#!/bin/bash

ROOT_DIR=/dvlp/Projects/dev/github/tranZPUter/
SW_DIR=${ROOT_DIR}/software
PROCESS_MZF_FILES=0
if [ "x$1" = '-m' ]; then
	PROCESS_MZF_FILES=1
fi


(
cd $SW_DIR
tools/assemble_tzfs.sh
if [ $? != 0 ]; then
	echo "TZFS assembly failed..."
	exit 1
fi
tools/assemble_roms.sh
if [ $? != 0 ]; then
	echo "ROMS assembly failed..."
	exit 1
fi
tools/assemble_cpm.sh
if [ $? != 0 ]; then
	echo "CPM assembly failed..."
	exit 1
fi

# Only needed if the program source tree changes, takes too long to run on every build!
if [[ ${PROCESS_MFZ_FILES} -eq 1 ]]; then
	tools/processMZFfiles.sh
	if [ $? != 0 ]; then
		echo "Failed to process MZF files into sectored variants...."
		exit 1
	fi
fi
tools/make_cpmdisks.sh
if [ $? != 0 ]; then
	echo "CPM disks assembly failed..."
	exit 1
fi
)
if [ $? != 0 ]; then
	exit 1
fi

# USE tools/copytosd.sh for copying TZFS to SD card.
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
#     -t<targethost>= Target host, MZ-80A, MZ-700, MZ-800, MZ-2000
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

echo "Done!"
