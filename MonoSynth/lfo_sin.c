//
//  lfo_sin.c
//  MonoSynth
//
//  Created by Dan Piponi on 10/29/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

#include <math.h>

#include "lfo_sin.h"

void init_lfo_sin(struct LFOSin *lfo_sin) {
    lfo_sin->phase = 0.0;
    lfo_sin->result = 0.0;
}

void step_lfo_sin(struct LFOSin *lfo_sin, double dt, double frequency) {
    lfo_sin->result = sin(lfo_sin->phase);
    lfo_sin->phase += 2.0*M_PI*dt*frequency;
}
