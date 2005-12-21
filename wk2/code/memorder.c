typedef struct {
int a;
int b;
} a_struct;

/*
 * Pass in a pointer to be allocated as a new structure
 */
void get_struct(a_struct *new_struct)
{
	void *p = malloc(sizeof(a_struct));

	/* We don't particularly care what order the following two
	 * instructions end up acutally executing in */
	p->a = 100;
	p->b = 150;

	/* However, they must be done before this instruction.
	 * Otherwise, another processor who looks at the value of p
	 * could find it pointing into a structure whose values have
	 * not been filled out.
	 */
	new_struct = p;
}
