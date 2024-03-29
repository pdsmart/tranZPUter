#!/bin/bash
#########################################################################################################
##
## Name:            make_cpmdisks.sh
## Created:         January 2020
## Author(s):       Philip Smart
## Description:     Script to build CPM Disks for the MZ80A
##                  This is a very basic script to assemble all the CPM source disks into a format
##                  which can be read by the MZ80A tranZPUter version of CPM.
##                  The source is composed of directories of actual original CPM disk contents which have
##                  been assembled or copied from original floppies by people on the internet.
##                  Credit goes to Grant Searle for the CPM_MC series of disks which can be found on his
##                  multicomputer project and to the various CPM archives on the net.
## Credits:         
## Copyright:       (c) 2020 Philip Smart <philip.smart@net2net.org>
##
## History:         Jan 2020 - Initial script written.
##                  May 2020 - Updated to allow 240/320K Rom RFS images to be built
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

# These two variables configure which CPM images and disks to build. If only 1 CPM_RFS ROM Drive is needed,
# remove it fro the lists.
#BUILDCPMLIST="cpm22"
#SOURCEDIRS="CPM_RFS_[1] CPM[0-9][0-9]_* CPM_MC_5 CPM_MC_C? CPM_MC_D? CPM_MC_E? CPM_MC_F? CPM[0-9][0-9]_MZ800*"
SOURCEDIRS="CPM_RFS_[1-2] CPM[0-9][0-9]_* CPM_MC_5 CPM_MC_C? CPM_MC_D? CPM_MC_E? CPM_MC_F? CPM[0-9][0-9]_MZ800*"

ROOTDIR=`realpath ../../tranZPUter`
CPM_PATH=${ROOTDIR}/software/CPM
ROMDIR=${ROOTDIR}/software/roms                     # Compiled or source ROM files.
MZFDIR=${ROOTDIR}/software/MZF/Common               # MZF Format source files.
HDRDIR=${ROOTDIR}/software/hdr                      # MZF Header directory for building images.
DISKSDIR=${ROOTDIR}/software/disks                  # MZF Binary sectored output files to go into ROMS.
FD1M44_PATH=${CPM_PATH}/1M44
FD1M44_CYLS=80
FD1M44_HEADS=2
FD1M44_SECTORS=36
FD1M44_GAP3=78
FD1M44_INTERLEAVE=4
SDC16M_PATH=${CPM_PATH}/SDC16M
SDC16M_CYLS=1024
SDC16M_HEADS=1
SDC16M_SECTORS=32
SDC16M_GAP3=78
SDC16M_INTERLEAVE=1

echo "Creating CPM Disks from all the directories in:$CPM_PATH} matching this filter:${SOURCEDIRS}.."
(cd ${CPM_PATH}
 rm -f ${FD1M44_PATH}/RAW/*.RAW
 rm -f ${FD1M44_PATH}/DSK/*.DSK
 rm -f ${SDC16M_PATH}/RAW/*.RAW
 rm -f ${SDC16M_PATH}/DSK/*.DSK
 for src in ${SOURCEDIRS}
 do
     # Place size of disk in the name, useful when using the Floppy Emulator.
     NEWDSKNAME=`echo ${src} | sed 's/_/_1M44_/'`

     # Copy a blank image to create the new disk.
     cp ${CPM_PATH}/BLANKFD/BLANK_1M44.RAW ${FD1M44_PATH}/RAW/${NEWDSKNAME}.RAW;
     
     # Copy the CPM files from the linux filesystem into the CPM Disk under the CPM filesystem.
     cpmcp -f MZ80A-1440 ${FD1M44_PATH}/RAW/${NEWDSKNAME}.RAW ${CPM_PATH}/${src}/*.* 0:
     
     # Convert the raw image into an Extended DSK format suitable for writing to a Floppy or using with the Lotharek HxC Floppy Emulator.
     samdisk copy ${FD1M44_PATH}/RAW/${NEWDSKNAME}.RAW ${FD1M44_PATH}/DSK/${NEWDSKNAME}.DSK --cyls=${FD1M44_CYLS} --head=${FD1M44_HEADS} --gap3=${FD1M44_GAP3} --sectors=${FD1M44_SECTORS} --interleave=${FD1M44_INTERLEAVE}
 done

 # Build the SD Card drive images, these images differ as they are larger and combine more programs in one disk under different user numbers.

 # Copy the CPM files from the linux filesystem into the CPM Disk under the CPM filesystem.
 cp ${CPM_PATH}/BLANKFD/BLANK_16M.RAW ${SDC16M_PATH}/RAW/CPMDSK00.RAW;
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK00.RAW ${CPM_PATH}/CPM00_SYSTEM/*.*          0:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK00.RAW ${CPM_PATH}/CPM01_TURBOP/*.*          1:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK00.RAW ${CPM_PATH}/CPM02_HI_C/*.*            2:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK00.RAW ${CPM_PATH}/CPM03_FORTRAN80/*.*       3:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK00.RAW ${CPM_PATH}/CPM04_MBASIC/*.*          4:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK00.RAW ${CPM_PATH}/CPM05_COBOL80_v13/*.*     5:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK00.RAW ${CPM_PATH}/CPM06_COBOL80_v20/*.*     6:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK00.RAW ${CPM_PATH}/CPM07_COBOL80/*.*         7:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK00.RAW ${CPM_PATH}/CPM08_Z80FORTH/*.*        8:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK00.RAW ${CPM_PATH}/CPM09_CPMTEX/*.*          9:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK00.RAW ${CPM_PATH}/CPM10_DISKUTILFUNC5/*.*   10:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK00.RAW ${CPM_PATH}/CPM11_MAC80/*.*           11:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK00.RAW ${CPM_PATH}/CPM29_ZSID_v14/*.*        12:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK00.RAW ${CPM_PATH}/CPM32_ZCPR3/*.*           13:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK00.RAW ${CPM_PATH}/CPM33_ZCPR3_COMMON/*.*    14:

 cp ${CPM_PATH}/BLANKFD/BLANK_16M.RAW ${SDC16M_PATH}/RAW/CPMDSK01.RAW;
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK01.RAW ${CPM_PATH}/CPM12_PASCALMTP_v561/*.*  0:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK01.RAW ${CPM_PATH}/CPM26_TPASCAL_v300a/*.*   1:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK01.RAW ${CPM_PATH}/CPM13_MTPUG_01/*.*        2:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK01.RAW ${CPM_PATH}/CPM14_MTPUG_02/*.*        3:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK01.RAW ${CPM_PATH}/CPM15_MTPUG_03/*.*        4:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK01.RAW ${CPM_PATH}/CPM16_MTPUG_04/*.*        5:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK01.RAW ${CPM_PATH}/CPM17_MTPUG_05/*.*        6:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK01.RAW ${CPM_PATH}/CPM18_MTPUG_06/*.*        7:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK01.RAW ${CPM_PATH}/CPM19_MTPUG_07/*.*        8:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK01.RAW ${CPM_PATH}/CPM20_MTPUG_08/*.*        9:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK01.RAW ${CPM_PATH}/CPM21_MTPUG_09/*.*        10:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK01.RAW ${CPM_PATH}/CPM22_MTPUG_10/*.*        11:

 cp ${CPM_PATH}/BLANKFD/BLANK_16M.RAW ${SDC16M_PATH}/RAW/CPMDSK02.RAW;
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK02.RAW ${CPM_PATH}/CPM23_PLI/*.*             0:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK02.RAW ${CPM_PATH}/CPM24_PLI80_v13/*.*       1:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK02.RAW ${CPM_PATH}/CPM25_PLI80_v14/*.*       2:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK02.RAW ${CPM_PATH}/CPM28_PLM80/*.*           3:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK02.RAW ${CPM_PATH}/CPM27_WORDSTAR_v30/*.*    4:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK02.RAW ${CPM_PATH}/CPM31_WORDSTAR_v330/*.*   5:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK02.RAW ${CPM_PATH}/CPM30_WORDSTAR_v400/*.*   6:

 cp ${CPM_PATH}/BLANKFD/BLANK_16M.RAW ${SDC16M_PATH}/RAW/CPMDSK03.RAW;
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK03.RAW ${CPM_PATH}/CPM_MC_C0/*.*             0:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK03.RAW ${CPM_PATH}/CPM_MC_C1/*.*             1:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK03.RAW ${CPM_PATH}/CPM_MC_C2/*.*             2:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK03.RAW ${CPM_PATH}/CPM_MC_C3/*.*             3:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK03.RAW ${CPM_PATH}/CPM_MC_C4/*.*             4:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK03.RAW ${CPM_PATH}/CPM_MC_C5/*.*             5:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK03.RAW ${CPM_PATH}/CPM_MC_C6/*.*             6:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK03.RAW ${CPM_PATH}/CPM_MC_C7/*.*             7:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK03.RAW ${CPM_PATH}/CPM_MC_C8/*.*             8:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK03.RAW ${CPM_PATH}/CPM_MC_C9/*.*             9:

 cp ${CPM_PATH}/BLANKFD/BLANK_16M.RAW ${SDC16M_PATH}/RAW/CPMDSK04.RAW;
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK04.RAW ${CPM_PATH}/CPM_MC_D0/*.*             0:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK04.RAW ${CPM_PATH}/CPM_MC_D1/*.*             1:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK04.RAW ${CPM_PATH}/CPM_MC_D2/*.*             2:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK04.RAW ${CPM_PATH}/CPM_MC_D3/*.*             3:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK04.RAW ${CPM_PATH}/CPM_MC_D4/*.*             4:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK04.RAW ${CPM_PATH}/CPM_MC_D5/*.*             5:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK04.RAW ${CPM_PATH}/CPM_MC_D6/*.*             6:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK04.RAW ${CPM_PATH}/CPM_MC_D7/*.*             7:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK04.RAW ${CPM_PATH}/CPM_MC_D8/*.*             8:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK04.RAW ${CPM_PATH}/CPM_MC_D9/*.*             9:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK04.RAW ${CPM_PATH}/CPM_MC_D9/*.*             9:

 cp ${CPM_PATH}/BLANKFD/BLANK_16M.RAW ${SDC16M_PATH}/RAW/CPMDSK05.RAW;
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK05.RAW ${CPM_PATH}/CPM_MC_E0/*.*             0:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK05.RAW ${CPM_PATH}/CPM_MC_E1/*.*             1:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK05.RAW ${CPM_PATH}/CPM_MC_E2/*.*             2:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK05.RAW ${CPM_PATH}/CPM_MC_E3/*.*             3:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK05.RAW ${CPM_PATH}/CPM_MC_E4/*.*             4:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK05.RAW ${CPM_PATH}/CPM_MC_E5/*.*             5:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK05.RAW ${CPM_PATH}/CPM_MC_E6/*.*             6:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK05.RAW ${CPM_PATH}/CPM_MC_E7/*.*             7:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK05.RAW ${CPM_PATH}/CPM_MC_E8/*.*             8:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK05.RAW ${CPM_PATH}/CPM_MC_E9/*.*             9:

 cp ${CPM_PATH}/BLANKFD/BLANK_16M.RAW ${SDC16M_PATH}/RAW/CPMDSK06.RAW;
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK06.RAW ${CPM_PATH}/CPM_MC_F0/*.*             0:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK06.RAW ${CPM_PATH}/CPM_MC_F1/*.*             1:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK06.RAW ${CPM_PATH}/CPM_MC_F2/*.*             2:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK06.RAW ${CPM_PATH}/CPM_MC_F3/*.*             3:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK06.RAW ${CPM_PATH}/CPM_MC_F4/*.*             4:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK06.RAW ${CPM_PATH}/CPM_MC_F5/*.*             5:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK06.RAW ${CPM_PATH}/CPM_MC_F6/*.*             6:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK06.RAW ${CPM_PATH}/CPM_MC_F7/*.*             7:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK06.RAW ${CPM_PATH}/CPM_MC_F8/*.*             8:
 cpmcp -f MZ80A-SDC16M ${SDC16M_PATH}/RAW/CPMDSK06.RAW ${CPM_PATH}/CPM_MC_F9/*.*             9:

 # Copy a blank image to create the new blank disk.
 cp ${CPM_PATH}/BLANKFD/BLANK_16M.RAW ${SDC16M_PATH}/RAW/CPMDSK07.RAW;
)

# Create the CPM boot image and Drive images.
echo "Building CPM images..."
> /tmp/filelist
for f in ${BUILDCPMLIST}
do
    if [ -f "${ROMDIR}/${f}.bin" ]; then
        CPMIMAGE="${ROMDIR}/${f}.bin"
    elif [ -f "${ROMDIR}/${f}.rom" ]; then
        CPMIMAGE="${ROMDIR}/${f}.rom"
    elif [ -f "${DISKSDIR}/${f}.RAW" ]; then
        CPMIMAGE="${DISKSDIR}/${f}.RAW"
    else
        CPMIMAGE=""
        echo "ALERT! ALERT! Couldnt find CPM image:${f}.RAW, not creating MZF file!"
    fi

    if [ "${CPMIMAGE}" != "" ]; then
        # Building is just a matter of concatenating together the heaader and the rom image.
        cat "${HDRDIR}/${f}.HDR" "${CPMIMAGE}" > "${MZFDIR}/${f}.MZF"

        # Place the name of the file into the MZF list so that we create an MZF format binary from this image.
        (cd ${MZFDIR}; ls -l ${f}.MZF ${f}.mzf 2>/dev/null | sed 's/  / /g' | sed 's/  / /g' | cut -d' ' -f5,9- >> /tmp/filelist 2>/dev/null)
    fi
done

ls ${FD1M44_PATH}/DSK/ ${SDC16M_PATH}/RAW/
echo "Done, all EDSK images can be found in: ${FD1M44_PATH} & ${SDC16M_PATH}."

exit 0
