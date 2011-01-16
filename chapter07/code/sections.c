#include <stdio.h>

int big_big_array[10*1024*1024];

char *a_string = "Hello, World!";

int a_var_with_value = 0x100;

int main(void)
{
	big_big_array[0] = 100;
	printf("%s\n", a_string);
	a_var_with_value += 20;
}
