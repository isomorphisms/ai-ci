/* Independent PATH acceptance. The oracle uses squared endpoint/cross-product
 * tests in long double; it calls no producer geometry helper. */
#include "subpixel/path.h"
#include <float.h>
#include <limits.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

enum { W=23, H=19, STRIDE=29, WORDS=W*H, CAPACITY=STRIDE*H };
static unsigned checks, failures;
static uint64_t output[CAPACITY], before[CAPACITY], candidate[WORDS], reference[WORDS];
static const uint64_t sentinel=UINT64_C(0x1020408001020408);
static void check(int condition,const char *name) {
    ++checks;
    if(!condition){++failures;fprintf(stderr,"FAIL %s\n",name);}
}
static cp_path_options defaults(void) {
    cp_path_options o={0};
    o.transform=(cp_path_transform){1,0,0,1,0,0};o.width=.79;o.tolerance=.01;
    o.max_pixel_error=0;o.max_depth=24;o.max_patches=200000;
    o.max_sample_tests=UINT64_C(100000000);o.strategy=CP_PATH_QUADRATIC;
    return o;
}
static cp_coverage_plane plane(void) {
    return (cp_coverage_plane){output,CAPACITY,STRIDE,W,H,-11,-9};
}
static void reset(int filled) {
    for(size_t i=0;i<CAPACITY;i++)output[i]=filled?sentinel:0;
    for(unsigned y=0;y<H;y++)for(unsigned x=W;x<STRIDE;x++)output[y*STRIDE+x]=sentinel;
    memcpy(before,output,sizeof(output));
}
static cp_path_status invoke(cp_coverage_plane *p,cp_path_segment *s,size_t n,
                             cp_path_options *o,cp_path_report *r) {
    cp_path_workspace w={candidate,reference,WORDS};
    return cp_path_rasterize(p,s,n,o,&w,r);
}
/* Compare a sample with the closed Euclidean tube about a finite segment.
 * For an interior projection, squared distance is cross^2 / length^2. */
static int line_contains(long double x,long double y,cp_vec2 a,cp_vec2 b,long double r) {
    long double dx=(long double)b.x-a.x,dy=(long double)b.y-a.y;
    long double qx=x-a.x,qy=y-a.y,length2=dx*dx+dy*dy;
    long double projection=qx*dx+qy*dy;
    if(projection<=0 || length2==0)return qx*qx+qy*qy<=r*r;
    if(projection>=length2){qx=x-b.x;qy=y-b.y;return qx*qx+qy*qy<=r*r;}
    long double cross=qx*dy-qy*dx;
    return cross*cross<=r*r*length2;
}
static cp_vec2 transform(cp_vec2 a,cp_path_transform t) {
    return (cp_vec2){t.xx*a.x+t.xy*a.y+t.tx,t.yx*a.x+t.yy*a.y+t.ty};
}
static uint64_t line_mask(int x,int y,cp_vec2 a,cp_vec2 b,double width) {
    uint64_t mask=0;
    for(unsigned sy=0;sy<8;sy++)for(unsigned sx=0;sx<8;sx++) {
        long double qx=x+((long double)sx+.5L)/8-.5L;
        long double qy=y+((long double)sy+.5L)/8-.5L;
        if(line_contains(qx,qy,a,b,(long double)width/2))mask|=UINT64_C(1)<<(8*sy+sx);
    }
    return mask;
}
static void compare_lines(const char *name,const cp_coverage_plane *p,
                          const cp_path_segment *s,size_t n,const cp_path_options *o,int filled) {
    unsigned mismatch=0;
    for(unsigned y=0;y<H;y++)for(unsigned x=0;x<W;x++) {
        uint64_t expected=filled?sentinel:0;
        for(size_t i=0;i<n;i++)expected|=line_mask(p->origin_x+(int)x,p->origin_y+(int)y,
            transform(s[i].controls[0],o->transform),transform(s[i].controls[s[i].degree],o->transform),o->width);
        if(output[y*STRIDE+x]!=expected) {
            if(mismatch++==0)fprintf(stderr,"%s first mask (%d,%d): actual %016llx expected %016llx\n",name,
                p->origin_x+(int)x,p->origin_y+(int)y,(unsigned long long)output[y*STRIDE+x],(unsigned long long)expected);
        }
    }
    check(mismatch==0,name);
    unsigned bad_padding=0;
    for(unsigned y=0;y<H;y++)for(unsigned x=W;x<STRIDE;x++)bad_padding+=output[y*STRIDE+x]!=sentinel;
    check(bad_padding==0,"stride padding preserved");
}
static void line_case(const char *name,cp_path_segment s,cp_path_options o,int filled) {
    reset(filled);cp_coverage_plane p=plane();cp_path_report r={0};
    cp_path_status status=invoke(&p,&s,1,&o,&r);
    if(status!=CP_PATH_OK)fprintf(stderr,"%s status %d\n",name,status);
    check(status==CP_PATH_OK,name);
    if(status==CP_PATH_OK){compare_lines(name,&p,&s,1,&o,filled);check(r.worst_pixel_error==0,"zero diagnostic error");}
}
static void analytic_cases(void) {
    cp_path_options o=defaults();
    cp_path_segment s={1,{{-9.17,-6.21},{8.37,5.13},{0,0},{0,0}}};
    line_case("oblique analytic quadratic",s,o,0);
    o.strategy=CP_PATH_CUBIC;line_case("oblique analytic cubic",s,o,0);
    o.strategy=CP_PATH_AUTO;line_case("oblique analytic auto union",s,o,1);
    cp_vec2 t=s.controls[0];s.controls[0]=s.controls[1];s.controls[1]=t;
    line_case("reverse analytic",s,o,0);
    o.transform=(cp_path_transform){-1,0,0,1,0,0};line_case("reflection x",s,o,0);
    o.transform=(cp_path_transform){0,1,-1,0,0,0};line_case("quarter rotation",s,o,0);
    o.transform=(cp_path_transform){1.25,.31,-.27,.83,.123,-.219};line_case("affine shear and nonuniform scale",s,o,0);
    s=(cp_path_segment){1,{{1.03125,-.09375},{1.03125,-.09375},{0,0},{0,0}}};
    o=defaults();line_case("zero length round cap",s,o,0);
    s=(cp_path_segment){1,{{-100,7.23},{100,7.23},{0,0},{0,0}}};line_case("clipped long line",s,o,0);
    s=(cp_path_segment){1,{{-2.37,-100},{-2.37,100},{0,0},{0,0}}};line_case("clipped vertical",s,o,0);
    s=(cp_path_segment){1,{{-2.37,-1.11},{4.27,5.73},{0,0},{0,0}}};
    o.width=3.17;line_case("wide oblique",s,o,0);
    o.width=.0001;line_case("thin oblique",s,o,0);
    s=(cp_path_segment){1,{{0,0},{3,4},{0,0},{0,0}}};o.width=1.0;line_case("rational 3-4-5 boundary",s,o,0);
}
static void union_cases(void) {
    cp_path_options o=defaults();cp_path_report r={0};cp_coverage_plane p=plane();
    cp_path_segment s[3]={
        {1,{{-8.17,-5.21},{8.37,5.13},{0,0},{0,0}}},
        {1,{{-8.17,5.21},{8.37,-5.13},{0,0},{0,0}}},
        {1,{{-8.17,-5.21},{8.37,5.13},{0,0},{0,0}}}
    };
    reset(1);check(invoke(&p,s,3,&o,&r)==CP_PATH_OK,"crossing duplicate union status");
    compare_lines("crossing duplicate union masks",&p,s,3,&o,1);
    uint64_t saved[CAPACITY];memcpy(saved,output,sizeof(saved));
    check(invoke(&p,s,3,&o,&r)==CP_PATH_OK,"idempotence second invocation");
    check(memcmp(output,saved,sizeof(saved))==0,"idempotence masks");
    s[0]=(cp_path_segment){1,{{-8.17,-5.21},{.10,-.04},{0,0},{0,0}}};
    s[1]=(cp_path_segment){1,{{.10,-.04},{8.37,5.13},{0,0},{0,0}}};
    reset(0);check(invoke(&p,s,2,&o,&r)==CP_PATH_OK,"explicit joint split status");
    compare_lines("explicit joint split analytic",&p,s,2,&o,0);
}
static void degree_cases(void) {
    cp_path_options o=defaults();
    cp_path_segment s={2,{{-6.25,-3.25},{0,0},{6.25,3.25},{0,0}}};
    line_case("quadratic degree elevation straight",s,o,0);
    s=(cp_path_segment){3,{{-6,-3},{-2,-1},{2,1},{6,3}}};
    line_case("cubic degree elevation straight",s,o,0);
    unsigned state=0x73021489u;
    for(unsigned i=0;i<64;i++) {
        state=1664525u*state+1013904223u;
        double ax=(double)((state>>8)%1701)/100-8.5;
        state=1664525u*state+1013904223u;
        double ay=(double)((state>>8)%1401)/100-7;
        state=1664525u*state+1013904223u;
        double bx=(double)((state>>8)%1701)/100-8.5;
        state=1664525u*state+1013904223u;
        double by=(double)((state>>8)%1401)/100-7;
        s=(cp_path_segment){1,{{ax,ay},{bx,by},{0,0},{0,0}}};
        state=1664525u*state+1013904223u;
        o.width=.101+(double)((state>>8)%801)/317;
        o.strategy=(i&1)?CP_PATH_CUBIC:CP_PATH_QUADRATIC;
        line_case("deterministic independent line matrix",s,o,0);
    }
}
static int cancel_immediate(void *state){(void)state;return 1;}
typedef struct { unsigned calls, stop; } cancellation;
static int cancel_at(void *state){cancellation *c=state;return ++c->calls>=c->stop;}
static void failed_call(const char *name,cp_coverage_plane *p,cp_path_segment *s,size_t n,
                        cp_path_options *o,cp_path_workspace *w,cp_path_status expected) {
    cp_path_report r,saved;memset(&r,0x5a,sizeof(r));memcpy(&saved,&r,sizeof(r));
    memcpy(before,output,sizeof(output));
    cp_path_status actual=cp_path_rasterize(p,s,n,o,w,&r);
    if(actual!=expected)fprintf(stderr,"%s status %d expected %d\n",name,actual,expected);
    check(actual==expected,name);
    check(memcmp(output,before,sizeof(output))==0,"failure destination atomicity");
    check(memcmp(&r,&saved,sizeof(r))==0,"failure report atomicity");
}
static void failure_cases(void) {
    cp_path_segment s[2]={{1,{{-8.17,-5.21},{8.37,5.13},{0,0},{0,0}}},{1,{{0,0},{1,1},{0,0},{0,0}}}};
    cp_path_options o=defaults();cp_coverage_plane p=plane();
    cp_path_workspace w={candidate,reference,WORDS};reset(1);
    failed_call("null destination",NULL,s,1,&o,&w,CP_PATH_INVALID);
    failed_call("null options",&p,s,1,NULL,&w,CP_PATH_INVALID);
    failed_call("null workspace",&p,s,1,&o,NULL,CP_PATH_INVALID);
    failed_call("null segments",&p,NULL,1,&o,&w,CP_PATH_INVALID);
    failed_call("no segments",&p,s,0,&o,&w,CP_PATH_INVALID);
    o.width=NAN;failed_call("NaN width",&p,s,1,&o,&w,CP_PATH_INVALID);o=defaults();
    o.width=-1;failed_call("negative width",&p,s,1,&o,&w,CP_PATH_INVALID);o=defaults();
    o.tolerance=INFINITY;failed_call("infinite tolerance",&p,s,1,&o,&w,CP_PATH_INVALID);o=defaults();
    o.transform.tx=NAN;failed_call("NaN transform",&p,s,1,&o,&w,CP_PATH_INVALID);o=defaults();
    s[1].controls[1].x=NAN;failed_call("invalid later segment",&p,s,2,&o,&w,CP_PATH_INVALID);s[1].controls[1].x=1;
    s[0].degree=4;failed_call("invalid degree",&p,s,1,&o,&w,CP_PATH_INVALID);s[0].degree=1;
    w.capacity_words=WORDS-1;failed_call("short scratch",&p,s,1,&o,&w,CP_PATH_INVALID);w.capacity_words=WORDS;
    w.candidate=reference;failed_call("scratch alias",&p,s,1,&o,&w,CP_PATH_INVALID);w.candidate=candidate;
    w.candidate=output+W;failed_call("destination padding alias",&p,s,1,&o,&w,CP_PATH_INVALID);w.candidate=candidate;
    p.stride_words=W-1;failed_call("invalid stride",&p,s,1,&o,&w,CP_PATH_INVALID);p=plane();
    p.origin_x=INT_MAX-W+2;failed_call("origin overflow",&p,s,1,&o,&w,CP_PATH_INVALID);p=plane();
    o.max_sample_tests=1;failed_call("sample budget",&p,s,1,&o,&w,CP_PATH_BUDGET);o=defaults();
    o.max_patches=1;failed_call("patch budget after scratch",&p,s,1,&o,&w,CP_PATH_BUDGET);o=defaults();
    o.max_depth=1;failed_call("subdivision nonconvergence",&p,s,1,&o,&w,CP_PATH_NONCONVERGENCE);o=defaults();
    o.cancelled=cancel_immediate;failed_call("immediate cancel",&p,s,1,&o,&w,CP_PATH_CANCELLED);o=defaults();
    cancellation c={0,70};o.cancelled=cancel_at;o.cancel_context=&c;
    failed_call("cancel after scratch progress",&p,s,1,&o,&w,CP_PATH_CANCELLED);check(c.calls==70,"cancellation callback reached target");
    o=defaults();p.origin_x=INT_MIN;p.origin_y=INT_MIN;
    cp_path_report r={0};reset(1);check(invoke(&p,s,1,&o,&r)==CP_PATH_OK,"distant extreme negative viewport clipping");
    check(memcmp(output,before,sizeof(output))==0,"offscreen shape no change");
}
static void budget_boundary(void) {
    cp_path_segment s={1,{{-3.17,-2.21},{4.37,3.13},{0,0},{0,0}}};
    cp_path_options o=defaults();cp_coverage_plane p=plane();cp_path_report r={0};
    reset(0);check(invoke(&p,&s,1,&o,&r)==CP_PATH_OK,"budget measurement status");
    size_t needed=r.sample_tests;
    check(needed>1 && needed<=o.max_sample_tests,"reported sample budget range");
    o.max_sample_tests=needed;reset(0);check(invoke(&p,&s,1,&o,&r)==CP_PATH_OK,"exact measured budget succeeds");
    o.max_sample_tests=needed-1;reset(1);cp_path_workspace w={candidate,reference,WORDS};
    failed_call("one less measured budget fails",&p,&s,1,&o,&w,CP_PATH_BUDGET);
    o=defaults();reset(0);check(invoke(&p,&s,1,&o,&r)==CP_PATH_OK,"cancel timing measurement");
    cancellation c={0,UINT_MAX};o.cancelled=cancel_at;o.cancel_context=&c;reset(0);
    check(invoke(&p,&s,1,&o,&r)==CP_PATH_OK,"cancel callback count measurement");
    unsigned final_call=c.calls;c.calls=0;c.stop=final_call;reset(1);
    failed_call("cancel at last precommit callback",&p,&s,1,&o,&w,CP_PATH_CANCELLED);
    check(c.calls==final_call,"last precommit callback reached");
}
static unsigned popcount(uint64_t x){unsigned n=0;while(x){x&=x-1;++n;}return n;}
static cp_vec2 cubic_point(const cp_path_segment *s,long double t) {
    long double u=1-t;
    long double a=u*u*u,b=3*u*u*t,c=3*u*t*t,d=t*t*t;
    return (cp_vec2){(double)(a*s->controls[0].x+b*s->controls[1].x+c*s->controls[2].x+d*s->controls[3].x),
                     (double)(a*s->controls[0].y+b*s->controls[1].y+c*s->controls[2].y+d*s->controls[3].y)};
}
/* Dense independent direct Bezier samples yield an upper distance bound.
 * Samples within max centerline step of the stroke boundary are uncertain;
 * acceptance rejects only provably classified bits. This cannot claim exact
 * masks, but catches omissions, transformed width, and axis/order mistakes. */
static void curve_reference_case(void) {
    enum{N=16384};
    cp_path_segment s={3,{{-7.123,-3.231},{-2.417,8.137},{4.271,-7.321},{8.219,3.713}}};
    cp_path_options o=defaults();o.strategy=CP_PATH_CUBIC;o.width=.877;
    cp_coverage_plane p=plane();cp_path_report r={0};reset(0);
    cp_path_status status=invoke(&p,&s,1,&o,&r);check(status==CP_PATH_OK,"curved numerical oracle status");
    if(status!=CP_PATH_OK)return;
    static cp_vec2 points[N+1];
    for(unsigned i=0;i<=N;i++)points[i]=cubic_point(&s,(long double)i/N);
    long double step=0;
    /* Derivative lies in the convex hull of three derivative controls. */
    for(unsigned i=0;i<3;i++){
        long double dx=3*((long double)s.controls[i+1].x-s.controls[i].x);
        long double dy=3*((long double)s.controls[i+1].y-s.controls[i].y);
        step=fmaxl(step,sqrtl(dx*dx+dy*dy)/N);
    }
    unsigned wrong=0,uncertain=0,classified=0;
    for(unsigned y=0;y<H;y++)for(unsigned x=0;x<W;x++)for(unsigned sy=0;sy<8;sy++)for(unsigned sx=0;sx<8;sx++){
        long double qx=p.origin_x+(int)x+((long double)sx+.5L)/8-.5L;
        long double qy=p.origin_y+(int)y+((long double)sy+.5L)/8-.5L;
        long double best=LDBL_MAX;
        for(unsigned i=0;i<=N;i++){
            long double dx=qx-points[i].x,dy=qy-points[i].y;
            long double squared=dx*dx+dy*dy;if(squared<best)best=squared;
        }
        long double distance=sqrtl(best),radius=(long double)o.width/2;
        if(distance>radius && distance<=radius+step){uncertain++;continue;}
        unsigned actual=(unsigned)((output[y*STRIDE+x]>>(8*sy+sx))&1);
        classified++;wrong+=actual!=(distance<=radius);
    }
    if(wrong)fprintf(stderr,"curve independent distance: %u wrong of %u classified, %u uncertain\n",wrong,classified,uncertain);
    check(classified>WORDS*63,"curve oracle mostly classified");check(wrong==0,"curve independent conservative distance oracle");
    check(r.worst_pixel_error==0,"curve reports selected mask reference equality");
    uint64_t saved[CAPACITY];memcpy(saved,output,sizeof(saved));
    for(unsigned i=0;i<2;i++){cp_vec2 t=s.controls[i];s.controls[i]=s.controls[3-i];s.controls[3-i]=t;}
    reset(0);status=invoke(&p,&s,1,&o,&r);check(status==CP_PATH_OK,"curve reversal status");
    unsigned changed=0;for(unsigned y=0;y<H;y++)for(unsigned x=0;x<W;x++)changed+=popcount(saved[y*STRIDE+x]^output[y*STRIDE+x]);
    check(changed==0,"curve reversal masks");
}
int main(void) {
    analytic_cases();union_cases();degree_cases();failure_cases();budget_boundary();curve_reference_case();
    printf("independent PATH acceptance: %u checks, %u failures\n",checks,failures);
    return failures?1:0;
}
