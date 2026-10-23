/* Independent ordinary-C11 numerical oracle, like font_verify.c. ICK produces
 * this test. Only the public coverage API is used; producer controls are never
 * read. Literal line geometry is the intended mathematical font contract. */
#include "subpixel/font.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

static uint8_t actual[14000];
static unsigned failures;
static int old_slash;
static const unsigned char slash_rows[7] = {1,2,2,4,8,8,16};
static int cell(int x,int y) {
    return x >= 0 && x < 5 && y >= 0 && y < 7 &&
        (slash_rows[y] & (1U << (4-x)));
}
/* Retained historical 4x4 bilinear threshold reconstruction, test control only. */
static unsigned old_coverage(unsigned x,unsigned y,unsigned scale) {
    unsigned count = 0;
    for (unsigned sy = 0; sy < 4; ++sy)
        for (unsigned sx = 0; sx < 4; ++sx) {
            double px = (x+(sx+.5)/4)/scale-.5;
            double py = (y+(sy+.5)/4)/scale-.5;
            int ix = (int)floor(px), iy = (int)floor(py);
            double fx = px-ix, fy = py-iy;
            double weight = (cell(ix,iy)?(1-fx)*(1-fy):0)+
                (cell(ix+1,iy)?fx*(1-fy):0)+(cell(ix,iy+1)?(1-fx)*fy:0)+
                (cell(ix+1,iy+1)?fx*fy:0);
            count += weight >= .4;
        }
    return (count*255+8)/16;
}
static int tube(double x,double y,double ax,double ay,double bx,double by) {
    double dx = bx-ax,dy = by-ay;
    double t = ((x-ax)*dx+(y-ay)*dy)/(dx*dx+dy*dy);
    if (t < 0) t = 0;
    if (t > 1) t = 1;
    double ex = x-ax-t*dx,ey = y-ay-t*dy;
    return ex*ex+ey*ey <= .36*.36;
}
static int intended_ink(uint32_t code,double x,double y) {
    switch (code) {
        case '/': return tube(x,y,.6,6.35,4.4,.65);
        case '\\': return tube(x,y,.6,.65,4.4,6.35);
        case '+': return tube(x,y,.7,3.5,4.3,3.5) || tube(x,y,2.5,1.5,2.5,5.5);
        case 0x2212: return tube(x,y,.7,3.5,4.3,3.5);
        case 0x00d7: return tube(x,y,.9,1.9,4.1,5.1) || tube(x,y,.9,5.1,4.1,1.9);
        default: return 0;
    }
}
static int geometry_cases(void) {
    const uint32_t codes[] = {'/','\\','+',0x2212,0x00d7};
    const unsigned scales[] = {1,3,5,8,14};
    const double phases[] = {-.375,0,.125,.5};
    puts("codepoint\tscale\tphase_x\tphase_y\tworst_coverage_error");
    for (unsigned ci = 0; ci < 5; ++ci)
        for (unsigned si = 0; si < 5; ++si)
            for (unsigned pi = 0; pi < 4; ++pi) {
                uint32_t code = codes[ci];
                unsigned scale = scales[si],width = 5*scale,height = 7*scale;
                double px = phases[pi],py = pi == 1 ? 0 : phases[3-pi];
                if (!sf57_render_coverage(code,scale,px,py,actual,sizeof actual)) return 2;
                unsigned worst = 0;
                for (unsigned y = 0; y < height; ++y)
                    for (unsigned x = 0; x < width; ++x) {
                        unsigned count = 0;
                        for (unsigned sy = 0; sy < 8; ++sy)
                            for (unsigned sx = 0; sx < 8; ++sx)
                                count += intended_ink(code,(x+(sx+.5)/8-px)/scale,
                                    (y+(sy+.5)/8-py)/scale);
                        unsigned wanted = (count*255+32)/64;
                        unsigned got = old_slash && code == '/' ? old_coverage(x,y,scale) : actual[y*width+x];
                        unsigned error = wanted > got ? wanted-got : got-wanted;
                        if (error > worst) worst = error;
                    }
                printf("U+%04x\t%u\t%.3f\t%.3f\t%u\n",(unsigned)code,scale,px,py,worst);
                if (worst > 8) {
                    fprintf(stderr,"SENSOR_FONT_REJECT exact finite-segment union U+%04x scale=%u error=%u\n",(unsigned)code,scale,worst);
                    ++failures;
                }
            }
    return 0;
}
static unsigned counters(unsigned width,unsigned height) {
    unsigned char seen[875] = {0};
    unsigned queue[875],holes = 0;
    for (unsigned start = 0; start < width*height; ++start) {
        if (seen[start] || actual[start] >= 128) continue;
        unsigned front = 0,back = 0;
        int exterior = 0;
        queue[back++] = start; seen[start] = 1;
        while (front < back) {
            unsigned at = queue[front++],x = at%width,y = at/width;
            if (!x || !y || x+1 == width || y+1 == height) exterior = 1;
            const int dx[] = {-1,1,0,0},dy[] = {0,0,-1,1};
            for (unsigned d = 0; d < 4; ++d) {
                int nx = (int)x+dx[d],ny = (int)y+dy[d];
                if (nx < 0 || ny < 0 || nx >= (int)width || ny >= (int)height) continue;
                unsigned next = (unsigned)ny*width+(unsigned)nx;
                if (seen[next] || actual[next] >= 128) continue;
                seen[next] = 1; queue[back++] = next;
            }
        }
        if (!exterior) ++holes;
    }
    return holes;
}
static int contour_cases(void) {
    const uint32_t codes[] = {'0','6','8','9','B','D','O','C','S','a','b','d','o','p','q',0x00b0};
    const unsigned expected[] = {1,1,2,1,2,1,1,0,0,1,1,1,1,1,1,1};
    for (unsigned i = 0; i < sizeof codes/sizeof codes[0]; ++i)
        for (unsigned scale = 3; scale <= 5; scale += 2) {
            if (!sf57_render_coverage(codes[i],scale,0,0,actual,sizeof actual)) return 2;
            unsigned found = counters(5*scale,7*scale);
            if (found != expected[i]) {
                fprintf(stderr,"SENSOR_FONT_REJECT counter topology U+%04x scale=%u wanted=%u got=%u\n",
                    (unsigned)codes[i],scale,expected[i],found);
                ++failures;
            }
        }
    return 0;
}
static int specimen(const char *path) {
    enum { WIDTH=144,HEIGHT=72,SCALE=8 };
    unsigned char image[WIDTH*HEIGHT];
    memset(image,255,sizeof image);
    if (!sf57_render_coverage('/',SCALE,0,0,actual,sizeof actual)) return 2;
    for (unsigned y = 0; y < 56; ++y)
        for (unsigned x = 0; x < 40; ++x) {
            image[(y+8)*WIDTH+x+4] = cell((int)(x/SCALE),(int)(y/SCALE)) ? 0 : 255;
            image[(y+8)*WIDTH+x+52] = (unsigned char)(255-old_coverage(x,y,SCALE));
            image[(y+8)*WIDTH+x+100] = (unsigned char)(255-actual[y*40+x]);
        }
    FILE *file = fopen(path,"wb");
    if (!file) return 2;
    int okay = fprintf(file,"P5\n%d %d\n255\n",WIDTH,HEIGHT) > 0 &&
        fwrite(image,1,sizeof image,file) == sizeof image;
    return fclose(file) == 0 && okay ? 0 : 2;
}
int main(int argc,char **argv) {
    old_slash = argc == 2 && !strcmp(argv[1],"--old-slash");
    if (geometry_cases() || contour_cases()) return 2;
    if (argc == 2 && !old_slash && specimen(argv[1])) return 2;
    if (failures) return 1;
    puts("SENSOR_FONT_ACCEPT 100 independent line-union cases and 32 sampled contour cases: PASS");
    return 0;
}
