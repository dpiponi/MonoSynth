//
//  envelope.h
//  MonoSynth
//
//  Created by Dan Piponi on 10/31/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

#ifndef envelope_h
#define envelope_h

//#include <stdio.h>

enum EnvelopeState {
    IDLE = 0,
    DELAY = 1,
    ATTACK = 2,
    HOLD = 3,
    DECAY = 4,
    SUSTAIN = 5,
    RELEASE = 6
};

struct Envelope {
    enum EnvelopeState state;
    
    double level;
    double time_since_start;
    double time_since_key_down;
    double last_gate;
};

void init_envelope(struct Envelope *env);

void exec_envelope(struct Envelope *env, double dt, double delay, double attack, double hold, double decay, double sustain, double release,
                   double retrigger, double gate);

#endif /* envelope_h */
