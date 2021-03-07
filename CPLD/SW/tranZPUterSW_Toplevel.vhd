---------------------------------------------------------------------------------------------------------
--
-- Name:            tranZPUterSW_Toplevel.vhd
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
--                  <ar 2021  - Synchronize with SW700 development in order to progress MZ800 adaptation.
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
use work.tranZPUterSW_pkg.all;
library altera;
use altera.altera_syn_attributes.all;

entity tranZPUterSW is
    port (
        -- Z80 Address and Data.
        Z80_HI_ADDR               : inout std_logic_vector(23 downto 16);                -- Hi address. These are the upper bank bits allowing 512K of address space. They are directly set by the K64F when accessing RAM or FPGA and set by the FPGA according to memory mode.
        Z80_RA_ADDR               : out   std_logic_vector(15 downto 12);                -- Row address - RAM is subdivided into 4K blocks which can be remapped as needed. This is required for the MZ80B emulation where memory changes location according to mode.
        Z80_ADDR                  : inout std_logic_vector(15 downto 0);
        Z80_DATA                  : inout std_logic_vector(7 downto 0);

        -- Z80 Control signals.
        Z80_BUSRQn                : out   std_logic;
        Z80_BUSACKn               : in    std_logic;
        Z80_INTn                  : inout std_logic;
        Z80_IORQn                 : in    std_logic;
        Z80_MREQn                 : inout std_logic;
        Z80_NMIn                  : inout std_logic;
        Z80_RDn                   : in    std_logic;
        Z80_WRn                   : in    std_logic;
        Z80_RESETn                : in    std_logic;
        Z80_HALTn                 : in    std_logic;
        Z80_WAITn                 : out   std_logic;
        Z80_M1n                   : in    std_logic;
        Z80_RFSHn                 : in    std_logic;
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
        SYS_WRn                   : out   std_logic;
        SYS_RDn                   : out   std_logic;

        -- RAM control.
        RAM_CSn                   : out   std_logic;
        RAM_OEn                   : out   std_logic;
        RAM_WEn                   : out   std_logic;
    
        -- Graphics Board I/O and Memory Select.
        INCLK                     : in    std_logic;
        OUTDATA                   : out   std_logic_vector(3 downto 0);

        -- Clocks, system and K64F generated.
        SYSCLK                    : in    std_logic;
        CTLCLK                    : in    std_logic
    );
END entity;

architecture rtl of tranZPUterSW is

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
        SYS_WRn                   => SYS_WRn,
        SYS_RDn                   => SYS_RDn,

        -- RAM control.
        RAM_CSn                   => RAM_CSn,
        RAM_OEn                   => RAM_OEn,
        RAM_WEn                   => RAM_WEn,

        -- Graphics Board I/O and Memory Select.
        INCLK                     => INCLK,
        OUTDATA                   => OUTDATA,

        -- Clocks, system and K64F generated.
        SYSCLK                    => SYSCLK,
        CTLCLK                    => CTLCLK
    );

end architecture;
