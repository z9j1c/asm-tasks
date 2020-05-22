#include "../string_set.h"
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <assert.h>
#include <iostream>

/*!
    Intrusive string-word list node
*/
struct word_st {
    char* str_;

    word_st(char* str = nullptr) : str_(str) {}
};

char* load_full_file(const char* filename, int* file_size) {    
    struct stat file_st;
    int fd = -1;
    
    if ((fd = open(filename, O_RDONLY)) == -1) {
        return nullptr;
    }
    
    if (stat(filename, &file_st) == -1) {
        return nullptr;
    }

    char* content = new char[file_st.st_size];
    *file_size = file_st.st_size;

    read(fd, content, *file_size);
    close(fd);

    return content;
}

bool test_real_words(const char* filename) {    
    // Load full file with words
    int file_size = 0;
    char* content = load_full_file(filename, &file_size);
    if (content == nullptr) {
        return false;
    }

    // Make strings from lines
    int words_count = 0;
    for (int i = 0; i < file_size; ++i) {        
        if (content[i] == '\n') {
            content[i] = '\0';
            ++words_count;
        }
    }

    // Compute ptrs on strings beginings
    word_st* words = new word_st[words_count];
    int word_index = 0;
    words[0].str_ = content;

    for (int i = 0; i < file_size; ++i) {
        if (content[i] == '\0' && content[i + 1] != '\0') {
            words[++word_index].str_ = content + i + 1;
        }
    }

    // Put all words into set
    std::cout << "Inserts\n";
    StringSet set;
    for (int i = 0; i < words_count; ++i) {
        set.Insert(words[i].str_);
    }

    unsigned long long words_processed = 0;
    bool result = true;
    for (int i = 0; i < 100; ++i) {
        for (int j = words_count - 1; j >= 0; --j) {
            result &= set.Find(words[j].str_);
            ++words_processed;
        }
    }
    std::cout << "WORDS PROCESSED: " << words_processed << "\n";

    // Clear memory
    delete[] content;
    delete[] words;

    return result;
}

int main(int argc, char** argv) {
    test_real_words("../data/words_file.txt");
    return 0;
}