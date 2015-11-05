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

void init_audio_state(struct AudioState *state) {
    //
    // UI
    //
    state->gate = 0.0;
    state->vcaEnv2 = 0;
    //
    // UI: VCA
    //
    for (int i = 0; i < 2; ++i) {
        state->vcaLfoModulation[i] = 0.0;
    }
    
    //
    // LFO
    //
    for (int i = 0; i < 2; ++i) {
        init_lfo(&state->lfo[i]);
    }
    
    // VCO1
    state->vco1_number = 1;
    state->vco1_detune = 0.0;
    state->vco1_spread = 0.0;
    state->vco1_lfo1_modulation = 0.0;
    
    init_vco(&state->vco1);
    
    state->sampleRate = 44100.0;
    state->phase = 0.0;
    state->actualFrequency = 440.0;
    state->amplitude = 0.0;
    state->frequency = 440.0f;
    state->targetAmplitude = 0.0;
    
    for (int i = 0; i < 2; ++i) {
        state->envDelay[i] = 0.0;
        state->envAttack[i] = 0.1;
        state->envHold[i] = 0.0;;
        state->envDecay[i] = 0.5;
        state->envSustain[i] = 0.5;
        state->envRelease[i] = 0.5;
        state->envRetrigger[i] = 1000.0;
        
        init_envelope(&state->env[i]);
    }
    
    init_ladder(&state->ladder);
    
    //
    // Filter
    //
    state->filter_cutoff = 1.0;
    state->filter_resonance = 2.0;
    state->filter_cutoff_lfo_modulation[0] = 0.0;
    state->filter_cutoff_lfo_modulation[1] = 0.0;
    state->filter_cutoff_env_modulation[0] = 0.0;
    state->filter_cutoff_env_modulation[1] = 0.0;
    
    //
    // ENV1
    //
    
}

OSStatus audio_render(void *inRefCon,
                      AudioUnitRenderActionFlags *ioActionFlags,
                      const AudioTimeStamp *inTimeStamp,
                      UInt32 inBusNumber,
                      UInt32 inNumberFrames,
                      AudioBufferList *ioData) {
    
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
            exec_lfo(&state->lfo[j], dt, state->lfo_frequency[j]);
        }
        
//        double sample = 0.0;
        
        //
        // VCO1
        //
//        if (i==0) printf("OSCTYPE = %d\n", state->oscType);
        exec_vco(&state->vco1, state->vcoType, state->frequency,
                 state->vco1_number,
                 state->vco1_detune+state->vco1_lfo1_modulation*state->lfo[0].result,
                 state->vco1_spread);
//        step_exp_decay(&state->exp_decay, dt, 1.0, state->gate);
        
//        double env1 = state->exp_decay.amplitude;
        
        for (int j = 0; j < 2; ++j) {
            exec_envelope(i,j, &state->env[j], dt, state->envDelay[j],
                                              state->envAttack[j],
                                              state->envHold[j],
                                              state->envDecay[j],
                                              state->envSustain[j],
                                              state->envRelease[j],
                                              state->envRetrigger[j],
                                              state->gate);
//            if (i==0) printf("level[%d]=%f\n", j, state->env[j].level);
        }
        
        //
        // VCA
        //
        double result = state->vco1.result*state->env[0].level;
        if (state->vcaEnv2) {
            result *= state->env[1].level;
        }
        for (int i = 0; i < 2; ++i) {
            double mod = 0.5*state->vcaLfoModulation[i];
            result *= 1.0-mod+mod*state->lfo[i].result;
        }
        
        double shift = state->filter_cutoff_lfo_modulation[0]*state->lfo[0].result+
                       state->filter_cutoff_lfo_modulation[1]*state->lfo[1].result+
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