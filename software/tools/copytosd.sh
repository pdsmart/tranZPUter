#!/bin/bash
#========================================================================================================
# NAME
#     copytosd.sh -  Shell script to copy necessary TZFS, CPM and host program files to SD card for the
#                    tranZPUter SW K64F processor.
#
# SYNOPSIS
#     copytosd.sh [-cdxDMt]
#
# DESCRIPTION
#
# OPTIONS
#     -D<root path> = Absolute path to root of tranZPUter project dir.
#     -M<mediapath> = Path to mounted SD card.
#     -t<targethost>= Target host, MZ-80K, MZ-80A, MZ-700, MZ-800, MZ-1500, MZ-2000
#     -d            = Debug mode.
#     -x            = Shell trace mode.
#     -h            = This help screen.
#
# EXAMPLES
#     copytosd.sh -D/projects/github -M/media/guest/7764-2389 -tMZ-700
#
# EXIT STATUS
#      0    The command ran successfully
#
#      >0    An error ocurred.
#
#EndOfUsage <- do not remove this line
#========================================================================================================
# History:
#          v1.00         : Initial version (C) P. Smart January 2020.
#          v1.10         : Updated to cater for different targets, copying selected files accordingly.
#========================================================================================================
# This source file is free software: you can redistribute it and#or modify
# it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This source file is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#========================================================================================================

PROG=${0##*/}
#PARAMS="`basename ${PROG} '.sh'`.params"
ARGS=$*

##############################################################################
# Load program specific variables
##############################################################################

# VERSION of this RELEASE.
#
VERSION="1.10"

# Temporary files.
TMP_DIR=/tmp
TMP_OUTPUT_FILE=${TMP_DIR}/tmpoutput_$$.log
TMP_STDERR_FILE=${TMP_DIR}/tmperror_$$.log

# Log mechanism setup.
#
LOG="/tmp/${PROG}_`date +"%Y_%m_%d"`.log"
LOGTIMEWIDTH=40
LOGMODULE="MAIN"

# Mutex's - prevent multiple threads entering a sensitive block at the same time.
#
MUTEXDIR="/var/tmp"

##############################################################################
# Utility procedures
##############################################################################

# Function to output Usage instructions, which is soley a copy of this script header.
#
function Usage
{
    # Output the lines at the start of this script from NAME to EndOfUsage
    cat $0 | nawk 'BEGIN {s=0} /EndOfUsage/ { exit } /NAME/ {s=1} { if (s==1) print substr( $0, 3 ) }'
    exit 1
}

# Function to output a message in Log format, ie. includes date, time and issuing module.
#
function Log
{
    DATESTR=`date "+%d/%m/%Y %H:%M:%S"`
    PADLEN=`expr ${LOGTIMEWIDTH} + -${#DATESTR} + -1 + -${#LOGMODULE} + -15`
    printf "%s %-${PADLEN}s %s\n" "${DATESTR} [$LOGMODULE]" " " "$*"
}

# Function to terminate the script after logging an error message.
#
function Fatal
{
    Log "ERROR: $*"
    Log "$PROG aborted"
    exit 2
}

# Function to output the Usage, then invoke Fatal to exit with a terminal message.
#
function FatalUsage
{
    # Output the lines at the start of this script from NAME to EndOfUsage
    cat $0 | nawk 'BEGIN {s=0} /EndOfUsage/ { exit } /NAME/ {s=1} { if (s==1) print substr( $0, 3 ) }'
    echo " "
    echo "ERROR: $*"
    echo "$PROG aborted"
    exit 3
}

# Function to output a message if DEBUG mode is enabled. Primarily to see debug messages should a
# problem occur.
#
function Debug
{
    if [ $DEBUGMODE -eq 1 ]; then
        Log "$*"
    fi
}

# Function to output a file if DEBUG mode is enabled.
#
function DebugFile
{
    if [ $DEBUGMODE -eq 1 ]; then
        cat $1
    fi
}

# Setup default media location.
#media=/media/psmart/A6F4-14E8;
#media=/media/psmart/1DBB-7404;
#media=/media/psmart/1BC8-C12D/;
media=/media/psmart/6B92-7702;
#media=/media/psmart/K64F/; 

# Setup default target.
#target=MZ-80A
#target=MZ-700
target=MZ-800
#target=MZ-2000
#target=MZ-80B

# Setup root directory.
rootdir=/dvlp/Projects/dev/github/

# Directory where software is held in root.
softwaredir=tranZPUter/software

# Process parameters, loading up variables as necessary.
#
if [ $# -gt 0 ]; then
    while getopts ":dhM:t:D:x" opt; do
        case $opt in
            d)     DEBUGMODE=1;;
            D)     rootdir=${OPTARG};;
            M)     media=${OPTARG};;
            t)     target=${OPTARG};;
            x)     set -x; TRACEMODE=1;;
            h)     Usage;;
           \?)     FatalUsage "Unknown option: -${OPTARG}";;
        esac
    done
    shift $(($OPTIND - 1 ))
fi

# Sanity checks.
if [ ! -d "${rootdir}/${softwaredir}" ]; then
    Fatal "-D < root path > is invalid, this should be the directory where the tranZPUter project directory is located."
fi
if [ ! -d "${rootdir}/${softwaredir}/MZF/${target}" ]; then
    Fatal "-t < target host> is invalid, this should be one of: MZ-80K, MZ-80A, MZ-700, MZ-800, MZ-1500, MZ-2000"
fi
if [ ! -d "${media}" ]; then
    Fatal "-m < root path > is invalid, this should be the directory where the tranZPUter project directory is located."
fi

# Create necessary directories on the SD card.
mkdir -p $media/TZFS/;
mkdir -p $media/MZF/;
mkdir -p $media/CPM/;
mkdir -p $media/BAS;
mkdir -p $media/CAS; 

# Clean out the directories to avoid old files being used.
rm $media/TZFS/*;
rm $media/MZF/*;
rm $media/CPM/*;
rm $media/BAS/*;
rm $media/CAS/*; 

# Copy required files.
cp ${rootdir}/${softwaredir}/roms/tzfs.rom                        $media/TZFS/; 
cp ${rootdir}/${softwaredir}/roms/monitor_SA1510.rom              $media/TZFS/SA1510.rom; 
cp ${rootdir}/${softwaredir}/roms/monitor_80c_SA1510.rom          $media/TZFS/SA1510-8.rom; 
cp ${rootdir}/${softwaredir}/roms/monitor_1Z-013A.rom             $media/TZFS/1Z-013A.rom; 
cp ${rootdir}/${softwaredir}/roms/monitor_80c_1Z-013A.rom         $media/TZFS/1Z-013A-8.rom; 
cp ${rootdir}/${softwaredir}/roms/monitor_1Z-013A-KM.rom          $media/TZFS/1Z-013A-KM.rom; 
cp ${rootdir}/${softwaredir}/roms/monitor_80c_1Z-013A-KM.rom      $media/TZFS/1Z-013A-KM-8.rom; 
cp ${rootdir}/${softwaredir}/roms/MZ80B_IPL.rom                   $media/TZFS/MZ80B_IPL.rom; 
cp ${rootdir}/${softwaredir}/roms/MZ800_*                         $media/TZFS/;
cp ${rootdir}/${softwaredir}/roms/cpm22.bin                       $media/CPM/; 
cp ${rootdir}/${softwaredir}/CPM/SDC16M/RAW/*                     $media/CPM/; 
cp ${rootdir}/${softwaredir}/MZF/Common/*                         $media/MZF/;
cp ${rootdir}/${softwaredir}/MZF/${target}/*                      $media/MZF/;
cp ${rootdir}/${softwaredir}/MZF/MZ-80K/*                         $media/MZF/;
cp ${rootdir}/${softwaredir}/BAS/*                                $media/BAS/; 
cp ${rootdir}/${softwaredir}/CAS/*                                $media/CAS/

echo "Done, TZFS, CPM and host programs copied to SD card."
exit 0
