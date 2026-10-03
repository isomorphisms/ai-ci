/* Run by the deterministic local SSH server, never against SDF. */
#include <stdio.h>
int main(void) {
    const unsigned char out[]={0,'O','U','T','\n',255};
    const unsigned char err[]={'E','R','R','\r','\n'};
    if(fwrite(out,1,sizeof out,stdout)!=sizeof out || fflush(stdout))return 111;
    if(fwrite(err,1,sizeof err,stderr)!=sizeof err || fflush(stderr))return 112;
    return 23;
}
