## Generated SDC file "VideoController_constraints.sdc"

## Copyright (C) 1991-2013 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 13.1.0 Build 162 10/23/2013 SJ Full Version"

## DATE    "Fri Jul  3 00:11:58 2020"

##
## DEVICE  "EP3C25E144C8"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3

#**************************************************************
# Create Clock
#**************************************************************

#**************************************************************
# Create Generated Clock
#**************************************************************

#derive_pll_clocks
create_generated_clock -name {SYS_CLK}           -source [get_pins {vcCoreVideo|VCPLL1|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 12  -divide_by 5   -phase  0.00 -master_clock {CLOCK_50} [get_pins {vcCoreVideo|VCPLL1|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {VIDCLK_8MHZ}       -source [get_pins {vcCoreVideo|VCPLL1|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 8   -divide_by 25  -phase  0.00 -master_clock {CLOCK_50} [get_pins {vcCoreVideo|VCPLL1|altpll_component|auto_generated|pll1|clk[1]}] 
create_generated_clock -name {VIDCLK_16MHZ}      -source [get_pins {vcCoreVideo|VCPLL1|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 16  -divide_by 25  -phase  0.00 -master_clock {CLOCK_50} [get_pins {vcCoreVideo|VCPLL1|altpll_component|auto_generated|pll1|clk[2]}] 
create_generated_clock -name {VIDCLK_40MHZ}      -source [get_pins {vcCoreVideo|VCPLL1|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 8   -divide_by 5   -phase  0.00 -master_clock {CLOCK_50} [get_pins {vcCoreVideo|VCPLL1|altpll_component|auto_generated|pll1|clk[3]}] 
create_generated_clock -name {VIDCLK_65MHZ}      -source [get_pins {vcCoreVideo|VCPLL2|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 13  -divide_by 5   -phase  0.00 -master_clock {CLOCK_50} [get_pins {vcCoreVideo|VCPLL2|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {VIDCLK_25_175MHZ}  -source [get_pins {vcCoreVideo|VCPLL2|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 91  -divide_by 90  -phase  0.00 -master_clock {CLOCK_50} [get_pins {vcCoreVideo|VCPLL2|altpll_component|auto_generated|pll1|clk[1]}] 
create_generated_clock -name {VIDCLK_8_86719MHZ} -source [get_pins {vcCoreVideo|VCPLL3|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 115 -divide_by 324 -phase  0.00 -master_clock {CLOCK_50} [get_pins {vcCoreVideo|VCPLL3|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {VIDCLK_17_7344MHZ} -source [get_pins {vcCoreVideo|VCPLL3|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 115 -divide_by 162 -phase  0.00 -master_clock {CLOCK_50} [get_pins {vcCoreVideo|VCPLL3|altpll_component|auto_generated|pll1|clk[1]}]

#**************************************************************
# Set Clock Latency
#**************************************************************

#**************************************************************
# Set Clock Uncertainty
#**************************************************************

derive_clock_uncertainty

#**************************************************************
# Set Input Delay
#**************************************************************
 
#**************************************************************
# Set Output Delay
#**************************************************************
 
#**************************************************************
# Set Clock Groups
#**************************************************************
 
#**************************************************************
# Set False Path
#**************************************************************
# # There is no relationship between the different video frequencies, only one is used at a time and they are switched through synchronised D-Type flip flops.
set_false_path  -from  [get_clocks {VIDCLK_8MHZ}]        -to  [get_clocks {CLOCK_50             VIDCLK_16MHZ VIDCLK_40MHZ VIDCLK_65MHZ VIDCLK_25_175MHZ VIDCLK_8_86719MHZ VIDCLK_17_7344MHZ VZ80_CLK}]
set_false_path  -from  [get_clocks {VIDCLK_8_86719MHZ}]  -to  [get_clocks {CLOCK_50 VIDCLK_8MHZ VIDCLK_16MHZ VIDCLK_40MHZ VIDCLK_65MHZ VIDCLK_25_175MHZ                   VIDCLK_17_7344MHZ VZ80_CLK}]
set_false_path  -from  [get_clocks {VIDCLK_16MHZ}]       -to  [get_clocks {CLOCK_50 VIDCLK_8MHZ VIDCLK_40MHZ              VIDCLK_65MHZ VIDCLK_25_175MHZ VIDCLK_8_86719MHZ VIDCLK_17_7344MHZ VZ80_CLK}]
set_false_path  -from  [get_clocks {VIDCLK_17_7344MHZ}]  -to  [get_clocks {CLOCK_50 VIDCLK_8MHZ VIDCLK_16MHZ VIDCLK_40MHZ VIDCLK_65MHZ VIDCLK_25_175MHZ VIDCLK_8_86719MHZ                   VZ80_CLK}]
set_false_path  -from  [get_clocks {VIDCLK_25_175MHZ}]   -to  [get_clocks {CLOCK_50 VIDCLK_8MHZ VIDCLK_16MHZ VIDCLK_40MHZ VIDCLK_65MHZ                  VIDCLK_8_86719MHZ VIDCLK_17_7344MHZ VZ80_CLK}]
set_false_path  -from  [get_clocks {VIDCLK_40MHZ}]       -to  [get_clocks {CLOCK_50 VIDCLK_8MHZ VIDCLK_16MHZ              VIDCLK_65MHZ VIDCLK_25_175MHZ VIDCLK_8_86719MHZ VIDCLK_17_7344MHZ VZ80_CLK}]
set_false_path  -from  [get_clocks {VIDCLK_65MHZ}]       -to  [get_clocks {CLOCK_50 VIDCLK_8MHZ VIDCLK_16MHZ VIDCLK_40MHZ VIDCLK_65MHZ VIDCLK_25_175MHZ VIDCLK_8_86719MHZ VIDCLK_17_7344MHZ VZ80_CLK}]

# Clock 50MHZ, the input oscillator is only used for the PLL input and does not directly drive registers.
set_false_path  -from  [get_clocks {CLOCK_50}]           -to  [get_clocks {SYS_CLK VIDCLK_8MHZ VIDCLK_16MHZ VIDCLK_40MHZ VIDCLK_25_175MHZ VIDCLK_65MHZ VIDCLK_8_86719MHZ VIDCLK_17_7344MHZ}]

#**************************************************************
# Set Multicycle Path
#**************************************************************
set_multicycle_path -from [get_clocks {SYS_CLK}]                                            -to [get_clocks {CLOCK_50}]                                           -setup -end 2
set_multicycle_path -from [get_clocks {SYS_CLK}]                                            -to [get_clocks {CLOCK_50}]                                           -hold -end 1

set_multicycle_path -from [get_clocks {SYS_CLK}]                                            -to [get_clocks {VIDCLK_8MHZ}]                                        -setup -end 2
set_multicycle_path -from [get_clocks {SYS_CLK}]                                            -to [get_clocks {VIDCLK_8MHZ}]                                        -hold -end 1

set_multicycle_path -from [get_clocks {SYS_CLK}]                                            -to [get_clocks {VIDCLK_8_86719MHZ}]                                  -setup -end 2
set_multicycle_path -from [get_clocks {SYS_CLK}]                                            -to [get_clocks {VIDCLK_8_86719MHZ}]                                  -hold -end 1

set_multicycle_path -from [get_clocks {SYS_CLK}]                                            -to [get_clocks {VIDCLK_16MHZ}]                                       -setup -end 2
set_multicycle_path -from [get_clocks {SYS_CLK}]                                            -to [get_clocks {VIDCLK_16MHZ}]                                       -hold -end 1

set_multicycle_path -from [get_clocks {SYS_CLK}]                                            -to [get_clocks {VIDCLK_17_7344MHZ}]                                  -setup -end 2
set_multicycle_path -from [get_clocks {SYS_CLK}]                                            -to [get_clocks {VIDCLK_17_7344MHZ}]                                  -hold -end 1

set_multicycle_path -from [get_clocks {SYS_CLK}]                                            -to [get_clocks {VIDCLK_25_175MHZ}]                                   -setup -end 2
set_multicycle_path -from [get_clocks {SYS_CLK}]                                            -to [get_clocks {VIDCLK_25_175MHZ}]                                   -hold -end 1

set_multicycle_path -from [get_clocks {SYS_CLK}]                                            -to [get_clocks {VIDCLK_40MHZ}]                                       -setup -end 2
set_multicycle_path -from [get_clocks {SYS_CLK}]                                            -to [get_clocks {VIDCLK_40MHZ}]                                       -hold -end 1

#set_multicycle_path -from [get_clocks {SYS_CLK}]                                            -to [get_clocks {VIDCLK_65MHZ}]                                       -setup -end 2
#set_multicycle_path -from [get_clocks {SYS_CLK}]                                            -to [get_clocks {VIDCLK_65MHZ}]                                       -hold -end 1

set_multicycle_path -from [get_clocks {VIDCLK_8MHZ}]                                        -to [get_clocks {SYS_CLK}]                                            -setup -end 2
set_multicycle_path -from [get_clocks {VIDCLK_8MHZ}]                                        -to [get_clocks {SYS_CLK}]                                            -hold -end 1

set_multicycle_path -from [get_clocks {VIDCLK_8_86719MHZ}]                                  -to [get_clocks {SYS_CLK}]                                            -setup -end 2
set_multicycle_path -from [get_clocks {VIDCLK_8_86719MHZ}]                                  -to [get_clocks {SYS_CLK}]                                            -hold -end 1

set_multicycle_path -from [get_clocks {VIDCLK_16MHZ}]                                       -to [get_clocks {SYS_CLK}]                                            -setup -end 2
set_multicycle_path -from [get_clocks {VIDCLK_16MHZ}]                                       -to [get_clocks {SYS_CLK}]                                            -hold -end 1

set_multicycle_path -from [get_clocks {VIDCLK_17_7344MHZ}]                                  -to [get_clocks {SYS_CLK}]                                            -setup -end 2
set_multicycle_path -from [get_clocks {VIDCLK_17_7344MHZ}]                                  -to [get_clocks {SYS_CLK}]                                            -hold -end 1

set_multicycle_path -from [get_clocks {VIDCLK_25_175MHZ}]                                   -to [get_clocks {SYS_CLK}]                                            -setup -end 3
set_multicycle_path -from [get_clocks {VIDCLK_25_175MHZ}]                                   -to [get_clocks {SYS_CLK}]                                            -hold -end 2

set_multicycle_path -from [get_clocks {VIDCLK_40MHZ}]                                       -to [get_clocks {SYS_CLK}]                                            -setup -end 2
set_multicycle_path -from [get_clocks {VIDCLK_40MHZ}]                                       -to [get_clocks {SYS_CLK}]                                            -hold -end 1

set_multicycle_path -from [get_clocks {VIDCLK_65MHZ}]                                       -to [get_clocks {SYS_CLK}]                                            -setup -end 2
set_multicycle_path -from [get_clocks {VIDCLK_65MHZ}]                                       -to [get_clocks {SYS_CLK}]                                            -hold -end 1

# GPU control and run variables have at least 1 clock between them being setup and used.
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_START_X[*]}] -to [get_registers {VideoController:vcCoreVideo|GPU_START_ADDR[*]}]   -setup -start 2
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_END_X[*]}]   -to [get_registers {VideoController:vcCoreVideo|GPU_START_ADDR[*]}]   -setup -start 2
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_START_X[*]}] -to [get_registers {VideoController:vcCoreVideo|GRAM_GPU_ADDR[*]}]    -setup -start 2
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_END_X[*]}]   -to [get_registers {VideoController:vcCoreVideo|GRAM_GPU_ADDR[*]}]    -setup -start 2
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_START_Y[*]}] -to [get_registers {VideoController:vcCoreVideo|GPU_START_ADDR[*]}]   -setup -start 2
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_END_Y[*]}]   -to [get_registers {VideoController:vcCoreVideo|GPU_START_ADDR[*]}]   -setup -start 2
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_START_Y[*]}] -to [get_registers {VideoController:vcCoreVideo|GRAM_GPU_ADDR[*]}]    -setup -start 2
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_END_Y[*]}]   -to [get_registers {VideoController:vcCoreVideo|GRAM_GPU_ADDR[*]}]    -setup -start 2
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_START_X[*]}] -to [get_registers {VideoController:vcCoreVideo|\GPU:GPU_VAR_Y[*]}]   -setup -start 2
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_END_X[*]}]   -to [get_registers {VideoController:vcCoreVideo|\GPU:GPU_VAR_Y[*]}]   -setup -start 2
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_START_X[*]}] -to [get_registers {VideoController:vcCoreVideo|GPU_STATE.*}]         -setup -start 2
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_END_X[*]}]   -to [get_registers {VideoController:vcCoreVideo|GPU_STATE.*}]         -setup -start 2
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_START_X[*]}] -to [get_registers {VideoController:vcCoreVideo|VRAM_GPU_ADDR[*]}]    -setup -start 2
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_END_X[*]}]   -to [get_registers {VideoController:vcCoreVideo|VRAM_GPU_ADDR[*]}]    -setup -start 2

set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_START_Y[*]}] -to [get_registers {VideoController:vcCoreVideo|VRAM_GPU_ADDR[*]}]    -setup -start 2
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|GPU_START_ADDR[*]}]   -to [get_registers {VideoController:vcCoreVideo|VRAM_GPU_ADDR[*]}]    -setup -start 2
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_COLUMNS[*]}] -to [get_registers {VideoController:vcCoreVideo|GPU_START_ADDR[*]}]   -setup -start 2
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_COLUMNS[*]}] -to [get_registers {VideoController:vcCoreVideo|VRAM_GPU_ADDR[*]}]    -setup -start 2
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|XFER_DST_ADDR[*]}]    -to [get_registers {VideoController:vcCoreVideo|XFER_MAPPED_DATA[*]}] -setup -start 2
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|XFER_DST_ADDR[*]}]    -to [get_registers {VideoController:vcCoreVideo|XFER_DST_ADDR[*]}]    -setup -start 2


set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_START_X[*]}] -to [get_registers {VideoController:vcCoreVideo|GPU_START_ADDR[*]}]   -hold -end 1
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_END_X[*]}]   -to [get_registers {VideoController:vcCoreVideo|GPU_START_ADDR[*]}]   -hold -end 1
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_START_X[*]}] -to [get_registers {VideoController:vcCoreVideo|GRAM_GPU_ADDR[*]}]    -hold -end 1
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_END_X[*]}]   -to [get_registers {VideoController:vcCoreVideo|GRAM_GPU_ADDR[*]}]    -hold -end 1
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_START_Y[*]}] -to [get_registers {VideoController:vcCoreVideo|GPU_START_ADDR[*]}]   -hold -end 1
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_END_Y[*]}]   -to [get_registers {VideoController:vcCoreVideo|GPU_START_ADDR[*]}]   -hold -end 1
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_START_Y[*]}] -to [get_registers {VideoController:vcCoreVideo|GRAM_GPU_ADDR[*]}]    -hold -end 1
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_END_Y[*]}]   -to [get_registers {VideoController:vcCoreVideo|GRAM_GPU_ADDR[*]}]    -hold -end 1
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_START_X[*]}] -to [get_registers {VideoController:vcCoreVideo|\GPU:GPU_VAR_Y[*]}]   -hold -end 1
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_END_X[*]}]   -to [get_registers {VideoController:vcCoreVideo|\GPU:GPU_VAR_Y[*]}]   -hold -end 1
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_START_X[*]}] -to [get_registers {VideoController:vcCoreVideo|GPU_STATE.*}]         -hold -end 1
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_END_X[*]}]   -to [get_registers {VideoController:vcCoreVideo|GPU_STATE.*}]         -hold -end 1
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_START_X[*]}] -to [get_registers {VideoController:vcCoreVideo|VRAM_GPU_ADDR[*]}]    -hold -end 1
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_END_X[*]}]   -to [get_registers {VideoController:vcCoreVideo|VRAM_GPU_ADDR[*]}]    -hold -end 1

set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_START_Y[*]}] -to [get_registers {VideoController:vcCoreVideo|VRAM_GPU_ADDR[*]}]    -hold -end 1
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|GPU_START_ADDR[*]}]   -to [get_registers {VideoController:vcCoreVideo|VRAM_GPU_ADDR[*]}]    -hold -end 1
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_COLUMNS[*]}] -to [get_registers {VideoController:vcCoreVideo|GPU_START_ADDR[*]}]   -hold -end 1
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_COLUMNS[*]}] -to [get_registers {VideoController:vcCoreVideo|VRAM_GPU_ADDR[*]}]    -hold -end 1
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|XFER_DST_ADDR[*]}]    -to [get_registers {VideoController:vcCoreVideo|XFER_MAPPED_DATA[*]}] -hold -end 1
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|XFER_DST_ADDR[*]}]    -to [get_registers {VideoController:vcCoreVideo|XFER_DST_ADDR[*]}]    -hold -end 1
#**************************************************************
# Set Maximum Delay
#**************************************************************
 
#**************************************************************
# Set Minimum Delay
#**************************************************************
 
#**************************************************************
# Set Input Transition
#**************************************************************
