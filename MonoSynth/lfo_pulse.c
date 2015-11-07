//
//  lfo_pulse.c
//  MonoSynth
//
//  Created by Dan Piponi on 11/7/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

#include <math.h>

#include "lfo_pulse.h"

void init_lfo_pulse(struct LFOPulse *lfo_pulse) {
    lfo_pulse->phase = 0.0;
    lfo_pulse->result = 0.0;
}

void exec_lfo_pulse(struct LFOPulse *lfo_pulse, double dt, double frequency) {
    lfo_pulse->result = -1.0;
    lfo_pulse->phase += 2.0*M_PI*dt*frequency;
    while (lfo_pulse->phase >= 2.0*M_PI) {
        lfo_pulse->phase -= 2*M_PI;
        lfo_pulse->result = 1.0; // XXX Make subsample accurate
    }
}
