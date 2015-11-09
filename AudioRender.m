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

#define OSC_BUFSIZE 1024

void init_audio_state(struct AudioState *state) {
    //
    // UI
    //
    state->gate = 0.0;
    state->vcaEnv2 = 0;
    
    //
    // UI: VCA
    //
    state->vca_modulation = 0.0;
    state->vca_modulation_source = SOURCE_LFO1;
    state->vca_level = 1.0;
//    for (int i = 0; i < 2; ++i) {
//        state->vcaLfoModulation[i] = 0.0;
//    }
    
    //
    // UI: LFO
    //
    for (int i = 0; i < 2; ++i) {
        state->lfoType[i] = LFO_TYPE_SINE;
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
    
    state->peak = 0.0;
    
    //
    // OSC
    //
    state->osc_waiting = true;
    state->osc_pos = 0.0;
    state->osc_data = malloc(OSC_BUFSIZE*sizeof(double));
    state->osc_previous = 0.0;
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
    
    for (int i = 0; i < inNumberFrames; ++i) {
        //
        // LFOs
        //
        for (int j = 0; j < 2; ++j) {
            exec_lfo(&state->lfo[j], dt, state->lfoType[j], state->lfo_frequency[j]);
        }
        
        exec_vco(&state->vco1, state->vcoType, dt, state->frequency,
                 state->vco1_number,
                 state->vco1_detune+state->vco1_lfo1_modulation*state->lfo[0].result,
                 state->vco1_spread, state->vco1SyncRatio);
        
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
        
        //
        // Modulation by source
        //
        double modulation;
        switch (state->vca_modulation_source) {
            case SOURCE_LFO1:
                modulation = state->lfo[0].result;
                break;
            case SOURCE_LFO2:
                modulation = state->lfo[1].result;
                break;
            case SOURCE_ENV1:
                modulation = state->env[0].level;
                break;
            case SOURCE_ENV2:
                modulation = state->env[1].level;
                break;
        }
        
//        double mod = 0.5*state->vca_modulation;
        result *= state->vca_level+state->vca_modulation_source;
        
//        for (int i = 0; i < 2; ++i) {
//            double mod = 0.5*state->vcaLfoModulation[i];
//            result *= 1.0-mod+mod*state->lfo[i].result;
//        }
        
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
        
        //
        // VU Meter
        //
        double abs_sample = fabs(buffer[i]);
        state->peak *= 0.99999;
        if (abs_sample > state->peak) {
            state->peak = abs_sample;
        }
        
        //
        // Oscilloscope
        //
        if (state->osc_waiting && state->osc_previous <= 0.0 && buffer[i] > 0.0) {
            //
            // Trigger on rise
            //
            state->osc_waiting = false;
        }
        if (!state->osc_waiting) {
            state->osc_data[state->osc_pos++] = buffer[i];
            if (state->osc_pos >= OSC_BUFSIZE) {
                state->osc_pos = 0;
                state->osc_waiting = true;
            }
        }
            
        state->osc_previous = buffer[i];
    }
    
    
    return noErr;
}