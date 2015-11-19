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
    static struct WaveForm wave_form;
    
    static double x[3] = { 0.0, 0.25, 0.6 };
    static double y0[3] = { 0.0, 1.0, -0.2};
    static double y1[3] = { 0.0, -1.0, 0.2 };
    wave_form.n_segments = 3;
    wave_form.wave_period = 1.0;
    wave_form.x = x;
    wave_form.y0 = y0;
    wave_form.y1 = y1;
    
    return &wave_form;
}

void init_wave(struct Wave *wave) {
    init_band_limited(&wave->band_limited);
    wave->i = 0;
    wave->t_next_control_point = 0.0;
    wave->index = 0;
    wave->t = 0.0;
    wave->y = 0.0;
    wave->wave_form = make_weird_wave();
    struct WaveForm *wave_form = wave->wave_form;
    wave->gradient = (wave_form->y0[0]-wave_form->y1[wave_form->n_segments-1])/(wave_form->wave_period*(1.0-wave_form->x[0]));
}

void exec_wave(struct Wave *wave, double dt, double frequency) {
    wave->wave_form->wave_period = 44100.0/frequency; // Hard coded XXX
    output_wave(wave, wave->i+1);
}

//void output_wave(struct Wave *wave, int end) {
//    struct WaveForm *wave_form = wave->wave_form;
//    int added_sample = 0; // XXX
//    double sample_added; // XXX
//    
//    while (wave->i < end) {
//        
//        int index = wave->index;
//        
//        if (wave->i < wave->t_next_control_point) {
//            double y_new = wave->y+wave->gradient*(wave->i-wave->t);
//            add_sample(&wave->band_limited, y_new);
//            sample_added = y_new;
//            added_sample = 1;
//            wave->t = wave->i;
//            ++wave->i;
//            wave->y = y_new;
//        } else {
//            double gradient_new;
//            int new_index = (index+1)%wave_form->n_segments;
//            int wrap = new_index <= index;
//            gradient_new = (wave_form->y0[new_index]-wave_form->y1[index])/
//            (wave_form->wave_period*(wave_form->x[new_index]-wave_form->x[index]+wrap));
//            if (wave->i == wave->t_next_control_point) {
//                //                add_sample(&wave->band_limited, 0.5*(wave_form->y0[index]+wave_form->y1[index]));
//                add_sample(&wave->band_limited, wave_form->y1[index]);
//                added_sample = 1;
//                sample_added = wave_form->y1[index];
//                ++wave->i;
//            }
//            //
//            // wave->i is pointing at next sample but the offset we send to
//            // band_limited is relative to previous sample.
//            //
//            if (wave_form->y1[index] != wave_form->y0[index]) {
//                add_discontinuity0(&wave->band_limited, 1+wave->t_next_control_point-wave->i,
//                                   wave_form->y1[index]-wave_form->y0[index]);
//                
//                //                printf("%d %f\n", wave->i, wave_form->y1[index]-wave_form->y0[index]);
//            }
//            if (gradient_new != wave->gradient) {
//                add_discontinuity1(&wave->band_limited, 1+wave->t_next_control_point-wave->i,
//                                   gradient_new-wave->gradient);
//            }
//            wave->t = wave->t_next_control_point;
//            wave->t_next_control_point += wave_form->wave_period*(wave_form->x[new_index]-wave_form->x[index]+wrap);
//            wave->index = new_index;
//            wave->y = wave_form->y1[index];
//            wave->gradient = gradient_new;
//        }
//    }
//    
//    assert(added_sample);
//    wave->result = get_sample(&wave->band_limited);
//}

void output_wave(struct Wave *wave, int end) {
    struct WaveForm *wave_form = wave->wave_form;
    int added_sample = 0; // XXX
    double sample_added; // XXX
    
    // Need to handle on-sample ecent
    double y_new = wave->y+wave->gradient*(wave->i-wave->t);
    add_sample(&wave->band_limited, y_new);
    sample_added = y_new;
    added_sample = 1;
    wave->t = wave->i;
//    ++wave->i;
    wave->y = y_new;

    while (wave->t_next_control_point < wave->i+1) {
    
        int index = wave->index;
        
        double gradient_new;
        int new_index = (index+1)%wave_form->n_segments;
        int wrap = new_index <= index;
        gradient_new = (wave_form->y0[new_index]-wave_form->y1[index])/
        (wave_form->wave_period*(wave_form->x[new_index]-wave_form->x[index]+wrap));
//        if (wave->i == wave->t_next_control_point) {
////                add_sample(&wave->band_limited, 0.5*(wave_form->y0[index]+wave_form->y1[index]));
//            add_sample(&wave->band_limited, wave_form->y1[index]);
//            added_sample = 1;
//            sample_added = wave_form->y1[index];
//            ++wave->i;
//        }
        //
        // wave->i is pointing at next sample but the offset we send to
        // band_limited is relative to previous sample.
        //
        if (wave_form->y1[index] != wave_form->y0[index]) {
            add_discontinuity0(&wave->band_limited, wave->t_next_control_point-wave->i,
                                                    wave_form->y1[index]-wave_form->y0[index]);
            
//                printf("%d %f\n", wave->i, wave_form->y1[index]-wave_form->y0[index]);
        }
        if (gradient_new != wave->gradient) {
            add_discontinuity1(&wave->band_limited, wave->t_next_control_point-wave->i,
                                                    gradient_new-wave->gradient);
        }
        wave->t = wave->t_next_control_point;
        wave->t_next_control_point += wave_form->wave_period*(wave_form->x[new_index]-wave_form->x[index]+wrap);
        wave->index = new_index;
        wave->y = wave_form->y1[index];
        wave->gradient = gradient_new;
    }

//    assert(added_sample);
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
