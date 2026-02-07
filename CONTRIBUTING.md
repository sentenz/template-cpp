# Contributing

Contribution guidelines and project management tools.

- [1. AI Agents](#1-ai-agents)
- [2. Skills Manager](#2-skills-manager)
  - [2.1. Skills CLI](#21-skills-cli)
- [3. Task Runner](#3-task-runner)
  - [3.1. Make](#31-make)
- [4. Bootstrap](#4-bootstrap)
  - [4.1. Scripts](#41-scripts)
- [5. Dev Containers](#5-dev-containers)
- [6. Build System](#6-build-system)
  - [6.1. CMake](#61-cmake)
- [7. Dependency Manager](#7-dependency-manager)
  - [7.1. Conan](#71-conan)
- [8. Software Testing](#8-software-testing)
  - [8.1. Unit Testing](#81-unit-testing)
  - [8.2. Code Coverage](#82-code-coverage)
  - [8.3. Sanitizers](#83-sanitizers)
- [9. Cache Manager](#9-cache-manager)
  - [9.1. Compiler Cache](#91-compiler-cache)
- [10. Release Manager](#10-release-manager)
  - [10.1. Semantic-Release](#101-semantic-release)
- [11. Update Manager](#11-update-manager)
  - [11.1. Renovate](#111-renovate)
  - [11.2. Dependabot](#112-dependabot)
- [12. Secrets Manager](#12-secrets-manager)
  - [12.1. SOPS](#121-sops)
- [13. Container Manager](#13-container-manager)
  - [13.1. Docker](#131-docker)
- [14. Policy Manager](#14-policy-manager)
  - [14.1. Conftest](#141-conftest)
- [15. Supply Chain Manager](#15-supply-chain-manager)
  - [15.1. Trivy](#151-trivy)
- [16. Documentation Generators](#16-documentation-generators)
  - [16.1. Doxygen](#161-doxygen)

## 1. AI Agents

AI Agents are automated tools that assist in various development tasks such as code generation, testing, and documentation.

1. Insights and Details

    - [AGENTS.md](AGENTS.md)
      > Instructions for AI coding agents working with the project.

    - [.agents/skills/](.agents/skills/)
      > Directory containing AI agent skill definitions and configurations.

2. Usage and Instructions

    - Implicit Invocation
      > AI Agents can be implicitly invoked based on file paths, programming languages, or specific keywords in user prompts.

      ```plaintext
      .agents/skills/<skill-name>/SKILL.md
      ```

    - Explicit Invocation
      > AI Agents can be explicitly invoked by specifying the skill name in user prompts.

      ```plaintext
      @agent <skill-name> <task-description>
      ```

## 2. Skills Manager

### 2.1. Skills CLI

[Skills CLI](https://skills.sh/) is a command-line tool for managing AI agent skills in development projects.

1. Insights and Details

    - [Sentenz Skills](https://github.com/sentenz/skills)
      > Reusable AI agent skills for various development tasks.

2. Usage and Instructions

    - Tasks

      ```bash
      make skills-add
      ```

      ```bash
      make skills-update
      ```

## 3. Task Runner

### 3.1. Make

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

## 4. Bootstrap

### 4.1. Scripts

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

## 5. Dev Containers

1. Insights and Details

    - [.devcontainer/](.devcontainer/README.md)
      > Provides Dev Containers as a consistent development environment using Docker containers.

2. Usage and Instructions

    - Tasks

      ```bash
      # TODO
      # make devcontainer-cpp
      ```

## 6. Build System

### 6.1. CMake

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

## 7. Dependency Manager

### 7.1. Conan

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

## 8. Software Testing

### 8.1. Unit Testing

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

### 8.2. Code Coverage

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

### 8.3. Sanitizers

[Clang Sanitizers](https://clang.llvm.org/docs/) are a set of runtime tools to detect memory errors (MemorySanitizer), undefined behavior (UndefinedBehaviorSanitizer) or thread issues (ThreadSanitizer) in C/C++ programs.

1. Insights and Details

    - [meta_sanitizers.cmake](tools/cmake/meta_sanitizers.cmake)
      > CMake module to integrate Clang Sanitizers into the build system.

      ```cmake
      include(meta_sanitizers)
      meta_sanitizers(ENABLE ON)
      ```

## 9. Cache Manager

### 9.1. Compiler Cache

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

## 10. Release Manager

### 10.1. Semantic-Release

[Semantic-Release](https://github.com/semantic-release/semantic-release) automates the release process by analyzing commit messages to determine the next version number, generating changelog and release notes, and publishing the release.

1. Insights and Details

    - [.releaserc.json](.releaserc.json)
      > Configuration file for Semantic-Release specifying release rules and plugins.

2. Usage and Instructions

    - CI/CD

      ```yaml
      uses: sentenz/actions/semantic-release@latest
      ```

## 11. Update Manager

### 11.1. Renovate

[Renovate](https://github.com/renovatebot/renovate) automates dependency updates by creating merge requests for outdated dependencies, libraries and packages.

1. Insights and Details

    - [renovate.json](renovate.json)
      > Configuration file for Renovate specifying update rules and schedules.

2. Usage and Instructions

    - CI/CD

      ```yaml
      uses: sentenz/actions/renovate@latest
      ```

### 11.2. Dependabot

[Dependabot](https://github.com/dependabot/dependabot-core) automates dependency updates by creating pull requests for outdated dependencies, libraries and packages.

1. Insights and Details

    - [.github/dependabot.yml](.github/dependabot.yml)
      > Configuration file for Dependabot specifying update rules and schedules.

## 12. Secrets Manager

### 12.1. SOPS

[SOPS (Secrets OPerationS)](https://github.com/getsops/sops) is a tool for managing and encrypting sensitive data such as passwords, API keys, and other secrets.

1. Insights and Details

    - [.sops.yaml](.sops.yaml)
      > Configuration file for SOPS specifying encryption rules and key management.

2. Usage and Instructions

    - GPG Key Pair Generation

      - Tasks
        > Generate a new key pair to be used with SOPS.

        > [!NOTE]
        > The UID can be customized via the `SECRETS_SOPS_UID` variable (defaults to `sops-dx`).

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

## 13. Container Manager

### 13.1. Docker

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

## 14. Policy Manager

### 14.1. Conftest

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
      make policy-regal-lint <filepath>
      ```

      ```bash
      make policy-conftest-test <filepath>
      ```

## 15. Supply Chain Manager

### 15.1. Trivy

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

## 16. Documentation Generators

### 16.1. Doxygen

[Doxygen](https://www.doxygen.nl/) is an **API Documentation Generator** for C++, C programming languages, used to create software reference documentation from annotated source code.

1. Insights and Details

    - [Doxyfile](Doxyfile)
      > Configuration file for Doxygen specifying documentation generation settings.

2. Usage and Instructions

    - CI/CD

      ```yaml
      uses: sentenz/actions/doxygen@latest
      ```

    - Tasks

      ```bash
      make pages-doxygen-generate
      ```

      ```bash
      make pages-doxygen-server
      ```
