# Compiler and Flags
GHC = ghc
GHC_FLAGS = -Wall -O2

# Directories
SRC_DIR = src
LIB_DIR = lib
APP_DIR = app
BUILD_DIR = build
BIN_DIR = bin

# File Discovery
# Find all .hs files in src, lib, and app directories
SOURCES = $(wildcard $(SRC_DIR)/*.hs) $(wildcard $(LIB_DIR)/*.hs) $(wildcard $(APP_DIR)/*.hs)

# Mapping source files to object files in the build directory
# This preserves the directory structure inside the build folder
OBJECTS = $(patsubst %.hs, $(BUILD_DIR)/%.o, $(SOURCES))

# Include paths for GHC so it can find modules in different directories
INCLUDE_FLAGS = -i$(SRC_DIR) -i$(LIB_DIR) -i$(APP_DIR)

# Final Executable Name
TARGET = $(BIN_DIR)/bam322_hw4

.PHONY: all clean directories

# Default target
all: directories $(TARGET)

# Create necessary directories
directories:
	@mkdir -p $(BUILD_DIR)
	@mkdir -p $(BIN_DIR)

# Linking: Link all object files into the final executable
$(TARGET): $(OBJECTS)
	$(GHC) $(GHC_FLAGS) $(INCLUDE_FLAGS) -o $(TARGET) $(OBJECTS)

# Compilation: Compile .hs files into .o files
# The @mkdir -p $(dir $@) ensures subdirectories exist within the build folder
$(BUILD_DIR)/%.o: %.hs
	@mkdir -p $(dir $@)
	$(GHC) $(GHC_FLAGS) $(INCLUDE_FLAGS) -c $< -o $@

# Clean up build artifacts
clean:
	rm -rf $(BUILD_DIR) $(BIN_DIR)
