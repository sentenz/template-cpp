# AGENTS.md

This file provides instructions for AI coding agents working with this C++ project.

- [1. Tech Stack](#1-tech-stack)
  - [1.1. C/C++](#11-cc)
- [2. Project Structure](#2-project-structure)

## 1. Tech Stack

### 1.1. C/C++

1. Programming & Scripting

    - [x] C
      > Standard C11/C17 is used for low-level programming and hardware interfacing.

    - [x] C++
      > Standard C++17 is utilized to leverage modern object-oriented and functional programming features while maintaining compatibility.

2. Build Systems

    - [x] [CMake](https://cmake.org)
      > Cross-platform build-system generator. Preferred for modern C/C++ projects; integrates with multiple toolchains and CI systems.

    - [x] [Ninja](https://ninja-build.org)
      > Lightweight, fast build backend used as CMake's primary generator for improved build performance.

3. Cache Manager

    - [x] [sccache](https://github.com/mozilla/sccache)
      > A shared/remote compilation cache for distributed builds with Rust and C/C++ support.

4. Dependency Manager

    - [x] [Conan](https://github.com/conan-io/conan)
      > A decentralized, cross-platform C/C++ package manager for dependency resolution, binary distribution, and reproducible builds.

5. Compilers & Toolchains

    - [x] GNU Compiler Collection (GCC)
      > GCC is a compiler system supporting various programming languages for compiling C and C++ code on Unix-like systems.

6. Analysis

    - [x] [Clang-Format](https://clang.llvm.org/docs/ClangFormat.html)
      > A tool to automatically format C/C++ code according to a set of rules and style guides.

    - [x] [Sanitizers](https://clang.llvm.org/docs/AddressSanitizer.html)
      > A suite of runtime tools to detect various types of bugs, including memory errors (AddressSanitizer), undefined behavior (UndefinedBehaviorSanitizer), and thread data races (ThreadSanitizer).

7. Test Framework

    - [x] [GoogleTest](https://google.github.io/googletest/)
      > GoogleTest (gtest/gmock) is a testing framework for C++, providing a rich set of features for unit testing and test-driven development.

    - [ ] [Google FuzzTest](https://github.com/google/fuzztest)
      > A library for coverage-guided fuzz testing of C++ code, integrated with GoogleTest. It is used to discover and exploit software vulnerabilities by generating random inputs.

    - [ ] [Google Benchmark](https://github.com/google/benchmark)
      > A microbenchmark support library for GoogleTest. It is used to add performance benchmarks to tests.

    - [x] [CTest](https://cmake.org/cmake/help/latest/manual/ctest.1.html#)
      > A testing tool integrated with CMake, primarily used for running tests and ensuring code quality across builds.

    - [x] [gcov](https://gcc.gnu.org/onlinedocs/gcc/Gcov.html)
      > A test coverage program used to analyze and create code coverage reports for C/C++ programs.

8. Documentation

    - [x] [Doxygen](https://www.doxygen.nl/)
      > Doxygen is a open-source API documentation generator for various programming languages, including C++. It extracts structured comments from source code and generates documentation in multiple formats such as HTML, LaTeX, and XML.

9. Repository Strategy

    - [x] Modular Monolith
      > The Modular Monolith organizes a single application into distinct, self-contained modules within one repository.

10. Conventions & Style Guides

    - [x] [Google C++ Style Guide](https://google.github.io/styleguide/cppguide.html)
      > The Google C++ Style Guide is adopted as the primary coding style guide for consistency and readability.

    - [x] [Microsoft CMake Style Guide](https://learn.microsoft.com/en-us/vcpkg/contributing/cmake-guidelines)
      > Guidelines for writing clear, portable, and maintainable CMake scripts, including target-based patterns, recommended project layout, and best practices.

## 2. Project Structure

```plaintext
.
├── src
├── tests
├── scripts
├── tools
├── build
├── logs
├── CMakeLists.txt
├── CMakePresets.json
├── Makefile
├── LICENSE
├── CODEOWNERS
├── AGENTS.md
└── README.md
```
