#pragma once
#include <cstring>s

namespace hash_table_defaults {
    const unsigned SIZE = 16;
}

/*!
    HashTable for (int, std::string) pairs
*/
class IntLineMap {
public:
    IntLineMap(unsigned table_size = hash_table_defaults::SIZE);

    ~IntLineMap();

    void Insert(int key, const char* str, int len = -1);

    char* Find(int key);

    /*!
        Allow rehash (and realloc) procedures in hashtable
        @return False if rehashing was already allowed, True otherwise
    */
    bool AllowRehash() noexcept;

    /*!
        Forbid rehash (and realloc) procedures in hashtable
        @return False if rehashing was already forbidden, True otherwise
    */
    bool ForbidRehash() noexcept;

protected:
    /*!
        Internal hashtable node struct
        Contains c-lines and 
    */
    struct TNode {
        TNode();

        ~TNode();

        char* str_;
        TNode* next_node_;

        size_t str_size_;
        unsigned str_hash_;
    };

    TNode* root_nodes_;
    unsigned roots_count_;
    unsigned inserted_elems_;
    bool rehash_enable_opt_;

    /*!
        Primary c-string hashing
        @param str Original c-line
        @return Unsigned c-string hash
    */
    unsigned PrimaryHash(const char* str);

    /*!
        Hashing to go through the table
        @param str Original c-line
        @return Unsigned c-string hash
    */
    unsigned SecondaryHash(const char* str);

    /*!
        Set rehash option
        @param opt New rehash option
        @return True if the new opt differs from the previous one, False otherwise
    */
    bool SetRehashOpt(bool opt);
};