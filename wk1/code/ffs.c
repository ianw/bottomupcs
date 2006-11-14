#define ia64_getf_exp(x)                                        \
({                                                              \
        long ia64_intri_res;                                    \
                                                                \
        asm ("getf.exp %0=%1" : "=r"(ia64_intri_res) : "f"(x)); \
                                                                \
        ia64_intri_res;                                         \
})


int main(void)
{

	long double d = 0x1UL;
	long exp;

	exp = ia64_getf_exp(d);

	printf("The first non-zero bit is bit %d\n", exp - 65535);
}

