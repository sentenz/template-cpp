# Template DX

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![CMake](https://img.shields.io/badge/CMake-3.28+-blue.svg)](https://cmake.org/)
[![Conan](https://img.shields.io/badge/Conan-2.21+-blue.svg)](https://conan.io/)
[![Semantic Release](https://img.shields.io/badge/semantic--release-enabled-brightgreen.svg)](https://semantic-release.gitbook.io/semantic-release/)
[![Renovate Enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![SOPS Enabled](https://img.shields.io/badge/sops-enabled-brightgreen.svg)](https://github.com/mozilla/sops)
[![Conftest Enabled](https://img.shields.io/badge/conftest-enabled-brightgreen.svg)](https://www.conftest.dev/)

A modular C++ project using a component-based architecture, with CMake as the build system and Conan for dependency management.

- [1. Details](#1-details)
  - [1.1. Prerequisites](#11-prerequisites)
- [2. Contribute](#2-contribute)
  - [2.1. Task Runner](#21-task-runner)
    - [2.1.1. Make](#211-make)
  - [2.2. Bootstrap](#22-bootstrap)
    - [2.2.1. Scripts](#221-scripts)
  - [2.3. Dev Containers](#23-dev-containers)
  - [2.4. Build System](#24-build-system)
    - [2.4.1. CMake](#241-cmake)
  - [2.5. Dependency Manager](#25-dependency-manager)
    - [2.5.1. Conan](#251-conan)
  - [2.6. Software Testing](#26-software-testing)
    - [2.6.1. Unit Testing](#261-unit-testing)
    - [2.6.2. Code Coverage](#262-code-coverage)
    - [2.6.3. Sanitizers](#263-sanitizers)
  - [2.7. Cache Manager](#27-cache-manager)
    - [2.7.1. Ccache](#271-ccache)
  - [2.8. Release Manager](#28-release-manager)
    - [2.8.1. Semantic-Release](#281-semantic-release)
  - [2.9. Update Manager](#29-update-manager)
    - [2.9.1. Renovate](#291-renovate)
  - [2.10. Secrets Manager](#210-secrets-manager)
    - [2.10.1. SOPS](#2101-sops)
  - [2.11. Container Manager](#211-container-manager)
    - [2.11.1. Docker](#2111-docker)
  - [2.12. Policy Manager](#212-policy-manager)
    - [2.12.1. Conftest](#2121-conftest)
- [3. Troubleshoot](#3-troubleshoot)
  - [3.1. TODO](#31-todo)
- [4. References](#4-references)

## 1. Details

### 1.1. Prerequisites

- [C++](https://isocpp.org/)
  > The C++ programming language (ISO/IEC C++17 standard) for software development.

- [GCC GNU](https://gcc.gnu.org/)
  > GCC (GNU Compiler Collection) for compiling C and C++ code.

- [CMake](https://cmake.org/)
  > Cross-platform build system generator to manage the build process of software projects.

## 2. Contribute

Contribution guidelines and project management tools.

### 2.1. Task Runner

#### 2.1.1. Make

[Make](https://www.gnu.org/software/make/) is a automation tool that defines and manages tasks to streamline development workflows.

1. Insights and Details

    - [Makefile](Makefile)
      > Makefile defining tasks for building, testing, and managing the project.

2. Usage and Instructions

    - Tasks

      ```bash
      make help
      ```

      > [!NOTE]
      > - Each task description must begin with `##` to be included in the task list.

      ```plaintext
      $ make help

      Tasks
              A collection of tasks used in the current project.

      Usage
              make <task>

              bootstrap         Initialize a software development workspace with requisites
              setup             Install and configure all dependencies essential for development
              teardown          Remove development artifacts and restore the host to its pre-setup state
      ```

### 2.2. Bootstrap

#### 2.2.1. Scripts

[scripts/](scripts/README.md) provides scripts to bootstrap, setup, and teardown a software development workspace with requisites.

1. Insights and Details

    - [bootstrap.sh](scripts/bootstrap.sh)
      > Initializes a software development workspace with requisites.

    - [setup.sh](scripts/setup.sh)
      > Installs and configures all dependencies essential for development.

    - [teardown.sh](scripts/teardown.sh)
      > Removes development artifacts and restores the host to its pre-setup state.

2. Usage and Instructions

    - Tasks

      ```bash
      make bootstrap
      ```

      ```bash
      make setup
      ```

      ```bash
      make teardown
      ```

### 2.3. Dev Containers

[.devcontainer/](.devcontainer/README.md) provides Dev Containers as a consistent development environment using Docker containers.

1. Insights and Details

    - [cpp/](.devcontainer/cpp/)
      > Dev Container configuration for C++ development environment.

      ```json
      // ...
      "postCreateCommand": "sudo make bootstrap && sudo make setup",
      // ...
      ```

      > [!NOTE]
      > The `devcontainer.json` runs the `bootstrap` and `setup` tasks to initialize and configure the development environment.

2. Usage and Instructions

    - Tasks

      ```bash
      # TODO
      # make devcontainer-cpp
      ```

### 2.4. Build System

#### 2.4.1. CMake

[CMake](https://cmake.org/) is a cross-platform, compiler-independent, open-source build system that manages the build process.

1. Insights and Details

    - [CMakeLists.txt](CMakeLists.txt)
      > The CMake build system configuration file.

    - [CMakePresets.json](CMakePresets.json)
      > CMake presets for configuring and building the project.

2. Usage and Instructions

    - CI/CD

      ```yaml
      # TODO
      ```

    - Tasks

      ```bash
      make cmake-gcc-debug-build
      ```

      ```bash
      make cmake-gcc-release-build
      ```

### 2.5. Dependency Manager

#### 2.5.1. Conan

[Conan](https://conan.io/) is a package manager for C and C++ that simplifies the process of managing dependencies and libraries.

1. Insights and Details

    - [Conanfile.txt](Conanfile.txt)
      > The Conan package manager configuration file.

    - [conan.cmake](tools/cmake/meta_conan.cmake)
      > CMake module to integrate Conan into the build system.

      ```cmake
      include(conan)
      conan()
      ```

### 2.6. Software Testing

#### 2.6.1. Unit Testing

[Google Test (GTest)](https://github.com/google/googletest) is a unit testing library for the C++ programming language.

1. Insights and Details

    - [gtest.cmake](tools/cmake/meta_gtest.cmake)
      > CMake module to integrate Google Test into the build system.

      ```cmake
      include(gtest)
      gtest(...)
      ```

    - [AGENTS.md](./AGENTS.md)
      > Automate unit test generation using Large Language Models (LLMs) Agents.

2. Usage and Instructions

    - CI/CD

      ```yaml
      # TODO
      ```

    - Tasks

      ```bash
      make cmake-gcc-test-unit-run
      ```

#### 2.6.2. Code Coverage

[gcovr](https://gcovr.com/en/stable/) is a Python tool that provides a utility for managing and generating code coverage reports.

1. Insights and Details

    - [coverage.cmake](tools/cmake/meta_coverage.cmake)
      > CMake module to integrate code coverage analysis into the build system.

      ```cmake
      include(coverage)
      coverage(ENABLE ON)
      ```

2. Usage and Instructions

    - CI/CD

      ```yaml
      # TODO
      ```

    - Tasks

      ```bash
      make cmake-gcc-test-unit-coverage
      ```

#### 2.6.3. Sanitizers

[Clang Sanitizers](https://clang.llvm.org/docs/) are a set of runtime tools to detect memory errors (MemorySanitizer), undefined behavior (UndefinedBehaviorSanitizer) or thread issues (ThreadSanitizer) in C/C++ programs.

1. Insights and Details

    - [sanitizers.cmake](tools/cmake/meta_sanitizers.cmake)
      > CMake module to integrate Clang Sanitizers into the build system.

      ```cmake
      include(sanitizers)
      sanitizers(ENABLE ON)
      ```

### 2.7. Cache Manager

#### 2.7.1. Ccache

[Ccache](https://ccache.dev/) is a compiler cache that speeds up recompilation by caching previous compilations and detecting when the same compilation is being done again.

1. Insights and Details

    - [ccache.cmake](tools/cmake/meta_ccache.cmake)
      > CMake module to integrate Ccache into the build system.

      ```cmake
      include(ccache)
      ccache(ENABLE ON)
      ```

### 2.8. Release Manager

#### 2.8.1. Semantic-Release

[Semantic-Release](https://github.com/semantic-release/semantic-release) automates the release process by analyzing commit messages to determine the next version number, generating changelog and release notes, and publishing the release.

1. Insights and Details

    - [.releaserc.json](.releaserc.json)
      > Configuration file for Semantic-Release specifying release rules and plugins.

2. Usage and Instructions

    - CI/CD

      ```yaml
      uses: sentenz/actions/semantic-release@latest
      ```

### 2.9. Update Manager

#### 2.9.1. Renovate

[Renovate](https://github.com/renovatebot/renovate) automates dependency updates by creating merge requests for outdated dependencies, ensuring that projects stay up-to-date with the latest versions of libraries and packages.

1. Insights and Details

    - [renovate.json](renovate.json)
      > Configuration file for Renovate specifying update rules and schedules.

2. Usage and Instructions

    - CI/CD

      ```yaml
      uses: sentenz/actions/renovate@latest
      ```

### 2.10. Secrets Manager

#### 2.10.1. SOPS

[SOPS (Secrets OPerationS)](https://github.com/getsops/sops) is a tool for managing and encrypting sensitive data such as passwords, API keys, and other secrets.

1. Insights and Details

    - [.sops.yaml](.sops.yaml)
      > Configuration file for SOPS specifying encryption rules and key management.

2. Usage and Instructions

    - GPG Key Pair Generation

      - Tasks
        > Generate a new key pair to be used with SOPS.

        > [!NOTE]
        > The UID can be customized via the `SECRETS_SOPS_UID` variable (defaults to `sops-c++`).

        ```bash
        make secrets-gpg-generate SECRETS_SOPS_UID=<uid>
        ```

    - GPG Public Key Fingerprint

      - Tasks
        > Print the  GPG Public Key fingerprint associated with a given UID.

        ```bash
        make secrets-gpg-show SECRETS_SOPS_UID=<uid>
        ```

      - [.sops.yaml](.sops.yaml)
        > The GPG UID is required for populating in `.sops.yaml`.

        ```yaml
        creation_rules:
          - pgp: "<fingerprint>" # <uid>
        ```

    - SOPS Encrypt/Decrypt

      - Tasks
        > Encrypt/decrypt one or more files in place using SOPS.

        ```bash
        make secrets-sops-encrypt <files>
        ```

        ```bash
        make secrets-sops-decrypt <files>
        ```

### 2.11. Container Manager

#### 2.11.1. Docker

[Docker](https://github.com/docker) containerization tool to run applications in isolated container environments and execute container-based tasks.

1. Insights and Details

    - [Dockerfile](Dockerfile)
      > Dockerfile defining the container image for the project.

2. Usage and Instructions

    - CI/CD

      ```yaml
      # TODO
      ```

    - Tasks

      ```bash
      # TODO
      ```

### 2.12. Policy Manager

#### 2.12.1. Conftest

[Conftest](https://www.conftest.dev/) is a **Policy as Code (PaC)** tool to streamline policy management for improved development, security and audit capability.

1. Insights and Details

    - [conftest.toml](conftest.toml)
      > Configuration file for Conftest specifying policy paths and output formats.

    - [tests/policy](tests/policy/)
      > Directory contains Rego policies for Conftest to enforce best practices and compliance standards.

2. Usage and Instructions

    - CI/CD

      ```yaml
      uses: sentenz/actions/regal@latest
      ```

      ```yaml
      uses: sentenz/actions/conftest@latest
      ```

    - Tasks

      ```bash
      make policy-lint-regal <filepath>
      ```

      ```bash
      make policy-analysis-conftest <filepath>
      ```

## 3. Troubleshoot

### 3.1. TODO

TODO

## 4. References

- GitHub [Template DX](https://github.com/sentenz/template-dx) repository.
- GitHub [Template C++](https://github.com/sentenz/template-cpp) repository.
- Sentenz [Manager Tools](https://github.com/sentenz/convention/issues/392) article.
