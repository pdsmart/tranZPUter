#!/bin/bash
#########################################################################################################
##
## Name:            assemble_roms.sh
## Created:         August 2018
## Author(s):       Philip Smart
## Description:     Sharp MZ series ROM assembly tool
##                  This script takes Sharp MZ ROMS in assembler format and compiles/assembles them
##                  into a ROM file using the GLASS Z80 assembler.
##
## Credits:         
## Copyright:       (c) 2018-21 Philip Smart <philip.smart@net2net.org>
##
## History:         August 2018   - Initial script written.
##                  March 2021    - Added MZ-800 IPL
##                  March 2021    - Updated to compile different versions of Microsoft BASIC.
##
#########################################################################################################
## This source file is free software: you can redistribute it and#or modify
## it under the terms of the GNU General Public License as published
## by the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This source file is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.
#########################################################################################################

ROOTDIR=../../tranZPUter
TOOLDIR=${ROOTDIR}/software/tools
JARDIR=${ROOTDIR}/software/tools
ASM=glass-0.5.jar
BUILDROMLIST="MZ800_1Z_013B MZ800_9Z_504M MZ800_IOCS MZ80AFI monitor_SA1510 monitor_80c_SA1510 monitor_1Z-013A monitor_80c_1Z-013A monitor_1Z-013A-KM monitor_80c_1Z-013A-KM MZ80B_IPL"
#BUILDMZFLIST="hi-ramcheck sharpmz-test"
BUILDMZFLIST="5Z009-1B MSBASIC_MZ80A MSBASIC_MZ700 MSBASIC_TZFS sharpmz-test"
ASMDIR=${ROOTDIR}/software/asm
ASMTMPDIR=${ROOTDIR}/software/tmp
INCDIR=${ROOTDIR}/software/asm/include
ROMDIR=${ROOTDIR}/software/roms
MZFDIR=${ROOTDIR}/software/MZF/Common

# Go through list and build image.
#
for f in ${BUILDROMLIST} ${BUILDMZFLIST}
do
    echo "Assembling: $f..."

    SRCNAME=${f}
    ASMNAME=${f}.asm
    OBJNAME=${f}.obj
    SYMNAME=${f}.sym
    ROMNAME=${f}.rom
    MZFNAME=${f}.MZF

    # Special handling for the 4 version of MS BASIC.
    if [[ ${SRCNAME} = "MSBASIC_MZ80A" ]]; then
        ASMNAME="MSBASIC.asm"
        echo "BUILD_VERSION EQU 0" > ${INCDIR}/MSBASIC_BuildVersion.asm
    elif [[ ${SRCNAME} = "MSBASIC_MZ700" ]]; then
        ASMNAME="MSBASIC.asm"
        echo "BUILD_VERSION EQU 1" > ${INCDIR}/MSBASIC_BuildVersion.asm
    elif [[ ${SRCNAME} = "MSBASIC_TZFS" ]]; then
        ASMNAME="MSBASIC.asm"
        echo "BUILD_VERSION EQU 2" > ${INCDIR}/MSBASIC_BuildVersion.asm
    fi

    # Assemble the source.
    echo "java -jar ${JARDIR}/${ASM} ${ASMDIR}/${ASMNAME} ${ASMTMPDIR}/${OBJNAME} ${ASMTMPDIR}/${SYMNAME}"
    java -jar ${JARDIR}/${ASM} ${ASMDIR}/${ASMNAME} ${ASMTMPDIR}/${OBJNAME} ${ASMTMPDIR}/${SYMNAME} -I ${INCDIR}

    # On successful compile, perform post actions else go onto next build.
    #
    if [ $? = 0 ]
    then
        # The object file is binary, no need to link, copy according to build group.
        if [[ ${BUILDROMLIST} = *"${SRCNAME}"* ]]; then
            echo "Copy ${ASMTMPDIR}/${OBJNAME} to ${ROMDIR}/${ROMNAME}"
            cp ${ASMTMPDIR}/${OBJNAME} ${ROMDIR}/${ROMNAME}
        else
            # Build standard MZF files for inclusion in the SD Drive.
            echo "Copy ${ASMTMPDIR}/${OBJNAME} to ${MZFDIR}/${MZFNAME}"
            cp ${ASMTMPDIR}/${OBJNAME} ${MZFDIR}/${MZFNAME}

            # Create sectored versions of file for inclusion into the ROM Drives.
            for BLOCKSIZE in ${BLOCKSIZELIST}
            do
                FILESIZE=$(stat -c%s "${ASMTMPDIR}/${OBJNAME}")
                if [ $((${FILESIZE} % ${BLOCKSIZE})) -ne 0 ]; then
                    FILESIZE=$(( ((${FILESIZE} / ${BLOCKSIZE})+1 ) * ${BLOCKSIZE} ))
                fi

                dd if=/dev/zero ibs=1 count=${FILESIZE} 2>/dev/null | tr "\000" "\377" > "${MZBDIR}/${SRCNAME}.${BLOCKSIZE}.bin"
                dd if="${ASMTMPDIR}/${OBJNAME}" of="${MZBDIR}/${SRCNAME}.${BLOCKSIZE}.bin" conv=notrunc 2>/dev/null
            done
        fi
    fi
done

# Manual tinkering to build the MZ800 Rom.
cat ${ROMDIR}/MZ800_1Z_013B.rom ${ROMDIR}/MZ800_CGROM.ORI ${ROMDIR}/MZ800_9Z_504M.rom ${ROMDIR}/MZ800_IOCS.rom > ${ROMDIR}/MZ800_IPL.rom
