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
    float *buffer = ioData->mBuffers[0].mData;
    
    for (int i = 0; i < inNumberFrames; ++i) {
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
    }
    
    return noErr;
}