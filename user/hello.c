#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Hello World\n");
        return 1;
    }

    printf("\nHello %s, nice to meet you!\n", argv[1]);
    return 0;
}
