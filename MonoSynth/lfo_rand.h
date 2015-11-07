//
//  lfo_rand.h
//  MonoSynth
//
//  Created by Dan Piponi on 11/6/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

#ifndef lfo_rand_h
#define lfo_rand_h

#include <stdio.h>

struct LFORand {
    double phase;
    double result;
};

void init_lfo_rand(struct LFORand *lfo_rand);
void exec_lfo_rand(struct LFORand *lfo_rand, double dt, double frequency);

#endif /* lfo_rand_h */
