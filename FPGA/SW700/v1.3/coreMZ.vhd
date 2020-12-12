---------------------------------------------------------------------------------------------------------
--
-- Name:            coreMZ.vhd
-- Created:         June 2020
-- Author(s):       Philip Smart
-- Description:     Sharp MZ Series FPGA core.
--                                                     
--                  This module provides a Sharp MZ series computer with Video and Soft CPU enhancements.
--                  Initially written for the Sharp MZ-700 on the SW700 v1.3 board and will be migrated
--                  to the pure FPGA tranZPUter v2.1 baord.
--
-- Credits:         
-- Copyright:       (c) 2018-20 Philip Smart <philip.smart@net2net.org>
--
-- History:         June 2020 - Initial creation.
--                  Oct 2020  - Split off from the Sharp MZ80A Video Module, the Video Module for the 
--                              Sharp MZ700 has the same roots but different control functionality. The
--                              MZ700 version resides within the tranZPUter memory and not the mainboard
--                              allowing for generally easier control. The MZ80A and MZ700 graphics logic
--                              should be pretty much identical.
--                  Nov 2020 -  Split off from v1.2 VideoController700 module. With the advent of v1.3
--                              with it's much larger FPGA, it is now possible to add Soft CPU's in
--                              addition to the Video Controller logic. This required a restructuring
--                              of the VHDL to seperate the Video from the Soft CPUs.
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
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     work.coreMZ_pkg.all;
--use work.zpu_pkg.all;
use     altera.altera_syn_attributes.all;

entity coreMZ is
    port (
        -- Primary and video clocks.
        CLOCK_50                  : in    std_logic;                                     -- 50MHz base clock for video timing and gate clocking.
        CTLCLK                    : in    std_logic;                                     -- tranZPUter external clock (for overclocking).
        SYSCLK                    : in    std_logic;                                     -- Mainboard system clock.
        VZ80_CLK                  : in    std_logic;                                     -- Z80 clock combining SYSCLK and CTLCLK.

        -- V[name] = Voltage translated signals which mirror the mainboard signals but at a lower voltage.
        -- Address Bus
        VZ80_ADDR                 : inout std_logic_vector(15 downto 0);                 -- Z80 Address bus.

        -- Data Bus
        VZ80_DATA                 : inout std_logic_vector(7 downto 0);                  -- Z80 Data bus.

        -- Control signals.
        VZ80_MREQn                : inout std_logic;                                     -- Z80 MREQ Out from Soft CPU.
        VZ80_IORQn                : inout std_logic;                                     -- Z80 IORQ In from Hard Z80/Out from Soft CPU.
        VZ80_RDn                  : inout std_logic;                                     -- Z80 RDn In from Hard Z80/Out from Soft CPU.
        VZ80_WRn                  : inout std_logic;                                     -- Z80 WRn In from Hard Z80/Out from Soft CPU.
        VZ80_M1n                  : inout std_logic;                                     -- Z80 M1 Out from Soft CPU.
        VZ80_BUSACKn              : out   std_logic;                                     -- Z80 BUSACK Out from Soft CPU.
        VIDEO_RDn                 : in    std_logic;                                     -- Decoded Video Controller Read from CPLD memory manager.
        VIDEO_WRn                 : in    std_logic;                                     -- Decoded Video Controller Write from CPLD memory manager.

        -- VGA & Composite output signals.
        VGA_R                     : out   std_logic_vector(3 downto 0);                  -- 16 level Red output.
        VGA_G                     : out   std_logic_vector(3 downto 0);                  -- 16 level Green output.
        VGA_B                     : out   std_logic_vector(3 downto 0);                  -- 16 level Blue output.
        VGA_R_COMPOSITE           : inout std_logic;                                     -- RGB Red override for composite output.
        VGA_G_COMPOSITE           : inout std_logic;                                     -- RGB Green override for composite output.
        VGA_B_COMPOSITE           : inout std_logic;                                     -- RGB Blue override for composite output.
        HSYNC_OUTn                : out   std_logic;                                     -- Horizontal sync.
        VSYNC_OUTn                : out   std_logic;                                     -- Vertical sync.
        COLR_OUT                  : out   std_logic;                                     -- Composite and RF base frequency.
        CSYNC_OUTn                : out   std_logic;                                     -- Composite sync (negative).
        CSYNC_OUT                 : out   std_logic;                                     -- Composite sync (positive).

        -- RGB & Composite input signals.
        VWAITn_V_CSYNC            : inout std_logic;                                     -- Wait signal to the CPU when accessing FPGA video RAM / Composite sync from mainboard.
        VZ80_RFSHn_V_HSYNCn       : inout std_logic;                                     -- Soft CPU RFSH out / Horizontal sync (negative) from mainboard.
        VZ80_HALTn_V_VSYNCn       : inout std_logic;                                     -- Soft CPU HALT out / Video memory selected / Vertical sync (negative) from mainboard.
        VZ80_NMIn_V_COLR          : in    std_logic;                                     -- Soft CPU NMIn in / Composite and RF base frequency from mainboard.
        VZ80_BUSRQn_V_G           : in    std_logic;                                     -- Soft CPU BUSRQn in / Digital Green (on/off) from mainboard.
        VZ80_WAITn_V_B            : in    std_logic;                                     -- Soft CPU WAITn in / Digital Blue (on/off) from mainboard.
        VZ80_INTn_V_R             : in    std_logic                                      -- Soft CPU INTn in / Digital Red (on/off) from mainboard.
    );
END entity;

architecture rtl of coreMZ is

    signal SYS_CLK                :       std_logic;
    signal VIDCLK_8MHZ            :       std_logic;
    signal VIDCLK_16MHZ           :       std_logic;
    signal VIDCLK_25_175MHZ       :       std_logic;
    signal VIDCLK_40MHZ           :       std_logic;
    signal VIDCLK_65MHZ           :       std_logic;
    signal VIDCLK_8_86719MHZ      :       std_logic;
    signal VIDCLK_17_7344MHZ      :       std_logic;
    signal PLL_LOCKED             :       std_logic;
    signal PLL_LOCKED2            :       std_logic;
    signal PLL_LOCKED3            :       std_logic;
    signal RESETn                 :       std_logic := '0';
    signal RESET_COUNTER          :       unsigned(3 downto 0) := (others => '1');
    signal MODE_CPLD_VIDEO_WAIT   :       std_logic;                                     -- FPGA video display period wait flag, 1 = enabled, 0 = disabled.
    signal CPU_CFG_DATA           :       std_logic_vector(7 downto 0):=(others => '0'); -- CPU Configuration register.
    signal CPU_INFO_DATA          :       std_logic_vector(7 downto 0);                  -- CPU configuration information register.
    signal CPLD_CFG_DATA          :       std_logic_vector(7 downto 0);                  -- CPLD configuration register.
    signal MODE_CPLD_SWITCH       :       std_logic := '1';                              -- Machine configuration (memory map, I/O etc) set in the CPLD. When this flag is set, the machine mode has changed. Flag is active for 1 clock cycle.
    signal MODE_CPU_CHANGED       :       std_logic;                                     -- Flag to indicate the CPU has been changed. 
    signal MODE_CPU_SOFT          :       std_logic;                                     -- Control signal to enable the Soft CPU and support logic.
    signal MODE_CPLD_MB_VIDEOn    :       std_logic := '0';                              -- Machine configuration (memory map, I/O etc) set in the CPLD. When this flag is set, the mainboard video logic is enabled, disabling or blending with the FPGA graphics.
    signal CS_IO_6XXn             :       std_logic;                                     -- Chip select for CPLD configuration registers.
    signal CS_CPU_CFGn            :       std_logic;                                     -- Select to set the CPU configuration register.
    signal CS_CPU_INFOn           :       std_logic;                                     -- Select to read the CPU information register.
    signal CS_CPLD_CFGn           :       std_logic;                                     -- Chip Select to write to the CPLD configuration register at 0x6E.

    -- T80
    --
    signal T80_MREQn              :       std_logic;
    signal T80_BUSRQn             :       std_logic;
    signal T80_IORQn              :       std_logic;
    signal T80_WRn                :       std_logic;
    signal T80_RDn                :       std_logic;
    signal T80_WAITn              :       std_logic;
    signal T80_M1n                :       std_logic;
    signal T80_RFSHn              :       std_logic;
    signal T80_ADDR               :       std_logic_vector(15 downto 0);
    signal T80_INTn               :       std_logic;
    signal T80_DATA_IN            :       std_logic_vector(7 downto 0);
    signal T80_DATA_OUT           :       std_logic_vector(7 downto 0);
    signal T80_BUSACKn            :       std_logic;
    signal T80_NMIn               :       std_logic;
    signal T80_HALTn              :       std_logic;

    -- ZPU 
    signal ZPU_MREQn              :       std_logic;
    signal ZPU_BUSRQn             :       std_logic;
    signal ZPU_IORQn              :       std_logic;
    signal ZPU_WRn                :       std_logic;
    signal ZPU_RDn                :       std_logic;
    signal ZPU_WAITn              :       std_logic;
    signal ZPU_M1n                :       std_logic;
    signal ZPU_RFSHn              :       std_logic;
    signal ZPU_VIDEO_WRn          :       std_logic;
    signal ZPU_VIDEO_RDn          :       std_logic;
    signal ZPU_ADDR               :       std_logic_vector(15 downto 0);
    signal ZPU_VIDEO_ADDR         :       std_logic_vector(2 downto 0);
    signal ZPU_INTn               :       std_logic;
    signal ZPU_DATA_IN            :       std_logic_vector(7 downto 0);
    signal ZPU_DATA_OUT           :       std_logic_vector(7 downto 0);
    signal ZPU_BUSACKn            :       std_logic;
    signal ZPU_NMIn               :       std_logic;
    signal ZPU_HALTn              :       std_logic;

    -- Internal core signals, muxed or demuxed physical connections.
    --
    signal CORE_MREQn             :       std_logic;                                     -- 
    signal CORE_IORQn             :       std_logic;                                     -- 
    signal CORE_RDn               :       std_logic;                                     -- 
    signal CORE_WRn               :       std_logic;                                     -- 
    signal CORE_M1n               :       std_logic;                                     -- 
    signal CORE_RFSHn             :       std_logic;                                     -- 
    signal CORE_HALTn             :       std_logic;                                     -- 
    signal CORE_RESETn            :       std_logic; 
    signal CORE_VIDEO_WRn         :       std_logic;                                     -- FPGA video write. Normally from the CPLD memory manager but overriden by soft CPU's such as the ZPU.
    signal CORE_VIDEO_RDn         :       std_logic;                                     -- FPGA video read. Normally from the CPLD memory manager but overriden by soft CPU's such as the ZPU.
    signal CORE_ADDR              :       std_logic_vector(15 downto 0);                 --
    signal CORE_VIDEO_ADDR        :       std_logic_vector(2 downto 0);                  --
    signal CORE_DATA_OUT          :       std_logic_vector(7 downto 0);                  --
    signal CORE_DATA_IN           :       std_logic_vector(7 downto 0);                  --
    signal CORE_V_HSYNCn          :       std_logic;                                     -- 
    signal CORE_V_VSYNCn          :       std_logic;                                     -- 
    signal CORE_V_COLR            :       std_logic;                                     -- 
    signal CORE_V_R               :       std_logic;                                     -- 
    signal CORE_V_G               :       std_logic;                                     -- 
    signal CORE_V_B               :       std_logic;                                     -- 

begin
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
         locked                  => PLL_LOCKED
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

    -- Add the Serial Flash Loader megafunction to enable in-situ programming of the EPCS16 configuration memory.
    --
    SFL : entity work.sfl_iv
    port map
    (
        noe_in                   => '0' 
    );

    -- Process to reset the FPGA based on the external RESET trigger, PLL's being locked
    -- and a counter to set minimum width.
    --
    FPGARESET: process(CLOCK_50, PLL_LOCKED, PLL_LOCKED2, PLL_LOCKED3)
    begin
       if PLL_LOCKED = '0' or PLL_LOCKED2 = '0' or PLL_LOCKED3 = '0' then
            RESET_COUNTER         <= (others => '1');
            RESETn                <= '0';

       elsif PLL_LOCKED = '1' and PLL_LOCKED2 = '1' and PLL_LOCKED3 = '1' then
            if rising_edge(CLOCK_50) then
                if RESET_COUNTER /= 0 then
                    RESET_COUNTER <= RESET_COUNTER - 1;
                elsif VIDEO_WRn = '0' and VIDEO_RDn = '0' then
                    RESETn        <= '0';
                elsif VIDEO_WRn = '1' or VIDEO_RDn = '1' then
                    RESETn        <= '1';
                end if;
            end if;
        end if;
    end process;

    ------------------------------------------------------------------------------------
    -- Video Controller
    ------------------------------------------------------------------------------------    

    vcCoreVideo : entity work.VideoController
    --generic map
    --(
    --)
    port map
    (    
        -- Primary and video clocks.
        SYS_CLK                  => SYS_CLK,                                             -- 120MHz main FPGA clock.
        VZ80_CLK                 => VZ80_CLK,                                            -- Z80 runtime clock (product of SYSCLK and CTLCLK - variable frequency).
        VIDCLK_8MHZ              => VIDCLK_8MHZ,                                         -- 2x 8MHz base clock for video timing and gate clocking.
        VIDCLK_16MHZ             => VIDCLK_16MHZ,                                        -- 2x 16MHz base clock for video timing and gate clocking.
        VIDCLK_65MHZ             => VIDCLK_65MHZ,                                        -- 2x 65MHz base clock for video timing and gate clocking.
        VIDCLK_25_175MHZ         => VIDCLK_25_175MHZ,                                    -- 2x 25.175MHz base clock for video timing and gate clocking.
        VIDCLK_40MHZ             => VIDCLK_40MHZ,                                        -- 2x 40MHz base clock for video timing and gate clocking.
        VIDCLK_8_86719MHZ        => VIDCLK_8_86719MHZ,                                   -- 2x original MZ700 video clock.
        VIDCLK_17_7344MHZ        => VIDCLK_17_7344MHZ,                                   -- 2x original MZ700 colour modulator clock.

        -- V[name] = Voltage translated signals which mirror the mainboard signals but at a lower voltage.
        -- Address Bus
        VIDEO_ADDR               => CORE_ADDR,                                           -- Z80 Address bus.

        -- Direct addressing Bus. Normally this is set to 0 during standard Sharp MZ operation, when > 0 then direct addressing of the various video
        -- memory's is required.
        -- 000 - Normal
        -- 001 - Video RAM..
        -- 010 - Attribute RAM.
        -- 011 - Character Generator RAM
        -- 100 - Red framebuffer.
        -- 101 - Blue framebuffer.
        -- 110 - Green framebuffer.
        VIDEO_HI_ADDR            => CORE_VIDEO_ADDR,                                     -- Direct Addressing bus.

        -- Data Bus
        VIDEO_DATA_IN            => CORE_DATA_IN,                                        -- Z80 Data bus from CPU into video module.
        VIDEO_DATA_OUT           => CORE_DATA_OUT,                                       -- Z80 Data bus from video module to CPU.

        -- Control signals.
        VIDEO_IORQn              => CORE_IORQn,                                          -- IORQ signal, active low. When high, request is to memory.
        VIDEO_RDn                => CORE_VIDEO_RDn,                                      -- Decoded Video Controller Read from CPLD memory manager.
        VIDEO_WRn                => CORE_VIDEO_WRn,                                      -- Decoded Video Controller Write from CPLD memory manager.

        -- VGA & Composite output signals.
        VGA_R                    => VGA_R,                                               -- 16 level Red output.
        VGA_G                    => VGA_G,                                               -- 16 level Green output.
        VGA_B                    => VGA_B,                                               -- 16 level Blue output.
        VGA_R_COMPOSITE          => VGA_R_COMPOSITE,                                     -- RGB Red override for composite output.
        VGA_G_COMPOSITE          => VGA_G_COMPOSITE,                                     -- RGB Green override for composite output.
        VGA_B_COMPOSITE          => VGA_B_COMPOSITE,                                     -- RGB Blue override for composite output.
        HSYNC_OUTn               => HSYNC_OUTn,                                          -- Horizontal sync.
        VSYNC_OUTn               => VSYNC_OUTn,                                          -- Vertical sync.
        COLR_OUT                 => COLR_OUT,                                            -- Composite and RF base frequency.
        CSYNC_OUTn               => CSYNC_OUTn,                                          -- Composite sync (negative).
        CSYNC_OUT                => CSYNC_OUT,                                           -- Composite sync (positive).

        -- RGB & Composite input signals.
        VWAITn_V_CSYNC           => VWAITn_V_CSYNC,                                      -- Wait signal to the CPU when accessing FPGA video RAM / Composite sync from mainboard.
        V_HSYNCn                 => CORE_V_HSYNCn,                                       -- Horizontal sync (negative) from mainboard.
        V_VSYNCn                 => CORE_V_VSYNCn,                                       -- Vertical sync (negative) from mainboard.
        V_COLR                   => CORE_V_COLR,                                         -- Soft CPU NMIn / Composite and RF base frequency from mainboard.
        V_G                      => CORE_V_G,                                            -- Soft CPU BUSRQn / Digital Green (on/off) from mainboard.
        V_B                      => CORE_V_B,                                            -- Soft CPU WAITn / Digital Blue (on/off) from mainboard.
        V_R                      => CORE_V_R,                                            -- Soft CPU INTn / Digital Red (on/off) from mainboard.

        -- Reset.
        VRESETn                  => CORE_RESETn,                                         -- Internal reset.

        -- Configuration.
        CPLD_CFG_DATA            => CPLD_CFG_DATA,                                       -- CPLD internal settings register.        
        MB_VIDEO_ENABLEn         => MODE_CPLD_MB_VIDEOn                                  -- Mainboard video enabled (=0) or FPGA advanced video (=1).
    );


    ------------------------------------------------------------------------------------
    -- T80 CPU
    ------------------------------------------------------------------------------------    

    CPU0 : entity work.softT80
    port map (
        -- System signals and clocks.
        SYS_RESETn               => RESETn,                                              -- System reset.
        SYS_CLK                  => SYS_CLK,                                             -- System logic clock ~120MHz
        Z80_CLK                  => VZ80_CLK,                                            -- Underlying hardware system clock
                                                                                             
        -- Software controlled signals.                                                      
        SW_RESET                 => CPU_CFG_DATA(7),                                     -- Software controlled reset.
        SW_ENABLE                => MODE_CPU_SOFT,                                       -- Software controlled CPU enable.
        CPU_CHANGED              => MODE_CPU_CHANGED,                                    -- Flag to indicate when software selects a different CPU.

        -- Core Sharp MZ signals.
        T80_WAITn                => T80_WAITn,                                           -- WAITn signal into the CPU to prolong a memory cycle.
        T80_INTn                 => T80_INTn,                                            -- INTn signal for maskable interrupts.
        T80_NMIn                 => T80_NMIn,                                            -- NMIn non maskable interrupt input.
        T80_BUSRQn               => T80_BUSRQn,                                          -- BUSRQn signal to request CPU go into tristate and relinquish bus.
        T80_M1n                  => T80_M1n,                                             -- M1n Machine Cycle 1 signal. M1 and MREQ active = opcode fetch, M1 and IORQ active = interrupt, vector can be read from D0-D7.
        T80_MREQn                => T80_MREQn,                                           -- MREQn signal indicates that the address bus holds a valid address for reading or writing memory.
        T80_IORQn                => T80_IORQn,                                           -- IORQn signal indicates that the address bus (A0-A7) holds a valid address for reading or writing and I/O device.
        T80_RDn                  => T80_RDn,                                             -- RDn signal indicates that data is ready to be read from a memory or I/O device to the CPU.
        T80_WRn                  => T80_WRn,                                             -- WRn signal indicates that data is going to be written from the CPU data bus to a memory or I/O device.
        T80_RFSHn                => T80_RFSHn,                                           -- RFSHn signal to indicate dynamic memory refresh can take place.
        T80_HALTn                => T80_HALTn,                                           -- HALTn signal indicates that the CPU has executed a "HALT" instruction.
        T80_BUSACKn              => T80_BUSACKn,                                         -- BUSACKn signal indicates that the CPU address bus, data bus, and control signals have entered their HI-Z states, and that the external circuitry can now control these lines.
        T80_ADDR                 => T80_ADDR,                                            -- 16 bit address lines.
        T80_DATA_IN              => T80_DATA_IN,                                         -- 8 bit data bus in.
        T80_DATA_OUT             => T80_DATA_OUT                                         -- 8 bit data bus out.
    );


    ------------------------------------------------------------------------------------
    -- ZPU Evolution CPU
    ------------------------------------------------------------------------------------    

    CPU1 : entity work.softZPU
    generic map (
        SYSCLK_FREQUENCY         => 50000000                                             -- Speed of clock used for the ZPU.
    )
    port map (
        -- System signals and clocks.
        SYS_RESETn               => RESETn,                                              -- System reset.
        SYS_CLK                  => SYS_CLK,                                             -- System logic clock ~120MHz
        ZPU_CLK                  => CLOCK_50,                                            -- ZPU clock.
        Z80_CLK                  => VZ80_CLK,                                            -- Underlying hardware system clock
                                                                                             
        -- Software controlled signals.                                                      
        SW_RESET                 => CPU_CFG_DATA(7),                                     -- Software controlled reset.
        SW_ENABLE                => MODE_CPU_SOFT,                                       -- Software controlled CPU enable.
        CPU_CHANGED              => MODE_CPU_CHANGED,                                    -- Flag to indicate when software selects a different CPU.
        VIDEO_WRn                => ZPU_VIDEO_WRn,                                       -- Direct video write from ZPU, bypass CPLD memory manager.
        VIDEO_RDn                => ZPU_VIDEO_RDn,                                       -- Direct video read from ZPU, bypass CPLD memory manager.
        VIDEO_DIRECT_ADDR        => ZPU_VIDEO_ADDR,                                      -- Direct addressing of video memory (bypassing register configuration needed by Sharp MZ host to maintain compatibility or address space restrictions).

        -- Core Sharp MZ signals.
        ZPU_WAITn                => ZPU_WAITn,                                           -- WAITn signal into the CPU to prolong a memory cycle.
        ZPU_INTn                 => ZPU_INTn,                                            -- INTn signal for maskable interrupts.
        ZPU_NMIn                 => ZPU_NMIn,                                            -- NMIn non maskable interrupt input.
        ZPU_BUSRQn               => ZPU_BUSRQn,                                          -- BUSRQn signal to request CPU go into tristate and relinquish bus.
        ZPU_M1n                  => ZPU_M1n,                                             -- M1n Machine Cycle 1 signal. M1 and MREQ active = opcode fetch, M1 and IORQ active = interrupt, vector can be read from D0-D7.
        ZPU_MREQn                => ZPU_MREQn,                                           -- MREQn signal indicates that the address bus holds a valid address for reading or writing memory.
        ZPU_IORQn                => ZPU_IORQn,                                           -- IORQn signal indicates that the address bus (A0-A7) holds a valid address for reading or writing and I/O device.
        ZPU_RDn                  => ZPU_RDn,                                             -- RDn signal indicates that data is ready to be read from a memory or I/O device to the CPU.
        ZPU_WRn                  => ZPU_WRn,                                             -- WRn signal indicates that data is going to be written from the CPU data bus to a memory or I/O device.
        ZPU_RFSHn                => ZPU_RFSHn,                                           -- RFSHn signal to indicate dynamic memory refresh can take place.
        ZPU_HALTn                => ZPU_HALTn,                                           -- HALTn signal indicates that the CPU has executed a "HALT" instruction.
        ZPU_BUSACKn              => ZPU_BUSACKn,                                         -- BUSACKn signal indicates that the CPU address bus, data bus, and control signals have entered their HI-Z states, and that the external circuitry can now control these lines.
        ZPU_ADDR                 => ZPU_ADDR,                                            -- 16 bit address lines.
        ZPU_DATA_IN              => ZPU_DATA_IN,                                         -- 8 bit data bus in.
        ZPU_DATA_OUT             => ZPU_DATA_OUT                                         -- 8 bit data bus out.
    );

    ------------------------------------------------------------------------------------
    -- Core Logic
    ------------------------------------------------------------------------------------    

    -- Common Control Registers
    --
    --
    CTRLREGISTERS: process( RESETn, VZ80_CLK, CS_CPU_CFGn, CS_CPLD_CFGn, VZ80_WRn, VZ80_RDn )
        variable CPU_CHANGED          :    unsigned(3 downto 0);                           -- Flag to indicate the CPU has been changed. 
    begin
        -- Ensure default values at reset.
        if RESETn='0' then
            MODE_CPLD_SWITCH          <= '0';
            CPLD_CFG_DATA             <= "00000100";
            CPU_CFG_DATA(7 downto 6)  <= "00";                                             -- Dont reset soft CPU selection flag on a reset.
            CPU_CHANGED               := (others => '0');
    
        elsif rising_edge(VZ80_CLK) then

            -- CPLD/CPU Configuration registers.
            --
            -- CPU:
            -- Version 1.3-> of the tranZPUter SW-700 provides the ability to instantiate alternative soft CPU's. This register configures the FPGA to enable a soft/hard CPU and the CPLD
            -- is reconfigured to allow a CPU operation on the FPGA side rather than the physical hardware side.
            --
            -- [5:0] - R/W - CPU selection.
            --               000000 = Hard CPU
            --               000001 = T80 CPU
            --               000010 = ZPU Evolution
            --               000100 = Future CPU AAA
            --               001000 = Future CPU AAA
            --               010000 = Future CPU AAA
            --               100000 = Future CPU AAA
            --               All other configurations reserved and default to Hard CPU.
            -- [7]   - R/W - CPU Reset. When active ('1'), hold the CPU in reset, when inactive, commence the reset completion and CPU run.
            --
            -- CPLD:
            -- The mode can be changed by a Z80 transaction write into the register and it is acted upon if the mode switches between differing values. The Z80 write is typically used
            -- by host software such as RFS.
            --
            -- [2:0] - R/W - Mode/emulated machine.
            --               000 = MZ-80K
            --               001 = MZ-80C
            --               010 = MZ-1200
            --               011 = MZ-80A
            --               100 = MZ-700
            --               101 = MZ-800
            --               110 = MZ-80B
            --               111 = MZ-2000
            -- [3]   - R/W - Mainboard Video - 0 = Enable, 1 = Disable - This flag allows Z-80 transactions in the range D000:DFFF to be directed to the mainboard. When disabled all transactions
            --                                 can only be seen by the FPGA video logic. The FPGA uses this flag to enable/disable it's functionality.
            -- [4]   - R/W - Enable WAIT state during frame display period. 1 = Enable, 0 = Disable (default). The flag enables Z80 WAIT assertion during the frame display period. Most video modes
            --                                 use double buffering so this isnt needed, but use of direct writes to the frame buffer in 8 colour mode (ie. 640x200 or 320x200 8 colour) there
            --                                 is not enough memory to double buffer so potentially there could be tear or snow, hence this optional wait generator.
            --
            if(CS_CPU_CFGn = '0' and VZ80_WRn = '0') then

                -- Store the new value into the register, used for read operations.
                CPU_CFG_DATA                 <= VZ80_DATA;

                -- Check to ensure only one CPU selected, if more than one default to hard CPU. Also check to ensure only instantiated CPU's selected, otherwise default to hard CPU.
                --
                if (unsigned(VZ80_DATA(5 downto 0)) and (unsigned(VZ80_DATA(5 downto 0))-1)) /= 0 or (VZ80_DATA(5 downto 2) and "1111") /= "0000" then
                    CPU_CFG_DATA(5 downto 0) <= (others => '0');
                end if;

                -- If the CPU bit has changed, raise the flag to force a reset.
                CPU_CHANGED(0)               := '1';

            elsif(CS_CPLD_CFGn = '0' and VZ80_WRn = '0') then

                -- Set the mode switch event flag if the mode changes.
                if CPLD_CFG_DATA(2 downto 0) /= VZ80_DATA(2 downto 0) then
                    MODE_CPLD_SWITCH         <= '1';
                end if;

                -- Store the new value into the register, used for read operations.
                CPLD_CFG_DATA                <= VZ80_DATA;
            else
                MODE_CPLD_SWITCH             <= '0';
                CPU_CHANGED                  := CPU_CHANGED(2 downto 0) & '0';
            end if;
        end if;

        -- Flag to indicate when a soft CPU has been changed.
        if CPU_CHANGED /= 0 then
           MODE_CPU_CHANGED                  <= '1';
        else
           MODE_CPU_CHANGED                  <= '0';
        end if;
    end process;

    -- CPU information register.
    -- [5:0] - R/O - CPU Availability.
    --               000000 = Hard CPU
    --               000001 = T80 CPU
    --               000010 = ZPU Evolution
    --               000100 = Future CPU AAA
    --               001000 = Future CPU AAA
    --               010000 = Future CPU AAA
    --               100000 = Future CPU AAA
    -- [7:6] - R/O - Soft CPU capable, 01 = capable, /01 = not capable (value to cater for non-FPGA reads which return 11 or 00).
    --
    CPU_INFO_DATA         <= "01" & "000011";

    -- CPLD configuration register range.
    CS_IO_6XXn            <= '0'                                             when CORE_IORQn = '0'          and CORE_ADDR(7 downto 4) = "0110"
                             else '1';

    -- CPU configuration register range within the FPGA. These registers select and control the soft/hard CPU and parameters.
    CS_CPU_CFGn           <= '0'                                             when CS_IO_6XXn = '0'          and CORE_ADDR(3 downto 0) = "1100"                                            -- IO 6C
                              else '1';
    CS_CPU_INFOn          <= '0'                                             when CS_IO_6XXn = '0'          and CORE_ADDR(3 downto 0) = "1101"                                            -- IO 6D
                              else '1'; 

    -- CPLD mirrored logic. Registers on the CPLD which need to be known by the FPGA are duplicated within the FPGA.
    CS_CPLD_CFGn          <= '0'                                             when CS_IO_6XXn = '0'          and CORE_ADDR(3 downto 0) = "1110"                                            -- IO 6E - CPLD configuration register.
                             else '1';

    -- Set the mainboard video state, 0 = enabled, 1 = disabled. Signal set to enabled if the soft cpu is enabled.
    MODE_CPLD_MB_VIDEOn   <= '1'                                             when CPLD_CFG_DATA(3) = '1'    or  CPU_CFG_DATA(5 downto 0) /= "000000"
                             else '0';
    -- Flag to indicate Soft CPU is running,
    MODE_CPU_SOFT         <= '1'                                             when CPU_CFG_DATA(5 downto 0) /= "000000"
                             else '0';

    -- Mux the main Z80 control signals for internal use, either use the hard Z80 on the tranZPUter or the soft CPU in the FPGA.
    --
    CORE_MREQn            <= VZ80_MREQn                                      when MODE_CPU_SOFT = '0'       or  (CPU_CFG_DATA(0) = '1'     and T80_BUSACKn = '0')     or  (CPU_CFG_DATA(1) = '1'     and ZPU_BUSACKn = '0')
                             else
                             T80_MREQn                                       when CPU_CFG_DATA(0) = '1'     and T80_BUSACKn = '1'
                             else
                             ZPU_MREQn                                       when CPU_CFG_DATA(1) = '1'     and ZPU_BUSACKn = '1'
                             else '1';
    CORE_IORQn            <= VZ80_IORQn                                      when MODE_CPU_SOFT = '0'       or  (CPU_CFG_DATA(0) = '1'     and T80_BUSACKn = '0')     or  (CPU_CFG_DATA(1) = '1'     and ZPU_BUSACKn = '0')
                             else
                             T80_IORQn                                       when CPU_CFG_DATA(0) = '1'     and T80_BUSACKn = '1'
                             else
                             ZPU_IORQn                                       when CPU_CFG_DATA(1) = '1'     and ZPU_BUSACKn = '1'
                             else '1';
    CORE_RDn              <= VZ80_RDn                                        when MODE_CPU_SOFT = '0'       or  (CPU_CFG_DATA(0) = '1'     and T80_BUSACKn = '0')     or  (CPU_CFG_DATA(1) = '1'     and ZPU_BUSACKn = '0')
                             else
                             T80_RDn                                         when CPU_CFG_DATA(0) = '1'     and T80_BUSACKn = '1'
                             else
                             ZPU_RDn                                         when CPU_CFG_DATA(1) = '1'     and ZPU_BUSACKn = '1'
                             else '1';
    CORE_WRn              <= VZ80_WRn                                        when MODE_CPU_SOFT = '0'       or  (CPU_CFG_DATA(0) = '1'     and T80_BUSACKn = '0')     or  (CPU_CFG_DATA(1) = '1'     and ZPU_BUSACKn = '0')
                             else
                             T80_WRn                                         when CPU_CFG_DATA(0) = '1'     and T80_BUSACKn = '1'
                             else
                             ZPU_WRn                                         when CPU_CFG_DATA(1) = '1'     and ZPU_BUSACKn = '1'
                             else '1';
    CORE_M1n              <= VZ80_M1n                                        when MODE_CPU_SOFT = '0'       or  (CPU_CFG_DATA(0) = '1'     and T80_BUSACKn = '0')     or  (CPU_CFG_DATA(1) = '1'     and ZPU_BUSACKn = '0')
                             else
                             T80_M1n                                         when CPU_CFG_DATA(0) = '1'     and T80_BUSACKn = '1'
                             else
                             ZPU_M1n                                         when CPU_CFG_DATA(1) = '1'     and ZPU_BUSACKn = '1'
                             else '1';
    CORE_RFSHn            <= VZ80_RFSHn_V_HSYNCn                             when MODE_CPU_SOFT = '1'       or  MODE_CPLD_MB_VIDEOn = '1'
                             else
                             T80_RFSHn                                       when CPU_CFG_DATA(0) = '1'     and T80_BUSACKn = '1'
                             else
                             ZPU_RFSHn                                       when CPU_CFG_DATA(1) = '1'     and ZPU_BUSACKn = '1'
                             else '1';
    CORE_HALTn            <= VZ80_HALTn_V_VSYNCn                             when MODE_CPU_SOFT = '1'       or  MODE_CPLD_MB_VIDEOn = '1'
                             else
                             T80_HALTn                                       when CPU_CFG_DATA(0) = '1'     and T80_BUSACKn = '1'
                             else
                             ZPU_HALTn                                       when CPU_CFG_DATA(1) = '1'     and ZPU_BUSACKn = '1'
                             else '1';
    CORE_VIDEO_WRn        <= ZPU_VIDEO_WRn                                   when CPU_CFG_DATA(1) = '1'     and ZPU_BUSACKn = '1'
                             else
                             VIDEO_WRn;
    CORE_VIDEO_RDn        <= ZPU_VIDEO_RDn                                   when CPU_CFG_DATA(1) = '1'     and ZPU_BUSACKn = '1'
                             else
                             VIDEO_RDn;

    -- Address lines driven according to the CPU being used. Hard CPU = address via CPLD, Soft CPU = address direct.
    CORE_ADDR             <= VZ80_ADDR                                       when MODE_CPU_SOFT = '0'       or  (CPU_CFG_DATA(0) = '1'     and T80_BUSACKn = '0')     or  (CPU_CFG_DATA(1) = '1'     and ZPU_BUSACKn = '0')
                             else
                             T80_ADDR                                        when CPU_CFG_DATA(0) = '1'     and T80_BUSACKn = '1'
                             else
                             ZPU_ADDR                                        when CPU_CFG_DATA(1) = '1'     and ZPU_BUSACKn = '1'
                             else (others => '0');

    -- Direct addressing of video memory devices for soft CPU's.
    CORE_VIDEO_ADDR       <= (others => '0')                                 when CPU_CFG_DATA(1) = '0'     or  (CPU_CFG_DATA(1) = '1'     and ZPU_BUSACKn = '0')
                             else
                             ZPU_VIDEO_ADDR;

    -- Data into the core, generally the Video Controller, comes from the CPLD (hard CPU or mainboard) if the soft CPU is disabled else from the soft CPU.
    CORE_DATA_IN          <= VZ80_DATA                                       when MODE_CPU_SOFT = '0'       or  (CPU_CFG_DATA(0) = '1'     and T80_BUSACKn = '0')     or  (CPU_CFG_DATA(1) = '1'     and ZPU_BUSACKn = '0')
                             else
                             T80_DATA_OUT                                    when CPU_CFG_DATA(0) = '1'     and T80_BUSACKn = '1'
                             else
                             ZPU_DATA_OUT                                    when CPU_CFG_DATA(1) = '1'     and ZPU_BUSACKn = '1'
                             else (others => '0');
    -- tranZPUter, hard CPU or mainboard data input. Read directly from the Video Controller if selected, else the data being output from the soft CPU if enabled otherwise
    -- tri-state as data is coming from the CPLD.
    VZ80_DATA             <= CPU_CFG_DATA                                    when CS_CPU_CFGn = '0'         and VZ80_RDn = '0'                                                            -- Read current CPU register settings.
                             else
                             CPU_INFO_DATA                                   when CS_CPU_INFOn = '0'        and VZ80_RDn = '0'                                                            -- Read CPU version & hw build information.
                             else
                             CORE_DATA_OUT                                   when VIDEO_RDn = '0'
                             else
                             T80_DATA_OUT                                    when CPU_CFG_DATA(0) = '1'     and T80_WRn = '0'              and T80_BUSACKn = '1'
                             else
                             ZPU_DATA_OUT                                    when CPU_CFG_DATA(1) = '1'     and ZPU_WRn = '0'              and ZPU_BUSACKn = '1'
                             else
                             ZPU_DATA_OUT                                    when CPU_CFG_DATA(1) = '1'     and ZPU_MREQn = '0'            and ZPU_IORQn = '0'        and ZPU_BUSACKn = '1'
                             else (others => 'Z');
    -- Soft CPU data input. Read directly from the Video Controller if selected, at all other times read from the CPLD which in turn reads from the tranZPUter or mainboard.
    T80_DATA_IN           <= CPU_CFG_DATA                                    when CS_CPU_CFGn = '0'         and MODE_CPU_SOFT = '1'        and T80_RDn = '0'                                   -- Read current CPU register settings.
                             else
                             CPU_INFO_DATA                                   when CS_CPU_INFOn = '0'        and MODE_CPU_SOFT = '1'        and T80_RDn = '0'                                   -- Read CPU version & hw build information.
                             else
                             CORE_DATA_OUT                                   when VIDEO_RDn = '0'
                             else
                             VZ80_DATA                                       when CPU_CFG_DATA(0) = '1'     and T80_RDn = '0'
                             else (others => '0');
    ZPU_DATA_IN           <= CPU_CFG_DATA                                    when CS_CPU_CFGn = '0'         and MODE_CPU_SOFT = '1'        and ZPU_RDn = '0'                                   -- Read current CPU register settings.
                             else
                             CPU_INFO_DATA                                   when CS_CPU_INFOn = '0'        and MODE_CPU_SOFT = '1'        and ZPU_RDn = '0'                                   -- Read CPU version & hw build information.
                             else
                             CORE_DATA_OUT                                   when VIDEO_RDn = '0'
                             else
                             VZ80_DATA                                       when CPU_CFG_DATA(1) = '1'     and ZPU_RDn = '0'
                             else (others => '0');

    -- Direct routed signals to the T80 when not using mainboard video.
    T80_INTn              <= VZ80_INTn_V_R                                   when CPU_CFG_DATA(0) = '1'     or  MODE_CPLD_MB_VIDEOn = '1'
                             else '1';
    T80_NMIn              <= VZ80_NMIn_V_COLR                                when CPU_CFG_DATA(0) = '1'     or  MODE_CPLD_MB_VIDEOn = '1'
                             else '1';
    T80_BUSRQn            <= VZ80_BUSRQn_V_G                                 when CPU_CFG_DATA(0) = '1'     or  MODE_CPLD_MB_VIDEOn = '1'
                             else '1';
    T80_WAITn             <= VZ80_WAITn_V_B                                  when CPU_CFG_DATA(0) = '1'     or  MODE_CPLD_MB_VIDEOn = '1'
                             else '1';

    -- Direct routed signals to the ZPU when not using mainboard video.
    ZPU_INTn              <= VZ80_INTn_V_R                                   when CPU_CFG_DATA(1) = '1'     or  MODE_CPLD_MB_VIDEOn = '1'
                             else '1';
    ZPU_NMIn              <= VZ80_NMIn_V_COLR                                when CPU_CFG_DATA(1) = '1'     or  MODE_CPLD_MB_VIDEOn = '1'
                             else '1';
    ZPU_BUSRQn            <= VZ80_BUSRQn_V_G                                 when CPU_CFG_DATA(1) = '1'     or  MODE_CPLD_MB_VIDEOn = '1'
                             else '1';
    ZPU_WAITn             <= VZ80_WAITn_V_B                                  when CPU_CFG_DATA(1) = '1'     or  MODE_CPLD_MB_VIDEOn = '1'
                             else '1';

    -- Internal reset dependent on external reset or a change of the SOFT CPU.
    CORE_RESETn           <= '0'                                             when RESETn = '0'
                             else '1';

    -- Tri-state controls. If the hard Z80 is being used then tri-state output signals.
    VZ80_MREQn            <= T80_MREQn                                       when CPU_CFG_DATA(0) = '1'     and T80_BUSACKn = '1'
                             else
                             ZPU_MREQn                                       when CPU_CFG_DATA(1) = '1'     and ZPU_BUSACKn = '1'
                             else 'Z';
    VZ80_IORQn            <= T80_IORQn                                       when CPU_CFG_DATA(0) = '1'     and T80_BUSACKn = '1'
                             else
                             ZPU_IORQn                                       when CPU_CFG_DATA(1) = '1'     and ZPU_BUSACKn = '1'
                             else 'Z';
    VZ80_RDn              <= T80_RDn                                         when CPU_CFG_DATA(0) = '1'     and T80_BUSACKn = '1'
                             else
                             ZPU_RDn                                         when CPU_CFG_DATA(1) = '1'     and ZPU_BUSACKn = '1'
                             else 'Z';
    VZ80_WRn              <= T80_WRn                                         when CPU_CFG_DATA(0) = '1'     and T80_BUSACKn = '1'
                             else
                             ZPU_WRn                                         when CPU_CFG_DATA(1) = '1'     and ZPU_BUSACKn = '1'
                             else 'Z';
    VZ80_M1n              <= T80_M1n                                         when CPU_CFG_DATA(0) = '1'     and T80_BUSACKn = '1'
                             else
                             ZPU_M1n                                         when CPU_CFG_DATA(1) = '1'     and ZPU_BUSACKn = '1'                                 
                             else 'Z';
    VZ80_RFSHn_V_HSYNCn   <= T80_RFSHn                                       when CPU_CFG_DATA(0) = '1'     and T80_BUSACKn = '1'
                             else
                             ZPU_RFSHn                                       when CPU_CFG_DATA(1) = '1'     and ZPU_BUSACKn = '1'
                             else 'Z';
    VZ80_HALTn_V_VSYNCn   <= T80_HALTn                                       when CPU_CFG_DATA(0) = '1'     and T80_BUSACKn = '1'
                             else
                             ZPU_HALTn                                       when CPU_CFG_DATA(1) = '1'     and ZPU_BUSACKn = '1'
                             else 'Z';
    VZ80_ADDR             <= T80_ADDR                                        when CPU_CFG_DATA(0) = '1'     and T80_BUSACKn = '1'
                             else
                             ZPU_ADDR                                        when CPU_CFG_DATA(1) = '1'     and ZPU_BUSACKn = '1'
                             else (others => 'Z');
    VZ80_BUSACKn          <= T80_BUSACKn                                     when CPU_CFG_DATA(0) = '1'
                             else
                             ZPU_BUSACKn                                     when CPU_CFG_DATA(1) = '1'
                             else '1';

    -- Demux the mainboard video signals, these are used when the FPGA video is disabled and the Soft CPU is disabled.
    CORE_V_HSYNCn         <= VZ80_RFSHn_V_HSYNCn                             when MODE_CPLD_MB_VIDEOn = '0'
                             else '1';
    CORE_V_VSYNCn         <= VZ80_HALTn_V_VSYNCn                             when MODE_CPLD_MB_VIDEOn = '0'
                             else '1';
    CORE_V_COLR           <= VZ80_NMIn_V_COLR                                when MODE_CPLD_MB_VIDEOn = '0'
                             else '1';
    CORE_V_R              <= VZ80_INTn_V_R                                   when MODE_CPLD_MB_VIDEOn = '0'
                             else '1';
    CORE_V_G              <= VZ80_BUSRQn_V_G                                 when MODE_CPLD_MB_VIDEOn = '0'
                             else '1';
    CORE_V_B              <= VZ80_WAITn_V_B                                  when MODE_CPLD_MB_VIDEOn = '0'
                             else '1';
end architecture;
