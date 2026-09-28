/* Synthetic fixture construction, never a parser. Expected structure is supplied
 * beside each literal, not inferred by a mail implementation. */
#include "support.h"

static char root[4096], dir[4096];
static FILE *catalog, *input, *facts, *objects;
static uint64_t position;
static int field_index;
static const char *common = "Date: Mon, 28 Sep 2026 12:00:00 +0000\r\nFrom: sender@example.invalid\r\n";

static void begin(const char *id,const char *op,const char *state,const char *evidence,const char *why) {
    char p[4096]; path_join(dir,sizeof dir,root,id); directory(dir);
    fprintf(catalog,"%s\t%s\t%s\t%s\t%s\n",id,op,state,evidence,why);
    path_join(p,sizeof p,dir,"input.bin"); input=open_file(p,"wb");
    path_join(p,sizeof p,dir,"facts.tsv"); facts=open_file(p,"wb");
    path_join(p,sizeof p,dir,"objects.tsv"); objects=open_file(p,"wb");
    position=0; field_index=0;
}
static void put(const void *s,size_t n) {if(fwrite(s,1,n,input)!=n) die("fixture-write");position+=n;}
static void text_bytes(const char *s) {put(s,strlen(s));}
static void object(const char *name,const void *s,size_t n) {
    char p[4096],h[65]; path_join(p,sizeof p,dir,name); write_bytes(p,s,n); hash_bytes(s,n,h);
    fprintf(objects,"%s\t%zu\t%s\n",name,n,h);
}
static void end(void) {
    char p[4096],h[65]; uint64_t n;
    if(fclose(input)||fclose(facts)||fclose(objects)) die("fixture-close");
    path_join(p,sizeof p,dir,"input.bin"); hash_file(p,h,&n);
    path_join(p,sizeof p,dir,"source.tsv"); FILE *f=open_file(p,"wb");
    fprintf(f,"0\t%"PRIu64"\t%"PRIu64"\t%s\n",n,n,h); fclose(f);
}
static void header(const char *raw,const char *name,const char *unfolded) {
    text_bytes(raw); fprintf(facts,"header\t%d\t",field_index++); hex_print(facts,name);
    fputc('\t',facts); hex_print(facts,unfolded); fputc('\n',facts);
}
static void ordinary(void) {
    header("Date: Mon, 28 Sep 2026 12:00:00 +0000\r\n","date"," Mon, 28 Sep 2026 12:00:00 +0000");
    header("From: sender@example.invalid\r\n","from"," sender@example.invalid");
}
static void body(const char *s) {
    text_bytes("\r\n"); text_bytes(s);
    fprintf(facts,"body\t%"PRIu64"\t%"PRIu64"\n",position-strlen(s),position);
}
static void rfc_cases(void) {
    begin("rfc-ordinary","rfc","SPEC","R5322","ordinary headers and body"); ordinary();
    header("To: target@example.invalid\r\n","to"," target@example.invalid");
    header("Subject: hello\r\n","subject"," hello");body("hello\r\n");end();
    begin("rfc-folded-repeated","rfc","SPEC","R5322","preserve order capitalization whitespace and folding bytes");ordinary();
    header("sUbJeCt:\talpha\r\n beta\r\n\tgamma\r\n","subject","\talpha beta\tgamma");
    header("X-Tag: one\r\n","x-tag"," one");header("X-Tag: two\r\n","x-tag"," two");
    header("X-Empty:\r\n","x-empty","");body("\r\n\r\n");end();
    begin("rfc-no-optional","rfc","SPEC","R5322","Message-ID Subject and To absent");ordinary();body("");end();
    begin("rfc-unusual-value","rfc","SPEC","R5322","commas quoted names comments and colon in value");ordinary();
    header("To: \"A, B\" <a@example.invalid> (comment)\r\n","to"," \"A, B\" <a@example.invalid> (comment)");
    header("Subject: time: 12:00\r\n","subject"," time: 12:00");body("no final newline");end();
    begin("rfc-utf8","rfc","SPEC","R6532","internationalized headers under explicit RFC6532 profile");ordinary();
    header("Subject: caf\xc3\xa9 \xf0\x9f\x8c\x8d\r\n","subject"," caf\xc3\xa9 \xf0\x9f\x8c\x8d");body("caf\xc3\xa9\r\n");end();
    begin("rfc-encoded-word","rfc","SPEC","R2047","encoded word display distinct from stored header");ordinary();
    header("Subject: =?UTF-8?Q?caf=C3=A9?=\r\n","subject"," =?UTF-8?Q?caf=C3=A9?=");
    fprintf(facts,"display\tsubject\t636166c3a9\n");body("hello\r\n");end();
    begin("rfc-long-fold","rfc","SPEC","R5322","long unfolded field without long physical line");ordinary();
    char raw[4096]="X-Long:",value[4096]="";
    for(int i=0;i<64;i++){strcat(raw,"\r\n 01234567890123456789");strcat(value," 01234567890123456789");}
    strcat(raw,"\r\n");header(raw,"x-long",value);body("end\r\n");end();
    const char *ids[]={"rfc-bad-word","rfc-no-colon","rfc-leading-fold","rfc-bare-lf","rfc-missing-separator","rfc-bare-cr","rfc-nul-header","rfc-duplicate-singleton"};
    const char *raws[]={"Subject: =?UTF-8?Q?=ZZ?=\r\n\r\nx", "bad header\r\n\r\nx", " orphan\r\n\r\nx", "From: a@example.invalid\n\nx", "Subject: unfinished", "Subject: a\rb\r\n\r\nx", "X-Binary: before", "Subject: a\r\nSubject: b\r\n\r\nx"};
    for(size_t i=0;i<sizeof ids/sizeof *ids;i++) {
        begin(ids[i],"rfc","UNRESOLVED","Q-MESSAGE","recovery policy needs retained source; raw preservation active");text_bytes(raws[i]);
        if(i==6){const unsigned char tail[]={0,'a','f','t','e','r','\r','\n','\r','\n'};put(tail,sizeof tail);}end();
    }
}
static void leaf(const char *path,const char *type,const char *encoding,const char *name,const void *s,size_t n) {
    fprintf(facts,"part\t%s\t%s\t%s\t%s\n",path,type,encoding,name);object(name,s,n);
}
static void mime_cases(void) {
    const char *ids[]={"mime-plain","mime-html","mime-base64","mime-qp","mime-8bit","mime-base64-wrapped"};
    const char *types[]={"text/plain","text/html","text/plain","text/plain","text/plain","text/plain"};
    const char *encs[]={"7bit","7bit","base64","quoted-printable","8bit","base64"};
    const char *encdata[]={"hello\r\n","<p>hello</p>\r\n","aGVsbG8NCg==\r\n","hel=6Co=0D=0A","caf\xc3\xa9\r\n","aGVs\r\nbG8N\r\nCg==\r\n"};
    const char *decdata[]={"hello\r\n","<p>hello</p>\r\n","hello\r\n","hello\r\n","caf\xc3\xa9\r\n","hello\r\n"};
    for(size_t i=0;i<6;i++) {
        begin(ids[i],"mime","SPEC","R2045","literal transfer encoding pair");text_bytes(common);
        fprintf(input,"MIME-Version: 1.0\r\nContent-Type: %s; charset=utf-8\r\nContent-Transfer-Encoding: %s\r\n\r\n%s",types[i],encs[i],encdata[i]);
        leaf("0",types[i],encs[i],"part-0.bin",decdata[i],strlen(decdata[i]));end();
    }
    begin("mime-qp-soft-break","mime","SPEC","R2045","QP soft break and escaped equals");text_bytes(common);
    text_bytes("MIME-Version: 1.0\r\nContent-Type: text/plain\r\nContent-Transfer-Encoding: quoted-printable\r\n\r\nab=\r\ncd=3D\r\n");
    leaf("0","text/plain","quoted-printable","part-0.bin","abcd=\r\n",7);end();
    begin("mime-alternative","mime","SPEC","R2046","ordered alternatives are not concatenated");text_bytes(common);
    text_bytes("MIME-Version: 1.0\r\nContent-Type: multipart/alternative; boundary=alt\r\n\r\npreamble\r\n--alt\r\nContent-Type: text/plain\r\n\r\nhello\r\n--alt\r\nContent-Type: text/html\r\n\r\n<p>hello</p>\r\n--alt--\r\nepilogue\r\n");
    fprintf(facts,"part\t0\tmultipart/alternative\t7bit\t-\n");
    leaf("0.0","text/plain","7bit","part-0.0.bin","hello",5);
    leaf("0.1","text/html","7bit","part-0.1.bin","<p>hello</p>",12);end();
    begin("mime-nested-attachment","mime","SPEC","R2046,R2231","nested structure attachment bytes and filename continuations");text_bytes(common);
    text_bytes("MIME-Version: 1.0\r\nContent-Type: multipart/mixed; boundary=outer\r\n\r\n--outer\r\nContent-Type: multipart/alternative; boundary=inner\r\n\r\n--inner\r\nContent-Type: text/plain\r\n\r\ntext\r\n--inner\r\nContent-Type: text/html\r\n\r\n<b>text</b>\r\n--inner--\r\n--outer\r\nContent-Type: application/octet-stream\r\nContent-Disposition: attachment; filename*0*=utf-8''caf%C3;\r\n filename*1*=%A9.bin\r\nContent-Transfer-Encoding: base64\r\n\r\nAP8NCg==\r\n--outer--\r\n");
    fprintf(facts,"part\t0\tmultipart/mixed\t7bit\t-\npart\t0.0\tmultipart/alternative\t7bit\t-\n");
    leaf("0.0.0","text/plain","7bit","part-0.0.0.bin","text",4);
    leaf("0.0.1","text/html","7bit","part-0.0.1.bin","<b>text</b>",11);
    const unsigned char bin[]={0,255,13,10};leaf("0.1","application/octet-stream","base64","part-0.1.bin",bin,4);
    fprintf(facts,"filename\t0.1\t636166c3a92e62696e\n");end();
    begin("mime-empty-quoted-boundary","mime","SPEC","R2046","empty part unusual quoted boundary and boundary-looking payload");text_bytes(common);
    text_bytes("MIME-Version: 1.0\r\nContent-Type: multipart/mixed; boundary=\"a:b?c d\"\r\n\r\n--a:b?c d\r\nContent-Type: text/plain\r\n\r\n\r\n--a:b?c d\r\nContent-Type: text/plain\r\n\r\nx--a:b?c d\r\nFrom fake\r\n--a:b?c d--\r\n");
    fprintf(facts,"part\t0\tmultipart/mixed\t7bit\t-\n");leaf("0.0","text/plain","7bit","part-0.0.bin","",0);
    const char *payload="x--a:b?c d\r\nFrom fake";leaf("0.1","text/plain","7bit","part-0.1.bin",payload,strlen(payload));end();
    begin("mime-nested-message","mime","SPEC","R2046","message/rfc822 with independently encoded inner leaf");text_bytes(common);
    text_bytes("MIME-Version: 1.0\r\nContent-Type: message/rfc822\r\n\r\n");text_bytes(common);
    text_bytes("MIME-Version: 1.0\r\nContent-Type: text/plain\r\nContent-Transfer-Encoding: base64\r\n\r\naGVsbG8NCg==\r\n");
    fprintf(facts,"part\t0\tmessage/rfc822\t7bit\t-\n");leaf("0.0","text/plain","base64","part-0.0.bin","hello\r\n",7);end();
    const char *bad_ids[]={"mime-missing-close","mime-invalid-base64","mime-invalid-qp","mime-encoded-multipart","mime-prefix-collision"};
    const char *bad[]={"Content-Type: multipart/mixed; boundary=b\r\n\r\n--b\r\n\r\nx", "Content-Transfer-Encoding: base64\r\n\r\nA===", "Content-Transfer-Encoding: quoted-printable\r\n\r\nx=", "Content-Type: multipart/mixed; boundary=b\r\nContent-Transfer-Encoding: base64\r\n\r\nLS1i", "Content-Type: multipart/mixed; boundary=b\r\n\r\n--b\r\n\r\nx\r\n--bXYZ\r\ny\r\n--b--\r\n"};
    for(size_t i=0;i<5;i++){begin(bad_ids[i],"mime","UNRESOLVED","Q-MESSAGE","malformed-input recovery not invented");text_bytes(common);text_bytes("MIME-Version: 1.0\r\n");text_bytes(bad[i]);end();}
}
static void mbox_record(FILE *spans,int ordinal,const char *sep,const void *msg,size_t n) {
    uint64_t start=position;char name[64],h[65];text_bytes(sep);uint64_t raw_start=position;put(msg,n);
    snprintf(name,sizeof name,"constructed-%d.bin",ordinal);object(name,msg,n);hash_bytes(msg,n,h);
    fprintf(spans,"%d\t%"PRIu64"\t%"PRIu64"\t%"PRIu64"\t%zu\t%s\t%s\n",ordinal,start,raw_start,position,n,h,name);
}
static void mbox_cases(void) {
    const char *sep="From sender@example.invalid Mon Sep 28 12:00:00 2026\n";
    const char *ids[]={"mbox-one","mbox-several","mbox-no-final-lf","mbox-empty-body","mbox-newlines","mbox-from-quotes","mbox-mime-separator","mbox-binary","mbox-incomplete","mbox-adjacent","mbox-duplicate-id","mbox-absent-id","mbox-malformed-id","mbox-same-body","mbox-identical-copies"};
    const char *messages[]={"Subject: one\n\none\n\n","Subject: first\n\nfirst\n\n","Subject: end\n\nno newline","Subject: empty\n\n","Subject: newlines\n\n\n\n\n","Subject: quotes\n\nFrom fake\n>From escaped\n>>From twice\n>>>From thrice\n From indented\nFrom:\nXFrom misleading\n\n","Content-Type: multipart/mixed; boundary=b\n\n--b\nContent-Type: text/plain\n\nFrom sender@example.invalid Mon Sep 28 12:00:00 2026\ninside\n--b--\n\n","Subject: binary\n\n","Subject: cut\nX-Unfinished:","Subject: near\n\nx\n","Message-ID: <same@example.invalid>\n\na\n\n","Subject: absent\n\na\n\n","Message-ID: broken\n\na\n\n","X-Distinct: one\n\nsame\n\n","Subject: identical\n\nsame\n\n"};
    begin("mbox-empty","mbox","UNRESOLVED","Q-MBOX","empty file pending selected format");end();
    for(size_t i=0;i<sizeof ids/sizeof *ids;i++) {
        begin(ids[i],"mbox","UNRESOLVED","Q-MBOX","constructed spans are evidence, not selected parser semantics");
        char p[4096];path_join(p,sizeof p,dir,"constructed-spans.tsv");FILE *spans=open_file(p,"wb");
        if(i==7){unsigned char b[256];size_t n=strlen(messages[i]);memcpy(b,messages[i],n);b[n++]=0;b[n++]=255;b[n++]=128;b[n++]='\n';mbox_record(spans,0,sep,b,n);}
        else mbox_record(spans,0,sep,messages[i],strlen(messages[i]));
        if(i==1||i>=9){const char *second=i==13?"X-Distinct: two\n\nsame\n\n":messages[i];mbox_record(spans,1,sep,second,strlen(second));}
        fclose(spans);end();
    }
    const char *badids[]={"mbox-truncated-separator","mbox-malformed-separator","mbox-invalid-message","mbox-content-length-conflict"};
    const char *bad[]={"From sender@example.invalid Mon Sep", "From nonsense\nSubject: x\n\ny\n", "From sender@example.invalid Mon Sep 28 12:00:00 2026\nnot a header\n\nx\n", "From sender@example.invalid Mon Sep 28 12:00:00 2026\nContent-Length: 1\n\na\nFrom sender@example.invalid Mon Sep 28 12:00:00 2026\nSubject: y\n\nz\n"};
    for(size_t i=0;i<4;i++){begin(badids[i],"mbox","UNRESOLVED","Q-MBOX","boundary/recovery ambiguity retained for resolution");text_bytes(bad[i]);end();}
}
static void state_case(const char *id,const char *events,const char *knowledge,const char *retry,const char *complete) {
    begin(id,"migration","POLICY","U-CRASH","knowledge after cut, distinct from hidden destination truth");text_bytes(events);
    fprintf(facts,"knowledge\t%s\nretry\t%s\ncomplete\t%s\n",knowledge,retry,complete);end();
}
static void migration_cases(void) {
    state_case("crash-before-read","cut\tbefore-read\n","not-written","safe","no");
    state_case("crash-during-read","read\tpartial\ncut\tduring-read\n","not-written","safe","no");
    state_case("crash-after-parse","parsed\tsource-A:0:100\ncut\tbefore-submit\n","not-written","safe","no");
    state_case("crash-during-submit","durable\tintent-A\nsubmit\tstarted\ncut\tduring-submit\n","unknown","prohibited","no");
    state_case("crash-accepted-ack-lost","durable\tintent-A\nsubmit\tstarted\nhidden-remote\taccepted:g-1\ncut\tbefore-ack\n","unknown","prohibited","no");
    state_case("crash-not-accepted-ack-lost","durable\tintent-A\nsubmit\tstarted\nhidden-remote\tnot-accepted\ncut\tbefore-ack\n","unknown","prohibited","no");
    state_case("crash-ack-before-durable","durable\tintent-A\nsubmit\tstarted\nvolatile-ack\tg-1\ncut\tbefore-record\n","unknown","prohibited","no");
    state_case("crash-after-durable","durable\tintent-A\nsubmit\tstarted\nvolatile-ack\tg-1\ndurable\taccepted:g-1\ncut\tafter-record\n","written","unnecessary","yes");
    state_case("restart-corrupt-tail","durable\tintent-A\nsubmit\tstarted\ncorrupt-tail\taccepted:g-1\ncut\trecovery\n","unknown","prohibited","no");
    state_case("restart-truncated-tail","durable\tintent-A\nsubmit\tstarted\ntruncated-tail\taccepted:g-\ncut\trecovery\n","unknown","prohibited","no");
    state_case("crash-definite-failure","durable\tintent-A\nsubmit\tstarted\ndurable\trejected-permanent\ncut\tafter-record\n","failed","prohibited","no");
    state_case("restart-safe-retry","durable\tnot-submitted\ncut\trestart\n","not-written","safe","no");
}
static void ssh_cases(void) {
    const char *ids[]={"ssh-success","ssh-host-mismatch","ssh-host-missing","ssh-auth-failed","ssh-tcp-only","ssh-no-algorithm","ssh-channel-denied","ssh-setup-close","ssh-abrupt-close","ssh-sftp","ssh-scp"};
    const char *events[]={
        "tcp\tconnected\nkex\tfixture-common\ntrust\tmatch\nauth\taccepted\nchannel\topened\ncommand\tstreams-exit23\nread\tagain\nread\tidle\nread\tstdout\nread\tstderr\nread\teof\nclose\tordinary\n",
        "tcp\tconnected\nkex\tfixture-common\ntrust\tmismatch\n",
        "tcp\tconnected\nkex\tfixture-common\ntrust\tnotfound\n",
        "tcp\tconnected\nkex\tfixture-common\ntrust\tmatch\nauth\trejected\n",
        "tcp\tconnected\nkex\tfailed\n",
        "tcp\tconnected\nkex\tno-common-algorithm\n",
        "tcp\tconnected\nkex\tfixture-common\ntrust\tmatch\nauth\taccepted\nchannel\tdenied\n",
        "tcp\tconnected\npeer\tclosed-during-kex\n",
        "tcp\tconnected\nkex\tfixture-common\ntrust\tmatch\nauth\taccepted\nchannel\topened\nread\tpartial\npeer\treset\n",
        "protocol\tsftp\nfile\tsynthetic.bin\nread\tshort\nread\tagain\nread\teof\n",
        "protocol\tscp\nfile\tsynthetic.bin\nread\tshort\nread\teof\n"};
    const char *expected[]={
        "connection\tclosed\nnegotiation\tsuccess\nhost\tverified\nauth\tsuccess\nchannel\topened\nexit\t23\nterminal\teof\n",
        "host\trejected-mismatch\nauth\tnot-attempted\nchannel\tnot-opened\n",
        "host\tuntrusted\nauth\tnot-attempted\nchannel\tnot-opened\n",
        "host\tverified\nauth\tfailed\nchannel\tnot-opened\n",
        "connection\ttcp-only\nauth\tnot-established\nchannel\tnot-opened\n",
        "negotiation\tfailed\nauth\tnot-attempted\nchannel\tnot-opened\n",
        "auth\tsuccess\nchannel\tfailed\ncommand\tnot-started\n",
        "connection\tsetup-failed\nauth\tnot-established\n",
        "terminal\ttransport-error\ncomplete\tno\n",
        "terminal\teof\ncomplete\tyes\n",
        "terminal\teof\ncomplete\tyes\n"};
    for(size_t i=0;i<sizeof ids/sizeof *ids;i++) {
        begin(ids[i],"ssh-model","POLICY","SSH,U-TRUST","observable-contract model; never live SSH evidence");text_bytes(events[i]);fputs(expected[i],facts);
        if(i==0){const unsigned char out[]={0,'O','U','T','\n',255};object("stdout.bin",out,sizeof out);object("stderr.bin","ERR\r\n",5);}
        if(i>=9){const unsigned char file[]={0,255,13,10,'F','r','o','m',' ','x','\n'};object("file.bin",file,sizeof file);}
        end();
    }
}
static void identities(void) {
    begin("identity-collisions","identity","POLICY","U-IDENTITY","retain occurrence records without choosing destination deduplication");
    const char *a="Message-ID: <same@example.invalid>\r\nX-Copy: a\r\n\r\nsame\r\n";
    const char *b="Message-ID: <same@example.invalid>\r\nX-Copy: b\r\n\r\nsame\r\n";
    const char *messages[]={a,b,a,"Subject: no id\r\n\r\nsame\r\n","Message-ID: broken\r\n\r\nsame\r\n",a};
    uint64_t offset=0;
    for(size_t i=0;i<6;i++) {
        if(i==5)offset=0;
        char h[65],name[64];size_t n=strlen(messages[i]);hash_bytes(messages[i],n,h);
        snprintf(name,sizeof name,"message-%zu.bin",i);object(name,messages[i],n);
        fprintf(input,"occurrence\t%zu\tsnapshot-A\t%"PRIu64"\t%"PRIu64"\t%s\t%s\n",i,offset,offset+n,h,i==3?"absent":i==4?"malformed":"same@example.invalid");
        fprintf(facts,"occurrence\t%zu\tsnapshot-A\t%"PRIu64"\t%"PRIu64"\t%s\tdestination-unknown\n",i,offset,offset+n,h);
        offset+=n+64; /* last replays the SAME locator; occurrence stays distinct */
    }
    end();
}
static void generated(uint32_t seed,unsigned count) {
    for(unsigned i=0;i<count;i++) {
        seed=seed*UINT32_C(1664525)+UINT32_C(1013904223);
        char id[64],raw[4096],value[4096],name[64],payload[128];
        snprintf(id,sizeof id,"generated-%08"PRIx32"-%u",seed,i);
        begin(id,"rfc","SPEC","R5322","bounded grammar construction; seed and index recover the fixture");ordinary();
        snprintf(name,sizeof name,"x-seed-%08"PRIx32,seed);snprintf(raw,sizeof raw,"X-Seed-%08"PRIx32":",seed);value[0]=0;
        unsigned folds=1+seed%32;
        for(unsigned j=0;j<folds;j++){const char *segment=j%2?"\tpart":" part";strcat(raw,"\r\n");strcat(raw,segment);strcat(value,segment);}
        strcat(raw,"\r\n");header(raw,name,value);snprintf(payload,sizeof payload,"seed %"PRIu32"\r\n",seed);body(payload);end();
    }
}
int main(int argc,char **argv) {
    int generated_only=argc==5&&!strcmp(argv[1],"--generated-only");
    if((argc!=2&&argc!=4)&&!generated_only)
        die("usage: make-corpus OUTPUT-DIRECTORY [SEED COUNT] | make-corpus --generated-only OUTPUT-DIRECTORY SEED COUNT");
    const char *output=generated_only?argv[2]:argv[1];
    if(strlen(output)>=sizeof root) die("root-too-long");
    strcpy(root,output);directory(root);char p[4096];path_join(p,sizeof p,root,"cases.tsv");catalog=open_file(p,"wb");
    fprintf(catalog,"case\toperation\tstatus\tevidence\tpurpose\n");
    if(generated_only) {
        uint64_t count=number(argv[4]),seed=number(argv[3]);
        if(!count||count>1024||seed>UINT32_MAX)die("generator-bounds");
        generated((uint32_t)seed,(unsigned)count);
    } else {
        rfc_cases();mime_cases();mbox_cases();migration_cases();ssh_cases();identities();
        if(argc==4){uint64_t count=number(argv[3]),seed=number(argv[2]);if(count>1024||seed>UINT32_MAX)die("generator-bounds");generated((uint32_t)seed,(unsigned)count);}
    }
    if(fclose(catalog)) die("catalog-close");
    return 0;
}
