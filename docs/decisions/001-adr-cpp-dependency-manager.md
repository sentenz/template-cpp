# ADR C/C++ Dependency Manager

Architectural Decision Records (ADR) on the selection of a dependency manager for C/C++ projects.

- [1. State](#1-state)
- [2. Context](#2-context)
- [3. Decision](#3-decision)
  - [3.1. Conan](#31-conan)
- [4. Considered](#4-considered)
  - [4.1. Conan](#41-conan)
  - [4.2. vcpkg](#42-vcpkg)
  - [4.3. CPM.cmake](#43-cpmcmake)
- [5. Consequences](#5-consequences)
- [6. Implementation](#6-implementation)
- [7. References](#7-references)

## 1. State

- Author(s): sentenz
- Date: 2026-04-20
- Status: Accepted

## 2. Context

C and C++ projects lack a universally adopted dependency management solution, resulting in fragmented tooling across teams and platforms. Without a standardized dependency manager, maintaining consistent, reproducible builds across development machines, CI/CD pipelines, and target platforms is error-prone and labour-intensive. A dependency manager must handle both production and development dependencies, enforce pinned versions, support transitive dependency resolution, and integrate cleanly with the CMake-based build system used by this project.

1. Decision Drivers

    - Dependencies and Dev Dependencies
      > The tool must allow separate declaration of runtime (production) and development-only dependencies (e.g., test frameworks, benchmarking libraries) to keep the production artifact lean.

    - Dependency Resolution
      > The tool must automatically resolve, download, and configure direct and transitive dependencies, including conflict detection and version negotiation.

    - Dependency Pinning
      > The tool must support explicit version pinning for all dependencies to eliminate non-deterministic resolution across environments and over time.

    - Transitive Dependencies
      > The tool must resolve and manage the full dependency graph, including indirect dependencies pulled in by direct dependencies, and surface conflicts clearly.

    - Immutable Lockfiles
      > The tool must generate a machine-readable lockfile that captures the exact resolved dependency graph, enabling bit-for-bit reproducible installs.

    - Cross-Platform Support
      > The tool must run on Linux, macOS, and Windows and support cross-compilation scenarios so that the same dependency declarations work across all target platforms and toolchains.

    - Prebuilt Binary and Build from Source
      > The tool must support consuming prebuilt binaries when available for speed and fall back to building from source when binaries are unavailable or when custom build options are required.

    - CMake Integration
      > The tool must generate CMake-compatible artefacts (e.g., `CMakeDeps`, `CMakeToolchain`, or `find_package`-compatible config files) so that downstream CMake targets can consume dependencies without manual path configuration.

    - Reproducibility
      > Builds performed at any point in time from the same source tree and lockfile must produce identical artefacts, regardless of the state of the upstream package registry.

    - CI/CD
      > The tool must support headless, non-interactive operation in CI/CD pipelines, expose caching mechanisms for package binaries, and integrate with common CI systems without additional infrastructure.

    - Private and Public Dependencies
      > The tool must support both public registries and private or self-hosted package repositories so that proprietary or internal packages can be managed alongside open-source ones.

## 3. Decision

### 3.1. Conan

Conan is selected as the C/C++ dependency manager. It is the only option evaluated that fully satisfies all decision drivers: it separates regular from development dependencies via `[requires]` / `[tool_requires]`, generates native CMake integration files (`CMakeDeps`, `CMakeToolchain`), produces an immutable lockfile (`conan.lock`), and supports prebuilt binaries with a fallback to source builds. Its support for private Conan servers (Artifactory, self-hosted) and multi-platform cross-compilation profiles makes it suitable for enterprise and open-source projects alike.

1. Rationale

    - Dependencies and Dev Dependencies
      > Conan distinguishes production dependencies (`[requires]`) from tool/build-time dependencies (`[tool_requires]`), enabling a clean separation between runtime and development artefacts.

    - Dependency Resolution
      > Conan's SAT-solver-based resolver handles complex version graphs, detects conflicts, and supports version ranges and revisions.

    - Dependency Pinning
      > Exact versions are declared in `conanfile.txt` or `conanfile.py`; `conan.lock` pins the entire resolved graph to a specific revision, preventing unexpected upgrades.

    - Transitive Dependencies
      > Conan resolves and manages the full dependency graph, propagating include paths, link flags, and compiler settings through all layers of transitive dependencies.

    - Immutable Lockfiles
      > `conan.lock` captures the exact package reference (name, version, and revision) for every dependency, ensuring reproducible installs from the same lockfile at any future date.

    - Cross-Platform Support
      > Conan profile files abstract compiler, OS, architecture, and standard library settings, enabling the same `conanfile.txt` to target Linux, macOS, Windows, and cross-compilation scenarios without modification.

    - Prebuilt Binary and Build from Source
      > Conan first checks configured remote(s) for a matching prebuilt binary; if none is found, it transparently builds the package from source using the recipe, without user intervention.

    - CMake Integration
      > The `CMakeDeps` and `CMakeToolchain` generators produce first-class CMake config files and a toolchain file, allowing standard `find_package()` / `target_link_libraries()` usage with no manual path setup.

    - Reproducibility
      > Combining pinned versions in `conanfile.txt` with `conan.lock` and Conan's package revision system guarantees that every install produces the same binary artefacts.

    - CI/CD
      > Conan operates fully headlessly; its binary cache is file-system-based and integrates with any CI cache layer (GitHub Actions, GitLab CI, Jenkins). The `--lockfile` flag enforces the recorded graph in pipelines.

    - Private and Public Dependencies
      > Conan supports multiple configurable remotes (ConanCenter for public packages, JFrog Artifactory or a self-hosted Conan server for private packages) with per-remote authentication.

## 4. Considered

### 4.1. Conan

[Conan](https://conan.io/) is a decentralized, cross-platform C/C++ package manager focused on reproducible builds and binary distribution.

- Pros:

  - Dependencies and Dev Dependencies
    > Supports `[requires]` for runtime dependencies and `[tool_requires]` for build-time / dev-only tools, cleanly separating production from development artefacts.

  - Dependency Resolution
    > Uses a SAT-solver-based graph resolver that handles version ranges, revisions, conflicts, and complex transitive graphs reliably.

  - Dependency Pinning
    > Version pinning is native; `conanfile.txt` / `conanfile.py` declare exact versions, and `conan.lock` records every resolved revision.

  - Transitive Dependencies
    > Propagates all settings, options, and link flags through the full dependency graph automatically.

  - Immutable Lockfiles
    > `conan.lock` is a JSON-based lockfile that freezes every package reference and revision, guaranteeing identical installs at any point in time.

  - Cross-Platform Support
    > Profile system abstracts OS, compiler, architecture, and standard library, enabling multi-platform and cross-compilation workflows from the same recipe.

  - Prebuilt Binary and Build from Source
    > Transparently downloads prebuilt binaries from a remote or builds from source when no matching binary exists, without requiring recipe changes.

  - CMake Integration
    > First-class `CMakeDeps` and `CMakeToolchain` generators produce config files and toolchain files consumed directly by `find_package()` and `cmake --toolchain`.

  - Reproducibility
    > Combination of pinned versions, lockfiles, and package revisions delivers fully reproducible builds across environments and time.

  - CI/CD
    > Fully headless; file-system binary cache can be layered with CI caching (e.g., `actions/cache`); `--lockfile` flag enforces the recorded graph in pipelines.

  - Private and Public Dependencies
    > Supports multiple remotes with per-remote authentication; works with ConanCenter (public), JFrog Artifactory, and self-hosted Conan servers.

- Cons:

  - Setup Complexity
    > Requires installing Python and configuring profiles, remotes, and settings before first use, adding initial onboarding friction compared to header-only solutions.

  - Ecosystem Size
    > ConanCenter is smaller than vcpkg's curated port catalogue; some niche packages may not have a Conan recipe and must be authored.

  - Learning Curve
    > `conanfile.py` is a Python-based DSL that requires familiarity with both Conan concepts and Python for advanced use cases.

### 4.2. vcpkg

[vcpkg](https://vcpkg.io/) is a Microsoft-maintained C/C++ package manager with deep Visual Studio and CMake integration.

- Pros:

  - Dependency Resolution
    > Resolves and installs transitive dependencies automatically from a large curated port catalogue (over 2,000 ports).

  - CMake Integration
    > Toolchain file (`vcpkg.cmake`) enables transparent `find_package()` integration; CMake Presets can reference vcpkg's toolchain directly.

  - Cross-Platform Support
    > Supports Linux, macOS, and Windows; triplet system expresses target platform, architecture, and linkage type.

  - Prebuilt Binary and Build from Source
    > Binary caching (local or remote, e.g., GitHub Packages, Azure Artifacts) speeds up CI; falls back to source builds when no cached binary is available.

  - Reproducibility
    > `vcpkg.json` manifest with a `builtin-baseline` or explicit version overrides ensures reproducible dependency resolution.

- Cons:

  - Dependencies and Dev Dependencies
    > No first-class distinction between runtime and development-only dependencies; all packages are treated uniformly regardless of usage context.

  - Immutable Lockfiles
    > vcpkg generates a `vcpkg.json` manifest and optional `vcpkg-configuration.json` baseline, but does not produce a full lockfile capturing every resolved transitive dependency revision.

  - Private and Public Dependencies
    > Private registries are supported but require additional registry authoring effort; authentication for private feeds is more complex than Conan's remote configuration.

  - CI/CD
    > Binary caching with remote backends requires additional CI configuration; cache invalidation can be non-obvious for large dependency graphs.

  - Dependency Pinning
    > Version pinning requires `overrides` entries in `vcpkg.json` and a baseline; the mechanism is less ergonomic than Conan's lockfile for pinning exact revisions.

### 4.3. CPM.cmake

[CPM.cmake](https://github.com/cpm-cmake/CPM.cmake) is a lightweight, zero-install CMake dependency manager built on top of CMake's `FetchContent` module.

- Pros:

  - CMake Integration
    > Pure CMake implementation; no external tooling required—adding a single `CPM.cmake` script to the project is sufficient to begin declaring dependencies.

  - Cross-Platform Support
    > Inherits full CMake cross-platform support; works wherever CMake and a network connection are available.

  - Prebuilt Binary and Build from Source
    > Always builds dependencies from source as part of the CMake configure step, ensuring complete control over build options and compiler flags.

  - Dependencies and Dev Dependencies
    > Dependencies can be scoped per CMake target using standard CMake `PRIVATE` / `PUBLIC` / `INTERFACE` visibility semantics.

- Cons:

  - Dependency Resolution
    > No SAT-based conflict resolution; version conflicts between transitive dependencies are not automatically detected and may silently produce incorrect builds.

  - Dependency Pinning
    > Pinning relies on Git commit SHAs or tags in CMake scripts; there is no centralised manifest file or structured version declaration.

  - Transitive Dependencies
    > Transitive dependency management is shallow; downstream packages must also use CPM.cmake or expose their dependencies explicitly.

  - Immutable Lockfiles
    > No lockfile mechanism; reproducibility depends entirely on using immutable Git references (exact commit SHAs) in every `CPMAddPackage` call.

  - Reproducibility
    > Without a lockfile, reproducibility depends on upstream Git tags remaining immutable and upstream repositories remaining available.

  - CI/CD
    > Each clean CI run re-downloads all sources; the CPM cache directory must be persisted manually to avoid repeated downloads, adding pipeline complexity.

  - Private and Public Dependencies
    > Private package support depends on Git repository access; there is no package registry concept, authentication configuration, or binary distribution mechanism.

## 5. Consequences

- Positive Consequences
  > Conan provides fully reproducible builds via `conan.lock`, enables binary caching to reduce CI build times, and integrates natively with the CMake build system through `CMakeDeps` and `CMakeToolchain`. Developers across different platforms and operating systems can reproduce the exact same dependency graph from a single `conanfile.txt` and lockfile.

- Negative Consequences
  > Developers must install Python and the Conan client and must create and maintain a Conan profile for each platform or toolchain target. Any new dependency not present on ConanCenter requires authoring a custom Conan recipe, which involves learning the `conanfile.py` DSL.

- Risks
  > If a required package is not available on ConanCenter and a custom recipe cannot be maintained, an alternative source strategy (vendoring, system package) must be adopted. Mitigation: audit all required dependencies against ConanCenter before adopting Conan; prefer widely used libraries with existing recipes.

## 6. Implementation

1. Install the Conan client (`pip install conan`) and initialise a default profile (`conan profile detect`) on all developer machines and CI runners.

2. Declare all production and development dependencies in `conanfile.txt` using the `[requires]` and `[tool_requires]` sections respectively; specify exact versions for every entry.

3. Generate the lockfile by running `conan lock create conanfile.txt --lockfile-out conan.lock` and commit `conan.lock` to version control.

4. Configure `CMakeDeps` and `CMakeToolchain` in the `[generators]` section of `conanfile.txt` so that CMake can consume installed packages via `find_package()`.

5. Integrate Conan into the CMake build flow via a `meta_conan` CMake helper module that invokes `conan install` before the configure step, passing the lockfile with `--lockfile conan.lock`.

6. Add a CI step to restore and save the Conan package cache (e.g., `~/.conan2/p`) using the CI platform's caching action, keyed on a hash of `conan.lock`.

7. Document the Conan profile format and remote configuration in the project's `CONTRIBUTING.md` so that new contributors can reproduce the build environment.

8. Validate conformance by verifying that `conan.lock` is committed and up to date in CI (fail the pipeline if `conan lock create` produces a diff against the committed lockfile).

## 7. References

- Conan [documentation](https://docs.conan.io/) page.
- Conan [conanfile.txt reference](https://docs.conan.io/2/reference/conanfile_txt.html) page.
- Conan [lockfiles](https://docs.conan.io/2/examples/lockfiles.html) documentation.
- Conan [CMakeDeps generator](https://docs.conan.io/2/reference/tools/cmake/cmakedeps.html) page.
- Conan [CMakeToolchain generator](https://docs.conan.io/2/reference/tools/cmake/cmaketoolchain.html) page.
- vcpkg [documentation](https://vcpkg.io/en/docs/README.html) page.
- vcpkg [manifest mode](https://learn.microsoft.com/en-us/vcpkg/reference/vcpkg-json) page.
- CPM.cmake [repository](https://github.com/cpm-cmake/CPM.cmake) page.
- CPM.cmake [usage documentation](https://github.com/cpm-cmake/CPM.cmake/blob/master/README.md) page.
