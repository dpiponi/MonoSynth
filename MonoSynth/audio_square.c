#include "audio_square.h"

void init_square(struct Square *state) {
    init_band_limited(&state->limited);
    state->this_sample = 0.0;
    state->output_time = 0.0;
    state->last_output_time = 0.0;
    state->y = -1;
    state->last_sync = 0.0;
}

double step_square(struct Square *state, double dt, double frequency,
                   double pwm, double sync) {
    double period = 1.0/frequency;
    double sync_time = 0.0;
    int sync_pending = 0;
    const double period_in_samples = period/dt;
    
    add_sample(&state->limited, state->y);
    
    if (state->last_sync < 0 && sync >= 0) {
        sync_time = state->last_sync/(state->last_sync-sync);
        sync_pending = 1;
    }
    while (1) {
        if (sync_pending &&
            state->this_sample+sync_time <= state->output_time) {
            
            sync_pending = 0;
            add_discontinuity0(&state->limited, sync_time, 1.0-state->y);
            state->y = 1;
            state->output_time = state->this_sample+sync_time+(1-pwm)*period_in_samples;
        }
        if (state->output_time > state->this_sample+1) {
            break;
        }
        if (state->y > 0) {
            add_discontinuity0(&state->limited,
                               state->output_time-state->this_sample, -2);
        } else {
            add_discontinuity0(&state->limited,
                               state->output_time-state->this_sample, 2);
        }
        if (state->y > 0) {
            state->output_time += pwm*period_in_samples;
        } else {
            state->output_time += (1-pwm)*period_in_samples;
        }
        state->y = -state->y;
    }
    
    double result = get_sample(&state->limited);
    ++state->this_sample;
    state->last_sync = sync;
    
    return result;
}

double step_square_nosync(struct Square *state, double dt,
                          double frequency,
                          double pwm) {
    double period = 1.0/frequency;
    const double period_in_samples = period/dt;
//    printf("f=%f period=%f", frequency, period);
    
    add_sample(&state->limited, state->y);
    
    //
    // Walk through all events from now to now+1
    //
    while (1) {
//        printf("time=%f\n", state->output_time);
        if (state->output_time > state->this_sample+1) {
            break;
        }
        if (state->y > 0) {
            add_discontinuity0(&state->limited,
                               state->output_time-state->this_sample, -2);
            state->output_time += pwm*period_in_samples;
        } else {
            add_discontinuity0(&state->limited,
                               state->output_time-state->this_sample, 2);
            state->output_time += (1-pwm)*period_in_samples;
        }
        state->y = -state->y;
    }
    
    double result = get_sample(&state->limited);
    ++state->this_sample;
//    printf("time at end=%f\n", state->output_time);
    
    return result;
}


