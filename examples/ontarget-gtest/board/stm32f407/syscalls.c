// Minimal newlib-nano retargeting: stdout and stderr are routed through RTT.
#include <errno.h>
#include <stddef.h>
#include <stdint.h>
#include <sys/stat.h>
#include <sys/time.h>
#include "SEGGER_RTT.h"

extern char __HeapBase;
extern char __HeapLimit;

void* _sbrk(ptrdiff_t increment) {
  static char* end;
  if (!end) end = &__HeapBase;
  if (increment < 0) {
    if ((size_t)(-increment) > (size_t)(end - &__HeapBase)) {
      errno = EINVAL;
      return (void*)-1;
    }
  } else if ((size_t)increment > (size_t)(&__HeapLimit - end)) {
    errno = ENOMEM;
    return (void*)-1;
  }
  char* previous = end;
  end += increment;
  end = (char*)(((uintptr_t)end + 7u) & ~(uintptr_t)7u);
  return previous;
}

int _write(int fd, char* data, int size) {
  if ((fd != 1 && fd != 2) || size < 0) {
    errno = EBADF;
    return -1;
  }
  return (int)SEGGER_RTT_Write(0, data, (unsigned)size);
}

int _read(int fd, char* data, int size) {
  (void)data; (void)size;
  if (fd != 0) { errno = EBADF; return -1; }
  return 0;  // RTT argument transport uses SEGGER_RTT_Read directly.
}
int _close(int fd) { (void)fd; errno = EBADF; return -1; }
int _fstat(int fd, struct stat* st) {
  if (fd < 0 || fd > 2) { errno = EBADF; return -1; }
  st->st_mode = S_IFCHR;
  return 0;
}
int _isatty(int fd) { return fd >= 0 && fd <= 2; }
int _lseek(int fd, int offset, int whence) {
  (void)fd; (void)offset; (void)whence;
  return 0;
}
int _getpid(void) { return 1; }
int _kill(int pid, int signal) {
  (void)pid; (void)signal; errno = EINVAL; return -1;
}
int _gettimeofday(struct timeval* tv, void* tz) {
  (void)tz;
  if (tv) { tv->tv_sec = 0; tv->tv_usec = 0; }
  return 0; // Example has no RTC: Google Test wall time reports 0 ms.
}

__attribute__((noreturn)) void _exit(int status) {
  if (status == 0) SEGGER_RTT_WriteString(0, "*STOP*0\n");
  else SEGGER_RTT_printf(0, "*STOP*%d\n", status > 0 ? status : 1);
  for (;;) { __asm volatile("nop"); }
}
