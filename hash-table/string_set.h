#pragma once
#include <cstring>
#include <iostream>

// #define DEBUG_MSG 1

#ifdef DEBUG_MSG
#define _db(code) (code);
#endif

#ifndef DEBUG_MSG
#define _db(code) ;
#endif

/*!
    Namespace with default values for StringSet class
*/
namespace hash_table_defaults {
    const unsigned SIZE = 16;
    const double LOAD_FACTOR = 0.96;

    const int BUFF_SIZE = 18 + 1;
}

/*!
    HashTable-based set for c-strings
*/
class StringSet {
public:
    StringSet(unsigned table_size = hash_table_defaults::SIZE,
                double load_factor = hash_table_defaults::LOAD_FACTOR);

    ~StringSet();

    bool Insert(const char* str);

    bool Find(const char* str);

    bool Erase(const char* str);

protected:
    struct TNode {
        char* str_;

        unsigned hash_;
        bool filled_flag_;
        int buff_size_;

        TNode* next_node_;

        TNode();
        TNode(const char* str, int str_len, unsigned hash);
        ~TNode();

        void Put(const char* str, int str_len, unsigned hash) noexcept;

        void Erase() noexcept;
    };

    TNode* root_nodes_;
    
    unsigned table_size_;
    unsigned inserted_elems_count_;
    double load_factor_;

    unsigned Hash(const char* line);

    void Rehash();
};