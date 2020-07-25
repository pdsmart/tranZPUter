---------------------------------------------------------------------------------------------------------
--
-- Name:            tranZPUterSW.vhd
-- Created:         June 2020
-- Author(s):       Philip Smart
-- Description:     tranZPUter SW v2.1 CPLD logic definition file.
--                  This module contains the definition of the logic used in v1.0-v1.1 of the tranZPUterSW
--                  project plus enhancements.
--
-- Credits:         
-- Copyright:       (c) 2018-20 Philip Smart <philip.smart@net2net.org>
--
-- History:         June 2020 - Initial creation.
--                  July 2020 - Updated and fixed logic, removed the MZ80B compatibility logic as there
--                              are not enough resources in the CPLD to fully implement.
--                  July 2020 - Changed the keyboard mapping logic to be more compatible. A scan is made
--                              periodically of the underlying keyboard and the key data is stored in 
--                              the key matrix. When the running software accesses the keyboard it reads
--                              from the key matrix and not the PPI. This allows for better compatibility
--                              and a functioning SHIFT+BREAK key. The MZ80A keyboard layout is mapped
--                              as though the keyboard was a real MZ700 keyboard, ie. BREAK key is CLR/HOME
--                              and INST/DEL is CTRL etc. The numeric keypad on the MZ80A is mapped to the
--                              cursor key layout with 7 and 9 acting as INST/DEL. The function keys are
--                              mapped to 1, 0, 00, . and 3 on the numeric keypad.
--                              
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

entity cpld512 is
    --generic (
    --);
    port (    
        -- Z80 Address and Data.
        Z80_HI_ADDR     : out   std_logic_vector(18 downto 15);
        Z80_ADDR        : inout std_logic_vector(15 downto 0);
        Z80_DATA        : inout std_logic_vector( 7 downto 0);
        VADDR           : out   std_logic_vector(13 downto 11);

        -- Z80 Control signals.
        Z80_BUSRQn      : out   std_logic;
        Z80_BUSACKn     : in    std_logic;
        Z80_INTn        : inout std_logic;
        Z80_IORQn       : in    std_logic;
        Z80_MREQn       : inout std_logic;
        Z80_NMIn        : inout std_logic;
        Z80_RDn         : inout std_logic;
        Z80_WRn         : inout std_logic;
        Z80_RESETn      : in    std_logic;                       -- NB. The CPLD inverts the GCLRn pin, so active negative on the mainboard, active positive inside the CPLD.
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

        -- Mode signals.
        CFG_MZ80A       : in    std_logic;
        CFG_MZ700       : in    std_logic;

        -- Reserved.
        TBA             : in    std_logic_vector(8 downto 0)
    );
end entity;

architecture rtl of cpld512 is

    -- Definition of a keyboard mapping matrix as an array of registers. The host keyboard is
    -- read into the matrix and the output is mapped according to the target.
    --
    type KeyMatrixType is array(natural range 0 to 9) of std_logic_vector(7 downto 0);

    -- Keyboard mapping signals
    signal KEY_MATRIX             :       KeyMatrixType;
    signal KEYMAP_DATA            :       std_logic_vector(7 downto 0);
    signal KEY_STROBE             :       std_logic_vector(3 downto 0);
    signal KEY_SUBSTITUTE         :       std_logic;
    signal MB_KEY_STROBE          :       std_logic_vector(3 downto 0);
    signal MB_WRITE_STROBE        :       std_logic;
    signal MB_READ_KEYS           :       std_logic;

    -- CPLD configuration signals.
    signal MODE_MZ80A             :       std_logic;
    signal MODE_MZ700             :       std_logic;
    signal CPLD_CFG_DATA          :       std_logic_vector(7 downto 0);

    -- IO Decode signals.
    signal TZIO_CSn               :       std_logic := '0';
    signal MEM_CFGn               :       std_logic := '0';
    signal SCK_CTLCLKn            :       std_logic := '0';
    signal SCK_SYSCLKn            :       std_logic := '0';
    signal SCK_RDn                :       std_logic := '0';
    signal CPLD_CFGn              :       std_logic := '0';
    signal CPLD_INFOn             :       std_logic := '0';
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

    -- CPU Frequency select logic based on Flip Flops and gates.
    signal CTL_CLKSLCTi           :       std_logic;
    signal SCK_CTLSELn            :       std_logic;
    signal Z80_CLKi               :       std_logic;

    -- Z80 Wait Insert generator when I/O ports in region > 0XE0 are accessed to give the K64F time to proces them.
    --
    --signal REQ_WAIT             :       std_logic;

    -- RAM select and write signals.
    signal RAM_OEni               :       std_logic;
    signal RAM_CSni               :       std_logic;
    signal RAM_WEni               :       std_logic;

    -- Mainboard writeback multiplexing signals.
    signal MB_MREQn               :       std_logic;
    signal MB_BUSRQn              :       std_logic;
    signal MB_ADDR                :       std_logic_vector(15 downto 0);
    signal MB_DATA                :       std_logic_vector(7 downto 0);
    signal MB_DELAY               :       unsigned(15 downto 0);
    signal MB_STATE               :       integer range 0 to 7;

    function to_std_logic(L: boolean) return std_logic is
    begin
        if L then
            return('1');
        else
            return('0');
        end if;
    end function to_std_logic;
begin

    -- CPLD Configuration register.
    --
    -- The mode can be changed either by a Z80 transaction write into the register or setting of the external signals. The Z80 write is typically used
    -- by host software such as RFS, the external signals by the K64F I/O processor.
    --
    process( SYSCLK, Z80_RESETn, CPLD_CFGn, CPLD_INFOn, Z80_ADDR, Z80_DATA )
    begin

        if(Z80_RESETn = '0') then
            MODE_MZ80A            <= '1';
            MODE_MZ700            <= '0';

        elsif(SYSCLK'event and SYSCLK = '1') then
            --- Potential, if RFS available, reset to correct mode.
            -- Write to register.
            if(CPLD_CFGn = '0' and Z80_WRn = '0') then

                -- Set mode, default to MZ80A if no valid combination given.
                MODE_MZ80A        <= '0';
                MODE_MZ700        <= '0';
                if(Z80_DATA(2 downto 0) = "010") then
                    MODE_MZ700    <= '1';
                else
                    MODE_MZ80A    <= '1';
                end if;

            -- Read current register settings.
            elsif(CPLD_CFGn = '0' and Z80_RDn = '0') then
                CPLD_CFG_DATA     <= "000000" & MODE_MZ700 & MODE_MZ80A;

            -- Read version information.
            elsif(CPLD_INFOn = '0' and Z80_RDn = '0') then
                CPLD_CFG_DATA     <= "1010" & std_logic_vector(to_unsigned(CPLD_VERSION, 4));

            else
                null;
            end if;

            -- The external signals override the register settings if applied.
            --
            if(CFG_MZ700 = '0' and CFG_MZ80A = '1') then
                MODE_MZ80A            <= '1';
            elsif(CFG_MZ700 = '1' and CFG_MZ80A = '0') then
                MODE_MZ700            <= '1';
            else
                null;
            end if;
        end if;

    end process;


    -- Memory mode latch. This latch stores the current memory mode (or Bank Paging Scheme) according to the running software.
    --
    process( SYSCLK, Z80_RESETn, MEM_CFGn, Z80_IORQn, Z80_ADDR, Z80_DATA )
        variable mz700_LOWER_RAM    : std_logic;
        variable mz700_UPPER_RAM    : std_logic;
        variable mz700_INHIBIT      : std_logic;
    begin

        if(Z80_RESETn = '0') then
            --MEM_MODE_LATCH    <= "00001000";
            MEM_MODE_LATCH     <= "00000000";
            mz700_LOWER_RAM    := '0';
            mz700_UPPER_RAM    := '0';
            mz700_INHIBIT      := '0';

        elsif(SYSCLK'event and SYSCLK = '1') then

            if(MEM_CFGn = '0' and Z80_WRn = '0') then
                MEM_MODE_LATCH <= Z80_DATA;

            -- Check for MZ700 Mode memory changes and adjust current memory mode setting.
            elsif(MODE_MZ700 = '1' and Z80_IORQn = '0' and Z80_M1n = '1' and Z80_ADDR(7 downto 3) = "11100") then

                
                -- MZ700 memory mode switch?
                --         0x0000:0x0FFF     0xD000:0xFFFF
                -- 0xE0 =  DRAM
                -- 0xE1 =                    DRAM
                -- 0xE2 =  MONITOR
                -- 0xE3 =                    Memory Mapped I/O
                -- 0xE4 =  MONITOR           Memory Mapped I/O
                -- 0xE5 =                    Inhibit
                -- 0xE6 =                    Return to state prior to 0xE5
                case Z80_ADDR(2 downto 0) is
                    -- 0xE0
                    when "000" =>
                        mz700_LOWER_RAM  := '1';

                    -- 0xE1
                    when "001" =>
                        mz700_UPPER_RAM  := '1';

                    -- 0xE2
                    when "010" =>
                        mz700_LOWER_RAM  := '0';

                    -- 0xE3
                    when "011" =>
                        mz700_UPPER_RAM  := '0';

                    -- 0xE4
                    when "100" =>
                        mz700_LOWER_RAM  := '0';
                        mz700_UPPER_RAM  := '0';

                    -- 0xE5
                    when "101" =>
                        mz700_INHIBIT    := '1';

                    -- 0xE6
                    when "110" =>
                        mz700_INHIBIT    := '0';

                    -- 0xE7
                    when "111" =>
                end case;

                if(mz700_INHIBIT = '0' and mz700_LOWER_RAM = '0' and mz700_UPPER_RAM = '0') then
                    MEM_MODE_LATCH(4 downto 0) <= "00010";

                elsif(mz700_INHIBIT = '0' and mz700_LOWER_RAM = '1' and mz700_UPPER_RAM = '0') then
                    MEM_MODE_LATCH(4 downto 0) <= "01010";

                elsif(mz700_INHIBIT = '0' and mz700_LOWER_RAM = '0' and mz700_UPPER_RAM = '1') then
                    MEM_MODE_LATCH(4 downto 0) <= "01011";

                elsif(mz700_INHIBIT = '0' and mz700_LOWER_RAM = '1' and mz700_UPPER_RAM = '1') then
                    MEM_MODE_LATCH(4 downto 0) <= "01100";

                elsif(mz700_INHIBIT = '1' and mz700_LOWER_RAM = '0') then
                    MEM_MODE_LATCH(4 downto 0) <= "01101";

                elsif(mz700_INHIBIT = '1' and mz700_LOWER_RAM = '1') then
                    MEM_MODE_LATCH(4 downto 0) <= "01110";
                else
                    null;
                end if;

            else
                null;
            end if;
        end if;
    end process;

    -- Process to map host keyboard to realise compatibility with other Sharp machines.
    -- Currently the host is the Sharp MZ-80A and a mapping exists for the MZ-700.
    process( SYSCLK, Z80_RESETn, MEM_CFGn, Z80_IORQn, Z80_ADDR, Z80_DATA )
    begin

        if Z80_RESETn = '0' then
            MB_BUSRQn               <= '1';
            MB_MREQn                <= '1';
            MB_ADDR                 <= (others => '0');
            MB_DELAY                <= (others => '1');
            MB_KEY_STROBE           <= (others => '0');
            MB_WRITE_STROBE         <= '0';
            MB_READ_KEYS            <= '0';
            MB_STATE                <= 0;
            KEY_STROBE              <= (others => '0');
            KEY_SUBSTITUTE          <= '0';

        elsif SYSCLK'event and SYSCLK = '1' then

            -- When inactive, wait for a Z80 I/O transaction that needs writeback.
            --
            if MODE_MZ700 = '1' then

                -- Configurable delay, halts all actions whilst the timer > 0.
                if MB_DELAY /= 0 then
                    MB_DELAY        <= MB_DELAY - 1;

                -- If the Z80 Bus has not been requested, request it for the next transaction.
                elsif MB_BUSRQn = '1' and KEY_SUBSTITUTE = '0' then
                    MB_BUSRQn       <= '0';

                -- When the Z80 bus is available, run the FSM.
                elsif MB_BUSRQn = '0' and Z80_BUSACKn = '0' then

                    -- Move along the state machine, next state can be overriden if required.
                    --
                    if MB_STATE = 5 then
                        MB_STATE                <= 0;
                    else
                        MB_STATE                <= MB_STATE+1;
                    end if;

                    -- FSM.
                    case MB_STATE is
                        -- Setup to write the strobe value to PPI A.
                        when 0 =>
                            MB_ADDR             <= X"E000";
                            MB_DATA             <= "1111" & MB_KEY_STROBE;
    
                        -- Allow at least 2 cycles for the write pulse.
                        when 1 =>
                            MB_MREQn            <= '0';
                            MB_WRITE_STROBE     <= '1';
                            MB_DELAY            <= X"0001";
    
                        -- Terminate write pulse.
                        when 2 =>
                            MB_MREQn            <= '1';
                            MB_WRITE_STROBE     <= '0';
    
                        -- Setup for a read of the key data from PPI B.
                        when 3 =>
                            MB_ADDR             <= X"E001";
    
                        -- Allow at least 2 cycles for the data to become available.
                        when 4 =>
                            MB_MREQn            <= '0';
                            MB_READ_KEYS        <= '1';
                            MB_DELAY            <= X"0001";
    
                        -- Read the key data into the matrix for later mapping.
                        when 5 =>
                            KEY_MATRIX(to_integer(unsigned(MB_KEY_STROBE))) <= Z80_DATA;
                            MB_MREQn            <= '1';
                            MB_READ_KEYS        <= '0';
                            MB_DELAY            <= X"0DFC";                    -- 1ms delay between key sweeps with a 3.58MHz clock.
                            MB_BUSRQn           <= '1';
    
                            if unsigned(MB_KEY_STROBE) = 9 then
                                MB_KEY_STROBE   <= (others => '0');
                            else
                                MB_KEY_STROBE   <= MB_KEY_STROBE + 1;
                            end if;
    
                        when others =>
                            MB_STATE            <= 0;
                    end case;

                end if;

                -- When the Z80 isnt tri-stated process normally.
                --
                if MB_BUSRQn = '1' and Z80_BUSACKn = '1' then
                    -- Detect a strobe output write and store it - this is used as the index into the key matrix for each read operation on the .
                    if(Z80_MREQn = '0' and Z80_ADDR(15 downto 0) = X"E000") then
                        KEY_STROBE     <= Z80_DATA(3 downto 0);
                    end if;

                    -- On a keyscan read data into the matrix and raise the substitue flag. This flag will disable the mainboard (tri-state it) so that the data lines are not driven. The mapped
                    -- data is the output on the data bus by the CPLD which the Z80 reads.
                    if(Z80_MREQn = '0' and Z80_ADDR(15 downto 0) = X"E001") then
                        if((unsigned(MEM_MODE_LATCH(4 downto 0)) = 2 or unsigned(MEM_MODE_LATCH(4 downto 0)) = 8 or (unsigned(MEM_MODE_LATCH(4 downto 0)) >= 10 and unsigned(MEM_MODE_LATCH(4 downto 0)) < 15))) then
                            KEY_SUBSTITUTE <= '1';
                            MB_BUSRQn      <= '1'; 
                        end if;
                    end if;

                    -- Actual keyboard mapping. The Sharp MZ-80A key codes are scanned into a 10x8 matrix and then this matrix is indexed to extract the keycodes for the machine we
                    -- are being compatible with.
                    --
                    if(KEY_SUBSTITUTE = '1') then

                        -- MZ-80A Keyboard -> MZ-700 mapping.
                        case KEY_STROBE is
                            --                 D7                D6                D5                D4                D3                D2                D1                D0
                            when "0000" =>
                                KEYMAP_DATA <= '1'              & KEY_MATRIX(0)(7) & KEY_MATRIX(7)(4) & KEY_MATRIX(0)(1) & '1'              & KEY_MATRIX(6)(2) & KEY_MATRIX(6)(3) & KEY_MATRIX(7)(3);  -- 1
                            when "0001" =>
                                KEYMAP_DATA <= KEY_MATRIX(3)(5) & KEY_MATRIX(1)(0) & KEY_MATRIX(6)(4) & KEY_MATRIX(6)(5) & KEY_MATRIX(7)(2) & '1'              & '1'              & '1'             ;  -- 2
                            when "0010" =>
                                KEYMAP_DATA <= KEY_MATRIX(1)(4) & KEY_MATRIX(2)(5) & KEY_MATRIX(2)(2) & KEY_MATRIX(3)(4) & KEY_MATRIX(4)(4) & KEY_MATRIX(3)(1) & KEY_MATRIX(1)(5) & KEY_MATRIX(2)(1);  -- 3
                            when "0011" =>
                                KEYMAP_DATA <= KEY_MATRIX(4)(5) & KEY_MATRIX(4)(3) & KEY_MATRIX(5)(2) & KEY_MATRIX(5)(3) & KEY_MATRIX(5)(0) & KEY_MATRIX(4)(1) & KEY_MATRIX(5)(4) & KEY_MATRIX(5)(5);  -- 4
                            when "0100" =>
                                KEYMAP_DATA <= KEY_MATRIX(1)(3) & KEY_MATRIX(3)(0) & KEY_MATRIX(2)(0) & KEY_MATRIX(2)(3) & KEY_MATRIX(2)(4) & KEY_MATRIX(3)(2) & KEY_MATRIX(3)(3) & KEY_MATRIX(4)(2);  -- 5
                            when "0101" =>
                                KEYMAP_DATA <= KEY_MATRIX(1)(6) & KEY_MATRIX(1)(7) & KEY_MATRIX(2)(6) & KEY_MATRIX(2)(7) & KEY_MATRIX(3)(6) & KEY_MATRIX(3)(7) & KEY_MATRIX(4)(6) & KEY_MATRIX(4)(7);  -- 6
                            when "0110" =>
                                KEYMAP_DATA <= KEY_MATRIX(7)(6) & KEY_MATRIX(6)(7) & KEY_MATRIX(6)(6) & KEY_MATRIX(4)(0) & KEY_MATRIX(5)(7) & KEY_MATRIX(5)(6) & KEY_MATRIX(5)(1) & KEY_MATRIX(6)(0);  -- 7
                            when "0111" =>
                                KEYMAP_DATA <= KEY_MATRIX(8)(6) & KEY_MATRIX(9)(6) & KEY_MATRIX(8)(7) & KEY_MATRIX(8)(3) & KEY_MATRIX(9)(4) & KEY_MATRIX(8)(4) & KEY_MATRIX(7)(0) & KEY_MATRIX(6)(1);  -- 8
                            when "1000" =>
                                KEYMAP_DATA <= KEY_MATRIX(7)(7) & KEY_MATRIX(1)(2) & '1'              & '1'              & '1'              & '1'             & '1'               & KEY_MATRIX(0)(0);  -- 9
                            when "1001" =>
                                KEYMAP_DATA <= KEY_MATRIX(8)(2) & KEY_MATRIX(8)(0) & KEY_MATRIX(8)(1) & KEY_MATRIX(9)(0) & KEY_MATRIX(9)(2) & '1'             & '1'               & '1'             ;  -- 10
                            when others =>
                                KEYMAP_DATA <= "11111111";
                        end case;
                    end if;

                    -- When the Z80_MREQn goes inactive, the keyboard read has completed so clear the substitute flag which in turn allows normal bus operations.
                    --
                    if(KEY_SUBSTITUTE = '1' and Z80_MREQn = '1') then
                        KEY_SUBSTITUTE <= '0';
                    end if;
                end if;

            else
                MB_BUSRQn           <= '1';
                MB_STATE            <= 0;
            end if;

        end if;
    end process;


    -- D type Flip Flops used for the CPU frequency switching circuit. The changeover of frequencies occurs on the high level, the output clock remaining
    -- high until the falling edge of the clock being switched into.
    FFCLK1: process( SYSCLK, Z80_RESETn ) begin

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
    FFCLK2: process( CTLCLK, Z80_RESETn ) begin
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
    Z80_CLKi    <= CTLCLK when CTLCLK_Q = '0'
                   else SYSCLK;
    CTL_CLKSLCTi<= '1' when (TZ_BUSACKni = '0' and SCK_CTLSELn = '0')
                   else '0';
    CTL_CLKSLCT <= CTL_CLKSLCTi;
    Z80_CLK     <= Z80_CLKi;

    -- Mainboard BUS Request S-R latch 1.
    MBBUSREQ: process(SYSCLK)
        variable tmp    : std_logic;
    begin
        if(SYSCLK='1' and SYSCLK'event) then
            if((ENABLE_BUSn = '1' and Z80_RESETn = '1')   and DISABLE_BUSn = '1') then
                tmp := tmp;
            elsif((ENABLE_BUSn = '0' or Z80_RESETn = '0') and DISABLE_BUSn = '0') then
                tmp := 'Z';
            elsif((ENABLE_BUSn = '0' or Z80_RESETn = '0') and DISABLE_BUSn = '1') then
                tmp := '1';
            else
                tmp := '0';
            end if;
        end if;

        TZ_BUSACKni <= tmp;
    end PROCESS;

    -- Mainboard Clock Select S-R latch 3.
    MBCLKSEL: process(SYSCLK)
        variable tmp    : std_logic;
    begin
        if(SYSCLK='1' and SYSCLK'event) then
            if((SCK_SYSCLKn = '1' and Z80_RESETn = '1')   and SCK_CTLCLKn = '1') then
                tmp := tmp;
            elsif((SCK_SYSCLKn = '0' or Z80_RESETn = '0') and SCK_CTLCLKn = '0') then
                tmp := 'Z';
            elsif((SCK_SYSCLKn = '0' or Z80_RESETn = '0') and SCK_CTLCLKn = '1') then
                tmp := '1';
            else
                tmp := '0';
            end if;
        end if;

        SCK_CTLSELn <= tmp;
    end PROCESS;


    -- Mainboard WAIT State Generator S-R latch 4.
    -- NB: V2.1 design doesnt need the wait state generator as the mapping is done in hardware.
    --
    --MBWAITGEN: process(SYSCLK, Z80_ADDR, Z80_M1n, CTL_BUSRQn, MEM_MODE_LATCH, Z80_IORQn)
    --    variable tmp    : std_logic;
    --    variable iowait : std_logic;
    --begin
    --
    --    -- IO Wait select active when an IO operation is made in range 0xE0-0xFF.
    --    if (Z80_ADDR(7 downto 5) = "111" and Z80_M1n = '1' and CTL_BUSRQn = '1' and MEM_MODE_LATCH(5) = '1' and Z80_IORQn = '0') then
    --        iowait := '0';
    --    else
    --        iowait := '1';
    --    end if;
    --
    --    if(SYSCLK='1' and SYSCLK'event) then
    --        if((CTL_BUSRQn = '1' and Z80_RESETn = '1') and iowait = '1') then
    --            tmp := tmp;
    --        elsif((CTL_BUSRQn = '0' or Z80_RESETn = '0') and iowait = '0') then
    --            tmp := 'Z';
    --        elsif((CTL_BUSRQn = '0' or Z80_RESETn = '0') and iowait = '1') then
    --            tmp := '1';
    --        else
    --            tmp := '0';
    --        end if;
    --    end if;
    --
    --    REQ_WAIT <= tmp;
    --end PROCESS;

    -- Wait states, added by the video circuitry or the K64F.
    Z80_WAITn   <= '0' when SYS_WAITn = '0' or CTL_WAITn = '0' --or REQ_WAITn = '0'
                   else '1';

    -- Z80 signals passed to the mainboard, if the K64F has control of the bus then the Z80 signals are disabled as they are not tri-stated during a BUSRQ state.
    CTL_M1n     <= Z80_M1n   when Z80_BUSACKn = '1'
                   else 'Z';
    CTL_RFSHn   <= Z80_RFSHn when Z80_BUSACKn = '1'
                   else 'Z';
    CTL_HALTn   <= Z80_HALTn when Z80_BUSACKn = '1'
                   else 'Z';

    -- Bus control logic.
    TZ_BUSACKn  <= TZ_BUSACKni;
    SYS_BUSACKn <= '1' when Z80_BUSACKn = '0' and MB_BUSRQn = '0'
                   else
                   '0' when TZ_BUSACKni = '0' or (Z80_BUSACKn = '0' and CTL_BUSACKn = '0') 
                   else '1';
    Z80_BUSRQn  <= '0' when SYS_BUSRQn = '0' or CTL_BUSRQn = '0' or MB_BUSRQn = '0'
                   else '1';
        
    --
    -- Data Bus Multiplexing, plex the output devices onto the Z80 data bus.
    --
    Z80_DATA    <= "0000000" & CTL_CLKSLCTi   when SCK_RDn = '0'
                   else 
                   MEM_MODE_LATCH(7 downto 0) when MEM_CFGn = '0' and Z80_RDn = '0'
                   else
                   KEYMAP_DATA                when MB_BUSRQn = '1' and Z80_BUSACKn = '1' and KEY_SUBSTITUTE = '1'
                   else
                   CPLD_CFG_DATA              when (CPLD_CFGn = '0' or CPLD_INFOn = '0') and Z80_RDn = '0'
                   else
                   MB_DATA                    when MB_BUSRQn = '0' and Z80_BUSACKn = '0' and MB_READ_KEYS = '0' -- add read signals inactive state here.
                   else
                   (others => 'Z');
    
    --
    -- Address Bus Multiplexing.
    --
    Z80_ADDR    <= MB_ADDR when MB_BUSRQn = '0' and Z80_BUSACKn = '0'
                   else (others => 'Z');

    Z80_WRn     <= '0' when MB_MREQn = '0' and Z80_BUSACKn = '0' and (MB_WRITE_STROBE = '1') -- and (write1 or write2...) signals active here
                   else
                   '1' when Z80_BUSACKn = '0'
                   else 'Z';

    Z80_RDn     <= '0' when MB_MREQn = '0' and Z80_BUSACKn = '0' and (MB_READ_KEYS = '1') -- and (read1 or read2...) signals active here
                   else
                   '1' when Z80_BUSACKn = '0'
                   else 'Z';

    Z80_MREQn   <= MB_MREQn when Z80_BUSACKn = '0'
                   else 'Z';

    -- The tranZPUter SW board adds upgrades for the Z80 processor and host. These upgrades are controlled through an IO port which 
    -- in v1.0 - v1.1 was either at 0x2-=0x2f, 0x60-0x6f, 0xA0-0xAf, 0xF0-0xFF, the default being 0x60. This logic mimcs the 74HCT138 and
    -- FlashRAM decoder which produces the Io port select signals.
    --
    TZIO_CSn    <= '0' when Z80_IORQn = '0' and Z80_M1n = '1' and Z80_ADDR(7 downto 4) = "0110"
                   else '1';
    MEM_CFGn    <= '0' when TZIO_CSn = '0' and Z80_ADDR(3 downto 1) = "000"                                  -- IO 60
                   else '1';
    SCK_CTLCLKn <= '0' when TZIO_CSn = '0' and Z80_ADDR(3 downto 1) = "001"                                  -- IO 62
                   else '1';
    SCK_SYSCLKn <= '0' when TZIO_CSn = '0' and Z80_ADDR(3 downto 1) = "010"                                  -- IO 64
                   else '1';
    SCK_RDn     <= '0' when TZIO_CSn = '0' and Z80_ADDR(3 downto 1) = "011"                                  -- IO 66
                   else '1';
    SVCREQn     <= '0' when TZIO_CSn = '0' and Z80_ADDR(3 downto 1) = "100"                                  -- IO 68
                   else '1';
    SYSREQn     <= '0' when TZIO_CSn = '0' and Z80_ADDR(3 downto 1) = "101"                                  -- IO 6A
                   else '1';
    CPLD_CFGn   <= '0' when TZIO_CSn = '0' and Z80_ADDR(3 downto 0) = "1110"                                 -- IO 6E
                   else '1';
    CPLD_INFOn  <= '0' when TZIO_CSn = '0' and Z80_ADDR(3 downto 0) = "1111"                                 -- IO 6F
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
    --                   8 - Monitor ROM (0000:0FFF) on mainboard, Main RAM (1000:CFFF) in tranZPUter bank 0 and video, memory mapped I/O, User/Floppy ROM on mainboard.
    --                       NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
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
    process(Z80_ADDR, Z80_WRn, Z80_RDn, Z80_IORQn, Z80_MREQn, Z80_M1n, MEM_MODE_LATCH, KEY_SUBSTITUTE) begin

        case MEM_MODE_LATCH(4 downto 0) is

            -- Set 0 - default, no tranZPUter RAM access so just pulse the ENABLE_BUS signal for safety to ensure the CPU has continuous access to the
            -- mainboard resources, especially for Refresh of DRAM.
            when "00000" => 
                ENABLE_BUSn         <= '0';
                DISABLE_BUSn        <= '1';
                Z80_HI_ADDR(18 downto 16) <= "000";
                RAM_CSni            <= '1';
                RAM_WEni            <= '1';
                RAM_OEni            <= '1';

            -- Whenever running in RAM ensure the mainboard is disabled to prevent decoder propagation delay glitches.
            when "00001" => 
                RAM_CSni            <= '0';
                Z80_HI_ADDR(18 downto 15) <= "000" & Z80_ADDR(15);
                if( Z80_MREQn = '0' and unsigned(Z80_ADDR(15 downto 0)) >= X"E800" and unsigned(Z80_ADDR(15 downto 0)) < X"F000") then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;
                else
                    DISABLE_BUSn    <= '1';
                    ENABLE_BUSn     <= '0';
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 2 - Monitor ROM 0000-0FFF, Main DRAM 0x1000-0xD000, User/Floppy ROM E800-FFFF are in tranZPUter memory. Two small holes at F3FE and F7FE exist for the Floppy disk controller (which have to be 64
            -- bytes from F3C0 and F7C0 due to the granularity of the address lines into the Flash RAM), these locations  need to be on the mainboard.
            -- NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
            when "00010" => 
                RAM_CSni            <= '0';
                Z80_HI_ADDR(18 downto 15) <= "000" & Z80_ADDR(15);
                if( Z80_MREQn = '0' and ((unsigned(Z80_ADDR(15 downto 0)) >= X"0000" and unsigned(Z80_ADDR(15 downto 0)) < X"D000") or (unsigned(Z80_ADDR(15 downto 0)) >= X"E800" and unsigned(Z80_ADDR(15 downto 0)) < X"F3C0") or (unsigned(Z80_ADDR(15 downto 0)) >= X"F400" and unsigned(Z80_ADDR(15 downto 0)) < X"F7C0") or (unsigned(Z80_ADDR(15 downto 0)) >= X"F800" and unsigned(Z80_ADDR(15 downto 0)) <= X"FFFF"))) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;
                else
                    DISABLE_BUSn    <= '1';
                    ENABLE_BUSn     <= '0';
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

                if KEY_SUBSTITUTE = '1' then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                end if;

            -- Set 3 - Monitor ROM 0000-0FFF, Main RAM area 0x1000-0xD000, User ROM 0xE800-EFFF are in tranZPUter memory block 0, Floppy ROM F000-FFFF are in tranZPUter memory block 1.
            -- NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
            when "00011" => 
                RAM_CSni            <= '0';
                if( Z80_MREQn = '0' and ((unsigned(Z80_ADDR(15 downto 0)) >= X"0000" and unsigned(Z80_ADDR(15 downto 0)) < X"D000") or (unsigned(Z80_ADDR(15 downto 0)) >= X"E800" and unsigned(Z80_ADDR(15 downto 0)) < X"F000"))) then 
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 15) <= "000" & Z80_ADDR(15);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;
                elsif( Z80_MREQn = '0' and ((unsigned(Z80_ADDR(15 downto 0)) >= X"F000" and unsigned(Z80_ADDR(15 downto 0)) < X"F3C0") or (unsigned(Z80_ADDR(15 downto 0)) >= X"F400" and unsigned(Z80_ADDR(15 downto 0)) < X"F7C0") or (unsigned(Z80_ADDR(15 downto 0)) >= X"F000" and unsigned(Z80_ADDR(15 downto 0)) <= X"FFFF"))) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 15) <= "001" & Z80_ADDR(15);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;
                else
                    DISABLE_BUSn    <= '1';
                    ENABLE_BUSn     <= '0';
                    Z80_HI_ADDR(18 downto 15) <= "000" & Z80_ADDR(15);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 4 - Monitor ROM 0000-0FFF, Main RAM area 0x1000-0xD000, User ROM 0xE800-EFFF are in tranZPUter memory block 0, Floppy ROM F000-FFFF are in tranZPUter memory block 2.
            -- NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
            when "00100" => 
                RAM_CSni            <= '0';
                if( Z80_MREQn = '0' and ((unsigned(Z80_ADDR(15 downto 0)) >= X"0000" and unsigned(Z80_ADDR(15 downto 0)) < X"D000") or (unsigned(Z80_ADDR(15 downto 0)) >= X"E800" and unsigned(Z80_ADDR(15 downto 0)) < X"F000"))) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 15) <= "000" & Z80_ADDR(15);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;

                elsif( Z80_MREQn = '0' and (unsigned(Z80_ADDR(15 downto 0)) >= X"F000" and unsigned(Z80_ADDR(15 downto 0)) <= X"FFFF")) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 15) <= "010" & Z80_ADDR(15);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;
                else
                    DISABLE_BUSn    <= '1';
                    ENABLE_BUSn     <= '0';
                    Z80_HI_ADDR(18 downto 15) <= "000" & Z80_ADDR(15);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 5 - Monitor ROM 0000-0FFF, Main RAM area 0x1000-0xD000, User ROM 0xE800-EFFF are in tranZPUter memory block 0, Floppy ROM F000-FFFF are in tranZPUter memory block 3.
            -- NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
            when "00101" => 
                RAM_CSni            <= '0';
                if( Z80_MREQn = '0' and ((unsigned(Z80_ADDR(15 downto 0)) >= X"0000" and unsigned(Z80_ADDR(15 downto 0)) < X"D000") or (unsigned(Z80_ADDR(15 downto 0)) >= X"E800" and unsigned(Z80_ADDR(15 downto 0)) < X"F000"))) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 15) <= "000" & Z80_ADDR(15);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;

                elsif( Z80_MREQn = '0' and (unsigned(Z80_ADDR(15 downto 0)) >= X"F000" and unsigned(Z80_ADDR(15 downto 0)) <= X"FFFF")) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 15) <= "011" & Z80_ADDR(15);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;
                else
                    DISABLE_BUSn    <= '1';
                    ENABLE_BUSn     <= '0';
                    Z80_HI_ADDR(18 downto 15) <= "000" & Z80_ADDR(15);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 6 - CPM, all memory on the tranZPUter board, 64K block 4 selected.
            -- Special case for F3C0:F3FF & F7C0:F7FF (floppy disk paging vectors) which resides on the mainboard.
            when "00110" => 
                RAM_CSni            <= '0';
                if( Z80_MREQn = '0' and ((unsigned(Z80_ADDR(15 downto 0)) >= X"D000" and unsigned(Z80_ADDR(15 downto 0)) < X"F3C0") or (unsigned(Z80_ADDR(15 downto 0)) >= X"F400" and unsigned(Z80_ADDR(15 downto 0)) < X"F7C0") or (unsigned(Z80_ADDR(15 downto 0)) >= X"F800" and unsigned(Z80_ADDR(15 downto 0)) <= X"FFFF"))) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 15) <= "001" & Z80_ADDR(15);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;

                elsif( Z80_MREQn = '0' and ((unsigned(Z80_ADDR(15 downto 0)) >= X"0100" and unsigned(Z80_ADDR(15 downto 0)) < X"D000") or (unsigned(Z80_ADDR(15 downto 0)) >= X"E800" and unsigned(Z80_ADDR(15 downto 0)) < X"F000"))) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 15) <= "101" & Z80_ADDR(15);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;
                else
                    DISABLE_BUSn    <= '1';
                    ENABLE_BUSn     <= '0';
                    Z80_HI_ADDR(18 downto 15) <= "000" & Z80_ADDR(15);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 7 - CPM, F000-FFFF are on the tranZPUter board in block 4, 0040-CFFF and E800-EFFF are in block 5 selected, mainboard for D000-DFFF (video), E000-E800 (Memory control) selected.
            -- Special case for 0000:00FF (interrupt vectors) which resides in block 4 and CPM vectors, F3C0:F3FF & F7C0:F7FF (floppy disk paging vectors) which resides on the mainboard.
            when "00111" => 
                RAM_CSni            <= '0';
                if( Z80_MREQn = '0' and ((unsigned(Z80_ADDR(15 downto 0)) >= X"0000" and unsigned(Z80_ADDR(15 downto 0)) < X"0100") or (unsigned(Z80_ADDR(15 downto 0)) >= X"F000" and unsigned(Z80_ADDR(15 downto 0)) < X"F3C0") or (unsigned(Z80_ADDR(15 downto 0)) >= X"F400" and unsigned(Z80_ADDR(15 downto 0)) < X"F7C0") or (unsigned(Z80_ADDR(15 downto 0)) >= X"F800" and unsigned(Z80_ADDR(15 downto 0)) <= X"FFFF"))) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 15) <= "100" & Z80_ADDR(15);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;

                elsif( Z80_MREQn = '0' and ((unsigned(Z80_ADDR(15 downto 0)) >= X"0100" and unsigned(Z80_ADDR(15 downto 0)) < X"D000") or (unsigned(Z80_ADDR(15 downto 0)) >= X"E800" and unsigned(Z80_ADDR(15 downto 0)) < X"F000"))) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 15) <= "101" & Z80_ADDR(15);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;

                else
                    DISABLE_BUSn    <= '1';
                    ENABLE_BUSn     <= '0';
                    Z80_HI_ADDR(18 downto 15) <= "000" & Z80_ADDR(15);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 8 - Monitor ROM 0000-0FFF on mainboard, Main DRAM 0x1000-0xD000 is in tranZPUter memory. 
            -- NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
            when "01000" => 
                RAM_CSni            <= '0';
                Z80_HI_ADDR(18 downto 15) <= "000" & Z80_ADDR(15);
                if( Z80_MREQn = '0' and (unsigned(Z80_ADDR(15 downto 0)) >= X"1000" and unsigned(Z80_ADDR(15 downto 0)) < X"D000")) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;
                else
                    DISABLE_BUSn    <= '1';
                    ENABLE_BUSn     <= '0';
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

                if KEY_SUBSTITUTE = '1' then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                end if;

            -- Set 10 - MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 6, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is on the mainboard.
            when "01010" =>
                RAM_CSni            <= '0';
                if( Z80_MREQn = '0' and ((unsigned(Z80_ADDR(15 downto 0)) >= X"0000" and unsigned(Z80_ADDR(15 downto 0)) < X"1000"))) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 15) <= "110" & Z80_ADDR(15);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;

                elsif( Z80_MREQn = '0' and (unsigned(Z80_ADDR(15 downto 0)) >= X"1000" and unsigned(Z80_ADDR(15 downto 0)) < X"D000")) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 15) <= "000" & Z80_ADDR(15);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;

                else
                    DISABLE_BUSn    <= '1';
                    ENABLE_BUSn     <= '0';
                    Z80_HI_ADDR(18 downto 15) <= "000" & Z80_ADDR(15);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

                if KEY_SUBSTITUTE = '1' then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                end if;

            -- Set 11 - MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 0, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is on the tranZPUter in block 6.
            when "01011" =>
                RAM_CSni            <= '0';
                if( Z80_MREQn = '0' and ((unsigned(Z80_ADDR(15 downto 0)) >= X"0000" and unsigned(Z80_ADDR(15 downto 0)) < X"1000"))) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 15) <= "000" & Z80_ADDR(15);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;

                elsif( Z80_MREQn = '0' and (unsigned(Z80_ADDR(15 downto 0)) >= X"1000" and unsigned(Z80_ADDR(15 downto 0)) < X"D000")) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 15) <= "000" & Z80_ADDR(15);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;

                elsif( Z80_MREQn = '0' and ((unsigned(Z80_ADDR(15 downto 0)) >= X"D000" and unsigned(Z80_ADDR(15 downto 0)) <= X"FFFF"))) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 15) <= "110" & Z80_ADDR(15);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;

                else
                    DISABLE_BUSn    <= '1';
                    ENABLE_BUSn     <= '0';
                    Z80_HI_ADDR(18 downto 15) <= "000" & Z80_ADDR(15);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

                if KEY_SUBSTITUTE = '1' then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                end if;

            -- Set 12 - MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 6, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is on the tranZPUter in block 6.
            when "01100" =>
                RAM_CSni            <= '0';
                if( Z80_MREQn = '0' and ((unsigned(Z80_ADDR(15 downto 0)) >= X"0000" and unsigned(Z80_ADDR(15 downto 0)) < X"1000"))) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 15) <= "110" & Z80_ADDR(15);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;

                elsif( Z80_MREQn = '0' and (unsigned(Z80_ADDR(15 downto 0)) >= X"1000" and unsigned(Z80_ADDR(15 downto 0)) < X"D000")) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 15) <= "000" & Z80_ADDR(15);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;

                elsif( Z80_MREQn = '0' and ((unsigned(Z80_ADDR(15 downto 0)) >= X"D000" and unsigned(Z80_ADDR(15 downto 0)) <= X"FFFF"))) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 15) <= "110" & Z80_ADDR(15);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;

                else
                    DISABLE_BUSn    <= '1';
                    ENABLE_BUSn     <= '0';
                    Z80_HI_ADDR(18 downto 15) <= "000" & Z80_ADDR(15);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

                if KEY_SUBSTITUTE = '1' then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                end if;

            -- Set 13 - MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 0, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is inaccessible.
            when "01101" =>
                RAM_CSni            <= '0';
                if( Z80_MREQn = '0' and ((unsigned(Z80_ADDR(15 downto 0)) >= X"0000" and unsigned(Z80_ADDR(15 downto 0)) < X"1000"))) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 15) <= "000" & Z80_ADDR(15);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;

                elsif( Z80_MREQn = '0' and (unsigned(Z80_ADDR(15 downto 0)) >= X"1000" and unsigned(Z80_ADDR(15 downto 0)) < X"D000")) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 15) <= "000" & Z80_ADDR(15);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;

                elsif( Z80_MREQn = '0' and ((unsigned(Z80_ADDR(15 downto 0)) >= X"D000" and unsigned(Z80_ADDR(15 downto 0)) <= X"FFFF"))) then
                    DISABLE_BUSn    <= '1';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 15) <= "000" & Z80_ADDR(15);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';

                else
                    DISABLE_BUSn    <= '1';
                    ENABLE_BUSn     <= '0';
                    Z80_HI_ADDR(18 downto 15) <= "000" & Z80_ADDR(15);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

                if KEY_SUBSTITUTE = '1' then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                end if;

            -- Set 14 - MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 6, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is inaccessible.
            when "01110" =>
                RAM_CSni            <= '0';
                if( Z80_MREQn = '0' and ((unsigned(Z80_ADDR(15 downto 0)) >= X"0000" and unsigned(Z80_ADDR(15 downto 0)) < X"1000"))) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 15) <= "110" & Z80_ADDR(15);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;

                elsif( Z80_MREQn = '0' and (unsigned(Z80_ADDR(15 downto 0)) >= X"1000" and unsigned(Z80_ADDR(15 downto 0)) < X"D000")) then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 15) <= "000" & Z80_ADDR(15);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;

                elsif( Z80_MREQn = '0' and ((unsigned(Z80_ADDR(15 downto 0)) >= X"D000" and unsigned(Z80_ADDR(15 downto 0)) <= X"FFFF"))) then
                    DISABLE_BUSn    <= '1';
                    ENABLE_BUSn     <= '1';
                    Z80_HI_ADDR(18 downto 15) <= "000" & Z80_ADDR(15);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';

                else
                    DISABLE_BUSn    <= '1';
                    ENABLE_BUSn     <= '0';
                    Z80_HI_ADDR(18 downto 15) <= "000" & Z80_ADDR(15);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

                if KEY_SUBSTITUTE = '1' then
                    DISABLE_BUSn    <= '0';
                    ENABLE_BUSn     <= '1';
                end if;

            -- Set 24 - All memory and IO are on the tranZPUter board, 64K block 0 selected.
            when "11000" =>
                DISABLE_BUSn        <= '0';
                ENABLE_BUSn         <= '1';
                Z80_HI_ADDR(18 downto 15) <= "000" & Z80_ADDR(15);
                RAM_CSni            <= '0';
                RAM_OEni            <= Z80_RDn;
                RAM_WEni            <= Z80_WRn;

            -- Set 25 - All memory and IO are on the tranZPUter board, 64K block 1 selected.
            when "11001" =>
                DISABLE_BUSn        <= '0';
                ENABLE_BUSn         <= '1';
                Z80_HI_ADDR(18 downto 15) <= "001" & Z80_ADDR(15);
                RAM_CSni            <= '0';
                RAM_OEni            <= Z80_RDn;
                RAM_WEni            <= Z80_WRn;

            -- Set 26 - All memory and IO are on the tranZPUter board, 64K block 2 selected.
            when "11010" =>
                DISABLE_BUSn        <= '0';
                ENABLE_BUSn         <= '1';
                Z80_HI_ADDR(18 downto 15) <= "010" & Z80_ADDR(15);
                RAM_CSni            <= '0';
                RAM_OEni            <= Z80_RDn;
                RAM_WEni            <= Z80_WRn;

            -- Set 27 - All memory and IO are on the tranZPUter board, 64K block 3 selected.
            when "11011" =>
                DISABLE_BUSn        <= '0';
                ENABLE_BUSn         <= '1';
                Z80_HI_ADDR(18 downto 15) <= "011" & Z80_ADDR(15);
                RAM_CSni            <= '0';
                RAM_OEni            <= Z80_RDn;
                RAM_WEni            <= Z80_WRn;

            -- Set 28 - All memory and IO are on the tranZPUter board, 64K block 4 selected.
            when "11100" =>
                DISABLE_BUSn        <= '0';
                ENABLE_BUSn         <= '1';
                Z80_HI_ADDR(18 downto 15) <= "100" & Z80_ADDR(15);
                RAM_CSni            <= '0';
                RAM_OEni            <= Z80_RDn;
                RAM_WEni            <= Z80_WRn;

            -- Set 29 - All memory and IO are on the tranZPUter board, 64K block 5 selected.                
            when "11101" =>
                DISABLE_BUSn        <= '0';
                ENABLE_BUSn         <= '1';
                Z80_HI_ADDR(18 downto 15) <= "101" & Z80_ADDR(15);
                RAM_CSni            <= '0';
                RAM_OEni            <= Z80_RDn;
                RAM_WEni            <= Z80_WRn;

            -- Set 30 - All memory and IO are on the tranZPUter board, 64K block 6 selected.
            when "11110" =>
                DISABLE_BUSn        <= '0';
                ENABLE_BUSn         <= '1';
                Z80_HI_ADDR(18 downto 15) <= "110" & Z80_ADDR(15);
                RAM_CSni            <= '0';
                RAM_OEni            <= Z80_RDn;
                RAM_WEni            <= Z80_WRn;

            -- Set 31 - All memory and IO are on the tranZPUter board, 64K block 7 selected.
            when "11111" =>
                DISABLE_BUSn        <= '0';
                ENABLE_BUSn         <= '1';
                Z80_HI_ADDR(18 downto 15) <= "111" & Z80_ADDR(15);
                RAM_CSni            <= '0';
                RAM_OEni            <= Z80_RDn;
                RAM_WEni            <= Z80_WRn;

            when others =>
        end case;

        -- If the non-standard case of Z80 RD and Z80 WR being set low occurs, enable the ENABLE_BUS signal as the K64F is requesting access to the MZ80A motherboard.
        if(Z80_RDn = '0' and Z80_WRn = '0' and Z80_MREQn = '1' and Z80_IORQn = '1') then
            DISABLE_BUSn        <= '0';
            ENABLE_BUSn         <= '1';
            RAM_OEni            <= '1';
            RAM_CSni            <= '1';
            RAM_WEni            <= '1';
        end if;

        -- Defaults for IO operations, can be overriden for a specific set but should be present in all other sets.
        if((Z80_WRn = '0' or Z80_RDn = '0') and Z80_IORQn = '0') then

            -- If the address is within configured IO control register range, activate the IODECODE signal.
            if(unsigned(Z80_ADDR(7 downto 0)) >= X"60" and unsigned(Z80_ADDR(7 downto 0)) < X"79") then

                if(unsigned(MEM_MODE_LATCH(4 downto 0)) >= 10 and unsigned(MEM_MODE_LATCH(4 downto 0)) < 15) then
                    DISABLE_BUSn<= '1';
                    ENABLE_BUSn <= '1';
                else
                    DISABLE_BUSn<= '0';
                    ENABLE_BUSn <= '1';
                end if;

            elsif(unsigned(Z80_ADDR(7 downto 0)) >= X"E0" and unsigned(Z80_ADDR(7 downto 0)) < X"EF") then
                    DISABLE_BUSn<= '0';
                    ENABLE_BUSn <= '1';
            else
                DISABLE_BUSn    <= '1';
                ENABLE_BUSn     <= '0';
            end if;
        end if;
    end process;

    -- Assign the RAM select signals to their external pins.
    RAM_CSn   <= RAM_CSni;
    RAM_OEn   <= RAM_OEni;
    RAM_WEn   <= RAM_WEni;

    -- For the video card, additional address lines are needed to address the banked video memory. The CPLD is acting as a buffer for these lines.
    VADDR     <= Z80_ADDR(13 downto 11) when Z80_BUSACKn = '1'
                 else (others => 'Z');
    VMEM_CSn  <= '0' when unsigned(Z80_ADDR(15 downto 0)) >= X"E000" and unsigned(Z80_ADDR(15 downto 0)) <= X"FFFF" and Z80_MREQn = '0' and Z80_RFSHn = '1'
                 else '1';


end architecture;
