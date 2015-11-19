#if !defined(BAND_LIMITED_H)
#define BAND_LIMITED_H

#include <assert.h>

extern double ctable0[258];
extern double ctable1[258];
extern double cwtable0[16][258];
extern double cwtable1[16][258];

struct BandLimited {
    double data[64];
    int ptr;
    double min, max; // XXX <- delete
    int count; // XXX
};

static inline void init_band_limited(struct BandLimited *limited) {
    for (int i = 0; i < 64; ++i) {
        limited->data[i] = 0;
    }
    limited->ptr = 0;
    limited->min = 100;
    limited->max = -100;
    limited->count = 0;
}

static inline void add_sample(struct BandLimited *limited, double x) {
    double previous = limited->data[limited->ptr]; // XXX
//    assert(fabs(previous-(-0.58507641323213522))>0.00000001);
//    assert(previous > -0.5 && previous < 0.5);
    double new = previous+x;
//    assert(new > -1.5 && new < 1.5);
//    assert(fabs(new-0.6912035449)>0.00000001);
    limited->data[limited->ptr] = new;
    if (limited->count > 40000) {
//        assert(limited->data[limited->ptr] < 1.6); // XXX
    }
}

static inline double get_sample(struct BandLimited *limited) {
    int ioffset = (limited->ptr-32) & 63;
    double x = limited->data[ioffset];
    if (limited->count > 40000) {
//        assert(x < 1.6);
    }
    limited->data[ioffset] = 0.0;
    limited->ptr = (limited->ptr+1) & 63;
    ++limited->count;
    if (limited->count > 40000) {
        if (x < limited->min) {
            limited->min = x;
            printf("min=%f\n", limited->min);
        }
        if (x > limited->max) {
            limited->max = x;
            printf("max=%f\n", limited->max);
//            assert(limited->max < 1.6);
        }
    }
    return x;
}

extern void add_discontinuity0(struct BandLimited *limited,
                        double offset, double x);
extern void add_discontinuity1(struct BandLimited *limited, double offset, double x);
extern void add_discontinuity0w(struct BandLimited *limited, double offset,
                         double omega, double x);
extern void add_discontinuity1w(struct BandLimited *limited, double offset,
                         double omega, double x);


#endif
