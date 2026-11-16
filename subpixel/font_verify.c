/* Independent M1 whole-path font acceptance.
 * sf57_find_glyph supplies source controls ONLY. No producer diagnostic or
 * didactic font sampler is consulted by the oracle. */
#include "subpixel/path.h"
#include "font_5x7.h"
#include <float.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

enum { MAX_W=20, MAX_H=28, STRIDE=25, CAP=STRIDE*MAX_H, WORDS=MAX_W*MAX_H, DENSE=2048 };
typedef struct {long double x,y;} point;
static uint64_t destination[CAP], candidate[WORDS], diagnostic[WORDS];
static uint64_t lower[WORDS],upper[WORDS];
static unsigned checks,failures,run_cases;
static size_t total_uncertain,total_definite,total_bad;
static const uint64_t pad=UINT64_C(0x1020408001020408);
static const long double boundary_tolerance=1.0L/64;

static void check(int condition,const char *name){
    ++checks;if(!condition){++failures;fprintf(stderr,"FAIL %s\n",name);}
}
static unsigned popcount(uint64_t x){unsigned n=0;while(x){x&=x-1;++n;}return n;}
static point screen(sf57_point p,unsigned scale,long double phase){
    return (point){(long double)p.x*scale+phase-.5L,(long double)p.y*scale+phase-.5L};
}
/* Direct long-double Bernstein evaluation, independent of de Casteljau jets
 * and subdivision used by cp_path_rasterize. */
static point evaluate(const sf57_segment *s,long double t,unsigned scale,long double phase){
    long double u=1-t;
    point c[4];for(unsigned i=0;i<=(unsigned)s->kind;i++)c[i]=screen(s->point[i],scale,phase);
    if(s->kind==SF57_LINE)return (point){u*c[0].x+t*c[1].x,u*c[0].y+t*c[1].y};
    if(s->kind==SF57_QUADRATIC)return (point){u*u*c[0].x+2*u*t*c[1].x+t*t*c[2].x,
        u*u*c[0].y+2*u*t*c[1].y+t*t*c[2].y};
    return (point){u*u*u*c[0].x+3*u*u*t*c[1].x+3*u*t*t*c[2].x+t*t*t*c[3].x,
        u*u*u*c[0].y+3*u*u*t*c[1].y+3*u*t*t*c[2].y+t*t*t*c[3].y};
}
static long double second_derivative_bound(const sf57_segment *s,unsigned scale){
    if(s->kind==SF57_LINE)return 0;
    long double bound=0;
    unsigned degree=(unsigned)s->kind;
    for(unsigned i=0;i+2<=degree;i++){
        long double x=((long double)s->point[i+2].x-2*(long double)s->point[i+1].x+s->point[i].x)*degree*(degree-1)*scale;
        long double y=((long double)s->point[i+2].y-2*(long double)s->point[i+1].y+s->point[i].y)*degree*(degree-1)*scale;
        bound=fmaxl(bound,sqrtl(x*x+y*y));
    }
    return bound;
}
static long double line_squared(point q,point a,point b){
    long double dx=b.x-a.x,dy=b.y-a.y,qx=q.x-a.x,qy=q.y-a.y;
    long double n=dx*dx+dy*dy,projection=qx*dx+qy*dy;
    if(projection<=0 || n==0)return qx*qx+qy*qy;
    if(projection>=n){qx=q.x-b.x;qy=q.y-b.y;return qx*qx+qy*qy;}
    long double cross=qx*dy-qy*dx;return cross*cross/n;
}
static int bounded_index(long double x,int high){
    if(x<0)return 0;
    if(x>high)return high;
    return (int)x;
}
static void chord(point a,point b,long double radius,long double error,unsigned width,unsigned height){
    long double rmax=radius+boundary_tolerance+error;
    long double rmin=fmaxl(0,radius-boundary_tolerance-error);
    long double minx=fminl(a.x,b.x)-rmax,maxx=fmaxl(a.x,b.x)+rmax;
    long double miny=fminl(a.y,b.y)-rmax,maxy=fmaxl(a.y,b.y)+rmax;
    int xmax=(int)(width*8)-1,ymax=(int)(height*8)-1;
    if(maxx<-.4375L || maxy<-.4375L || minx>(long double)xmax/8-.4375L || miny>(long double)ymax/8-.4375L)return;
    int x0=bounded_index(floorl(8*(minx+.5L)-.5L),xmax);
    int x1=bounded_index(ceill(8*(maxx+.5L)-.5L),xmax);
    int y0=bounded_index(floorl(8*(miny+.5L)-.5L),ymax);
    int y1=bounded_index(ceill(8*(maxy+.5L)-.5L),ymax);
    for(int y=y0;y<=y1;y++)for(int x=x0;x<=x1;x++){
        point q={(long double)x/8-.4375L,(long double)y/8-.4375L};
        long double d2=line_squared(q,a,b);
        size_t index=(size_t)(y/8)*width+(unsigned)x/8;
        uint64_t bit=UINT64_C(1)<<(8*(y%8)+x%8);
        if(d2<=rmax*rmax)upper[index]|=bit;
        if(d2<=rmin*rmin)lower[index]|=bit;
    }
}
static void oracle(const sf57_glyph *g,unsigned scale,long double phase,unsigned w,unsigned h){
    memset(lower,0,sizeof(lower));memset(upper,0,sizeof(upper));
    for(size_t i=0;i<g->segment_count;i++){
        const sf57_segment *s=&g->segments[i];
        unsigned divisions=s->kind==SF57_LINE?1:DENSE;
        /* Linear interpolation error <= max|B''| * delta_t^2 / 8.
         * The derivative Bernstein convex hull bounds max|B''|. The same
         * parameter on the curve and chord proves two-sided Hausdorff bounds.
         * 4096*LDBL_EPSILON accommodates polynomial rounding for coordinates
         * bounded by 32 screen pixels in this fixed acceptance matrix. */
        long double error=second_derivative_bound(s,scale)/(8*(long double)divisions*divisions)+4096*LDBL_EPSILON;
        check(error<boundary_tolerance/64,"dense chord geometric bound below declared boundary strip");
        point a=evaluate(s,0,scale,phase);
        for(unsigned j=1;j<=divisions;j++){
            point b=evaluate(s,(long double)j/divisions,scale,phase);
            chord(a,b,(long double)g->stroke_width*scale/2,error,w,h);a=b;
        }
    }
}
static size_t compare(unsigned w,unsigned h,size_t *uncertain){
    size_t wrong=0;*uncertain=0;
    for(unsigned y=0;y<h;y++)for(unsigned x=0;x<w;x++){
        uint64_t a=destination[y*STRIDE+x],lo=lower[y*w+x],hi=upper[y*w+x];
        wrong+=popcount((lo&~a)|(a&~hi));*uncertain+=popcount(lo^hi);
    }
    return wrong;
}
/* Four-neighbour background connectivity on the actual emitted sample bits;
 * this does not infer topology from source flags or 5x7 grayscale thresholds. */
static unsigned counters(unsigned width,unsigned height){
    enum {FINE_CAP=MAX_W*MAX_H*64};
    unsigned char seen[FINE_CAP]={0};unsigned queue[FINE_CAP];
    unsigned fw=width*8,fh=height*8,count=0;
    for(unsigned y=0;y<fh;y++)for(unsigned x=0;x<fw;x++){
        unsigned index=y*fw+x;
        uint64_t mask=destination[(y/8)*STRIDE+x/8];
        if(seen[index] || ((mask>>(8*(y%8)+x%8))&1))continue;
        unsigned read=0,write=0;int exterior=0;queue[write++]=index;seen[index]=1;
        while(read<write){
            unsigned current=queue[read++],cx=current%fw,cy=current/fw;
            if(cx==0 || cy==0 || cx+1==fw || cy+1==fh)exterior=1;
            const int dx[4]={-1,1,0,0},dy[4]={0,0,-1,1};
            for(unsigned d=0;d<4;d++){
                int nx=(int)cx+dx[d],ny=(int)cy+dy[d];
                if(nx<0 || ny<0 || nx>=(int)fw || ny>=(int)fh)continue;
                unsigned next=(unsigned)ny*fw+(unsigned)nx;
                mask=destination[((unsigned)ny/8)*STRIDE+(unsigned)nx/8];
                if(seen[next] || ((mask>>(8*(ny%8)+nx%8))&1))continue;
                seen[next]=1;queue[write++]=next;
            }
        }
        if(!exterior)count++;
    }
    return count;
}
static size_t convert(const sf57_glyph *g,cp_path_segment segments[16]){
    for(size_t i=0;i<g->segment_count;i++){
        segments[i].degree=(unsigned)g->segments[i].kind;
        for(unsigned j=0;j<=segments[i].degree;j++)segments[i].controls[j]=(cp_vec2){g->segments[i].point[j].x,g->segments[i].point[j].y};
    }
    return g->segment_count;
}
static size_t mutate(cp_path_segment s[16],size_t n,const char *name){
    if(!strcmp(name,"closed-C")){
        s[n]=(cp_path_segment){1,{s[n-1].controls[s[n-1].degree],s[0].controls[0],{0,0},{0,0}}};return n+1;
    }
    /* Keep the outer upper-right, lower-bottom/right, lower-left and
     * upper-left arcs, joining the outer sides directly. Removing both
     * internal waist arcs merges the two empty counters into one. */
    cp_path_segment original[8];memcpy(original,s,sizeof(original));
    s[0]=original[0];
    s[1]=(cp_path_segment){1,{original[0].controls[3],original[5].controls[0],{0,0},{0,0}}};
    s[2]=original[5];s[3]=original[6];
    s[4]=(cp_path_segment){1,{original[6].controls[3],original[3].controls[0],{0,0},{0,0}}};
    s[5]=original[3];return 6;
}
static void run(const sf57_glyph *g,unsigned scale,long double phase,cp_path_strategy strategy,const char *mutant){
    unsigned width=5*scale,height=7*scale;cp_path_segment segments[16]={0};
    size_t n=convert(g,segments);if(mutant)n=mutate(segments,n,mutant);
    for(size_t i=0;i<CAP;i++)destination[i]=pad;
    for(unsigned y=0;y<height;y++)for(unsigned x=0;x<width;x++)destination[y*STRIDE+x]=0;
    cp_coverage_plane plane={destination,CAP,STRIDE,width,height,0,0};
    cp_path_workspace workspace={candidate,diagnostic,WORDS};
    cp_path_options o={0};o.transform=(cp_path_transform){scale,0,0,scale,(double)phase-.5,(double)phase-.5};
    o.width=g->stroke_width*scale;o.tolerance=.01;o.max_pixel_error=2;o.max_depth=24;
    o.max_patches=100000;o.max_sample_tests=200000000;o.strategy=strategy;
    cp_path_report report={0};cp_path_status status=cp_path_rasterize(&plane,segments,n,&o,&workspace,&report);
    run_cases++;check(status==CP_PATH_OK,"whole-path font render succeeds");
    if(status!=CP_PATH_OK){fprintf(stderr,"glyph %c scale %u phase %.3Lf strategy %d status %d\n",g->name,scale,phase,strategy,status);return;}
    check(strategy==CP_PATH_AUTO?(report.selected==CP_PATH_QUADRATIC || report.selected==CP_PATH_CUBIC):report.selected==strategy,"forced strategy retained or auto names actual choice");
    unsigned bad_padding=0;
    for(unsigned y=0;y<MAX_H;y++)for(unsigned x=0;x<STRIDE;x++)if((y>=height || x>=width) && destination[y*STRIDE+x]!=pad)bad_padding++;
    check(bad_padding==0,"whole-path font padding and unused rows unchanged");
    size_t uncertain=0,bad=compare(width,height,&uncertain);total_bad+=bad;total_uncertain+=uncertain;total_definite+=(size_t)width*height*64-uncertain;
    check(bad==0,"independent geometric masks outside 1/64 pixel boundary strip");
    unsigned holes=scale==1?counters(width,height):0;
    if(scale==1)check(holes==(g->name=='O'?1u:g->name=='8'?2u:0u),"known 40x56 counter topology");
    char counter_text[32];
    if(scale==1)(void)snprintf(counter_text,sizeof(counter_text),"%u",holes);
    else (void)snprintf(counter_text,sizeof(counter_text),"NOT_CHECKED");
    printf("glyph %c scale %u phase %+.3Lf strategy %d selected %d bad %zu uncertain %zu counters %s%s\n",g->name,scale,phase,strategy,report.selected,bad,uncertain,counter_text,mutant?" MUTANT":"");
}
int main(int argc,char **argv){
    check(LDBL_MANT_DIG>=64,"host long-double precision at least 64 binary significand bits");
    if(argc==3 && !strcmp(argv[1],"--mutant")){
        const char *mutant=argv[2];
        if(strcmp(mutant,"closed-C") && strcmp(mutant,"merged-8")){fprintf(stderr,"unknown mutant\n");return 2;}
        const sf57_glyph *g=sf57_find_glyph(!strcmp(mutant,"closed-C")?'C':'8');
        check(g!=NULL,"source master exists");if(!g)return 2;
        oracle(g,1,0,5,7);run(g,1,0,CP_PATH_CUBIC,mutant);
    }else if(argc==1){
        const char names[4]={'O','C','S','8'};const unsigned scales[3]={1,2,4};
        const long double phases[2]={-.125L,.125L};
        for(unsigned gi=0;gi<4;gi++){
            const sf57_glyph *g=sf57_find_glyph(names[gi]);check(g!=NULL,"source master exists");if(!g)return 2;
            for(unsigned si=0;si<3;si++)for(unsigned pi=0;pi<2;pi++){
                unsigned scale=scales[si];oracle(g,scale,phases[pi],5*scale,7*scale);
                for(unsigned strategy=CP_PATH_AUTO;strategy<=CP_PATH_CUBIC;strategy++)run(g,scale,phases[pi],(cp_path_strategy)strategy,NULL);
            }
            oracle(g,1,0,5,7);run(g,1,0,CP_PATH_CUBIC,NULL);
        }
    }else{fprintf(stderr,"usage: font-independent [--mutant closed-C|merged-8]\n");return 2;}
    printf("independent FONT acceptance: %u render cases, %u checks, %u failures; %zu definite samples, %zu boundary samples, %zu wrong definite samples\n",run_cases,checks,failures,total_definite,total_uncertain,total_bad);
    return failures?1:0;
}
