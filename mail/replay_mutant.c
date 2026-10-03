/* A deliberately fixture-replaying adapter for testing the TEST HARNESS.
 * It is not an original program, parser, migration implementation, or oracle. */
#include "support.h"

int main(int argc,char **argv) {
    const char *root=getenv("AICI_REPLAY_CORPUS"),*mutation=getenv("AICI_MUTATION");
    if(argc!=4||!root)die("selftest-only: requires AICI_REPLAY_CORPUS");
    if(!mutation)mutation="none";
    if(!strcmp(mutation,"public-fixture-only")&&!strncmp(argv[2],"generated-",10)) return 10;
    char fixture[4096],p[4096],q[4096],line[1024];path_join(fixture,sizeof fixture,root,argv[2]);
    path_join(p,sizeof p,argv[3],"archive.bin");FILE *archive=open_file(p,"wb");
    if(!fgets(line,sizeof line,stdin)||strcmp(line,"MAIL-ACCEPT/1\n"))die("protocol-magic");
    if(!fgets(line,sizeof line,stdin)||strncmp(line,"base\t",5))die("protocol-base");
    line[strcspn(line,"\n")]=0;uint64_t base=number(line+5);const char *terminal="eof";
    unsigned char buffer[65536];uint64_t frames=0;int previous_cr=0;
    for(;;) {
        if(!fgets(line,sizeof line,stdin))die("transport-ended-without-eof");
        if(!strcmp(line,"eof\n")){if(!strcmp(mutation,"eof-error"))return 7;break;}
        if(!strcmp(line,"again\n")||!strcmp(line,"idle\n")) {
            if(!strcmp(mutation,"again-as-eof"))return 8;
            continue;
        }
        if(!strcmp(line,"error\tIO\n")){terminal=!strcmp(mutation,"error-as-eof")?"eof":"io-error";break;}
        if(strncmp(line,"data\t",5))die("protocol-frame");
        line[strcspn(line,"\n")]=0;uint64_t n=number(line+5),position=0;frames++;
        while(n) {
            size_t count=n>sizeof buffer?sizeof buffer:(size_t)n;
            if(fread(buffer,1,count,stdin)!=count)die("protocol-short-data");
            for(size_t i=0;i<count;i++,position++) {
                unsigned char c=buffer[i];
                if(!strcmp(mutation,"drop-boundary-byte")&&frames>1&&position==0)continue;
                if(!strcmp(mutation,"normalize-crlf")&&c=='\r')continue;
                if(!strcmp(mutation,"destructive-unfold")&&previous_cr&&c=='\n')continue;
                previous_cr=c=='\r';fputc(c,archive);
            }
            n-=count;
        }
        if(getchar()!='\n')die("protocol-delimiter");
    }
    if(fclose(archive))die("archive-close");
    if(!strcmp(terminal,"io-error")) {
        path_join(q,sizeof q,argv[3],"archive.bin");
        if(!strcmp(mutation,"complete-failed-input")) {
            path_join(p,sizeof p,fixture,"input.bin");copy_file(p,q);
        }
        if(!strcmp(mutation,"discard-failed-prefix"))write_bytes(q,"",0);
    }
    path_join(p,sizeof p,argv[3],"archive.bin");char digest[65];uint64_t length;hash_file(p,digest,&length);
    path_join(p,sizeof p,argv[3],"source.tsv");FILE *source=open_file(p,"wb");
    uint64_t start=base,finish=base+length;
    if(!strcmp(mutation,"offset32")){start=(uint32_t)start;finish=(uint32_t)finish;}
    fprintf(source,"%"PRIu64"\t%"PRIu64"\t%"PRIu64"\t%s\n",start,finish,length,digest);fclose(source);
    path_join(p,sizeof p,argv[3],"terminal.tsv");source=open_file(p,"wb");fprintf(source,"%s\n",terminal);fclose(source);
    path_join(p,sizeof p,fixture,"facts.tsv");path_join(q,sizeof q,argv[3],"facts.tsv");copy_file(p,q);
    path_join(p,sizeof p,fixture,"objects.tsv");FILE *objects=open_file(p,"rb");
    while(fgets(line,sizeof line,objects)) {
        char *tab=strchr(line,'\t');if(!tab)die("object-row");*tab=0;
        path_join(p,sizeof p,fixture,line);path_join(q,sizeof q,argv[3],line);copy_file(p,q);
    }
    fclose(objects);
    if(!strcmp(mutation,"decode-before-archive")) {
        path_join(p,sizeof p,fixture,"part-0.bin");path_join(q,sizeof q,argv[3],"archive.bin");
        struct stat st;if(!stat(p,&st))copy_file(p,q);
    }
    if(!strcmp(mutation,"decoded-byte")) {
        path_join(p,sizeof p,argv[3],"part-0.bin");FILE *f=fopen(p,"r+b");if(f){fputc('X',f);fclose(f);}
    }
    if(!strcmp(mutation,"missing-id")) {
        if(!strcmp(argv[2],"rfc-no-optional"))return 9;
    }
    if(!strcmp(mutation,"retry-unknown")&&!strncmp(argv[2],"crash-accepted",14)) {
        path_join(p,sizeof p,argv[3],"facts.tsv");const char *s="knowledge\tunknown\nretry\tsafe\ncomplete\tno\n";write_bytes(p,s,strlen(s));
    }
    if(!strcmp(mutation,"premature-success")&&!strcmp(argv[2],"crash-during-submit")) {
        path_join(p,sizeof p,argv[3],"facts.tsv");const char *s="knowledge\twritten\nretry\tunnecessary\ncomplete\tyes\n";write_bytes(p,s,strlen(s));
    }
    if(!strcmp(mutation,"lost-uncertainty")&&!strcmp(argv[2],"crash-ack-before-durable")) {
        path_join(p,sizeof p,argv[3],"facts.tsv");const char *s="knowledge\tnot-written\nretry\tsafe\ncomplete\tno\n";write_bytes(p,s,strlen(s));
    }
    if(!strcmp(mutation,"semantic-change")) {
        path_join(p,sizeof p,argv[3],"facts.tsv");FILE *f=open_file(p,"ab");fputs("invented\tvalue\n",f);fclose(f);
    }
    if(!strcmp(mutation,"merge-stdout-stderr")) {
        path_join(p,sizeof p,argv[3],"stdout.bin");FILE *f=open_file(p,"ab");fputs("ERR\r\n",f);fclose(f);
    }
    if(!strcmp(mutation,"ignore-exit")||!strcmp(mutation,"accept-any-key")||!strcmp(mutation,"tcp-is-auth")||!strcmp(mutation,"drop-duplicate-id")||!strcmp(mutation,"drop-identical-copy")||!strcmp(mutation,"corrupt-ledger-is-success")) {
        path_join(p,sizeof p,fixture,"facts.tsv");FILE *original=open_file(p,"rb");
        path_join(q,sizeof q,argv[3],"facts.tsv");FILE *changed=open_file(q,"wb");
        while(fgets(line,sizeof line,original)) {
            if(!strcmp(mutation,"ignore-exit")&&!strcmp(line,"exit\t23\n"))strcpy(line,"exit\t0\n");
            if(!strcmp(mutation,"accept-any-key")&&!strcmp(line,"host\trejected-mismatch\n"))strcpy(line,"host\tverified\n");
            if(!strcmp(mutation,"tcp-is-auth")&&!strcmp(line,"auth\tnot-established\n"))strcpy(line,"auth\tsuccess\n");
            if(!strcmp(mutation,"drop-duplicate-id")&&(!strncmp(line,"occurrence\t1\t",13)||!strncmp(line,"occurrence\t2\t",13)||!strncmp(line,"occurrence\t5\t",13)))continue;
            if(!strcmp(mutation,"drop-identical-copy")&&!strncmp(line,"occurrence\t2\t",13))continue;
            if(!strcmp(mutation,"corrupt-ledger-is-success")&&!strcmp(line,"knowledge\tunknown\n"))strcpy(line,"knowledge\twritten\n");
            fputs(line,changed);
        }
        fclose(original);fclose(changed);
    }
    return 0;
}
