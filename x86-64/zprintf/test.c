#include <stdio.h>
extern int zprintf(const char *format, ...);

int main(int argc, char** argv) {
    zprintf("~~~%s%s~~~%d~~%c~%c~%x~~%b", "Go ", "to the hell", 512, 'A', '^', 32, 65);
    return 0;
}