#include "../string_set.h"

StringSet::StringSet(unsigned table_size, double load_factor) :
    table_size_(table_size),
    load_factor_(load_factor),
    inserted_elems_count_(0),
    root_nodes_(nullptr)
{
    root_nodes_ = new TNode[table_size_];
}

StringSet::StringSet(StringSet&& set) :
    root_nodes_(std::move(set.root_nodes_)),
    table_size_(std::move(set.table_size_)),
    inserted_elems_count_(std::move(set.inserted_elems_count_)),
    load_factor_(std::move(set.load_factor_)) {}

StringSet::StringSet(const StringSet& set) :
    table_size_(set.table_size_),
    load_factor_(set.load_factor_)
{
    TNode* old_nodes = set.root_nodes_;
    root_nodes_ = new TNode[table_size_];

    for (unsigned root_node_index = 0; root_node_index < table_size_; ++root_node_index) {
        if (!old_nodes[root_node_index].filled_flag_) {
            continue;
        }

        TNode* curr_node = old_nodes + root_node_index;
        while (curr_node != nullptr) {
            Insert(curr_node->str_);
            curr_node = curr_node->next_node_;
        }
    }
}

StringSet& StringSet::operator=(StringSet&& set) {
    RemoveNodes();

    root_nodes_ = std::move(set.root_nodes_);
    table_size_ = std::move(set.table_size_);
    inserted_elems_count_ = std::move(set.inserted_elems_count_);
    load_factor_ = std::move(set.load_factor_);
    return *this;
}

StringSet& StringSet::operator=(const StringSet& set) {
    RemoveNodes();

    table_size_ = set.table_size_;
    load_factor_ = set.load_factor_;

    TNode* old_nodes = set.root_nodes_;
    root_nodes_ = new TNode[table_size_];

    for (unsigned root_node_index = 0; root_node_index < table_size_; ++root_node_index) {
        if (!old_nodes[root_node_index].filled_flag_) {
            continue;
        }

        TNode* curr_node = old_nodes + root_node_index;
        while (curr_node != nullptr) {
            Insert(curr_node->str_);
            curr_node = curr_node->next_node_;
        }
    }
    return *this;
}

StringSet::~StringSet() {
    RemoveNodes();
}

void StringSet::RemoveNodes() {
    for (unsigned root_node_index = 0; root_node_index < table_size_; ++root_node_index) {
        if (root_nodes_[root_node_index].next_node_ == nullptr) {
            continue;
        }

        TNode* curr_node = root_nodes_[root_node_index].next_node_;
        TNode* next_node = nullptr;
        
        while (curr_node != nullptr) {
            next_node = curr_node->next_node_;
            delete curr_node;
            curr_node = next_node;
        }
    }

    inserted_elems_count_ = 0;
    delete[] root_nodes_;
}

bool StringSet::Insert(const char* str) {
    _db(std::cout << "--> INSERT()\n");
    unsigned hash = Hash(str);
    unsigned ins_place = hash % table_size_;

    if (inserted_elems_count_ >= table_size_ * load_factor_) {
        _db(std::cout << "  rehash\n");
        Rehash();
    }

    TNode* last_filled_node = root_nodes_ + ins_place;

    _db(std::cout << "  nodes traverse - start with position " << ins_place << "\n");
    while (last_filled_node->filled_flag_ && last_filled_node->next_node_ != nullptr) {     
        if (last_filled_node->hash_ == hash && strcmp(last_filled_node->str_, str) == 0) {
            _db(std::cout << "  element already exists\n");
            return false;
        }

        last_filled_node = last_filled_node->next_node_;
    }
    _db(std::cout << "  nodes traverse - end\n");
    
    // Additional repetition check if only root node was filled
    if (last_filled_node->hash_ == hash && strcmp(last_filled_node->str_, str) == 0) {
        _db(std::cout << "  element already exists\n");
        return false;
    }

    if (!root_nodes_[ins_place].filled_flag_) {
        last_filled_node->Put(str, strlen(str), hash);
        _db(std::cout << "  existed node filled\n");
    } else {
        last_filled_node->next_node_ = new TNode(str, strlen(str), hash);
        _db(std::cout << "  new node created\n");
    }

    ++inserted_elems_count_;
    return true;
}

bool StringSet::Erase(const char* str) {
    _db(std::cout << "--> ERASE\n");
    unsigned hash = Hash(str);
    unsigned ins_place = hash % table_size_;

    _db(std::cout << "  start traverse loop\n");
    TNode* curr_node = root_nodes_ + ins_place;
    TNode* prev_node = nullptr;
    
    while (curr_node != nullptr) {
        if (curr_node->hash_ == hash && strcmp(curr_node->str_, str) == 0) {
            _db(std::cout << "  found\n");

            if (prev_node == nullptr) {
                // If node to be erased is one of the root nodes
                curr_node->filled_flag_ = false;
            } else {
                // If node to be erased is in chain
                prev_node->next_node_ = curr_node->next_node_;
                delete curr_node;
            }

            --inserted_elems_count_;
            return true;
        }

        prev_node = curr_node;
        curr_node = curr_node->next_node_;
    }

    _db(std::cout << "  not found\n");
    return false;
}

void StringSet::Rehash() {
    _db(std::cout << "--> REHASH\n");
    _db(std::cout << "  old table size: " << table_size_ << "\n  new table size: " << (table_size_ * 4) << "\n  elems count: " << inserted_elems_count_ << "\n");

    if (table_size_ * 4 <= table_size_) {
        return;
    }

    TNode* old_nodes = root_nodes_;
    unsigned old_table_size = table_size_;
    
    table_size_ *= 4;
    root_nodes_ = new TNode[table_size_];

    for (unsigned root_node_index = 0; root_node_index < old_table_size; ++root_node_index) {
        if (!old_nodes[root_node_index].filled_flag_) {
            continue;
        }

        Insert(old_nodes[root_node_index].str_);

        TNode* curr_node = old_nodes[root_node_index].next_node_;
        while (curr_node != nullptr) {
            Insert(curr_node->str_);

            TNode* tmp_node = curr_node;
            curr_node = curr_node->next_node_;
            delete tmp_node;
        }
    }

    delete[] old_nodes;
}

unsigned StringSet::Hash(const char* str) {
    // Hash algorithm: fnv1a32
    unsigned hash = 0x811c9dc5;
    while (*str != '\0') {
        hash = (hash ^ *str) * 0x01000193;
        ++str;
    }
    return hash;
}

// -=- -=- -=- -=- -=- -=- -=- -=- -=- -=- -=- -=- -=- -=-

StringSet::TNode::TNode() :
    str_(nullptr),
    hash_(0),
    filled_flag_(false),
    buff_size_(hash_table_defaults::BUFF_SIZE),
    next_node_(nullptr)
{
    str_ = new char[buff_size_];
    str_[0] = '\0';
}


StringSet::TNode::TNode(const char* str, int str_len, unsigned hash) :
    hash_(hash),
    filled_flag_(true),
    buff_size_(str_len + 1),
    next_node_(nullptr)
{
    _db("--> TNODE() constructor with given values\n");
    str_ = new char[buff_size_];
    strncpy(str_, str, str_len);
    str_[str_len] = '\0';
}

StringSet::TNode::~TNode() {
    delete[] str_;
}

void StringSet::TNode::Put(const char* str, int str_len, unsigned hash) noexcept {   
    if (str_len + 1 > buff_size_) {     
        delete[] str_;
        buff_size_ = str_len + 1;
        str_ = new char[buff_size_];
    }
    
    strncpy(str_, str, str_len);
    str_[str_len] = '\0';    
    hash_ = hash;
    filled_flag_ = true;
}

void StringSet::TNode::Erase() noexcept {
    filled_flag_ = false;
}