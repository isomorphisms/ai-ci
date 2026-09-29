/* Acceptance orchestration and comparisons only. No mail parser lives here. */
#define _GNU_SOURCE
#include "support.h"
#include <fcntl.h>
#include <sys/resource.h>
#include <sys/wait.h>
#include <time.h>

static volatile sig_atomic_t active_child;
static void expired(int signal_number) {
    (void)signal_number;
    if(active_child>0) kill(-(pid_t)active_child,SIGKILL);
    _exit(124);
}
static int safe_name(const char *s) {
    if(!*s || strstr(s,"..")) return 0;
    for(;*s;s++) if(!((*s>='a'&&*s<='z')||(*s>='0'&&*s<='9')||*s=='-'||*s=='.'||*s=='_')) return 0;
    return 1;
}
/* Compare the supplied prefix, not the unread suffix, without trusting a
 * candidate digest or constructing parser-derived expected answers. */
static int input_prefix(const char *input,const char *archive,uint64_t supplied,char digest[65],uint64_t *length) {
    struct stat st;if(lstat(archive,&st)||!S_ISREG(st.st_mode))return 0;
    FILE *in=open_file(input,"rb"),*got=open_file(archive,"rb");
    EVP_MD_CTX *ctx=EVP_MD_CTX_new();unsigned char a[65536],b[65536],hash[EVP_MAX_MD_SIZE];unsigned hash_size;
    if(!ctx||EVP_DigestInit_ex(ctx,EVP_sha256(),NULL)!=1)die("prefix-hash-init");
    *length=0;int equal=1;
    while(*length<supplied) {
        size_t count=supplied-*length>sizeof a?sizeof a:(size_t)(supplied-*length);
        size_t n=fread(a,1,count,in);
        if(ferror(in))die("prefix-input-read");
        if(!n)break;
        if(fread(b,1,n,got)!=n||memcmp(a,b,n))equal=0;
        if(EVP_DigestUpdate(ctx,a,n)!=1)die("prefix-hash-update");
        *length+=n;
    }
    if(supplied!=UINT64_MAX&&*length!=supplied)die("prefix-beyond-input");
    if(fgetc(got)!=EOF||ferror(got))equal=0;
    if(EVP_DigestFinal_ex(ctx,hash,&hash_size)!=1||hash_size!=32)die("prefix-hash-finish");
    for(unsigned i=0;i<hash_size;i++)sprintf(digest+2*i,"%02x",hash[i]);
    digest[64]=0;EVP_MD_CTX_free(ctx);fclose(in);fclose(got);return equal;
}
static int check(const char *fixture,const char *out,int semantic,uint64_t base,const char *terminal,uint64_t supplied) {
    char a[4096],b[4096],line[1024];
    path_join(a,sizeof a,fixture,"input.bin");path_join(b,sizeof b,out,"archive.bin");
    char digest[65],expected[256];uint64_t length;
    if(!input_prefix(a,b,supplied,digest,&length))return 10;
    if(UINT64_MAX-base<length)die("span-overflow");
    snprintf(expected,sizeof expected,"%"PRIu64"\t%"PRIu64"\t%"PRIu64"\t%s\n",base,base+length,length,digest);
    path_join(b,sizeof b,out,"source.tsv");FILE *source=fopen(b,"rb");
    if(!source)return 14;
    int ok=fgets(line,sizeof line,source)!=NULL&&!strcmp(line,expected)&&fgetc(source)==EOF;fclose(source);
    if(!ok)return 14;
    path_join(b,sizeof b,out,"terminal.tsv");source=fopen(b,"rb");if(!source)return 15;
    snprintf(expected,sizeof expected,"%s\n",terminal);
    ok=fgets(line,sizeof line,source)!=NULL&&!strcmp(line,expected)&&fgetc(source)==EOF;fclose(source);
    if(!ok)return 15;
    if(!semantic) return 0;
    path_join(a,sizeof a,fixture,"facts.tsv");path_join(b,sizeof b,out,"facts.tsv");
    if(!same_file(a,b)) return 11;
    path_join(a,sizeof a,fixture,"objects.tsv");FILE *f=open_file(a,"rb");
    while(fgets(line,sizeof line,f)) {
        char *tab=strchr(line,'\t');if(!tab) die("object-manifest");*tab=0;
        if(!safe_name(line)) die("object-path");
        path_join(a,sizeof a,fixture,line);path_join(b,sizeof b,out,line);
        if(!same_file(a,b)){fclose(f);return 12;}
    }
    if(ferror(f)) die("object-manifest-read");
    fclose(f);return 0;
}
static const char *diagnostic(int n) {
    switch(n){case 0:return "accepted-observations";case 10:return "raw-byte-corruption";
    case 11:return "semantic-or-state-mismatch";case 12:return "decoded-content-corruption";
    case 13:return "adapter-failed";case 14:return "source-span-mismatch";
    case 15:return "terminal-event-mismatch";default:return "harness-failure";}
}
/* Schedules are portable integer algorithms. A DATA frame, not a pipe write,
 * defines one feed call. The same bytes and schedule reach every language. */
static size_t chunk_size(const char *schedule,uint64_t position,uint64_t length,uint32_t *rng) {
    uint64_t n=0;
    if(!strcmp(schedule,"whole")) n=length-position;
    else if(!strcmp(schedule,"one")||!strcmp(schedule,"read-error")||!strcmp(schedule,"pauses")) n=1;
    else if(!strcmp(schedule,"random")) {*rng=*rng*UINT32_C(1664525)+UINT32_C(1013904223);n=1+*rng%31;}
    else if(!strncmp(schedule,"cut-",4)) {uint64_t cut=number(schedule+4);n=position<cut?cut-position:length-position;}
    else n=number(schedule);
    if(n>length-position)n=length-position;
    if(n>65536)n=65536; /* whole is one frame, streamed through a bounded producer below */
    return (size_t)n;
}
static int invoke(const char *fixture,const char *adapter,const char *op,const char *id,const char *schedule,const char *out,uint64_t base,uint64_t *rss) {
    int pipes[2];char inpath[4096],p[4096],executable_hash[65];uint64_t size,executable_size;
    path_join(inpath,sizeof inpath,fixture,"input.bin");char h[65];hash_file(inpath,h,&size);
    int interrupted=!strncmp(schedule,"error-at-",9);
    uint64_t supplied=interrupted?number(schedule+9):size;
    if(supplied>size)die("interruption-beyond-input");
    hash_file(adapter,executable_hash,&executable_size);
    directory(out);
    /* Self-test receipts may be regenerated in the same BUILD directory.  Only
     * these controller-owned capture names require exclusive creation below. */
    path_join(p,sizeof p,out,"stdout.txt");if(unlink(p)&&errno!=ENOENT)die("remove-old-stdout");
    path_join(p,sizeof p,out,"stderr.txt");if(unlink(p)&&errno!=ENOENT)die("remove-old-stderr");
    if(pipe(pipes))die("pipe");
    pid_t child=fork();if(child<0)die("fork");
    if(child==0) {
        setpgid(0,0);close(pipes[1]);if(dup2(pipes[0],STDIN_FILENO)<0)_exit(125);close(pipes[0]);
        path_join(p,sizeof p,out,"stdout.txt");int fd=open(p,O_WRONLY|O_CREAT|O_EXCL,0600);if(fd<0)_exit(125);dup2(fd,1);close(fd);
        path_join(p,sizeof p,out,"stderr.txt");fd=open(p,O_WRONLY|O_CREAT|O_EXCL,0600);if(fd<0)_exit(125);dup2(fd,2);close(fd);
        struct rlimit limit={16*1024*1024,16*1024*1024};setrlimit(RLIMIT_FSIZE,&limit);
        limit.rlim_cur=limit.rlim_max=30;setrlimit(RLIMIT_CPU,&limit);
        execl(adapter,adapter,op,id,out,(char *)NULL);_exit(126);
    }
    setpgid(child,child);active_child=child;alarm(45);close(pipes[0]);
    FILE *to=fdopen(pipes[1],"wb"),*from=open_file(inpath,"rb");if(!to)die("fdopen");
    fprintf(to,"MAIL-ACCEPT/1\nbase\t%"PRIu64"\n",base);
    uint64_t pos=0;uint32_t rng=UINT32_C(0x4d41494c);unsigned char buffer[65536];
    while(pos<supplied) {
        if(!strcmp(schedule,"pauses")) fputs("again\nidle\n",to);
        uint64_t count=!strcmp(schedule,"whole")?supplied-pos:chunk_size(interrupted?"random":schedule,pos,supplied,&rng);
        fprintf(to,"data\t%"PRIu64"\n",count);
        while(count) {
            size_t n=count>sizeof buffer?sizeof buffer:(size_t)count;
            if(fread(buffer,1,n,from)!=n)die("fixture-short-read");
            if(fwrite(buffer,1,n,to)!=n)break;
            pos+=n;count-=n;
        }
        if(ferror(to))break;
        fputc('\n',to);fflush(to);
    }
    fprintf(to,"%s\n",interrupted||!strcmp(schedule,"read-error")?"error\tIO":"eof");int send_failed=fclose(to)!=0;fclose(from);
    int status=0;struct rusage usage;
    if(wait4(child,&status,0,&usage)<0)die("wait-adapter");
    alarm(0);active_child=0;
    *rss=(uint64_t)usage.ru_maxrss;
    char after_hash[65];uint64_t after_size;hash_file(adapter,after_hash,&after_size);
    if(strcmp(after_hash,executable_hash)||after_size!=executable_size)send_failed=1;
    path_join(p,sizeof p,out,"execution.tsv");FILE *receipt=open_file(p,"wb");
    fprintf(receipt,"evidence\thost-adapter-process\nexecutable\t%s\nsha256\t%s\ninput-sha256\t%s\nschedule\t%s\nbase\t%"PRIu64"\nsupplied-bytes\t%"PRIu64"\npeak-rss-platform-units\t%"PRIu64"\nwait-status\t%d\n",adapter,executable_hash,h,schedule,base,pos,*rss,status);fclose(receipt);
    return send_failed||!WIFEXITED(status)||WEXITSTATUS(status)!=0?13:0;
}
static int run(const char *root,const char *adapter,const char *output,int exhaustive) {
    char p[4096],line[2048];directory(output);path_join(p,sizeof p,root,"cases.tsv");FILE *catalog=open_file(p,"rb");
    if(!fgets(line,sizeof line,catalog)||strcmp(line,"case\toperation\tstatus\tevidence\tpurpose\n"))die("catalog-header");
    int failed=0,blocked=0,runs=0;FILE *matrix;
    path_join(p,sizeof p,output,"matrix.tsv");matrix=open_file(p,"wb");fprintf(matrix,"case\tschedule\tresult\tdiagnostic\n");
    while(fgets(line,sizeof line,catalog)) {
        char *save=NULL,*id=strtok_r(line,"\t",&save),*op=strtok_r(NULL,"\t",&save),*state=strtok_r(NULL,"\t",&save);
        if(!id||!op||!state||!safe_name(id))die("catalog-row");
        if(strcmp(state,"SPEC")&&strcmp(state,"POLICY")&&strcmp(state,"UNRESOLVED"))die("unknown-case-status");
        char fixture[4096],caseout[4096];path_join(fixture,sizeof fixture,root,id);path_join(caseout,sizeof caseout,output,id);directory(caseout);
        path_join(p,sizeof p,fixture,"input.bin");char hash[65];uint64_t size;hash_file(p,hash,&size);
        int semantic=strcmp(state,"UNRESOLVED")!=0;if(!semantic)blocked++;
        const char *fixed[]={"whole","one","2","3","7","17","31","random"};
        uint64_t cuts=exhaustive && size<4096?size-!!size:0;
        for(uint64_t i=0;i<8+cuts;i++) {
            char schedule[64];if(i<8)snprintf(schedule,sizeof schedule,"%s",fixed[i]);else snprintf(schedule,sizeof schedule,"cut-%"PRIu64,i-7);
            char out[4096];path_join(out,sizeof out,caseout,schedule);uint64_t rss;
            int verdict=invoke(fixture,adapter,op,id,schedule,out,0,&rss);
            if(!verdict)verdict=check(fixture,out,semantic,0,"eof",UINT64_MAX);
            fprintf(matrix,"%s\t%s\t%s\t%s\n",id,schedule,verdict?"FAIL":semantic?"PASS_OBSERVATIONS":"BYTES_ONLY_UNRESOLVED",diagnostic(verdict));
            if(verdict)failed++;
            runs++;
        }
    }
    if(ferror(catalog))die("catalog-read");
    fclose(catalog);fclose(matrix);
    if(!runs)die("empty-corpus");
    printf("runs\t%d\nfailures\t%d\nunresolved-cases\t%d\n",runs,failed,blocked);
    return failed?1:blocked?2:0;
}
static int interruptions(const char *root,const char *adapter,const char *output) {
    char p[4096],line[2048];directory(output);path_join(p,sizeof p,root,"cases.tsv");FILE *catalog=open_file(p,"rb");
    if(!fgets(line,sizeof line,catalog)||strcmp(line,"case\toperation\tstatus\tevidence\tpurpose\n"))die("catalog-header");
    path_join(p,sizeof p,output,"matrix.tsv");FILE *matrix=open_file(p,"wb");
    fprintf(matrix,"case\tschedule\tresult\tdiagnostic\n");int failed=0,runs=0;
    while(fgets(line,sizeof line,catalog)) {
        char *save=NULL,*id=strtok_r(line,"\t",&save),*op=strtok_r(NULL,"\t",&save);
        if(!id||!op||!safe_name(id))die("catalog-row");
        if(strcmp(op,"mbox")&&strcmp(op,"rfc")&&strcmp(op,"mime"))continue;
        char fixture[4096],caseout[4096],hash[65];uint64_t size;
        path_join(fixture,sizeof fixture,root,id);path_join(p,sizeof p,fixture,"input.bin");hash_file(p,hash,&size);
        path_join(caseout,sizeof caseout,output,id);directory(caseout);
        uint64_t count=size<4096?size+1:5;
        for(uint64_t i=0;i<count;i++) {
            uint64_t supplied=size<4096?i:i==0?0:i==1?1:i==2?size/2:i==3?size-1:size;
            char schedule[64],out[4096];snprintf(schedule,sizeof schedule,"error-at-%"PRIu64,supplied);
            path_join(out,sizeof out,caseout,schedule);uint64_t rss;
            int code=invoke(fixture,adapter,op,id,schedule,out,0,&rss);
            if(!code)code=check(fixture,out,0,0,"io-error",supplied);
            fprintf(matrix,"%s\t%s\t%s\t%s\n",id,schedule,code?"FAIL":"PASS_PREFIX_ONLY",diagnostic(code));
            failed+=code!=0;runs++;
        }
    }
    if(ferror(catalog))die("catalog-read");
    fclose(catalog);fclose(matrix);if(!runs)die("no-stream-cases");
    printf("interruption-runs\t%d\ninterruption-failures\t%d\n",runs,failed);return failed?1:0;
}
static void generate_holdout(const char *generator,const char *output,uint32_t seed,unsigned count) {
    char before[65],after[65],seed_text[16],count_text[16];uint64_t before_size,after_size;
    if(generator[0]!='/')die("generator-not-absolute");
    hash_file(generator,before,&before_size);
    snprintf(seed_text,sizeof seed_text,"%"PRIu32,seed);
    snprintf(count_text,sizeof count_text,"%u",count);
    pid_t child=fork();if(child<0)die("generator-fork");
    if(child==0) {
        setpgid(0,0);
        execl(generator,generator,"--generated-only",output,seed_text,count_text,(char *)NULL);
        _exit(126);
    }
    setpgid(child,child);active_child=child;alarm(45);
    int status=0;if(waitpid(child,&status,0)<0)die("wait-generator");
    alarm(0);active_child=0;
    hash_file(generator,after,&after_size);
    if(strcmp(before,after)||before_size!=after_size)die("generator-changed");
    if(!WIFEXITED(status)||WEXITSTATUS(status)!=0)die("generator-failed");
}
static uint32_t fresh_seed(void) {
    uint32_t seed;unsigned char *p=(unsigned char *)&seed;size_t at=0;
    int fd=open("/dev/urandom",O_RDONLY);if(fd<0)die("open-random");
    while(at<sizeof seed) {
        ssize_t n=read(fd,p+at,sizeof seed-at);
        if(n<0&&errno==EINTR)continue;
        if(n<=0)die("read-random");
        at+=(size_t)n;
    }
    if(close(fd))die("close-random");
    return seed;
}
static int challenge(const char *generator,const char *adapter,const char *output,uint32_t seed,unsigned count) {
    if(!count||count>64)die("challenge-count");
    char corpus[4096],receipts[4096],record[4096],generator_hash[65],adapter_hash[65];
    uint64_t generator_size,adapter_size;
    directory(output);path_join(corpus,sizeof corpus,output,"corpus");
    hash_file(generator,generator_hash,&generator_size);hash_file(adapter,adapter_hash,&adapter_size);
    generate_holdout(generator,corpus,seed,count);
    path_join(receipts,sizeof receipts,output,"receipts");int result=run(corpus,adapter,receipts,1);
    path_join(record,sizeof record,output,"challenge.tsv");FILE *f=open_file(record,"wb");
    fprintf(f,"evidence\tgenerated-rfc-holdout\nseed\t%"PRIu32"\ncase-count\t%u\ngenerator\t%s\ngenerator-sha256\t%s\nadapter\t%s\nadapter-sha256\t%s\nresult\t%d\n",seed,count,generator,generator_hash,adapter,adapter_hash,result);
    fclose(f);return result;
}
static int self_test(const char *root,const char *generator,const char *adapter,const char *output) {
    struct mutation {const char *name,*fixture,*schedule;int want;uint64_t base;} tests[]={
        {"none","rfc-folded-repeated","one",0,0},
        {"none","mime-base64","random",0,0},
        {"none","rfc-no-optional","read-error",0,0},
        {"none","rfc-no-optional","pauses",0,0},
        {"none","rfc-ordinary","3",0,UINT64_C(4294967293)},
        {"none","rfc-ordinary","error-at-0",0,0},
        {"none","rfc-ordinary","error-at-1",0,0},
        {"none","mime-base64","error-at-17",0,UINT64_C(4294967293)},
        {"error-as-eof","rfc-ordinary","error-at-0",15,0},
        {"error-as-eof","mime-base64","error-at-17",15,0},
        {"complete-failed-input","mime-base64","error-at-17",10,0},
        {"discard-failed-prefix","mime-base64","error-at-17",10,0},
        {"offset32","mime-base64","error-at-17",14,UINT64_C(4294967293)},
        {"drop-boundary-byte","rfc-ordinary","one",10,0},
        {"normalize-crlf","rfc-ordinary","whole",10,0},
        {"destructive-unfold","rfc-folded-repeated","3",10,0},
        {"decode-before-archive","mime-base64","7",10,0},
        {"decoded-byte","mime-base64","whole",12,0},
        {"eof-error","rfc-ordinary","whole",13,0},
        {"error-as-eof","rfc-ordinary","read-error",15,0},
        {"again-as-eof","rfc-ordinary","pauses",13,0},
        {"offset32","rfc-ordinary","3",14,UINT64_C(4294967293)},
        {"missing-id","rfc-no-optional","one",13,0},
        {"retry-unknown","crash-accepted-ack-lost","whole",11,0},
        {"premature-success","crash-during-submit","whole",11,0},
        {"lost-uncertainty","crash-ack-before-durable","whole",11,0},
        {"merge-stdout-stderr","ssh-success","one",12,0},
        {"ignore-exit","ssh-success","whole",11,0},
        {"accept-any-key","ssh-host-mismatch","whole",11,0},
        {"tcp-is-auth","ssh-tcp-only","whole",11,0},
        {"drop-duplicate-id","identity-collisions","whole",11,0},
        {"drop-identical-copy","identity-collisions","whole",11,0},
        {"corrupt-ledger-is-success","restart-corrupt-tail","whole",11,0},
        {"semantic-change","rfc-ordinary","whole",11,0}
    };
    directory(output);setenv("AICI_REPLAY_CORPUS",root,1);int failed=0;
    char report[4096];path_join(report,sizeof report,output,"mutations.tsv");FILE *f=open_file(report,"wb");
    fprintf(f,"mutation\tcase\tschedule\texpected-code\tactual-code\tdiagnostic\tresult\n");
    for(size_t i=0;i<sizeof tests/sizeof *tests;i++) {
        char fixture[4096],out[4096],name[128];path_join(fixture,sizeof fixture,root,tests[i].fixture);
        snprintf(name,sizeof name,"%zu-%s",i,tests[i].name);path_join(out,sizeof out,output,name);
        setenv("AICI_MUTATION",tests[i].name,1);uint64_t rss;
        const char *op=!strncmp(tests[i].fixture,"crash",5)?"migration":!strncmp(tests[i].fixture,"mime",4)?"mime":"rfc";
        int code=invoke(fixture,adapter,op,tests[i].fixture,tests[i].schedule,out,tests[i].base,&rss);
        int partial=!strncmp(tests[i].schedule,"error-at-",9);
        int error=partial||!strcmp(tests[i].schedule,"read-error");
        if(!code)code=check(fixture,out,!error,tests[i].base,error?"io-error":"eof",partial?number(tests[i].schedule+9):UINT64_MAX);
        int good=code==tests[i].want;failed+=!good;
        fprintf(f,"%s\t%s\t%s\t%d\t%d\t%s\t%s\n",tests[i].name,tests[i].fixture,tests[i].schedule,tests[i].want,code,diagnostic(code),good?"PASS":"FAIL");
    }
    char interruption_out[4096];path_join(interruption_out,sizeof interruption_out,output,"interruptions");
    setenv("AICI_MUTATION","none",1);
    int interruption_result=interruptions(root,adapter,interruption_out);
    failed+=interruption_result!=0;
    fprintf(f,"interruption-control\tstream-corpus\terror-at-every-cut\t0\t%d\tprefix-and-failure-control\t%s\n",interruption_result,interruption_result?"FAIL":"PASS");
    char holdout[4096],holdout_root[4096];
    path_join(holdout,sizeof holdout,output,"holdout-good");path_join(holdout_root,sizeof holdout_root,holdout,"corpus");
    setenv("AICI_REPLAY_CORPUS",holdout_root,1);setenv("AICI_MUTATION","none",1);
    int code=challenge(generator,adapter,holdout,UINT32_C(305419896),4);
    int good=code==0;failed+=!good;
    fprintf(f,"generated-holdout\tgenerated-rfc\texhaustive\t0\t%d\t%s\t%s\n",code,"generated-spec-holdout",good?"PASS":"FAIL");
    path_join(holdout,sizeof holdout,output,"holdout-unrecognized");path_join(holdout_root,sizeof holdout_root,holdout,"corpus");
    setenv("AICI_REPLAY_CORPUS",holdout_root,1);setenv("AICI_MUTATION","public-fixture-only",1);
    code=challenge(generator,adapter,holdout,UINT32_C(305419896),4);
    good=code==1;failed+=!good;
    fprintf(f,"public-fixture-only\tgenerated-rfc\texhaustive\t1\t%d\t%s\t%s\n",code,"holdout-case-unrecognized",good?"PASS":"FAIL");
    fclose(f);unsetenv("AICI_MUTATION");unsetenv("AICI_REPLAY_CORPUS");
    printf("harness-mutation-selftest\t%s\n",failed?"FAIL":"PASS");return failed?1:0;
}
static int differential(const char *corpus,const char *registry,const char *output) {
    directory(output);FILE *r=open_file(registry,"rb");char line[4096],path[4096];
    path_join(path,sizeof path,output,"differential.tsv");FILE *matrix=open_file(path,"wb");
    fprintf(matrix,"case\tlanguage\tschedule\tresult\tdiagnostic\n");
    if(!fgets(line,sizeof line,r))die("empty-adapter-registry");
    int failed=0,unknown=0,count=0;
    while(fgets(line,sizeof line,r)) {
        line[strcspn(line,"\n")]=0;char *save=NULL,*language=strtok_r(line,"\t",&save),*repo=strtok_r(NULL,"\t",&save),*commit=strtok_r(NULL,"\t",&save),*executable=strtok_r(NULL,"\t",&save),*wanted=strtok_r(NULL,"\t",&save);
        if(!language||!repo||!commit||!executable||!wanted||!safe_name(language))die("adapter-registry-row");
        count++;
        if(!strcmp(executable,"-")) {
            char cp[4096],cl[2048];path_join(cp,sizeof cp,corpus,"cases.tsv");FILE *c=open_file(cp,"rb");
            if(!fgets(cl,sizeof cl,c))die("empty-corpus");
            while(fgets(cl,sizeof cl,c)){char *tab=strchr(cl,'\t');if(!tab)die("case-row");*tab=0;fprintf(matrix,"%s\t%s\t-\tNOT_RUN\tadapter-unavailable\n",cl,language);}fclose(c);unknown++;continue;
        }
        if(strlen(commit)!=40||strspn(commit,"0123456789abcdef")!=40||strlen(wanted)!=64||executable[0]!='/')die("adapter-identity");
        char actual[65];uint64_t n;hash_file(executable,actual,&n);if(strcmp(actual,wanted))die("adapter-digest-mismatch");
        char childout[4096];path_join(childout,sizeof childout,output,language);
        int result=run(corpus,executable,childout,0);failed+=result==1;unknown+=result==2;
        path_join(path,sizeof path,childout,"identity.tsv");FILE *identity=open_file(path,"wb");fprintf(identity,"repository\t%s\nsource-commit\t%s\nexecutable-sha256\t%s\n",repo,commit,actual);fclose(identity);
        path_join(path,sizeof path,childout,"matrix.tsv");FILE *rows=open_file(path,"rb");if(!fgets(line,sizeof line,rows))die("missing-matrix");
        while(fgets(line,sizeof line,rows)){char *tab=strchr(line,'\t');if(!tab)die("matrix-row");*tab=0;fprintf(matrix,"%s\t%s\t%s",line,language,tab+1);}fclose(rows);
        path_join(path,sizeof path,childout,"interruptions");
        failed+=interruptions(corpus,executable,path)!=0;
        char interruption_matrix[4096];path_join(interruption_matrix,sizeof interruption_matrix,path,"matrix.tsv");
        rows=open_file(interruption_matrix,"rb");if(!fgets(line,sizeof line,rows))die("missing-interruption-matrix");
        while(fgets(line,sizeof line,rows)){char *tab=strchr(line,'\t');if(!tab)die("matrix-row");*tab=0;fprintf(matrix,"%s\t%s\t%s",line,language,tab+1);}fclose(rows);
    }
    fclose(r);fclose(matrix);if(!count)die("no-adapters");return failed?1:unknown?2:0;
}
int main(int argc,char **argv) {
    signal(SIGALRM,expired);signal(SIGPIPE,SIG_IGN);
    if(argc==5&&!strcmp(argv[1],"check")) {
        int code=check(argv[2],argv[3],strcmp(argv[4],"bytes")!=0,0,"eof",UINT64_MAX);printf("%s\n",diagnostic(code));return code;
    }
    if(argc==6&&!strcmp(argv[1],"self-test"))return self_test(argv[2],argv[3],argv[4],argv[5]);
    if(argc==5&&!strcmp(argv[1],"differential"))return differential(argv[2],argv[3],argv[4]);
    if(argc==5&&!strcmp(argv[1],"interrupt"))return interruptions(argv[2],argv[3],argv[4]);
    if((argc==5||argc==6)&&!strcmp(argv[1],"run"))return run(argv[2],argv[3],argv[4],argc==6&&!strcmp(argv[5],"exhaustive"));
    if((argc==5||argc==7)&&!strcmp(argv[1],"challenge")) {
        uint64_t chosen_seed=argc==7?number(argv[5]):fresh_seed();
        uint64_t chosen_count=argc==7?number(argv[6]):16;
        if(chosen_seed>UINT32_MAX||!chosen_count||chosen_count>64)die("challenge-bounds");
        return challenge(argv[2],argv[3],argv[4],(uint32_t)chosen_seed,(unsigned)chosen_count);
    }
    die("usage: accept run CORPUS ABSOLUTE-ADAPTER NEW-OUTPUT [exhaustive] | interrupt CORPUS ABSOLUTE-ADAPTER NEW-OUTPUT | accept challenge ABSOLUTE-GENERATOR ABSOLUTE-ADAPTER NEW-OUTPUT [SEED COUNT] | check FIXTURE OUTPUT semantic|bytes");
}
