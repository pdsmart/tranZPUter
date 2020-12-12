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
        Z80_HI_ADDR     : out   std_logic_vector(18 downto 12);
        Z80_ADDR        : inout std_logic_vector(15 downto 0);
        Z80_DATA        : inout std_logic_vector(7 downto 0);

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
        Z80_MEM         : out   std_logic_vector(4 downto 0);

        -- Mainboard signals which are blended with K64F signals to activate corresponding Z80 functionality.
        SYS_BUSACKn     : out   std_logic;
        SYS_BUSRQn      : in    std_logic;
        SYS_WAITn       : in    std_logic;

        -- RAM control.
        RAM_CSn         : out   std_logic;
        RAM_OEn         : out   std_logic;
        RAM_WEn         : out   std_logic;
    
        -- Graphics FPGA address, data and control signals.
        VADDR           : out   std_logic_vector(15 downto 0);
        VDATA           : inout std_logic_vector(7 downto 0);
        VZ80_IORQn      : out   std_logic;
        VZ80_RDn        : out   std_logic;
        VZ80_WRn        : out   std_logic;
        VZ80_CLK        : out   std_logic;
        VWAITn          : in    std_logic;                         -- Wait signal from asserted when Video RAM is busy.

        -- Graphics signal in/out.
        V_CSYNC         : out   std_logic;
        V_HSYNC         : out   std_logic;
        V_VSYNC         : out   std_logic;
        V_G             : out   std_logic;
        V_B             : out   std_logic;
        V_R             : out   std_logic;
        V_COLR          : out   std_logic;
        CSYNC_IN        : in    std_logic;
      --CVIDEO_IN       : in    std_logic;
        HSYNC_IN        : in    std_logic;
        VSYNC_IN        : in    std_logic;
        G_IN            : in    std_logic;
        B_IN            : in    std_logic;
        R_IN            : in    std_logic;
        COLR_IN         : in    std_logic;

        -- Clocks, system and K64F generated.
        SYSCLK          : in    std_logic;
        CTLCLK          : in    std_logic;
        CTL_CLKSLCT     : out   std_logic 
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
        Z80_HI_ADDR     => Z80_HI_ADDR,
        Z80_ADDR        => Z80_ADDR,
        Z80_DATA        => Z80_DATA,

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
        Z80_MEM         => Z80_MEM,

        -- Mainboard signals which are blended with K64F signals to activate corresponding Z80 functionality.
        SYS_BUSACKn     => SYS_BUSACKn,
        SYS_BUSRQn      => SYS_BUSRQn,
        SYS_WAITn       => SYS_WAITn,

        -- RAM control.
        RAM_CSn         => RAM_CSn,
        RAM_OEn         => RAM_OEn,
        RAM_WEn         => RAM_WEn,

        -- Graphics FPGA address, data and control signals.
        VADDR           => VADDR,
        VDATA           => VDATA,
        VZ80_IORQn      => VZ80_IORQn,
        VZ80_RDn        => VZ80_RDn,
        VZ80_WRn        => VZ80_WRn,
        VWAITn          => VWAITn,                         -- Wait signal from asserted when Video RAM is busy.
        VZ80_CLK        => VZ80_CLK,

        -- Graphics signal in/out.
        V_CSYNC         => V_CSYNC,
        V_HSYNC         => V_HSYNC,
        V_VSYNC         => V_VSYNC,
        V_G             => V_G,
        V_B             => V_B,
        V_R             => V_R,
        V_COLR          => V_COLR,
        CSYNC_IN        => CSYNC_IN,
      --CVIDEO_IN       => CVIDEO_IN,
        HSYNC_IN        => HSYNC_IN,
        VSYNC_IN        => VSYNC_IN,
        G_IN            => G_IN,
        B_IN            => B_IN,
        R_IN            => R_IN,
        COLR_IN         => COLR_IN,

        -- Clocks, system and K64F generated.
        SYSCLK          => SYSCLK,
        CTLCLK          => CTLCLK,
        CTL_CLKSLCT     => CTL_CLKSLCT 
    );

end architecture;
