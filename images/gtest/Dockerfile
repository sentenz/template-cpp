# syntax=docker/dockerfile:1.7
# SPDX-License-Identifier: Apache-2.0

ARG ALPINE_IMAGE=alpine:3.22.4@sha256:310c62b5e7ca5b08167e4384c68db0fd2905dd9c7493756d356e893909057601

FROM ${ALPINE_IMAGE}

ARG GTEST_VERSION=1.17.0
ARG CONAN_VERSION=2.21.0
ARG GCOVR_VERSION=8.4

LABEL org.opencontainers.image.title="GoogleTest runner" \
      org.opencontainers.image.description="C++ unit-test environment for template-cpp" \
      org.opencontainers.image.source="https://github.com/sentenz/template-cpp" \
      org.opencontainers.image.version="${GTEST_VERSION}" \
      org.opencontainers.image.licenses="Apache-2.0"

RUN apk add --no-cache \
      bash \
      build-base \
      ca-certificates \
      ccache \
      cmake \
      git \
      ninja \
      py3-pip \
      python3 \
    && python3 -m pip install \
      --break-system-packages \
      --no-cache-dir \
      "conan==${CONAN_VERSION}" \
      "gcovr==${GCOVR_VERSION}"

ENV CONAN_HOME=/opt/conan \
    CCACHE_DIR=/tmp/ccache \
    HOME=/tmp

RUN set -eux; \
    mkdir -p "${CONAN_HOME}" "${CCACHE_DIR}" /workspace; \
    conan profile detect --force; \
    conan install \
      --requires="gtest/${GTEST_VERSION}" \
      --settings=build_type=Debug \
      --build=missing; \
    chmod -R a+rwX "${CONAN_HOME}" "${CCACHE_DIR}" /workspace

WORKDIR /workspace

ENTRYPOINT ["make"]
CMD ["cmake-gcc-test-unit-run"]
