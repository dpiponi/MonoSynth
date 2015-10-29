#include <math.h>

#include "moodler_lib.h"
#include "ladder.h"

//@import "Darwin.C.tgmath"

void fast(double x[5][5], double k, double a, double t) {
    double v00 = t * a;
    double v01 = sinh(v00);
    double v02 = cosh(v00);
    double v03 = sqrt(sqrt(k)); // pow(k, 0.25)
    double v04 = 1/sqrt(2);
    double v05 = 1/sqrt(k);
    double v06 = v03/k; // pow(k, -0.75)
    double v07 = sqrt(k);
    double v08 = sqrt(2);
    double v09 = 1.0/v06; // pow(k, 0.75)
    double v10 = 1/(1 + k);
    double v11 = exp(-v00);
    double v12 = 1 + v07;
    double v13 = -1 + v07;
    double v14 = v00 * v03 * v04;
    double v15 = cosh(v14);
    double v16 = cos(v14);
    double v17 = sinh(v14);
    double v18 = sin(v14);
    double v19 = v16 * v17;
    double v20 = v15 * v18;
    double v21 = v11 * v15 * v16;
    double v22 = v08 * v09 * v19;
    double v23 = v05 * v11 * v17 * v18;
    double v24 = -(v07 * v11 * v17 * v18);
    double v25 = v19 + v20;
    double v26 = (v04 * v11 * v25)/pow(k,0.25);
    double v27 = v03 * v04 * v11 * (v19 - v20);
    double z[5][5] = {
        {1,0,0,0,0},
        {(v10*v11*(2*v01+2*v02+2*v07*v17*v18+v15*(-2*v16+v03*v08*v12*v18)-v03*v08*v19+v22))/2.,
         v21,
         v27,
         v24,
         -(v04*v09*v11*v25)},
        {(v10*v11*(2*k*v01+2*k*v02+2*pow(k,1.5)*v17*v18+v15*(-2*k*v16+v08*v09*v13*v18)-pow(k,1.25)*v08*v19-v22))/(2.*k),
         v26,
         v21,
         v27,
         v24},
        {-(v05*v10*v11*(-2*v01*v07-2*v02*v07+2*v17*v18+v15*(2*v07*v16-v03*v08*v13*v18)+v03*v08*v19+v22))/2.,
         v23,
         v26,
         v21,
         v27},
        {(v06*v10*v11*(2*v01*v09+2*v02*v09-2*v03*v17*v18-v15*(2*v09*v16+v08*v12*v18)+v08*v19-v07*v08*v19))/2.,
         v04*v06*v11*(-v19+v20),
         v23,
         v26,
         v21}
    };
    for (int i = 0; i < 5; ++i) {
        for (int j = 0; j < 5; ++j) {
            x[i][j] = z[i][j];
        }
    }
}
void init_ladder(struct Ladder *ladder) {
    ladder->result = 0.0;
    
    ladder->y0 = 0.0;
    ladder->y1 = 0.0;
    ladder->y2 = 0.0;
    ladder->y3 = 0.0;
}

void step_ladder(struct Ladder *ladder, double dt, double frequency, double resonance, double signal) {
//    double freq2 = clamp(-1.0, 0.7, freq);
    double res2 = clamp_double(1e-7, 3.999, resonance);
//    double f = signal_to_frequency(freq2);
    double f = frequency;
    double x[5][5];
    fast(x, res2, 2.0*M_PI*f, dt);
    double ny0, ny1, ny2, ny3;
    ny0 = x[1][0]*signal+x[1][1]*ladder->y0+x[1][2]*ladder->y1+x[1][3]*ladder->y2+x[1][4]*ladder->y3;
    ny1 = x[2][0]*signal+x[2][1]*ladder->y0+x[2][2]*ladder->y1+x[2][3]*ladder->y2+x[2][4]*ladder->y3;
    ny2 = x[3][0]*signal+x[3][1]*ladder->y0+x[3][2]*ladder->y1+x[3][3]*ladder->y2+x[3][4]*ladder->y3;
    ny3 = x[4][0]*signal+x[4][1]*ladder->y0+x[4][2]*ladder->y1+x[4][3]*ladder->y2+x[4][4]*ladder->y3;
//    printf("ny3=%f\n", ny3);
    ladder->y0 = ny0;
    ladder->y1 = ny1;
    ladder->y2 = ny2;
    ladder->y3 = ny3;
    ladder->result = ny3;
}
