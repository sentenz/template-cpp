# GoogleTest container image

This image provides the compiler, CMake, Ninja, ccache, Conan, gcovr, and GoogleTest environment required by the repository test workflow.

The default container command runs:

```bash
make cmake-gcc-test-unit-run
```

That target configures the CMake `test` preset, builds the test executable, executes CTest, and writes JUnit output to `logs/test/junit.xml`.

## Build

```bash
docker build \
  --build-arg GTEST_VERSION=1.17.0 \
  -t sentenz/gtest:1.17.0 \
  images/gtest
```

The image pins the Alpine base image by digest, pins the Python tooling versions used by the repository setup script, and pre-populates the Conan cache with the selected Debug GoogleTest package.

## Multi-platform publication

GoogleTest is resolved for the target platform during each Buildx build, so the same Dockerfile supports `linux/amd64` and `linux/arm64`.

```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --build-arg GTEST_VERSION=1.17.0 \
  -t sentenz/gtest:1.17.0 \
  --push \
  images/gtest
```

## Run the unit tests

Mount the repository at `/workspace`. Running with the host UID and GID prevents root-owned build and report artifacts in the working tree.

```bash
docker run --rm \
  --user "$(id -u):$(id -g)" \
  -v "$PWD:/workspace" \
  -w /workspace \
  sentenz/gtest:1.17.0
```

Because `make` is the image entrypoint, another repository target can be selected directly. For example, to run the unit tests and generate coverage reports:

```bash
docker run --rm \
  --user "$(id -u):$(id -g)" \
  -v "$PWD:/workspace" \
  -w /workspace \
  sentenz/gtest:1.17.0 \
  cmake-gcc-test-unit-coverage
```
