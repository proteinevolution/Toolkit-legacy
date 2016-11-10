#!/bin/bash

PART="Standard Prefix"

BUILDDEPS_PATH=$(pwd)
LOG_DIR=${BUILDDEPS_PATH}/log

cd ${BUILDDEPS_PATH}
[  -d log ] || mkdir log
 
function check_dir {

    if [ ! -d "$1" ] ; then
        echo "${PART}. Error: Not a directory: $1"
        exit 1
    fi
}



while [[ $# -gt 1 ]] ; do
key="$1"

case $key in
    -l|--loc)
    PREFIX="$2"
    shift # past argument
    ;;
    --with-python)
    PYEXEC="$2"
    shift
    ;;
    --loc-boost)
    BOOST="$2"
    shift
    ;;
    --with-boost)
    WITH_BOOST="$2"
    shift
    ;;
    --loc-pdbx)
    PDBX="$2"
    shift
    ;;
    --loc-dssp)
    DSSP="$2"
    shift
    ;;
    --loc-hhsuite)
    HHSUITE="$2"
    shift
    ;;
    --with-hhsuite)
    WITH_HHSUITE="$2"
    shift
    ;;
    --with-mmseqs)
    WITH_MMSEQS="$2"
    shift
    ;;
    --loc-mmseqs)
    MMSEQS="$2"
    shift
    ;;
    --with-psipred)
    WITH_PSIPRED="$2"
    shift
    ;;
    --loc-psipred)
    PSIPRED="$2"
    shift
    ;;
    --with-legacy-blast)
    WITH_LEGACY_BLAST="$2"
    shift
    ;;
    *)
    ;;
esac
shift # past argument or value
done


# TODO Check for consistency of arguments 

# Specify standard prefix
if [ ! "$PREFIX" ] ; then

    echo "${PART}. Error: No standard prefix path specified"
    exit 1
fi
check_dir "$PREFIX"



#############################################################################
#############################################################################
# Select BLAST version
PART="BLAST"


if [ "${WITH_LEGACY_BLAST}" ] ; then

    # TODO Check whether the directory actually contains legacy BLAST

    cd "${WITH_LEGACY_BLAST}"
    BLASTROOT=$(pwd)
else 

    echo "${PART}. ERROR. Currently, you must provide a legacy BLAST distribution with --with-legacy-blast. This is needed for PSI-PRED."
    exit 5
fi

# TODO Also provide version information
echo "${PART}. Will use LEGACY BLAST in: ${BLASTROOT}"



cd "${BUILDDEPS_PATH}"
#############################################################################
#############################################################################
# INSTALL PSI-PRED
PART="PSIPRED"

if [ "$WITH_PSIPRED" ] ; then

    cd "$WITH_PSIPRED"
    PSIPREDROOT=$(pwd)

else

    [[ "$PSIPRED" ]] && INSTALL="$PSIPRED" || INSTALL="$PREFIX"

    cd "$INSTALL"
    wget http://bioinfadmin.cs.ucl.ac.uk/downloads/psipred/psipred.4.01.tar.gz -O psipreddist > /dev/null 2>&1
    tar -xzf psipreddist
    rm psipreddist
    cd psipred/src
    make 1> ${LOG_DIR}/psipred_make.out 2> ${LOG_DIR}/psipred_make.err
    make install 1> ${LOG_DIR}/psipred_makeinstall.out 2> ${LOG_DIR}/psipred_makeinstall.err
    cd ..
    PSIPREDROOT=$(pwd)
fi



cd "${BUILDDEPS_PATH}"
#############################################################################
#############################################################################
# Determine Python Executable
PART="PYTHON"

[ "$PYEXEC" ] || PYEXEC="python3"

# Verify that a Python interpreter was actually selected
if [ !  $(which "$PYEXEC")  ] ; then
    echo "${PART}. ERROR. Python Executable $PYEXEC is not in PATH"
    exit 4
fi

# Validate the Python Version 
"$PYEXEC" --version > pyout 2>&1
if [ $(grep -o  [0-9]  pyout | head -n 1) -ne 3 ] ; then
    echo "${PART}. ERROR. Python interpreter is not of Python version 3"
    rm pyout
    exit 5
fi
rm pyout
echo "${PART}. Using Python executable: ${PYEXEC}"


cd "${BUILDDEPS_PATH}"
#############################################################################
#############################################################################
# Determine whether Boost was selected or install new distribution
PART="BOOST"

# IF the user has specified WITH_BOOST, we do not attempt to install it
if [  "${WITH_BOOST}" ] ; then

   # Check if the lib and include direcories exists
   # TODO Also check for particular files
    if [[ ! -d "${WITH_BOOST}/include" || ! -d ${WITH_BOOST}/lib ]] ; then

        echo "${PART}. ERROR. include or lib directory missing in Boost installation."    
        exit 6
    fi
    BOOSTROOT=$(readlink -f "${WITH_BOOST}")
else

    [[ "$BOOST" ]] && INSTALL="$BOOST" || INSTALL="$PREFIX"

    # TODO Check whether install already contains a Boost distribution


    check_dir "$INSTALL"
    echo "${PART}. Using prefix: $INSTALL"
    cd "$INSTALL"

    # TODO Display determined Boost version

    echo "${PART}. Downloading Boost..."
    # Download Latest Boost Version from Sourceforge
    wget https://sourceforge.net/projects/boost/files/latest/boostdist > /dev/null 2>&1

    # Extract boost and remove original dist file
    echo "${PART}. Extracting Boost..."
    tar --bzip2 -xf boostdist
    rm boostdist

    # Append suffix src
    # TODO Ensure that it only has one iteration
    for i in $(ls | grep boost) ; do

        mv "$i" "${i}_src"
        BBOOTSTRAP=$(readlink -f "${i}_src/bootstrap.sh")
    done

    # Make the prefix dir for Boost
    mkdir "$i"

    # BOOST PREFIX
    BOOSTROOT=$(readlink -f "$i")

    # Go into the SRC directory
    cd "${i}_src"

    # Boosts Bootstrap
    echo "${PART}. Bootstrapping Boost with: ${BBOOTSTRAP} --prefix=${BOOSTROOT}"
    echo "${PART}. You might want to check the files bootstrap.out and bootstrap.err"

    "${BBOOTSTRAP}" --prefix="${BOOSTROOT}" --with-python="${PYEXEC}" 1> "${LOG_DIR}/bootstrap.out" 2> "${LOG_DIR}/bootstrap.err"

    # Build Boost
    echo "${PART}. Building Boost with: ./b2 install"
    echo "${PART}. You might want to check the files b2.out and b2.err"
    ./b2 install 1> "${LOG_DIR}/b2.out" 2> "${LOG_DIR}/b2.err"
fi

echo "${PART}. Boost is now available in: ${BOOSTROOT}"

cd "${BUILDDEPS_PATH}"
#############################################################################
#############################################################################
# Determine the used PDBX version
PART="PDBX"

[[ "$PDBX" ]] && INSTALL="$PDBX" || INSTALL="$PREFIX"

check_dir "$INSTALL"

cd "$INSTALL"

# Download PDBX
echo "${PART}. Downloading PDBX"
git clone https://github.com/soedinglab/pdbx.git > /dev/null 2>&1
cd pdbx
mkdir build
cd build
echo "${PART}. Cmake for PDBX."
echo "${PART}. You might want to check the files pdbx_cmake.out and pdbx_cmake.err"
cmake -DUserInstallOption=ON ../ 1> ${LOG_DIR}/pdbx_cmake.out 2> ${LOG_DIR}/pdbx_cmake.err
echo "${PART}. Make for PDBX."
echo "${PART}. You might want to check the files pdbx_make.out and pdbx_make.err"
make  1> ${LOG_DIR}/pdbx_make.out 2> ${LOG_DIR}/pdbx_make.err
echo "${PART}. Make_install for PDBX."
echo "${PART}. You might want to check the files pdbx_makeinstall.out and pdbx_makeinstall.err"
make install 1> ${LOG_DIR}/pdbx_makeinstall.out 2> ${LOG_DIR}/pdbx_makeinstall.err
cd ..
PDBXPYPATH=$(pwd)

cd "${BUILDDEPS_PATH}"
#############################################################################
#############################################################################
# Process DSSP

PART="DSSP"
[[ "$DSSP" ]] && INSTALL="$DSSP" || INSTALL="$PREFIX"

check_dir "$INSTALL"

cd "$INSTALL"

# TODO Also provide version information and determine newest version automatically
# DOWNLOAD DSSP
echo "${PART}. Downloading DSSP"
wget ftp://ftp.cmbi.ru.nl/pub/software/dssp/dssp-2.2.1.tgz -O dsspdist > /dev/null 2>&1 
tar -xzf dsspdist
rm dsspdist

# change into the newly created directory
cd $(ls | grep dssp)

# Write the Boost configuration from the previous step to the BOOST_LIB
echo "# Set local options for make here" > make.config
echo "BOOST_LIB_DIR    = ${BOOSTROOT}/lib" >> make.config
echo "BOOST_INC_DIR    = ${BOOSTROOT}/include" >> make.config
echo "${PART}. Make DSSP"
DSSPROOT=$(pwd)
make 1> ${LOG_DIR}/dssp_make.out 2> ${LOG_DIR}/dssp_make.err


cd "${BUILDDEPS_PATH}"
#############################################################################
#############################################################################
# Process MMSEQS

PART="MMSEQS"

if [ "$WITH_MMSEQS" ] ; then

    MMSEQSROOT=$(readlink -f ${WITH_MMSEQS})
else
    
    [[ "$MMSEQS" ]] && INSTALL="$MMSEQS" || INSTALL="$PREFIX"
    cd "$INSTALL"
    
    echo "${PART}. Cloning mmseqs2"
    git clone https://github.com/soedinglab/mmseqs2.git > /dev/null 2>&1
    mv mmseqs2 mmseqs2_src
    mkdir mmseqs2
    MMSEQSROOT=$(readlink -f mmseqs2)
    cd mmseqs2_src
    mkdir build
    cd build
    echo "${PART}. Cmake for mmseqs2"
    cmake -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX="${MMSEQSROOT}" .. 1> ${LOG_DIR}/mmseqs_cmake.out 2> ${LOG_DIR}/mmseqs_cmake.err
    echo "${PART}. Make for mmseqs2"
    make 1> ${LOG_DIR}/mmseqs_make.out 2> ${LOG_DIR}/mmseqs_make.err
    echo "${PART}. Make install for mmseqs2"
    make install 1> ${LOG_DIR}/mmseqs_makeinstall.out 2> ${LOG_DIR}/mmseqs_makeinstall.err
fi

cd ${BUILDDEPS_PATH}
#############################################################################
#############################################################################
# Process hh-suite

PART="HHSUITE"

if [ "${WITH_HHSUITE}" ] ; then

    HHSUITEROOT=$(readlink -f ${WITH_HHSUITE})
else
    [[ "$HHSUITE" ]] && INSTALL="$HHSUITE" || INSTALL="$PREFIX"
    cd "$INSTALL"

    echo "${PART}. Cloning hh-suite"
    git clone https://github.com/soedinglab/hh-suite.git > /dev/null 2>&1 
    mv hh-suite hh-suite_src
    mkdir hh-suite
    HHSUITEROOT=$(readlink -f hh-suite)
    cd hh-suite_src

    echo "${PART}. Initialize submodule"
    git submodule init > /dev/null 2>&1
    git submodule update > /dev/null 2>&1
    mkdir build
    cd build
    echo "${PART}. Cmake for hh-suite"
    cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="${HHSUITEROOT}" .. 1> ${LOG_DIR}/hhsuite_cmake.out 2> ${LOG_DIR}/hhsuite_cmake.err
    echo "${PART}. Make for hh-suite"
    make 1> ${LOG_DIR}/hhsuite_make.out 2> ${LOG_DIR}/hhsuite_make.err
    echo "${PART}. Make install for hh-suite"
    make install 1> ${LOG_DIR}/hhsuite_makeinstall.out 2> ${LOG_DIR}/hhsuite_makeinstall.err
fi

# Adjust the scripts in HHpaths
cd "${HHSUITEROOT}/scripts"

# TODO Add the semicolon

sed -i "s|our \$execdir =.*|our \$execdir = \"${PSIPREDROOT}/bin\"|g" HHPaths.pm
sed -i "s|our \$datadir =.*|our \$datadir = \"${PSIPREDROOT}/data\"|g" HHPaths.pm
sed -i "s|our \$ncbidir =.*|our \$ncbidir = \"${BLASTROOT}/bin\"|g" HHPaths.pm
sed -i "s|our \$dssp    =.*|our \$dssp    = \"${DSSPROOT}/mkdssp\"|g" HHPaths.pm

cd ${BUILDDEPS_PATH}
#############################################################################
#############################################################################
# Make a setenv and unsetenv script for BASH and hh-suite usage

cd ${PREFIX}

echo "export HHLIB=${HHSUITEROOT}" > setenv.sh
echo "unset HHLIB" > unsetenv.sh

echo "export PATH=${PATH}" >> unsetenv.sh

PYPATH=$(which "$PYEXEC")


# TODO Add  PSI-PRED to PATH #TODO Validate (runpsipred in PATH?)
# TODO ADD HHpred to PATH
# TODO Also deploy HHviz script
echo "export PATH=\"$(dirname $PYPATH):${PSIPREDROOT}:${HHSUITEROOT}/bin:${HHSUITEROOT}/scripts:${MMSEQSROOT}/bin:${DSSPROOT}:${PATH}\"" >> setenv.sh

echo "export PYTHONPATH=\"${PDBXPYPATH}:${PYTHONPATH}\"" >> setenv.sh
echo "export PYTHONPATH=\"${PYTHONPATH}\"" >> unsetenv.sh









