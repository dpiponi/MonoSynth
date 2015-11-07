//
//  lfo_rand.c
//  MonoSynth
//
//  Created by Dan Piponi on 11/6/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

#include <stdlib.h>
#include <math.h>

#define ARC4RANDOM_MAX 0x100000000

#include "lfo_rand.h"

void init_lfo_rand(struct LFORand *lfo_rand) {
    lfo_rand->phase = 0.0;
    lfo_rand->result = 0.0;
}

void exec_lfo_rand(struct LFORand *lfo_rand, double dt, double frequency) {
    lfo_rand->phase += 2.0*M_PI*dt*frequency;
    while (lfo_rand->phase >= 2*M_PI) {
        lfo_rand->phase -= 2*M_PI;
        lfo_rand->result = -1.0+2.0*(double)arc4random()/ARC4RANDOM_MAX;
    }
}
