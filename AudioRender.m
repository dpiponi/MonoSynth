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

void init_ui_state(struct UiState *state) {
    //
    // UI
    //
    state->gate = 0.0;
    state->frequency = 440.0f;
    
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
    
    for (int i = 0; i < 2; ++i) {
        state->envDelay[i] = 0.0;
        state->envAttack[i] = 0.1;
        state->envHold[i] = 0.0;;
        state->envDecay[i] = 0.5;
        state->envSustain[i] = 0.5;
        state->envRelease[i] = 0.5;
        state->envRetrigger[i] = 1000.0;
    }
    
    
    state->vco1_number = 1;
    state->vco1_detune = 0.0;
    state->vco1_spread = 0.0;
    state->vco1_detune_modulation = 0.0;
    state->vco1_detune_modulation_source = SOURCE_LFO1;
    
    //
    // LPF
    //
    state->filter_cutoff = 1.0;
    state->filter_resonance = 2.0;
    state->filter_cutoff_modulation = 0.0;
    state->filter_resonance_modulation = 0.0;
    state->filter_cutoff_modulation_source = SOURCE_LFO1;
    state->filter_resonance_modulation_source = SOURCE_LFO1;
}

void init_audio_state(struct AudioState *state) {
    state->sampleRate = 44100.0;

    init_ui_state(&state->uiState);
    
    //
    // LFO
    //
    for (int i = 0; i < 2; ++i) {
        init_lfo(&state->lfo[i]);
    }
    
    // VCO1
    
    init_vco(&state->vco1);
    
    for (int i = 0; i < 2; ++i) {
        init_envelope(&state->env[i]);
    }
    
    init_ladder(&state->ladder);
    
    
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
    double source[4];
    
    for (int i = 0; i < inNumberFrames; ++i) {
        //
        // LFOs
        //
        for (int j = 0; j < 2; ++j) {
            exec_lfo(&state->lfo[j], dt, state->uiState.lfoType[j], state->uiState.lfo_frequency[j]);
        }
        source[SOURCE_LFO1] = state->lfo[0].result;
        source[SOURCE_LFO2] = state->lfo[1].result;
        
        for (int j = 0; j < 2; ++j) {
            exec_envelope(i,j, &state->env[j], dt, state->uiState.envDelay[j],
                                              state->uiState.envAttack[j],
                                              state->uiState.envHold[j],
                                              state->uiState.envDecay[j],
                                              state->uiState.envSustain[j],
                                              state->uiState.envRelease[j],
                                              state->uiState.envRetrigger[j],
                                              state->uiState.gate);
//            if (i==0) printf("level[%d]=%f\n", j, state->env[j].level);
        }
        source[SOURCE_ENV1] = state->env[0].level;
        source[SOURCE_ENV2] = state->env[1].level;
        
        exec_vco(&state->vco1, state->uiState.vcoType, dt, state->uiState.frequency,
                 state->uiState.vco1_number,
                 state->uiState.vco1_detune+state->uiState.vco1_detune_modulation*source[state->uiState.vco1_detune_modulation_source],
                 state->uiState.vco1_spread, state->uiState.vco1SyncRatio);

        //
        // VCA
        //
        double result = state->vco1.result*state->env[0].level;
        if (state->uiState.vcaEnv2) {
            result *= state->env[1].level;
        }
        
        //
        // Modulation by source
        //
        double modulation = source[state->uiState.vca_modulation_source];
        result *= state->uiState.vca_level+state->uiState.vca_modulation*modulation;
        
        double shift = state->uiState.filter_cutoff_modulation*source[state->uiState.filter_cutoff_modulation_source];
        double filter_frequency = state->uiState.frequency*pow(2.0, state->uiState.filter_cutoff+shift);
        double filter_resonance = state->uiState.filter_resonance+state->uiState.filter_resonance_modulation*source[state->uiState.filter_resonance_modulation_source];
        step_ladder(&state->ladder, dt,
                    filter_frequency,
                    filter_resonance,
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