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
#include "envelope.h"

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
    
    //
    // VCO1
    //
    enum OscType oscType;
    int vco1_number;
    double vco1_detune;
    double vco1_spread;
    double vco1_lfo1_modulation;
    
    struct Saw saw_state[8];
    struct Sin sin_state[8];
    struct Square square_state[8];
    
    //
    // ENV1
    //
    double envDelay[2];
    double envAttack[2];
    double envHold[2];
    double envDecay[2];
    double envSustain[2];
    double envRelease[2];
    double envRetrigger[2];
    struct Envelope env1;
    
    //
    // Filter
    //
    double lfo_filter_cutoff_modulation[2];
    double filter_cutoff_env_modulation;
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
    
    // VCO1
    state->vco1_number = 1;
    state->vco1_detune = 0.0;
    state->vco1_spread = 0.0;
    state->vco1_lfo1_modulation = 0.0;
    state->oscType = OSC_TYPE_SINE;
    for (int i = 0; i < 8; ++i) {
        init_saw(&state->saw_state[i]);
        init_square(&state->square_state[i]);
        init_sin(&state->sin_state[i]);
    }
    
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
    }
    init_envelope(&state->env1);

    init_ladder(&state->ladder);
    
    //
    // Filter
    //
    state->filter_cutoff = 1.0;
    state->filter_resonance = 2.0;
    state->lfo_filter_cutoff_modulation[0] = 0.0;
    state->lfo_filter_cutoff_modulation[1] = 0.0;
    state->filter_cutoff_env_modulation = 0.0;
    
    //
    // ENV1
    //
    
}

OSStatus audio_render( void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData );
#endif /* Header_h */
