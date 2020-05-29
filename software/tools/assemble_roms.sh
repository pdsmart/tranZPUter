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
## Copyright:       (c) 2018 Philip Smart <philip.smart@net2net.org>
##
## History:         August 2018   - Initial script written.
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
BUILDROMLIST="monitor_80c_SA1510 MZ80AFI monitor_SA1510 monitor_80c_SA1510"
#BUILDMZFLIST="hi-ramcheck sharpmz-test"
BUILDMZFLIST="sharpmz-test"
ASMDIR=${ROOTDIR}/software/asm
ASMTMPDIR=${ROOTDIR}/software/tmp
INCDIR=${ROOTDIR}/software/asm/include
ROMDIR=${ROOTDIR}/software/roms
MZFDIR=${ROOTDIR}/software/MZF

# Go through list and build image.
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