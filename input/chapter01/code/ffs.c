#include <stdio.h>

int main(void)
{
	//  in binary = 1000 0000 0000 0000
	//  bit num     5432 1098 7654 3210
	int i = 0x8000;
	int count = 0;
	while ( !(i & 0x1) ) {
		count ++;
		i = i >> 1;
	}
	printf("First non-zero (slow) is %d\n", count);

	// this value is normalised when it is loaded
	long double d = 0x8000UL;
	long exp;

	// Itanium "get floating point exponent" instruction
	asm ("getf.exp %0=%1" : "=r"(exp) : "f"(d));

	// note exponent include bias
	printf("The first non-zero (fast) is %d\n", exp - 65535);

}
