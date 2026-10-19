/* Independently authored acceptance of the Flower Net->2D Subpixel consumer.
 * No producer/Flower fixture values or screenshot are used as an oracle.
 * All claims are host-only; no real depth or Android touch/GPU is tested.
 */
#include "flower_subpixel.h"
#include "flower.h"

#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TEST(expr,tag) do { if (!(expr)) reject(tag); } while (0)

static void reject(const char *reason) {
    fprintf(stderr, "AICI_FLOWER_SUBPIXEL_REJECT %s\n", reason);
    exit(1);
}
static unsigned ones(uint64_t bits) {
    unsigned result=0;
    while(bits) { bits&=bits-1; ++result; }
    return result;
}
/* The segment passes through (40,35+shift) in direction (20,10).
 * This is an independent analytic signed Euclidean line, NOT a sampled
 * copy of the producer's local-frame or residual implementation.
 * Every pixel uses all 64 separate rational midpoint coordinates. */
static uint64_t analytic_line_pixel(int x, int y, double shift) {
    uint64_t bits=0;
    for (int sub_y=0;sub_y<8;sub_y++)
        for(int sub_x=0;sub_x<8;sub_x++) {
            double px=x+((double)sub_x+0.5)/8.0-0.5;
            double py=y+((double)sub_y+0.5)/8.0-0.5;
            double numerator=20.0*(py-35.0-shift)-10.0*(px-40.0);
            if (fabs(numerator)<=0.52*sqrt(500.0))
                bits |= UINT64_C(1) << (sub_y*8+sub_x);
        }
    return bits;
}
static cp_curve_patch tilted_patch(double shift) {
    cp_curve_patch patch;
    cp_status status=cp_patch_from_segment(&patch,
        (cp_vec2){30.0,30.0+shift}, (cp_vec2){50.0,40.0+shift},0.52);
    TEST(status==CP_OK,"diagonal-constructor");
    return patch;
}
static void check_diagonal(void) {
    uint64_t active[9]={0};
    cp_coverage_plane plane={active,9,3,3,3,39,34};
    cp_curve_patch patch=tilted_patch(0);
    TEST(cp_coverage_plane_accumulate_3x3(&plane,&patch,40,35)==CP_OK,
         "diagonal-evaluation");
    unsigned nontrivial=0;
    for(int y=0;y<3;y++) for(int x=0;x<3;x++) {
        uint64_t expected=analytic_line_pixel(39+x,34+y,0);
        TEST(active[y*3+x]==expected,"diagonal-oracle");
        unsigned k=ones(expected);
        nontrivial += (k>0 && k<64);
    }
    TEST(nontrivial>2,"diagonal-nontrivial");
}
static void check_stride_and_union(void) {
    uint64_t words[15]={0}, prior[15]={0};
    const uint64_t padding=UINT64_C(0x8badf00dcafebabe);
    for(int row=0;row<3;row++) words[row*5+3]=words[row*5+4]=padding;
    cp_coverage_plane plane={words,15,5,3,3,39,34};
    cp_curve_patch a=tilted_patch(0),b=tilted_patch(0.75);
    TEST(cp_coverage_plane_accumulate_3x3(&plane,&a,40,35)==CP_OK,
         "stride-evaluation");
    for(int y=0;y<3;y++) {
        for(int x=0;x<3;x++)
            TEST(words[y*5+x]==analytic_line_pixel(39+x,34+y,0),
                 "stride-oracle");
        TEST(words[y*5+3]==padding && words[y*5+4]==padding,
             "stride-oracle");
    }
    TEST(cp_coverage_plane_accumulate_3x3(&plane,&b,40,35)==CP_OK,
         "mask-union-evaluation");
    unsigned different=0;
    for(int y=0;y<3;y++) {
        for(int x=0;x<3;x++) {
            uint64_t mask_a=analytic_line_pixel(39+x,34+y,0);
            uint64_t mask_b=analytic_line_pixel(39+x,34+y,0.75);
            TEST(words[y*5+x]==(mask_a|mask_b),"mask-union-oracle");
            different+=(mask_a && mask_b && mask_a!=mask_b);
        }
        TEST(words[y*5+3]==padding && words[y*5+4]==padding,
             "mask-union-stride");
    }
    TEST(different>0,"mask-union-nontrivial");
    memcpy(prior,words,sizeof prior);
    TEST(cp_coverage_plane_accumulate_3x3(&plane,&a,40,35)==CP_OK,
         "mask-repeat-evaluation");
    TEST(memcmp(words,prior,sizeof prior)==0,"mask-repeat-oracle");
    plane.stride_words=2;
    TEST(cp_coverage_plane_accumulate_3x3(&plane,&a,40,35)==CP_INVALID,
         "invalid-stride-refusal");
    TEST(memcmp(words,prior,sizeof prior)==0,"invalid-stride-write");
}
static void check_alpha(void) {
    uint64_t occupancy=UINT64_C(1);
    cp_coverage_plane plane={&occupancy,1,1,1,1,0,0};
    uint32_t dest[3]={UINT32_C(0xffffffff),UINT32_C(0x11223344),
                      UINT32_C(0xaabbccdd)};
    rough_framebuffer buffer={dest,1,1,3};
    TEST(flower_subpixel_blend(&buffer,&plane,UINT32_C(0xff000000),1),
         "alpha-evaluation");
    /* White 255 with 1/64 black => round(255 * 63/64)=251. */
    TEST(dest[0]==UINT32_C(0xfffbfbfb),"alpha-oracle");
    TEST(dest[1]==UINT32_C(0x11223344) &&
         dest[2]==UINT32_C(0xaabbccdd),"alpha-stride-oracle");
    occupancy=UINT64_C(0xffffffff);
    dest[0]=UINT32_C(0xffffffff);
    TEST(flower_subpixel_blend(&buffer,&plane,UINT32_C(0xff000000),1),
         "alpha-half-evaluation");
    TEST(dest[0]==UINT32_C(0xff808080),"alpha-oracle");
    buffer.stride_pixels=0;
    TEST(!flower_subpixel_blend(&buffer,&plane,UINT32_C(0xff000000),1),
         "alpha-invalid-refusal");
    TEST(dest[0]==UINT32_C(0xff808080),"alpha-invalid-write");
}
enum { WIDTH=160, HEIGHT=160, STRIDE=164 };
static uint64_t chart[STRIDE*HEIGHT], saved[STRIDE*HEIGHT];
static Flower flower,before;
static void check_pane_ownership(void) {
    TEST(flower_construction_pane_contains(true,576,366,88),"pane-blocks-growth");
    TEST(flower_construction_pane_contains(true,576,559,304),"pane-caption-blocks-growth");
    TEST(!flower_construction_pane_contains(false,576,400,100),"disabled-pane-restores-growth");
    TEST(!flower_construction_pane_contains(true,576,364,100),"pane-left-boundary");
    TEST(!flower_construction_pane_contains(true,576,400,305),"pane-bottom-boundary");
    TEST(flower_construction_pane_contains(true,100,12,100),"pane-small-viewport");
    TEST(!flower_construction_pane_contains(true,576,NAN,100),"pane-invalid-pointer");
}
static void check_material(void) {
    flower_init(&flower);
    before=flower;
    FlowerMaterialRound round;
    FlowerMaterialRadial spoke;
    TEST(flower_material_round(&flower.net,8,80,80,50,&round),
         "material-round");
    TEST(flower_material_radial(&flower.net,0,80,80,16,4,&spoke),
         "material-spoke");
    TEST(round.count==64 && spoke.count==16,"material-count");
    for(int i=0;i<64;i++) {
        FlowerMaterialCubic *segment=&round.segment[i];
        TEST(segment->first_node==8*64+i,"material-stable-id");
        TEST(segment->last_node==8*64+(i+1)%64,"material-periodic-seam");
        TEST(fabs(hypot(segment->control[0].x-80,
                        segment->control[0].y-80)-50)<1e-8,
             "material-chart-radius");
        FlowerMaterialCubic *next=&round.segment[(i+1)%64];
        TEST(hypot(segment->control[3].x-next->control[0].x,
                   segment->control[3].y-next->control[0].y)<1e-8,
             "material-chart-joins");
    }
    for(int i=0;i<16;i++) {
        TEST(spoke.segment[i].first_node==i*64,"material-radial-id");
        TEST(spoke.segment[i].last_node==(i+1)*64,"material-radial-edge");
    }
    TEST(memcmp(&flower,&before,sizeof flower)==0,"material-no-state-write");
    cp_coverage_plane plane={chart,STRIDE*HEIGHT,STRIDE,WIDTH,HEIGHT,0,0};
    FlowerDiagramStats sample3;
    TEST(flower_subpixel_round(&round,FLOWER_CURVE_3X3,&plane,&sample3),
         "material-3x3");
    TEST(sample3.patches==64*9 &&
         sample3.maximum_sample_evaluations==(size_t)64*9*9*64,
         "material-3x3-work");
    unsigned fractional=0;
    for(int y=0;y<HEIGHT;y++) for(int x=0;x<WIDTH;x++)
        fractional += ones(chart[y*STRIDE+x])>0 &&
                      ones(chart[y*STRIDE+x])<64;
    TEST(fractional>70,"material-3x3-fractional");
    memcpy(saved,chart,sizeof chart);
    TEST(flower_subpixel_round(&round,FLOWER_CURVE_3X3,&plane,0),
         "material-repeat");
    TEST(memcmp(chart,saved,sizeof chart)==0,"material-idempotence");
    FlowerMesh low={0},high={0};
    TEST(flower_mesh_build(&flower,1,&low),"material-density1");
    TEST(flower_mesh_build(&flower,2,&high),"material-density2");
    TEST(memcmp(&flower,&before,sizeof flower)==0,"material-density-no-write");
    for(int i=0;i<FLOWER_VERTICES;i++) {
        flower.skin.position[i]=(FlowerPoint){(float)(i%3),0,0};
        flower.skin.growth[i]=(float)i/FLOWER_VERTICES;
    }
    FlowerMaterialRound folded;
    TEST(flower_material_round(&flower.net,8,80,80,50,&folded),
         "material-folded-round");
    TEST(memcmp(&round,&folded,sizeof round)==0,"material-fold-invariance");
    memset(chart,0,sizeof chart);
    TEST(flower_subpixel_round(&folded,FLOWER_CURVE_3X3,&plane,0),
         "material-folded-coverage");
    TEST(memcmp(chart,saved,sizeof chart)==0,"material-fold-coverage");
    TEST(memcmp(&flower.net,&before.net,sizeof before.net)==0,
         "material-topology-immutable");
    flower_mesh_free(&low);
    flower_mesh_free(&high);
    memset(chart,0,sizeof chart);
    FlowerDiagramStats sample5;
    TEST(flower_subpixel_round(&folded,FLOWER_CURVE_5X5,&plane,&sample5),
         "material-5x5");
    TEST(sample5.patches==64*9 &&
         sample5.maximum_sample_evaluations==(size_t)64*9*25*64,
         "material-5x5-work");
    TEST(sample5.occupied_pixels>100,"material-5x5-coverage");
}
int main(void) {
    check_pane_ownership();
    check_diagonal();
    check_stride_and_union();
    check_alpha();
    check_material();
    puts("AICI_FLOWER_SUBPIXEL_ACCEPT independent masks, alpha, Net chart, folds, 3x3/5x5: PASS");
    return 0;
}
