/* Independent public-API witnesses for the existing framebuffer stack.
 * Expected values come from geometry, per-sample truth tables and rational
 * color arithmetic. No candidate tests, fixtures or expected arrays imported.
 * Compile STACK_LEVEL=4,7,9,11 for the successive source candidates, or 21
 * for mask algebra. This is a host oracle, never physical Android evidence. */
#include <limits.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "framebuffer.h"
#if STACK_LEVEL == 21
#include "subpixel/coverage_plane.h"
#else
#include "present.h"
#include "surface.h"
#include "touch.h"
#if STACK_LEVEL >= 7
#include "surface_aa.h"
#endif
#if STACK_LEVEL >= 9
#include "subpixel_demo.h"
#endif
#endif

static unsigned long assertions;
#define CHECK(condition, name) do { ++assertions; if (!(condition)) { \
    fprintf(stderr,"STACK_REJECT %s line=%d\n",name,__LINE__); exit(1); \
} } while (0)

#if STACK_LEVEL == 21
/* Test each bit as a Boolean proposition, rather than repeating the C
 * implementation's word expressions. Include equal-popcount disjoint masks. */
static uint64_t truth(uint64_t left, uint64_t right, unsigned operation) {
    uint64_t result=0;
    for (unsigned bit=0;bit<64;++bit) {
        unsigned a=(unsigned)((left>>bit)&1u), b=(unsigned)((right>>bit)&1u);
        unsigned keep=operation==0 ? a+b>0 : operation==1 ? a+b==2 :
                      operation==2 ? a==1 && b==0 : a+b==1;
        if (keep) result+=UINT64_C(1)<<bit;
    }
    return result;
}
static uint64_t random_state=UINT64_C(0xe07d38b9a8c15123);
static uint64_t next_word(void) {
    random_state=random_state*UINT64_C(6364136223846793005)+UINT64_C(1442695040888963407);
    return random_state;
}
static void masks(void) {
    uint64_t destination[40],source[40],expected[40],unchanged[40];
    for (unsigned trial=0;trial<4096;++trial) {
        unsigned width=1+(unsigned)(next_word()%5),height=1+(unsigned)(next_word()%4);
        unsigned source_width=1+(unsigned)(next_word()%5),source_height=1+(unsigned)(next_word()%4);
        unsigned operation=trial%4;
        int dx=(int)(next_word()%9)-4,dy=(int)(next_word()%9)-4;
        int sx=(int)(next_word()%9)-4,sy=(int)(next_word()%9)-4;
        for (unsigned i=0;i<40;++i) { destination[i]=next_word(); source[i]=next_word(); }
        memcpy(expected,destination,sizeof expected); memcpy(unchanged,source,sizeof source);
        cp_coverage_plane into={destination+1,38,7,width,height,dx,dy};
        cp_coverage_plane from={source+1,38,8,source_width,source_height,sx,sy};
        for (unsigned y=0;y<height;++y) for (unsigned x=0;x<width;++x) {
            uint64_t word=0;
            /* Locate source by searching its global pixels. This intentionally
             * differs from the implementation's subtraction/index strategy. */
            for (unsigned yy=0;yy<source_height;++yy) for (unsigned xx=0;xx<source_width;++xx)
                if (dx+(int)x==sx+(int)xx && dy+(int)y==sy+(int)yy)
                    word=source[1+8*yy+xx];
            expected[1+7*y+x]=truth(destination[1+7*y+x],word,operation);
        }
        CHECK(cp_coverage_plane_combine(&into,&from,(cp_mask_operation)operation)==CP_OK,"mask valid domains");
        CHECK(memcmp(destination,expected,sizeof expected)==0,"mask bit truth or padding");
        CHECK(memcmp(source,unchanged,sizeof source)==0,"mask source modified");
    }
    for (unsigned bit=0;bit<64;++bit) for (unsigned pair=0;pair<4;++pair)
        for (unsigned operation=0;operation<4;++operation) {
            uint64_t a=(pair&1u)?UINT64_C(1)<<bit:0,b=(pair&2u)?UINT64_C(1)<<bit:0;
            uint64_t expected_word=truth(a,b,operation);
            cp_coverage_plane into={&a,1,1,1,1,INT_MIN,INT_MAX};
            cp_coverage_plane from={&b,1,1,1,1,INT_MIN,INT_MAX};
            CHECK(cp_coverage_plane_combine(&into,&from,(cp_mask_operation)operation)==CP_OK,"mask extreme origins");
            CHECK(a==expected_word,"mask all 64 bit positions");
        }
    uint64_t a=0x0f,b=0xf0;
    cp_coverage_plane into={&a,1,1,1,1,0,0},from={&b,1,1,1,1,0,0};
    CHECK(cp_coverage_plane_combine(&into,&from,CP_MASK_INTERSECTION)==CP_OK && a==0,"equal popcount disjoint");
    for (unsigned i=0;i<40;++i) destination[i]=next_word();
    memcpy(expected,destination,sizeof expected);
    into=(cp_coverage_plane){destination+1,38,7,5,4,0,0};
    from=into;
    CHECK(cp_coverage_plane_combine(&into,&from,CP_MASK_UNION)==CP_INVALID,"mask self alias");
    from.occupied++;
    CHECK(cp_coverage_plane_combine(&into,&from,CP_MASK_UNION)==CP_INVALID,"mask partial alias");
    from=(cp_coverage_plane){source+1,38,8,5,4,0,0};
    from.capacity_words=1;
    CHECK(cp_coverage_plane_combine(&into,&from,CP_MASK_UNION)==CP_INVALID,"mask source capacity");
    from.capacity_words=38;
    CHECK(cp_coverage_plane_combine(&into,&from,(cp_mask_operation)73)==CP_INVALID,"mask invalid operation");
    from.stride_words=SIZE_MAX;
    CHECK(cp_coverage_plane_combine(&into,&from,CP_MASK_UNION)==CP_OVERFLOW,"mask index overflow");
    CHECK(memcmp(destination,expected,sizeof expected)==0,"mask failure transactional");
}
#else
static void clear(uint32_t *pixels,float *depth,unsigned count) {
    for (unsigned i=0;i<count;++i) { pixels[i]=UINT32_C(0xffffffff); depth[i]=INFINITY; }
}
static void touch_and_pixels(void) {
    rough_touch_state state;
    CHECK(rough_touch_init(&state,480,640)==0,"touch init");
    CHECK(rough_touch_apply(&state,ROUGH_TOUCH_DOWN,7,200,300)==0,"touch down");
    CHECK(rough_touch_apply(&state,ROUGH_TOUCH_MOVE,9,300,300)==0,"secondary finger");
    CHECK(rough_touch_apply(&state,ROUGH_TOUCH_MOVE,7,320,300)==1,"touch drag");
    /* A point on the front hemisphere is (0,0,-1). Right-hand yaw sends
     * its x coordinate to -sin(yaw). A right drag must make that positive. */
    double radians=state.yaw_degrees*acos(-1.0)/180.0;
    CHECK(-sin(radians)>0.70 && fabs(state.yaw_degrees-315)<1e-12,"front hemisphere direction");
    CHECK(rough_touch_apply(&state,ROUGH_TOUCH_CANCEL,7,320,300)==1 && state.yaw_degrees==0,"touch cancel");
    CHECK(rough_touch_apply(&state,ROUGH_TOUCH_DOWN,7,200,300)==0,"zoom down");
    CHECK(rough_touch_apply(&state,ROUGH_TOUCH_MOVE,7,200,1e6)==1 && state.camera_distance==12,"zoom upper bound");
    CHECK(rough_touch_apply(&state,ROUGH_TOUCH_MOVE,7,200,-1e6)==1 && state.camera_distance==2.4,"zoom lower bound");
    CHECK(rough_touch_resize(&state,640,480)==0 && !state.active,"resize cancels pointer");
    CHECK(rough_touch_apply(&state,ROUGH_TOUCH_DOWN,7,200,200)==0,"tap down");
    CHECK(rough_touch_apply(&state,ROUGH_TOUCH_UP,7,200,200)==1 && state.shape==ROUGH_SURFACE_ENNEPER,"shape toggle");

    uint32_t pixels[96*96],reference[96*96]; float depth[96*96],reference_depth[96*96];
    clear(pixels,depth,96*96); clear(reference,reference_depth,96*96);
    rough_framebuffer direct={pixels,96,96,96,depth,96}, replay={reference,96,96,96,reference_depth,96};
    FILE *stream=tmpfile(); CHECK(stream!=NULL,"stream file");
    CHECK(rough_emit_surface(stream,ROUGH_SURFACE_ENNEPER,53,96,96,4.7)==0,"stream emit");
    rewind(stream); CHECK(rough_render_stream(stream,&replay)==0,"stream replay");
    CHECK(fclose(stream)==0,"stream close");
    CHECK(rough_draw_surface(&direct,ROUGH_SURFACE_ENNEPER,53,4.7)==0,"direct draw");
    CHECK(memcmp(pixels,reference,sizeof pixels)==0 && memcmp(depth,reference_depth,sizeof depth)==0,"direct vs serialized pixels");

    uint32_t input[4]={0xffff0000u,0xff00ff00u,0xff0000ffu,0xffffffffu};
    rough_framebuffer small={input,2,2,2,NULL,0}; unsigned char rgba[3*5*4];
    memset(rgba,0x5a,sizeof rgba);
    CHECK(rough_present_rgba8888(&small,rgba,3,3,5)==0,"present dimensions");
    const unsigned char center[4]={128,128,128,255};
    CHECK(memcmp(rgba+(5+1)*4,center,4)==0,"present rational center");
    for (unsigned y=0;y<3;++y) for (unsigned x=3*4;x<5*4;++x)
        CHECK(rgba[y*20+x]==0x5a,"present stride guard");
    input[0]=0x00ff0000u; input[1]=input[2]=input[3]=0xff0000ffu;
    CHECK(rough_present_rgba8888(&small,rgba,3,3,5)==0,"present alpha");
    CHECK(rgba[24]==0 && rgba[25]==0 && rgba[26]==255 && rgba[27]==191,"premultiplied no red fringe");
}
#if STACK_LEVEL >= 7
static void antialias(void) {
    uint32_t colors[6]={0xffff0000u,0xff00ff00u,0x12345678u,0xff0000ffu,0xffffffffu,0x12345678u};
    float depths[8]={.8f,.3f,9,9,.1f,INFINITY,9,9};
    uint32_t result[3]={0xdeadbeefu,0xabcdef01u,0xcafef00du}; float z[3]={9,8,7};
    rough_framebuffer samples={colors,2,2,3,depths,4}, target={result,1,1,3,z,3};
    CHECK(rough_resolve_2x2(&samples,&target)==0,"aa resolve");
    CHECK(result[0]==0xff808080u && z[0]==.1f,"aa four colors independent depth");
    CHECK(result[1]==0xabcdef01u && z[1]==8,"aa destination padding");
    depths[5]=NAN; result[0]=0xdeadbeefu; z[0]=9;
    CHECK(rough_resolve_2x2(&samples,&target)==-1 && result[0]==0xdeadbeefu && z[0]==9,"aa failure transactional");
    uint32_t high[48*48],low[24*24]; float high_z[48*48],low_z[24*24];
    rough_framebuffer scratch={high,48,48,48,high_z,48}, destination={low,24,24,24,low_z,24};
    CHECK(rough_draw_surface_aa2(&destination,&scratch,ROUGH_SURFACE_TORUS,21,5.2)==0,"aa actual surface");
    for (unsigned y=0;y<24;++y) for (unsigned x=0;x<24;++x) {
        unsigned red=0,green=0,blue=0; float nearest=INFINITY;
        for (unsigned yy=2*y;yy<2*y+2;++yy) for (unsigned xx=2*x;xx<2*x+2;++xx) {
            uint32_t color=high[yy*48+xx]; red+=(color>>16)&255;green+=(color>>8)&255;blue+=color&255;
            if (high_z[yy*48+xx]<nearest) nearest=high_z[yy*48+xx];
        }
        uint32_t expected=0xff000000u|((red+2)/4)<<16|((green+2)/4)<<8|((blue+2)/4);
        CHECK(low[y*24+x]==expected && low_z[y*24+x]==nearest,"aa actual sample resolve");
    }
}
#endif
#if STACK_LEVEL >= 9
static void diagnostic(void) {
    uint32_t pixels[280*200]; float depths[280*200]; clear(pixels,depths,280*200);
    rough_framebuffer fb={pixels,272,200,280,depths,280}; rough_subpixel_demo_layout layout;
    CHECK(rough_subpixel_demo_draw(&fb,&layout)==0,"diagnostic draw");
    /* Evaluate the declared strip in rotated coordinates, using long double
     * at all 64 midpoint locations. No library projection or mask is reused. */
    for (unsigned mode=0;mode<2;++mode) for (int row=-2;row<=2;++row) for (int col=-2;col<=2;++col) {
        unsigned count=0;
        if (mode || (abs(row)<=1 && abs(col)<=1))
            for (unsigned y=0;y<8;++y) for (unsigned x=0;x<8;++x) {
                long double px=col+((long double)x-3.5L)/8,py=row+((long double)y-3.5L)/8;
                long double along=(4*px+3*py)/5,across=(-3*px+4*py)/5;
                long double curve=along*along/4+(mode?along*along*along/16:0);
                if (fabsl(along)<=3 && fabsl(across-curve)<=3.L/16) ++count;
            }
        uint32_t ink=mode?0xffa63873u:0xff097ca2u,expected=0xff000000u;
        for (unsigned shift=0;shift<=16;shift+=8)
            expected|=((255*(64-count)+((ink>>shift)&255)*count+32)/64)<<shift;
        unsigned x=(mode?layout.right_x:layout.left_x)+(unsigned)(col+2)*layout.cell+layout.cell/2;
        unsigned y=layout.top_y+(unsigned)(row+2)*layout.cell+layout.cell/2;
        CHECK(pixels[y*280+x]==expected,"diagnostic geometric samples to pixels");
    }
    for (unsigned y=0;y<200;++y) for (unsigned x=272;x<280;++x)
        CHECK(pixels[y*280+x]==0xffffffffu,"diagnostic padding");
    for (unsigned i=0;i<280*200;++i) CHECK(isinf(depths[i]),"diagnostic preserves depth");
}
#endif
#if STACK_LEVEL >= 11
static void smooth(void) {
    for (unsigned shape=1;shape<=2;++shape) for (int i=-7;i<=7;++i) for (int j=-6;j<=6;++j) {
        double u=i*.27,v=j*.31,actual[3],expected[3];
        if (shape==1) { expected[0]=cos(u)*cos(v);expected[1]=sin(u)*cos(v);expected[2]=sin(v); }
        else { double denominator=1+u*u+v*v;expected[0]=-2*u/denominator;expected[1]=2*v/denominator;expected[2]=(1-u*u-v*v)/denominator; }
        CHECK(rough_surface_unit_normal((rough_surface_shape)shape,u,v,actual)==0,"normal evaluate");
        for (unsigned k=0;k<3;++k) CHECK(fabs(actual[k]-expected[k])<1e-11,"normal analytic orientation");
    }
    uint32_t pixels[100];float depth[100];clear(pixels,depth,100);
    rough_framebuffer target={pixels,10,10,10,depth,10};
    rough_smooth_vertex a={{0,0,.2},1,-.42,-.55,-.72,30,90,150};
    rough_smooth_vertex b={{8,0,.8},.25,-.42,-.55,-.72,210,90,150};
    rough_smooth_vertex c={{0,8,.4},.5,-.42,-.55,-.72,70,90,150};
    CHECK(rough_fill_smooth_triangle(&target,a,b,c)==0,"smooth triangle");
    /* This raster API samples integer centers. At (2,2), barycentric weights
     * are (1/2,1/4,1/4), then attributes divide by weighted reciprocal z. */
    unsigned expected=(unsigned)floor((.5*30+.25*.25*210+.25*.5*70)/(.5+.25*.25+.25*.5)+.5);
    unsigned actual=(pixels[22]>>16)&255;
    CHECK(abs((int)actual-(int)expected)<=1,"perspective material");
    CHECK(fabs(depth[22]-.4)<1e-6,"smooth screen depth");
    a.normal_x=0;a.normal_y=0;a.normal_z=-1;
    b.normal_x=0;b.normal_y=1;b.normal_z=0;
    c.normal_x=1;c.normal_y=0;c.normal_z=0;
    a.base_red=b.base_red=c.base_red=200;
    clear(pixels,depth,100);CHECK(rough_fill_smooth_triangle(&target,a,b,c)==0,"fragment triangle");
    CHECK(pixels[11]!=pixels[15] && pixels[11]!=pixels[51],"per fragment normal");
}
#endif
#endif
int main(void) {
#if STACK_LEVEL == 21
    masks();
#else
    touch_and_pixels();
#if STACK_LEVEL >= 7
    antialias();
#endif
#if STACK_LEVEL >= 9
    diagnostic();
#endif
#if STACK_LEVEL >= 11
    smooth();
#endif
#endif
    printf("STACK_ACCEPT level=%d assertions=%lu\n",STACK_LEVEL,assertions);
    return 0;
}
