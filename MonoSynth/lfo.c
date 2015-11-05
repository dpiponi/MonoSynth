//
//  lfo.c
//  MonoSynth
//
//  Created by Dan Piponi on 11/5/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

#include "lfo.h"

void init_lfo(struct LFO *lfo) {
    init_lfo_sin(&lfo->lfo_sin);
}

void exec_lfo(struct LFO *lfo, double dt, double frequency) {
    step_lfo_sin(&lfo->lfo_sin, dt, frequency);
    lfo->result = lfo->lfo_sin.result;
}
