//
//  lfo_saw.h
//  MonoSynth
//
//  Created by Dan Piponi on 10/29/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

#ifndef lfo_saw_h
#define lfo_saw_h

#include <stdio.h>

struct LFOSaw {
    double phase;
    double result;
};

void init_lfo_saw(struct LFOSaw *lfo_saw);
void exec_lfo_saw(struct LFOSaw *lfo_saw, double dt, double frequency);

#endif /* lfo_saw_h */
