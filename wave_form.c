//
//  wave_form.c
//  MonoSynth
//
//  Created by Dan Piponi on 11/17/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

#include "wave_form.h"

#include <stdio.h>
#include <assert.h>
#include <stdlib.h>

struct WaveForm *make_square_wave() {
    static struct WaveForm wave_form;
    
    static double x[2] = { 0.0, 0.5 };
    static double y0[2] = { -1.0, 1.0 };
    static double y1[2] = { 1.0, -1.0 };
    wave_form.n_segments = 2;
    wave_form.wave_period = 1.0;
    wave_form.x = x;
    wave_form.y0 = y0;
    wave_form.y1 = y1;
    
    return &wave_form;
}

struct WaveForm *make_triangle_wave() {
    static struct WaveForm wave_form;
    
    static double x[1] = { 0.0 };
    static double y0[1] = { 1.0 };
    static double y1[1] = { 0.0 };
    wave_form.n_segments = 1;
    wave_form.wave_period = 1.0;
    wave_form.x = x;
    wave_form.y0 = y0;
    wave_form.y1 = y1;
    
    return &wave_form;
}

struct WaveForm *make_hybrid_wave() {
    static struct WaveForm wave_form;
    
    static double x[2] = { 0.0, 0.5 };
    static double y0[2] = { -1.0, -1.0};
    static double y1[2] = { 1.0, -1.0 };
    wave_form.n_segments = 2;
    wave_form.wave_period = 1.0;
    wave_form.x = x;
    wave_form.y0 = y0;
    wave_form.y1 = y1;
    
    return &wave_form;
}

struct WaveForm *make_weird_wave() {
    struct WaveForm *wave_form = new_wave_form(3);
    
    static double x[3] = { 0.0, 0.25, 0.6 };
    static double y0[3] = { 0.0, 1.0, -0.2};
    static double y1[3] = { 0.0, -1.0, 0.2 };
    for (int i = 0; i < 3; ++i) {
        wave_form->x[i] = x[i];
        wave_form->y0[i] = y0[i];
        wave_form->y1[i] = y1[i];
    }
    wave_form->n_segments = 3;
    wave_form->wave_period = 1.0;
    wave_form->x = x;
    wave_form->y0 = y0;
    wave_form->y1 = y1;
    
    return wave_form;
}

struct WaveForm *new_wave_form(int n) {
    struct WaveForm *wave_form = malloc(sizeof(struct WaveForm));
    
    wave_form->n_segments = n;
    wave_form->x = malloc(n*sizeof(double));
    wave_form->y0 = malloc(n*sizeof(double));
    wave_form->y1 = malloc(n*sizeof(double));
    return wave_form;
}

void delete_wave_form(struct WaveForm *wave_form) {
    return;
    free(wave_form->x);
    free(wave_form->y0);
    free(wave_form->y1);
    free(wave_form);
}

void init_wave(struct Wave *wave) {
    init_band_limited(&wave->band_limited);
    wave->i = 0;
    wave->t_next_control_point = 0.0;
    wave->index = 0;
    wave->t = 0.0;
    wave->y = 0.0;
    wave->wave_form = 0;
    wave->phase = 0.0;
}

void reinit_wave(struct Wave *wave) {
//    init_band_limited(&wave->band_limited);
//    wave->i = 0;
//    wave->t_next_control_point = 0.0;
//    wave->index = 0;
//    wave->t = 0.0;
//    wave->y = 0.0;
//    wave->phase = 0.0;
//    struct WaveForm *wave_form = wave->wave_form;
//    if (wave_form) {
//        wave->gradient = (wave_form->y0[0]-wave_form->y1[wave_form->n_segments-1])/(wave_form->wave_period*(1.0-wave_form->x[0]));
//    }
}

void exec_wave(struct Wave *wave, double dt, double frequency) {
    struct WaveForm *w = wave->new_wave;
    if (w != wave->wave_form) {
        struct WaveForm *old_wave = wave->wave_form;
        wave->wave_form = w;
        wave->wave_form->wave_period = 44100.0/frequency; // Hard coded XXX
        reinit_wave(wave);
        if (old_wave) {
            delete_wave_form(old_wave);
        }
    }
    if (wave->wave_form) {
        wave->wave_form->wave_period = 44100.0/frequency; // Hard coded XXX
        output_wave(wave, wave->i+1);
    }
}

// wave->phase = wave->t/period
void output_wave(struct Wave *wave, int end) {
    struct WaveForm *wave_form = wave->wave_form;
    
    // Need to handle on-sample event XXX
    double y_new = wave->y+wave->gradient*(wave->i-wave->t);
    add_sample(&wave->band_limited, y_new);
    wave->phase += (wave->i-wave->t)/wave_form->wave_period;
    wave->t = wave->i;
    wave->y = y_new;
    assert(wave->i <= wave->t_next_control_point);
    double time_before_next_sample = 1+wave->i-wave->t_next_control_point;
    while (time_before_next_sample > 0) {
    
        int index = wave->index%wave_form->n_segments;
        
        double gradient_new;
        int new_index = (index+1)%wave_form->n_segments;
        int wrap = new_index <= index;
        gradient_new = (wave_form->y0[new_index]-wave_form->y1[index])/
        (wave_form->wave_period*(wave_form->x[new_index]-wave_form->x[index]+wrap));
        if (wave_form->y1[index] != wave_form->y0[index]) {
            add_discontinuity0(&wave->band_limited, wave->t_next_control_point-wave->i,
                                                    wave_form->y1[index]-wave_form->y0[index]);
            
        }
        if (gradient_new != wave->gradient) {
            add_discontinuity1(&wave->band_limited, wave->t_next_control_point-wave->i,
                                                    gradient_new-wave->gradient);
        }
        wave->t = wave->t_next_control_point;
        double t_step = wave_form->wave_period*(wave_form->x[new_index]-wave_form->x[index]+wrap);
        wave->t_next_control_point += t_step;
        time_before_next_sample -= t_step;
        wave->index = new_index;
        wave->y = wave_form->y1[index];
        wave->gradient = gradient_new;
    }

    wave->result = get_sample(&wave->band_limited);
    ++wave->i;
}

void test_square_wave1() {
    struct WaveForm wave_form;
    struct Wave wave;
    
    double x[2] = { 0.0, 0.5 };
    double y0[2] = { 0.0, 1.0 };
    double y1[2] = { 1.0, 0.0 };
    wave_form.n_segments = 2;
    wave_form.wave_period = 1.0;
    wave_form.x = x;
    wave_form.y0 = y0;
    wave_form.y1 = y1;
    init_wave(&wave);
    
    for (int i = 0; i < 10; ++i) {
        output_wave(&wave, wave.i+1);
    }
}

void test_square_wave2() {
    struct WaveForm wave_form;
    struct Wave wave;
    
    double x[2] = { 0.0, 0.5 };
    double y0[2] = { 0.0, 1.0 };
    double y1[2] = { 1.0, 0.0 };
    wave_form.n_segments = 2;
    wave_form.wave_period = 4.0;
    wave_form.x = x;
    wave_form.y0 = y0;
    wave_form.y1 = y1;
    init_wave(&wave);
    
    for (int i = 0; i < 10; ++i) {
        output_wave(&wave, wave.i+1);
    }
}

void test_ramp_wave1() {
    struct WaveForm wave_form;
    struct Wave wave;
    
    double x[1] = { 0.0 };
    double y0[1] = { 1.0 };
    double y1[1] = { 0.0 };
    wave_form.n_segments = 1;
    wave_form.wave_period = 4.0;
    wave_form.x = x;
    wave_form.y0 = y0;
    wave_form.y1 = y1;
    init_wave(&wave);
    
    for (int i = 0; i < 10; ++i) {
        output_wave(&wave, wave.i+1);
    }
}

void test_saw_wave1() {
    struct WaveForm wave_form;
    struct Wave wave;
    
    double x[1] = { 0.0 };
    double y0[1] = { 0.0 };
    double y1[1] = { 1.0 };
    wave_form.n_segments = 1;
    wave_form.wave_period = 4.012345;
    wave_form.x = x;
    wave_form.y0 = y0;
    wave_form.y1 = y1;
    init_wave(&wave);
    
    for (int i = 0; i < 10; ++i) {
        output_wave(&wave, wave.i+1);
    }
}

//int main(int argc, char **argv) {
//    switch (atoi(argv[1])) {
//        case 0:
//            test_square_wave1();
//            break;
//        case 1:
//            test_square_wave2();
//            break;
//        case 2:
//            test_ramp_wave1();
//            break;
//        case 3:
//            test_saw_wave1();
//            break;
//    }
//    
//    return 0;
//}
