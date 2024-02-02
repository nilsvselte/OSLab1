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
        char* stateStr = (char*)malloc(16);
        char* nameStr = (char*)malloc(16);
        state(pid_array[i],stateStr);
        procname(pid_array[i],nameStr);

        printf("PID: %d\n", pid_array[i]);
        printf("State: %s\n", stateStr);
        printf("Name: %s\n", nameStr);
    }

    exit(0);
} 