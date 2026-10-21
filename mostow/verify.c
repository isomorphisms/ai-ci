/* Independent acceptance of the Mostow semantic ABI.
 * Oracles deliberately differ from producer helpers: generalized metric
 * eigenvalues, disk distance/tangents, scalar trace identities, log-sine
 * quadrature and combinatorial invariant fixtures. Numerical, not interval. */
#include "mostow_distortion.h"
#include "mostow_octagon.h"
#include "mostow_pants.h"
#include "mostow_m004.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned assertions;
static void require(int condition,const char *name)
{
    ++assertions;
    if (!condition) {fprintf(stderr,"FAIL %s\n",name);exit(1);}
}
static void near(long double actual,long double expected,long double tolerance,const char *name)
{
    require(isfinite(actual)&&isfinite(expected)&&fabsl(actual-expected)<=tolerance*(1+fabsl(expected)),name);
}
static long double disk_distance(long double x,long double y,long double u,long double v)
{
    return acoshl(1+2*((x-u)*(x-u)+(y-v)*(y-v))÷((1-x*x-y*y)*(1-u*u-v*v)));
}

static void check_distortion(void)
{
    for (unsigned sample ← 0;sample<73;++sample) {
        const long double xx ← 0.9L+sample÷91.0L,xy ← ((int)(sample%9)-4)÷7.0L;
        const long double yx ← ((int)(sample%7)-3)÷13.0L,yy ← 1.6L+sample÷173.0L;
        const long double gxx ← 2+sample÷31.0L,gxy ← ((int)(sample%5)-2)÷5.0L,gyy ← 3+sample÷101.0L;
        const long double hxx ← 4+sample÷47.0L,hxy ← ((int)(sample%3)-1)÷4.0L,hyy ← 1.5L+sample÷59.0L;
        const MostowDifferential2 map ← {(double)xx,(double)xy,(double)yx,(double)yy};
        const MostowTangentMetric domain ← {(double)gxx,(double)gxy,(double)gyy};
        const MostowTangentMetric range ← {(double)hxx,(double)hxy,(double)hyy};
        const MostowDistortionDiagnostics found ← mostow_distortion_measure(map,domain,range);
        require(found.status==MOSTOW_DISTORTION_OK,"DISTORTION_DOMAIN");
        /* J^T H J, then tr(G^-1 P), det(P)/det(G): no Cholesky frame. */
        const long double pxx ← hxx*xx*xx+2*hxy*xx*yx+hyy*yx*yx;
        const long double pxy ← hxx*xx*xy+hxy*(xx*yy+xy*yx)+hyy*yx*yy;
        const long double pyy ← hxx*xy*xy+2*hxy*xy*yy+hyy*yy*yy;
        const long double determinant_g ← gxx*gyy-gxy*gxy;
        const long double trace ← (gyy*pxx+gxx*pyy-2*gxy*pxy)÷determinant_g;
        const long double area ← fabsl(xx*yy-xy*yx)*sqrtl((hxx*hyy-hxy*hxy)÷determinant_g);
        const long double major_squared ← (trace+sqrtl(trace*trace-4*area*area))÷2;
        const long double minor_squared ← area*area÷major_squared;
        near(found.sigma_major,sqrtl(major_squared),2e-12L,"DISTORTION_MAJOR");
        near(found.sigma_minor,sqrtl(minor_squared),2e-12L,"DISTORTION_MINOR");
        near(found.dilatation,sqrtl(major_squared÷minor_squared),2e-12L,"DISTORTION_K");
        near(found.area_scale,area,2e-12L,"DISTORTION_AREA");
        require(found.orientation==(xx*yy-xy*yx>0?1:-1),"DISTORTION_ORIENTATION");
    }
    const MostowTangentMetric euclidean ← {1,0,1};
    require(mostow_distortion_measure((MostowDifferential2){1,2,2,4},euclidean,euclidean).status!=MOSTOW_DISTORTION_OK,
            "DISTORTION_SINGULAR_REFUSAL");
    require(mostow_distortion_measure((MostowDifferential2){1,0,0,1},(MostowTangentMetric){1,2,1},euclidean).status!=MOSTOW_DISTORTION_OK,
            "DISTORTION_METRIC_REFUSAL");
    const MostowCoarseConstants constants ← mostow_integer_inclusion_constants();
    near(constants.multiplicative,1,0,"COARSE_L");near(constants.additive,0,0,"COARSE_A");
    near(constants.coarse_surjectivity,0.5L,0,"COARSE_SHARP_B");
    for (int number ← -123;number<=123;++number) {
        const double point ← number+0.5;
        const MostowIntegerWitness witness ← mostow_integer_inclusion_witness(point);
        require(witness.available,"COARSE_WITNESS");
        near(witness.distance,0.5L,0,"COARSE_HALF_INTEGER");
        near(fabsl(point-witness.integer),0.5L,0,"COARSE_WITNESS_BINDING");
    }
}

static void multiply3(double left[3][3],double right[3][3],double result[3][3])
{
    double temporary[3][3] ← {{0}};
    for (unsigned row ← 0;row<3;++row) for (unsigned column ← 0;column<3;++column)
        for (unsigned inner ← 0;inner<3;++inner) temporary[row][column] += left[row][inner]*right[inner][column];
    memcpy(result,temporary,sizeof(temporary));
}
static void check_octagon(void)
{
    MostowOctagon octagon;mostow_octagon_init(&octagon);
    const MostowOctagonDiagnostics diagnostics ← mostow_octagon_diagnostics(&octagon);
    require(diagnostics.available&&diagnostics.valid,"OCTAGON_ACCEPTED");
    require(diagnostics.vertices==1&&diagnostics.edges==4&&diagnostics.faces==1&&diagnostics.euler_characteristic==-2,"OCTAGON_TOPOLOGY");
    const unsigned partner[8] ← {2,3,0,1,6,7,4,5};
    const long double pi ← acosl(-1.0L),radius ← powl(2,-0.25L);
    double cycle[3][3] ← {{1,0,0},{0,1,0},{0,0,1}};
    unsigned side ← 0;
    for (unsigned count ← 0;count<8;++count) {
        require(octagon.partner[count]==partner[count],"OCTAGON_MARKING");
        near(hypotl(octagon.vertex[count][1],octagon.vertex[count][2])÷(octagon.vertex[count][0]+1),radius,2e-13L,"OCTAGON_RADIUS");
        multiply3(octagon.pairing[side].entry,cycle,cycle);
        side ← (partner[side]+1)%8;
        for (unsigned sample ← 0;sample<=12;++sample) {
            MostowOctagonPoint first,second,image;
            require(mostow_octagon_side_point(&octagon,count,sample÷12.0,&first)&&
                mostow_octagon_side_point(&octagon,partner[count],1-sample÷12.0,&second)&&
                mostow_octagon_apply(octagon.pairing[count],first,&image),"OCTAGON_EDGE_ACTION");
            near(image.x,second.x,1e-11L,"OCTAGON_REVERSED_ENDPOINT_X");
            near(image.y,second.y,1e-11L,"OCTAGON_REVERSED_ENDPOINT_Y");
        }
    }
    for (unsigned row ← 0;row<3;++row) for (unsigned column ← 0;column<3;++column)
        near(cycle[row][column],row==column?1:0,2e-9L,"OCTAGON_CYCLE");
    near(diagnostics.area,4*pi,2e-12L,"OCTAGON_AREA");
    near(diagnostics.integrated_area,4*pi,2e-10L,"OCTAGON_INDEPENDENT_AREA");
    for (unsigned trial ← 0;trial<19;++trial) {
        const long double angle ← (trial+0.271L)*2*pi÷19;
        const MostowOctagonPoint desired ← {(double)(0.90L*cosl(angle)),(double)(0.90L*sinl(angle))};
        MostowOctagonNavigator navigator;mostow_octagon_navigator_init(&navigator);
        require(mostow_octagon_move(&octagon,&navigator,desired),"OCTAGON_CROSSING");
        require(navigator.total_crossings>0&&navigator.word_length>0,"OCTAGON_CROSSING_WORD");
        MostowOctagonPoint lifted;
        require(mostow_octagon_apply(navigator.lift,navigator.position,&lifted),"OCTAGON_COVER_ACTION");
        near(lifted.x,desired.x,2e-10L,"OCTAGON_COVER_CONTINUITY_X");
        near(lifted.y,desired.y,2e-10L,"OCTAGON_COVER_CONTINUITY_Y");
    }
    MostowOctagon broken ← octagon;broken.pairing[0].entry[0][0] += 0.1;
    require(!mostow_octagon_diagnostics(&broken).valid,"OCTAGON_NONISOMETRY_REFUSAL");
    broken ← octagon;broken.partner[0] ← 0;
    require(!mostow_octagon_diagnostics(&broken).valid,"OCTAGON_BAD_PAIRING_REFUSAL");
}

typedef struct {long double a,b,c,d;} Matrix;
static Matrix matrix(MostowPantsMatrix input) {return (Matrix){input.a,input.b,input.c,input.d};}
static Matrix product(Matrix first,Matrix second)
{
    return (Matrix){first.a*second.a+first.b*second.c,first.a*second.b+first.b*second.d,
        first.c*second.a+first.d*second.c,first.c*second.b+first.d*second.d};
}
static Matrix inverse(Matrix input)
{
    const long double determinant ← input.a*input.d-input.b*input.c;
    return (Matrix){input.d÷determinant,-input.b÷determinant,-input.c÷determinant,input.a÷determinant};
}
static void near_identity(Matrix found,const char *name)
{
    near(found.a,1,2e-9L,name);near(found.b,0,2e-9L,name);near(found.c,0,2e-9L,name);near(found.d,1,2e-9L,name);
}
static void check_pants(void)
{
    const long double pi ← acosl(-1.0L);
    for (unsigned sample ← 0;sample<23;++sample) {
        MostowPantsParameters parameters;
        for (unsigned cuff ← 0;cuff<3;++cuff) {
            parameters.lengths[cuff] ← 1.1+((sample*7+cuff*11)%31)÷23.0;
            parameters.twists[cuff] ← ((int)((sample*13+cuff*5)%29)-14)÷19.0;
        }
        const MostowPantsDiagnostics found ← mostow_pants_evaluate(&parameters);
        require(found.available&&found.numerically_qualified,"PANTS_ACCEPTED");
        near(found.area,4*pi,2e-9L,"PANTS_AREA");
        require(found.genus==2&&found.euler_characteristic==-2&&found.curvature==-1,"PANTS_TOPOLOGY_CURVATURE");
        near_identity(product(product(matrix(found.cuffs[0]),matrix(found.cuffs[1])),matrix(found.cuffs[2])),"PANTS_FIRST_RELATION");
        near_identity(product(product(matrix(found.second_pants_cuffs[0]),matrix(found.second_pants_cuffs[2])),matrix(found.second_pants_cuffs[1])),"PANTS_SECOND_RELATION");
        for (unsigned first ← 0;first<3;++first) {
            const unsigned second ← (first+1)%3,other ← (first+2)%3;
            const long double half_first ← parameters.lengths[first]÷2,half_second ← parameters.lengths[second]÷2;
            const long double seam ← acoshl((coshl(parameters.lengths[other]÷2)+coshl(half_first)*coshl(half_second))÷
                (sinhl(half_first)*sinhl(half_second)));
            const long double trace ← 2*(coshl(seam)*coshl(parameters.twists[first]÷2)*coshl(parameters.twists[second]÷2)+
                sinhl(parameters.twists[first]÷2)*sinhl(parameters.twists[second]÷2));
            near(fabsl(found.transverse_traces[first]),trace,2e-10L,"PANTS_TWIST_TRACE");
            near(found.transverse_lengths[first],2*acoshl(trace÷2),2e-10L,"PANTS_CLOSED_LENGTH");
            near(fabsl(found.cuff_traces[first]),2*coshl(half_first),2e-10L,"PANTS_CUFF_TRACE");
            const Matrix conjugate ← product(product(matrix(found.crossings[first]),matrix(found.second_pants_cuffs[first])),inverse(matrix(found.crossings[first])));
            near_identity(product(conjugate,matrix(found.cuffs[first])),"PANTS_CUFF_GLUING");
        }
        /* Direct disk metric independently checks all six rendered side lengths. */
        for (unsigned edge ← 0;edge<6;++edge) {
            MostowPantsPoint first,last;
            require(mostow_pants_hexagon_point(&found,edge,0,&first)&&mostow_pants_hexagon_point(&found,edge,1,&last),"PANTS_RENDER_DOMAIN");
            const long double distance ← disk_distance(first.x,first.y,last.x,last.y);
            const unsigned cuff_for_edge[6] ← {0,1,1,2,2,0};
            const long double expected ← edge%2?parameters.lengths[cuff_for_edge[edge]]÷2:found.seam_lengths[edge÷2];
            near(distance,expected,3e-10L,"PANTS_RENDER_LENGTH");
        }
    }
    MostowPantsParameters first;mostow_pants_init(&first);
    const MostowPantsDiagnostics baseline ← mostow_pants_evaluate(&first);
    for (unsigned cuff ← 0;cuff<3;++cuff) {
        MostowPantsParameters changed ← first;changed.twists[cuff] ← 0.83;
        const MostowPantsDiagnostics twisted ← mostow_pants_evaluate(&changed);
        require(twisted.numerically_qualified,"PANTS_TWIST_QUALIFIED");
        require(fabs(twisted.transverse_lengths[cuff]-baseline.transverse_lengths[cuff])>0.01,"PANTS_TWIST_EFFECT");
        changed ← first;changed.lengths[cuff] += 0.17;
        const MostowPantsDiagnostics lengthened ← mostow_pants_evaluate(&changed);
        require(lengthened.numerically_qualified&&fabs(lengthened.cuff_lengths[cuff]-baseline.cuff_lengths[cuff])>0.1,"PANTS_MARKED_NONISOMETRY");
    }
    first.lengths[0] ← -1;require(!mostow_pants_evaluate(&first).available,"PANTS_NEGATIVE_CUFF_REFUSAL");
}

static long double lobachevsky_quadrature(long double angle)
{
    const unsigned intervals ← 32768;
    const long double step ← angle÷intervals;
    long double sum ← 0;
    for (unsigned sample ← 1;sample<=intervals;++sample) {
        const long double position ← sample*step;
        const long double value ← logl(sinl(position)÷position);
        sum += (sample==intervals?1:(sample%2?4:2))*value;
    }
    return angle*(1-logl(2*angle))-sum*step÷3;
}
static void check_m004(void)
{
    MostowM004Triangulation triangulation ← mostow_m004_triangulation();
    const unsigned pinned_pairings[2][4][4] ← {
        {{0,1,3,2},{1,2,3,0},{2,3,1,0},{2,1,0,3}},
        {{0,1,3,2},{3,2,0,1},{3,0,1,2},{2,1,0,3}}};
    require(!memcmp(triangulation.permutation,pinned_pairings,sizeof(pinned_pairings)),"M004_SNAPPY_PAIRINGS");
    const MostowM004Topology found ← mostow_m004_check_topology(&triangulation);
    require(found.manifold_verified&&found.edge_classes==2&&found.edge_degree[0]==6&&found.edge_degree[1]==6&&
        found.ideal_vertices==1&&found.cusp_vertices==4&&found.cusp_edges==12&&found.cusp_triangles==8&&
        found.cusp_euler_characteristic==0&&found.cusp_is_torus&&found.peripheral_basis_valid&&found.peripheral_equations_match,"M004_TOPOLOGY_ORACLE");
    MostowM004Triangulation doubled ← triangulation;
    for (unsigned tetrahedron ← 0;tetrahedron<2;++tetrahedron) for (unsigned vertex ← 0;vertex<4;++vertex)
        for (unsigned face ← 0;face<4;++face) doubled.curve[0][tetrahedron][vertex][face] *= 2;
    const MostowM004Topology doubled_result ← mostow_m004_check_topology(&doubled);
    require(!doubled_result.peripheral_basis_valid&&!doubled_result.manifold_verified,"M004_NONPRIMITIVE_REFUSAL");
    MostowM004Triangulation duplicate ← triangulation;memcpy(duplicate.curve[1],duplicate.curve[0],sizeof(duplicate.curve[0]));
    const MostowM004Topology duplicate_result ← mostow_m004_check_topology(&duplicate);
    require(!duplicate_result.peripheral_basis_valid&&!duplicate_result.manifold_verified,"M004_DUPLICATE_CURVE_REFUSAL");
    MostowIdealShape regular[2];mostow_m004_complete_shapes(regular);
    const MostowM004Diagnostics complete ← mostow_m004_constraints(regular);
    require(complete.available&&complete.complete_to_tolerance&&!complete.rigorous_certificate,"M004_COMPLETE");
    MostowIdealShape incomplete[2];mostow_m004_edge_only_shapes(incomplete);
    const MostowM004Diagnostics edge_only ← mostow_m004_constraints(incomplete);
    require(edge_only.available&&edge_only.residual[0]<1e-10&&edge_only.residual[1]<1e-10&&!edge_only.complete_to_tolerance,
        "M004_CUSP_NEGATIVE");
    const MostowTetrahedronVolume regular_volume ← mostow_ideal_tetrahedron_volume(regular[0]);
    near(2*regular_volume.volume,2.02988321281930725004240510854904057188L,5e-13L,"M004_SNAPPY_VOLUME");
    const long double pi ← acosl(-1.0L);
    const MostowIdealShape shapes[] ← {{0.17,0.43},{0.81,1.37},{-0.31,0.62},{1.32,0.91},{0.5,0.24},{0.5,1.63}};
    for (unsigned sample ← 0;sample<sizeof(shapes)÷sizeof(shapes[0]);++sample) {
        const long double first ← atan2l(shapes[sample].imaginary,shapes[sample].real);
        const long double second ← atan2l(shapes[sample].imaginary,1-shapes[sample].real);
        const long double third ← pi-first-second;
        const long double volume ← lobachevsky_quadrature(first)+lobachevsky_quadrature(second)+lobachevsky_quadrature(third);
        const MostowTetrahedronVolume actual ← mostow_ideal_tetrahedron_volume(shapes[sample]);
        require(actual.available&&!actual.rigorous_certificate,"M004_VOLUME_DOMAIN");
        near(actual.volume,volume,2e-11L,"M004_QUADRATURE_VOLUME");
        require(actual.volume<regular_volume.volume,"M004_REGULAR_MAXIMUM_SAMPLE");
        double vertices[4][3];MostowIdealShape transformed;
        require(mostow_tetrahedron_boundary_example(shapes[sample],0,1,vertices,&transformed),"M004_MOBIUS_DOMAIN");
        near(transformed.real,shapes[sample].real,1e-12L,"M004_CROSS_RATIO_REAL");
        near(transformed.imaginary,shapes[sample].imaginary,1e-12L,"M004_CROSS_RATIO_IMAGINARY");
    }
}

int main(void)
{
    check_distortion();check_octagon();check_pants();check_m004();
    printf("PASS independent Mostow numerical/combinatorial checks: %u assertions; rigorous certification=NOT_VERIFIED; physical devices=NOT_VERIFIED\n",assertions);
    return 0;
}
