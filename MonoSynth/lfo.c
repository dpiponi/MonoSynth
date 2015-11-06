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

void exec_lfo(struct LFO *lfo, double dt, enum LfoType lfoType, double frequency) {
    switch (lfoType) {
        case LFO_TYPE_SINE:
            step_lfo_sin(&lfo->lfo_sin, dt, frequency);
            lfo->result = lfo->lfo_sin.result;
            break;
        case LFO_TYPE_SQUARE:
            exec_lfo_square(&lfo->lfo_square, dt, frequency);
            lfo->result = lfo->lfo_square.result;
            break;
        case LFO_TYPE_SAW:
            exec_lfo_saw(&lfo->lfo_saw, dt, frequency);
            lfo->result = lfo->lfo_saw.result;
            break;
        default:
            break;
    }
}
