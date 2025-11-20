#pragma once

#include "spdlog/logger.h"
#include "spdlog/spdlog.h"
#include "spdlog/sinks/stdout_color_sinks.h"

template<class CategoryTag>
struct StaticLogRegistry
{
	StaticLogRegistry()
	{
		if(spdlog::get(CategoryTag::Name))
		{
			return;
		}

		auto sink = std::make_shared<spdlog::sinks::stdout_color_sink_mt>();
		auto logger = std::make_shared<spdlog::logger>(CategoryTag::Name, sink);

		logger->set_pattern("%^[%T] %n: %v%$");
		logger->set_level(CategoryTag::DefaultLevel);
		spdlog::register_logger(logger);
	}
};

template<class CategoryTag, class Sink, class... Args>
void AttachSinkToCategory(Args&&... SinkArgs)
{
	auto logger = spdlog::get(CategoryTag::Name);
	if(logger)
	{
		auto sinkPtr = std::make_shared<Sink>(std::forward<Args>(SinkArgs)...);
		logger->sinks().push_back(sinkPtr);
	}
}

#define DECLARE_LOG_CATEGORY(CategoryName, Level) \
	struct CategoryName \
	{ \
		static constexpr const char* Name = #CategoryName; \
		static constexpr spdlog::level::level_enum DefaultLevel = Level; \
	}; \
	static StaticLogRegistry<CategoryName> CategoryName##Registry;

DECLARE_LOG_CATEGORY(LogTemp, spdlog::level::trace)

#define LOG_TRACE(CAT, ...) spdlog::get(CAT::Name)->trace(__VA_ARGS__)
#define LOG_DEBUG(CAT, ...) spdlog::get(CAT::Name)->debug(__VA_ARGS__)
#define LOG_INFO(CAT, ...) spdlog::get(CAT::Name)->info(__VA_ARGS__)
#define LOG_WARN(CAT, ...) spdlog::get(CAT::Name)->warn(__VA_ARGS__)
#define LOG_ERROR(CAT, ...) spdlog::get(CAT::Name)->error(__VA_ARGS__)
#define LOG_CRITICAL(CAT, ...) spdlog::get(CAT::Name)->critical(__VA_ARGS__)
#define LOG_FLUSH(CAT) spdlog::get(CAT::Name)->flush()
#define LOG_SET_LEVEL(CAT, LEVEL) spdlog::get(CAT::Name)->set_level(LEVEL)
#define LOG_GET_HANDLE(CAT) spdlog::get(CAT::Name)
#define LOG_ATTACH_FILE_SINK(CAT, FILEPATH, TRUNCATE) \
	AttachSinkToCategory<CAT, spdlog::sinks::basic_file_sink_mt>(FILEPATH, TRUNCATE)