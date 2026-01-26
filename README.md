# Template C++

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![CMake](https://img.shields.io/badge/dynamic/regex?url=https%3A%2F%2Fraw.githubusercontent.com%2Fsentenz%2Ftemplate-cpp%2Fmain%2FCMakeLists.txt&label=CMake&search=%28%5B0-9%5D%2B%5C.%5B0-9%5D%2B%5C.%5B0-9%5D%2B%29&color=blue&logo=cmake)](https://cmake.org/)

A modular C++ project using a component-based architecture, with CMake as the build system and Conan for dependency management.

- [1. Details](#1-details)
  - [1.1. Prerequisites](#11-prerequisites)
- [2. Contribute](#2-contribute)
  - [2.1. AI Agents](#21-ai-agents)
  - [2.2. Task Runner](#22-task-runner)
    - [2.2.1. Make](#221-make)
  - [2.3. Bootstrap](#23-bootstrap)
    - [2.3.1. Scripts](#231-scripts)
  - [2.4. Dev Containers](#24-dev-containers)
  - [2.5. Build System](#25-build-system)
    - [2.5.1. CMake](#251-cmake)
  - [2.6. Dependency Manager](#26-dependency-manager)
    - [2.6.1. Conan](#261-conan)
  - [2.7. Software Testing](#27-software-testing)
    - [2.7.1. Unit Testing](#271-unit-testing)
    - [2.7.2. Code Coverage](#272-code-coverage)
    - [2.7.3. Sanitizers](#273-sanitizers)
  - [2.8. Cache Manager](#28-cache-manager)
    - [2.8.1. Compiler Cache](#281-compiler-cache)
  - [2.9. Release Manager](#29-release-manager)
    - [2.9.1. Semantic-Release](#291-semantic-release)
  - [2.10. Update Manager](#210-update-manager)
    - [2.10.1. Renovate](#2101-renovate)
    - [2.10.2. Dependabot](#2102-dependabot)
  - [2.11. Secrets Manager](#211-secrets-manager)
    - [2.11.1. SOPS](#2111-sops)
  - [2.12. Container Manager](#212-container-manager)
    - [2.12.1. Docker](#2121-docker)
  - [2.13. Policy Manager](#213-policy-manager)
    - [2.13.1. Conftest](#2131-conftest)
  - [2.14. Supply Chain Manager](#214-supply-chain-manager)
    - [2.14.1. Trivy](#2141-trivy)
- [3. Troubleshoot](#3-troubleshoot)
  - [3.1. TODO](#31-todo)
- [4. References](#4-references)

## 1. Details

### 1.1. Prerequisites

- [Git](https://git-scm.com/)
  > Distributed version control system for tracking source code changes.

- [Git LFS](https://git-lfs.com/)
  > Git extension for managing large files (assets, binaries) outside normal Git history.

- [Make](https://www.gnu.org/software/make/)
  > Task automation tool to manage build processes and workflows.

## 2. Contribute

Contribution guidelines and project management tools.

### 2.1. AI Agents

AI Agents are automated tools that assist in various development tasks such as code generation, testing, and documentation.

1. Insights and Details

    - [AGENTS.md](AGENTS.md)
      > Instructions for AI coding agents working with the project.

    - [SKILLS.md](.github/skills/README.md)
      > Instructions for AI agent skills used in the project.

### 2.2. Task Runner

#### 2.2.1. Make

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

### 2.3. Bootstrap

#### 2.3.1. Scripts

1. Insights and Details

    - [scripts/](scripts/README.md)
      > Provides scripts to bootstrap, setup, and teardown a software development workspace with requisites.

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

### 2.4. Dev Containers

1. Insights and Details

    - [.devcontainer/](.devcontainer/README.md)
      > Provides Dev Containers as a consistent development environment using Docker containers.

2. Usage and Instructions

    - Tasks

      ```bash
      # TODO
      # make devcontainer-cpp
      ```

### 2.5. Build System

#### 2.5.1. CMake

[CMake](https://cmake.org/) is a cross-platform, compiler-independent, open-source build system that manages the build process.

1. Insights and Details

    - [CMakeLists.txt](CMakeLists.txt)
      > The CMake build system configuration file.

    - [CMakePresets.json](CMakePresets.json)
      > CMake presets for configuring and building the project.

    - [CMake Modules](tools/cmake/)
      > CMake modules to streamline the build system.

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

### 2.6. Dependency Manager

#### 2.6.1. Conan

[Conan](https://conan.io/) is a package manager for C and C++ that simplifies the process of managing dependencies and libraries.

1. Insights and Details

    - [conanfile.txt](conanfile.txt)
      > The Conan package manager configuration file.

    - [conan.lock](conan.lock)
      > The Conan lock file to ensure reproducible builds.

    - [meta_conan.cmake](tools/cmake/meta_conan.cmake)
      > CMake module to integrate Conan into the build system.

      ```cmake
      include(meta_conan)
      meta_conan()
      ```

### 2.7. Software Testing

#### 2.7.1. Unit Testing

[Google Test (GTest)](https://github.com/google/googletest) is a unit testing library for the C++ programming language.

1. Insights and Details

    - [meta_gtest.cmake](tools/cmake/meta_gtest.cmake)
      > CMake module to integrate Google Test into the build system.

      ```cmake
      include(meta_gtest)
      meta_gtest(ENABLE ON ...)
      ```

2. Usage and Instructions

    - CI/CD

      ```yaml
      # TODO
      ```

    - Tasks

      ```bash
      make cmake-gcc-test-unit-run
      ```

    - AI Agents
      > Instruct Agent Skills capabilities to to perform [Unit Testing](.github/skills/unit-testing/SKILL.md) tasks.

#### 2.7.2. Code Coverage

[gcovr](https://gcovr.com/en/stable/) is a Python tool that provides a utility for managing and generating code coverage reports.

1. Insights and Details

    - [meta_coverage.cmake](tools/cmake/meta_coverage.cmake)
      > CMake module to integrate code coverage analysis into the build system.

      ```cmake
      include(meta_coverage)
      meta_coverage(ENABLE ON)
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

#### 2.7.3. Sanitizers

[Clang Sanitizers](https://clang.llvm.org/docs/) are a set of runtime tools to detect memory errors (MemorySanitizer), undefined behavior (UndefinedBehaviorSanitizer) or thread issues (ThreadSanitizer) in C/C++ programs.

1. Insights and Details

    - [meta_sanitizers.cmake](tools/cmake/meta_sanitizers.cmake)
      > CMake module to integrate Clang Sanitizers into the build system.

      ```cmake
      include(meta_sanitizers)
      meta_sanitizers(ENABLE ON)
      ```

### 2.8. Cache Manager

#### 2.8.1. Compiler Cache

[Ccache](https://ccache.dev/) and [sccache](https://github.com/mozilla/sccache) are compiler caches that speed up recompilation by caching previous compilations and detecting when the same compilation is being done again.

1. Insights and Details

    - [meta_compiler_cache.cmake](tools/cmake/meta_compiler_cache.cmake)
      > CMake module to integrate compiler caching (ccache or sccache) into the build system.

      ```cmake
      include(meta_compiler_cache)
      meta_compiler_cache(ENABLE ON TYPE auto)
      meta_compiler_cache(ENABLE ON TYPE ccache)
      meta_compiler_cache(ENABLE ON TYPE sccache)
      ```

### 2.9. Release Manager

#### 2.9.1. Semantic-Release

[Semantic-Release](https://github.com/semantic-release/semantic-release) automates the release process by analyzing commit messages to determine the next version number, generating changelog and release notes, and publishing the release.

1. Insights and Details

    - [.releaserc.json](.releaserc.json)
      > Configuration file for Semantic-Release specifying release rules and plugins.

2. Usage and Instructions

    - CI/CD

      ```yaml
      uses: sentenz/actions/semantic-release@latest
      ```

### 2.10. Update Manager

#### 2.10.1. Renovate

[Renovate](https://github.com/renovatebot/renovate) automates dependency updates by creating merge requests for outdated dependencies, libraries and packages.

1. Insights and Details

    - [renovate.json](renovate.json)
      > Configuration file for Renovate specifying update rules and schedules.

2. Usage and Instructions

    - CI/CD

      ```yaml
      uses: sentenz/actions/renovate@latest
      ```

#### 2.10.2. Dependabot

[Dependabot](https://github.com/dependabot/dependabot-core) automates dependency updates by creating pull requests for outdated dependencies, libraries and packages.

1. Insights and Details

    - [.github/dependabot.yml](.github/dependabot.yml)
      > Configuration file for Dependabot specifying update rules and schedules.

### 2.11. Secrets Manager

#### 2.11.1. SOPS

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

### 2.12. Container Manager

#### 2.12.1. Docker

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

### 2.13. Policy Manager

#### 2.13.1. Conftest

[Conftest](https://www.conftest.dev/) is a **Policy as Code (PaC)** tool to streamline policy management for improved development, security and audit capability.

1. Insights and Details

    - [conftest.toml](conftest.toml)
      > Configuration file for Conftest specifying policy paths and output formats.

    - [tests/policy/](tests/policy/)
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

### 2.14. Supply Chain Manager

#### 2.14.1. Trivy

[Trivy](https://github.com/aquasecurity/trivy) is a comprehensive security scanner for vulnerabilities, misconfigurations, and compliance issues in container images, filesystems, and source code.

1. Insights and Details

    - [trivy.yaml](trivy.yaml)
      > Configuration file for Trivy specifying scan settings and options.

    - [.trivyignore](.trivyignore)
      > File specifying vulnerabilities to ignore during Trivy scans.

2. Usage and Instructions

    - CI/CD

      ```yaml
      uses: sentenz/actions/trivy@latest
      ```

    - Tasks

      ```bash
      make sast-trivy-fs <path>
      ```

      ```bash
      make sast-trivy-sbom-cyclonedx-fs <path>
      ```

      ```bash
      make sast-trivy-sbom-scan <sbom_path>
      ```

      ```bash
      make sast-trivy-sbom-license <sbom_path>
      ```

## 3. Troubleshoot

### 3.1. TODO

TODO

## 4. References

- Sentenz [Template DX](https://github.com/sentenz/template-dx) repository.
- Sentenz [Template C++](https://github.com/sentenz/template-cpp) repository.
- Sentenz [Actions](https://github.com/sentenz/actions) repository.
- Sentenz [Manager Tools](https://github.com/sentenz/convention/issues/392) article.
