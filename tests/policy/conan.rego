package tests.policy

import rego.v1

is_conan if {
	input.requires
}

# METADATA
# title: Conan dependency version pinning
# description: Ensure Conan dependencies are pinned to a specific version
# custom:
#   severity: medium
# entrypoint: true
deny_conan contains msg if {
	is_conan

	some requirement in input.requires
	parts := split(requirement, "/")
	version := parts[1]

	not is_strict_semver(version)
	msg := sprintf("Dependency '%s' uses ranged version specifier '%s'. Pin to the exact semantic versioning tag like 'v1.2.3'.", [requirement, version])
}

is_strict_semver(v) if {
	is_string(v)
	regex.match(`^v?\d+\.\d+\.\d+$`, v)
}
