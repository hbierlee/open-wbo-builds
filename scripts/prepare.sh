#!/bin/bash
set -x

# Base configure args
config_opts="--verbosity=4 \
    --parallel-jobs=2 \
    --enable-static --disable-shared \
    --without-blas --without-lapack --without-mumps --disable-bzlib \
    --no-third-party \
    --skip-update"

workspace="${GITHUB_WORKSPACE}"

if [[ "$CBC_PLATFORM" == "osx" ]]; then
    brew update  
    brew install bash dos2unix pkg-config
    ln -s /usr/local/bin/bash /usr/local/bin/coin-bash
    config_opts+=" --enable-cbc-parallel --tests none"
    echo "::set-output name=cflags::-arch x86_64 -arch arm64"
elif [[ "$CBC_PLATFORM" == "linux" ]]; then
    sudo apt-get update
    sudo apt-get -y install dos2unix
    sudo ln -s /bin/bash /usr/local/bin/coin-bash
    config_opts+=" --enable-cbc-parallel"
elif [[ "$CBC_PLATFORM" == "musl" ]]; then
    apt-get update
    apt-get -y install dos2unix pkg-config
    ln -s /bin/bash /usr/local/bin/coin-bash
    config_opts+=" --enable-cbc-parallel"
elif [[ "$CBC_PLATFORM" == "wasm" ]]; then
    apt-get update
    apt-get -y install dos2unix pkg-config
    ln -s /bin/bash /usr/local/bin/coin-bash
    config_opts+=" --tests none"
elif [[ "$CBC_PLATFORM" == "win64" ]]; then
    coin-bash.bat -c "pacman -S --noconfirm git subversion wget dos2unix pkg-config make"
    workspace="$(coin-bash.bat -c 'cygpath ${GITHUB_WORKSPACE}')"
    config_opts+=" --enable-cbc-parallel \
        --with-pthreadsw32-lflags=winpthreads.lib \
        --with-pthreadsw32-cflags=-I${workspace}/winpthreads/include \
        --with-pthreadsw32-lib=${workspace}/winpthreads/lib/winpthreads.lib \
        --with-pthreadsw32-incdir=${workspace}/winpthreads/include \
        --enable-msvc \
        --build=x86_64-w64-mingw32 \
        --tests none"
    # Force /MD /O2 on Windows
    echo "::set-output name=cflags::-MD -O2"
else
    echo "Unknown platform"
    exit 1
fi

build_type=$(basename $(dirname "$GITHUB_REF"))
build_version=$(basename "$GITHUB_REF")
config_opts+=" --prefix=${workspace}/dist/cbc-${build_type}-${build_version}-${CBC_PLATFORM}/cbc"

# Set environment for future steps
echo "CBC_BUILD_TYPE=${build_type}" >> $GITHUB_ENV
echo "CBC_VERSION=${build_version}" >> $GITHUB_ENV
echo "CBC_CONFIG_OPTS=${config_opts}" >> $GITHUB_ENV
echo "CBC_INSTALL_DIR=${GITHUB_WORKSPACE}/dist/cbc-${build_type}-${build_version}-${CBC_PLATFORM}/cbc" >> $GITHUB_ENV
