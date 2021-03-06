CC=g++

BIN = bin
OBJ_DIR = obj
SRC = src
INCLUDE = include
LIB = lib
TEST_DIR = test

FLAGS = -g -ftest-coverage -fprofile-arcs -fPIC -O0
LIBS = -lgtest -lpthread

# The names of the files to compile to create the library
BASENAMES = roman

# Files to compile to standalone binaries
BINS = roman-to-int

# Final dynamic library
LIB_FINAL = roman

# The names of the tests to run
TESTS = testSimple testIncreasing testSubtracting testUntil3000 testBin

# Generating the final .so path
LIB_NAME=lib$(LIB_FINAL).a
LIB_FULLNAME = $(LIB)/$(LIB_NAME)

# Generating include/*.h dependencies
_HEADERS = $(addprefix $(INCLUDE)/, $(BASENAMES))
HEADERS = $(addsuffix .h, $(_HEADERS))

# Generating src/*.c dependencies
_SOURCES = $(addprefix $(SRC)/, $(BASENAMES))
SOURCES = $(addsuffix .c, $(_SOURCES))

BIN_EXES= $(addprefix $(BIN)/, $(BINS))

_OBJS = $(addprefix $(OBJ_DIR)/, $(BASENAMES))
OBJS = $(addsuffix .o, $(_OBJS))

# Setting up gtest
GTEST_ROOT_DIR?=../googletest-master/
# GTEST_LIB_DIR must point to where is libgtest.a
GTEST_LIB_DIR?=$(GTEST_ROOT_DIR)build/googlemock/gtest
# GTEST_INCLUDE_DIR must point to where the include directory "gtest" is
GTEST_INCLUDE_DIR?=$(GTEST_ROOT_DIR)googletest/include

# Paths pointing to where the libraries are
LIBS_DIR = $(GTEST_LIB_DIR) $(LIB)
LIBS_FLAG = $(addprefix -L, $(LIBS_DIR)) $(LIBS)

# Paths to include to the .h path
_HEADERS_FLAG = $(INCLUDE) $(GTEST_INCLUDE_DIR)
HEADERS_FLAG = $(addprefix -I, $(_HEADERS_FLAG))

_TESTS_SOURCE=$(addprefix $(TEST_DIR)/, $(TESTS))
TESTS_SOURCE=$(addsuffix .c, $(_TESTS_SOURCE))
TESTS_BIN = $(addprefix $(TEST_DIR)/bin/, $(TESTS))
TESTS_BIN_2 = : $(TESTS_BIN)

# The default target builds the .so library and all the tests
all: $(LIB_FULLNAME) build-tests bin

# The target that builds the standalone binaries
bin: $(BIN_EXES)

$(LIB_FULLNAME): $(OBJS)
	mkdir -p $(LIB)
	ar rcs $(LIB_FULLNAME) $(OBJS)

$(OBJ_DIR)/%.o: $(SRC)/%.c $(HEADERS)
	mkdir -p $(OBJ_DIR)
	$(CC) $(FLAGS) -c -o $@ $< $(HEADERS_FLAG)

$(BIN)/%: $(SRC)/%.c $(HEADERS) $(LIB_FULLNAME)
	mkdir -p $(BIN)
	$(CC) $(FLAGS) -c -o $(OBJ_DIR)/$*.o $< $(HEADERS_FLAG)
	$(CC) $(FLAGS) -o $@ $(OBJ_DIR)/$*.o $(HEADERS_FLAG) $(LIBS_FLAG) -l$(LIB_FINAL)

run-tests: build-tests
	LD_LIBRARY_PATH=$(LIB) $(foreach var,$(TESTS_BIN),./$(var) && ) :

build-tests: $(LIB_FULLNAME) $(TESTS_BIN) $(BIN_EXES)

$(TEST_DIR)/bin/%: $(TEST_DIR)/%.c $(HEADERS) $(SOURCES)
	mkdir -p $(TEST_DIR)/bin
	mkdir -p $(TEST_DIR)/obj
	$(CC) $(FLAGS) -c -o $(TEST_DIR)/obj/$*.o $< $(HEADERS_FLAG)
	$(CC) $(FLAGS) -o $@ $(TEST_DIR)/obj/$*.o $(HEADERS_FLAG) $(LIBS_FLAG) -l$(LIB_FINAL)

.PHONY: clean

clean:
	rm -rf $(OBJ_DIR)
	rm -rf $(TEST_DIR)/bin
	rm -rf $(TEST_DIR)/obj
	rm -rf $(LIB)
	rm -rf $(BIN)
	rm -rf *.gc*

