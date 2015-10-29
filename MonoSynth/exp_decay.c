//
//  exp_decay.c
//  MonoSynth
//
//  Created by Dan Piponi on 10/28/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

#include "exp_decay.h"

void init_exp_decay(struct ExpDecay *exp_decay) {
    exp_decay->amplitude = 0.0;
}

void step_exp_decay(struct ExpDecay *exp_decay, double dt, double decay_time, double gate) {
    if (gate > 0.0) {
        exp_decay->amplitude = 1.0;
    } else {
        exp_decay->amplitude *= 1.0-dt/decay_time;
    }
}