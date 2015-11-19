//
//  vco.c
//  MonoSynth
//
//  Created by Dan Piponi on 11/3/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

#include <math.h>

#include "vco.h"
#include "wave_form.h"

void init_vco(struct VCO *state) {
//    state->oscType = OSC_TYPE_SINE;
    for (int i = 0; i < MAX_NUM_OSCILLATORS; ++i) {
        init_lfo_pulse(&state->sync[i]);
        init_saw(&state->saw_state[i]);
        init_square(&state->square_state[i]);
        init_sin(&state->sin_state[i]);
        init_wave(&state->wave_state[i]);
    }
}

double offset[8] = { 0.0, 0.9712, -1.0123, 0.511, -0.522, 0.23, -0.227, 0.7122 };

void exec_vco(struct VCO *state, enum VcoType oscType, double dt, double frequency, int vco1_number, double vco1_detune, double vco1_spread, double sync_ratio) {
    double sample = 0.0;
    
    double sync_frequency = frequency*sync_ratio;

    switch (oscType) {
        case VCO_TYPE_SQUARE:
            
            for (int i = 0; i < vco1_number; ++i) {
                double detune = vco1_detune+(double)i*vco1_spread*offset[i];
                double sync_level = sync_ratio > 0.0 ? state->sync[i].result : 0.0;
                sample += step_square(&state->square_state[i],
                                             dt,
                                             sync_frequency*pow(2.0, detune),
                                             0.5, sync_level);
                exec_lfo_pulse(&state->sync[i], dt, frequency*pow(2.0, detune));
//                printf("vco square\n");
            }
            break;
            
//        case VCO_TYPE_SINE:
//            for (int i = 0; i < vco1_number; ++i) {
//                double detune = vco1_detune+(double)i*vco1_spread*offset[i];
//                double sync_level = sync_ratio > 0.0 ? state->sync[i].result : 0.0;
//                sample += step_sin(&state->sin_state[i],
//                                   dt,
//                                   sync_frequency*pow(2.0, detune), sync_level);
//                exec_lfo_pulse(&state->sync[i], dt, frequency*pow(2.0, detune));
//            }
//            break;
            
        case VCO_TYPE_SINE:
            for (int i = 0; i < vco1_number; ++i) {
                double detune = vco1_detune+(double)i*vco1_spread*offset[i];
                exec_wave(&state->wave_state[i], dt, frequency*pow(2.0, detune));
                sample += state->wave_state[i].result;
            }
            break;
            
        case VCO_TYPE_SAW:
            for (int i = 0; i < vco1_number; ++i) {
                double detune = vco1_detune+(double)i*vco1_spread*offset[i];
                double sync_level = sync_ratio > 0.0 ? state->sync[i].result : 0.0;
                sample += step_saw(&state->saw_state[i],
                                   dt,
                                   sync_frequency*pow(2.0, detune), sync_level);
                exec_lfo_pulse(&state->sync[i], dt, frequency*pow(2.0, detune));

            }
            break;
        default:
            printf("Error!\n");
            break;
    }
//    printf("res=%f\n", state->result);
 
    state->result = sample;
}