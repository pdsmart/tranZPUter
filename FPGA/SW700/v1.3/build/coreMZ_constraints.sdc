## Generated SDC file "VideoController700_constraints.sdc"

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

create_clock -name {altera_reserved_tck} -period 100.000 -waveform { 0.000 50.000 } [get_ports {altera_reserved_tck}]
create_clock -name {CLOCK_50} -period 20.000 -waveform { 0.000 10.000 } [get_ports {CLOCK_50}]
create_clock -name {VZ80_CLK} -period 50.000 -waveform { 0.000 25.000 } [get_ports {VZ80_CLK}]

#**************************************************************
# Create Generated Clock
#**************************************************************

#derive_pll_clocks
create_generated_clock -name {SYS_CLK} -source [get_pins {VCPLL1|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 12 -divide_by 5 -master_clock {CLOCK_50} [get_pins {VCPLL1|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {VIDCLK_8MHZ} -source [get_pins {VCPLL1|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 8 -divide_by 25 -master_clock {CLOCK_50} [get_pins {VCPLL1|altpll_component|auto_generated|pll1|clk[1]}] 
create_generated_clock -name {VIDCLK_16MHZ} -source [get_pins {VCPLL1|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 16 -divide_by 25 -master_clock {CLOCK_50} [get_pins {VCPLL1|altpll_component|auto_generated|pll1|clk[2]}] 
create_generated_clock -name {VIDCLK_40MHZ} -source [get_pins {VCPLL1|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 8 -divide_by 5 -master_clock {CLOCK_50} [get_pins {VCPLL1|altpll_component|auto_generated|pll1|clk[3]}] 
create_generated_clock -name {VIDCLK_65MHZ} -source [get_pins {VCPLL2|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 13 -divide_by 5 -phase 0.00 -master_clock {CLOCK_50} [get_pins {VCPLL2|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {VIDCLK_25_175MHZ} -source [get_pins {VCPLL2|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 91 -divide_by 90 -master_clock {CLOCK_50} [get_pins {VCPLL2|altpll_component|auto_generated|pll1|clk[1]}] 
create_generated_clock -name {VIDCLK_8_86719MHZ} -source [get_pins {VCPLL3|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 115 -divide_by 324 -master_clock {CLOCK_50} [get_pins {VCPLL3|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {VIDCLK_17_7344MHZ} -source [get_pins {VCPLL3|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 115 -divide_by 162 -master_clock {CLOCK_50} [get_pins {VCPLL3|altpll_component|auto_generated|pll1|clk[1]}]


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

set_input_delay -add_delay  -clock [get_clocks {CLOCK_50}]  1.000  [get_ports {CLOCK_50}]
set_input_delay -add_delay  -clock [get_clocks {VZ80_CLK}]  1.000  [get_ports {VZ80_CLK}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VIDEO_WRn}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VIDEO_RDn}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_WRn}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_RDn}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_IORQn}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_MREQn}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_M1n}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_ADDR[15]}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_ADDR[14]}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_ADDR[13]}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_ADDR[12]}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_ADDR[11]}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_ADDR[10]}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_ADDR[9]}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_ADDR[8]}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_ADDR[7]}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_ADDR[6]}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_ADDR[5]}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_ADDR[4]}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_ADDR[3]}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_ADDR[2]}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_ADDR[1]}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_ADDR[0]}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_DATA[0]}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_DATA[1]}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_DATA[2]}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_DATA[3]}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_DATA[4]}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_DATA[5]}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_DATA[6]}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_DATA[7]}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  1.000  [get_ports {VGA_B_COMPOSITE}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  1.000  [get_ports {VGA_G_COMPOSITE}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  1.000  [get_ports {VGA_R_COMPOSITE}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  1.000  [get_ports {VWAITn_V_CSYNC}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  1.000  [get_ports {VZ80_RFSHn_V_HSYNCn}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  1.000  [get_ports {VZ80_HALTn_V_VSYNCn}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  1.000  [get_ports {VZ80_BUSRQn_V_G}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  1.000  [get_ports {VZ80_WAITn_V_B}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  1.000  [get_ports {VZ80_INTn_V_R}]
set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]  1.000  [get_ports {VZ80_NMIn_V_COLR}]
# Required for the Serial Flash Loader.
set_input_delay -add_delay  -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {altera_reserved_tck}]
set_input_delay -add_delay  -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {altera_reserved_tdi}]
set_input_delay -add_delay  -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {altera_reserved_tms}]
set_input_delay -add_delay  -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {SFL:sfl|altserial_flash_loader_component|\GEN_ASMI_TYPE_1:asmi_inst~ALTERA_DATA0}]


#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_DATA[0]}]
set_output_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_DATA[1]}]
set_output_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_DATA[2]}]
set_output_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_DATA[3]}]
set_output_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_DATA[4]}]
set_output_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_DATA[5]}]
set_output_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_DATA[6]}]
set_output_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_DATA[7]}]
set_output_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_WRn}]
set_output_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_RDn}]
set_output_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_IORQn}]
set_output_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_MREQn}]
set_output_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_M1n}]
set_output_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_BUSACKn}]
set_output_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VWAITn_V_CSYNC}]
set_output_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_RFSHn_V_HSYNCn}]
set_output_delay -add_delay  -clock [get_clocks {SYS_CLK}]  8.000  [get_ports {VZ80_HALTn_V_VSYNCn}]
set_output_delay -add_delay  -clock [get_clocks {SYS_CLK}]  1.000  [get_ports {VGA_B[0]}]
set_output_delay -add_delay  -clock [get_clocks {SYS_CLK}]  1.000  [get_ports {VGA_B[1]}]
set_output_delay -add_delay  -clock [get_clocks {SYS_CLK}]  1.000  [get_ports {VGA_B[2]}]
set_output_delay -add_delay  -clock [get_clocks {SYS_CLK}]  1.000  [get_ports {VGA_B[3]}]
set_output_delay -add_delay  -clock [get_clocks {SYS_CLK}]  1.000  [get_ports {VGA_B_COMPOSITE}]
set_output_delay -add_delay  -clock [get_clocks {SYS_CLK}]  1.000  [get_ports {VGA_G[0]}]
set_output_delay -add_delay  -clock [get_clocks {SYS_CLK}]  1.000  [get_ports {VGA_G[1]}]
set_output_delay -add_delay  -clock [get_clocks {SYS_CLK}]  1.000  [get_ports {VGA_G[2]}]
set_output_delay -add_delay  -clock [get_clocks {SYS_CLK}]  1.000  [get_ports {VGA_G[3]}]
set_output_delay -add_delay  -clock [get_clocks {SYS_CLK}]  1.000  [get_ports {VGA_G_COMPOSITE}]
set_output_delay -add_delay  -clock [get_clocks {SYS_CLK}]  1.000  [get_ports {VGA_R[0]}]
set_output_delay -add_delay  -clock [get_clocks {SYS_CLK}]  1.000  [get_ports {VGA_R[1]}]
set_output_delay -add_delay  -clock [get_clocks {SYS_CLK}]  1.000  [get_ports {VGA_R[2]}]
set_output_delay -add_delay  -clock [get_clocks {SYS_CLK}]  1.000  [get_ports {VGA_R[3]}]
set_output_delay -add_delay  -clock [get_clocks {SYS_CLK}]  1.000  [get_ports {VGA_R_COMPOSITE}]
set_output_delay -add_delay  -clock [get_clocks {SYS_CLK}]  1.000  [get_ports {HSYNC_OUTn}]
set_output_delay -add_delay  -clock [get_clocks {SYS_CLK}]  1.000  [get_ports {VSYNC_OUTn}]
set_output_delay -add_delay  -clock [get_clocks {SYS_CLK}]  1.000  [get_ports {COLR_OUT}]
set_output_delay -add_delay  -clock [get_clocks {SYS_CLK}]  1.000  [get_ports {CSYNC_OUT}]
set_output_delay -add_delay  -clock [get_clocks {SYS_CLK}]  1.000  [get_ports {CSYNC_OUTn}]
# Required for the Serial Flash Loader.
set_output_delay -add_delay  -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {SFL:sfl|altserial_flash_loader_component|\GEN_ASMI_TYPE_1:asmi_inst~ALTERA_DCLK}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {SFL:sfl|altserial_flash_loader_component|\GEN_ASMI_TYPE_1:asmi_inst~ALTERA_SCE}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {SFL:sfl|altserial_flash_loader_component|\GEN_ASMI_TYPE_1:asmi_inst~ALTERA_SDO}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {altera_reserved_tdo}]


#**************************************************************
# Set Clock Groups
#**************************************************************


#**************************************************************
# Set False Path
#**************************************************************
# There is no relationship between the different video frequencies, only one is used at a time and they are switched through synchronised D-Type flip flops.
set_false_path  -from  [get_clocks {VIDCLK_8MHZ}]        -to  [get_clocks {CLOCK_50 VIDCLK_16MHZ VIDCLK_40MHZ VIDCLK_65MHZ VIDCLK_25_175MHZ VIDCLK_8_86719MHZ VIDCLK_17_7344MHZ VZ80_CLK}]
set_false_path  -from  [get_clocks {VIDCLK_8_86719MHZ}]  -to  [get_clocks {CLOCK_50 VIDCLK_8MHZ VIDCLK_16MHZ VIDCLK_40MHZ VIDCLK_65MHZ VIDCLK_25_175MHZ VIDCLK_17_7344MHZ VZ80_CLK}]
set_false_path  -from  [get_clocks {VIDCLK_16MHZ}]       -to  [get_clocks {CLOCK_50 VIDCLK_8MHZ VIDCLK_40MHZ VIDCLK_65MHZ VIDCLK_25_175MHZ VIDCLK_8_86719MHZ VIDCLK_17_7344MHZ VZ80_CLK}]
set_false_path  -from  [get_clocks {VIDCLK_17_7344MHZ}]  -to  [get_clocks {CLOCK_50 VIDCLK_8MHZ VIDCLK_16MHZ VIDCLK_40MHZ VIDCLK_65MHZ VIDCLK_25_175MHZ VIDCLK_8_86719MHZ VZ80_CLK}]
set_false_path  -from  [get_clocks {VIDCLK_25_175MHZ}]   -to  [get_clocks {CLOCK_50 VIDCLK_8MHZ VIDCLK_16MHZ VIDCLK_40MHZ VIDCLK_65MHZ VIDCLK_8_86719MHZ VIDCLK_17_7344MHZ VZ80_CLK}]
set_false_path  -from  [get_clocks {VIDCLK_40MHZ}]       -to  [get_clocks {CLOCK_50 VIDCLK_8MHZ VIDCLK_16MHZ VIDCLK_65MHZ VIDCLK_25_175MHZ VIDCLK_8_86719MHZ VIDCLK_17_7344MHZ VZ80_CLK}]
set_false_path  -from  [get_clocks {VIDCLK_65MHZ}]       -to  [get_clocks {CLOCK_50 VIDCLK_8MHZ VIDCLK_16MHZ VIDCLK_40MHZ VIDCLK_65MHZ VIDCLK_25_175MHZ VIDCLK_8_86719MHZ VIDCLK_17_7344MHZ VZ80_CLK}]

# Z80 clock has no relationship to the video frequencies, it is used only for latching data asynchronous to the FPGA clocks.
set_false_path  -from  [get_clocks {VZ80_CLK}]           -to  [get_clocks {VIDCLK_8MHZ VIDCLK_16MHZ VIDCLK_40MHZ VIDCLK_25_175MHZ VIDCLK_65MHZ VIDCLK_8_86719MHZ VIDCLK_17_7344MHZ}]

# The system clock has no real relationship with the video frequencies, rendering and display. The only place they meet is in the dual port BRAM.
set_false_path  -from  [get_clocks {SYS_CLK}]            -to  [get_clocks {CLOCK_50 VIDCLK_8MHZ VIDCLK_16MHZ VIDCLK_40MHZ VIDCLK_25_175MHZ VIDCLK_65MHZ VIDCLK_8_86719MHZ VIDCLK_17_7344MHZ}]

# Clock 50MHZ, the input oscillator is only used for the PLL input and as I/O input/output latch which is detached from the video block
set_false_path  -from  [get_clocks {CLOCK_50}]           -to  [get_clocks {VIDCLK_8MHZ VIDCLK_16MHZ VIDCLK_40MHZ VIDCLK_25_175MHZ VIDCLK_65MHZ VIDCLK_8_86719MHZ VIDCLK_17_7344MHZ}]

# The Z80 data, address and control lines do not go to the video block (except the parameter update which is not critical) so set it as a false path so as not to consider.
set_false_path  -from  [get_ports {VZ80_DATA[*]}]        -to  [get_clocks {VIDCLK_8MHZ VIDCLK_16MHZ VIDCLK_40MHZ VIDCLK_25_175MHZ VIDCLK_65MHZ VIDCLK_8_86719MHZ VIDCLK_17_7344MHZ}]
set_false_path  -from  [get_ports {VZ80_ADDR[*]}]        -to [get_registers {VideoController:vcCoreVideo|XFER_MAPPED_DATA[*]}]
set_false_path  -from  [get_ports {VZ80_WRn VZ80_RDn VZ80_IORQn}]  -to [get_registers {VideoController:vcCoreVideo|XFER_MAPPED_DATA[*]}]


#**************************************************************
# Set Multicycle Path
#**************************************************************

set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|DSP_PARAM_SEL[*]}] -to [get_ports {VZ80_DATA[*]}] -hold -start 1
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|DSP_PARAM_SEL[*]}] -to [get_ports {VZ80_DATA[*]}] -setup -start 2

set_multicycle_path -from [get_clocks {SYS_CLK}] -to [get_clocks {VZ80_CLK}] -hold -start 1
set_multicycle_path -from [get_clocks {SYS_CLK}] -to [get_clocks {VZ80_CLK}] -setup -start 2
set_multicycle_path -from [get_clocks {VZ80_CLK}] -to [get_clocks {SYS_CLK}] -hold -start 2
set_multicycle_path -from [get_clocks {VZ80_CLK}] -to [get_clocks {SYS_CLK}] -setup -start 3

# GPU control and run variables have at least 1 clock between them being setup and used.
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_START_X[*]}] -to [get_registers {VideoController:vcCoreVideo|GPU_START_ADDR[*]}] -setup -start 2
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_END_X[*]}] -to [get_registers {VideoController:vcCoreVideo|GPU_START_ADDR[*]}] -setup -start 2
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_START_X[*]}] -to [get_registers {VideoController:vcCoreVideo|GRAM_GPU_ADDR[*]}] -setup -start 2
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_END_X[*]}] -to [get_registers {VideoController:vcCoreVideo|GRAM_GPU_ADDR[*]}] -setup -start 2
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_START_Y[*]}] -to [get_registers {VideoController:vcCoreVideo|GPU_START_ADDR[*]}] -setup -start 2
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_END_Y[*]}] -to [get_registers {VideoController:vcCoreVideo|GPU_START_ADDR[*]}] -setup -start 2
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_START_Y[*]}] -to [get_registers {VideoController:vcCoreVideo|GRAM_GPU_ADDR[*]}] -setup -start 2
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_END_Y[*]}] -to [get_registers {VideoController:vcCoreVideo|GRAM_GPU_ADDR[*]}] -setup -start 2
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_START_X[*]}] -to [get_registers {VideoController:vcCoreVideo|\GPU:GPU_VAR_Y[*]}] -setup -start 2
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_END_X[*]}] -to [get_registers {VideoController:vcCoreVideo|\GPU:GPU_VAR_Y[*]}] -setup -start 2
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_START_X[*]}] -to [get_registers {VideoController:vcCoreVideo|GPU_STATE.*}] -setup -start 2
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_END_X[*]}] -to [get_registers {VideoController:vcCoreVideo|GPU_STATE.*}] -setup -start 2
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_START_X[*]}] -to [get_registers {VideoController:vcCoreVideo|VRAM_GPU_ADDR[*]}] -setup -start 2
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_END_X[*]}] -to [get_registers {VideoController:vcCoreVideo|VRAM_GPU_ADDR[*]}] -setup -start 2

set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_START_Y[*]}] -to [get_registers {VideoController:vcCoreVideo|VRAM_GPU_ADDR[*]}] -setup -start 2
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|GPU_START_ADDR[*]}] -to [get_registers {VideoController:vcCoreVideo|VRAM_GPU_ADDR[*]}] -setup -start 2
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_COLUMNS[*]}] -to [get_registers {VideoController:vcCoreVideo|GPU_START_ADDR[*]}] -setup -start 2
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_COLUMNS[*]}] -to [get_registers {VideoController:vcCoreVideo|VRAM_GPU_ADDR[*]}] -setup -start 2
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|XFER_DST_ADDR[*]}] -to [get_registers {VideoController:vcCoreVideo|XFER_MAPPED_DATA[*]}] -setup -start 2
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|XFER_DST_ADDR[*]}] -to [get_registers {VideoController:vcCoreVideo|XFER_DST_ADDR[*]}] -setup -start 2


set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_START_X[*]}] -to [get_registers {VideoController:vcCoreVideo|GPU_START_ADDR[*]}] -hold -start 1
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_END_X[*]}] -to [get_registers {VideoController:vcCoreVideo|GPU_START_ADDR[*]}] -hold -start 1
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_START_X[*]}] -to [get_registers {VideoController:vcCoreVideo|GRAM_GPU_ADDR[*]}] -hold -start 1
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_END_X[*]}] -to [get_registers {VideoController:vcCoreVideo|GRAM_GPU_ADDR[*]}] -hold -start 1
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_START_Y[*]}] -to [get_registers {VideoController:vcCoreVideo|GPU_START_ADDR[*]}] -hold -start 1
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_END_Y[*]}] -to [get_registers {VideoController:vcCoreVideo|GPU_START_ADDR[*]}] -hold -start 1
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_START_Y[*]}] -to [get_registers {VideoController:vcCoreVideo|GRAM_GPU_ADDR[*]}] -hold -start 1
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_END_Y[*]}] -to [get_registers {VideoController:vcCoreVideo|GRAM_GPU_ADDR[*]}] -hold -start 1
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_START_X[*]}] -to [get_registers {VideoController:vcCoreVideo|\GPU:GPU_VAR_Y[*]}] -hold -start 1
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_END_X[*]}] -to [get_registers {VideoController:vcCoreVideo|\GPU:GPU_VAR_Y[*]}] -hold -start 1
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_START_X[*]}] -to [get_registers {VideoController:vcCoreVideo|GPU_STATE.*}] -hold -start 1
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_END_X[*]}] -to [get_registers {VideoController:vcCoreVideo|GPU_STATE.*}] -hold -start 1
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_START_X[*]}] -to [get_registers {VideoController:vcCoreVideo|VRAM_GPU_ADDR[*]}] -hold -start 1
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_END_X[*]}] -to [get_registers {VideoController:vcCoreVideo|VRAM_GPU_ADDR[*]}] -hold -start 1

set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_START_Y[*]}] -to [get_registers {VideoController:vcCoreVideo|VRAM_GPU_ADDR[*]}] -hold -start 1
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|GPU_START_ADDR[*]}] -to [get_registers {VideoController:vcCoreVideo|VRAM_GPU_ADDR[*]}] -hold -start 1
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_COLUMNS[*]}] -to [get_registers {VideoController:vcCoreVideo|GPU_START_ADDR[*]}] -hold -start 1
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|\GPU:GPU_COLUMNS[*]}] -to [get_registers {VideoController:vcCoreVideo|VRAM_GPU_ADDR[*]}] -hold -start 1
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|XFER_DST_ADDR[*]}] -to [get_registers {VideoController:vcCoreVideo|XFER_MAPPED_DATA[*]}] -hold -start 1
set_multicycle_path -from [get_registers {VideoController:vcCoreVideo|XFER_DST_ADDR[*]}] -to [get_registers {VideoController:vcCoreVideo|XFER_DST_ADDR[*]}] -hold -start 1


#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

