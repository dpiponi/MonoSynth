//
//  AudioRender.m
//  MonoSynth
//
//  Created by Dan Piponi on 10/27/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AudioUnit;

#import "AudioRender.h"

OSStatus audio_render(void *inRefCon,
                      AudioUnitRenderActionFlags *ioActionFlags,
                      const AudioTimeStamp *inTimeStamp,
                      UInt32 inBusNumber,
                      UInt32 inNumberFrames,
                      AudioBufferList *ioData) {
    
    printf("Yo!\n");
    struct AudioState *state = (struct AudioState *)inRefCon;
    const double dt = 1.0/44100.0;
    float *buffer = ioData->mBuffers[0].mData;
//    printf("gate=%f\n", state->gate);
    
//    printf("lforeq=%f\n", state->lfo1_frequency);
    
    for (int i = 0; i < inNumberFrames; ++i) {
        //
        // LFOs
        //
        for (int j = 0; j < 2; ++j) {
            step_lfo_sin(&state->lfo_sin[j], dt, state->lfo_frequency[j]);
        }
        double lfo1_result = state->lfo_sin[0].result;
        
        double sample = 0.0;
        
        double offset[8] = { 0.0, 0.9712, -1.0123, 0.511, -0.522, 0.23, -0.227, 0.7122 };
        //
        // VCO1
        //
        switch (state->oscType) {
            case OSC_TYPE_SQUARE:
                
                for (int i = 0; i < state->vco1_number; ++i) {
                    double detune = state->vco1_detune+(double)i*state->vco1_spread*offset[i]+state->vco1_lfo1_modulation*lfo1_result;
                    sample += step_square_nosync(&state->square_state[i],
                                                1.0/44100.0,
                                                state->frequency*pow(2.0, detune),
                                                0.5);
                }
                break;
            case OSC_TYPE_SINE:
                for (int i = 0; i < state->vco1_number; ++i) {
                    double detune = state->vco1_detune+(double)i*state->vco1_spread*offset[i]+state->vco1_lfo1_modulation*lfo1_result;
                    sample += step_sin(&state->sin_state[i],
                                                1.0/44100.0,
                                                state->frequency*pow(2.0, detune), 0.0);
                }
                break;
            case OSC_TYPE_SAW:
                for (int i = 0; i < state->vco1_number; ++i) {
                    double detune = state->vco1_detune+(double)i*state->vco1_spread*offset[i]+state->vco1_lfo1_modulation*lfo1_result;
                    sample += step_saw(&state->saw_state[i],
                                                1.0/44100.0,
                                                state->frequency*pow(2.0, detune), 0.0);
                }
                break;
        }
//        step_exp_decay(&state->exp_decay, dt, 1.0, state->gate);
        
//        double env1 = state->exp_decay.amplitude;
        
        for (int i = 0; i < 2; ++i) {
            exec_envelope(&state->env[i], dt, state->envDelay[i],
                                              state->envAttack[i],
                                              state->envHold[i],
                                              state->envDecay[i],
                                              state->envSustain[i],
                                              state->envRelease[i],
                                              state->envRetrigger[i],
                                              state->gate);
        }
        
        double result = sample*state->env[0].level;
        if (state->vcaEnv2) {
            result *= state->env[1].level;
        }
        double shift = state->lfo_filter_cutoff_modulation[0]*state->lfo_sin[0].result+
                       state->lfo_filter_cutoff_modulation[1]*state->lfo_sin[1].result+
                        state->filter_cutoff_env_modulation[0]*state->env[0].level+
                        state->filter_cutoff_env_modulation[1]*state->env[1].level;
        double filter_frequency = state->frequency*pow(2.0, state->filter_cutoff+shift);
        step_ladder(&state->ladder, dt,
                    filter_frequency,
                    state->filter_resonance,
                    result);
        buffer[i] = 1.0*state->ladder.result;
    }
//    printf(":::");
//    for (int i = 0; i < 10; ++i) {
//        printf("%f ", buffer[i]);
//    }
//    printf("\n");
    
    return noErr;
}