//
//  vco.c
//  MonoSynth
//
//  Created by Dan Piponi on 11/3/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

#include <math.h>

#include "vco.h"

void init_vco(struct VCO *state) {
//    state->oscType = OSC_TYPE_SINE;
    for (int i = 0; i < MAX_NUM_OSCILLATORS; ++i) {
        init_saw(&state->saw_state[i]);
        init_square(&state->square_state[i]);
        init_sin(&state->sin_state[i]);
    }
    
}

double offset[8] = { 0.0, 0.9712, -1.0123, 0.511, -0.522, 0.23, -0.227, 0.7122 };

void exec_vco(struct VCO *state, enum OscType oscType, double frequency, int vco1_number, double vco1_detune, double vco1_spread) {
    double sample = 0.0;

    switch (oscType) {
        case OSC_TYPE_SQUARE:
            
            for (int i = 0; i < vco1_number; ++i) {
                double detune = vco1_detune+(double)i*vco1_spread*offset[i];
                sample += step_square_nosync(&state->square_state[i],
                                             1.0/44100.0,
                                             frequency*pow(2.0, detune),
                                             0.5);
            }
            break;
        case OSC_TYPE_SINE:
            for (int i = 0; i < vco1_number; ++i) {
                double detune = vco1_detune+(double)i*vco1_spread*offset[i];
                sample += step_sin(&state->sin_state[i],
                                   1.0/44100.0,
                                   frequency*pow(2.0, detune), 0.0);
            }
            break;
        case OSC_TYPE_SAW:
            for (int i = 0; i < vco1_number; ++i) {
                double detune = vco1_detune+(double)i*vco1_spread*offset[i];
                sample += step_saw(&state->saw_state[i],
                                   1.0/44100.0,
                                   frequency*pow(2.0, detune), 0.0);
            }
            break;
    }
 
    state->result = sample;
}