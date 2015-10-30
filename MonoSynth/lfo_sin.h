//
//  lfo_sin.h
//  MonoSynth
//
//  Created by Dan Piponi on 10/29/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

#ifndef lfo_sin_h
#define lfo_sin_h

#include <stdio.h>

struct LFOSin {
    double phase;
    double result;
};

void init_lfo_sin(struct LFOSin *lfo_sin);
void step_lfo_sin(struct LFOSin *lfo_sin, double dt, double frequency);

#endif /* lfo_sin_h */
