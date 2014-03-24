#### PROJECT SETTINGS ####
# The name of the executable to be created
export BIN_NAME = beemon
# Compiler used
export CXX = g++
# Extension of source files used in the project
SRC_EXT = cpp
# Path to the source directory, relative to the makefile
SRC_PATH = src
# Set additional compiler flags
override CXXFLAGS := $(CXXFLAGS) -std=c++11 -Wall
# Addtional compiler flags for the debug build
debug: export CXXFLAGS += -g -D NDEBUG
# Add additional include paths
export INCLUDES = -I$(SRC_PATH)/
# Add additional libraries
export LIBS = -lwiringPi -lrt
# install path (bin/ is appended automatically
INSTALL_PREFIX = /usr/local
#### END PROJECT SETTINGS ####
 
# Generally should not need to edit below this line
 
# Build and output paths
release: export BUILD_PATH = build/release
release: export BIN_PATH := bin/release
debug: export BUILD_PATH := build/debug
debug: export BIN_PATH := bin/debug
 
# Find all source files in the source directory
SOURCES = $(shell find $(SRC_PATH)/ -name '*.$(SRC_EXT)')
# Set the object file names, with the root source directory stripped
# from the path
OBJECTS = $(SOURCES:$(SRC_PATH)/%.$(SRC_EXT)=$(BUILD_PATH)/%.o)
# Set the dependency files that will be used to add header dependencies
DEPS = $(OBJECTS:.o=.d)
 
TFILE = $(dir $@).$(notdir $@)_time
STIME = date '+%s' > $(TFILE)
ETIME = read st < $(TFILE) ; \
$(RM) $(TFILE) ; \
st=$$((`date '+%s'` - $$st - 86400)) ; \
echo `date -u -d @$$st '+%H:%M:%S'`
 
# Standard, non-optimized release build
.PHONY: release
release: dirs
@echo "Beginning release build"
@$(STIME)
@$(MAKE) all --no-print-directory
@echo -n "Total build time: "
@$(ETIME)
 
# Debug build for gdb debugging
.PHONY: debug
debug: dirs
@echo "Beginning debug build"
@$(STIME)
@$(MAKE) all --no-print-directory
@echo -n "Total build time: "
@$(ETIME)
 
# Create the directories used in the build
.PHONY: dirs
dirs:
@echo "Creating directories"
@mkdir -p $(dir $(OBJECTS))
@mkdir -p $(BIN_PATH)
 
# Installs to the set path
.PHONY: install
install:
@echo "Installing to $(INSTALL_PREFIX)/bin"
@install -m 0755 $(BIN_NAME) $(INSTALL_PREFIX)/bin
 
# Removes all build files
.PHONY: clean
clean:
@echo "Deleting symlink to $(BIN_NAME)"
@$(RM) $(BIN_NAME)
@echo "Deleting directories"
@$(RM) -r build
@$(RM) -r bin
 
# Main rule, checks the executable file and symlinks to the output
all: $(BIN_PATH)/$(BIN_NAME)
@echo "Making symlink: $(BIN_NAME) -> $<"
@$(RM) $(BIN_NAME)
@ln -s $(BIN_PATH)/$(BIN_NAME) $(BIN_NAME)
 
# Build the executable file
$(BIN_PATH)/$(BIN_NAME): $(OBJECTS)
@echo "Linking: $@"
@$(STIME)
@$(CXX) $(OBJECTS) $(LIBS) -o $@
@echo -n "\t Link time: "
@$(ETIME)
 
# Add dependency files, if they exist
-include $(DEPS)
 
# Source file rules
# After the first compilation they will be joined with the rules from the
# dependency files to provide header dependencies
$(BUILD_PATH)/%.o: $(SRC_PATH)/%.$(SRC_EXT)
@echo "Compiling: $< -> $@"
@$(STIME)
@$(CXX) $(CXXFLAGS) $(INCLUDES) $(LIBS) -MMD -c $< -o $@
@echo -n "\t Compile time: "
@$(ETIME)
