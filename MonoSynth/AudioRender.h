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

//#include "lfo_sin.h"
//#include "exp_decay.h"
#include "ladder.h"
#include "envelope.h"
#include "vco.h"
#include "lfo.h"

enum Source {
    SOURCE_LFO1 = 0,
    SOURCE_LFO2 = 1,
    SOURCE_ENV1 = 2,
    SOURCE_ENV2 = 3
};

struct UiState {
    //
    // Keyboard
    //
    double frequency;
    double gate;
    double targetAmplitude; // XXX <- into a low pass filter

    
    //
    // ENV1 & ENV 2
    //
    double envDelay[2];
    double envAttack[2];
    double envHold[2];
    double envDecay[2];
    double envSustain[2];
    double envRelease[2];
    double envRetrigger[2];
    
    //
    // LFO1 & LFO2
    //
    double lfo_frequency[2];
    enum LfoType lfoType[2];

    //
    // VCO1 & VCO2
    //
    double vco_level[2];
    double vco_detune[2];
    int vco_number[2];
    double vco_spread[2];
    enum VcoType vco_type[2];
    double vco_detune_modulation[2];
    enum Source vco_detune_modulation_source[2];
    double vco_sync_ratio[2];
    
    //
    // LPF
    //
    double filter_cutoff; // octaves relative to keyboard frequency
    double filter_resonance;
    enum Source filter_cutoff_modulation_source;
    enum Source filter_resonance_modulation_source;
    double filter_cutoff_modulation;
    double filter_resonance_modulation;    
    
    //
    // VCA
    //
    int vcaEnv2;
    
    double vca_level;
    enum Source vca_modulation_source;
    double vca_modulation;
};

struct AudioState {
    // Globals
    double sampleRate;
    
    // VU meter
    double peak;
    
    // Oscilloscope
    bool osc_waiting;
    int osc_pos;
    double *osc_data;
    double osc_previous ;
    
    struct UiState uiState;
    struct LFO lfo[2];
    struct VCO vco[2];
    struct Envelope env[2];
    
    //
    // Filter
    //
    struct Ladder ladder;
    
    double actualFrequency;
    double phase;
    double amplitude;
    
    
};

void init_audio_state(struct AudioState *state);

OSStatus audio_render( void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData );
#endif /* Header_h */
