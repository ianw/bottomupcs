#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* return 2^n */
int two_to_pos(int n)
{
	if (n == 0)
		return 1;
	return 2 * two_to_pos(n - 1);
}

float two_to_neg(int n)
{
	if (n == 0)
		return 1;
	return 1.0 / (two_to_pos(abs(n)));
}

float two_to(int n)
{
	if (n >= 0)
		return two_to_pos(n);
	if (n < 0)
		return two_to_neg(n);
	return 0;
}

/* Go through some memory "m" which is the 23 bit significand of a
   floating point number.  We work "backwards" from the bits
   furthest on the right, for no particular reason. */
float calc_float(int m, int bit)
{
	/* bit 23 is implied by the standard to be 1.
	   This also terminates our recursion */
	if (bit > 22)
		return 1;

	/* if the bit is set, it represents the value 1/2^bit */
	if ((m >> bit) & 1)
		return 1.0/two_to(23 - bit) + calc_float(m, bit + 1);

	/* otherwise go to the next bit */
	return calc_float(m, bit + 1);
}

int main(int argc, char *argv[])
{
	float f;
	int m,i,sign,exponent,significand;

	if (argc != 2)
	{
		printf("usage: float 123.456\n");
		exit(1);
	}

	if (sscanf(argv[1], "%f", &f) != 1)
	{
		printf("invalid input\n");
		exit(1);
	}

	/* We need to "fool" the compiler, as if we start to use casts
	   (e.g. (int)f) it will actually do a conversion for us.  We
	   want access to the raw bits, so we just copy it into a same
	   sized variable. */
	memcpy(&m, &f, 4);

	/* The sign bit is the first bit */
	sign = (m >> 31) & 0x1;

	/* Exponent is 8 bits following the sign bit */
	exponent = ((m >> 23) & 0xFF) - 127;

	/* Significand fills out the float, the first bit is implied
	   to be 1, hence the or value below. */
	significand = (m & 0x7FFFFF) | 0x800000;

	/* print out a power representation */
	printf("%f = %d * (1 ", f, sign ? -1 : 1);
	for(i = 22 ; i > 0 ; i--)
	{
		if ((m >> i) & 1)
			printf(" + 1/2^%d", 23-i);
	}
	printf(") * 2^%d\n", exponent);

	/* print out a fractional representation */
	printf("%f = %d * (1 ", f, sign ? -1 : 1);
	for(i = 22 ; i > 0 ; i--)
	{
		if ((m >> i) & 1)
			printf(" + 1/%d", (int)two_to(23-i));
	}
	printf(") * 2^%d\n", exponent);

	/* convert this into decimal and print it out */
	printf("%f = %d * %f * %f\n",
	       f,
	       (sign ? -1 : 1),
	       calc_float(significand, 0),
	       two_to(exponent));

	/* do the math this time */
	printf("%f = %f\n",
	       f,
	       (sign ? -1 : 1) *
	       calc_float(significand, 0) *
	       two_to(exponent)
		);

	return 0;
}
