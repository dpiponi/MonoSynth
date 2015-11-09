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
    SOURCE_LFO1,
    SOURCE_LFO2,
    SOURCE_ENV1,
    SOURCE_ENV2
};

struct AudioState {
    // Globals
    double sampleRate;
    
    //
    // UI: VCA
    //
    int vcaEnv2;
    
    double vca_level;
    enum Source vca_modulation_source;
    double vca_modulation;
    
    //
    // UI: LFO
    //
    enum LfoType lfoType[2];
    double lfo_frequency[2];

    //
    // LFO
    //
    struct LFO lfo[2];
    
    //
    // VCO1
    //
    enum VcoType vcoType;
    int vco1_number;
    double vco1_detune;
    double vco1_spread;
    double vco1_lfo1_modulation;
    double vco1SyncRatio;

    struct VCO vco1;
    
    double peak;
    
    //
    // Envelopes
    //
    double envDelay[2];
    double envAttack[2];
    double envHold[2];
    double envDecay[2];
    double envSustain[2];
    double envRelease[2];
    double envRetrigger[2];
    struct Envelope env[2];
    
    //
    // Filter
    //
    double filter_cutoff_lfo_modulation[2];
    double filter_cutoff_env_modulation[2];
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
    
    bool osc_waiting;
    int osc_pos;
    double *osc_data;
    double osc_previous ;
};

void init_audio_state(struct AudioState *state);

OSStatus audio_render( void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData );
#endif /* Header_h */
