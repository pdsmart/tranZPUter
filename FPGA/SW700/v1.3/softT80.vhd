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
        SW_ENABLE                 : in    std_logic;                                     -- Software controlled CPU enable.
        CPU_CHANGED               : in    std_logic;                                     -- Flag to indicate when software selects a different CPU.
      
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

    -- T80
    --
    signal T80_RESETn             :       std_logic; 
    signal T80_CLK                :       std_logic; 
    signal T80_CLKEN              :       std_logic; 
    signal T80_BUSACKni           :       std_logic; 

    component T80a
        generic (
              Mode                :       integer := 0;                                  -- 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
              IOWait              :       integer := 1                                   -- 0 => Single cycle I/O, 1 => Std I/O cycle
        );
        Port (
              RESET_n             : in    std_logic;
              CLK_n               : in    std_logic;                                     -- NB. Clock is high active.
              CLK_EN              : in    std_logic;
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
              DIN                 : in    std_logic_vector(7 downto 0);
              DOUT                : out   std_logic_vector(7 downto 0)
        );
    end component;    

begin
    -- Process to clean up the Z80 clock originating from the CPLD to drive the T80.
    --
    process(SYS_RESETn, SYS_CLK, Z80_CLK)
    begin
        if SYS_RESETn = '0' then
            T80_CLK              <= '0';
        elsif rising_edge(SYS_CLK) then
            if Z80_CLK = '0' then
                T80_CLK          <= '0';
            elsif Z80_CLK = '1' then
                T80_CLK          <= '1';
            end if;
        end if;
    end process;

    -- Process to reliably reset the T80. The T80 is disabled whilst in hard CPU mode, once switched to soft CPU, the reset is 
    -- activated and held low whilst the CPLD changes its state, the clock is then enabled so that the synchronous reset is latched
    -- and then the reset is deactivated.
    process(SYS_RESETn, T80_CLK)
        variable T80_RESET_COUNTER: unsigned(3 downto 0) := (others => '1');
    begin
        if SYS_RESETn = '0' then
            T80_RESET_COUNTER     := (others => '1');
            T80_RESETn            <= '0';
            T80_CLKEN             <= '0';

        elsif rising_edge(T80_CLK) then
            if CPU_CHANGED = '1'  or SW_RESET = '1' then
                T80_RESET_COUNTER := (others => '1');
                T80_RESETn        <= '0';
                T80_CLKEN         <= '0';
            end if;

            if T80_RESET_COUNTER = 5 and SW_ENABLE = '1' then
                T80_CLKEN         <= '1';

            elsif T80_RESET_COUNTER = 0 then
                T80_RESETn        <= '1';
            end if;

            if T80_BUSRQn = '1' and T80_RESET_COUNTER /= 0 then
                T80_RESET_COUNTER := T80_RESET_COUNTER - 1;
            end if;
        end if;
    end process;


    ------------------------------------------------------------------------------------
    -- T80 CPU
    ------------------------------------------------------------------------------------    

    CPU0 : T80a
    generic map (
        Mode                     => 0,                                                   -- 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
        IOWait                   => 1                                                    -- 
    )
    port map (
        RESET_n                  => T80_RESETn,                                          -- Reset signal.
        CLK_n                    => T80_CLK,                                             -- T80a clock, sane as the hardware clock but synchronised to the system clock.
        CLK_EN                   => T80_CLKEN,                                           -- Only clock the T80 when enabled.
        WAIT_n                   => T80_WAITn,                                           -- WAITn signal into the CPU to prolong a memory cycle.
        INT_n                    => T80_INTn,                                            -- INTn signal for maskable interrupts.
        NMI_n                    => T80_NMIn,                                            -- NMIn non maskable interrupt input.
        BUSRQ_n                  => T80_BUSRQn,                                          -- BUSRQn signal to request CPU go into tristate and relinquish bus.
        M1_n                     => T80_M1n,                                             -- M1n Machine Cycle 1 signal. M1 and MREQ active = opcode fetch, M1 and IORQ active = interrupt, vector can be read from D0-D7.
        MREQ_n                   => T80_MREQn,                                           -- MREQn signal indicates that the address bus holds a valid address for reading or writing memory.
        IORQ_n                   => T80_IORQn,                                           -- IORQn signal indicates that the address bus (A0-A7) holds a valid address for reading or writing and I/O device.
        RD_n                     => T80_RDn,                                             -- RDn signal indicates that data is ready to be read from a memory or I/O device to the CPU.
        WR_n                     => T80_WRn,                                             -- WRn signal indicates that data is going to be written from the CPU data bus to a memory or I/O device.
        RFSH_n                   => T80_RFSHn,                                           -- RFSHn signal to indicate dynamic memory refresh can take place.
        HALT_n                   => T80_HALTn,                                           -- HALTn signal indicates that the CPU has executed a "HALT" instruction.
        BUSAK_n                  => T80_BUSACKni,                                        -- BUSACKn signal indicates that the CPU address bus, data bus, and control signals have entered their HI-Z states, and that the external circuitry can now control these lines.
        A                        => T80_ADDR,                                            -- 16 bit address lines.
        DIN                      => T80_DATA_IN,                                         -- 8 bit data bus in.
        DOUT                     => T80_DATA_OUT                                         -- 8 bit data bus out.
    );

    -- Combine RESET into BUSACK signal.
    T80_BUSACKn                  <= '0'                                             when T80_RESETn = '0'
                                    else
                                    T80_BUSACKni                                    when T80_RESETn = '1'
                                    else '1';

end architecture;
