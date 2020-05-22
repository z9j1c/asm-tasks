#!/bin/bash

g++ real_words_test.cpp ../cpp_ver/string_set.cpp -O0 -o rtest_asm
echo 'rtest_asm -- runnable file'