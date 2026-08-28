# GoogleTest container image

This project-specific image provides the compiler, CMake, Ninja, ccache, Conan, gcovr, and dependency cache required by the repository test workflow.

The default container command runs:

```bash
make cmake-gcc-test-unit-run
```

That target configures the CMake `test` preset, builds the test executable, executes CTest, and writes JUnit output to `logs/test/junit.xml`.

## Dependency model

The image installs dependencies from the repository-root `conanfile.txt` and explicitly applies `conan.lock`. This keeps the pre-populated Conan cache aligned with the complete project dependency graph, including GoogleTest and nlohmann/json, without duplicating dependency versions in the Dockerfile.

Changes to either manifest invalidate the dependency installation layer and rebuild the cache deterministically from the updated graph.

## Make tasks

The repository Makefile provides the primary image workflow:

```bash
make container-gtest-build
make container-gtest-test
make container-gtest-coverage
```

`container-gtest-test` and `container-gtest-coverage` build the image first, mount the repository at `/workspace`, and run with the host UID and GID to avoid root-owned build and report artifacts.

The image settings can be overridden at invocation time:

```bash
make container-gtest-build \
  GTEST_IMAGE=sentenz/gtest:local \
  GTEST_DOCKERFILE=images/gtest/Dockerfile \
  GTEST_BUILD_CONTEXT=.
```

## Direct Docker build

Run the build from the repository root so the dependency manifests are available in the Docker build context:

```bash
docker build \
  -f images/gtest/Dockerfile \
  -t sentenz/gtest:1.17.0 \
  .
```

`images/gtest/Dockerfile.dockerignore` limits the root context to `conanfile.txt` and `conan.lock`, avoiding transmission of source, build, log, and Git data that are not needed to construct the image.

The image pins the Alpine base image by digest and pins the Python tooling versions used by `scripts/setup.sh`.

## Multi-platform publication

Conan resolves the locked dependency graph independently for each target platform, so the same Dockerfile supports `linux/amd64` and `linux/arm64`:

```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -f images/gtest/Dockerfile \
  -t sentenz/gtest:1.17.0 \
  --push \
  .
```

## Direct Docker run

Mount the repository at `/workspace`. Running with the host UID and GID prevents root-owned build and report artifacts in the working tree.

```bash
docker run --rm \
  --user "$(id -u):$(id -g)" \
  -v "$PWD:/workspace" \
  -w /workspace \
  sentenz/gtest:1.17.0
```

At runtime, the repository CMake configuration invokes Conan again. The packages already present in `/opt/conan` satisfy the locked graph without downloading or rebuilding them unless the mounted repository manifests differ from those used to build the image.

Because `make` is the image entrypoint, another repository target can be selected directly. For example, to run the unit tests and generate coverage reports:

```bash
docker run --rm \
  --user "$(id -u):$(id -g)" \
  -v "$PWD:/workspace" \
  -w /workspace \
  sentenz/gtest:1.17.0 \
  cmake-gcc-test-unit-coverage
```
