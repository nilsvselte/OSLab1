#include "kernel/types.h"
#include "user.h"

int
string_state_to_int(char* stateStr)
{
    if (strcmp(stateStr, "UNUSED") == 0) 
    {
        return 0;
    } else if (strcmp(stateStr, "USED") == 0) {
        return 1;
    } else if (strcmp(stateStr, "SLEEPING") == 0) {
        return 2;
    } else if (strcmp(stateStr, "RUNNABLE") == 0) {
        return 3;
    } else if (strcmp(stateStr, "RUNNING") == 0) {
        return 4;
    } else if (strcmp(stateStr, "ZOMBIE") == 0) {
        return 5;
    } else {
        return -1;
    }
}

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
    //printf("Received %d PIDs:\n", num_pids);
    for (int i = 0; i < num_pids; i++) {
        char* stateStr = (char*)malloc(16);
        char* nameStr = (char*)malloc(16);
        state(pid_array[i],stateStr);
        procname(pid_array[i],nameStr);
        printf("%s ", nameStr);
        printf("(%d):", pid_array[i]);
        printf(" %d\n", string_state_to_int(stateStr));        
    }
    exit(0);
} 