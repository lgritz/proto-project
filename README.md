Master README for the project goes here.

Proto-Project is an example project setup meant to incorporate best
practices from my "real" projects, so that it can be quickly stamped down to
initialize a new project, and have a robust organizational setup and build
system.

The basic setup is cobbled together from my big projects, OpenImageIO
and OSL. In fact, the goal is to have Proto-Project serve as a kind of
"synchronization base" between them, and other projects, for  how the
build systems work.

The idea is that the project prototype has a fully working example of
everything I might need (not all implemented yet):

* A C++ library with a public API and header file.
* Python bindings for the library (using PyBind11 or boost.Python).
* Unit tests for the library and testsuite for the binary.
* A command-line binary that calls the library.
* A GUI program using Qt.
* CMake-based build system.
* TravisCI and Appveyor build and testsuite.
* All the right stubs for readmes, license files, CLAs, release notes,
  documentation, etc.
