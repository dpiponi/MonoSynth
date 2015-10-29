//
//  exp_decay.h
//  MonoSynth
//
//  Created by Dan Piponi on 10/28/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

#ifndef exp_decay_h
#define exp_decay_h

#include <stdio.h>

struct ExpDecay {
    double amplitude;
};

void init_exp_decay(struct ExpDecay *exp_decay);
void step_exp_decay(struct ExpDecay *exp_decay, double dt, double decay_time, double gate);

#endif /* exp_decay_h */
