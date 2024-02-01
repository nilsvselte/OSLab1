#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  exit(n);
  return 0;  // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return fork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return wait(p);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int n;

  argint(0, &n);
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

uint64
sys_sleep(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

uint64
sys_year(void)
{
  int *user_buf;
  int user_buf_size;
  int count = 0;
  struct proc *p;

  // Fetch the system call arguments: pointer to user buffer and its size
  argaddr(0, (uint64 *)&user_buf);
  argint(1, &user_buf_size);

  // Check if user_buf_size is valid
  if (user_buf_size <= 0)
    return -1;

  // Iterate over the process table and copy PIDs to user buffer
  for(p = proc; p < &proc[NPROC] && count < user_buf_size; p++) {
    if(p->state != UNUSED) {
      // Check for user-space memory access error
      if(copyout(myproc()->pagetable, (uint64)&user_buf[count], (char*)&p->pid, sizeof(int)) < 0)
        return -1;  // Return error if copyout fails

      count++;
    }
  }

  return count;  // Return the number of PIDs written
}
