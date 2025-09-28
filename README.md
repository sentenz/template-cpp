# Template C++

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

Developer Experience (DX) encompasses the practices, tools, and workflows that streamline software development, ensuring consistency, automation, and maintainability across environments and teams.

- [1. Details](#1-details)
  - [1.1. Prerequisites](#11-prerequisites)
- [2. Usage](#2-usage)
  - [2.1. Build System](#21-build-system)
    - [2.1.1. CMake](#211-cmake)
  - [2.2. Package Manager](#22-package-manager)
    - [2.2.1. Conan](#221-conan)
  - [2.3. Compiler Cache](#23-compiler-cache)
    - [2.3.1. Ccache](#231-ccache)
  - [2.4. Test Framework](#24-test-framework)
    - [2.4.1. GTest](#241-gtest)
    - [2.4.2. Code Coverage](#242-code-coverage)
    - [2.4.3. Sanitizers](#243-sanitizers)
  - [2.5. Secret Manager](#25-secret-manager)
    - [2.5.1. SOPS](#251-sops)
  - [2.6. Task Runner](#26-task-runner)
    - [2.6.1. Makefile](#261-makefile)
- [3. Troubleshoot](#3-troubleshoot)
  - [3.1. TODO](#31-todo)
- [4. References](#4-references)

## 1. Details

### 1.1. Prerequisites

## 2. Usage

### 2.1. Build System

#### 2.1.1. CMake

CMake is a cross-platform, compiler-independent, open-source build system that manages the build process.

- [CMake](https://cmake.org/)
  > CMake is an open-source, cross-platform family of tools designed to build, test and package software.

- [CMakeLists.txt](CMakeLists.txt)
  > The CMake build system configuration file.

- [CMakePresets.json](CMakePresets.json)
  > CMake presets for configuring and building the project.

### 2.2. Package Manager

#### 2.2.1. Conan

Conan is a package manager for C and C++ that simplifies the process of managing dependencies and libraries.

- [Conan](https://conan.io/)
  > Conan nis a decentralized, open-source package manager for C and C++.

- [Conanfile.txt](Conanfile.txt)
  > The Conan package manager configuration file.

### 2.3. Compiler Cache

#### 2.3.1. Ccache

Ccache is a compiler cache that speeds up recompilation by caching previous compilations and detecting when the same compilation is being done again.

- [Ccache](https://ccache.dev/)
  > Ccache is a compiler cache that speeds up recompilation by caching previous compilations and detecting when the same compilation is being done again.

  ```bash
  # Example: Using ccache with gcc
  export CC="ccache gcc"
  export CXX="ccache g++"
  ```

### 2.4. Test Framework

#### 2.4.1. GTest

Google Test (GTest) is a unit testing framework for C++.

- [GTest](https://github.com/google/googletest)
  > Google Test is a unit testing library for the C++ programming language, based on the xUnit architecture.

#### 2.4.2. Code Coverage

Code coverage is a measure used to describe the degree to which the source code of a program is executed when a particular test suite runs.

- [gcovr](https://gcovr.com/en/stable/)
  > Gcovr is a Python tool that provides a utility for managing and generating code coverage reports.

#### 2.4.3. Sanitizers

Sanitizers are runtime tools that detect various types of bugs in C/C++ programs, such as memory errors and undefined behavior.

- [AddressSanitizer (ASan)](https://clang.llvm.org/docs/AddressSanitizer.html)
  > AddressSanitizer is a fast memory error detector.

- [UndefinedBehaviorSanitizer (UBSan)](https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html)
  > UndefinedBehaviorSanitizer is a fast undefined behavior detector.

- [ThreadSanitizer (TSan)](https://clang.llvm.org/docs/ThreadSanitizer.html)
  > hreadSanitizer is a tool that detects data races.

### 2.5. Secret Manager

#### 2.5.1. SOPS

1. GPG Key Pair Generation

    - Task Runner
      > Generate a new key pair to be used with SOPS.

      > [!NOTE]
      > The UID can be customized via the `SOPS_UID` variable (defaults to `sops-dx`).

      ```sh
      make secret-gpg-generate SOPS_UID=<uid>
      ```

2. GPG Public Key Fingerprint

    - Task Runner
      > Print the  GPG Public Key fingerprint associated with a given UID.

      ```sh
      make secret-gpg-show SOPS_UID=<uid>
      ```

    - [.sops.yaml](.sops.yaml)
      > The GPG UID is required for populating in `.sops.yaml`.

      ```yaml
      creation_rules:
        - pgp: "<fingerprint>" # <uid>
      ```

3. SOPS Encrypt/Decrypt

    - Task Runner
      > Encrypt/decrypt one or more files in place using SOPS.

      ```sh
      make secret-sops-encrypt <files>
      make secret-sops-decrypt <files>
      ```

### 2.6. Task Runner

#### 2.6.1. Makefile

- [Makefile](Makefile)
  > The Makefile serves as the task runner.

  > [!NOTE]
  > - Run the `make help` command in the terminal to list the tasks used for the project.
  > - Targets **must** have a leading comment line starting with `##` to be included in the task list.

  ```plaintext
  $ make help

  Tasks
          A collection of tasks used in the current project.

  Usage
          make <task>

          bootstrap              Initialize a software development workspace with requisites
          setup                  Install and configure all dependencies essential for development
          teardown               Remove development artifacts and restore the host to its pre-setup state
          secret-gpg-generate    Generate a new GPG key pair for SOPS
          secret-gpg-show        Print the GPG key fingerprint for SOPS (.sops.yaml)
          secret-gpg-remove      Remove an existing GPG key for SOPS (interactive)
          secret-sops-encrypt    Encrypt file using SOPS
          secret-sops-decrypt    Decrypt file using SOPS
          secret-sops-view       View a file encrypted with SOPS
  ```

## 3. Troubleshoot

### 3.1. TODO

TODO

## 4. References

- GitHub [Template DX](https://github.com/sentenz/template-dx) repository.
- GitHub [Template C++](https://github.com/sentenz/template-cpp) repository.
