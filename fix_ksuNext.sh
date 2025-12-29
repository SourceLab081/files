sed -i "12i\#include <linux/sched/task.h>" KernelSU-Next/kernel/allowlist.c
sed -i "11i\#include \"kernel_compat.h\"" KernelSU-Next/kernel/allowlist.c
sed -i "6i\#include \"kernel_compat.h\"" KernelSU-Next/kernel/setuid_hook.h
