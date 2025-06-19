#include "types.h"
#include "param.h"
#include "riscv.h"
#include "defs.h"

static unsigned int seed = 1;

int 
random(int max)
{
  seed = (uint64)seed * 48271 % 2147483647;
  return seed % max;
}