/* Set up the loaded object described by L so its unrelocated PLT
   entries will jump to the on-demand fixup code in dl-runtime.c.  */

static inline int __attribute__ ((unused, always_inline))
elf_machine_runtime_setup (struct link_map *l, int lazy, int profile)
{
  extern void _dl_runtime_resolve (void);
  extern void _dl_runtime_profile (void);

  if (lazy)
    {
      register Elf64_Addr gp __asm__ ("gp");
      Elf64_Addr *reserve, doit;

      /*
       * Careful with the typecast here or it will try to add l-l_addr
       * pointer elements
       */
      reserve = ((Elf64_Addr *)
                 (l->l_info[DT_IA_64 (PLT_RESERVE)]->d_un.d_ptr + l->l_addr));
      /* Identify this shared object.  */
      reserve[0] = (Elf64_Addr) l;

      /* This function will be called to perform the relocation.  */
      if (!profile)
        doit = (Elf64_Addr) ((struct fdesc *) &_dl_runtime_resolve)->ip;
      else
        {
          if (GLRO(dl_profile) != NULL
              && _dl_name_match_p (GLRO(dl_profile), l))
            {
              /* This is the object we are looking for.  Say that we really
                 want profiling and the timers are started.  */
              GL(dl_profile_map) = l;
            }
          doit = (Elf64_Addr) ((struct fdesc *) &_dl_runtime_profile)->ip;
        }

      reserve[1] = doit;
      reserve[2] = gp;
    }

  return lazy;
}
