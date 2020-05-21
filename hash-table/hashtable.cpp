#include "hashtable.h"

IntLineMap::IntLineMap(unsigned table_size) :
    roots_count_(table_size),
    inserted_elems_(0),
    rehash_enable_opt_(true)
{
    root_nodes_ = new TNode[];
}

IntLineMap::~IntLineMap() {
    for 
}

bool IntLineMap::AllowRehash() noexcept {
    SetRehashOpt(false);
}

bool IntLineMap::AllowRehash() noexcept {
    SetRehashOpt(true);
}

bool IntLineMap::SetRehashOpt(bool opt) {
    bool prev_opt = rehash_enable_opt_;
    rehash_enable_opt_ = opt;

    return (prev_opt != rehash_enable_opt_);
}

unsigned IntLineMap::PrimaryHash(const char* str) {
    unsigned hash = 0x811c9dc5;
    while (*str != '\0') {
        hash = (hash ^ *str) * 0x01000193;
    }
    return hash;
}

unsigned IntLineMap::SecondaryHash(const char* str) {
    return 0;
}

// -=- -=- -=- -=- -=- -=- -=- -=- -=- -=- -=- -=- -=- -=-

IntLineMap::TNode::TNode() :
    str_(nullptr), next_node_(nullptr), str_size_(0), str_hash_(0) {}

IntLineMap::TNode::~TNode() {
    delete str_;
}