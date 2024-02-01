#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Hello World.\n");
        return 1;
    }

    printf("\n Hello, %s!\n", argv[1]);
    return 0;
}
