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

#include "lfo_sin.h"
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

    //
    // LFO1
    //
    enum OscType lfo_type[2];
    double lfo_frequency[2];
    struct LFOSin lfo_sin[2];
    
    enum OscType oscType;
    struct Saw saw_state;
    struct Sin sin_state;
    struct Square square_state;
    struct ExpDecay exp_decay;
    
    //
    // Filter
    //
    double lfo_filter_cutoff_modulation[2];
    struct Ladder ladder;
    
    double actualFrequency;
    double phase;
    double amplitude;
    
    //
    // Controls
    //
    double frequency;
    double gate;
    double targetAmplitude;
    
    double filter_cutoff; // octaves relative to keyboard frequency
    double filter_resonance;
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
    
    state->filter_cutoff = 1.0;
    state->filter_resonance = 2.0;
    state->lfo_filter_cutoff_modulation[0] = 0.0;
    state->lfo_filter_cutoff_modulation[1] = 0.0;
}

OSStatus audio_render( void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData );
#endif /* Header_h */
