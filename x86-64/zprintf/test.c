#include <stdio.h>
extern int zprintf(const char *format, ...);

int main(int argc, char** argv) {
    zprintf("help%b", 33);
    return 0;
}