#!/bin/bash -x
#########################################################################################################
##
## Name:            assemble_cpm.sh
## Created:         August 2018
## Author(s):       Philip Smart
## Description:     Sharp MZ series CPM assembly tool
##                  This script builds a CPM version compatible with the MZ-80A RFS system.
##
## Credits:         
## Copyright:       (c) 2020 Philip Smart <philip.smart@net2net.org>
##
## History:         January 2020   - Initial script written.
##
#########################################################################################################
## This source file is free software: you can redistribute it and/or modify
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
ASM=glass.jar
BUILDROMLIST="cbios cpm22"
ASMDIR=${ROOTDIR}/software/asm
ASMTMPDIR=${ROOTDIR}/software/tmp
INCDIR=${ROOTDIR}/software/asm/include
ROMDIR=${ROOTDIR}/software/roms                     # Compiled or source ROM files.
HDRDIR=${ROOTDIR}/software/hdr                      # MZF headers directory.
MZFDIR=${ROOTDIR}/software/MZF/Common               # MZF Format source files.
CPMVERSIONS="MZ700_80C:0 MZ80A_80C:1 MZ80A_STD:2"

# As the tranZPUter project has eveolved different variants of CP/M are needed, so this loop along with the CPMVERSIONS string builds the versions as needed.
for ver in ${CPMVERSIONS}
do
    # Setup the version to be built.
    FILEEXT=`echo ${ver} |cut -d: -f1`
    BUILDVER=`echo ${ver}|cut -d: -f2`
    echo "BUILD_VERSION EQU ${BUILDVER}" > ${INCDIR}/CPM_BuildVersion.asm

    # Go through list and build images.
    #
    for f in ${BUILDROMLIST}
    do
        echo "Assembling: $f..."
    
        # Assemble the source.
        echo "java -jar ${JARDIR}/${ASM} ${ASMDIR}/${f}.asm ${ASMTMPDIR}/${f}.obj ${ASMTMPDIR}/${f}.sym"
        java -jar ${JARDIR}/${ASM} ${ASMDIR}/${f}.asm ${ASMTMPDIR}/${f}.obj ${ASMTMPDIR}/${f}.sym -I ${INCDIR}
    
        # On successful compile, perform post actions else go onto next build.
        #
        if [ $? = 0 ]
        then
            # The object file is binary, no need to link, copy according to build group.
            echo "Copy ${ASMDIR}/${f}.obj to ${ROMDIR}/${f}.bin"
            cp ${ASMTMPDIR}/${f}.obj ${ROMDIR}/${f}.bin
        fi
    done

    # Manual tinkering to produce the loadable MZF file...
    #
    cat ${ROMDIR}/cpm22.bin ${ROMDIR}/cbios.bin  > ${ROMDIR}/CPM223_${FILEEXT}.BIN
    cat ${HDRDIR}/cpm22_${FILEEXT}.HDR ${ROMDIR}/CPM223_${FILEEXT}.BIN > ${MZFDIR}/CPM223_${FILEEXT}.MZF
done
