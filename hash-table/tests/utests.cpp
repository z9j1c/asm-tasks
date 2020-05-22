#include <assert.h>
#include <iostream>
#include "../string_set.h"

int __z9j1c_tests_counter__ = 1;

#define TEST(obj) { \
    std::cout << __z9j1c_tests_counter__++ << " "; \
    assert(obj); \
    std::cout << "= OK =\n"; \
}

// ==================== TESTS ====================

bool test_create() {
    StringSet set;
    return true;
}

bool test_one_insert() {
    StringSet set;
    set.Insert("helloaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
    return true;
}

bool test_long_one_insert() {
    StringSet set;
    set.Insert("hello");
    return true;
}

bool test_double_insert() {
    StringSet set;
    set.Insert("hello");
    return !set.Insert("hello");
}

bool test_small_stress() {
    StringSet set;
    char str[3] = {1, 1, 0};
    bool result = true;

    for (int i = 'a'; i <= 'z'; ++i) {
        for (int j = 'A'; j <= 'Z'; ++j) {
            str[0] = i;
            str[1] = j;

            result &= set.Insert(str);
        }
    }

    return result;
}

bool test_single_find() {
    StringSet set;
    set.Insert("hello");
    set.Insert("rururu");
    set.Insert("afgbt");
    set.Insert("aaaaaa");
    set.Insert("asdsaaa");
    set.Insert("atttt");
    set.Insert("atg");
    set.Insert("abnn");
    set.Insert("asxc");
    set.Insert("aeee");
    set.Insert("aqwws");
    set.Insert("agn");
    set.Insert("asadv");
    set.Insert("abv");
    set.Insert("arg");
    set.Insert("aeg");
    set.Insert("sd");
    set.Insert("d");
    set.Insert("dfg");
    set.Insert("gf");
    set.Insert("h");
    return set.Find("h");
}

bool test_not_find() {
    StringSet set;
    set.Insert("hello");
    return !set.Find("jojo");
}

bool test_small_stress_find() {
    StringSet set;
    char str[3] = {1, 1, 0};
    bool result = true;

    for (int i = 'a'; i <= 'i'; ++i) {
        for (int j = 'A'; j <= 'Z'; ++j) {
            str[0] = i;
            str[1] = j;

            set.Insert(str);
            result &= set.Find(str);
        }
    }
    return result;
}

bool test_one_erase() {
    StringSet set;
    set.Insert("hi");
    set.Erase("hi");
    return !set.Find("hi");
}

bool test_double_erase() {
    StringSet set;
    set.Insert("nope");
    set.Erase("nope");
    set.Insert("nope");

    bool result = true;
    result &= set.Erase("nope");
    result &= (!set.Find("nope"));
    return result;
}

bool test_small_stress_erase() {
    StringSet set;
    char str[3] = {1, 1, 0};
    bool result = true;

    for (int i = 'a'; i <= 'z'; ++i) {
        for (int j = 'A'; j <= 'Z'; ++j) {
            str[0] = i;
            str[1] = j;
            set.Insert(str);
        }
    }

    for (int i = 'z'; i >= 'a'; --i) {
        for (int j = 'Z'; j >= 'A'; --j) {
            str[0] = i;
            str[1] = j;
            result &= set.Erase(str);
            
            str[0] = i - 'a' + 'A';
            str[1] = j - 'A' + 'a';
            result &= !set.Erase(str); 
        }
    }

    return result;
}

int main(int argc, char** argv) {
    TEST(test_create());
    TEST(test_one_insert());
    TEST(test_long_one_insert());
    TEST(test_double_insert());
    TEST(test_small_stress());

    TEST(test_single_find());
    TEST(test_not_find());
    TEST(test_small_stress_find());

    TEST(test_one_erase());
    TEST(test_double_erase());
    TEST(test_small_stress_erase());
    return 0;
}