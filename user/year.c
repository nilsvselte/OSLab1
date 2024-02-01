#include "kernel/types.h"
#include "user.h"

int 
main(void) 
{
    int pid_array[100];
    int num_pids;
    num_pids = year(pid_array, 100);

    if (num_pids < 0) {
        printf("Error in sys_year\n");
        exit(0);
    }

    // Process or print the PIDs
    printf("Received %d PIDs:\n", num_pids);
    for (int i = 0; i < num_pids; i++) {
        printf("PID: %d\n", pid_array[i]);
    }

    exit(0);
} 