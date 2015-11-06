//
//  lfo_square.c
//  MonoSynth
//
//  Created by Dan Piponi on 10/29/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

#include <math.h>

#include "lfo_square.h"

void init_lfo_square(struct LFOSquare *lfo_square) {
    lfo_square->phase = 0.0;
    lfo_square->result = 0.0;
}

void exec_lfo_square(struct LFOSquare *lfo_square, double dt, double frequency) {
    lfo_square->result = lfo_square->phase > M_PI ? 1.0 : -1.0;
    lfo_square->phase += 2.0*M_PI*dt*frequency;
    while (lfo_square->phase >= 2*M_PI) {
        lfo_square->phase -= 2*M_PI;
    }
}
