#include <stdio.h>

/*
 *  define all 8 possible flags for an 8 bit variable
 *      name  hex     binary
 */
#define FLAG1 0x01 /* 00000001 */
#define FLAG2 0x02 /* 00000010 */
#define FLAG3 0x04 /* 00000100 */
#define FLAG4 0x08 /* 00001000 */
/* ... and so on */
#define FLAG8 0x80 /* 10000000 */

int main(int argc, char *argv[])
{
	char flags = 0; /* an 8 bit variable */

	/* set flags with a logical or */
	flags = flags | FLAG1; /* set flag 1 */
	flags = flags | FLAG3; /* set flag 3

	/* check flags with a logical and.  If the flag is set (1)
	 * then the logical and will return 1, causing the if
	 * condition to be true. */
	if (flags & FLAG1)
		printf("FLAG1 set!\n");

	/* this of course will be untrue. */
	if (flags & FLAG8)
		printf("FLAG8 set!\n");

	/* check multiple flags by using a logical or
	 * this will pass as FLAG1 is set */
	if (flags & (FLAG1|FLAG4))
		printf("FLAG1 or FLAG4 set!\n");

	return 0;
}
