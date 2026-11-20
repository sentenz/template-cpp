# SPDX-License-Identifier: Apache-2.0

# Load Dotenv Files

DOTENV_FILES := $(filter-out %.enc,$(wildcard .env .env.*))
ifneq ($(strip $(DOTENV_FILES)),)
	include $(DOTENV_FILES)
	export
endif

# Define Variables

SHELL := bash
.SHELLFLAGS := -euo pipefail -c
.ONESHELL:

# ─── General ─────────────────────────────────────────────────────────────────────────────────────

default: help

# NOTE Targets MUST have a leading comment line starting with `##` to be included in the list. See the targets below for examples.
#
## Display help message with a list of available tasks and their descriptions
help:
	@awk 'BEGIN {printf "Tasks\n\tA collection of tasks used in the current project.\n\n"}'
	@awk 'BEGIN {printf "Usage\n\tmake $(shell tput -Txterm setaf 6)<task>$(shell tput -Txterm sgr0)\n\n"}' $(MAKEFILE_LIST)
	@awk '/^##/{c=substr($$0,3);next}c&&/^[[:alpha:]][[:alnum:]_-]+:/{print "$(shell tput -Txterm setaf 6)\t" substr($$1,1,index($$1,":")) "$(shell tput -Txterm sgr0)",c}1{c=0}' $(MAKEFILE_LIST) | column -s: -t
.PHONY: help

# ─── Setup & Teardown ────────────────────────────────────────────────────────────────────────────

# NOTE Privileged task may require elevated permissions (e.g., sudo) to execute.
#
## Initialize a software development workspace with requisites
bootstrap:
	cd $(@D)/scripts && ./bootstrap.sh
.PHONY: bootstrap

# NOTE Privileged task may require elevated permissions (e.g., sudo) to execute.
#
## Install and configure all dependencies essential for development
setup:
	cd $(@D)/scripts && ./setup.sh
.PHONY: setup

# NOTE Privileged task may require elevated permissions (e.g., sudo) to execute.
#
## Remove development artifacts and restore the host to its pre-setup state
teardown:
	cd $(@D)/scripts && ./teardown.sh
.PHONY: teardown

# ─── Git Hooks Manager ───────────────────────────────────────────────────────────────────────────

## Initialize Lefthook Git hooks in the local repository
githooks-lefthook-initialize:
	lefthook install --force
.PHONY: githooks-lefthook-initialize

## Deinitialize Lefthook Git hooks from the local repository
githooks-lefthook-deinitialize:
	lefthook uninstall
.PHONY: githooks-lefthook-deinitialize


# ── Dependency Manager ───────────────────────────────────────────────────────────────────────────

# NOTE Conan install is performed automatically by `meta_conan()`
#
## Initialize Conan for package management
pkg-conan-initialize:
	conan profile detect --force
	conan install . -s build_type=Debug --output-folder=build/test/conan --build=missing
.PHONY: pkg-conan-initialize

# ─── Dependency Manager ──────────────────────────────────────────────────────────────────────────

DEPENDENCY_RENOVATE_IMAGE ?= docker.io/renovate/renovate:44.166.0@sha256:510b885a90cd70437816c5c2da1d0c3beff513d3979497b2db1d37c84adfbc2b
DEPENDENCY_RENOVATE_ALIAS := docker run --rm -v "${PWD}:/workspace" -w /workspace -e LOG_LEVEL=debug -e RENOVATE_REPOSITORIES -e RENOVATE_TOKEN=$(RENOVATE_TOKEN) "$(DEPENDENCY_RENOVATE_IMAGE)"

## Update project dependencies locally using Renovate and generate a report
dependency-renovate-update:
	@mkdir -p logs/dependency

	$(DEPENDENCY_RENOVATE_ALIAS) renovate --platform=local --repository-cache=reset > logs/dependency/renovate.log 2>&1
.PHONY: dependency-renovate-update

# ── Build System ─────────────────────────────────────────────────────────────────────────────────

LOGS_PATH_TEST := logs/test

## Generate a CMake project configured for GCC-ARM in Debug mode
cmake-gcc-debug-configure:
	cmake --preset debug
.PHONY: cmake-gcc-debug-configure

## Compile the GCC-ARM project in Debug configuration
cmake-gcc-debug-build: cmake-gcc-debug-configure
	cmake --build --preset debug
.PHONY: cmake-gcc-debug-build

## Clean the GCC-ARM project in Debug configuration
cmake-gcc-debug-clean:
	cmake --build --preset debug --target clean
.PHONY: cmake-gcc-debug-clean

## Generate a CMake project configured for GCC-ARM in Release mode
cmake-gcc-release-configure:
	cmake --preset release
.PHONY: cmake-gcc-release-configure

## Compile the GCC-ARM project in Release configuration
cmake-gcc-release-build: cmake-gcc-release-configure
	cmake --build --preset release
.PHONY: cmake-gcc-release-build

## Clean the GCC-ARM project in Release configuration
cmake-gcc-release-clean:
	cmake --build --preset release --target clean
.PHONY: cmake-gcc-release-clean

## Generate a CMake project configured for unit tests
cmake-gcc-test-unit-configure:
	cmake --preset test
.PHONY: cmake-gcc-test-unit-configure

## Compile the unit test
cmake-gcc-test-unit-build: cmake-gcc-test-unit-configure
	cmake --build --preset test
.PHONY: cmake-gcc-test-unit-build

## Run the unit tests
cmake-gcc-test-unit-run: cmake-gcc-test-unit-build
	@mkdir -p "$(CURDIR)/${LOGS_PATH_TEST}"
	ctest --preset test --output-junit "$(CURDIR)/${LOGS_PATH_TEST}/junit.xml"
.PHONY: cmake-gcc-test-unit-run

## Clean the unit test build artifacts
cmake-gcc-test-unit-clean:
	cmake --build --preset test --target clean
.PHONY: cmake-gcc-test-unit-clean

## Run the GCC unit tests and generate code coverage report
cmake-gcc-test-unit-coverage:
	$(MAKE) cmake-gcc-test-unit-run || true
	$(MAKE) static-analysis-coverage
.PHONY: cmake-gcc-test-unit-coverage

## Cross-compile Google Test firmware and run the suites on hardware via SEGGER J-Run
cmake-gcc-test-ontarget-run:
	cmake --preset ontarget
	cmake --build --preset ontarget
	ctest --preset ontarget
.PHONY: cmake-gcc-test-ontarget-run

# ── Static Analysis ──────────────────────────────────────────────────────────────────────────────

LOGS_PATH_COVERAGE := logs/coverage

##
static-analysis-coverage:
	@mkdir -p "$(CURDIR)/${LOGS_PATH_COVERAGE}"
	gcovr --xml-pretty --print-summary --cobertura --output "$(CURDIR)/${LOGS_PATH_COVERAGE}/cobertura.xml" --html="$(CURDIR)/${LOGS_PATH_COVERAGE}/" --filter "src/" --exclude-unreachable-branches
.PHONY: static-analysis-coverage

# ─── Secrets Manager ─────────────────────────────────────────────────────────────────────────────

SECRETS_SOPS_IMAGE ?= ghcr.io/getsops/sops:v3.13.3@sha256:857f5a151ac0b2bfc55c1e4e5581d66fb8e268e4d106b38e74191f3bac9d58ea
SECRETS_SOPS_ALIAS ?= docker run --rm --user "$(shell id -u):$(shell id -g)" -e GNUPGHOME=/tmp/.gnupg -v "${PWD}:/workspace" -v "$${HOME}/.gnupg:/tmp/.gnupg" -w /workspace "$(SECRETS_SOPS_IMAGE)"
SECRETS_SOPS_UID ?= sops-$(notdir $(CURDIR))

# Usage: make secrets-gpg-generate SECRETS_SOPS_UID=<uid>
#
## Generate a new GPG key pair for SOPS with the specified UID
secrets-gpg-generate:
	@gpg --batch --quiet --passphrase '' --quick-generate-key "$(SECRETS_SOPS_UID)" ed25519 cert,sign 0
	@NEW_FPR="$$(gpg --list-keys --with-colons "$(SECRETS_SOPS_UID)" | awk -F: '/^fpr:/ {print $$10; exit}')"
	@gpg --batch --quiet --passphrase '' --quick-add-key "$${NEW_FPR}" cv25519 encrypt 0
.PHONY: secrets-gpg-generate

# Usage: make secrets-gpg-export SECRETS_SOPS_UID=<uid>
#
## Export the GPG key pair for SOPS with the specified UID to ASCII files
secrets-gpg-export:
	@if [ -z "$(SECRETS_SOPS_UID)" ]; then \
		echo "usage: make secrets-gpg-export SECRETS_SOPS_UID=<uid>" >&2; \
		exit 1; \
	fi

	@gpg --armor --export "$(SECRETS_SOPS_UID)" > "$(SECRETS_SOPS_UID)-public.asc"
	@gpg --armor --export-secret-keys "$(SECRETS_SOPS_UID)" > "$(SECRETS_SOPS_UID)-private.asc"
.PHONY: secrets-gpg-export

# Usage: make secrets-gpg-import [SECRETS_SOPS_UID=<uid>] <key-files>
#
## Import GPG keys from specified files and if provided set ultimate trust for the SOPS UID
secrets-gpg-import:
	@if [ -z "$(filter-out $@,$(MAKECMDGOALS))" ]; then \
		echo "usage: make secrets-gpg-import <files>" >&2; \
		exit 1; \
	fi

	# Import keys from specified files
	@for file in $(filter-out $@,$(MAKECMDGOALS)); do \
		if [ -f "$$file" ]; then \
			gpg --import "$$file"; \
		fi; \
	done

	# Set ultimate trust for the SECRETS_SOPS_UID
	@if [ "$(origin SECRETS_SOPS_UID)" = "command line" ] && [ -n "$(SECRETS_SOPS_UID)" ]; then \
		FPR="$$( { gpg --list-keys --with-colons "$(SECRETS_SOPS_UID)" 2>/dev/null || true; } | awk -F: '/^fpr:/ {print $$10; exit}')"; \
		if [ -n "$${FPR}" ]; then \
			echo "$${FPR}:6:" | gpg --import-ownertrust; \
		fi; \
	fi
.PHONY: secrets-gpg-import

# Usage: make secrets-gpg-remove SECRETS_SOPS_UID=<uid>
#
## Remove GPG keys for SOPS with the specified UID (interactive)
secrets-gpg-remove:
	@if ! gpg --list-keys "$(SECRETS_SOPS_UID)" >/dev/null 2>&1; then
		echo "warning: no key found for '$(SECRETS_SOPS_UID)'" >&2
		exit 0
	fi

	# Delete private key first, then public key
	@gpg --yes --delete-secret-keys "$(SECRETS_SOPS_UID)"
	@gpg --yes --delete-keys "$(SECRETS_SOPS_UID)"
.PHONY: secrets-gpg-remove

# Usage: make secrets-gpg-show [SECRETS_SOPS_UID=<uid>]
#
## Show GPG public key information for SOPS UID or list all keys if UID is not set
secrets-gpg-show:
	@if [ "$(origin SECRETS_SOPS_UID)" != "command line" ]; then \
		gpg --list-keys --keyid-format long; \
		exit 0; \
	fi

	@FPR="$$( { gpg --list-keys --with-colons "$(SECRETS_SOPS_UID)" 2>/dev/null || true; } | awk -F: '/^fpr:/ {print $$10; exit}')"; \
	if [ -z "$${FPR}" ]; then \
		echo "error: no fingerprint found for UID '$(SECRETS_SOPS_UID)'" >&2; \
		exit 1; \
	fi; \
	echo -e "UID: $(SECRETS_SOPS_UID)\nFingerprint: $${FPR}"
.PHONY: secrets-gpg-show

# Usage: make secrets-sops-encrypt <files>
#
## Encrypt specified files using SOPS with GPG keys, writing output to <file>.enc
secrets-sops-encrypt:
	@if [ -z "$(filter-out $@,$(MAKECMDGOALS))" ]; then \
		echo "usage: make secrets-sops-encrypt <files>" >&2; \
		exit 1; \
	fi

	@for file in $(filter-out $@,$(MAKECMDGOALS)); do \
		if [ -f "$$file" ]; then \
			$(SECRETS_SOPS_ALIAS) encrypt --output "$$file.enc" "$$file"; \
		else \
			echo "file not found: $$file" >&2; \
		fi; \
	done
.PHONY: secrets-sops-encrypt

# Usage: make secrets-sops-decrypt <files>
#
## Decrypt specified SOPS-encrypted files (expects <file>.enc), writing output to <file>
secrets-sops-decrypt:
	@if [ -z "$(filter-out $@,$(MAKECMDGOALS))" ]; then \
		echo "usage: make secrets-sops-decrypt <files>" >&2; \
		exit 1; \
	fi

	@for file in $(filter-out $@,$(MAKECMDGOALS)); do \
		case "$$file" in \
			*.enc) \
				$(SECRETS_SOPS_ALIAS) decrypt --filename-override "$${file%.enc}" --output "$${file%.enc}" "$$file"; \
				;;
			*) \
				$(SECRETS_SOPS_ALIAS) decrypt --in-place "$$file"; \
				;;
		esac; \
	done
.PHONY: secrets-sops-decrypt

# Usage: make secrets-sops-view <file>
#
## View decrypted contents of a SOPS-encrypted file using GPG keys
secrets-sops-view:
	@if [ -z "$(filter-out $@,$(MAKECMDGOALS))" ]; then \
		echo "usage: make secrets-sops-view <file>" >&2; \
		exit 1; \
	fi

	$(SECRETS_SOPS_ALIAS) decrypt "$(filter-out $@,$(MAKECMDGOALS))"
.PHONY: secrets-sops-view

# ─── Policy Manager ──────────────────────────────────────────────────────────────────────────────

POLICY_CONFTEST_IMAGE ?= docker.io/openpolicyagent/conftest:v0.71.1@sha256:0e77cdf7c1fcde035f3c579e4aaa6664ee2a8be5777eaa9af9f520cdd02280c0
POLICY_CONFTEST_ALIAS := docker run --rm -v "${PWD}:/workspace" -w /workspace "$(POLICY_CONFTEST_IMAGE)"

# Usage: make policy-conftest-test <filepath>
#
## Run Conftest container in REPL (Read-Eval-Print-Loop) to evaluate policies against input data and generate a report
policy-conftest-test:
	@if [ -z "$(filter-out $@,$(MAKECMDGOALS))" ]; then \
		echo "usage: make policy-conftest-test <filepath>"; \
		exit 1; \
	fi

	@mkdir -p logs/policy

	$(POLICY_CONFTEST_ALIAS) test "$(filter-out $@,$(MAKECMDGOALS))" > logs/policy/conftest-report.json 2>&1
.PHONY: policy-conftest-test

POLICY_REGAL_IMAGE ?= ghcr.io/open-policy-agent/regal:0.43.0@sha256:29460f0ec1340d37f6c0c74bcbd88dd232fd8382c7a2337f0684415bd4c46da1
POLICY_REGAL_ALIAS := docker run --rm -v "${PWD}:/workspace" -w /workspace "$(POLICY_REGAL_IMAGE)"

# Usage: make policy-regal-lint <filepath>
#
## Lint Rego policies using Regal and generate a report
policy-regal-lint:
	@if [ -z "$(filter-out $@,$(MAKECMDGOALS))" ]; then \
		echo "usage: make policy-regal-lint <filepath>"; \
		exit 1; \
	fi

	@mkdir -p logs/policy

	$(POLICY_REGAL_ALIAS) lint "$(filter-out $@,$(MAKECMDGOALS))" --format json > logs/policy/regal.json 2>&1
.PHONY: policy-regal-lint

# ─── SAST Manager ────────────────────────────────────────────────────────────────────────────────

SAST_SEMGREP_IMAGE ?= semgrep/semgrep:1.181.0@sha256:81474464c1f07483ba0682a44787fd93c91397419762a04abe2bafaae396304b
SAST_SEMGREP_ALIAS := docker run --rm -v "${PWD}:/workspace" -w /workspace "$(SAST_SEMGREP_IMAGE)"
SAST_SEMGREP_FILES ?= .
SAST_SEMGREP_FILTER = $(if $(strip $(SAST_SEMGREP_FILES)),$(SAST_SEMGREP_FILES),.)

## Scan source code for security issues using Semgrep and generate a report
sast-semgrep-scan:
	@mkdir -p logs/sast

	$(SAST_SEMGREP_ALIAS) semgrep scan --config auto --error --json --output logs/sast/semgrep.json $(SAST_SEMGREP_FILTER) 2> logs/sast/semgrep.log
.PHONY: sast-semgrep-scan

SAST_TRIVY_IMAGE ?= aquasec/trivy:0.76.0@sha256:2416d1f74045b57274df1a340eee6b510cacd73c66a6ccb8da092b117eb7d222
SAST_TRIVY_ALIAS := docker run --rm -v "${PWD}:/workspace" -w /workspace "$(SAST_TRIVY_IMAGE)"
SAST_TRIVY_FILES ?= .

## Scan Infrastructure-as-Code (IaC) files for misconfigurations using Trivy and generate a report
sast-trivy-misconfig:
	@mkdir -p logs/sast

	$(SAST_TRIVY_ALIAS) config --output logs/sast/trivy-misconfig.json $(SAST_TRIVY_FILES) 2>&1
.PHONY: sast-trivy-misconfig

## Scan local filesystem for vulnerabilities and misconfigurations using Trivy
sast-trivy-fs:
	@mkdir -p logs/sast

	$(SAST_TRIVY_ALIAS) filesystem --output logs/sast/trivy-filesystem.json /workspace 2>&1
.PHONY: sast-trivy-fs

# Usage: make sast-trivy-image <image_name>
#
## Scan a container image for vulnerabilities using Trivy
sast-trivy-image:
	@if [ -z "$(filter-out $@,$(MAKECMDGOALS))" ]; then \
		echo "usage: make sast-trivy-image <image_name>"; \
		exit 1; \
	fi

	@mkdir -p logs/sast

	docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v "${PWD}:/workspace" -w /workspace "$(SAST_TRIVY_IMAGE)" image --output logs/sast/trivy-image.json "$(filter-out $@,$(MAKECMDGOALS))" 2>&1
.PHONY: sast-trivy-image

# Usage: make sast-trivy-image-license <image_name>
#
## Scan a container image for license compliance using Trivy
sast-trivy-image-license:
	@if [ -z "$(filter-out $@,$(MAKECMDGOALS))" ]; then \
		echo "usage: make sast-trivy-image-license <image_name>"; \
		exit 1; \
	fi

	@mkdir -p logs/sast

	$(SAST_TRIVY_ALIAS) image --scanners license --format table --output logs/sast/trivy-image-license.txt "$(filter-out $@,$(MAKECMDGOALS))" 2>&1
.PHONY: sast-trivy-image-license

# Usage: make sast-trivy-repository <repo_url>
#
## Scan a remote repository for vulnerabilities using Trivy
sast-trivy-repository:
	@if [ -z "$(filter-out $@,$(MAKECMDGOALS))" ]; then \
		echo "usage: make sast-trivy-repository <repo_url>"; \
		exit 1; \
	fi

	@mkdir -p logs/sast

	$(SAST_TRIVY_ALIAS) repository --output logs/sast/trivy-repository.json "$(filter-out $@,$(MAKECMDGOALS))" 2>&1
.PHONY: sast-trivy-repository

# Usage: make sast-trivy-rootfs <path>
#
## Scan a rootfs e.g. `/` for vulnerabilities using Trivy
sast-trivy-rootfs:
	@if [ -z "$(filter-out $@,$(MAKECMDGOALS))" ]; then \
		echo "usage: make sast-trivy-rootfs <path>"; \
		exit 1; \
	fi

	@mkdir -p logs/sast

	$(SAST_TRIVY_ALIAS) rootfs --output logs/sast/trivy-rootfs.json "$(filter-out $@,$(MAKECMDGOALS))" 2>&1
.PHONY: sast-trivy-rootfs

# Usage: make sast-trivy-sbom-scan <sbom_path>
#
## Scan SBOM for vulnerabilities using Trivy
sast-trivy-sbom-scan:
	@if [ -z "$(filter-out $@,$(MAKECMDGOALS))" ]; then \
		echo "usage: make sast-trivy-sbom-scan <sbom_path>"; \
		exit 1; \
	fi

	@mkdir -p logs/sast

	$(SAST_TRIVY_ALIAS) sbom --output logs/sast/trivy-sbom.json "$(filter-out $@,$(MAKECMDGOALS))" 2>&1
.PHONY: sast-trivy-sbom-scan

# Usage: make sast-trivy-sbom-cyclonedx-image <image_name>
#
## Generate SBOM in CycloneDX format for a container image using Trivy
sast-trivy-sbom-cyclonedx-image:
	@if [ -z "$(filter-out $@,$(MAKECMDGOALS))" ]; then \
		echo "usage: make sast-trivy-sbom-cyclonedx-image <image_name>"; \
		exit 1; \
	fi

	@mkdir -p logs/sbom

	docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v "${PWD}:/workspace" -w /workspace "$(SAST_TRIVY_IMAGE)" image --format cyclonedx --output logs/sbom/sbom-image.cdx.json "$(filter-out $@,$(MAKECMDGOALS))" 2>&1
.PHONY: sast-trivy-sbom-cyclonedx-image

# Usage: make sast-trivy-sbom-cyclonedx-fs <path>
#
## Generate SBOM in CycloneDX format for a file system using Trivy
sast-trivy-sbom-cyclonedx-fs:
	@if [ -z "$(filter-out $@,$(MAKECMDGOALS))" ]; then \
		echo "usage: make sast-trivy-sbom-cyclonedx-fs <path>"; \
		exit 1; \
	fi

	@mkdir -p logs/sbom

	$(SAST_TRIVY_ALIAS) filesystem --format cyclonedx --output logs/sbom/sbom-fs.cdx.json "$(filter-out $@,$(MAKECMDGOALS))" 2>&1
.PHONY: sast-trivy-sbom-cyclonedx-fs

# Usage: make sast-trivy-sbom-license <sbom_path>
#
## Scan SBOM for license compliance using Trivy
sast-trivy-sbom-license:
	@if [ -z "$(filter-out $@,$(MAKECMDGOALS))" ]; then \
		echo "usage: make sast-trivy-sbom-license <sbom_path>"; \
		exit 1; \
	fi

	@mkdir -p logs/sast

	$(SAST_TRIVY_ALIAS) sbom --scanners license --format table --output logs/sast/trivy-sbom-license.txt "$(filter-out $@,$(MAKECMDGOALS))" 2>&1
.PHONY: sast-trivy-sbom-license

# Usage: make sast-trivy-sbom-attestation <intoto_sbom_path>
#
## Scan the verified SBOM attestation using Trivy
sast-trivy-sbom-attestation:
	@if [ -z "$(filter-out $@,$(MAKECMDGOALS))" ]; then \
		echo "usage: make sast-trivy-sbom-attestation <intoto_sbom_path>"; \
		exit 1; \
	fi

	@mkdir -p logs/sast

	$(SAST_TRIVY_ALIAS) sbom "$(filter-out $@,$(MAKECMDGOALS))"
.PHONY: sast-trivy-sbom-attestation

# Usage: make sast-trivy-vm <vm_image_path>
#
## [EXPERIMENTAL] Scan a virtual machine image using Trivy
sast-trivy-vm:
	@if [ -z "$(filter-out $@,$(MAKECMDGOALS))" ]; then \
		echo "usage: make sast-trivy-vm <vm_image_path>"; \
		exit 1; \
	fi

	@mkdir -p logs/sast

	$(SAST_TRIVY_ALIAS) vm --output logs/sast/trivy-vm.json "$(filter-out $@,$(MAKECMDGOALS))" 2>&1
.PHONY: sast-trivy-vm

# Usage: make sast-trivy-kubernetes [target]
#
## [EXPERIMENTAL] Scan kubernetes cluster using Trivy (default `cluster`)
sast-trivy-kubernetes:
	@echo "Note: This requires KUBECONFIG to be mounted or available to the container. Assuming ~/.kube/config is mounted to /root/.kube/config"

	@mkdir -p logs/sast

	docker run --rm -v "${HOME}/.kube/config:/root/.kube/config" -v "${PWD}:/workspace" -w /workspace "$(SAST_TRIVY_IMAGE)" kubernetes --output logs/sast/trivy-kubernetes.json $(if $(filter-out $@,$(MAKECMDGOALS)),$(filter-out $@,$(MAKECMDGOALS)),cluster) 2>&1
.PHONY: sast-trivy-kubernetes

SAST_TRIVY_KBOM_FILE ?= logs/sbom/kbom.cdx.json

## Generate a CycloneDX KBOM (Kubernetes Bill of Materials) from the selected Kubernetes cluster
sast-trivy-kbom:
	@test -s "$(K8S_KUBECONFIG)" || { \
		echo "error: kubeconfig not found: $(K8S_KUBECONFIG)" >&2; \
		exit 1; \
	}

	@mkdir -p "$(dir $(SAST_TRIVY_KBOM_FILE))"

	docker run --rm --user root --network host --volume /var/run/docker.sock:/var/run/docker.sock --volume "$(CURDIR):/workspace" --workdir /workspace \
		"$(SAST_TRIVY_IMAGE)" k8s --kubeconfig "$(K8S_KUBECONFIG)" --format cyclonedx --output "/workspace/$(SAST_TRIVY_KBOM_FILE)"
.PHONY: sast-trivy-kbom

SAST_IMAGE_GITLEAKS ?= ghcr.io/gitleaks/gitleaks:v8.30.1@sha256:c00b6bd0aeb3071cbcb79009cb16a60dd9e0a7c60e2be9ab65d25e6bc8abbb7f

## Scan git repository history for leaked secrets using Gitleaks and generate a report
sast-gitleaks-detect:
	@mkdir -p logs/sast

	docker run --rm -v "${PWD}:/workspace" -w /workspace "$(SAST_IMAGE_GITLEAKS)" detect --redact --source /workspace --report-format json --report-path logs/sast/gitleaks-detect.json 2>&1
.PHONY: sast-gitleaks-detect

## Scan staged git changes for leaked secrets using Gitleaks and generate a report
sast-gitleaks-staged:
	@mkdir -p logs/sast

	docker run --rm -v "${PWD}:/workspace" -w /workspace "$(SAST_IMAGE_GITLEAKS)" protect --redact --staged --source /workspace --report-format json --report-path logs/sast/gitleaks-protect.json 2>&1
.PHONY: sast-gitleaks-staged

SAST_IMAGE_TRUFFLEHOG ?= trufflesecurity/trufflehog:3.99.2@sha256:47a84bc18a0d04a165498bbbd3bacfd84176661cbc91f8e0f85467f6a771e99a

## Scan local filesystem for leaked secrets using TruffleHog and generate a report
sast-trufflehog-fs:
	@mkdir -p logs/sast

	docker run --rm -v "${PWD}:/workspace" -w /workspace "$(SAST_IMAGE_TRUFFLEHOG)" filesystem . --no-update --json > logs/sast/trufflehog-filesystem.json 2> logs/sast/trufflehog-filesystem.log
.PHONY: sast-trufflehog-fs

## Scan git repository history for leaked secrets using TruffleHog and generate a report
sast-trufflehog-git:
	@mkdir -p logs/sast

	docker run --rm -v "${PWD}:/workspace" -w /workspace "$(SAST_IMAGE_TRUFFLEHOG)" git file:///workspace --no-update --json > logs/sast/trufflehog-git.json 2> logs/sast/trufflehog-git.log
.PHONY: sast-trufflehog-git

# ─── Software Supply Chain Security (SSCS) ───────────────────────────────────────────────────────

SSCS_COSIGN_IMAGE ?= cgr.dev/chainguard/cosign:3.0.0@sha256:b6bc266358e9368be1b3d01fca889b78d5ad5a47832986e14640c34a237ef638
SSCS_COSIGN_ALIAS := docker run --rm -v "${PWD}:/workspace" -w /workspace "$(SSCS_COSIGN_IMAGE)"

## Generate Cosign key pair
sast-cosign-generate-key-pair:
	$(SSCS_COSIGN_ALIAS) generate-key-pair
.PHONY: sast-cosign-generate-key-pair

# Usage: make sast-cosign-attest <image_name>
#
## Attest an image with the generated SBOM using Cosign
sast-cosign-attest:
	@if [ -z "$(filter-out $@,$(MAKECMDGOALS))" ]; then \
		echo "usage: make sast-cosign-attest <image_name>"; \
		exit 1; \
	fi
	@if [ ! -f cosign.key ]; then \
		echo "Error: cosign.key not found. Run 'make sast-cosign-generate-key-pair' first."; \
		exit 1; \
	fi
	@if [ ! -f logs/sbom/sbom.cdx.json ]; then \
		echo "Error: logs/sbom/sbom.cdx.json not found. Run 'make sast-trivy-sbom-cyclonedx <image_name>' first."; \
		exit 1; \
	fi

	$(SSCS_COSIGN_ALIAS) attest --key cosign.key --type cyclonedx --predicate logs/sbom/sbom.cdx.json "$(filter-out $@,$(MAKECMDGOALS))"
.PHONY: sast-cosign-attest

# Usage: make sast-cosign-verify <image_name>
#
## Verify SBOM attestation for an image using Cosign
sast-cosign-verify:
	@if [ -z "$(filter-out $@,$(MAKECMDGOALS))" ]; then \
		echo "usage: make sast-cosign-verify <image_name>"; \
		exit 1; \
	fi
	@if [ ! -f cosign.pub ]; then \
		echo "Error: cosign.pub not found. Run 'make sast-cosign-generate-key-pair' first."; \
		exit 1; \
	fi

	@mkdir -p logs/sast

	$(SSCS_COSIGN_ALIAS) verify-attestation --key cosign.pub --type cyclonedx "$(filter-out $@,$(MAKECMDGOALS))" > logs/sbom/sbom.cdx.intoto.jsonl 2> logs/sast/cosign-verify.log
.PHONY: sast-cosign-verify

# ─── Certificate Manager ─────────────────────────────────────────────────────────────────────────

CERT_HOSTNAME ?=
CERT_DIR ?= $(K8S_CLUSTER_PATH)
CERT_DAYS ?= 365

# Usage: make cert-certificate-generate CERT_HOSTNAME=<hostname-or-url> [CERT_DIR=<directory>] [CERT_DAYS=<days>]
#
## Generate a self-signed TLS certificate for a local hostname or URL
cert-certificate-generate:
	@raw_hostname="$(strip $(CERT_HOSTNAME))"
	if [[ -z "$$raw_hostname" ]]; then
		echo "usage: make cert-certificate-generate CERT_HOSTNAME=<hostname-or-url> [CERT_DIR=<directory>] [CERT_DAYS=<days>]" >&2
		exit 1
	fi

	hostname="$$raw_hostname"
	hostname="$${hostname#*://}"
	hostname="$${hostname%%/*}"
	hostname="$${hostname%%\?*}"
	hostname="$${hostname%%\#*}"
	hostname="$${hostname%%:*}"

	if (( $${#hostname} > 253 )) || [[ ! "$$hostname" =~ ^[A-Za-z0-9]([A-Za-z0-9.-]*[A-Za-z0-9])?$$ ]] || [[ "$$hostname" == *..* ]]; then
		echo "error: invalid hostname derived from '$(CERT_HOSTNAME)': $$hostname" >&2
		exit 1
	fi
	if [[ ! "$(CERT_DAYS)" =~ ^[1-9][0-9]*$$ ]]; then
		echo "error: CERT_DAYS must be a positive integer" >&2
		exit 1
	fi
	if ! command -v openssl >/dev/null 2>&1; then
		echo "error: openssl is required to generate a self-signed certificate" >&2
		exit 1
	fi

	output_dir="$(CERT_DIR)"
	certificate_path="$$output_dir/$$hostname+1.pem"
	private_key_path="$$output_dir/$$hostname+1-key.pem"
	mkdir -p "$$output_dir"

	umask 077
	openssl req \
		-x509 \
		-nodes \
		-newkey rsa:2048 \
		-sha256 \
		-days "$(CERT_DAYS)" \
		-keyout "$$private_key_path" \
		-out "$$certificate_path" \
		-subj "/CN=$$hostname" \
		-addext "subjectAltName=DNS:$$hostname"
	chmod 0644 "$$certificate_path"

	printf 'Generated self-signed certificate for %s\n  certificate: %s\n  private key: %s\n' \
		"$$hostname" "$$certificate_path" "$$private_key_path"
.PHONY: cert-certificate-generate

# ─── Skills Manager ──────────────────────────────────────────────────────────────────────────────

## Provision new Agent Skills into the project environment
agent-skills-add:
	DISABLE_TELEMETRY=1 \
	npx skills@latest add sentenz/skills
.PHONY: agent-skills-add

## Synchronize and update existing Agent Skills in the project environment
agent-skills-update:
	DISABLE_TELEMETRY=1 \
	npx skills@latest update sentenz/skills \
		--skills adr \
		--skills cpp-api-documentation \
		--skills cpp-benchmark-testing \
		--skills cpp-fuzz-testing \
		--skills cpp-mock-testing \
		--skills cpp-unit-testing \
		--skills google-cpp-style-guide \
		-y
.PHONY: agent-skills-update
