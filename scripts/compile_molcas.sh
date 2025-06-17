#!/bin/bash


# Parse command-line arguments
SKIP_MPI=0
SKIP_HDF5=0

for arg in "$@"
do
    case $arg in
        --skip-mpi)
        SKIP_MPI=1
        shift
        ;;
        --skip-hdf5)
        SKIP_HDF5=1
        shift
        ;;
        *)
        echo "Unknown option: $arg"
        echo "Supported options: --skip-mpi --skip-hdf5"
        exit 1
        ;;
    esac
done


### CONFIG
TARBALL_URL="https://gitlab.com/Molcas/OpenMolcas/-/archive/v24.10/OpenMolcas-v24.10.tar.gz"
OPENMPI_URL="https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.6.tar.gz"
HDF5_URL="https://github.com/HDFGroup/hdf5/releases/download/hdf5_1.14.5/hdf5-1.14.5.tar.gz"
export MOLCAS_DIR=/opt/OpenMolcas
export OPENMPI_DIR=/opt/openmpi
export HDF5_DIR=/opt/hdf5
export MOLCAS_VERSION=24.10
export OPENMPI_VERSION=4.1.6
export HDF5_VERSION=1.14.5
export MOLCAS_INSTALL_PREFIX=$MOLCAS_DIR/$MOLCAS_VERSION
export OPENMPI_INSTALL_PREFIX=$OPENMPI_DIR/$OPENMPI_VERSION
export HDF5_INSTALL_PREFIX=$HDF5_DIR/$HDF5_VERISON

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

### BOOTSTRAP
echo Compile settings:
echo TARBALL_URL=$TARBALL_URL
echo OPENMPI_URL=$OPENMPI_URL
echo HD5_URL=$HD5_URL
echo MOLCAS_INSTALL_PREFIX=$MOLCAS_INSTALL_PREFIX
echo OPENMPI_INSTALL_PREFIX=$OPENMPI_INSTALL_PREFIX
echo HDF5_INSTALL_PREFIX=$HDF5_INSTALL_PREFIX

### OPENMPI COMPILATION
if [ "$SKIP_MPI" -eq 0 ]; then
    echo compiling openmpi...
    echo getting the tarball...
    mkdir -p $OPENMPI_INSTALL_PREFIX
    mkdir -p $OPENMPI_INSTALL_PREFIX/../tarballs
    mkdir -p $OPENMPI_DIR/src/

    pushd $OPENMPI_DIR/tarballs > /dev/null
    wget -q -N $OPENMPI_URL
    popd
    echo Done!
    echo unpacking tarball...
    pushd $OPENMPI_DIR/src/
    tar xf $OPENMPI_DIR/tarballs/openmpi-4.1.6.tar.gz
    popd
    echo Done!

    echo Running configure ...
    echo The result of the configure script is in $OPENMPI_DIR/src/openmpi-4.1.6/configure_full_log.txt
    pushd $OPENMPI_DIR/src/openmpi-4.1.6
    make distclean
    ./configure --prefix=$OPENMPI_INSTALL_PREFIX &> configure_full_log.txt
    popd
    echo DONE!

    echo COMPILING OPENMPI
    echo Check log at $OPENMPI_DIR/src/openmpi-4.1.6/make_full_log.txt
    pushd $OPENMPI_DIR/src/openmpi-4.1.6
    make all -j &> make_full_log.txt
    echo COMPILED SUCCESS
    echo Installing ...
    make install &> /dev/null
    popd
    echo DONE WITH OPENMPI
else
    echo Skipping OpenMPI compilation
fi


### HDF5 compile

if [ "$SKIP_HDF5" -eq 0 ]; then
    echo getting hdf5...
    mkdir -p $HDF5_DIR/src
    mkdir -p $HDF5_DIR/tarballs
    mkdir -p $HDF5_INSTALL_PREFIX
    pushd $HDF5_DIR/tarballs
    wget -N -q $HDF5_URL
    popd
    echo Done

    echo unpacking tarball...
    pushd $HDF5_DIR/src
    tar xf $HDF5_DIR/tarballs/hdf5-1.14.5.tar.gz
    popd
    echo Done

    echo running configure
	pushd $HDF5_DIR/src/hdf5-1.14.5
	popd
    echo done
else
    echo Skipping HDF5 compilation
fi
