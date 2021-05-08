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
-- Copyright:       (c) 2018-21 Philip Smart <philip.smart@net2net.org>
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
--                  May 2021 -  Split into modules:
--                              CoreMZ         - Video Module only.
--                              CoreMZ SoftCPU - Video Module and Soft CPUs (T80/ZPU).
--                              CoreMZ emuMZ   - Video Module and a port of the SharpMZ Series FPGA
--                                               emulator.
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

  --signal CPUCLK_75MHZ           :       std_logic;
    signal PLL_LOCKED             :       std_logic := '0';
    signal RESETn                 :       std_logic := '0';
    signal RESET_COUNTER          :       unsigned(3 downto 0) := (others => '1');
    signal CTRLREG_RESET          :       std_logic := '1';                              -- Flag to indicate when a hard reset occurs so that registers can be preloaded based on conditions.
    signal MODE_CPLD_VIDEO_WAIT   :       std_logic;                                     -- FPGA video display period wait flag, 1 = enabled, 0 = disabled.
    signal CPU_CFG_DATA           :       std_logic_vector(7 downto 0):=(others => '0'); -- CPU Configuration register.
    signal CPU_INFO_DATA          :       std_logic_vector(7 downto 0);                  -- CPU configuration information register.
    signal CPLD_CFG_DATA          :       std_logic_vector(7 downto 0):=(others => '0'); -- CPLD configuration register.
    signal MODE_CPU_SOFT          :       std_logic;                                     -- Control signal to enable the Soft CPU and support logic.
    signal MODE_CPLD_MB_VIDEOn    :       std_logic := '0';                              -- Machine configuration (memory map, I/O etc) set in the CPLD. When this flag is set, the mainboard video logic is enabled, disabling or blending with the FPGA graphics.
    signal CS_IO_6XXn             :       std_logic;                                     -- Chip select for CPLD configuration registers.
    signal CS_CPU_CFGn            :       std_logic;                                     -- Select to set the CPU configuration register.
    signal CS_CPU_INFOn           :       std_logic;                                     -- Select to read the CPU information register.
    signal CS_CPLD_CFGn           :       std_logic;                                     -- Chip Select to write to the CPLD configuration register at 0x6E.
    signal VZ80_HI_ADDR           :       std_logic_vector(23 downto 16);                -- Upper address bits (to 16M) are multiplexed and only available during external access of the FPGA resources.
    signal VZ80_BUSACKni          :       std_logic;                                     -- Internal combination of BUSACK signals.

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
  --COREMZPLL1 : entity work.Video_Clock_IV
  --port map
  --(
  --     inclk0                  => CLOCK_50,
  --     areset                  => '0',
  --     c0                      => CPUCLK_75MHZ,
  --     locked                  => PLL_LOCKED
  --);

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
            PLL_LOCKED            <= '1';
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
        COLR_OUT                 => COLR_OUT,                                            -- Composite colour and RF base frequency.
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
    -- Core Logic
    ------------------------------------------------------------------------------------    

    -- Common Control Registers
    --
    --
    CTRLREGISTERS: process( RESETn, CLOCK_50, VZ80_CLK, CS_CPU_CFGn, CS_CPLD_CFGn, VZ80_WRn, VZ80_RDn )
    begin
        -- Ensure default values at reset.
        if RESETn='0' then
            CTRLREG_RESET             <= '1';
            CPU_CFG_DATA(7 downto 6)  <= "01";                                             -- Dont reset soft CPU selection flag on a reset.
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

                    -- Soft CPU's are not implemented.
                    CPU_CFG_DATA                 <= (others => '0');

                elsif(CS_CPLD_CFGn = '0' and VZ80_WRn = '0') then

                    -- Store the new value into the register, used for read operations.
                    CPLD_CFG_DATA                <= VZ80_DATA;
                end if;
            end if;
        end if;
    end process;

    -- CPU information register. Not implemented in this module.
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
    CPU_INFO_DATA         <= "00000000";

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

    -- Set the mainboard video state, 0 = enabled, 1 = disabled.
    MODE_CPLD_MB_VIDEOn   <= '1'                                             when CPLD_CFG_DATA(3) = '1'
                             else '0';

    -- Mux the main Z80 control signals for internal use, either use the hard Z80 on the tranZPUter or the soft CPU in the FPGA.
    --
    CORE_MREQn            <= VZ80_MREQn;
    CORE_IORQn            <= VZ80_IORQn;
    CORE_RDn              <= VZ80_RDn;
    CORE_WRn              <= VZ80_WRn;
    CORE_M1n              <= VZ80_M1n;
    CORE_RFSHn            <= '1';
    CORE_HALTn            <= '1';
    CORE_VIDEO_WRn        <= '0'                                             when VZ80_WRn = '0'            and VZ80_HI_ADDR(23 downto 19) = "00001"
                             else
                             VIDEO_WRn;
    CORE_VIDEO_RDn        <= '0'                                             when VZ80_RDn = '0'            and VZ80_HI_ADDR(23 downto 19) = "00001"
                             else
                             VIDEO_RDn;
    -- 32/16/8 bit write select. When the ZPU is writing, the signals are active and controlled by the ZPU, otherwise default to 1 byte writes.
    CORE_VIDEO_WR_BYTE    <= '1';
    CORE_VIDEO_WR_HWORD   <= '0';

    -- Internal reset dependent on external reset or a change of the SOFT CPU.
    CORE_RESETn           <= '0'                                             when RESETn = '0'
                             else '1';

    -- Address lines driven according to the CPU being used. Hard CPU = address via CPLD, Soft CPU = address direct.
    CORE_ADDR             <= VZ80_HI_ADDR & VZ80_ADDR                        when VZ80_BUSACKni = '0'
                             else
                             "00000000" & VZ80_ADDR;

    -- Data into the core, generally the Video Controller, comes from the CPLD (hard CPU or mainboard) if the soft CPU is disabled else from the soft CPU.
    CORE_DATA_IN          <= X"000000" & VZ80_DATA;

    -- tranZPUter, hard CPU or mainboard data input. Read directly from the Video Controller if selected, else the data being output from the soft CPU if enabled otherwise
    -- tri-state as data is coming from the CPLD.
    VZ80_DATA             <= CPU_CFG_DATA                                    when CS_CPU_CFGn = '0'         and VZ80_RDn = '0'                                                                  -- Read current CPU register settings.
                             else
                             CPU_INFO_DATA                                   when CS_CPU_INFOn = '0'        and VZ80_RDn = '0'                                                                  -- Read CPU version & hw build information.
                             else
                             CORE_DATA_OUT (7 downto 0)                      when CORE_VIDEO_RDn = '0'                                                                                          -- If the video resources are being read, either by the hard cpu or the K64f, output requested data.
                             else (others => 'Z');

    -- Direct routed signals to the ZPU when not using mainboard video.
    VZ80_HI_ADDR(16)      <= VZ80_A16_WAITn_V_B;
    VZ80_HI_ADDR(17)      <= VZ80_A17_NMIn_V_COLR;
    VZ80_HI_ADDR(18)      <= VZ80_A18_INTn_V_R;
    VZ80_HI_ADDR(19)      <= VZ80_A19_HALTn_V_VSYNCn;
    VZ80_HI_ADDR(20)      <= VZ80_A20_RFSHn_V_HSYNCn;
    VZ80_HI_ADDR(21)      <= VWAITn_A21_V_CSYNC;
    VZ80_HI_ADDR(22)      <= '0';
    VZ80_HI_ADDR(23)      <= '0';

    -- Tri-state controls. If the hard Z80 is being used then tri-state output signals.
    VZ80_MREQn            <= 'Z';
    VZ80_IORQn            <= 'Z';
    VZ80_RDn              <= 'Z';
    VZ80_WRn              <= 'Z';
    VZ80_M1n              <= 'Z';
    VZ80_A20_RFSHn_V_HSYNCn<= 'Z';
    VZ80_A19_HALTn_V_VSYNCn<= 'Z';
    VZ80_ADDR             <= (others => 'Z');
    VZ80_BUSACKni         <= VZ80_BUSRQn;
    VZ80_BUSRQn           <= VZ80_BUSRQn_V_G                                 when MODE_CPLD_MB_VIDEOn = '1'
                             else '1';
    VZ80_BUSACKn          <= VZ80_BUSACKni;

end architecture;
