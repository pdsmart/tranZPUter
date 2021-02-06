---------------------------------------------------------------------------------------------------------
--
-- Name:            tranZPUterSW700_Toplevel.vhd
-- Created:         June 2020
-- Author(s):       Philip Smart
-- Description:     tranZPUter SW CPLD Top Level module.
--                                                     
--                  This module contains the basic pin definition of the CPLD<->logic needed in the project.
--
-- Credits:         
-- Copyright:       (c) 2018-20 Philip Smart <philip.smart@net2net.org>
--
-- History:         June 2020 - Initial creation.
--                  Oct 2020  - Cut taken from the tranZPUterSW 2.1 to be used for the tranZPUter SW 700
--                              as there are a lot of pin and logic differences. The tranZPUter SW is still
--                              under development so didnt make sense to share the same files and make 
--                              them conditional.
--                  Nov 2020 -  Version 1.3 board needs major changes as the FPGA is now capable of 
--                              supporting soft CPU's, an original target of the tranZPUter project.
--                              The keyboard mapping has been removed as more complex signal switching is
--                              needed and this logic will be placed in the FPGA. The CPLD still remains
--                              the central memory management for both hard and soft CPU's.
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
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.tranZPUterSW700_pkg.all;
library altera;
use altera.altera_syn_attributes.all;

entity tranZPUterSW700 is
    port (
        -- Z80 Address and Data.
        Z80_HI_ADDR               : inout std_logic_vector(23 downto 16);                -- Hi address. These are the upper bank bits allowing 512K of address space. They are directly set by the K64F when accessing RAM or FPGA and set by the FPGA according to memory mode.
        Z80_RA_ADDR               : out   std_logic_vector(15 downto 12);                -- Row address - RAM is subdivided into 4K blocks which can be remapped as needed. This is required for the MZ80B emulation where memory changes location according to mode.
        Z80_ADDR                  : inout std_logic_vector(15 downto 0);
        Z80_DATA                  : inout std_logic_vector(7 downto 0);

        -- Z80 Control signals.
        Z80_BUSRQn                : out   std_logic;
        Z80_BUSACKn               : in    std_logic;
        Z80_INTn                  : in    std_logic;
        Z80_IORQn                 : inout std_logic;
        Z80_MREQn                 : inout std_logic;
        Z80_NMIn                  : in    std_logic;
        Z80_RDn                   : inout std_logic;
        Z80_WRn                   : inout std_logic;
        Z80_RESETn                : in    std_logic;
        Z80_HALTn                 : inout std_logic;
        Z80_WAITn                 : inout std_logic;
        Z80_M1n                   : inout std_logic;
        Z80_RFSHn                 : inout std_logic;
        Z80_CLK                   : out   std_logic;

        -- K64F control signals.
        CTL_MBSEL                 : in    std_logic;                                     -- Select mainboard, 1 = mainboard, 0 = tranzputer bus.
        CTL_BUSRQn                : in    std_logic;
        CTL_BUSACKn               : out   std_logic;                                     -- Combined BUSACK signal to the K64F
        CTL_HALTn                 : out   std_logic;
        CTL_M1n                   : out   std_logic;
        CTL_RFSHn                 : out   std_logic;
        CTL_WAITn                 : in    std_logic;
        SVCREQn                   : out   std_logic;

        -- Mainboard signals which are blended with K64F signals to activate corresponding Z80 functionality.
        SYS_BUSACKn               : out   std_logic;
        SYS_BUSRQn                : in    std_logic;
        SYS_WAITn                 : in    std_logic;

        -- RAM control.
        RAM_CSn                   : out   std_logic;
        RAM_OEn                   : out   std_logic;
        RAM_WEn                   : out   std_logic;
    
        -- FPGA address, data and control signals.
        VZ80_ADDR                 : inout std_logic_vector(15 downto 0);
        VZ80_DATA                 : inout std_logic_vector(7 downto 0);
        VZ80_MREQn                : inout std_logic;
        VZ80_IORQn                : inout std_logic;
        VZ80_RDn                  : inout std_logic;
        VZ80_WRn                  : inout std_logic;
        VZ80_M1n                  : inout std_logic;
        VZ80_BUSACKn              : in    std_logic;
        VZ80_CLK                  : out   std_logic;
        VIDEO_RDn                 : out   std_logic;
        VIDEO_WRn                 : out   std_logic;

        -- FPGA control signals muxed with Graphics signals from the mainboard.
        VWAITn_A21_V_CSYNC        : inout std_logic;                                     -- Upper address bit for access to FPGA resources / Wait signal from asserted when Video RAM is busy / Mainboard Video Composite Sync.
        VZ80_A20_RFSHn_V_HSYNC    : inout std_logic;                                     -- Upper address bit for access to FPGA resources / Voltage translated Z80 RFSH / Mainboard Video Horizontal Sync.
        VZ80_A19_HALTn_V_VSYNC    : inout std_logic;                                     -- Upper address bit for access to FPGA resources / Voltage translated Z80 HALT / Mainboard Video Vertical Sync.
        VZ80_BUSRQn_V_G           : out   std_logic;                                     -- Voltage translated Z80 BUSRQ / Mainboard Video Green signal.
        VZ80_A16_WAITn_V_B        : out   std_logic;                                     -- Upper address bit for access to FPGA resources / Voltage translated Z80 WAIT / Mainboard Video Blue signal.
        VZ80_A18_INTn_V_R         : out   std_logic;                                     -- Upper address bit for access to FPGA resources / Voltage translated Z80 INT / Mainboard Video Red signal.
        VZ80_A17_NMIn_V_COLR      : out   std_logic;                                     -- Upper address bit for access to FPGA resources / Voltage translated Z80 NMI / Mainboard Video Colour Modulation Frequency.
        CSYNC_IN                  : in    std_logic;                                     -- Mainboard Video Composite Sync.
        HSYNC_IN                  : in    std_logic;                                     -- Mainboard Video Horizontal Sync.
        VSYNC_IN                  : in    std_logic;                                     -- Mainboard Video Vertical Sync.
        G_IN                      : in    std_logic;                                     -- Mainboard Video Green signal.
        B_IN                      : in    std_logic;                                     -- Mainboard Video Blue signal.
        R_IN                      : in    std_logic;                                     -- Mainboard Video Red signal.
        COLR_IN                   : in    std_logic;                                     -- Mainboard Video Colour Modulation Frequency.

        -- Clocks, system and K64F generated.
        SYSCLK                    : in    std_logic;
        CTLCLK                    : in    std_logic 
    );
END entity;

architecture rtl of tranZPUterSW700 is

begin

    cpldl512Toplevel : entity work.cpld512
    --generic map
    --(
    --)
    port map
    (    
        Z80_HI_ADDR               => Z80_HI_ADDR,
        Z80_RA_ADDR               => Z80_RA_ADDR,
        Z80_ADDR                  => Z80_ADDR,
        Z80_DATA                  => Z80_DATA,

        -- Z80 Control signals.
        Z80_BUSRQn                => Z80_BUSRQn,
        Z80_BUSACKn               => Z80_BUSACKn,
        Z80_INTn                  => Z80_INTn,
        Z80_IORQn                 => Z80_IORQn,
        Z80_MREQn                 => Z80_MREQn,
        Z80_NMIn                  => Z80_NMIn,
        Z80_RDn                   => Z80_RDn,
        Z80_WRn                   => Z80_WRn,
        Z80_RESETn                => Z80_RESETn,
        Z80_HALTn                 => Z80_HALTn,
        Z80_WAITn                 => Z80_WAITn,
        Z80_M1n                   => Z80_M1n,
        Z80_RFSHn                 => Z80_RFSHn,
        Z80_CLK                   => Z80_CLK,

        -- K64F control signals.
        CTL_MBSEL                 => CTL_MBSEL,
        CTL_BUSRQn                => CTL_BUSRQn,
        CTL_BUSACKn               => CTL_BUSACKn,
        CTL_HALTn                 => CTL_HALTn,
        CTL_M1n                   => CTL_M1n,
        CTL_RFSHn                 => CTL_RFSHn,
        CTL_WAITn                 => CTL_WAITn,
        SVCREQn                   => SVCREQn,

        -- Mainboard signals which are blended with K64F signals to activate corresponding Z80 functionality.
        SYS_BUSACKn               => SYS_BUSACKn,
        SYS_BUSRQn                => SYS_BUSRQn,
        SYS_WAITn                 => SYS_WAITn,

        -- RAM control.
        RAM_CSn                   => RAM_CSn,
        RAM_OEn                   => RAM_OEn,
        RAM_WEn                   => RAM_WEn,

        -- FPGA address, data and control signals.
        VZ80_ADDR                 => VZ80_ADDR,                              
        VZ80_DATA                 => VZ80_DATA,                              
        VZ80_MREQn                => VZ80_MREQn,                              
        VZ80_IORQn                => VZ80_IORQn,                              
        VZ80_RDn                  => VZ80_RDn,                              
        VZ80_WRn                  => VZ80_WRn,                              
        VZ80_M1n                  => VZ80_M1n,                              
        VZ80_BUSACKn              => VZ80_BUSACKn,                              
        VZ80_CLK                  => VZ80_CLK,                              
        VIDEO_RDn                 => VIDEO_RDn,                              
        VIDEO_WRn                 => VIDEO_WRn,                              

        -- FPGA control signals muxed with Graphics signals from the mainboard.
        VWAITn_A21_V_CSYNC        => VWAITn_A21_V_CSYNC,                          -- Upper address bit for access to FPGA resources / Wait signal from asserted when Video RAM is busy / Mainboard Video Composite Sync.
        VZ80_A20_RFSHn_V_HSYNC    => VZ80_A20_RFSHn_V_HSYNC,                      -- Upper address bit for access to FPGA resources / Voltage translated Z80 RFSH / Mainboard Video Horizontal Sync.
        VZ80_A19_HALTn_V_VSYNC    => VZ80_A19_HALTn_V_VSYNC,                      -- Upper address bit for access to FPGA resources / Voltage translated Z80 HALT / Mainboard Video Vertical Sync.
        VZ80_BUSRQn_V_G           => VZ80_BUSRQn_V_G,                             -- Voltage translated Z80 BUSRQ / Mainboard Video Green signal.
        VZ80_A16_WAITn_V_B        => VZ80_A16_WAITn_V_B,                          -- Upper address bit for access to FPGA resources / Voltage translated Z80 WAIT / Mainboard Video Blue signal.
        VZ80_A18_INTn_V_R         => VZ80_A18_INTn_V_R,                           -- Upper address bit for access to FPGA resources / Voltage translated Z80 INT / Mainboard Video Red signal.
        VZ80_A17_NMIn_V_COLR      => VZ80_A17_NMIn_V_COLR,                        -- Upper address bit for access to FPGA resources / Voltage translated Z80 NMI / Mainboard Video Colour Modulation Frequency.
        CSYNC_IN                  => CSYNC_IN,                                    -- Mainboard Video Composite Sync.
        HSYNC_IN                  => HSYNC_IN,                                    -- Mainboard Video Horizontal Sync.
        VSYNC_IN                  => VSYNC_IN,                                    -- Mainboard Video Vertical Sync.
        G_IN                      => G_IN,                                        -- Mainboard Video Green signal.
        B_IN                      => B_IN,                                        -- Mainboard Video Blue signal.
        R_IN                      => R_IN,                                        -- Mainboard Video Red signal.
        COLR_IN                   => COLR_IN,                                     -- Mainboard Video Colour Modulation Frequency.

        -- Clocks, system and K64F generated.
        SYSCLK                    => SYSCLK,
        CTLCLK                    => CTLCLK
    );

end architecture;
