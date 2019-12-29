#include <stdio.h>

#define LOWER_MASK 0x0F
#define UPPER_MASK 0xF0

int main(int argc, char* argv[])
{
        /* Two 4-bit values stored in one
         * 8-bit variable */
        char value = 0xA5;
        char lower = value & LOWER_MASK;
        char upper = (value & UPPER_MASK) >> 4;

        printf("Lower: %x\n", lower);
        printf("Upper: %x\n", upper);
}
