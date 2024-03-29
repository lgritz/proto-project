#!/usr/bin/env bash
#

set -ex


#
# Install system packages when those are acceptable for dependencies.
#
if [[ "$ASWF_ORG" != ""  ]] ; then
    # Using ASWF CentOS container

    #ls /etc/yum.repos.d

    sudo yum install -y giflib giflib-devel && true
    if [[ "${USE_OPENCV}" != "0" ]] ; then
        sudo yum install -y opencv opencv-devel && true
    fi
    if [[ "${USE_FFMPEG}" != "0" ]] ; then
        sudo yum install -y ffmpeg ffmpeg-devel && true
    fi
    if [[ "${EXTRA_DEP_PACKAGES}" != "" ]] ; then
        time sudo yum install -y ${EXTRA_DEP_PACKAGES}
    fi

    if [[ "${CONAN_LLVM_VERSION}" != "" ]] ; then
        mkdir conan
        pushd conan
        # Simple way to conan install just one package:
        #   conan install clang/${CONAN_LLVM_VERSION}@aswftesting/ci_common1 -g deploy -g virtualenv
        # But the below method can accommodate multiple requirements:
        echo "[imports]" >> conanfile.txt
        echo "., * -> ." >> conanfile.txt
        echo "[requires]" >> conanfile.txt
        echo "clang/${CONAN_LLVM_VERSION}@aswftesting/ci_common1" >> conanfile.txt
        time conan install .
        echo "--ls--"
        ls -R .
        export PATH=$PWD/bin:$PATH
        export LD_LIBRARY_PATH=$PWD/lib:$LD_LIBRARY_PATH
        export LLVM_ROOT=$PWD
        popd
    fi

    if [[ "${CONAN_PACKAGES}" != "" ]] ; then
        export PATH=$PWD/conan/bin:$PATH
        export LD_LIBRARY_PATH=$PWD/conan/lib:$LD_LIBRARY_PATH
        mkdir -p conan
        pushd conan
        for pkg in ${CONAN_PACKAGES} ; do
            echo "Installing $pkg via Conan..."
            time conan install $pkg
        done
        popd
        ls -R conan
    fi

    if [[ "$CXX" == "icpc" || "$CC" == "icc" || "$USE_ICC" != "" ]] ; then
        # Lock down icc to 2022.1 because newer versions hosted on the Intel
        # repo require a glibc too new for the ASWF CentOS7-based containers
        # we run CI on.
        sudo cp src/build-scripts/oneAPI.repo /etc/yum.repos.d
        sudo /usr/bin/yum install -y intel-oneapi-compiler-dpcpp-cpp-and-cpp-classic-2022.1.0.x86_64
        set +e; source /opt/intel/oneapi/setvars.sh --config oneapi_2022.1.0.cfg; set -e
    elif [[ "$CXX" == "icpc" || "$CC" == "icc" || "$USE_ICC" != "" || "$CXX" == "icpx" || "$CC" == "icx" || "$USE_ICX" != "" ]] ; then
        # Lock down icx to 2023.1 because newer versions hosted on the Intel
        # repo require a libstd++ too new for the ASWF containers we run CI on
        # because their default install of gcc 9 based toolchain.
        sudo cp src/build-scripts/oneAPI.repo /etc/yum.repos.d
        sudo yum install -y intel-oneapi-compiler-dpcpp-cpp-and-cpp-classic-2023.1.0.x86_64
        # sudo yum install -y intel-oneapi-compiler-dpcpp-cpp-and-cpp-classic
        set +e; source /opt/intel/oneapi/setvars.sh; set -e
        echo "Verifying installation of Intel(r) oneAPI DPC++/C++ Compiler:"
        icpx --version
    fi

else
    # Using native Ubuntu runner

    time sudo apt-get update

    time sudo apt-get -q install -y \
        git cmake ninja-build ccache g++ \
        libboost-dev libboost-thread-dev libboost-filesystem-dev \
        libilmbase-dev libopenexr-dev \
        libtiff-dev libgif-dev libpng-dev
    if [[ "${SKIP_SYSTEM_DEPS_INSTALL}" != "1" ]] ; then
        time sudo apt-get -q install -y \
            libfreetype6-dev \
            locales wget \
            libopencolorio-dev \
            libtbb-dev \
            libopencv-dev
    fi
    if [[ "${QT_VERSION:-5}" == "5" ]] ; then
        time sudo apt-get -q install -y \
            qt5-default || /bin/true
    elif [[ "${QT_VERSION}" == "6" ]] ; then
        time sudo apt-get -q install -y qt6-base-dev || /bin/true
    fi
    if [[ "${EXTRA_DEP_PACKAGES}" != "" ]] ; then
        time sudo apt-get -q install -y ${EXTRA_DEP_PACKAGES}
    fi

    # Nonstandard python versions
    if [[ "${PYTHON_VERSION}" == "3.9" ]] ; then
        time sudo apt-get -q install -y python3.9-dev python3-numpy
        pip3 --version
        pip3 install numpy
    else
        pip3 install numpy
    fi

    export CMAKE_PREFIX_PATH=/usr/lib/x86_64-linux-gnu:$CMAKE_PREFIX_PATH

    if [[ "$CXX" == "g++-9" ]] ; then
        time sudo apt-get install -y g++-9
    elif [[ "$CXX" == "g++-10" ]] ; then
        time sudo apt-get install -y g++-10
    elif [[ "$CXX" == "g++-11" ]] ; then
        time sudo apt-get install -y g++-11
    elif [[ "$CXX" == "g++-12" ]] ; then
        time sudo apt-get install -y g++-12
    elif [[ "$CXX" == "g++-12" ]] ; then
        time sudo apt-get install -y g++-13
    fi

    if [[ "$CXX" == "icpc" || "$CC" == "icc" || "$USE_ICC" != "" || "$USE_ICX" != "" ]] ; then
        wget https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2023.PUB
        sudo apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS-2023.PUB
        echo "deb https://apt.repos.intel.com/oneapi all main" | sudo tee /etc/apt/sources.list.d/oneAPI.list
        time sudo apt-get update
        time sudo apt-get install -y intel-oneapi-compiler-dpcpp-cpp-and-cpp-classic
        set +e; source /opt/intel/oneapi/setvars.sh; set -e
    fi

fi

if [[ "$CMAKE_VERSION" != "" ]] ; then
    source src/build-scripts/build_cmake.bash
fi
cmake --version


#
# If we're using clang to compile on native Ubuntu, we need to install it.
# If on an ASWF CentOS docker container, it already is installed.
#
if [[ ("$CXX" == "clang++" && "$ASWF_ORG" == "") || "$LLVM_VERSION" != "" ]] ; then
    source src/build-scripts/build_llvm.bash
fi



#
# Packages we need to build from scratch.
#

source src/build-scripts/build_pybind11.bash

if [[ "$OPENEXR_VERSION" != "" ]] ; then
    source src/build-scripts/build_openexr.bash
fi

if [[ "$OPENCOLORIO_VERSION" != "" ]] ; then
    source src/build-scripts/build_opencolorio.bash
fi

if [[ "$OPENIMAGEIO_VERSION" != "" ]] ; then
    # There are many parts of OIIO we don't need to build
    export ENABLE_iinfo=0 ENABLE_iv=0 ENABLE_igrep=0
    export ENABLE_iconvert=0 ENABLE_testtex=0
    export ENABLE_BMP=0 ENABLE_cineon=0 ENABLE_DDS=0 ENABLE_DPX=0 ENABLE_FITS=0
    export ENABLE_ICO=0 ENABLE_iff=0 ENABLE_jpeg2000=0 ENABLE_PNM=0 ENABLE_PSD=0
    export ENABLE_RLA=0 ENABLE_SGI=0 ENABLE_SOCKET=0 ENABLE_SOFTIMAGE=0
    export ENABLE_TARGA=0 ENABLE_WEBP=0
    export OPENIMAGEIO_MAKEFLAGS="OIIO_BUILD_TESTS=0 BUILD_TESTING=0 USE_PYTHON=0 USE_OPENGL=0"
    export OPENIMAGEIO_CMAKE_FLAGS="${OPENIMAGEEIO_CMAKE_FLAGS} -DSTOP_ON_WARNING=OFF"
    source src/build-scripts/build_openimageio.bash
fi
export LD_LIBRARY_PATH=$OpenImageIO_ROOT/lib:$LD_LIBRARY_PATH
export DYLD_LIBRARY_PATH=$OpenImageIO_ROOT/lib:$DYLD_LIBRARY_PATH

if [[ "$ABI_CHECK" != "" ]] ; then
    source src/build-scripts/build_abi_tools.bash
fi

if [[ "$LIBJPEGTURBO_VERSION" != "" ]] ; then
    source src/build-scripts/build_libjpeg-turbo.bash
fi

if [[ "$USE_ICC" != "" ]] ; then
    # We used gcc for the prior dependency builds, but use icc for OIIO itself
    echo "which icpc:" $(which icpc)
    export CXX=icpc
    export CC=icc
fi

# Save the env for use by other stages
src/build-scripts/save-env.bash
