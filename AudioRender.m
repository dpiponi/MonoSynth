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
    
    for (int i = 0; i < inNumberFrames; ++i) {
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
        step_exp_decay(&state->exp_decay, dt, 0.25, state->gate);
        
        double result = state->exp_decay.amplitude*sample;
        step_ladder(&state->ladder, dt, 8.0*state->frequency, 3.5, result);
//        printf("res=%f %f\n", result, state->ladder.y3);
        buffer[i] = 2.0*state->ladder.result;
//        printf("^ %f\n", buffer[i]);
//        if (i==0) { NSLog(@"%f",result); }
#if 0
        buffer[i] = state->amplitude*sin(state->phase);
        
        state->phase += 2.0*M_PI*state->actualFrequency/state->sampleRate;
        state->actualFrequency = 0.999*state->actualFrequency+0.001*state->frequency;
        
        double rate = 0.0;
        if (state->targetAmplitude > state->amplitude) {
            rate = 0.9;
        } else {
            rate = 0.9999;
        }
        
        state->amplitude = rate*state->amplitude+(1-rate)*state->targetAmplitude;
        
        if (state->phase > 2.0 * M_PI) {
            state->phase -= 2.0 * M_PI;
        }
#endif
    }
    
    return noErr;
}