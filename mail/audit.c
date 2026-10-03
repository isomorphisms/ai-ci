/* Corpus self-consistency and independently justified metamorphic relations. */
#include "support.h"
static void verify_manifest(const char *dir,const char *manifest,int source) {
    char p[4096],line[2048];path_join(p,sizeof p,dir,manifest);FILE *f=open_file(p,"rb");int rows=0;
    while(fgets(line,sizeof line,f)) {
        char *save=NULL,*first=strtok_r(line,"\t",&save),*second=strtok_r(NULL,"\t",&save),*third=strtok_r(NULL,"\t\n",&save);
        if(!first||!second||!third)die("manifest-schema");
        const char *filename=source?"input.bin":first,*digest=third;uint64_t length=number(second);
        if(source){digest=strtok_r(NULL,"\t\n",&save);if(!digest||strcmp(first,"0")||number(third)!=length)die("source-manifest-span");}
        path_join(p,sizeof p,dir,filename);char h[65];uint64_t size;hash_file(p,h,&size);
        if(size!=length||strcmp(h,digest))die("manifest-bytes-or-digest");
        rows++;
    }
    if(ferror(f))die("manifest-read");
    fclose(f);if(source&&rows!=1)die("source-manifest-count");
}
static void relation(const char *root,const char *left,const char *right,int equal,const char *name) {
    char a[4096],b[4096];path_join(a,sizeof a,root,left);path_join(b,sizeof b,root,right);
    if(same_file(a,b)!=equal)die(name);
    printf("PASS\t%s\n",name);
}
int main(int argc,char **argv) {
    if(argc!=2)die("usage: audit CORPUS");
    char p[4096],line[2048];path_join(p,sizeof p,argv[1],"cases.tsv");FILE *f=open_file(p,"rb");
    if(!fgets(line,sizeof line,f))die("empty-catalog");
    int count=0;
    while(fgets(line,sizeof line,f)){char *tab=strchr(line,'\t');if(!tab)die("case-schema");*tab=0;path_join(p,sizeof p,argv[1],line);verify_manifest(p,"source.tsv",1);verify_manifest(p,"objects.tsv",0);count++;}
    if(ferror(f))die("catalog-read");
    fclose(f);if(!count)die("empty-corpus");
    relation(argv[1],"mime-plain/part-0.bin","mime-base64/part-0.bin",1,"encoding-equivalence");
    relation(argv[1],"mime-plain/part-0.bin","mime-qp/part-0.bin",1,"qp-equivalence");
    relation(argv[1],"mime-base64/part-0.bin","mime-base64-wrapped/part-0.bin",1,"base64-line-wrap-equivalence");
    relation(argv[1],"mime-base64/input.bin","mime-base64-wrapped/input.bin",0,"encoded-bytes-distinct");
    relation(argv[1],"mime-plain/part-0.bin","mime-html/part-0.bin",0,"text-html-not-byte-equal");
    relation(argv[1],"crash-accepted-ack-lost/facts.tsv","crash-not-accepted-ack-lost/facts.tsv",1,"hidden-world-indistinguishability");
    relation(argv[1],"crash-after-durable/facts.tsv","crash-ack-before-durable/facts.tsv",0,"durable-not-volatile");
    relation(argv[1],"identity-collisions/message-0.bin","identity-collisions/message-2.bin",1,"same-content-different-source");
    relation(argv[1],"identity-collisions/message-0.bin","identity-collisions/message-1.bin",0,"same-id-different-content");
    printf("audited-cases\t%d\n",count);return 0;
}
