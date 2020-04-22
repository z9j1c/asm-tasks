#include <stdio.h>
extern int zprintf(const char *format, ...);

int main(int argc, char** argv) {
    zprintf("help%d~~~%d", 2513, 1137);
    return 0;
}