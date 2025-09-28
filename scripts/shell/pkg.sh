#!/bin/bash
#
# Library for package management actions.

source "$(dirname "${BASH_SOURCE[0]}")/log.sh"
source "$(dirname "${BASH_SOURCE[0]}")/util.sh"

# Generic package list iteration.
#
# Arguments:
#   $1 - function
#   $@ - packages
# Returns:
#   $? - Boolean
function pkg_list() {
  local func="${1:?function is missing}"
  local -n packages="${2:?array is missing}"

  local -i retval=0
  local -i result=0

  for key in "${!packages[@]}"; do
    "$func" "${key}" "${packages[$key]}"
    ((result = $?))
    ((retval |= "${result}"))

    log_message "package" "${key} ${packages[$key]}" "${result}"
  done

  return "${retval}"
}

# Install apt package dependency.
#
# Arguments:
#   $1 - package
#   $2 - version
# Returns:
#   $? - Boolean
function pkg_apt_install() {
  local package="${1:?package is missing}"
  local version="${2:-}"

  local -i retval=0

  # Check if package is already installed (any version)
  if command -v "${package}" &>/dev/null; then
    return 0
  fi

  if util_string_exist "${version}"; then
    apt install "${package}"="${version}" -qqq -y --no-install-recommends >/dev/null 2>&1
    ((retval = $?))
  else
    apt install "${package}" -qqq -y --no-install-recommends >/dev/null 2>&1
    ((retval = $?))
  fi

  return "${retval}"
}

# Uninstall apt package dependency.
#
# Arguments:
#   $1 - package
# Returns:
#   $? - Boolean
function pkg_apt_uninstall() {
  local package="${1:?package is missing}"

  local -i retval=0

  # Check if package is installed (any version)
  if ! command -v "${package}" &>/dev/null; then
    return 0
  fi

  apt remove -y -qqq "${package}" >/dev/null 2>&1
  ((retval = $?))

  return "${retval}"
}

# Update apt package dependencies.
#
# Arguments:
#   None
# Returns:
#   None
function pkg_apt_update() {
  apt update -qqq >/dev/null 2>&1
}

# Cleanup apt package dependencies.
#
# Arguments:
#   None
# Returns:
#   $? - Boolean
function pkg_apt_clean() {
  local -i retval=0

  apt -f install -y -qqq >/dev/null 2>&1
  ((retval |= $?))

  apt autoremove -y -qqq >/dev/null 2>&1
  ((retval |= $?))

  apt clean -qqq >/dev/null 2>&1
  ((retval |= $?))

  rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* >/dev/null 2>&1
  ((retval |= $?))

  log_message "clean" "apt" "${retval}"

  return "${retval}"
}

# Install apt package list dependencies.
#
# Arguments:
#   $@ - packages
# Returns:
#   $? - Boolean
function pkg_apt_install_list() {
  local -A packages="${1:?array is missing}"

  local -i retval=0

  pkg_apt_update
  pkg_list pkg_apt_install "${packages[@]}"
  ((retval |= $?))

  return "${retval}"
}

# Uninstall apt package list dependencies.
#
# Arguments:
#   $@ - packages
# Returns:
#   $? - Boolean
function pkg_apt_uninstall_list() {
  local -A packages=("$@")

  local -i retval=0

  pkg_list pkg_apt_uninstall "${packages[@]}"
  ((retval |= $?))

  return "${retval}"
}

# Install apk package dependency.
#
# Arguments:
#   $1 - package
#   $2 - version
# Returns:
#   $? - Boolean
function pkg_apk_install() {
  local package="${1:?package is missing}"
  local version="${2:-}"

  local -i retval=0

  # Check if package is already installed (any version)
  if command -v "${package}" &>/dev/null; then
    return 0
  fi

  if util_string_exist "${version}"; then
    apk add "${package}=${version}" --quiet --no-cache >/dev/null 2>&1
    ((retval = $?))
  else
    apk add "${package}" --quiet --no-cache >/dev/null 2>&1
    ((retval = $?))
  fi

  return "${retval}"
}

# Uninstall apk package dependency.
#
# Arguments:
#   $1 - package
# Returns:
#   $? - Boolean
function pkg_apk_uninstall() {
  local package="${1:?package is missing}"

  local -i retval=0

  # Check if package is installed (any version)
  if ! command -v "${package}" &>/dev/null; then
    return 0
  fi

  apk del --quiet "${package}" >/dev/null 2>&1
  ((retval = $?))

  return "${retval}"
}

# Update apk package dependencies.
#
# Arguments:
#   None
# Returns:
#   None
function pkg_apk_update() {
  apk update --quiet >/dev/null 2>&1
}

# Cleanup apk package dependencies.
#
# Arguments:
#   None
# Returns:
#   $? - Boolean
function pkg_apk_clean() {
  local -i retval=0

  apk fix --quiet >/dev/null 2>&1
  ((retval |= $?))

  apk cache clean --quiet >/dev/null 2>&1
  ((retval |= $?))

  rm -rf /var/cache/apk/* >/dev/null 2>&1
  ((retval |= $?))

  log_message "clean" "apk" "${retval}"

  return "${retval}"
}

# Install apk package list dependencies.
#
# Arguments:
#   $@ - packages
# Returns:
#   $? - Boolean
function pkg_apk_install_list() {
  local -A packages="${1:?array is missing}"

  local -i retval=0

  pkg_apk_update
  pkg_list pkg_apk_install "${packages[@]}"
  ((retval |= $?))

  return "${retval}"
}

# Uninstall apk package list dependencies.
#
# Arguments:
#   $@ - packages
# Returns:
#   $? - Boolean
function pkg_apk_uninstall_list() {
  local -A packages=("$@")

  local -i retval=0

  pkg_list pkg_apk_uninstall "${packages[@]}"
  ((retval |= $?))

  return "${retval}"
}

# Install pip package dependency.
#
# Arguments:
#   $1 - package
#   $2 - version
# Returns:
#   $? - Boolean
function pkg_pip_install() {
  local package="${1:?package is missing}"
  local version="${2:-}"

  local -i retval=0

  # Check if package is already installed (any version)
  if pipx -q list | grep -qE "^package ${package} " &>/dev/null; then
    return 0
  fi

  if util_string_exist "${version}"; then
    pipx -q install -q "${package}==${version}" >/dev/null 2>&1
    ((retval = $?))
  else
    pipx -q install -q "${package}" >/dev/null 2>&1
    ((retval = $?))
  fi

  return "${retval}"
}

# Install pip package list dependencies.
#
# Arguments:
#   $@ - packages
# Returns:
#   $? - Boolean
function pkg_pip_install_list() {
  local -A packages="${1:?array is missing}"

  local -i retval=0

  pkg_list pkg_pip_install "${packages[@]}"
  ((retval |= $?))

  return "${retval}"
}

# Uninstall pip package dependency.
#
# Arguments:
#   $1 - package
#   $2 - version
# Returns:
#   $? - Boolean
function pkg_pip_uninstall() {
  local package="${1:?package is missing}"
  local version="${2:-}"

  local -i retval=0

  # Check if package is installed (any version)
  if ! pipx -q list | grep -qE "^package ${package} " &>/dev/null; then
    return 0
  fi

  pipx -q uninstall -q "${package}" >/dev/null 2>&1
  ((retval |= $?))

  return "${retval}"
}

# Uninstall a list of pip package dependencies.
#
# Arguments:
#   $@ - packages
# Returns:
#   $? - Boolean
function pkg_pip_uninstall_list() {
  local -A packages="${1:?array is missing}"

  local -i retval=0

  pkg_list pkg_pip_uninstall "${packages[@]}"
  ((retval |= $?))

  return "${retval}"
}

# Cleanup pip package dependencies.
#
# Arguments:
#   None
# Returns:
#   $? - Boolean
function pkg_pip_clean() {
  local -i retval=0

  pip3 cache purge -q >/dev/null 2>&1
  ((retval |= $?))

  log_message "clean" "pip" "${retval}"

  return "${retval}"
}

# Install snap package dependency.
#
# Arguments:
#   $1 - package
#   $2 - version
# Returns:
#   $? - Boolean
function pkg_snap_install() {
  local package="${1:?package is missing}"
  local version="${2:-}"

  local -i retval=0

  # Check if package is already installed (any version)
  if command -v "${package}" &>/dev/null; then
    return 0
  fi

  if util_string_exist "${version}"; then
    snap install "${package}" --channel="${version}/stable" --classic >/dev/null 2>&1
    ((retval = $?))
  else
    snap install --stable "${package}" --classic >/dev/null 2>&1
    ((retval = $?))
  fi

  return "${retval}"
}

# Install snap package list dependencies.
#
# Arguments:
#   $@ - packages
# Returns:
#   $? - Boolean
function pkg_snap_install_list() {
  local -A packages="${1:?array is missing}"

  local -i retval=0

  pkg_list pkg_snap_install "${packages[@]}"
  ((retval |= $?))

  return "${retval}"
}

# Clean obsolete snap revisions.
#
# This function removes disabled revisions from the system,
# ensuring that only the active revision of each snap package is retained.
#
# Returns:
#   $? - Boolean indicating success.
function pkg_snap_clean() {
  local -i retval=0

  # TODO Implement `pkg_snap_clean` script function

  return "${retval}"
}

# Uninstall snap package dependency.
#
# Arguments:
#   $1 - package
# Returns:
#   $? - Boolean indicating success.
function pkg_snap_uninstall() {
  local package="${1:?package is missing}"

  local -i retval=0

  # Check if package is installed (any version)
  if ! command -v "${package}" &>/dev/null; then
    return 0
  fi

  snap remove "${package}" >/dev/null 2>&1
  ((retval = $?))

  return "${retval}"
}

# Uninstall a list of snap package dependencies.
#
# Arguments:
#   $@ - associative array of packages
# Returns:
#   $? - Boolean indicating success.
function pkg_snap_uninstall_list() {
  local -A packages="${1:?array is missing}"

  local -i retval=0

  pkg_list pkg_snap_uninstall "${packages[@]}"
  ((retval |= $?))

  return "${retval}"
}

# Install npm package dependency.
#
# Arguments:
#   $1 - package
#   $2 - version
# Returns:
#   $? - Boolean
function pkg_npm_install() {
  local package="${1:?package is missing}"
  local version="${2:-}"

  local -i retval=0

  # Check if package is already installed (any version)
  if npm list "${package}" -g --depth=0 &>/dev/null; then
    return 0
  fi

  npm install "${package}@${version:-latest}" --silent -g >/dev/null 2>&1
  ((retval = $?))

  return "${retval}"
}

# Install npm package list dependencies.
#
# Arguments:
#   $@ - packages
# Returns:
#   $? - Boolean
function pkg_npm_install_list() {
  local -A packages="${1:?array is missing}"

  local -i retval=0

  pkg_list pkg_npm_install "${packages[@]}"
  ((retval |= $?))

  return "${retval}"
}

# Uninstall npm package dependency.
#
# Arguments:
#   $1 - package
# Returns:
#   $? - Boolean
function pkg_npm_uninstall() {
  local package="${1:?package is missing}"

  local -i retval=0

  # Check if package is installed (any version)
  if npm list "${package}" -g --depth=0 &>/dev/null; then
    return 0
  fi

  npm uninstall "${package}" --silent -g >/dev/null 2>&1
  ((retval = $?))

  return "${retval}"
}

# Uninstall a list of npm package dependencies.
#
# Arguments:
#   $@ - packages
# Returns:
#   $? - Boolean
function pkg_npm_uninstall_list() {
  local -A packages="${1:?array is missing}"

  local -i retval=0

  pkg_list pkg_npm_uninstall "${packages[@]}"
  ((retval |= $?))

  return "${retval}"
}

# Cleanup npm package dependencies.
#
# Arguments:
#   None
# Returns:
#   $? - Boolean
function pkg_npm_clean() {
  local -i retval=0

  npm cache clean --force --silent >/dev/null 2>&1
  ((retval = $?))

  log_message "clean" "npm" "${retval}"

  return "${retval}"
}

# Install go package dependency.
#
# Arguments:
#   $1 - package
#   $2 - version
# Returns:
#   $? - Boolean
function pkg_go_install() {
  local package="${1:?package is missing}"
  local version="${2:-}"

  local -i retval=0

  # Check if package is already installed (any version)
  local package_path
  package_path="$(go env GOPATH)/bin/${package}"
  if [[ -x "${package_path}" ]]; then
    return 0
  fi

  go install "${package}"@"${version:-latest}" >/dev/null 2>&1
  ((retval = $?))

  return "${retval}"
}

# Install go package list dependencies.
#
# Arguments:
#   $@ - packages
# Returns:
#   $? - Boolean
function pkg_go_install_list() {
  local -A packages="${1:?array is missing}"

  local -i retval=0

  # XXX Add Go binaries to PATH
  PATH="${PATH}:$(go env GOPATH)/bin"
  export PATH

  pkg_list pkg_go_install "${packages[@]}"
  ((retval |= $?))

  return "${retval}"
}

# Uninstall go package dependency by removing its binary.
#
# Arguments:
#   $1 - Package import path or binary name (required)
#   $2 - version (optional, currently unused)
# Returns:
#   $? - 0 if binary was removed or did not exist, non-zero on error
function pkg_go_uninstall() {
  local package="${1:?package is missing}"
  local version="${2:-}"

  local -i retval=0

  # Check if package is installed (any version)
  local package_path
  package_path="$(go env GOPATH)/bin/${package}"
  if [[ ! -e "${package_path}" ]]; then
    return 0
  fi

  rm -f -- "${package_path}" >/dev/null 2>&1
  ((retval = $?))

  return "${retval}"
}

# Uninstall go package list dependencies.
#
# Arguments:
#   $@ - packages
# Returns:
#   $? - Boolean
function pkg_go_uninstall_list() {
  local -A packages="${1:?array is missing}"

  local -i retval=0

  pkg_list pkg_go_uninstall "${packages[@]}"
  ((retval |= $?))

  return "${retval}"
}

# Cleanup go package dependencies.
#
# Arguments:
#   None
# Returns:
#   $? - Boolean
function pkg_go_clean() {
  local -i retval=0

  # Cleans build cache
  go clean -cache >/dev/null 2>&1
  ((retval |= $?))

  # Cleans downloaded module dependencies
  go clean -modcache >/dev/null 2>&1
  ((retval |= $?))

  log_message "clean" "go" "${retval}"

  return "${retval}"
}

# Download a file using wget.
#
# Arguments:
#   $1 - URL (may contain `<version>` placeholder)
#   $2 - version string (optional)
# Returns:
#   $? - Boolean
function pkg_wget_download() {
  local url="${1:?URL is missing}"
  local version="${2:-}"

  local -i retval=0

  if util_string_exist "${version}"; then
    url="${url//<version>/$version}"
  fi

  local dest
  dest="$(basename "$url")"

  if util_file_exist "${dest}"; then
    return 0
  fi

  wget -q "$url" -O "$dest" >/dev/null 2>&1
  ((retval = $?))

  return "${retval}"
}

# Download a list of files using wget.
#
# Arguments:
#   $@ - packages
# Returns:
#   $? - Boolean
function pkg_wget_download_list() {
  local -A urls="${1:?array is missing}"

  local -i retval=0

  pkg_list pkg_wget_download "${urls[@]}"
  ((retval |= $?))

  return "${retval}"
}
