#!/bin/bash
#
# Install and configure all dependencies essential for development.

# -x: print a trace (debug)
# -u: treat unset variables
# -o pipefail: return value of a pipeline
set -uo pipefail

# Include Scripts

source ./../scripts/shell/pkg.sh

# Constant Variables

readonly -A PIP_PACKAGES=(
  ["gcovr"]="8.4"
  ["conan"]="2.21.0"
)

readonly -A GO_PACKAGES=(
  ["go.mozilla.org/sops/cmd/sops"]="3.4.0"
)

# Control Flow Logic

function setup() {
  local -i retval=0

  pkg_pip_install_list PIP_PACKAGES
  ((retval |= $?))

  pkg_pip_clean
  ((retval |= $?))

  pkg_go_install_list GO_PACKAGES
  ((retval |= $?))

  pkg_go_clean
  ((retval |= $?))

  return "${retval}"
}

setup
exit "${?}"
