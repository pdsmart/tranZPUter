/////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Name:            flashmmcfg.c
// Created:         May 2020
// Author(s):       Philip Smart
// Description:     tranZPUter SW Memory Map Configuration Tool
//                  This program creates the 512KB array which forms the tranZPUterSW memory decoder.
//                  The 512KB Flash has 19 inputs and 8 outputs, the outputs select or enable
//                  a function on the tranZPUter SW design.
//
//                  Inputs:
//                     A0  - Z80_MEM0 = MEM[4:0] for the latched configuration selection. 
//                     A1  - Z80_MEM1            Based on these bits the decoder operates in a 
//                     A2  - Z80_MEM2            differing manner. Basically it will allow areas
//                     A3  - Z80_MEM3            of the Z80 Memory to use the onboard 512K Static RAM
//                     A4  - Z80_MEM4            at a 64Byte granularity or the Sharp MZ80A mainboard.
//                     A5  - Z80_WR   = Z80 Write Signal
//                     A6  - Z80_RD   = Z80 Read Signal
//                     A7  - Z80_IORQ = Z80 IORQ Signal, an IO operation is taking place.
//                     A8  - Z80_MREQ = Z80 MREQ Signal, a memory operation is taking place.
//                     A9  - Z80_A6   = A[15:6] Z80 address lines of IO or Memory target.
//                     A10 - Z80_A7
//                     A11 - Z80_A8
//                     A12 - Z80_A9
//                     A13 - Z80_A10
//                     A14 - Z80_A11
//                     A15 - Z80_A12
//                     A16 - Z80_A13
//                     A17 - Z80_A14
//                     A18 - Z80_A15
//                  Outputs:
//                     D0  - DISABLE_BUS - This signal clears an SR latch which in turn sets BUSACK on the main Sharp MZ80A board. This tristates all major Z80 signals coming from the tranZPUter board to the Sharp mainboard.
//                     D1  - ENABLE_BUS  - This signal sets an SR latch which in turn disables BUSACK allowing all Z80 signals to be sent to the Sharp mainboard.
//                     D2  - A16         - Upper address bit to select a portion of the 512K Static RAM.
//                     D3  - A17         - Upper address bit to select a portion of the 512K Static RAM.
//                     D4  - A18         - Upper address bit to select a portion of the 512K Static RAM.
//                     D5  - IODECODE    - This signal is active whenever an OUT/IN instruction is issued to a reserved address, typically 060H. According to the value of address lines A3:A1 a tranZPUter feature is accessed such as the memory map selection latch.
//                     D6  - WE          - This signal is active whenever a write is to take place into the 512K Static RAM on the tranZPUter board.
//                     D7  - OE          - This signal is active whenever a read is to take place from the 512K Static RAM on the tranZPUter board.
//
// Memory Modes:     0 - Default, normal Sharp MZ80A operating mode, all memory and IO (except tranZPUter control IO block) are on the mainboard
//                   1 - As 0 except User ROM is mapped to tranZPUter RAM.
//                   2 - TZFS, Monitor ROM 0000-0FFF, Main DRAM 0x1000-0xD000, User/Floppy ROM E800-FFFF are in tranZPUter memory. Two small holes at F3FE and F7FE exist for the Floppy disk controller (which have to be 64
//                       bytes from F3C0 and F7C0 due to the granularity of the address lines into the Flash RAM), these locations  need to be on the mainboard.
//                       NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
//                   3 - TZFS, Monitor ROM 0000-0FFF, Main RAM area 0x1000-0xD000, User ROM 0xE800-EFFF are in tranZPUter memory block 0, Floppy ROM F000-FFFF are in tranZPUter memory block 1.
//                       NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
//                   4 - TZFS, Monitor ROM 0000-0FFF, Main RAM area 0x1000-0xD000, User ROM 0xE800-EFFF are in tranZPUter memory block 0, Floppy ROM F000-FFFF are in tranZPUter memory block 2.
//                       NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
//                   5 - TZFS, Monitor ROM 0000-0FFF, Main RAM area 0x1000-0xD000, User ROM 0xE800-EFFF are in tranZPUter memory block 0, Floppy ROM F000-FFFF are in tranZPUter memory block 3.
//                       NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
//                   6 - CPM, all memory on the tranZPUter board, 64K block 4 selected.
//                       Special case for F3C0:F3FF & F7C0:F7FF (floppy disk paging vectors) which resides on the mainboard.
//                   7 - CPM, F000-FFFF are on the tranZPUter board in block 4, 0040-CFFF and E800-EFFF are in block 5 selected, mainboard for D000-DFFF (video), E000-E800 (Memory control) selected.
//                       Special case for 0000:003F (interrupt vectors) which resides in block 4, F3C0:F3FF & F7C0:F7FF (floppy disk paging vectors) which resides on the mainboard.
//                  24 - All memory and IO are on the tranZPUter board, 64K block 0 selected.
//                  25 - All memory and IO are on the tranZPUter board, 64K block 1 selected.
//                  26 - All memory and IO are on the tranZPUter board, 64K block 2 selected.
//                  27 - All memory and IO are on the tranZPUter board, 64K block 3 selected.
//                  28 - All memory and IO are on the tranZPUter board, 64K block 4 selected.
//                  29 - All memory and IO are on the tranZPUter board, 64K block 5 selected.
//                  30 - All memory and IO are on the tranZPUter board, 64K block 6 selected.
//                  31 - All memory and IO are on the tranZPUter board, 64K block 7 selected.
//
//
// Credits:         
// Copyright:       (c) 2020 Philip Smart <philip.smart@net2net.org>
//
// History:         May 2020   - Initial program written.
//
// Notes:           
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// This source file is free software: you can redistribute it and#or modify
// it under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This source file is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
/////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>
#include <unistd.h>
#include <string.h>
#include <getopt.h>

#define VERSION              "1.0"
#define FLASHRAMBITS         19
#define FLASHRAMSIZE         1 << FLASHRAMBITS
#define CFGBITS              5
#define CFGSETS              (1 << CFGBITS)
#define TRANCHESIZE          (FLASHRAMSIZE) / (CFGSETS)

#define CFG_IO_CONTROL_ADDR  0x60

typedef struct __attribute__((__packed__)) {
    uint8_t   DISABLE_BUS : 1;
    uint8_t   ENABLE_BUS  : 1;
    uint8_t   A16         : 1;
    uint8_t   A17         : 1;
    uint8_t   A18         : 1;
    uint8_t   IODECODE    : 1;
    uint8_t   RAM_WE      : 1;
    uint8_t   RAM_OE      : 1;
} t_map_output;

// Structure to represent one of the 32 possible memory map configurations as set by the MEM[4:0] latch.
//
typedef struct __attribute__((__packed__)) {
    t_map_output tranche[TRANCHESIZE];
} t_memmap_tranche;

static t_memmap_tranche flashRAM[CFGSETS];
static int              verbose_flag      = 0;
static uint32_t         ioAddr            = CFG_IO_CONTROL_ADDR;


// Simple help screen to remmber how this utility works!!
//
void usage(void)
{
    printf("FLASHMMCFG v%s\n", VERSION);
    printf("\nOptions:-\n");
    printf("  -h | --help              This help test.\n");
    printf("  -i | --io-addr <addr>    Base address for the IO Control Registers.\n");
    printf("  -o | --output <file>     Output the final binary image to the given file. This file is programmed into the Flash RAM.\n");
    printf("  -v | --verbose           Output more messages.\n");

    printf("\nExamples:\n");
    printf("  flashmmcfg --output Decode1.bin --io-addr 0x20       Create the mapping binary using 0x20 as the base address for the IO Control Registers.\n");

}

// Method to convert a little endian <-> big endian 32bit unsigned.
//
uint32_t swap_endian(uint32_t value)
{
    uint32_t b[4];
    b[0] = ((value & 0x000000ff) << 24u);
    b[1] = ((value & 0x0000ff00) <<  8u);
    b[2] = ((value & 0x00ff0000) >>  8u);
    b[3] = ((value & 0xff000000) >> 24u);

    return(b[0] | b[1] | b[2] | b[3]);
}

// Method to initialise the structures which represent the output binary image for uploading into the decoder Flash RAM.
// There are a fixed number of 'sets' of configurations which are selected by the MEM[4:0] latch bits, each set gives a 
// different decoding action so that different memory maps and IO maps can be realised by the Z80 dependent upon its task
// or machine it is emulating.
//
void initMap(void)
{
    for(uint8_t idx=0; idx < CFGSETS; idx++)
    {
        for(uint32_t idx2=0; idx2 < TRANCHESIZE; idx2++)
        {
            flashRAM[idx].tranche[idx2].DISABLE_BUS = 1;
            flashRAM[idx].tranche[idx2].ENABLE_BUS  = 1;
            flashRAM[idx].tranche[idx2].A16         = 1;
            flashRAM[idx].tranche[idx2].A17         = 1;
            flashRAM[idx].tranche[idx2].A18         = 1;
            flashRAM[idx].tranche[idx2].IODECODE    = 1;
            flashRAM[idx].tranche[idx2].RAM_WE      = 1;
            flashRAM[idx].tranche[idx2].RAM_OE      = 1;
        }
    }
    return;
}

// This method takes the internal array, organised as sets and tranches and manipulates them to fit the actual hardware
// definition. As the configuration bits MEM[4:0] operate the lowest address select bits of the Flash RAM the output needs
// to be sliced into CFGSETS where byte 0 = byte 0 of config set 0 ..... byte n = byte n of config set n, n = 31 for the 
// current hardware design. This slice is repeated for all TRANCHESIZE bytes in each tranche.
//
void outputMap(FILE *fp)
{
    // Locals.
    uint32_t idx;
    uint8_t  idx2;
    uint8_t  outbuf[CFGSETS];

    // As the configuration bits MEM[4:0] operate the lowest address select bits of the Flash RAM the output needs to be 
    //
    //
    for(idx=0; idx < TRANCHESIZE; idx++)
    {
        for(idx2=0; idx2 < CFGSETS; idx2++)
        {
            outbuf[idx2] = flashRAM[idx2].tranche[idx].RAM_OE      << 7 |
                           flashRAM[idx2].tranche[idx].RAM_WE      << 6 |
                           flashRAM[idx2].tranche[idx].IODECODE    << 5 |
                           flashRAM[idx2].tranche[idx].A16         << 4 |
                           flashRAM[idx2].tranche[idx].A17         << 3 |
                           flashRAM[idx2].tranche[idx].A18         << 2 |
                           flashRAM[idx2].tranche[idx].ENABLE_BUS  << 1 |
                           flashRAM[idx2].tranche[idx].DISABLE_BUS;
        }
        if(fwrite(outbuf, 1, CFGSETS, fp) != CFGSETS)
        {
            printf("Write Error: Failed to write %d bytes of set:tranche %u:%u\n", CFGSETS, idx2, idx);
        }
    }
    return;
}

// This method looks at the input signals for a given set and updates the output bits accordingly.
//
void setMap(uint8_t set, uint32_t inSignals)
{
    // Decode the input signals into there components.
    uint8_t  Z80_WR        = (inSignals & 0b00000000000001);
    uint8_t  Z80_RD        = (inSignals & 0b00000000000010) >> 1;
    uint8_t  Z80_IORQ      = (inSignals & 0b00000000000100) >> 2;
    uint8_t  Z80_MREQ      = (inSignals & 0b00000000001000) >> 3;
    uint8_t  Z80_A6        = (inSignals & 0b00000000010000) >> 4;
    uint8_t  Z80_A7        = (inSignals & 0b00000000100000) >> 5;
    uint8_t  Z80_A8        = (inSignals & 0b00000001000000) >> 6;
    uint8_t  Z80_A9        = (inSignals & 0b00000010000000) >> 7;
    uint8_t  Z80_A10       = (inSignals & 0b00000100000000) >> 8;
    uint8_t  Z80_A11       = (inSignals & 0b00001000000000) >> 9;
    uint8_t  Z80_A12       = (inSignals & 0b00010000000000) >> 10;
    uint8_t  Z80_A13       = (inSignals & 0b00100000000000) >> 11;
    uint8_t  Z80_A14       = (inSignals & 0b01000000000000) >> 12;
    uint8_t  Z80_A15       = (inSignals & 0b10000000000000) >> 13;
    uint32_t Z80_ADDR      = (inSignals & 0b11111111110000) << 2;                                    // 16 bit memory address.
    uint32_t Z80_IO_ADDR   = ((inSignals & 0b00000000110000) << 2) | 0b00100000;                     // 8 bit IO address, bit 5 is hardwired to 1, bit 4 is hardwired to 0.
    uint8_t  Z80_MEM_WRITE = (Z80_WR == 0 && Z80_MREQ == 0 && Z80_RD == 1 && Z80_IORQ == 1) ? 1 : 0;
    uint8_t  Z80_MEM_READ  = (Z80_RD == 0 && Z80_MREQ == 0 && Z80_WR == 1 && Z80_IORQ == 1) ? 1 : 0;
    uint8_t  Z80_IO_WRITE  = (Z80_WR == 0 && Z80_IORQ == 0 && Z80_RD == 1 && Z80_MREQ == 1) ? 1 : 0;
    uint8_t  Z80_IO_READ   = (Z80_RD == 0 && Z80_IORQ == 0 && Z80_WR == 1 && Z80_MREQ == 1) ? 1 : 0;

    //printf("Signals(%u): Z80_WR=%u, Z80_RD=%u, Z80_IORQ=%u, Z80_MREQ=%u, Z80_ADDR=%u, Z80_IO_ADDR=%u\n", inSignals, Z80_WR, Z80_RD, Z80_IORQ, Z80_MREQ, Z80_ADDR, Z80_IO_ADDR);
    //printf("MEMWR=%u, MEMRD=%u, IOWR=%u, IORD=%u\n", Z80_MEM_WRITE, Z80_MEM_READ, Z80_IO_WRITE, Z80_IO_WRITE);

    // Upper address bits are always 0 unless modified by input parameters.
    //
    flashRAM[set].tranche[inSignals].A16 = 0;
    flashRAM[set].tranche[inSignals].A17 = 0;
    flashRAM[set].tranche[inSignals].A18 = 0;

    // Pre transaction setup. The address lines contain the next address prior to the RD/WR/MREQ/IORQ signals being asserted. If a set
    // uses mixed resources, ie tranZPUter ond mainboard then their is a propogation delay from the FlashRAM being presented with the signals
    // to it outputting a signal plus additional delays for the 279 SR latch, 74HCT08 AND gate and the tristate buffers on the mainboard. This
    // action on the address to pre enable the mainboard or tranZPUter removes the propagation effect on the BUSACK signal on the main board.
    //
    switch(set)
    {
        // Set 0 - default, no tranZPUter RAM access so just pulse the ENABLE_BUS signal for safety to ensure the CPU has continuous access to the
        // mainboard resources, especially for Refresh of DRAM.
        case 0:
            flashRAM[set].tranche[inSignals].DISABLE_BUS = 1;
            flashRAM[set].tranche[inSignals].ENABLE_BUS = 0;
            break;

        // Whenever running in RAM ensure the mainboard is disabled to prevent decoder propagation delay glitches.
        case 1:
            if( (Z80_ADDR >= 0xE800 && Z80_ADDR < 0xF000) )
            {
                flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                flashRAM[set].tranche[inSignals].ENABLE_BUS = 1;
            } else
            {
                flashRAM[set].tranche[inSignals].DISABLE_BUS = 1;
                flashRAM[set].tranche[inSignals].ENABLE_BUS = 0;
            }
            break;

        // Set 2 - Monitor ROM 0000-0FFF, Main DRAM 0x1000-0xD000, User/Floppy ROM E800-FFFF are in tranZPUter memory. Two small holes at F3FE and F7FE exist for the Floppy disk controller (which have to be 64
        // bytes from F3C0 and F7C0 due to the granularity of the address lines into the Flash RAM), these locations  need to be on the mainboard.
        // NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
        case 2:
            if( (Z80_ADDR >= 0x0000 && Z80_ADDR < 0xD000) || (Z80_ADDR >= 0xE800 && Z80_ADDR < 0xF3C0) || (Z80_ADDR >= 0xF400 && Z80_ADDR < 0xF7C0) || (Z80_ADDR >= 0xF800 && Z80_ADDR < 0x10000)) 
            {
                flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                flashRAM[set].tranche[inSignals].ENABLE_BUS = 1;
            } else
            {
                flashRAM[set].tranche[inSignals].DISABLE_BUS = 1;
                flashRAM[set].tranche[inSignals].ENABLE_BUS = 0;
            }
            break;
        
        // Set 3 - Monitor ROM 0000-0FFF, Main RAM area 0x1000-0xD000, User ROM 0xE800-EFFF are in tranZPUter memory block 0, Floppy ROM F000-FFFF are in tranZPUter memory block 1.
        // NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
        case 3:
            if( (Z80_ADDR >= 0x0000 && Z80_ADDR < 0xD000) || (Z80_ADDR >= 0xE800 && Z80_ADDR < 0xF000)) 
            {
                flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                flashRAM[set].tranche[inSignals].ENABLE_BUS = 1;
            } else if ((Z80_ADDR >= 0xF000 && Z80_ADDR < 0xF3C0) || (Z80_ADDR >= 0xF400 && Z80_ADDR < 0xF7C0) || (Z80_ADDR >= 0xF800 && Z80_ADDR < 0x10000))
            {
                flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                flashRAM[set].tranche[inSignals].ENABLE_BUS = 1;
                flashRAM[set].tranche[inSignals].A16 = 1;
                flashRAM[set].tranche[inSignals].A17 = 0;
                flashRAM[set].tranche[inSignals].A18 = 0;
            } else
            {
                flashRAM[set].tranche[inSignals].DISABLE_BUS = 1;
                flashRAM[set].tranche[inSignals].ENABLE_BUS = 0;
            } 
            break;
           
        // Set 4 - Monitor ROM 0000-0FFF, Main RAM area 0x1000-0xD000, User ROM 0xE800-EFFF are in tranZPUter memory block 0, Floppy ROM F000-FFFF are in tranZPUter memory block 2.
        // NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
        case 4:
            if( (Z80_ADDR >= 0x0000 && Z80_ADDR < 0xD000) || (Z80_ADDR >= 0xE800 && Z80_ADDR < 0xF000)) 
            {
                flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                flashRAM[set].tranche[inSignals].ENABLE_BUS = 1;
            } else if ((Z80_ADDR >= 0xF000 && Z80_ADDR < 0x10000))
            {
                flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                flashRAM[set].tranche[inSignals].ENABLE_BUS = 1;
                flashRAM[set].tranche[inSignals].A16 = 0;
                flashRAM[set].tranche[inSignals].A17 = 1;
                flashRAM[set].tranche[inSignals].A18 = 0;
            } else
            {
                flashRAM[set].tranche[inSignals].DISABLE_BUS = 1;
                flashRAM[set].tranche[inSignals].ENABLE_BUS = 0;
            } 
            break;
           
        // Set 5 - Monitor ROM 0000-0FFF, Main RAM area 0x1000-0xD000, User ROM 0xE800-EFFF are in tranZPUter memory block 0, Floppy ROM F000-FFFF are in tranZPUter memory block 3.
        // NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
        case 5:
            if( (Z80_ADDR >= 0x0000 && Z80_ADDR < 0xD000) || (Z80_ADDR >= 0xE800 && Z80_ADDR < 0xF000)) 
            {
                flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                flashRAM[set].tranche[inSignals].ENABLE_BUS = 1;
            } else if ((Z80_ADDR >= 0xF000 && Z80_ADDR < 0x10000))
            {
                flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                flashRAM[set].tranche[inSignals].ENABLE_BUS = 1;
                flashRAM[set].tranche[inSignals].A16 = 1;
                flashRAM[set].tranche[inSignals].A17 = 1;
                flashRAM[set].tranche[inSignals].A18 = 0;
            } else
            {
                flashRAM[set].tranche[inSignals].DISABLE_BUS = 1;
                flashRAM[set].tranche[inSignals].ENABLE_BUS = 0;
            } 
            break;
           
        // Set 6 - CPM, all memory on the tranZPUter board, 64K block 4 selected.
        // Special case for F3C0:F3FF & F7C0:F7FF (floppy disk paging vectors) which resides on the mainboard.
        case 6:
            if ((Z80_ADDR >= 0x0000 && Z80_ADDR < 0xF000) || (Z80_ADDR >= 0xF000 && Z80_ADDR < 0xF3C0) || (Z80_ADDR >= 0xF400 && Z80_ADDR < 0xF7C0) || (Z80_ADDR >= 0xF800 && Z80_ADDR < 0x10000))
            {
                flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                flashRAM[set].tranche[inSignals].ENABLE_BUS = 1;
                flashRAM[set].tranche[inSignals].A16 = 0;
                flashRAM[set].tranche[inSignals].A17 = 0;
                flashRAM[set].tranche[inSignals].A18 = 1;
            }
            else
            {
                flashRAM[set].tranche[inSignals].DISABLE_BUS = 1;
                flashRAM[set].tranche[inSignals].ENABLE_BUS = 0;
            }
            break;

        // Set 7 - CPM, F000-FFFF are on the tranZPUter board in block 4, 0040-CFFF and E800-EFFF are in block 5 selected, mainboard for D000-DFFF (video), E000-E800 (Memory control) selected.
        // Special case for 0000:00FF (interrupt vectors) which resides in block 4 and CPM vectors, F3C0:F3FF & F7C0:F7FF (floppy disk paging vectors) which resides on the mainboard.
        case 7:
            if ((Z80_ADDR >= 0x0000 && Z80_ADDR < 0x0100) || (Z80_ADDR >= 0xF000 && Z80_ADDR < 0xF3C0) || (Z80_ADDR >= 0xF400 && Z80_ADDR < 0xF7C0) || (Z80_ADDR >= 0xF800 && Z80_ADDR < 0x10000))
            {
                flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                flashRAM[set].tranche[inSignals].ENABLE_BUS = 1;
                flashRAM[set].tranche[inSignals].A16 = 0;
                flashRAM[set].tranche[inSignals].A17 = 0;
                flashRAM[set].tranche[inSignals].A18 = 1;
            }
            else if((Z80_ADDR >= 0x0100 && Z80_ADDR < 0xD000) || (Z80_ADDR >= 0xE800 && Z80_ADDR < 0xF000))
            {
                flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                flashRAM[set].tranche[inSignals].ENABLE_BUS = 1;
                flashRAM[set].tranche[inSignals].A16 = 1;
                flashRAM[set].tranche[inSignals].A17 = 0;
                flashRAM[set].tranche[inSignals].A18 = 1;
            }
            else
            {
                flashRAM[set].tranche[inSignals].DISABLE_BUS = 1;
                flashRAM[set].tranche[inSignals].ENABLE_BUS = 0;
            }
            break;

         
        // Set 24 - All memory and IO are on the tranZPUter board, 64K block 0 selected.
        case 24:
            flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
            flashRAM[set].tranche[inSignals].ENABLE_BUS = 1;
            flashRAM[set].tranche[inSignals].A16 = 0;
            flashRAM[set].tranche[inSignals].A17 = 0;
            flashRAM[set].tranche[inSignals].A18 = 0;
            break;
        // Set 25 - All memory and IO are on the tranZPUter board, 64K block 1 selected.
        case 25:
            flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
            flashRAM[set].tranche[inSignals].ENABLE_BUS = 1;
            flashRAM[set].tranche[inSignals].A16 = 1;
            flashRAM[set].tranche[inSignals].A17 = 0;
            flashRAM[set].tranche[inSignals].A18 = 0;
            break;
        // Set 26 - All memory and IO are on the tranZPUter board, 64K block 2 selected.
        case 26:
            flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
            flashRAM[set].tranche[inSignals].ENABLE_BUS = 1;
            flashRAM[set].tranche[inSignals].A16 = 0;
            flashRAM[set].tranche[inSignals].A17 = 1;
            flashRAM[set].tranche[inSignals].A18 = 0;
            break;
        // Set 27 - All memory and IO are on the tranZPUter board, 64K block 3 selected.
        case 27:
            flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
            flashRAM[set].tranche[inSignals].ENABLE_BUS = 1;
            flashRAM[set].tranche[inSignals].A16 = 1;
            flashRAM[set].tranche[inSignals].A17 = 1;
            flashRAM[set].tranche[inSignals].A18 = 0;
            break;
        // Set 28 - All memory and IO are on the tranZPUter board, 64K block 4 selected.
        case 28:
            flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
            flashRAM[set].tranche[inSignals].ENABLE_BUS = 1;
            flashRAM[set].tranche[inSignals].A16 = 0;
            flashRAM[set].tranche[inSignals].A17 = 0;
            flashRAM[set].tranche[inSignals].A18 = 1;
            break;
        // Set 29 - All memory and IO are on the tranZPUter board, 64K block 5 selected.
        case 29:
            flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
            flashRAM[set].tranche[inSignals].ENABLE_BUS = 1;
            flashRAM[set].tranche[inSignals].A16 = 1;
            flashRAM[set].tranche[inSignals].A17 = 0;
            flashRAM[set].tranche[inSignals].A18 = 1;
            break;
        // Set 30 - All memory and IO are on the tranZPUter board, 64K block 6 selected.
        case 30:
            flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
            flashRAM[set].tranche[inSignals].ENABLE_BUS = 1;
            flashRAM[set].tranche[inSignals].A16 = 0;
            flashRAM[set].tranche[inSignals].A17 = 1;
            flashRAM[set].tranche[inSignals].A18 = 1;
            break;
        // Set 31 - All memory and IO are on the tranZPUter board, 64K block 7 selected.
        case 31:
            flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
            flashRAM[set].tranche[inSignals].ENABLE_BUS = 1;
            flashRAM[set].tranche[inSignals].A16 = 1;
            flashRAM[set].tranche[inSignals].A17 = 1;
            flashRAM[set].tranche[inSignals].A18 = 1;
            break;
          
        // Default, most modes will need access to the hardware on the mainboard, so if the address falls into the memory mapped devices,
        // pulse the ENABLE_BUS signal. Conversely, if running in tranZPUter RAM disable the mainboard to prevent decoder glitches activating
        // mainboard circuits.
        //
        default:
            if(Z80_ADDR >= 0xD000 && Z80_ADDR < 0xE800)
            {
                flashRAM[set].tranche[inSignals].DISABLE_BUS = 1;
                flashRAM[set].tranche[inSignals].ENABLE_BUS = 0;
            } else
            {
                flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                flashRAM[set].tranche[inSignals].ENABLE_BUS = 1;
            }
            break;
    }

    // If the non-standard case of Z80 RD and Z80 WR being set low occurs, enable the ENABLE_BUS signal as the K64F is requesting access to the MZ80A motherboard.
    //
    if(Z80_RD == 0 && Z80_WR == 0 && Z80_MREQ == 1 && Z80_IORQ == 1)
    {
        flashRAM[set].tranche[inSignals].DISABLE_BUS = 1;
        flashRAM[set].tranche[inSignals].ENABLE_BUS  = 0;
        flashRAM[set].tranche[inSignals].RAM_OE      = 1;
        flashRAM[set].tranche[inSignals].RAM_WE      = 1;
        flashRAM[set].tranche[inSignals].IODECODE    = 1;
    }


    // Defaults for IO operations, can be overriden for a specific set but should be present in all other sets.
    //
    if(Z80_IO_WRITE || Z80_IO_READ)
    {
        // If the address is within configured IO control register range, activate the IODECODE signal.
        if(Z80_IO_ADDR == ioAddr)
        {
            flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
            flashRAM[set].tranche[inSignals].ENABLE_BUS  = 1;
            flashRAM[set].tranche[inSignals].IODECODE    = 0;
        } else
        {
            flashRAM[set].tranche[inSignals].ENABLE_BUS  = 0;
            flashRAM[set].tranche[inSignals].DISABLE_BUS = 1;
            flashRAM[set].tranche[inSignals].IODECODE    = 1;
        }  
    }

    // Specific mapping for Memory Writes.
    if(Z80_MEM_WRITE)
    {
        switch(set)
        {
            // Set 0 - default, the Z80 uses the motherboard so no special signal activation is needed.
            case 0:
                break;

            // Set 1 - A standard MZ80A, the tranZPUter maps in RAM to the User ROM slot but otherwise all standard.
            // NB: This set is mainly used for bootstrapping, prolonged access to the User ROM areas will see the main DRAM refresh being skipped
            // and thus loss of data.
            case 1:
                // Place a bank of RAM into the user ROM area.
                if( (Z80_ADDR >= 0xEC80 && Z80_ADDR < 0xF000) )
                {
                    flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                    flashRAM[set].tranche[inSignals].RAM_WE = 0;
                }
                break;

            // Set 2 - Monitor ROM 0000-0FFF, Main RAM area 0x1000-0xD000, User/Floppy ROM E800-FFFF are in tranZPUter memory Block 0.
            // NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
            case 2:
                if( (Z80_ADDR >= 0x0000 && Z80_ADDR < 0xD000) || (Z80_ADDR >= 0xE840 && Z80_ADDR < 0xF3C0) || (Z80_ADDR >= 0xF400 && Z80_ADDR < 0xF7C0) || (Z80_ADDR >= 0xF800 && Z80_ADDR < 0x10000)) 
                {
                    flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                    flashRAM[set].tranche[inSignals].RAM_WE = 0;
                    flashRAM[set].tranche[inSignals].RAM_OE = 1;
                } 
                break;

            // Set 3 - Monitor ROM 0000-0FFF, Main RAM area 0x1000-0xD000, User ROM 0xE800-EFFF are in tranZPUter memory block 0, Floppy ROM F000-FFFF are in tranZPUter memory block 1.
            // NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
            case 3:
                if( (Z80_ADDR >= 0x0000 && Z80_ADDR < 0xD000) || (Z80_ADDR >= 0xE840 && Z80_ADDR < 0xF3C0) || (Z80_ADDR >= 0xF400 && Z80_ADDR < 0xF7C0) || (Z80_ADDR >= 0xF800 && Z80_ADDR < 0x10000)) 
                {
                    flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                    flashRAM[set].tranche[inSignals].RAM_WE = 0;
                    flashRAM[set].tranche[inSignals].RAM_OE = 1;
                }
                break;
               
            // Set 4 - Monitor ROM 0000-0FFF, Main RAM area 0x1000-0xD000, User ROM 0xE800-EFFF are in tranZPUter memory block 0, Floppy ROM F000-FFFF are in tranZPUter memory block 2.
            // NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
            case 4:
                if( (Z80_ADDR >= 0x0000 && Z80_ADDR < 0x1000) || (Z80_ADDR >= 0x1000 && Z80_ADDR < 0xD000) || (Z80_ADDR >= 0xE801 && Z80_ADDR < 0x10000) ) 
                {
                    flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                    flashRAM[set].tranche[inSignals].RAM_WE = 0;
                    flashRAM[set].tranche[inSignals].RAM_OE = 1;
                } 
                break;
               
            // Set 5 - Monitor ROM 0000-0FFF, Main RAM area 0x1000-0xD000, User ROM 0xE800-EFFF are in tranZPUter memory block 0, Floppy ROM F000-FFFF are in tranZPUter memory block 3.
            // NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
            case 5:
                if( (Z80_ADDR >= 0x0000 && Z80_ADDR < 0x1000) || (Z80_ADDR >= 0x1000 && Z80_ADDR < 0xD000) || (Z80_ADDR >= 0xE801 && Z80_ADDR < 0x10000) ) 
                {
                    flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                    flashRAM[set].tranche[inSignals].RAM_WE = 0;
                    flashRAM[set].tranche[inSignals].RAM_OE = 1;
                } 
                break;

            // Set 6 - CPM, all memory on the tranZPUter board, 64K block 4 selected.
            // Special case for F3C0:F3FF & F7C0:F7FF (floppy disk paging vectors) which resides on the mainboard.
            case 6:
                if( (Z80_ADDR >= 0x0000 && Z80_ADDR < 0xF3C0) || (Z80_ADDR >= 0xF400 && Z80_ADDR < 0xF7C0) || (Z80_ADDR >= 0xF800 && Z80_ADDR < 0x10000)) 
                {
                    flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                    flashRAM[set].tranche[inSignals].RAM_WE = 0;
                    flashRAM[set].tranche[inSignals].RAM_OE = 1;
                }
                break;

            // Set 7 - CPM, F000-FFFF are on the tranZPUter board in block 4, 0040-CFFF and E800-EFFF are in block 5 selected, mainboard for D000-DFFF (video), E000-E800 (Memory control) selected.
            // Special case for 0000:00FF (interrupt vectors) which resides in block 4 and CPM vectors, F3C0:F3FF & F7C0:F7FF (floppy disk paging vectors) which resides on the mainboard.
            case 7:
                if( (Z80_ADDR >= 0x0000 && Z80_ADDR < 0xD000) || (Z80_ADDR >= 0xE800 && Z80_ADDR < 0xF3C0) || (Z80_ADDR >= 0xF400 && Z80_ADDR < 0xF7C0) || (Z80_ADDR >= 0xF800 && Z80_ADDR < 0x10000)) 
                {
                    flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                    flashRAM[set].tranche[inSignals].RAM_WE = 0;
                    flashRAM[set].tranche[inSignals].RAM_OE = 1;
                }
                break;

            // Set 24 - All memory and IO are on the tranZPUter board, 64K block 0 selected.
            case 24:
                flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                flashRAM[set].tranche[inSignals].RAM_WE = 0;
                break;
            // Set 25 - All memory and IO are on the tranZPUter board, 64K block 1 selected.
            case 25:
                flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                flashRAM[set].tranche[inSignals].RAM_WE = 0;
                break;
            // Set 26 - All memory and IO are on the tranZPUter board, 64K block 2 selected.
            case 26:
                flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                flashRAM[set].tranche[inSignals].RAM_WE = 0;
                break;
            // Set 27 - All memory and IO are on the tranZPUter board, 64K block 3 selected.
            case 27:
                flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                flashRAM[set].tranche[inSignals].RAM_WE = 0;
                break;
            // Set 28 - All memory and IO are on the tranZPUter board, 64K block 4 selected.
            case 28:
                flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                flashRAM[set].tranche[inSignals].RAM_WE = 0;
                break;
            // Set 29 - All memory and IO are on the tranZPUter board, 64K block 5 selected.
            case 29:
                flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                flashRAM[set].tranche[inSignals].RAM_WE = 0;
                break;
            // Set 30 - All memory and IO are on the tranZPUter board, 64K block 6 selected.
            case 30:
                flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                flashRAM[set].tranche[inSignals].RAM_WE = 0;
                break;
            // Set 31 - All memory and IO are on the tranZPUter board, 64K block 7 selected.
            case 31:
                flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                flashRAM[set].tranche[inSignals].RAM_WE = 0;
                break;

            // For default, do nothing.
            default:
                break;
        }
    }

    // Specific mapping for Memory Reads.
    else if(Z80_MEM_READ)
    {
        switch(set)
        {
            // Set 0 - default, the Z80 uses the motherboard so no signal activation is needed.
            case 0:
                break;

            // Set 1 - A standard MZ80A, the tranZPUter maps in RAM to the User ROM slot but otherwise all standard.
            // NB: This set is mainly used for bootstrapping, prolonged access to the User ROM areas will see the main DRAM refresh being skipped
            // and thus loss of data.
            case 1:
                // Place a bank of RAM into the user ROM area.
                if( (Z80_ADDR >= 0xE800 && Z80_ADDR < 0xF000) )
                {
                    flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                    flashRAM[set].tranche[inSignals].RAM_OE = 0;
                }
                break;

            // Set 2 - Monitor ROM 0000-0FFF, Main DRAM 0x1000-0xD000, User/Floppy ROM E800-FFFF are in tranZPUter memory.
            // NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
            case 2:
                if( (Z80_ADDR >= 0x0000 && Z80_ADDR < 0xD000) || (Z80_ADDR >= 0xE800 && Z80_ADDR < 0xF3C0) || (Z80_ADDR >= 0xF400 && Z80_ADDR < 0xF7C0) || (Z80_ADDR >= 0xF800 && Z80_ADDR < 0x10000)) 
                {
                    flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                    flashRAM[set].tranche[inSignals].RAM_WE = 1;
                    flashRAM[set].tranche[inSignals].RAM_OE = 0;
                } 
                break;
            
            // Set 3 - Monitor ROM 0000-0FFF, Main RAM area 0x1000-0xD000, User ROM 0xE800-EFFF are in tranZPUter memory block 0, Floppy ROM F000-FFFF are in tranZPUter memory block 1.
            // NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
            case 3:
                if( (Z80_ADDR >= 0x0000 && Z80_ADDR < 0xD000) || (Z80_ADDR >= 0xE800 && Z80_ADDR < 0xF3C0) || (Z80_ADDR >= 0xF400 && Z80_ADDR < 0xF7C0) || (Z80_ADDR >= 0xF800 && Z80_ADDR < 0x10000)) 
                {
                    flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                    flashRAM[set].tranche[inSignals].RAM_WE = 1;
                    flashRAM[set].tranche[inSignals].RAM_OE = 0;
                } 
                break;
               
            // Set 4 - Monitor ROM 0000-0FFF, Main RAM area 0x1000-0xD000, User ROM 0xE800-EFFF are in tranZPUter memory block 0, Floppy ROM F000-FFFF are in tranZPUter memory block 2.
            // NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
            case 4:
                if( (Z80_ADDR >= 0x0000 && Z80_ADDR < 0x1000) || (Z80_ADDR >= 0x1000 && Z80_ADDR < 0xD000) || (Z80_ADDR >= 0xE800 && Z80_ADDR < 0x10000) ) 
                {
                    flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                    flashRAM[set].tranche[inSignals].RAM_WE = 1;
                    flashRAM[set].tranche[inSignals].RAM_OE = 0;
                } 
                break;
               
            // Set 5 - Monitor ROM 0000-0FFF, Main RAM area 0x1000-0xD000, User ROM 0xE800-EFFF are in tranZPUter memory block 0, Floppy ROM F000-FFFF are in tranZPUter memory block 3.
            // NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
            case 5:
                if( (Z80_ADDR >= 0x0000 && Z80_ADDR < 0x1000) || (Z80_ADDR >= 0x1000 && Z80_ADDR < 0xD000) || (Z80_ADDR >= 0xE800 && Z80_ADDR < 0x10000) ) 
                {
                    flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                    flashRAM[set].tranche[inSignals].RAM_WE = 1;
                    flashRAM[set].tranche[inSignals].RAM_OE = 0;
                } 
                break;
               
            // Set 6 - CPM, all memory on the tranZPUter board, 64K block 4 selected.
            // Special case for F3C0:F3FF & F7C0:F7FF (floppy disk paging vectors) which resides on the mainboard.
            case 6:
                if( (Z80_ADDR >= 0x0000 && Z80_ADDR < 0xF3C0) || (Z80_ADDR >= 0xF400 && Z80_ADDR < 0xF7C0) || (Z80_ADDR >= 0xF800 && Z80_ADDR < 0x10000)) 
                {
                    flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                    flashRAM[set].tranche[inSignals].RAM_WE = 1;
                    flashRAM[set].tranche[inSignals].RAM_OE = 0;
                }
                break;

            // Set 7 - CPM, F000-FFFF are on the tranZPUter board in block 4, 0040-CFFF and E800-EFFF are in block 5 selected, mainboard for D000-DFFF (video), E000-E800 (Memory control) selected.
            // Special case for 0000:00FF (interrupt vectors) which resides in block 4 and CPM vectors, F3C0:F3FF & F7C0:F7FF (floppy disk paging vectors) which resides on the mainboard.
            case 7:
                if( (Z80_ADDR >= 0x0000 && Z80_ADDR < 0xD000) || (Z80_ADDR >= 0xE800 && Z80_ADDR < 0xF3C0) || (Z80_ADDR >= 0xF400 && Z80_ADDR < 0xF7C0) || (Z80_ADDR >= 0xF800 && Z80_ADDR < 0x10000)) 
                {
                    flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                    flashRAM[set].tranche[inSignals].RAM_WE = 1;
                    flashRAM[set].tranche[inSignals].RAM_OE = 0;
                }
                break;

            // Set 24 - All memory and IO are on the tranZPUter board, 64K block 0 selected.
            case 24:
                flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                flashRAM[set].tranche[inSignals].RAM_OE = 0;
                break;
            // Set 25 - All memory and IO are on the tranZPUter board, 64K block 1 selected.
            case 25:
                flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                flashRAM[set].tranche[inSignals].RAM_OE = 0;
                break;
            // Set 26 - All memory and IO are on the tranZPUter board, 64K block 2 selected.
            case 26:
                flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                flashRAM[set].tranche[inSignals].RAM_OE = 0;
                break;
            // Set 27 - All memory and IO are on the tranZPUter board, 64K block 3 selected.
            case 27:
                flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                flashRAM[set].tranche[inSignals].RAM_OE = 0;
                break;
            // Set 28 - All memory and IO are on the tranZPUter board, 64K block 4 selected.
            case 28:
                flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                flashRAM[set].tranche[inSignals].RAM_OE = 0;
                break;
            // Set 29 - All memory and IO are on the tranZPUter board, 64K block 5 selected.
            case 29:
                flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                flashRAM[set].tranche[inSignals].RAM_OE = 0;
                break;
            // Set 30 - All memory and IO are on the tranZPUter board, 64K block 6 selected.
            case 30:
                flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                flashRAM[set].tranche[inSignals].RAM_OE = 0;
                break;
            // Set 31 - All memory and IO are on the tranZPUter board, 64K block 7 selected.
            case 31:
                flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                flashRAM[set].tranche[inSignals].RAM_OE = 0;
                break;
              
            // For default, do nothing.
            default:
                break;
        }
    }

    // Specific mapping for IO Writes.
    else if(Z80_IO_WRITE)
    {
        switch(set)
        {
            case 0:
                break;
              
            // Set 31 - All memory and IO are on the tranZPUter board.
            case 31:
                flashRAM[set].tranche[inSignals].ENABLE_BUS = 1;
                flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                break;

            // For default, do nothing.
            default:
                break;
        }
    }
    
    // Specific mapping for IO Reads.
    else if(Z80_IO_READ)
    {
        switch(set)
        {
            case 0:
                break;
               
            // Set 31 - All memory and IO are on the tranZPUter board.
            case 31:
                flashRAM[set].tranche[inSignals].ENABLE_BUS = 1;
                flashRAM[set].tranche[inSignals].DISABLE_BUS = 0;
                break;

            // For default, do nothing.
            default:
                break;
        }
    }

    // Actions which generally arent a valid Z80 transaction.
    else
    {
    }
}


// A method to create each set definition. At the moment this is manually coded, if I think of a suitable algorithm then this set of
// procedures will change.
//
void createMap(void)
{
    for(uint8_t idx=0; idx < CFGSETS; idx++)
    {
        for(uint32_t idx2=0; idx2 < TRANCHESIZE; idx2++)
        {
            setMap(idx, idx2);
        }
    }
}




// Main program, to be split up into methods at a later date!! Just quick write as Im concentrating on the tranZPUterSW!!
//
int main(int argc, char *argv[])
{
    // Locals.
    char       outputFile[1024];
    FILE       *fpOutput;
    int        help_flag         = 0;
    int        opt; 
    int        option_index      = 0; 

    // Initialise any other variables as needed.
    //
    outputFile[0] = '\0';

    // Modes of operation.
    // flashmmcfg --output file
    // flashmmcfg --help
    static struct option long_options[] =
    {
        {"help",          no_argument,       0,   'h'},
        {"ioaddr",        required_argument, 0,   'i'},
        {"output",        required_argument, 0,   'o'},
        {"verbose",       no_argument,       0,   'v'},
        {0,               0,                 0,    0}
    };

    // Parse the command line options.
    //
    while((opt = getopt_long(argc, argv, ":hvo;", long_options, &option_index)) != -1)  
    {  
        switch(opt)  
        {  
            case 'h':
                help_flag = 1;
                break;

            case 'i':
                ioAddr = atoi(argv[optind]);
                break;

            case 'o':
                strcpy(outputFile, argv[optind]);
                break;

            case 'v':
                verbose_flag = 1;
                break;

            case ':':  
                printf("Option %s needs a value\n", argv[optind-1]);  
                break;  
            case '?':  
                printf("Unknown option: %s, ignoring!\n", argv[optind-1]); 
                break;  
        }  
    } 

    // Validate the input.
    if(help_flag == 1)
    {
        usage();
        exit(0);
    }
    if(strlen(outputFile) == 0 )
    {
        printf("Output file not specified, please use --output <file>.\n");
        exit(10);     
    }

    // Open the output file for read/write operations to store the final Flash RAM binary byte image.
    fpOutput  = fopen(outputFile,  "w+");
    if(fpOutput == NULL)
    {
        printf("Couldnt open the output file:%s.\n", outputFile);
        exit(20);     
    }
    if(ioAddr != 0x20 && ioAddr != 0x60 && ioAddr != 0xA0 && ioAddr != 0xF0)
    {
        printf("IO Control Register Base address is illegal:%04x, it should be one of 0x20, 0x60, 0xA0, 0xF0.\n", ioAddr);
        exit(30);     
    }

    // Initialise the flash map to default unused state.
    //
    initMap();

    // Create the required map.
    //
    createMap();

    // Output the binary image for flashing into the FlashRAM to perform required decoding.
    //
    outputMap(fpOutput);

    // Tidy up, close and finish.
    fclose(fpOutput);
    if(verbose_flag)
        printf("Output file created.\n");
}
