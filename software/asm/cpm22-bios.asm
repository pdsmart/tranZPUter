;--------------------------------------------------------------------------------------------------------
;-
;- Name:            cpm22-bios.asm
;- Created:         January 2020
;- Author(s):       Philip Smart
;- Description:     CPM BIOS for CPM v2.23 on the Sharp MZ80A with the Rom Filing System.
;-                  Most of the code is stored in the ROM based CBIOS which is part of the
;-                  Rom Filing System upgrade. Declarations in this file are for tables
;-                  which need to reside in RAM.
;-
;- Credits:         Some of the comments and parts of the deblocking/blocking algorithm come from the
;                   Z80-MBC2 project, (C) SuperFabius.
;- Copyright:       (c) 2020 Philip Smart <philip.smart@net2net.org>
;-
;- History:         January 2020 - Initial creation.
;-
;--------------------------------------------------------------------------------------------------------
;- This source file is free software: you can redistribute it and-or modify
;- it under the terms of the GNU General Public License as published
;- by the Free Software Foundation, either version 3 of the License, or
;- (at your option) any later version.
;-
;- This source file is distributed in the hope that it will be useful,
;- but WITHOUT ANY WARRANTY; without even the implied warranty of
;- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;- GNU General Public License for more details.
;-
;- You should have received a copy of the GNU General Public License
;- along with this program.  If not, see <http://www.gnu.org/licenses/>.
;--------------------------------------------------------------------------------------------------------

            ORG     CPMBIOS            

;------------------------------------------------------------------------------------------------------------
; DISK PARAMETER HEADER
;
; Disk parameter headers for disk 0 to 3                                      
;                                                                             
; +-------+------+------+------+----------+-------+-------+-------+
; |  XLT  | 0000 | 0000 | 0000 |DIRBUF    | DPB   | CSV   | ALV   |
; +------+------+------+-------+----------+-------+-------+-------+      
;   16B     16B    16B    16B    16B        16B     16B     16B
;
; -XLT    Address of the logical-to-physical translation vector, if used for this particular drive,
;         or the value 0000H if no sector translation takes place (that is, the physical and
;         logical sectornumbers are the same). Disk drives with identical sector skew factors share
;         the same translatetables.
; -0000   Scratch pad values for use within the BDOS, initial value is unimportant.
; -DIRBUF Address of a 128-byte scratch pad area for directory operations within BDOS. All DPHs
;         address the same scratch pad area. 
; -DPB    Address of a disk parameter block for this drive. Drives with identical disk characteristics
;         address the same disk parameter block.
; -CSV    Address of a scratch pad area used for software check for changed disks. This address is
;         different for each DPH.
; -ALV    Address of a scratch pad area used by the BDOS to keep disk storage allocation information.
;         This address is different for each DPH.
;------------------------------------------------------------------------------------------------------------
            ALIGN_NOPS   DPBASE                                          ; Space for 2xROM, 2xFD, 3xSD or upto 7 drives
                                                                         ; These entries are created dynamically based on hardware available.

            ; NB. The Disk Parameter Blocks are stored in CBIOS ROM to save RAM space.

;------------------------------------------------------------------------------------------------------------
; CPN Disk work areas.
;------------------------------------------------------------------------------------------------------------
            ALIGN_NOPS   CDIRBUF                                         ; Memory work areas, just allocate the space.
            ALIGN_NOPS   CSVALVMEM
            ALIGN_NOPS   CSVALVEND
            ALIGN        CBIOSDATA
