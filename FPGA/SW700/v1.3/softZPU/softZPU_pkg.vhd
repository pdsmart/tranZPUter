---------------------------------------------------------------------------------------------------------
--
-- Name:            softZPU_pkg.vhd
-- Created:         December 2020
-- Author(s):       Philip Smart
-- Description:     Sharp MZ Series FPGA soft cpu module - ZPU.
--                                                     
--                  This module provides a soft CPU to the Sharp MZ Core running on a Sharp MZ-700 with
--                  the tranZPUter SW-700 v1.3-> board and will be migrated to the pure FPGA tranZPUter
--                  v2.2 board in due course.
--
-- Credits:         
-- Copyright:       (c) 2018-20 Philip Smart <philip.smart@net2net.org>
--
-- History:         Dec 2020  - Initial creation.
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
use     ieee.numeric_std.all;
use     ieee.math_real.all;
use     work.coreMZ_pkg.all;
use     work.zpu_pkg.all;
use     altera.altera_syn_attributes.all;
use     altera_mf.all;

package softZPU_pkg is
    ------------------------------------------------------------ 
    -- Function prototypes
    ------------------------------------------------------------ 
    -- Find the maximum of two integers.
    function IntMax(a : in integer; b : in integer) return integer;

    -- Find the number of bits required to represent an integer.
    function log2ceil(arg : positive) return natural;

    -- Function to calculate the number of whole 'clock' cycles in a given time period, the period being in ns.
    function clockTicks(period : in integer; clock : in integer) return integer;

    ------------------------------------------------------------ 
    -- Constants
    ------------------------------------------------------------ 

    -- Target board declaration.
    --
    constant BOARD_E115               :     boolean    := false;                                            -- E115 FPGA Board
    constant BOARD_QMV                :     boolean    := false;                                            -- QMTECH Cyclone V FPGA Board
    constant BOARD_DE0                :     boolean    := false;                                            -- DE0-Nano FPGA Board
    constant BOARD_DE10               :     boolean    := false;                                            -- DE10-Nano FPGA Board
    constant BOARD_CYC1000            :     boolean    := false;                                            -- Trenz CYC1000 FPGA Board
    constant BOARD_TRANZPUTER_SW700   :     boolean    := true;                                             -- tranZPUter SW-700 v1.3 Board.

    -- Frequencies for the various boards.
    --
    constant SYSCLK_E115_FREQ         :     integer    := 100000000;                                        -- E115 FPGA Board
    constant SYSCLK_QMV_FREQ          :     integer    := 100000000;                                        -- QMTECH Cyclone V FPGA Board
    constant SYSCLK_DE0_FREQ          :     integer    := 100000000;                                        -- DE0-Nano FPGA Board
    constant SYSCLK_DE10_FREQ         :     integer    := 100000000;                                        -- DE10-Nano FPGA Board
    constant SYSCLK_CYC1000_FREQ      :     integer    := 100000000;                                        -- Trenz CYC1000 FPGA Board
    constant SYSCLK_TRANZPUTER_SW_FREQ:     integer    := 50000000;                                         -- tranZPUter SW-700 v1.3-> board frequency.

    -- ID for the various ZPU models. The format is 2 bytes, MSB=<Model>, LSB=<Revision>
    constant ZPU_ID_SMALL             :     integer    := 16#0101#;                                         -- ID for the ZPU Small in this package.
    constant ZPU_ID_MEDIUM            :     integer    := 16#0201#;                                         -- ID for the ZPU Medium in this package.
    constant ZPU_ID_FLEX              :     integer    := 16#0301#;                                         -- ID for the ZPU Flex in this package.
    constant ZPU_ID_EVO               :     integer    := 16#0402#;                                         -- ID for the ZPU Evo in this package.
    constant ZPU_ID_EVO_MINIMAL       :     integer    := 16#0501#;                                         -- ID for the ZPU Evo Minimal in this package.

    -- EVO CPU specific configuration.
    constant MAX_EVO_L1CACHE_BITS     :     integer    := 6;                                                -- Maximum size in instructions of the Level 1 instruction cache governed by the number of bits, ie. 8 = 256 instruction cache.
    constant MAX_EVO_L2CACHE_BITS     :     integer    := 14;                                               -- Maximum bit size in bytes of the Level 2 instruction cache governed by the number of bits, ie. 8 = 256 byte cache.
    constant MAX_EVO_MXCACHE_BITS     :     integer    := 4;                                                -- Maximum size of the memory transaction cache governed by the number of bits.

    -- Settings for various IO devices.
    --
    constant SYSTEM_FREQUENCY         :     integer    := 100000000;                                        -- Default system clock frequency if not overriden in top level.

    -- Constants.
    --
    constant maxZ80BusBit             :     integer    := maxAddrBit - WB_ACTIVE - 4;                       -- Upper bit (to define range) of the Z80 Bus space in top section of address space.

    -- SoC specific options.
    --
    constant SOC_IMPL_Z80BUS          :     boolean    := true;                                             -- Implement a ZPU<->Z80 Bus interface.
    constant SOC_IMPL_TIMER1          :     boolean    := true;                                             -- Implement Timer 1, an array of prescaled downcounter with enable.
    constant SOC_TIMER1_COUNTERS      :     integer    := 0;                                                -- Number of downcounters in Timer 1. Value is a 2^ array of counters, so 0 = 1 counter.
    constant SOC_IMPL_INTRCTL         :     boolean    := true;                                             -- Implement the prioritised interrupt controller.
    constant SOC_INTR_MAX             :     integer    := 16;                                               -- Maximum number of interrupt inputs.
    constant SOC_IMPL_SOCCFG          :     boolean    := true;                                             -- Implement the SoC Configuration information registers.
    -- Main Boot BRAM on sysbus, contains startup firmware.
    constant SOC_IMPL_BRAM            :     boolean    := true;                                             -- Implement BRAM for the BIOS and initial Stack.
    constant SOC_IMPL_INSN_BRAM       :     boolean    := EVO_USE_INSN_BUS;                                 -- Implement dedicated instruction BRAM for the EVO CPU. Any addr access beyond the BRAM size goes to normal memory.
    constant SOC_MAX_ADDR_BRAM_BIT    :     integer    := 17;                                               -- Max address bit of the System BRAM ROM/Stack in bytes, ie. 15 = 32KB or 8K 32bit words. NB. For non evo CPUS you must adjust the maxMemBit parameter in zpu_pkg.vhd to be the same.
    constant SOC_ADDR_BRAM_START      :     integer    := 0;                                                -- Start address of BRAM.
    constant SOC_ADDR_BRAM_END        :     integer    := SOC_ADDR_BRAM_START+(2**SOC_MAX_ADDR_BRAM_BIT);   -- End address of BRAM = START + 2^SOC_MAX_ADDR_INSN_BRAM_BIT.
    -- Secondary block of sysbus RAM, typically implemented in BRAM.
    constant SOC_IMPL_RAM             :     boolean    := false;                                            -- Implement RAM using BRAM, typically for Application programs seperate to BIOS.
    constant SOC_MAX_ADDR_RAM_BIT     :     integer    := 16;                                               -- Max address bit of the System RAM.
    constant SOC_ADDR_RAM_START       :     integer    := 131072;                                           -- Start address of RAM.
    constant SOC_ADDR_RAM_END         :     integer    := SOC_ADDR_RAM_START+(2**SOC_MAX_ADDR_RAM_BIT);     -- End address of RAM =  START + 2^SOC_MAX_ADDR_INSN_BRAM_BIT.
    -- Instruction BRAM on sysbus, typically as a 2nd port on the main Boot BRAM (ie. dualport).
    constant SOC_MAX_ADDR_INSN_BRAM_BIT:    integer    := SOC_MAX_ADDR_BRAM_BIT;                            -- Max address bit of the dedicated instruction BRAM in bytes, ie. 15 = 32KB or 8K 32bit words.
    constant SOC_ADDR_INSN_BRAM_START :     integer    := 0;                                                -- Start address of dedicated instrution BRAM.
    constant SOC_ADDR_INSN_BRAM_END   :     integer    := SOC_ADDR_BRAM_START+(2**SOC_MAX_ADDR_INSN_BRAM_BIT); -- End address of dedicated instruction BRAM = START + 2^SOC_MAX_ADDR_INSN_BRAM_BIT.

    -- CPU specific settings.
    -- Define the address which is first executed upon reset, stack address, Sysbus I/O Region, Wishbone I/O Region.
    constant SOC_RESET_ADDR_CPU       :     integer    := SOC_ADDR_BRAM_START;                              -- Initial address to start execution from after reset.
    constant SOC_START_ADDR_MEM       :     integer    := SOC_ADDR_BRAM_START;                              -- Start location of program memory (BRAM/ROM/RAM).
    constant SOC_STACK_ADDR           :     integer    := SOC_ADDR_BRAM_END - 8;                            -- Stack start address (BRAM/RAM).
    constant SOC_ADDR_IO_START        :     integer    := (2**(maxAddrBit-WB_ACTIVE)) - (2**maxIOBit);      -- Start address of the Evo Direct Memory Mapped IO region.
    constant SOC_ADDR_IO_END          :     integer    := (2**(maxAddrBit-WB_ACTIVE)) - 1;                  -- End address of the Evo Direct Memory Mapped IO region.
    constant SOC_ADDR_Z80BUS_START    :     integer    := SOC_ADDR_IO_START - (2**maxZ80BusBit);            -- Start address of the Evo Direct Memory Mapped Z80 Bus region.
    constant SOC_ADDR_Z80BUS_END      :     integer    := SOC_ADDR_IO_END - 1;                              -- End address of the Evo Direct Memory Mapped Z80 Bus region.

    -- ZPU Evo configuration
    --
    -- Optional Evo CPU hardware features to be implemented.
    constant IMPL_EVO_OPTIMIZE_IM     :     boolean    := true;                                             -- If the instruction cache is enabled, optimise Im instructions to gain speed.
    -- Optional Evo CPU instructions to be implemented in hardware:
    constant IMPL_EVO_ASHIFTLEFT      :     boolean    := true;                                             -- Arithmetic Shift Left (uses same logic so normally combined with ASHIFTRIGHT and LSHIFTRIGHT).
    constant IMPL_EVO_ASHIFTRIGHT     :     boolean    := true;                                             -- Arithmetic Shift Right.
    constant IMPL_EVO_CALL            :     boolean    := true;                                             -- Call to direct address.
    constant IMPL_EVO_CALLPCREL       :     boolean    := true;                                             -- Call to indirect address (add offset to program counter).
    constant IMPL_EVO_DIV             :     boolean    := true;                                             -- 32bit signed division.
    constant IMPL_EVO_EQ              :     boolean    := true;                                             -- Equality test.
    constant IMPL_EVO_EXTENDED_INSN   :     boolean    := true;                                             -- Extended multibyte instruction set.
    constant IMPL_EVO_FIADD32         :     boolean    := false;                                            -- Fixed point Q17.15 addition.
    constant IMPL_EVO_FIDIV32         :     boolean    := false;                                            -- Fixed point Q17.15 division.
    constant IMPL_EVO_FIMULT32        :     boolean    := false;                                            -- Fixed point Q17.15 multiplication.
    constant IMPL_EVO_LOADB           :     boolean    := true;                                             -- Load single byte from memory.
    constant IMPL_EVO_LOADH           :     boolean    := true;                                             -- Load half word (16bit) from memory.
    constant IMPL_EVO_LSHIFTRIGHT     :     boolean    := true;                                             -- Logical shift right.
    constant IMPL_EVO_MOD             :     boolean    := true;                                             -- 32bit modulo (remainder after division).
    constant IMPL_EVO_MULT            :     boolean    := true;                                             -- 32bit signed multiplication.
    constant IMPL_EVO_NEG             :     boolean    := true;                                             -- Negate value in TOS.
    constant IMPL_EVO_NEQ             :     boolean    := true;                                             -- Not equal test.
    constant IMPL_EVO_POPPCREL        :     boolean    := true;                                             -- Pop a value into the Program Counter from a location relative to the Stack Pointer.
    constant IMPL_EVO_PUSHSPADD       :     boolean    := true;                                             -- Add a value to the Stack pointer and push it onto the stack.
    constant IMPL_EVO_STOREB          :     boolean    := true;                                             -- Store/Write a single byte to memory/IO.
    constant IMPL_EVO_STOREH          :     boolean    := true;                                             -- Store/Write a half word (16bit) to memory/IO.
    constant IMPL_EVO_SUB             :     boolean    := true;                                             -- 32bit signed subtract.
    constant IMPL_EVO_XOR             :     boolean    := true;                                             -- Exclusive or of value in TOS.

    -- Ranges used throughout the SOC source.
    subtype ADDR_BIT_BRAM_RANGE       is natural range SOC_MAX_ADDR_BRAM_BIT-1   downto 0;              -- Address range of the onboard B(lock)RAM - 1 byte aligned
    subtype ADDR_16BIT_BRAM_RANGE     is natural range SOC_MAX_ADDR_BRAM_BIT-1   downto 1;              -- Address range of the onboard B(lock)RAM - 2 bytes aligned
    subtype ADDR_32BIT_BRAM_RANGE     is natural range SOC_MAX_ADDR_BRAM_BIT-1   downto minAddrBit;     -- Address range of the onboard B(lock)RAM - 4 bytes aligned
    subtype ADDR_BIT_RAM_RANGE        is natural range SOC_MAX_ADDR_RAM_BIT-1    downto 0;              -- Address range of external RAM (BRAM, Dynamic, Static etc) - 1 byte aligned
    subtype ADDR_16BIT_RAM_RANGE      is natural range SOC_MAX_ADDR_RAM_BIT-1    downto 1;              -- Address range of external RAM (BRAM, Dynamic, Static etc) - 2 bytes aligned
    subtype ADDR_32BIT_RAM_RANGE      is natural range SOC_MAX_ADDR_RAM_BIT-1    downto minAddrBit;     -- Address range of external RAM (BRAM, Dynamic, Static etc) - 4 bytes aligned
--  subtype ADDR_DECODE_BRAM_RANGE    is natural range maxAddrBit-1 downto SOC_MAX_ADDR_BRAM_BIT;       -- Decode range for selection of the BRAM within the address space.
--  subtype ADDR_DECODE_RAM_RANGE     is natural range maxAddrBit-1 downto SOC_MAX_ADDR_RAM_BIT;        -- Decode range for selection of the RAM within the address space.
    subtype IO_DECODE_RANGE           is natural range maxAddrBit-WB_ACTIVE-1    downto maxIOBit;       -- Upper bits in memory defining the IO block within the address space for the EVO cpu IO. All other models use ioBit.
    subtype Z80BUS_DECODE_RANGE       is natural range maxAddrBit-WB_ACTIVE-1    downto maxZ80BusBit;   -- Upper bits in memory defining the a block within the address space for the Z80 Bus.
 
    -- Potential logic state constants.
    constant YES                      : std_logic := '1';
    constant NO                       : std_logic := '0';
    constant HI                       : std_logic := '1';
    constant LO                       : std_logic := '0';
    constant ONE                      : std_logic := '1';
    constant ZERO                     : std_logic := '0';
    constant HIZ                      : std_logic := 'Z';


    ------------------------------------------------------------ 
    -- Records
    ------------------------------------------------------------ 

    ------------------------------------------------------------ 
    -- Components
    ------------------------------------------------------------
    component dualport_ram is
        port (
            clk                       : in    std_logic;
            memAWriteEnable           : in    std_logic;
            memAAddr                  : in    std_logic_vector(ADDR_32BIT_RANGE);
            memAWrite                 : in    std_logic_vector(WORD_32BIT_RANGE);
            memARead                  : out   std_logic_vector(WORD_32BIT_RANGE);
            memBWriteEnable           : in    std_logic;
            memBAddr                  : in    std_logic_vector(ADDR_32BIT_RANGE);
            memBWrite                 : in    std_logic_vector(WORD_32BIT_RANGE);
            memBRead                  : out   std_logic_vector(WORD_32BIT_RANGE)
        );
    end component;        

    component dpram
        generic (
            init_file                 : string;
            widthad_a                 : natural;
            width_a                   : natural;
            widthad_b                 : natural;
            width_b                   : natural;
            outdata_reg_a             : string := "UNREGISTERED";
            outdata_reg_b             : string := "UNREGISTERED"
        );
        port (
            clock_a                   : in    std_logic  := '1';
            clocken_a                 : in    std_logic  := '1';
            address_a                 : in    std_logic_vector (widthad_a-1 downto 0);
            data_a                    : in    std_logic_vector (width_a-1 downto 0);
            wren_a                    : in    std_logic  := '0';
            q_a                       : out   std_logic_vector (width_a-1 downto 0);

            clock_b                   : in    std_logic;
            clocken_b                 : in    std_logic  := '1';
            address_b                 : in    std_logic_vector (widthad_b-1 downto 0);
            data_b                    : in    std_logic_vector (width_b-1 downto 0);
            wren_b                    : in    std_logic  := '0';
            q_b                       : out   std_logic_vector (width_b-1 downto 0)
      );
    end component;

end softZPU_pkg;

------------------------------------------------------------ 
-- Function definitions.
------------------------------------------------------------ 
package body softZPU_pkg is
    
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

end package body;
