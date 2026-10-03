/* Deterministic source and resource probe. Not an mbox framing implementation. */
#define _GNU_SOURCE
#include "../support.h"
#include <sys/resource.h>
#include <sys/wait.h>

static volatile sig_atomic_t child_pid;
static void timeout(int sig) {(void)sig;if(child_pid>0)kill(-(pid_t)child_pid,SIGKILL);_exit(124);}
static void digest_finish(EVP_MD_CTX *ctx,char h[65]) {
    unsigned char d[32];unsigned n;if(EVP_DigestFinal_ex(ctx,d,&n)!=1||n!=32)die("digest");
    for(unsigned i=0;i<n;i++)sprintf(h+2*i,"%02x",d[i]);
    h[64]=0;EVP_MD_CTX_free(ctx);
}
static int produce(FILE *out,uint64_t count,const char *mode,char hash[65]) {
    const char *prefix="From source@example.invalid Mon Sep 28 12:00:00 2026\nDate: Mon, 28 Sep 2026 12:00:00 +0000\nFrom: source@example.invalid\nSubject: synthetic large input\n\n";
    const char *many="From source@example.invalid Mon Sep 28 12:00:00 2026\nSubject: repeated tiny message\n\nx\n\n";
    const char *unit=!strcmp(mode,"many")?many:"0123456789abcdef0123456789abcdef\n";
    size_t plen=strlen(prefix),ulen=strlen(unit);unsigned char b[65536];uint64_t done=0;
    EVP_MD_CTX *ctx=EVP_MD_CTX_new();if(!ctx||EVP_DigestInit_ex(ctx,EVP_sha256(),NULL)!=1)die("digest-init");
    while(done<count) {
        size_t n=count-done>sizeof b?sizeof b:(size_t)(count-done);
        for(size_t i=0;i<n;i++) {
            uint64_t at=done+i;
            b[i]=(unsigned char)(!strcmp(mode,"single")&&at<plen?prefix[at]:unit[(!strcmp(mode,"single")?at-plen:at)%ulen]);
        }
        if(fwrite(b,1,n,out)!=n){digest_finish(ctx,hash);return 0;}
        if(EVP_DigestUpdate(ctx,b,n)!=1)die("large-digest");
        done+=n;
    }
    int ok=fflush(out)==0;digest_finish(ctx,hash);return ok;
}
static int probe(const char *mode) {
    unsigned char buffer[65536];unsigned char *all=NULL;uint64_t total=0;size_t n;
    EVP_MD_CTX *ctx=EVP_MD_CTX_new();if(!ctx||EVP_DigestInit_ex(ctx,EVP_sha256(),NULL)!=1)die("digest-init");
    while((n=fread(buffer,1,sizeof buffer,stdin))) {
        if(!strcmp(mode,"probe-buffer")) {
            unsigned char *next=realloc(all,(size_t)(total+n));if(!next){free(all);return 21;}all=next;memcpy(all+total,buffer,n);
        }
        if(EVP_DigestUpdate(ctx,buffer,n)!=1)die("probe-digest");
        total+=n;
    }
    if(ferror(stdin))die("probe-read");
    free(all);char h[65];digest_finish(ctx,h);
    if(!strcmp(mode,"probe-offset32"))total=(uint32_t)total;
    printf("%"PRIu64"\t%s\n",total,h);return 0;
}
int main(int argc,char **argv) {
    if(argc==2&&!strncmp(argv[1],"probe-",6))return probe(argv[1]);
    if(argc==4&&!strcmp(argv[1],"emit")){char h[65];int ok=produce(stdout,number(argv[3]),argv[2],h);fprintf(stderr,"sha256\t%s\n",h);return ok?0:1;}
    if(argc!=8||strcmp(argv[1],"check"))die("usage: large emit single|many BYTES | check ADAPTER ARG single|many BYTES MEMORY-MIB NEW-RECEIPT");
    uint64_t count=number(argv[5]),mib=number(argv[6]);if(!mib||mib>UINT64_MAX/(1024*1024))die("memory-limit");
    if(strcmp(argv[4],"single")&&strcmp(argv[4],"many"))die("large-mode");
    int in[2],out[2];if(pipe(in)||pipe(out))die("pipe");
    signal(SIGALRM,timeout);signal(SIGPIPE,SIG_IGN);pid_t child=fork();if(child<0)die("fork");
    if(child==0) {
        setpgid(0,0);dup2(in[0],0);dup2(out[1],1);close(in[0]);close(in[1]);close(out[0]);close(out[1]);
        struct rlimit limit={(rlim_t)(mib*1024*1024),(rlim_t)(mib*1024*1024)};if(setrlimit(RLIMIT_AS,&limit))_exit(125);
        execl(argv[2],argv[2],argv[3],(char *)NULL);_exit(126);
    }
    setpgid(child,child);child_pid=child;alarm(180);close(in[0]);close(out[1]);
    FILE *to=fdopen(in[1],"wb"),*from=fdopen(out[0],"rb");if(!to||!from)die("fdopen");
    char expected_hash[65];int produced=produce(to,count,argv[4],expected_hash);int send_error=fclose(to)!=0||!produced;
    char answer[256]="",expected[256];int got=fgets(answer,sizeof answer,from)!=NULL;int extra=fgetc(from);fclose(from);
    int status;struct rusage usage;if(wait4(child,&status,0,&usage)<0)die("wait");alarm(0);child_pid=0;
    snprintf(expected,sizeof expected,"%"PRIu64"\t%s\n",count,expected_hash);
    int pass=!send_error&&got&&extra==EOF&&!strcmp(answer,expected)&&WIFEXITED(status)&&WEXITSTATUS(status)==0;
    FILE *f=open_file(argv[7],"wb");char executable_hash[65];uint64_t executable_size;hash_file(argv[2],executable_hash,&executable_size);
    fprintf(f,"result\t%s\nevidence\tbounded-byte-stream-probe\nrequested-bytes\t%"PRIu64"\nproducer-completed\t%s\nshape\t%s\nproduced-prefix-sha256\t%s\nadapter-sha256\t%s\naddress-space-limit-mib\t%"PRIu64"\npeak-rss-linux-kib\t%ld\nwait-status\t%d\n",pass?"PASS":"FAIL",count,produced?"yes":"no",argv[4],expected_hash,executable_hash,mib,usage.ru_maxrss,status);fclose(f);
    return pass?0:1;
}
