#ifndef THREAD_POOL_HPP
#define THREAD_POOL_HPP

#include <vector>
#include <queue>
#include <thread>
#include <mutex>
#include <condition_variable>
#include <functional>
#include <future>

class ThreadPool {
public:
	explicit ThreadPool(size_t numThreads);
	~ThreadPool();

	ThreadPool(const ThreadPool&) = delete;
	ThreadPool& operator=(const ThreadPool&) = delete;

	template <typename F, typename... Args>
	auto enqueue(F&& f, Args&&... args)
		-> std::future<std::invoke_result_t<F, Args...>>;

	size_t pendingTasks() const;
	void shutdown();

private:
	std::vector<std::thread> workers_;
	std::queue<std::function<void()>> tasks_;
	mutable std::mutex mutex_;
	std::condition_variable condition_;
	bool stopped_ = false;
};

#endif // THREAD_POOL_HPP
