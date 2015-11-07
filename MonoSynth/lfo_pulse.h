//
//  lfo_pulse.h
//  MonoSynth
//
//  Created by Dan Piponi on 11/7/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

#ifndef lfo_pulse_h
#define lfo_pulse_h

#include <stdio.h>

struct LFOPulse {
    double phase;
    double result;
};

void init_lfo_pulse(struct LFOPulse *lfo_sin);
void exec_lfo_pulse(struct LFOPulse *lfo_sin, double dt, double frequency);

#endif /* lfo_pulse_h */
