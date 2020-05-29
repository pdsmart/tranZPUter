#!/bin/bash
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
ASM=glass.jar
BUILDROMLIST="cbios cbios_bank1 cbios_bank2 cbios_bank3 cbios_bank4 cpm22"
BUILDMZFLIST=""
ASMDIR=${ROOTDIR}/software/asm
ASMTMPDIR=${ROOTDIR}/software/tmp
INCDIR=${ROOTDIR}/software/asm/include
ROMDIR=${ROOTDIR}/software/roms                     # Compiled or source ROM files.
MZFDIR=${ROOTDIR}/software/MZF                      # MZF Format source files.

# Go through list and build images.
#
for f in ${BUILDROMLIST} ${BUILDMZFLIST}
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
        if [[ ${BUILDROMLIST} = *"${f}"* ]]; then
            echo "Copy ${ASMDIR}/${f}.obj to ${ROMDIR}/${f}.rom"
            cp ${ASMTMPDIR}/${f}.obj ${ROMDIR}/${f}.rom
        else
            echo "Copy ${ASMDIR}/${f}.obj to ${MZFDIR}/${f}.mzf"
            cp ${ASMTMPDIR}/${f}.obj ${MZFDIR}/${f}.mzf
        fi
    fi
done
