#include <complex.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#include "biquad.h"

sample saturate(sample x) {
//    if (x < -0.25) {
//        return -0.25;
//    }
//    if (x > 0.25) {
//        return 0.25;
//    }
    return 0.25*tanh(4.0*x);
}
//
// y = (a[0]+a[1]Z+a[2]Z^2)/(b[0]+b[1]Z+b[2]Z^2) x
//
void exec_biquad(struct Biquad *biquad, sample in) {
    biquad->x[0] = in;
    biquad->y[0] = (biquad->a[0]*biquad->x[0]+
                    biquad->a[1]*biquad->x[1]+
                    biquad->a[2]*biquad->x[2]-
                    biquad->b[1]*biquad->y[1]-
                    biquad->b[2]*biquad->y[2])/biquad->b[0];
    biquad->result = biquad->y[0];
    biquad->x[2] = biquad->x[1];
    biquad->x[1] = biquad->x[0];
    biquad->y[2] = biquad->y[1];
    biquad->y[1] = biquad->y[0];
}

//
// a[0]+a[1]Z+a[2]Z^2 = (w-Z)(w*-Z)
//                    = |w|^2-2Re(w)+Z^2
//
void init_biquad(struct Biquad *biquad,
                 sample complex zero,
                 sample complex pole) {
    biquad->a[0] = 1.0;
    biquad->a[1] = -2*creal(zero);
    biquad->a[2] = creal(zero*conj(zero));
    biquad->b[0] = 1.0;
    biquad->b[1] = -2*creal(pole);
    biquad->b[2] = creal(pole*conj(pole));
    biquad->x[0] = 0.0;
    biquad->x[1] = 0.0;
    biquad->x[2] = 0.0;
    biquad->y[0] = 0.0;
    biquad->y[1] = 0.0;
    biquad->y[2] = 0.0;
}

void init_biquad_with_zero(struct Biquad *biquad,
                           sample complex zero) {
    biquad->a[0] = 1.0;
    biquad->a[1] = -2*creal(zero);
    biquad->a[2] = creal(zero*conj(zero));
    biquad->b[0] = 1.0;
    biquad->b[1] = 0.0;
    biquad->b[2] = 0.0;
    biquad->x[0] = 0.0;
    biquad->x[1] = 0.0;
    biquad->x[2] = 0.0;
    biquad->y[0] = 0.0;
    biquad->y[1] = 0.0;
    biquad->y[2] = 0.0;
}

void init_biquad_with_pole(struct Biquad *biquad,
                           sample complex pole) {
    biquad->a[0] = 1.0;
    biquad->a[1] = 0.0;
    biquad->a[2] = 0.0;
    biquad->b[0] = 1.0;
    biquad->b[1] = -2*creal(pole);
    biquad->b[2] = creal(pole*conj(pole));
    biquad->x[0] = 0.0;
    biquad->x[1] = 0.0;
    biquad->x[2] = 0.0;
    biquad->y[0] = 0.0;
    biquad->y[1] = 0.0;
    biquad->y[2] = 0.0;
}

sample complex control_to_complex(sample f, sample y) {
    sample rate = 44100.0;
    complex sample z = exp(3*y)*cexp(2*M_PI*I*f/rate);
    return z;
}

//struct BiquadFilter {
//    int n_biquads;
//    struct Biquad *biquads;
//    sample result;
//};

struct BiquadFilter *new_filter(int n_zeros, int n_poles) {
    struct BiquadFilter *filter = malloc(sizeof(struct BiquadFilter));
    int n_biquads = n_poles > n_zeros ? n_poles : n_zeros;
    filter->n_biquads = n_biquads;
    filter->n_zeros = n_zeros;
    filter->n_poles = n_poles;
    struct Biquad *biquads = malloc(n_biquads*sizeof(struct Biquad));
    filter->biquads = biquads;
    filter->zeros = malloc(n_zeros*sizeof(sample complex));
    filter->poles = malloc(n_poles*sizeof(sample complex));
    return filter;
}

void init_filter(struct BiquadFilter *filter) {
    int n_biquads = filter->n_biquads;
    int n_zeros = filter->n_zeros;
    int n_poles = filter->n_poles;
    for (int i = 0; i < n_biquads; ++i) {
        if (i < n_zeros && i < n_poles) {
            init_biquad(&filter->biquads[i], filter->zeros[i], filter->poles[i]);
//            printf("%f + %fi / %f + %fi\n",
//                   creal(filter->zeros[i]), cimag(filter->zeros[i]),
//                   creal(filter->poles[i]), cimag(filter->poles[i]));
        } else if (i < n_zeros) {
            init_biquad_with_zero(&filter->biquads[i], filter->zeros[i]);
//            printf("%f + %fi / 1\n",
//                   creal(filter->zeros[i]), cimag(filter->zeros[i]));
        } else if (i < n_poles) {
            init_biquad_with_pole(&filter->biquads[i], filter->poles[i]);
//            printf("1 / %f + %fi\n",
//                   creal(filter->poles[i]), cimag(filter->poles[i]));
        }
    }
}

void delete_filter(struct BiquadFilter *filter) {
    free(filter->biquads);
    free(filter->zeros);
    free(filter->poles);
    free(filter);
}

void exec_filter(struct BiquadFilter *filter, sample input) {
    struct Biquad *biquads = filter->biquads;
    exec_biquad(&biquads[0], input);
    sample result = biquads[0].result;
    for (int j = 1; j < filter->n_biquads; ++j) {
        exec_biquad(&biquads[j], result);
        result = biquads[j].result;
    }
    filter->result = filter->scale*result;
}

#if 0
const int N = 20000;
sample input[N];
sample /*output1[N],*/ output2[N];

int main() {
    sample f = 4400.0;
    sample rate = 44100.0;
    for (int i = 0; i < N; ++i) {
        input[i] = cos(2*M_PI*i*f/rate);
    }
    const int n_zeros = 2;
    const int n_poles = 1;
    sample complex zeros[n_zeros] = {
        CMPLX(0.2, 0.002), CMPLX(0.3, 0.001)
    };
    sample complex poles[n_poles] = {
        CMPLX(0.5, 0.001)
    };
    struct Filter filter;
    init_filter(&filter, n_zeros, n_poles, zeros, poles);
    /*int n_biquads = n_poles > n_zeros ? n_poles : n_zeros;*/
    /*struct Biquad *biquads = malloc(n_biquads*sizeof(struct Biquad));*/
    /*for (int i = 0; i < n_biquads; ++i) {*/
        /*if (i < n_zeros && i < n_poles) {*/
            /*init_biquad(&biquads[i], zeros[i], poles[i]);*/
        /*} else if (i < n_zeros) {*/
            /*init_biquad_with_zero(&biquads[i], zeros[i]);*/
        /*} else if (i < n_poles) {*/
            /*init_biquad_with_pole(&biquads[i], poles[i]);*/
        /*}*/
    /*}*/

    for (int i = 2; i < N; ++i) {
        /*exec_biquad(&biquads[0], input[i]);*/
        /*sample result = biquads[0].result;*/
        /*for (int j = 1; j < n_biquads; ++j) {*/
            /*exec_biquad(&biquads[j], result);*/
            /*result = biquads[j].result;*/
        /*}*/
        /*output2[i] = result;*/
        exec_filter(&filter, input[i]);
        output2[i] = filter.result;
    }

    sample complex z = cexp(2*M_PI*I*f/rate);
    sample complex num = CMPLX(1.0, 0.0);
    sample complex den = CMPLX(1.0, 0.0);
    int n_biquads = n_poles > n_zeros ? n_poles : n_zeros;
    for (int i = 0; i < n_biquads; ++i) {
        if (i < n_zeros) {
            num *= (z-zeros[i])*(z-conj(zeros[i]));
        }
        if (i < n_poles) {
            den *= (z-poles[i])*(z-conj(poles[i]));
        }
    }
    sample t = cabs(num/den);

    sample lo = 1E8, hi = -1e8;
    for (int i = N/2; i < N; ++i) {
        if (output2[i] < lo) {
            lo = output2[i];
        }
        if (output2[i] > hi) {
            hi = output2[i];
        }
    }
    printf("lo=%f hi=%f, t=%f\n", lo, hi, t);
}
#endif
