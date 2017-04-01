#########################################################################
#
# This is the master makefile.
# Here we put all the top-level make targets, platform-independent
# rules, etc.
#
# Run 'make help' to list helpful targets.
#
#########################################################################


.PHONY: all debug profile clean realclean doxygen nuke

working_dir	:= ${shell pwd}
INSTALLDIR	=${working_dir}

# Figure out which architecture we're on
include ${working_dir}/src/make/detectplatform.mk

# Presence of make variables DEBUG and PROFILE cause us to make special
# builds, which we put in their own areas.
ifdef DEBUG
    variant +=.debug
endif
ifdef PROFILE
    variant +=.profile
endif

MY_MAKE_FLAGS ?=
MY_NINJA_FLAGS ?=
MY_CMAKE_FLAGS += -g3 -DSELF_CONTAINED_INSTALL_TREE:BOOL=TRUE
BUILDSENTINEL ?= Makefile
NINJA ?= ninja
CMAKE ?= cmake

# Site-specific build instructions
ifndef SITE
    SITE := ${shell uname -n}
endif
#ifneq (${shell echo ${SITE} | grep MYSITENAME},)
#include ${working_dir}/site/spi/Makefile-bits
#endif

# Set up variables holding the names of platform-dependent directories --
# set these after evaluating site-specific instructions
top_build_dir := build
build_dir     := ${top_build_dir}/${platform}${variant}
top_dist_dir  := dist
dist_dir      := ${top_dist_dir}/${platform}${variant}

VERBOSE ?= ${SHOWCOMMANDS}
ifneq (${VERBOSE},)
MY_MAKE_FLAGS += VERBOSE=${VERBOSE}
MY_CMAKE_FLAGS += -DVERBOSE:BOOL=${VERBOSE}
ifneq (${VERBOSE},0)
	MY_NINJA_FLAGS += -v
	TEST_FLAGS += -V
endif
$(info SITE = ${SITE})
$(info dist_dir = ${dist_dir})
$(info INSTALLDIR = ${INSTALLDIR})
endif

ifneq (${NAMESPACE},)
MY_CMAKE_FLAGS += -DNAMESPACE:STRING=${NAMESPACE}
endif

ifneq (${HIDE_SYMBOLS},)
MY_CMAKE_FLAGS += -DHIDE_SYMBOLS:BOOL=${HIDE_SYMBOLS}
endif

ifneq (${USE_PYTHON},)
MY_CMAKE_FLAGS += -DUSE_PYTHON:BOOL=${USE_PYTHON}
endif

ifneq (${USE_PYTHON3},)
MY_CMAKE_FLAGS += -DUSE_PYTHON3:BOOL=${USE_PYTHON3}
endif

ifneq (${PYTHON_VERSION},)
MY_CMAKE_FLAGS += -DPYTHON_VERSION:STRING=${PYTHON_VERSION}
endif

ifneq (${OPENEXR_HOME},)
MY_CMAKE_FLAGS += -DOPENEXR_HOME:STRING=${OPENEXR_HOME}
endif

ifneq (${ILMBASE_HOME},)
MY_CMAKE_FLAGS += -DILMBASE_HOME:STRING=${ILMBASE_HOME}
endif

ifneq (${BOOST_HOME},)
MY_CMAKE_FLAGS += -DBOOST_ROOT:STRING=${BOOST_HOME}
endif

ifneq (${STOP_ON_WARNING},)
MY_CMAKE_FLAGS += -DSTOP_ON_WARNING:BOOL=${STOP_ON_WARNING}
endif

ifneq (${BUILDSTATIC},)
MY_CMAKE_FLAGS += -DBUILDSTATIC:BOOL=${BUILDSTATIC}
endif

ifneq (${LINKSTATIC},)
MY_CMAKE_FLAGS += -DLINKSTATIC:BOOL=${LINKSTATIC}
endif

ifneq (${BUILD_TOOLS},)
MY_CMAKE_FLAGS += -DBUILD_TOOLS:BOOL=${BUILD_TOOLS}
endif

ifneq (${BUILD_TESTS},)
MY_CMAKE_FLAGS += -DBUILD_TESTS:BOOL=${BUILD_TESTS}
endif

ifneq (${SOVERSION},)
MY_CMAKE_FLAGS += -DSOVERSION:STRING=${SOVERSION}
endif

ifdef DEBUG
MY_CMAKE_FLAGS += -DCMAKE_BUILD_TYPE:STRING=Debug
endif

ifdef PROFILE
MY_CMAKE_FLAGS += -DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo
endif

ifneq (${MYCC},)
MY_CMAKE_FLAGS += -DCMAKE_C_COMPILER:STRING="${MYCC}"
endif
ifneq (${MYCXX},)
MY_CMAKE_FLAGS += -DCMAKE_CXX_COMPILER:STRING="${MYCXX}"
endif

ifneq (${USE_CPP},)
MY_CMAKE_FLAGS += -DUSE_CPP=${USE_CPP}
endif

ifneq (${USE_LIBCPLUSPLUS},)
MY_CMAKE_FLAGS += -DUSE_LIBCPLUSPLUS:BOOL=${USE_LIBCPLUSPLUS}
endif

ifneq (${EXTRA_CPP_ARGS},)
MY_CMAKE_FLAGS += -DEXTRA_CPP_ARGS:STRING="${EXTRA_CPP_ARGS}"
endif

ifneq (${USE_SIMD},)
MY_CMAKE_FLAGS += -DUSE_SIMD:STRING="${USE_SIMD}"
endif

ifneq (${TEST},)
TEST_FLAGS += -R ${TEST}
endif

ifneq (${USE_CCACHE},)
MY_CMAKE_FLAGS += -DUSE_CCACHE:BOOL=${USE_CCACHE}
endif

ifeq (${USE_NINJA},1)
MY_CMAKE_FLAGS += -G Ninja
BUILDSENTINEL := build.ninja
endif

ifneq (${CODECOV},)
MY_CMAKE_FLAGS += -DCMAKE_BUILD_TYPE:STRING=Debug -DCODECOV:BOOL=${CODECOV}
endif

ifneq (${SANITIZE},)
MY_CMAKE_FLAGS += -DSANITIZE=${SANITIZE}
endif

ifneq (${CLANG_TIDY},)
  MY_CMAKE_FLAGS += -DCLANG_TIDY:BOOL=1
endif
ifneq (${CLANG_TIDY_CHECKS},)
  MY_CMAKE_FLAGS += -DCLANG_TIDY_CHECKS:STRING=${CLANG_TIDY_CHECKS}
endif
ifneq (${CLANG_TIDY_ARGS},)
  MY_CMAKE_FLAGS += -DCLANG_TIDY_ARGS:STRING=${CLANG_TIDY_ARGS}
endif
ifneq (${CLANG_TIDY_FIX},)
  MY_CMAKE_FLAGS += -DCLANG_TIDY_FIX:BOOL=${CLANG_TIDY_FIX}
  MY_NINJA_FLAGS += -j 1
  # N.B. when fixing, you don't want parallel jobs!
endif

#$(info MY_CMAKE_FLAGS = ${MY_CMAKE_FLAGS})
#$(info MY_MAKE_FLAGS = ${MY_MAKE_FLAGS})

#########################################################################




#########################################################################
# Top-level documented targets

all: dist

# 'make debug' is implemented via recursive make setting DEBUG
debug:
	${MAKE} DEBUG=1 --no-print-directory

# 'make profile' is implemented via recursive make setting PROFILE
profile:
	${MAKE} PROFILE=1 --no-print-directory

# 'make cmakesetup' constructs the build directory and runs 'cmake' there,
# generating makefiles to build the project.  For speed, it only does this when
# ${build_dir}/Makefile doesn't already exist, in which case we rely on the
# cmake generated makefiles to regenerate themselves when necessary.
cmakesetup:
	@ (if [ ! -e ${build_dir}/${BUILDSENTINEL} ] ; then \
		${CMAKE} -E make_directory ${build_dir} ; \
		cd ${build_dir} ; \
		${CMAKE} -DCMAKE_INSTALL_PREFIX=${INSTALLDIR}/${dist_dir} \
			${MY_CMAKE_FLAGS} -DBOOST_ROOT=${BOOST_HOME} \
			../.. ; \
	 fi)

ifeq (${USE_NINJA},1)

# 'make cmake' does a basic build (after first setting it up)
cmake: cmakesetup
	@ ( cd ${build_dir} ; ${NINJA} ${MY_NINJA_FLAGS} )

# 'make cmakeinstall' builds everthing and installs it in 'dist'.
# Suppress pointless output from docs installation.
cmakeinstall: cmake
	@ ( cd ${build_dir} ; ${NINJA} ${MY_NINJA_FLAGS} install | grep -v '^-- \(Installing\|Up-to-date\|Set runtime path\)' )

# 'make package' builds everything and then makes an installable package
# (platform dependent -- may be .tar.gz, .sh, .dmg, .rpm, .deb. .exe)
package: cmakeinstall
	@ ( cd ${build_dir} ; ${NINJA} ${MY_NINJA_FLAGS} package )

# 'make package_source' makes an installable source package
# (platform dependent -- may be .tar.gz, .sh, .dmg, .rpm, .deb. .exe)
package_source: cmakeinstall
	@ ( cd ${build_dir} ; ${NINJA} ${MY_NINJA_FLAGS} package_source )

else

# 'make cmake' does a basic build (after first setting it up)
cmake: cmakesetup
	@ ( cd ${build_dir} ; ${MAKE} ${MY_MAKE_FLAGS} )

# 'make cmakeinstall' builds everthing and installs it in 'dist'.
# Suppress pointless output from docs installation.
cmakeinstall: cmake
	@ ( cd ${build_dir} ; ${MAKE} ${MY_MAKE_FLAGS} install | grep -v '^-- \(Installing\|Up-to-date\|Set runtime path\)' )

# 'make package' builds everything and then makes an installable package
# (platform dependent -- may be .tar.gz, .sh, .dmg, .rpm, .deb. .exe)
package: cmakeinstall
	@ ( cd ${build_dir} ; ${MAKE} ${MY_MAKE_FLAGS} package )

# 'make package_source' makes an installable source package
# (platform dependent -- may be .tar.gz, .sh, .dmg, .rpm, .deb. .exe)
package_source: cmakeinstall
	@ ( cd ${build_dir} ; ${MAKE} ${MY_MAKE_FLAGS} package_source )

endif

# 'make dist' is just a synonym for 'make cmakeinstall'
dist : cmakeinstall

TEST_FLAGS += --force-new-ctest-process --output-on-failure

# 'make test' does a full build and then runs all tests
test: cmake
	@ ${CMAKE} -E cmake_echo_color --switch=$(COLOR) --cyan "Running tests ${TEST_FLAGS}..."
	@ # if [ "${CODECOV}" == "1" ] ; then lcov -b ${build_dir} -d ${build_dir} -z ; rm -rf ${build_dir}/cov ; fi
	@ ( cd ${build_dir} ; PYTHONPATH=${PWD}/${build_dir}/src/python ctest -E broken ${TEST_FLAGS} )
	@ ( if [ "${CODECOV}" == "1" ] ; then \
	      cd ${build_dir} ; \
	      lcov -b . -d . -c -o cov.info ; \
	      lcov --remove cov.info "/usr*" -o cov.info ; \
	      genhtml -o ./cov -t "Test coverage" --num-spaces 4 cov.info ; \
	  fi )

# 'make testall' does a full build and then runs all tests (even the ones
# that are expected to fail on some platforms)
testall: cmake
	${CMAKE} -E cmake_echo_color --switch=$(COLOR) --cyan "Running all tests ${TEST_FLAGS}..."
	( cd ${build_dir} ; PYTHONPATH=${PWD}/${build_dir}/src/python ctest ${TEST_FLAGS} )

# 'make clean' clears out the build directory for this platform
clean:
	${CMAKE} -E remove_directory ${build_dir}

# 'make realclean' clears out both build and dist directories for this platform
realclean: clean
	${CMAKE} -E remove_directory ${dist_dir}

# 'make nuke' blows away the build and dist areas for all platforms
nuke:
	${CMAKE} -E remove_directory ${top_build_dir}
	${CMAKE} -E remove_directory ${top_dist_dir}

doxygen:
	doxygen src/doc/Doxyfile

#########################################################################



# 'make help' prints important make targets
help:
	@echo "Targets:"
	@echo "  make              Build optimized binaries and libraries in ${dist_dir},"
	@echo "                        temporary build files in ${build_dir}"
	@echo "  make debug        Build unoptimized with symbols in ${dist_dir}.debug,"
	@echo "                        temporary build files in ${build_dir}.debug"
	@echo "  make profile      Build for profiling in ${dist_dir}.profile,"
	@echo "                        temporary build files in ${build_dir}.profile"
	@echo "  make clean        Remove the temporary files in ${build_dir}"
	@echo "  make realclean    Remove both ${build_dir} AND ${dist_dir}"
	@echo "  make nuke         Remove ALL of build and dist (not just ${platform})"
	@echo "  make test         Run tests"
	@echo "  make testall      Run all tests, even broken ones"
	@echo "  make doxygen      Build the Doxygen docs in ${top_build_dir}/doxygen"
	@echo ""
	@echo "Helpful modifiers:"
	@echo "  C++ compiler and build process:"
	@echo "      VERBOSE=1                Show all compilation commands"
	@echo "      STOP_ON_WARNING=0        Do not stop building if compiler warns"
	@echo "      SITE=xx                  Use custom site build mods"
	@echo "      MYCC=xx MYCXX=yy         Use custom compilers"
	@echo "      USE_CPP=14               Compile in C++14 mode (default is C++11)"
	@echo "      USE_LIBCPLUSPLUS=1       Use clang libc++"
	@echo "      EXTRA_CPP_ARGS=          Additional args to the C++ command"
	@echo "      USE_NINJA=1              Set up Ninja build (instead of make)"
	@echo "      USE_CCACHE=0             Disable ccache (even if available)"
	@echo "      CODECOV=1                Enable code coverage tests"
	@echo "      SANITIZE=name1,...       Enablie sanitizers (address, leak, thread)"
	@echo "      CLANG_TIDY=1             Run clang-tidy on all source (can be modified"
	@echo "                                  by CLANG_TIDY_ARGS=... and CLANG_TIDY_FIX=1"
	@echo "  Linking and libraries:"
	@echo "      HIDE_SYMBOLS=1           Hide symbols not in the public API"
	@echo "      SOVERSION=nn             Include the specifed major version number "
	@echo "                                  in the shared object metadata"
	@echo "      BUILDSTATIC=1            Build static library instead of shared"
	@echo "      LINKSTATIC=1             Link with static external libs when possible"
	@echo "  Finding and Using Dependencies:"
	@echo "      BOOST_HOME=path          Custom Boost installation"
	@echo "      OPENEXR_HOME=path        Custom OpenEXR installation"
	@echo "      ILMBASE_HOME=path        Custom IlmBase installation"
	@echo "      USE_QT=0                 Skip anything that needs Qt"
	@echo "      USE_PYTHON=0             Don't build the Python binding"
	@echo "      USE_PYTHON3=1            If 1, try to build against Python3, not 2.x"
	@echo "      PYTHON_VERSION=2.6       Specify the Python version"
	@echo "  Build-time options:"
	@echo "      NAMESPACE=name           Wrap everything in another namespace"
	@echo "      BUILD_TOOLS=0            Skip building the command-line tools"
	@echo "      BUILD_TESTS=0            Skip building the unit tests"
	@echo "      USE_SIMD=arch            Build with SIMD support (choices: 0, sse2, sse3,"
	@echo "                                  ssse3, sse4.1, sse4.2, f16c, avx, avx2"
	@echo "                                  comma-separated ok)"
	@echo "  make test, extra options:"
	@echo "      TEST=regex               Run only tests matching the regex"
	@echo ""

