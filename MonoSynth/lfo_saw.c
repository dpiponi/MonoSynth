//
//  lfo_saw.c
//  MonoSynth
//
//  Created by Dan Piponi on 10/29/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

#include <math.h>

#include "lfo_saw.h"

void init_lfo_saw(struct LFOSaw *lfo_saw) {
    lfo_saw->phase = 0.0;
    lfo_saw->result = 0.0;
}

void exec_lfo_saw(struct LFOSaw *lfo_saw, double dt, double frequency) {
    lfo_saw->result = lfo_saw->phase/M_PI-1.0;
    lfo_saw->phase += 2.0*M_PI*dt*frequency;
    while (lfo_saw->phase >= 2*M_PI) {
        lfo_saw->phase -= 2*M_PI;
    }
}
