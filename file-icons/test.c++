#include <iostream>
#include <vector>
#include <algorithm>
#include <numeric>

template <typename T>
class Statistics {
public:
    void add(T value) {
        data_.push_back(value);
    }

    T mean() const {
        T sum = std::accumulate(data_.begin(), data_.end(), T{});
        return sum / static_cast<T>(data_.size());
    }

    T median() const {
        std::vector<T> sorted = data_;
        std::sort(sorted.begin(), sorted.end());
        size_t mid = sorted.size() / 2;
        return sorted.size() % 2 == 0
            ? (sorted[mid - 1] + sorted[mid]) / T{2}
            : sorted[mid];
    }

private:
    std::vector<T> data_;
};

int main() {
    Statistics<double> stats;
    for (double v : {4.2, 7.8, 1.5, 9.3, 3.6, 6.1}) {
        stats.add(v);
    }
    std::cout << "Mean:   " << stats.mean() << "\n";
    std::cout << "Median: " << stats.median() << "\n";
    return 0;
}
