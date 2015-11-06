//
//  vco.h
//  MonoSynth
//
//  Created by Dan Piponi on 11/3/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

#ifndef vco_h
#define vco_h

#include <stdio.h>

#include "audio_square.h"
#include "audio_saw.h"
#include "audio_sin.h"

#define MAX_NUM_OSCILLATORS 8

enum VcoType {
    VCO_TYPE_SINE = 0,
    VCO_TYPE_SQUARE = 1,
    VCO_TYPE_SAW = 2
};

struct VCO {
    struct Saw saw_state[8];
    struct Sin sin_state[8];
    struct Square square_state[MAX_NUM_OSCILLATORS];
    
    double result;
};

void init_vco(struct VCO *state);

void exec_vco(struct VCO *state, enum VcoType vcoType, double frequency, int vco1_number, double vco1_detune, double vco1_spread);

#endif /* vco_h */