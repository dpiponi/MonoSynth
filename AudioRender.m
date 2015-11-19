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
#import "moodler_lib.h"

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
    
    
    for (int i = 0; i < 2; ++i) {
        state->vco_level[i] = 1.0;
        state->vco_number[i] = 1;
        state->vco_detune[i] = 0.0;
        state->vco_spread[i] = 0.0;
        state->vco_detune_modulation[i] = 0.0;
        state->vco_detune_modulation_source[i] = SOURCE_LFO1;
    }
    
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
    
    // VCO1 & VCO2
    
    for (int i = 0; i < 2; ++i) {
        init_vco(&state->vco[i]);
    }
    
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
        
        for (int i = 0; i < 2; ++i) {
            exec_vco(&state->vco[i], state->uiState.vco_type[i], dt, state->uiState.frequency,
                     state->uiState.vco_number[i],
                     state->uiState.vco_detune[i]+state->uiState.vco_detune_modulation[i]*source[state->uiState.vco_detune_modulation_source[i]],
                     state->uiState.vco_spread[i], state->uiState.vco_sync_ratio[i]);
        }

        //
        // VCA
        //
//        if (i==0) {
//            printf("%f %f\n", state->uiState.vco_level[0], state->uiState.vco_level[1]);
//        }
        double result = (state->vco[0].result*state->uiState.vco_level[0]+
                         state->vco[1].result*state->uiState.vco_level[1])*state->env[0].level;
        if (state->uiState.vcaEnv2) {
            result *= state->env[1].level;
        }
        
        //
        // Modulation by source
        //
        double modulation = source[state->uiState.vca_modulation_source];
        result *= state->uiState.vca_level+state->uiState.vca_modulation*modulation;
        
        //
        // LPF
        //
        double shift = state->uiState.filter_cutoff_modulation*source[state->uiState.filter_cutoff_modulation_source];
        double filter_frequency = state->uiState.frequency*pow(2.0, state->uiState.filter_cutoff+shift);
        double filter_resonance = state->uiState.filter_resonance+state->uiState.filter_resonance_modulation*source[state->uiState.filter_resonance_modulation_source];
        step_ladder(&state->ladder, dt,
                    filter_frequency,
                    filter_resonance,
                    result);
//        double final = result;// XXX 1.0*state->ladder.result;
        double final = 1.0*state->ladder.result;
        final = clamp_double(-1.0, 1.0, final);
        buffer[i] = final;// XXX 1.0*state->ladder.result;
        
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