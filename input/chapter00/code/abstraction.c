#include <stdio.h>

/* The API to implement */
struct greet_api
{
	int (*say_hello)(char *name);
	int (*say_goodbye)(void);
};

/* Our implementation of the hello function */
int say_hello_fn(char *name)
{
	printf("Hello %s\n", name);
	return 0;
}

/* Our implementation of the goodbye function */
int say_goodbye_fn(void)
{
	printf("Goodbye\n");
	return 0;
}

/* A struct implementing the API */
struct greet_api greet_api =
{
	.say_hello = say_hello_fn,
	.say_goodbye = say_goodbye_fn
};

/* main() doesn't need to know anything about how the
 * say_hello/goodbye works, it just knows that it does */
int main(int argc, char *argv[])
{
	greet_api.say_hello(argv[1]);
	greet_api.say_goodbye();

	printf("%p, %p, %p\n", greet_api.say_hello, say_hello_fn, &say_hello_fn);

	exit(0);
}
