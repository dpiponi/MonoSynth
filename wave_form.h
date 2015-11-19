//
//  wave_form.h
//  MonoSynth
//
//  Created by Dan Piponi on 11/17/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

#ifndef wave_form_h
#define wave_form_h

#include "band_limited.h"

struct WaveForm {
    int n_segments;
    double wave_period;
    double *x, *y0, *y1;
};

struct Wave {
    struct BandLimited band_limited;
    struct WaveForm *wave_form;
    int i;
    int index;
    double t_next_control_point;
    double t;
    double y;
    double gradient;
    
    double result;
};

void init_wave(struct Wave *wave);
void output_wave(struct Wave *wave, int end);
void exec_wave(struct Wave *wave, double dt, double frequency);


#endif /* wave_form_h */
