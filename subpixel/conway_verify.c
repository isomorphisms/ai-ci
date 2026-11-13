/* Independent acceptance of the fixed, real Conway *442 seam. The expected
 * geometry is a finite square-isometry inventory and analytic line/circle
 * distances, not a second orbit engine or the producer's reference helper. */
#include "subpixel/path.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum { SIDE=128, STRIDE=133, WORDS=SIDE*SIDE, CAPACITY=STRIDE*SIDE,
       MAX_SHAPES=1400, MAX_SEGMENTS=8000 };
typedef struct { unsigned first,count,color; double width,opacity; } paint_shape;
typedef struct {
    cp_path_segment segments[MAX_SEGMENTS];
    paint_shape shapes[MAX_SHAPES];
    unsigned width,height,background,count,segment_count;
} scene;
typedef struct { int a,b,c,d,e,f; } square_isometry;
typedef struct { long double x,y; } point;
static scene wallpaper,probe;
static uint64_t masks[CAPACITY],candidate[WORDS],reference[WORDS];
static unsigned failures,checks;
static unsigned long long definite_samples,boundary_samples,charged_work,patches;
static const uint64_t padding=UINT64_C(0x1020408001020408);

static int check(int condition,const char *message) {
    checks++;
    if(!condition){if(failures++<12)fprintf(stderr,"CONWAY_REJECT %s\n",message);}
    return condition;
}
static int at_end(const char *line,int consumed) {
    for(;line[consumed];consumed++) {
        char c=line[consumed];
        if(c=='#')return 1;
        if(c!=' '&&c!='\t'&&c!='\r'&&c!='\n')return 0;
    }
    return 1;
}
static int load_scene(const char *path,scene *out) {
    FILE *input=fopen(path,"r");
    if(!input)return 0;
    char line[1024],word[32];unsigned stage=0;int active=0,ok=1;
    while(ok&&fgets(line,sizeof line,input)) {
        int consumed=0;
        if(!strchr(line,'\n')){ok=0;break;}
        if(sscanf(line," %31s",word)!=1||word[0]=='#')continue;
        if(stage==0) {
            unsigned version;
            ok=sscanf(line,"SUBPIXEL-PATH %u %n",&version,&consumed)==1&&version==1&&at_end(line,consumed);
            stage++;continue;
        }
        if(stage==1) {
            ok=sscanf(line,"canvas %u %u %x %n",&out->width,&out->height,&out->background,&consumed)==3&&
                at_end(line,consumed)&&out->width>0&&out->height>0&&out->width<=SIDE&&out->height<=SIDE;
            stage++;continue;
        }
        if(!strcmp(word,"shape")) {
            unsigned identifier;
            if(active||out->count>=MAX_SHAPES){ok=0;break;}
            paint_shape *shape=&out->shapes[out->count];
            ok=sscanf(line,"shape %u %x %lf %lf %n",&identifier,&shape->color,&shape->opacity,&shape->width,&consumed)==4&&
                identifier==out->count&&at_end(line,consumed)&&isfinite(shape->width)&&isfinite(shape->opacity);
            shape->first=out->segment_count;active=1;
        }else if(!strcmp(word,"end")) {
            ok=active&&out->shapes[out->count].count>0&&sscanf(line,"end %n",&consumed)==0&&at_end(line,consumed);
            active=0;out->count++;
        }else {
            if(!active||out->segment_count>=MAX_SEGMENTS){ok=0;break;}
            cp_path_segment *segment=&out->segments[out->segment_count];
            double values[8]={0};unsigned degree=0;
            if(!strcmp(word,"line")) {
                degree=1;ok=sscanf(line,"line %lf %lf %lf %lf %n",values,values+1,values+2,values+3,&consumed)==4;
            }else if(!strcmp(word,"cubic")) {
                degree=3;ok=sscanf(line,"cubic %lf %lf %lf %lf %lf %lf %lf %lf %n",values,values+1,values+2,values+3,values+4,values+5,values+6,values+7,&consumed)==8;
            }else {ok=0;break;}
            segment->degree=degree;ok=ok&&at_end(line,consumed);
            for(unsigned i=0;i<=degree;i++) {
                segment->controls[i]=(cp_vec2){values[2*i],values[2*i+1]};
                ok=ok&&isfinite(values[2*i])&&isfinite(values[2*i+1]);
            }
            out->segment_count++;out->shapes[out->count].count++;
        }
    }
    ok=ok&&!ferror(input)&&stage==2&&!active&&out->count>0;
    if(fclose(input))ok=0;
    return ok;
}
static int near(long double first,long double second) {return fabsl(first-second)<1e-7L;}
static point design_point(cp_vec2 screen) {
    return (point){((long double)screen.x-64)*45/8,(64-(long double)screen.y)*45/8};
}
static point move_point(point local,square_isometry transform) {
    return (point){transform.a*local.x+transform.c*local.y+84*transform.e,
                   transform.b*local.x+transform.d*local.y+84*transform.f};
}
static point undo_screen(long double x,long double y,square_isometry transform) {
    long double horizontal=(x-64)*45/8-84*transform.e;
    long double vertical=(64-y)*45/8-84*transform.f;
    return (point){transform.a*horizontal+transform.b*vertical,
                   transform.c*horizontal+transform.d*vertical};
}
static int orientation_index(square_isometry transform) {
    const int orientations[8][4]={{1,0,0,1},{0,1,-1,0},{-1,0,0,-1},{0,-1,1,0},
                                 {1,0,0,-1},{0,1,1,0},{-1,0,0,1},{0,-1,-1,0}};
    for(int i=0;i<8;i++)if(transform.a==orientations[i][0]&&transform.b==orientations[i][1]&&
        transform.c==orientations[i][2]&&transform.d==orientations[i][3])return i;
    return -1;
}
static int wallpaper_transform(unsigned pair,square_isometry *transform) {
    paint_shape path=wallpaper.shapes[2*pair];
    cp_path_segment first=wallpaper.segments[path.first];
    cp_path_segment last=wallpaper.segments[path.first+path.count-1];
    if(!check(first.degree==1&&last.degree==1&&path.count>=3,"motif keeps both line segments"))return 0;
    point start=design_point(first.controls[0]),finish=design_point(first.controls[1]);
    point end=design_point(last.controls[1]);
    long double a=(finish.x-start.x)/26,b=(finish.y-start.y)/26;
    long double c=(end.x-start.x-13*a)/26,d=(end.y-start.y-13*b)/26;
    long double e=(start.x-8*a-8*c)/84,f=(start.y-8*b-8*d)/84;
    if(!check(fabsl(a)<=1.00001L&&fabsl(b)<=1.00001L&&fabsl(c)<=1.00001L&&fabsl(d)<=1.00001L&&
        fabsl(e)<=4.00001L&&fabsl(f)<=4.00001L,"square tile bounds"))return 0;
    *transform=(square_isometry){(int)roundl(a),(int)roundl(b),(int)roundl(c),(int)roundl(d),(int)roundl(e),(int)roundl(f)};
    return check(near(a,transform->a)&&near(b,transform->b)&&near(c,transform->c)&&near(d,transform->d)&&
        near(e,transform->e)&&near(f,transform->f)&&orientation_index(*transform)>=0,"exact square isometry and tile translation");
}
static long double segment_distance(point sample,point start,point finish) {
    long double horizontal=finish.x-start.x,vertical=finish.y-start.y;
    long double squared_length=horizontal*horizontal+vertical*vertical;
    long double parameter=squared_length?((sample.x-start.x)*horizontal+(sample.y-start.y)*vertical)/squared_length:0;
    if(parameter<0)parameter=0;
    if(parameter>1)parameter=1;
    return hypotl(sample.x-start.x-parameter*horizontal,sample.y-start.y-parameter*vertical);
}
static long double motif_distance(point sample,int circle) {
    if(circle)return fabsl(hypotl(sample.x-15,sample.y-15)-3);
    long double distance=fminl(segment_distance(sample,(point){8,8},(point){34,8}),
                               segment_distance(sample,(point){47,21},(point){21,34}));
    long double arc=sample.x>=34&&sample.y<=21?fabsl(hypotl(sample.x-34,sample.y-21)-13):
        fminl(hypotl(sample.x-34,sample.y-8),hypotl(sample.x-47,sample.y-21));
    return fminl(distance,arc);
}
static cp_path_options options(cp_path_strategy strategy,double width) {
    cp_path_options result={0};
    result.transform=(cp_path_transform){1,0,0,1,0,0};result.width=width;result.tolerance=.01;
    result.max_pixel_error=2;result.max_depth=24;result.max_patches=100000;
    result.max_sample_tests=200000000;result.strategy=strategy;
    return result;
}
static int render(const scene *source,unsigned index,cp_path_strategy strategy,cp_coverage_plane *plane) {
    paint_shape shape=source->shapes[index];
    *plane=(cp_coverage_plane){masks,CAPACITY,STRIDE,source->width,source->height,0,0};
    for(unsigned row=0;row<source->height;row++)for(unsigned column=0;column<STRIDE;column++)
        masks[row*STRIDE+column]=column<source->width?0:padding;
    cp_path_workspace workspace={candidate,reference,WORDS};cp_path_report report={0};
    cp_path_options quality=options(strategy,shape.width);
    int ok=check(cp_path_rasterize(plane,source->segments+shape.first,shape.count,&quality,&workspace,&report)==CP_PATH_OK,"native shape converges");
    if(!ok)return 0;
    charged_work+=report.sample_tests;patches+=report.patches;
    check(strategy==CP_PATH_AUTO||report.selected==strategy,"forced strategy is honored");
    unsigned corrupt=0;
    for(unsigned row=0;row<source->height;row++)for(unsigned column=source->width;column<STRIDE;column++)
        corrupt+=masks[row*STRIDE+column]!=padding;
    check(corrupt==0,"native row padding preserved");
    return 1;
}
static void wallpaper_masks(unsigned index,square_isometry transform,cp_path_strategy strategy) {
    paint_shape shape=wallpaper.shapes[index];
    if(!check(shape.color==0xff252a2e&&near(shape.opacity,1)&&near(shape.width,16.L/45),"wallpaper paint metadata"))return;
    int circle=(int)(index%2);point lower={circle?11:7,circle?11:7},upper={circle?19:48,circle?19:35};
    long double min_x=1e9L,max_x=-1e9L,min_y=1e9L,max_y=-1e9L;
    for(int corner=0;corner<4;corner++) {
        point location=move_point((point){corner&1?upper.x:lower.x,corner&2?upper.y:lower.y},transform);
        long double x=64+location.x*8/45,y=64-location.y*8/45;
        min_x=fminl(min_x,x);max_x=fmaxl(max_x,x);min_y=fminl(min_y,y);max_y=fmaxl(max_y,y);
    }
    cp_coverage_plane plane;
    if(!render(&wallpaper,index,strategy,&plane))return;
    unsigned bad=0;
    for(unsigned y=0;y<SIDE;y++)for(unsigned x=0;x<SIDE;x++) {
        uint64_t actual=masks[y*STRIDE+x];
        if(x+.5L<min_x||x-.5L>max_x||y+.5L<min_y||y-.5L>max_y) {
            if(actual)bad++;
            continue;
        }
        for(unsigned sy=0;sy<8;sy++)for(unsigned sx=0;sx<8;sx++) {
            point sample=undo_screen(x+((long double)sx+.5L)/8-.5L,y+((long double)sy+.5L)/8-.5L,transform);
            long double separation=motif_distance(sample,circle)*8/45-8.L/45;
            /* Declared 1/32px uncertainty includes the bridge's 0.01px
             * circular approximation. No claim of exact boundary decisions. */
            if(fabsl(separation)<=1.L/32){boundary_samples++;continue;}
            definite_samples++;
            if((int)((actual>>(8*sy+sx))&1)!=(separation<0))bad++;
        }
    }
    check(bad==0,"independent analytic wallpaper sample masks");
}
static unsigned population(uint64_t bits) {unsigned count=0;while(bits){bits&=bits-1;count++;}return count;}
static unsigned blend_channel(unsigned source,unsigned destination,unsigned count) {
    /* CSS #f008 expands to #ff000088: alpha is exactly 136/255.
     * Sample coverage is independently count/64. */
    unsigned numerator=136*count;
    return (source*numerator+destination*(255*64-numerator)+(255*64)/2)/(255*64);
}
static int compare_ppm(const char *path,const uint32_t *expected) {
    FILE *input=fopen(path,"rb");if(!input)return 0;
    char header[32];unsigned width,height,maximum;int ok=fgets(header,sizeof header,input)&&!strcmp(header,"P6\n")&&
        fscanf(input,"%u %u\n%u",&width,&height,&maximum)==3&&width==32&&height==24&&maximum==255&&fgetc(input)=='\n';
    for(unsigned i=0;i<32*24&&ok;i++) {
        unsigned char rgb[3];ok=fread(rgb,1,3,input)==3;
        if(ok&&(rgb[0]!=((expected[i]>>16)&255)||rgb[1]!=((expected[i]>>8)&255)||rgb[2]!=(expected[i]&255))) {
            fprintf(stderr,"native pixel (%u,%u): got %02x%02x%02x expected %06x\n",i%32,i/32,rgb[0],rgb[1],rgb[2],expected[i]&0xffffff);
            ok=0;
        }
    }
    ok=ok&&fgetc(input)==EOF&&!ferror(input);if(fclose(input))ok=0;return ok;
}
static void probe_masks(cp_path_strategy strategy,const char *ppm) {
    const point starts[6]={{13,14},{15,16},{-4,0},{13,10},{15,8},{-4,24}};
    const point finishes[6]={{21,11},{18,7},{4,0},{21,13},{18,17},{4,24}};
    const unsigned colors[3]={0x88ff0000,0x880000ff,0x8800ff00};
    uint32_t expected[32*24];for(unsigned i=0;i<32*24;i++)expected[i]=0xfff4e9d8;
    if(!check(probe.width==32&&probe.height==24&&probe.background==0xfff4e9d8&&probe.count==6,"probe geometry inventory"))return;
    for(unsigned index=0;index<6;index++) {
        paint_shape shape=probe.shapes[index];unsigned color=colors[index%3];
        if(!check(shape.color==color&&near(shape.opacity,1)&&near(shape.width,2)&&shape.count==(index%3?1U:3U),"probe ordered translucent paint"))return;
        cp_coverage_plane plane;if(!render(&probe,index,strategy,&plane))return;
        unsigned bad=0;
        for(unsigned y=0;y<24;y++)for(unsigned x=0;x<32;x++) {
            uint64_t wanted=0;
            for(unsigned sy=0;sy<8;sy++)for(unsigned sx=0;sx<8;sx++) {
                point sample={x+((long double)sx+.5L)/8-.5L,y+((long double)sy+.5L)/8-.5L};
                if(segment_distance(sample,starts[index],finishes[index])<=1)wanted|=UINT64_C(1)<<(8*sy+sx);
            }
            if(masks[y*STRIDE+x]!=wanted)bad++;
            unsigned count=population(wanted);uint32_t before=expected[y*32+x],after=0xff000000;
            for(unsigned shift=0;shift<=16;shift+=8)after|=blend_channel((color>>shift)&255,(before>>shift)&255,count)<<shift;
            expected[y*32+x]=after;
        }
        check(bad==0,"probe reflection and duplicate-segment mask union");
    }
    check(compare_ppm(ppm,expected),"native CLI ordered single-resolve translucent pixels");
}
int main(int argc,char **argv) {
    int probe_only=argc==7&&!strcmp(argv[6],"--probe-only");
    if(argc!=6&&!probe_only){fputs("usage: conway-verify WALLPAPER.sppath PROBE.sppath QUADRATIC.ppm CUBIC.ppm AUTO.ppm [--probe-only]\n",stderr);return 2;}
    if(!check(load_scene(argv[1],&wallpaper)&&load_scene(argv[2],&probe),"versioned serialized geometry"))return 1;
    if(!check(wallpaper.width==SIDE&&wallpaper.height==SIDE&&wallpaper.background==0xfff8f6ee&&wallpaper.count==1296,"real wallpaper inventory"))return 1;
    unsigned seen[81*8]={0};square_isometry transforms[648];
    for(unsigned pair=0;pair<648;pair++) {
        if(!wallpaper_transform(pair,&transforms[pair]))return 1;
        square_isometry transform=transforms[pair];int orientation=orientation_index(transform);
        unsigned key=(unsigned)(((transform.e+4)*9+transform.f+4)*8+orientation);
        if(!check(seen[key]++==0,"no duplicated square orbit member"))return 1;
    }
    for(unsigned i=0;i<81*8;i++)if(!check(seen[i]==1,"complete square orbit inventory"))return 1;
    const cp_path_strategy strategies[3]={CP_PATH_QUADRATIC,CP_PATH_CUBIC,CP_PATH_AUTO};
    for(unsigned strategy=0;strategy<3;strategy++) {
        if(!probe_only)for(unsigned index=0;index<1296;index++)wallpaper_masks(index,transforms[index/2],strategies[strategy]);
        probe_masks(strategies[strategy],argv[strategy+3]);
    }
    printf("independent Conway (%s): %u checks, %u failures; %llu definite samples, %llu boundary samples; %llu patches, %llu charged work\n",
        probe_only?"probe-only":"full-wallpaper",checks,failures,definite_samples,boundary_samples,patches,charged_work);
    if(!failures)puts("AICI_CONWAY_SUBPIXEL_ACCEPT analytic wallpaper geometry, masks and ordered native pixels: PASS");
    return failures?1:0;
}
