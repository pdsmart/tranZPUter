---------------------------------------------------------------------------------------------------------
--
-- Name:            softT80_pkg.vhd
-- Created:         June 2020
-- Author(s):       Philip Smart
-- Description:     Share MZ series FPGA spft processor logic. This module implements a Z80 compatible
--                  processor such as the T80, AZ80 or NextZ80.
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
--                  Jan 2021 -  Further split as I seperate out the components into seperate modules for a
--                              more object orientated approach.
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
library pkgs;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package softT80_pkg is

    ------------------------------------------------------------ 
    -- Constants
    ------------------------------------------------------------ 

    -- Potential logic state constants.
    constant YES                      : std_logic := '1';
    constant NO                       : std_logic := '0';
    constant HI                       : std_logic := '1';
    constant LO                       : std_logic := '0';
    constant ONE                      : std_logic := '1';
    constant ZERO                     : std_logic := '0';
    constant HIZ                      : std_logic := 'Z';

    ------------------------------------------------------------ 
    -- Configurable parameters.
    ------------------------------------------------------------ 

    -- Add the Serial Flash Loader megafunction to enable programming of the EPCS64 NV FPGA Boot ROM.
    constant IMPL_SFL                 : boolean   := true;

    -- Soft CPU's to embed in the core.
    --
    constant IMPL_SOFTCPU_T80         : boolean   := true;
    constant IMPL_SOFTCPU_AZ80        : boolean   := false;
    constant IMPL_SOFTCPU_NEXTZ80     : boolean   := false;
    --constant IMPL_SOFTCPU_Z80         : boolean   := IMPL_SOFTCPU_T80 or IMPL_SOFTCPU_AZ80 or IMPL_SOFTCPU_NEXTZ80;

    ------------------------------------------------------------ 
    -- Function prototypes
    ------------------------------------------------------------ 
    -- Find the maximum of two integers.
    function IntMax(a : in integer; b : in integer) return integer;

    -- Find the number of bits required to represent an integer.
    function log2ceil(arg : positive) return natural;

    -- Function to calculate the number of whole 'clock' cycles in a given time period, the period being in ns.
    function clockTicks(period : in integer; clock : in integer) return integer;

    -- Function to reverse the order of the bits in a standard logic vector.
    -- ie. 1010 becomes 0101
    function reverse_vector(slv:std_logic_vector) return std_logic_vector; 

    -- Function to convert an integer (0 or 1) into std_logic.
    --
    function to_std_logic(i : in integer) return std_logic;

    -- Function to return the value of a bit as an integer for array indexing etc.
    function bit_to_integer( s : std_logic ) return natural;   

    ------------------------------------------------------------ 
    -- Records
    ------------------------------------------------------------ 

    ------------------------------------------------------------ 
    -- Components
    ------------------------------------------------------------

end softT80_pkg;

------------------------------------------------------------ 
-- Function definitions.
------------------------------------------------------------ 
package body softT80_pkg is
    
    -- Find the maximum of two integers.
    function IntMax(a : in integer; b : in integer) return integer is
    begin
        if a > b then
            return a;
        else
            return b;
        end if;
        return a;
    end function IntMax;

    -- Find the number of bits required to represent an integer.
    function log2ceil(arg : positive) return natural is
        variable tmp : positive     := 1;
        variable log : natural      := 0;
    begin
        if arg = 1 then
            return 0;
        end if;

        while arg > tmp loop
            tmp := tmp * 2;
            log := log + 1;
        end loop;
        return log;
    end function;

    -- Function to calculate the number of whole 'clock' cycles in a given time period, the period being in ns.
    function clockTicks(period : in integer; clock : in integer) return integer is
        variable ticks         : real;
        variable fracTicks     : real;
    begin
        ticks         := (Real(period) * Real(clock)) / 1000000000.0;
        fracTicks     := ticks - CEIL(ticks);
        if fracTicks > 0.0001 then
            return Integer(CEIL(ticks + 1.0));
        else
            return Integer(CEIL(ticks));
        end if;
    end function;

    function reverse_vector(slv:std_logic_vector) return std_logic_vector is 
       variable target : std_logic_vector(slv'high downto slv'low); 
    begin 
      for idx in slv'high downto slv'low loop 
        target(idx) := slv(slv'low + (slv'high-idx)); 
      end loop; 
      return target; 
    end reverse_vector;

    function to_std_logic(i : in integer) return std_logic is
    begin
      if i = 0 then
        return '0';
      end if;
      return '1';
    end function;

    -- Function to return the value of a bit as an integer for array indexing etc.
    function bit_to_integer( s : std_logic ) return natural is
    begin
        if s = '1' then
            return 1;
        else
            return 0;
        end if;
    end function;
end package body;
