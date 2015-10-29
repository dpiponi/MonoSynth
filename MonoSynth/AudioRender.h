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
#include "exp_decay.h"
#include "ladder.h"

enum OscType {
    OSC_TYPE_SINE = 0,
    OSC_TYPE_SQUARE = 1,
    OSC_TYPE_SAW = 2
};

struct AudioState {
    // Globals
    double sampleRate;
    
    double gate;
    
    enum OscType oscType;
    struct Saw saw_state;
    struct Sin sin_state;
    struct Square square_state;
    struct ExpDecay exp_decay;
    struct Ladder ladder;
    
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
    state->gate = 0.0;
    
    state->oscType = OSC_TYPE_SINE;
    state->sampleRate = 44100.0;
    state->phase = 0.0;
    state->actualFrequency = 440.0;
    state->amplitude = 0.0;
    state->frequency = 440.0f;
    state->targetAmplitude = 0.0;
    
    init_exp_decay(&state->exp_decay);
    init_saw(&state->saw_state);
    init_square(&state->square_state);
    init_sin(&state->sin_state);
    state-> oscType = OSC_TYPE_SINE;

    init_ladder(&state->ladder);
}

OSStatus audio_render( void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData );
#endif /* Header_h */
