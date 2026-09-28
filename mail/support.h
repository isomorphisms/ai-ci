#ifndef AICI_MAIL_SUPPORT_H
#define AICI_MAIL_SUPPORT_H
#define _POSIX_C_SOURCE 200809L
#include <errno.h>
#include <inttypes.h>
#include <limits.h>
#include <openssl/evp.h>
#include <signal.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

static inline void die(const char *s) { fprintf(stderr, "FAIL\t%s\n", s); exit(1); }
static inline FILE *open_file(const char *p, const char *m) {
    FILE *f = fopen(p,m); if (!f) { perror(p); exit(1); } return f;
}
static inline void path_join(char *out, size_t n, const char *a, const char *b) {
    if (snprintf(out,n,"%s/%s",a,b) < 0 || strlen(a)+strlen(b)+2 > n) die("path-too-long");
}
static inline void directory(const char *p) {
    if (mkdir(p,0700) && errno != EEXIST) die("create-directory");
}
static inline void write_bytes(const char *p, const void *s, size_t n) {
    FILE *f=open_file(p,"wb"); if (fwrite(s,1,n,f)!=n || fclose(f)) die("write-file");
}
static inline void copy_file(const char *a, const char *b) {
    unsigned char buf[65536]; size_t n; FILE *in=open_file(a,"rb"), *out=open_file(b,"wb");
    while ((n=fread(buf,1,sizeof buf,in))) if(fwrite(buf,1,n,out)!=n) die("copy-write");
    if(ferror(in) || fclose(out)) die("copy-io");
    fclose(in);
}
static inline void hash_file(const char *p, char hex[65], uint64_t *size) {
    unsigned char buf[65536], digest[EVP_MAX_MD_SIZE]; unsigned len=0; size_t n;
    FILE *f=open_file(p,"rb"); EVP_MD_CTX *ctx=EVP_MD_CTX_new(); *size=0;
    if(!ctx || EVP_DigestInit_ex(ctx,EVP_sha256(),NULL)!=1) die("sha256-init");
    while((n=fread(buf,1,sizeof buf,f))) {
        if(EVP_DigestUpdate(ctx,buf,n)!=1 || UINT64_MAX-*size<n) die("sha256-update");
        *size+=n;
    }
    if(ferror(f) || EVP_DigestFinal_ex(ctx,digest,&len)!=1 || len!=32) die("sha256-finish");
    fclose(f); EVP_MD_CTX_free(ctx);
    for(unsigned i=0;i<len;i++) sprintf(hex+2*i,"%02x",digest[i]);
    hex[64]=0;
}
static inline void hash_bytes(const void *bytes,size_t n,char hex[65]) {
    unsigned char digest[EVP_MAX_MD_SIZE]; unsigned len=0;
    if(EVP_Digest(bytes,n,digest,&len,EVP_sha256(),NULL)!=1 || len!=32) die("sha256-bytes");
    for(unsigned i=0;i<len;i++) sprintf(hex+2*i,"%02x",digest[i]);
    hex[64]=0;
}
static inline void hex_print(FILE *f,const char *s) {
    if(!*s) {fputc('-',f); return;}
    for(;*s;s++) fprintf(f,"%02x",(unsigned char)*s);
}
static inline int same_file(const char *a,const char *b) {
    char x[65],y[65]; uint64_t nx,ny; struct stat st;
    if(lstat(b,&st) || !S_ISREG(st.st_mode)) return 0;
    hash_file(a,x,&nx); hash_file(b,y,&ny); return nx==ny && !strcmp(x,y);
}
static inline uint64_t number(const char *s) {
    char *end; uintmax_t n; if(!*s) die("empty-number");
    for(const char *p=s;*p;p++) if(*p<'0'||*p>'9') die("nondecimal-number");
    errno=0; n=strtoumax(s,&end,10);
    if(errno || *end || n>UINT64_MAX) die("number-overflow");
    return (uint64_t)n;
}
#endif
