root := justfile_directory()

export TYPST_ROOT := root

# The build and the tests run through the typst Python package in the project venv, so no
# Typst binary and no global installs are needed. See CONTRIBUTING.md for the setup.
python := if os_family() == "windows" { root / ".venv/Scripts/python.exe" } else { root / ".venv/bin/python" }

[private]
default:
	@just --list --unsorted

# compile the template to build/thesis.pdf
build:
	{{ python }} scripts/build.py

# compile and rasterise every page to build/pages/
render *args:
	{{ python }} scripts/build.py --render {{ args }}

# regenerate the rendered example committed at the repository root
example:
	{{ python }} scripts/build.py -o example.pdf

# run the regression suites
test:
	{{ python }} tests/check_layout.py
	{{ python }} tests/check_variants.py

# package the library into the specified destination folder
package target:
  ./scripts/package "{{target}}"

# install the library with the "@local" prefix
install: (package "@local")

# install the library with the "@preview" prefix (for pre-release testing)
install-preview: (package "@preview")

[private]
remove target:
  ./scripts/uninstall "{{target}}"

# uninstalls the library from the "@local" prefix
uninstall: (remove "@local")

# uninstalls the library from the "@preview" prefix (for pre-release testing)
uninstall-preview: (remove "@preview")

# run ci suite
ci: test
