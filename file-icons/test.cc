#include <iostream>
#include <string>
#include <unordered_map>
#include <fstream>

class WordFrequency {
public:
    void process(const std::string& filename) {
        std::ifstream file(filename);
        std::string word;
        while (file >> word) {
            ++freq_[normalize(word)];
        }
    }

    void print_top(size_t n) const {
        std::vector<std::pair<std::string, int>> entries(freq_.begin(), freq_.end());
        std::sort(entries.begin(), entries.end(),
            [](const auto& a, const auto& b) { return a.second > b.second; });
        for (size_t i = 0; i < std::min(n, entries.size()); ++i) {
            std::cout << entries[i].first << ": " << entries[i].second << "\n";
        }
    }

private:
    std::unordered_map<std::string, int> freq_;

    static std::string normalize(std::string s) {
        std::transform(s.begin(), s.end(), s.begin(), ::tolower);
        return s;
    }
};

int main(int argc, char* argv[]) {
    if (argc < 2) {
        std::cerr << "Usage: " << argv[0] << " <file>\n";
        return 1;
    }
    WordFrequency wf;
    wf.process(argv[1]);
    wf.print_top(10);
    return 0;
}
