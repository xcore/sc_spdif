#include <xs1.h>
#include "SpdifReceive.h"

buffered in port:4 oneBitPort = XS1_PORT_1F;
clock clockblock = XS1_CLKBLK_1;

void generate(streaming chanend c) {
    while(1) {
        int v;
        int left, right;
        c :> v;
        switch(v & 0xF) {
        case FRAME_X:
        case FRAME_Z:
            left = v >> 4;
            break;
        case FRAME_Y:
            right = v >> 4;
            break;
        }
    }
}

int main(void) {
    streaming chan c;
    par {
        SpdifReceive(oneBitPort, c, 1, clockblock);
        generate(c);
    }
}
