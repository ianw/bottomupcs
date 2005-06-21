#include <stdio.h>

/* for syscall() */
#include <sys/syscall.h>
#include <unistd.h>

/* system call numbers */
#include <asm/unistd.h>

void function(void)
{
	int pid;

	pid = __syscall(__NR_getpid);
}
