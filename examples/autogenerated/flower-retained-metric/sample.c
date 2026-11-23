/* Observation adapter only. The independent oracle reads positions, growth
 * fields and public metric results; it computes its own adjacency and angles. */
#include "flower_inspection.h"
#include <stdio.h>

static int emit(const Flower *flower, unsigned step) {
    for (int node ← 0; node < flower->net.node_count; ++node) {
        FlowerNodeMetric metric;
        if (!flower_inspection_metric(flower,node,&metric)) return 1;
        FlowerPoint reference ← flower->skin.reference[node];
        FlowerPoint actual ← flower->skin.position[node];
        if (printf("%u %d %.17g %.17g %.17g %.17g %.17g %.17g %.17g %.17g "
                   "%d %.17g %.17g %.17g %.17g %.17g %.17g\n",
                   step,node,reference.x,reference.y,reference.z,actual.x,actual.y,actual.z,
                   flower->skin.growth[node],flower->skin.radial_growth[node],metric.boundary,
                   metric.round.preferred,metric.round.realized,metric.spoke.preferred,metric.spoke.realized,
                   metric.angle_defect.preferred,metric.angle_defect.realized)<0) return 1;
    }
    return 0;
}

int main(void) {
    static Flower flower;
    FlowerHold hold;
    FlowerHit hit ← {0};
    hit.hit ← true;
    hit.radial ← 0.5f;
    hit.node ← 8 × FLOWER_SLICES + FLOWER_SLICES - 1;
    flower_init(&flower);
    if (emit(&flower,0)) return 1;
    flower_hold_init(&hold);
    FlowerPolicy policy ← flower_policy_default();
    policy.rate ← 1.5f;
    policy.radial_fraction ← 0.3f;
    if (!flower_hold_begin(&hold,0,true,true,hit)) return 1;
    for (int step ← 0; step < 24; ++step)
        if (!flower_hold_frame_policy(&flower,&hold,0,true,true,hit,FLOWER_STEP,&policy)) return 1;
    if (flower.skin.steps!=24 || emit(&flower,24) || fflush(stdout)) return 1;
    return 0;
}
