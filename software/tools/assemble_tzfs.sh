#!/bin/bash
#########################################################################################################
##
## Name:            assemble_tzfs.sh
## Created:         August 2018
## Author(s):       Philip Smart
## Description:     Sharp MZ series TZFS assembly tool
##                  This script takes Sharp MZ TZFS assembler and compiles/assembles them into a file
##                  using the GLASS Z80 assembler. The file can then be loaded by zOS into the 
##                  tranZPUter SW memory as a User ROM application.
##
## Credits:         
## Copyright:       (c) 2018-2020 Philip Smart <philip.smart@net2net.org>
##
## History:         August 2018   - Initial script written.
##                  May 2020      - Branch taken from RFS v2.0 to be used for TZFS on the tranZPUter.
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
BUILDROMLIST="tzfs"
BUILDMZFLIST="testtz"
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

	    # BUG in GLASS 0.5, wont assemble to 0xFFFF so add a padding byte at end.
	    # Uncomment if your not using my modified version 0.5.1 which fixes the bug
	    # echo -n -e '\xff' >> ${ROMDIR}/${f}.rom
        else
            echo "Copy ${ASMDIR}/${f}.obj to ${MZFDIR}/${f}.MZF"
            cp ${ASMTMPDIR}/${f}.obj ${MZFDIR}/${f}.MZF
        fi
    fi
done
