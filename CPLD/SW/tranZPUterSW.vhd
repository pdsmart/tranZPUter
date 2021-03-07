--------------------------------------------------------------------------------------------------------
--
-- Name:            tranZPUterSW.vhd
-- Created:         June 2020
-- Author(s):       Philip Smart
-- Description:     tranZPUter SW v2.1 - v2.2 CPLD logic definition file.
--                  This module contains the definition of the logic used in v1.0-v1.1 of the tranZPUterSW
--                  project plus enhancements.
--
-- Credits:         
-- Copyright:       (c) 2018-20 Philip Smart <philip.smart@net2net.org>
--
-- History:         June 2020 - Initial creation.
--                  July 2020 - Updated and fixed logic, removed the MZ80B compatibility logic as there
--                              are not enough resources in the CPLD to fully implement.
--                  July 2020 - Changed the keyboard mapping logic to be more compatible. A full swepp 
--                              is made if a read is made to the keyboard data twice in a row as this
--                              signifies a game or program reading BREAK. When the software scans the
--                              keyboard the data is stored into a matrix which is then used for mapping
--                              of the keys.  When the running software accesses the keyboard it reads
--                              from the key matrix and not the PPI. This allows for better compatibility
--                              and a functioning SHIFT+BREAK key. The MZ80A keyboard layout is mapped
--                              as though the keyboard was a real MZ700 keyboard, ie. BREAK key is CLR/HOME
--                              and INST/DEL is CTRL etc. The numeric keypad on the MZ80A is mapped to the
--                              cursor key layout with 7 and 9 acting as INST/DEL. The function keys are
--                              mapped to 1, 0, 00, . and 3 on the numeric keypad.
--                  July 2020 - Making RFS updates I decided that a basic board (ie. no K64F) which would
--                              be used in conjunction with the RFS board needs a secondary clock, 
--                              more especially for the MZ700 3.58MHz mode. I thus added a 50MHz clock 
--                              onto the output that would normally be driven by a K64F. This output
--                              is then divided down to act as the secondary clock. When a mode switch
--                              is made to MZ700 mode the frequency automatically changes.
--                  Mar 2021  - Updated to enable better compatibility with the Sharp MZ-800.
--                  Mar 2021 -  Better control of the external Asyn BUSRQ/BUSACK was needed, bringing in 
--                              Synchronize with the SW700 development.
--                              the async K64F CTL_BUSRQ into the Z80 clocked domain and adjustment of
--                              mux lines.
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
        Z80_HI_ADDR               : inout std_logic_vector(23 downto 16);                -- Hi address. These are the upper bank bits allowing 512K of address space. They are directly set by the K64F when accessing RAM or FPGA and set by the FPGA according to memory mode.
        Z80_RA_ADDR               : out   std_logic_vector(15 downto 12);                -- Row address - RAM is subdivided into 4K blocks which can be remapped as needed. This is required for the MZ80B emulation where memory changes location according to mode.
        Z80_ADDR                  : inout std_logic_vector(15 downto 0);
        Z80_DATA                  : inout std_logic_vector( 7 downto 0);

        -- Z80 Control signals.
        Z80_BUSRQn                : out   std_logic;
        Z80_BUSACKn               : in    std_logic;
        Z80_INTn                  : inout std_logic;
        Z80_IORQn                 : in    std_logic;
        Z80_MREQn                 : inout std_logic;
        Z80_NMIn                  : inout std_logic;
        Z80_RDn                   : in    std_logic;
        Z80_WRn                   : in    std_logic;
        Z80_RESETn                : in    std_logic;                                     -- NB. The CPLD inverts the GCLRn pin, so active negative on the mainboard, active positive inside the CPLD.
        Z80_HALTn                 : in    std_logic;
        Z80_WAITn                 : out   std_logic;
        Z80_M1n                   : in    std_logic;
        Z80_RFSHn                 : in    std_logic;
        Z80_CLK                   : out   std_logic;

        -- K64F control signals.
        CTL_MBSEL                 : in    std_logic;                                     -- Select mainboard, 1 = mainboard, 0 = tranzputer bus.
        CTL_BUSRQn                : in    std_logic;
        CTL_BUSACKn               : out   std_logic;                                     -- Combined BUSACK signal to the K64F
        CTL_HALTn                 : out   std_logic;
        CTL_M1n                   : out   std_logic;
        CTL_RFSHn                 : out   std_logic;
        CTL_WAITn                 : in    std_logic;
        SVCREQn                   : out   std_logic;

        -- Mainboard signals which are blended with K64F signals to activate corresponding Z80 functionality.
        SYS_BUSACKn               : out   std_logic;
        SYS_BUSRQn                : in    std_logic;
        SYS_WAITn                 : in    std_logic;
        SYS_WRn                   : out   std_logic;
        SYS_RDn                   : out   std_logic;    

        -- RAM control.
        RAM_CSn                   : out   std_logic;
        RAM_OEn                   : out   std_logic;
        RAM_WEn                   : out   std_logic;

        -- Graphics Board I/O and Memory Select.
        INCLK                     : in    std_logic;
        OUTDATA                   : out   std_logic_vector(3 downto 0);

        -- Clocks, system and K64F generated.
        SYSCLK                    : in    std_logic;                                     -- Mainboard system clock.
        CTLCLK                    : in    std_logic                                      -- K64F generated secondary CPU clock.
    );
end entity;

architecture rtl of cpld512 is

    -- Definition of a keyboard mapping matrix as an array of registers. The host keyboard is
    -- read into the matrix and the output is mapped according to the target.
    --
    type KeyMatrixType is array(natural range 0 to 9) of std_logic_vector(7 downto 0);

    -- Keyboard mapping signals
    signal KEY_MATRIX             :       KeyMatrixType;
    signal KEY_DATA               :       std_logic_vector(7 downto 0);
    signal KEY_STROBE             :       std_logic_vector(3 downto 0);
    signal KEY_STROBE_LAST        :       std_logic_vector(3 downto 0);
    signal KEY_SUBSTITUTE         :       std_logic;
    signal KEY_SWEEP              :       std_logic;
    signal MB_KEY_STROBE          :       std_logic_vector(3 downto 0);
    signal MB_WRITE_STROBE        :       std_logic;
    signal MB_READ_KEYS           :       std_logic;

    -- CPLD configuration signals.
    signal MODE_CPLD_MZ80K        :       std_logic;
    signal MODE_CPLD_MZ80C        :       std_logic;
    signal MODE_CPLD_MZ1200       :       std_logic;
    signal MODE_CPLD_MZ80A        :       std_logic;
    signal MODE_CPLD_MZ700        :       std_logic;
    signal MODE_CPLD_MZ800        :       std_logic;
    signal MODE_CPLD_MZ80B        :       std_logic;
    signal MODE_CPLD_MZ2000       :       std_logic;
    signal MODE_CPLD_SWITCH       :       std_logic;
    signal MODE_CPLD_MB_VIDEOn    :       std_logic;                                     -- Mainboard video, 0 = enabled, 1 = disabled. 
    signal CPLD_CFG_DATA          :       std_logic_vector(7 downto 0);                  -- CPLD Configuration register.
    signal CPLD_INFO_DATA         :       std_logic_vector(7 downto 0);                  -- CPLD status value.
    signal VIDEOMODULE_PRESENT    :       std_logic;                                     -- Automatic flag which is set if the serializer becomes active.

    -- IO Decode signals.
    signal CS_IO_6XXn             :       std_logic;                                     -- IO decode for the 0x60-0x6f region used by the CPLD.
    signal CS_MEM_CFGn            :       std_logic;                                     -- Select for the memory mode latch.
    signal CS_SCK_CTLCLKn         :       std_logic;                                     -- Select for setting the K64F clock as the active Z80 clock.
    signal CS_SCK_SYSCLKn         :       std_logic;                                     -- Select for setting the Mainboard clock as the active Z80 clock.
    signal CS_SCK_RDn             :       std_logic;                                     -- Select to read which clock is active.
    signal CS_CPLD_CFGn           :       std_logic;                                     -- Select to set the CPLD configuration register.
    signal CS_CPLD_INFOn          :       std_logic;                                     -- Select to read the CPLD information register.
    signal CS_VIDEOn              :       std_logic;                                     -- Primary select of the FPGA video logic, used to enable control signals in the memory management process.
    signal CS_VIDEO_MEMn          :       std_logic;                                     -- Select to read/write video memory according to mode.
    signal CS_VIDEO_IOn           :       std_logic;                                     -- Select to read/write video IO registers according to mode.
    signal CS_VIDEO_RDn           :       std_logic;                                     -- Select to read video memory and video IO registers according to mode.
    signal CS_VIDEO_WRn           :       std_logic;                                     -- Select to write video memory and video IO registers according to mode.
    signal MEM_MODE_LATCH         :       std_logic_vector(4 downto 0);                  -- Register to store the active memory mode.
    signal MEM_MODE_DATA          :       std_logic_vector(7 downto 0);                  -- Scratch signal to form an 8 bit read of the memory mode register.

    -- SR (LS279) state symbols.
    signal SYSCLK_Q               :       std_logic;
    signal CTLCLK_Q               :       std_logic;
    --
    signal DISABLE_BUSn           :       std_logic;                                     -- Signal to disable access to the mainboard (= 0) via the SYS_BUSACKn signal which tri-states the mainboard logic.
    signal SYS_BUSACKni           :       std_logic := '0';                              -- Signal to hold the current state of the SYS_BUSACKn signal used to activate/tri-state the mainboard logic.

    -- CPU Frequency select logic based on Flip Flops and gates.
    signal SCK_CTLSELn            :       std_logic;
    signal Z80_CLKi               :       std_logic;
    signal CTLCLKi                :       std_logic;
    signal CLK_STATUS_DATA        :       std_logic_vector(7 downto 0);

    -- Video module signals.
    --
    signal VZ80_IORQn             :       std_logic;
    signal OUTBUF                 :       std_logic_vector(3 downto 0);

    -- Video module signal mirrors.
    signal MODE_VIDEO_MZ80A       :       std_logic := '1';                              -- The machine is running in MZ80A mode.
    signal MODE_VIDEO_MZ700       :       std_logic := '0';                              -- The machine is running in MZ700 mode.
    signal MODE_VIDEO_MZ800       :       std_logic := '0';                              -- The machine is running in MZ800 mode.
    signal MODE_VIDEO_MZ80B       :       std_logic := '0';                              -- The machine is running in MZ80B mode.
    signal MODE_VIDEO_MZ80K       :       std_logic := '0';                              -- The machine is running in MZ80K mode.
    signal MODE_VIDEO_MZ80C       :       std_logic := '0';                              -- The machine is running in MZ80C mode.
    signal MODE_VIDEO_MZ1200      :       std_logic := '0';                              -- The machine is running in MZ1200 mode.
    signal MODE_VIDEO_MZ2000      :       std_logic := '0';                              -- The machine is running in MZ2000 mode.
    signal GRAM_PAGE_ENABLE       :       std_logic;                                     -- Graphics mode page enable.
    signal MZ80B_VRAM_HI_ADDR     :       std_logic;                                     -- Video RAM located at D000:FFFF when high.
    signal MZ80B_VRAM_LO_ADDR     :       std_logic;                                     -- Video RAM located at 5000:7FFF when high.
    signal CS_FB_VMn              :       std_logic;                                     -- Chip Select for the Video Mode register.
    signal CS_FB_PAGEn            :       std_logic;                                     -- Chip Select for the Page select register.
    signal CS_IO_DXXn             :       std_logic;                                     -- Chip select for block 00:0F
    signal CS_IO_EXXn             :       std_logic;                                     -- Chip select for block E0:EF
    signal CS_IO_FXXn             :       std_logic;                                     -- Chip select for block F0:FF
    signal CS_80B_PIOn            :       std_logic;                                     -- Chip select for MZ80B PIO when in MZ80B mode.

    -- Z80 Wait Insert generator when I/O ports in region > 0XE0 are accessed to give the K64F time to proces them.
  --signal REQ_WAITn            :       std_logic;

    -- Internal control signals.
    signal Z80_HI_ADDRi           :       std_logic_vector(23 downto 16);                -- Hi address. These are the upper bank bits allowing 512K of address space. They are directly set by the K64F when accessing RAM or FPGA and set by the FPGA according to memory mode.
    signal Z80_RA_ADDRi           :       std_logic_vector(15 downto 12);                -- Row address - RAM is subdivided into 4K blocks which can be remapped as needed. This is required for the MZ80B emulation where memory changes location according to mode.
    signal CTL_BUSACKni           :       std_logic;                                     -- Buffered BUSACK signal to the K64F to indicate it has control of the bus.
    signal CTL_BUSRQni            :       std_logic;                                     -- Buffered BUSRQ signal. 

    -- RAM select and write signals.
    signal RAM_OEni               :       std_logic;
    signal RAM_CSni               :       std_logic;
    signal RAM_WEni               :       std_logic;

    -- Mainboard writeback multiplexing signals.
    signal MB_MREQn               :       std_logic;
    signal MB_BUSRQn              :       std_logic;
    signal MB_ADDR                :       std_logic_vector(15 downto 0);
    signal MB_DELAY_TICKS         :       unsigned(11 downto 0);
    signal MB_DELAY_MS            :       unsigned(7 downto 0);
    signal MB_STATE               :       integer range 0 to 7;
    signal MB_WAITn               :       std_logic;

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
    -- The mode can be changed by a Z80 transaction write into the register and it is acted upon if the mode switches between differing values. The Z80 write is typically used
    -- by host software such as RFS.
    --
    -- [2:0] - R/W - Mode/emulated machine.
    --               000 = MZ-80K
    --               001 = MZ-80C
    --               010 = MZ-1200
    --               011 = MZ-80A
    --               100 = MZ-700
    --               101 = MZ-800
    --               110 = MZ-80B
    --               111 = MZ-2000
    -- [3]   - R/W - Mainboard Video - 0 = Enable, 1 = Disable - This flag allows Z-80 transactions in the range D000:DFFF to be directed to the mainboard. When disabled all transactions
    --                                 can only be seen by the FPGA video logic. The FPGA uses this flag to enable/disable it's functionality.
    --*[4]   - R/W - Enable WAIT state during frame display period. 1 = Enable, 0 = Disable (default). The flag enables Z80 WAIT assertion during the frame display period. Most video modes
    --                                 use double buffering so this isnt needed, but use of direct writes to the frame buffer in 8 colour mode (ie. 640x200 or 320x200 8 colour) there
    --                                 is not enough memory to double buffer so potentially there could be tear or snow, hence this optional wait generator.
    -- [6:5] - R/W - Mainboard/CPU clock.
    --               000 = Sharp MZ80A 2MHz System Clock.
    --               001 = Sharp MZ80B 4MHz System Clock.
    --               010 = Sharp MZ700 3.54MHz System Clock.
    --               011 -111 = Reserved, defaults to 2MHz System Clock.
    --*[7]   - R/W - Preserve configuration over reset (=1) or set to default on reset (=0).
    -- * = SW700 v1.3 only, not used in other CPLD versions.
    --
    MACHINEMODE: process( Z80_CLKi, Z80_RESETn, CS_CPLD_CFGn, CPLD_CFG_DATA, CS_CPLD_INFOn, Z80_DATA )
    begin

        if(Z80_RESETn = '0') then
            MODE_CPLD_SWITCH          <= '0';
            if CPLD_CFG_DATA(7) = '0' then
                if CPLD_HOST_HW = MODE_MZ800 then
                    CPLD_CFG_DATA             <= "10001101";                            -- Enable Sharp MZ-800 host setting, mainboard video unused, wait state unused.
                else -- Default to MZ-80A
                    CPLD_CFG_DATA             <= "10000011";                            -- Default to Sharp MZ80A
                end if;
            end if;

        elsif(rising_edge(Z80_CLKi)) then

            -- Write to config register.
            if(CS_CPLD_CFGn = '0' and Z80_WRn = '0') then

                -- Set the mode switch event flag if the mode changes.
                if CPLD_CFG_DATA(2 downto 0) /= Z80_DATA(2 downto 0) then
                    MODE_CPLD_SWITCH  <= '1';
                end if;

                -- Store the new value into the register, used for read operations.
                CPLD_CFG_DATA         <= Z80_DATA;
            else
                MODE_CPLD_SWITCH      <= '0';
            end if;
        end if;
    end process;

    -- Memory mode latch. This latch stores the current memory mode (or Bank Paging Scheme) according to the running software.
    --
    MEMORYMODE: process( Z80_CLKi, Z80_RESETn, CS_MEM_CFGn, Z80_IORQn, Z80_WRn, Z80_ADDR, Z80_DATA )
        variable mz700_LOWER_RAM      : std_logic;
        variable mz700_UPPER_RAM      : std_logic;
        variable mz700_INHIBIT        : std_logic;
    begin

        if(Z80_RESETn = '0') then
            MEM_MODE_LATCH            <= "00000";
            mz700_LOWER_RAM           := '0';
            mz700_UPPER_RAM           := '0';
            mz700_INHIBIT             := '0';

        elsif (CS_MEM_CFGn = '0' and Z80_WRn = '0') then
            MEM_MODE_LATCH          <= Z80_DATA(4 downto 0);

        elsif(Z80_CLKi'event and Z80_CLKi = '1') then

            -- Check for MZ700 Mode memory changes and adjust current memory mode setting.
            if(MODE_CPLD_MZ700 = '1' and Z80_IORQn = '0' and Z80_M1n = '1' and Z80_ADDR(7 downto 3) = "11100") then
                
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
    -- Currently the host can be a Sharp MZ-80A or MZ-800. Target (emulated) machines will be mapped accordingly.
    -- will appear as the target keyboard.
    USEKEYMAPPER: if CPLD_HOST_HW = MODE_MZ80A generate

        KEYMAPPER: process( Z80_CLKi, Z80_RESETn, CS_MEM_CFGn, Z80_IORQn, Z80_ADDR, Z80_DATA )
        begin

            if Z80_RESETn = '0' then
                KEY_SUBSTITUTE          <= '0';
                KEY_SWEEP               <= '0';
                MB_STATE                <= 0;
                MB_BUSRQn               <= '1';
                MB_MREQn                <= '1';
                MB_WRITE_STROBE         <= '0';
                MB_READ_KEYS            <= '0';
                MB_WAITn                <= '1';
                MB_ADDR                 <= (others => '0');
                MB_DELAY_TICKS          <= (others => '1');
                MB_DELAY_MS             <= (others => '0');
                MB_KEY_STROBE           <= (others => '0');
                KEY_STROBE              <= (others => '0');
                KEY_STROBE_LAST         <= (others => '0');

            elsif Z80_CLKi'event and Z80_CLKi = '1' then

                -- When inactive, wait for a Z80 I/O transaction that needs writeback.
                --
                if CPLD_HOST_HW = MODE_MZ80A and MODE_CPLD_MZ700 = '1' then

                    -- Auto scanning state machine. When the MZ700 isnt scanning the keys this FSM scans them to be ready
                    -- to respond to events such as BREAK key detection. Normally the FSM wont run as the MZ700 scans the keys in
                    -- software but when the MZ700 runs some kinds of software the scans stop and occasionally the BREAK/SHIFT line 9 is scanned.
                    -- Under these circumstances the FSM will make a full sweep of the keys.
                    --
                    -- Configurable delay, a tick by tick timer and a millisecond timer, halts all actions whilst the timer > 0.
                    if MB_DELAY_TICKS /= 0 or MB_DELAY_MS /= 0 then

                        if MB_DELAY_TICKS = 0 and MB_DELAY_MS /= 0 then
                            MB_DELAY_TICKS          <= X"DFC";                       -- 1ms with a 3.58MHz clock.
                            MB_DELAY_MS             <= MB_DELAY_MS - 1;
                        else
                            MB_DELAY_TICKS          <= MB_DELAY_TICKS - 1;
                        end if;

                    -- If the Z80 Bus has not been requested and we need to make a key sweep, request the bus and start the sweep.
                    elsif Z80_MREQn = '1' and MB_BUSRQn = '1' and MB_WAITn = '1' and KEY_SWEEP = '1' and KEY_SUBSTITUTE = '0' then
                        MB_BUSRQn       <= '0';

                    -- When the Z80 bus is available, run the FSM.
                    elsif MB_BUSRQn = '0' and Z80_BUSACKn = '0' then

                        -- Move along the state machine, next state can be overriden if required.
                        --
                        if MB_STATE = 6 then
                            MB_STATE                <= 0;
                        else
                            MB_STATE                <= MB_STATE+1;
                        end if;

                        -- FSM.
                        case MB_STATE is
                            -- Setup to write the strobe value to PPI A.
                            when 0 =>
                                MB_ADDR             <= X"E000";
                                KEY_DATA            <= "1111" & MB_KEY_STROBE;
        
                            -- Allow at least 1 cycles for the MREQ signal to settle.
                            when 1 =>
                                MB_MREQn            <= '0';

                            -- Allow at least 1 cycle for the write pulse.
                            when 2 =>
                                MB_WRITE_STROBE     <= '1';
        
                            -- Terminate write pulse.
                            when 3 =>
                                MB_MREQn            <= '1';
                                MB_WRITE_STROBE     <= '0';
        
                            -- Setup for a read of the key data from PPI B.
                            when 4 =>
                                MB_ADDR             <= X"E001";
        
                            -- Allow at least 2 cycles for the data to become available.
                            when 5 =>
                                MB_MREQn            <= '0';
                                MB_READ_KEYS        <= '1';
        
                            -- Read the key data into the matrix for later mapping.
                            when 6 =>
                                KEY_MATRIX(to_integer(unsigned(MB_KEY_STROBE))) <= Z80_DATA;
                                MB_MREQn            <= '1';
                                MB_READ_KEYS        <= '0';
        
                                if unsigned(MB_KEY_STROBE) = 9 then
                                    MB_KEY_STROBE   <= (others => '0');
                                    MB_DELAY_MS     <= X"FA";                     -- 250ms delay between key sweeps with a 3.58MHz clock to prevent excessive scanning.
                                    KEY_SWEEP       <= '0';
                                    MB_BUSRQn       <= '1';
                                else
                                    MB_KEY_STROBE   <= MB_KEY_STROBE + 1;
                                    MB_BUSRQn       <= '1';
                                end if;
        
                            when others =>
                                MB_STATE            <= 0;
                        end case;
                    end if;

                    -- When the Z80 isnt tri-stated process the memory operations and act on required triggers.
                    --
                    if MB_BUSRQn = '1' and Z80_BUSACKn = '1' then
                        -- Detect a strobe output write and store it - this is used as the index into the key matrix for each read operation.
                        if(Z80_MREQn = '0' and Z80_ADDR(15 downto 0) = X"E000" and Z80_DATA(7) = '1') then
                            KEY_STROBE              <= Z80_DATA(3 downto 0);
                        end if;

                        -- On a keyscan read data into the matrix and raise the substitue flag. This flag will disable the mainboard (tri-state it) so that the data lines are not driven. The mapped
                        -- data is then output on the data bus by the CPLD which the Z80 reads.
                        if(Z80_MREQn = '0' and Z80_ADDR(15 downto 0) = X"E001") then

                            -- If this is the first loop, set a 1 cycle wait to allow us to read in the scanned data before overriding with the mapped data. The Z80 cycle is short so without the wait
                            -- we cant reliably read the data being output from the 8255.
                            if MB_WAITn = '1' and KEY_SUBSTITUTE = '0' then
                                MB_WAITn            <= '0';
                                MB_BUSRQn           <= '1'; 
                            else
                                -- 2nd cycle we release the WAIT state and override the data being output by the 8255 with the mapped equivalent.
                                MB_WAITn            <= '1';
                                KEY_SUBSTITUTE      <= '1';

                                -- On the 2nd loop the data from the 8255 key scan has settled on the bus so can be captured.
                                if KEY_SUBSTITUTE = '0' then
                                    KEY_MATRIX(to_integer(unsigned(KEY_STROBE))) <= Z80_DATA;
                                end if;

                                -- Remember last key strobe as we need to detect a scan to the same row more than once, this is typically used for BREAK detection or single key detection.
                                -- In these cases we make an automated sweep of the entire keyboard as keys on the host are spread out on different strobe lines whereas the machine we are mapping to
                                -- has them on one strobe line.
                                KEY_STROBE_LAST <= KEY_STROBE;
                                if KEY_STROBE_LAST = KEY_STROBE and KEY_SWEEP = '0' then
                                    KEY_SWEEP       <= '1';
                                end if;
                            end if;

                            -- Actual keyboard mapping. The Sharp MZ-80A key codes are scanned into a 10x8 matrix and then this matrix is indexed to extract the keycodes for the machine we
                            -- are being compatible with.
                            --
                            -- MZ-80A Keyboard -> MZ-700 mapping.
                            if MODE_CPLD_MZ700 = '1' then
                                case KEY_STROBE is
                                    --                     D7                D6                D5                D4                D3                D2                D1                D0
                                    when "0000" =>
                                        KEY_DATA        <= '1'              & KEY_MATRIX(0)(7) & KEY_MATRIX(7)(4) & KEY_MATRIX(0)(1) & '1'              & KEY_MATRIX(6)(2) & KEY_MATRIX(6)(3) & KEY_MATRIX(7)(3);  -- 1
                                    when "0001" =>
                                        KEY_DATA        <= KEY_MATRIX(3)(5) & KEY_MATRIX(1)(0) & KEY_MATRIX(6)(4) & KEY_MATRIX(6)(5) & KEY_MATRIX(7)(2) & '1'              & '1'              & '1'             ;  -- 2
                                    when "0010" =>
                                        KEY_DATA        <= KEY_MATRIX(1)(4) & KEY_MATRIX(2)(5) & KEY_MATRIX(2)(2) & KEY_MATRIX(3)(4) & KEY_MATRIX(4)(4) & KEY_MATRIX(3)(1) & KEY_MATRIX(1)(5) & KEY_MATRIX(2)(1);  -- 3
                                    when "0011" =>
                                        KEY_DATA        <= KEY_MATRIX(4)(5) & KEY_MATRIX(4)(3) & KEY_MATRIX(5)(2) & KEY_MATRIX(5)(3) & KEY_MATRIX(5)(0) & KEY_MATRIX(4)(1) & KEY_MATRIX(5)(4) & KEY_MATRIX(5)(5);  -- 4
                                    when "0100" =>
                                        KEY_DATA        <= KEY_MATRIX(1)(3) & KEY_MATRIX(3)(0) & KEY_MATRIX(2)(0) & KEY_MATRIX(2)(3) & KEY_MATRIX(2)(4) & KEY_MATRIX(3)(2) & KEY_MATRIX(3)(3) & KEY_MATRIX(4)(2);  -- 5
                                    when "0101" =>
                                        KEY_DATA        <= KEY_MATRIX(1)(6) & KEY_MATRIX(1)(7) & KEY_MATRIX(2)(6) & KEY_MATRIX(2)(7) & KEY_MATRIX(3)(6) & KEY_MATRIX(3)(7) & KEY_MATRIX(4)(6) & KEY_MATRIX(4)(7);  -- 6
                                    when "0110" =>
                                        KEY_DATA        <= KEY_MATRIX(7)(6) & KEY_MATRIX(6)(7) & KEY_MATRIX(6)(6) & KEY_MATRIX(4)(0) & KEY_MATRIX(5)(7) & KEY_MATRIX(5)(6) & KEY_MATRIX(5)(1) & KEY_MATRIX(6)(0);  -- 7
                                    when "0111" =>
                                        KEY_DATA        <= KEY_MATRIX(8)(6) & KEY_MATRIX(9)(6) & KEY_MATRIX(8)(7) & KEY_MATRIX(8)(3) & KEY_MATRIX(9)(4) & KEY_MATRIX(8)(4) & KEY_MATRIX(7)(0) & KEY_MATRIX(6)(1);  -- 8
                                    when "1000" =>
                                        KEY_DATA        <= KEY_MATRIX(7)(7) & KEY_MATRIX(1)(2) & '1'              & '1'              & '1'              & '1'             & '1'               & KEY_MATRIX(0)(0);  -- 9
                                    when "1001" =>
                                        KEY_DATA        <= KEY_MATRIX(8)(2) & KEY_MATRIX(8)(0) & KEY_MATRIX(8)(1) & KEY_MATRIX(9)(0) & KEY_MATRIX(9)(2) & '1'             & '1'               & '1'             ;  -- 10
                                    when others =>
                                        KEY_DATA        <= "11111111";
                                end case;
                            end if;
                        end if;

                        -- When the Z80_MREQn goes inactive, the keyboard read has completed so clear the substitute flag which in turn allows normal bus operations.
                        --
                        if(KEY_SUBSTITUTE = '1' and Z80_MREQn = '1') then
                            KEY_SUBSTITUTE          <= '0';
                        end if;
                    end if;
                else
                    -- Standard mode we dont use the MB logic so set to default.
                    MB_BUSRQn           <= '1';
                    MB_STATE            <= 0;
                end if;
            end if;
        end process;
    else generate
        KEY_SUBSTITUTE          <= '0';
        MB_BUSRQn               <= '1';
        MB_MREQn                <= '1';
        MB_WRITE_STROBE         <= '0';
        MB_READ_KEYS            <= '0';
        MB_WAITn                <= '1';
        MB_ADDR                 <= (others => '0');
        KEY_DATA                <= (others => '0');
    end generate;


    -- Secondary clock source. If the K64F processor is installed, then use its clock output as the secondary clock as it is more finely programmable. If the K64F
    -- is not available, use the onboard oscillator.
    --
    CTLCLKSRC: if USE_K64F_CTL_CLOCK = 1 generate
        CTLCLKi                <= CTLCLK;
    else generate
        process(Z80_RESETn, CTLCLK)
            variable FREQDIVCTR : unsigned(3 downto 0);
        begin
            if Z80_RESETn = '0' then
                FREQDIVCTR     := (others => '0');
                CTLCLKi        <= '0';

            elsif CTLCLK'event and CTLCLK = '1' then

                FREQDIVCTR     := FREQDIVCTR + 1;

                -- MZ700 => 3.58MHz, MZ80A => 12.5MHz
                if (FREQDIVCTR = 7 and MODE_CPLD_MZ700 = '1') or (FREQDIVCTR = 2 and MODE_CPLD_MZ80A = '1') then
                    CTLCLKi    <= not CTLCLKi;
                    FREQDIVCTR := (others => '0');
                end if;
            end if;
        end process;
    end generate;

    -- D type Flip Flops used for the CPU frequency switching circuit. The changeover of frequencies occurs on the high level, the output clock remaining
    -- high until the falling edge of the clock being switched into.
    FFCLK1: process( SYSCLK, Z80_RESETn ) begin
        if Z80_RESETn = '0' then
            SYSCLK_Q           <= '0';

        -- If the system clock goes active high, process the inputs and set the D-type output.
        elsif( rising_edge(SYSCLK) ) then
            if ((DISABLE_BUSn = '1' or MB_BUSRQn = '0' or SCK_CTLSELn = '1') and CTLCLK_Q = '1') then
                SYSCLK_Q       <= '0';
            else
                SYSCLK_Q       <= '1';
            end if;
        end if;
    end process;
    FFCLK2: process( CTLCLKi, Z80_RESETn ) begin
        if Z80_RESETn = '0' then
            CTLCLK_Q           <= '1';

        -- If the control clock goes active high, process the inputs and set the D-type output.
        elsif( rising_edge(CTLCLKi) ) then
            if ((DISABLE_BUSn = '0' and SCK_CTLSELn = '0') and SYSCLK_Q = '1') then
                CTLCLK_Q       <= '0';
            else
                CTLCLK_Q       <= '1';
            end if;
        end if;
    end process;

    -- Mainboard Clock Select S-R latch 3.
    MBCLKSEL: process(Z80_CLKi, CS_SCK_SYSCLKn, CS_SCK_CTLCLKn, Z80_RESETn)
    begin
        if Z80_RESETn = '0' then
            SCK_CTLSELn        <= '1';
        elsif (Z80_CLKi='1' and Z80_CLKi'event) then
            if CS_SCK_SYSCLKn = '0'    or (MODE_CPLD_SWITCH = '1' and MODE_CPLD_MZ80A = '1') then
                SCK_CTLSELn    <= '1';
            elsif CS_SCK_CTLCLKn = '0' or (MODE_CPLD_SWITCH = '1' and MODE_CPLD_MZ700 = '1') then
                SCK_CTLSELn    <= '0';
            else
                null;
            end if;
        end if;
    end process;

    -- A Video Module signal serializer. Signals required by the Video Module but not accessible physically (without hardware hacks) are captured and serialised as a set of x 4 blocks, clocked by the video module,
    -- Reset synchronises the Video Module CPLD with the tranZPUter CPLD and the signals are sent during valid mainboard accesses.
    --
    MZ80ASERIALISER: if CPLD_HOST_HW = MODE_MZ80A generate
        SIGNALSERIALIZER: process(INCLK, Z80_RESETn)
            variable XMIT_CYCLE             : integer range 0 to 1;
        begin
            if Z80_RESETn = '0' then
                XMIT_CYCLE                  := 0;
                VIDEOMODULE_PRESENT         <= '0';

            elsif (INCLK='1' and INCLK'event) then

                -- Tight loop, sending current signal status on each clock. There are 16 signals to send and 4 data lines, so we need 4 cycles per data set.
                case XMIT_CYCLE is
                    when 0 =>
                        -- If we are accessing the mainboard then send across a valid signal set else mark it as invalid.
                        --
                        if SYSCLK_Q = '0' then
                            OUTDATA(3 downto 0) <= Z80_ADDR(14 downto 11);
                            OUTBUF              <= VZ80_IORQn & CS_VIDEO_WRn & CS_VIDEO_RDn & Z80_ADDR(15);
                        else
                            OUTDATA(3 downto 0) <= (others => '0');
                            OUTBUF              <= (others => '0');
                        end if;
                        XMIT_CYCLE              := 1;

                    when 1 =>
                        -- Double check, if we started with a valid mainboard cycle but the clock switched, or we started with an invalid mainboard
                        -- cycle and the clock switched to mainboard, then invalidate this cycle, otherwise send the final signals as captured at the 
                        -- start of the cycle.
                        if SYSCLK_Q = '0' and OUTBUF(3 downto 1) /= "000" then
                            OUTDATA(3 downto 0) <= OUTBUF(3 downto 0);
                        else
                            OUTDATA(3 downto 0) <= (others => '0');
                        end if;
                        VIDEOMODULE_PRESENT     <= '1';
                        XMIT_CYCLE              := 0;
                end case;
            end if;
        end process;

        -- Read from memory and IO devices within the FPGA.
        CS_VIDEO_RDn          <= '0'            when (CS_VIDEO_MEMn = '0' or CS_VIDEO_IOn = '0') and Z80_RDn = '0'
                                 else '1';

        -- Write to memory and IO devices within the FPGA. Duplicate the transaction to the FPGA for CPLD register writes 0x60:0x6F so that the FPGA can register current settings.
        CS_VIDEO_WRn          <= '0'            when (CS_VIDEO_MEMn = '0' or CS_VIDEO_IOn = '0' or CS_IO_EXXn = '0' or CS_IO_6XXn = '0') and Z80_WRn = '0'
                                 else '1';

        -- Pass through the addres and control signals to the FPGA.
        VZ80_IORQn            <= '0'            when Z80_IORQn = '0' and (Z80_RDn = '0' or Z80_WRn = '0')
                                 else '1';
    else generate
        VIDEOMODULE_PRESENT   <= '0';
        OUTDATA               <= (others => '0');
    end generate;

    -- Control Registers - This mirrors the Video Module control registers as we need to know when video memory is to be mapped into main memory.
    --
    -- IO Range for Graphics enhancements is set by the Video Mode registers at 0xF8->.
    --   0xF8=<val> sets the mode that of the Video Module. [2:0] - 000 (default) = MZ80A, 001 = MZ-700, 010 = MZ800, 011 = MZ80B, 100 = MZ80K, 101 = MZ80C, 110 = MZ1200, 111 = MZ2000.
    --   0xFD=<val> memory page register. [1:0] switches in 1 16Kb page (3 pages) of graphics ram to C000 - FFFF. Bits [1:0] = page, 00 = off, 01 = Red, 10 = Green, 11 = Blue.
    --
    CTRLREGISTERS: process( Z80_RESETn, Z80_CLKi, GRAM_PAGE_ENABLE, MZ80B_VRAM_HI_ADDR, MZ80B_VRAM_LO_ADDR )
    begin
        -- Ensure default values at reset.
        if Z80_RESETn = '0' then
            if CPLD_HOST_HW = MODE_MZ80A then
                MODE_VIDEO_MZ80A  <= '1';
            else
                MODE_VIDEO_MZ80A  <= '0';
            end if;
            MODE_VIDEO_MZ700      <= '0';
            if CPLD_HOST_HW = MODE_MZ800 then
                MODE_VIDEO_MZ800  <= '1';
            else 
                MODE_VIDEO_MZ800  <= '0';
            end if;
            MODE_VIDEO_MZ80B      <= '0';
            MODE_VIDEO_MZ80K      <= '0';
            MODE_VIDEO_MZ80C      <= '0';
            MODE_VIDEO_MZ1200     <= '0';
            MODE_VIDEO_MZ2000     <= '0';
            GRAM_PAGE_ENABLE      <= '0';
            MZ80B_VRAM_HI_ADDR    <= '0';
            MZ80B_VRAM_LO_ADDR    <= '0';
    
        elsif rising_edge(Z80_CLKi) then

            -- Setup the machine mode.
            if CS_FB_VMn = '0' and Z80_WRn = '0' then
                MODE_VIDEO_MZ80K  <= '0';
                MODE_VIDEO_MZ80C  <= '0';
                MODE_VIDEO_MZ1200 <= '0';
                MODE_VIDEO_MZ80A  <= '0';
                MODE_VIDEO_MZ700  <= '0';
                MODE_VIDEO_MZ800  <= '0';
                MODE_VIDEO_MZ80B  <= '0';
                MODE_VIDEO_MZ2000 <= '0';

                -- Bits [2:0] define the machine compatibility.
                --
                case to_integer(unsigned(Z80_DATA(2 downto 0))) is
                    when MODE_MZ80K =>
                        MODE_VIDEO_MZ80K  <= '1';
                    when MODE_MZ80C =>
                        MODE_VIDEO_MZ80C  <= '1';
                    when MODE_MZ1200 =>
                        MODE_VIDEO_MZ1200 <= '1';
                    when MODE_MZ80A =>
                        MODE_VIDEO_MZ80A  <= '1';
                    when MODE_MZ700 =>
                        MODE_VIDEO_MZ700  <= '1';
                    when MODE_MZ800 =>
                        MODE_VIDEO_MZ800  <= '1';
                    when MODE_MZ80B =>
                        MODE_VIDEO_MZ80B  <= '1';
                    when MODE_MZ2000 =>
                        MODE_VIDEO_MZ2000 <= '1';
                    when others =>
                end case;
            end if;

            -- memory page register. [1:0] switches in 16Kb page (1 of 3 pages) of graphics ram to C000 - FFFF. Bits [0] = page, 0 = Off, 1 = Enabled. This overrides all MZ700/MZ80B page switching functions. [7] 0 - normal, 1 - switches in CGROM for upload at D000:DFFF.
            if CS_FB_PAGEn = '0' and Z80_WRn = '0' then
                GRAM_PAGE_ENABLE          <= Z80_DATA(0);
            end if;

            -- MZ80B Z80 PIO.
            if CS_80B_PIOn = '0' and MODE_VIDEO_MZ80B = '1' and Z80_WRn = '0' then

                -- Write to PIO A.
                -- 7 = Assigns addresses $DOOO-$FFFF to V-RAM.
                -- 6 = Assigns addresses $5000-$7FFF to V-RAM.
                -- 5 = Changes screen to 80-character mode (L: 40-character mode).
                if Z80_ADDR(1 downto 0) = "00" then
                    MZ80B_VRAM_HI_ADDR    <= Z80_DATA(7);
                    MZ80B_VRAM_LO_ADDR    <= Z80_DATA(6);
                end if;
            end if;
        end if;
    end process;


    -- Memory decoding, taken directly from the definitions coded into the flashcfg tool in v1.1. The CPLD adds greater flexibility and mapping down to the byte level where needed.
    --
    -- Memory Modes:     0 - Default, normal Sharp MZ80A operating mode, all memory and IO (except tranZPUter control IO block) are on the mainboard
    --                   1 - As 0 except User ROM is mapped to tranZPUter RAM.
    --                   2 - TZFS, Monitor ROM 0000-0FFF, Main DRAM 0x1000-0xD000, User/Floppy ROM E800-FFFF are in tranZPUter memory. Two small holes of 2 bytes at F3FE and F7FE exist
    --                       for the Floppy disk controller, the fdc uses the rom as a wait detection by toggling the ROM lines according to WAIT, the Z80 at 2MHz hasnt enough ooomph to read WAIT and action it. 
    --                       NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
    --                   3 - TZFS, Monitor ROM 0000-0FFF, Main RAM area 0x1000-0xD000, User ROM 0xE800-EFFF are in tranZPUter memory block 0, Floppy ROM F000-FFFF are in tranZPUter memory block 1.
    --                       NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
    --                   4 - TZFS, Monitor ROM 0000-0FFF, Main RAM area 0x1000-0xD000, User ROM 0xE800-EFFF are in tranZPUter memory block 0, Floppy ROM F000-FFFF are in tranZPUter memory block 2.
    --                       NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
    --                   5 - TZFS, Monitor ROM 0000-0FFF, Main RAM area 0x1000-0xD000, User ROM 0xE800-EFFF are in tranZPUter memory block 0, Floppy ROM F000-FFFF are in tranZPUter memory block 3.
    --                       NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
    --                   6 - CPM, all memory on the tranZPUter board, 64K block 4 selected.
    --                       Special case for F3FE:F3FF & F7FE:F7FF (floppy disk paging vectors) which resides on the mainboard.
    --                   7 - CPM, F000-FFFF are on the tranZPUter board in block 4, 0040-CFFF and E800-EFFF are in block 5 selected, mainboard for D000-DFFF (video), E000-E800 (Memory control) selected.
    --                       Special case for 0000:00FF (interrupt vectors) which resides in block 4 and CPM vectors and two small holes of 2 bytes at F3FE and F7FE exist for the Floppy disk controller, the fdc
    --                       uses the rom as a wait detection by toggling the ROM lines according to WAIT, the Z80 at 2MHz hasnt enough ooomph to read WAIT and action it. 
    --                   8 - Monitor ROM (0000:0FFF) on mainboard, Main RAM (1000:CFFF) in tranZPUter bank 0 and video, memory mapped I/O, User/Floppy ROM on mainboard.
    --                       NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
    --                  10 - MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 6, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is on the mainboard.
    --                  11 - MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 0, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is on the tranZPUter in block 6.
    --                  12 - MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 6, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is on the tranZPUter in block 6.
    --                  13 - MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 0, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is inaccessible.
    --                  14 - MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 6, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is inaccessible.
    --                  21 - Access the FPGA memory by passing through the full 24bit Z80 address, typically from the K64F.
    --                  22 - Access to the host mainboard 64K address space only.
    --                  23 - Access all memory and IO on the tranZPUter board with the K64F addressing the full 512K RAM.
    --                  24 - All memory and IO are on the tranZPUter board, 64K block 0 selected.
    --                  25 - All memory and IO are on the tranZPUter board, 64K block 1 selected.
    --                  26 - All memory and IO are on the tranZPUter board, 64K block 2 selected.
    --                  27 - All memory and IO are on the tranZPUter board, 64K block 3 selected.
    --                  28 - All memory and IO are on the tranZPUter board, 64K block 4 selected.
    --                  29 - All memory and IO are on the tranZPUter board, 64K block 5 selected.
    --                  30 - All memory and IO are on the tranZPUter board, 64K block 6 selected.
    --                  31 - All memory and IO are on the tranZPUter board, 64K block 7 selected.
    --
    MEMORYMGMT: process(Z80_ADDR, Z80_WRn, Z80_RDn, Z80_IORQn, Z80_MREQn, Z80_M1n, MEM_MODE_LATCH, SYS_BUSACKni, CS_VIDEOn, CS_VIDEO_IOn, CS_IO_DXXn, CS_IO_EXXn, CS_IO_FXXn, CS_CPLD_CFGn, CS_CPLD_INFOn, MODE_CPLD_MB_VIDEOn)
    begin

        -- Memory action according to the configured memory mode. Not synchronous as we need to detect and act on address or signals long before a rising edge.
        --
        case to_integer(unsigned(MEM_MODE_LATCH(4 downto 0))) is

            -- Set 0 - default, no tranZPUter RAM access so hold the DISABLE_BUS signal inactive to ensure the CPU has continuous access to the
            -- mainboard resources, especially for Refresh of DRAM.
            when TZMM_ORIG => 
                Z80_HI_ADDRi        <= "00000000"; 
                Z80_RA_ADDRi        <= Z80_ADDR(15 downto 12);
                RAM_CSni            <= '1';
                RAM_WEni            <= '1';
                RAM_OEni            <= '1';
                CS_VIDEO_MEMn       <= '1';
                if  CS_VIDEOn = '0' then
                    CS_VIDEO_MEMn   <= Z80_MREQn;
                    DISABLE_BUSn    <= '1';
                else
                    DISABLE_BUSn    <= '1';
                end if;

            -- Whenever running in RAM ensure the mainboard is disabled to prevent decoder propagation delay glitches.
            when TZMM_BOOT => 
                RAM_CSni            <= '0';
                CS_VIDEO_MEMn       <= '1';
                Z80_HI_ADDRi        <= "00000000"; 
                Z80_RA_ADDRi        <= Z80_ADDR(15 downto 12);
                if CS_VIDEOn = '0' then
                    DISABLE_BUSn    <= '1';
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                    CS_VIDEO_MEMn   <= Z80_MREQn;

                elsif( unsigned(Z80_ADDR(15 downto 0)) >= X"E800" and unsigned(Z80_ADDR(15 downto 0)) < X"F000") then
                    DISABLE_BUSn    <= '0';
                    RAM_OEni        <= Z80_RDn;
                    if unsigned(Z80_ADDR(15 downto 0)) >= X"EC00" then
                        RAM_WEni    <= Z80_WRn;
                    else
                        RAM_WEni    <= '1';
                    end if;

                else
                    DISABLE_BUSn    <= '1';
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 2 - Monitor ROM 0000-0FFF, Main DRAM 0x1000-0xD000, User/Floppy ROM E800-FFFF are in tranZPUter memory. Two small holes of 2 bytes at F3FE and F7FE exist for the Floppy disk controller, the fdc uses the rom as a wait
            -- detection by toggling the ROM lines according to WAIT, the Z80 at 2MHz hasnt enough ooomph to read WAIT and action it. 
            -- NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
            when TZMM_TZFS => 
                RAM_CSni            <= '0';
                CS_VIDEO_MEMn       <= '1';
                Z80_HI_ADDRi        <= "00000000"; 
                Z80_RA_ADDRi        <= Z80_ADDR(15 downto 12);

                if CS_VIDEOn = '0' then
                    DISABLE_BUSn    <= '1';
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                    CS_VIDEO_MEMn   <= Z80_MREQn;

                elsif( (unsigned(Z80_ADDR(15 downto 0)) >= X"0000" and unsigned(Z80_ADDR(15 downto 0)) < X"D000") or (unsigned(Z80_ADDR(15 downto 0)) >= X"E800" and unsigned(Z80_ADDR(15 downto 0)) <= X"FFFF" and not std_match(Z80_ADDR(15 downto 1), "11110-111111111")) ) then 
                    DISABLE_BUSn    <= '0';
                    RAM_OEni        <= Z80_RDn;
                    if unsigned(Z80_ADDR(15 downto 0)) = X"E800" then
                        RAM_WEni    <= '1';
                    else
                        RAM_WEni    <= Z80_WRn;
                    end if;

                else
                    DISABLE_BUSn    <= '1';
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 3 - Monitor ROM 0000-0FFF, Main RAM area 0x1000-0xD000, User ROM 0xE800-EFFF are in tranZPUter memory block 0, Floppy ROM F000-FFFF are in tranZPUter memory block 1.
            -- NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
            when TZMM_TZFS2 => 
                RAM_CSni            <= '0';
                CS_VIDEO_MEMn       <= '1';

                if CS_VIDEOn = '0' then
                    DISABLE_BUSn    <= '1';
                    Z80_HI_ADDRi    <= "00000000"; 
                    Z80_RA_ADDRi    <= Z80_ADDR(15 downto 12);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                    CS_VIDEO_MEMn   <= Z80_MREQn;

                elsif(((unsigned(Z80_ADDR(15 downto 0)) >= X"0000" and unsigned(Z80_ADDR(15 downto 0)) < X"D000") or (unsigned(Z80_ADDR(15 downto 0)) >= X"E800" and unsigned(Z80_ADDR(15 downto 0)) < X"F000"))) then 
                    DISABLE_BUSn    <= '0';
                    Z80_HI_ADDRi    <= "00000000"; 
                    Z80_RA_ADDRi    <= Z80_ADDR(15 downto 12);
                    RAM_OEni        <= Z80_RDn;
                    if unsigned(Z80_ADDR(15 downto 0)) = X"E800" then
                        RAM_WEni    <= '1';
                    else
                        RAM_WEni    <= Z80_WRn;
                    end if;

                elsif (unsigned(Z80_ADDR(15 downto 0)) >= X"F000" and unsigned(Z80_ADDR(15 downto 0)) <= X"FFFF" and not std_match(Z80_ADDR(15 downto 1), "11110-111111111")) then
                    DISABLE_BUSn    <= '0';
                    Z80_HI_ADDRi    <= "00000001"; 
                    Z80_RA_ADDRi    <= Z80_ADDR(15 downto 12);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;

                else
                    DISABLE_BUSn    <= '1';
                    Z80_HI_ADDRi    <= "00000000"; 
                    Z80_RA_ADDRi    <= Z80_ADDR(15 downto 12);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 4 - Monitor ROM 0000-0FFF, Main RAM area 0x1000-0xD000, User ROM 0xE800-EFFF are in tranZPUter memory block 0, Floppy ROM F000-FFFF are in tranZPUter memory block 2.
            -- NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
            when TZMM_TZFS3 => 
                RAM_CSni            <= '0';
                CS_VIDEO_MEMn       <= '1';

                if CS_VIDEOn = '0' then
                    DISABLE_BUSn    <= '1';
                    Z80_HI_ADDRi    <= "00000000"; 
                    Z80_RA_ADDRi    <= Z80_ADDR(15 downto 12);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                    CS_VIDEO_MEMn   <= Z80_MREQn;

                elsif( ((unsigned(Z80_ADDR(15 downto 0)) >= X"0000" and unsigned(Z80_ADDR(15 downto 0)) < X"D000") or (unsigned(Z80_ADDR(15 downto 0)) >= X"E800" and unsigned(Z80_ADDR(15 downto 0)) < X"F000"))) then
                    DISABLE_BUSn    <= '0';
                    Z80_HI_ADDRi    <= "00000000"; 
                    Z80_RA_ADDRi    <= Z80_ADDR(15 downto 12);
                    RAM_OEni        <= Z80_RDn;
                    if unsigned(Z80_ADDR(15 downto 0)) = X"E800" then
                        RAM_WEni    <= '1';
                    else
                        RAM_WEni    <= Z80_WRn;
                    end if;

                elsif((unsigned(Z80_ADDR(15 downto 0)) >= X"F000" and unsigned(Z80_ADDR(15 downto 0)) <= X"FFFF")) then
                    DISABLE_BUSn    <= '0';
                    Z80_HI_ADDRi    <= "00000010"; 
                    Z80_RA_ADDRi    <= Z80_ADDR(15 downto 12);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;

                else
                    DISABLE_BUSn    <= '1';
                    Z80_HI_ADDRi    <= "00000000"; 
                    Z80_RA_ADDRi    <= Z80_ADDR(15 downto 12);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 5 - Monitor ROM 0000-0FFF, Main RAM area 0x1000-0xD000, User ROM 0xE800-EFFF are in tranZPUter memory block 0, Floppy ROM F000-FFFF are in tranZPUter memory block 3.
            -- NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
            when TZMM_TZFS4 => 
                RAM_CSni            <= '0';
                CS_VIDEO_MEMn       <= '1';

                if CS_VIDEOn = '0' then
                    DISABLE_BUSn    <= '1';
                    Z80_HI_ADDRi    <= "00000000"; 
                    Z80_RA_ADDRi    <= Z80_ADDR(15 downto 12);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                    CS_VIDEO_MEMn   <= Z80_MREQn;

                elsif( ((unsigned(Z80_ADDR(15 downto 0)) >= X"0000" and unsigned(Z80_ADDR(15 downto 0)) < X"D000") or (unsigned(Z80_ADDR(15 downto 0)) >= X"E800" and unsigned(Z80_ADDR(15 downto 0)) < X"F000"))) then
                    DISABLE_BUSn    <= '0';
                    Z80_HI_ADDRi    <= "00000000"; 
                    Z80_RA_ADDRi    <= Z80_ADDR(15 downto 12);
                    RAM_OEni        <= Z80_RDn;
                    if unsigned(Z80_ADDR(15 downto 0)) = X"E800" then
                        RAM_WEni    <= '1';
                    else
                        RAM_WEni    <= Z80_WRn;
                    end if;

                elsif((unsigned(Z80_ADDR(15 downto 0)) >= X"F000" and unsigned(Z80_ADDR(15 downto 0)) <= X"FFFF")) then
                    DISABLE_BUSn    <= '0';
                    Z80_HI_ADDRi    <= "00000011"; 
                    Z80_RA_ADDRi    <= Z80_ADDR(15 downto 12);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;

                else
                    DISABLE_BUSn    <= '1';
                    Z80_HI_ADDRi    <= "00000000"; 
                    Z80_RA_ADDRi    <= Z80_ADDR(15 downto 12);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 6 - CPM, all memory on the tranZPUter board, 64K block 4 selected.
            -- Two small holes of 2 bytes at F3FE and F7FE exist for the Floppy disk controller, the fdc uses the rom as a wait detection by toggling the ROM lines according to WAIT, the Z80 at 2MHz hasnt enough ooomph to read WAIT and action it. 
            when TZMM_CPM => 
                RAM_CSni            <= '0';
                CS_VIDEO_MEMn       <= '1';

                if (unsigned(Z80_ADDR(15 downto 0)) >= X"0000" and unsigned(Z80_ADDR(15 downto 0)) <= X"FFFF" and not std_match(Z80_ADDR(15 downto 1), "11110-111111111")) then 
                    DISABLE_BUSn    <= '0';
                    Z80_HI_ADDRi    <= "00000000"; 
                    Z80_RA_ADDRi    <= Z80_ADDR(15 downto 12);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;

                else
                    DISABLE_BUSn    <= '1';
                    Z80_HI_ADDRi    <= "00000000"; 
                    Z80_RA_ADDRi    <= Z80_ADDR(15 downto 12);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 7 - CPM, F000-FFFF are on the tranZPUter board in block 4, 0040-CFFF and E800-EFFF are in block 5 selected, mainboard for D000-DFFF (video), E000-E800 (Memory control) selected.
            -- Special case for 0000:00FF (interrupt vectors) which resides in block 4 and CPM vectors and two small holes of 2 bytes at F3FE and F7FE exist for the Floppy disk controller, the fdc
            -- uses the rom as a wait detection by toggling the ROM lines according to WAIT, the Z80 at 2MHz hasnt enough ooomph to read WAIT and action it. 
            when TZMM_CPM2 => 
                RAM_CSni            <= '0';
                CS_VIDEO_MEMn       <= '1';

                if CS_VIDEOn = '0' then
                    DISABLE_BUSn    <= '1';
                    Z80_HI_ADDRi    <= "00000000"; 
                    Z80_RA_ADDRi    <= Z80_ADDR(15 downto 12);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                    CS_VIDEO_MEMn   <= Z80_MREQn;

                elsif ((unsigned(Z80_ADDR(15 downto 0)) >= X"0000" and unsigned(Z80_ADDR(15 downto 0)) < X"0100") or (unsigned(Z80_ADDR(15 downto 0)) >= X"F000" and unsigned(Z80_ADDR(15 downto 0)) <= X"FFFF" and not std_match(Z80_ADDR(15 downto 1), "11110-111111111"))) then
                    DISABLE_BUSn    <= '0';
                    Z80_HI_ADDRi    <= "00000100"; 
                    Z80_RA_ADDRi    <= Z80_ADDR(15 downto 12);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;

                elsif(((unsigned(Z80_ADDR(15 downto 0)) >= X"0100" and unsigned(Z80_ADDR(15 downto 0)) < X"D000") or (unsigned(Z80_ADDR(15 downto 0)) >= X"E800" and unsigned(Z80_ADDR(15 downto 0)) < X"F000"))) then
                    DISABLE_BUSn    <= '0';
                    Z80_HI_ADDRi    <= "00000101"; 
                    Z80_RA_ADDRi    <= Z80_ADDR(15 downto 12);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;

                else
                    DISABLE_BUSn    <= '1';
                    Z80_HI_ADDRi    <= "00000000"; 
                    Z80_RA_ADDRi    <= Z80_ADDR(15 downto 12);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 8 - Monitor ROM 0000-0FFF on mainboard, Main DRAM 0x1000-0xD000 is in tranZPUter memory. 
            -- NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
            when TZMM_COMPAT => 
                RAM_CSni            <= '0';
                CS_VIDEO_MEMn       <= '1';
                Z80_HI_ADDRi        <= "00000000"; 
                Z80_RA_ADDRi        <= Z80_ADDR(15 downto 12);

                if CS_VIDEOn = '0' then
                    DISABLE_BUSn    <= '1';
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                    CS_VIDEO_MEMn   <= Z80_MREQn;

                elsif((unsigned(Z80_ADDR(15 downto 0)) >= X"1000" and unsigned(Z80_ADDR(15 downto 0)) < X"D000")) then
                    DISABLE_BUSn    <= '0';
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;

                else
                    DISABLE_BUSn    <= '1';
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 10 - MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 6, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is on the mainboard.
            when TZMM_MZ700_0 =>
                RAM_CSni            <= '0';
                CS_VIDEO_MEMn       <= '1';

                if CS_VIDEOn = '0' then
                    DISABLE_BUSn    <= '1';
                    Z80_HI_ADDRi    <= "00000000"; 
                    Z80_RA_ADDRi    <= Z80_ADDR(15 downto 12);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                    CS_VIDEO_MEMn   <= Z80_MREQn;

                elsif(((unsigned(Z80_ADDR(15 downto 0)) >= X"0000" and unsigned(Z80_ADDR(15 downto 0)) < X"1000"))) then
                    DISABLE_BUSn    <= '0';
                    Z80_HI_ADDRi    <= "00000110"; 
                    Z80_RA_ADDRi    <= Z80_ADDR(15 downto 12);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;

                elsif((unsigned(Z80_ADDR(15 downto 0)) >= X"1000" and unsigned(Z80_ADDR(15 downto 0)) < X"D000")) then
                    DISABLE_BUSn    <= '0';
                    Z80_HI_ADDRi    <= "00000000"; 
                    Z80_RA_ADDRi    <= Z80_ADDR(15 downto 12);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;

                else
                    DISABLE_BUSn    <= '1';
                    Z80_HI_ADDRi    <= "00000000"; 
                    Z80_RA_ADDRi    <= Z80_ADDR(15 downto 12);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 11 - MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 0, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is on the tranZPUter in block 6.
            when TZMM_MZ700_1 =>
                RAM_CSni            <= '0';
                CS_VIDEO_MEMn       <= '1';

                if(((unsigned(Z80_ADDR(15 downto 0)) >= X"0000" and unsigned(Z80_ADDR(15 downto 0)) < X"1000"))) then
                    DISABLE_BUSn    <= '0';
                    Z80_HI_ADDRi    <= "00000000"; 
                    Z80_RA_ADDRi    <= Z80_ADDR(15 downto 12);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;

                elsif((unsigned(Z80_ADDR(15 downto 0)) >= X"1000" and unsigned(Z80_ADDR(15 downto 0)) < X"D000")) then
                    DISABLE_BUSn    <= '0';
                    Z80_HI_ADDRi    <= "00000000"; 
                    Z80_RA_ADDRi    <= Z80_ADDR(15 downto 12);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;

                elsif(((unsigned(Z80_ADDR(15 downto 0)) >= X"D000" and unsigned(Z80_ADDR(15 downto 0)) <= X"FFFF"))) then
                    DISABLE_BUSn    <= '0';
                    Z80_HI_ADDRi    <= "00000110"; 
                    Z80_RA_ADDRi    <= Z80_ADDR(15 downto 12);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;

                else
                    DISABLE_BUSn    <= '1';
                    Z80_HI_ADDRi    <= "00000000"; 
                    Z80_RA_ADDRi    <= Z80_ADDR(15 downto 12);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 12 - MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 6, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is on the tranZPUter in block 6.
            when TZMM_MZ700_2 =>
                RAM_CSni            <= '0';
                CS_VIDEO_MEMn       <= '1';

                if(((unsigned(Z80_ADDR(15 downto 0)) >= X"0000" and unsigned(Z80_ADDR(15 downto 0)) < X"1000"))) then
                    DISABLE_BUSn    <= '0';
                    Z80_HI_ADDRi    <= "00000110"; 
                    Z80_RA_ADDRi    <= Z80_ADDR(15 downto 12);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;

                elsif((unsigned(Z80_ADDR(15 downto 0)) >= X"1000" and unsigned(Z80_ADDR(15 downto 0)) < X"D000")) then
                    DISABLE_BUSn    <= '0';
                    Z80_HI_ADDRi    <= "00000000"; 
                    Z80_RA_ADDRi    <= Z80_ADDR(15 downto 12);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;

                elsif(((unsigned(Z80_ADDR(15 downto 0)) >= X"D000" and unsigned(Z80_ADDR(15 downto 0)) <= X"FFFF"))) then
                    DISABLE_BUSn    <= '0';
                    Z80_HI_ADDRi    <= "00000110"; 
                    Z80_RA_ADDRi    <= Z80_ADDR(15 downto 12);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;

                else
                    DISABLE_BUSn    <= '1';
                    Z80_HI_ADDRi    <= "00000000"; 
                    Z80_RA_ADDRi    <= Z80_ADDR(15 downto 12);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 13 - MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 0, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is inaccessible.
            when TZMM_MZ700_3 =>
                RAM_CSni            <= '0';
                CS_VIDEO_MEMn       <= '1';

                if(((unsigned(Z80_ADDR(15 downto 0)) >= X"0000" and unsigned(Z80_ADDR(15 downto 0)) < X"1000"))) then
                    DISABLE_BUSn    <= '0';
                    Z80_HI_ADDRi    <= "00000000"; 
                    Z80_RA_ADDRi    <= Z80_ADDR(15 downto 12);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;

                elsif((unsigned(Z80_ADDR(15 downto 0)) >= X"1000" and unsigned(Z80_ADDR(15 downto 0)) < X"D000")) then
                    DISABLE_BUSn    <= '0';
                    Z80_HI_ADDRi    <= "00000000"; 
                    Z80_RA_ADDRi    <= Z80_ADDR(15 downto 12);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;

                elsif(((unsigned(Z80_ADDR(15 downto 0)) >= X"D000" and unsigned(Z80_ADDR(15 downto 0)) <= X"FFFF"))) then
                    DISABLE_BUSn    <= '1';
                    Z80_HI_ADDRi    <= "00000000"; 
                    Z80_RA_ADDRi    <= Z80_ADDR(15 downto 12);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';

                else
                    DISABLE_BUSn    <= '1';
                    Z80_HI_ADDRi    <= "00000000"; 
                    Z80_RA_ADDRi    <= Z80_ADDR(15 downto 12);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 14 - MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 6, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is inaccessible.
            when TZMM_MZ700_4 =>
                RAM_CSni            <= '0';
                CS_VIDEO_MEMn       <= '1';

                if(((unsigned(Z80_ADDR(15 downto 0)) >= X"0000" and unsigned(Z80_ADDR(15 downto 0)) < X"1000"))) then
                    DISABLE_BUSn    <= '0';
                    Z80_HI_ADDRi    <= "00000110"; 
                    Z80_RA_ADDRi    <= Z80_ADDR(15 downto 12);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;

                elsif((unsigned(Z80_ADDR(15 downto 0)) >= X"1000" and unsigned(Z80_ADDR(15 downto 0)) < X"D000")) then
                    DISABLE_BUSn    <= '0';
                    Z80_HI_ADDRi    <= "00000000"; 
                    Z80_RA_ADDRi    <= Z80_ADDR(15 downto 12);
                    RAM_OEni        <= Z80_RDn;
                    RAM_WEni        <= Z80_WRn;

                elsif(((unsigned(Z80_ADDR(15 downto 0)) >= X"D000" and unsigned(Z80_ADDR(15 downto 0)) <= X"FFFF"))) then
                    DISABLE_BUSn    <= '1';
                    Z80_HI_ADDRi    <= "00000000"; 
                    Z80_RA_ADDRi    <= Z80_ADDR(15 downto 12);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';

                else
                    DISABLE_BUSn    <= '1';
                    Z80_HI_ADDRi    <= "00000000"; 
                    Z80_RA_ADDRi    <= Z80_ADDR(15 downto 12);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 21 - Access the FPGA memory by passing through the full 24bit Z80 address, typically from the K64F.
            when TZMM_FPGA =>
                DISABLE_BUSn        <= '0';
                Z80_RA_ADDRi        <= Z80_ADDR(15 downto 12);
                RAM_CSni            <= '1';
                RAM_WEni            <= '1';
                RAM_OEni            <= '1';
                CS_VIDEO_MEMn       <= '1';

            -- Set 22 - Access to the host mainboard 64K address space.
            when TZMM_TZPUM => 
                Z80_HI_ADDRi        <= "00000000"; 
                Z80_RA_ADDRi        <= Z80_ADDR(15 downto 12);
                RAM_CSni            <= '1';
                RAM_WEni            <= '1';
                RAM_OEni            <= '1';
                CS_VIDEO_MEMn       <= '1';
                DISABLE_BUSn        <= '1';

            -- Set 23 - Access all memory and IO on the tranZPUter board with the K64F addressing the full 512K RAM.
            when TZMM_TZPU =>
                DISABLE_BUSn        <= '0';
                Z80_HI_ADDRi        <= "00000000";                                       -- Hi bits directly driven by external source,
                Z80_RA_ADDRi        <= Z80_ADDR(15 downto 12);
                RAM_CSni            <= '0';
                RAM_OEni            <= Z80_RDn;
                RAM_WEni            <= Z80_WRn;
                CS_VIDEO_MEMn       <= '1';

            -- Set 24 - All memory and IO are on the tranZPUter board, 64K block 0 selected.
            when TZMM_TZPU0 =>
                DISABLE_BUSn        <= '0';
                Z80_HI_ADDRi        <= "00000000"; 
                Z80_RA_ADDRi        <= Z80_ADDR(15 downto 12);
                RAM_CSni            <= '0';
                RAM_OEni            <= Z80_RDn;
                RAM_WEni            <= Z80_WRn;
                CS_VIDEO_MEMn       <= '1';

            -- Set 25 - All memory and IO are on the tranZPUter board, 64K block 1 selected.
            when TZMM_TZPU1 =>
                DISABLE_BUSn        <= '0';
                Z80_HI_ADDRi        <= "00000001"; 
                Z80_RA_ADDRi        <= Z80_ADDR(15 downto 12);
                RAM_CSni            <= '0';
                RAM_OEni            <= Z80_RDn;
                RAM_WEni            <= Z80_WRn;
                CS_VIDEO_MEMn       <= '1';

            -- Set 26 - All memory and IO are on the tranZPUter board, 64K block 2 selected.
            when TZMM_TZPU2 =>
                DISABLE_BUSn        <= '0';
                Z80_HI_ADDRi        <= "00000010"; 
                Z80_RA_ADDRi        <= Z80_ADDR(15 downto 12);
                RAM_CSni            <= '0';
                RAM_OEni            <= Z80_RDn;
                RAM_WEni            <= Z80_WRn;
                CS_VIDEO_MEMn       <= '1';

            -- Set 27 - All memory and IO are on the tranZPUter board, 64K block 3 selected.
            when TZMM_TZPU3 =>
                DISABLE_BUSn        <= '0';
                Z80_HI_ADDRi        <= "00000011"; 
                Z80_RA_ADDRi        <= Z80_ADDR(15 downto 12);
                RAM_CSni            <= '0';
                RAM_OEni            <= Z80_RDn;
                RAM_WEni            <= Z80_WRn;
                CS_VIDEO_MEMn       <= '1';

            -- Set 28 - All memory and IO are on the tranZPUter board, 64K block 4 selected.
            when TZMM_TZPU4 =>
                DISABLE_BUSn        <= '0';
                Z80_HI_ADDRi        <= "00000100"; 
                Z80_RA_ADDRi        <= Z80_ADDR(15 downto 12);
                RAM_CSni            <= '0';
                RAM_OEni            <= Z80_RDn;
                RAM_WEni            <= Z80_WRn;
                CS_VIDEO_MEMn       <= '1';

            -- Set 29 - All memory and IO are on the tranZPUter board, 64K block 5 selected.                
            when TZMM_TZPU5 =>
                DISABLE_BUSn        <= '0';
                Z80_HI_ADDRi        <= "00000101"; 
                Z80_RA_ADDRi        <= Z80_ADDR(15 downto 12);
                RAM_CSni            <= '0';
                RAM_OEni            <= Z80_RDn;
                RAM_WEni            <= Z80_WRn;
                CS_VIDEO_MEMn       <= '1';

            -- Set 30 - All memory and IO are on the tranZPUter board, 64K block 6 selected.
            when TZMM_TZPU6 =>
                DISABLE_BUSn        <= '0';
                Z80_HI_ADDRi        <= "00000110"; 
                Z80_RA_ADDRi        <= Z80_ADDR(15 downto 12);
                RAM_CSni            <= '0';
                RAM_OEni            <= Z80_RDn;
                RAM_WEni            <= Z80_WRn;
                CS_VIDEO_MEMn       <= '1';

            -- Set 31 - All memory and IO are on the tranZPUter board, 64K block 7 selected.
            when TZMM_TZPU7 =>
                DISABLE_BUSn        <= '0';
                Z80_HI_ADDRi        <= "00000111"; 
                Z80_RA_ADDRi        <= Z80_ADDR(15 downto 12);
                RAM_CSni            <= '0';
                RAM_OEni            <= Z80_RDn;
                RAM_WEni            <= Z80_WRn;
                CS_VIDEO_MEMn       <= '1';

            -- Uncoded modes default to the original machine settings.
            when others =>
                Z80_HI_ADDRi        <= "00000000"; 
                Z80_RA_ADDRi        <= Z80_ADDR(15 downto 12);
                RAM_CSni            <= '1';
                RAM_WEni            <= '1';
                RAM_OEni            <= '1';
                CS_VIDEO_MEMn       <= '1';
                if  CS_VIDEOn = '0' then
                    CS_VIDEO_MEMn   <= Z80_MREQn;
                    DISABLE_BUSn    <= '0';

                else
                    DISABLE_BUSn    <= '1';
                end if;
        end case;

        -- Defaults for IO operations, can be overriden for a specific set but should be present in all other sets.
        if((Z80_WRn = '0' or Z80_RDn = '0') and Z80_IORQn = '0') then

            -- If the address is within configured IO control register range within the CPLD, disable the mainboard.
            if(unsigned(Z80_ADDR(7 downto 0)) >= X"60" and unsigned(Z80_ADDR(7 downto 0)) <= X"6D") then
                DISABLE_BUSn        <= '0';

            -- CPLD Writes need to be echoed to the Video Module if present.
            elsif(unsigned(Z80_ADDR(7 downto 0)) >= X"6D" and unsigned(Z80_ADDR(7 downto 0)) <= X"6F") and Z80_WRn = '1' then
                DISABLE_BUSn        <= '1';

            -- Select for the video IO registers.
            -- If the address is within configured IO control register range within the FPGA (when enabled) then leave the mainboard enabled as data flows via the mainboard
            -- to the FPGA..
            elsif MODE_CPLD_MB_VIDEOn = '1' and (CS_IO_DXXn = '0' or CS_IO_FXXn = '0') then
                DISABLE_BUSn        <= '1';
                CS_VIDEO_IOn        <= Z80_IORQn;

            -- Only allow I/O operations to pass through to the mainboard when not processed by the CPLD or enabled FPGA.
            else
                DISABLE_BUSn        <= '1';
            end if;
        else
            CS_VIDEO_IOn            <= '1';
        end if;
    end process;

    -- A process to bring the external K64F control signals into this domain. The K64F can request the bus asynchronously so it is important the system state is known before
    -- passing the request onto the internal processes.
    --
    SIGNALSYNC: process( Z80_CLKi, Z80_RESETn, CTL_BUSRQn )
    begin

        if(Z80_RESETn = '0') then
            CTL_BUSRQni               <= '1';

        elsif rising_edge(Z80_CLKi) then
            -- When a Bus request comes in, ensure that the state is idle before passing it on as this signal is used to enable/disable or mux control other signals.
            if CTL_BUSRQn = '0' then
                CTL_BUSRQni          <= '0';
            end if;
            if CTL_BUSRQn = '1' then
                CTL_BUSRQni          <= '1';
            end if;
        end if;
    end process;

    -- Clock frequency switching. Depending on the state of the flip flops either the system (mainboard) clocks is selected (default and selected when accessing
    -- the mainboard) and the programmable frequency generated by the K64F timers.
    Z80_CLKi              <= (SYSCLK or SYSCLK_Q) and (CTLCLKi or CTLCLK_Q);
    Z80_CLK               <= Z80_CLKi;

    -- Wait states, added by the video circuitry or the K64F.
    Z80_WAITn             <= '0'                         when SYS_WAITn = '0' or CTL_WAITn = '0' or MB_WAITn = '0'
                             else '1';

    -- Z80 signals passed to the mainboard, if the K64F has control of the bus then the Z80 signals are disabled as they are not tri-stated during a BUSRQ state.
    CTL_M1n               <= Z80_M1n                     when Z80_BUSACKn = '1'
                             else 'Z';
    CTL_RFSHn             <= Z80_RFSHn                   when Z80_BUSACKn = '1'
                             else 'Z';
    CTL_HALTn             <= Z80_HALTn                   when Z80_BUSACKn = '1'
                             else 'Z';
 
    -- Bus control logic, SYS_BUSACKni directly controls the mainboard tri-state buffers, enabling will disable the mainboard.
    SYS_BUSACKni          <= '0'                         when DISABLE_BUSn = '0'        or  (KEY_SUBSTITUTE = '1' and Z80_MREQn = '0') or (Z80_BUSACKn = '0' and CTL_MBSEL = '0') 
                             else '1';
    SYS_BUSACKn           <= SYS_BUSACKni;
    Z80_BUSRQn            <= '0'                         when SYS_BUSRQn = '0'          or  CTL_BUSRQni = '0'      or MB_BUSRQn = '0'
                             else '1';

    -- Acknowlegde to the K64F it has bus control.
    CTL_BUSACKni          <= '0'                         when CTL_BUSRQni = '0'         and Z80_BUSACKn = '0' 
                             else '1';
    CTL_BUSACKn           <= CTL_BUSACKni;

    -- Register read values.
    CLK_STATUS_DATA       <= "0000000" & SYSCLK_Q;
    MEM_MODE_DATA         <= "000" & MEM_MODE_LATCH(4 downto 0);

    -- CPLD information register.
    -- [2:0] - R/O - Physical hardware.
    --               000 = MZ-80K
    --               001 = MZ-80C
    --               010 = MZ-1200
    --               011 = MZ-80A
    --               100 = MZ-700
    --               101 = MZ-800
    --               110 = MZ-80B
    --               111 = MZ-2000
    -- [3]     R/O - FPGA Video Capable, 1 = FPGA Video capable, 0 = no FPGA.
    -- [7:5]   R/O - CPLD Version number, 0..7
    --    
    CPLD_INFO_DATA        <= std_logic_vector(to_unsigned(CPLD_VERSION, 3)) & '0' & CPLD_HAS_FPGA_VIDEO & std_logic_vector(to_unsigned(CPLD_HOST_HW, 3));

    --
    -- Data Bus Multiplexing, plex the output devices onto the Z80 data bus.
    --
    Z80_DATA              <= CPLD_CFG_DATA               when CS_CPLD_CFGn = '0'   and Z80_RDn = '0'                               -- Read current register settings.
                             else
                             CPLD_INFO_DATA              when CS_CPLD_INFOn = '0'  and Z80_RDn = '0'                               -- Read version & hw build information.
                             else
                             CLK_STATUS_DATA             when CS_SCK_RDn = '0'     and Z80_RDn = '0'                               -- Read the clock select status.
                             else 
                             MEM_MODE_DATA               when CS_MEM_CFGn = '0'    and Z80_RDn = '0'                               -- Read the memory mode latch.
                             else
                             KEY_DATA                    when MB_BUSRQn = '1'      and Z80_BUSACKn = '1' and KEY_SUBSTITUTE = '1' and Z80_MREQn = '0'  -- Read mapped keyboard data.
                             else
                             (others => 'Z')             when Z80_BUSACKn = '0'    and CTL_BUSACKni = '0'                          -- Tristate bus when Z80 tristated and the K64F is requesting all devices to tristate.
                             else
                             (others => 'Z');                                                                                      -- Default is to tristate the CPLD data bus output when not being used.
    
    --
    -- Address Bus Multiplexing.
    --
    --
    Z80_HI_ADDR           <= Z80_HI_ADDRi                when CTL_BUSACKni = '1'                                                             -- New addition, pass through the upper address bits directly. K64F directly drives A16-A23 to RAM and into CPLD.
                             else (others => 'Z');
    Z80_RA_ADDR           <= Z80_RA_ADDRi;
    Z80_ADDR              <= MB_ADDR                     when Z80_BUSACKn = '0'    and MB_BUSRQn = '0'
                             else
                             (others => 'Z');

    Z80_MREQn             <= MB_MREQn                    when Z80_BUSACKn = '0'    and MB_BUSRQn = '0'
                             else 'Z';

    Z80_INTn              <= '1'                         when Z80_BUSACKn = '0'    and MB_BUSRQn = '0'
                             else 'Z';

    Z80_NMIn              <= '1'                         when Z80_BUSACKn = '0'    and MB_BUSRQn = '0'
                             else 'Z';

                              -- Writes to standard video memory are blocked from the system board. This is because the actual write is sent to the Video Module via the serializer.
    SYS_WRn                <= '0'                        when MB_MREQn = '0'       and Z80_BUSACKn = '0' and (MB_WRITE_STROBE = '1')  -- and (write1 or write2...) signals active here
                              else
                              '1'                        when Z80_BUSACKn = '0'    and MB_BUSRQn = '0'
                              else 
                              Z80_WRn;
                              -- Reads from standard video memory are blocked from the system board. This is because the actual read is requested via the Video Module using the serializer and the Video Module puts the required data onto the data bus.
    SYS_RDn                <= '0'                        when MB_MREQn = '0'       and Z80_BUSACKn = '0' and (MB_READ_KEYS = '1')  -- and (read1 or read2...) signals active here
                              else
                              '1'                        when Z80_BUSACKn = '0'    and MB_BUSRQn = '0'
                              else
                              Z80_RDn;
        
    -- The tranZPUter SW board adds upgrades for the Z80 processor and host. These upgrades are controlled through an IO port which 
    -- in v1.0 - v1.1 was either at 0x2-=0x2f, 0x60-0x6f, 0xA0-0xAf, 0xF0-0xFF, the default being 0x60. This logic mimcs the 74HCT138 and
    -- FlashRAM decoder which produces the I/O port select signals.
    --
    CS_IO_6XXn            <= '0'                         when Z80_IORQn = '0'      and Z80_M1n = '1' and Z80_ADDR(7 downto 4) = "0110"
                              else '1';
    CS_MEM_CFGn           <= '0'                         when CS_IO_6XXn = '0'     and Z80_ADDR(3 downto 1) = "000"                -- IO 60
                              else '1';
    CS_SCK_CTLCLKn        <= '0'                         when CS_IO_6XXn = '0'     and Z80_ADDR(3 downto 1) = "001"                -- IO 62
                              else '1';
    CS_SCK_SYSCLKn        <= '0'                         when CS_IO_6XXn = '0'     and Z80_ADDR(3 downto 1) = "010"                -- IO 64
                              else '1';
    CS_SCK_RDn            <= '0'                         when CS_IO_6XXn = '0'     and Z80_ADDR(3 downto 1) = "011"                -- IO 66
                              else '1';
    SVCREQn               <= '0'                         when CS_IO_6XXn = '0'     and Z80_ADDR(3 downto 1) = "100"                -- IO 68
                              else '1';
    CS_CPLD_CFGn          <= '0'                         when CS_IO_6XXn = '0'     and Z80_ADDR(3 downto 0) = "1110"               -- IO 6E
                              else '1';
    CS_CPLD_INFOn         <= '0'                         when CS_IO_6XXn = '0'     and Z80_ADDR(3 downto 0) = "1111"               -- IO 6F
                              else '1';

    -- Assign the RAM select signals to their external pins.
    RAM_CSn               <= RAM_CSni;
    RAM_OEn               <= RAM_OEni                    when Z80_MREQn = '0'
                             else '1';
    RAM_WEn               <= RAM_WEni                    when Z80_MREQn = '0'
                             else '1';

    -- I/O Control signals to read and update the current video parameters, mainly used for setting FPGA access.
    CS_IO_DXXn            <= '0'                         when Z80_IORQn = '0'      and Z80_M1n = '1' and Z80_ADDR(7 downto 4) = "1101"
                              else '1';
    -- I/O Control signals, mainly used for mirroring of the video module registers.
    CS_IO_EXXn            <= '0'                         when Z80_IORQn = '0'      and Z80_M1n = '1' and Z80_ADDR(7 downto 4) = "1110"
                              else '1';
    CS_IO_FXXn            <= '0'                         when Z80_IORQn = '0'      and Z80_M1n = '1' and Z80_ADDR(7 downto 4) = "1111"
                              else '1';
    -- 0xF8 set the video mode. [2:0] = mode, 000 = MZ80A, 001 = MZ-700, 010 = MZ-80B, 011 = MZ-800, 111 = Pixel graphics.
    CS_FB_VMn             <= '0'                         when CS_IO_FXXn = '0'     and Z80_ADDR(3 downto 0) = "1000"
                              else '1';
    -- 0xFD set the Video memory page in block C000:FFFF bit 0, set the CGROM upload access in bit 7.
    CS_FB_PAGEn           <= '0'                         when CS_IO_FXXn = '0'     and Z80_ADDR(3 downto 0) = "1101"
                              else '1';
    -- MZ80B/MZ2000 I/O Registers E0-EB,
    CS_80B_PIOn           <= '0'                         when CS_IO_EXXn = '0'     and Z80_ADDR(3 downto 2) = "10" and MODE_VIDEO_MZ80B = '1'
                              else '1';

    -- Select for video based on the memory being accessed, the mode and control signals.
                             -- Standard access to VRAM/ARAM. Video memory based IO registers in region E000:E2FF are enabled so that the FPGA can set its internal mirrored values but FPGA to block read operations as it will affect mainboard reads from keyboard etc.
    CS_VIDEOn             <= '0'                         when MODE_CPLD_MB_VIDEOn = '1' and GRAM_PAGE_ENABLE = '0'  and MODE_VIDEO_MZ80B = '0' and unsigned(Z80_ADDR(15 downto 0)) >= X"D000" and unsigned(Z80_ADDR(15 downto 0)) < X"E300"
                             else
                             -- Graphics RAM enabled, range C000:FFFF is mapped to graphics RAM.
                             '0'                         when MODE_CPLD_MB_VIDEOn = '1' and GRAM_PAGE_ENABLE = '1' and unsigned(Z80_ADDR(15 downto 0)) >= X"C000" and unsigned(Z80_ADDR(15 downto 0)) <= X"FFFF"
                             else
                             -- MZ80B Graphics RAM enabled, range E000:FFFF is mapped to graphics RAMI + II and D000:DFFF to standard video.
                             '0'                         when MODE_CPLD_MB_VIDEOn = '1' and GRAM_PAGE_ENABLE = '0'  and MODE_VIDEO_MZ80B = '1' and MZ80B_VRAM_HI_ADDR = '1' and unsigned(Z80_ADDR(15 downto 0)) >= X"D000" and unsigned(Z80_ADDR(15 downto 0)) <= X"FFFF"
                             else
                             -- MZ80B Graphics RAM enabled, range 6000:7FFF is mapped to graphics RAMI + II and 5000:5FFF to standard video.
                             '0'                         when MODE_CPLD_MB_VIDEOn = '1' and GRAM_PAGE_ENABLE = '0'  and MODE_VIDEO_MZ80B = '1' and MZ80B_VRAM_LO_ADDR = '1' and unsigned(Z80_ADDR(15 downto 0)) >= X"5000" and unsigned(Z80_ADDR(15 downto 0)) <= X"7FFF"
                             else '1';



    -- Set the mainboard video state, 0 = enabled, 1 = disabled. The flag is set if the CPLD Config register Bit 3 is set or if the Serializer
    -- becomes active which means a Video Module is connected.
    MODE_CPLD_MB_VIDEOn   <= '1'                         when CPLD_CFG_DATA(3) = '1' or VIDEOMODULE_PRESENT = '1'
                             else '0';
    -- Set CPLD mode flag according to value given in config 2:0 
    MODE_CPLD_MZ80K       <= '1'                         when to_integer(unsigned(CPLD_CFG_DATA(2 downto 0))) = MODE_MZ80K
                             else '0';
    MODE_CPLD_MZ80C       <= '1'                         when to_integer(unsigned(CPLD_CFG_DATA(2 downto 0))) = MODE_MZ80C
                             else '0';
    MODE_CPLD_MZ1200      <= '1'                         when to_integer(unsigned(CPLD_CFG_DATA(2 downto 0))) = MODE_MZ1200
                             else '0';
    MODE_CPLD_MZ80A       <= '1'                         when to_integer(unsigned(CPLD_CFG_DATA(2 downto 0))) = MODE_MZ80A
                             else '0';
    MODE_CPLD_MZ700       <= '1'                         when to_integer(unsigned(CPLD_CFG_DATA(2 downto 0))) = MODE_MZ700
                             else '0';
    MODE_CPLD_MZ800       <= '1'                         when to_integer(unsigned(CPLD_CFG_DATA(2 downto 0))) = MODE_MZ800
                             else '0';
    MODE_CPLD_MZ80B       <= '1'                         when to_integer(unsigned(CPLD_CFG_DATA(2 downto 0))) = MODE_MZ80B
                             else '0';
    MODE_CPLD_MZ2000      <= '1'                         when to_integer(unsigned(CPLD_CFG_DATA(2 downto 0))) = MODE_MZ2000
                             else '0';


    -- Mainboard WAIT State Generator S-R latch 4.
    -- NB: V2.1 design doesnt need the wait state generator as the mapping is done in hardware.
    --
    --MBWAITGEN: process(SYSCLK, Z80_ADDR, Z80_M1n, CTL_BUSRQni, MEM_MODE_LATCH, Z80_IORQn)
    --    variable tmp    : std_logic;
    --    variable iowait : std_logic;
    --begin
    --
    --    -- IO Wait select active when an IO operation is made in range 0xE0-0xFF.
    --    if (Z80_ADDR(7 downto 5) = "111" and Z80_M1n = '1' and CTL_BUSRQni = '1' and MEM_MODE_LATCH(5) = '1' and Z80_IORQn = '0') then
    --        iowait := '0';
    --    else
    --        iowait := '1';
    --    end if;
    --
    --    if(SYSCLK='1' and SYSCLK'event) then
    --        if((CTL_BUSRQni = '1' and Z80_RESETn = '1') and iowait = '1') then
    --            tmp := tmp;
    --        elsif((CTL_BUSRQni = '0' or Z80_RESETn = '0') and iowait = '0') then
    --            tmp := 'Z';
    --        elsif((CTL_BUSRQni = '0' or Z80_RESETn = '0') and iowait = '1') then
    --            tmp := '1';
    --        else
    --            tmp := '0';
    --        end if;
    --    end if;
    --
    --    REQ_WAIT <= tmp;
    --end PROCESS;


end architecture;
