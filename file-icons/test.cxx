#include <iostream>
#include <vector>
#include <algorithm>
#include <string>

class TaskQueue {
public:
	void addTask(const std::string& name, int priority) {
		tasks_.push_back({name, priority});
	}

	void processByPriority() {
		std::sort(tasks_.begin(), tasks_.end(),
			[](const Task& a, const Task& b) { return a.priority > b.priority; });

		for (const auto& task : tasks_) {
			std::cout << "Processing: " << task.name
			          << " (priority " << task.priority << ")" << std::endl;
		}
	}

private:
	struct Task {
		std::string name;
		int priority;
	};
	std::vector<Task> tasks_;
};

int main() {
	TaskQueue queue;
	queue.addTask("Send email", 2);
	queue.addTask("Build project", 5);
	queue.addTask("Run tests", 4);
	queue.addTask("Deploy", 1);
	queue.processByPriority();
	return 0;
}
