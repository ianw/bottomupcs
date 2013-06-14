/* user-visible error numbers are in the range -1 - -124: see <asm-i386/errno.h> */

#define __syscall_return(type, res)				\
do {								\
        if ((unsigned long)(res) >= (unsigned long)(-125)) {	\
                errno = -(res);					\
                res = -1;					\
        }							\
        return (type) (res);					\
} while (0)

/* XXX - _foo needs to be __foo, while __NR_bar could be _NR_bar. */
#define _syscall0(type,name)			\
type name(void)					\
{						\
long __res;					\
__asm__ volatile ("int $0x80"			\
        : "=a" (__res)				\
        : "0" (__NR_##name));			\
__syscall_return(type,__res);
}

#define _syscall1(type,name,type1,arg1)			\
type name(type1 arg1)					\
{							\
long __res;						\
__asm__ volatile ("int $0x80"				\
        : "=a" (__res)					\
        : "0" (__NR_##name),"b" ((long)(arg1)));	\
__syscall_return(type,__res);
}

#define _syscall2(type,name,type1,arg1,type2,arg2)			\
type name(type1 arg1,type2 arg2)					\
{									\
long __res;								\
__asm__ volatile ("int $0x80"						\
        : "=a" (__res)							\
        : "0" (__NR_##name),"b" ((long)(arg1)),"c" ((long)(arg2)));	\
__syscall_return(type,__res);
}

#define _syscall3(type,name,type1,arg1,type2,arg2,type3,arg3)		\
type name(type1 arg1,type2 arg2,type3 arg3)				\
{									\
long __res;								\
__asm__ volatile ("int $0x80"						\
        : "=a" (__res)							\
        : "0" (__NR_##name),"b" ((long)(arg1)),"c" ((long)(arg2)),	\
                  "d" ((long)(arg3)));					\
__syscall_return(type,__res);						\
}

#define _syscall4(type,name,type1,arg1,type2,arg2,type3,arg3,type4,arg4)	\
type name (type1 arg1, type2 arg2, type3 arg3, type4 arg4)			\
{										\
long __res;									\
__asm__ volatile ("int $0x80"							\
        : "=a" (__res)								\
        : "0" (__NR_##name),"b" ((long)(arg1)),"c" ((long)(arg2)),		\
          "d" ((long)(arg3)),"S" ((long)(arg4)));				\
__syscall_return(type,__res);							\
}

#define _syscall5(type,name,type1,arg1,type2,arg2,type3,arg3,type4,arg4,	\
          type5,arg5)								\
type name (type1 arg1,type2 arg2,type3 arg3,type4 arg4,type5 arg5)		\
{										\
long __res;									\
__asm__ volatile ("int $0x80"							\
        : "=a" (__res)								\
        : "0" (__NR_##name),"b" ((long)(arg1)),"c" ((long)(arg2)),		\
          "d" ((long)(arg3)),"S" ((long)(arg4)),"D" ((long)(arg5)));		\
__syscall_return(type,__res);							\
}

#define _syscall6(type,name,type1,arg1,type2,arg2,type3,arg3,type4,arg4,			\
          type5,arg5,type6,arg6)								\
type name (type1 arg1,type2 arg2,type3 arg3,type4 arg4,type5 arg5,type6 arg6)			\
{												\
long __res;											\
__asm__ volatile ("push %%ebp ; movl %%eax,%%ebp ; movl %1,%%eax ; int $0x80 ; pop %%ebp"	\
        : "=a" (__res)										\
        : "i" (__NR_##name),"b" ((long)(arg1)),"c" ((long)(arg2)),				\
          "d" ((long)(arg3)),"S" ((long)(arg4)),"D" ((long)(arg5)),				\
          "0" ((long)(arg6)));									\
__syscall_return(type,__res);									\
}
