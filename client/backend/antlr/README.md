# ANTLR - build lexer/parser and check cypher queries

## 0. Prerequisite
* Java 11
* CMake 3.16.3+
* g++ 9.4.0

## 1. Build the antlr project
Execute setup.sh, it will:
1. Download antlr-4.13.0-complete.jar
2. Use CMake to generate Makefile for the c++ project
3. use Make to compile and generate the binary**.
``` bash
bash ./setup.sh
```

## 2. Test the binary
After step 1, binary file (grammarCheck) will be created under `build/`. The same binary will be copied under `project/` for later use (called by the client).

Before using the client to test the whole grammar-checking procedure, one can run the test script to pass cypher queries into the grammar checker.
``` bash
bash ./test.sh
```

## 3. Reference
Antrl CMake
* https://github.com/antlr/antlr4/tree/master/runtime/Cpp/cmake
* https://github.com/gabriele-tomassetti/antlr-cpp/tree/master
* https://stackoverflow.com/questions/72688711/anltr4-cpp-demo-fails-to-run-because-of-a-gthread-problem