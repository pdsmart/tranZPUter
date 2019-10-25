library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.zpu_soc_pkg.all;

entity tranZPUter is
    port (
        -- Clock
        CLOCK_12M       : in    std_logic;
        -- LED
        LED             : out   std_logic_vector(7 downto 0);
        -- Debounced keys
--        KEY             : in    std_logic_vector(1 downto 0);
        -- DIP switches
--        SW              : in    std_logic_vector(3 downto 0);
        USER_BTN        :   in    std_logic;
    
    --  TDI             : in    std_logic;
    --  TCK             : in    std_logic;
    --  TCS             : in    std_logic;
    --  TDO             : out   std_logic;
    --  I2C_SDAT        : inout std_logic;
    --  I2C_SCLK        : out   std_logic;
    --  GPIO_0          : inout std_logic_vector(33 downto 0);
    --  GPIO_1          : inout std_logic_vector(33 downto 0);

        -- SD Card 1
        SDCARD_MISO     : in    std_logic_vector(SOC_SD_DEVICES-1 downto 0);
        SDCARD_MOSI     : out   std_logic_vector(SOC_SD_DEVICES-1 downto 0);
        SDCARD_CLK      : out   std_logic_vector(SOC_SD_DEVICES-1 downto 0);
        SDCARD_CS       : out   std_logic_vector(SOC_SD_DEVICES-1 downto 0);    
    
        UART_RX_0       : in    std_logic;
        UART_TX_0       : out   std_logic;
        UART_RX_1       : in    std_logic;
        UART_TX_1       : out   std_logic;

        -- SDRAM signals
        SDRAM_CLK       : out   std_logic;                                  -- sdram is accessed at 128MHz
        SDRAM_CKE       : out   std_logic;                                  -- clock enable.
        SDRAM_DQ        : inout std_logic_vector(15 downto 0);              -- 16 bit bidirectional data bus
        SDRAM_ADDR      : out   std_logic_vector(12 downto 0);              -- 13 bit multiplexed address bus
        SDRAM_DQM       : out   std_logic_vector(1 downto 0);               -- two byte masks
        SDRAM_BA        : out   std_logic_vector(1 downto 0);               -- two banks
        SDRAM_CS        : out   std_logic;                                  -- a single chip select
        SDRAM_WE        : out   std_logic;                                  -- write enable
        SDRAM_RAS       : out   std_logic;                                  -- row address select
        SDRAM_CAS       : out   std_logic;                                  -- columns address select

        -- TCPU signals.
        CYC_D           : inout std_logic_vector(15 downto 0);              -- Data bus
        CYC_CTL_SET_n   : out   std_logic;                                  -- Set the transceiver control signals.
        CYC_CTL_RST_n   : out   std_logic;                                  -- Reset the transceiver control signals.
        CYC_CLK_n       : in    std_logic;                                  -- Z80 Main Clock
        CYC_NMI_n       : in    std_logic;                                  -- Z80 NMI converted to 3.3v
        CYC_INT_n       : in    std_logic;                                  -- Z80 INT converted to 3.,3v
        CYC_WAIT_I_n    : in    std_logic;                                  -- Z80 Wait converted to 3.3v.
        CYC_BUSACK_I_n  : in    std_logic;                                  -- Z80 Bus Ack converted to 3.3v.
        CYC_BUSACK_n    : out   std_logic;                                  -- CYC sending BUS ACK
        CYC_BUSRQ_n     : out   std_logic;                                  -- CYC requesting Z80 bus.
        CYC_BUSRQ_I_n   : in    std_logic                                   -- System requesting Z80 bus.
    );
END entity;

architecture rtl of tranZPUter is

    signal reset        : std_logic;
    signal sysclk       : std_logic;
    signal memclk       : std_logic;
    signal pll_locked   : std_logic;
    
    --signal ps2m_clk_in : std_logic;
    --signal ps2m_clk_out : std_logic;
    --signal ps2m_dat_in : std_logic;
    --signal ps2m_dat_out : std_logic;
    
    --signal ps2k_clk_in : std_logic;
    --signal ps2k_clk_out : std_logic;
    --signal ps2k_dat_in : std_logic;
    --signal ps2k_dat_out : std_logic;
    
    --alias PS2_MDAT : std_logic is GPIO_1(19);
    --alias PS2_MCLK : std_logic is GPIO_1(18);

begin

--I2C_SDAT    <= 'Z';
--GPIO_0(33 downto 2) <= (others => 'Z');
--GPIO_1 <= (others => 'Z');
--LED <= "101010" & reset & UART_RX_0;
LED <= "00000000";

mypll : entity work.Clock_12to100
port map
(
    inclk0            => CLOCK_12M,
    c0                => sysclk,
    c1                => memclk,
    locked            => pll_locked
);

--reset<=(not SW(0) xor KEY(0)) and pll_locked;
reset<=(not USER_BTN) and pll_locked;

myVirtualToplevel : entity work.zpu_soc
generic map
(
    SYSCLK_FREQUENCY => SYSCLK_CYC1000_FREQ
)
port map
(    
    SYSCLK            => sysclk,
    MEMCLK            => memclk,
    RESET_IN          => reset,

    -- RS232
    UART_RX_0         => UART_RX_0,
    UART_TX_0         => UART_TX_0,
    UART_RX_1         => UART_RX_1,
    UART_TX_1         => UART_TX_1,

    -- SD Card (SPI) signals
    SDCARD_MISO       => SDCARD_MISO,
    SDCARD_MOSI       => SDCARD_MOSI,
    SDCARD_CLK        => SDCARD_CLK,
    SDCARD_CS         => SDCARD_CS,
        
    -- SDRAM signals
    SDRAM_CLK         => SDRAM_CLK,                        -- sdram is accessed at 128MHz
    SDRAM_RST         => reset,                            -- reset the sdram controller.
    SDRAM_CKE         => SDRAM_CKE,                        -- clock enable.
    SDRAM_DQ          => SDRAM_DQ,                         -- 16 bit bidirectional data bus
    SDRAM_ADDR        => SDRAM_ADDR,                       -- 13 bit multiplexed address bus
    SDRAM_DQM         => SDRAM_DQM,                        -- two byte masks
    SDRAM_BA          => SDRAM_BA,                         -- two banks
    SDRAM_CS_n        => SDRAM_CS,                         -- a single chip select
    SDRAM_WE_n        => SDRAM_WE,                         -- write enable
    SDRAM_RAS_n       => SDRAM_RAS,                        -- row address select
    SDRAM_CAS_n       => SDRAM_CAS,                        -- columns address select
    SDRAM_READY       => open,                             -- sd ready.

    -- TCPU Bus
    TCPU_DATA         => CYC_D,                            -- Data bus
    TCPU_CTL_SET_n    => CYC_CTL_SET_n,                    -- Set the transceiver control signals.
    TCPU_CTL_RST_n    => CYC_CTL_RST_n,                    -- Reset the transceiver control signals.
    TCPU_CLK_n        => CYC_CLK_n,                        -- Z80 Main Clock
    TCPU_NMI_n        => CYC_NMI_n,                        -- Z80 NMI converted to 3.3v
    TCPU_INT_n        => CYC_INT_n,                        -- Z80 INT converted to 3.,3v
    TCPU_WAIT_I_n     => CYC_WAIT_I_n,                     -- Z80 Wait converted to 3.3v.
    TCPU_BUSACK_I_n   => CYC_BUSACK_I_n,                   -- Z80 Bus Ack converted to 3.3v.
    TCPU_BUSACK_n     => CYC_BUSACK_n,                     -- CYC sending BUS ACK
    TCPU_BUSRQ_n      => CYC_BUSRQ_n,                      -- CYC requesting Z80 bus.
    TCPU_BUSRQ_I_n    => CYC_BUSRQ_I_n                     -- System requesting Z80 bus.
);


end architecture;
