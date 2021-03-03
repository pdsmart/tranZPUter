---------------------------------------------------------------------------------------------------------
--
-- Name:            VideoRAM_DP_3216.vhd
-- Created:         Jan 2021
-- Author(s):       Philip Smart
-- Description:     Video RAM for the Sharp MZ series Video Controller Core.
--                                                     
--                  This module provides a dual port inferred RAM definition for use as Video RAM
--                  in the Video Controller. Port A allows 8/16/32 bit access, Port B allows for 
--                  16 bit access. The size of the RAM is declared in the generic attribute
--                  'addrbits'.
--
-- Credits:         
-- Copyright:       (c) 2018-21 Philip Smart <philip.smart@net2net.org>
--
-- History:         Jan 2021  - Initial creation.
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
use     ieee.std_logic_unsigned.all;
use     ieee.numeric_std.all;
use     work.VideoController_pkg.all;
use     altera.altera_syn_attributes.all;
use     altera_mf.all;

entity VideoRAM_DP_3216 is
    generic
    (
        addrbits             : integer := 16                                  -- Max address bit, size in bytes.
    );
    port
    (
        clkA                 : in  std_logic;
        memAAddr             : in  std_logic_vector(addrbits-1 downto 0);
        memAWriteEnable      : in  std_logic;
        memAWriteByte        : in  std_logic;
        memAWriteHalfWord    : in  std_logic;
        memAWrite            : in  std_logic_vector(31 downto 0);
        memARead             : out std_logic_vector(31 downto 0);

        clkB                 : in  std_logic;
        memBAddr             : in  std_logic_vector(addrbits-2 downto 0);
        memBWriteEnable      : in  std_logic;
        memBWrite            : in  std_logic_vector(15 downto 0);
        memBRead             : out std_logic_vector(15 downto 0)
    );
end VideoRAM_DP_3216;

architecture arch of VideoRAM_DP_3216 is

    type ramArray is array(natural range 0 to (2**(addrbits-2))-1) of std_logic_vector(7 downto 0);

    shared variable RAM0     : ramArray :=
    (
        others => X"00"                                                      -- No/space character.
    );

    shared variable RAM1     : ramArray :=
    (
        others => X"71"                                                      -- Blue background white foreground.
    );

    shared variable RAM2     : ramArray :=
    (
        others => X"00"                                                      -- No/space character.
    );

    shared variable RAM3     : ramArray :=
    (
        others => X"71"                                                      -- Blue background white foreground.
    );

    signal RAM0_PORTA_DO     : std_logic_vector(7 downto 0);                 -- Buffer for byte in 32bit word to be written on Port A.
    signal RAM1_PORTA_DO     : std_logic_vector(7 downto 0);                 -- Buffer for byte in 32bit word to be written on Port A.
    signal RAM2_PORTA_DO     : std_logic_vector(7 downto 0);                 -- Buffer for byte in 32bit word to be written on Port A.
    signal RAM3_PORTA_DO     : std_logic_vector(7 downto 0);                 -- Buffer for byte in 32bit word to be written on Port A.
    signal RAM_PORTA_DI      : std_logic_vector(31 downto 0);                -- Buffer for 32bit word being read prior to assignment to external port.
    signal RAM_PORTB_DIL     : std_logic_vector(15 downto 0);                -- Buffer for 16bit word being read prior to assignment to external port.
    signal RAM_PORTB_DIH     : std_logic_vector(15 downto 0);                -- Buffer for 16bit word being read prior to assignment to external port.
    signal RAM0_PORTA_WREN   : std_logic;                                    -- Write Enable for this particular byte in 32 bit word on Port A.
    signal RAM1_PORTA_WREN   : std_logic;                                    -- Write Enable for this particular byte in 32 bit word on Port A.
    signal RAM2_PORTA_WREN   : std_logic;                                    -- Write Enable for this particular byte in 32 bit word on Port A.
    signal RAM3_PORTA_WREN   : std_logic;                                    -- Write Enable for this particular byte in 32 bit word on Port A.
    signal RAM0_PORTB_WREN   : std_logic;                                    -- Write Enable for this particular byte in 16 bit word on Port B, lowest addr = '0'.
    signal RAM1_PORTB_WREN   : std_logic;                                    -- Write Enable for this particular byte in 16 bit word on Port B, lowest addr = '0'.
    signal RAM2_PORTB_WREN   : std_logic;                                    -- Write Enable for this particular byte in 16 bit word on Port B, lowest addr = '1'.
    signal RAM3_PORTB_WREN   : std_logic;                                    -- Write Enable for this particular byte in 16 bit word on Port B, lowest addr = '1'.

begin

    -- Choose data to be written according to Byte/HWord select signals.
    RAM0_PORTA_DO   <= memAWrite(7 downto 0);
    RAM1_PORTA_DO   <= memAWrite(15 downto 8)  when (memAWriteByte = '0' and memAWriteHalfWord = '0') or memAWriteHalfWord = '1'
                       else
                       memAWrite(7 downto 0);
    RAM2_PORTA_DO   <= memAWrite(23 downto 16) when (memAWriteByte = '0' and memAWriteHalfWord = '0')
                       else
                       memAWrite(7 downto 0);
    RAM3_PORTA_DO   <= memAWrite(31 downto 24) when (memAWriteByte = '0' and memAWriteHalfWord = '0')
                       else
                       memAWrite(15 downto 8)  when memAWriteHalfWord = '1'
                       else
                       memAWrite(7 downto 0);

    -- Data output is according to Least significant bits. Normally, a 32bit CPU would set them to 0 so output full word when 0, it there not zero, then 
    -- process as a byte read and copy selected byte to lower 8 bits.
    memARead        <= RAM_PORTA_DI                           when memAAddr(1 downto 0) = "00"
                       else
                       X"000000" & RAM_PORTA_DI(15 downto 8)  when memAAddr(1 downto 0) = "01"
                       else
                       X"000000" & RAM_PORTA_DI(23 downto 16) when memAAddr(1 downto 0) = "10"
                       else
                       X"000000" & RAM_PORTA_DI(31 downto 24) when memAAddr(1 downto 0) = "11"
                       else (others => 'X');
    memBRead        <= RAM_PORTB_DIL                          when memBAddr(0) = '0'
                       else
                       RAM_PORTB_DIH;

    -- Write enable based on byte select, either write a single byte or a complete word.
    RAM0_PORTA_WREN <= '1'                                    when memAWriteEnable = '1' and ((memAWriteByte = '0' and memAWriteHalfWord = '0') or (memAWriteByte = '1' and memAAddr(1 downto 0) = "00") or (memAWriteHalfWord = '1' and memAAddr(1) = '0'))
                       else '0';
    RAM1_PORTA_WREN <= '1'                                    when memAWriteEnable = '1' and ((memAWriteByte = '0' and memAWriteHalfWord = '0') or (memAWriteByte = '1' and memAAddr(1 downto 0) = "01") or (memAWriteHalfWord = '1' and memAAddr(1) = '0'))
                       else '0';
    RAM2_PORTA_WREN <= '1'                                    when memAWriteEnable = '1' and ((memAWriteByte = '0' and memAWriteHalfWord = '0') or (memAWriteByte = '1' and memAAddr(1 downto 0) = "10") or (memAWriteHalfWord = '1' and memAAddr(1) = '1'))
                       else '0';
    RAM3_PORTA_WREN <= '1'                                    when memAWriteEnable = '1' and ((memAWriteByte = '0' and memAWriteHalfWord = '0') or (memAWriteByte = '1' and memAAddr(1 downto 0) = "11") or (memAWriteHalfWord = '1' and memAAddr(1) = '1'))
                       else '0';

    -- Port B is 16bit read and write so use the lowest address line to toggle write to a particular RAM set array.
    RAM0_PORTB_WREN <= '1'                                    when memBWriteEnable = '1' and memBAddr(0) = '0'
                       else '0';
    RAM1_PORTB_WREN <= '1'                                    when memBWriteEnable = '1' and memBAddr(0) = '0'
                       else '0';
    RAM2_PORTB_WREN <= '1'                                    when memBWriteEnable = '1' and memBAddr(0) = '1'
                       else '0';
    RAM3_PORTB_WREN <= '1'                                    when memBWriteEnable = '1' and memBAddr(0) = '1'
                       else '0';

    ---------------- PORT A - 32 bit --------------------

    -- RAM Byte 0 - Port A - bits 7 to 0
    process(clkA)
    begin
        if rising_edge(clkA) then
            if RAM0_PORTA_WREN = '1' then
                RAM0(to_integer(unsigned(memAAddr(addrbits-1 downto 2)))) := RAM0_PORTA_DO;
            end if;
            RAM_PORTA_DI(7 downto 0) <= RAM0(to_integer(unsigned(memAAddr(addrbits-1 downto 2))));
        end if;
    end process;

    -- RAM Byte 1 - Port A - bits 15 to 8
    process(clkA)
    begin
        if rising_edge(clkA) then
            if RAM1_PORTA_WREN = '1' then
                RAM1(to_integer(unsigned(memAAddr(addrbits-1 downto 2)))) := RAM1_PORTA_DO;
            end if;
            RAM_PORTA_DI(15 downto 8) <= RAM1(to_integer(unsigned(memAAddr(addrbits-1 downto 2))));
        end if;
    end process;

    -- RAM Byte 2 - Port A - bits 23 to 16 
    process(clkA)
    begin
        if rising_edge(clkA) then
            if RAM2_PORTA_WREN = '1' then
                RAM2(to_integer(unsigned(memAAddr(addrbits-1 downto 2)))) := RAM2_PORTA_DO;
            end if;
            RAM_PORTA_DI(23 downto 16) <= RAM2(to_integer(unsigned(memAAddr(addrbits-1 downto 2))));
        end if;
    end process;

    -- RAM Byte 3 - Port A - bits 31 to 24 
    process(clkA)
    begin
        if rising_edge(clkA) then
            if RAM3_PORTA_WREN = '1' then
                RAM3(to_integer(unsigned(memAAddr(addrbits-1 downto 2)))) := RAM3_PORTA_DO;
            end if;
            RAM_PORTA_DI(31 downto 24) <= RAM3(to_integer(unsigned(memAAddr(addrbits-1 downto 2))));
        end if;
    end process;

    ---------------- PORT B - 16 bit --------------------

    -- BRAM Byte 0 - Port B - Half-Word 0 - bits 7 downto 0
    process(clkB)
    begin
        if rising_edge(clkB) then
            if RAM0_PORTB_WREN = '1' then
                RAM0(to_integer(unsigned(memBAddr(addrbits-2 downto 1)))) := memBWrite(7 downto 0);
            end if;
            RAM_PORTB_DIL(7 downto 0) <= RAM0(to_integer(unsigned(memBAddr(addrbits-2 downto 1))));
        end if;
    end process;

    -- BRAM Byte 1 - Port B - Half-Word 0 - bits 15 downto 8
    process(clkB)
    begin
        if rising_edge(clkB) then
            if RAM1_PORTB_WREN = '1' then
                RAM1(to_integer(unsigned(memBAddr(addrbits-2 downto 1)))) := memBWrite(15 downto 8);
            end if;
            RAM_PORTB_DIL(15 downto 8) <= RAM1(to_integer(unsigned(memBAddr(addrbits-2 downto 1))));
        end if;
    end process;

    -- BRAM Byte 2 - Port B - Half-Word 1 - bits 7 downto 0
    process(clkB)
    begin
        if rising_edge(clkB) then
            if RAM2_PORTB_WREN = '1' then
                RAM2(to_integer(unsigned(memBAddr(addrbits-2 downto 1)))) := memBWrite(7 downto 0);
            end if;
            RAM_PORTB_DIH(7 downto 0)   <= RAM2(to_integer(unsigned(memBAddr(addrbits-2 downto 1))));
        end if;
    end process;

    -- BRAM Byte 3 - Port B - Half-Word 1 - bits 15 downto 8
    process(clkB)
    begin
        if rising_edge(clkB) then
            if RAM3_PORTB_WREN = '1' then
                RAM3(to_integer(unsigned(memBAddr(addrbits-2 downto 1)))) := memBWrite(15 downto 8);
            end if;
            RAM_PORTB_DIH(15 downto 8)  <= RAM3(to_integer(unsigned(memBAddr(addrbits-2 downto 1))));
        end if;
    end process;

end arch;
