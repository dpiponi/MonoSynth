#if !defined(LADDER_H)
#define LADDER_H

struct Ladder {
    double result;
    
    double y0;
    double y1;
    double y2;
    double y3;
};

void init_ladder(struct Ladder *ladder);
void step_ladder(struct Ladder *ladder, double dt, double frequency, double resonance, double signal);

#endif