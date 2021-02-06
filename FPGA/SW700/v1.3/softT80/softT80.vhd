---------------------------------------------------------------------------------------------------------
--
-- Name:            softT80.vhd
-- Created:         December 2020
-- Author(s):       Philip Smart
-- Description:     Sharp MZ Series FPGA soft cpu module - T80.
--                                                     
--                  This module provides a soft CPU to the Sharp MZ Core running on a Sharp MZ-700 with
--                  the tranZPUter SW-700 v1.3-> board and will be migrated to the pure FPGA tranZPUter
--                  v2.2 board in due course.
--
-- Credits:         
-- Copyright:       (c) 2018-20 Philip Smart <philip.smart@net2net.org>
--
-- History:         Dec 2020  - Initial creation.
--                  Jan 2021  - Addition of the AZ80 and the NextZ80. The AZ80 basically works but the
--                              timing is a little out for physical Sharp I/O device access located in 
--                              main memory (E000:E7FF). This results in occasional keys being detected
--                              so needs investigation into the AZ80 code. The NextZ80 needs more work
--                              as it was not intended to run with a physical machine so doesnt have 
--                              the needed signals or timing.
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
use     work.softT80_pkg.all;
use     altera.altera_syn_attributes.all;
use     altera_mf.all;

entity softT80 is
    --generic (
    --);
    Port (
        -- System signals and clocks.
        SYS_RESETn                : in    std_logic;                                     -- System reset.
        SYS_CLK                   : in    std_logic;                                     -- System logic clock ~120MHz
        Z80_CLK                   : in    std_logic;                                     -- Underlying hardware system clock

        -- Software controlled signals.
        SW_RESET                  : in    std_logic;                                     -- Software controlled reset.
        SW_CLKEN                  : in    std_logic;                                     -- Software controlled clock enable.
        SW_CPUEN                  : in    std_logic;                                     -- Software controlled CPU enable.
      
        -- Core Sharp MZ signals.
        T80_WAITn                 : in    std_logic;                                     -- WAITn signal into the CPU to prolong a memory cycle.
        T80_INTn                  : in    std_logic;                                     -- INTn signal for maskable interrupts.
        T80_NMIn                  : in    std_logic;                                     -- NMIn non maskable interrupt input.
        T80_BUSRQn                : in    std_logic;                                     -- BUSRQn signal to request CPU go into tristate and relinquish bus.
        T80_M1n                   : out   std_logic;                                     -- M1n Machine Cycle 1 signal. M1 and MREQ active = opcode fetch, M1 and IORQ active = interrupt, vector can be read from D0-D7.
        T80_MREQn                 : out   std_logic;                                     -- MREQn signal indicates that the address bus holds a valid address for reading or writing memory.
        T80_IORQn                 : out   std_logic;                                     -- IORQn signal indicates that the address bus (A0-A7) holds a valid address for reading or writing and I/O device.
        T80_RDn                   : out   std_logic;                                     -- RDn signal indicates that data is ready to be read from a memory or I/O device to the CPU.
        T80_WRn                   : out   std_logic;                                     -- WRn signal indicates that data is going to be written from the CPU data bus to a memory or I/O device.
        T80_RFSHn                 : out   std_logic;                                     -- RFSHn signal to indicate dynamic memory refresh can take place.
        T80_HALTn                 : out   std_logic;                                     -- HALTn signal indicates that the CPU has executed a "HALT" instruction.
        T80_BUSACKn               : out   std_logic;                                     -- BUSACKn signal indicates that the CPU address bus, data bus, and control signals have entered their HI-Z states, and that the external circuitry can now control these lines.
        T80_ADDR                  : out   std_logic_vector(15 downto 0);                 -- 16 bit address lines.
        T80_DATA_IN               : in    std_logic_vector(7 downto 0);                  -- 8 bit data bus in.
        T80_DATA_OUT              : out   std_logic_vector(7 downto 0)                   -- 8 bit data bus out.
    );
END entity;

architecture rtl of softT80 is

    -- T80 Control signals.
    --
    signal T80_RESETn             :       std_logic; 
    signal T80_CLK                :       std_logic; 
    signal T80_CLKEN              :       std_logic; 
    signal T80_BUSACKni           :       std_logic; 
    signal Z80_CLK_LAST           :       std_logic_vector(2 downto 0);

    -- The T80 CPU definition.
    component T80se
        generic (
              Mode                :       integer := 0;                                  -- 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
		      T2Write             :       integer := 0;                                  -- 0 => WR_n active in T3, /=0 => WR_n active in T2        
              IOWait              :       integer := 1                                   -- 0 => Single cycle I/O, 1 => Std I/O cycle
        );
        Port (
              RESET_n             : in    std_logic;
              CLK_n               : in    std_logic;                                     -- NB. Clock is high active.
              CLKEN               : in    std_logic;
              WAIT_n              : in    std_logic;
              INT_n               : in    std_logic;
              NMI_n               : in    std_logic;
              BUSRQ_n             : in    std_logic;
              M1_n                : out   std_logic;
              MREQ_n              : out   std_logic;
              IORQ_n              : out   std_logic;
              RD_n                : out   std_logic;
              WR_n                : out   std_logic;
              RFSH_n              : out   std_logic;
              HALT_n              : out   std_logic;
              BUSAK_n             : out   std_logic;
              A                   : out   std_logic_vector(15 downto 0);
              DI                  : in    std_logic_vector(7 downto 0);
              DO                  : out   std_logic_vector(7 downto 0)
        );
    end component;    

    -- The AZ80 CPU definition.
    component AZ80
        --generic (
        --);
        Port (
              nM1                 : out   std_logic;
              nMREQ               : out   std_logic;
              nIORQ               : out   std_logic;
              nRD                 : out   std_logic;
              nWR                 : out   std_logic;
              nRFSH               : out   std_logic;
              nHALT               : out   std_logic;
              nBUSACK             : out   std_logic;

              nWAIT               : in    std_logic;
              nINT                : in    std_logic;
              nNMI                : in    std_logic;
              nRESET              : in    std_logic;
              nBUSRQ              : in    std_logic;

              CLK                 : in    std_logic;
              A                   : out   std_logic_vector(15 downto 0);
              D                   : inout std_logic_vector(7 downto 0) 
        );
    end component;    

    -- The NextZ80 CPU definition.
    component NextZ80
        --generic (
        --);
        Port (
              M1                  : out   std_logic;
              MREQ                : out   std_logic;
              IORQ                : out   std_logic;
              WR                  : out   std_logic;
              HALT                : out   std_logic;

              ZWAIT               : in    std_logic;
              INT                 : in    std_logic;
              NMI                 : in    std_logic;
              RESET               : in    std_logic;

              CLK                 : in    std_logic;
              ADDR                : out   std_logic_vector(15 downto 0);
              DI                  : in    std_logic_vector(7 downto 0);
              DO                  : out   std_logic_vector(7 downto 0)
        );
    end component;    

begin

    -- As the Z80 clock is originating in the CPLD and it is a mux between the mainboard generated clock and the K64F variable frequency clock, we need to bring it into this soft CPU
    -- domain for better sync and timing.
    --
--    process(SYS_RESETn, Z80_CLK, Z80_CLK)
--    begin
--        if SYS_RESETn = '0' then
--            T80_CLK              <= '0';
--
--        elsif rising_edge(Z80_CLK) then
--            -- Detect the clock edges.
--            Z80_CLK_LAST         <= Z80_CLK_LAST(1 downto 0) & Z80_CLK;
--
--            --if Z80_CLK_LAST = "111" and Z80_CLK = '0' then
--            if Z80_CLK = '1' then
--                T80_CLK          <= '0';
--            end if;
--
--            --if Z80_CLK_LAST = "000" and Z80_CLK = '1' and SW_CLKEN = '1' then
--            if Z80_CLK = '0' and SW_CLKEN = '1' then
--                T80_CLK          <= '1';
--            end if;
--        end if;
--    end process;
    T80_CLK <= '1' when Z80_CLK = '1' and SW_CLKEN = '1'
               else '0';

    -- Process to reliably reset the T80. The T80 is disabled whilst in hard CPU mode, once switched to soft CPU, the reset is 
    -- activated and held low whilst the CPLD changes its state, this is done via a count down counter, holding RESET low beyond the system
    -- reset.
    --
    process(SYS_RESETn, T80_CLK, SW_RESET, SW_CPUEN)
        variable T80_RESET_COUNTER: unsigned(3 downto 0) := (others => '1');
    begin
        if SYS_RESETn = '0' then
            T80_RESET_COUNTER     := (others => '1');
            T80_RESETn            <= '0';

        elsif rising_edge(T80_CLK) then
            -- If reset enabled or the CPU is disabled, hold CPU in reset.
            if SW_RESET = '1' or SW_CPUEN = '0' then
                T80_RESET_COUNTER := (others => '1');
                T80_RESETn        <= '0';
            end if;

            if T80_RESET_COUNTER = 0 then
                T80_RESETn        <= '1';
            end if;

            if T80_RESET_COUNTER /= 0 then
                T80_RESET_COUNTER := T80_RESET_COUNTER - 1;
            end if;
        end if;
    end process;


    ------------------------------------------------------------------------------------
    -- T80 CPU or A-Z80 CPU
    ------------------------------------------------------------------------------------    

    CPU0 :if IMPL_SOFTCPU_T80 = true generate
        T80CPU : T80se
        generic map (
            Mode            => 0,                                                   -- 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
            T2Write         => 1,
            IOWait          => 1                                                    -- 
        )
        port map (
            RESET_n         => T80_RESETn,                                          -- Reset signal.
            CLK_n           => T80_CLK,                                             -- T80a clock, sane as the hardware clock but synchronised to the system clock.
            CLKEN           => SW_CLKEN,                                            -- Only clock the T80 when enabled.
            WAIT_n          => T80_WAITn,                                           -- WAITn signal into the CPU to prolong a memory cycle.
            INT_n           => T80_INTn,                                            -- INTn signal for maskable interrupts.
            NMI_n           => T80_NMIn,                                            -- NMIn non maskable interrupt input.
            BUSRQ_n         => T80_BUSRQn,                                          -- BUSRQn signal to request CPU go into tristate and relinquish bus.
            M1_n            => T80_M1n,                                             -- M1n Machine Cycle 1 signal. M1 and MREQ active = opcode fetch, M1 and IORQ active = interrupt, vector can be read from D0-D7.
            MREQ_n          => T80_MREQn,                                           -- MREQn signal indicates that the address bus holds a valid address for reading or writing memory.
            IORQ_n          => T80_IORQn,                                           -- IORQn signal indicates that the address bus (A0-A7) holds a valid address for reading or writing and I/O device.
            RD_n            => T80_RDn,                                             -- RDn signal indicates that data is ready to be read from a memory or I/O device to the CPU.
            WR_n            => T80_WRn,                                             -- WRn signal indicates that data is going to be written from the CPU data bus to a memory or I/O device.
            RFSH_n          => T80_RFSHn,                                           -- RFSHn signal to indicate dynamic memory refresh can take place.
            HALT_n          => T80_HALTn,                                           -- HALTn signal indicates that the CPU has executed a "HALT" instruction.
            BUSAK_n         => T80_BUSACKni,                                        -- BUSACKn signal indicates that the CPU address bus, data bus, and control signals have entered their HI-Z states, and that the external circuitry can now control these lines.
            A               => T80_ADDR,                                            -- 16 bit address lines.
            DI              => T80_DATA_IN,                                         -- 8 bit data bus in.
            DO              => T80_DATA_OUT                                         -- 8 bit data bus out.
        );
    end generate;

    CPU1 :if IMPL_SOFTCPU_AZ80 = true generate
        signal T80_DATA     : std_logic_vector(7 downto 0);
    begin
        CPU0 : AZ80
        --generic (
        --);
        Port map (
            nM1             => T80_M1n,                                             -- M1n Machine Cycle 1 signal. M1 and MREQ active = opcode fetch, M1 and IORQ active = interrupt, vector can be read from D0-D7.
            nMREQ           => T80_MREQn,                                           -- MREQn signal indicates that the address bus holds a valid address for reading or writing memory.
            nIORQ           => T80_IORQn,                                           -- IORQn signal indicates that the address bus (A0-A7) holds a valid address for reading or writing and I/O device.
            nRD             => T80_RDn,                                             -- RDn signal indicates that data is ready to be read from a memory or I/O device to the CPU.
            nWR             => T80_WRn,                                             -- WRn signal indicates that data is going to be written from the CPU data bus to a memory or I/O device.
            nRFSH           => T80_RFSHn,                                           -- RFSHn signal to indicate dynamic memory refresh can take place.
            nHALT           => T80_HALTn,                                           -- HALTn signal indicates that the CPU has executed a "HALT" instruction.
            nBUSACK         => T80_BUSACKni,                                        -- BUSACKn signal indicates that the CPU address bus, data bus, and control signals have entered their HI-Z states, and that the external circuitry can now control these lines.

            nWAIT           => T80_WAITn,                                           -- WAITn signal into the CPU to prolong a memory cycle.
            nINT            => T80_INTn,                                            -- INTn signal for maskable interrupts.
            nNMI            => T80_NMIn,                                            -- NMIn non maskable interrupt input.
            nRESET          => T80_RESETn,                                          -- Reset signal.
            nBUSRQ          => T80_BUSRQn,                                          -- BUSRQn signal to request CPU go into tristate and relinquish bus.

            CLK             => T80_CLK,                                             -- T80a clock, sane as the hardware clock but synchronised to the system clock.
            A               => T80_ADDR,                                            -- 16 bit address lines.
            D               => T80_DATA                                             -- 8 bit data bus in.
        );

        -- Demux the Data Bus.
        T80_DATA            <= T80_DATA_IN when T80_RDn = '0'
                               else (others => 'Z');
        T80_DATA_OUT        <= T80_DATA;
    end generate;

    CPU2 :if IMPL_SOFTCPU_NEXTZ80 = true generate
        signal M1           : std_logic;
        signal MREQ         : std_logic;
        signal IORQ         : std_logic;
        signal WR           : std_logic;
        signal HALT         : std_logic;
    begin
        CPU0 : NextZ80
        Port map (
            RESET           => not T80_RESETn,                                      -- Reset signal.
            CLK             => T80_CLK,                                             -- T80a clock, sane as the hardware clock but synchronised to the system clock.
            ZWAIT           => not T80_WAITn,                                       -- WAITn signal into the CPU to prolong a memory cycle.
            INT             => not T80_INTn,                                        -- INTn signal for maskable interrupts.
            NMI             => not T80_NMIn,                                        -- NMIn non maskable interrupt input.
            M1              => M1,                                                  -- M1n Machine Cycle 1 signal. M1 and MREQ active = opcode fetch, M1 and IORQ active = interrupt, vector can be read from D0-D7.
            MREQ            => MREQ,                                                -- MREQn signal indicates that the address bus holds a valid address for reading or writing memory.
            IORQ            => IORQ,                                                -- IORQn signal indicates that the address bus (A0-A7) holds a valid address for reading or writing and I/O device.
            WR              => WR,                                                  -- WRn signal indicates that data is going to be written from the CPU data bus to a memory or I/O device.
            HALT            => HALT,                                                -- HALTn signal indicates that the CPU has executed a "HALT" instruction.
            ADDR            => T80_ADDR,                                            -- 16 bit address lines.
            DI              => T80_DATA_IN,                                         -- 8 bit data bus in.
            DO              => T80_DATA_OUT                                         -- 8 bit data bus out.
        );
        T80_M1n             <= not M1;                                              -- M1n Machine Cycle 1 signal. M1 and MREQ active = opcode fetch, M1 and IORQ active = interrupt, vector can be read from D0-D7.
        T80_MREQn           <= not MREQ;                                            -- MREQn signal indicates that the address bus holds a valid address for reading or writing memory.
        T80_IORQn           <= not IORQ;                                            -- IORQn signal indicates that the address bus (A0-A7) holds a valid address for reading or writing and I/O device.
        T80_WRn             <= not WR;                                              -- WRn signal indicates that data is going to be written from the CPU data bus to a memory or I/O device.
        T80_HALTn           <= not HALT;                                            -- HALTn signal indicates that the CPU has executed a "HALT" instruction.
        T80_RFSHn           <= '1';                                                 -- RFSHn signal not provided on NextZ80.
        T80_RDn             <= '0' when (T80_MREQn='0' or T80_IORQn='0') and T80_WRn='1' -- RDn signal not provided on NextZ80.
                               else '1';
        T80_BUSACKni        <= T80_BUSRQn;                                          -- BUSACKn signal indicates that the CPU address bus, data bus, and control signals have entered their HI-Z states, and that the external circuitry can now control these lines.
    end generate;

    -- Busack is granted during RESET, through the BUSRQ mechanism or during the period the clock has been disabled. This is necessary
    -- to allow the K64F to make changes which requires BUSACK active.
    --
    T80_BUSACKn <= '0' when (T80_BUSACKni = '0' and SW_CLKEN = '1' and T80_RESETn = '1') or (T80_BUSRQn = '0' and SW_CLKEN = '0')
                    else '1';

end architecture;
