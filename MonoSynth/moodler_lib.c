#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "moodler_lib.h"
#include "band_limited.h"

sample lagrange_3rd_order_4_point[4][4] = {
    {0, 1, 0, 0},
    {-7.0/128, 105.0/128, 35.0/128, -5.0/128},
    {-1.0/16, 9.0/16, 9.0/16, -1.0/16},
    {-5.0/128, 35.0/128, 105.0/128, -7.0/128}
};

sample downsample_4_filter[15] = {
    -0.063753, -0.0412023, 0., 0.0527295, 0.107869, 0.155884, 0.188473,
    0.2, 0.188473, 0.155884, 0.107869, 0.0527295, 0., -0.0412023,
    -0.063753
};

void upsample_lagrange_3rd_order_4_point(sample input,
                                                sample *x,
                                                sample *y) {
    x[3] = input;
    for (int i = 0; i < 4; ++i) {
        sample t = 0.0;
        for (int j = 0; j < 4; ++j) {
            t += lagrange_3rd_order_4_point[i][j]*x[j];
        }
        y[i] = t;
    }
}

sample downsample_4(sample *y) {
    sample t = 0.0;
    for (int i = 0; i < 15; ++i) {
        t += downsample_4_filter[i]*y[i+1];
    }
    return t;
}
