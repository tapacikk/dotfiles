#!/bin/bash

# Strict error handling
set -euo pipefail

# Script configuration
readonly SCRIPT_NAME="$(basename "$0")"
readonly LOG_DATE="$(date +%Y%m%d_%H%M%S)"

PREFIX_GLOBAL=/home/avi/scine/setUpPublic12_10_25
MKLROOT=/opt/intel/oneapi/mkl/latest
NUMPROCS=12
# module type can be "release" or "dev". Setting anything other than release will install dev.
MODULE_TYPE="release"

# versions
MONGO_C_VERSION=1.23.5
MONGO_CPP_VERSION=3.7.2
SCINE_UTILS_VERSION=10.1.0
SCINE_DATABASE_VERSION=1.5.0
SCINE_MOLASSEMBLER_VERSION=3.0.1
SCINE_READUCT_VERSION=6.1.0
SCINE_CORE_VERSION=6.0.2
SCINE_KINETX_VERSION=3.1.0
BOOST_VERSION=1.83.0
NUMPY_VERSION=1.24.2
SCIPY_VERSION=1.10.1
DEV_VERSION=10.0.0


# URLS
readonly SCINE_UTILS_URL="https://github.com/qcscine/utilities/archive/refs/tags/${SCINE_UTILS_VERSION}.tar.gz"
readonly SCINE_DATABASE_URL="https://github.com/qcscine/database/archive/refs/tags/${SCINE_DATABASE_VERSION}.tar.gz"
readonly SCINE_MOLASSEMBLER_URL="https://github.com/qcscine/molassembler/archive/refs/tags/${SCINE_MOLASSEMBLER_VERSION}.tar.gz"
readonly SCINE_READUCT_URL="https://github.com/qcscine/readuct/archive/refs/tags/${SCINE_READUCT_VERSION}.tar.gz"
readonly SCINE_CORE_URL="https://github.com/qcscine/core/archive/refs/tags/${SCINE_CORE_VERSION}.tar.gz"
readonly SCINE_KINETX_URL="https://github.com/qcscine/kinetx/archive/refs/tags/${SCINE_KINETX_VERSION}.tar.gz"
readonly MONGO_DB_C_DRIVER_URL="https://github.com/mongodb/mongo-c-driver/releases/download/${MONGO_C_VERSION}/mongo-c-driver-${MONGO_C_VERSION}.tar.gz"
readonly MONGO_DB_CPP_DRIVER_URL="https://github.com/mongodb/mongo-cxx-driver/archive/r${MONGO_CPP_VERSION}.tar.gz"
readonly BOOST_URL="https://github.com/boostorg/boost/releases/download/boost-${BOOST_VERSION}/boost-${BOOST_VERSION}.tar.gz"
readonly NUMPY_URL="https://github.com/numpy/numpy/releases/download/v${NUMPY_VERSION}/numpy-${NUMPY_VERSION}.tar.gz"
readonly SCIPY_URL="https://github.com/scipy/scipy/releases/download/v${SCIPY_VERSION}/scipy-${SCIPY_VERSION}.tar.gz"
readonly DEV_URL="https://github.com/qcscine/development-utils/archive/refs/tags/${DEV_VERSION}.tar.gz"
# this will require having ssh key set up to git 
readonly SCINE_CHEMOTON_URL="ssh://git@github.com/qcscine/chemoton.git"

# branches
SCINE_UTILS_BRANCH="add_vasp_interface"
SCINE_DATABASE_BRANCH="develop"
SCINE_MOLASSEMBLER_BRANCH="develop"
SCINE_READUCT_BRANCH="develop"
SCINE_CORE_BRANCH="develop"
SCINE_KINETX_BRANCH="develop"
SCINE_CHEMOTON_BRANCH="develop"

# gitlab URLS
# requires access to gitlab repos and ssh keys
readonly SCINE_UTILS_GITLABREPO="gitlab.chab.ethz.ch:scine/utils-open-source.git"
readonly SCINE_DATABASE_GITLABREPO="gitlab.chab.ethz.ch:scine/database.git"
readonly SCINE_MOLASSEMBLER_GITLABREPO="gitlab.chab.ethz.ch:scine/molassembler.git"
readonly SCINE_READUCT_GITLABREPO="gitlab.chab.ethz.ch:scine/readuct.git"
readonly SCINE_CORE_GITLABREPO="gitlab.chab.ethz.ch:scine/core.git"
readonly SCINE_KINETX_GITLABREPO="gitlab.chab.ethz.ch:scine/kinetx.git"
readonly SCINE_CHEMOTON_GITLABREPO="ssh://git@gitlab.chab.ethz.ch/scine/chemoton.git"

# Default CMAKE tags
SCINE_CMAKE_FLAGS="-DCMAKE_BUILD_TYPE=Release  -DSCINE_BUILD_TESTS=OFF  -DSCINE_BUILD_PYTHON_BINDINGS=ON  -DSCINE_MARCH=native SCINE_BUILD_DOCS=OFF -DMKL_ROOT=${MKLROOT} -DBUILD_SHARED_LIBS=ON"

# Logging functions
log_info() {
    echo "[INFO $(date '+%H:%M:%S')] $*"
}

log_error() {
    echo "[ERROR $(date '+%H:%M:%S')] $*" >&2
}

log_success() {
    echo "[SUCCESS $(date '+%H:%M:%S')] $*"
}

# Error handling function
handle_error() {
    local exit_code=$?
    local line_number=$1
    log_error "Script failed at line $line_number with exit code $exit_code"
    exit $exit_code
}

trap 'handle_error $LINENO' ERR


print_configuration() {
    log_info "Build configuration:"
    echo "  PREFIX_GLOBAL: $PREFIX_GLOBAL"
    echo "  MKLROOT: $MKLROOT"
    echo "  MONGO_C_VERSIONL: $MONGO_C_VERSION"
    echo "  MONGO_CPP_VERSION: $MONGO_CPP_VERSION"
    echo "  MONGO_C_VERSION: $MONGO_C_VERSION"
    echo "  MONGO_CPP_VERSION: $MONGO_CPP_VERSION"
    echo "  SCINE_UTILS_VERSION: $SCINE_UTILS_VERSION"
    echo "  SCINE_DATABASE_VERSION: $SCINE_DATABASE_VERSION"
    echo "  SCINE_MOLASSEMBLER_VERSION: $SCINE_MOLASSEMBLER_VERSION"
    echo "  SCINE_READUCT_VERSION: $SCINE_READUCT_VERSION"
    echo "  SCINE_CORE_VERSION: $SCINE_CORE_VERSION"
    echo "  DEV_VERSION: $DEV_VERSION"
    echo "  BOOST_VERSION: $BOOST_VERSION"
    echo "  NUMPROCS: $NUMPROCS"
    echo " Good luck."
}


setup_environment() {
    SCINE_ENV_DIR=${PREFIX_GLOBAL}/scine-env
    log_info "Cleaning up the previous environment"
    rm -rf $SCINE_ENV_DIR
    python3.11 -m venv $SCINE_ENV_DIR
    source $SCINE_ENV_DIR/bin/activate
    log_success "venv set"
    pip install pybind11
    log_success "installed pybind11"
    pip install cython==0.29.36
    log_success "installed cython"
    pip install scipy==${SCIPY_VERSION}
    log_success "installed scipy"
}

install_scine_module_gitlab () {
    # $1 needs to be subdir name, it will be created under ${PREFIX_GLOBAL/$1
    # $2 needs to be the gitlab repository url
    # $3 needs to be the branch to checkout
    
    echo "using gitlab private repos"

    # args
    MODULE_NAME=$1
    MODULE_URL=$2
    MODULE_BRANCH=$3

    #config
    MODULE_DIR=${PREFIX_GLOBAL}/$MODULE_NAME
    
    # env setup
    SCINE_ENV_DIR=${PREFIX_GLOBAL}/scine-env
    source $SCINE_ENV_DIR/bin/activate
    
    log_info "Cleaning up previous build..."
    rm -rf $MODULE_DIR 
    mkdir -p $MODULE_DIR
    log_info "Preparing the environment..."
    SCINE_ENV_DIR=${PREFIX_GLOBAL}/scine-env
    source $SCINE_ENV_DIR/bin/activate

    # get git repository
    git clone git@${MODULE_URL} ${MODULE_DIR}
    
    # checkout branch
    log_info "Checking out the branch ${MODULE_BRANCH}"
    pushd ${MODULE_DIR}
    git checkout $MODULE_BRANCH
    log_success "checked out"

    # install and update the dev submodule
    log_info "inniting submodules of branch"
    git submodule init 
    git submodule update
    log_success "nice!"

    # build
    mkdir build
    pushd build
    echo $PWD
    cmake .. \
    -DCMAKE_INSTALL_PREFIX=${PREFIX_GLOBAL}/puffin/software/install \
    $SCINE_CMAKE_FLAGS 
    > cmake_config_log.log
    make -j ${NUMPROCS}
    make install
    popd
    popd
    log_success "we did that. (${MODULE_NAME})"
}

install_scine_module () {
    # $1 needs to be subdir name, it will be created under ${PREFIX_GLOBAL}/$1
    # $2 needs to be tarball url
    # $3 needs module version
    
    # args
    MODULE_NAME=$1
    MODULE_URL=$2
    MODULE_VERSION=$3

    # config
    MODULE_DIR=${PREFIX_GLOBAL}/$MODULE_NAME
    MODULE_TARBALL_DIR=${MODULE_DIR}/tarballs

    # env setup
    SCINE_ENV_DIR=${PREFIX_GLOBAL}/scine-env
    source $SCINE_ENV_DIR/bin/activate
    
    log_info "Cleaning up previous build..."
    rm -rf $MODULE_DIR 
    mkdir -p $MODULE_DIR $MODULE_TARBALL_DIR
    log_info "Preparing the environment..."
    SCINE_ENV_DIR=${PREFIX_GLOBAL}/scine-env
    source $SCINE_ENV_DIR/bin/activate

    # get tarball
    pushd $MODULE_TARBALL_DIR
    wget $MODULE_URL
    popd

    # untar
    pushd $MODULE_DIR
    tar xf $MODULE_TARBALL_DIR/$MODULE_VERSION.tar.gz
    popd

    pushd $MODULE_DIR/$MODULE_NAME-$MODULE_VERSION
    # init the dev
    pushd $MODULE_TARBALL_DIR
    wget $DEV_URL
    popd
    tar xf $MODULE_TARBALL_DIR/$DEV_VERSION.tar.gz
    rmdir dev
    mv development-utils-$DEV_VERSION dev

    mkdir build
    cd build
    echo $PWD
    cmake .. \
    -DCMAKE_INSTALL_PREFIX=${PREFIX_GLOBAL}/puffin/software/install \
    $SCINE_CMAKE_FLAGS 
    > cmake_config_log.log
    make -j ${NUMPROCS}
    make install
    popd

    log_success "we did do that. ($MODULE_NAME)"
}


install_numpy() {
    NUMPY_DIR=${PREFIX_GLOBAL}/scine-numpy
    NUMPY_TARBALLS_DIR=${NUMPY_DIR}/tarballs
    SCINE_ENV_DIR=${PREFIX_GLOBAL}/scine-env
    
    log_info "Cleaning up previous build..."
    rm -rf $NUMPY_DIR 
    mkdir $NUMPY_DIR $NUMPY_TARBALLS_DIR

    pushd $NUMPY_DIR

    source $SCINE_ENV_DIR/bin/activate


    pushd $NUMPY_TARBALLS_DIR
    wget $NUMPY_URL
    popd
    tar xf $NUMPY_TARBALLS_DIR/numpy-${NUMPY_VERSION}.tar.gz
    pushd numpy-${NUMPY_VERSION}

    cp site.cfg.example site.cfg  
    echo -e "\n[mkl]" >> site.cfg  
    echo "include_dirs = ${MKLROOT}/intel64/" >> site.cfg  
    echo "library_dirs = ${MKLROOT}/lib/intel64/" >> site.cfg  
    echo "mkl_libs = mkl_rt" >> site.cfg  
    echo "lapack_libs =" >> site.cfg
    python3 setup.py build --fcompiler=gnu95
    python3 setup.py install

    popd
    popd
    log_success "we did do that. (numpy)"
    
}



install_scipy() {
    SCIPY_DIR=${PREFIX_GLOBAL}/scine-scipy
    SCINE_ENV_DIR=${PREFIX_GLOBAL}/scine-env
    
    log_info "Cleaning up previous build..."
    rm -rf $SCIPY_DIR
    mkdir $SCIPY_DIR
    pushd $SCIPY_DIR

    # env setup
    source $SCINE_ENV_DIR/bin/activate
    if [[ $LD_LIBRARY_PATH != "" ]];then 
        export LD_LIBRARY_PATH=/opt/intel/oneapi/mkl/latest/lib:$LD_LIBRARY_PATH
    else
        LD_LIBRARY_PATH=/opt/intel/oneapi/mkl/latest/lib
    fi

    git clone https://github.com/scipy/scipy.git .
    git checkout v1.10.1
    git submodule update --init
    python3 setup.py build
    python3 setup.py install

    popd
    log_success "we did do that. (scipy)"
    
}


install_boost() {

    BOOST_DIR=${PREFIX_GLOBAL}/boost
    BOOST_TARBALL_DIR=${BOOST_DIR}/tarballs
    BOOST_INSTALL_DIR=${BOOST_DIR}/${BOOST_VERSION}
    # env setup
    SCINE_ENV_DIR=${PREFIX_GLOBAL}/scine-env
    source $SCINE_ENV_DIR/bin/activate
    
    log_info "Cleaning up previous build..."
    rm -rf $BOOST_DIR
    mkdir -p $BOOST_TARBALL_DIR
    pushd $BOOST_TARBALL_DIR
    wget $BOOST_URL
    popd
    pushd $BOOST_DIR
    tar xzf "$BOOST_TARBALL_DIR/boost-${BOOST_VERSION}.tar.gz"
    popd
    pushd "$BOOST_DIR/boost-${BOOST_VERSION}"
    mkdir build
    cd build
    cmake .. -DCMAKE_INSTALL_PREFIX=${BOOST_DIR}/${BOOST_VERSION} -DBUILD_SHARED_LIBS=ON
    make -j12
    make install
    popd

    log_success "Boost compiled succesfully!"
    
}


install_mongo_c() {

    MONGO_DIR=${PREFIX_GLOBAL}/mongo
    MONGO_C_DIR=${PREFIX_GLOBAL}/mongo/c
    MONGO_C_TARBALL_DIR=${MONGO_C_DIR}/tarballs
    MONGO_C_INSTALL_DIR=${MONGO_C_DIR}/${MONGO_C_VERSION}
    # env setup
    SCINE_ENV_DIR=${PREFIX_GLOBAL}/scine-env
    source $SCINE_ENV_DIR/bin/activate
    
    log_info "Cleaning up previous build..."
    rm -rf $MONGO_C_DIR
    mkdir -p $MONGO_C_TARBALL_DIR
    pushd $MONGO_C_TARBALL_DIR
    wget $MONGO_DB_C_DRIVER_URL
    popd
    pushd $MONGO_C_DIR
    tar xzf "$MONGO_C_TARBALL_DIR/mongo-c-driver-${MONGO_C_VERSION}.tar.gz"
    popd
    pushd "$MONGO_C_DIR/mongo-c-driver-${MONGO_C_VERSION}"
    mkdir cmake-build
    cd cmake-build
    cmake -DCMAKE_BUILD_TYPE=Release -DENABLE_AUTOMATIC_INIT_AND_CLEANUP=OFF -DCMAKE_INSTALL_PREFIX=$MONGO_C_INSTALL_DIR  -DENABLE_STATIC=ON ..
    make -j8
    make install

    popd

    log_success "we did do that. (mongo_c)"
    
}


install_mongo_cpp() {

    MONGO_DIR=${PREFIX_GLOBAL}/mongo
    MONGO_CPP_DIR=${PREFIX_GLOBAL}/mongo/cpp
    MONGO_CPP_TARBALL_DIR=${MONGO_CPP_DIR}/tarballs
    MONGO_CPP_INSTALL_DIR="${MONGO_CPP_DIR}/${MONGO_CPP_VERSION}"
    # env setup
    SCINE_ENV_DIR=${PREFIX_GLOBAL}/scine-env
    source $SCINE_ENV_DIR/bin/activate
    
    log_info "Cleaning up previous build..."
    rm -rf $MONGO_CPP_DIR
    mkdir -p $MONGO_CPP_TARBALL_DIR
    pushd $MONGO_CPP_TARBALL_DIR
    wget $MONGO_DB_CPP_DRIVER_URL
    popd
    pushd $MONGO_CPP_DIR
    tar xzf $MONGO_CPP_TARBALL_DIR/r${MONGO_CPP_VERSION}.tar.gz
    popd
    pushd "$MONGO_CPP_DIR/mongo-cxx-driver-r${MONGO_CPP_VERSION}"
    mkdir -p build
    cd build
    cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_VERSION=3.7.2 \
    -DENABLE_AUTOMATIC_INIT_AND_CLEANUP=OFF \
    -DCMAKE_INSTALL_PREFIX=$MONGO_CPP_INSTALL_DIR \
    -DBUILD_SHARED_AND_STATIC_LIBS=ON -DBUILD_SHARED_LIBS_WITH_STATIC_=ON \
    -DCMAKE_PREFIX_PATH=${PREFIX_GLOBAL}/mongo/c/${MONGO_C_VERSION}
    make -j ${NUMPROCS}
    make install

    popd

    log_success "we did do that. (mongo_cpp)"
    
}


install_puffin() {

    # env setup
    SCINE_ENV_DIR=${PREFIX_GLOBAL}/scine-env
    source $SCINE_ENV_DIR/bin/activate
    pip install scine_puffin
    
    log_success "we did do that. (puffin)"
    
}


instantiate_puffin() {
    INSTANCE_DIR=${PREFIX_GLOBAL}/instance
    rm -rf ${INSTANCE_DIR}; mkdir ${INSTANCE_DIR}
    pushd ${INSTANCE_DIR}
    python3 -m scine_puffin configure
    >puffin.sh
    echo "export PYTHONPATH=${PREFIX_GLOBAL}/puffin/software/install/lib/python3.11/site-packages" >> puffin.sh
    echo "export PYTHONPATH=\$PYTHONPATH:${PREFIX_GLOBAL}/puffin/software/install/lib64/python3.11/site-packages" >> puffin.sh
    echo "export PYTHONPATH=\$PYTHONPATH:${PREFIX_GLOBAL}/puffin/software/install/local/lib/python3.11/dist-packages" >> puffin.sh
    echo "export PYTHONPATH=\$PYTHONPATH:${PREFIX_GLOBAL}/puffin/software/install/local/lib64/python3.11/dist-packages" >> puffin.sh
    echo "export PATH=${PREFIX_GLOBAL}/puffin/software/install/bin:$PATH" >> puffin.sh
    echo "export LD_LIBRARY_PATH=${PREFIX_GLOBAL}/puffin/software/install/lib" >> puffin.sh
    echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:${PREFIX_GLOBAL}/puffin/software/install/lib64" >> puffin.sh
    echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:${PREFIX_GLOBAL}/mongo/c/${MONGO_C_VERSION}/lib" >> puffin.sh
    echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:${PREFIX_GLOBAL}/mongo/cpp/${MONGO_CPP_VERSION}/lib" >> puffin.sh
    echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:${PREFIX_GLOBAL}/boost/${BOOST_VERSION}/lib" >> puffin.sh
    echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:${MKLROOT}/lib" >> puffin.sh
    echo "export SCINE_MODULE_PATH=${PREFIX_GLOBAL}/puffin/software/install/lib:${PREFIX_GLOBAL}/puffin/software/install/lib64" >> puffin.sh
    echo "export OMP_NUM_THREADS=1" >> puffin.sh
    # source puffin.sh
    # sed time
    PUFFIN_DIR=${PREFIX_GLOBAL}/puffin
    sed -i "s@/scratch/puffin@${PUFFIN_DIR}@g" puffin.yaml

    popd
}


install_deps() {
    log_info "Installing dependencies..."
    log_info "Meaning boost, mongo_c and mongo_cpp bindings (for release)"
    install_boost
    if [[ ${MODULE_TYPE} == "release" ]]; then
        install_mongo_c
        install_mongo_cpp
    fi
    #install_numpy
}


install_chemoton() {
    
    # variables
    # $1 url for release chemoton repo 
    # $2 url for dev chemoton repo
    # $3 branch of development repo
    
    # initialize var
    CHEMOTON_GITREPO=$1
    CHEMOTON_GITLABREPO=$2
    BRANCH_NAME=$3

    #inititalize env
    SCINE_ENV_DIR=${PREFIX_GLOBAL}/scine-env
    source $SCINE_ENV_DIR/bin/activate

    if [[ ${MODULE_TYPE} == "release" ]]; then
        pip install git+${CHEMOTON_GITREPO}
    else
        pip install git+${CHEMOTON_GITLABREPO}@${BRANCH_NAME}
    fi
}


# Main execution
main() {
    log_info "Actually bootstrapping Puffin..."
    
    print_configuration

    setup_environment

   install_deps
    
    export CMAKE_PREFIX_PATH=${PREFIX_GLOBAL}/boost/${BOOST_VERSION}
    export CMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH:${PREFIX_GLOBAL}/puffin/software/install
    export CMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH:${PREFIX_GLOBAL}/mongo/c/${MONGO_C_VERSION}
    export CMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH:${PREFIX_GLOBAL}/mongo/cpp/${MONGO_CPP_VERSION}
    
    if [[ ${MODULE_TYPE} == "release" ]]; then
    # These will install the released versions of modules
        install_scine_module core         $SCINE_CORE_URL         $SCINE_CORE_VERSION
        install_scine_module utilities    $SCINE_UTILS_URL        $SCINE_UTILS_VERSION 
        install_scine_module database     $SCINE_DATABASE_URL     $SCINE_DATABASE_VERSION 
        install_scine_module molassembler $SCINE_MOLASSEMBLER_URL $SCINE_MOLASSEMBLER_VERSION 
        install_scine_module readuct      $SCINE_READUCT_URL      $SCINE_READUCT_VERSION 
        install_scine_module kinetx       $SCINE_KINETX_URL       $SCINE_KINETX_VERSION 
    else
    # These will install the development versions of modules
        install_scine_module_gitlab core         $SCINE_CORE_GITLABREPO         $SCINE_CORE_BRANCH
        install_scine_module_gitlab utilities    $SCINE_UTILS_GITLABREPO        $SCINE_UTILS_BRANCH
        install_scine_module_gitlab database     $SCINE_DATABASE_GITLABREPO     $SCINE_DATABASE_BRANCH
        install_scine_module_gitlab molassembler $SCINE_MOLASSEMBLER_GITLABREPO $SCINE_MOLASSEMBLER_BRANCH
        install_scine_module_gitlab readuct      $SCINE_READUCT_GITLABREPO      $SCINE_READUCT_BRANCH
        install_scine_module_gitlab kinetx       $SCINE_KINETX_GITLABREPO       $SCINE_KINETX_BRANCH
    fi

    # Install and initialize puffin under /instance
    install_puffin
    instantiate_puffin
    # Please make sure to check your .yaml and .sh

    install_chemoton $SCINE_CHEMOTON_URL $SCINE_CHEMOTON_GITLABREPO $SCINE_CHEMOTON_BRANCH
   
}

# Run main function
main "$@"


