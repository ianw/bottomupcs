/*
 * Start at the bottom, and work your way up!
 */

/* Indirect macros required for expanded argument pasting, eg. __LINE__. */
#define ___PASTE(a,b) a##b
#define __PASTE(a,b) ___PASTE(a,b)


#define __UNIQUE_ID(prefix) __PASTE(__PASTE(__UNIQUE_ID_, prefix), __COUNTER__)

/* Indirect stringification.  Doing two levels allows the parameter to be a
 * macro itself.  For example, compile with -DFOO=bar, __stringify(FOO)
 * converts to "bar".
 */

#define __stringify_1(x...)     #x
#define __stringify(x...)       __stringify_1(x)

#define __MODULE_INFO(tag, name, info)                                    \
static const char __UNIQUE_ID(name)[]                                     \
  __used __attribute__((section(".modinfo"), unused, aligned(1)))         \
  = __stringify(tag) "=" info

/* Generic info of form tag = "info" */
#define MODULE_INFO(tag, info) __MODULE_INFO(tag, tag, info)

/*
 * Author(s), use "Name <email>" or just "Name", for multiple
 * authors use multiple MODULE_AUTHOR() statements/lines.
 */
#define MODULE_AUTHOR(_author) MODULE_INFO(author, _author)

/* ---- */

MODULE_AUTHOR("Your Name <your@name.com>");
