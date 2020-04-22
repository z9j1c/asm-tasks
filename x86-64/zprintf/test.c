#include <stdio.h>
extern int zprintf(const char *format, ...);

int main(int argc, char** argv) {
    zprintf("help%otutu%x", 16, 65);
    return 0;
}