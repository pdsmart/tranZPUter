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
        Z80_HI_ADDR     : out   std_logic_vector(18 downto 15);
        Z80_ADDR        : inout std_logic_vector(15 downto 0);
        Z80_DATA        : inout std_logic_vector(7 downto 0);
        VADDR           : out   std_logic_vector(13 downto 11);

        -- Z80 Control signals.
        Z80_BUSRQn      : out   std_logic;
        Z80_BUSACKn     : in    std_logic;
        Z80_INTn        : inout std_logic;
        Z80_IORQn       : in    std_logic;
        Z80_MREQn       : inout std_logic;
        Z80_NMIn        : inout std_logic;
        Z80_RDn         : inout std_logic;
        Z80_WRn         : inout std_logic;
        Z80_RESETn      : in    std_logic;
        Z80_HALTn       : in    std_logic;
        Z80_WAITn       : out   std_logic;
        Z80_M1n         : in    std_logic;
        Z80_RFSHn       : in    std_logic;
        Z80_CLK         : out   std_logic;

        -- K64F control signals.
        CTL_BUSACKn     : in    std_logic;
        CTL_BUSRQn      : in    std_logic;
        CTL_HALTn       : out   std_logic;
        CTL_M1n         : out   std_logic;
        CTL_RFSHn       : out   std_logic;
        CTL_WAITn       : in    std_logic;
        SVCREQn         : out   std_logic;
        SYSREQn         : out   std_logic;
        TZ_BUSACKn      : out   std_logic;
        ENIOWAIT        : out   std_logic;
        Z80_MEM         : out   std_logic_vector(4 downto 0);

        -- Mainboard signals which are blended with K64F signals to activate corresponding Z80 functionality.
        SYS_BUSACKn     : out   std_logic;
        SYS_BUSRQn      : in    std_logic;
        SYS_WAITn       : in    std_logic;

        -- RAM control.
        RAM_CSn         : out   std_logic;
        RAM_OEn         : out   std_logic;
        RAM_WEn         : out   std_logic;
    
        -- Graphics Board I/O and Memory Select.
        VMEM_CSn        : out   std_logic;

        -- Clocks, system and K64F generated.
        SYSCLK          : in    std_logic;
        CTLCLK          : in    std_logic;
        CTL_CLKSLCT     : out   std_logic;

        -- Mode signals.
        CFG_MZ80A       : in    std_logic;
        CFG_MZ700       : in    std_logic;

        -- Reserved.
        TBA             : in    std_logic_vector(8 downto 0)

        -- JTAG / ISP
        --TCK             : in    std_logic;
        --TDI             : in    std_logic;
        --TDO             : out   std_logic;
        --TMS             : in    std_logic 
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
        Z80_HI_ADDR     => Z80_HI_ADDR,
        Z80_ADDR        => Z80_ADDR,
        Z80_DATA        => Z80_DATA,
        VADDR           => VADDR,

        -- Z80 Control signals.
        Z80_BUSRQn      => Z80_BUSRQn,
        Z80_BUSACKn     => Z80_BUSACKn,
        Z80_INTn        => Z80_INTn,
        Z80_IORQn       => Z80_IORQn,
        Z80_MREQn       => Z80_MREQn,
        Z80_NMIn        => Z80_NMIn,
        Z80_RDn         => Z80_RDn,
        Z80_WRn         => Z80_WRn,
        Z80_RESETn      => Z80_RESETn,
        Z80_HALTn       => Z80_HALTn,
        Z80_WAITn       => Z80_WAITn,
        Z80_M1n         => Z80_M1n,
        Z80_RFSHn       => Z80_RFSHn,
        Z80_CLK         => Z80_CLK,

        -- K64F control signals.
        CTL_BUSACKn     => CTL_BUSACKn,
        CTL_BUSRQn      => CTL_BUSRQn,
        CTL_HALTn       => CTL_HALTn,
        CTL_M1n         => CTL_M1n,
        CTL_RFSHn       => CTL_RFSHn,
        CTL_WAITn       => CTL_WAITn,
        SVCREQn         => SVCREQn,
        SYSREQn         => SYSREQn,
        TZ_BUSACKn      => TZ_BUSACKn,
        ENIOWAIT        => ENIOWAIT,
        Z80_MEM         => Z80_MEM,

        -- Mainboard signals which are blended with K64F signals to activate corresponding Z80 functionality.
        SYS_BUSACKn     => SYS_BUSACKn,
        SYS_BUSRQn      => SYS_BUSRQn,
        SYS_WAITn       => SYS_WAITn,

        -- RAM control.
        RAM_CSn         => RAM_CSn,
        RAM_OEn         => RAM_OEn,
        RAM_WEn         => RAM_WEn,

        -- Graphics Board I/O and Memory Select.
        VMEM_CSn        => VMEM_CSn,

        -- Clocks, system and K64F generated.
        SYSCLK          => SYSCLK,
        CTLCLK          => CTLCLK,
        CTL_CLKSLCT     => CTL_CLKSLCT,

        -- Mode signals.
        CFG_MZ80A       => CFG_MZ80A,
        CFG_MZ700       => CFG_MZ700,

        -- Reserved.
        TBA             => TBA
    );

end architecture;
