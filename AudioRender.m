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
    
    struct AudioState *state = (struct AudioState *)inRefCon;
    const double dt = 1.0/44100.0;
    float *buffer = ioData->mBuffers[0].mData;
//    printf("gate=%f\n", state->gate);
    
//    printf("lforeq=%f\n", state->lfo1_frequency);
    
    for (int i = 0; i < inNumberFrames; ++i) {
        //
        // LFO
        //
        step_lfo_sin(&state->lfo1_sin, dt, state->lfo1_frequency);
        double sample;
        switch (state->oscType ) {
            case OSC_TYPE_SQUARE:
                sample = step_square_nosync(&state->square_state,
                                            1.0/44100.0,
                                            state->frequency,
                                            0.5);
                break;
            case OSC_TYPE_SINE:
                sample = step_sin(&state->sin_state,
                                            1.0/44100.0,
                                            state->frequency, 0.0);
                break;
            case OSC_TYPE_SAW:
                sample = step_saw(&state->saw_state,
                                            1.0/44100.0,
                                            state->frequency, 0.0);
                break;
        }
        step_exp_decay(&state->exp_decay, dt, 1.0, state->gate);
        
        double result = state->exp_decay.amplitude*sample;
        double shift = state->lfo1_filter_cutoff_modulation*state->lfo1_sin.result;
        double filter_frequency = state->frequency*pow(2.0, state->filter_cutoff+shift);
        step_ladder(&state->ladder, dt,
                    filter_frequency,
                    state->filter_resonance,
                    result);
        buffer[i] = 2.0*state->ladder.result;
    }
    
    return noErr;
}