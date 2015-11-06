//
//  lfo_square.h
//  MonoSynth
//
//  Created by Dan Piponi on 10/29/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

#ifndef lfo_square_h
#define lfo_square_h

#include <stdio.h>

struct LFOSquare {
    double phase;
    double result;
};

void init_lfo_square(struct LFOSquare *lfo_square);
void exec_lfo_square(struct LFOSquare *lfo_square, double dt, double frequency);

#endif /* lfo_square_h */
