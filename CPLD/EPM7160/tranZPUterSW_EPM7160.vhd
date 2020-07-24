---------------------------------------------------------------------------------------------------------
--
-- Name:            tranZPUterSW.vhd
-- Created:         June 2020
-- Author(s):       Philip Smart
-- Description:     tranZPUter SW v2.0 CPLD logic definition file.
--                  This module contains the definition of the logic used in v1.0-v1.1 of the tranZPUterSW
--                  project plus enhancements.
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
library ieee;
library pkgs;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.tranZPUterSW_pkg.all;

entity cpld160 is
    --generic (
    --);
    port (    
        -- Z80 Address and Data.
		Z80_HI_ADDR     : out   std_logic_vector(18 downto 16);
		Z80_ADDR        : in    std_logic_vector(15 downto 0);
		Z80_DATA        : inout std_logic_vector(7 downto 0);
        VADDR           : out   std_logic_vector(13 downto 11);

        -- Z80 Control signals.
		Z80_BUSRQn      : out   std_logic;
		Z80_BUSACKn     : in    std_logic;
		Z80_INTn        : in    std_logic;
		Z80_IORQn       : in    std_logic;
		Z80_MREQn       : in    std_logic;
		Z80_NMIn        : in    std_logic;
		Z80_RDn         : in    std_logic;
		Z80_WRn         : in    std_logic;
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

        -- Reserved.
		TBA             : in    std_logic_vector(3 downto 0)
    );
end entity;

architecture rtl of cpld160 is

    -- IO Decode signals.
    signal TZIO_CSn               :       std_logic := '0';
    signal MEM_CFGn               :       std_logic := '0';
    signal SCK_CTLCLKn            :       std_logic := '0';
    signal SCK_SYSCLKn            :       std_logic := '0';
    signal SCK_RDn                :       std_logic := '0';
    signal IODECODEni             :       std_logic;
    signal MEM_MODE_LATCH         :       std_logic_vector(7 downto 0);

    -- SR (LS279) state symbols.
    signal SYSCLK_D               :       std_logic;
    signal SYSCLK_Q               :       std_logic;
    signal CTLCLK_D               :       std_logic;
    signal CTLCLK_Q               :       std_logic;
    --
    signal TZ_BUSACKni            :       std_logic;
    signal DISABLE_BUSn           :       std_logic;
    signal ENABLE_BUSn            :       std_logic;
    signal notSRLatch1            :       std_logic;

    -- CPU Frequency select logic based on Flip Flops and gates.
    signal CTL_CLKSLCTi           :       std_logic;
    signal SCK_CTLSELn            :       std_logic;
    signal notSRLatch3            :       std_logic;
    signal Z80_CLKi               :       std_logic;

    -- Z80 Wait Insert generator when I/O ports in region > 0XE0 are accessed to give the K64F time to proces them.
    --
    signal REQ_WAIT               :       std_logic;
    signal notSRLatch4            :       std_logic;

    -- RAM select and write signals.
    signal RAM_OEni               :       std_logic;
    signal RAM_CSni               :       std_logic;
    signal RAM_WEni               :       std_logic;

    function to_std_logic(L: boolean) return std_logic is
    begin
        if L then
            return('1');
        else
            return('0');
        end if;
    end function to_std_logic;
begin

    --
    -- Instantiation
    --

    -- Memory mode latch. This latch stores the current memory mode (or Bank Paging Scheme) according to the running software.
    --
    process( Z80_RESETn, MEM_CFGn, Z80_DATA ) begin

        if(Z80_RESETn = '0') then
            MEM_MODE_LATCH <= (others => '0');

        elsif(MEM_CFGn = '0') then

            MEM_MODE_LATCH <= Z80_DATA;
        end if;
    end process;

    -- D type Flip Flops used for the CPU frequency switching circuit. The changeover of frequencies occurs on the high level, the output clock remaining
    -- high until the falling edge of the clock being switched into.
    process( SYSCLK, Z80_RESETn ) begin
        if Z80_RESETn = '0' then
            SYSCLK_Q <= '0';

        -- If the system clock goes active high, process the inputs and set the D-type output.
        elsif( rising_edge(SYSCLK) ) then
            if ((TZ_BUSACKni = '0' and  SCK_CTLSELn = '0') or CTLCLK_Q = '1') then
                SYSCLK_Q    <= '0';
            else
                SYSCLK_Q    <= '1';
            end if;
        end if;
    end process;
    process( CTLCLK, Z80_RESETn ) begin
        if Z80_RESETn = '0' then
            CTLCLK_Q <= '1';

        -- If the control clock goes active high, process the inputs and set the D-type output.
        elsif( rising_edge(CTLCLK) ) then
            if ((TZ_BUSACKni = '1' or  SCK_CTLSELn = '1') and SYSCLK_Q = '1') then
                CTLCLK_Q    <= '0';
            else
                CTLCLK_Q    <= '1';
            end if;
        end if;
    end process;

    -- Latch output so the K64F can determine current status.
    Z80_MEM     <= MEM_MODE_LATCH(4 downto 0);
    ENIOWAIT    <= MEM_MODE_LATCH(5);

    -- Clock frequency switching. Depending on the state of the flip flops either the system (mainboard) clocks is selected (default and selected when accessing
    -- the mainboard) and the programmable frequency generated by the K64F timers.
    Z80_CLKi    <= SYSCLK when SYSCLK_Q = '0'
                   else
                   CTLCLK when CTLCLK_Q = '0'
                   else SYSCLK;
    CTL_CLKSLCTi<= '1' when (TZ_BUSACKni = '0' and SCK_CTLSELn = '0')
                   else '0';
    CTL_CLKSLCT <= CTL_CLKSLCTi;
    Z80_CLK     <= Z80_CLKi;

    -- Mainboard BUS Request S-R latch 1.
    TZ_BUSACKni <= '1' when DISABLE_BUSn = '0' or notSRLatch1 = '0'
                   else '0';
    notSRLatch1 <= '1' when (Z80_RESETn = '0' or ENABLE_BUSn = '0') or TZ_BUSACKni = '0'
                   else '0';

    -- Mainboard Clock Select S-R latch 3.
    SCK_CTLSELn <= '1' when SCK_CTLCLKn = '0' or notSRLatch3 = '0'
                   else '0';
    notSRLatch3 <= '1' when (Z80_RESETn = '0' or SCK_SYSCLKn = '0') or SCK_CTLSELn = '0'
                   else '0';

    -- Mainboard WAIT State Generator S-R latch 4.
    REQ_WAIT    <= '1' when (Z80_ADDR(7 downto 5) = "111" and Z80_M1n = '1' and CTL_BUSRQn = '1' and MEM_MODE_LATCH(5) = '1' and Z80_IORQn = '0') or notSRLatch4 = '0'
                   else '0';
    notSRLatch4 <= '1' when (Z80_RESETn = '0' or CTL_BUSRQn = '0') or REQ_WAIT = '0'
                   else '0';
    Z80_WAITn   <= '0' when SYS_WAITn = '0' or REQ_WAIT = '1' or CTL_WAITn = '0'
                   else '1';

    -- Z80 signals passed to the mainboard, if the K64F has control of the bus then the Z80 signals are disabled as they are not tri-stated during a BUSRQ state.
    CTL_M1n     <= Z80_M1n when Z80_BUSACKn = '0'
                   else 'Z';
    CTL_RFSHn   <= Z80_RFSHn when Z80_BUSACKn = '0'
                   else 'Z';
    CTL_HALTn   <= Z80_HALTn when Z80_BUSACKn = '0'
                   else 'Z';

    -- Bus control logic.
    TZ_BUSACKn  <= TZ_BUSACKni;
    SYS_BUSACKn <= '0' when TZ_BUSACKni = '0' or (Z80_BUSACKn = '0' and CTL_BUSACKn = '0')
                   else '1';
    Z80_BUSRQn  <= '0' when SYS_BUSRQn = '0' or CTL_BUSRQn = '0'
                   else '1';
        
    --
    -- Data Bus Multiplexing, plex the output devices onto the Z80 data bus.
    --
    Z80_DATA    <= CTL_CLKSLCTi & MEM_MODE_LATCH(6 downto 0) when SCK_RDn = '0'
                   else 
                   (others=>'Z');

    -- The tranZPUter SW board adds upgrades for the Z80 processor and host. These upgrades are controlled through an IO port which 
    -- in v1.0 - v1.1 was either at 0x2-=0x2f, 0x60-0x6f, 0xA0-0xAf, 0xF0-0xFF, the default being 0x60. This logic mimcs the 74HCT138 and
    -- FlashRAM decoder which produces the Io port select signals.
    --
    TZIO_CSn    <= '0' when Z80_IORQn = '0' and Z80_M1n = '1' and Z80_ADDR(7 downto 4) = "0110" and IODECODEni = '0'
                   else '1';
    MEM_CFGn    <= '0' when TZIO_CSn = '0' and Z80_ADDR(3 downto 1) = "000"
                   else '1';
    SCK_CTLCLKn <= '0' when TZIO_CSn = '0' and Z80_ADDR(3 downto 1) = "001"
                   else '1';
    SCK_SYSCLKn <= '0' when TZIO_CSn = '0' and Z80_ADDR(3 downto 1) = "010"
                   else '1';
    SCK_RDn     <= '0' when TZIO_CSn = '0' and Z80_ADDR(3 downto 1) = "011"
                   else '1';
    SVCREQn     <= '0' when TZIO_CSn = '0' and Z80_ADDR(3 downto 1) = "100"
                   else '1';
    SYSREQn     <= '0' when TZIO_CSn = '0' and Z80_ADDR(3 downto 1) = "101"
                   else '1';


    -- Memory decoding, taken directly from the definitions coded into the flashcfg tool in v1.1. The CPLD adds greater flexibility and mapping down to the byte level where needed.
    --
    -- Memory Modes:     0 - Default, normal Sharp MZ80A operating mode, all memory and IO (except tranZPUter control IO block) are on the mainboard
    --                   1 - As 0 except User ROM is mapped to tranZPUter RAM.
    --                   2 - TZFS, Monitor ROM 0000-0FFF, Main DRAM 0x1000-0xD000, User/Floppy ROM E800-FFFF are in tranZPUter memory. Two small holes at F3FE and F7FE exist for the Floppy disk controller (which have to be 64
    --                       bytes from F3C0 and F7C0 due to the granularity of the address lines into the Flash RAM), these locations  need to be on the mainboard.
    --                       NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
    --                   3 - TZFS, Monitor ROM 0000-0FFF, Main RAM area 0x1000-0xD000, User ROM 0xE800-EFFF are in tranZPUter memory block 0, Floppy ROM F000-FFFF are in tranZPUter memory block 1.
    --                       NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
    --                   4 - TZFS, Monitor ROM 0000-0FFF, Main RAM area 0x1000-0xD000, User ROM 0xE800-EFFF are in tranZPUter memory block 0, Floppy ROM F000-FFFF are in tranZPUter memory block 2.
    --                       NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
    --                   5 - TZFS, Monitor ROM 0000-0FFF, Main RAM area 0x1000-0xD000, User ROM 0xE800-EFFF are in tranZPUter memory block 0, Floppy ROM F000-FFFF are in tranZPUter memory block 3.
    --                       NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
    --                   6 - CPM, all memory on the tranZPUter board, 64K block 4 selected.
    --                       Special case for F3C0:F3FF & F7C0:F7FF (floppy disk paging vectors) which resides on the mainboard.
    --                   7 - CPM, F000-FFFF are on the tranZPUter board in block 4, 0040-CFFF and E800-EFFF are in block 5 selected, mainboard for D000-DFFF (video), E000-E800 (Memory control) selected.
    --                       Special case for 0000:003F (interrupt vectors) which resides in block 4, F3C0:F3FF & F7C0:F7FF (floppy disk paging vectors) which resides on the mainboard.
    --                  10 - MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 6, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is on the mainboard.
    --                  11 - MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 0, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is on the tranZPUter in block 6.
    --                  12 - MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 6, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is on the tranZPUter in block 6.
    --                  13 - MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 0, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is inaccessible.
    --                  14 - MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 6, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is inaccessible.
    --                  24 - All memory and IO are on the tranZPUter board, 64K block 0 selected.
    --                  25 - All memory and IO are on the tranZPUter board, 64K block 1 selected.
    --                  26 - All memory and IO are on the tranZPUter board, 64K block 2 selected.
    --                  27 - All memory and IO are on the tranZPUter board, 64K block 3 selected.
    --                  28 - All memory and IO are on the tranZPUter board, 64K block 4 selected.
    --                  29 - All memory and IO are on the tranZPUter board, 64K block 5 selected.
    --                  30 - All memory and IO are on the tranZPUter board, 64K block 6 selected.
    --                  31 - All memory and IO are on the tranZPUter board, 64K block 7 selected.
    process(Z80_ADDR, Z80_WRn, Z80_RDn, Z80_IORQn, Z80_MREQn, Z80_M1n, MEM_MODE_LATCH) begin

        -- Set the default state of the signals, updated according to the logic below.
        if(Z80_WRn = '0' and (Z80_MREQn = '0' or Z80_IORQn = '0') and Z80_M1n = '1') then
            RAM_CSni    <= '0';
            RAM_WEni    <= '0';
        else
            RAM_CSni    <= '1';
            RAM_WEni    <= '1';
        end if;

        if(Z80_RDn = '0' and (Z80_MREQn = '0' or Z80_IORQn = '0') and Z80_M1n = '1') then
            RAM_CSni    <= '0';
            RAM_OEni    <= '0';
        else
            RAM_CSni    <= '1';
            RAM_OEni    <= '1';
        end if;

        ENABLE_BUSn     <= '1';
        DISABLE_BUSn    <= '1';
        IODECODEni      <= '1';

        case MEM_MODE_LATCH(4 downto 0) is

            -- Set 0 - default, no tranZPUter RAM access so just pulse the ENABLE_BUS signal for safety to ensure the CPU has continuous access to the
            -- mainboard resources, especially for Refresh of DRAM.
            when "00000" => 
                ENABLE_BUSn     <= '0';
                DISABLE_BUSn    <= '0';

            -- Whenever running in RAM ensure the mainboard is disabled to prevent decoder propagation delay glitches.
            when "00001" => 
                if( unsigned(Z80_ADDR(15 downto 0)) >= X"E800" and unsigned(Z80_ADDR(15 downto 0)) < X"F000") then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';

                    -- First byte in the User ROM socket is read only as this is expected by the Monitor ROM firmware in determining if it should execute code at this location.
                    if(Z80_WRn = '0' and unsigned(Z80_ADDR(15 downto 0)) >= X"E800") then
                        RAM_CSni    <= '1';
                        RAM_WEni    <= '1';
                    end if;
                else
                    DISABLE_BUSn    <= '1';
                    ENABLE_BUSn     <= '0';
                    RAM_CSni        <= '1';
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 2 - Monitor ROM 0000-0FFF, Main DRAM 0x1000-0xD000, User/Floppy ROM E800-FFFF are in tranZPUter memory. Two small holes at F3FE and F7FE exist for the Floppy disk controller (which have to be 64
            -- bytes from F3C0 and F7C0 due to the granularity of the address lines into the Flash RAM), these locations  need to be on the mainboard.
            -- NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
            when "00010" => 
                if( (unsigned(Z80_ADDR(15 downto 0)) >= X"0000" and unsigned(Z80_ADDR(15 downto 0)) < X"D000") or (unsigned(Z80_ADDR(15 downto 0)) >= X"E800" and unsigned(Z80_ADDR(15 downto 0)) < X"F3C0") or (unsigned(Z80_ADDR(15 downto 0)) >= X"F400" and unsigned(Z80_ADDR(15 downto 0)) < X"F7C0") or (unsigned(Z80_ADDR(15 downto 0)) >= X"F800" and unsigned(Z80_ADDR(15 downto 0)) <= X"FFFF")) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                else
                    DISABLE_BUSn    <= '1';
                    ENABLE_BUSn     <= '0';
                    RAM_CSni        <= '1';
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 3 - Monitor ROM 0000-0FFF, Main RAM area 0x1000-0xD000, User ROM 0xE800-EFFF are in tranZPUter memory block 0, Floppy ROM F000-FFFF are in tranZPUter memory block 1.
            -- NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
            when "00011" => 
                if( (unsigned(Z80_ADDR(15 downto 0)) >= X"0000" and unsigned(Z80_ADDR(15 downto 0)) < X"D000") or (unsigned(Z80_ADDR(15 downto 0)) >= X"E800" and unsigned(Z80_ADDR(15 downto 0)) < X"F000") ) then 
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                elsif( (unsigned(Z80_ADDR(15 downto 0)) >= X"F000" and unsigned(Z80_ADDR(15 downto 0)) < X"F3C0") or (unsigned(Z80_ADDR(15 downto 0)) >= X"F400" and unsigned(Z80_ADDR(15 downto 0)) < X"F7C0") or (unsigned(Z80_ADDR(15 downto 0)) >= X"F000" and unsigned(Z80_ADDR(15 downto 0)) <= X"FFFF")) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 16) <= "001";
                else
                    DISABLE_BUSn    <= '1';
                    ENABLE_BUSn     <= '0';
                    RAM_CSni        <= '1';
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 4 - Monitor ROM 0000-0FFF, Main RAM area 0x1000-0xD000, User ROM 0xE800-EFFF are in tranZPUter memory block 0, Floppy ROM F000-FFFF are in tranZPUter memory block 2.
            -- NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
            when "00100" => 
                if( (unsigned(Z80_ADDR(15 downto 0)) >= X"0000" and unsigned(Z80_ADDR(15 downto 0)) < X"D000") or (unsigned(Z80_ADDR(15 downto 0)) >= X"E800" and unsigned(Z80_ADDR(15 downto 0)) < X"F000")) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                elsif( unsigned(Z80_ADDR(15 downto 0)) >= X"F000" and unsigned(Z80_ADDR(15 downto 0)) <= X"FFFF" ) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 16) <= "010";
                else
                    DISABLE_BUSn    <= '1';
                    ENABLE_BUSn     <= '0';
                    RAM_CSni        <= '1';
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 5 - Monitor ROM 0000-0FFF, Main RAM area 0x1000-0xD000, User ROM 0xE800-EFFF are in tranZPUter memory block 0, Floppy ROM F000-FFFF are in tranZPUter memory block 3.
            -- NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
            when "00101" => 
                if( (unsigned(Z80_ADDR(15 downto 0)) >= X"0000" and unsigned(Z80_ADDR(15 downto 0)) < X"D000") or (unsigned(Z80_ADDR(15 downto 0)) >= X"E800" and unsigned(Z80_ADDR(15 downto 0)) < X"F000")) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                elsif( unsigned(Z80_ADDR(15 downto 0)) >= X"F000" and unsigned(Z80_ADDR(15 downto 0)) <= X"FFFF" ) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 16) <= "011";
                else
                    DISABLE_BUSn    <= '1';
                    ENABLE_BUSn     <= '0';
                    RAM_CSni        <= '1';
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 6 - CPM, all memory on the tranZPUter board, 64K block 4 selected.
            -- Special case for F3C0:F3FF & F7C0:F7FF (floppy disk paging vectors) which resides on the mainboard.
            when "00110" => 
                if( (unsigned(Z80_ADDR(15 downto 0)) >= X"D000" and unsigned(Z80_ADDR(15 downto 0)) < X"F3C0") or (unsigned(Z80_ADDR(15 downto 0)) >= X"F400" and unsigned(Z80_ADDR(15 downto 0)) < X"F7C0") or (unsigned(Z80_ADDR(15 downto 0)) >= X"F800" and unsigned(Z80_ADDR(15 downto 0)) <= X"FFFF")) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 16) <= "001";
                elsif( (unsigned(Z80_ADDR(15 downto 0)) >= X"0100" and unsigned(Z80_ADDR(15 downto 0)) < X"D000") or (unsigned(Z80_ADDR(15 downto 0)) >= X"E800" and unsigned(Z80_ADDR(15 downto 0)) < X"F000")) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 16) <= "101";
                else
                    DISABLE_BUSn    <= '1';
                    ENABLE_BUSn     <= '0';
                    RAM_CSni        <= '1';
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 7 - CPM, F000-FFFF are on the tranZPUter board in block 4, 0040-CFFF and E800-EFFF are in block 5 selected, mainboard for D000-DFFF (video), E000-E800 (Memory control) selected.
            -- Special case for 0000:00FF (interrupt vectors) which resides in block 4 and CPM vectors, F3C0:F3FF & F7C0:F7FF (floppy disk paging vectors) which resides on the mainboard.
            when "00111" => 
                if( (unsigned(Z80_ADDR(15 downto 0)) >= X"0000" and unsigned(Z80_ADDR(15 downto 0)) < X"0100") or (unsigned(Z80_ADDR(15 downto 0)) >= X"F000" and unsigned(Z80_ADDR(15 downto 0)) < X"F3C0") or (unsigned(Z80_ADDR(15 downto 0)) >= X"F400" and unsigned(Z80_ADDR(15 downto 0)) < X"F7C0") or (unsigned(Z80_ADDR(15 downto 0)) >= X"F800" and unsigned(Z80_ADDR(15 downto 0)) <= X"FFFF")) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 16) <= "100";
                elsif( (unsigned(Z80_ADDR(15 downto 0)) >= X"0100" and unsigned(Z80_ADDR(15 downto 0)) < X"D000") or (unsigned(Z80_ADDR(15 downto 0)) >= X"E800" and unsigned(Z80_ADDR(15 downto 0)) < X"F000")) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 16) <= "101";
                else
                    DISABLE_BUSn    <= '1';
                    ENABLE_BUSn     <= '0';
                    RAM_CSni        <= '1';
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 10 - MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 6, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is on the mainboard.
            when "01010" =>
                if( (unsigned(Z80_ADDR(15 downto 0)) >= X"0000" and unsigned(Z80_ADDR(15 downto 0)) < X"1000") ) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 16) <= "110";
                elsif( unsigned(Z80_ADDR(15 downto 0)) >= X"1000" and unsigned(Z80_ADDR(15 downto 0)) < X"D000" ) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 16) <= "000";
                else
                    DISABLE_BUSn    <= '1';
                    ENABLE_BUSn     <= '0';
                    RAM_CSni        <= '1';
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 11 - MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 0, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is on the tranZPUter in block 6.
            when "01011" =>
                if( (unsigned(Z80_ADDR(15 downto 0)) >= X"0000" and unsigned(Z80_ADDR(15 downto 0)) < X"1000") ) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 16) <= "000";
                elsif( unsigned(Z80_ADDR(15 downto 0)) >= X"1000" and unsigned(Z80_ADDR(15 downto 0)) < X"D000" ) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 16) <= "000";
                elsif( (unsigned(Z80_ADDR(15 downto 0)) >= X"D000" and unsigned(Z80_ADDR(15 downto 0)) <= X"FFFF")) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 16) <= "110";
                else
                    RAM_CSni        <= '1';
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 12 - MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 6, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is on the tranZPUter in block 6.
            when "01100" =>
                if( (unsigned(Z80_ADDR(15 downto 0)) >= X"0000" and unsigned(Z80_ADDR(15 downto 0)) < X"1000") ) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 16) <= "110";
                elsif( unsigned(Z80_ADDR(15 downto 0)) >= X"1000" and unsigned(Z80_ADDR(15 downto 0)) < X"D000" ) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 16) <= "000";
                elsif( (unsigned(Z80_ADDR(15 downto 0)) >= X"D000" and unsigned(Z80_ADDR(15 downto 0)) <= X"FFFF")) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 16) <= "110";
                else
                    RAM_CSni        <= '1';
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 13 - MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 0, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is inaccessible.
            when "01101" =>
                if( (unsigned(Z80_ADDR(15 downto 0)) >= X"0000" and unsigned(Z80_ADDR(15 downto 0)) < X"1000") ) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 16) <= "000";
                elsif( unsigned(Z80_ADDR(15 downto 0)) >= X"1000" and unsigned(Z80_ADDR(15 downto 0)) < X"D000" ) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 16) <= "000";
                elsif( (unsigned(Z80_ADDR(15 downto 0)) >= X"D000" and unsigned(Z80_ADDR(15 downto 0)) <= X"FFFF")) then
                    DISABLE_BUSn    <= '1';
                    ENABLE_BUSn     <= '1';
                    RAM_CSni        <= '1';
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 14 - MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 6, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is inaccessible.
            when "01110" =>
                if( (unsigned(Z80_ADDR(15 downto 0)) >= X"0000" and unsigned(Z80_ADDR(15 downto 0)) < X"1000") ) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 16) <= "110";
                elsif( unsigned(Z80_ADDR(15 downto 0)) >= X"1000" and unsigned(Z80_ADDR(15 downto 0)) < X"D000" ) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 16) <= "000";
                elsif( (unsigned(Z80_ADDR(15 downto 0)) >= X"D000" and unsigned(Z80_ADDR(15 downto 0)) <= X"FFFF")) then
                    DISABLE_BUSn    <= '1';
                    ENABLE_BUSn     <= '1';
                    RAM_CSni        <= '1';
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 24 - All memory and IO are on the tranZPUter board, 64K block 0 selected.
            when "11000" =>
                DISABLE_BUSn    <= '0';
                ENABLE_BUSn     <= '1';
                Z80_HI_ADDR(18 downto 16) <= "000";

            -- Set 25 - All memory and IO are on the tranZPUter board, 64K block 1 selected.
            when "11001" =>
                DISABLE_BUSn    <= '0';
                ENABLE_BUSn     <= '1';
                Z80_HI_ADDR(18 downto 16) <= "001";

            -- Set 26 - All memory and IO are on the tranZPUter board, 64K block 2 selected.
            when "11010" =>
                DISABLE_BUSn    <= '0';
                ENABLE_BUSn     <= '1';
                Z80_HI_ADDR(18 downto 16) <= "010";

            -- Set 27 - All memory and IO are on the tranZPUter board, 64K block 3 selected.
            when "11011" =>
                DISABLE_BUSn<= '0';
                ENABLE_BUSn <= '1';
                Z80_HI_ADDR(18 downto 16) <= "011";

            -- Set 28 - All memory and IO are on the tranZPUter board, 64K block 4 selected.
            when "11100" =>
                DISABLE_BUSn    <= '0';
                ENABLE_BUSn     <= '1';
                Z80_HI_ADDR(18 downto 16) <= "100";

            -- Set 29 - All memory and IO are on the tranZPUter board, 64K block 5 selected.                
            when "11101" =>
                DISABLE_BUSn    <= '0';
                ENABLE_BUSn     <= '1';
                Z80_HI_ADDR(18 downto 16) <= "101";

            -- Set 30 - All memory and IO are on the tranZPUter board, 64K block 6 selected.
            when "11110" =>
                DISABLE_BUSn    <= '0';
                ENABLE_BUSn     <= '1';
                Z80_HI_ADDR(18 downto 16) <= "110";

            -- Set 31 - All memory and IO are on the tranZPUter board, 64K block 7 selected.
            when "11111" =>
                DISABLE_BUSn    <= '0';
                ENABLE_BUSn     <= '1';
                Z80_HI_ADDR(18 downto 16) <= "111";

            when others =>
        end case;

        -- If the non-standard case of Z80 RD and Z80 WR being set low occurs, enable the ENABLE_BUS signal as the K64F is requesting access to the MZ80A motherboard.
        if(Z80_RDn = '0' and Z80_WRn = '0' and Z80_MREQn = '1' and Z80_IORQn = '1') then
            DISABLE_BUSn        <= '0';
            ENABLE_BUSn         <= '1';
            RAM_OEni            <= '1';
            RAM_CSni            <= '1';
            RAM_WEni            <= '1';
            IODECODEni          <= '1';
        end if;

        -- Defaults for IO operations, can be overriden for a specific set but should be present in all other sets.
        if(Z80_WRn = '0' or Z80_RDn = '0') then

            -- If the address is within configured IO control register range, activate the IODECODE signal.
            if(unsigned(Z80_ADDR(7 downto 0)) >= X"60" and unsigned(Z80_ADDR(7 downto 0)) < X"79") then

                if(unsigned(MEM_MODE_LATCH(4 downto 0)) >= 10 and unsigned(MEM_MODE_LATCH(4 downto 0)) < 15) then
                    DISABLE_BUSn<= '1';
                    ENABLE_BUSn <= '1';
                    IODECODEni  <= '0';
                else
                    DISABLE_BUSn<= '0';
                    ENABLE_BUSn <= '1';
                    IODECODEni  <= '0';
                end if;
            else
                DISABLE_BUSn    <= '1';
                ENABLE_BUSn     <= '0';
                IODECODEni      <= '1';
            end if;
        end if;
    end process;

    -- Assign the RAM select signals to their external pins.
    RAM_CSn   <= RAM_CSni;
    RAM_OEn   <= RAM_OEni;
    RAM_WEn   <= RAM_WEni;

    -- For the video card, additional address lines are needed to address the banked video memory. The CPLD is acting as a buffer for these lines.
    VADDR     <= Z80_ADDR(13 downto 11);
    VMEM_CSn  <= '0' when unsigned(Z80_ADDR(15 downto 0)) >= X"E000" and unsigned(Z80_ADDR(15 downto 0)) <= X"FFFF" and Z80_MREQn = '0' and Z80_RFSHn = '1'
                 else '1';

end architecture;
