--------------------------------------------------------------------------------------------------------
--
-- Name:            tranZPUterSW700.vhd
-- Created:         June 2020
-- Author(s):       Philip Smart
-- Description:     tranZPUter SW 700 v1.2 CPLD logic definition file.
--                  This module contains the definition of the logic used in v1.0-v1.1 of the tranZPUterSW
--                  project plus enhancements for the MZ700.
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
--                  Oct 2020  - Cut taken from the tranZPUterSW 2.1 to be used for the tranZPUter SW 700
--                              as there are a lot of pin and logic differences. The tranZPUter SW is still
--                              under development so didnt make sense to share the same files and make 
--                              them conditional.
--                  Nov 2020 -  Version 1.3 board needs major changes as the FPGA is now capable of 
--                              supporting soft CPU's, an original target of the tranZPUter project.
--                              The keyboard mapping has been removed as more complex signal switching is
--                              needed and this logic will be placed in the FPGA. The CPLD still remains
--                              the central memory management for both hard and soft CPU's.
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
use work.tranZPUterSW700_pkg.all;

entity cpld512 is
    --generic (
    --);
    port (    
        -- Z80 Address and Data.
        Z80_HI_ADDR               : inout std_logic_vector(18 downto 16);                -- Hi address. These are the upper bank bits allowing 512K of address space. They are directly set by the K64F when accessing RAM or FPGA and set by the FPGA according to memory mode.
        Z80_RA_ADDR               : out   std_logic_vector(15 downto 12);                -- Row address - RAM is subdivided into 4K blocks which can be remapped as needed. This is required for the MZ80B emulation where memory changes location according to mode.
        Z80_ADDR                  : inout std_logic_vector(15 downto 0);
        Z80_DATA                  : inout std_logic_vector( 7 downto 0);

        -- Z80 Control signals.
        Z80_BUSRQn                : out   std_logic;
        Z80_BUSACKn               : in    std_logic;
        Z80_INTn                  : in    std_logic;
        Z80_IORQn                 : inout std_logic;
        Z80_MREQn                 : inout std_logic;
        Z80_NMIn                  : in    std_logic;
        Z80_RDn                   : inout std_logic;
        Z80_WRn                   : inout std_logic;
        Z80_RESETn                : in    std_logic;                                     -- NB. The CPLD inverts the GCLRn pin, so active negative on the mainboard, active positive inside the CPLD.
        Z80_HALTn                 : inout std_logic;
        Z80_WAITn                 : inout std_logic;
        Z80_M1n                   : inout std_logic;
        Z80_RFSHn                 : inout std_logic;
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
        Z80_MEM                   : out   std_logic_vector(4 downto 0);

        -- Mainboard signals which are blended with K64F signals to activate corresponding Z80 functionality.
        SYS_BUSACKn               : out   std_logic;
        SYS_BUSRQn                : in    std_logic;
        SYS_WAITn                 : in    std_logic;

        -- RAM control.
        RAM_CSn                   : out   std_logic;
        RAM_OEn                   : out   std_logic;
        RAM_WEn                   : out   std_logic;

        -- FPGA address, data and control signals.
        VZ80_ADDR                 : inout std_logic_vector(15 downto 0);
        VZ80_DATA                 : inout std_logic_vector(7 downto 0);
        VZ80_MREQn                : inout std_logic;
        VZ80_IORQn                : inout std_logic;
        VZ80_RDn                  : inout std_logic;
        VZ80_WRn                  : inout std_logic;
        VZ80_M1n                  : inout std_logic;
        VZ80_BUSACKn              : in    std_logic;
        VZ80_CLK                  : out   std_logic;
        VIDEO_RDn                 : out   std_logic;
        VIDEO_WRn                 : out   std_logic;

        -- FPGA control signals muxed with Graphics signals from the mainboard.
        VWAITn_V_CSYNC            : inout std_logic;                                     -- Wait signal from asserted when Video RAM is busy / Mainboard Video Composite Sync.
        VZ80_RFSHn_V_HSYNC        : inout std_logic;                                     -- Voltage translated Z80 RFSH / Mainboard Video Horizontal Sync.
        VZ80_HALTn_V_VSYNC        : inout std_logic;                                     -- Voltage translated Z80 HALT / Mainboard Video Vertical Sync.
        VZ80_BUSRQn_V_G           : out   std_logic;                                     -- Voltage translated Z80 BUSRQ / Mainboard Video Green signal.
        VZ80_WAITn_V_B            : out   std_logic;                                     -- Voltage translated Z80 WAIT / Mainboard Video Blue signal.
        VZ80_INTn_V_R             : out   std_logic;                                     -- Voltage translated Z80 INT / Mainboard Video Red signal.
        VZ80_NMIn_V_COLR          : out   std_logic;                                     -- Voltage translated Z80 NMI / Mainboard Video Colour Modulation Frequency.
        CSYNC_IN                  : in    std_logic;                                     -- Mainboard Video Composite Sync.
        HSYNC_IN                  : in    std_logic;                                     -- Mainboard Video Horizontal Sync.
        VSYNC_IN                  : in    std_logic;                                     -- Mainboard Video Vertical Sync.
        G_IN                      : in    std_logic;                                     -- Mainboard Video Green signal.
        B_IN                      : in    std_logic;                                     -- Mainboard Video Blue signal.
        R_IN                      : in    std_logic;                                     -- Mainboard Video Red signal.
        COLR_IN                   : in    std_logic;                                     -- Mainboard Video Colour Modulation Frequency.

        -- Clocks, system and K64F generated.
        SYSCLK                    : in    std_logic;                                     -- Mainboard system clock.
        CTLCLK                    : in    std_logic                                      -- K64F generated secondary CPU clock.
    );
end entity;

architecture rtl of cpld512 is

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
    signal MODE_CPU_SOFT          :       std_logic;                                     -- Soft CPU Enable, 1 = enabled, 0 = disabled. 
    signal MODE_CPLD_VIDEO_WAIT   :       std_logic;                                     -- FPGA video display period wait flag, 1 = enabled, 0 = disabled.
    signal CPU_CFG_DATA           :       std_logic_vector(7 downto 0):=(others => '0'); -- CPU Configuration register.
    signal CPLD_CFG_DATA          :       std_logic_vector(7 downto 0):=(others => '0'); -- CPLD Configuration register.
    signal CPLD_INFO_DATA         :       std_logic_vector(7 downto 0);                  -- CPLD status value.

    -- IO Decode signals.
    signal CS_IO_6XXn             :       std_logic;                                     -- IO decode for the 0x60-0x6f region used by the CPLD.
    signal CS_MEM_CFGn            :       std_logic;                                     -- Select for the memory mode latch.
    signal CS_SCK_CTLCLKn         :       std_logic;                                     -- Select for setting the K64F clock as the active Z80 clock.
    signal CS_SCK_SYSCLKn         :       std_logic;                                     -- Select for setting the Mainboard clock as the active Z80 clock.
    signal CS_SCK_RDn             :       std_logic;                                     -- Select to read which clock is active.
    signal CS_CPU_CFGn            :       std_logic;                                     -- Select to set the CPU configuration register.
    signal CS_CPU_INFOn           :       std_logic;                                     -- Select to read the CPU information register.
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
    signal CS_IO_DXXn             :       std_logic;                                     -- Chip select for block D0:DF
    signal CS_IO_EXXn             :       std_logic;                                     -- Chip select for block E0:EF
    signal CS_IO_FXXn             :       std_logic;                                     -- Chip select for block F0:FF
    signal CS_80B_PIOn            :       std_logic;                                     -- Chip select for MZ80B PIO when in MZ80B mode.

    -- Z80 Wait Insert generator when the video framebuffer is being accessed during rendering.
    signal VWAITn                 :       std_logic;

    -- Internal control signals.
    signal VZ80_BUSRQn            :       std_logic;                                     --
    signal VZ80_RFSHn             :       std_logic;                                     --
    signal VZ80_HALTn             :       std_logic;                                     --
    signal VZ80_A18_INTn          :       std_logic;                                     -- Multi-function, normally INTn to the soft CPU but VZ80_A18 during K64F access.
    signal VZ80_A17_NMIn          :       std_logic;                                     -- Multi-function, normally NMIn to the soft CPU but VZ80_A17 during K64F access.
    signal VZ80_A16_WAITn         :       std_logic;                                     -- Multi-function, normally WAITn to the soft CPU but VZ80_A16 during K64F access.
    signal CPLD_HI_ADDR           :       std_logic_vector(18 downto 16);                -- Tri-state ability on upper address bits.
    signal CPLD_RA_ADDR           :       std_logic_vector(15 downto 12);                -- Address lines 15:12 to the RAM are reconfigurable to allow different memory organisation.
    signal CPLD_ADDR              :       std_logic_vector(15 downto 0);                 --  
    signal CPLD_DATA_IN           :       std_logic_vector(7 downto 0);                  --  
    signal CPLD_DATA_OUT          :       std_logic_vector(7 downto 0);                  --  
    signal CPLD_RDn               :       std_logic;                                     --  
    signal CPLD_WRn               :       std_logic;                                     --  
    signal CPLD_MREQn             :       std_logic;                                     --  
    signal CPLD_IORQn             :       std_logic;                                     --  
    signal CPLD_M1n               :       std_logic;                                     --  
    signal CPLD_RFSHn             :       std_logic;                                     --  
    signal CPLD_HALTn             :       std_logic;                                     --  
    signal CTL_BUSACKni           :       std_logic;                                     --  

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

    -- CPLD/CPU Configuration registers.
    --
    -- CPU:
    -- Version 1.3-> of the tranZPUter SW-700 provides the ability to instantiate alternative soft CPU's. This register configures the FPGA to enable a soft/hard CPU and the CPLD
    -- is reconfigured to allow a CPU operation on the FPGA side rather than the physical hardware side.
    --
    -- [5:0] - R/W - CPU selection.
    --               000000 = Hard CPU
    --               000001 = T80 CPU
    --               000010 = ZPU Evolution
    --               000100 = Future CPU AAA
    --               001000 = Future CPU AAA
    --               010000 = Future CPU AAA
    --               100000 = Future CPU AAA
    --               All other configurations reserved and default to Hard CPU.
    -- [7]   - R/W - CPU Reset. When active ('1'), hold the CPU in reset, when inactive, commence the reset completion and CPU run.
    --
    -- CPLD:
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
    -- [4]   - R/W - Enable WAIT state during frame display period. 1 = Enable, 0 = Disable (default). The flag enables Z80 WAIT assertion during the frame display period. Most video modes
    --                                 use double buffering so this isnt needed, but use of direct writes to the frame buffer in 8 colour mode (ie. 640x200 or 320x200 8 colour) there
    --                                 is not enough memory to double buffer so potentially there could be tear or snow, hence this optional wait generator.
    --
    MACHINEMODE: process( Z80_CLKi, Z80_RESETn, CS_CPU_CFGn, CS_CPLD_CFGn, CPLD_ADDR, CPLD_DATA_IN )
    begin

        if(Z80_RESETn = '0') then
            MODE_CPLD_SWITCH          <= '0';
            CPLD_CFG_DATA             <= "00000100";                             -- Default to Sharp MZ700, mainboard video enabled, wait state off.
            CPU_CFG_DATA(7 downto 6)  <= "00";                                   -- Dont reset soft CPU selection flag on a reset.

        elsif(rising_edge(Z80_CLKi)) then

            -- Write to CPU config register.
            if(CS_CPU_CFGn = '0' and CPLD_WRn = '0') then

                -- Store the new value into the register, used for read operations.
                CPU_CFG_DATA          <= CPLD_DATA_IN;

                -- Check to ensure only one CPU selected, if more than one default to hard CPU. Also check to ensure only instantiated CPU's selected, otherwise default to hard CPU.
                --
                if (unsigned(CPLD_DATA_IN(5 downto 0)) and (unsigned(CPLD_DATA_IN(5 downto 0))-1)) /= 0 or (CPLD_DATA_IN(5 downto 2) and "1111") /= "0000" then
                    CPU_CFG_DATA(5 downto 0) <= (others => '0');
                end if;

            -- Write to CPLD config register.
            elsif(CS_CPLD_CFGn = '0' and CPLD_WRn = '0') then

                -- Set the mode switch event flag if the mode changes.
                if CPLD_CFG_DATA(2 downto 0) /= CPLD_DATA_IN(2 downto 0) then
                    MODE_CPLD_SWITCH  <= '1';
                end if;

                -- Store the new value into the register, used for read operations.
                CPLD_CFG_DATA         <= CPLD_DATA_IN;
            else
                MODE_CPLD_SWITCH      <= '0';
            end if;
        end if;
    end process;

    -- Memory mode latch. This latch stores the current memory mode (or Bank Paging Scheme) according to the running software.
    --
    MEMORYMODE: process( Z80_CLKi, Z80_RESETn, CS_MEM_CFGn, VZ80_MREQn, VZ80_IORQn, VZ80_BUSACKn, CPLD_IORQn, CPLD_WRn, CPLD_ADDR, CPLD_DATA_IN, CPU_CFG_DATA, MODE_CPU_SOFT )
        variable mz700_LOWER_RAM      : std_logic;
        variable mz700_UPPER_RAM      : std_logic;
        variable mz700_INHIBIT        : std_logic;
    begin

        if(Z80_RESETn = '0') then
            -- Initialise memory mode if running on hard cpu, soft cpu remains on current selection.
            MEM_MODE_LATCH            <= "00000";
            mz700_LOWER_RAM           := '0';
            mz700_UPPER_RAM           := '0';
            mz700_INHIBIT             := '0';

        -- Special case for soft CPU's wanting to address the entire 512k RAM or the 64K address space of the mainboard. The MREQn and IORQn are held low and data[7] and data[2:0] indicate required memory access.
        -- data[7] = 1 - Access 64K address space of mainboard. data[7] = 0 - Access 512K RAM with high address bits stored in data[2:0]. These bits are mapped into a memory mode 
        -- and the memory management logic handles any future requests accordingly.
        elsif (VZ80_MREQn = '0' and VZ80_IORQn = '0' and MODE_CPU_SOFT = '1' and VZ80_BUSACKn = '1') then
            if CPLD_DATA_IN(7) = '1' then
                MEM_MODE_LATCH            <= std_logic_vector(to_unsigned(TZMM_TZPUM, 5));
            else
                MEM_MODE_LATCH            <= "11" & CPLD_DATA_IN(2 downto 0);
            end if;

        -- A direct write to the memory latch stores the required memory mode into the latch.
        elsif (CS_MEM_CFGn = '0' and CPLD_WRn = '0') then
            MEM_MODE_LATCH            <= CPLD_DATA_IN(4 downto 0);

        elsif(Z80_CLKi'event and Z80_CLKi = '1') then

            -- Check for MZ700 Mode memory changes and adjust current memory mode setting.
            if(MODE_CPLD_MZ700 = '1' and CPLD_IORQn = '0' and CPLD_M1n = '1' and CPLD_ADDR(7 downto 3) = "11100") then
                
                -- MZ700 memory mode switch?
                --         0x0000:0x0FFF     0xD000:0xFFFF
                -- 0xE0 =  DRAM
                -- 0xE1 =                    DRAM
                -- 0xE2 =  MONITOR
                -- 0xE3 =                    Memory Mapped I/O
                -- 0xE4 =  MONITOR           Memory Mapped I/O
                -- 0xE5 =                    Inhibit
                -- 0xE6 =                    Return to state prior to 0xE5
                case CPLD_ADDR(2 downto 0) is
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
            if ((DISABLE_BUSn = '1' or SCK_CTLSELn = '1') and CTLCLK_Q = '1') then
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
            MODE_VIDEO_MZ80A      <= '0';
            MODE_VIDEO_MZ700      <= '1';
            MODE_VIDEO_MZ800      <= '0';
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
            if CS_FB_VMn = '0' and CPLD_WRn = '0' then
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
                case to_integer(unsigned(CPLD_DATA_IN(2 downto 0))) is
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
            if CS_FB_PAGEn = '0' and CPLD_WRn = '0' then
                GRAM_PAGE_ENABLE          <= CPLD_DATA_IN(0);
            end if;

            -- MZ80B Z80 PIO.
            if CS_80B_PIOn = '0' and MODE_VIDEO_MZ80B = '1' and CPLD_WRn = '0' then

                -- Write to PIO A.
                -- 7 = Assigns addresses $DOOO-$FFFF to V-RAM.
                -- 6 = Assigns addresses $5000-$7FFF to V-RAM.
                -- 5 = Changes screen to 80-character mode (L: 40-character mode).
                if CPLD_ADDR(1 downto 0) = "00" then
                    MZ80B_VRAM_HI_ADDR    <= CPLD_DATA_IN(7);
                    MZ80B_VRAM_LO_ADDR    <= CPLD_DATA_IN(6);
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
    --                  21 - Access the FPGA memory by passing through the full 19bit Z80 address, typically from the K64F.
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
    MEMORYMGMT: process(CPLD_ADDR, CPLD_WRn, CPLD_RDn, CPLD_IORQn, CPLD_MREQn, CPLD_M1n, Z80_HI_ADDR, MEM_MODE_LATCH, SYS_BUSACKni, CS_VIDEOn, CS_VIDEO_IOn, CS_IO_DXXn, CS_IO_EXXn, CS_IO_FXXn, CS_CPU_CFGn, CS_CPU_INFOn, MODE_CPLD_MB_VIDEOn)
    begin

        -- Memory action according to the configured memory mode. Not synchronous as we need to detect and act on address or signals long before a rising edge.
        --
        case to_integer(unsigned(MEM_MODE_LATCH(4 downto 0))) is

            -- Set 0 - default, no tranZPUter RAM access so hold the DISABLE_BUS signal inactive to ensure the CPU has continuous access to the
            -- mainboard resources, especially for Refresh of DRAM.
            when TZMM_ORIG => 
                CPLD_HI_ADDR        <= "000";
                CPLD_RA_ADDR        <= CPLD_ADDR(15 downto 12);
                RAM_CSni            <= '1';
                RAM_WEni            <= '1';
                RAM_OEni            <= '1';
                CS_VIDEO_MEMn       <= '1';
                if  CS_VIDEOn = '0' then
                    CS_VIDEO_MEMn   <= '0'; --CPLD_MREQn;
                    DISABLE_BUSn    <= '0';
                else
                    DISABLE_BUSn    <= '1';
                end if;

            -- Whenever running in RAM ensure the mainboard is disabled to prevent decoder propagation delay glitches.
            when TZMM_BOOT => 
                RAM_CSni            <= '0';
                CS_VIDEO_MEMn       <= '1';
                CPLD_HI_ADDR        <= "000";
                CPLD_RA_ADDR        <= CPLD_ADDR(15 downto 12);
                if CS_VIDEOn = '0' then
                    DISABLE_BUSn    <= '0';
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                    CS_VIDEO_MEMn   <= '0'; --CPLD_MREQn;

                elsif( unsigned(CPLD_ADDR(15 downto 0)) >= X"E800" and unsigned(CPLD_ADDR(15 downto 0)) < X"F000") then
                    DISABLE_BUSn    <= '0';
                    RAM_OEni        <= CPLD_RDn;
                    if unsigned(CPLD_ADDR(15 downto 0)) >= X"EC00" then
                        RAM_WEni    <= CPLD_WRn;
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
                CPLD_HI_ADDR        <= "000";
                CPLD_RA_ADDR        <= CPLD_ADDR(15 downto 12);

                if CS_VIDEOn = '0' then
                    DISABLE_BUSn    <= '0';
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                    CS_VIDEO_MEMn   <= '0'; --CPLD_MREQn;

                elsif( (unsigned(CPLD_ADDR(15 downto 0)) >= X"0000" and unsigned(CPLD_ADDR(15 downto 0)) < X"D000") or (unsigned(CPLD_ADDR(15 downto 0)) >= X"E800" and unsigned(CPLD_ADDR(15 downto 0)) <= X"FFFF" and not std_match(CPLD_ADDR(15 downto 1), "11110-111111111")) ) then 
                    DISABLE_BUSn    <= '0';
                    RAM_OEni        <= CPLD_RDn;
                    if unsigned(CPLD_ADDR(15 downto 0)) = X"E800" then
                        RAM_WEni    <= '1';
                    else
                        RAM_WEni    <= CPLD_WRn;
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
                    DISABLE_BUSn    <= '0';
                    CPLD_HI_ADDR    <= "000";
                    CPLD_RA_ADDR    <= CPLD_ADDR(15 downto 12);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                    CS_VIDEO_MEMn   <= '0'; --CPLD_MREQn;

                elsif(((unsigned(CPLD_ADDR(15 downto 0)) >= X"0000" and unsigned(CPLD_ADDR(15 downto 0)) < X"D000") or (unsigned(CPLD_ADDR(15 downto 0)) >= X"E800" and unsigned(CPLD_ADDR(15 downto 0)) < X"F000"))) then 
                    DISABLE_BUSn    <= '0';
                    CPLD_HI_ADDR    <= "000";
                    CPLD_RA_ADDR    <= CPLD_ADDR(15 downto 12);
                    RAM_OEni        <= CPLD_RDn;
                    if unsigned(CPLD_ADDR(15 downto 0)) = X"E800" then
                        RAM_WEni    <= '1';
                    else
                        RAM_WEni    <= CPLD_WRn;
                    end if;

                elsif (unsigned(CPLD_ADDR(15 downto 0)) >= X"F000" and unsigned(CPLD_ADDR(15 downto 0)) <= X"FFFF" and not std_match(CPLD_ADDR(15 downto 1), "11110-111111111")) then
                    DISABLE_BUSn    <= '0';
                    CPLD_HI_ADDR    <= "001";
                    CPLD_RA_ADDR    <= CPLD_ADDR(15 downto 12);
                    RAM_OEni        <= CPLD_RDn;
                    RAM_WEni        <= CPLD_WRn;

                else
                    DISABLE_BUSn    <= '1';
                    CPLD_HI_ADDR    <= "000";
                    CPLD_RA_ADDR    <= CPLD_ADDR(15 downto 12);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 4 - Monitor ROM 0000-0FFF, Main RAM area 0x1000-0xD000, User ROM 0xE800-EFFF are in tranZPUter memory block 0, Floppy ROM F000-FFFF are in tranZPUter memory block 2.
            -- NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
            when TZMM_TZFS3 => 
                RAM_CSni            <= '0';
                CS_VIDEO_MEMn       <= '1';

                if CS_VIDEOn = '0' then
                    DISABLE_BUSn    <= '0';
                    CPLD_HI_ADDR    <= "000";
                    CPLD_RA_ADDR    <= CPLD_ADDR(15 downto 12);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                    CS_VIDEO_MEMn   <= '0'; --CPLD_MREQn;

                elsif( ((unsigned(CPLD_ADDR(15 downto 0)) >= X"0000" and unsigned(CPLD_ADDR(15 downto 0)) < X"D000") or (unsigned(CPLD_ADDR(15 downto 0)) >= X"E800" and unsigned(CPLD_ADDR(15 downto 0)) < X"F000"))) then
                    DISABLE_BUSn    <= '0';
                    CPLD_HI_ADDR    <= "000";
                    CPLD_RA_ADDR    <= CPLD_ADDR(15 downto 12);
                    RAM_OEni        <= CPLD_RDn;
                    if unsigned(CPLD_ADDR(15 downto 0)) = X"E800" then
                        RAM_WEni    <= '1';
                    else
                        RAM_WEni    <= CPLD_WRn;
                    end if;

                elsif((unsigned(CPLD_ADDR(15 downto 0)) >= X"F000" and unsigned(CPLD_ADDR(15 downto 0)) <= X"FFFF")) then
                    DISABLE_BUSn    <= '0';
                    CPLD_HI_ADDR    <= "010";
                    CPLD_RA_ADDR    <= CPLD_ADDR(15 downto 12);
                    RAM_OEni        <= CPLD_RDn;
                    RAM_WEni        <= CPLD_WRn;

                else
                    DISABLE_BUSn    <= '1';
                    CPLD_HI_ADDR    <= "000";
                    CPLD_RA_ADDR    <= CPLD_ADDR(15 downto 12);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 5 - Monitor ROM 0000-0FFF, Main RAM area 0x1000-0xD000, User ROM 0xE800-EFFF are in tranZPUter memory block 0, Floppy ROM F000-FFFF are in tranZPUter memory block 3.
            -- NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
            when TZMM_TZFS4 => 
                RAM_CSni            <= '0';
                CS_VIDEO_MEMn       <= '1';

                if CS_VIDEOn = '0' then
                    DISABLE_BUSn    <= '0';
                    CPLD_HI_ADDR    <= "000";
                    CPLD_RA_ADDR    <= CPLD_ADDR(15 downto 12);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                    CS_VIDEO_MEMn   <= '0'; --CPLD_MREQn;

                elsif( ((unsigned(CPLD_ADDR(15 downto 0)) >= X"0000" and unsigned(CPLD_ADDR(15 downto 0)) < X"D000") or (unsigned(CPLD_ADDR(15 downto 0)) >= X"E800" and unsigned(CPLD_ADDR(15 downto 0)) < X"F000"))) then
                    DISABLE_BUSn    <= '0';
                    CPLD_HI_ADDR    <= "000";
                    CPLD_RA_ADDR    <= CPLD_ADDR(15 downto 12);
                    RAM_OEni        <= CPLD_RDn;
                    if unsigned(CPLD_ADDR(15 downto 0)) = X"E800" then
                        RAM_WEni    <= '1';
                    else
                        RAM_WEni    <= CPLD_WRn;
                    end if;

                elsif((unsigned(CPLD_ADDR(15 downto 0)) >= X"F000" and unsigned(CPLD_ADDR(15 downto 0)) <= X"FFFF")) then
                    DISABLE_BUSn    <= '0';
                    CPLD_HI_ADDR    <= "011";
                    CPLD_RA_ADDR    <= CPLD_ADDR(15 downto 12);
                    RAM_OEni        <= CPLD_RDn;
                    RAM_WEni        <= CPLD_WRn;

                else
                    DISABLE_BUSn    <= '1';
                    CPLD_HI_ADDR    <= "000";
                    CPLD_RA_ADDR    <= CPLD_ADDR(15 downto 12);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 6 - CPM, all memory on the tranZPUter board, 64K block 4 selected.
            -- Two small holes of 2 bytes at F3FE and F7FE exist for the Floppy disk controller, the fdc uses the rom as a wait detection by toggling the ROM lines according to WAIT, the Z80 at 2MHz hasnt enough ooomph to read WAIT and action it. 
            when TZMM_CPM => 
                RAM_CSni            <= '0';
                CS_VIDEO_MEMn       <= '1';

                if (unsigned(CPLD_ADDR(15 downto 0)) >= X"0000" and unsigned(CPLD_ADDR(15 downto 0)) <= X"FFFF" and not std_match(CPLD_ADDR(15 downto 1), "11110-111111111")) then 
                    DISABLE_BUSn    <= '0';
                    CPLD_HI_ADDR    <= "100";
                    CPLD_RA_ADDR    <= CPLD_ADDR(15 downto 12);
                    RAM_OEni        <= CPLD_RDn;
                    RAM_WEni        <= CPLD_WRn;

                else
                    DISABLE_BUSn    <= '1';
                    CPLD_HI_ADDR    <= "000";
                    CPLD_RA_ADDR    <= CPLD_ADDR(15 downto 12);
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
                    DISABLE_BUSn    <= '0';
                    CPLD_HI_ADDR    <= "000";
                    CPLD_RA_ADDR    <= CPLD_ADDR(15 downto 12);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                    CS_VIDEO_MEMn   <= '0'; --CPLD_MREQn;

                elsif ((unsigned(CPLD_ADDR(15 downto 0)) >= X"0000" and unsigned(CPLD_ADDR(15 downto 0)) < X"0100") or (unsigned(CPLD_ADDR(15 downto 0)) >= X"F000" and unsigned(CPLD_ADDR(15 downto 0)) <= X"FFFF" and not std_match(CPLD_ADDR(15 downto 1), "11110-111111111"))) then
                    DISABLE_BUSn    <= '0';
                    CPLD_HI_ADDR    <= "100";
                    CPLD_RA_ADDR    <= CPLD_ADDR(15 downto 12);
                    RAM_OEni        <= CPLD_RDn;
                    RAM_WEni        <= CPLD_WRn;

                elsif(((unsigned(CPLD_ADDR(15 downto 0)) >= X"0100" and unsigned(CPLD_ADDR(15 downto 0)) < X"D000") or (unsigned(CPLD_ADDR(15 downto 0)) >= X"E800" and unsigned(CPLD_ADDR(15 downto 0)) < X"F000"))) then
                    DISABLE_BUSn    <= '0';
                    CPLD_HI_ADDR    <= "101";
                    CPLD_RA_ADDR    <= CPLD_ADDR(15 downto 12);
                    RAM_OEni        <= CPLD_RDn;
                    RAM_WEni        <= CPLD_WRn;

                else
                    DISABLE_BUSn    <= '1';
                    CPLD_HI_ADDR    <= "000";
                    CPLD_RA_ADDR    <= CPLD_ADDR(15 downto 12);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 8 - Monitor ROM 0000-0FFF on mainboard, Main DRAM 0x1000-0xD000 is in tranZPUter memory. 
            -- NB: Main DRAM will not be refreshed so cannot be used to store data in this mode.
            when TZMM_COMPAT => 
                RAM_CSni            <= '0';
                CS_VIDEO_MEMn       <= '1';
                CPLD_HI_ADDR        <= "000";
                CPLD_RA_ADDR        <= CPLD_ADDR(15 downto 12);

                if CS_VIDEOn = '0' then
                    DISABLE_BUSn    <= '0';
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                    CS_VIDEO_MEMn   <= '0'; --CPLD_MREQn;

                elsif((unsigned(CPLD_ADDR(15 downto 0)) >= X"1000" and unsigned(CPLD_ADDR(15 downto 0)) < X"D000")) then
                    DISABLE_BUSn    <= '0';
                    RAM_OEni        <= CPLD_RDn;
                    RAM_WEni        <= CPLD_WRn;

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
                    DISABLE_BUSn    <= '0';
                    CPLD_HI_ADDR    <= "000";
                    CPLD_RA_ADDR    <= CPLD_ADDR(15 downto 12);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                    CS_VIDEO_MEMn   <= '0'; --CPLD_MREQn;

                elsif(((unsigned(CPLD_ADDR(15 downto 0)) >= X"0000" and unsigned(CPLD_ADDR(15 downto 0)) < X"1000"))) then
                    DISABLE_BUSn    <= '0';
                    CPLD_HI_ADDR    <= "110";
                    CPLD_RA_ADDR    <= CPLD_ADDR(15 downto 12);
                    RAM_OEni        <= CPLD_RDn;
                    RAM_WEni        <= CPLD_WRn;

                elsif((unsigned(CPLD_ADDR(15 downto 0)) >= X"1000" and unsigned(CPLD_ADDR(15 downto 0)) < X"D000")) then
                    DISABLE_BUSn    <= '0';
                    CPLD_HI_ADDR    <= "000";
                    CPLD_RA_ADDR    <= CPLD_ADDR(15 downto 12);
                    RAM_OEni        <= CPLD_RDn;
                    RAM_WEni        <= CPLD_WRn;

                else
                    DISABLE_BUSn    <= '1';
                    CPLD_HI_ADDR    <= "000";
                    CPLD_RA_ADDR    <= CPLD_ADDR(15 downto 12);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 11 - MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 0, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is on the tranZPUter in block 6.
            when TZMM_MZ700_1 =>
                RAM_CSni            <= '0';
                CS_VIDEO_MEMn       <= '1';

                if(((unsigned(CPLD_ADDR(15 downto 0)) >= X"0000" and unsigned(CPLD_ADDR(15 downto 0)) < X"1000"))) then
                    DISABLE_BUSn    <= '0';
                    CPLD_HI_ADDR    <= "000";
                    CPLD_RA_ADDR    <= CPLD_ADDR(15 downto 12);
                    RAM_OEni        <= CPLD_RDn;
                    RAM_WEni        <= CPLD_WRn;

                elsif((unsigned(CPLD_ADDR(15 downto 0)) >= X"1000" and unsigned(CPLD_ADDR(15 downto 0)) < X"D000")) then
                    DISABLE_BUSn    <= '0';
                    CPLD_HI_ADDR    <= "000";
                    CPLD_RA_ADDR    <= CPLD_ADDR(15 downto 12);
                    RAM_OEni        <= CPLD_RDn;
                    RAM_WEni        <= CPLD_WRn;

                elsif(((unsigned(CPLD_ADDR(15 downto 0)) >= X"D000" and unsigned(CPLD_ADDR(15 downto 0)) <= X"FFFF"))) then
                    DISABLE_BUSn    <= '0';
                    CPLD_HI_ADDR    <= "110";
                    CPLD_RA_ADDR    <= CPLD_ADDR(15 downto 12);
                    RAM_OEni        <= CPLD_RDn;
                    RAM_WEni        <= CPLD_WRn;

                else
                    DISABLE_BUSn    <= '1';
                    CPLD_HI_ADDR    <= "000";
                    CPLD_RA_ADDR    <= CPLD_ADDR(15 downto 12);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 12 - MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 6, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is on the tranZPUter in block 6.
            when TZMM_MZ700_2 =>
                RAM_CSni            <= '0';
                CS_VIDEO_MEMn       <= '1';

                if(((unsigned(CPLD_ADDR(15 downto 0)) >= X"0000" and unsigned(CPLD_ADDR(15 downto 0)) < X"1000"))) then
                    DISABLE_BUSn    <= '0';
                    CPLD_HI_ADDR    <= "110";
                    CPLD_RA_ADDR    <= CPLD_ADDR(15 downto 12);
                    RAM_OEni        <= CPLD_RDn;
                    RAM_WEni        <= CPLD_WRn;

                elsif((unsigned(CPLD_ADDR(15 downto 0)) >= X"1000" and unsigned(CPLD_ADDR(15 downto 0)) < X"D000")) then
                    DISABLE_BUSn    <= '0';
                    CPLD_HI_ADDR    <= "000";
                    CPLD_RA_ADDR    <= CPLD_ADDR(15 downto 12);
                    RAM_OEni        <= CPLD_RDn;
                    RAM_WEni        <= CPLD_WRn;

                elsif(((unsigned(CPLD_ADDR(15 downto 0)) >= X"D000" and unsigned(CPLD_ADDR(15 downto 0)) <= X"FFFF"))) then
                    DISABLE_BUSn    <= '0';
                    CPLD_HI_ADDR    <= "110";
                    CPLD_RA_ADDR    <= CPLD_ADDR(15 downto 12);
                    RAM_OEni        <= CPLD_RDn;
                    RAM_WEni        <= CPLD_WRn;

                else
                    DISABLE_BUSn    <= '1';
                    CPLD_HI_ADDR    <= "000";
                    CPLD_RA_ADDR    <= CPLD_ADDR(15 downto 12);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 13 - MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 0, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is inaccessible.
            when TZMM_MZ700_3 =>
                RAM_CSni            <= '0';
                CS_VIDEO_MEMn       <= '1';

                if(((unsigned(CPLD_ADDR(15 downto 0)) >= X"0000" and unsigned(CPLD_ADDR(15 downto 0)) < X"1000"))) then
                    DISABLE_BUSn    <= '0';
                    CPLD_HI_ADDR    <= "000";
                    CPLD_RA_ADDR    <= CPLD_ADDR(15 downto 12);
                    RAM_OEni        <= CPLD_RDn;
                    RAM_WEni        <= CPLD_WRn;

                elsif((unsigned(CPLD_ADDR(15 downto 0)) >= X"1000" and unsigned(CPLD_ADDR(15 downto 0)) < X"D000")) then
                    DISABLE_BUSn    <= '0';
                    CPLD_HI_ADDR    <= "000";
                    CPLD_RA_ADDR    <= CPLD_ADDR(15 downto 12);
                    RAM_OEni        <= CPLD_RDn;
                    RAM_WEni        <= CPLD_WRn;

                elsif(((unsigned(CPLD_ADDR(15 downto 0)) >= X"D000" and unsigned(CPLD_ADDR(15 downto 0)) <= X"FFFF"))) then
                    DISABLE_BUSn    <= '1';
                    CPLD_HI_ADDR    <= "000";
                    CPLD_RA_ADDR    <= CPLD_ADDR(15 downto 12);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';

                else
                    DISABLE_BUSn    <= '1';
                    CPLD_HI_ADDR    <= "000";
                    CPLD_RA_ADDR    <= CPLD_ADDR(15 downto 12);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 14 - MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 6, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is inaccessible.
            when TZMM_MZ700_4 =>
                RAM_CSni            <= '0';
                CS_VIDEO_MEMn       <= '1';

                if(((unsigned(CPLD_ADDR(15 downto 0)) >= X"0000" and unsigned(CPLD_ADDR(15 downto 0)) < X"1000"))) then
                    DISABLE_BUSn    <= '0';
                    CPLD_HI_ADDR    <= "110";
                    CPLD_RA_ADDR    <= CPLD_ADDR(15 downto 12);
                    RAM_OEni        <= CPLD_RDn;
                    RAM_WEni        <= CPLD_WRn;

                elsif((unsigned(CPLD_ADDR(15 downto 0)) >= X"1000" and unsigned(CPLD_ADDR(15 downto 0)) < X"D000")) then
                    DISABLE_BUSn    <= '0';
                    CPLD_HI_ADDR    <= "000";
                    CPLD_RA_ADDR    <= CPLD_ADDR(15 downto 12);
                    RAM_OEni        <= CPLD_RDn;
                    RAM_WEni        <= CPLD_WRn;

                elsif(((unsigned(CPLD_ADDR(15 downto 0)) >= X"D000" and unsigned(CPLD_ADDR(15 downto 0)) <= X"FFFF"))) then
                    DISABLE_BUSn    <= '1';
                    CPLD_HI_ADDR    <= "000";
                    CPLD_RA_ADDR    <= CPLD_ADDR(15 downto 12);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';

                else
                    DISABLE_BUSn    <= '1';
                    CPLD_HI_ADDR    <= "000";
                    CPLD_RA_ADDR    <= CPLD_ADDR(15 downto 12);
                    RAM_WEni        <= '1';
                    RAM_OEni        <= '1';
                end if;

            -- Set 21 - Access the FPGA memory by passing through the full 19bit Z80 address, typically from the K64F.
            when TZMM_FPGA =>
                CPLD_HI_ADDR        <= "000";  -- Hi bits directly driven by external source, ie. K64F in this mode.
                CPLD_RA_ADDR        <= CPLD_ADDR(15 downto 12);
                RAM_CSni            <= '1';
                RAM_WEni            <= '1';
                RAM_OEni            <= '1';
                CS_VIDEO_MEMn       <= '1';
                DISABLE_BUSn        <= '0';

            -- Set 22 - Access to the host mainboard 64K address space.
            when TZMM_TZPUM => 
                CPLD_HI_ADDR        <= "000";
                CPLD_RA_ADDR        <= CPLD_ADDR(15 downto 12);
                RAM_CSni            <= '1';
                RAM_WEni            <= '1';
                RAM_OEni            <= '1';
                CS_VIDEO_MEMn       <= '1';
                DISABLE_BUSn        <= '1';

            -- Set 23 - Access all memory and IO on the tranZPUter board with the K64F addressing the full 512K RAM.
            when TZMM_TZPU =>
                DISABLE_BUSn        <= '0';
                CPLD_HI_ADDR        <= "000";  -- Hi bits directly driven by external source, ie. K64F in this mode.
                CPLD_RA_ADDR        <= CPLD_ADDR(15 downto 12);
                RAM_CSni            <= '0';
                RAM_OEni            <= CPLD_RDn;
                RAM_WEni            <= CPLD_WRn;
                CS_VIDEO_MEMn       <= '1';

            -- Set 24 - All memory and IO are on the tranZPUter board, 64K block 0 selected.
            when TZMM_TZPU0 =>
                DISABLE_BUSn        <= '0';
                CPLD_HI_ADDR        <= "000";
                CPLD_RA_ADDR        <= CPLD_ADDR(15 downto 12);
                RAM_CSni            <= '0';
                RAM_OEni            <= CPLD_RDn;
                RAM_WEni            <= CPLD_WRn;
                CS_VIDEO_MEMn       <= '1';

            -- Set 25 - All memory and IO are on the tranZPUter board, 64K block 1 selected.
            when TZMM_TZPU1 =>
                DISABLE_BUSn        <= '0';
                CPLD_HI_ADDR        <= "001";
                CPLD_RA_ADDR        <= CPLD_ADDR(15 downto 12);
                RAM_CSni            <= '0';
                RAM_OEni            <= CPLD_RDn;
                RAM_WEni            <= CPLD_WRn;
                CS_VIDEO_MEMn       <= '1';

            -- Set 26 - All memory and IO are on the tranZPUter board, 64K block 2 selected.
            when TZMM_TZPU2 =>
                DISABLE_BUSn        <= '0';
                CPLD_HI_ADDR        <= "010";
                CPLD_RA_ADDR        <= CPLD_ADDR(15 downto 12);
                RAM_CSni            <= '0';
                RAM_OEni            <= CPLD_RDn;
                RAM_WEni            <= CPLD_WRn;
                CS_VIDEO_MEMn       <= '1';

            -- Set 27 - All memory and IO are on the tranZPUter board, 64K block 3 selected.
            when TZMM_TZPU3 =>
                DISABLE_BUSn        <= '0';
                CPLD_HI_ADDR        <= "011";
                CPLD_RA_ADDR        <= CPLD_ADDR(15 downto 12);
                RAM_CSni            <= '0';
                RAM_OEni            <= CPLD_RDn;
                RAM_WEni            <= CPLD_WRn;
                CS_VIDEO_MEMn       <= '1';

            -- Set 28 - All memory and IO are on the tranZPUter board, 64K block 4 selected.
            when TZMM_TZPU4 =>
                DISABLE_BUSn        <= '0';
                CPLD_HI_ADDR        <= "100";
                CPLD_RA_ADDR        <= CPLD_ADDR(15 downto 12);
                RAM_CSni            <= '0';
                RAM_OEni            <= CPLD_RDn;
                RAM_WEni            <= CPLD_WRn;
                CS_VIDEO_MEMn       <= '1';

            -- Set 29 - All memory and IO are on the tranZPUter board, 64K block 5 selected.                
            when TZMM_TZPU5 =>
                DISABLE_BUSn        <= '0';
                CPLD_HI_ADDR        <= "101";
                CPLD_RA_ADDR        <= CPLD_ADDR(15 downto 12);
                RAM_CSni            <= '0';
                RAM_OEni            <= CPLD_RDn;
                RAM_WEni            <= CPLD_WRn;
                CS_VIDEO_MEMn       <= '1';

            -- Set 30 - All memory and IO are on the tranZPUter board, 64K block 6 selected.
            when TZMM_TZPU6 =>
                DISABLE_BUSn        <= '0';
                CPLD_HI_ADDR        <= "110";
                CPLD_RA_ADDR        <= CPLD_ADDR(15 downto 12);
                RAM_CSni            <= '0';
                RAM_OEni            <= CPLD_RDn;
                RAM_WEni            <= CPLD_WRn;
                CS_VIDEO_MEMn       <= '1';

            -- Set 31 - All memory and IO are on the tranZPUter board, 64K block 7 selected.
            when TZMM_TZPU7 =>
                DISABLE_BUSn        <= '0';
                CPLD_HI_ADDR        <= "111";
                CPLD_RA_ADDR        <= CPLD_ADDR(15 downto 12);
                RAM_CSni            <= '0';
                RAM_OEni            <= CPLD_RDn;
                RAM_WEni            <= CPLD_WRn;
                CS_VIDEO_MEMn       <= '1';

            -- Uncoded modes default to the original machine settings.
            when others =>
                CPLD_HI_ADDR        <= "000";
                CPLD_RA_ADDR        <= CPLD_ADDR(15 downto 12);
                RAM_CSni            <= '1';
                RAM_WEni            <= '1';
                RAM_OEni            <= '1';
                CS_VIDEO_MEMn       <= '1';
                if  CS_VIDEOn = '0' then
                    CS_VIDEO_MEMn   <= '0'; --CPLD_MREQn;
                    DISABLE_BUSn    <= '0';

                else
                    DISABLE_BUSn    <= '1';
                end if;
        end case;

        -- Defaults for IO operations, can be overriden for a specific set but should be present in all other sets.
        if((CPLD_WRn = '0' or CPLD_RDn = '0') and CPLD_IORQn = '0') then

            -- If the address is within configured IO control register range within the CPLD, disable the mainboard.
            if( (unsigned(CPLD_ADDR(7 downto 0)) >= X"60" and unsigned(CPLD_ADDR(7 downto 0)) <= X"6B") or (unsigned(CPLD_ADDR(7 downto 0)) >= X"6E" and unsigned(CPLD_ADDR(7 downto 0)) <= X"6F") ) then
                DISABLE_BUSn        <= '0';

            -- If the address is within configured IO control register range within the FPGA (when enabled) then disable the mainboard.
            elsif (CS_CPU_CFGn = '0' or CS_CPU_INFOn = '0' or CS_IO_DXXn = '0' or CS_IO_FXXn = '0') then
                DISABLE_BUSn        <= '0';
                CS_VIDEO_IOn        <= '0'; --CPLD_IORQn;

            -- Dont allow bank switches to filter through to the mainboard of an MZ-700.
         --   elsif MODE_CPLD_MZ700 = '1' and CS_IO_EXXn = '0' and CPLD_ADDR(3) = '0' then
         --       DISABLE_BUSn        <= '0';

            -- Only allow I/O operations to pass through to the mainboard when not processed by the CPLD or enabled FPGA.
            else
                DISABLE_BUSn        <= '1';
            end if;
        else
            CS_VIDEO_IOn            <= '1';
        end if;
    end process;

    -- Latch output so the K64F can determine current status.
    Z80_MEM               <= MEM_MODE_LATCH(4 downto 0);

    -- Clock frequency switching. Depending on the state of the flip flops either the system (mainboard) clocks is selected (default and selected when accessing
    -- the mainboard) and the programmable frequency generated by the K64F timers.
    Z80_CLKi              <= (SYSCLK or SYSCLK_Q) and (CTLCLKi or CTLCLK_Q);
    Z80_CLK               <= Z80_CLKi;

    -- Wait states, added by the mainboard video circuitry, FPGA video circuitry or the K64F.
    Z80_WAITn             <= '0'                         when MODE_CPU_SOFT = '0' and CTL_BUSRQn = '1' and (SYS_WAITn = '0' or CTL_WAITn = '0' or ((VWAITn = '0' and MODE_CPLD_MB_VIDEOn = '1') and MODE_CPLD_VIDEO_WAIT = '1'))
                             else
                             '1'                         when MODE_CPU_SOFT = '0' and CTL_BUSRQn = '1' and SYS_WAITn = '1' and CTL_WAITn = '1' and (VWAITn = '1' or MODE_CPLD_MB_VIDEOn = '0')
                             else 'Z';

    -- Z80 signals passed to the mainboard, if the K64F has control of the bus then the Z80 signals are disabled as they are not tri-stated during a BUSRQ state.
    CTL_M1n               <= CPLD_M1n                    when Z80_BUSACKn = '1'
                             else 'Z';
    CTL_RFSHn             <= CPLD_RFSHn                  when Z80_BUSACKn = '1'
                             else 'Z';
    CTL_HALTn             <= CPLD_HALTn                  when Z80_BUSACKn = '1'
                             else 'Z';
 
    -- Bus control logic, SYS_BUSACKni directly controls the mainboard tri-state buffers, enabling will disable the mainboard..
    SYS_BUSACKni          <= '0'                         when DISABLE_BUSn = '0'      or  (Z80_BUSACKn = '0'   and CTL_MBSEL = '0') 
                             else '1';
    SYS_BUSACKn           <= SYS_BUSACKni;

    -- Request hard Z80 bus. SYS_BUSRQ = mainboard requesting bus, CTL_BUSRQ = K64F requesting bus, MODE_CPU_SOFT = when set, soft CPU is running so hard CPU is permanently tri-stated.
    Z80_BUSRQn            <= '0'                         when MODE_CPU_SOFT = '1'     or  SYS_BUSRQn = '0'     or  CTL_BUSRQn = '0' 
                             else '1';
    -- Soft CPU bus request, ie, disable the Soft CPU, whenever enabled and the K64F requests the bus.
    VZ80_BUSRQn           <= '0'                         when MODE_CPU_SOFT = '1'     and CTL_BUSRQn = '0'
                             else '1';
    -- Acknowlegde to the K64F, if soft CPU is running then the soft CPU must acknowledge otherwise base on the hard Z80 acknowledge.
    CTL_BUSACKni          <= '0'                         when MODE_CPU_SOFT = '1'     and CTL_BUSRQn = '0'     and Z80_BUSACKn = '0'    and VZ80_BUSACKn = '0'
                             else
                             '0'                         when MODE_CPU_SOFT = '0'     and CTL_BUSRQn = '0'     and Z80_BUSACKn = '0'
                             else
                             '1';
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
    -- Data Bus Multiplexing, plex the output devices onto the correct Z80 (external or internal) data bus.
    --
    -- FPGA/CPLD -> External
    Z80_DATA              <= CPLD_CFG_DATA               when CS_CPLD_CFGn = '0'      and Z80_RDn = '0'                                  -- Read current CPLD register settings.
                             else
                             CPLD_INFO_DATA              when CS_CPLD_INFOn = '0'     and Z80_RDn = '0'                                  -- Read CPLD version & hw build information.
                             else
                             CLK_STATUS_DATA             when CS_SCK_RDn = '0'        and Z80_RDn = '0'                                  -- Read the clock select status.
                             else 
                             MEM_MODE_DATA               when CS_MEM_CFGn = '0'       and Z80_RDn = '0'                                  -- Read the memory mode latch.
                             else
                             VZ80_DATA                   when CS_VIDEO_RDn = '0'      and Z80_RDn = '0'                                  -- Read video memory inside FPGA when using FPGA based video.
                             else
                             VZ80_DATA                   when MODE_CPU_SOFT = '1'     and VZ80_WRn = '0'                                 -- Output T80 data to tranZPUter/mainboard when writing and T80 active.
                             else
                             (others => 'Z');                                                                                            -- Default is to tristate the Z80 data bus output when not being used.
    -- External/CPLD -> FPGA
    VZ80_DATA             <= CPLD_CFG_DATA               when MODE_CPU_SOFT = '1'     and CS_CPLD_CFGn = '0'   and VZ80_RDn = '0'        -- Read current register settings.
                             else
                             CPLD_INFO_DATA              when MODE_CPU_SOFT = '1'     and CS_CPLD_INFOn = '0'  and VZ80_RDn = '0'        -- Read version & hw build information.
                             else
                             CLK_STATUS_DATA             when MODE_CPU_SOFT = '1'     and CS_SCK_RDn = '0'     and VZ80_RDn = '0'        -- Read the clock select status.
                             else 
                             MEM_MODE_DATA               when MODE_CPU_SOFT = '1'     and CS_MEM_CFGn = '0'    and VZ80_RDn = '0'        -- Read the memory mode latch.
                             else
                             Z80_DATA                    when MODE_CPU_SOFT = '1'     and CTL_BUSRQn = '1'     and VZ80_RDn = '0'        -- Copy the Z80 data if being read by the T80.
                             else
                             Z80_DATA                    when MODE_CPU_SOFT = '0'     and Z80_WRn = '0'                                  -- Copy the Z80 data if being written by the Z80.
                             else
                             Z80_DATA                    when CTL_BUSRQn = '0'        and VZ80_BUSACKn = '0'   and Z80_WRn = '0'         -- Copy the Z80 data if the K64F is writing on the bus.
                             else
                             (others => 'Z');                                                                                            -- Default is to tristate the VZ80 data bus output when not being used.
    -- External/FPGA -> CPLD
    CPLD_DATA_IN          <= Z80_DATA                    when MODE_CPU_SOFT = '0'     or  (CTL_BUSRQn = '0'    and VZ80_BUSACKn = '0')
                             else
                             VZ80_DATA;

    --
    -- Core CPLD signals - depending on mode, the control signals are either taken from the hard CPU or soft CPU.
    --
    CPLD_ADDR             <= Z80_ADDR                    when MODE_CPU_SOFT = '0'     or  (CTL_BUSRQn = '0'    and VZ80_BUSACKn = '0')
                             else
                             VZ80_ADDR;
    CPLD_RDn              <= Z80_RDn                     when MODE_CPU_SOFT = '0'     or  (CTL_BUSRQn = '0'    and VZ80_BUSACKn = '0')
                             else
                             VZ80_RDn;
    CPLD_WRn              <= Z80_WRn                     when MODE_CPU_SOFT = '0'     or  (CTL_BUSRQn = '0'    and VZ80_BUSACKn = '0')
                             else
                             VZ80_WRn;
    CPLD_MREQn            <= Z80_MREQn                   when MODE_CPU_SOFT = '0'     or  (CTL_BUSRQn = '0'    and VZ80_BUSACKn = '0')
                             else
                             VZ80_MREQn;
    CPLD_IORQn            <= Z80_IORQn                   when MODE_CPU_SOFT = '0'     or  (CTL_BUSRQn = '0'    and VZ80_BUSACKn = '0')
                             else
                             VZ80_IORQn;
    CPLD_M1n              <= Z80_M1n                     when MODE_CPU_SOFT = '0'     or  (CTL_BUSRQn = '0'    and VZ80_BUSACKn = '0')
                             else
                             VZ80_M1n;
    CPLD_RFSHn            <= Z80_RFSHn                   when MODE_CPU_SOFT = '0'     or  (CTL_BUSRQn = '0'    and VZ80_BUSACKn = '0')
                             else
                             VZ80_RFSHn;
    CPLD_HALTn            <= Z80_HALTn                   when MODE_CPU_SOFT = '0'     or  (CTL_BUSRQn = '0'    and VZ80_BUSACKn = '0')
                             else
                             VZ80_HALTn;
    
    --
    -- Address Bus and Control Multiplexing on the hard CPU side.
    --
    Z80_HI_ADDR           <= CPLD_HI_ADDR                when CTL_BUSACKni = '1'                                                             -- New addition, pass through the upper address bits directly. K64F directly drives A16-A18 to RAM and into CPLD.
                             else (others => 'Z');
    Z80_RA_ADDR           <= CPLD_RA_ADDR;
    Z80_ADDR              <= VZ80_ADDR                   when MODE_CPU_SOFT = '1'     and (Z80_BUSACKn = '0'   and CTL_BUSRQn = '1')         -- In soft cpu mode, if the K64F hasnt taken control of the bus, always output the soft CPU address.
                             else (others => 'Z');

    Z80_WRn               <= VZ80_WRn                    when MODE_CPU_SOFT = '1'     and (Z80_BUSACKn = '0'   and CTL_BUSRQn = '1')
                             else 'Z';

    Z80_RDn               <= VZ80_RDn                    when MODE_CPU_SOFT = '1'     and (Z80_BUSACKn = '0'   and CTL_BUSRQn = '1')
                             else 'Z';

    Z80_MREQn             <= VZ80_MREQn                  when MODE_CPU_SOFT = '1'     and (Z80_BUSACKn = '0'   and CTL_BUSRQn = '1')
                             else 'Z';

    Z80_IORQn             <= VZ80_IORQn                  when MODE_CPU_SOFT = '1'     and (Z80_BUSACKn = '0'   and CTL_BUSRQn = '1')
                             else 'Z';

    Z80_RFSHn             <= VZ80_RFSHn                  when MODE_CPU_SOFT = '1'     and (Z80_BUSACKn = '0'   and CTL_BUSRQn = '1')
                             else 'Z';

    Z80_M1n               <= VZ80_M1n                    when MODE_CPU_SOFT = '1'     and (Z80_BUSACKn = '0'   and CTL_BUSRQn = '1')
                             else 'Z';

    Z80_HALTn             <= VZ80_HALTn                  when MODE_CPU_SOFT = '1'     and (Z80_BUSACKn = '0'   and CTL_BUSRQn = '1')
                             else 'Z';

    --
    -- Address Bus and Control Multiplexing on the soft CPU (FPGA) side.
    --
    VZ80_ADDR             <= Z80_ADDR(15 downto 0)       when MODE_CPU_SOFT = '0'     or  (CTL_BUSRQn = '0'    and VZ80_BUSACKn = '0')
                             else (others => 'Z');
    VZ80_MREQn            <= Z80_MREQn                   when MODE_CPU_SOFT = '0'     or  (CTL_BUSRQn = '0'    and VZ80_BUSACKn = '0')
                             else 'Z';
    VZ80_IORQn            <= Z80_IORQn                   when MODE_CPU_SOFT = '0'     or  (CTL_BUSRQn = '0'    and VZ80_BUSACKn = '0')
                             else 'Z';
    VZ80_RDn              <= Z80_RDn                     when MODE_CPU_SOFT = '0'     or  (CTL_BUSRQn = '0'    and VZ80_BUSACKn = '0')
                             else 'Z';
    VZ80_WRn              <= Z80_WRn                     when MODE_CPU_SOFT = '0'     or  (CTL_BUSRQn = '0'    and VZ80_BUSACKn = '0')
                             else 'Z';
    VZ80_M1n              <= Z80_M1n                     when MODE_CPU_SOFT = '0'     or  (CTL_BUSRQn = '0'    and VZ80_BUSACKn = '0')
                             else 'Z';
    -- Inputs, they share signal lines with the mainboard video and K64F addressing, so only route them if a soft CPU in the FPGA is enabled (which also implies FPGA video is in use).
    VZ80_A16_WAITn        <= Z80_HI_ADDR(16)             when MODE_CPU_SOFT = '1'     and (CTL_BUSRQn = '0'    and VZ80_BUSACKn = '0')
                             else
                             Z80_WAITn                   when MODE_CPU_SOFT = '1'     and CTL_BUSRQn = '1'
                             else '1';
    VZ80_A17_NMIn         <= Z80_HI_ADDR(17)             when MODE_CPU_SOFT = '1'     and (CTL_BUSRQn = '0'    and VZ80_BUSACKn = '0')
                             else
                             Z80_NMIn                    when MODE_CPU_SOFT = '1'     and CTL_BUSRQn = '1'
                             else '1';
    VZ80_A18_INTn         <= Z80_HI_ADDR(18)             when MODE_CPU_SOFT = '1'     and (CTL_BUSRQn = '0'    and VZ80_BUSACKn = '0')
                             else
                             Z80_INTn                    when MODE_CPU_SOFT = '1'     and CTL_BUSRQn = '1'
                             else '1';
    -- Clock, route the clock which is composed of the hard CPU mainboard clock and the K64F secondary clock. The T80 will be clocked with this clock.
    VZ80_CLK              <= Z80_CLKi;
    -- Video Read/Write signals. Enabled whenever the video controller is selected. When both VIDEO RDn/WRn are low (an impossible state under normal conditions), a reset is triggered inside the FPGA.
    VIDEO_RDn             <= '0'                         when Z80_RESETn = '0'
                             else
                             CPLD_RDn                    when CS_VIDEO_RDn = '0'
                             else '1';
    VIDEO_WRn             <= '0'                         when Z80_RESETn = '0'
                             else
                             CPLD_WRn                    when CS_VIDEO_WRn = '0'
                             else '1';

    -- Select for video based on the memory being accessed, the mode and control signals.
                             -- Standard access to VRAM/ARAM.
    CS_VIDEOn             <= '0'                         when MODE_CPLD_MB_VIDEOn = '1' and GRAM_PAGE_ENABLE = '0'  and MODE_VIDEO_MZ80B = '0'                              and unsigned(CPLD_ADDR(15 downto 0)) >= X"D000" and unsigned(CPLD_ADDR(15 downto 0)) < X"E000"
                             else
                             -- Graphics RAM enabled, range C000:FFFF is mapped to graphics RAM.
                             '0'                         when MODE_CPLD_MB_VIDEOn = '1' and GRAM_PAGE_ENABLE = '1'                                                          and unsigned(CPLD_ADDR(15 downto 0)) >= X"C000" and unsigned(CPLD_ADDR(15 downto 0)) <= X"FFFF"
                             else
                             -- MZ80B Graphics RAM enabled, range E000:FFFF is mapped to graphics RAMI + II and D000:DFFF to standard video.
                             '0'                         when MODE_CPLD_MB_VIDEOn = '1' and GRAM_PAGE_ENABLE = '0'  and MODE_VIDEO_MZ80B = '1' and MZ80B_VRAM_HI_ADDR = '1' and unsigned(CPLD_ADDR(15 downto 0)) >= X"D000" and unsigned(CPLD_ADDR(15 downto 0)) <= X"FFFF"
                             else
                             -- MZ80B Graphics RAM enabled, range 6000:7FFF is mapped to graphics RAMI + II and 5000:5FFF to standard video.
                             '0'                         when MODE_CPLD_MB_VIDEOn = '1' and GRAM_PAGE_ENABLE = '0'  and MODE_VIDEO_MZ80B = '1' and MZ80B_VRAM_LO_ADDR = '1' and unsigned(CPLD_ADDR(15 downto 0)) >= X"5000" and unsigned(CPLD_ADDR(15 downto 0)) <= X"7FFF"
                             else '1';

    -- Read from memory and IO devices within the FPGA.
    CS_VIDEO_RDn          <= '0'                         when (CS_VIDEO_MEMn = '0' or CS_VIDEO_IOn = '0')
                             else '1';

    -- Write to memory and IO devices within the FPGA. Duplicate the transaction to the FPGA for CPLD register writes 0x60:0x6F so that the FPGA can register current settings.
    CS_VIDEO_WRn          <= '0'                         when (CS_VIDEO_MEMn = '0' or CS_VIDEO_IOn = '0' or CS_IO_EXXn = '0' or CS_IO_6XXn = '0')
                             else '1';


    -- The tranZPUter SW board adds upgrades for the Z80 processor and host. These upgrades are controlled through an IO port which 
    -- in v1.0 - v1.1 was either at 0x2-=0x2f, 0x60-0x6f, 0xA0-0xAf, 0xF0-0xFF, the default being 0x60. This logic mimcs the 74HCT138 and
    -- FlashRAM decoder which produces the I/O port select signals.
    --
    CS_IO_6XXn            <= '0'                         when CPLD_IORQn = '0'  and CPLD_M1n = '1' and CPLD_ADDR(7 downto 4) = "0110"
                              else '1';
    CS_MEM_CFGn           <= '0'                         when CS_IO_6XXn = '0'  and CPLD_ADDR(3 downto 1) = "000"                   -- IO 60
                              else '1';
    CS_SCK_CTLCLKn        <= '0'                         when CS_IO_6XXn = '0'  and CPLD_ADDR(3 downto 1) = "001"                   -- IO 62
                              else '1';
    CS_SCK_SYSCLKn        <= '0'                         when CS_IO_6XXn = '0'  and CPLD_ADDR(3 downto 1) = "010"                   -- IO 64
                              else '1';
    CS_SCK_RDn            <= '0'                         when CS_IO_6XXn = '0'  and CPLD_ADDR(3 downto 1) = "011"                   -- IO 66
                              else '1';
    SVCREQn               <= '0'                         when CS_IO_6XXn = '0'  and CPLD_ADDR(3 downto 1) = "100"                   -- IO 68
                              else '1';
    CS_CPU_CFGn           <= '0'                         when CS_IO_6XXn = '0'  and CPLD_ADDR(3 downto 0) = "1100"                  -- IO 6C
                              else '1';
    CS_CPU_INFOn          <= '0'                         when CS_IO_6XXn = '0'  and CPLD_ADDR(3 downto 0) = "1101"                  -- IO 6D
                              else '1';
    CS_CPLD_CFGn          <= '0'                         when CS_IO_6XXn = '0'  and CPLD_ADDR(3 downto 0) = "1110"                  -- IO 6E
                              else '1';
    CS_CPLD_INFOn         <= '0'                         when CS_IO_6XXn = '0'  and CPLD_ADDR(3 downto 0) = "1111"                  -- IO 6F
                              else '1';

    -- Assign the RAM select signals to their external pins.
    RAM_CSn               <= RAM_CSni;
    RAM_OEn               <= RAM_OEni                    when CPLD_MREQn = '0'
                             else '1';
    RAM_WEn               <= RAM_WEni                    when CPLD_MREQn = '0'
                             else '1';

    -- I/O Control signals to read and update the current video parameters, mainly used for setting FPGA access.
    CS_IO_DXXn            <= '0'                         when CPLD_IORQn = '0'  and CPLD_M1n = '1' and CPLD_ADDR(7 downto 4) = "1101"
                              else '1';

    -- I/O Control signals, mainly used for mirroring of the video module registers.
    CS_IO_EXXn            <= '0'                         when CPLD_IORQn = '0'  and CPLD_M1n = '1' and CPLD_ADDR(7 downto 4) = "1110"
                              else '1';
    -- MZ80B/MZ2000 I/O Registers E0-EB,
    CS_80B_PIOn           <= '0'                         when CS_IO_EXXn = '0'  and CPLD_ADDR(3 downto 2) = "10" and MODE_VIDEO_MZ80B = '1'
                              else '1';

    -- I/O Control signals to read and update the current video parameters, mainly used for setting FPGA access.
    CS_IO_FXXn            <= '0'                         when CPLD_IORQn = '0'  and CPLD_M1n = '1' and CPLD_ADDR(7 downto 4) = "1111"
                              else '1';
    -- 0xF8 set the video mode. [2:0] = mode, 000 = MZ80A, 001 = MZ-700, 010 = MZ-80B, 011 = MZ-800, 111 = Pixel graphics.
    CS_FB_VMn             <= '0'                         when CS_IO_FXXn = '0'  and CPLD_ADDR(3 downto 0) = "1000"
                              else '1';
    -- 0xFD set the Video memory page in block C000:FFFF bit 0, set the CGROM upload access in bit 7.
    CS_FB_PAGEn           <= '0'                         when CS_IO_FXXn = '0'  and CPLD_ADDR(3 downto 0) = "1101"
                              else '1';


    -- Set the video wait state generator, 0 = disabled, 1 = enabled.
    MODE_CPLD_VIDEO_WAIT  <= CPLD_CFG_DATA(4);
    -- Set the mainboard video state, 0 = enabled, 1 = disabled. Signal set to enabled if the soft cpu is enabled.
    MODE_CPLD_MB_VIDEOn   <= '1'                         when CPLD_CFG_DATA(3) = '1'  or CPU_CFG_DATA(5 downto 0) /= "000000"
                             else '0';
    -- Flag to indicate Soft CPU is running,
    MODE_CPU_SOFT         <= '1'                         when CPU_CFG_DATA(5 downto 0) /= "000000"
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

    -- Graphics signal out, enabled when the FPGA video is disabled.
    VWAITn_V_CSYNC        <= CSYNC_IN                    when MODE_CPLD_MB_VIDEOn = '0'            -- Composite sync from mainboard to the FPGA which then outputs to the external devices if FPGA video disabled.
                             else 'Z';
    VZ80_RFSHn_V_HSYNC    <= HSYNC_IN                    when MODE_CPLD_MB_VIDEOn = '0'            -- Horizontal sync from mainboard to the FPGA which then outputs to the external devices if FPGA video disabled.
                             else 'Z';
    VZ80_HALTn_V_VSYNC    <= VSYNC_IN                    when MODE_CPLD_MB_VIDEOn = '0'            -- Vertical sync from mainboard to the FPGA which then outputs to the external devices if FPGA video disabled.
                             else 'Z';
    VZ80_BUSRQn_V_G       <= G_IN                        when MODE_CPLD_MB_VIDEOn = '0'            -- Green video from mainboard to the FPGA which then outputs to the external devices if FPGA video disabled.
                             else
                             VZ80_BUSRQn;                                                          -- Z80 BUSRQ generated by CPLD to tri-state the soft CPU.
    VZ80_WAITn_V_B        <= B_IN                        when MODE_CPLD_MB_VIDEOn = '0'            -- Blue video from mainboard to the FPGA which then outputs to the external devices if FPGA video disabled.
                             else
                             VZ80_A16_WAITn;                                                       -- Z80 WAIT generated by system or CPLD to force the soft CPU to wait and VZ80_A16 from the K64F during memory access.
    VZ80_NMIn_V_COLR      <= COLR_IN                     when MODE_CPLD_MB_VIDEOn = '0'            -- Colour modulation frequency for generation of external composite video and RF signals.
                             else
                             VZ80_A17_NMIn;                                                        -- Z80 NMI generated by external sources to interrupt the soft CPU and VZ80_A17 from the K64F during memory access.
    VZ80_INTn_V_R         <= R_IN                        when MODE_CPLD_MB_VIDEOn = '0'            -- Red video from mainboard to the FPGA which then outputs to the external devices if FPGA video disabled.
                             else
                             VZ80_A18_INTn;                                                        -- Z80 INT generated by external sources to interrupt the soft CPU and VZ80_A18 from the K64F during memory access.

    -- Z80 control signals, enabled when the FPGA video is enabled, the signals share the same physical wire as the mainboard video signals and 
    -- when the FPGA video is used the mainboard video signals are not needed.
    VWAITn                <= VWAITn_V_CSYNC              when MODE_CPLD_MB_VIDEOn = '1'            -- VWAITn signal output by FPGA during access to memory during Framebuffer rendering.
                             else '1';
    VZ80_RFSHn            <= VZ80_RFSHn_V_HSYNC          when MODE_CPLD_MB_VIDEOn = '1'            -- Z80 RFSH signal output by soft CPU.
                             else '1';
    VZ80_HALTn            <= VZ80_HALTn_V_VSYNC          when MODE_CPLD_MB_VIDEOn = '1'            -- Z80 HALT signal output by soft CPU.
                             else '1';

end architecture;
