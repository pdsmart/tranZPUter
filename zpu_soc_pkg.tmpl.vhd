---------------------------------------------------------------------------------------------------------
--
-- Name:            zpu_soc_pkg.vhd
-- Created:         January 2019
-- Author(s):       Philip Smart
-- Description:     ZPU System On a Chip Configuration
--                                                     
--                  This module contains the System on a Chip configuration for the ZPU.
--
-- Credits:         
-- Copyright:       (c) 2018 Philip Smart <philip.smart@net2net.org>
--
-- History:         January 2019 - Initial creation.
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
use work.zpu_pkg.all;

package zpu_soc_pkg is

    -- Choose which CPU to instantiate depending on requirements. Warning, keep the below 5 lines exactly the same
    -- or ensure you update the Makefile as they are set by the Makefile to generate zpu_soc_pkg.vhd
    --
    constant ZPU_SMALL                :     integer    := 0;                                                -- Use the SMALL CPU.
    constant ZPU_MEDIUM               :     integer    := 0;                                                -- Use the MEDIUM CPU.
    constant ZPU_FLEX                 :     integer    := 0;                                                -- Use the FLEX CPU.
    constant ZPU_EVO                  :     integer    := 0;                                                -- Use the EVOLUTION CPU.
    constant ZPU_EVO_MINIMAL          :     integer    := 0;                                                -- Use the Minimalist EVOLUTION CPU.

    -- Frequencies for the various boards.
    --
    constant SYSCLK_E115_FREQ         :     integer    := 100000000;                                        -- E115 FPGA Board
    constant SYSCLK_QMV_FREQ          :     integer    := 100000000;                                        -- QMTECH Cyclone V FPGA Board
    constant SYSCLK_DE0_FREQ          :     integer    := 100000000;                                        -- DE0-Nano FPGA Board
    constant SYSCLK_DE10_FREQ         :     integer    := 100000000;                                        -- DE10-Nano FPGA Board
    constant SYSCLK_CYC1000_FREQ      :     integer    := 100000000;                                        -- Trenz CYC1000 FPGA Board

    -- ID for the various ZPU models. The format is 2 bytes, MSB=<Model>, LSB=<Revision>
    constant ZPU_ID_SMALL             :     integer    := 16#0101#;                                         -- ID for the ZPU Small in this package.
    constant ZPU_ID_MEDIUM            :     integer    := 16#0201#;                                         -- ID for the ZPU Medium in this package.
    constant ZPU_ID_FLEX              :     integer    := 16#0301#;                                         -- ID for the ZPU Flex in this package.
    constant ZPU_ID_EVO               :     integer    := 16#0401#;                                         -- ID for the ZPU Evo in this package.
    constant ZPU_ID_EVO_MINIMAL       :     integer    := 16#0501#;                                         -- ID for the ZPU Evo Minimal in this package.

    -- EVO CPU specific configuration.
    constant MAX_EVO_L1CACHE_BITS     :     integer    := 4;                                                -- Maximum size in instructions of the Level 0 instruction cache governed by the number of bits, ie. 8 = 256 instruction cache.
    constant MAX_EVO_L2CACHE_BITS     :     integer    := 11;                                               -- Maximum bit size in bytes of the Level 2 instruction cache governed by the number of bits, ie. 8 = 256 byte cache.
    constant MAX_EVO_MXCACHE_BITS     :     integer    := 3;                                                -- Maximum size of the memory transaction cache governed by the number of bits.
    constant MAX_EVO_MIN_L1CACHE_BITS :     integer    := 4;                                                -- Maximum size in instructions of the Level 0 instruction cache governed by the number of bits, ie. 8 = 256 instruction cache.
    constant MAX_EVO_MIN_L2CACHE_BITS :     integer    := 12;                                               -- Maximum bit size in bytes of the Level 2 instruction cache governed by the number of bits, ie. 8 = 256 byte cache.
    constant MAX_EVO_MIN_MXCACHE_BITS :     integer    := 3;                                                -- Maximum size of the memory transaction cache governed by the number of bits.

    -- Settings for various IO devices.
    --
    constant MAX_RX_FIFO_BITS         :     integer    := 8;                                                -- Size of UART RX Fifo.
    constant MAX_TX_FIFO_BITS         :     integer    := 8;                                                -- Size of UART TX Fifo.
    constant MAX_UART_DIVISOR_BITS    :     integer    := 16;                                               -- Maximum number of bits for the UART clock rate generator divisor.
    constant INTR_MAX                 :     integer    := 16;                                               -- Maximum number of interrupt inputs.
    constant SYSTEM_FREQUENCY         :     integer    := 100000000;                                        -- Default system clock frequency if not overriden by top level.
--    constant SYSCLK_FREQUENCY         :     integer    := 1000;                                             -- System clock in MHz x 10
--    constant SYSCLK_HZ                :     integer    := SYSCLK_FREQUENCY*100000;                          -- System clock in Hertz
--    constant UART_RESET_COUNT         :     integer    := ((SYSCLK_FREQUENCY*100000)/300)*8;                -- Count of system clock ticks for a UART break to be recognised as a system reset.

    -- SoC specific options.
    --
    constant SOC_IMPL_WB              :     boolean    := EVO_USE_WB_BUS;                                   -- Implement the Wishbone bus and all enabled devices.
    constant SOC_IMPL_WB_I2C          :     boolean    := false;                                            -- Implement I2C over wishbone interface.
    constant SOC_IMPL_WB_SDRAM        :     boolean    := true;                                             -- Implement SDRAM over wishbone interface.
    constant SOC_IMPL_TIMER1          :     boolean    := true;                                             -- Implement Timer 1, an array of prescaled downcounter with enable.
    constant SOC_TIMER1_COUNTERS      :     integer    := 0;                                                -- Number of downcounters in Timer 1. Value is a 2^ array of counters, so 0 = 1 counter.
    constant SOC_IMPL_PS2             :     boolean    := false;                                            -- Implement PS2 keyboard and mouse hardware.
    constant SOC_IMPL_SPI             :     boolean    := false;                                            -- Implement Serial Peripheral Inteface(s).
    constant SOC_IMPL_SD              :     boolean    := true;                                             -- Implement SD Card interface.
    constant SOC_SD_DEVICES           :     integer    := 1;                                                -- Number of SD card channels implemented.
    constant SOC_IMPL_INTRCTL         :     boolean    := true;                                             -- Implement the prioritised interrupt controller.
    constant SOC_IMPL_IOCTL           :     boolean    := false;                                            -- Implement the IOCTL controller (specific to the MiSTer project).
    constant SOC_IMPL_TCPU            :     boolean    := true;                                             -- Implement the TCPU controller for controlling the Z80 Bus. 
    constant SOC_IMPL_SOCCFG          :     boolean    := true;                                             -- Implement the SoC Configuration information registers.
    constant SOC_IMPL_BRAM            :     boolean    := true;                                             -- Implement BRAM for the BIOS and initial Stack.
    constant SOC_IMPL_RAM             :     boolean    := false;                                            -- Implement RAM using BRAM, typically for Application programs seperate to BIOS.
    constant SOC_IMPL_DRAM            :     boolean    := false;                                            -- Implement Dynamic RAM and controller.
    constant SOC_IMPL_INSN_BRAM       :     boolean    := true;                                             -- Implement dedicated instruction BRAM for the EVO CPU. Any addr access beyond the BRAM size goes to normal memory.
    constant SOC_MAX_ADDR_BRAM_BIT    :     integer    := 15;                                               -- Max address bit of the System BRAM ROM/Stack in bytes, ie. 15 = 32KB or 8K 32bit words. NB. For non evo CPUS you must adjust the maxMemBit parameter in zpu_pkg.vhd to be the same.
    constant SOC_ADDR_BRAM_START      :     integer    := 0;                                                -- Start address of BRAM.
    constant SOC_ADDR_BRAM_END        :     integer    := SOC_ADDR_BRAM_START+(2**SOC_MAX_ADDR_BRAM_BIT);   -- End address of BRAM = START + 2^SOC_MAX_ADDR_INSN_BRAM_BIT.
    constant SOC_MAX_ADDR_RAM_BIT     :     integer    := 23;                                               -- Max address bit of the System RAM.
    constant SOC_ADDR_RAM_START       :     integer    := 16777216;                                         -- Start address of RAM.
    constant SOC_ADDR_RAM_END         :     integer    := SOC_ADDR_RAM_START+(2**SOC_MAX_ADDR_RAM_BIT);     -- End address of RAM =  START + 2^SOC_MAX_ADDR_INSN_BRAM_BIT.
    constant SOC_MAX_ADDR_INSN_BRAM_BIT:    integer    := SOC_MAX_ADDR_BRAM_BIT;                            -- Max address bit of the dedicated instruction BRAM in bytes, ie. 15 = 32KB or 8K 32bit words.
    constant SOC_ADDR_INSN_BRAM_START :     integer    := 0;                                                -- Start address of dedicated instrution BRAM.
    constant SOC_ADDR_INSN_BRAM_END   :     integer    := SOC_ADDR_BRAM_START+(2**SOC_MAX_ADDR_INSN_BRAM_BIT); -- End address of dedicated instruction BRAM = START + 2^SOC_MAX_ADDR_INSN_BRAM_BIT.
    constant SOC_RESET_ADDR_CPU       :     integer    := SOC_ADDR_BRAM_START;                              -- Initial address to start execution from after reset.
    constant SOC_START_ADDR_MEM       :     integer    := SOC_ADDR_BRAM_START;                              -- Start location of program memory (BRAM/ROM/RAM).
    constant SOC_STACK_ADDR           :     integer    := SOC_ADDR_BRAM_END - 8;                            -- Stack start address (BRAM/RAM).
    constant SOC_ADDR_IO_START        :     integer    := (2**(maxAddrBit-WB_ACTIVE)) - (2**maxIOBit);      -- Start address of the Evo Direct Memory Mapped IO region.
    constant SOC_ADDR_IO_END          :     integer    := (2**(maxAddrBit-WB_ACTIVE)) - 1;                  -- End address of the Evo Direct Memory Mapped IO region.
    constant SOC_WB_IO_START          :     integer    := 32505856;                                         -- Start address of IO range.
    constant SOC_WB_IO_END            :     integer    := 33554431;                                         -- End address of IO range.

    -- Ranges used throughout the SOC source.
    subtype ADDR_BIT_BRAM_RANGE       is natural range SOC_MAX_ADDR_BRAM_BIT-1 downto 0;                    -- Address range of the onboard B(lock)RAM - 1 byte aligned
    subtype ADDR_BIT_BRAM_16BIT_RANGE is natural range SOC_MAX_ADDR_BRAM_BIT-1 downto 1;                    -- Address range of the onboard B(lock)RAM - 2 bytes aligned
    subtype ADDR_BIT_BRAM_32BIT_RANGE is natural range SOC_MAX_ADDR_BRAM_BIT-1 downto minAddrBit;           -- Address range of the onboard B(lock)RAM - 4 bytes aligned
    subtype ADDR_BIT_RAM_RANGE        is natural range SOC_MAX_ADDR_RAM_BIT-1  downto 0;                    -- Address range of external RAM (BRAM, Dynamic, Static etc) - 1 byte aligned
    subtype ADDR_BIT_RAM_16BIT_RANGE  is natural range SOC_MAX_ADDR_RAM_BIT-1  downto 1;                    -- Address range of external RAM (BRAM, Dynamic, Static etc) - 2 bytes aligned
    subtype ADDR_BIT_RAM_32BIT_RANGE  is natural range SOC_MAX_ADDR_RAM_BIT-1  downto minAddrBit;           -- Address range of external RAM (BRAM, Dynamic, Static etc) - 4 bytes aligned
--  subtype ADDR_DECODE_BRAM_RANGE    is natural range maxAddrBit-1            downto SOC_MAX_ADDR_BRAM_BIT;-- Decode range for selection of the BRAM within the address space.
--  subtype ADDR_DECODE_RAM_RANGE     is natural range maxAddrBit-1            downto SOC_MAX_ADDR_RAM_BIT; -- Decode range for selection of the RAM within the address space.
    subtype IO_DECODE_RANGE           is natural range maxAddrBit-WB_ACTIVE-1  downto maxIOBit;             -- Upper bits in memory defining the IO block within the address space for the EVO cpu IO. All other models use ioBit.
--    subtype WB_IO_DECODE_RANGE        is natural range maxAddrBit-1            downto maxIOBit;             -- Upper bits in memory defining the IO block within the address space for the EVO cpu IO. All other models use ioBit.
 
    -- Device options
    type CardType_t is (SD_CARD_E, SDHC_CARD_E);                                                     -- Define the different types of SD cards.


    ------------------------------------------------------------ 
    -- Constants
    ------------------------------------------------------------ 
    
    constant YES  : std_logic := '1';
    constant NO   : std_logic := '0';
    constant HI   : std_logic := '1';
    constant LO   : std_logic := '0';
    constant ONE  : std_logic := '1';
    constant ZERO : std_logic := '0';
    constant HIZ  : std_logic := 'Z';

    ------------------------------------------------------------ 
    -- Function prototypes
    ------------------------------------------------------------ 
    -- Find the maximum of two integers.
    function IntMax(a : in integer; b : in integer) return integer;

    ------------------------------------------------------------ 
    -- Records
    ------------------------------------------------------------ 

    ------------------------------------------------------------ 
    -- Components
    ------------------------------------------------------------
    component dualport_ram is
        port (
            clk : in std_logic;
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

    component SDCard is
        generic (
          FREQ_G                      : real              := 100.0;       -- Master clock frequency (MHz).
          INIT_SPI_FREQ_G             : real              := 0.4;         -- Slow SPI clock freq. during initialization (MHz).
          SPI_FREQ_G                  : real              := 25.0;        -- Operational SPI freq. to the SD card (MHz).
          BLOCK_SIZE_G                : natural           := 512;         -- Number of bytes in an SD card block or sector.
          CARD_TYPE_G                 : CardType_t      := SD_CARD_E    -- Type of SD card connected to this controller.
          );
        port (
          -- Host-side interface signals.
          clk_i                       : in    std_logic;                -- Master clock.
          reset_i                     : in    std_logic   := NO;        -- active-high, synchronous  reset.
          rd_i                        : in    std_logic   := NO;        -- active-high read block request.
          wr_i                        : in    std_logic   := NO;        -- active-high write block request.
          continue_i                  : in    std_logic   := NO;        -- If true, inc address and continue R/W.
          addr_i                      : in    std_logic_vector(31 downto 0) := x"00000000";  -- Block address.
          data_i                      : in    std_logic_vector(7 downto 0)  := x"00";        -- Data to write to block.
          data_o                      : out   std_logic_vector(7 downto 0)  := x"00";        -- Data read from block.
          busy_o                      : out   std_logic;                -- High when controller is busy performing some operation.
          hndShk_i                    : in    std_logic;                -- High when host has data to give or has taken data.
          hndShk_o                    : out   std_logic;                -- High when controller has taken data or has data to give.
          error_o                     : out   std_logic_vector(15 downto 0) := (others => NO);
          -- I/O signals to the external SD card.
          cs_bo                       : out   std_logic   := HI;        -- Active-low chip-select.
          sclk_o                      : out   std_logic   := LO;        -- Serial clock to SD card.
          mosi_o                      : out   std_logic   := HI;        -- Serial data output to SD card.
          miso_i                      : in    std_logic   := ZERO       -- Serial data input from SD card.
        );
    end component;

end zpu_soc_pkg;

------------------------------------------------------------ 
-- Function definitions.
------------------------------------------------------------ 
package body zpu_soc_pkg is
    
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

end package body;
