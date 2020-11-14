---------------------------------------------------------------------------------------------------------
--
-- Name:            VideoController700_Toplevel.vhd
-- Created:         June 2020
-- Author(s):       Philip Smart
-- Description:     MZ80A Video Module FPGA Top Level module.
--                                                     
--                  This module contains the definition of the video controller used in tranZPUter SW 700
--                  board for the Sharp MZ700. The controller emulates the video logic of the Sharp MZ80A,
--                  MZ-700 and MZ80B including pixel graphics.
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
use work.VideoController700_pkg.all;
library altera;
use altera.altera_syn_attributes.all;

entity VideoController700 is
    port (
        -- Primary and video clocks.
        CLOCK_50                  : in    std_logic;                                     -- 50MHz base clock for video timing and gate clocking.
        CTLCLK                    : in    std_logic;                                     -- tranZPUter external clock (for overclocking).
        SYSCLK                    : in    std_logic;                                     -- Mainboard system clock.
        VZ80_CLK                  : in    std_logic;                                     -- Z80 clock combining SYSCLK and CTLCLK.

        -- V[name] = Voltage translated signals which mirror the mainboard signals but at a lower voltage.
        -- Address Bus
        VADDR                     : in    std_logic_vector(15 downto 0);                 -- Z80 Address bus.

        -- Data Bus
        VDATA                     : inout std_logic_vector(7 downto 0);                  -- Z80 Data bus.

        -- Control signals.
        VZ80_IORQn                : in    std_logic;                                     -- Z80 IORQ.
        VZ80_RDn                  : in    std_logic;                                     -- Z80 RDn.
        VZ80_WRn                  : in    std_logic;                                     -- Z80 WRn.
        VWAITn                    : out   std_logic;                                     -- WAIT signal to CPU when accessing video RAM when busy. 

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
        V_CSYNC                   : in    std_logic;                                     -- Composite sync from mainboard.
        V_HSYNCn                  : in    std_logic;                                     -- Horizontal sync (negative) from mainboard.
        V_VSYNCn                  : in    std_logic;                                     -- Vertical sync (negative) from mainboard.
        V_COLR                    : in    std_logic;                                     -- Composite and RF base frequency from mainboard.
        V_G                       : in    std_logic;                                     -- Digital Green (on/off) from mainboard.
        V_B                       : in    std_logic;                                     -- Digital Blue (on/off) from mainboard.
        V_R                       : in    std_logic                                      -- Digital Red (on/off) from mainboard.
    );
END entity;

architecture rtl of VideoController700 is

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
         inclk0                  => SYS_CLK,
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
    SFL : entity work.sfl
    port map
    (
        noe_in                      => '0' 
    );

    vcToplevel : entity work.VideoController
    --generic map
    --(
    --)
    port map
    (    
        -- Primary and video clocks.
        SYS_CLK                  => SYS_CLK,                                             -- 120MHz main FPGA clock.
        IF_CLK                   => VZ80_CLK,                                            -- Z80 runtime clock (product of SYSCLK and CTLCLK - variable frequency).
        VIDCLK_8MHZ              => VIDCLK_8MHZ,                                         -- 2x 8MHz base clock for video timing and gate clocking.
        VIDCLK_16MHZ             => VIDCLK_16MHZ,                                        -- 2x 16MHz base clock for video timing and gate clocking.
        VIDCLK_65MHZ             => VIDCLK_65MHZ,                                        -- 2x 65MHz base clock for video timing and gate clocking.
        VIDCLK_25_175MHZ         => VIDCLK_25_175MHZ,                                    -- 2x 25.175MHz base clock for video timing and gate clocking.
        VIDCLK_40MHZ             => VIDCLK_40MHZ,                                        -- 2x 40MHz base clock for video timing and gate clocking.
        VIDCLK_8_86719MHZ        => VIDCLK_8_86719MHZ,                                   -- 2x original MZ700 video clock.
        VIDCLK_17_7344MHZ        => VIDCLK_17_7344MHZ,                                   -- 2x original MZ700 colour modulator clock.

        -- V[name] = Voltage translated signals which mirror the mainboard signals but at a lower voltage.
        -- Address Bus
        VADDR                    => VADDR,                                               -- Z80 Address bus.

        -- Data Bus
        VDATA                    => VDATA,                                               -- Z80 Data bus.

        -- Control signals.
        VZ80_IORQn               => VZ80_IORQn,                                          -- Z80 IORQ.
        VZ80_RDn                 => VZ80_RDn,                                            -- Z80 RDn.
        VZ80_WRn                 => VZ80_WRn,                                            -- Z80 WRn.
        VWAITn                   => VWAITn,                                              -- WAIT signal to CPU when accessing video RAM when busy. 

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
        V_CSYNC                  => V_CSYNC,                                             -- Composite sync from mainboard.
        V_HSYNCn                 => V_HSYNCn,                                            -- Horizontal sync (negative) from mainboard.
        V_VSYNCn                 => V_VSYNCn,                                            -- Vertical sync (negative) from mainboard.
        V_COLR                   => V_COLR,                                              -- Composite and RF base frequency from mainboard.
        V_G                      => V_G,                                                 -- Digital Green (on/off) from mainboard.
        V_B                      => V_B,                                                 -- Digital Blue (on/off) from mainboard.
        V_R                      => V_R,                                                 -- Digital Red (on/off) from mainboard.

        -- Reset.
        VRESETn                  => RESETn                                               -- Internal reset.
    );

    -- Process to reset the FPGA based on the external RESET trigger, PLL's being locked
    -- and a counter to set minimum width.
    --
    FPGARESET: process(CLOCK_50, PLL_LOCKED, PLL_LOCKED2, PLL_LOCKED3)
    begin
       if PLL_LOCKED = '0' or PLL_LOCKED2 = '0' or PLL_LOCKED3 = '0' then
            RESET_COUNTER        <= (others => '1');
            RESETn               <= '0';

       elsif PLL_LOCKED = '1' and PLL_LOCKED2 = '1' and PLL_LOCKED3 = '1' then
            if rising_edge(CLOCK_50) then
                if RESET_COUNTER /= 0 then
                    RESET_COUNTER <= RESET_COUNTER - 1;
                elsif VZ80_WRn = '0' and VZ80_RDn = '0' then
                    RESETn        <= '0';
                elsif VZ80_WRn = '1' or VZ80_RDn = '1' then
                    RESETn        <= '1';
                end if;
            end if;
        end if;
    end process;

end architecture;
