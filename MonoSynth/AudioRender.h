//
//  Header.h
//  MonoSynth
//
//  Created by Dan Piponi on 10/27/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

#ifndef Header_h
#define Header_h

@import AudioUnit;

#include "audio_square.h"
#include "audio_saw.h"
#include "audio_sin.h"

enum OscType {
    OSC_TYPE_SINE,
    OSC_TYPE_SQUARE,
    OSC_TYPE_TRIANGLE
};

struct AudioState {
    // Globals
    double sampleRate;
    
    enum OscType oscType;
    struct Saw saw_state;
    struct Sin sin_state;
    struct Square square_state;
    
    double actualFrequency;
    double phase;
    double amplitude;
    
    //
    // Controls
    //
    double frequency;
    double targetAmplitude;
};

void init_audio_state(struct AudioState *state) {
    state->oscType = OSC_TYPE_SINE;
    state->sampleRate = 44100.0;
    state->phase = 0.0;
    state->actualFrequency = 0.0;
    state->amplitude = 0.0;
    state->frequency = 440.0f;
    state->targetAmplitude = 0.0;
}

OSStatus audio_render( void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData );
#endif /* Header_h */
