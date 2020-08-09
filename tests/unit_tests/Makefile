# Initially based on https://www.partow.net/programming/makefile/index.html
CXX      := g++
CXXFLAGS := -pedantic-errors -Wall -Wextra -Werror
LDFLAGS  := -L/usr/lib -lstdc++ ../../build/libgroff.a ../../build/lib/libgnu.a
# Note that groff 'src' and _not_ 'src/include' goes on path. If we use
# 'src/include' then the GROFF version of 'assert.h' is found by catch.hpp and
# causes trouble.
INCLUDE  := -Iexternal/ -I ../../groff-mirror/src/

BUILD    := ../../build/unit_tests
OBJ_DIR  := $(BUILD)/objects
APP_DIR  := $(BUILD)/apps

TARGET   := unit_test_runner

SRC      :=                       \
    $(wildcard src/module1/*.cpp) \
    $(wildcard src/module2/*.cpp) \
    $(wildcard src/module3/*.cpp) \
    $(wildcard src/*.cpp)         \

OBJECTS  := $(SRC:%.cpp=$(OBJ_DIR)/%.o)

all: build $(APP_DIR)/$(TARGET)

$(OBJ_DIR)/%.o: %.cpp
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) $(INCLUDE) -c $< -o $@ $(LDFLAGS)

$(APP_DIR)/$(TARGET): $(OBJECTS)
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) -o $(APP_DIR)/$(TARGET) $^ $(LDFLAGS)

.PHONY: all build clean debug release

build:
	@mkdir -p $(APP_DIR)
	@mkdir -p $(OBJ_DIR)

debug: CXXFLAGS += -DDEBUG -g -O0
debug: all

release: CXXFLAGS += -O2
release: all

clean:
	-@rm -rvf $(OBJ_DIR)/*
	-@rm -rvf $(APP_DIR)/*
