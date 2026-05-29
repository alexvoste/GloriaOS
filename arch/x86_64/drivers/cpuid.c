#include "../include/types.h"

void cpuid(u32 code, u32* eax, u32* ebx, u32* ecx, u32* edx)
{
    __asm__ volatile("cpuid" : "=a"(*eax), "=b"(*ebx), "=c"(*ecx), "=d"(*edx) : "a"(code));
}
