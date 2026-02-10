#ifndef LOGGER_HH
#define LOGGER_HH

#include <string>
#include <fstream>
#include <mutex>
#include <chrono>

namespace logging {

enum class Level { Debug, Info, Warning, Error };

class Logger {
public:
	static Logger& instance();

	void setLevel(Level level);
	void setOutput(const std::string& filePath);

	void debug(const std::string& message);
	void info(const std::string& message);
	void warning(const std::string& message);
	void error(const std::string& message);

private:
	Logger() = default;
	~Logger();
	Logger(const Logger&) = delete;
	Logger& operator=(const Logger&) = delete;

	void log(Level level, const std::string& message);
	static std::string levelToString(Level level);
	static std::string timestamp();

	Level minLevel_ = Level::Info;
	std::ofstream file_;
	std::mutex mutex_;
};

} // namespace logging

#endif // LOGGER_HH
