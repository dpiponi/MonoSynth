//
//  envelope.c
//  MonoSynth
//
//  Created by Dan Piponi on 10/31/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

#include "envelope.h"

void init_envelope(struct Envelope *env) {
    env->state = IDLE;
    env->level = 0.0;
    env->time_since_start = 0.0;
    env->last_gate = 0.0;
    env->time_since_key_down = 0.0;
}

void exec_envelope(struct Envelope *env, double dt, double delay, double attack, double hold, double decay, double sustain, double release,
                   double retrigger, double gate) {
    if (gate > 0 && (env->last_gate <= 0 || env->time_since_key_down >= retrigger)) {
        env->time_since_start = 0.0;
        env->state = DELAY;
        env->time_since_start = 0.0;
        env->time_since_key_down = 0.0;
    }
    switch (env->state) {
        case IDLE:
            break;
        case DELAY:
            if (env->time_since_start >= delay) {
                env->state = ATTACK;
                env->time_since_start = 0.0;
            }
            break;
        case ATTACK:
            if (attack > 0) {
                env->level = (1.0-dt/attack)*env->level+(dt/attack)*1.3;
                if (env->level >= 1.0) {
                    env->level = 1.0;
                    env->state = HOLD;
                    env->time_since_start = 0.0;
                }
            } else {
                env->level = 1.0;
                env->state = HOLD;
                env->time_since_start = 0.0;
            }
            break;
        case HOLD:
            if (env->time_since_start >= hold) {
                env->state = DECAY;
                env->time_since_start = 0.0;
            }
            break;
        case DECAY:
            if (decay > 0) {
                env->level *= 1.0-dt/decay;
                if (env->level <= sustain) {
                    env->level = sustain;
                    env->state = SUSTAIN;
                    env->time_since_start = 0.0;
                }
            } else {
                env->level = sustain;
                env->state = SUSTAIN;
                env->time_since_start = 0.0;
            }
            break;
        case SUSTAIN:
            if (gate <= 0) {
                env->state = RELEASE;
                env->time_since_start = 0.0;
            }
            break;
        case RELEASE:
            if (release > 0) {
                env->level *= 1.0-dt/release;
            } else {
                env->level = 0.0;
                env->state = IDLE;
                env->time_since_start = 0.0;
            }
            break;
    }
    
    env->time_since_start += dt;
    env->time_since_key_down += dt;
    env->last_gate = gate;
}
