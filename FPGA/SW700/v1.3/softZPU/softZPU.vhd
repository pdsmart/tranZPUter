---------------------------------------------------------------------------------------------------------
--
-- Name:            softZPU.vhd
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
use     work.coreMZ_pkg.all;
use     work.softZPU_pkg.all;
use     work.zpu_pkg.all;
use     altera.altera_syn_attributes.all;
use     altera_mf.all;

entity softZPU is
    generic (
        SYSCLK_FREQUENCY          : integer := SYSTEM_FREQUENCY                          -- System clock frequency
    );
    Port (
        -- System signals and clocks.
        SYS_RESETn                : in    std_logic;                                     -- System reset.
        ZPU_CLK                   : in    std_logic;                                     -- Clock for ZPU cpu.
        Z80_CLK                   : in    std_logic;                                     -- Underlying hardware system clock

        -- Software controlled signals.
        SW_RESET                  : in    std_logic;                                     -- Software controlled reset.
        SW_CLKEN                  : in    std_logic;                                     -- Software controlled clock enable.
        SW_CPUEN                  : in    std_logic;                                     -- Software controlled CPU enable.

        -- Direct access to the video controller, bypassing the CPLD Memory management.
        VIDEO_ADDR                : out   std_logic_vector(23 downto 0);                 -- Direct video controller addressing, bypass CPLD memory manager and operate at 32bits.
        VIDEO_DATA_IN             : in    std_logic_vector(31 downto 0);                 -- Video controller to ZPU data in.
        VIDEO_DATA_OUT            : out   std_logic_vector(31 downto 0);                 -- ZPU to Video controller data out.
        VIDEO_WRn                 : out   std_logic;                                     -- Direct video write.
        VIDEO_RDn                 : out   std_logic;                                     -- Direct video read.
        VIDEO_WR_BYTE             : out   std_logic;                                     -- Signal to indicate a byte should be written not a 32bit word.
        VIDEO_WR_HWORD            : out   std_logic;                                     -- Signal to indicate a 16bit half word should be written not a 32bit word.

        -- External access to internal BRAM memory.
        INT_MEM_DATA_IN           : in    std_logic_vector(WORD_32BIT_RANGE);            -- Internal RAM block data to write to RAM.
        INT_MEM_DATA_OUT          : out   std_logic_vector(WORD_32BIT_RANGE);            -- Internal RAM block data read from RAM.
        INT_MEM_ADDR              : in    std_logic_vector(ADDR_BIT_RANGE);              -- 24bit address bus to address RAM.
        INT_MEM_WRITE_EN          : in    std_logic;                                     -- Write to external RAM.
        INT_MEM_WRITE_BYTE_EN     : in    std_logic;                                     -- Write is 1 byte wide.
        INT_MEM_WRITE_HWORD_EN    : in    std_logic;                                     -- Write is 1 half word wide.

        -- Bus request/ack mechanism.
        MEM_BUSRQ                 : in    std_logic;                                     -- Memory interface bus request signal. Set to 1 to request bus control.
        MEM_BUSACK                : out   std_logic;                                     -- Memory bus acknowledge signal. set to 1 when bus control granted.
      
        -- Core Sharp MZ signals.
        ZPU80_WAITn               : in    std_logic;                                     -- WAITn signal into the CPU to prolong a memory cycle.
        ZPU80_INTn                : in    std_logic;                                     -- INTn signal for maskable interrupts.
        ZPU80_NMIn                : in    std_logic;                                     -- NMIn non maskable interrupt input.
        ZPU80_BUSRQn              : in    std_logic;                                     -- BUSRQn signal to request CPU go into tristate and relinquish bus.
        ZPU80_M1n                 : out   std_logic;                                     -- M1n Machine Cycle 1 signal. M1 and MREQ active = opcode fetch, M1 and IORQ active = interrupt, vector can be read from D0-D7.
        ZPU80_MREQn               : out   std_logic;                                     -- MREQn signal indicates that the address bus holds a valid address for reading or writing memory.
        ZPU80_IORQn               : out   std_logic;                                     -- IORQn signal indicates that the address bus (A0-A7) holds a valid address for reading or writing and I/O device.
        ZPU80_RDn                 : out   std_logic;                                     -- RDn signal indicates that data is ready to be read from a memory or I/O device to the CPU.
        ZPU80_WRn                 : out   std_logic;                                     -- WRn signal indicates that data is going to be written from the CPU data bus to a memory or I/O device.
        ZPU80_RFSHn               : out   std_logic;                                     -- RFSHn signal to indicate dynamic memory refresh can take place.
        ZPU80_HALTn               : out   std_logic;                                     -- HALTn signal indicates that the CPU has executed a "HALT" instruction.
        ZPU80_BUSACKn             : out   std_logic;                                     -- BUSACKn signal indicates that the CPU address bus, data bus, and control signals have entered their HI-Z states, and that the external circuitry can now control these lines.
        ZPU80_ADDR                : out   std_logic_vector(15 downto 0);                 -- 16 bit address lines.
        ZPU80_DATA_IN             : in    std_logic_vector(7 downto 0);                  -- 8 bit data bus in.
        ZPU80_DATA_OUT            : out   std_logic_vector(7 downto 0);                  -- 8 bit data bus out.

        -- Debug.
        DEBUG_TXD_IN              : in    std_logic;                                     -- Serial debug loop, used as output when debug not enabled.
        DEBUG_TXD_OUT             : out   std_logic                                      -- Debug serial output when debug enabled. / DEBUG_TXD_IN when debug disabled.
    );
END entity;

architecture rtl of softZPU is

    -- ZPU and SoC
    --
    signal ZPU_RESETn             :       std_logic;                                     -- Internal Reset to the ZPU, based on system and programmable reset.
    signal DEBUG_TXD              :       std_logic;                                     -- ZPU debug output stream when debug enabled.

    -- Millisecond counter
    signal MICROSEC_DOWN_COUNTER  :       unsigned(23 downto 0);                         -- Allow for 16 seconds delay.
    signal MILLISEC_DOWN_COUNTER  :       unsigned(17 downto 0);                         -- Allow for 262 seconds delay.
    signal MILLISEC_UP_COUNTER    :       unsigned(31 downto 0);                         -- Up counter allowing for 49 days count in milliseconds.
    signal SECOND_DOWN_COUNTER    :       unsigned(11 downto 0);                         -- Allow for 1 hour in seconds delay.
    signal MICROSEC_DOWN_TICK     :       integer range 0 to 150;                        -- Independent tick register to ensure down counter is accurate.
    signal MILLISEC_DOWN_TICK     :       integer range 0 to 150*1000;                   -- Independent tick register to ensure down counter is accurate.
    signal SECOND_DOWN_TICK       :       integer range 0 to 150*1000000;                -- Independent tick register to ensure down counter is accurate.
    signal MILLISEC_UP_TICK       :       integer range 0 to 150*1000;                   -- Independent tick register to ensure up counter is accurate.
    signal MICROSEC_DOWN_INTR     :       std_logic;                                     -- Interrupt when counter reaches 0.
    signal MICROSEC_DOWN_INTR_EN  :       std_logic;                                     -- Interrupt enable for microsecond down counter.
    signal MILLISEC_DOWN_INTR     :       std_logic;                                     -- Interrupt when counter reaches 0.
    signal MILLISEC_DOWN_INTR_EN  :       std_logic;                                     -- Interrupt enable for millisecond down counter.
    signal SECOND_DOWN_INTR       :       std_logic;                                     -- Interrupt when counter reaches 0.
    signal SECOND_DOWN_INTR_EN    :       std_logic;                                     -- Interrupt enable for second down counter.
    signal RTC_MICROSEC_TICK      :       integer range 0 to 150;                        -- Allow for frequencies upto 150MHz.
    signal RTC_MICROSEC_COUNTER   :       integer range 0 to 1000;                       -- Real Time Clock counters.
    signal RTC_MILLISEC_COUNTER   :       integer range 0 to 1000;
    signal RTC_MILLISEC_FS_COUNTER:       unsigned(31 downto 0);                         -- Real time millisecond counter from reset (epoch).
    signal RTC_SECOND_COUNTER     :       integer range 0 to 60;
    signal RTC_MINUTE_COUNTER     :       integer range 0 to 60;
    signal RTC_HOUR_COUNTER       :       integer range 0 to 24;
    signal RTC_DAY_COUNTER        :       integer range 1 to 32;
    signal RTC_MONTH_COUNTER      :       integer range 1 to 13;
    signal RTC_YEAR_COUNTER       :       integer range 0 to 4095;
    signal RTC_TICK_HALT          :       std_logic;
    
    -- Timer register block signals
    signal TIMER_REG_REQ          :       std_logic;
    signal TIMER1_TICK            :       std_logic;

   -- ZPU signals
    signal MEM_BUSY               :       std_logic;
    signal IO_WAIT_SD             :       std_logic;
    signal IO_WAIT_INTR           :       std_logic;
    signal IO_WAIT_TIMER1         :       std_logic;
    signal IO_WAIT_Z80BUS         :       std_logic;
    signal IO_WAIT_VIDEO          :       std_logic;
    signal MEM_DATA_READ          :       std_logic_vector(WORD_32BIT_RANGE);
    signal MEM_DATA_WRITE         :       std_logic_vector(WORD_32BIT_RANGE);
    signal MEM_ADDR               :       std_logic_vector(ADDR_BIT_RANGE);
    signal MEM_WRITE_ENABLE       :       std_logic; 
    signal MEM_WRITE_ENABLE_LAST  :       std_logic_vector(2 downto 0); 
    signal MEM_WRITE_BYTE_ENABLE  :       std_logic; 
    signal MEM_WRITE_HWORD_ENABLE :       std_logic; 
    signal MEM_READ_ENABLE        :       std_logic;
    signal MEM_READ_ENABLE_LAST   :       std_logic_vector(2 downto 0);
    signal MEM_DATA_READ_INSN     :       std_logic_vector(WORD_64BIT_RANGE);
    signal MEM_ADDR_INSN          :       std_logic_vector(ADDR_BIT_RANGE);
    signal MEM_READ_ENABLE_INSN   :       std_logic;
    signal MEM_BUSACKi            :       std_logic;
    signal ZPU_MEM_BUSACK         :       std_logic;
    signal IO_DATA_READ           :       std_logic_vector(WORD_32BIT_RANGE);
    signal IO_DATA_READ_INTRCTL   :       std_logic_vector(WORD_32BIT_RANGE);
    signal IO_DATA_READ_SOCCFG    :       std_logic_vector(WORD_32BIT_RANGE);
    signal Z80_DATA_IN            :       std_logic_vector(WORD_32BIT_RANGE);            -- Data read and assembled from the Z80 bus.
    signal Z80_START_XACT         :       std_logic := '0';                              -- Z80 transaction start flag.
    signal Z80_CLK_EDGE           :       std_logic_vector(2 downto 0);
    signal ZPU_CLKEN              :       std_logic;

    -- ZPU ROM/BRAM/RAM/Stack signals.
    signal MEM_A_WRITE_ENABLE     :       std_logic;
    signal MEM_A_ADDR             :       std_logic_vector(ADDR_32BIT_RANGE);
    signal MEM_A_WRITE            :       std_logic_vector(WORD_32BIT_RANGE);
    signal MEM_B_WRITE_ENABLE     :       std_logic;
    signal MEM_B_ADDR             :       std_logic_vector(ADDR_32BIT_RANGE);
    signal MEM_B_WRITE            :       std_logic_vector(WORD_32BIT_RANGE);
    signal MEM_A_READ             :       std_logic_vector(WORD_32BIT_RANGE);
    signal MEM_B_READ             :       std_logic_vector(WORD_32BIT_RANGE);

    -- Interrupt signals
    signal INT_TRIGGERS           :       std_logic_vector(SOC_INTR_MAX downto 0);
    signal INT_ENABLE             :       std_logic_vector(SOC_INTR_MAX downto 0);
    signal INT_STATUS             :       std_logic_vector(SOC_INTR_MAX downto 0);
    signal INT_REQ                :       std_logic;
    signal INT_TRIGGER            :       std_logic;
    signal INT_ACK                :       std_logic;
    signal INT_DONE               :       std_logic;
    
    -- ZPU ROM/BRAM/RAM Access
    signal BRAM_SELECT            :       std_logic;
    signal INT_MEM_WR_LASTn       :       std_logic_vector(1 downto 0);
    signal BRAM_WREN              :       std_logic;
    signal BRAM_ADDR              :       std_logic_vector(23 downto 0);
    signal BRAM_BYTE_ENABLE       :       std_logic;
    signal BRAM_HWORD_ENABLE      :       std_logic;
    signal BRAM_DATA_IN           :       std_logic_vector(31 downto 0);
    
    -- IO Chip selects
    signal IO_SELECT              :       std_logic;                                     -- IO Range 0x<msb=0>7FFFFxxx of devices connected to the ZPU system bus.
    signal IO_INTR_SELECT         :       std_logic;                                     -- Interrupt Range 0xFFFFFBxx
    signal IO_TIMER_SELECT        :       std_logic;                                     -- Timer Range 0xFFFFFCxx
    signal Z80BUS_CS              :       std_logic;                                     -- Z80 Bus select. The Z80 has a window within the ZPU system bus address space.
    signal VIDEO_CS               :       std_logic;                                     -- Video controller select.
    signal VIDEO_8BIT_CS          :       std_logic;                                     -- 8bit register region within the Video controller selection window is active.
    signal INTR0_CS               :       std_logic;                                     -- 0xB00-B0F
    signal TIMER0_CS              :       std_logic;                                     -- 0xC00-C0F Millisecond timer.
    signal TIMER1_CS              :       std_logic;                                     -- 0xC10-C1F
    signal SOCCFG_CS              :       std_logic;                                     -- 0xF00-F0F

    -- Debug signals.
  --signal BRAM_SELECT2           :       std_logic;
  --signal BRAM_WREN2             :       std_logic;
  --signal BRAM_DATA_READ2        :       std_logic_vector(WORD_32BIT_RANGE);            -- Data output from BRAM.

    -- BRAM
    signal BRAM_DATA_READ         :       std_logic_vector(WORD_32BIT_RANGE);            -- Data output from BRAM.

    function to_std_logic(L: boolean) return std_logic is
    begin
        if L then
            return('1');
        else
            return('0');
        end if;
    end function to_std_logic;

begin

    -- Process to reliably reset the ZPU. The ZPU is disabled whilst in hard CPU mode, once switched to soft CPU, the reset is 
    -- activated and held low whilst the CPLD changes its state.
    process(SYS_RESETn, ZPU_CLK, SW_RESET, SW_CPUEN)
        variable ZPU_RESET_COUNTER: unsigned(15 downto 0) := (others => '1');
    begin
        if SYS_RESETn = '0' then
            ZPU_RESET_COUNTER                 := (others => '1');
            ZPU_RESETn                        <= '0';
            MEM_READ_ENABLE_LAST              <= (others => '0');
            MEM_WRITE_ENABLE_LAST             <= (others => '0');

        else
            if rising_edge(ZPU_CLK) then

                -- If reset enabled or the CPU is disabled or changed, hold CPU in reset.
                if SW_RESET = '1' or SW_CPUEN = '0' then
                    ZPU_RESET_COUNTER         := (others => '1');
                    ZPU_RESETn                <= '0';
                else

                    if ZPU_RESET_COUNTER = 0 then
                        ZPU_RESETn            <= '1';
                    end if;

                    if ZPU_RESET_COUNTER /= 0 then
                        ZPU_RESET_COUNTER     := ZPU_RESET_COUNTER - 1;
                    end if;
                end if;

            end if;

            if falling_edge(ZPU_CLK) then
                -- Edge detection for read/write signals. Most I/O operations need a read signal longer than 1 clock so BUSY needs to be asserted in order to prolong the read cycle. 
                -- 
                MEM_READ_ENABLE_LAST          <= MEM_READ_ENABLE_LAST(1 downto 0) & MEM_READ_ENABLE;
                MEM_WRITE_ENABLE_LAST         <= MEM_WRITE_ENABLE_LAST(1 downto 0) & MEM_WRITE_ENABLE;
            end if;
        end if;
    end process;

    ------------------------------------------------------------------------------------
    -- Soft CPU BRAM.
    ------------------------------------------------------------------------------------    

    -- Process to bring the external Write signal into sync with the ZPU_CLK. The external signal operates asynchronously.
    --
    process(ZPU_CLK, ZPU_RESETn, INT_MEM_WRITE_EN)
    begin
        if ZPU_RESETn = '0' then
            INT_MEM_WR_LASTn        <= (others => '1');

        elsif falling_edge(ZPU_CLK) then
            INT_MEM_WR_LASTn        <= INT_MEM_WR_LASTn(0) & INT_MEM_WRITE_EN;
        end if;
    end process;

    -- System BRAM, single port.
    SOFTCPUBRAM : entity work.SinglePortBootBRAM
       generic map (
           addrbits              => 17
       )
       port map (
           clk                   => ZPU_CLK,
           memAAddr              => BRAM_ADDR(16 downto 0),
           memAWriteEnable       => BRAM_WREN,
           memAWriteByte         => BRAM_BYTE_ENABLE,
           memAWriteHalfWord     => BRAM_HWORD_ENABLE,
           memAWrite             => BRAM_DATA_IN,
           memARead              => BRAM_DATA_READ
       );

    -- Enable write to System BRAM when selected and CPU in write state.
    BRAM_WREN                    <= '1'                                       when BRAM_SELECT = '1'                  and MEM_WRITE_ENABLE = '1'
                                    else
                                    '1'                                       when BRAM_SELECT = '1'                  and INT_MEM_WR_LASTn = "10"
                                    else '0';

    -- BRAM Range 0x00000000 - (2^SOC_MAX_ADDR_INSN_BRAM_BIT)-1
    BRAM_SELECT                  <= '1'                                       when (MEM_ADDR >= std_logic_vector(to_unsigned(SOC_ADDR_BRAM_START, MEM_ADDR'LENGTH)) and MEM_ADDR < std_logic_vector(to_unsigned(SOC_ADDR_BRAM_END, MEM_ADDR'LENGTH)))  and MEM_BUSACKi = '0'
                                    else
                                    '1'                                       when INT_MEM_ADDR(23 downto 17)= "0001000" and MEM_BUSACKi = '1'
                                    else '0';

    -- 24bit address bus, only a portion actually used for BRAM.
    BRAM_ADDR                    <= MEM_ADDR                                  when MEM_BUSACKi = '0'
                                    else
                                    INT_MEM_ADDR;

    -- Byte write enable.
    BRAM_BYTE_ENABLE             <= MEM_WRITE_BYTE_ENABLE                     when MEM_BUSACKi = '0'
                                    else
                                    INT_MEM_WRITE_BYTE_EN;
    -- Half word write enable.
    BRAM_HWORD_ENABLE            <= MEM_WRITE_HWORD_ENABLE                    when MEM_BUSACKi = '0'
                                    else
                                    INT_MEM_WRITE_HWORD_EN;

    -- Data output when bus under external control.
    INT_MEM_DATA_OUT             <= BRAM_DATA_READ;

    -- Data input into BRAM.
    BRAM_DATA_IN                 <= MEM_DATA_WRITE                            when MEM_BUSACKi = '0'
                                    else
                                    INT_MEM_DATA_IN;


    -- Debug code to replace the external 512K RAM with a chunk of BRAM for debugging comparisons.
--    SOFTCPUBRAM2 : entity work.SinglePortBRAM
--       generic map (
--           addrbits              => 15
--       )
--       port map (
--           clk                   => ZPU_CLK,
--           memAAddr              => BRAM_ADDR(14 downto 0),
--           memAWriteEnable       => BRAM_WREN2,
--           memAWriteByte         => BRAM_BYTE_ENABLE,
--           memAWriteHalfWord     => BRAM_HWORD_ENABLE,
--           memAWrite             => BRAM_DATA_IN,
--           memARead              => BRAM_DATA_READ2
--       );
--
--    BRAM_WREN2                   <= '1'                                       when BRAM_SELECT2 = '1'                  and MEM_WRITE_ENABLE = '1'
--                                    else
--                                    '1'                                       when BRAM_SELECT2 = '1'                  and INT_MEM_WR_LASTn = "10"
--                                    else '0';
--
--    BRAM_SELECT2                 <= '1'                                       when MEM_ADDR(Z80BUS_DECODE_RANGE) = std_logic_vector(to_unsigned(1,  maxAddrBit-WB_ACTIVE - maxZ80BusBit)) 
--                                    else '0';



    ------------------------------------------------------------------------------------
    -- ZPU Evolution and SoC
    ------------------------------------------------------------------------------------    
    ZPU0 : zpu_core_evo
        generic map (
            -- Optional hardware features to be implemented.
            IMPL_HW_BYTE_WRITE   => EVO_USE_HW_BYTE_WRITE,  -- Enable use of hardware direct byte write rather than read 33bits-modify 8 bits-write 32bits.
            IMPL_HW_WORD_WRITE   => EVO_USE_HW_WORD_WRITE,  -- Enable use of hardware direct byte write rather than read 32bits-modify 16 bits-write 32bits.
            IMPL_OPTIMIZE_IM     => IMPL_EVO_OPTIMIZE_IM,   -- If the instruction cache is enabled, optimise Im instructions to gain speed.
            IMPL_USE_INSN_BUS    => SOC_IMPL_INSN_BRAM,     -- Use a seperate bus to read instruction memory, normally implemented in BRAM.
            IMPL_USE_WB_BUS      => EVO_USE_WB_BUS,         -- Use the wishbone interface in addition to direct access bus.    
            -- Optional instructions to be implemented in hardware:
            IMPL_ASHIFTLEFT      => IMPL_EVO_ASHIFTLEFT,    -- Arithmetic Shift Left (uses same logic so normally combined with ASHIFTRIGHT and LSHIFTRIGHT).
            IMPL_ASHIFTRIGHT     => IMPL_EVO_ASHIFTRIGHT,   -- Arithmetic Shift Right.
            IMPL_CALL            => IMPL_EVO_CALL,          -- Call to direct address.
            IMPL_CALLPCREL       => IMPL_EVO_CALLPCREL,     -- Call to indirect address (add offset to program counter).
            IMPL_DIV             => IMPL_EVO_DIV,           -- 32bit signed division.
            IMPL_EQ              => IMPL_EVO_EQ,            -- Equality test.
            IMPL_EXTENDED_INSN   => IMPL_EVO_EXTENDED_INSN, -- Extended multibyte instruction set.
            IMPL_FIADD32         => IMPL_EVO_FIADD32,       -- Fixed point Q17.15 addition.
            IMPL_FIDIV32         => IMPL_EVO_FIDIV32,       -- Fixed point Q17.15 division.
            IMPL_FIMULT32        => IMPL_EVO_FIMULT32,      -- Fixed point Q17.15 multiplication.
            IMPL_LOADB           => IMPL_EVO_LOADB,         -- Load single byte from memory.
            IMPL_LOADH           => IMPL_EVO_LOADH,         -- Load half word (16bit) from memory.
            IMPL_LSHIFTRIGHT     => IMPL_EVO_LSHIFTRIGHT,   -- Logical shift right.
            IMPL_MOD             => IMPL_EVO_MOD,           -- 32bit modulo (remainder after division).
            IMPL_MULT            => IMPL_EVO_MULT,          -- 32bit signed multiplication.
            IMPL_NEG             => IMPL_EVO_NEG,           -- Negate value in TOS.
            IMPL_NEQ             => IMPL_EVO_NEQ,           -- Not equal test.
            IMPL_POPPCREL        => IMPL_EVO_POPPCREL,      -- Pop a value into the Program Counter from a location relative to the Stack Pointer.
            IMPL_PUSHSPADD       => IMPL_EVO_PUSHSPADD,     -- Add a value to the Stack pointer and push it onto the stack.
            IMPL_STOREB          => IMPL_EVO_STOREB,        -- Store/Write a single byte to memory/IO.
            IMPL_STOREH          => IMPL_EVO_STOREH,        -- Store/Write a half word (16bit) to memory/IO.
            IMPL_SUB             => IMPL_EVO_SUB,           -- 32bit signed subtract.
            IMPL_XOR             => IMPL_EVO_XOR,           -- Exclusive or of value in TOS.
            -- Size/Control parameters for the optional hardware.
            MAX_INSNRAM_SIZE     => (2**(SOC_MAX_ADDR_INSN_BRAM_BIT)), -- Maximum size of the optional instruction BRAM on the INSN Bus.
            MAX_L1CACHE_BITS     => MAX_EVO_L1CACHE_BITS,   -- Maximum size in instructions of the Level 0 instruction cache governed by the number of bits, ie. 8 = 256 instruction cache.
            MAX_L2CACHE_BITS     => MAX_EVO_L2CACHE_BITS,   -- Maximum bit size in bytes of the Level 2 instruction cache governed by the number of bits, ie. 8 = 256 byte cache.
            MAX_MXCACHE_BITS     => MAX_EVO_MXCACHE_BITS,   -- Maximum size of the memory transaction cache governed by the number of bits.
            RESET_ADDR_CPU       => SOC_RESET_ADDR_CPU,     -- Initial start address of the CPU.
            START_ADDR_MEM       => SOC_START_ADDR_MEM,     -- Start address of program memory.
            STACK_ADDR           => SOC_STACK_ADDR,         -- Initial stack address on CPU start.
  --          EXT_MEM_START        => Z80_MEM_START,          -- Start of off chip memory needing different timing to onchip resources.
  --          EXT_MEM_SIZE         => Z80_MEM_SIZE,           -- Size of off chip memory.
  --          EXT_IO_START         => Z80_IO_START,           -- Start of off chip I/O region needing different timing to onchip resources.
  --          EXT_IO_SIZE          => Z80_IO_SIZE,            -- Size of off chip I/O region.
            CLK_FREQ             => SYSCLK_FREQUENCY        -- System clock frequency.
        )
        port map (
            CLK                  => ZPU_CLK,
            RESET                => not ZPU_RESETn,
            ENABLE               => ZPU_CLKEN,
            MEM_BUSY             => MEM_BUSY,
            MEM_DATA_IN          => MEM_DATA_READ,
            MEM_DATA_OUT         => MEM_DATA_WRITE,
            MEM_ADDR             => MEM_ADDR,
            MEM_WRITE_ENABLE     => MEM_WRITE_ENABLE,
            MEM_READ_ENABLE      => MEM_READ_ENABLE,
            MEM_WRITE_BYTE       => MEM_WRITE_BYTE_ENABLE,
            MEM_WRITE_HWORD      => MEM_WRITE_HWORD_ENABLE,
            MEM_BUSRQ            => MEM_BUSRQ,
            MEM_BUSACK           => ZPU_MEM_BUSACK,
            -- Instruction memory path.
            MEM_BUSY_INSN        => '0',
            MEM_DATA_IN_INSN     => MEM_DATA_READ_INSN,
            MEM_ADDR_INSN        => MEM_ADDR_INSN,
            MEM_READ_ENABLE_INSN => MEM_READ_ENABLE_INSN,
            -- Master Wishbone Memory/IO bus interface.
            WB_CLK_I             => '0',
            WB_RST_I             => '0',
            WB_ACK_I             => '0',
            WB_DAT_I             => (others => '0'),
            WB_DAT_O             => open,
            WB_ADR_O             => open,
            WB_CYC_O             => open,
            WB_STB_O             => open,
            WB_CTI_O             => open,
            WB_WE_O              => open,
            WB_SEL_O             => open,
            WB_HALT_I            => '0',
            WB_ERR_I             => '0',
            WB_INTA_I            => '0',
            --
            INT_REQ              => INT_TRIGGER,
            INT_ACK              => INT_ACK,                -- Interrupt acknowledge, ZPU has entered Interrupt Service Routine.
            INT_DONE             => INT_DONE,               -- Interrupt service routine completed/done.
            BREAK                => open,                   -- A break instruction encountered.
            CONTINUE             => '1',                    -- When break activated, processing stops. Setting CONTINUE to logic 1 resumes processing with next instruction.
            DEBUG_TXD            => DEBUG_TXD               -- Debug serial output.
        );

    -- Only enable the clock if the soft cpu is selected (enabled) and the seperate clock enable is set.
    ZPU_CLKEN                 <= '1'                  when SW_CPUEN = '1'          and SW_CLKEN = '1'
                                 else '0';

    -- Busack is combined with reset and clock enable to ensure that a busack signal is sent when the CPU is paused or the clock is disabled.
    MEM_BUSACKi               <= '1'                  when (ZPU_MEM_BUSACK = '1' and SW_CLKEN = '1' and ZPU_RESETn = '1') or (MEM_BUSRQ = '1' and SW_CLKEN = '0')
                                 else '0';
    MEM_BUSACK                <= MEM_BUSACKi;

    -- Force the CPU to wait when slower memory/IO is accessed and it cant deliver an immediate result.
    MEM_BUSY                  <= '1'                  when SOC_IMPL_Z80BUS = true  and IO_WAIT_Z80BUS = '1' -- ((Z80BUS_CS = '1' and MEM_READ_ENABLE_LAST(0) = '0' and MEM_READ_ENABLE = '1') or IO_WAIT_Z80BUS = '1')
                                 else
                                 '1'                  when SOC_IMPL_INTRCTL = true and IO_WAIT_INTR = '1'   -- INTR0_CS = '1'    and MEM_READ_ENABLE_LAST(0) = '0' and MEM_READ_ENABLE = '1' and IO_WAIT_INTR = '1'
                                 else
                                 '1'                  when SOC_IMPL_TIMER1 = true  and IO_WAIT_TIMER1 = '1'  -- TIMER1_CS = '1'   and MEM_READ_ENABLE_LAST(0) = '0' and MEM_READ_ENABLE = '1' and IO_WAIT_TIMER1 = '1'
                                 else
                               --  '1'                  when SOC_IMPL_SOCCFG = true  and SOCCFG_CS = '1'   and MEM_READ_ENABLE_LAST(0) = '0' and MEM_READ_ENABLE = '1'
                               --  else
                                 '1'                  when                             IO_WAIT_VIDEO = '1' --                         (VIDEO_CS = '1'   and MEM_READ_ENABLE_LAST(0) = '0'  and MEM_READ_ENABLE = '1') --or IO_WAIT_VIDEO = '1' 
                                 else
                                 '0';

    -- Select CPU input source, memory or IO.
    MEM_DATA_READ             <= BRAM_DATA_READ       when BRAM_SELECT = '1'
                                 else
                              -- BRAM_DATA_READ2      when BRAM_SELECT2 = '1'
                              -- else
                                 IO_DATA_READ_INTRCTL when SOC_IMPL_INTRCTL = true and INTR0_CS = '1'
                                 else
                                 IO_DATA_READ_SOCCFG  when SOC_IMPL_SOCCFG = true  and SOCCFG_CS = '1'
                                 else
                                 VIDEO_DATA_IN        when                             VIDEO_CS = '1'
                                 else
                                 Z80_DATA_IN          when SOC_IMPL_Z80BUS = true  and Z80BUS_CS = '1'
                                 else
                                 IO_DATA_READ         when IO_SELECT = '1'
                                 else
                                 (others => '1');


    -- Fixed peripheral Decoding.
                                        -- IO Range for EVO CPU
    IO_SELECT                 <= '1'                  when MEM_ADDR(IO_DECODE_RANGE)     = std_logic_vector(to_unsigned(15, maxAddrBit-WB_ACTIVE - maxIOBit))          -- 1MByte address space, normally 0xF00000:FFFFFF
                                 else '0';
    IO_TIMER_SELECT           <= '1'                  when IO_SELECT = '1'         and MEM_ADDR(11 downto 8) = X"C"                                                    -- Timer Range 0x<msb=0>FFFFCxx
                                 else '0';
    TIMER0_CS                 <= '1'                  when IO_TIMER_SELECT = '1'   and MEM_ADDR(7 downto 6) = "00"                                                     -- 0xC00-C3F Millisecond timer.
                                 else '0';
    Z80BUS_CS                 <= '1'                  when MEM_ADDR(Z80BUS_DECODE_RANGE) = std_logic_vector(to_unsigned(1,  maxAddrBit-WB_ACTIVE - maxZ80BusBit))      -- 1MByte address space, normally 0x100000:1FFFFF - lower address mirror for 512K RAM
                                 else
                                 '1'                  when MEM_ADDR(Z80BUS_DECODE_RANGE) = std_logic_vector(to_unsigned(13, maxAddrBit-WB_ACTIVE - maxZ80BusBit))      -- 1MByte address space, normally 0xD00000:DFFFFF
                                 else
                                 '1'                  when MEM_ADDR(Z80BUS_DECODE_RANGE) = std_logic_vector(to_unsigned(14, maxAddrBit-WB_ACTIVE - maxZ80BusBit))      -- 1MByte address space, normally 0xE00000:EFFFFF
                                 else '0';

--    BRAM_SELECT               <= '1'                  when (MEM_ADDR >= std_logic_vector(to_unsigned(SOC_ADDR_BRAM_START, MEM_ADDR'LENGTH)) and MEM_ADDR < std_logic_vector(to_unsigned(SOC_ADDR_BRAM_END, MEM_ADDR'LENGTH)))
--                                 else
--                                 '1'                  when MEM_ADDR(23 downto 17) = "1101000"
--                                 else '0';
--    Z80BUS_CS                 <= --'1'                  when MEM_ADDR(Z80BUS_DECODE_RANGE) = std_logic_vector(to_unsigned(13, maxAddrBit-WB_ACTIVE - maxZ80BusBit))      -- 1MByte address space, normally 0xD00000:DFFFFF
--                                 '1'                  when MEM_ADDR(23 downto 19) = "11011"
--                                 else
--                                 '1'                  when MEM_ADDR(Z80BUS_DECODE_RANGE) = std_logic_vector(to_unsigned(14, maxAddrBit-WB_ACTIVE - maxZ80BusBit))      -- 1MByte address space, normally 0xE00000:EFFFFF
--                                 else '0';

    -- Debug output loop through. If the ZPU debugger is enabled, feed the serial output stream to the output, if not enabled, feed the loop input to the output.
    --
    DEBUG_TXD_OUT             <= DEBUG_TXD            when DEBUG_CPU = true
                                 else
                                 DEBUG_TXD_IN;

    -- Direct addressing Bus. Normally this is set to 0 during standard Sharp MZ operation, when 23:19 > 0 then direct addressing of the various video
    -- memory's is enabled.
    -- Address    A23 -A16
    -- 0x000000   00000000 - Normal Sharp MZ behaviour, Video Controller controlled by Z80 bus transactions.
    -- 0x080000   00001000 - Memory and I/O ports mapped into direct addressable memory location.
    --
    --                       A15 - A8 A7 -  A0
    --                       I/O registers are mapped to the bottom 256 bytes mirroring the I/O address.
    -- 0x0800D0              00000000 11010000 - 0xD0 - Set the parameter number to update.
    --                       00000000 11010001 - 0xD1 - Update the lower selected parameter byte.
    --                       00000000 11010010 - 0xD2 - Update the upper selected parameter byte.
    --                       00000000 11010011 - 0xD3 - set the palette slot Off position to be adjusted.
    --                       00000000 11010100 - 0xD4 - set the palette slot On position to be adjusted.
    --                       00000000 11010101 - 0xD5 - set the red palette value according to the PALETTE_PARAM_SEL address.
    --                       00000000 11010110 - 0xD6 - set the green palette value according to the PALETTE_PARAM_SEL address.
    -- 0x0800D7              00000000 11010111 - 0xD7 - set the blue palette value according to the PALETTE_PARAM_SEL address.
    --
    -- 0x0800E0              00000000 11100000 - 0xE0 MZ80B PPI
    --                       00000000 11100100 - 0xE4 MZ80B PIT
    -- 0x0800E8              00000000 11101000 - 0xE8 MZ80B PIO
    --
    --                       00000000 11110000 - 
    --                       00000000 11110001 - 
    --                       00000000 11110010 - 
    -- 0x0800F3              00000000 11110011 - 0xF3 set the VGA border colour.
    --                       00000000 11110100 - 0xF4 set the MZ80B video in/out mode.
    --                       00000000 11110101 - 0xF5 sets the palette.
    --                       00000000 11110110 - 0xF6 set parameters.
    --                       00000000 11110111 - 0xF7 set the graphics processor unit commands.
    --                       00000000 11111000 - 0xF6 set parameters.
    --                       00000000 11111001 - 0xF7 set the graphics processor unit commands.
    --                       00000000 11111010 - 0xF8 set the video mode. 
    --                       00000000 11111011 - 0xF9 set the graphics mode.
    --                       00000000 11111100 - 0xFA set the Red bit mask
    --                       00000000 11111101 - 0xFB set the Green bit mask
    --                       00000000 11111110 - 0xFC set the Blue bit mask
    -- 0x0800FD              00000000 11111111 - 0xFD set the Video memory page in block C000:FFFF 
    --
    --                       Memory registers are mapped to the E000 region as per base machines.
    -- 0x08E010              11100000 00010010 - Program Character Generator RAM. E010 - Write cycle (Read cycle = reset memory swap).
    --                       11100000 00010100 - Normal display select.
    --                       11100000 00010101 - Inverted display select.
    --                       11100010 00000000 - Scroll display register. E200 - E2FF
    -- 0x08E2FF              11111111
    --
    -- 0x090000   00001001 - Video/Attribute RAM. 64K Window.
    -- 0x09D000              11010000 00000000 - Video RAM
    -- 0x09D7FF              11010111 11111111
    -- 0x09D800              11011000 00000000 - Attribute RAM
    -- 0x09DFFF              11011111 11111111
    --
    -- 0x0A0000   00001010 - Character Generator RAM 64K Window.
    -- 0x0A0000              00000000 00000000 - CGROM
    -- 0x0A0FFF              00001111 11111111 
    -- 0x0A1000              00010000 00000000 - CGRAM
    -- 0x0A1FFF              00011111 11111111
    --
    -- 0x0C0000   00001100 - 128K Red framebuffer.
    --                       00000000 00000000 - Red pixel addressed framebuffer. Also MZ-80B GRAM I memory in lower 8K
    -- 0x0C3FFF              00111111 11111111
    -- 0x0D0000   00001101 - 128K Blue framebuffer.
    --                       00000000 00000000 - Blue pixel addressed framebuffer. Also MZ-80B GRAM II memory in lower 8K
    -- 0x0D3FFF              00111111 11111111
    -- 0x0E0000   00001110 - 128K Green framebuffer.
    --                       00000000 00000000 - Green pixel addressed framebuffer.
    -- 0x0E3FFF              00111111 11111111
    --
    VIDEO_CS                  <= '1'                                when MEM_ADDR(23 downto 19) = "11001"                                            -- 512Kbyte address space, normally 0xC80000:CFFFFF - can expand down if needed.
                                 else '0';
    VIDEO_8BIT_CS             <= '1'                                when MEM_ADDR(23 downto 16) = "11001000"                                         -- 8 bit region of video controller where registers are accessed 8bit at a time for read operations.
                                 else '0';
--    VIDEO_ADDR                <= "00001000" & MEM_ADDR(17 downto 2) when VIDEO_8BIT_CS = '1'  and VIDEO_RDn = '0'                                    -- In the 8 bit region, reads are 32bit but the address is x4 so a shift right by 2 will yield a byte level address, 32bits will be return with the top 3 bytes zeroed.
--                                 else
--                                 "0000"     & MEM_ADDR(19 downto 0);
--    VIDEO_DATA_OUT            <= MEM_DATA_WRITE;
--    VIDEO_WRn                 <= '0'                                when (VIDEO_CS = '1'       and MEM_WRITE_ENABLE = '1')
--                                 else '1';
--    VIDEO_RDn                 <= '0'                                when (VIDEO_CS = '1'       and MEM_READ_ENABLE = '1')
--                                 else '1';
--    VIDEO_WR_BYTE             <= MEM_WRITE_BYTE_ENABLE;
--    VIDEO_WR_HWORD            <= MEM_WRITE_HWORD_ENABLE;

    -- A process to match the timing requirements of the Video Controller, which in itself is trying to adapt between a variable low frequency (2-24MHz) multicycle
    -- Z80 bus and the ZPU bus which runs at 75-100MHz and can complete in a single cycle.
    --
    process(ZPU_CLK, ZPU_RESETn)
        variable IO_WAIT_VIDEO_CNT : unsigned(2 downto 0);
    begin
        if rising_edge(ZPU_CLK) then
            if ZPU_RESETn = '0' then
                IO_WAIT_VIDEO       <= '0';
                IO_WAIT_VIDEO_CNT   := (others => '0');
                VIDEO_RDn           <= '1';
                VIDEO_WRn           <= '1';
                VIDEO_WR_BYTE       <= '0';
                VIDEO_WR_HWORD      <= '0';
            else
                -- On positive edge detection commence the transaction applying WAIT to the ZPU to accommodate the frequency and cycle mismatch.
                -- Timing for 8 bit differs to the 32bit access.
                if VIDEO_CS = '1' and ((MEM_READ_ENABLE_LAST = "001" and MEM_READ_ENABLE = '1') or (MEM_WRITE_ENABLE_LAST = "001" and MEM_WRITE_ENABLE = '1')) then

                    if VIDEO_8BIT_CS = '1' and MEM_READ_ENABLE = '1' then
                        VIDEO_ADDR            <= "00001000" & MEM_ADDR(17 downto 2);
                    else
                        VIDEO_ADDR            <= "0000"     & MEM_ADDR(19 downto 0);
                    end if;
                    if MEM_WRITE_ENABLE = '1' then
                        VIDEO_DATA_OUT        <= MEM_DATA_WRITE;
                    end if;
                    VIDEO_WR_BYTE             <= MEM_WRITE_BYTE_ENABLE;
                    VIDEO_WR_HWORD            <= MEM_WRITE_HWORD_ENABLE;
                    IO_WAIT_VIDEO             <= '1';

                    if MEM_READ_ENABLE = '1' then
                        if VIDEO_8BIT_CS = '1' then
                            IO_WAIT_VIDEO_CNT := (others => '1');
                        else
                            IO_WAIT_VIDEO_CNT := to_unsigned(2, IO_WAIT_VIDEO_CNT'length);
                        end if;
                        VIDEO_RDn                 <= '0';
                    else
                        if VIDEO_8BIT_CS = '1' then
                            IO_WAIT_VIDEO_CNT := (others => '1');
                        else
                            IO_WAIT_VIDEO_CNT := to_unsigned(2, IO_WAIT_VIDEO_CNT'length);
                        end if;
                        VIDEO_WRn             <= '0';
                    end if;
                end if;

                -- Reads terminate 1 cycle early so that the Video Controller can latch the output data before the ZPU reads it.
                --
                if IO_WAIT_VIDEO_CNT = 1 and VIDEO_RDn = '0' then
                    VIDEO_RDn                 <= '1';
                end if;
                -- At end of down count, reset all control signals and release ZPU from WAIT.
                if IO_WAIT_VIDEO_CNT = 0 then
                    VIDEO_WRn                 <= '1';
                    VIDEO_RDn                 <= '1';
                    IO_WAIT_VIDEO             <= '0';
                end if;

                -- IO Wait down counter. When not zero, we are in a WAIT state counting down.
                if IO_WAIT_VIDEO_CNT /= 0 then
                    IO_WAIT_VIDEO_CNT := IO_WAIT_VIDEO_CNT - 1;
                end if;
            end if;
        end if;
    end process;

    -- Z80 Bus Interface.
    --
    -- 24bit address, 8 bit data.  The Z80 Memory and I/O are mapped into linear ZPU address space. The ZPU makes standard memory transactions and this state machine holds the ZPU whilst it performs the Z80 transaction.
    --
    -- Depending on the accessed address will determine the type of transaction. In order to provide byte level access on a 32bit read CPU, a bank of addresses, word aligned per byte is assigned in addition to
    -- an address to read 32bit word aligned value.
    --
    -- Y+000000:Y+07FFFF = 512K Static RAM on the tranZPUter board. All reads are 32bit, all writes are 8, 16 or 32bit wide on word boundary.
    -- Y+080000:Y+0BFFFF = 64K address space on host mainboard (ie. RAM/ROM/Memory mapped I/O) accessed 1 byte at a time. The physical address is word aligned per byte, so 4 bytes on the ZPU address space = 1
    --                     byte on the Z80 address space. ie. 0x00780 ZPU = 0x0078 Z80.
    -- Y+0C0000:Y+0FFFFF = 64K I/O space on the host mainboard or the underlying CPLD/FPGA. 64K address space is due to the Z80 ability to address 64K via the Accumulator being set in 15:8 and the port in 7:0.
    --                     The ZPU, via a direct address will mimic this ability for hardware which requires it. ie. A write to 0x3F with 0x10 in the accumulator would yield an address of 0x103f.
    --                     All reads are 8 bit, writes are 8, 16 or 32bit wide on word boundary. The physical address is word aligned per byte, so 4 bytes on the ZPU address space = 1
    --                     byte on the Z80 address space. ie. 0x00780 ZPU = 0x0078 Z80.
    --
    -- Y+100000:Y+10FFFF = 64K address space on host mainboard (ie. RAM/ROM/Memory mapped I/O) accessed 4 bytes at a time, a 32 bit read will return 4 consecutive bytes,1start of read must be on a 32bit word boundary.
    -- Y+180000:Y+1FFFFF = 512K unassigned.
    --
    -- Y = 2Mbyte sector in ZPU address space the Z80 bus interface is located. This is normally below the ZPU I/O sector and set to 0xExxxxx
    --
    --
    Z80BUS: if SOC_IMPL_Z80BUS = true generate
        -- State machine states for the Z80 bus transaction FSM.
        --
        type Z80BusStateType is 
        (
            State_IDLE,
            State_SETUP,
            State_MEM_READ,
            State_MEM_READ_1,
            State_MEM_READ_2,
            State_MEM_BYTE_READ,
            State_MEM_BYTE_READ_1,
            State_MEM_BYTE_READ_2,
            State_MEM_WRITE,
            State_MEM_WRITE_1,
            State_MEM_WRITE_2,
            State_IO_READ,
            State_IO_READ_1,
            State_IO_READ_2,
            State_IO_READ_3,
            State_IO_BYTE_READ,
            State_IO_BYTE_READ_1,
            State_IO_BYTE_READ_2,
            State_IO_BYTE_READ_3,
            State_IO_WRITE,
            State_IO_WRITE_1,
            State_IO_WRITE_2,
            State_IO_WRITE_3
        ); 
    
        -- Local signals for the Z80 Bus implementation.
        signal Z80_ADDR              :       std_logic_vector(23 downto 0);                -- Z80 address for next transaction.
        signal Z80_DATA_OUT          :       std_logic_vector(31 downto 0);                -- Data to be sent to the Z80 bus.
        signal Z80_XACT_RUN          :       std_logic;                                    -- Z80 FSM transaction running.
        signal Z80_XACT_RUN_LAST     :       std_logic;                                    -- Edge detect for Z80_XACT_RUN.
        signal Z80_WRITE_BYTE        :       std_logic;                                    -- Z80 writing 1 byte.
        signal Z80_WRITE_HWORD       :       std_logic;                                    -- Z80 writing 2 bytes.
        signal Z80_BUS_HOST_ACCESS   :       std_logic;                                    -- Z80 to access underlying HOST mainboard hardware. Default is to access tranZPUter hardware.
        signal Z80_BUS_MREQn         :       std_logic;                                    -- MREQn signal indicates that the address bus holds a valid address for reading or writing memory.
        signal Z80_BUS_IORQn         :       std_logic;                                    -- IORQn signal indicates that the address bus (A0-A7) holds a valid address for reading or writing and I/O device.
        signal Z80_BUS_RDn           :       std_logic;                                    -- RDn signal indicates that data is ready to be read from a memory or I/O device to the CPU.
        signal Z80_BUS_WRn           :       std_logic;                                    -- WRn signal indicates that data is going to be written from the CPU data bus to a memory or I/O device.
        signal Z80_BUS_M1n           :       std_logic;                                    -- M1n Machine Cycle 1 signal. M1 and MREQ active = opcode fetch, M1 and IORQ active = interrupt, vector can be read from D0-D7. M1n is used in this module as a flag to the CPLD to latch the upper address bits or enable host mainboard access.
        signal Z80_BUS_BUSACKn       :       std_logic;                                    -- Bus request acknowledge, becomes active when the Z80 component of the FSM is idle and BUSRQ is asserted or during RESET.
        signal Z80_BUS_DATA_OUT      :       std_logic_vector(7 downto 0);                 -- Data placed on the the Z80 bus.
        signal Z80_BYTE_COUNT        :       integer range 0 to 4;                         -- Count of bytes in a transaction, 1 byte, half-word (2 bytes) or 32bit word (4 bytes).
        signal Z80_BYTE_ADDR         :       unsigned(1 downto 0);                         -- Lower address bits to accommodate 1, 2 or 4 byte read/writes.
        signal Z80_BUS_XACT          :       Z80BusStateType;                              -- Transaction to perform.
        signal Z80_BUS_XACT_FULLSPEED:       std_logic;                                    -- Perform transaction at full CPU clock speed rather than the Z80 clock speed.
        signal Z80BusFSMState        :       Z80BusStateType;                              -- Running FSM state.

    begin
        process(ZPU_CLK, Z80_CLK, ZPU_RESETn, Z80_BUS_DATA_OUT, Z80_BUS_MREQn, Z80_BUS_IORQn, Z80_BUS_RDn, Z80_BUS_WRn, Z80_BUS_M1n, Z80_BUS_BUSACKn, Z80_ADDR, Z80_BYTE_ADDR, ZPU80_BUSRQn, Z80_XACT_RUN, Z80_XACT_RUN_LAST)
        begin
            ------------------------
            -- HIGH LEVEL         --
            ------------------------
            ZPU80_RFSHn                <= '1';                                             -- RFSHn signal to indicate dynamic memory refresh can take place.
            ZPU80_HALTn                <= '1';                                             -- HALTn signal indicates that the CPU has executed a "HALT" instruction.

            ------------------------
            -- ASYNCHRONOUS RESET --
            ------------------------
            if ZPU_RESETn='0' then
                Z80_BUS_MREQn          <= '1';                                             -- MREQn signal indicates that the address bus holds a valid address for reading or writing memory.
                Z80_BUS_IORQn          <= '1';                                             -- IORQn signal indicates that the address bus (A0-A7) holds a valid address for reading or writing and I/O device.
                Z80_BUS_RDn            <= '1';                                             -- RDn signal indicates that data is ready to be read from a memory or I/O device to the CPU.
                Z80_BUS_WRn            <= '1';                                             -- WRn signal indicates that data is going to be written from the CPU data bus to a memory or I/O device.
                Z80_BUS_M1n            <= '1';                                             -- M1n Machine Cycle 1 signal. M1 and MREQ active = opcode fetch, M1 and IORQ active = interrupt, vector can be read from D0-D7. M1n is used in this module as a flag to the CPLD to latch the upper address bits or enable host mainboard access.
                Z80_BUS_BUSACKn        <= '1';                                             -- Bus request acknowledge, becomes active when the Z80 component of the FSM is idle and BUSRQ is asserted or during RESET.
                Z80_BUS_DATA_OUT       <= (others => '0');                                 -- 8 bit data bus out.
                IO_WAIT_Z80BUS         <= '0';                                             -- Flag to force the ZPU to wait during Z80 transactions, the Z80 Bus is slower and 8 bit.
                Z80_START_XACT         <= '0';
                Z80_BUS_XACT_FULLSPEED <= '0';                                             -- Perform the Z80 bus transaction at the CPU speed not the Z80 speed.
                Z80_XACT_RUN           <= '0';
                Z80_CLK_EDGE           <= (others => '0');                                 -- Z80 clock edge detection.
                Z80BusFSMState         <= State_IDLE;

            -----------------------
            -- RISING CLOCK EDGE --
            -----------------------                
            elsif rising_edge(ZPU_CLK) then

                -- Detect the Z80 Clock edge and use it to synchronise with the Z80 Bus.
                Z80_CLK_EDGE                               <= Z80_CLK_EDGE(1 downto 0) & Z80_CLK;

                -- If the start of transaction has been acknowledged, clear the flag ready for next request.
                --
                if Z80_START_XACT = '1' and Z80_XACT_RUN = '1' then
                    Z80_START_XACT                         <= '0';
                end if;

                -- Read operations, detect end of transaction and copy to ZPU, then release ZPU from wait state.
                -- Write operations, just release the ZPU from wait state.
                if Z80_START_XACT = '0' and Z80_XACT_RUN = '0' then --and Z80_XACT_RUN_LAST = '1' then
                    IO_WAIT_Z80BUS                         <= '0';
                    Z80_ADDR                               <= (others => '0');
                end if;

                -- When a BUS request goes inactive, reset acknowledge and processing commences next cycle.
                if ZPU80_BUSRQn = '1' then
                    Z80_BUS_BUSACKn                        <= '1';
                end if;

                -- If the bus is requested, wait until the Z80 bus FSM is idle then halt operations.
                if Z80_START_XACT = '0' and Z80_XACT_RUN = '0' and ZPU80_BUSRQn = '0' then
                    Z80_BUS_BUSACKn                        <= '0';

                -- Start a Z80 BUS Read or Write?
                elsif Z80_START_XACT = '0' and Z80_XACT_RUN = '0' and ((MEM_WRITE_ENABLE_LAST = "011" and MEM_WRITE_ENABLE = '1') or (MEM_READ_ENABLE_LAST = "001" and MEM_READ_ENABLE = '1')) and Z80BUS_CS = '1' and Z80_BUS_BUSACKn = '1' then

                    -- Halt the ZPU, Z80 transactions take a lot more time.
                    IO_WAIT_Z80BUS                         <= '1';

                    -- Store the ZPU data, detaching it for 2 purposes, timing and ability to read/write data other than the ZPU required transaction.
                    Z80_ADDR                               <= "00000" & MEM_ADDR(18 downto 0);

                    -- Store the write signals for write operations.
                    if MEM_WRITE_ENABLE = '1' then
                        Z80_DATA_OUT                       <= MEM_DATA_WRITE;
                        Z80_WRITE_BYTE                     <= MEM_WRITE_BYTE_ENABLE;
                        Z80_WRITE_HWORD                    <= MEM_WRITE_HWORD_ENABLE;
                    end if;

                    -- Preset signals.
                    --
                    Z80_BUS_HOST_ACCESS                    <= '0';
                    Z80_START_XACT                         <= '1';
                    Z80_BUS_XACT_FULLSPEED                 <= '0';

                    -- Depending on the accessed address will determine the type of transaction. In order to provide byte level access on a 32bit read CPU, a bank of addresses, word aligned per byte is assigned in addition to
                    -- an address to read 32bit word aligned value.
                    --
                    -- Y+000000:Y+07FFFF = 512K Static RAM on the tranZPUter board. All reads are 32bit, all writes are 8, 16 or 32bit wide on word boundary.
                    -- Y+080000:Y+0BFFFF = 64K address space on host mainboard (ie. RAM/ROM/Memory mapped I/O) accessed 1 byte at a time. The physical address is word aligned per byte, so 4 bytes on the ZPU address space = 1
                    --                     byte on the Z80 address space. ie. 0x00780 ZPU = 0x0078 Z80.
                    -- Y+0C0000:Y+0FFFFF = 64K I/O space on the host mainboard or the underlying CPLD/FPGA. 64K address space is due to the Z80 ability to address 64K via the Accumulator being set in 15:8 and the port in 7:0.
                    --                     The ZPU, via a direct address will mimic this ability for hardware which requires it. ie. A write to 0x3F with 0x10 in the accumulator would yield an address of 0xF103f.
                    --                     All reads are 8 bit, writes are 8, 16 or 32bit wide on word boundary. The physical address is word aligned per byte, so 4 bytes on the ZPU address space = 1
                    --                     byte on the Z80 address space. ie. 0x00780 ZPU = 0x0078 Z80.
                    --
                    -- Y+100000:Y+10FFFF = 64K address space on host mainboard (ie. RAM/ROM/Memory mapped I/O) accessed 4 bytes at a time, a 32 bit read will return 4 consecutive bytes, start of read must be on a 32bit word boundary.
                    -- Y+180000:Y+1FFFFF = 512K Video address space - the video processor memory will be directly mapped into this space as follows:
                    --                     0x180000 - 0x18FFFF = 64K Video / Attribute RAM
                    --                     0x190000 - 0x19FFFF = 64K Character Generator ROM/PCG RAM.
                    --                     0x1A0000 - 0x1BFFFF = 128K Red Framebuffer address space.
                    --                     0x1C0000 - 0x1DFFFF = 128K Blue Framebuffer address space.
                    --                     0x1E0000 - 0x1FFFFF = 128K Green Framebuffer address space.
                    --                     This invokes memory read/write operations but the Video Read/Write signal is directly set, MREQ is not set. This 
                    --                     allows direct writes to be made to the FPGA video logic, bypassing the CPLD memory manager.
                    --                     All reads are 32bit, writes are 8, 16 or 32bit wide on word boundary.
                    --
                    -- Y = 2Mbyte sector in ZPU address space the Z80 bus interface is located. This is normally below the ZPU I/O sector and set to 0xExxxxx
                    --
                    -- Y+000000:Y+07FFFF - Direct addressable 512K RAM on tranZPUter board.
                    if MEM_ADDR(maxZ80BusBit+1 downto maxZ80BusBit-1) = "010" then
                        if MEM_WRITE_ENABLE = '1' then
                            Z80_BUS_XACT                   <= State_MEM_WRITE;
                        else
                            Z80_BUS_XACT                   <= State_MEM_READ;
                        end if;
                        Z80_BUS_XACT_FULLSPEED             <= '1';

                    -- Y+080000:Y+0BFFFF - Access to host mainboard 64K address space. Due to 32bit mapping, address is shifted right by 2, so each byte on the mainboard is accessed as a 32bit word in the ZPU.
                    elsif MEM_ADDR(maxZ80BusBit+1 downto maxZ80BusBit-2) = "0110" then
                        if MEM_WRITE_ENABLE = '1' then
                            Z80_BUS_XACT                   <= State_MEM_WRITE;
                        else
                            Z80_BUS_XACT                   <= State_MEM_BYTE_READ;
                        end if;
                        Z80_ADDR                           <= "00000" & MEM_ADDR(20 downto 2);
                        Z80_BUS_HOST_ACCESS                <= '1';

                    -- Y+0C0000:Y+0FFFFF - Access to 64K I/O space, the upper 8 bits representing the accumulator on a typical Z80 transaction. As above, each byte is accessed as a 32bit word in the ZPU thus 256K ZPU address space is occupied for 64K Z80 I/O space.
                    elsif MEM_ADDR(maxZ80BusBit+1 downto maxZ80BusBit-2) = "0111" then
                        if MEM_WRITE_ENABLE = '1' then
                            Z80_BUS_XACT                   <= State_IO_WRITE;
                        else
                            Z80_ADDR                       <= "00000" & MEM_ADDR(20 downto 2);
                            Z80_BUS_XACT                   <= State_IO_BYTE_READ;
                        end if;
                        Z80_BUS_HOST_ACCESS                <= '1';

                    -- Y+100000:Y+10FFFF - Access to 64K on mainboard, accessed 32bit at a time (via 4x Z80 transactions as needed).
                    elsif MEM_ADDR(maxZ80BusBit+1 downto maxZ80BusBit-4) = "100000" then
                        if MEM_WRITE_ENABLE = '1' then
                            Z80_BUS_XACT                   <= State_MEM_WRITE;
                        else
                            Z80_BUS_XACT                   <= State_MEM_READ;
                        end if;
                        Z80_BUS_HOST_ACCESS                <= '1';

                    else
                        Z80_BUS_XACT                       <= State_IDLE;
                        Z80_START_XACT                     <= '0';
                        IO_WAIT_Z80BUS                     <= '0';
                    end if;

                -- Z80 bus domain. Run according to transaction target, either full speed or at the frequency of the hard/soft Z80 to correctly emulate a Z80 bus transaction.
                --
                elsif Z80_BUS_XACT_FULLSPEED = '1' or (Z80_BUS_XACT_FULLSPEED = '0' and Z80_CLK_EDGE = "001" and Z80_CLK = '1') then
                --elsif (Z80_CLK_EDGE = "001" and Z80_CLK = '1') then

                    -- Edge detection of completion flag.
                    Z80_XACT_RUN_LAST                          <= Z80_XACT_RUN;

                    -- If a transaction request is made, setup to run the FSM.
                    -- The actual transaction task is set in Z80_BUS_XACT and the ZPU_DATA and ADDR busses are used directly.
                    -- The start of transaction is acknowledged by setting RUN which gives ample cross-clock domain time for setup and hold.
                    --
                    if Z80_START_XACT = '1' and Z80_XACT_RUN = '0' and Z80_XACT_RUN_LAST = '0' then

                        if Z80_BUS_XACT = State_MEM_WRITE or Z80_BUS_XACT = State_IO_WRITE then
                            if Z80_WRITE_BYTE = '0' and Z80_WRITE_HWORD = '0' then
                                Z80_BYTE_COUNT                 <= 4;
                                Z80_BYTE_ADDR                  <= "00";
                            elsif Z80_WRITE_BYTE = '0' and Z80_WRITE_HWORD = '1' then
                                Z80_BYTE_COUNT                 <= 2;
                                Z80_BYTE_ADDR                  <= Z80_ADDR(1) & '0';
                            else
                                Z80_BYTE_COUNT                 <= 1;
                                Z80_BYTE_ADDR                  <= unsigned(Z80_ADDR(1 downto 0));
                            end if;
                        elsif Z80_BUS_XACT = State_MEM_READ or Z80_BUS_XACT = State_IO_READ then
                            Z80_BYTE_COUNT                     <= 4;
                            Z80_BYTE_ADDR                      <= "00";
                        else
                            Z80_BYTE_COUNT                     <= 1;
                            Z80_BYTE_ADDR                      <= unsigned(Z80_ADDR(1 downto 0));
                        end if;

                        -- Use the start of transaction to clock the upper memory bits into the CPLD or to select the host access mode.
                        if Z80_BUS_HOST_ACCESS = '1' then
                            Z80_BUS_DATA_OUT                   <= Z80_BUS_HOST_ACCESS & "0000000";
                            Z80_BUS_M1n                        <= '1';
                        else
                            --Z80_BUS_DATA_OUT                   <= (others => '0'); --Z80_ADDR(23 downto 16);
                            Z80_BUS_DATA_OUT                   <= Z80_ADDR(23 downto 16);
                            Z80_BUS_M1n                        <= '0';
                        end if;
                        Z80_BUS_MREQn                          <= '0';
                        Z80_BUS_IORQn                          <= '0';
                        Z80_XACT_RUN                           <= '1';
                        Z80_DATA_IN                            <= (others => '0');
                        Z80BusFSMState                         <= State_SETUP;
                    end if;

                    -- FSM to perform the Z80 bus transactions, for Memory Read/Write and I/O Read/Write.
                    -- As the ZPU is 32bit and can perform byte, half-word or full-word transactions, the FSM will run 1, 2 or 4 transactions reading/writing 1, 2 or 4 bytes
                    -- accordingly.
                    -- The starting address is in ZPU80_ADDR(15..2) and the lower 2 bits are set in MEM_BYTE_ADDR. The number of bytes to read/write are set in MEM_BYTE_COUNT.
                    --
                    case Z80BusFSMState is
                        when State_IDLE =>
                            Z80_BUS_XACT_FULLSPEED             <= '0';
                            Z80_XACT_RUN                       <= '0';

                        -- Setup the address and clear all lines ready for the Z80 transaction.
                        when State_SETUP =>
                            Z80_BUS_MREQn                      <= '1';
                            Z80_BUS_IORQn                      <= '1';
                            Z80_BUS_M1n                        <= '1';
                            Z80_BUS_RDn                        <= '1';
                            Z80_BUS_WRn                        <= '1';
                            Z80BusFSMState                     <= Z80_BUS_XACT;

                        -- Read sets signals on 1st transaction clock edge.
                        when State_MEM_READ =>
                            Z80_BUS_MREQn                      <= '0';
                            Z80_BUS_RDn                        <= '0';
                            Z80BusFSMState                     <= State_MEM_READ_1;

                        -- Detect and insert wait states.
                        when State_MEM_READ_1 =>
                            if ZPU80_WAITn = '1' then
                                Z80BusFSMState                 <= State_MEM_READ_2;
                            end if;

                        -- End of read cycle we sample and store data.
                        when State_MEM_READ_2 =>
                            Z80_BUS_MREQn                      <= '1';
                            Z80_BUS_RDn                        <= '1';

                            -- Shift the data in, so if we are reading more than 1 byte, it is in the correct endian location.
                            --Z80_DATA_IN                        <= ZPU80_DATA_IN & Z80_DATA_IN(31 downto 8);
                            Z80_DATA_IN                        <= Z80_DATA_IN(23 downto 0) & ZPU80_DATA_IN;

                            -- Read in upto Z80_BYTE_COUNT bytes then return to idle. When Z80_XACT_RUN is cleared the ZPU will latch the read word.
                            --
                            if Z80_BYTE_COUNT > 1 then
                                Z80_BYTE_COUNT                 <= Z80_BYTE_COUNT -1;
                                Z80_BYTE_ADDR                  <= Z80_BYTE_ADDR + 1;
                                Z80BusFSMState                 <= Z80_BUS_XACT;
                            else
                                Z80BusFSMState                 <= State_IDLE;
                            end if;

                        -- Read sets signals on 1st transaction clock edge.
                        when State_MEM_BYTE_READ =>
                            Z80_BUS_MREQn                      <= '0';
                            Z80_BUS_RDn                        <= '0';
                            Z80BusFSMState                     <= State_MEM_BYTE_READ_1;

                        -- Detect and insert wait states.
                        when State_MEM_BYTE_READ_1 =>
                            if ZPU80_WAITn = '1' then
                                Z80BusFSMState                 <= State_MEM_BYTE_READ_2;
                            end if;

                        -- End of read cycle we sample and store data.
                        when State_MEM_BYTE_READ_2 =>
                            Z80_BUS_MREQn                      <= '1';
                            Z80_BUS_RDn                        <= '1';

                            -- Single byte appears in bits 7:0
                            Z80_DATA_IN                        <= X"000000" & ZPU80_DATA_IN;
                            Z80BusFSMState                     <= State_IDLE;
                     --       Z80_XACT_RUN                       <= '0';

                        -- Write activates MREQ and prepares data on the bus. 
                        -- Mechanism setup to write MSB Big Endian.
                        when State_MEM_WRITE =>
                            Z80_BUS_MREQn                      <= '0';
                            Z80BusFSMState                     <= State_MEM_WRITE_1;

                            case to_integer(Z80_BYTE_ADDR) is
                                when 3 =>
                                    Z80_BUS_DATA_OUT           <= Z80_DATA_OUT(7 downto 0);
                                when 2 =>
                                    if (Z80_WRITE_BYTE = '0' and Z80_WRITE_HWORD = '0') or Z80_WRITE_HWORD = '1' then
                                        Z80_BUS_DATA_OUT       <= Z80_DATA_OUT(15 downto 8);
                                    else
                                        Z80_BUS_DATA_OUT       <= Z80_DATA_OUT(7 downto 0);
                                    end if;
                                when 1 =>
                                    if (Z80_WRITE_BYTE = '0' and Z80_WRITE_HWORD = '0') then
                                        Z80_BUS_DATA_OUT       <= Z80_DATA_OUT(23 downto 16);
                                    else
                                        Z80_BUS_DATA_OUT       <= Z80_DATA_OUT(7 downto 0);
                                    end if;
                                when 0 =>
                                    if (Z80_WRITE_BYTE = '0' and Z80_WRITE_HWORD = '0') then
                                        Z80_BUS_DATA_OUT       <= Z80_DATA_OUT(31 downto 24);
                                    elsif (Z80_WRITE_HWORD = '1') then
                                        Z80_BUS_DATA_OUT       <= Z80_DATA_OUT(15 downto 8);
                                    else
                                        Z80_BUS_DATA_OUT       <= Z80_DATA_OUT(7 downto 0);
                                    end if;
                                when others =>
                            end case;

                        -- Activate Write and detect and insert wait states.
                        when State_MEM_WRITE_1 =>
                            Z80_BUS_WRn                        <= '0';
                            if ZPU80_WAITn = '1' then -- or Z80_BUS_VIDEO_WRITE = '1' then
                                Z80BusFSMState                 <= State_MEM_WRITE_2;
                            end if;

                        when State_MEM_WRITE_2 =>
                            Z80_BUS_MREQn                      <= '1';
                            Z80_BUS_WRn                        <= '1';
                            if Z80_BYTE_COUNT > 1 then
                                Z80_BYTE_COUNT                 <= Z80_BYTE_COUNT -1;
                                Z80_BYTE_ADDR                  <= Z80_BYTE_ADDR + 1;
                                Z80BusFSMState                 <= Z80_BUS_XACT;
                            else
                                Z80BusFSMState                 <= State_IDLE;
                        --        Z80_XACT_RUN                   <= '0';
                            end if;

                        -- IO Read sets signals on 1st transaction clock edge as address already setup.
                        when State_IO_READ =>
                            Z80_BUS_IORQn                      <= '0';
                            Z80_BUS_RDn                        <= '0';
                            Z80BusFSMState                     <= State_IO_READ_1;

                        -- Insert automatic wait state for IO operations.
                        when State_IO_READ_1 =>
                            Z80BusFSMState                     <= State_IO_READ_2;

                        -- Detect and insert further wait states.
                        when State_IO_READ_2 =>
                            if ZPU80_WAITn = '1' then
                                Z80BusFSMState                 <= State_IO_READ_3;
                            end if;

                        -- End of read cycle we sample and store data.
                        when State_IO_READ_3 =>
                            Z80_BUS_IORQn                      <= '1';
                            Z80_BUS_RDn                        <= '1';

                            -- Shift the data in, so if we are reading more than 1 byte, it is in the correct endian location.
                            Z80_DATA_IN                        <= Z80_DATA_IN(23 downto 0) & ZPU80_DATA_IN;

                            if Z80_BYTE_COUNT > 1 then
                                Z80_BYTE_COUNT                 <= Z80_BYTE_COUNT -1;
                                Z80_BYTE_ADDR                  <= Z80_BYTE_ADDR + 1;
                                Z80BusFSMState                 <= Z80_BUS_XACT;
                            else
                                Z80BusFSMState                 <= State_IDLE;
                             --   Z80_XACT_RUN                   <= '0';
                            end if;

                        -- IO Read sets signals on 1st transaction clock edge as address already setup.
                        when State_IO_BYTE_READ =>
                            Z80_BUS_IORQn                      <= '0';
                            Z80_BUS_RDn                        <= '0';
                            Z80BusFSMState                     <= State_IO_BYTE_READ_1;

                        -- Insert automatic wait state for IO operations.
                        when State_IO_BYTE_READ_1 =>
                            Z80BusFSMState                     <= State_IO_BYTE_READ_2;

                        -- Detect and insert further wait states.
                        when State_IO_BYTE_READ_2 =>
                            if ZPU80_WAITn = '1' then
                                Z80BusFSMState                 <= State_IO_BYTE_READ_3;
                            end if;

                        -- End of read cycle we sample and store data.
                        when State_IO_BYTE_READ_3 =>
                            Z80_BUS_IORQn                      <= '1';
                            Z80_BUS_RDn                        <= '1';

                            -- Single byte appears in bits 7:0
                            Z80_DATA_IN                        <= X"000000" & ZPU80_DATA_IN;
                            Z80BusFSMState                     <= State_IDLE;
                    --        Z80_XACT_RUN                       <= '0';

                        -- Write prepares data on the bus. 
                        when State_IO_WRITE =>
                            Z80BusFSMState                     <= State_IO_WRITE_1;

                            case to_integer(Z80_BYTE_ADDR) is
                                when 0 =>
                                    Z80_BUS_DATA_OUT           <= Z80_DATA_OUT(7 downto 0);
                                when 1 =>
                                    if (Z80_WRITE_BYTE = '0' and Z80_WRITE_HWORD = '0') or Z80_WRITE_HWORD = '1' then
                                        Z80_BUS_DATA_OUT       <= Z80_DATA_OUT(15 downto 8);
                                    else
                                        Z80_BUS_DATA_OUT       <= Z80_DATA_OUT(7 downto 0);
                                    end if;
                                when 2 =>
                                    if (Z80_WRITE_BYTE = '0' and Z80_WRITE_HWORD = '0') then
                                        Z80_BUS_DATA_OUT       <= Z80_DATA_OUT(23 downto 16);
                                    else
                                        Z80_BUS_DATA_OUT       <= Z80_DATA_OUT(7 downto 0);
                                    end if;
                                when 3 =>
                                    if (Z80_WRITE_BYTE = '0' and Z80_WRITE_HWORD = '0') then
                                        Z80_BUS_DATA_OUT       <= Z80_DATA_OUT(31 downto 24);
                                    elsif (Z80_WRITE_HWORD = '1') then
                                        Z80_BUS_DATA_OUT       <= Z80_DATA_OUT(15 downto 8);
                                    else
                                        Z80_BUS_DATA_OUT       <= Z80_DATA_OUT(7 downto 0);
                                    end if;
                                when others =>
                            end case;

                        -- Activate Write and detect and insert wait states.
                        when State_IO_WRITE_1 =>
                            Z80_BUS_IORQn                      <= '0';
                            Z80_BUS_WRn                        <= '0';
                            Z80BusFSMState                     <= State_IO_WRITE_2;

                        -- Insert automatic wait state for IO operations.
                        when State_IO_WRITE_2 =>
                            if ZPU80_WAITn = '1' then
                                Z80BusFSMState                 <= State_IO_WRITE_3;
                            end if;

                        when State_IO_WRITE_3 =>
                            Z80_BUS_IORQn                      <= '1';
                            Z80_BUS_WRn                        <= '1';
                            if Z80_BYTE_COUNT > 0 then
                                Z80_BYTE_COUNT                 <= Z80_BYTE_COUNT -1;
                                Z80_BYTE_ADDR                  <= Z80_BYTE_ADDR + 1;
                                Z80BusFSMState                 <= Z80_BUS_XACT;
                            else
                                Z80BusFSMState                 <= State_IDLE;
                          --      Z80_XACT_RUN                   <= '0';
                            end if;

                        when others =>
                            Z80BusFSMState                     <= State_IDLE;
                    end case;
                end if;
            end if;
            
            -- The Z80 bus request mechanism, when active, bring all signals to an inactive state (not hi-Z).
            --
            if Z80_BUS_BUSACKn = '1' then
                ZPU80_ADDR                <= Z80_ADDR(15 downto 2) & std_logic_vector(Z80_BYTE_ADDR);
                ZPU80_DATA_OUT            <= Z80_BUS_DATA_OUT;
                ZPU80_MREQn               <= Z80_BUS_MREQn;
                ZPU80_IORQn               <= Z80_BUS_IORQn;
                ZPU80_RDn                 <= Z80_BUS_RDn;
                ZPU80_WRn                 <= Z80_BUS_WRn;
                ZPU80_M1n                 <= Z80_BUS_M1n;
                ZPU80_BUSACKn             <= '1';
            else
                ZPU80_ADDR                <= (others => '0');
                ZPU80_DATA_OUT            <= (others => '0');
                ZPU80_MREQn               <= '1';
                ZPU80_IORQn               <= '1';
                ZPU80_RDn                 <= '1';
                ZPU80_WRn                 <= '1';
                ZPU80_M1n                 <= '1';
                ZPU80_BUSACKn             <= '0';
            end if;
        end process;

    else generate
        ZPU80_DATA_OUT            <= (others => '1');
        ZPU80_MREQn               <= '1';
        ZPU80_IORQn               <= '1';
        ZPU80_RDn                 <= '1';
        ZPU80_WRn                 <= '1';
        ZPU80_M1n                 <= '1';
    end generate;

    ------------------------------------------------------------------------------------
    -- Direct Memory I/O devices
    ------------------------------------------------------------------------------------

    TIMER : if SOC_IMPL_TIMER1 = true generate
        -- TIMER
        TIMER1 : entity work.timer_controller
            generic map(
                prescale             => 1,                         -- Prescale incoming clock
                timers               => SOC_TIMER1_COUNTERS
            )
            port map (
                clk                  => ZPU_CLK,
                reset                => ZPU_RESETn,

                reg_addr_in          => MEM_ADDR(7 downto 0),
                reg_data_in          => MEM_DATA_WRITE,
                reg_rw               => '0', -- we never read from the timers
                reg_req              => TIMER_REG_REQ,

                ticks(0)             => TIMER1_TICK -- Tick signal is used to trigger an interrupt
            );

        process(ZPU_CLK, ZPU_RESETn)
        begin
            ------------------------
            -- HIGH LEVEL         --
            ------------------------

            ------------------------
            -- ASYNCHRONOUS RESET --
            ------------------------
            if ZPU_RESETn='0' then
                TIMER_REG_REQ                                       <= '0';
                IO_WAIT_TIMER1                                      <= '0';

            -----------------------
            -- RISING CLOCK EDGE --
            -----------------------                
            elsif rising_edge(ZPU_CLK) then

                IO_WAIT_TIMER1                                      <= '0';

                -- CPU Write?
                if MEM_WRITE_ENABLE = '1' and TIMER1_CS = '1' then

                    -- Write to Timer.
                    TIMER_REG_REQ                                   <= '1';

                -- IO Read?
                elsif MEM_READ_ENABLE = '1' and TIMER1_CS = '1' then

                end if;
            end if; -- rising-edge(ZPU_CLK)
        end process;

        TIMER1_CS                                                   <= '1' when IO_TIMER_SELECT = '1'  and MEM_ADDR(7 downto 6) = "01"     -- 0xC40-C7F
                                                                       else '0';
    else generate
        TIMER_REG_REQ                                               <= '0';
        IO_WAIT_TIMER1                                              <= '0';
    end generate;

    -- Interrupt controller
    INTRCTL: if SOC_IMPL_INTRCTL = true generate
        INTCONTROLLER : entity work.interrupt_controller
            generic map (
                max_int              => SOC_INTR_MAX
            )
            port map (
                clk                  => ZPU_CLK,
                reset_n              => ZPU_RESETn,
                trigger              => INT_TRIGGERS,
                enable_mask          => INT_ENABLE,
                ack                  => INT_DONE,
                int                  => INT_REQ,
                status               => INT_STATUS
            );

        process(ZPU_CLK, ZPU_RESETn)
        begin
            ------------------------
            -- HIGH LEVEL         --
            ------------------------

            ------------------------
            -- ASYNCHRONOUS RESET --
            ------------------------
            if ZPU_RESETn='0' then
                INT_ENABLE                                          <= (others => '0');
                IO_WAIT_INTR                                        <= '0';
                IO_DATA_READ_INTRCTL                                <= (others => 'X');

            -----------------------
            -- RISING CLOCK EDGE --
            -----------------------                
            elsif rising_edge(ZPU_CLK) then

                IO_WAIT_INTR                                        <= '0';

                -- CPU Write?
                if MEM_WRITE_ENABLE = '1' and INTR0_CS = '1' then

                    -- Write to interrupt controller sets the enable mask bits.
                    case MEM_ADDR(2) is
                        when '0' =>

                        when '1' =>
                            INT_ENABLE                              <= MEM_DATA_WRITE(SOC_INTR_MAX downto 0);
                    end case;

                -- IO Read?
                elsif MEM_READ_ENABLE = '1' and INTR0_CS = '1' then

                    -- Read interrupt status, 32 bits showing which interrupts have been triggered.
                    IO_DATA_READ_INTRCTL                            <= (others => 'X');
                    if MEM_ADDR(2) = '0' then
                        IO_DATA_READ_INTRCTL(SOC_INTR_MAX downto 0) <= INT_STATUS;
                    else
                        Io_DATA_READ_INTRCTL(SOC_INTR_MAX downto 0) <= INT_ENABLE;
                    end if;

                end if;
            end if; -- rising-edge(ZPU_CLK)
        end process;
    
        INT_TRIGGERS                 <= ( 0      => '0',
                                          1      => MICROSEC_DOWN_INTR,
                                          2      => MILLISEC_DOWN_INTR,
                                          3      => SECOND_DOWN_INTR,
                                          4      => TIMER1_TICK,
                                          5      => '0',                         -- PS2_INT
                                          6      => '0',                         -- IOCTL_RDINT
                                          7      => '0',                         -- IOCTL_WRINT
                                          8      => '0',
                                          9      => '0',
                                         10      => '0',
                                         11      => '0',
                                         others  => '0');
        INT_TRIGGER                  <= INT_REQ;    

        INTR0_CS                     <= '1' when IO_SELECT = '1'   and MEM_ADDR(11 downto 4) = "10110000"  -- Interrupt Range 0xFFFFFBxx, 0xB00-B0F
                                        else '0';

    else generate
        IO_DATA_READ_INTRCTL                                        <= (others => 'X');
        INT_TRIGGER                                                 <= '0';
        INT_ENABLE                                                  <= (others => '0');
        IO_WAIT_INTR                                                <= '0';
    end generate;

    IMPLSOCCFG: if SOC_IMPL_SOCCFG = true generate
        process(ZPU_CLK, ZPU_RESETn)
        begin
            ------------------------
            -- HIGH LEVEL         --
            ------------------------

            ------------------------
            -- ASYNCHRONOUS RESET --
            ------------------------
            if ZPU_RESETn='0' then
    
            -----------------------
            -- RISING CLOCK EDGE --
            -----------------------                
            elsif rising_edge(ZPU_CLK) then
    
                -- SoC Configuration.
                IO_DATA_READ_SOCCFG                                 <= (others => 'X');
                case MEM_ADDR(7 downto 2) is
                    when "000000" => -- ZPU Id
                        IO_DATA_READ_SOCCFG(31 downto 28)           <= "1010";                                                            -- Identifier to show SoC Configuration registers are implemented.
                        IO_DATA_READ_SOCCFG(15 downto 0)            <= std_logic_vector(to_unsigned(ZPU_ID_EVO, 16));

                    when "000001" => -- System Frequency
                        IO_DATA_READ_SOCCFG                         <= std_logic_vector(to_unsigned(SYSCLK_FREQUENCY, wordSize));

                    when "000010" => -- Sysbus Memory Frequency
                        IO_DATA_READ_SOCCFG                         <= (others => 'X');

                    when "000011" => -- Wishbone Memory Frequency
                        IO_DATA_READ_SOCCFG                         <= (others => 'X');

                    when "000100" => -- Devices Implemented
                        IO_DATA_READ_SOCCFG(22 downto 0)            <= '0'                                                      &
                                                                       '0'                                                      & 
                                                                       '0'                                                      &
                                                                       to_std_logic(SOC_IMPL_BRAM)                              & 
                                                                       to_std_logic(SOC_IMPL_RAM)                               & 
                                                                       to_std_logic(SOC_IMPL_INSN_BRAM)                         &
                                                                       '0'                                                      & 
                                                                       '0'                                                      &
                                                                       '0'                                                      &
                                                                       '0'                                                      &
                                                                       '0'                                                      & 
                                                                       std_logic_vector(to_unsigned(0,          2)) &
                                                                       to_std_logic(SOC_IMPL_INTRCTL)                           & 
                                                                       std_logic_vector(to_unsigned(SOC_INTR_MAX,           5)) &
                                                                       to_std_logic(SOC_IMPL_TIMER1)                            & 
                                                                       std_logic_vector(to_unsigned(2**SOC_TIMER1_COUNTERS, 3));

                    when "000101" => -- BRAM Address
                        if SOC_IMPL_BRAM = true then
                            IO_DATA_READ_SOCCFG                     <= std_logic_vector(to_unsigned(SOC_ADDR_BRAM_START, wordSize));
                        end if;

                    when "000110" => -- BRAM Size
                        if SOC_IMPL_BRAM = true then
                            IO_DATA_READ_SOCCFG                     <= std_logic_vector(to_unsigned(SOC_ADDR_BRAM_END - SOC_ADDR_BRAM_START, wordSize));
                        else
                            IO_DATA_READ_SOCCFG                     <= (others => 'X');
                        end if;

                    when "000111" => -- RAM Address
                        if SOC_IMPL_RAM = true then
                            IO_DATA_READ_SOCCFG                     <= std_logic_vector(to_unsigned(SOC_ADDR_RAM_START, wordSize));
                        else
                            IO_DATA_READ_SOCCFG                     <= (others => 'X');
                        end if;

                    when "001000" => -- RAM Size
                        if SOC_IMPL_RAM = true then
                            IO_DATA_READ_SOCCFG                     <= std_logic_vector(to_unsigned(SOC_ADDR_RAM_END - SOC_ADDR_RAM_START, wordSize));
                        else
                            IO_DATA_READ_SOCCFG                     <= (others => 'X');
                        end if;

                    when "001001" => -- Instruction BRAM Address
                        if SOC_IMPL_INSN_BRAM = true then
                            IO_DATA_READ_SOCCFG                     <= std_logic_vector(to_unsigned(SOC_ADDR_INSN_BRAM_START, wordSize));
                        else
                            IO_DATA_READ_SOCCFG                     <= (others => 'X');
                        end if;

                    when "001010" => -- Instruction BRAM Size
                        if SOC_IMPL_INSN_BRAM = true then
                            IO_DATA_READ_SOCCFG                     <= std_logic_vector(to_unsigned(SOC_ADDR_INSN_BRAM_END - SOC_ADDR_INSN_BRAM_START, wordSize));
                        else
                            IO_DATA_READ_SOCCFG                     <= (others => 'X');
                        end if;

                    when "001011" => -- SDRAM Address
                        IO_DATA_READ_SOCCFG                     <= (others => 'X');

                    when "001100" => -- SDRAM Size
                        IO_DATA_READ_SOCCFG                     <= (others => 'X');

                    when "001101" => -- WB SDRAM Address
                        IO_DATA_READ_SOCCFG                     <= (others => 'X');

                    when "001110" => -- WB SDRAM Size
                        IO_DATA_READ_SOCCFG                     <= (others => 'X');

                    when "001111" => -- CPU Reset Address
                        IO_DATA_READ_SOCCFG                         <= std_logic_vector(to_unsigned(SOC_RESET_ADDR_CPU, wordSize));

                    when "010000" => -- CPU Memory Start Address
                        IO_DATA_READ_SOCCFG                         <= std_logic_vector(to_unsigned(SOC_START_ADDR_MEM, wordSize));

                    when "010001" => -- Stack Start Address
                        IO_DATA_READ_SOCCFG                         <= std_logic_vector(to_unsigned(SOC_STACK_ADDR, wordSize));

                    when others =>
                end case;
            end if; -- rising-edge(ZPU_CLK)
        end process;

        SOCCFG_CS             <= '1' when IO_SELECT = '1' and MEM_ADDR(11 downto 8) = "1111"          -- SoC Config Range 0xF00-FF0, step 4 for 32 bit registers.
                                 else '0';
    else generate
        IO_DATA_READ_SOCCFG                                         <= (others => '0');
    end generate;

   -- Main peripheral process, decode address and activate memory/peripheral accordingly.        
    process(ZPU_CLK, ZPU_RESETn)
    begin
        ------------------------
        -- HIGH LEVEL         --
        ------------------------

        ------------------------
        -- ASYNCHRONOUS RESET --
        ------------------------
        if ZPU_RESETn='0' then
            MICROSEC_DOWN_COUNTER                                   <= (others => '0');
            MILLISEC_DOWN_COUNTER                                   <= (others => '0');
            MILLISEC_UP_COUNTER                                     <= (others => '0');
            SECOND_DOWN_COUNTER                                     <= (others => '0');
            MICROSEC_DOWN_TICK                                      <= 0;
            MILLISEC_DOWN_TICK                                      <= 0;
            SECOND_DOWN_TICK                                        <= 0;
            MILLISEC_UP_TICK                                        <= 0;
            MICROSEC_DOWN_INTR                                      <= '0';
            MICROSEC_DOWN_INTR_EN                                   <= '0';
            MILLISEC_DOWN_INTR                                      <= '0';
            MILLISEC_DOWN_INTR_EN                                   <= '0';
            SECOND_DOWN_INTR                                        <= '0';
            SECOND_DOWN_INTR_EN                                     <= '0';
            RTC_MICROSEC_TICK                                       <= 0;
            RTC_MICROSEC_COUNTER                                    <= 0;
            RTC_MILLISEC_COUNTER                                    <= 0;
            RTC_MILLISEC_FS_COUNTER                                 <= (others => '0');
            RTC_SECOND_COUNTER                                      <= 0;
            RTC_MINUTE_COUNTER                                      <= 0;
            RTC_HOUR_COUNTER                                        <= 0;
            RTC_DAY_COUNTER                                         <= 1;
            RTC_MONTH_COUNTER                                       <= 1;
            RTC_YEAR_COUNTER                                        <= 0;
            RTC_TICK_HALT                                           <= '0';

        -----------------------
        -- RISING CLOCK EDGE --
        -----------------------                
        elsif rising_edge(ZPU_CLK) then

            -- CPU Write?
            if MEM_WRITE_ENABLE = '1' and IO_SELECT = '1' then

                -- Write to Millisecond Timer - set current time and day.
                if TIMER0_CS = '1' then
                    case MEM_ADDR(5 downto 2) is
                        when "0000" =>
                            MICROSEC_DOWN_COUNTER(23 downto 0)      <= unsigned(MEM_DATA_WRITE(23 downto 0));
                            MICROSEC_DOWN_TICK                      <= 0;

                        when "0001" =>
                            MILLISEC_DOWN_COUNTER(17 downto 0)      <= unsigned(MEM_DATA_WRITE(17 downto 0));
                            MILLISEC_DOWN_TICK                      <= 0;

                        when "0010" =>
                            MILLISEC_UP_COUNTER(31 downto 0)        <= unsigned(MEM_DATA_WRITE(31 downto 0));
                            MILLISEC_UP_TICK                        <= 0;

                        when "0011" =>
                            SECOND_DOWN_COUNTER(11 downto 0)        <= unsigned(MEM_DATA_WRITE(11 downto 0));
                            SECOND_DOWN_TICK                        <= 0;

                        when "0111" =>
                            RTC_TICK_HALT                           <= MEM_DATA_WRITE(0);

                        when "1000" =>
                            RTC_MICROSEC_COUNTER                    <= to_integer(unsigned(MEM_DATA_WRITE(9 downto 0)));
                            RTC_MICROSEC_TICK                       <= 0;

                        when "1001" =>
                            RTC_MILLISEC_COUNTER                    <= to_integer(unsigned(MEM_DATA_WRITE(9 downto 0)));
                            RTC_MICROSEC_TICK                       <= 0;

                        when "1010" =>
                            RTC_SECOND_COUNTER                      <= to_integer(unsigned(MEM_DATA_WRITE(5 downto 0)));
                            RTC_MICROSEC_TICK                       <= 0;

                        when "1011" =>
                            RTC_MINUTE_COUNTER                      <= to_integer(unsigned(MEM_DATA_WRITE(5 downto 0)));
                            RTC_MICROSEC_TICK                       <= 0;

                        when "1100" =>
                            RTC_HOUR_COUNTER                        <= to_integer(unsigned(MEM_DATA_WRITE(4 downto 0)));
                            RTC_MICROSEC_TICK                       <= 0;

                        when "1101" =>
                            RTC_DAY_COUNTER                         <= to_integer(unsigned(MEM_DATA_WRITE(3 downto 0)));
                            RTC_MICROSEC_TICK                       <= 0;

                        when "1110" =>
                            RTC_MONTH_COUNTER                       <= to_integer(unsigned(MEM_DATA_WRITE(3 downto 0)));
                            RTC_MICROSEC_TICK                       <= 0;

                        when "1111" =>
                            RTC_YEAR_COUNTER                        <= to_integer(unsigned(MEM_DATA_WRITE(11 downto 0)));
                            RTC_MICROSEC_TICK                       <= 0;

                        when others =>
                    end case;
                end if;
            end if;

            -- Read from millisecond timer, read milliseconds in last 24 hours and number of elapsed days.
            if TIMER0_CS = '1' then
                IO_DATA_READ                                        <= (others => '0');
                case MEM_ADDR(5 downto 2) is
                    when "0000" =>
                        IO_DATA_READ(23 downto 0)                   <= std_logic_vector(MICROSEC_DOWN_COUNTER(23 downto 0));

                    when "0001" =>
                        IO_DATA_READ(17 downto 0)                   <= std_logic_vector(MILLISEC_DOWN_COUNTER(17 downto 0));

                    when "0010" =>
                        IO_DATA_READ(31 downto 0)                   <= std_logic_vector(MILLISEC_UP_COUNTER(31 downto 0));

                    when "0011" =>
                        IO_DATA_READ(11 downto 0)                   <= std_logic_vector(SECOND_DOWN_COUNTER(11 downto 0));

                    when "0111" =>
                        IO_DATA_READ(31 downto 0)                   <= std_logic_vector(RTC_MILLISEC_FS_COUNTER(31 downto 0));

                    when "1000" =>
                        IO_DATA_READ(9 downto 0)                    <= std_logic_vector(to_unsigned(RTC_MICROSEC_COUNTER, 10));

                    when "1001" =>
                        IO_DATA_READ(9 downto 0)                    <= std_logic_vector(to_unsigned(RTC_MILLISEC_COUNTER, 10));

                    when "1010" =>
                        IO_DATA_READ(5 downto 0)                    <= std_logic_vector(to_unsigned(RTC_SECOND_COUNTER, 6));

                    when "1011" =>
                        IO_DATA_READ(5 downto 0)                    <= std_logic_vector(to_unsigned(RTC_MINUTE_COUNTER, 6));

                    when "1100" =>
                        IO_DATA_READ(4 downto 0)                    <= std_logic_vector(to_unsigned(RTC_HOUR_COUNTER, 5));

                    when "1101" =>
                        IO_DATA_READ(4 downto 0)                    <= std_logic_vector(to_unsigned(RTC_DAY_COUNTER, 5));

                    when "1110" =>
                        IO_DATA_READ(3 downto 0)                    <= std_logic_vector(to_unsigned(RTC_MONTH_COUNTER, 4));

                    when "1111" =>
                        IO_DATA_READ(11 downto 0)                   <= std_logic_vector(to_unsigned(RTC_YEAR_COUNTER, 12));

                    when others =>
                end case;
            end if;

            -- Timer in microseconds, Each 24 hours the timer is zeroed and the day counter incremented. Used for delay loops
            -- and RTC.
            if RTC_TICK_HALT = '0' then
                RTC_MICROSEC_TICK                                   <= RTC_MICROSEC_TICK+1;
            end if;
            if RTC_MICROSEC_TICK = ((SYSCLK_FREQUENCY/1000000) -1) then                                 -- Sys clock has to be > 1MHz or will not be accurate.
                RTC_MICROSEC_TICK                                   <= 0;
                RTC_MICROSEC_COUNTER                                <= RTC_MICROSEC_COUNTER + 1;

                if RTC_MICROSEC_COUNTER = (1000 - 1) then
                    RTC_MICROSEC_COUNTER                            <= 0;
                    RTC_MILLISEC_COUNTER                            <= RTC_MILLISEC_COUNTER + 1;
                    RTC_MILLISEC_FS_COUNTER                         <= RTC_MILLISEC_FS_COUNTER + 1;

                    if RTC_MILLISEC_COUNTER = (1000 - 1) then
                        RTC_SECOND_COUNTER                          <= RTC_SECOND_COUNTER + 1; 
                        RTC_MILLISEC_COUNTER                        <= 0;

                        if RTC_SECOND_COUNTER = (60 - 1) then
                            RTC_MINUTE_COUNTER                      <= RTC_MINUTE_COUNTER + 1;
                            RTC_SECOND_COUNTER                      <= 0;

                            if RTC_MINUTE_COUNTER = (60 - 1) then
                                RTC_HOUR_COUNTER                    <= RTC_HOUR_COUNTER + 1;
                                RTC_MINUTE_COUNTER                  <= 0;

                                if RTC_HOUR_COUNTER = (24 - 1) then
                                    RTC_DAY_COUNTER                 <= RTC_DAY_COUNTER + 1;
                                    RTC_HOUR_COUNTER                <= 0;

                                    if (RTC_DAY_COUNTER = 31 and (RTC_MONTH_COUNTER = 4 or RTC_MONTH_COUNTER = 6 or RTC_MONTH_COUNTER = 9 or RTC_MONTH_COUNTER = 11)) 
                                       or
                                       (RTC_DAY_COUNTER = 32 and RTC_MONTH_COUNTER /= 4 and RTC_MONTH_COUNTER /= 6 and RTC_MONTH_COUNTER /= 9 and RTC_MONTH_COUNTER /= 11)
                                       or
                                       (RTC_DAY_COUNTER = 29 and RTC_MONTH_COUNTER = 2 and std_logic_vector(to_unsigned(RTC_YEAR_COUNTER, 2)) /= "00")
                                       or
                                       (RTC_DAY_COUNTER = 30 and RTC_MONTH_COUNTER = 2 and std_logic_vector(to_unsigned(RTC_YEAR_COUNTER, 2))  = "00")
                                    then
                                        RTC_MONTH_COUNTER           <= RTC_MONTH_COUNTER + 1;
                                        RTC_DAY_COUNTER             <= 1;

                                        if RTC_MONTH_COUNTER = 13 then
                                            RTC_YEAR_COUNTER        <= RTC_YEAR_COUNTER + 1;
                                            RTC_MONTH_COUNTER       <= 1;
                                        end if;
                                    end if;
                                end if;
                            end if;
                        end if;
                    end if;
                end if;
            end if;

            -- Down and up counters, each have independent ticks which reset on counter set, this guarantees timer is accurate.
            MICROSEC_DOWN_TICK                                      <= MICROSEC_DOWN_TICK+1;
            if MICROSEC_DOWN_TICK = ((SYSCLK_FREQUENCY/1000000) -1) then                            -- Sys clock has to be > 1MHz or will not be accurate.
                MICROSEC_DOWN_TICK                                  <= 0;

                -- Decrement microsecond down counter if not yet zero.
                if MICROSEC_DOWN_COUNTER /= 0 then
                    MICROSEC_DOWN_COUNTER                           <= MICROSEC_DOWN_COUNTER - 1;
                end if;
                if MICROSEC_DOWN_COUNTER = 0 and MICROSEC_DOWN_INTR_EN = '1' then
                    MICROSEC_DOWN_INTR                              <= '1';
                end if;
            end if;

            MILLISEC_DOWN_TICK                                      <= MILLISEC_DOWN_TICK+1;
            if MILLISEC_DOWN_TICK = (((SYSCLK_FREQUENCY/1000000)*1000) -1) then                     -- Sys clock has to be > 1MHz or will not be accurate.
                MILLISEC_DOWN_TICK                                  <= 0;

                -- Decrement millisecond down counter if not yet zero.
                if MILLISEC_DOWN_COUNTER /= 0 then
                    MILLISEC_DOWN_COUNTER                           <= MILLISEC_DOWN_COUNTER - 1;
                end if;
                if MILLISEC_DOWN_COUNTER = 0 and MILLISEC_DOWN_INTR_EN = '1' then
                    MILLISEC_DOWN_INTR                              <= '1';
                end if;
            end if;

            MILLISEC_UP_TICK                                        <= MILLISEC_UP_TICK+1;
            if MILLISEC_UP_TICK = (((SYSCLK_FREQUENCY/1000000)*1000) - 1) then                      -- Sys clock has to be > 1MHz or will not be accurate.
                MILLISEC_UP_TICK                                    <= 0;
                MILLISEC_UP_COUNTER                                 <= MILLISEC_UP_COUNTER + 1;
            end if;

            SECOND_DOWN_TICK                                        <= SECOND_DOWN_TICK+1;
            if SECOND_DOWN_TICK = (((SYSCLK_FREQUENCY/1000000)*1000000) - 1) then                   -- Sys clock has to be > 1MHz or will not be accurate.
                SECOND_DOWN_TICK                                    <= 0;

                -- Decrement second down counter if not yet zero.
                if SECOND_DOWN_COUNTER /= 0 then
                    SECOND_DOWN_COUNTER                             <= SECOND_DOWN_COUNTER - 1;
                end if;
                if SECOND_DOWN_COUNTER = 0 and SECOND_DOWN_INTR_EN = '1' then
                    SECOND_DOWN_INTR                                <= '1';
                end if;
            end if;
        end if; -- rising-edge(ZPU_CLK)
    end process;
end architecture;
