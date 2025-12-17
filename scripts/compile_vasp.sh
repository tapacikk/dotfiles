#!/bin/bash

# Strict error handling
set -euo pipefail

# Script configuration
readonly SCRIPT_NAME="$(basename "$0")"
readonly LOG_DATE="$(date +%Y%m%d_%H%M%S)"

# Parse command-line arguments
SKIP_MPI=0
SKIP_HDF5=0
SKIP_BLAS=0
DISTCLEAN=0
SKIP_SCALAPACK=0
SKIP_FFTW=0
SKIP_GA=0
PREFIX_GLOBAL=/opt
export CMAKE_INSTALL_PREFIX=

print_usage() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

Install VASP

OPTIONS:
    --prefix DIR          Where to install. Must be writable
    --distclean           Clean all source directories before building

    --skip-mpi            Skip OpenMPI compilation
    --skip-hdf5           Skip HDF5 compilation
    --skip-blas           Skip OpenBLAS compilation
    --skip-fftw           Skip FFTW compilation
    --skip-scalapack      Skip SCALAPACK compilation

    --help                Show this help message
EOF
}



while [[ $# -gt 0 ]]; do
    arg="$1"

    if [[ "$arg" == *=* ]]; then
        key="${arg%%=*}"
        value="${arg#*=}"
        set -- "$key" "$value" "${@:3}"
        arg="$1"
    fi

    case $arg in
        --distclean)
            DISTCLEAN=1
            shift
            ;;
        --prefix)
            shift
            if [[ -z "$1" || "$1" == --* ]]; then
                echo "Error: --prefix requires a directory argument" >&2
                exit 1
            fi
            PREFIX_GLOBAL="$1"
            shift
            ;;
        --skip-blas)
            SKIP_BLAS=1
            shift
            ;;
        --skip-mpi)
            SKIP_MPI=1
            shift
            ;;
        --skip-hdf5)
            SKIP_HDF5=1
            shift
            ;;
        --skip-fftw)
            SKIP_FFTW=1
            shift
            ;;
        --skip-scalapack)
            SKIP_SCALAPACK=1
            shift
            ;;
        --help)
            print_usage
            exit 0
            ;;
        *)
            echo "Error: Unknown option: $arg" >&2
            print_usage
            exit 1
            ;;
    esac
done



# Directory configuration
export OPENMPI_DIR="$PREFIX_GLOBAL/openmpi"
export HDF5_DIR="$PREFIX_GLOBAL/hdf5"
export BLAS_DIR="$PREFIX_GLOBAL/OpenBLAS"
export FFTW_DIR="$PREFIX_GLOBAL/fftw"
export SCALAPACK_DIR="$PREFIX_GLOBAL/scalapack"

# Version configuration
export OPENMPI_VERSION="4.1.4"
export HDF5_VERSION="1.14.5"
export BLAS_VERSION="0.3.29"
export FFTW_VERSION="3.3.10"
export SCALAPACK_VERSION="2.2.2"

# URLS
readonly OPENMPI_URL="https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-${OPENMPI_VERSION}.tar.gz"
readonly HDF5_URL="https://github.com/HDFGroup/hdf5/releases/download/hdf5_${HDF5_VERSION}/hdf5-${HDF5_VERSION}.tar.gz"
readonly BLAS_URL="https://github.com/OpenMathLib/OpenBLAS/releases/download/v${BLAS_VERSION}/OpenBLAS-${BLAS_VERSION}.tar.gz"
readonly FFTW_URL="http://fftw.org/fftw-${FFTW_VERSION}.tar.gz"
readonly SCALAPACK_URL="https://github.com/Reference-ScaLAPACK/scalapack/archive/refs/tags/v${SCALAPACK_VERSION}.tar.gz"

# Installation prefixes
export OPENMPI_INSTALL_PREFIX="${OPENMPI_DIR}/${OPENMPI_VERSION}"
export HDF5_INSTALL_PREFIX="${HDF5_DIR}/${HDF5_VERSION}"
export BLAS_INSTALL_PREFIX="${BLAS_DIR}/${BLAS_VERSION}"
export FFTW_INSTALL_PREFIX="${FFTW_DIR}/${FFTW_VERSION}"
export SCALAPACK_INSTALL_PREFIX="${SCALAPACK_DIR}/${SCALAPACK_VERSION}"


# ENVIRONMENT
export PATH=$PATH:${OPENMPI_INSTALL_PREFIX}/bin
export CMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH:$OPENMPI_INSTALL_PREFIX:$HDF5_INSTALL_PREFIX:$BLAS_INSTALL_PREFIX:$FFTW_INSTALL_PREFIX:$SCALAPACK_INSTALL_PREFIX

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

create_directory() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        log_info "Creating directory: $dir"
        mkdir -p "$dir" || {
            log_error "Failed to create directory: $dir"
            return 1
        }
    fi
}

download_file() {
    local url="$1"
    local dest_dir="$2"
    local filename
    filename="$(basename "$url")"
    
    log_info "Downloading: $filename"
    pushd "$dest_dir" > /dev/null
    
    if wget -q -N "$url"; then
        log_success "Downloaded: $filename"
    else
        log_error "Failed to download: $url"
        popd > /dev/null
        return 1
    fi
    
    popd > /dev/null
}

extract_tarball() {
    local tarball="$1"
    local dest_dir="$2"
    local filename
    filename="$(basename "$tarball")"
    
    log_info "Extracting: $filename"
    pushd "$dest_dir" > /dev/null
    
    if tar xf "$tarball"; then
        log_success "Extracted: $filename"
    else
        log_error "Failed to extract: $tarball"
        popd > /dev/null
        return 1
    fi
    
    popd > /dev/null
}

print_configuration() {
    log_info "Build configuration:"
    echo "  PREFIX_GLOBAL: $PREFIX_GLOBAL"
    echo "  OPENMPI_URL: $OPENMPI_URL"
    echo "  HDF5_URL: $HDF5_URL"
    echo "  BLAS_URL: $BLAS_URL"
    echo "  OPENMPI_INSTALL_PREFIX: $OPENMPI_INSTALL_PREFIX"
    echo "  HDF5_INSTALL_PREFIX: $HDF5_INSTALL_PREFIX"
    echo "  BLAS_INSTALL_PREFIX: $BLAS_INSTALL_PREFIX"
}

check_writable() {
    if [[ ! -d "$PREFIX_GLOBAL" ]]; then
        log_error "Error: Directory $1 does not exist." 
        exit 1
    elif [[ ! -w "$PREFIX_GLOBAL" ]]; then
        log_error "Error: Directory $PREFIX_GLOBAL is not writable." 
        exit 1
    else
        log_info "Directory $PREFIX_GLOBAL is writable."
    fi
}

clean_source_directories() {
    if [[ $DISTCLEAN -eq 1 ]]; then
        log_info "DISTCLEAN requested - removing source directories"
        local dirs=(
            "${HDF5_DIR}/src"
            "${OPENMPI_DIR}/src"
            "${BLAS_DIR}/src"
        )
        
        for dir in "${dirs[@]}"; do
            if [[ -d "$dir" ]]; then
                log_info "Removing: $dir"
                rm -rf "$dir" || log_error "Failed to remove: $dir"
            fi
        done
        
        log_success "Source directories cleaned"
    else
        log_info "Skipping DISTCLEAN"
    fi
}

install_openmpi() {
    if [[ $SKIP_MPI -eq 1 ]]; then
        log_info "Skipping OpenMPI compilation"
        return 0
    fi
    
    log_info "Starting OpenMPI compilation"
    
    # Create directories
    create_directory "$OPENMPI_INSTALL_PREFIX"
    create_directory "${OPENMPI_DIR}/tarballs"
    create_directory "${OPENMPI_DIR}/src"
    
    # Download and extract
    download_file "$OPENMPI_URL" "${OPENMPI_DIR}/tarballs"
    extract_tarball "${OPENMPI_DIR}/tarballs/openmpi-${OPENMPI_VERSION}.tar.gz" "${OPENMPI_DIR}/src"
    
    # Configure
    local build_dir="${OPENMPI_DIR}/src/openmpi-${OPENMPI_VERSION}"
    local log_file="${build_dir}/configure_${LOG_DATE}.log"
    
    log_info "Configuring OpenMPI (log: $log_file)"
    pushd "$build_dir" > /dev/null
    
    if ./configure --prefix="$OPENMPI_INSTALL_PREFIX" &> "$log_file"; then
        log_success "OpenMPI configured successfully"
    else
        log_error "OpenMPI configuration failed. Check: $log_file"
        popd > /dev/null
        return 1
    fi
    
    # Compile
    log_file="${build_dir}/make_${LOG_DATE}.log"
    log_info "Compiling OpenMPI (log: $log_file)"
    
    if make all -j"$(nproc)" &> "$log_file"; then
        log_success "OpenMPI compiled successfully"
    else
        log_error "OpenMPI compilation failed. Check: $log_file"
        popd > /dev/null
        return 1
    fi
    
    # Install
    log_info "Installing OpenMPI"
    if make install &> /dev/null; then
        log_success "OpenMPI installed successfully"
    else
        log_error "OpenMPI installation failed"
        popd > /dev/null
        return 1
    fi
    
    popd > /dev/null
    
    # Update PATH
    export PATH="$PATH:$OPENMPI_INSTALL_PREFIX/bin"
}

install_hdf5() {
    if [[ $SKIP_HDF5 -eq 1 ]]; then
        log_info "Skipping HDF5 compilation"
        return 0
    fi
    
    log_info "Starting HDF5 compilation"
    
    # Create directories
    create_directory "${HDF5_DIR}/src"
    create_directory "${HDF5_DIR}/tarballs"
    create_directory "$HDF5_INSTALL_PREFIX"
    
    # Download and extract
    download_file "$HDF5_URL" "${HDF5_DIR}/tarballs"
    extract_tarball "${HDF5_DIR}/tarballs/hdf5-${HDF5_VERSION}.tar.gz" "${HDF5_DIR}/src"
    
    # Configure with CMake
    local build_dir="${HDF5_DIR}/src/hdf5-${HDF5_VERSION}/build"
    local log_file="${build_dir}/cmake_${LOG_DATE}.log"
    
    create_directory "$build_dir"
    
    log_info "Configuring HDF5 with CMake (log: $log_file)"
    pushd "$build_dir" > /dev/null
    
    local cmake_args=(
        -DCMAKE_INSTALL_PREFIX="$HDF5_INSTALL_PREFIX"
        -DCMAKE_C_COMPILER="${OPENMPI_INSTALL_PREFIX}/bin/mpicc"
        -DCMAKE_CXX_COMPILER="${OPENMPI_INSTALL_PREFIX}/bin/mpic++"
        -DHDF5_BUILD_FORTRAN=ON
    )
    
    if cmake .. "${cmake_args[@]}" &> "$log_file"; then
        log_success "HDF5 configured successfully"
    else
        log_error "HDF5 configuration failed. Check: $log_file"
        popd > /dev/null
        return 1
    fi
    
    # Compile and install
    log_file="${build_dir}/make_${LOG_DATE}.log"
    log_info "Compiling and installing HDF5 (log: $log_file)"
    
    if make -j"$(nproc)" &> "$log_file" && make install &>> "$log_file"; then
        log_success "HDF5 compiled and installed successfully"
    else
        log_error "HDF5 compilation/installation failed. Check: $log_file"
        popd > /dev/null
        return 1
    fi
    
    popd > /dev/null
}

install_blas() {
if [[ $SKIP_BLAS -eq 1 ]]; then
        log_info "Skipping OpenBLAS compilation"
        return 0
    fi

    log_info "Starting OpenBLAS compilation"

    # Create directories
    create_directory "${BLAS_DIR}/src"
    create_directory "${BLAS_DIR}/tarballs"
    create_directory "$BLAS_INSTALL_PREFIX"

    # Download and extract
    download_file "$BLAS_URL" "${BLAS_DIR}/tarballs"
    extract_tarball "${BLAS_DIR}/tarballs/OpenBLAS-${BLAS_VERSION}.tar.gz" "${BLAS_DIR}/src"

    # Compile and install
    local build_dir="${BLAS_DIR}/src/OpenBLAS-${BLAS_VERSION}"
    local log_file="${build_dir}/make_${LOG_DATE}.log"

    log_info "Compiling OpenBLAS (log: $log_file)"
    pushd "$build_dir" > /dev/null

    local make_args=(
        INTERFACE64=1
        CC="${OPENMPI_INSTALL_PREFIX}/bin/mpicc"
        FC="${OPENMPI_INSTALL_PREFIX}/bin/mpifort"
        PREFIX="$BLAS_INSTALL_PREFIX"
    )

    if make "${make_args[@]}" &> "$log_file"; then
        log_success "OpenBLAS compiled successfully"
    else
        log_error "OpenBLAS compilation failed. Check: $log_file"
        popd > /dev/null
        return 1
    fi

    # Install
    log_info "Installing OpenBLAS"
    if make PREFIX="$BLAS_INSTALL_PREFIX" install &>> "$log_file"; then
        log_success "OpenBLAS installed successfully"
    else
        log_error "OpenBLAS installation failed. Check: $log_file"
        popd > /dev/null
        return 1
    fi

    popd > /dev/null
}

install_fftw() {
    if [[ $SKIP_FFTW -eq 1 ]]; then
        log_info "Skipping FFTW compilation"
        return 0
    fi
    
    log_info "Starting FFTW compilation"
    
    # Create directories
    create_directory "${FFTW_DIR}/src"
    create_directory "${FFTW_DIR}/tarballs"
    create_directory "$FFTW_INSTALL_PREFIX"
    
    # Download and extract
    download_file "$FFTW_URL" "${FFTW_DIR}/tarballs"
    extract_tarball "${FFTW_DIR}/tarballs/fftw-${FFTW_VERSION}.tar.gz" "${FFTW_DIR}/src"
    
    # Configure with CMake
    local build_dir="${FFTW_DIR}/src/fftw-${FFTW_VERSION}/build"
    local log_file="${build_dir}/cmake_${LOG_DATE}.log"
    
    create_directory "$build_dir"
    
    log_info "Configuring FFTW with CMake (log: $log_file)"
    pushd "$build_dir" > /dev/null
    
    local cmake_args=(
        -DENABLE_OPENMP=ON
        -DENABLE_THREADS=ON
        -DCMAKE_INSTALL_PREFIX="$FFTW_INSTALL_PREFIX"
        -DCMAKE_C_COMPILER="${OPENMPI_INSTALL_PREFIX}/bin/mpicc"
        -DCMAKE_CXX_COMPILER="${OPENMPI_INSTALL_PREFIX}/bin/mpic++"
    )
    
    if cmake .. "${cmake_args[@]}" &> "$log_file"; then
        log_success "FFTW configured successfully"
    else
        log_error "FFTW configuration failed. Check: $log_file"
        popd > /dev/null
        return 1
    fi
    
    # Compile and install
    log_file="${build_dir}/make_${LOG_DATE}.log"
    log_info "Compiling and installing FFTW (log: $log_file)"
    
    if make -j"$(nproc)" &> "$log_file" && make install &>> "$log_file"; then
        log_success "FFTW compiled and installed successfully"
    else
        log_error "FFTW compilation/installation failed. Check: $log_file"
        popd > /dev/null
        return 1
    fi
    
    popd > /dev/null
}



install_scalapack() {
    if [[ $SKIP_SCALAPACK -eq 1 ]]; then
        log_info "Skipping SCALAPACK compilation"
        return 0
    fi
    
    log_info "Starting SCALAPACK compilation"
    
    # Create directories
    create_directory "${SCALAPACK_DIR}/src"
    create_directory "${SCALAPACK_DIR}/tarballs"
    create_directory "$SCALAPACK_INSTALL_PREFIX"
    
    # Download and extract
    download_file "$SCALAPACK_URL" "${SCALAPACK_DIR}/tarballs"
    extract_tarball "${SCALAPACK_DIR}/tarballs/v${SCALAPACK_VERSION}.tar.gz" "${SCALAPACK_DIR}/src"
    
    # Configure with CMake
    local build_dir="${SCALAPACK_DIR}/src/scalapack-${SCALAPACK_VERSION}/build"
    local log_file="${build_dir}/cmake_${LOG_DATE}.log"
    
    create_directory "$build_dir"
    
    log_info "Configuring SCALAPACK with CMake (log: $log_file)"
    pushd "$build_dir" > /dev/null
    
    local cmake_args=(
        -DCMAKE_INSTALL_PREFIX="$SCALAPACK_INSTALL_PREFIX"
        -DCMAKE_C_COMPILER="${OPENMPI_INSTALL_PREFIX}/bin/mpicc"
        -DCMAKE_CXX_COMPILER="${OPENMPI_INSTALL_PREFIX}/bin/mpic++"
        -DCMAKE_C_FLAGS="-Wno-error=implicit-function-declaration"
    )
    export CMAKE_PREFIX_PATH=$OPENMPI_INSTALL_PREFIX:$BLAS_INSTALL_PREFIX
    
    if cmake .. "${cmake_args[@]}" &> "$log_file"; then
        log_success "SCALAPACK configured successfully"
    else
        log_error "SCALAPACK configuration failed. Check: $log_file"
        popd > /dev/null
        return 1
    fi
    
    # Compile and install
    log_file="${build_dir}/make_${LOG_DATE}.log"
    log_info "Compiling and installing SCALAPACK (log: $log_file)"
    
    if make -j"$(nproc)" &> "$log_file" && make install &>> "$log_file"; then
        log_success "SCALAPACK compiled and installed successfully"
    else
        log_error "SCALAPACK compilation/installation failed. Check: $log_file"
        popd > /dev/null
        return 1
    fi
    
    popd > /dev/null
}




# Main execution
main() {
    log_info "Starting VASP deps installation script"
    
    print_configuration

    check_writable
    
    clean_source_directories
    
    # Install packages in dependency order
    install_openmpi
    install_blas
    install_fftw
    install_hdf5
    install_scalapack
    log_success "Installation script completed successfully"
    log_info "Installation summary:"
    echo "  OpenMPI: ${OPENMPI_INSTALL_PREFIX}"
    echo "  OpenBLAS: ${BLAS_INSTALL_PREFIX}"
    echo "  FFTW: ${FFTW_INSTALL_PREFIX}"
    echo "  SCALAPACK: ${SCALAPACK_INSTALL_PREFIX}"
    echo "  HDF5: ${HDF5_INSTALL_PREFIX}"
    echo "  OpenBLAS: ${BLAS_INSTALL_PREFIX}"
}

# Run main function
main "$@"
