CC = gcc
CFLAGS = -Wall -Wextra -O2 -std=c17
LDFLAGS = -lm
SRC_DIR = src
BUILD_DIR = build
TARGET = $(BUILD_DIR)/app

SOURCES = $(wildcard $(SRC_DIR)/*.c)
OBJECTS = $(SOURCES:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.o)

.PHONY: all clean install test

all: $(TARGET)

$(TARGET): $(OBJECTS)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(OBJECTS) -o $@ $(LDFLAGS)
	@echo "Build complete: $@"

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -rf $(BUILD_DIR)

test: $(TARGET)
	./$(TARGET) --run-tests

install: $(TARGET)
	cp $(TARGET) /usr/local/bin/
