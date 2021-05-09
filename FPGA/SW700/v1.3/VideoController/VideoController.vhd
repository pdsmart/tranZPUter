---------------------------------------------------------------------------------------------------------
--
-- Name:            VideoController.vhd
-- Created:         June 2020
-- Author(s):       Philip Smart
-- Description:     Sharp MZ Series Video Module FPGA logic definition file.
--                  This module contains the definition of the video controller used in tranZPUter FPGA
--                  core whicch appears on the tranZPUter and tranZPUter SW 700 boards. The controller
--                  emulates the video logic of the Sharp MZ80A, MZ-700 and MZ80B including pixel graphics.
--                  The design needs 64KB of memory, so using a smaller FPGA would require the addition
--                  of an external SRAM and like most developments, more is better until the design is
--                  finalised as it gives you more options. This is especially true as the core FPGA will
--                  also instantiate Soft-CPU's for the Sharp MZ series, either the T80 clocking at 50-100MHz
--                  or other processors as time deems feasible to incorporate.
--
--                  One aim of this module is to maintain a degree of compatibility with the Sharp MZ
--                  emulator hardware I wrote, backporting enhancements made here and potentially making a
--                  single design shared by both.
--
-- Credits:         
-- Copyright:       (c) 2018-21 Philip Smart <philip.smart@net2net.org>
--
-- History:         June 2020 - Initial creation.
--                  Sep 2020  - Working first version. Slight sync issues on the VGA modes 1 & 2 as
--                              they use a seperate PLL so sometimes switching to these modes causes
--                              flicker which can be resolved by just reswitching to the same mode.
--                              All the MZ80B logic etc has been ported from my Emulator but not yet
--                              tested as I need to finish implementing the MZ80B mode on the MZ80A
--                              via the tranZPUter. Will feed back the video output generation into the
--                              Emulator as the original emulator design has bugs!
--                              A nice to have would be a seperate video output stream to the internal
--                              monitor when using VGA modes on the external display but this requires
--                              another framebuffer and the FPGA hasnt got the resources. Maybe v2.1
--                              will contain a bigger FPGA (or external RAM)!!!!
--                  Oct 2020  - Split off from the Sharp MZ80A Video Module, the Video Module for the 
--                              Sharp MZ700 has the same roots but different control functionality. The
--                              MZ700 version resides within the tranZPUter memory and not the mainboard
--                              allowing for generally easier control. The MZ80A and MZ700 graphics logic
--                              should be pretty much identical.
--                  Nov 2020 -  A further split from the SW700 board v1.2 logic, this time as part of 
--                              a reorganisation where the larger v1.3 FPGA will not only incorporate
--                              video logic but also soft-cpu's.
--                  Dec 2020 -  Added logic to accommodate direct addressing of the various internal
--                              memory devices to allow soft CPU's to avoid using the Sharp MZ register
--                              selection and 8K address space window.
--
---------------------------------------------------------------------------------------------------------
-- This source file is free software: you can redistribute it and-or modify
-- it under the terms of the GNU General Public License as published
-- by the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This source file is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http:--www.gnu.org-licenses->.
---------------------------------------------------------------------------------------------------------
library ieee;
library altera;
library altera_mf;
library pkgs;
use     ieee.std_logic_1164.all;
use     ieee.std_logic_unsigned.all;
use     ieee.numeric_std.all;
use     work.VideoController_pkg.all;
use     altera.altera_syn_attributes.all;
use     altera_mf.all;

entity VideoController is
    --generic (
    --);
    port (    
        -- Primary and video clocks.
        CLOCK_50                 : in    std_logic;                                      -- 50MHz main FPGA clock.

        -- Reset.
        VRESETn                  : in    std_logic;                                      -- Internal reset.

        -- Direct addressing Bus. Normally this is set to 0 during standard Sharp MZ operation, when 23:19 > 0 then direct addressing of the various video
        -- memory's is enabled.
        -- Address    A23 -A16
        -- 0x000000   00000000 - Normal Sharp MZ behaviour
        -- 0x080000   00001000 - Memory and I/O ports mapped into direct addressable memory location.
        --
        --                       A15 - A8 A7 -  A0
        --                       I/O registers are mapped to the bottom 256 bytes mirroring the I/O address.
        -- 0x0800D0              00000000 11010000 - 0xD0 - Set the parameter number to update.
        --                       00000000 11010001 - 0xD1 - Update the lower selected parameter byte.
        --                       00000000 11010010 - 0xD2 - Update the upper selected parameter byte.
        --                       00000000 11010011 - 0xD3 - set the palette slot Off position to be adjusted.
        --                       00000000 11010100 - 0xD4 - set the palette slot On position to be adjusted.
        --                       00000000 11010101 - 0xD5 - set the red palette value according to the PALETTE_PARAM_SEL address.
        --                       00000000 11010110 - 0xD6 - set the green palette value according to the PALETTE_PARAM_SEL address.
        -- 0x0800D7              00000000 11010111 - 0xD7 - set the blue palette value according to the PALETTE_PARAM_SEL address.
        --
        -- 0x0800E0              00000000 11100000 - 0xE0 MZ80B PPI
        --                       00000000 11100100 - 0xE4 MZ80B PIT
        -- 0x0800E8              00000000 11101000 - 0xE8 MZ80B PIO
        --
        --                       00000000 11110000 - 
        --                       00000000 11110001 - 
        --                       00000000 11110010 - 
        -- 0x0800F3              00000000 11110011 - 0xF3 set the VGA border colour.
        --                       00000000 11110100 - 0xF4 set the MZ80B video in/out mode.
        --                       00000000 11110101 - 0xF5 sets the palette.
        --                       00000000 11110110 - 0xF6 set parameters.
        --                       00000000 11110111 - 0xF7 set the graphics processor unit commands.
        --                       00000000 11111000 - 0xF6 set parameters.
        --                       00000000 11111001 - 0xF7 set the graphics processor unit commands.
        --                       00000000 11111010 - 0xF8 set the video mode. 
        --                       00000000 11111011 - 0xF9 set the graphics mode.
        --                       00000000 11111100 - 0xFA set the Red bit mask
        --                       00000000 11111101 - 0xFB set the Green bit mask
        --                       00000000 11111110 - 0xFC set the Blue bit mask
        -- 0x0800FD              00000000 11111111 - 0xFD set the Video memory page in block C000:FFFF 
        --
        --                       Memory registers are mapped to the E000 region as per base machines.
        -- 0x08E010              11100000 00010010 - Program Character Generator RAM. E010 - Write cycle (Read cycle = reset memory swap).
        --                       11100000 00010100 - Normal display select.
        --                       11100000 00010101 - Inverted display select.
        --                       11100010 00000000 - Scroll display register. E200 - E2FF
        -- 0x08E2FF              11111111
        --
        -- 0x090000   00001001 - Video/Attribute RAM. 64K Window.
        -- 0x09D000              11010000 00000000 - Video RAM
        -- 0x09D7FF              11010111 11111111
        -- 0x09D800              11011000 00000000 - Attribute RAM
        -- 0x09DFFF              11011111 11111111
        --
        -- 0x0A0000   00001010 - Character Generator RAM
        -- 0x0A0000              00000000 00000000 - CGROM
        -- 0x0A0FFF              00001111 11111111 
        -- 0x0A1000              00010000 00000000 - CGRAM
        -- 0x0A1FFF              00011111 11111111
        --
        -- 0x0C0000   00001100 - Red framebuffer.
        --                       00000000 00000000 - Red pixel addressed framebuffer. Also MZ-80B GRAM I memory in lower 8K
        -- 0x0C3FFF              00111111 11111111
        -- 0x0D0000   00001101 - Blue framebuffer.
        --                       00000000 00000000 - Blue pixel addressed framebuffer. Also MZ-80B GRAM II memory in lower 8K
        -- 0x0D3FFF              00111111 11111111
        -- 0x0E0000   00001110 - Green framebuffer.
        --                       00000000 00000000 - Green pixel addressed framebuffer.
        -- 0x0E3FFF              00111111 11111111
        --
        VIDEO_ADDR               : in    std_logic_vector(23 downto 0);                  -- CPU Address bus. Upper byte is for direct addressing (ie /= 0) and used by external systems or a soft CPU.

        -- Data Bus
        VIDEO_DATA_IN            : in    std_logic_vector(31 downto 0);                  -- Data bus into video module.
        VIDEO_DATA_OUT           : out   std_logic_vector(31 downto 0);                  -- Data bus out from video module to CPU.

        -- Control signals.
        VIDEO_IORQn              : in    std_logic;                                      -- IORQ signal, active low. When high, request is to memory.
        VIDEO_RDn                : in    std_logic;                                      -- Video RDn from the CPLD, decoded via memory manager.
        VIDEO_WRn                : in    std_logic;                                      -- Video WRn from the CPLD, decoded via memory manager.
        VIDEO_WR_BYTE            : in    std_logic;                                      -- Signal to indicate a byte should be written not a 32bit word.
        VIDEO_WR_HWORD           : in    std_logic;                                      -- Signal to indicate a 16bit half word should be written not a 32bit word.

        -- VGA & Composite output signals.
        VGA_R                    : out   std_logic_vector(3 downto 0);                   -- 16 level Red output.
        VGA_G                    : out   std_logic_vector(3 downto 0);                   -- 16 level Green output.
        VGA_B                    : out   std_logic_vector(3 downto 0);                   -- 16 level Blue output.
        VGA_R_COMPOSITE          : inout std_logic;                                      -- RGB Red override for composite output.
        VGA_G_COMPOSITE          : inout std_logic;                                      -- RGB Green override for composite output.
        VGA_B_COMPOSITE          : inout std_logic;                                      -- RGB Blue override for composite output.
        HSYNC_OUTn               : out   std_logic;                                      -- Horizontal sync.
        VSYNC_OUTn               : out   std_logic;                                      -- Vertical sync.
        COLR_OUT                 : out   std_logic;                                      -- Composite and RF base frequency.
        CSYNC_OUTn               : out   std_logic;                                      -- Composite sync (negative).
        CSYNC_OUT                : out   std_logic;                                      -- Composite sync (positive).

        -- RGB & Composite input signals.
        -- V[name] = Voltage translated signals which mirror the mainboard signals but at a lower voltage.
        VWAITn_V_CSYNC           : inout std_logic;                                      -- Wait signal to the CPU when accessing FPGA video RAM / Composite sync from mainboard.
        V_HSYNCn                 : in    std_logic;                                      -- Horizontal sync (negative) from mainboard.
        V_VSYNCn                 : in    std_logic;                                      -- Vertical sync (negative) from mainboard.
        V_COLR                   : in    std_logic;                                      -- Soft CPU NMIn / Composite and RF base frequency from mainboard.
        V_G                      : in    std_logic;                                      -- Soft CPU BUSRQn / Digital Green (on/off) from mainboard.
        V_B                      : in    std_logic;                                      -- Soft CPU WAITn / Digital Blue (on/off) from mainboard.
        V_R                      : in    std_logic;                                      -- Soft CPU INTn / Digital Red (on/off) from mainboard.
 
        -- Configuration.
        VIDEO_MODE               : in    std_logic_vector(2 downto 0);                   -- Video mode the controller should emulate.
        MB_VIDEO_ENABLEn         : in    std_logic                                       -- Mainboard Video (=0) or FPGA Video (=1).
    );
end entity;

architecture rtl of VideoController is


    -- Constants
    --
    constant MAX_SUBROW          : integer := 8;
    constant VIDEO_DEBUG         : std_logic := '0';

    -- 
    -- Video Timings for different machines and display configuration.
    --
    type VIDEOLUT is array (integer range 0 to 15, integer range 0 to 18) of integer range 0 to 2000;
    constant FB_PARAMS           : VIDEOLUT := (

    -- Display window variables: -
    -- Front porch is included in the <X>_SYNC_START parameters. Back porch is included in the <X>_LINE_END, ie. <X>_LINE_END - <X>_SYNC_END = Back Porch.
    --   0                 1             2                 3                 4                 5            6                 7                8              9             10                 11                   12                    13               14                      15                16                  17                18
    --   H_DSP_START,      H_DSP_END,    H_DSP_WND_START,  H_DSP_WND_END,    V_DSP_START,      V_DSP_END,   V_DSP_WND_START,  V_DSP_WND_END,   H_LINE_END,    V_LINE_END,   MAX_COLUMNS,       H_SYNC_START,        H_SYNC_END,           V_SYNC_START,    V_SYNC_END,             H_POLARITY,       V_POLARITY,         H_PX,             V_PX      			
      (            0,            320,              0,            320,              0,            200,              0,            200,            511,            259,         40,                320  + 43,        320 + 43  + 45,           200 + 19,      200 + 19 + 4,              0,               0,                0,               0),      -- 0  MZ80K/C/1200/A machines have a monochrome 60Hz display with scan of 512 x 260 for a 320x200 viewable area.
      (            0,            640,              0,            640,              0,            200,              0,            200,           1023,            259,         80,                640  + 106,       640 + 106 + 90,           200 + 19,      200 + 19 + 4,              0,               0,                0,               0),      -- 1  MZ80K/C/1200/A machines with an adapted monochrome 60Hz display with scan of 1024 x 260 for a 640x200 viewable area.			
    --(            0,            320,              0,            320,              0,            200,              0,            200,            567,            311,         40,                320  + 80,        320 + 80  + 40,           200 + 50,      200 + 50 + 3,              0,               0,                0,               0),      -- 2  MZ80K/C/1200/A machines with MZ700 style colour @ 50Hz display with scan of 568 x 312 for a 320x200 viewable area.
    --(            0,            640,              0,            640,              0,            200,              0,            200,           1135,            311,         80,                640  + 160,       640 + 160 + 80,           200 + 50,      200 + 50 + 3,              0,               0,                0,               0),      -- 3  MZ80K/C/1200/A machines with MZ700 style colour @ 50Hz display with scan of 1136 x 312 for a 640x200 viewable area.			
      (            0,            320,              0,            320,              0,            200,              0,            200,            567,            259,         40,                320  + 80,        320 + 80  + 40,           200 + 19,      200 + 19 + 4,              0,               0,                0,               0),      -- 2  MZ80K/C/1200/A machines with MZ700 style colour @ 60Hz display with scan of 512 x 260 for a 320x200 viewable area.			
      (            0,            640,              0,            640,              0,            200,              0,            200,           1135,            259,         80,                640  + 160,       640 + 160 + 80,           200 + 19,      200 + 19 + 4,              0,               0,                0,               0),      -- 3  MZ80K/C/1200/A machines with MZ700 style colour @ 60Hz display with scan of 1024 x 260 for a 640x200 viewable area.			

      (            0,            640,              0,            640,              0,            480,              48,           448,            799,            524,         40,                640  + 16,        640 + 16  + 96,           480 + 8,       480 + 8 + 2,              0,               0,                1,               1),      -- 4  Mode 0 upscaled as 640x480 @ 60Hz timings for 40Char mode monochrome. 			
      (            0,            640,              0,            640,              0,            480,              48,           448,            799,            524,         80,                640  + 16,        640 + 16  + 96,           480 + 8,       480 + 8 + 2,              0,               0,                0,               1),      -- 5  Mode 1 upscaled as 640x480 @ 60Hz timings for 80Char mode monochrome.
      (            0,            640,              0,            640,              0,            480,              48,           448,            799,            524,         40,                640  + 16,        640 + 16  + 96,           480 + 8,       480 + 8 + 2,              0,               0,                1,               1),      -- 6  Mode 2 upscaled as 640x480 @ 60Hz timings for 40Char mode colour. 			
      (            0,            640,              0,            640,              0,            480,              48,           448,            799,            524,         80,                640  + 16,        640 + 16  + 96,           480 + 8,       480 + 8 + 2,              0,               0,                0,               1),      -- 7  Mode 3 upscaled as 640x480 @ 60Hz timings for 80Char mode colour.

      (            0,           1024,              32,           992,              0,            768,              80,           680,           1343,            805,         40,               1024  + 24,       1024 + 24  + 136,          768 + 3,       768 +  3 + 6,              0,               0,                2,               2),      -- 8  Mode 0 upscaled as 1024x768 @ 60Hz timings for 40Char mode monochrome. 			
      (            0,           1024,              0,            640,              0,            768,              0,            600,           1343,            805,         80,               1024  + 24,       1024 + 24  + 136,          768 + 3,       768 +  3 + 6,              0,               0,                0,               2),      -- 9  Mode 1 upscaled as 1024x768 @ 60Hz timings for 80Char mode monochrome.
      (            0,           1024,              32,           992,              0,            768,              80,           680,           1343,            805,         40,               1024  + 24,       1024 + 24  + 136,          768 + 3,       768 +  3 + 6,              0,               0,                2,               2),      -- 10 Mode 2 upscaled as 1024x768 @ 60Hz timings for 40Char mode colour. 			
      (            0,           1024,              192,          832,              0,            768,              84,           684,           1343,            805,         80,               1024  + 24,       1024 + 24  + 136,          768 + 3,       768 +  3 + 6,              0,               0,                0,               2),      -- 11 Mode 3 upscaled as 1024x768 @ 60Hz timings for 80Char mode colour.

      (            0,            800,              80,           720,              0,            600,              0,            600,           1055,            627,         40,                800  + 40,        800 + 40  + 128,          600 + 1,       600 + 1 + 4,               1,               1,                1,               2),      -- 12 Mode 0 upscaled as 800x600 @ 60Hz timings for 40Char mode monochrome. 			
      (            0,            800,              0,            640,              0,            600,              0,            600,           1055,            627,         80,                800  + 40,        800 + 40  + 128,          600 + 1,       600 + 1 + 4,               1,               1,                0,               2),      -- 13 Mode 1 upscaled as 800x600 @ 60Hz timings for 80Char mode monochrome.
      (            0,            800,              80,           720,              0,            600,              0,            600,           1055,            627,         40,                800  + 40,        800 + 40  + 128,          600 + 1,       600 + 1 + 4,               1,               1,                1,               2),      -- 14 Mode 2 upscaled as 800x600 @ 60Hz timings for 40Char mode colour. 			
      (            0,            800,              0,            640,              0,            600,              0,            600,           1055,            627,         80,                800  + 40,        800 + 40  + 128,          600 + 1,       600 + 1 + 4,               1,               1,                0,               2)       -- 15 Mode 3 upscaled as 800x600 @ 60Hz timings for 80Char mode colour.
    );


    -- State machine states for the Graphics Processing Unit.
    --
    type GPUStateType is 
    (
        GPU_State_Idle,
        GPU_FB_Clear,
        GPU_FB_Clear_Param,
        GPU_FB_Clear_Start,
        GPU_FB_Clear_1,
        GPU_FB_Clear_2,
        GPU_FB_Clear_3,
        GPU_VRAM_Clear,
        GPU_VRAM_Clear_Attr,
        GPU_VRAM_Clear_Param,
        GPU_VRAM_Clear_Start,
        GPU_VRAM_Clear_1,
        GPU_VRAM_Clear_2,
        GPU_VRAM_Clear_3
    );
    --
    -- Registers
    --
    signal VIDEOMODE             :     integer range 0 to 20;                -- Active video mode, used to index the VIDEOLUT array to select required parameters.
    signal VIDEOMODE_NEXT        :     integer range 0 to 20;                -- Next video mode set when video mode is being changed.
    signal VIDEOMODE_SWITCH      :     std_logic;                            -- Video mode change detected, waiting for current display to complete before change.
    signal VIDEOMODE_RESET_TIMER :     unsigned(7 downto 0);                 -- Video mode changed timer, when not 0 the mode is being changed.
    signal SYS_CLK               :     std_logic;                            -- Video system clocking.
    signal VIDCLK_8MHZ           :     std_logic;                            -- 2x 8MHz base clock for video timing and gate clocking.
    signal VIDCLK_16MHZ          :     std_logic;                            -- 2x 16MHz base clock for video timing and gate clocking.
    signal VIDCLK_65MHZ          :     std_logic;                            -- 2x 65MHz base clock for video timing and gate clocking.
    signal VIDCLK_25_175MHZ      :     std_logic;                            -- 2x 25.175MHz base clock for video timing and gate clocking.
    signal VIDCLK_40MHZ          :     std_logic;                            -- 2x 40MHz base clock for video timing and gate clocking.
    signal VIDCLK_8_86719MHZ     :     std_logic;                            -- 2x original MZ700 video clock.
    signal VIDCLK_17_7344MHZ     :     std_logic;                            -- 2x original MZ700 colour modulator clock.
    signal VIDCLK_8MHZ_Q         :     std_logic;                            -- D-Type flip flop Q output used to enable a clock, active state is '0'.
    signal VIDCLK_16MHZ_Q        :     std_logic;
    signal VIDCLK_8_86719MHZ_Q   :     std_logic;
    signal VIDCLK_17_7344MHZ_Q   :     std_logic;
    signal VIDCLK_25_175MHZ_Q    :     std_logic;
    signal VIDCLK_40MHZ_Q        :     std_logic;
    signal VIDCLK_65MHZ_Q        :     std_logic;
    signal VIDCLK_DIV            :     std_logic;                            -- Video clock divisor, video clock runs at 2x frequency of display.
    signal PLL_LOCKED1           :     std_logic;
    signal PLL_LOCKED2           :     std_logic;
    signal PLL_LOCKED3           :     std_logic;
    signal MAX_COLUMN            :     unsigned(7 downto 0);
    signal FB_ADDR               :     std_logic_vector(14 downto 0);        -- Frame buffer actual address
    signal OFFSET_ADDR           :     std_logic_vector(7 downto 0);         -- Display Offset - for MZ1200/80A machines with 2K VRAM
    signal SR_G_DATA             :     std_logic_vector(7 downto 0);         -- Shift Register to serialise Green pixels.
    signal SR_R_DATA             :     std_logic_vector(7 downto 0);         -- Shift Register to serialise Red pixels.
    signal SR_B_DATA             :     std_logic_vector(7 downto 0);         -- Shift Register to serialise Blue pixels.
    signal DISPLAY_DATA          :     std_logic_vector(23 downto 0);
    signal XFER_ADDR             :     std_logic_vector(10 downto 0);
    signal XFER_SUB_ADDR         :     std_logic_vector(2 downto 0);
    signal XFER_VRAM_DATA        :     std_logic_vector(15 downto 0);
    signal XFER_MAPPED_DATA      :     std_logic_vector(23 downto 0);
    signal XFER_R_WEN            :     std_logic;
    signal XFER_G_WEN            :     std_logic;
    signal XFER_B_WEN            :     std_logic;
    signal XFER_VRAM_ADDR        :     std_logic_vector(10 downto 0);
    signal XFER_SRC_ADDR         :     std_logic_vector(14 downto 0);
    signal XFER_DST_ADDR         :     std_logic_vector(14 downto 0);
    signal XFER_CGROM_ADDR       :     std_logic_vector(11 downto 0);
    signal CGROM_DATA            :     std_logic_vector(7 downto 0);         -- Font Data To Display
    signal DISPLAY_INVERT        :     std_logic;                            -- Invert display Mode of MZ80A/1200
    signal H_SHIFT_CNT           :     integer range 0 to 7;
    signal H_PX                  :     unsigned(7 downto 0);                 -- Variable to indicate if horizontal pixels should be multiplied (for conversion to alternate formats).
    signal H_PX_CNT              :     integer range 0 to 3;           
    signal V_PX                  :     unsigned(7 downto 0);                 -- Variable to indicate if vertical pixels should be multiplied (for conversion to alternate formats).
    signal V_PX_CNT              :     integer range 0 to 3;                 -- Variable to indicate if vertical pixels should be multiplied (for conversion to alternate formats).
    signal VPARAM_DO             :     std_logic_vector(7 downto 0);         -- Video Parameter register read signal.
    signal PCGRAM                :     std_logic := '0';                     -- PCG RAM, allow access to the programmable character generator memory.
    signal MODE_VIDEO_MZ80K      :     std_logic := '0';                     -- The Video Module is running in MZ80K mode.
    signal MODE_VIDEO_MZ80C      :     std_logic := '0';                     -- The Video Module is running in MZ80C mode.
    signal MODE_VIDEO_MZ1200     :     std_logic := '0';                     -- The Video Module is running in MZ1200 mode.
    signal MODE_VIDEO_MZ80A      :     std_logic := '0';                     -- The Video Module is running in MZ80A mode.
    signal MODE_VIDEO_MZ700      :     std_logic := '1';                     -- The Video Module is running in MZ700 mode.
    signal MODE_VIDEO_MZ800      :     std_logic := '0';                     -- The Video Module is running in MZ800 mode.
    signal MODE_VIDEO_MZ80B      :     std_logic := '0';                     -- The Video Module is running in MZ80B mode.
    signal MODE_VIDEO_MZ2000     :     std_logic := '0';                     -- The Video Module is running in MZ2000 mode.
    signal MODE_VIDEO_MONO       :     std_logic := '1';                     -- The Video Module is running in monochrome 40 character mode.
    signal MODE_VIDEO_MONO80     :     std_logic := '0';                     -- The Video Module is running in monochrome 80 character mode.
    signal MODE_VIDEO_COLOUR     :     std_logic := '0';                     -- The Video Module is running in colour 40 character mode.
    signal MODE_VIDEO_COLOUR80   :     std_logic := '0';                     -- The Video Module is running in colour 80 character mode.
    signal MODE_CPLD_MZ80A       :     std_logic := '0';                     -- Machine configuration (memory map, I/O etc) set in the CPLD. When this flag is set, it is running in MZ80A mode.
    signal MODE_CPLD_MZ700       :     std_logic := '1';                     -- Machine configuration (memory map, I/O etc) set in the CPLD. When this flag is set, it is running in MZ700 mode.
    signal MODE_CPLD_MZ800       :     std_logic := '0';                     -- Machine configuration (memory map, I/O etc) set in the CPLD. When this flag is set, it is running in MZ800 mode.
    signal MODE_CPLD_MZ80B       :     std_logic := '0';                     -- Machine configuration (memory map, I/O etc) set in the CPLD. When this flag is set, it is running in MZ80B mode.
    signal MODE_CPLD_MZ80K       :     std_logic := '0';                     -- Machine configuration (memory map, I/O etc) set in the CPLD. When this flag is set, it is running in MZ80K mode.
    signal MODE_CPLD_MZ80C       :     std_logic := '0';                     -- Machine configuration (memory map, I/O etc) set in the CPLD. When this flag is set, it is running in MZ80C mode.
    signal MODE_CPLD_MZ1200      :     std_logic := '0';                     -- Machine configuration (memory map, I/O etc) set in the CPLD. When this flag is set, it is running in MZ1200 mode.
    signal MODE_CPLD_MZ2000      :     std_logic := '0';                     -- Machine configuration (memory map, I/O etc) set in the CPLD. When this flag is set, it is running in MZ2000 mode.
    signal MODE_320x200          :     std_logic := '0';                     -- Video resolution set to 640x200 pixels.
    signal MODE_640x200          :     std_logic := '0';                     -- Video resolution set to 640x200 pixels.
    signal MODE_640x400          :     std_logic := '0';                     -- Video resolution set to 640x400 pixels.
    signal DSP_PARAM_SEL         :     std_logic_vector(3 downto 0);         -- Display parameter selection register.
    signal DSP_PARAM_DATA        :     unsigned(7 downto 0);                 -- Video parameter update data.
    signal DSP_PARAM_UPD         :     std_logic;                            -- Flag to indicate parameter update data is available.
    signal DSP_PARAM_ADDR        :     std_logic;                            -- Video parameter address to update.
    signal DSP_PARAM_CLR         :     std_logic;                            -- Flag to indicate parameter update data processed and can be cleared.
    signal PALETTE_PARAM_SEL     :     std_logic_vector(8 downto 0);         -- Palette parameter selection register.
    signal PALETTE_DO_R          :     std_logic_vector(4 downto 0);         -- Read Red palette output.
    signal PALETTE_DO_G          :     std_logic_vector(4 downto 0);         -- Read Green palette output.
    signal PALETTE_DO_B          :     std_logic_vector(4 downto 0);         -- Read Blue palette output.
    signal PALETTE_WEN_R         :     std_logic;                            -- Write enable for Red palette map.
    signal PALETTE_WEN_G         :     std_logic;                            -- Write enable for Green palette map.
    signal PALETTE_WEN_B         :     std_logic;                            -- Write enable for Blue palette map.
    signal FB_PALETTE_R          :     std_logic_vector(4 downto 0);         -- Current palette map value for given video state input.
    signal FB_PALETTE_G          :     std_logic_vector(4 downto 0);         -- Current palette map value for given video state input.
    signal FB_PALETTE_B          :     std_logic_vector(4 downto 0);         -- Current palette map value for given video state input.

    signal VIDEO_ADDRi           :     std_logic_vector(23 downto 0);        -- CPU Address bus. Upper byte is for direct addressing (ie /= 0) and used by external systems or a soft CPU.
    signal VIDEO_DATA_INi        :     std_logic_vector(31 downto 0);        -- Data bus into video module.
    signal VIDEO_DATA_OUTi       :     std_logic_vector(31 downto 0);        -- Data bus out from video module to CPU.
    signal VIDEO_IORQni          :     std_logic;                            -- IORQ signal, active low. When high, request is to memory.
    signal VIDEO_RDni            :     std_logic;                            -- Video RDn from the CPLD, decoded via memory manager.
    signal VIDEO_WRni            :     std_logic;                            -- Video WRn from the CPLD, decoded via memory manager.
    signal VIDEO_WR_BYTEi        :     std_logic;                            -- Signal to indicate a byte should be written not a 32bit word.
    signal VIDEO_WR_HWORDi       :     std_logic;                            -- Signal to indicate a 16bit half word should be written not a 32bit word.

    --
    -- CPU/Video Access
    --
    signal VRAM_VIDEO_DATA       :     std_logic_vector(31 downto 0);        -- Display data output to CPU.
    signal VRAM_WEN              :     std_logic;                            -- VRAM Write enable signal.
    signal VRAM_WEN_BYTE         :     std_logic;                            -- VRAM Write byte enable signal.
    signal VRAM_WEN_HWORD        :     std_logic;                            -- VRAM Write 16bit half word enable signal.
    signal VRAM_GPU_WEN          :     std_logic;                            -- VRAM Write enable signal from the GPU.
    signal VRAM_GPU_ADDR         :     std_logic_vector(12 downto 0);        -- VRAM RAM Address from the GPU.
    signal VRAM_ADDR             :     std_logic_vector(11 downto 0);        -- VRAM RAM Address.
    signal VRAM_GPU_ENABLE       :     std_logic;                            -- Enable GPU VRAM access.
    signal VRAM_DI               :     std_logic_vector(31 downto 0);        -- VRAM Data input.
    signal VRAM_GPU_DI           :     std_logic_vector(7 downto 0);         -- VRAM Data input from the GPU.
    signal GRAM_ADDR             :     std_logic_vector(14 downto 0);        -- Graphics RAM Address.
    signal GRAM_GPU_ADDR         :     std_logic_vector(14 downto 0);        -- Graphics RAM Address.
    signal GRAM_DI_R             :     std_logic_vector(31 downto 0);        -- Graphics Red RAM Data.
    signal GRAM_DI_G             :     std_logic_vector(31 downto 0);        -- Graphics Green RAM Data.
    signal GRAM_DI_B             :     std_logic_vector(31 downto 0);        -- Graphics Blue RAM Data.
    signal GRAM_GPU_DI_R         :     std_logic_vector(7 downto 0);         -- Graphics Red RAM Data generated by GPU.
    signal GRAM_GPU_DI_G         :     std_logic_vector(7 downto 0);         -- Graphics Green RAM Data generated by GPU.
    signal GRAM_GPU_DI_B         :     std_logic_vector(7 downto 0);         -- Graphics Blue RAM Data generated by GPU.
    signal GRAM_DO_R             :     std_logic_vector(31 downto 0);        -- Graphics Red RAM Data out.
    signal GRAM_DO_G             :     std_logic_vector(31 downto 0);        -- Graphics Green RAM Data out.
    signal GRAM_DO_B             :     std_logic_vector(31 downto 0);        -- Graphics Blue RAM Data out.
    signal GRAM_DO_GI            :     std_logic_vector(31 downto 0);        -- Graphics Option GRAM I Data out for MZ80B.
    signal GRAM_DO_GII           :     std_logic_vector(31 downto 0);        -- Graphics Option GRAM II Data out for MZ80B.
    signal GRAM_DO_GIII          :     std_logic_vector(31 downto 0);        -- Graphics Option GRAM III Data out RGB mode.
    signal GRAM_WEN_GI           :     std_logic;                            -- Graphics Option GRAM I Write enable signal for MZ80B.
    signal GRAM_WEN_GII          :     std_logic;                            -- Graphics Option GRAM II Write enable signal for MZ80B.
    signal GRAM_WEN_GIII         :     std_logic;                            -- Graphics Option GRAM III Write enable signal RGB mode.
    signal GRAM_WEN_BYTE         :     std_logic;                            -- Graphics GRAM Write byte enable signal.
    signal GRAM_WEN_HWORD        :     std_logic;                            -- Graphics GRAM Write 16bit half word enable signal.
    signal GRAM_GPU_ENABLE       :     std_logic;                            -- Enable GPU GRAM access.
    signal GWEN_R                :     std_logic;                            -- Write enable to Red GRAM.
    signal GWEN_G                :     std_logic;                            -- Write enable to Green GRAM.
    signal GWEN_B                :     std_logic;                            -- Write enable to Blue GRAM.
    signal GWEN_GPU_R            :     std_logic;                            -- Write enable to Red GRAM by GPU.
    signal GWEN_GPU_G            :     std_logic;                            -- Write enable to Green GRAM by GPU.
    signal GWEN_GPU_B            :     std_logic;                            -- Write enable to Blue GRAM by GPU.
    signal GWEN_GI               :     std_logic;                            -- Write enable to for GRAMI option on MZ80B/2000.
    signal GWEN_GII              :     std_logic;                            -- Write enable to for GRAMII option on MZ80B/2000.
    signal GRAM_MODE_REG         :     std_logic_vector(7 downto 0);         -- Programmable mode register to control GRAM operations.
    signal GRAM_R_FILTER         :     std_logic_vector(7 downto 0);         -- Red pixel writer filter.
    signal GRAM_G_FILTER         :     std_logic_vector(7 downto 0);         -- Green pixel writer filter.
    signal GRAM_B_FILTER         :     std_logic_vector(7 downto 0);         -- Blue pixel writer filter.
    signal GRAM_OPT_WRITE        :     std_logic;                            -- Graphics write to GRAMI (0) or GRAMII (1) for MZ80B/MZ2000
    signal GRAM_OPT_OUT1         :     std_logic;                            -- Graphics enable GRAMI output to display
    signal GRAM_OPT_OUT2         :     std_logic;                            -- Graphics enable GRAMII output to display
    signal GRAM_PAGE_ENABLE      :     std_logic;                            -- Graphics mode page enable.
    signal VIDEO_MODE_REG        :     std_logic_vector(7 downto 0);         -- Programmable mode register to control video mode.
    signal PAGE_MODE_REG         :     std_logic_vector(7 downto 0);         -- Current value of the Page register.
    signal BORDER_REG            :     std_logic_vector(7 downto 0);         -- VGA Border attribute register to apply to the VGA unused border area.
    signal PALETTE_REG           :     std_logic_vector(7 downto 0);         -- Palette register to apply mapping to the digital RGB output.
    signal GPU_PARAMS            :     std_logic_vector(127 downto 0);       -- GPU parameter register.
    signal GPU_COMMAND           :     std_logic_vector(7 downto 0);         -- GPU command register.
    signal GPU_STATUS            :     std_logic_vector(7 downto 0);         -- GPU Status register.
    signal GPU_STATE             :     GPUStateType;                         -- GPU FSM State.
    signal GPU_START_ADDR        :     std_logic_vector(14 downto 0);        -- Address being worked on by the GPU.
    signal VIDEO_LAST_RDni       :     std_logic_vector(3 downto 0);         -- Edge detect on the external read signal.
    signal VIDEO_LAST_WRni       :     std_logic_vector(3 downto 0);         -- Edge detect on the external write signal.
    signal Z80_MA                :     std_logic_vector(11 downto 0);        -- CPU Address Masked according to machine model.
    signal CS_INVERTn            :     std_logic;                            -- Chip Select to enable Inverse mode.
    signal CS_SCROLLn            :     std_logic;                            -- Chip Select to perform a hardware scroll.
    signal CS_GRAM_OPTn          :     std_logic;                            -- Chip Select to write the graphics options for MZ80B/MZ2000.
    signal CS_FB_BORDERn         :     std_logic;                            -- Chip Select for setting the VGA border attributes.
    signal CS_FB_PALETTEn        :     std_logic;                            -- Chip Select for setting the active pallette.
    signal CS_FB_PARAMSn         :     std_logic;                            -- Chip Select for storing GPU parameters in a FILO stack.
    signal CS_FB_GPUn            :     std_logic;                            -- Chip Select for GPU command register.
    signal CS_FB_VMn             :     std_logic;                            -- Chip Select for the Video Mode register.
    signal CS_FB_PAGEn           :     std_logic;                            -- Chip Select for the Page select register.
    signal CS_FB_CTLn            :     std_logic;                            -- Chip Select to write to the Graphics mode register.
    signal CS_FB_REDn            :     std_logic;                            -- Chip Select to write to the Red pixel per byte indirect write register.
    signal CS_FB_GREENn          :     std_logic;                            -- Chip Select to write to the Green pixel per byte indirect write register.
    signal CS_FB_BLUEn           :     std_logic;                            -- Chip Select to write to the Blue pixel per byte indirect write register.
    signal CS_PCGn               :     std_logic;                            -- Chip select for the programmable character generator.
    signal CS_DXXXn              :     std_logic;                            -- Chip select range for the VRAM/ARAM.
    signal CS_EXXXn              :     std_logic;                            -- Chip select range for the memory mapped I/O.
    signal CS_GRAMn              :     std_logic;                            -- Chip select for the MZ80B Graphics Mode register.
    signal CS_FBRAMn             :     std_logic;                            -- Chip select for the Graphics Framebuffer RAM.
    signal VGAMODE               :     std_logic_vector(1 downto 0) := "00"; -- Current VGA mode - selectable VGA frequency output for the external display.
    signal CS_IO_DXXn            :     std_logic;                            -- Chip select for block D0:DF
    signal CS_IO_EXXn            :     std_logic;                            -- Chip select for block E0:EF
    signal CS_IO_FXXn            :     std_logic;                            -- Chip select for block F0:FF
    signal CS_VIDEO_LEGACYn      :     std_logic;                            -- Legacy video (Z80 access through 64K address space and paging registers).
    signal CS_VIDEO_IO_DIRECTn   :     std_logic;                            -- Direct access to the memory mapped and I/O registers.
    signal CS_VIDEO_VRAM_DIRECTn :     std_logic;                            -- Direct access to the video ram.
    signal CS_VIDEO_CG_DIRECTn   :     std_logic;                            -- Direct access to the character generator rom/ram.
    signal CS_VIDEO_R_FB_DIRECTn :     std_logic;                            -- Direct access to the red framebuffer ram.
    signal CS_VIDEO_B_FB_DIRECTn :     std_logic;                            -- Direct access to the blue framebuffer ram.
    signal CS_VIDEO_G_FB_DIRECTn :     std_logic;                            -- Direct access to the green framebuffer ram.
    --
    -- MZ80B Signals.
    --
    signal DISPLAY_VGATE         :     std_logic;                            -- Video Gate signal, blocks video signal when high.
    signal MZ80B_IPL             :     std_logic;                            -- MZ80B Initial Program Load taking place.
    signal MZ80B_BOOT            :     std_logic;                            -- MZ80B Boot process taking place, memory in default setting of $0000.
    signal MZ80B_VRAM_HI_ADDR    :     std_logic;                            -- Video RAM located at D000:FFFF when high.
    signal MZ80B_VRAM_LO_ADDR    :     std_logic;                            -- Video RAM located at 5000:7FFF when high.
    signal GRAM_MZ80B_ENABLE     :     std_logic;                            -- MZ80B Graphics memory enabled flag.
    signal MZ80B_VMODE_REG       :     std_logic_vector(7 downto 0);         -- MZ80B Input/Output mode to combine the VRAM/GRAM.
    signal CS_80B_PPIn           :     std_logic;                            -- Chip select for MZ80B PPI when in MZ80B mode.
    signal CS_80B_PITn           :     std_logic;                            -- Chip select for MZ80B PIT when in MZ80B mode.
    signal CS_80B_PIOn           :     std_logic;                            -- Chip select for MZ80B PIO when in MZ80B mode.
    signal CS_80B_VMODEn         :     std_logic;                            -- Chip select for MZ80B to set the video mode for VRAM/GRAM I/II.
    --
    -- Display Signals
    --
    signal H_COUNT               :     unsigned(10 downto 0);                -- Horizontal pixel counter
    signal H_BLANKi              :     std_logic;                            -- Horizontal Blanking
    signal H_SYNCni              :     std_logic;                            -- Horizontal Blanking
    signal H_DSP_START           :     unsigned(15 downto 0); 
    signal H_DSP_END             :     unsigned(15 downto 0); 
    signal H_DSP_WND_START       :     unsigned(15 downto 0);                -- Window within the horizontal display when data is output.
    signal H_DSP_WND_END         :     unsigned(15 downto 0); 
    signal H_SYNC_START          :     unsigned(15 downto 0); 
    signal H_SYNC_END            :     unsigned(15 downto 0); 
    signal H_LINE_END            :     unsigned(15 downto 0); 
    signal H_POLARITY            :     unsigned( 0 downto 0);                -- Horizontal polarity.
    signal V_POLARITY            :     unsigned( 0 downto 0);                -- Vertical polarity.
    signal V_COUNT               :     unsigned(10 downto 0);                -- Vertical pixel counter
    signal V_BLANKi              :     std_logic;                            -- Vertical Blanking
    signal V_SYNCni              :     std_logic;                            -- Horizontal Blanking
    signal V_DSP_START           :     unsigned(15 downto 0);
    signal V_DSP_END             :     unsigned(15 downto 0);
    signal V_DSP_WND_START       :     unsigned(15 downto 0);                -- Window within the vertical display when data is output.
    signal V_DSP_WND_END         :     unsigned(15 downto 0); 
    signal V_SYNC_START          :     unsigned(15 downto 0); 
    signal V_SYNC_END            :     unsigned(15 downto 0); 
    signal V_LINE_END            :     unsigned(15 downto 0); 
    --
    -- CG-ROM
    --
    signal CGROM_BIT_DO          :     std_logic_vector(7 downto 0);
    signal CGROM_DO              :     std_logic_vector(31 downto 0);
    signal CGROM_PAGE            :     std_logic;
    signal CGROM_WEN             :     std_logic;
    signal CGROM_WEN_BYTE        :     std_logic;                            -- CGROM Write byte enable signal.
    signal CGROM_WEN_HWORD       :     std_logic;                            -- CGROM Write 16bit half word enable signal.
    --
    -- PCG
    --
    signal CGRAM_DO              :     std_logic_vector(31 downto 0);
    signal CGRAM_BIT_DO          :     std_logic_vector(7 downto 0);
    signal CG_ADDR               :     std_logic_vector(11 downto 0);
    signal CGRAM_ADDR            :     std_logic_vector(11 downto 0);
    signal PCG_DATA              :     std_logic_vector(7 downto 0);
    signal CGRAM_DI              :     std_logic_vector(31 downto 0);
    signal CGRAM_WEn             :     std_logic;
    signal CGRAM_WREN            :     std_logic;
    signal CGRAM_WEN_BYTE        :     std_logic;                            -- CGRAM Write byte enable signal.
    signal CGRAM_WEN_HWORD       :     std_logic;                            -- CGRAM Write 16bit half word enable signal.
    signal CGRAM_SEL             :     std_logic;
    --
    -- Clocks
    --
    signal VID_CLK               :     std_logic;

    function to_std_logic(L: boolean) return std_logic is
    begin
        if L then
            return('1');
        else
            return('0');
        end if;
    end function to_std_logic;

    component dpram
        generic (
              init_file          : string;
              widthad_a          : natural;
              width_a            : natural;
              widthad_b          : natural;
              width_b            : natural;
              outdata_reg_a      : string := "UNREGISTERED";
              outdata_reg_b      : string := "UNREGISTERED"
        );
        Port (
              clock_a            : in  std_logic  := '1';
              clocken_a          : in  std_logic  := '1';
              address_a          : in  std_logic_vector (widthad_a-1 downto 0);
              data_a             : in  std_logic_vector (width_a-1 downto 0);
              wren_a             : in  std_logic  := '0';
              q_a                : out std_logic_vector (width_a-1 downto 0);

              clock_b            : in  std_logic;
              clocken_b          : in  std_logic  := '1';
              address_b          : in  std_logic_vector (widthad_b-1 downto 0);
              data_b             : in  std_logic_vector (width_b-1 downto 0);
              wren_b             : in  std_logic  := '0';
              q_b                : out std_logic_vector (width_b-1 downto 0)
          );
    end component;
begin

    ------------------------------------------------------------------------------------
    -- PLL Video clock and Video frequency generation.
    ------------------------------------------------------------------------------------    

    -- Instantiate a PLL to generate the system clock and base video clocks.
    --
    VCPLL1 : entity work.Video_Clock
    port map
    (
         inclk0                  => CLOCK_50,
         areset                  => '0',
         c0                      => SYS_CLK,
         c1                      => VIDCLK_8MHZ,
         c2                      => VIDCLK_16MHZ,
         c3                      => VIDCLK_40MHZ,
         locked                  => PLL_LOCKED1
    );

    -- Instantiate a 2nd PLL to generate additional video clocks for VGA and Sharp MZ700 modes.
    VCPLL2 : entity work.Video_Clock_II
    port map
    (
         inclk0                  => CLOCK_50,
         areset                  => '0',
         c0                      => VIDCLK_65MHZ,
         c1                      => VIDCLK_25_175MHZ,
         locked                  => PLL_LOCKED2
    );

    -- Instantiate a 3rd PLL to generate clock for pseudo monochrome generation on internal monitor.
    VCPLL3 : entity work.Video_Clock_III
    port map
    (
         inclk0                  => CLOCK_50,
         areset                  => '0',
         c0                      => VIDCLK_8_86719MHZ,
         c1                      => VIDCLK_17_7344MHZ,
         locked                  => PLL_LOCKED3
    );    

    --
    -- Instantiation
    --
    PALETTE_R: dpram
    GENERIC MAP (
        init_file            => "../../../../software/mif/PALETTE_R.mif",
        widthad_a            => 9,
        width_a              => 5,
        widthad_b            => 9,
        width_b              => 5,
        outdata_reg_a        => "CLOCK0",
        outdata_reg_b        => "CLOCK1"
    )
    PORT MAP (
        -- Port A used for CPU access.
        clock_a              => SYS_CLK,
        clocken_a            => '1',
        address_a            => PALETTE_PARAM_SEL,
        data_a               => VIDEO_DATA_INi(4 downto 0),   
        wren_a               => PALETTE_WEN_R,       
        q_a                  => PALETTE_DO_R,
    
        -- Port B used for Palette output map.
        clock_b              => VID_CLK,
        clocken_b            => '1',
        address_b            => PALETTE_REG & SR_R_DATA(7),
        data_b               => (others => '0'),
        wren_b               => '0',
        q_b                  => FB_PALETTE_R
    );
    PALETTE_G: dpram
    GENERIC MAP (
        init_file            => "../../../../software/mif/PALETTE_G.mif",
        widthad_a            => 9,
        width_a              => 5,
        widthad_b            => 9,
        width_b              => 5,
        outdata_reg_a        => "CLOCK0",
        outdata_reg_b        => "CLOCK1"
    )
    PORT MAP (
        -- Port A used for CPU access.
        clock_a              => SYS_CLK,
        clocken_a            => '1',
        address_a            => PALETTE_PARAM_SEL,
        data_a               => VIDEO_DATA_INi(4 downto 0),   
        wren_a               => PALETTE_WEN_G,       
        q_a                  => PALETTE_DO_G,
    
        -- Port B used for Palette output map.
        clock_b              => VID_CLK,
        clocken_b            => '1',
        address_b            => PALETTE_REG & SR_G_DATA(7),
        data_b               => (others => '0'),
        wren_b               => '0',
        q_b                  => FB_PALETTE_G
    );
    PALETTE_B: dpram
    GENERIC MAP (
        init_file            => "../../../../software/mif/PALETTE_B.mif",
        widthad_a            => 9,
        width_a              => 5,
        widthad_b            => 9,
        width_b              => 5,
        outdata_reg_a        => "CLOCK0",
        outdata_reg_b        => "CLOCK1"
    )
    PORT MAP (
        -- Port A used for CPU access.
        clock_a              => SYS_CLK,
        clocken_a            => '1',
        address_a            => PALETTE_PARAM_SEL,
        data_a               => VIDEO_DATA_INi(4 downto 0),   
        wren_a               => PALETTE_WEN_B,
        q_a                  => PALETTE_DO_B,
    
        -- Port B used for Palette output map.
        clock_b              => VID_CLK,
        clocken_b            => '1',
        address_b            => PALETTE_REG & SR_B_DATA(7),
        data_b               => (others => '0'),
        wren_b               => '0',
        q_b                  => FB_PALETTE_B
    );

    -- Video memory as seen by the MZ Series. This is a 1K or 2K or 2K + 2K Attribute RAM
    -- organised as 4K x 8 on the CPU side and 2K x 16 on the display side, top bits are not used for MZ80K/C/1200/A.
    --
    VRAM0 : work.VideoRAM_DP_3216
    GENERIC MAP (
        addrbits             => 12                                                  -- Max address bit of total size in bytes. ie. 12 = 4096 bytes.
    )
    PORT MAP (
        clkA                 => SYS_CLK,
        memAAddr             => VRAM_ADDR(10 downto 0) & VRAM_ADDR(11),
        memAWriteEnable      => VRAM_WEN,
        memAWriteByte        => VRAM_WEN_BYTE,
        memAWriteHalfWord    => VRAM_WEN_HWORD,
        memAWrite            => VRAM_DI,
        memARead             => VRAM_VIDEO_DATA,

        clkB                 => VID_CLK,
        memBAddr             => XFER_VRAM_ADDR,
        memBWriteEnable      => '0',
        memBWrite            => (others => '0'),
        memBRead             => XFER_VRAM_DATA
    );

    -- MZ80B Graphics RAM Option I and Red Framebuffer. The top 8K is used as GRAM I during MZ80B mode, the full 16K is used as Red frame/pixel
    -- buffer for other modes.
    --
    GRAMI : work.VideoRAM_DP_3208
    GENERIC MAP (
        addrbits             => 15                                                  -- Max address bit of total size in bytes. ie. 12 = 4096 bytes.
    )
    PORT MAP (
        clkA                 => SYS_CLK,
        memAAddr             => GRAM_ADDR(14 downto 0),
        memAWriteEnable      => GRAM_WEN_GI,
        memAWriteByte        => GRAM_WEN_BYTE,
        memAWriteHalfWord    => GRAM_WEN_HWORD,
        memAWrite            => GRAM_DI_R,
        memARead             => GRAM_DO_GI,

        clkB                 => VID_CLK,
        memBAddr             => XFER_SRC_ADDR(14 downto 0),                         -- FB Destination address is used as GRAM is on a 1:1 mapping with FB.
        memBWriteEnable      => XFER_R_WEN,
        memBWrite            => XFER_MAPPED_DATA(7 downto 0),
        memBRead             => DISPLAY_DATA(7 downto 0)
    );

    -- MZ80B Graphics RAM Option II and Blue Framebuffer. The top 8K is used as GRAM II during MZ80B mode, the full 16K is used as Blue frame/pixel
    -- buffer for other modes.
    --
    GRAMII : work.VideoRAM_DP_3208
    GENERIC MAP (
        addrbits             => 15                                                  -- Max address bit of total size in bytes. ie. 12 = 4096 bytes.
    )
    PORT MAP (
        clkA                 => SYS_CLK,
        memAAddr             => GRAM_ADDR(14 downto 0),
        memAWriteEnable      => GRAM_WEN_GII,
        memAWriteByte        => GRAM_WEN_BYTE,
        memAWriteHalfWord    => GRAM_WEN_HWORD,
        memAWrite            => GRAM_DI_B,
        memARead             => GRAM_DO_GII,

        clkB                 => VID_CLK,
        memBAddr             => XFER_SRC_ADDR(14 downto 0),                         -- FB Destination address is used as GRAM is on a 1:1 mapping with FB.
        memBWriteEnable      => XFER_B_WEN,
        memBWrite            => XFER_MAPPED_DATA(15 downto 8),
        memBRead             => DISPLAY_DATA(15 downto 8)
    );
    
    -- MZ80B Graphics RAM Option III and Green Framebuffer.
    -- This memory is not present on the MZ80B but is instantiated as the Green Framebuffer which is used as the main framebuffer during MZ80B mode, ie. GRAM I + II + VRAM -> GRAM III for display.
    -- In non-MZ80B modes, this memory acts as the Green framebuffer where direct pixel drawing can be made as well as rasterizing the Video RAM characters according to the Attribute RAM definitions. 
    --
    GRAMIII : work.VideoRAM_DP_3208
    GENERIC MAP (
        addrbits             => 15                                                  -- Max address bit of total size in bytes. ie. 12 = 4096 bytes.
    )
    PORT MAP (
        clkA                 => SYS_CLK,
        memAAddr             => GRAM_ADDR(14 downto 0),
        memAWriteEnable      => GRAM_WEN_GIII,
        memAWriteByte        => GRAM_WEN_BYTE,
        memAWriteHalfWord    => GRAM_WEN_HWORD,
        memAWrite            => GRAM_DI_G,
        memARead             => GRAM_DO_GIII,

        clkB                 => VID_CLK,
        memBAddr             => XFER_SRC_ADDR(14 downto 0),                         -- FB Destination address is used as GRAM is on a 1:1 mapping with FB.
        memBWriteEnable      => XFER_G_WEN,
        memBWrite            => XFER_MAPPED_DATA(23 downto 16),
        memBRead             => DISPLAY_DATA(23 downto 16)
    );

    -- CGROM - 4K allocated. Default ROM is for the MZ-80A.
    -- For other machines, the ROM needs to be uploaded by enabling the CGROM_PAGE, writing the ROM to D000:DFFF and then clearing the bit.
    --
    CGROM0 : work.ChrGenRAM_DP_3208
    GENERIC MAP (
        addrbits             => 12                                                  -- Max address bit of total size in bytes. ie. 12 = 4096 bytes.
    )
    PORT MAP (
        clkA                 => SYS_CLK,
        memAAddr             => VIDEO_ADDRi(11 downto 0),
        memAWriteEnable      => CGROM_WEN,
        memAWriteByte        => CGROM_WEN_BYTE,
        memAWriteHalfWord    => CGROM_WEN_HWORD,
        memAWrite            => VIDEO_DATA_INi,
        memARead             => CGROM_DO,

        clkB                 => VID_CLK,
        memBAddr             => CG_ADDR(11 downto 0),
        memBWriteEnable      => '0',
        memBWrite            => (others => '0'),
        memBRead             => CGROM_BIT_DO
    );
    
    -- Programmable Character Generator RAM. This is instantiated for compatibility with original hardware upgrades and software that makes use of it.
    -- If writing new software, it is easier to just write to the CGROM as per above.
    --
    CGRAM0 : work.ChrGenRAM_DP_3208
    GENERIC MAP (
        addrbits             => 12                                                  -- Max address bit of total size in bytes. ie. 12 = 4096 bytes.
    )
    PORT MAP (
        clkA                 => SYS_CLK,
        memAAddr             => CG_ADDR(11 downto 0),
        memAWriteEnable      => CGRAM_WREN,
        memAWriteByte        => CGRAM_WEN_BYTE,
        memAWriteHalfWord    => CGRAM_WEN_HWORD,
        memAWrite            => CGRAM_DI,
        memARead             => CGRAM_DO,

        clkB                 => VID_CLK,
        memBAddr             => CG_ADDR(11 downto 0),
        memBWriteEnable      => '0',
        memBWrite            => (others => '0'),
        memBRead             => CGRAM_BIT_DO
    );

    -- Process to bring all the interface signals into this clock domain with all timing within this component using the video system clock.
    process(SYS_CLK, VRESETn, VIDEO_ADDR, VIDEO_DATA_IN, VIDEO_DATA_OUTi, VIDEO_IORQn, VIDEO_RDn, VIDEO_WRn, VIDEO_WR_BYTE, VIDEO_WR_HWORDi)
    begin
        if rising_edge(SYS_CLK) then
            if VRESETn = '0' then
                VIDEO_ADDRi                  <= (others => '0');
                VIDEO_DATA_INi               <= (others => '0');
                VIDEO_DATA_OUT               <= (others => '0');
                VIDEO_WR_BYTEi               <= '0';
                VIDEO_WR_HWORDi              <= '0';
                VIDEO_IORQni                 <= '1';
                VIDEO_RDni                   <= '1';
                VIDEO_WRni                   <= '1';
                VIDEO_LAST_RDni              <= (others => '1');
                VIDEO_LAST_WRni              <= (others => '1');
            else
                VIDEO_ADDRi                  <= VIDEO_ADDR;
                VIDEO_IORQni                 <= VIDEO_IORQn;
                VIDEO_LAST_RDni              <= VIDEO_LAST_RDni(2 downto 0) & VIDEO_RDn;
                VIDEO_LAST_WRni              <= VIDEO_LAST_WRni(2 downto 0) & VIDEO_WRn;

                if VIDEO_LAST_RDni = "0000" and VIDEO_RDni = '1' then
                    VIDEO_DATA_OUT           <= VIDEO_DATA_OUTi;
                end if;

                -- Detect an edge on the RD/WR lines and create a video RD/WR which is one system clock pulse wide.
                VIDEO_WRni                   <= '1';
                VIDEO_RDni                   <= '1';
                if VIDEO_LAST_RDni = "1110" and VIDEO_RDn = '0' then
                    VIDEO_RDni               <= '0';
                end if;
                if VIDEO_LAST_WRni = "1110" and VIDEO_WRn = '0' then
                    VIDEO_WRni               <= '0';
                end if;
                if VIDEO_LAST_WRni = "1110" and VIDEO_WRn = '0' then
                    VIDEO_DATA_INi           <= VIDEO_DATA_IN;
                    VIDEO_WR_BYTEi           <= VIDEO_WR_BYTE;
                    VIDEO_WR_HWORDi          <= VIDEO_WR_HWORDi;
                end if;
            end if;
        end if;
    end process;

    -- D type Flip Flops used for the Video frequency switching circuit. The changeover of frequencies occurs on the high level to prevent glitches and lockups.
    FFCLK1: process( VIDCLK_8MHZ, VRESETn ) begin
        -- If the system clock goes active high, process the inputs and set the D-type output.
        if( rising_edge(VIDCLK_8MHZ) ) then
            if VRESETn = '0' then
                VIDCLK_8MHZ_Q                <= '0';
            else
                if (VIDEOMODE = 0 and (VIDCLK_8_86719MHZ_Q = '1' and VIDCLK_16MHZ_Q = '1' and VIDCLK_17_7344MHZ_Q = '1' and VIDCLK_25_175MHZ_Q = '1' and VIDCLK_40MHZ_Q = '1' and VIDCLK_65MHZ_Q = '1')) then
                    VIDCLK_8MHZ_Q            <= '0';
                else
                    VIDCLK_8MHZ_Q            <= '1';
                end if;
            end if;
        end if;
    end process;
    FFCLK2: process( VIDCLK_8_86719MHZ, VRESETn ) begin
        -- If the control clock goes active high, process the inputs and set the D-type output.
        if( rising_edge(VIDCLK_8_86719MHZ) ) then
            if VRESETn = '0' then
                VIDCLK_8_86719MHZ_Q          <= '1';
            else
                if (VIDEOMODE = 2 and VIDCLK_8MHZ_Q = '1' and VIDCLK_16MHZ_Q = '1' and (VIDCLK_17_7344MHZ_Q = '1' and VIDCLK_25_175MHZ_Q = '1' and VIDCLK_40MHZ_Q = '1' and VIDCLK_65MHZ_Q = '1')) then
                    VIDCLK_8_86719MHZ_Q      <= '0';
                else
                    VIDCLK_8_86719MHZ_Q      <= '1';
                end if;
            end if;
        end if;
    end process;
    FFCLK3: process( VIDCLK_16MHZ, VRESETn ) begin
        -- If the control clock goes active high, process the inputs and set the D-type output.
        if( rising_edge(VIDCLK_16MHZ) ) then
            if VRESETn = '0' then
                VIDCLK_16MHZ_Q               <= '1';
            else
                if (VIDEOMODE = 1 and VIDCLK_8MHZ_Q = '1' and VIDCLK_8_86719MHZ_Q = '1' and (VIDCLK_17_7344MHZ_Q = '1' and VIDCLK_25_175MHZ_Q = '1' and VIDCLK_40MHZ_Q = '1' and VIDCLK_65MHZ_Q = '1')) then
                    VIDCLK_16MHZ_Q           <= '0';
                else
                    VIDCLK_16MHZ_Q           <= '1';
                end if;
            end if;
        end if;
    end process;
    FFCLK4: process( VIDCLK_17_7344MHZ, VRESETn ) begin
        -- If the control clock goes active high, process the inputs and set the D-type output.
        if( rising_edge(VIDCLK_17_7344MHZ) ) then
            if VRESETn = '0' then
                VIDCLK_17_7344MHZ_Q          <= '1';
            else
                if (VIDEOMODE = 3 and VIDCLK_8MHZ_Q = '1' and VIDCLK_8_86719MHZ_Q = '1' and (VIDCLK_16MHZ_Q = '1' and VIDCLK_25_175MHZ_Q = '1' and VIDCLK_40MHZ_Q = '1' and VIDCLK_65MHZ_Q = '1')) then
                    VIDCLK_17_7344MHZ_Q      <= '0';
                else
                    VIDCLK_17_7344MHZ_Q      <= '1';
                end if;
            end if;
        end if;
    end process;
    FFCLK5: process( VIDCLK_25_175MHZ, VRESETn ) begin
        -- If the control clock goes active high, process the inputs and set the D-type output.
        if( rising_edge(VIDCLK_25_175MHZ) ) then
            if VRESETn = '0' then
                VIDCLK_25_175MHZ_Q           <= '1';
            else
                if ((VIDEOMODE = 4 or VIDEOMODE = 5 or VIDEOMODE = 6 or VIDEOMODE = 7) and (VIDCLK_8MHZ_Q = '1' and VIDCLK_8_86719MHZ_Q = '1' and VIDCLK_16MHZ_Q = '1' and VIDCLK_17_7344MHZ_Q = '1' and VIDCLK_40MHZ_Q = '1' and VIDCLK_65MHZ_Q = '1')) then
                    VIDCLK_25_175MHZ_Q       <= '0';
                else
                    VIDCLK_25_175MHZ_Q       <= '1';
                end if;
            end if;
        end if;
    end process;
    FFCLK6: process( VIDCLK_40MHZ, VRESETn ) begin
        -- If the control clock goes active high, process the inputs and set the D-type output.
        if( rising_edge(VIDCLK_40MHZ) ) then
            if VRESETn = '0' then
                VIDCLK_40MHZ_Q               <= '1';
            else
                if ((VIDEOMODE = 12 or VIDEOMODE = 13 or VIDEOMODE = 14 or VIDEOMODE = 15) and (VIDCLK_8MHZ_Q = '1' and VIDCLK_8_86719MHZ_Q = '1' and VIDCLK_16MHZ_Q = '1' and VIDCLK_17_7344MHZ_Q = '1' and VIDCLK_25_175MHZ_Q = '1' and VIDCLK_65MHZ_Q = '1')) then
                    VIDCLK_40MHZ_Q           <= '0';
                else
                    VIDCLK_40MHZ_Q           <= '1';
                end if;
            end if;
        end if;
    end process;
    FFCLK7: process( VIDCLK_65MHZ, VRESETn ) begin
        -- If the control clock goes active high, process the inputs and set the D-type output.
        if( rising_edge(VIDCLK_65MHZ) ) then
            if VRESETn = '0' then
                VIDCLK_65MHZ_Q               <= '1';
            else
                if ((VIDEOMODE = 8 or VIDEOMODE = 9 or VIDEOMODE = 10 or VIDEOMODE = 11) and (VIDCLK_8MHZ_Q = '1' and VIDCLK_8_86719MHZ_Q = '1' and VIDCLK_16MHZ_Q = '1' and VIDCLK_17_7344MHZ_Q = '1' and VIDCLK_25_175MHZ_Q = '1' and VIDCLK_40MHZ_Q = '1')) then
                    VIDCLK_65MHZ_Q           <= '0';
                else
                    VIDCLK_65MHZ_Q           <= '1';
                end if;
            end if;
        end if;
    end process;
    
    -- Clock at maximum system speed to minimise transfer time.
    -- Rasterisation and blending into the display framebuffer is made during the Vertical Blanking period.
    --
    RENDERFRAMES: process( VRESETn, VID_CLK, XFER_DST_ADDR, FB_ADDR, VIDEOMODE_RESET_TIMER )
        variable XFER_CYCLE     : integer range 0 to 10;
        variable XFER_ENABLED   : std_logic;                            -- Enable transfer of VRAM/GRAM to framebuffer.
        variable XFER_PAUSE     : std_logic;                            -- Pause transfer of VRAM/GRAM to framebuffer during data display period.
        variable XFER_SRC_COL   : integer range 0 to 80;
        variable XFER_DST_SUBROW: integer range 0 to 7;
    begin

        -- Copy at end of Display based on the highest clock to minimise time,
        --
        if rising_edge(VID_CLK) then

            if VRESETn='0' then
                XFER_VRAM_ADDR      <= (others => '0');
                XFER_DST_ADDR       <= (others => '0');
                XFER_CGROM_ADDR     <= (others => '0');
                XFER_ENABLED        := '0';
                XFER_PAUSE          := '0';
                XFER_SRC_COL        := 0;
                XFER_DST_SUBROW     := 0;
                XFER_CYCLE          := 0;
                XFER_R_WEN          <= '0';
                XFER_G_WEN          <= '0';
                XFER_B_WEN          <= '0';
                XFER_MAPPED_DATA    <= (others => '0');
    
            else
                -- A video mode change is similar to a RESET, the process halts and all the control variables are reset.
                --
                if VIDEOMODE_RESET_TIMER /= 0 then

                    XFER_VRAM_ADDR      <= (others => '0');
                    XFER_DST_ADDR       <= (others => '0');
                    XFER_CGROM_ADDR     <= (others => '0');
                    XFER_ENABLED        := '0';
                    XFER_PAUSE          := '0';
                    XFER_SRC_COL        := 0;
                    XFER_DST_SUBROW     := 0;
                    XFER_CYCLE          := 0;
                    XFER_R_WEN          <= '0';
                    XFER_G_WEN          <= '0';
                    XFER_B_WEN          <= '0';
                    XFER_MAPPED_DATA    <= (others => '0');

                else

                    -- Every time we reach the end of the visible display area we enable copying of the VRAM and GRAM into the
                    -- display framebuffer, ready for the next frame display. This starts to occur a fixed set of rows after 
                    -- they have been displayed, initially only during the hblank period of a row, but during the full row
                    -- in the vblank period.
                    --
                    if V_COUNT = 0 then
                        XFER_ENABLED    := '1';
                    end if;
            
                    -- During the actual data display, we pause rendering until the start of a horizontal or vertical blanking period.
                    --
                    if XFER_ENABLED = '1' and 
                      -- Horizontal blanking period, allow upto line end - 3 to allow 3 extra cycles if the FSM is actively writing to the Frame buffer.
                      ((H_COUNT > H_DSP_WND_END and H_COUNT < H_LINE_END-8 and FB_ADDR > XFER_DST_ADDR+std_logic_vector(MAX_COLUMN)) or 
                       -- Vertical blanking period, allow full use of this period for copying.
                       (V_COUNT > V_DSP_WND_END and V_COUNT < V_LINE_END) or
                       -- Active write to Framebuffer taking place, override other conditions in this state.
                       (XFER_R_WEN = '1' or XFER_G_WEN = '1' or XFER_B_WEN = '1')
                      )
                    then   
                        XFER_PAUSE      := '0';
                    else
                        XFER_PAUSE      := '1';
                    end if;
            
                    -- If we are in the active transfer window, start transfer.
                    --
                    if XFER_PAUSE = '0' then
            
                        -- Once we reach the end of the framebuffer, disable the copying until next frame.
                        --
                        if XFER_DST_ADDR >= 16383 then
                            XFER_ENABLED         := '0';
                        end if;
            
                        -- Finite state machine to implement read, map and write.
                        case (XFER_CYCLE) is
            
                            when 0 =>
                                XFER_MAPPED_DATA <= (others => '0');
                                XFER_CYCLE       := 1;
            
                            -- Get the source character and map via the PCG to a slice of the displayed character.
                            -- Recalculate the destination address based on this loops values.
                            when 1 =>
                                -- Setup the PCG address based on the read character.
                                XFER_CGROM_ADDR  <= XFER_VRAM_DATA(15) & XFER_VRAM_DATA(7 downto 0) & std_logic_vector(to_unsigned(XFER_DST_SUBROW, 3));
                                XFER_CYCLE       := 2;
            
                            --   Graphics mode:- 7/6 = Operator (00=OR,01=AND,10=NAND,11=XOR),
                            --                     5 = GRAM Output Enable  0 = active.
                            --                     4 = VRAM Output Enable, 0 = active.
                            --                   3/2 = Write mode (00=Page 1:Red, 01=Page 2:Green, 10=Page 3:Blue, 11=Indirect),
                            --                   1/0 = Read mode  (00=Page 1:Red, 01=Page2:Green, 10=Page 3:Blue, 11=Not used).
                            --
                            -- Extra cycle for CGROM to latch, use time to decide which mode we are processing.
                            when 2 =>
                                -- Check to see if VRAM is disabled, if it is, skip.
                                --
                                if    GRAM_MODE_REG(4) = '0' and (MODE_VIDEO_MONO = '1' or MODE_VIDEO_MONO80 = '1') then
                                    -- Monochrome modes?
                                    XFER_CYCLE := 4;
            
                                elsif GRAM_MODE_REG(4) = '0' and (MODE_VIDEO_COLOUR = '1' or MODE_VIDEO_COLOUR80 = '1') then
                                    -- Colour modes?
                                    XFER_CYCLE := 3;
            
                                else
                                    -- Disabled or unrecognised mode.
                                    XFER_CYCLE := 5;
                                end if;
            
                            -- Colour modes?
                            -- Expand and store the slice of the character with colour expansion.
                            --
                            when 3 =>
                                if CGROM_DATA(7) = '0' then
                                    XFER_MAPPED_DATA(7)      <= XFER_VRAM_DATA(9);              -- Red
                                    XFER_MAPPED_DATA(15)     <= XFER_VRAM_DATA(8);              -- Blue
                                    XFER_MAPPED_DATA(23)     <= XFER_VRAM_DATA(10);             -- Green
                                else
                                    XFER_MAPPED_DATA(7)      <= XFER_VRAM_DATA(13);
                                    XFER_MAPPED_DATA(15)     <= XFER_VRAM_DATA(12);
                                    XFER_MAPPED_DATA(23)     <= XFER_VRAM_DATA(14);
                                end if;
                                if CGROM_DATA(6) = '0' then
                                    XFER_MAPPED_DATA(6)      <= XFER_VRAM_DATA(9);
                                    XFER_MAPPED_DATA(14)     <= XFER_VRAM_DATA(8);
                                    XFER_MAPPED_DATA(22)     <= XFER_VRAM_DATA(10);
                                else
                                    XFER_MAPPED_DATA(6)      <= XFER_VRAM_DATA(13);
                                    XFER_MAPPED_DATA(14)     <= XFER_VRAM_DATA(12);
                                    XFER_MAPPED_DATA(22)     <= XFER_VRAM_DATA(14);
                                end if;
                                if CGROM_DATA(5) = '0' then
                                    XFER_MAPPED_DATA(5)      <= XFER_VRAM_DATA(9);
                                    XFER_MAPPED_DATA(13)     <= XFER_VRAM_DATA(8);
                                    XFER_MAPPED_DATA(21)     <= XFER_VRAM_DATA(10);
                                else
                                    XFER_MAPPED_DATA(5)      <= XFER_VRAM_DATA(13);
                                    XFER_MAPPED_DATA(13)     <= XFER_VRAM_DATA(12);
                                    XFER_MAPPED_DATA(21)     <= XFER_VRAM_DATA(14);
                                end if;
                                if CGROM_DATA(4) = '0' then
                                    XFER_MAPPED_DATA(4)      <= XFER_VRAM_DATA(9);
                                    XFER_MAPPED_DATA(12)     <= XFER_VRAM_DATA(8);
                                    XFER_MAPPED_DATA(20)     <= XFER_VRAM_DATA(10);
                                else
                                    XFER_MAPPED_DATA(4)      <= XFER_VRAM_DATA(13);
                                    XFER_MAPPED_DATA(12)     <= XFER_VRAM_DATA(12);
                                    XFER_MAPPED_DATA(20)     <= XFER_VRAM_DATA(14);
                                end if;
                                if CGROM_DATA(3) = '0' then
                                    XFER_MAPPED_DATA(3)      <= XFER_VRAM_DATA(9);
                                    XFER_MAPPED_DATA(11)     <= XFER_VRAM_DATA(8);
                                    XFER_MAPPED_DATA(19)     <= XFER_VRAM_DATA(10);
                                else
                                    XFER_MAPPED_DATA(3)      <= XFER_VRAM_DATA(13);
                                    XFER_MAPPED_DATA(11)     <= XFER_VRAM_DATA(12);
                                    XFER_MAPPED_DATA(19)     <= XFER_VRAM_DATA(14);
                                end if;
                                if CGROM_DATA(2) = '0' then
                                    XFER_MAPPED_DATA(2)      <= XFER_VRAM_DATA(9);
                                    XFER_MAPPED_DATA(10)     <= XFER_VRAM_DATA(8);
                                    XFER_MAPPED_DATA(18)     <= XFER_VRAM_DATA(10);
                                else
                                    XFER_MAPPED_DATA(2)      <= XFER_VRAM_DATA(13);
                                    XFER_MAPPED_DATA(10)     <= XFER_VRAM_DATA(12);
                                    XFER_MAPPED_DATA(18)     <= XFER_VRAM_DATA(14);
                                end if;
                                if CGROM_DATA(1) = '0' then
                                    XFER_MAPPED_DATA(1)      <= XFER_VRAM_DATA(9);
                                    XFER_MAPPED_DATA(9)      <= XFER_VRAM_DATA(8);
                                    XFER_MAPPED_DATA(17)     <= XFER_VRAM_DATA(10);
                                else
                                    XFER_MAPPED_DATA(1)      <= XFER_VRAM_DATA(13);
                                    XFER_MAPPED_DATA(9)      <= XFER_VRAM_DATA(12);
                                    XFER_MAPPED_DATA(17)     <= XFER_VRAM_DATA(14);
                                end if;
                                if CGROM_DATA(0) = '0' then
                                    XFER_MAPPED_DATA(0)      <= XFER_VRAM_DATA(9);
                                    XFER_MAPPED_DATA(8)      <= XFER_VRAM_DATA(8);
                                    XFER_MAPPED_DATA(16)     <= XFER_VRAM_DATA(10);
                                else
                                    XFER_MAPPED_DATA(0)      <= XFER_VRAM_DATA(13);
                                    XFER_MAPPED_DATA(8)      <= XFER_VRAM_DATA(12);
                                    XFER_MAPPED_DATA(16)     <= XFER_VRAM_DATA(14);
                                end if;
                                XFER_CYCLE := 6;
            
                            -- Monochrome modes?
                            -- Expand and store the slice of the character in monochrome according to machine mode. MZ80K/C = white, MZ80A/1200 = Green.
                            --
                            when 4 =>
                                if CGROM_DATA(7) = '1' then
                                    XFER_MAPPED_DATA(23)     <= '1';
                                    if MODE_VIDEO_MZ80K = '1' or MODE_VIDEO_MZ80K = '1' then
                                        XFER_MAPPED_DATA(7)  <= '1';
                                        XFER_MAPPED_DATA(15) <= '1';
                                    end if;
                                end if;
                                if CGROM_DATA(6) = '1' then
                                    XFER_MAPPED_DATA(22)      <= '1';
                                    if MODE_VIDEO_MZ80K = '1' or MODE_VIDEO_MZ80C = '1' then
                                        XFER_MAPPED_DATA(6)  <= '1';
                                        XFER_MAPPED_DATA(14) <= '1';
                                    end if;
                                end if;
                                if CGROM_DATA(5) = '1' then
                                    XFER_MAPPED_DATA(21)     <= '1';
                                    if MODE_VIDEO_MZ80K = '1' or MODE_VIDEO_MZ80C = '1' then
                                        XFER_MAPPED_DATA(5)  <= '1';
                                        XFER_MAPPED_DATA(13) <= '1';
                                    end if;
                                end if;
                                if CGROM_DATA(4) = '1' then
                                    XFER_MAPPED_DATA(20)     <= '1';
                                    if MODE_VIDEO_MZ80K = '1' or MODE_VIDEO_MZ80C = '1' then
                                        XFER_MAPPED_DATA(4)  <= '1';
                                        XFER_MAPPED_DATA(12) <= '1';
                                    end if;
                                end if;
                                if CGROM_DATA(3) = '1' then
                                    XFER_MAPPED_DATA(19)     <= '1';
                                    if MODE_VIDEO_MZ80K = '1' or MODE_VIDEO_MZ80C = '1' then
                                        XFER_MAPPED_DATA(3)  <= '1';
                                        XFER_MAPPED_DATA(11) <= '1';
                                    end if;
                                end if;
                                if CGROM_DATA(2) = '1' then
                                    XFER_MAPPED_DATA(18)     <= '1';
                                    if MODE_VIDEO_MZ80K = '1' or MODE_VIDEO_MZ80C = '1' then
                                        XFER_MAPPED_DATA(2)  <= '1';
                                        XFER_MAPPED_DATA(10) <= '1';
                                    end if;
                                end if;
                                if CGROM_DATA(1) = '1' then
                                    XFER_MAPPED_DATA(17)     <= '1';
                                    if MODE_VIDEO_MZ80K = '1' or MODE_VIDEO_MZ80C = '1' then
                                        XFER_MAPPED_DATA(1)  <= '1';
                                        XFER_MAPPED_DATA(9)  <= '1';
                                    end if;
                                end if;
                                if CGROM_DATA(0) = '1' then
                                    XFER_MAPPED_DATA(16)     <= '1';
                                    if MODE_VIDEO_MZ80K = '1' or MODE_VIDEO_MZ80C = '1' then
                                        XFER_MAPPED_DATA(0)  <= '1';
                                        XFER_MAPPED_DATA(8)  <= '1';
                                    end if;
                                end if;
                                XFER_CYCLE := 5;
            
                            when 5 =>
                                -- If invert option selected, invert green.
                                --
                                if (MODE_VIDEO_MZ80A = '1' or MODE_VIDEO_MZ80B = '1')and DISPLAY_INVERT = '1' then
                                    XFER_MAPPED_DATA(23 downto 16) <= not XFER_MAPPED_DATA(23 downto 16);
                                end if;
                                XFER_CYCLE := 6;
            
                            when 6 =>
                                -- Graphics ram enabled?
                                --
                                if GRAM_MODE_REG(5) = '0' then
                                    -- Merge in the graphics data using defined mode.
                                    --
                                    case GRAM_MODE_REG(7 downto 6) is
                                        when "00" =>
                                            --XFER_MAPPED_DATA <= XFER_MAPPED_DATA or   reverse_vector(DISPLAY_DATA(23 downto 16)) & reverse_vector(DISPLAY_DATA(15 downto 8)) & reverse_vector(DISPLAY_DATA(7 downto 0));
                                            XFER_MAPPED_DATA <= XFER_MAPPED_DATA or   DISPLAY_DATA(23 downto 16) & DISPLAY_DATA(15 downto 8) & DISPLAY_DATA(7 downto 0);
                                        when "01" =>
                                            --XFER_MAPPED_DATA <= XFER_MAPPED_DATA and  reverse_vector(DISPLAY_DATA(23 downto 16)) & reverse_vector(DISPLAY_DATA(15 downto 8)) & reverse_vector(DISPLAY_DATA(7 downto 0));
                                            XFER_MAPPED_DATA <= XFER_MAPPED_DATA and  DISPLAY_DATA(23 downto 16) & DISPLAY_DATA(15 downto 8) & DISPLAY_DATA(7 downto 0);
                                        when "10" =>
                                            --XFER_MAPPED_DATA <= XFER_MAPPED_DATA nand reverse_vector(DISPLAY_DATA(23 downto 16)) & reverse_vector(DISPLAY_DATA(15 downto 8)) & reverse_vector(DISPLAY_DATA(7 downto 0));
                                            XFER_MAPPED_DATA <= XFER_MAPPED_DATA nand DISPLAY_DATA(23 downto 16) & DISPLAY_DATA(15 downto 8) & DISPLAY_DATA(7 downto 0);
                                        when "11" =>
                                            --XFER_MAPPED_DATA <= XFER_MAPPED_DATA xor  reverse_vector(DISPLAY_DATA(23 downto 16)) & reverse_vector(DISPLAY_DATA(15 downto 8)) & reverse_vector(DISPLAY_DATA(7 downto 0));
                                            XFER_MAPPED_DATA <= XFER_MAPPED_DATA xor  DISPLAY_DATA(23 downto 16) & DISPLAY_DATA(15 downto 8) & DISPLAY_DATA(7 downto 0);
                                    end case;
                                end if;
                                XFER_CYCLE := 7;
            
                            when 7 =>
                                -- For MZ80B, if enabled, blend in the graphics memory.
                                --
                                if MODE_VIDEO_MZ80B = '1' and XFER_DST_ADDR < 8192 then
                                    if GRAM_OPT_OUT1 = '1' and GRAM_OPT_OUT2 = '1' then
                                        XFER_MAPPED_DATA(23 downto 16) <= XFER_MAPPED_DATA(23 downto 16) or reverse_vector(DISPLAY_DATA(7 downto 0)) or reverse_vector(DISPLAY_DATA(15 downto 8));
                                    elsif GRAM_OPT_OUT1 = '1' then
                                        XFER_MAPPED_DATA(23 downto 16) <= XFER_MAPPED_DATA(23 downto 16) or reverse_vector(DISPLAY_DATA(7 downto 0));
                                    elsif GRAM_OPT_OUT2 = '1' then
                                        XFER_MAPPED_DATA(23 downto 16) <= XFER_MAPPED_DATA(23 downto 16) or reverse_vector(DISPLAY_DATA(15 downto 8));
                                    end if;
                                end if;
                                XFER_CYCLE := 8;
            
                            -- Commence write of mapped data.
                            when 8 =>
                                XFER_R_WEN   <= '1';
                                XFER_G_WEN   <= '1';
                                XFER_B_WEN   <= '1';
                                XFER_CYCLE   := 9;
            
                            -- Complete write and update address.
                            when 9 =>
                                -- Write cycle to framebuffer finished.
                                XFER_R_WEN   <= '0';
                                XFER_G_WEN   <= '0';
                                XFER_B_WEN   <= '0';
                                XFER_CYCLE   := 10;
            
                            when 10 =>
                                -- For each source character, we generate 8 lines in the frame buffer. Thus we need to 
                                -- process the same source row 8 times, each time incrementing the sub-row which is used
                                -- to extract the next pixel set from the CG. This data is thus written into the destination as:-
                                -- <Row:0,CGLine:0,0 .. MAX_COLUMN -1> <Row:0,CGLine:1,0.. MAX_COLUMN -1> .. <Row:0,CGLine:7,0.. MAX_COLUMN -1>
                                -- ..
                                -- <Row:24,CGLine:0,0 .. MAX_COLUMN -1><Row:24,CGLine:1,0.. MAX_COLUMN -1> .. <Row:24,CGLine:7,0.. MAX_COLUMN -1>
                                --
                                -- To achieve this, we keep a note of the column and sub-row, incrementing the source address until end of line
                                -- then winding it back if we are still rendering the Characters for a given row. 
                                -- Destination address always increments every clock cycle to take the next pixel set.
                                --
                                if XFER_SRC_COL < MAX_COLUMN - 1 then
                                    XFER_SRC_COL        := XFER_SRC_COL + 1;
                                    XFER_VRAM_ADDR      <= XFER_VRAM_ADDR + 1;
                                else
                                    if XFER_DST_SUBROW < MAX_SUBROW -1 then
                                        XFER_SRC_COL    := 0;
                                        XFER_DST_SUBROW := XFER_DST_SUBROW + 1;
                                        XFER_VRAM_ADDR  <= XFER_VRAM_ADDR - std_logic_vector((MAX_COLUMN - 1));
                                    else
                                        XFER_SRC_COL    := 0;
                                        XFER_VRAM_ADDR  <= XFER_VRAM_ADDR + 1;
                                        XFER_DST_SUBROW := 0;
                                    end if;
                                end if;
            
                                -- Destination address increments every tick.
                                --
                                XFER_DST_ADDR <= XFER_DST_ADDR + 1;
                                XFER_CYCLE := 0;
                            end case;
                        end if;
            
                        -- On a new cycle, reset the transfer parameters.
                        --
                        if V_COUNT = V_LINE_END and H_COUNT = H_LINE_END - 1 then
            
                            -- Start of display, setup the start of VRAM for display according to machine. 
                            if MODE_VIDEO_MZ80A = '1' or MODE_VIDEO_MZ700 = '1' then
                                XFER_VRAM_ADDR <= (OFFSET_ADDR & "000");
                            else
                                XFER_VRAM_ADDR <= (others => '0');
                            end if;
                            XFER_DST_ADDR    <= (others => '0');
                            XFER_CGROM_ADDR  <= (others => '0');
                            XFER_SRC_COL     := 0;
                            XFER_DST_SUBROW  := 0;
                            XFER_CYCLE       := 0;
                            XFER_ENABLED     := '0';
                            XFER_R_WEN       <= '0';
                            XFER_G_WEN       <= '0';
                            XFER_B_WEN       <= '0';
                            XFER_MAPPED_DATA <= (others => '0');
                        end if;
                end if;
            end if; -- if VRESET
        end if; -- rising_edge(VID_CLK)

        -- Setup the Framebuffer address according to the current state. If we are in a blanking period, copying data from VRAM/GRAM to the 
        -- framebuffer then we use the XFER_DST_ADDR, all other times we use the Framebuffer address FB_ADDR which is used to extract data
        -- for display.
        --
        if XFER_PAUSE = '0' then
            XFER_SRC_ADDR                <= XFER_DST_ADDR;
        else
            XFER_SRC_ADDR                <= FB_ADDR;
        end if;
    end process;

    -- Process to generate the video data signals.
    -- The data is read out of the framebuffer, 8 pixels at a time and clocked out according to the timing clock. The H/V Sync and Blank signals are
    -- activated according to the mode selected and the values contained therein.
    --
    GENVIDEO: process( VRESETn, VID_CLK, VIDEOMODE_RESET_TIMER )
    begin

        -- Use the video clock for rendering to get the correct display frequencies.
        if rising_edge(VID_CLK) then

            -- On reset, set the basic parameters which hold the video signal generator in reset
            -- then load up the required parameter set and generate the video signal.
            --
            if VRESETn = '0' then
                    H_DSP_START                      <= (others => '0');
                    H_DSP_END                        <= (others => '0');
                    H_DSP_WND_START                  <= (others => '0');
                    H_DSP_WND_END                    <= (others => '0');
                    V_DSP_START                      <= (others => '0');
                    V_DSP_END                        <= (others => '0');
                    V_DSP_WND_START                  <= (others => '0');
                    V_DSP_WND_END                    <= (others => '0');
                    MAX_COLUMN                       <= (others => '0');
                    H_LINE_END                       <= (others => '0');
                    V_LINE_END                       <= (others => '0');
                    H_SYNC_START                     <= (others => '0');
                    H_SYNC_END                       <= (others => '0');
                    V_SYNC_START                     <= (others => '0');
                    V_SYNC_END                       <= (others => '0');
                    H_POLARITY                       <= (others => '0');
                    V_POLARITY                       <= (others => '0');
                    H_PX                             <= (others => '0');
                    V_PX                             <= (others => '0');
                    H_COUNT                          <= (others => '0');
                    V_COUNT                          <= (others => '0');
                    H_BLANKi                         <= '1';
                    V_BLANKi                         <= '1';
                    H_SYNCni                         <= '1';
                    V_SYNCni                         <= '1';
                    H_PX_CNT                         <= 0;
                    V_PX_CNT                         <= 0;
                    H_SHIFT_CNT                      <= 0;
                    FB_ADDR                          <= (others => '0');
                    VIDEOMODE_SWITCH                 <= '0';
                    VIDEOMODE                        <= 0;
                    VIDEOMODE_RESET_TIMER            <= (others => '1');
                    VIDCLK_DIV                       <= '0';
                    DSP_PARAM_CLR                    <= '0';

            else

                -- The video clock is running at twice the display frequency to provide additional edges for rendering the display during the blanking periods.
                -- We therefore divide the clock by two and only act on the second edge in 2 edges.
                VIDCLK_DIV                           <= not VIDCLK_DIV;

                -- If the video mode changes, we wait until the current frame has been displayed then commence switching to the new video mode.
                if VIDEOMODE /= VIDEOMODE_NEXT then
                    VIDEOMODE_SWITCH                 <= '1';
                end if;

                -- If the video mode changes, reset the variables to the initial state. This occurs
                -- at the end of a frame to minimise the monitor syncing incorrectly. Max columns is used as a parameter
                -- to cater for reset conditions in order to initialise the variables.
                --
                if (VIDEOMODE_SWITCH = '1' and V_COUNT = to_unsigned(FB_PARAMS(VIDEOMODE, 9), 16)) or MAX_COLUMN = 0
                then
                    VIDEOMODE                        <= VIDEOMODE_NEXT;
                    VIDEOMODE_SWITCH                 <= '0';

                    -- Iniitialise control registers.
                    --
                    FB_ADDR                          <= (others => '0');
    
                    -- Load up configuration from the look up table based on video mode.
                    --
                    H_DSP_START                      <= to_unsigned(FB_PARAMS(VIDEOMODE_NEXT, 0), 16);      -- IO 0
                    H_DSP_END                        <= to_unsigned(FB_PARAMS(VIDEOMODE_NEXT, 1), 16);      -- IO 2
                    H_DSP_WND_START                  <= to_unsigned(FB_PARAMS(VIDEOMODE_NEXT, 2), 16);      -- IO 4
                    H_DSP_WND_END                    <= to_unsigned(FB_PARAMS(VIDEOMODE_NEXT, 3), 16);      -- IO 6
                    V_DSP_START                      <= to_unsigned(FB_PARAMS(VIDEOMODE_NEXT, 4), 16);      -- IO 8
                    V_DSP_END                        <= to_unsigned(FB_PARAMS(VIDEOMODE_NEXT, 5), 16);      -- IO 10
                    V_DSP_WND_START                  <= to_unsigned(FB_PARAMS(VIDEOMODE_NEXT, 6), 16);      -- IO 12
                    V_DSP_WND_END                    <= to_unsigned(FB_PARAMS(VIDEOMODE_NEXT, 7), 16);      -- IO 14
                    H_LINE_END                       <= to_unsigned(FB_PARAMS(VIDEOMODE_NEXT, 8), 16);      -- IO 16
                    V_LINE_END                       <= to_unsigned(FB_PARAMS(VIDEOMODE_NEXT, 9), 16);      -- IO 18
                    MAX_COLUMN                       <= to_unsigned(FB_PARAMS(VIDEOMODE_NEXT, 10), 8);      -- IO 20
                    H_SYNC_START                     <= to_unsigned(FB_PARAMS(VIDEOMODE_NEXT, 11), 16);     -- IO 22
                    H_SYNC_END                       <= to_unsigned(FB_PARAMS(VIDEOMODE_NEXT, 12), 16);     -- IO 24
                    V_SYNC_START                     <= to_unsigned(FB_PARAMS(VIDEOMODE_NEXT, 13), 16);     -- IO 26
                    V_SYNC_END                       <= to_unsigned(FB_PARAMS(VIDEOMODE_NEXT, 14), 16);     -- IO 28
                    H_POLARITY                       <= to_unsigned(FB_PARAMS(VIDEOMODE_NEXT, 15), 1);      --
                    V_POLARITY                       <= to_unsigned(FB_PARAMS(VIDEOMODE_NEXT, 16), 1);      --
                    H_PX                             <= to_unsigned(FB_PARAMS(VIDEOMODE_NEXT, 17), 8);      -- IO 30
                    V_PX                             <= to_unsigned(FB_PARAMS(VIDEOMODE_NEXT, 18), 8);      -- IO 31
                    --
                    H_COUNT                          <= (others => '0');
                    V_COUNT                          <= (others => '0');
                    H_BLANKi                         <= '1';
                    V_BLANKi                         <= '1';
                    H_SYNCni                         <= not std_logic_vector(to_unsigned(FB_PARAMS(VIDEOMODE_NEXT, 15), 1))(0);
                    V_SYNCni                         <= not std_logic_vector(to_unsigned(FB_PARAMS(VIDEOMODE_NEXT, 16), 1))(0);
                    H_PX_CNT                         <= 0;
                    V_PX_CNT                         <= 0;
                    H_SHIFT_CNT                      <= 0;
                    --
                    -- On display start or change we need to give a small period between one set of frequencies/display settings and the next.
                    -- This is necessary as I've noticed on one of my displays that changing modes too quickly results in lock up - probably a bug
                    -- of my monitor but this ensures other monitors arent affected either.
                    VIDEOMODE_RESET_TIMER            <= (others => '1');
                    --
                    VIDCLK_DIV                       <= '0';

                -- During reset periods, just count down, no active display signals will be generated.
                elsif VIDEOMODE_RESET_TIMER /= 0 then
                    VIDEOMODE_RESET_TIMER            <= VIDEOMODE_RESET_TIMER - 1;
                    --
                    VIDCLK_DIV                       <= '0';

                -- Only process the display output on the second of each video clock edges as the video clock is running at 2x frequency.
                --
                elsif VIDCLK_DIV = '1' then

--                    -- Parameter update handshake. Clear the flag when the Z80 domain has cleared its flag.
--                    if DSP_PARAM_CLR = '1' and DSP_PARAM_UPD = '0' then
--                        DSP_PARAM_CLR                <= '0';
--                    end if;
--
--                    -- Ability to adjust the video parameter registers to tune or override the default values from the lookup table. This can be useful in debugging,
--                    -- adjusting to a new monitor etc.
--                    --
--                    -- The actual data is captured in the Z80 clock domain and passed/synchronised to this multi-clock domain via internal hand shaked registers.
--                    --
--                    if DSP_PARAM_UPD = '1' and DSP_PARAM_CLR = '0' then
--
--                        if DSP_PARAM_ADDR = '0' then
--                                case DSP_PARAM_SEL is
--                                    when "0000" =>
--                                        H_DSP_START(7 downto 0)       <= DSP_PARAM_DATA;
--                                    when "0001" =>
--                                        H_DSP_END(7 downto 0)         <= DSP_PARAM_DATA;
--                                    when "0010" =>
--                                        H_DSP_WND_START(7 downto 0)   <= DSP_PARAM_DATA;
--                                    when "0011" =>
--                                        H_DSP_WND_END(7 downto 0)     <= DSP_PARAM_DATA;
--                                    when "0100" =>
--                                        V_DSP_START(7 downto 0)       <= DSP_PARAM_DATA;
--                                    when "0101" =>
--                                        V_DSP_END(7 downto 0)         <= DSP_PARAM_DATA;
--                                    when "0110" =>
--                                        V_DSP_WND_START(7 downto 0)   <= DSP_PARAM_DATA;
--                                    when "0111" =>
--                                        V_DSP_WND_END(7 downto 0)     <= DSP_PARAM_DATA;
--                                    when "1000" =>
--                                        H_LINE_END(7 downto 0)        <= DSP_PARAM_DATA;
--                                    when "1001" =>
--                                        V_LINE_END(7 downto 0)        <= DSP_PARAM_DATA;
--                                    when "1010" =>
--                                        MAX_COLUMN(7 downto 0)        <= DSP_PARAM_DATA;
--                                    when "1011" =>
--                                        H_SYNC_START(7 downto 0)      <= DSP_PARAM_DATA;
--                                    when "1100" =>
--                                        H_SYNC_END(7 downto 0)        <= DSP_PARAM_DATA;
--                                    when "1101" =>
--                                        V_SYNC_START(7 downto 0)      <= DSP_PARAM_DATA;
--                                    when "1110" =>
--                                        V_SYNC_END(7 downto 0)        <= DSP_PARAM_DATA;
--                                    when "1111" =>
--                                        H_PX(7 downto 0)              <= DSP_PARAM_DATA;
--                                end case;
--                        else
--
--                                case DSP_PARAM_SEL is
--                                    when "0000" =>
--                                        H_DSP_START(15 downto 8)      <= DSP_PARAM_DATA;
--                                    when "0001" =>
--                                        H_DSP_END(15 downto 8)        <= DSP_PARAM_DATA;
--                                    when "0010" =>
--                                        H_DSP_WND_START(15 downto 8)  <= DSP_PARAM_DATA;
--                                    when "0011" =>
--                                        H_DSP_WND_END(15 downto 8)    <= DSP_PARAM_DATA;
--                                    when "0100" =>
--                                        V_DSP_START(15 downto 8)      <= DSP_PARAM_DATA;
--                                    when "0101" =>
--                                        V_DSP_END(15 downto 8)        <= DSP_PARAM_DATA;
--                                    when "0110" =>
--                                        V_DSP_WND_START(15 downto 8)  <= DSP_PARAM_DATA;
--                                    when "0111" =>
--                                        V_DSP_WND_END(15 downto 8)    <= DSP_PARAM_DATA;
--                                    when "1000" =>
--                                        H_LINE_END(15 downto 8)       <= DSP_PARAM_DATA;
--                                    when "1001" =>
--                                        V_LINE_END(15 downto 8)       <= DSP_PARAM_DATA;
--                                    when "1010" =>
--                                    when "1011" =>
--                                        H_SYNC_START(15 downto 8)     <= DSP_PARAM_DATA;
--                                    when "1100" =>
--                                        H_SYNC_END(15 downto 8)       <= DSP_PARAM_DATA;
--                                    when "1101" =>
--                                        V_SYNC_START(15 downto 8)     <= DSP_PARAM_DATA;
--                                    when "1110" =>
--                                        V_SYNC_END(15 downto 8)       <= DSP_PARAM_DATA;
--                                    when "1111" =>
--                                        V_PX(7 downto 0)              <= DSP_PARAM_DATA;
--                                end case;
--
--                        end if;
--
--                        -- Flag the data has been registered.
--                        DSP_PARAM_CLR                <= '1';
--                    end if;

                    -- Activate/deactivate signals according to pixel position.
                    --
                    if H_COUNT =  H_DSP_START     then H_BLANKi  <= '0'; end if;
                --  if H_COUNT =  H_LINE_END      then H_BLANKi  <= '0'; end if;
                    if H_COUNT =  H_DSP_END       then H_BLANKi  <= '1'; end if;
                    if H_COUNT =  H_SYNC_END      then H_SYNCni  <= '1'; end if;
                    if H_COUNT =  H_SYNC_START    then H_SYNCni  <= '0'; end if;
                    if V_COUNT =  V_DSP_START     then V_BLANKi  <= '0'; end if;
                -- if V_COUNT =  V_LINE_END      then V_BLANKi  <= '0'; end if;
                    if V_COUNT =  V_DSP_END       then V_BLANKi  <= '1'; end if;
                    if V_COUNT =  V_SYNC_START    then V_SYNCni  <= '0'; end if;
                    if V_COUNT =  V_SYNC_END      then V_SYNCni  <= '1'; end if;
    
                    -- If we are in the active visible area, stream the required output based on the various buffers.
                    --
                    if H_COUNT >= H_DSP_START and H_COUNT < H_DSP_END and V_COUNT >= V_DSP_START and V_COUNT < V_DSP_END then
    
                        if (V_COUNT >= V_DSP_WND_START and V_COUNT <= V_DSP_WND_END) and (H_COUNT >= H_DSP_WND_START and H_COUNT < H_DSP_WND_END) then

                            -- Update Horizontal Pixel multiplier.
                            --
                            if H_PX_CNT = 0 then
    
                                H_PX_CNT             <= to_integer(H_PX);
                                H_SHIFT_CNT          <= H_SHIFT_CNT - 1;
    
                                -- Main screen.
                                --
                                if H_SHIFT_CNT = 0 then
    
                                    -- During the visible portion of the frame, data is stored in the frame buffer in bytes, 1 bit per pixel x 8 and 3 colors,
                                    -- thus 1 x 8 x 3 or 24 bit. Read out the values into shift registers to be serialised.
                                    --
                                    SR_R_DATA        <= DISPLAY_DATA( 7 downto 0);
                                    SR_B_DATA        <= DISPLAY_DATA(15 downto 8);
                                    SR_G_DATA        <= DISPLAY_DATA(23 downto 16);
                                    FB_ADDR          <= FB_ADDR + 1;

                                else
                                    -- During the active display area, if the shift counter is not 0 and the horizontal multiplier is equal to the setting,
                                    -- shift the data in the shift register to display the next pixel.
                                    --
                                    SR_R_DATA        <= SR_R_DATA(6 downto 0) & '0';
                                    SR_B_DATA        <= SR_B_DATA(6 downto 0) & '0';
                                    SR_G_DATA        <= SR_G_DATA(6 downto 0) & '0';
    
                                end if;
                            else
                                H_PX_CNT             <= H_PX_CNT - 1;
                            end if;
                        else
                            -- Blank.
                            --
                            SR_G_DATA                <= (others => BORDER_REG(2));
                            SR_R_DATA                <= (others => BORDER_REG(1));
                            SR_B_DATA                <= (others => BORDER_REG(0));
                            H_PX_CNT                 <= 0;
                            H_SHIFT_CNT              <= 0;
                        end if;
    
                    else
                        H_PX_CNT                     <= 0;
                        H_SHIFT_CNT                  <= 0;
                    end if;
    
                    -- Horizontal/Vertical counters are updated each clock cycle to accurately track pixel/timing.
                    --
                    if H_COUNT = H_LINE_END then
                        H_COUNT                      <= (others => '0');
                        H_PX_CNT                     <= 0;
    
                        -- Update Vertical Pixel multiplier.
                        --
                        if V_PX_CNT = 0 then
                            V_PX_CNT                 <= to_integer(V_PX);
                        else
                            V_PX_CNT                 <= V_PX_CNT - 1;
                        end if;
    
                        -- When we need to repeat a line due to pixel multiplying, wind back the framebuffer address to start of line.
                        --
                        if V_COUNT >= V_DSP_WND_START and V_COUNT < V_DSP_WND_END-V_PX and V_PX /= 0 and V_PX_CNT > 0 then
                            FB_ADDR                  <= FB_ADDR - std_logic_vector(MAX_COLUMN);
                        end if;
    
                        -- Once we have reached the end of the active vertical display, reset the framebuffer address.
                        --
                        if V_COUNT = V_DSP_END then
                            FB_ADDR                  <= (others => '0');
                        end if;
    
                        -- End of vertical line, increment to next or reset to beginning.
                        --
                        if V_COUNT = V_LINE_END then
                            V_COUNT                  <= (others => '0');
                            V_PX_CNT                 <= 0;
                        else
                            V_COUNT                  <= V_COUNT + 1;
                        end if;

                    else
                        H_COUNT                      <= H_COUNT + 1;
                    end if;
                end if;
            end if; -- if VRESETn
        end if; -- rising_edge(VID_CLK)
    end process;

    -- A basic Graphics Processing Unit. The idea is to speed up certain tasks such as clearing the screen or setting a fixed colour. 
    -- The GPU works by several writes to the FB_PARAMS register which stores upto 128bits of parameters, the bit allocation depending upon the command given later.
    -- Once the parameters are stored, a command is written into the GPU control register and the requested task is undertaken.
    --
    -- Command word:-
    --     Bit    [7] - 0 = VRAN, 1 = Pixel Frame Buffer
    --     Bits [6:0] - Command:-
    --                  0x00 = NOP/Idle.
    --
    -- VRAM commands.
    --   0x01 = Clear VRAM screen.
    --   0x02 = Clear VRAM screen with char and attribute:  Parameters: [15:8] - character, [7:0] - attribute byte
    --   0x03 = Parameterised Clear VRAM screen:  Parameters: [47:40] - Start X, [39:32] - Start Y, [31:24] - End X, [23:16] - End Y, [15:8] - display char, [7:0] - attribute byte
    -- Framebuffer commands.
    --   0x81 = Clear framebuffer screen. Clear entire screen using current R/G/B filters.
    --   0x82 = Parameterised Clear framebuffer screen. Parameters: start x [87:72], start y [71:56], end x [55:40], end y [39:24], R Filter [23:16], G Filter [15:8], B Filter [7:0] - R/G/B Filters are 8 pixel wide.
    -- Other commands.
    --   0xFF = Immediate GPU reset, cancel current command and return to idle.
    GPU: process( VRESETn, SYS_CLK )
        variable GPU_START_X      : integer range 0 to 640;               -- X starting location.
        variable GPU_START_Y      : integer range 0 to 400;               -- Y starting location.
        variable GPU_END_X        : integer range 0 to 640;               -- X ending location.
        variable GPU_END_Y        : integer range 0 to 400;               -- Y ending location.
        variable GPU_COLUMNS      : integer range 0 to 132;               -- Number of char per row, setting is dynamic based on video mode.
        variable GPU_ROWS         : integer range 0 to 50;                -- Number of rows, setting is dynamic based on video mode.
        variable GPU_VAR_Y        : integer range 0 to 400;               -- Working Y position
        variable GPU_VBLANK_WAIT  : std_logic;                            -- Flag to indicate if the GPU should wait for the VBLANK signal before writes.
        variable GPU_FILTER_R     : std_logic_vector(7 downto 0);         -- Byte wide filter for 8 pixels, 0 = pixel off, 1 = pixel on.
        variable GPU_FILTER_G     : std_logic_vector(7 downto 0);         -- Byte wide filter for 8 pixels, 0 = pixel off, 1 = pixel on.
        variable GPU_FILTER_B     : std_logic_vector(7 downto 0);         -- Byte wide filter for 8 pixels, 0 = pixel off, 1 = pixel on.
        variable GPU_VRAM_CHAR    : std_logic_vector(7 downto 0);         -- Character byte to write into VRAM.
        variable GPU_VRAM_ATTR    : std_logic_vector(7 downto 0);         -- Attribute byte to write into VRAM.
    begin

        -- System clock is used for the GPU to obtain maximum performance.
        if rising_edge(SYS_CLK) then
           
            -- Ensure default values at reset.
            if VRESETn='0' then
                GPU_STATUS            <= "00000000";
                GRAM_GPU_DI_R         <= (others => '0');
                GRAM_GPU_DI_G         <= (others => '0');
                GRAM_GPU_DI_B         <= (others => '0');
                GWEN_GPU_R            <= '0';
                GWEN_GPU_G            <= '0';
                GWEN_GPU_B            <= '0';
                VRAM_GPU_WEN          <= '0';
                GRAM_GPU_ADDR         <= (others => '0');
                GPU_STATE             <= GPU_State_Idle;

            else

                -- GPU access to GRAM is controlled by state rather than setting a flag in each state which waits for a clock edge to latch.
                --
                if GPU_STATE = GPU_FB_Clear_1 or GPU_STATE = GPU_FB_Clear_2 then
                    GRAM_GPU_ENABLE   <= '1';
                else
                    GRAM_GPU_ENABLE   <= '0';
                end if;

                -- GPU access to VRAM is controlled by state rather than setting a flag in each state which waits for a clock edge to latch.
                --
                if GPU_STATE = GPU_VRAM_Clear_1 or GPU_STATE = GPU_VRAM_Clear_2 then
                    VRAM_GPU_ENABLE   <= '1';
                else
                    VRAM_GPU_ENABLE   <= '0';
                end if;

                -- Debug, view the FSM state via the status register.
                GPU_STATUS(7 downto 1) <= std_logic_vector(to_unsigned(GPUStateType'POS(GPU_STATE), 7));

                -- A reset command whilst the GPU FSM is busy cancels the operation and returns the FSM to idle.
                if GPU_COMMAND = X"FF" then
                    GPU_STATE         <= GPU_State_Idle;
                    GPU_STATUS(0)     <= '0';

                -- If a command has been given and we are not executing a command, start the FSM.
                elsif GPU_COMMAND(6 downto 0) /= "0000000" and GPU_STATE = GPU_State_Idle then
                    -- GPU busy.
                    GPU_STATUS(0)     <= '1';

                    case GPU_COMMAND is
                        -- Clear the VRAM without updating attributes.
                        when X"01" =>
                            GPU_STATE <= GPU_VRAM_Clear;

                        -- Clear the VRAM/ARAM with given attribute byte,
                        when X"02" =>
                            GPU_STATE <= GPU_VRAM_Clear_Attr;

                        -- Clear the VRAM/ARAM with parameters.
                        when X"03" =>
                            GPU_STATE <= GPU_VRAM_Clear_Param;

                        -- Clear the entire Framebuffer.
                        when X"81" =>
                            GPU_STATE <= GPU_FB_Clear;
                        -- Clear the Framebuffer according to parameters.
                        when X"82" =>
                            GPU_STATE <= GPU_FB_Clear_Param;

                        when others =>
                            GPU_STATE <= GPU_State_Idle;
                    end case;

                else

                    -- FSM for the Graphics Processing Unit.
                    --
                    case GPU_STATE is
                        -- Clear the entire display, all pixels off.
                        when GPU_FB_Clear =>
                            GPU_START_X       := 0;
                            GPU_START_Y       := 0;
                            GPU_END_X         := 640;
                            GPU_END_Y         := 400;
                            GPU_FILTER_R      := (others => '0');
                            GPU_FILTER_G      := (others => '0');
                            GPU_FILTER_B      := (others => '0');
                            GPU_STATE         <= GPU_FB_Clear_Start;
    
                        -- Clear a parameterised part of the display, 
                        -- Parameters: [88] = VBLANK Wait, start x [87:72], start y [71:56], end x [55:40], end y [39:24], R Filter [23:16], G Filter [15:8], B Filter [7:0] - R/G/B Filters are 8 pixel wide.
                        when GPU_FB_Clear_Param =>
                            if to_integer(unsigned(GPU_PARAMS(87 downto 72))) >= 640 then
                                GPU_START_X   := 0;
                            else
                                GPU_START_X   := to_integer(unsigned(GPU_PARAMS(87 downto 72)));
                            end if;
                            if to_integer(unsigned(GPU_PARAMS(71 downto 56))) >= 400 then 
                                GPU_START_Y   := 0;
                            else
                                GPU_START_Y   := to_integer(unsigned(GPU_PARAMS(71 downto 56)));
                            end if;
                            if to_integer(unsigned(GPU_PARAMS(55 downto 40))) <= to_integer(unsigned(GPU_PARAMS(87 downto 72))) or to_integer(unsigned(GPU_PARAMS(55 downto 40))) >= 640 then
                                GPU_END_X     := 640;
                            else
                                GPU_END_X     := to_integer(unsigned(GPU_PARAMS(55 downto 40)));
                            end if;
                            if to_integer(unsigned(GPU_PARAMS(39 downto 24))) <= to_integer(unsigned(GPU_PARAMS(71 downto 56))) or to_integer(unsigned(GPU_PARAMS(39 downto 24))) >= 400 then
                                GPU_END_Y     := 400;
                            else
                                GPU_END_Y     := to_integer(unsigned(GPU_PARAMS(39 downto 24)));
                            end if;
                            GPU_VBLANK_WAIT   := GPU_PARAMS(88);
                            GPU_FILTER_R      := GPU_PARAMS(23 downto 16);
                            GPU_FILTER_G      := GPU_PARAMS(15 downto 8);
                            GPU_FILTER_B      := GPU_PARAMS(7 downto 0);
                            GPU_STATE         <= GPU_FB_Clear_Start;
    
                        when GPU_FB_Clear_Start =>
                            GPU_START_ADDR    <= std_logic_vector(to_unsigned(((GPU_START_X / 8) + (GPU_START_Y * 80)), 15));
                            GRAM_GPU_ADDR     <= std_logic_vector(to_unsigned(((GPU_START_X / 8) + (GPU_START_Y * 80)), 15));
                            GRAM_GPU_DI_R     <= GPU_FILTER_R;
                            GRAM_GPU_DI_G     <= GPU_FILTER_G;
                            GRAM_GPU_DI_B     <= GPU_FILTER_B;
                            GPU_VAR_Y         := GPU_START_Y;
                            GPU_STATE         <= GPU_FB_Clear_1;
    
                        -- Wait for the vertical blanking period before writing into the framebuffer.
                        when GPU_FB_Clear_1 =>
                            if V_BLANKi = '1' or GPU_VBLANK_WAIT = '0' then
                                GWEN_GPU_R    <= '1';
                                GWEN_GPU_G    <= '1';
                                GWEN_GPU_B    <= '1';
                                GPU_STATE     <= GPU_FB_Clear_2;
                            end if;
    
                        when GPU_FB_Clear_2 =>
                            GWEN_GPU_R        <= '0';
                            GWEN_GPU_G        <= '0';
                            GWEN_GPU_B        <= '0';
    
                            if to_integer(unsigned(GRAM_GPU_ADDR)) >= to_integer(unsigned(GPU_START_ADDR)) + ((GPU_END_X - GPU_START_X)/8) or GRAM_GPU_ADDR = X"7FFF" then
                                if GPU_VAR_Y >= GPU_END_Y then
                                    GPU_STATE     <= GPU_FB_Clear_3;
                                else
                                    GRAM_GPU_ADDR <= GPU_START_ADDR + 80;
                                    GPU_START_ADDR<= GPU_START_ADDR + 80;
                                    GPU_VAR_Y     := GPU_VAR_Y + 1;
                                    GPU_STATE     <= GPU_FB_Clear_1;
                                end if;
                            else
                                GRAM_GPU_ADDR <= GRAM_GPU_ADDR + 1;
                                GPU_STATE     <= GPU_FB_Clear_1;
                            end if;
    
                        when GPU_FB_Clear_3 =>
                            GPU_STATE         <= GPU_State_Idle;
    
                        -- Clear the entire VRAM display to no characters and a blue background (for the MZ-700/colour modes).
                        when GPU_VRAM_Clear =>
                            GPU_COLUMNS       := 128;
                            GPU_ROWS          := 16;
                            GPU_START_X       := 0;
                            GPU_START_Y       := 0;
                            GPU_END_X         := GPU_COLUMNS - 1;
                            GPU_END_Y         := GPU_ROWS - 1;
                            GPU_VRAM_CHAR     := X"00";
                            GPU_VRAM_ATTR     := X"71";
                            GPU_STATE         <= GPU_VRAM_Clear_Start;
    
                        -- Clear the entire VRAM display to a character and a colour given as a parameter, [15:8] = character, [7:0] = attribute byte.
                        when GPU_VRAM_Clear_Attr =>
                            GPU_COLUMNS       := 128;
                            GPU_ROWS          := 16;
                            GPU_START_X       := 0;
                            GPU_START_Y       := 0;
                            GPU_END_X         := GPU_COLUMNS - 1;
                            GPU_END_Y         := GPU_ROWS - 1;
                            GPU_VRAM_CHAR     := GPU_PARAMS(15 downto 8);
                            GPU_VRAM_ATTR     := GPU_PARAMS(7 downto 0);
                            GPU_STATE         <= GPU_VRAM_Clear_Start;
    
                        -- Clear the VRAM display according to given parameters:
                        -- Parameters: [48] - VBLANK Wait, [47:40] - Start X, [39:32] - Start Y, [31:24] - End X, [23:16] - End Y, [15:8] - display char, [7:0] - attribute byte
                        when GPU_VRAM_Clear_Param =>
                            -- Update the column setting according to the dynamic mode.
                            if MODE_VIDEO_MONO = '1' or MODE_VIDEO_COLOUR = '1' then
                                GPU_COLUMNS   := 40;
                            else
                                GPU_COLUMNS   := 80;
                            end if;
                            GPU_ROWS          := 25;
    
                            -- Read and check the parameters.
                            if to_integer(unsigned(GPU_PARAMS(47 downto 40))) >= GPU_COLUMNS - 1 then
                                GPU_START_X   := GPU_COLUMNS - 1;
                            else
                                GPU_START_X   := to_integer(unsigned(GPU_PARAMS(47 downto 40)));
                            end if;
                            if to_integer(unsigned(GPU_PARAMS(39 downto 32))) >= GPU_ROWS - 1 then 
                                GPU_START_Y   := GPU_ROWS - 1;
                            else
                                GPU_START_Y   := to_integer(unsigned(GPU_PARAMS(39 downto 32)));
                            end if;
                            if to_integer(unsigned(GPU_PARAMS(31 downto 24))) < to_integer(unsigned(GPU_PARAMS(47 downto 40))) or to_integer(unsigned(GPU_PARAMS(31 downto 24))) >= GPU_COLUMNS - 1 then
                                GPU_END_X     := GPU_COLUMNS - 1;
                            else
                                GPU_END_X     := to_integer(unsigned(GPU_PARAMS(31 downto 24)));
                            end if;
                            if to_integer(unsigned(GPU_PARAMS(23 downto 16))) < to_integer(unsigned(GPU_PARAMS(39 downto 32))) or to_integer(unsigned(GPU_PARAMS(23 downto 16))) >= GPU_ROWS - 1 then
                                GPU_END_Y     := GPU_ROWS - 1;
                            else
                                GPU_END_Y     := to_integer(unsigned(GPU_PARAMS(23 downto 16)));
                            end if;
                            GPU_VRAM_CHAR     := GPU_PARAMS(15 downto 8);
                            GPU_VRAM_ATTR     := GPU_PARAMS(7 downto 0);
                            GPU_VBLANK_WAIT   := GPU_PARAMS(48);
                            GPU_STATE         <= GPU_VRAM_Clear_Start;
    
                        when GPU_VRAM_Clear_Start =>
                            -- For modes with hardware scroll, add in the current offset so the visible part of the display is updated.
                            if MODE_VIDEO_MZ80A = '1' or MODE_VIDEO_MZ700 = '1' then
                                GPU_START_ADDR<= std_logic_vector(to_unsigned((GPU_START_X + (GPU_START_Y * GPU_COLUMNS)), 15)) + (OFFSET_ADDR & "000");
                                VRAM_GPU_ADDR <= std_logic_vector(to_unsigned((GPU_START_X + (GPU_START_Y * GPU_COLUMNS)), 13)) + (OFFSET_ADDR & "000");
                            else
                                GPU_START_ADDR<= std_logic_vector(to_unsigned((GPU_START_X + (GPU_START_Y * GPU_COLUMNS)), 15));
                                VRAM_GPU_ADDR <= std_logic_vector(to_unsigned((GPU_START_X + (GPU_START_Y * GPU_COLUMNS)), 13));
                            end if;
                            GPU_VAR_Y         := GPU_START_Y;
                            GPU_STATE         <= GPU_VRAM_Clear_1;
    
                        when GPU_VRAM_Clear_1 =>
    
                            -- Set data according to region being filled, character (000:7FF) or attribute (800:FFF)
                            if VRAM_GPU_ADDR < X"800" then
                                VRAM_GPU_DI   <= GPU_VRAM_CHAR;
                            else
                                VRAM_GPU_DI   <= GPU_VRAM_ATTR;
                            end if;
    
                            -- Need to wait for the vertical blanking interval even though were using dual port RAM, this is to avoid part display or
                            -- old data and new data causing a visible tear.
                            if V_BLANKi = '1' or GPU_VBLANK_WAIT = '0' then
                                VRAM_GPU_WEN  <= '1';
                                GPU_STATE     <= GPU_VRAM_Clear_2;
                            end if;
    
                            -- Keep the Write Enable active for one full clock cycle before moving on to the next state.
                          --if VRAM_GPU_WEN = '1' then
                          --    GPU_STATE     <= GPU_VRAM_Clear_2;
                          --end if;
    
                        when GPU_VRAM_Clear_2 =>
                            VRAM_GPU_WEN      <= '0';
                            GPU_STATE         <= GPU_VRAM_Clear_1;
    
                            if (to_integer(unsigned(VRAM_GPU_ADDR)) >= to_integer(unsigned(GPU_START_ADDR)) + (GPU_END_X - GPU_START_X)) or VRAM_GPU_ADDR >= X"FFF" then
    
                                -- If we have completed filling in the entire char and attr RAM, exit.
                                if VRAM_GPU_ADDR >= X"FFF" then
                                    GPU_STATE          <= GPU_VRAM_Clear_3;
                                else
                                    -- Alternate between character ram and attribute ram, they differ by 0x800 bytes, ie; 0xD000:D7FF and 0xD800:0xDFFF
                                    if VRAM_GPU_ADDR < X"800" then
                                        VRAM_GPU_ADDR  <= GPU_START_ADDR(12 downto 0) + X"800";
                                        GPU_START_ADDR <= GPU_START_ADDR + X"800";
                                    else
                                        VRAM_GPU_ADDR  <= GPU_START_ADDR(12 downto 0) - X"800" + GPU_COLUMNS;
                                        GPU_START_ADDR <= GPU_START_ADDR - X"800" + GPU_COLUMNS;
                                        GPU_VAR_Y      := GPU_VAR_Y + 1;
    
                                        -- If we have filled to the set line, exit.
                                        if GPU_VAR_Y > GPU_END_Y then
                                            GPU_STATE  <= GPU_VRAM_Clear_3;
                                        end if;
                                    end if;
                                end if;
                            else
                                VRAM_GPU_ADDR <= VRAM_GPU_ADDR + 1;
                            end if;
    
                        when GPU_VRAM_Clear_3 =>
                            GPU_STATE         <= GPU_State_Idle;
    
                        -- Set to idle and cancel any active signals.
                        when others =>
                            -- GPU idle.
                            GPU_STATUS(0)     <= '0';
                            GWEN_GPU_R        <= '0';
                            GWEN_GPU_G        <= '0';
                            GWEN_GPU_B        <= '0';
                            VRAM_GPU_WEN      <= '0';
                    end case;
                end if;
            end if; -- if VRESETn
        end if; -- rising_edge(SYS_CLK)
    end process;

    -- Control Registers
    --
    -- MZ1200/80A: INVERT display, accessed at E014
    --             SCROLL display, accessed at E200 - E2FF, the address determines the offset.
    --
    -- Video Mode (display output):
    --   0xD0 - Set the Video Mode parameter number to update.
    --   0xD1 - Update the lower selected Video Mode parameter byte.
    --   0xD2 - Update the upper selected Video Mode parameter byte.
    -- Palette configuration:
    --   0xD3 - set the palette slot (PALETTE_PARAM_SEL) Off position to be adjusted.
    --   0xD4 - set the palette slot (PALETTE_PARAM_SEL) On position to be adjusted.
    --   0xD5 - set the red palette value according to the PALETTE_PARAM_SEL address.
    --   0xD6 - set the green palette value according to the PALETTE_PARAM_SEL address.
    --   0xD7 - set the blue palette value according to the PALETTE_PARAM_SEL address.
    --
    --   0xF3 set the VGA border attributes. The VGA modes have areas not used by the graphics output, this register allows this area to be set to a specific colour (when colour mode enabled).
    --     Bits [2:0] define the border colour, 2 = R, 1 = G, 0 = B
    -- MZ-80B GRAM:
    --   0xF4 set the MZ80B/MZ2000 graphics options.
    --     Bit 0 = 0, Write to Graphics RAM I, Bit 0 = 1, Write to Graphics RAM II.
    --     Bit 1 = 1, blend Graphics RAM I output on display, Bit 2 = 1, blend Graphics RAM II output on display.
    -- Select Palette:
    --   0xF5 sets the palette. The Video Module supports 4 bit per colour output but there is only enough RAM for 1 bit per colour so the pallette is used to change the colours output.
    --     Bits [7:0] defines the pallete number. This indexes a lookup table which contains the required 4bit output per 1bit input.
    -- GPU:
    --   0xF6 set parameters. Store parameters in a long word to be used by the graphics command processor.
    --     The parameter word is 128 bit and each write to the parameter word shifts left by 8 bits and adds the new byte at bits 7:0.
    --   0xF7 set the graphics processor unit commands.
    --     Bits [5:0] - 0 = Reset parameters.
    --                  1 = Clear to val. Start Location (16 bit), End Location (16 bit), Red Filter, Green Filter, Blue Filter
    --
    -- IO Range for Graphics enhancements is set by the Video Mode registers at 0xF5->.
    --   0xF8=<val> sets the mode of the Video Module. [2:0] - 000 = MZ-80K, 001 = MZ-80C, 010 = MZ-1200, 011 = MZ--80A, 100 = MZ-700, 101 = MZ-800, 110 = MZ-80B, 111 = MZ-2000. [3] = 0 - 40 col, 1 - 80 col, [4] = 0 - mono, 1 - colour.
    --              [4] defines the colour mode, 0 = mono, 1 = colour - ignored on certain modes. [5] defines wether PCGRAM is enabled, 0 = disabled, 1 = enabled. [7:6] define the VGA mode.
    --   0xF9=<val> sets the graphics mode. 7/6 = Operator (00=OR,01=AND,10=NAND,11=XOR), 5=GRAM Output Enable, 4 = VRAM Output Enable, 3/2 = Write mode (00=Page 1:Red, 01=Page 2:Green, 10=Page 3:Blue, 11=Indirect), 1/0=Read mode (00=Page 1:Red, 01=Page2:Green, 10=Page 3:Blue, 11=Not used).
    --   0xFA=<val> sets the Red bit mask (1 bit = 1 pixel, 8 pixels per byte).
    --   0xFB=<val> sets the Green bit mask (1 bit = 1 pixel, 8 pixels per byte).
    --   0xFC=<val> sets the Blue bit mask (1 bit = 1 pixel, 8 pixels per byte).
    --   0xFD=<val> memory page register. [0] switches in 16Kb page (1 of 3 pages) of graphics ram to C000 - FFFF. Bits [0] = page, 0 = off, 1 = GRAM enabled. This overrides all MZ700/MZ80B page switching functions. [7] 0 - normal, 1 - switches in CGROM for upload at D000:DFFF.
    --
    CTRLREGISTERS: process( VRESETn, SYS_CLK, CGROM_PAGE, GRAM_PAGE_ENABLE, VIDEOMODE, MZ80B_VRAM_HI_ADDR, MZ80B_VRAM_LO_ADDR )
    begin

        if rising_edge(SYS_CLK) then

            -- Ensure default values at reset.
            if VRESETn='0' then
                DISPLAY_INVERT        <= '0';
                OFFSET_ADDR           <= (others => '0');
                GRAM_MODE_REG         <= "00101100";
                GRAM_R_FILTER         <= (others => '1');
                GRAM_G_FILTER         <= (others => '1');
                GRAM_B_FILTER         <= (others => '1');
                GRAM_OPT_WRITE        <= '0';
                GRAM_OPT_OUT1         <= '0';
                GRAM_OPT_OUT2         <= '0';
                PCGRAM                <= '0';
                MODE_VIDEO_MZ80A      <= '0';
                MODE_VIDEO_MZ700      <= '1';
                MODE_VIDEO_MZ800      <= '0';
                MODE_VIDEO_MZ80B      <= '0';
                MODE_VIDEO_MZ80K      <= '0';
                MODE_VIDEO_MZ80C      <= '0';
                MODE_VIDEO_MZ1200     <= '0';
                MODE_VIDEO_MZ2000     <= '0';
                MODE_VIDEO_MONO       <= '0';
                MODE_VIDEO_MONO80     <= '0';
                MODE_VIDEO_COLOUR     <= '1';
                MODE_VIDEO_COLOUR80   <= '0';
                VIDEO_MODE_REG        <= std_logic_vector(to_unsigned(MODE_MZ700, VIDEO_MODE_REG'length));
                VGAMODE               <= "00";
                GRAM_PAGE_ENABLE      <= '0';
                CGROM_PAGE            <= '0';
                DISPLAY_VGATE         <= '0';
                CGRAM_ADDR            <= (others=>'0');
                PCG_DATA              <= (others=>'0');
                BORDER_REG            <= (others => '0');
                PALETTE_REG           <= (others => '0');
                PALETTE_PARAM_SEL     <= (others => '0');
                CGRAM_WEn             <= '1';
                GPU_PARAMS            <= (others => '0');
                GPU_COMMAND           <= (others => '0');
                DSP_PARAM_UPD         <= '0';
    
            else

                -- Clock register updates on the Z80 clock timing.
         --       if VZ80_CLKi = "1110" then

         --       end if;

                -- If the GPU goes busy, clear the command register ready for next command.
                --
                if CS_FB_GPUn = '1' and GPU_STATUS(0) = '1' then
                    GPU_COMMAND       <= (others => '0');
                end if;

                -- Clear write enables to the palette register.
                --
                PALETTE_WEN_R         <= '0';
                PALETTE_WEN_G         <= '0';
                PALETTE_WEN_B         <= '0';

                -- Read registers. Detect the edge of the read signal and action register reads on this edge.
                if VIDEO_RDni = '0' then

                    -- MZ80A has hardware inversion which is basically the inversion of the video out stream. A signal is set when inversion is required by a read to E014 and reset
                    -- with a read to E015.
                    if CS_INVERTn='0' and (MODE_VIDEO_MZ80A = '1' or MODE_VIDEO_MZ700 = '1') then
                        DISPLAY_INVERT    <= Z80_MA(0);
                    end if;
    
                    -- MZ80A has hardware scrolling which is basically the addition, in blocks of 8, to the video address line. A read from E200 will set the addition to 0,
                    -- a read from each location, E201 - E2FE will add X x 8 bytes to the address, a read from E2FF will scroll fully to the end of the VRAM buffer.
                    if CS_SCROLLn='0' and (MODE_VIDEO_MZ80A = '1' or MODE_VIDEO_MZ700 = '1') then
                        if MODE_VIDEO_MONO80 = '1' or MODE_VIDEO_COLOUR80 = '1' then
                            OFFSET_ADDR   <= (others => '0');
                        else
                            OFFSET_ADDR   <= VIDEO_ADDRi(7 downto 0);
                        end if;
                    end if;
                end if; -- Read block

                -- The register shift of the GPU parameters must occur after the read transaction completes otherwise scrambled data will be sent to the external device.
                if VIDEO_LAST_RDni = "0001" and VIDEO_RDni = '1' then
                    -- Read out the rightmost byte of the GPU parameters and shift right, this allows reading or manipulating the parameters.
                    -- The shift is made at the end of the read cycle so that valid data is seen by the CPU.
                    if CS_FB_PARAMSn = '0' then
                        GPU_PARAMS(119 downto 0) <= GPU_PARAMS(127 downto 8);
                    end if;
                end if;

                -- Data output, selected according to addressed resource.
                if VIDEO_RDni = '0' then

                    if CS_DXXXn = '0'   and ((CS_VIDEO_LEGACYn = '0' and CGROM_PAGE = '0') or CS_VIDEO_VRAM_DIRECTn = '0') then
                        VIDEO_DATA_OUTi       <= VRAM_VIDEO_DATA;
                    elsif ((CS_FBRAMn = '0'  and GRAM_MODE_REG(1 downto 0) = "00") or CS_VIDEO_R_FB_DIRECTn = '0') then    -- For direct framebuffer access, C000:FFFF is assigned to the framebuffer during a read if the GRAM_PAGE_ENABLE register is not 0. 
                        VIDEO_DATA_OUTi       <= GRAM_DO_R;
                    elsif ((CS_FBRAMn = '0'  and GRAM_MODE_REG(1 downto 0) = "01") or CS_VIDEO_B_FB_DIRECTn = '0') then
                        VIDEO_DATA_OUTi       <= GRAM_DO_B;
                    elsif ((CS_FBRAMn = '0'  and GRAM_MODE_REG(1 downto 0) = "10") or CS_VIDEO_G_FB_DIRECTn = '0') then
                        VIDEO_DATA_OUTi       <= GRAM_DO_G;
                    elsif CS_GRAMn = '0'   and GRAM_OPT_WRITE = '0'  then                                                  -- For MZ80B GRAM I memory read - lower 8K  of red framebuffer.
                        VIDEO_DATA_OUTi       <= GRAM_DO_GI;
                    elsif CS_GRAMn = '0'   and GRAM_OPT_WRITE = '1' then                                                   -- For MZ80B GRAM II memory read - lower 8K of blue framebuffer.
                        VIDEO_DATA_OUTi       <= GRAM_DO_GII;
                    elsif CS_FB_VMn = '0' then
                        VIDEO_DATA_OUTi       <= X"000000" & VIDEO_MODE_REG(7 downto 0);
                    elsif CS_FB_CTLn = '0' then
                        VIDEO_DATA_OUTi       <= X"000000" & GRAM_MODE_REG;
                    elsif CS_FB_REDn = '0' then
                        VIDEO_DATA_OUTi       <= X"000000" & GRAM_R_FILTER;
                    elsif CS_FB_GREENn = '0' then
                        VIDEO_DATA_OUTi       <= X"000000" & GRAM_G_FILTER;
                    elsif CS_FB_BLUEn = '0' then
                        VIDEO_DATA_OUTi       <= X"000000" & GRAM_B_FILTER;
                    elsif CS_FB_PAGEn = '0' then
                        VIDEO_DATA_OUTi       <= X"000000" & PAGE_MODE_REG(7) & V_BLANKi & H_BLANKi & PAGE_MODE_REG(4 downto 0);
                    elsif CS_DXXXn = '0'   and ((CS_VIDEO_LEGACYn = '0' and CGROM_PAGE = '1') or CS_VIDEO_CG_DIRECTn = '0') then
                        VIDEO_DATA_OUTi       <= CGROM_DO;
                    elsif CS_FB_GPUn = '0' then
                        VIDEO_DATA_OUTi       <= X"000000" & GPU_STATUS;
                    elsif CS_FB_PARAMSn = '0' then
                        VIDEO_DATA_OUTi       <= X"000000" & GPU_PARAMS(7 downto 0);
                    elsif CS_FB_BORDERn = '0' then
                        VIDEO_DATA_OUTi       <= X"000000" & BORDER_REG;
                    elsif CS_FB_PALETTEn = '0' then
                        VIDEO_DATA_OUTi       <= X"000000" & PALETTE_REG;
                    elsif CS_IO_DXXn = '0' and VIDEO_ADDRi(3 downto 0) = "0101" then
                        VIDEO_DATA_OUTi       <= X"000000" & "000" & PALETTE_DO_R;
                    elsif CS_IO_DXXn = '0' and VIDEO_ADDRi(3 downto 0) = "0110" then
                        VIDEO_DATA_OUTi       <= X"000000" & "000" & PALETTE_DO_G;
                    elsif CS_IO_DXXn = '0' and VIDEO_ADDRi(3 downto 0) = "0111" then
                        VIDEO_DATA_OUTi       <= X"000000" & "000" & PALETTE_DO_B;

                    -- Programmable video settings read out.
                    elsif VIDEO_RDni = '0'   and CS_IO_DXXn = '0' and VIDEO_ADDRi(3 downto 0) = "0001" and DSP_PARAM_SEL = "0000" then
                        VIDEO_DATA_OUTi       <= X"000000" & std_logic_vector(H_DSP_START(7 downto 0));
                    elsif VIDEO_RDni = '0'   and CS_IO_DXXn = '0' and VIDEO_ADDRi(3 downto 0) = "0010" and DSP_PARAM_SEL = "0000" then
                        VIDEO_DATA_OUTi       <= X"000000" & std_logic_vector(H_DSP_START(15 downto 8));
                    elsif VIDEO_RDni = '0'   and CS_IO_DXXn = '0' and VIDEO_ADDRi(3 downto 0) = "0001" and DSP_PARAM_SEL = "0001" then
                        VIDEO_DATA_OUTi       <= X"000000" & std_logic_vector(H_DSP_END(7 downto 0));
                    elsif VIDEO_RDni = '0'   and CS_IO_DXXn = '0' and VIDEO_ADDRi(3 downto 0) = "0010" and DSP_PARAM_SEL = "0001" then
                        VIDEO_DATA_OUTi       <= X"000000" & std_logic_vector(H_DSP_END(15 downto 8));
                    elsif VIDEO_RDni = '0'   and CS_IO_DXXn = '0' and VIDEO_ADDRi(3 downto 0) = "0001" and DSP_PARAM_SEL = "0010" then
                        VIDEO_DATA_OUTi       <= X"000000" & std_logic_vector(H_DSP_WND_START(7 downto 0));
                    elsif VIDEO_RDni = '0'   and CS_IO_DXXn = '0' and VIDEO_ADDRi(3 downto 0) = "0010" and DSP_PARAM_SEL = "0010" then
                        VIDEO_DATA_OUTi       <= X"000000" & std_logic_vector(H_DSP_WND_START(15 downto 8));
                    elsif VIDEO_RDni = '0'   and CS_IO_DXXn = '0' and VIDEO_ADDRi(3 downto 0) = "0001" and DSP_PARAM_SEL = "0011" then
                        VIDEO_DATA_OUTi       <= X"000000" & std_logic_vector(H_DSP_WND_END(7 downto 0));
                    elsif VIDEO_RDni = '0'   and CS_IO_DXXn = '0' and VIDEO_ADDRi(3 downto 0) = "0010" and DSP_PARAM_SEL = "0011" then
                        VIDEO_DATA_OUTi       <= X"000000" & std_logic_vector(H_DSP_WND_END(15 downto 8));
                    elsif VIDEO_RDni = '0'   and CS_IO_DXXn = '0' and VIDEO_ADDRi(3 downto 0) = "0001" and DSP_PARAM_SEL = "0100" then
                        VIDEO_DATA_OUTi       <= X"000000" & std_logic_vector(V_DSP_START(7 downto 0));
                    elsif VIDEO_RDni = '0'   and CS_IO_DXXn = '0' and VIDEO_ADDRi(3 downto 0) = "0010" and DSP_PARAM_SEL = "0100" then
                        VIDEO_DATA_OUTi       <= X"000000" & std_logic_vector(V_DSP_START(15 downto 8));
                    elsif VIDEO_RDni = '0'   and CS_IO_DXXn = '0' and VIDEO_ADDRi(3 downto 0) = "0001" and DSP_PARAM_SEL = "0101" then
                        VIDEO_DATA_OUTi       <= X"000000" & std_logic_vector(V_DSP_END(7 downto 0));
                    elsif VIDEO_RDni = '0'   and CS_IO_DXXn = '0' and VIDEO_ADDRi(3 downto 0) = "0010" and DSP_PARAM_SEL = "0101" then
                        VIDEO_DATA_OUTi       <= X"000000" & std_logic_vector(V_DSP_END(15 downto 8));
                    elsif VIDEO_RDni = '0'   and CS_IO_DXXn = '0' and VIDEO_ADDRi(3 downto 0) = "0001" and DSP_PARAM_SEL = "0110" then
                        VIDEO_DATA_OUTi       <= X"000000" & std_logic_vector(V_DSP_WND_START(7 downto 0));
                    elsif VIDEO_RDni = '0'   and CS_IO_DXXn = '0' and VIDEO_ADDRi(3 downto 0) = "0010" and DSP_PARAM_SEL = "0110" then
                        VIDEO_DATA_OUTi       <= X"000000" & std_logic_vector(V_DSP_WND_START(15 downto 8));
                    elsif VIDEO_RDni = '0'   and CS_IO_DXXn = '0' and VIDEO_ADDRi(3 downto 0) = "0001" and DSP_PARAM_SEL = "0111" then
                        VIDEO_DATA_OUTi       <= X"000000" & std_logic_vector(V_DSP_WND_END(7 downto 0));
                    elsif VIDEO_RDni = '0'   and CS_IO_DXXn = '0' and VIDEO_ADDRi(3 downto 0) = "0010" and DSP_PARAM_SEL = "0111" then
                        VIDEO_DATA_OUTi       <= X"000000" & std_logic_vector(V_DSP_WND_END(15 downto 8));
                    elsif VIDEO_RDni = '0'   and CS_IO_DXXn = '0' and VIDEO_ADDRi(3 downto 0) = "0001" and DSP_PARAM_SEL = "1000" then
                        VIDEO_DATA_OUTi       <= X"000000" & std_logic_vector(H_LINE_END(7 downto 0));
                    elsif VIDEO_RDni = '0'   and CS_IO_DXXn = '0' and VIDEO_ADDRi(3 downto 0) = "0010" and DSP_PARAM_SEL = "1000" then
                        VIDEO_DATA_OUTi       <= X"000000" & std_logic_vector(H_LINE_END(15 downto 8));
                    elsif VIDEO_RDni = '0'   and CS_IO_DXXn = '0' and VIDEO_ADDRi(3 downto 0) = "0001" and DSP_PARAM_SEL = "1001" then
                        VIDEO_DATA_OUTi       <= X"000000" & std_logic_vector(V_LINE_END(7 downto 0));
                    elsif VIDEO_RDni = '0'   and CS_IO_DXXn = '0' and VIDEO_ADDRi(3 downto 0) = "0010" and DSP_PARAM_SEL = "1001" then
                        VIDEO_DATA_OUTi       <= X"000000" & std_logic_vector(V_LINE_END(15 downto 8));
                    elsif VIDEO_RDni = '0'   and CS_IO_DXXn = '0' and VIDEO_ADDRi(3 downto 0) = "0001" and DSP_PARAM_SEL = "1010" then
                        VIDEO_DATA_OUTi       <= X"000000" & std_logic_vector(MAX_COLUMN(7 downto 0));
                    elsif VIDEO_RDni = '0'   and CS_IO_DXXn = '0' and VIDEO_ADDRi(3 downto 0) = "0010" and DSP_PARAM_SEL = "1010" then
                        VIDEO_DATA_OUTi       <= (others => '0');
                    elsif VIDEO_RDni = '0'   and CS_IO_DXXn = '0' and VIDEO_ADDRi(3 downto 0) = "0001" and DSP_PARAM_SEL = "1011" then
                        VIDEO_DATA_OUTi       <= X"000000" & std_logic_vector(H_SYNC_START(7 downto 0));
                    elsif VIDEO_RDni = '0'   and CS_IO_DXXn = '0' and VIDEO_ADDRi(3 downto 0) = "0010" and DSP_PARAM_SEL = "1011" then
                        VIDEO_DATA_OUTi       <= X"000000" & std_logic_vector(H_SYNC_START(15 downto 8));
                    elsif VIDEO_RDni = '0'   and CS_IO_DXXn = '0' and VIDEO_ADDRi(3 downto 0) = "0001" and DSP_PARAM_SEL = "1100" then
                        VIDEO_DATA_OUTi       <= X"000000" & std_logic_vector(H_SYNC_END(7 downto 0));
                    elsif VIDEO_RDni = '0'   and CS_IO_DXXn = '0' and VIDEO_ADDRi(3 downto 0) = "0010" and DSP_PARAM_SEL = "1100" then
                        VIDEO_DATA_OUTi       <= X"000000" & std_logic_vector(H_SYNC_END(15 downto 8));
                    elsif VIDEO_RDni = '0'   and CS_IO_DXXn = '0' and VIDEO_ADDRi(3 downto 0) = "0001" and DSP_PARAM_SEL = "1101" then
                        VIDEO_DATA_OUTi       <= X"000000" & std_logic_vector(V_SYNC_START(7 downto 0));
                    elsif VIDEO_RDni = '0'   and CS_IO_DXXn = '0' and VIDEO_ADDRi(3 downto 0) = "0010" and DSP_PARAM_SEL = "1101" then
                        VIDEO_DATA_OUTi       <= X"000000" & std_logic_vector(V_SYNC_START(15 downto 8));
                    elsif VIDEO_RDni = '0'   and CS_IO_DXXn = '0' and VIDEO_ADDRi(3 downto 0) = "0001" and DSP_PARAM_SEL = "1110" then
                        VIDEO_DATA_OUTi       <= X"000000" & std_logic_vector(V_SYNC_END(7 downto 0));
                    elsif VIDEO_RDni = '0'   and CS_IO_DXXn = '0' and VIDEO_ADDRi(3 downto 0) = "0010" and DSP_PARAM_SEL = "1110" then
                        VIDEO_DATA_OUTi       <= X"000000" & std_logic_vector(V_SYNC_END(15 downto 8));
                    elsif VIDEO_RDni = '0'   and CS_IO_DXXn = '0' and VIDEO_ADDRi(3 downto 0) = "0001" and DSP_PARAM_SEL = "1111" then
                        VIDEO_DATA_OUTi       <= X"000000" & std_logic_vector(H_PX(7 downto 0));
                    elsif VIDEO_RDni = '0'   and CS_IO_DXXn = '0' and VIDEO_ADDRi(3 downto 0) = "0010" and DSP_PARAM_SEL = "1111" then
                        VIDEO_DATA_OUTi       <= X"000000" & std_logic_vector(V_PX(7 downto 0));
                    else
                        VIDEO_DATA_OUTi       <= (others => '0');
                    end if;
                end if; -- Read block

                -- Write registers. Detect the edge of the write signal and action register updates on this edge.
                if VIDEO_WRni = '0' then

                    -- Store the incoming GPU parameters in a 128bit register.
                    if CS_FB_PARAMSn = '0' then
                        GPU_PARAMS(127 downto 8) <= GPU_PARAMS(119 downto 0);
                        GPU_PARAMS(7 downto 0)   <= VIDEO_DATA_INi(7 downto 0);
                    end if;

                    -- Setup the VGA border attributes. The VGA modes have areas not used by the graphics output, this register allows this area to be set to a specific colour (when colour mode enabled).
                    --        Bits [2:0] define the border colour, 2 = R, 1 = G, 0 = B
                    if CS_FB_BORDERn = '0' then
                        BORDER_REG        <= VIDEO_DATA_INi(7 downto 0);
                    end if;

                    -- Setup the palette register to given value.
                    if CS_FB_PALETTEn = '0' then
                        PALETTE_REG       <= VIDEO_DATA_INi(7 downto 0);
                    end if;

                    -- Setup the palette values for off and on states.
                    --
                    if CS_IO_DXXn = '0' then

                        case VIDEO_ADDRi(3 downto 0) is
                            -- 0xD3 - set the palette slot Off position to be adjusted.
                            when "0011" =>
                                PALETTE_PARAM_SEL   <= VIDEO_DATA_INi(7 downto 0) & '0';

                            -- 0xD4 - set the palette slot On position to be adjusted.
                            when "0100" =>
                                PALETTE_PARAM_SEL   <= VIDEO_DATA_INi(7 downto 0) & '1';

                            -- 0xD5 - set the red palette value according to the PALETTE_PARAM_SEL address.
                            when "0101" =>
                                PALETTE_WEN_R       <= '1';

                            -- 0xD6 - set the green palette value according to the PALETTE_PARAM_SEL address.
                            when "0110" =>
                                PALETTE_WEN_G       <= '1';

                            -- 0xD7 - set the blue palette value according to the PALETTE_PARAM_SEL address.
                            when "0111" =>
                                PALETTE_WEN_B       <= '1';

                            when others =>
                        end case;
                    end if;

                    -- Store the incoming GPU command.
                    if CS_FB_GPUn = '0' then
                        GPU_COMMAND       <= VIDEO_DATA_INi(7 downto 0);
                    end if;
    
                    -- Setup the machine mode and video mode.
                    if CS_FB_VMn = '0' then
                        MODE_VIDEO_MZ80A  <= '0';
                        MODE_VIDEO_MZ700  <= '0';
                        MODE_VIDEO_MZ800  <= '0';
                        MODE_VIDEO_MZ80B  <= '0';
                        MODE_VIDEO_MZ80K  <= '0';
                        MODE_VIDEO_MZ80C  <= '0';
                        MODE_VIDEO_MZ1200 <= '0';
                        MODE_VIDEO_MZ2000 <= '0';
                        MODE_VIDEO_MONO   <= '0';
                        MODE_VIDEO_MONO80 <= '0';
                        MODE_VIDEO_COLOUR <= '0';
                        MODE_VIDEO_COLOUR80<= '0';
                        VIDEO_MODE_REG    <= VIDEO_DATA_INi(7 downto 0);   -- Store the programmed setting for CPU readback.

                        -- Bits [2:0] define the Video Module machine compatibility.
                        -- Bit    [3] defines the 40/80 column mode, 0 = 40 col, 1 = 80 col.
                        -- Bit    [4] defines the colour mode, 0 = mono, 1 = colour - ignored on certain modes.
                        -- Bit    [5] defines wether PCGRAM is enabled, 0 = disabled, 1 = enabled.
                        -- Bits [7:6] define the VGA mode.
                        --
                        case to_integer(unsigned(VIDEO_DATA_INi(2 downto 0))) is
                            when MODE_MZ80A =>
                                MODE_VIDEO_MZ80A         <= '1';

                                -- The MZ-80A is a monochrome machine by default but can have the optional colour board, so consider the
                                -- colour flage (4) and the 40/80 column flag (3) to setup correct mode.
                                --
                                if VIDEO_DATA_INi(4) = '0' and VIDEO_DATA_INi(3) = '0' then
                                    MODE_VIDEO_MONO      <= '1';
                                elsif VIDEO_DATA_INi(3) = '1' and VIDEO_DATA_INi(4) = '0' then
                                    MODE_VIDEO_MONO80    <= '1';
                                elsif VIDEO_DATA_INi(3) = '0' and VIDEO_DATA_INi(4) = '1' then
                                    MODE_VIDEO_COLOUR    <= '1';
                                else
                                    MODE_VIDEO_COLOUR80  <= '1';
                                end if;

                            when MODE_MZ800 =>
                                MODE_VIDEO_MZ800         <= '1';

                                -- MZ-800 is a colour machine, so only consider the 40/80 column switch.
                                -- This flag is also updated in the MZ-800 emulation using the original port/bit. The two modes provide a common
                                -- interface, for the superset code and for original machine compatibility.
                                if VIDEO_DATA_INi(3) = '0' then
                                    MODE_VIDEO_COLOUR    <= '1';
                                else
                                    MODE_VIDEO_COLOUR80  <= '1';
                                end if;

                            when MODE_MZ80B =>
                                MODE_VIDEO_MZ80B         <= '1';

                                -- The MZ-80B is a monochrome machine so only consider monochrome. This is intentional as the GRAM used by the MZ80B
                                -- is used for the colour framebuffer, so true colour is not possible when using MZ80B compatible graphics. Colour is
                                -- possible if direct access to the colour frame buffers is used but this is a superset feature.
                                if VIDEO_DATA_INi(3) = '0' then
                                    MODE_VIDEO_MONO      <= '1';
                                else
                                    MODE_VIDEO_MONO80    <= '1';
                                end if;

                            when MODE_MZ80K =>
                                MODE_VIDEO_MZ80K         <= '1';

                                -- The MZ-80K is a mono machine, so only consider the 40/80 column flag as extensions to the original hardware were made for CP/M.
                                if VIDEO_DATA_INi(3) = '0' then
                                    MODE_VIDEO_MONO      <= '1';
                                else
                                    MODE_VIDEO_MONO80    <= '1';
                                end if;

                            when MODE_MZ80C =>
                                MODE_VIDEO_MZ80C         <= '1';

                                -- The MZ-80C is a mono machine, so only consider the 40/80 column flag as extensions to the original hardware were made for CP/M.
                                if VIDEO_DATA_INi(3) = '0' then
                                    MODE_VIDEO_MONO      <= '1';
                                else
                                    MODE_VIDEO_MONO80    <= '1';
                                end if;

                            when MODE_MZ1200 =>
                                MODE_VIDEO_MZ1200        <= '1';

                                -- The MZ-1200 is a mono machine, so only consider the 40/80 column flag as extensions to the original hardware were made for CP/M.
                                if VIDEO_DATA_INi(3) = '0' then
                                    MODE_VIDEO_MONO      <= '1';
                                else
                                    MODE_VIDEO_MONO80    <= '1';
                                end if;

                            when MODE_MZ2000 =>
                                MODE_VIDEO_MZ2000        <= '1';

                                -- The MZ-2000 is an enhancement of the MZ80B. At the moment the logic hasnt been written so we set it as an MZ80B for the time being.
                                if VIDEO_DATA_INi(3) = '0' then
                                    MODE_VIDEO_MONO      <= '1';
                                else
                                    MODE_VIDEO_MONO80    <= '1';
                                end if;

                            when MODE_MZ700 =>
                                MODE_VIDEO_MZ700         <= '1';

                                -- MZ-700 is a colour machine, so only consider the 40/80 column switch.
                                if VIDEO_DATA_INi(3) = '0' then
                                    MODE_VIDEO_COLOUR    <= '1';
                                else
                                    MODE_VIDEO_COLOUR80  <= '1';
                                end if;

                            when others =>
                        end case;

                        -- PCG RAM, enable/disable.
                        PCGRAM                    <= VIDEO_DATA_INi(5);

                        -- The VGA Mode is used to change the type of VGA output frequency and resolution made to the external monitor.
                        VGAMODE                   <= VIDEO_DATA_INi(7 downto 6);

                    end if;

                    -- Framebuffer control register.
                    -- sets the graphics mode. 7/6 = Operator (00=OR,01=AND,10=NAND,11=XOR), 5=GRAM Output Enable, 4 = VRAM Output Enable, 3/2 = Write mode (00=Page 1:Red, 01=Page 2:Green, 10=Page 3:Blue, 11=Indirect), 1/0=Read mode (00=Page 1:Red, 01=Page2:Green, 10=Page 3:Blue, 11=Not used).
                    if CS_FB_CTLn = '0' then
                        GRAM_MODE_REG             <= VIDEO_DATA_INi(7 downto 0);
                    end if;
    
                    -- sets the Red bit mask (1 bit = 1 pixel, 8 pixels per byte).
                    if CS_FB_REDn = '0' then
                        GRAM_R_FILTER             <= VIDEO_DATA_INi(7 downto 0);
                    end if;
    
                    -- sets the Green bit mask (1 bit = 1 pixel, 8 pixels per byte).
                    if CS_FB_GREENn = '0' then
                        GRAM_G_FILTER             <= VIDEO_DATA_INi(7 downto 0);
                    end if;
    
                    -- sets the Blue bit mask (1 bit = 1 pixel, 8 pixels per byte).
                    if CS_FB_BLUEn = '0' then
                        GRAM_B_FILTER             <= VIDEO_DATA_INi(7 downto 0);
                    end if;
    
                    -- set ths MZ80B/MZ2000 graphics options. Bit 0 = 0, Write to Graphics RAM I, Bit 0 = 1, Write to Graphics RAM II.
                    --                                        Bit 1 = 1, blend Graphics RAM I output on display, Bit 2 = 1, blend Graphics RAM II output on display.
                    if CS_GRAM_OPTn = '0' then
                        GRAM_OPT_WRITE            <= VIDEO_DATA_INi(0);
                        GRAM_OPT_OUT1             <= VIDEO_DATA_INi(1);
                        GRAM_OPT_OUT2             <= VIDEO_DATA_INi(2);
                    end if;

                    -- memory page register. [0] switches in 16Kb page (3 pages) of graphics ram to C000 - FFFF. Bits [0] = page, 0 = off, 1 = GRAM paged in. This overrides all MZ700/MZ80B page switching functions. [7] 0 - normal, 1 - switches in CGROM for upload at D000:DFFF.
                    if CS_FB_PAGEn = '0' then
                        GRAM_PAGE_ENABLE          <= VIDEO_DATA_INi(0);
                        CGROM_PAGE                <= VIDEO_DATA_INi(7);
                    end if;

                    -- MZ80B Registers - the writable values relevant to video are registered and stored in this module.
                    --
                    -- MZ80B 8255 PPI.
                    -- PA4 = 0 = Reverses B/W of entire display screen. 
                    -- PC3 = 0 = Starts IPL. 
                    -- PC1 = 1 = Sets memory in normal state, starting $0000. 
                    -- PC0 = 1 = Unconditionally clears the display screen.
                    if CS_80B_PPIn = '0' then

                        -- Port A
                        if VIDEO_ADDRi(1 downto 0) = "00" then
                            DISPLAY_INVERT        <= VIDEO_DATA_INi(4);
                        end if;
                        -- Port C
                        if VIDEO_ADDRi(1 downto 0) = "10" then
                            DISPLAY_VGATE         <= VIDEO_DATA_INi(0);
                            MZ80B_IPL             <= VIDEO_DATA_INi(3);
                            MZ80B_BOOT            <= VIDEO_DATA_INi(1);
                        end if;
                        -- Port C direct set/reset.
                        if VIDEO_ADDRi(1 downto 0) = "11" and VIDEO_DATA_INi(7) = '0' then
                            case VIDEO_DATA_INi(3 downto 1) is
                                when "000"        => DISPLAY_VGATE <= VIDEO_DATA_INi(0);
                                when "001"        => MZ80B_BOOT    <= VIDEO_DATA_INi(0);
                                when "010"        => 
                                when "011"        => MZ80B_IPL     <= VIDEO_DATA_INi(0);
                                when "100"        => 
                                when "101"        => 
                                when "110"        => 
                                when "111"        =>
                                when others       => 
                            end case;
                        end if;
                    end if;
            
                    -- MZ80B 8253 PIT.
                    if CS_80B_PITn = '0' then
                    end if;

                    -- MZ80B Z80 PIO.
                    if CS_80B_PIOn = '0' then

                        -- Write to PIO A.
                        -- 7 = Assigns addresses $DOOO-$FFFF to V-RAM.
                        -- 6 = Assigns addresses $50000-$7FFF to V-RAM.
                        -- 5 = Changes screen to 80-character mode (L: 40-character mode).
                        if VIDEO_ADDRi(1 downto 0) = "00" then
                            MZ80B_VRAM_HI_ADDR    <= VIDEO_DATA_INi(7);
                            MZ80B_VRAM_LO_ADDR    <= VIDEO_DATA_INi(6);
                            if VIDEO_DATA_INi(5) = '0' then
                                MODE_VIDEO_MONO   <= '1';
                            else
                                MODE_VIDEO_MONO80 <= '1';
                            end if;
                        end if;
                    end if;

                    -- MZ80B Video Mode.
                    --
                    if CS_80B_VMODEn = '0' then
                        MZ80B_VMODE_REG           <= VIDEO_DATA_INi(7 downto 0);
                    end if;

                    --
                    -- PCG Access Registers
                    --
                    -- E010: PCG_DATA (byte to describe 8-pixel row of a character)
                    -- E011: PCG_ADDR (offset in the PCG in 8-pixel row unit) -> up to 256/8 = 32 characters
                    -- E012: PCG_CTRL
                    --                bit 0-1: character selector -> (PCG_ADDR + 256*(PCG_CTRL&3)) -> address in the range of the upper 128 characters font
                    --                bit 2 : font selector -> PCG_CTRL&2 == 0 -> 1st font else 2nd font
                    --                bit 3 : select which font for display
                    --                bit 4 : use programmable font for display
                    --                bit 5 : set programmable upper font -> PCG_CTRL&20 == 0 -> fixed upper 128 characters else programmable upper 128 characters
                    --                So if you want to change a character pattern (only doable in the upper 128 characters of a font), you need to:
                    --                - set bit 5 to 1 : PCG_CTRL[5] = 1
                    --                - set the font to select : PCG_CTRL[2] = font_number
                    --                - set the first row address of the character: PCG_ADDR[0..7] = row[0..7] and PCG_CTRL[0..1] = row[8..9]
                    --                - set the 8 pixels of the row in PCG_DATA
                    --
                    if CS_PCGn = '0' then
                        -- Set the PCG Data to program to RAM. 
                        if VIDEO_ADDRi(1 downto 0) = "00" then
                            PCG_DATA                <= VIDEO_DATA_INi(7 downto 0);
                        end if;

                        -- Set the PCG Address in RAM. 
                        if VIDEO_ADDRi(1 downto 0) = "01" then
                            CGRAM_ADDR(7 downto 0)  <= VIDEO_DATA_INi(7 downto 0);
                        end if;

                        -- Set the PCG Control register.
                        if VIDEO_ADDRi(1 downto 0) = "10"  then
                            CGRAM_ADDR(11 downto 8) <= (VIDEO_DATA_INi(2) and MODE_VIDEO_MZ80A) & '1' & VIDEO_DATA_INi(1 downto 0);
                            CGRAM_WEn               <= not VIDEO_DATA_INi(4);
                            CGRAM_SEL               <= VIDEO_DATA_INi(5);
                        end if;
                    end if;


                    -- Ability to adjust the video parameter registers to tune or override the default values from the lookup table. This can be useful in debugging,
                    -- adjusting to a new monitor etc.
                    --
                    if CS_IO_DXXn = '0' then

                        case VIDEO_ADDRi(3 downto 0) is
                            -- 0xD0 - Set the parameter number to update.
                            when "0000" =>
                                DSP_PARAM_SEL     <= VIDEO_DATA_INi(3 downto 0);

                            -- 0xD1 - Update the lower selected parameter byte.
                            when "0001" =>
                                DSP_PARAM_DATA    <= unsigned(VIDEO_DATA_INi(7 downto 0));
                                DSP_PARAM_ADDR    <= '0';
                                DSP_PARAM_UPD     <= '1';

                            -- 0xD2 - Update the upper selected parameter byte.
                            when "0010" =>
                                DSP_PARAM_DATA    <= unsigned(VIDEO_DATA_INi(7 downto 0));
                                DSP_PARAM_ADDR    <= '1';
                                DSP_PARAM_UPD     <= '1';

                            when others =>
                        end case;
                    end if;
                end if; -- Write block

                -- Clear the parameter update flag if it has been actioned and the handshake has been set.
                if DSP_PARAM_UPD = '1' and DSP_PARAM_CLR = '1' then
                    DSP_PARAM_UPD             <= '0';
                end if;
            end if; -- is RESETn
        end if; -- Rising clock edge block.

        -- Non-registered signal vectors for readback.
        -- Page register: [7] = CGROM Page setting, [6:2] = Current video mode, [0] = GRAM enabled setting.
        PAGE_MODE_REG                 <=  CGROM_PAGE & std_logic_vector(to_unsigned(VIDEOMODE, 5)) & '0' & GRAM_PAGE_ENABLE;

        -- MZ80B Graphics RAM is enabled whenever one of the two control lines goes active.
        GRAM_MZ80B_ENABLE             <= MZ80B_VRAM_HI_ADDR or MZ80B_VRAM_LO_ADDR;
    end process;
    
    -- Direct addressing Bus. Normally this is set to 0 during standard Sharp MZ operation, when 23:19 > 0 then direct addressing of the various video
    -- memory's is enabled.
    -- Address    A23 -A16
    -- 0x000000   00000000 - Normal Sharp MZ behaviour
    -- 0x080000   00001000 - Memory and I/O ports mapped into direct addressable memory location.
    --
    --                       A15 - A8 A7 -  A0
    --                       I/O registers are mapped to the bottom 256 bytes mirroring the I/O address.
    -- 0x0800D0              00000000 11010000 - 0xD0 - Set the parameter number to update.
    --                       00000000 11010001 - 0xD1 - Update the lower selected parameter byte.
    --                       00000000 11010010 - 0xD2 - Update the upper selected parameter byte.
    --                       00000000 11010011 - 0xD3 - set the palette slot Off position to be adjusted.
    --                       00000000 11010100 - 0xD4 - set the palette slot On position to be adjusted.
    --                       00000000 11010101 - 0xD5 - set the red palette value according to the PALETTE_PARAM_SEL address.
    --                       00000000 11010110 - 0xD6 - set the green palette value according to the PALETTE_PARAM_SEL address.
    -- 0x0800D7              00000000 11010111 - 0xD7 - set the blue palette value according to the PALETTE_PARAM_SEL address.
    --
    -- 0x0800E0              00000000 11100000 - 0xE0 MZ80B PPI
    --                       00000000 11100100 - 0xE4 MZ80B PIT
    -- 0x0800E8              00000000 11101000 - 0xE8 MZ80B PIO
    --
    --                       00000000 11110000 - 
    --                       00000000 11110001 - 
    --                       00000000 11110010 - 
    -- 0x0800F3              00000000 11110011 - 0xF3 set the VGA border colour.
    --                       00000000 11110100 - 0xF4 set the MZ80B video in/out mode.
    --                       00000000 11110101 - 0xF5 sets the palette.
    --                       00000000 11110110 - 0xF6 set parameters.
    --                       00000000 11110111 - 0xF7 set the graphics processor unit commands.
    --                       00000000 11111000 - 0xF6 set parameters.
    --                       00000000 11111001 - 0xF7 set the graphics processor unit commands.
    --                       00000000 11111010 - 0xF8 set the video mode. 
    --                       00000000 11111011 - 0xF9 set the graphics mode.
    --                       00000000 11111100 - 0xFA set the Red bit mask
    --                       00000000 11111101 - 0xFB set the Green bit mask
    --                       00000000 11111110 - 0xFC set the Blue bit mask
    -- 0x0800FD              00000000 11111111 - 0xFD set the Video memory page in block C000:FFFF 
    --
    --                       Memory registers are mapped to the E000 region as per base machines.
    -- 0x08E010              11100000 00010010 - Program Character Generator RAM. E010 - Write cycle (Read cycle = reset memory swap).
    --                       11100000 00010100 - Normal display select.
    --                       11100000 00010101 - Inverted display select.
    --                       11100010 00000000 - Scroll display register. E200 - E2FF
    -- 0x08E2FF              11111111
    --
    -- 0x090000   00001001 - Video/Attribute RAM. 64K Window.
    -- 0x09D000              11010000 00000000 - Video RAM
    -- 0x09D7FF              11010111 11111111
    -- 0x09D800              11011000 00000000 - Attribute RAM
    -- 0x09DFFF              11011111 11111111
    --
    -- 0x0A0000   00001010 - Character Generator RAM
    -- 0x0A0000              00000000 00000000 - CGROM
    -- 0x0A0FFF              00001111 11111111 
    -- 0x0A1000              00010000 00000000 - CGRAM
    -- 0x0A1FFF              00011111 11111111
    --
    -- 0x0C0000   00001100 - Red framebuffer.
    --                       00000000 00000000 - Red pixel addressed framebuffer. Also MZ-80B GRAM I memory in lower 8K
    -- 0x0C3FFF              00111111 11111111
    -- 0x0D0000   00001101 - Blue framebuffer.
    --                       00000000 00000000 - Blue pixel addressed framebuffer. Also MZ-80B GRAM II memory in lower 8K
    -- 0x0D3FFF              00111111 11111111
    -- 0x0E0000   00001110 - Green framebuffer.
    --                       00000000 00000000 - Green pixel addressed framebuffer.
    -- 0x0E3FFF              00111111 11111111
    CS_VIDEO_LEGACYn      <= '0'                                             when VIDEO_ADDRi(23 downto 16) = "00000000"
                             else '1';
    CS_VIDEO_IO_DIRECTn   <= '0'                                             when VIDEO_ADDRi(23 downto 16) = "00001000"
                             else '1';
    CS_VIDEO_VRAM_DIRECTn <= '0'                                             when VIDEO_ADDRi(23 downto 16) = "00001001"
                             else '1';
    CS_VIDEO_CG_DIRECTn   <= '0'                                             when VIDEO_ADDRi(23 downto 16) = "00001010"
                             else '1';
    CS_VIDEO_R_FB_DIRECTn <= '0'                                             when VIDEO_ADDRi(23 downto 16) = "00001100"
                             else '1';
    CS_VIDEO_B_FB_DIRECTn <= '0'                                             when VIDEO_ADDRi(23 downto 16) = "00001101"
                             else '1';
    CS_VIDEO_G_FB_DIRECTn <= '0'                                             when VIDEO_ADDRi(23 downto 16) = "00001110"
                             else '1';

    -- CPU / RAM signals and selects.
    --
    Z80_MA                <= "00" & VIDEO_ADDRi(9 downto 0)                   when MODE_VIDEO_MZ80K = '1'  or MODE_VIDEO_MZ80C = '1'
                             else
                             VIDEO_ADDRi(11 downto 0);
    CS_DXXXn              <= '0'                                             when VIDEO_IORQni = '1' and VIDEO_ADDRi(15 downto 12) = "1101"
                             else '1';
                             -- Standard access to memory mapped I/O.
    CS_EXXXn              <= '0'                                             when VIDEO_IORQni = '1' and VIDEO_ADDRi(15 downto 11) = "11100" and (CS_VIDEO_IO_DIRECTn = '0' or (CS_VIDEO_LEGACYn = '0' and GRAM_PAGE_ENABLE = '0' and (MODE_VIDEO_MZ80B = '0' or (MODE_VIDEO_MZ80B = '1' and GRAM_MZ80B_ENABLE = '0')))) -- Normal memory mapped I/O if Graphics Option not enabled.
                             else '1';
                             -- MZ80B Graphics RAM enabled, range E000:FFFF is mapped to graphics RAMI + II and D000:DFFF to standard video.
    CS_GRAMn              <= '0'                                             when VIDEO_IORQni = '1' and unsigned(VIDEO_ADDRi(15 downto 0)) >= X"D000" and unsigned(VIDEO_ADDRi(15 downto 0)) <= X"FFFF" and GRAM_PAGE_ENABLE = '0'  and MODE_VIDEO_MZ80B = '1' and MZ80B_VRAM_HI_ADDR = '1' 
                             else
                             -- MZ80B Graphics RAM enabled, range 6000:7FFF is mapped to graphics RAMI + II and 5000:5FFF to standard video.
                             '0'                                             when VIDEO_IORQni = '1' and unsigned(VIDEO_ADDRi(15 downto 0)) >= X"5000" and unsigned(VIDEO_ADDRi(15 downto 0)) <= X"7FFF" and GRAM_PAGE_ENABLE = '0'  and MODE_VIDEO_MZ80B = '1' and MZ80B_VRAM_LO_ADDR = '1'
                             else '1';
                             -- Graphics RAM enabled, range C000:FFFF is mapped to graphics RAM.
    CS_FBRAMn             <= '1'                                             when VIDEO_IORQni = '1' and VIDEO_ADDRi(15 downto 14) = "11"  and GRAM_PAGE_ENABLE = '1'
                             else '1';
    CS_IO_DXXn            <= '0'                                             when (VIDEO_IORQni = '0' or (CS_VIDEO_IO_DIRECTn = '0' and VIDEO_ADDRi(15 downto 8) = "00000000")) and VIDEO_ADDRi(7 downto 4) = "1101"
                             else '1';
    CS_IO_EXXn            <= '0'                                             when (VIDEO_IORQni = '0' or (CS_VIDEO_IO_DIRECTn = '0' and VIDEO_ADDRi(15 downto 8) = "00000000")) and VIDEO_ADDRi(7 downto 4) = "1110"
                             else '1';
    CS_IO_FXXn            <= '0'                                             when (VIDEO_IORQni = '0' or CS_VIDEO_IO_DIRECTn = '0' ) and VIDEO_ADDRi(7 downto 4) = "1111"
                             else '1';

    -- Program Character Generator RAM. E010 - Write cycle (Read cycle = reset memory swap).
    CS_PCGn               <= '0'                                             when CS_EXXXn = '0'    and VIDEO_ADDRi(10 downto 4) = "0000001"
                             else '1';                                                                   -- E010 -> E01f
    -- Invert display register. E014/E015
    CS_INVERTn            <= '0'                                             when CS_EXXXn = '0'    and Z80_MA(11 downto 2) = "0000000101"
                             else '1';
    -- Scroll display register. E200 - E2FF
    CS_SCROLLn            <= '0'                                             when CS_EXXXn = '0'    and VIDEO_ADDRi(10 downto 8)="010"
                             else '1';
    -- MZ80B/MZ2000 Graphics Options Register select. F4-F7
    CS_GRAM_OPTn          <= '0'                                             when CS_IO_FXXn = '0'  and VIDEO_ADDRi(3 downto 2) = "01"
                             else '1';
    -- MZ80B/MZ2000 I/O Registers E0-EB,
    CS_80B_PPIn           <= '0'                                             when CS_IO_EXXn = '0'  and VIDEO_ADDRi(3 downto 2) = "00" and MODE_VIDEO_MZ80B = '1'
                             else '1';
    CS_80B_PITn           <= '0'                                             when CS_IO_EXXn = '0'  and VIDEO_ADDRi(3 downto 2) = "01" and MODE_VIDEO_MZ80B = '1'
                             else '1';
    CS_80B_PIOn           <= '0'                                             when CS_IO_EXXn = '0'  and VIDEO_ADDRi(3 downto 2) = "10" and MODE_VIDEO_MZ80B = '1'
                             else '1';

    -- 0xF3 set the VGA border colour. The VGA modes have areas not used by the graphics output, this register allows this area to be set to a specific colour (when colour mode enabled).
    --                       Bits [2:0] define the border colour, 2 = R, 1 = G, 0 = B
    CS_FB_BORDERn         <= '0'                                             when CS_IO_FXXn = '0'  and VIDEO_ADDRi(3 downto 0) = "0011"
                             else '1';

    -- 0xF4 set the MZ80B video in/out mode.
    -- Output data | V-RAM GRPH I | V-RAM GRPH II
    -- to port $F4 | Input Output | Input Output
    -- 00              0     X        X     X
    -- 01              X     X        0     X
    -- 02              0     0        X     X
    -- 03              X     0        0     X
    -- oc              0     X        X     O
    -- OD              X     X        0     O
    -- OE              0     0        X     O
    -- OF              X     0        0     O
    -- Note Input  0: V-RAM transfer enabled
    --             X: V-RAM transfer disabled
    --      Output 0: shown on CRT display
    --             X: not shown on CRT display
    CS_80B_VMODEn         <= '0'                                             when CS_IO_FXXn = '0'  and VIDEO_ADDRi(3 downto 0) = "0100"
                             else '1';

    -- 0xF5 sets the palette. The Video Module supports 4 bit per colour output but there is only enough RAM for 1 bit per colour so the pallette is used to change the colours output.
    --                       Bits [7:0] defines the pallete number. This indexes a lookup table which contains the required 4bit output per 1bit input.
    CS_FB_PALETTEn        <= '0'                                             when CS_IO_FXXn = '0'  and VIDEO_ADDRi(3 downto 0) = "0101"
                             else '1';
    -- 0xF6 set parameters. Store parameters in a long word to be used by the graphics command processor.
    -- The parameter word is 128 bit and each write to the parameter word shifts left by 8 bits and adds the new byte at bits 7:0.
    CS_FB_PARAMSn         <= '0'                                             when CS_IO_FXXn = '0'  and VIDEO_ADDRi(3 downto 0) = "0110"
                             else '1';
    -- 0xF7 set the graphics processor unit commands.
    --                       Bits [5:0] - 0 = Reset parameters.
    --                                    1 = Clear to val. Start Location (16 bit), End Location (16 bit), Red Filter, Green Filter, Blue Filter
    CS_FB_GPUn            <= '0'                                             when CS_IO_FXXn = '0'  and VIDEO_ADDRi(3 downto 0) = "0111"
                             else '1';
    -- 0xF8 set the video mode. 
    --                       Bits [2:0] define the Video Module machine compatibility. 000 = MZ80K, 001 = MZ80C, 010 = MZ1200, 011 = MZ80A, 100 = MZ-700, 101 = MZ-800, 110 = MZ-80B, 111 = MZ2000,
    --                       Bit    [3] defines the 40/80 column mode, 0 = 40 col, 1 = 80 col.
    --                       Bit    [4] defines the colour mode, 0 = mono, 1 = colour - ignored on certain modes.
    --                       Bit    [5] defines wether PCGRAM is enabled, 0 = disabled, 1 = enabled.
    --                       Bits [7:6] define the VGA mode.
    CS_FB_VMn             <= '0'                                             when CS_IO_FXXn = '0'  and VIDEO_ADDRi(3 downto 0) = "1000"
                             else '1';
    -- 0xF9 set the graphics mode. 7/6 = Operator (00=OR,01=AND,10=NAND,11=XOR),
    --                               5 = GRAM Output Enable (=0), 4 = VRAM Output Enable (=0),
    --                             3/2 = Write mode (00=Page 1:Red, 01=Page 2:Green, 10=Page 3:Blue, 11=Indirect),
    --                             1/0 = Read mode (00=Page 1:Red, 01=Page2:Green, 10=Page 3:Blue, 11=Not used).
    CS_FB_CTLn            <= '0'                                             when CS_IO_FXXn = '0'  and VIDEO_ADDRi(3 downto 0) = "1001"
                             else '1';
    -- 0xFA set the Red bit mask (1 bit = 1 pixel, 8 pixels per byte).
    CS_FB_REDn            <= '0'                                             when CS_IO_FXXn = '0'  and VIDEO_ADDRi(3 downto 0) = "1010"
                             else '1';
    -- 0xFB set the Green bit mask (1 bit = 1 pixel, 8 pixels per byte).
    CS_FB_GREENn          <= '0'                                             when CS_IO_FXXn = '0'  and VIDEO_ADDRi(3 downto 0) = "1011"
                             else '1';
    -- 0xFC set the Blue bit mask (1 bit = 1 pixel, 8 pixels per byte).
    CS_FB_BLUEn           <= '0'                                             when CS_IO_FXXn = '0'  and VIDEO_ADDRi(3 downto 0) = "1100"
                             else '1';
    -- 0xFD set the Video memory page in block C000:FFFF bit 0, set the CGROM upload access in bit 7.
    CS_FB_PAGEn           <= '0'                                             when CS_IO_FXXn = '0'  and VIDEO_ADDRi(3 downto 0) = "1101"
                             else '1';

    -- Wait state generation, when the GRAM Frame Buffer is being written to and the CPU is attempting to write, pause the CPU.
    VWAITn_V_CSYNC        <= 'Z'                                             when MB_VIDEO_ENABLEn = '0'
                             else
                             '0'                                             when MB_VIDEO_ENABLEn = '1' and  V_BLANKi = '1' and CS_FBRAMn = '0'
                             else
                             '1'                                             when MB_VIDEO_ENABLEn = '1' and (V_BLANKi = '0' or  CS_FBRAMn = '1')
                             else '1';

    -- VRAM mux between the CPU signals and the GPU. GPU takes priority.
    --
    VRAM_ADDR             <= VRAM_GPU_ADDR(11 downto 0)                      when VRAM_GPU_ENABLE = '1'
                             else
                             VIDEO_ADDRi(11 downto 0);
    VRAM_DI               <= X"000000" & VRAM_GPU_DI                         when VRAM_GPU_ENABLE = '1'
                             else
                             VIDEO_DATA_INi;
    VRAM_WEN              <= '1'                                             when VRAM_GPU_WEN = '1'
                             else
                             '1'                                             when VIDEO_WRni = '0'        and CS_DXXXn = '0' and ((CS_VIDEO_LEGACYn = '0' and CGROM_PAGE = '0' and GRAM_PAGE_ENABLE = '0') or (CS_VIDEO_VRAM_DIRECTn = '0'))
                             else '0';
    VRAM_WEN_BYTE         <= '1'                                             when VIDEO_WRni = '1'
                             else
                             VIDEO_WR_BYTEi;
    VRAM_WEN_HWORD        <= '0'                                             when VIDEO_WRni = '1'
                             else
                             VIDEO_WR_HWORDi;
    
    -- CGROM Data to CG RAM, either ROM -> RAM copy or Z80 provides map.
    --
    CGRAM_DI              <= X"000000" & CGROM_BIT_DO                        when CGRAM_SEL = '1'               -- Data from ROM
                             else
                             X"000000" & PCG_DATA                            when CGRAM_SEL = '0'               -- Data from PCG
                             else (others=>'0');
    CGRAM_WREN            <= not (CGRAM_WEn or CS_PCGn) and not VIDEO_WRni; 
    CGRAM_WEN_BYTE        <= '1'                                             when VIDEO_WRni = '1'
                             else
                             VIDEO_WR_BYTEi;
    CGRAM_WEN_HWORD       <= '0'                                             when VIDEO_WRni = '1'
                             else
                             VIDEO_WR_HWORDi;
    
    --
    -- Font select
    --
    CGROM_DATA            <= CGROM_BIT_DO                                    when PCGRAM='0'
                             else
                             CGRAM_BIT_DO                                    when PCGRAM='0'             and CGRAM_SEL = '1'
                             else
                             PCG_DATA                                        when CS_PCGn='0'            and VIDEO_ADDRi(1 downto 0)="10" and VIDEO_WRni='0'
                             else
                             CGRAM_DO(7 downto 0)                            when PCGRAM='1'
                             else (others => '1');
    CG_ADDR               <= CGRAM_ADDR(11 downto 0)                         when CGRAM_WEn = '0'
                             else XFER_CGROM_ADDR;
    CGROM_WEN             <= '1'                                             when VIDEO_WRni = '0'        and CS_DXXXn = '0' and ((CS_VIDEO_LEGACYn = '0' and CGROM_PAGE = '1' and GRAM_PAGE_ENABLE = '0') or (CS_VIDEO_CG_DIRECTn = '0'))
                             else '0';
    CGROM_WEN_BYTE        <= '1'                                             when VIDEO_WRni = '1'
                             else
                             VIDEO_WR_BYTEi;
    CGROM_WEN_HWORD       <= '0'                                             when VIDEO_WRni = '1'
                             else
                             VIDEO_WR_HWORDi;
    
    
    -- As the Graphics RAM is an odd size, 16384 x 3 colour planes, it has to be in 3 seperate 16K blocks to avoid wasting memory (or having it synthesized away),
    -- thus there are 3 sets of signals, 1 per colour.
    --
    GRAM_ADDR             <= GRAM_GPU_ADDR(14 downto 0)                      when GRAM_GPU_ENABLE = '1'
                             else
                             VIDEO_ADDRi(14 downto 0);
                            -- direct writes when accessing individual pages.
    GRAM_DI_R             <= X"000000" & GRAM_GPU_DI_R                       when GRAM_GPU_ENABLE = '1'
                             else
                             X"000000" & VIDEO_DATA_INi(7 downto 0)           when GRAM_MODE_REG(3 downto 2) = "00"
                             else
                             X"000000" & (VIDEO_DATA_INi(7 downto 0) and GRAM_R_FILTER)  when GRAM_MODE_REG(3 downto 2) = "11"
                             else
                             VIDEO_DATA_INi                                   when CS_VIDEO_R_FB_DIRECTn = '0'
                             else
                             (others=>'0');
                            -- direct writes when accessing individual pages.
    GRAM_DI_B             <= X"000000" & GRAM_GPU_DI_B                       when GRAM_GPU_ENABLE = '1'
                             else
                             X"000000" & VIDEO_DATA_INi(7 downto 0)           when GRAM_MODE_REG(3 downto 2) = "10"
                             else
                             X"000000" & (VIDEO_DATA_INi(7 downto 0) and GRAM_B_FILTER)  when GRAM_MODE_REG(3 downto 2) = "11"
                             else
                             VIDEO_DATA_INi                                   when CS_VIDEO_B_FB_DIRECTn = '0'
                             else
                             (others=>'0');
                            -- direct writes when accessing individual pages.
    GRAM_DI_G             <= X"000000" & GRAM_GPU_DI_G                       when GRAM_GPU_ENABLE = '1'
                             else
                             X"000000" & VIDEO_DATA_INi(7 downto 0)           when GRAM_MODE_REG(3 downto 2) = "01"
                             else
                             X"000000" & (VIDEO_DATA_INi(7 downto 0) and GRAM_G_FILTER)  when GRAM_MODE_REG(3 downto 2) = "11"
                             else
                             VIDEO_DATA_INi                                   when CS_VIDEO_G_FB_DIRECTn = '0'
                             else
                             (others=>'0');
                            -- For this implementation, a seperate Graphics RAM isnt implemented due to lack of memory, the Graphics RAM is shared
                            -- by the MZ80B GRAM and the individual colour framebuffer.
    GRAM_DO_R             <= GRAM_DO_GI;
    GRAM_DO_B             <= GRAM_DO_GII;
    GRAM_DO_G             <= GRAM_DO_GIII;
    GWEN_R                <= '1'                                             when GWEN_GPU_R = '1'
                             else
                             '1'                                             when VIDEO_WRni = '0' and ((CS_FBRAMn = '0'  and (GRAM_MODE_REG(3 downto 2) = "00" or GRAM_MODE_REG(3 downto 2) = "11")) or CS_VIDEO_R_FB_DIRECTn <= '0')
                             else
                             '0';
    GWEN_B                <= '1'                                             when GWEN_GPU_B = '1'
                             else
                             '1'                                             when VIDEO_WRni='0'   and ((CS_FBRAMn = '0'  and (GRAM_MODE_REG(3 downto 2) = "10" or GRAM_MODE_REG(3 downto 2) = "11")) or CS_VIDEO_B_FB_DIRECTn <= '0')
                             else
                             '0';
    GWEN_G                <= '1'                                             when GWEN_GPU_G = '1'
                             else
                             '1'                                             when VIDEO_WRni='0'   and ((CS_FBRAMn = '0'  and (GRAM_MODE_REG(3 downto 2) = "01" or GRAM_MODE_REG(3 downto 2) = "11")) or CS_VIDEO_G_FB_DIRECTn <= '0')
                             else
                             '0';
    GRAM_WEN_BYTE         <= '1'                                             when VIDEO_WRni = '1'
                             else
                             VIDEO_WR_BYTEi;
    GRAM_WEN_HWORD        <= '0'                                             when VIDEO_WRni = '1'
                             else
                             VIDEO_WR_HWORDi;
    
    -- MZ80B/MZ2000 Graphics Option RAM.
    --
    GWEN_GI               <= '1'                                             when VIDEO_WRni = '0' and CS_GRAMn = '0' and GRAM_OPT_WRITE = '0'
                             else
                             '0';
    GWEN_GII              <= '1'                                             when VIDEO_WRni='0'   and CS_GRAMn = '0' and GRAM_OPT_WRITE = '1'
                             else
                             '0';

    -- Write signals to the frame buffer memory are based on direct writes and writes to the MZ80B GRAM I/II which basically is the same memory, enabled differently.
    GRAM_WEN_GI           <= GWEN_GI or GWEN_R;
    GRAM_WEN_GII          <= GWEN_GII or GWEN_B;
    GRAM_WEN_GIII         <= GWEN_G;
    
    -- Work out the current video mode, which is used to look up the parameters for frame generation.
    --
    -- 0  MZ80K/C/1200/A machines have a monochrome 60Hz display with scan of 512 x 260 for a 320x200 viewable area.
    -- 1  MZ80K/C/1200/A machines with an adapted monochrome 60Hz display with scan of 1024 x 260 for a 640x200 viewable area.			
    -- 2  MZ80K/C/1200/A machines with MZ700 style colour @ 60Hz display with scan of 512 x 260 for a 320x200 viewable area.			
    -- 3  MZ80K/C/1200/A machines with MZ700 style colour @ 60Hz display with scan of 1024 x 260 for a 640x200 viewable area.			
    -- 4  Mode 0 upscaled as 640x480  @ 60Hz timings for 40Char mode monochrome. 			
    -- 5  Mode 1 upscaled as 640x480  @ 60Hz timings for 80Char mode monochrome.
    -- 6  Mode 2 upscaled as 640x480  @ 60Hz timings for 40Char mode colour. 			
    -- 7  Mode 3 upscaled as 640x480  @ 60Hz timings for 80Char mode colour.
    -- 8  Mode 0 upscaled as 640x480  @ 72Hz timings for 40Char mode monochrome. 			
    -- 9  Mode 1 upscaled as 640x480  @ 72Hz timings for 80Char mode monochrome.
    -- 10 Mode 2 upscaled as 640x480  @ 72Hz timings for 40Char mode colour. 			
    -- 11 Mode 3 upscaled as 640x480  @ 72Hz timings for 80Char mode colour.
    --
    VIDEOMODE_NEXT        <= 0                                               when VIDEO_DEBUG = '1'
                             else
                             0                                               when VGAMODE = "00" and (MODE_VIDEO_MZ80A = '1' or MODE_VIDEO_MZ80K = '1' or MODE_VIDEO_MZ80C = '1' or MODE_VIDEO_MZ1200 = '1' or MODE_VIDEO_MZ80B = '1')                           and MODE_VIDEO_MONO   = '1'
                             else
                             1                                               when VGAMODE = "00" and (MODE_VIDEO_MZ80A = '1' or MODE_VIDEO_MZ80K = '1' or MODE_VIDEO_MZ80C = '1' or MODE_VIDEO_MZ1200 = '1' or MODE_VIDEO_MZ80B = '1')                           and MODE_VIDEO_MONO80 = '1'
                             else
                             2                                               when VGAMODE = "00" and (MODE_VIDEO_MZ80A = '1' or MODE_VIDEO_MZ80K = '1' or MODE_VIDEO_MZ80C = '1' or MODE_VIDEO_MZ1200 = '1' or MODE_VIDEO_MZ700 = '1' or MODE_VIDEO_MZ800 = '1') and MODE_VIDEO_COLOUR   = '1'
                             else
                             3                                               when VGAMODE = "00" and (MODE_VIDEO_MZ80A = '1' or MODE_VIDEO_MZ80K = '1' or MODE_VIDEO_MZ80C = '1' or MODE_VIDEO_MZ1200 = '1' or MODE_VIDEO_MZ700 = '1' or MODE_VIDEO_MZ800 = '1') and MODE_VIDEO_COLOUR80 = '1' 
                             else
                             4                                               when VGAMODE = "01" and (MODE_VIDEO_MZ80A = '1' or MODE_VIDEO_MZ80K = '1' or MODE_VIDEO_MZ80C = '1' or MODE_VIDEO_MZ1200 = '1' or MODE_VIDEO_MZ80B = '1')                           and MODE_VIDEO_MONO   = '1'
                             else
                             5                                               when VGAMODE = "01" and (MODE_VIDEO_MZ80A = '1' or MODE_VIDEO_MZ80K = '1' or MODE_VIDEO_MZ80C = '1' or MODE_VIDEO_MZ1200 = '1' or MODE_VIDEO_MZ80B = '1')                           and MODE_VIDEO_MONO80 = '1'
                             else
                             6                                               when VGAMODE = "01" and (MODE_VIDEO_MZ80A = '1' or MODE_VIDEO_MZ80K = '1' or MODE_VIDEO_MZ80C = '1' or MODE_VIDEO_MZ1200 = '1' or MODE_VIDEO_MZ700 = '1' or MODE_VIDEO_MZ800 = '1') and MODE_VIDEO_COLOUR   = '1'
                             else
                             7                                               when VGAMODE = "01" and (MODE_VIDEO_MZ80A = '1' or MODE_VIDEO_MZ80K = '1' or MODE_VIDEO_MZ80C = '1' or MODE_VIDEO_MZ1200 = '1' or MODE_VIDEO_MZ700 = '1' or MODE_VIDEO_MZ800 = '1') and MODE_VIDEO_COLOUR80 = '1' 
                             else
                             8                                               when VGAMODE = "10" and (MODE_VIDEO_MZ80A = '1' or MODE_VIDEO_MZ80K = '1' or MODE_VIDEO_MZ80C = '1' or MODE_VIDEO_MZ1200 = '1' or MODE_VIDEO_MZ80B = '1')                           and MODE_VIDEO_MONO   = '1'
                             else
                             9                                               when VGAMODE = "10" and (MODE_VIDEO_MZ80A = '1' or MODE_VIDEO_MZ80K = '1' or MODE_VIDEO_MZ80C = '1' or MODE_VIDEO_MZ1200 = '1' or MODE_VIDEO_MZ80B = '1')                           and MODE_VIDEO_MONO80 = '1'
                             else
                             10                                              when VGAMODE = "10" and (MODE_VIDEO_MZ80A = '1' or MODE_VIDEO_MZ80K = '1' or MODE_VIDEO_MZ80C = '1' or MODE_VIDEO_MZ1200 = '1' or MODE_VIDEO_MZ700 = '1' or MODE_VIDEO_MZ800 = '1') and MODE_VIDEO_COLOUR   = '1'
                             else
                             11                                              when VGAMODE = "10" and (MODE_VIDEO_MZ80A = '1' or MODE_VIDEO_MZ80K = '1' or MODE_VIDEO_MZ80C = '1' or MODE_VIDEO_MZ1200 = '1' or MODE_VIDEO_MZ700 = '1' or MODE_VIDEO_MZ800 = '1') and MODE_VIDEO_COLOUR80 = '1' 
                             else
                             12                                              when VGAMODE = "11" and (MODE_VIDEO_MZ80A = '1' or MODE_VIDEO_MZ80K = '1' or MODE_VIDEO_MZ80C = '1' or MODE_VIDEO_MZ1200 = '1' or MODE_VIDEO_MZ80B = '1')                           and MODE_VIDEO_MONO   = '1'
                             else
                             13                                              when VGAMODE = "11" and (MODE_VIDEO_MZ80A = '1' or MODE_VIDEO_MZ80K = '1' or MODE_VIDEO_MZ80C = '1' or MODE_VIDEO_MZ1200 = '1' or MODE_VIDEO_MZ80B = '1')                           and MODE_VIDEO_MONO80 = '1'
                             else
                             14                                              when VGAMODE = "11" and (MODE_VIDEO_MZ80A = '1' or MODE_VIDEO_MZ80K = '1' or MODE_VIDEO_MZ80C = '1' or MODE_VIDEO_MZ1200 = '1' or MODE_VIDEO_MZ700 = '1' or MODE_VIDEO_MZ800 = '1') and MODE_VIDEO_COLOUR   = '1'
                             else
                             15                                              when VGAMODE = "11" and (MODE_VIDEO_MZ80A = '1' or MODE_VIDEO_MZ80K = '1' or MODE_VIDEO_MZ80C = '1' or MODE_VIDEO_MZ1200 = '1' or MODE_VIDEO_MZ700 = '1' or MODE_VIDEO_MZ800 = '1') and MODE_VIDEO_COLOUR80 = '1' 
                             else
                             0;

    -- Select the video clock based on the video mode. The video mode selects an active clock when the old and previous clocks go to the high level.
    --
    --
    VID_CLK               <= (VIDCLK_8MHZ or VIDCLK_8MHZ_Q)             and
                             (VIDCLK_8_86719MHZ or VIDCLK_8_86719MHZ_Q) and
                             (VIDCLK_16MHZ or VIDCLK_16MHZ_Q)           and
                             (VIDCLK_17_7344MHZ or VIDCLK_17_7344MHZ_Q) and
                             (VIDCLK_25_175MHZ or VIDCLK_25_175MHZ_Q)   and
                             (VIDCLK_65MHZ or VIDCLK_65MHZ_Q)           and
                             (VIDCLK_40MHZ or VIDCLK_40MHZ_Q);



--    -- Process to output signals on clock edges, to clean them up as needed.
--    --
--    process(VID_CLK)
--    begin
--        if rising_edge(VID_CLK) then
--            if MB_VIDEO_ENABLEn = '1' then
--
--                if H_POLARITY(0) = '0' then
--                    HSYNC_OUTn            <= H_SYNCni;
--                else
--                    HSYNC_OUTn            <= not H_SYNCni;
--                end if;
--
--                if V_POLARITY(0) = '0' then
--                    VSYNC_OUTn            <= V_SYNCni;
--                else
--                    VSYNC_OUTn            <= not V_SYNCni;
--                end if;
--
--            elsif MB_VIDEO_ENABLEn = '0' then
--                HSYNC_OUTn            <= V_HSYNCn;                                                   -- Horizontal sync (negative) from mainboard.
--                VSYNC_OUTn            <= V_VSYNCn;                                                   -- Vertical sync (negative) from mainboard.
--            end if;
--        end if;
--    end process;

    HSYNC_OUTn            <= V_HSYNCn                                        when MB_VIDEO_ENABLEn = '0'
                             else
                             H_SYNCni                                        when MB_VIDEO_ENABLEn = '1' and H_POLARITY(0) = '0'
                             else
                             not H_SYNCni;                                                                                              -- Horizontal sync (negative) from mainboard.
    VSYNC_OUTn            <= V_VSYNCn                                        when MB_VIDEO_ENABLEn = '0'
                             else
                             V_SYNCni                                        when MB_VIDEO_ENABLEn = '1' and V_POLARITY(0) = '0'
                             else
                             not V_SYNCni;                                                                                              -- Vertical sync (negative) from mainboard.

    -- Set CPLD mode flag according to value given in config 2:0 
    MODE_CPLD_MZ80K       <= '1'                                             when to_integer(unsigned(VIDEO_MODE(2 downto 0))) = MODE_MZ80K
                             else '0';
    MODE_CPLD_MZ80C       <= '1'                                             when to_integer(unsigned(VIDEO_MODE(2 downto 0))) = MODE_MZ80C
                             else '0';
    MODE_CPLD_MZ1200      <= '1'                                             when to_integer(unsigned(VIDEO_MODE(2 downto 0))) = MODE_MZ1200
                             else '0';
    MODE_CPLD_MZ80A       <= '1'                                             when to_integer(unsigned(VIDEO_MODE(2 downto 0))) = MODE_MZ80A
                             else '0';
    MODE_CPLD_MZ700       <= '1'                                             when to_integer(unsigned(VIDEO_MODE(2 downto 0))) = MODE_MZ700
                             else '0';
    MODE_CPLD_MZ800       <= '1'                                             when to_integer(unsigned(VIDEO_MODE(2 downto 0))) = MODE_MZ800
                             else '0';
    MODE_CPLD_MZ80B       <= '1'                                             when to_integer(unsigned(VIDEO_MODE(2 downto 0))) = MODE_MZ80B
                             else '0';
    MODE_CPLD_MZ2000      <= '1'                                             when to_integer(unsigned(VIDEO_MODE(2 downto 0))) = MODE_MZ2000
                             else '0';

    VGA_R(3 downto 0)     <= FB_PALETTE_R(3 downto 0)                        when MB_VIDEO_ENABLEn = '1' and H_BLANKi='0' and V_BLANKi = '0' and ((DISPLAY_VGATE = '0' and MODE_VIDEO_MZ80B = '1') or MODE_VIDEO_MZ80B = '0')
                             else
                             (others => V_R)                                 when MB_VIDEO_ENABLEn = '0'
                             else (others => '0');
    VGA_G(3 downto 0)     <= FB_PALETTE_G(3 downto 0)                        when MB_VIDEO_ENABLEn = '1' and H_BLANKi='0' and V_BLANKi = '0' and ((DISPLAY_VGATE = '0' and MODE_VIDEO_MZ80B = '1') or MODE_VIDEO_MZ80B = '0')
                             else
                             (others => V_G)                                 when MB_VIDEO_ENABLEn = '0'
                             else (others => '0');
    VGA_B(3 downto 0)     <= FB_PALETTE_B(3 downto 0)                        when MB_VIDEO_ENABLEn = '1' and H_BLANKi='0' and V_BLANKi = '0' and ((DISPLAY_VGATE = '0' and MODE_VIDEO_MZ80B = '1') or MODE_VIDEO_MZ80B = '0')
                             else
                             (others => V_B)                                 when MB_VIDEO_ENABLEn = '0'
                             else (others => '0');
    VGA_R_COMPOSITE       <= '1'                                             when MB_VIDEO_ENABLEn = '0' and V_R = '1'
                             else
                             FB_PALETTE_R(4)                                 when MB_VIDEO_ENABLEn = '1' and H_BLANKi='0' and V_BLANKi = '0' and (MODE_VIDEO_MONO = '1'   or MODE_VIDEO_MONO80 = '1')
                             else
                             '1'                                             when MB_VIDEO_ENABLEn = '1' and H_BLANKi='0' and V_BLANKi = '0' and (MODE_VIDEO_COLOUR = '1' or MODE_VIDEO_COLOUR80 = '1') and SR_R_DATA(7) = '1' and PALETTE_REG = X"00"
                             else
                             '0'                                             when MB_VIDEO_ENABLEn = '1' and H_BLANKi='0' and V_BLANKi = '0' and (MODE_VIDEO_COLOUR = '1' or MODE_VIDEO_COLOUR80 = '1') and FB_PALETTE_R(4) = '0'
                             else 'Z';
    VGA_G_COMPOSITE       <= '1'                                             when MB_VIDEO_ENABLEn = '0' and V_G = '1'
                             else
                             FB_PALETTE_G(4)                                 when MB_VIDEO_ENABLEn = '1' and H_BLANKi='0' and V_BLANKi = '0' and (MODE_VIDEO_MONO = '1'   or MODE_VIDEO_MONO80 = '1')
                             else
                             '1'                                             when MB_VIDEO_ENABLEn = '1' and H_BLANKi='0' and V_BLANKi = '0' and (MODE_VIDEO_COLOUR = '1' or MODE_VIDEO_COLOUR80 = '1') and SR_G_DATA(7) = '1' and PALETTE_REG = X"00"
                             else
                             '0'                                             when MB_VIDEO_ENABLEn = '1' and H_BLANKi='0' and V_BLANKi = '0' and (MODE_VIDEO_COLOUR = '1' or MODE_VIDEO_COLOUR80 = '1') and FB_PALETTE_G(4) = '0'
                             else 'Z';
    VGA_B_COMPOSITE       <= '1'                                             when MB_VIDEO_ENABLEn = '0' and V_B = '1'
                             else
                             FB_PALETTE_B(4)                                 when MB_VIDEO_ENABLEn = '1' and H_BLANKi='0' and V_BLANKi = '0' and (MODE_VIDEO_MONO = '1'   or MODE_VIDEO_MONO80 = '1') 
                             else
                             '1'                                             when MB_VIDEO_ENABLEn = '1' and H_BLANKi='0' and V_BLANKi = '0' and (MODE_VIDEO_COLOUR = '1' or MODE_VIDEO_COLOUR80 = '1') and SR_B_DATA(7) = '1' and PALETTE_REG = X"00"
                             else
                             '0'                                             when MB_VIDEO_ENABLEn = '1' and H_BLANKi='0' and V_BLANKi = '0' and (MODE_VIDEO_COLOUR = '1' or MODE_VIDEO_COLOUR80 = '1') and FB_PALETTE_B(4) = '0'
                             else 'Z';

    -- Composite video signal output. Composite video is formed in external hardware by the combination of VGA R/G/B signals.
    CSYNC_OUTn            <= not VWAITn_V_CSYNC                              when MB_VIDEO_ENABLEn = '0'
                             else
                             not (H_SYNCni xor not V_SYNCni);
    CSYNC_OUT             <= VWAITn_V_CSYNC                                  when MB_VIDEO_ENABLEn = '0'
                             else
                             H_SYNCni xor not V_SYNCni;
    COLR_OUT              <= V_COLR                                          when MB_VIDEO_ENABLEn = '0'      -- Composite and RF base frequency from mainboard.
                             else
                             VIDCLK_17_7344MHZ                               when (VIDEOMODE = 2)
                             else
                             V_COLR;

end architecture rtl;
