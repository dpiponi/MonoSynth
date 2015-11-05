//
//  lfo.h
//  MonoSynth
//
//  Created by Dan Piponi on 11/5/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

#ifndef lfo_h
#define lfo_h

#include <stdio.h>

#include "lfo_sin.h"

enum LfoType {
    LFO_TYPE_SINE = 0,
    LFO_TYPE_SQUARE = 1,
    LFO_TYPE_SAW = 2,
    LFO_TYPE_RAND = 3
};


struct LFO {
    struct LFOSin lfo_sin;
    
    double result;
};

void init_lfo(struct LFO *lfo);

void exec_lfo(struct LFO *lfo, double dt, double frequency);

#endif /* lfo_h */
