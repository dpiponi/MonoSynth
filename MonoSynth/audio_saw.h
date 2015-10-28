#ifndef audio_saw_h
#define audio_saw_h

#include "band_limited.h"

struct Saw {
    double started;
    struct BandLimited limited;
    double this_sample;
    double next_fall_time;
    double last_fall_time;
    double result;
    double gradient;
    double last_sync;
};

void init_saw(struct Saw *state);
double step_saw(struct Saw *state, double dt, double frequency,
                    double sync);

#endif /* audio_saw_h */
