#ifndef BIQUAD_H
#define BIQUAD_H

#define sample double

struct Biquad {
    sample a[3];
    sample b[3];
    sample x[3];
    sample y[3];
    sample result;
};

void exec_biquad(struct Biquad *biquad, sample in);
void init_biquad(struct Biquad *biquad,
                 sample complex zero,
                 sample complex pole);
void init_biquad_with_zero(struct Biquad *biquad,
                           sample complex zero);
void init_biquad_with_pole(struct Biquad *biquad,
                           sample complex pole);

struct Filter {
    int n_biquads;
    struct Biquad *biquads;
    sample result;
};

void init_filter(struct Filter *filter,
                 int n_zeros, int n_poles,
                 sample complex *zeros, sample complex *poles);;
void delete_filter(struct Filter *filter);
void exec_filter(struct Filter *filter, sample input);

#endif
