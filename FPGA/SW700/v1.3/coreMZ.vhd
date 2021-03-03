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
--                  Dec 2020 -  ZPU Evo added into the framework.
--                  Jan 2021 -  Z80 (T80, AZ80, NextZ80) and ZPU Evolution processors added into the
--                              framework.
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
        VWAITn_A21_V_CSYNC        : inout std_logic;                                     -- Upper address bit for access to FPGA resources / Wait signal to the CPU when accessing FPGA video RAM / Composite sync from mainboard.
        VZ80_A20_RFSHn_V_HSYNCn   : inout std_logic;                                     -- Upper address bit for access to FPGA resources / Soft CPU RFSH out / Horizontal sync (negative) from mainboard.
        VZ80_A19_HALTn_V_VSYNCn   : inout std_logic;                                     -- Upper address bit for access to FPGA resources / Soft CPU HALT out / Video memory selected / Vertical sync (negative) from mainboard.
        VZ80_A17_NMIn_V_COLR      : in    std_logic;                                     -- Upper address bit for access to FPGA resources / Soft CPU NMIn in / Composite and RF base frequency from mainboard.
        VZ80_BUSRQn_V_G           : in    std_logic;                                     -- Soft CPU BUSRQn in / Digital Green (on/off) from mainboard.
        VZ80_A16_WAITn_V_B        : in    std_logic;                                     -- Upper address bit for access to FPGA resources / Soft CPU WAITn in / Digital Blue (on/off) from mainboard.
        VZ80_A18_INTn_V_R         : in    std_logic                                      -- Upper address bit for access to FPGA resources / Soft CPU INTn in / Digital Red (on/off) from mainboard.
    );
END entity;

architecture rtl of coreMZ is

    signal CPUCLK_75MHZ           :       std_logic;
    signal PLL_LOCKED             :       std_logic;
    signal RESETn                 :       std_logic := '0';
    signal RESET_COUNTER          :       unsigned(3 downto 0) := (others => '1');
    signal CTRLREG_RESET          :       std_logic := '1';                              -- Flag to indicate when a hard reset occurs so that registers can be preloaded based on conditions.
    signal MODE_CPLD_VIDEO_WAIT   :       std_logic;                                     -- FPGA video display period wait flag, 1 = enabled, 0 = disabled.
    signal CPU_CFG_DATA           :       std_logic_vector(7 downto 0):=(others => '0'); -- CPU Configuration register.
    signal CPU_INFO_DATA          :       std_logic_vector(7 downto 0);                  -- CPU configuration information register.
    signal CPLD_CFG_DATA          :       std_logic_vector(7 downto 0):=(others => '0'); -- CPLD configuration register.
    signal MODE_CPU_SOFT          :       std_logic;                                     -- Control signal to enable the Soft CPU and support logic.
    signal MODE_SOFTCPU_RESET     :       std_logic;                                     -- Software controlled reset signal to reset a soft cpu.
    signal MODE_SOFTCPU_CLKEN     :       std_logic;                                     -- Enable the soft cpu clock (1).
    signal MODE_CPLD_MB_VIDEOn    :       std_logic := '0';                              -- Machine configuration (memory map, I/O etc) set in the CPLD. When this flag is set, the mainboard video logic is enabled, disabling or blending with the FPGA graphics.
    signal MODE_SOFTCPU_Z80       :       std_logic;                                     -- Flag to indicate the Z80 module is available and active.
    signal MODE_SOFTCPU_ZPUEVO    :       std_logic;                                     -- Flag to indicate the ZPU Evo module is available and active.
    signal CS_IO_6XXn             :       std_logic;                                     -- Chip select for CPLD configuration registers.
    signal CS_CPU_CFGn            :       std_logic;                                     -- Select to set the CPU configuration register.
    signal CS_CPU_INFOn           :       std_logic;                                     -- Select to read the CPU information register.
    signal CS_CPLD_CFGn           :       std_logic;                                     -- Chip Select to write to the CPLD configuration register at 0x6E.
    signal VZ80_HI_ADDR           :       std_logic_vector(23 downto 16);                -- Upper address bits (to 16M) are multiplexed and only available during external access of the FPGA resources.
    signal VZ80_BUSACKni          :       std_logic;                                     -- Internal combination of BUSACK signals.
    signal COLOUR_CARRIER_FREQ    :       std_logic;                                     -- Modulator colour carrier frequency output by video module.

    -- T80 - General identifier for Z80 based Soft CPU's, the T80 being the primary but also AZ80 and NextZ80 are available via config flag.
    --
    signal T80_MREQn              :       std_logic;
    signal T80_IORQn              :       std_logic;
    signal T80_WRn                :       std_logic;
    signal T80_RDn                :       std_logic;
    signal T80_M1n                :       std_logic;
    signal T80_RFSHn              :       std_logic;
    signal T80_ADDR               :       std_logic_vector(15 downto 0);
    signal T80_DATA_OUT           :       std_logic_vector(7 downto 0);
    signal T80_BUSACKn            :       std_logic;
    signal T80_HALTn              :       std_logic;

    -- ZPU 
    signal ZPU80_MREQn            :       std_logic;
    signal ZPU80_IORQn            :       std_logic;
    signal ZPU80_WRn              :       std_logic;
    signal ZPU80_RDn              :       std_logic;
    signal ZPU80_M1n              :       std_logic;
    signal ZPU80_RFSHn            :       std_logic;
    signal ZPU80_ADDR             :       std_logic_vector(15 downto 0);
    signal ZPU80_VIDEO_ADDR       :       std_logic_vector(7 downto 0);
    signal ZPU80_DATA_OUT         :       std_logic_vector(7 downto 0);
    signal ZPU80_HALTn            :       std_logic;
    signal ZPU_DATA_OUT           :       std_logic_vector(31 downto 0);                 -- External RAM block data to write to RAM.
    signal ZPU_WRITE_EN           :       std_logic;                                     -- Write to external RAM.
    signal ZPU_MEM_BUSACK         :       std_logic;                                     -- Memory bus acknowledge signal.
    signal ZPU_VIDEO_ADDR         :       std_logic_vector(23 downto 0);                 -- Dedicated video address, bypasses the CPLD.
    signal ZPU_VIDEO_DATA_IN      :       std_logic_vector(31 downto 0);                 -- Video controller to ZPU data in.
    signal ZPU_VIDEO_DATA_OUT     :       std_logic_vector(31 downto 0);                 -- ZPU to Video controller data out.
    signal ZPU_VIDEO_WRn          :       std_logic;                                     -- Dedicated video channel write signal, bypasses the CPLD.
    signal ZPU_VIDEO_RDn          :       std_logic;                                     -- Dedicated video channel read signal, bypasses the CPLD.
    signal ZPU_VIDEO_WR_BYTE      :       std_logic;                                     -- Dedicated video channel 8bit byte write identifier signal, bypasses the CPLD.
    signal ZPU_VIDEO_WR_HWORD     :       std_logic;                                     -- Dedicated video channel 16bit half word write identifier signal, bypasses the CPLD.

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
    signal CORE_VIDEO_WR_BYTE     :       std_logic;                                     -- FPGA video byte write. A single byte is written when this flag is active.
    signal CORE_VIDEO_WR_HWORD    :       std_logic;                                     -- FPGA video 16bit half word write. A 16bit word, 2 bytes are written when this flag is active, half word aligned.
    signal CORE_ADDR              :       std_logic_vector(23 downto 0);                 --
    signal CORE_DATA_OUT          :       std_logic_vector(31 downto 0);                 --
    signal CORE_DATA_IN           :       std_logic_vector(31 downto 0);                 --
    signal VZ80_CLK_LAST          :       std_logic_vector(2 downto 0);
    signal VZ80_BUSRQn            :       std_logic;
begin
    ------------------------------------------------------------------------------------
    -- PLL System generation.
    ------------------------------------------------------------------------------------    

    -- Instantiate a PLL to generate the clocks required by soft processors.
    --
    COREMZPLL1 : entity work.Video_Clock_IV
    port map
    (
         inclk0                  => CLOCK_50,
         areset                  => '0',
         c0                      => CPUCLK_75MHZ,
         locked                  => PLL_LOCKED
    );

    ------------------------------------------------------------------------------------
    -- Serial Flash Loader for updating the EPCS64 via Altera Quartus.
    ------------------------------------------------------------------------------------    

    SERIALFLASHLOADER: if IMPL_SFL = true generate
        -- Add the Serial Flash Loader megafunction to enable in-situ programming of the EPCS16 configuration memory.
        --
        SFL : entity work.sfl_iv
        port map
        (
            noe_in               => '0' 
        );
    end generate;

    ------------------------------------------------------------------------------------
    -- System Reset
    ------------------------------------------------------------------------------------    

    -- Process to reset the FPGA based on the external RESET trigger, PLL's being locked
    -- and a counter to set minimum width.
    --
    FPGARESET: process(CLOCK_50, PLL_LOCKED)
    begin
        if PLL_LOCKED = '0' then
            RESET_COUNTER         <= (others => '1');
            RESETn                <= '0';

        elsif PLL_LOCKED = '1' then
            if rising_edge(CLOCK_50) then
                if RESET_COUNTER /= 0 then
                    RESET_COUNTER <= RESET_COUNTER - 1;
                elsif VIDEO_WRn = '0' and VIDEO_RDn = '0' then
                    RESETn        <= '0';
                elsif (VIDEO_WRn = '1' or VIDEO_RDn = '1') and RESET_COUNTER = 0 then
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
        CLOCK_50                 => CLOCK_50,                                            -- 50MHz main FPGA clock.

        -- Reset.
        VRESETn                  => CORE_RESETn,                                         -- Internal reset.

        -- V[name] = Voltage translated signals which mirror the mainboard signals but at a lower voltage.
        -- Address Bus
        VIDEO_ADDR               => CORE_ADDR,                                           -- 24bit Address bus.

        -- Data Bus
        VIDEO_DATA_IN            => CORE_DATA_IN,                                        -- Data bus from CPU into video module.
        VIDEO_DATA_OUT           => CORE_DATA_OUT,                                       -- Data bus from video module to CPU.

        -- Control signals.
        VIDEO_IORQn              => CORE_IORQn,                                          -- IORQ signal, active low. When high, request is to memory.
        VIDEO_RDn                => CORE_VIDEO_RDn,                                      -- Decoded Video Controller Read from CPLD memory manager.
        VIDEO_WRn                => CORE_VIDEO_WRn,                                      -- Decoded Video Controller Write from CPLD memory manager.
        VIDEO_WR_BYTE            => CORE_VIDEO_WR_BYTE,                                  -- Signal to indicate a byte should be written not a 32bit word.
        VIDEO_WR_HWORD           => CORE_VIDEO_WR_HWORD,                                 -- Signal to indicate a 16bit half word should be written not a 32bit word.

        -- VGA & Composite output signals.
        VGA_R                    => VGA_R,                                               -- 16 level Red output.
        VGA_G                    => VGA_G,                                               -- 16 level Green output.
        VGA_B                    => VGA_B,                                               -- 16 level Blue output.
        VGA_R_COMPOSITE          => VGA_R_COMPOSITE,                                     -- RGB Red override for composite output.
        VGA_G_COMPOSITE          => VGA_G_COMPOSITE,                                     -- RGB Green override for composite output.
        VGA_B_COMPOSITE          => VGA_B_COMPOSITE,                                     -- RGB Blue override for composite output.
        HSYNC_OUTn               => HSYNC_OUTn,                                          -- Horizontal sync.
        VSYNC_OUTn               => VSYNC_OUTn,                                          -- Vertical sync.
        COLR_OUT                 => COLOUR_CARRIER_FREQ,                                 -- Composite colour and RF base frequency.
        CSYNC_OUTn               => CSYNC_OUTn,                                          -- Composite sync (negative).
        CSYNC_OUT                => CSYNC_OUT,                                           -- Composite sync (positive).

        -- RGB & Composite input signals.
        VWAITn_V_CSYNC           => VWAITn_A21_V_CSYNC,                                  -- Wait signal to the CPU when accessing FPGA video RAM / Composite sync from mainboard.
        V_HSYNCn                 => VZ80_A20_RFSHn_V_HSYNCn,                             -- Horizontal sync (negative) from mainboard.
        V_VSYNCn                 => VZ80_A19_HALTn_V_VSYNCn,                             -- Vertical sync (negative) from mainboard.
        V_COLR                   => VZ80_A17_NMIn_V_COLR,                                -- Soft CPU NMIn / Composite and RF base frequency from mainboard.
        V_G                      => VZ80_BUSRQn_V_G,                                     -- Soft CPU BUSRQn / Digital Green (on/off) from mainboard.
        V_B                      => VZ80_A16_WAITn_V_B,                                  -- Soft CPU WAITn / Digital Blue (on/off) from mainboard.
        V_R                      => VZ80_A18_INTn_V_R,                                   -- Soft CPU INTn / Digital Red (on/off) from mainboard.

        -- Configuration.
        VIDEO_MODE               => CPLD_CFG_DATA(2 downto 0),                           -- Video mode the controller should emulate.
        MB_VIDEO_ENABLEn         => MODE_CPLD_MB_VIDEOn                                  -- Mainboard video enabled (=0) or FPGA advanced video (=1).
    );

    ------------------------------------------------------------------------------------
    -- T80 CPU
    ------------------------------------------------------------------------------------    

    CPU0: if IMPL_SOFTCPU_Z80 = true generate
        signal T80_INTn              :       std_logic;
        signal T80_NMIn              :       std_logic;
        signal T80_BUSRQn            :       std_logic;
        signal T80_WAITn             :       std_logic;
        signal T80_DATA_IN           :       std_logic_vector(7 downto 0);
    begin

        T80CPU : entity work.softT80
        port map (
            -- System signals and clocks.
            SYS_RESETn               => RESETn,                                              -- System reset.
            SYS_CLK                  => CLOCK_50,                                            -- System logic clock ~50MHz
            Z80_CLK                  => VZ80_CLK,                                            -- Underlying hardware system clock
                                                                                                 
            -- Software controlled signals.                                                      
            SW_RESET                 => MODE_SOFTCPU_RESET,                                  -- Software controlled reset.
            SW_CLKEN                 => MODE_SOFTCPU_CLKEN,                                  -- Software controlled clock enable.
            SW_CPUEN                 => MODE_SOFTCPU_Z80,                                    -- Software controlled CPU enable.
    
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
    
        -- Soft CPU data input. Read directly from the Video Controller if selected, at all other times read from the CPLD which in turn reads from the tranZPUter or mainboard.
        T80_DATA_IN                  <= CPU_CFG_DATA                when CS_CPU_CFGn = '0'         and MODE_CPU_SOFT = '1'        and T80_RDn = '0'                                   -- Read current CPU register settings.
                                        else
                                        CPU_INFO_DATA               when CS_CPU_INFOn = '0'        and MODE_CPU_SOFT = '1'        and T80_RDn = '0'                                   -- Read CPU version & hw build information.
                                        else
                                        CORE_DATA_OUT(7 downto 0)   when CORE_VIDEO_RDn = '0'
                                        else
                                        VZ80_DATA                   when MODE_SOFTCPU_Z80 = '1'    and T80_RDn = '0'
                                        else (others => '0');
        -- Direct routed signals to the T80 when not using mainboard video.
        T80_INTn                     <= VZ80_A18_INTn_V_R           when VZ80_BUSACKni = '1'       and (MODE_SOFTCPU_Z80 = '1'   or  MODE_CPLD_MB_VIDEOn = '1')
                                        else '1';
        T80_NMIn                     <= VZ80_A17_NMIn_V_COLR        when VZ80_BUSACKni = '1'       and (MODE_SOFTCPU_Z80 = '1'   or  MODE_CPLD_MB_VIDEOn = '1')
                                        else '1';
        T80_BUSRQn                   <= VZ80_BUSRQn                 when MODE_SOFTCPU_Z80 = '1'    or  MODE_CPLD_MB_VIDEOn = '1'
                                        else '1';
        T80_WAITn                    <= VZ80_A16_WAITn_V_B          when VZ80_BUSACKni = '1'       and (MODE_SOFTCPU_Z80 = '1'   or  MODE_CPLD_MB_VIDEOn = '1')
                                        else '1';
    
    else generate
        T80_WRn                      <= '1';
        T80_RDn                      <= '1';
        T80_M1n                      <= '1';
        T80_HALTn                    <= '1';
        T80_MREQn                    <= '1';
        T80_IORQn                    <= '1';
        T80_BUSACKn                  <= '1';
        T80_ADDR                     <= (others => 'X');
        T80_DATA_OUT                 <= (others => 'X');
    end generate;


    ------------------------------------------------------------------------------------
    -- ZPU Evolution CPU
    ------------------------------------------------------------------------------------    

    CPU1: if IMPL_SOFTCPU_ZPUEVO = true generate
        signal ZPU80_INTn            : std_logic;
        signal ZPU80_NMIn            : std_logic;
        signal ZPU80_WAITn           : std_logic;
        signal ZPU80_DATA_IN         : std_logic_vector(7 downto 0);
        signal ZPU_MEM_BUSRQ         : std_logic;                                            -- Memory bus request signal.
    begin

        ZPUCPU : entity work.softZPU
        generic map (
            SYSCLK_FREQUENCY         => 75000000                                             -- Speed of clock used for the ZPU.
        )
        port map (
            -- System signals and clocks.
            SYS_RESETn               => RESETn,                                              -- System reset.
            ZPU_CLK                  => CPUCLK_75MHZ,                                        -- ZPU clock.
            Z80_CLK                  => VZ80_CLK,                                            -- Underlying hardware system clock
                                                                                                 
            -- Software controlled signals.                                                      
            SW_RESET                 => MODE_SOFTCPU_RESET,                                  -- Software controlled reset.
            SW_CLKEN                 => MODE_SOFTCPU_CLKEN,                                  -- Software controlled clock enable.
            SW_CPUEN                 => MODE_SOFTCPU_ZPUEVO,                                 -- Software controlled CPU enable.

            -- Direct access to the video controller, bypassing the CPLD Memory management.
            VIDEO_ADDR               => ZPU_VIDEO_ADDR,                                      -- Direct video controller addressing, bypass CPLD memory manager and operate at 32bits.
            VIDEO_DATA_IN            => ZPU_VIDEO_DATA_IN,                                   -- Video controller to ZPU data in.
            VIDEO_DATA_OUT           => ZPU_VIDEO_DATA_OUT,                                  -- ZPU to Video controller data out.
            VIDEO_WRn                => ZPU_VIDEO_WRn,                                       -- Direct video write from ZPU, bypass CPLD memory manager.
            VIDEO_RDn                => ZPU_VIDEO_RDn,                                       -- Direct video read from ZPU, bypass CPLD memory manager.
            VIDEO_WR_BYTE            => ZPU_VIDEO_WR_BYTE,                                   -- Direct video write byte signal, when set a byte should be written.
            VIDEO_WR_HWORD           => ZPU_VIDEO_WR_HWORD,                                  -- Direct video write byte signal, when set a 16bit half word should be written.
    
            -- External Direct addressing Bus. Ability to read and write to the internal ZPU memory for uploading new programs/debugging.
            -- When BUSRQ is asserted, the external system can drive the signals to query memory.
            -- A23 -A16
            -- 00000000 - Normal Sharp MZ behaviour
            -- 00001XXX - Video Controller
            -- 00010000 ->
            -- 00011000 - ZPU 128K Block. Boot and stack memory.
    
            -- Access to internal BRAM access signals, become active when bus granted.
            INT_MEM_DATA_IN          => X"000000" & VZ80_DATA(7 downto 0),                   -- Internal RAM block data to write to RAM.
            INT_MEM_DATA_OUT         => ZPU_DATA_OUT,                                        -- Internal RAM block data read from RAM.
            INT_MEM_ADDR             => VZ80_HI_ADDR & VZ80_ADDR,                            -- 24bit address bus to address RAM.
            INT_MEM_WRITE_EN         => not VZ80_WRn,                                        -- Write to internal RAM.
            INT_MEM_WRITE_BYTE_EN    => '1',                                                 -- Write is 1 byte wide.
            INT_MEM_WRITE_HWORD_EN   => '0',                                                 -- Write is 1 half word wide.

            -- Bus request/ack mechanism.
            MEM_BUSRQ                => ZPU_MEM_BUSRQ,                                       -- Bus request signal. Set to 1 when external control is needed of the memory bus.
            MEM_BUSACK               => ZPU_MEM_BUSACK,                                      -- Bus acknowledge signal, set to 1 when control of the bus is granted.
    
            -- Core Sharp MZ signals.
            ZPU80_WAITn              => ZPU80_WAITn,                                         -- WAITn signal into the CPU to prolong a memory cycle.
            ZPU80_INTn               => ZPU80_INTn,                                          -- INTn signal for maskable interrupts.
            ZPU80_NMIn               => ZPU80_NMIn,                                          -- NMIn non maskable interrupt input.
            ZPU80_BUSRQn             => '1',                                                 -- BUSRQn signal to request CPU go into tristate and relinquish bus. Not used in this design
            ZPU80_M1n                => ZPU80_M1n,                                           -- M1n Machine Cycle 1 signal. M1 and MREQ active = opcode fetch, M1 and IORQ active = interrupt, vector can be read from D0-D7.
            ZPU80_MREQn              => ZPU80_MREQn,                                         -- MREQn signal indicates that the address bus holds a valid address for reading or writing memory.
            ZPU80_IORQn              => ZPU80_IORQn,                                         -- IORQn signal indicates that the address bus (A0-A7) holds a valid address for reading or writing and I/O device.
            ZPU80_RDn                => ZPU80_RDn,                                           -- RDn signal indicates that data is ready to be read from a memory or I/O device to the CPU.
            ZPU80_WRn                => ZPU80_WRn,                                           -- WRn signal indicates that data is going to be written from the CPU data bus to a memory or I/O device.
            ZPU80_RFSHn              => ZPU80_RFSHn,                                         -- RFSHn signal to indicate dynamic memory refresh can take place.
            ZPU80_HALTn              => ZPU80_HALTn,                                         -- HALTn signal indicates that the CPU has executed a "HALT" instruction.
            ZPU80_BUSACKn            => open,                                                -- BUSACKn signal indicates that the CPU address bus, data bus, and control signals have entered their HI-Z states, and that the external circuitry can now control these lines.
            ZPU80_ADDR               => ZPU80_ADDR,                                          -- 16 bit address lines.
            ZPU80_DATA_IN            => ZPU80_DATA_IN,                                       -- 8 bit data bus in.
            ZPU80_DATA_OUT           => ZPU80_DATA_OUT,                                      -- 8 bit data bus out.

            -- Debug.
            DEBUG_TXD_IN             => COLOUR_CARRIER_FREQ,                                 -- Serial debug loop, used as output when debug not enabled.
            DEBUG_TXD_OUT            => COLR_OUT                                             -- Debug serial output when debug enabled. / DEBUG_TXD_IN when debug disabled.
        );

        -- Direct routed signals to the ZPU when not using mainboard video.
        ZPU_VIDEO_DATA_IN            <= CORE_DATA_OUT;

        ZPU80_INTn                   <= VZ80_A18_INTn_V_R           when VZ80_BUSACKni = '1'       and (MODE_SOFTCPU_ZPUEVO = '1' or  MODE_CPLD_MB_VIDEOn = '1')
                                        else '1';
        ZPU80_NMIn                   <= VZ80_A17_NMIn_V_COLR        when VZ80_BUSACKni = '1'       and (MODE_SOFTCPU_ZPUEVO = '1' or  MODE_CPLD_MB_VIDEOn = '1')
                                        else '1';
        ZPU80_WAITn                  <= VZ80_A16_WAITn_V_B          when VZ80_BUSACKni = '1'       and (MODE_SOFTCPU_ZPUEVO = '1' or  MODE_CPLD_MB_VIDEOn = '1')
                                        else '1';
    
        ZPU80_DATA_IN                <= CPU_CFG_DATA                when CS_CPU_CFGn = '0'         and MODE_CPU_SOFT = '1'        and ZPU80_RDn = '0'                                   -- Read current CPU register settings.
                                        else
                                        CPU_INFO_DATA               when CS_CPU_INFOn = '0'        and MODE_CPU_SOFT = '1'        and ZPU80_RDn = '0'                                   -- Read CPU version & hw build information.
                                        else
                                        CORE_DATA_OUT(7 downto 0)   when CORE_VIDEO_RDn = '0'
                                        else
                                        VZ80_DATA                   when MODE_SOFTCPU_ZPUEVO = '1' and ZPU80_RDn = '0'
                                        else (others => '0');
        ZPU_MEM_BUSRQ                <= '1'                         when VZ80_BUSRQn = '0'         and (MODE_SOFTCPU_ZPUEVO = '1' or  MODE_CPLD_MB_VIDEOn = '1')                        -- Incoming BUSRQ from the K64F requests the ZPU Bus as well.
                                        else '0';

    else generate
        ZPU80_M1n                    <= '1';
        ZPU80_MREQn                  <= '1';
        ZPU80_IORQn                  <= '1';
        ZPU80_RDn                    <= '1';
        ZPU80_WRn                    <= '1';
        ZPU80_RFSHn                  <= '1';
        ZPU80_HALTn                  <= '1';
        ZPU80_ADDR                   <= (others => '0');
        ZPU80_DATA_OUT               <= (others => '0');
        ZPU_WRITE_EN                 <= '0';
        ZPU_MEM_BUSACK               <= '0';
        ZPU_VIDEO_WRn                <= '1';
        ZPU_VIDEO_RDn                <= '1';
    end generate;

    ------------------------------------------------------------------------------------
    -- Core Logic
    ------------------------------------------------------------------------------------    

    -- Common Control Registers
    --
    --
    CTRLREGISTERS: process( RESETn, CLOCK_50, VZ80_CLK, CS_CPU_CFGn, CS_CPLD_CFGn, VZ80_WRn, VZ80_RDn )
        variable SOFT_RESET_COUNTER   :    unsigned(3 downto 0);                           -- Down counter to set reset pulse width.
    begin
        -- Ensure default values at reset.
        if RESETn='0' then
            CTRLREG_RESET             <= '1';
            CPU_CFG_DATA(7 downto 6)  <= "01";                                             -- Dont reset soft CPU selection flag on a reset.
            MODE_SOFTCPU_RESET        <= '0';
            SOFT_RESET_COUNTER        := (others => '0');
            VZ80_CLK_LAST             <= (others => '0');

        elsif rising_edge(CLOCK_50) then

            -- Hard reset we must return registers to the same as the CPLD.
            if CTRLREG_RESET = '1' then
                CTRLREG_RESET         <= '0';
                if CPLD_CFG_DATA(7) = '0' or CPU_CFG_DATA(5 downto 0) = "000000" then
                    CPLD_CFG_DATA     <= "10000100";                                       -- Default to Sharp MZ700, mainboard video enabled, wait state off.
                end if;
            end if;

            -- Detect clean edges.
            VZ80_CLK_LAST             <= VZ80_CLK_LAST(1 downto 0) & VZ80_CLK;

            -- As the Z80 clock is originating in the CPLD and it is a mux between the mainboard generated clock and the K64F variable frequency clock, we need to bring it into this FPGA clock
            -- domain for better sync and timing. We act on the negative edge as the T80 has slightly different timing thus to remain compatible with the Z80/T80 we clock on the negative edge.
            --
            if VZ80_CLK_LAST = "000" and VZ80_CLK = '1' then

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
                -- [6]   - R/W - Clock enable. Enable (1) or disable the soft CPU clock.
                -- [7]   - R/W - CPU Reset. When set to active ('1'), a reset pulse is generated and the bit state returned to 0.
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
                -- [7]   - R/W - Preserve configuration over reset (=1) or set to default on reset (=0).
                --
                if(CS_CPU_CFGn = '0' and VZ80_WRn = '0') then

                    -- Store the new value into the register, used for read operations.
                    CPU_CFG_DATA                 <= VZ80_DATA;

                    -- Check to ensure only one CPU selected, if more than one default to hard CPU. Also check to ensure only instantiated CPU's selected, otherwise default to hard CPU.
                    --
                    if (unsigned(VZ80_DATA(5 downto 0)) and (unsigned(VZ80_DATA(5 downto 0))-1)) /= 0 or (VZ80_DATA(5 downto 2) and "1111") /= "0000" or (IMPL_SOFTCPU_Z80 = false and VZ80_DATA(0) = '1') or (IMPL_SOFTCPU_ZPUEVO = false and VZ80_DATA(1) = '1') then
                        CPU_CFG_DATA(5 downto 0) <= (others => '0');
                    end if;

                elsif(CS_CPLD_CFGn = '0' and VZ80_WRn = '0') then

                    -- Store the new value into the register, used for read operations.
                    CPLD_CFG_DATA                <= VZ80_DATA;
                end if;

                -- Soft reset mechanism. If the reset flag was set on the previous cycle, toggle reset active and start a down counter. On zero, toggle reset to inactive.
                if CPU_CFG_DATA(7) = '1' then
                    MODE_SOFTCPU_RESET           <= '1';
                    SOFT_RESET_COUNTER           := (others => '1');
                    CPU_CFG_DATA(7)              <= '0';
                end if;
                if SOFT_RESET_COUNTER /= 0 then
                    SOFT_RESET_COUNTER           := SOFT_RESET_COUNTER - 1;
                else
                    MODE_SOFTCPU_RESET           <= '0';
                end if;
            end if;
        end if;
    end process;

    -- Mode flags to indicate a CPU is available and selected.
    MODEZ80: if IMPL_SOFTCPU_Z80 = true generate
      MODE_SOFTCPU_Z80    <= '1'                                             when CPU_CFG_DATA(0) = '1'
                             else '0';
    else generate
      MODE_SOFTCPU_Z80    <= '0';
    end generate;

    MODEEVO: if IMPL_SOFTCPU_ZPUEVO = true generate
      MODE_SOFTCPU_ZPUEVO <= '1'                                             when CPU_CFG_DATA(1) = '1'
                             else '0';
    else generate
      MODE_SOFTCPU_ZPUEVO <= '0';
    end generate;
    --
    MODE_SOFTCPU_CLKEN    <= CPU_CFG_DATA(6);

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
    CPU_INFO_DATA         <= "01000001"                                      when IMPL_SOFTCPU_Z80 = true   and IMPL_SOFTCPU_ZPUEVO = false
                             else
                             "01000010"                                      when IMPL_SOFTCPU_Z80 = false  and IMPL_SOFTCPU_ZPUEVO = true
                             else
                             "01000011"                                      when IMPL_SOFTCPU_Z80 = true   and IMPL_SOFTCPU_ZPUEVO = true
                             else
                             "00000000";

    -- CPLD configuration register range.
    CS_IO_6XXn            <= '0'                                             when CORE_IORQn = '0'          and CORE_ADDR(7 downto 4) = "0110"
                             else '1';

    -- CPU configuration register range within the FPGA. These registers select and control the soft/hard CPU and parameters.
    CS_CPU_CFGn           <= '0'                                             when CS_IO_6XXn = '0'          and CORE_ADDR(3 downto 0) = "1100"                                                  -- IO 6C
                              else '1';
    CS_CPU_INFOn          <= '0'                                             when CS_IO_6XXn = '0'          and CORE_ADDR(3 downto 0) = "1101"                                                  -- IO 6D
                              else '1'; 

    -- CPLD mirrored logic. Registers on the CPLD which need to be known by the FPGA are duplicated within the FPGA.
    CS_CPLD_CFGn          <= '0'                                             when CS_IO_6XXn = '0'          and CORE_ADDR(3 downto 0) = "1110"                                                  -- IO 6E - CPLD configuration register.
                             else '1';

    -- Set the mainboard video state, 0 = enabled, 1 = disabled. Signal set to enabled if the soft cpu is enabled.
    MODE_CPLD_MB_VIDEOn   <= '1'                                             when CPLD_CFG_DATA(3) = '1'    or  CPU_CFG_DATA(5 downto 0) /= "000000"
                             else '0';
    -- Flag to indicate Soft CPU is running,
    MODE_CPU_SOFT         <= '1'                                             when CPU_CFG_DATA(5 downto 0) /= "000000"
                             else '0';

    -- Mux the main Z80 control signals for internal use, either use the hard Z80 on the tranZPUter or the soft CPU in the FPGA.
    --
    CORE_MREQn            <= VZ80_MREQn                                      when MODE_CPU_SOFT = '0'       or  VZ80_BUSACKni = '0'
                             else
                             T80_MREQn                                       when MODE_SOFTCPU_Z80 = '1'    and VZ80_BUSACKni = '1'
                             else
                             ZPU80_MREQn                                     when MODE_SOFTCPU_ZPUEVO = '1' and VZ80_BUSACKni = '1'
                             else '1';
    CORE_IORQn            <= VZ80_IORQn                                      when MODE_CPU_SOFT = '0'       or  VZ80_BUSACKni = '0'
                             else
                             T80_IORQn                                       when MODE_SOFTCPU_Z80 = '1'    and VZ80_BUSACKni = '1'
                             else
                             ZPU80_IORQn                                     when MODE_SOFTCPU_ZPUEVO = '1' and VZ80_BUSACKni = '1'
                             else '1';
    CORE_RDn              <= VZ80_RDn                                        when MODE_CPU_SOFT = '0'       or  VZ80_BUSACKni = '0'
                             else
                             T80_RDn                                         when MODE_SOFTCPU_Z80 = '1'    and VZ80_BUSACKni = '1'
                             else
                             ZPU80_RDn                                       when MODE_SOFTCPU_ZPUEVO = '1' and VZ80_BUSACKni = '1'
                             else '1';
    CORE_WRn              <= VZ80_WRn                                        when MODE_CPU_SOFT = '0'       or  VZ80_BUSACKni = '0'
                             else
                             T80_WRn                                         when MODE_SOFTCPU_Z80 = '1'    and VZ80_BUSACKni = '1'
                             else
                             ZPU80_WRn                                       when MODE_SOFTCPU_ZPUEVO = '1' and VZ80_BUSACKni = '1'
                             else '1';
    CORE_M1n              <= VZ80_M1n                                        when MODE_CPU_SOFT = '0'       or  VZ80_BUSACKni = '0'
                             else
                             T80_M1n                                         when MODE_SOFTCPU_Z80 = '1'    and VZ80_BUSACKni = '1'
                             else
                             ZPU80_M1n                                       when MODE_SOFTCPU_ZPUEVO = '1' and VZ80_BUSACKni = '1'
                             else '1';
    CORE_RFSHn            <= T80_RFSHn                                       when MODE_SOFTCPU_Z80 = '1'    and VZ80_BUSACKni = '1'
                             else
                             ZPU80_RFSHn                                     when MODE_SOFTCPU_ZPUEVO = '1' and VZ80_BUSACKni = '1'
                             else '1';
    CORE_HALTn            <= T80_HALTn                                       when MODE_SOFTCPU_Z80 = '1'    and VZ80_BUSACKni = '1'
                             else
                             ZPU80_HALTn                                     when MODE_SOFTCPU_ZPUEVO = '1' and VZ80_BUSACKni = '1'
                             else '1';
    CORE_VIDEO_WRn        <= '0'                                             when VZ80_BUSACKni = '0'       and VZ80_WRn = '0'            and VZ80_HI_ADDR(23 downto 19) = "00001"
                             else
                             ZPU_VIDEO_WRn                                   when MODE_SOFTCPU_ZPUEVO = '1' and VZ80_BUSACKni = '1'
                             else
                             VIDEO_WRn;
    CORE_VIDEO_RDn        <= '0'                                             when VZ80_BUSACKni = '0'       and VZ80_RDn = '0'            and VZ80_HI_ADDR(23 downto 19) = "00001"
                             else
                             ZPU_VIDEO_RDn                                   when MODE_SOFTCPU_ZPUEVO = '1' and VZ80_BUSACKni = '1'
                             else
                             VIDEO_RDn;
    -- 32/16/8 bit write select. When the ZPU is writing, the signals are active and controlled by the ZPU, otherwise default to 1 byte writes.
    CORE_VIDEO_WR_BYTE    <= '1'                                             when ZPU_VIDEO_WRn = '1'
                             else
                             ZPU_VIDEO_WR_BYTE;
    CORE_VIDEO_WR_HWORD   <= '0'                                             when ZPU_VIDEO_WRn = '1'
                             else
                             ZPU_VIDEO_WR_HWORD;

    -- Internal reset dependent on external reset or a change of the SOFT CPU.
    CORE_RESETn           <= '0'                                             when RESETn = '0'
                             else '1';


    -- Address lines driven according to the CPU being used. Hard CPU = address via CPLD, Soft CPU = address direct.
    CORE_ADDR             <= X"00" & T80_ADDR                                when MODE_SOFTCPU_Z80 = '1'    and VZ80_BUSACKni = '1'
                             else
                             ZPU_VIDEO_ADDR                                  when MODE_SOFTCPU_ZPUEVO = '1' and VZ80_BUSACKni = '1'       and (ZPU_VIDEO_WRn = '0'      or  ZPU_VIDEO_RDn = '0')
                             else
                             X"00" & ZPU80_ADDR                              when MODE_SOFTCPU_ZPUEVO = '1' and VZ80_BUSACKni = '1'       and ZPU_VIDEO_WRn = '1'       and ZPU_VIDEO_RDn = '1'
                             else
                             VZ80_HI_ADDR & VZ80_ADDR                        when MODE_CPU_SOFT = '0'        or VZ80_BUSACKni = '0'
                             else (others => '0');

    -- Data into the core, generally the Video Controller, comes from the CPLD (hard CPU or mainboard) if the soft CPU is disabled else from the soft CPU.
    CORE_DATA_IN          <= X"000000" & T80_DATA_OUT                        when MODE_SOFTCPU_Z80 = '1'    and VZ80_BUSACKni = '1'
                             else
                             ZPU_VIDEO_DATA_OUT                              when MODE_SOFTCPU_ZPUEVO = '1' and VZ80_BUSACKni = '1'       and (ZPU_VIDEO_WRn = '0'      or  ZPU_VIDEO_RDn = '0')
                             else
                             X"000000" & ZPU80_DATA_OUT                      when MODE_SOFTCPU_ZPUEVO = '1' and VZ80_BUSACKni = '1'       and ZPU_VIDEO_WRn = '1'       and ZPU_VIDEO_RDn = '1'
                             else
                             X"000000" & VZ80_DATA                           when MODE_CPU_SOFT = '0'       or  VZ80_BUSACKni = '0'
                             else (others => '0');

    -- tranZPUter, hard CPU or mainboard data input. Read directly from the Video Controller if selected, else the data being output from the soft CPU if enabled otherwise
    -- tri-state as data is coming from the CPLD.
    VZ80_DATA             <= CPU_CFG_DATA                                    when CS_CPU_CFGn = '0'         and VZ80_RDn = '0'                                                                  -- Read current CPU register settings.
                             else
                             CPU_INFO_DATA                                   when CS_CPU_INFOn = '0'        and VZ80_RDn = '0'                                                                  -- Read CPU version & hw build information.
                             else
                             CORE_DATA_OUT (7 downto 0)                      when CORE_VIDEO_RDn = '0'                                                                                          -- If the video resources are being read, either by the hard cpu or the K64f, output requested data.
                             else
                             T80_DATA_OUT                                    when MODE_SOFTCPU_Z80 = '1'    and T80_WRn = '0'             and VZ80_BUSACKni = '1'                               -- T80 has control over writing data when enabled and bus not requested.
                             else
                             ZPU80_DATA_OUT                                  when MODE_SOFTCPU_ZPUEVO = '1' and ZPU80_WRn = '0'           and VZ80_BUSACKni = '1'                               -- ZPU Evo Z80 Bus controller has control over writing data when enabled and bus not requested.
                             else
                             ZPU80_DATA_OUT                                  when MODE_SOFTCPU_ZPUEVO = '1' and ZPU80_MREQn = '0'         and ZPU80_IORQn = '0'        and VZ80_BUSACKni = '1'  -- ZPU has control when writing special control word to CPLD to enable memory mode.
                             -- When bus requested, K64F has control, reading data from the ZPU BRAM if selected.
                             else
                             ZPU_DATA_OUT(7 downto 0)                        when MODE_SOFTCPU_ZPUEVO = '1' and VZ80_BUSACKni = '0'       and VZ80_RDn = '0'           and VZ80_ADDR(1 downto 0) = "11"
                             else
                             ZPU_DATA_OUT(15 downto 8)                       when MODE_SOFTCPU_ZPUEVO = '1' and VZ80_BUSACKni = '0'       and VZ80_RDn = '0'           and VZ80_ADDR(1 downto 0) = "10"
                             else
                             ZPU_DATA_OUT(23 downto 16)                      when MODE_SOFTCPU_ZPUEVO = '1' and VZ80_BUSACKni = '0'       and VZ80_RDn = '0'           and VZ80_ADDR(1 downto 0) = "01"
                             else
                             ZPU_DATA_OUT(31 downto 24)                      when MODE_SOFTCPU_ZPUEVO = '1' and VZ80_BUSACKni = '0'       and VZ80_RDn = '0'           and VZ80_ADDR(1 downto 0) = "00"
                             else (others => 'Z');

    -- Direct routed signals to the ZPU when not using mainboard video.
    VZ80_HI_ADDR(16)      <= VZ80_A16_WAITn_V_B                              when VZ80_BUSACKni = '0'
                             else '0';
    VZ80_HI_ADDR(17)      <= VZ80_A17_NMIn_V_COLR                            when VZ80_BUSACKni = '0'
                             else '0';
    VZ80_HI_ADDR(18)      <= VZ80_A18_INTn_V_R                               when VZ80_BUSACKni = '0'
                             else '0';
    VZ80_HI_ADDR(19)      <= VZ80_A19_HALTn_V_VSYNCn                         when VZ80_BUSACKni = '0'
                             else '0';
    VZ80_HI_ADDR(20)      <= VZ80_A20_RFSHn_V_HSYNCn                         when VZ80_BUSACKni = '0'
                             else '0';
    VZ80_HI_ADDR(21)      <= VWAITn_A21_V_CSYNC                              when VZ80_BUSACKni = '0'
                             else '0';
    VZ80_HI_ADDR(22)      <= '0';
    VZ80_HI_ADDR(23)      <= '0';

    -- Tri-state controls. If the hard Z80 is being used then tri-state output signals.
    VZ80_MREQn            <= T80_MREQn                                       when MODE_SOFTCPU_Z80 = '1'    and VZ80_BUSACKni = '1'                                                             -- When the T80 is selected and not under K64F control, drive the MREQ line output by the T80.
                             else
                             ZPU80_MREQn                                     when MODE_SOFTCPU_ZPUEVO = '1' and VZ80_BUSACKni = '1'                                                             -- When the ZPU Evo is selected and not under K64F control, drive the MREQ line output by the T80.
                             else 'Z';
    VZ80_IORQn            <= T80_IORQn                                       when MODE_SOFTCPU_Z80 = '1'    and VZ80_BUSACKni = '1'
                             else
                             ZPU80_IORQn                                     when MODE_SOFTCPU_ZPUEVO = '1' and VZ80_BUSACKni = '1'
                             else 'Z';
    VZ80_RDn              <= T80_RDn                                         when MODE_SOFTCPU_Z80 = '1'    and VZ80_BUSACKni = '1'
                             else
                             ZPU80_RDn                                       when MODE_SOFTCPU_ZPUEVO = '1' and VZ80_BUSACKni = '1'
                             else 'Z';
    VZ80_WRn              <= T80_WRn                                         when MODE_SOFTCPU_Z80 = '1'    and VZ80_BUSACKni = '1'
                             else
                             ZPU80_WRn                                       when MODE_SOFTCPU_ZPUEVO = '1' and VZ80_BUSACKni = '1'
                             else 'Z';
    VZ80_M1n              <= T80_M1n                                         when MODE_SOFTCPU_Z80 = '1'    and VZ80_BUSACKni = '1'
                             else
                             ZPU80_M1n                                       when MODE_SOFTCPU_ZPUEVO = '1' and VZ80_BUSACKni = '1'                                 
                             else 'Z';
    VZ80_A20_RFSHn_V_HSYNCn<=T80_RFSHn                                       when MODE_SOFTCPU_Z80 = '1'    and VZ80_BUSACKni = '1'
                             else
                             ZPU80_RFSHn                                     when MODE_SOFTCPU_ZPUEVO = '1' and VZ80_BUSACKni = '1'
                             else 'Z';
    VZ80_A19_HALTn_V_VSYNCn<=T80_HALTn                                       when MODE_SOFTCPU_Z80 = '1'    and VZ80_BUSACKni = '1'
                             else
                             ZPU80_HALTn                                     when MODE_SOFTCPU_ZPUEVO = '1' and VZ80_BUSACKni = '1'
                             else 'Z';
    VZ80_ADDR             <= T80_ADDR                                        when MODE_SOFTCPU_Z80 = '1'    and VZ80_BUSACKni = '1'
                             else
                             ZPU80_ADDR                                      when MODE_SOFTCPU_ZPUEVO = '1' and VZ80_BUSACKni = '1'
                             else (others => 'Z');
    VZ80_BUSACKni         <= '0'                                             when MODE_CPU_SOFT = '0'       and VZ80_BUSRQn = '0'         and MODE_CPLD_MB_VIDEOn = '1'                         -- When soft CPU's are disabled, generate a BUSACK when FPGA video is enabled and BUSRQ is asserted.
                             else
                             '0'                                             when MODE_SOFTCPU_Z80 = '1'    and T80_BUSACKn = '0'
                             else
                             '0'                                             when MODE_SOFTCPU_ZPUEVO = '1' and ZPU_MEM_BUSACK = '1'                                                            -- The ZPU has priority, when it acknowledges then the Z80 BUS is already idle.
                             else '1';
    VZ80_BUSRQn           <= VZ80_BUSRQn_V_G                                 when MODE_CPU_SOFT = '1'       or  MODE_CPLD_MB_VIDEOn = '1'                                                       -- Just a wire, demux of the VZ80_BUSRQn_V_G signal.
                             else '1';
    VZ80_BUSACKn          <= VZ80_BUSACKni;

end architecture;
