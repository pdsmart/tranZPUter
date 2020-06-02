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

; All CBIOS code, tables and variables are stored in the CBIOS source code.
