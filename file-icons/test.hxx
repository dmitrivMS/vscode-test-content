#ifndef LINKED_LIST_HXX
#define LINKED_LIST_HXX

#include <memory>
#include <stdexcept>

template <typename T>
class LinkedList {
public:
    struct Node {
        T data;
        std::unique_ptr<Node> next;
        Node(T val) : data(std::move(val)), next(nullptr) {}
    };

    LinkedList() : head_(nullptr), size_(0) {}

    void push_front(T value) {
        auto node = std::make_unique<Node>(std::move(value));
        node->next = std::move(head_);
        head_ = std::move(node);
        ++size_;
    }

    T& front() {
        if (!head_) throw std::runtime_error("List is empty");
        return head_->data;
    }

    std::size_t size() const { return size_; }
    bool empty() const { return size_ == 0; }

private:
    std::unique_ptr<Node> head_;
    std::size_t size_;
};

#endif // LINKED_LIST_HXX
