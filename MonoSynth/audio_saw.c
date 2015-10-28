#include "audio_saw.h"

void init_saw(struct Saw *state) {
    init_band_limited(&state->limited);
    state->started = 1.0;
    state->last_sync = 0.0;
}

double step_saw(struct Saw *state, double dt, double frequency,
                double sync) {
    double period = 1.0/frequency;
    state->gradient = 2.0/period/44100.0; // hard coded :-(
    double sync_time = 0.0;
    int sync_pending = 0;
    const double period_in_samples = period/dt;

    if (state->last_sync < 0 && sync >= 0) {
        sync_time = state->last_sync/(state->last_sync-sync);
        sync_pending = 1;
        if (sync_time == 0) {
            add_sample(&state->limited, -1);
        }
    } else {
        add_sample(&state->limited,
                   -1+(state->this_sample-state->last_fall_time)*state->gradient);
    }
    while (1) {
        if (sync_pending &&
            state->this_sample+sync_time <= state->next_fall_time) {
            
            sync_pending = 0;
            double value_at_sync =
                -1+(state->this_sample+sync_time-state->last_fall_time)*state->gradient;
            add_discontinuity0(&state->limited, sync_time,
                               -(value_at_sync+1));
            state->last_fall_time = state->this_sample+sync_time;
            state->next_fall_time = state->last_fall_time+period_in_samples;
        }
        if (state->next_fall_time >= state->this_sample+1) {
            break;
        }
        add_discontinuity0(&state->limited,
                           state->next_fall_time-state->this_sample, -2);
        state->last_fall_time = state->next_fall_time;
        state->next_fall_time += period_in_samples;
    }

    double result = get_sample(&state->limited);

    ++state->this_sample;

    state->last_sync = sync;
    
    return result;
}
