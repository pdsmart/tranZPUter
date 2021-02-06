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
create_clock -name {CLOCK_50}            -period 20.000  -waveform { 0.000 10.000 } [get_ports {CLOCK_50}]
create_clock -name {VZ80_CLK}            -period 50.000  -waveform { 0.000 25.000 } [get_ports {VZ80_CLK}]
create_clock -name {softT80:\CPU0:T80CPU|T80_CLK} -period 50

#**************************************************************
# Create Generated Clock
#**************************************************************
#derive_pll_clocks
create_generated_clock -name {CPUCLK_75MHZ}      -source [get_pins {COREMZPLL1|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 3 -divide_by 2 -phase  0.00 -master_clock {CLOCK_50} [get_pins {COREMZPLL1|altpll_component|auto_generated|pll1|clk[0]}] 


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
set_input_delay -add_delay  -clock [get_clocks {CLOCK_50}]   1.000  [get_ports {VIDEO_WRn}]
set_input_delay -add_delay  -clock [get_clocks {CLOCK_50}]   1.000  [get_ports {VIDEO_RDn}]
set_input_delay -add_delay  -clock [get_clocks {CLOCK_50}]   1.000  [get_ports {VZ80_WRn}]
set_input_delay -add_delay  -clock [get_clocks {CLOCK_50}]   1.000  [get_ports {VZ80_RDn}]
set_input_delay -add_delay  -clock [get_clocks {CLOCK_50}]   1.000  [get_ports {VZ80_IORQn}]
set_input_delay -add_delay  -clock [get_clocks {CLOCK_50}]   1.000  [get_ports {VZ80_MREQn}]
set_input_delay -add_delay  -clock [get_clocks {CLOCK_50}]   1.000  [get_ports {VZ80_M1n}]
set_input_delay -add_delay  -clock [get_clocks {CLOCK_50}]   1.000  [get_ports {VZ80_ADDR[*]}]
set_input_delay -add_delay  -clock [get_clocks {CLOCK_50}]   1.000  [get_ports {VZ80_DATA[*]}]
# set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]   1.000  [get_ports {VGA_B_COMPOSITE}]
# set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]   1.000  [get_ports {VGA_G_COMPOSITE}]
# set_input_delay -add_delay  -clock [get_clocks {SYS_CLK}]   1.000  [get_ports {VGA_R_COMPOSITE}]
set_input_delay -add_delay  -clock [get_clocks {CLOCK_50}]   1.000  [get_ports {VWAITn_A21_V_CSYNC}]
set_input_delay -add_delay  -clock [get_clocks {CLOCK_50}]   1.000  [get_ports {VZ80_A20_RFSHn_V_HSYNCn}]
set_input_delay -add_delay  -clock [get_clocks {CLOCK_50}]   1.000  [get_ports {VZ80_A19_HALTn_V_VSYNCn}]
set_input_delay -add_delay  -clock [get_clocks {CLOCK_50}]   1.000  [get_ports {VZ80_BUSRQn_V_G}]
set_input_delay -add_delay  -clock [get_clocks {CLOCK_50}]   1.000  [get_ports {VZ80_A16_WAITn_V_B}]
set_input_delay -add_delay  -clock [get_clocks {CLOCK_50}]   1.000  [get_ports {VZ80_A18_INTn_V_R}]
set_input_delay -add_delay  -clock [get_clocks {CLOCK_50}]   1.000  [get_ports {VZ80_A17_NMIn_V_COLR}]
# # Required for the Serial Flash Loader.
set_input_delay -add_delay -clock { altera_reserved_tck }   1.000  [get_ports {altera_reserved_tck}]
set_input_delay -add_delay -clock { altera_reserved_tck }   1.000  [get_ports {SFL_IV:\SERIALFLASHLOADER:SFL|altserial_flash_loader:altserial_flash_loader_component|\GEN_ASMI_TYPE_1:asmi_inst~ALTERA_DATA0}]
set_input_delay -add_delay -clock { altera_reserved_tck }   1.000  [get_ports {altera_reserved_tdi}]
set_input_delay -add_delay -clock { altera_reserved_tck }   1.000  [get_ports {altera_reserved_tms}]


#**************************************************************
# Set Output Delay
#**************************************************************
set_output_delay -add_delay  -clock [get_clocks {CLOCK_50}]  1.000  [get_ports {VZ80_DATA[*]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK_50}]  1.000  [get_ports {VZ80_WRn}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK_50}]  1.000  [get_ports {VZ80_RDn}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK_50}]  1.000  [get_ports {VZ80_IORQn}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK_50}]  1.000  [get_ports {VZ80_MREQn}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK_50}]  1.000  [get_ports {VZ80_M1n}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK_50}]  1.000  [get_ports {VZ80_BUSACKn}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK_50}]  1.000  [get_ports {VWAITn_A21_V_CSYNC}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK_50}]  1.000  [get_ports {VZ80_A20_RFSHn_V_HSYNCn}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK_50}]  1.000  [get_ports {VZ80_A19_HALTn_V_VSYNCn}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK_50}]  1.000  [get_ports {VGA_B[*]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK_50}]  1.000  [get_ports {VGA_B_COMPOSITE}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK_50}]  1.000  [get_ports {VGA_G[*]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK_50}]  1.000  [get_ports {VGA_G_COMPOSITE}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK_50}]  1.000  [get_ports {VGA_R[*]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK_50}]  1.000  [get_ports {VGA_R_COMPOSITE}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK_50}]  1.000  [get_ports {HSYNC_OUTn}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK_50}]  1.000  [get_ports {VSYNC_OUTn}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK_50}]  1.000  [get_ports {COLR_OUT}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK_50}]  1.000  [get_ports {CSYNC_OUT}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK_50}]  1.000  [get_ports {CSYNC_OUTn}]
# # Required for the Serial Flash Loader.
set_output_delay -add_delay  -clock { altera_reserved_tck } 1.000  [get_ports {SFL_IV:\SERIALFLASHLOADER:SFL|altserial_flash_loader:altserial_flash_loader_component|\GEN_ASMI_TYPE_1:asmi_inst~ALTERA_DCLK}]
set_output_delay -add_delay  -clock { altera_reserved_tck } 1.000  [get_ports {SFL_IV:\SERIALFLASHLOADER:SFL|altserial_flash_loader:altserial_flash_loader_component|\GEN_ASMI_TYPE_1:asmi_inst~ALTERA_SCE}]
set_output_delay -add_delay  -clock { altera_reserved_tck } 1.000  [get_ports {SFL_IV:\SERIALFLASHLOADER:SFL|altserial_flash_loader:altserial_flash_loader_component|\GEN_ASMI_TYPE_1:asmi_inst~ALTERA_SDO}]
set_output_delay -add_delay  -clock { altera_reserved_tck } 1.000  [get_ports {altera_reserved_tdo}]


#**************************************************************
# Set Clock Groups
#**************************************************************
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}]

#**************************************************************
# Set False Path
#**************************************************************

#**************************************************************
# Set Multicycle Path
#**************************************************************
set_multicycle_path -from [get_clocks {CLOCK_50}] -to [get_clocks {CPUCLK_75MHZ}] -setup -end 3
set_multicycle_path -from [get_clocks {CLOCK_50}] -to [get_clocks {CPUCLK_75MHZ}] -hold -end 2

#**************************************************************
# Set Maximum Delay
#**************************************************************
set_max_delay -from {VZ80_BUSRQn_V_G}                                       -to [get_ports {VZ80_ADDR[*]}] 100.00
set_max_delay -from {CPLD_CFG_DATA[*]}                                      -to [get_ports {VZ80_ADDR[*]}] 100.00
set_max_delay -from {CPU_CFG_DATA[*]}                                       -to [get_ports {VZ80_ADDR[*]}] 100.00
set_max_delay -from {CPLD_CFG_DATA[*]}                                      -to [get_ports {VZ80_DATA[*]}] 100.00
set_max_delay -from {CPU_CFG_DATA[*]}                                       -to [get_ports {VZ80_DATA[*]}] 100.00
set_max_delay -from {VZ80_BUSRQn_V_G}                                       -to [get_ports {VZ80_DATA[*]}] 50.00
set_max_delay -from {VZ80_RDn}                                              -to [get_ports {VZ80_DATA[*]}] 50.00
set_max_delay -from {VZ80_IORQn}                                            -to [get_ports {VZ80_DATA[*]}] 50.00
set_max_delay -from {VIDEO_RDn}                                             -to [get_ports {VZ80_DATA[*]}] 50.00
set_max_delay -from {VZ80_ADDR[*]}                                          -to [get_ports {VZ80_DATA[*]}] 50.00
set_max_delay -from {VWAITn_A21_V_CSYNC}                                    -to [get_ports {VZ80_DATA[*]}] 50.00
set_max_delay -from {VZ80_A20_RFSHn_V_HSYNCn}                               -to [get_ports {VZ80_DATA[*]}] 50.00
set_max_delay -from {VZ80_A19_HALTn_V_VSYNCn}                               -to [get_ports {VZ80_DATA[*]}] 50.00
set_max_delay -from {VZ80_A18_INTn_V_R}                                     -to [get_ports {VZ80_DATA[*]}] 50.00
set_max_delay -from {VZ80_A17_NMIn_V_COLR}                                  -to [get_ports {VZ80_DATA[*]}] 50.00
set_max_delay -from {VZ80_A16_WAITn_V_B}                                    -to [get_ports {VZ80_DATA[*]}] 50.00

#**************************************************************
# Set Minimum Delay
#**************************************************************
set_min_delay -from {VZ80_BUSRQn_V_G}                                       -to [get_ports {VZ80_ADDR[*]}] 1.00
set_min_delay -from {CPLD_CFG_DATA[*]}                                      -to [get_ports {VZ80_ADDR[*]}] 1.00
set_min_delay -from {CPU_CFG_DATA[*]}                                       -to [get_ports {VZ80_ADDR[*]}] 1.00
set_min_delay -from {CPLD_CFG_DATA[*]}                                      -to [get_ports {VZ80_DATA[*]}] 1.00
set_min_delay -from {CPU_CFG_DATA[*]}                                       -to [get_ports {VZ80_DATA[*]}] 1.00
set_min_delay -from {VZ80_BUSRQn_V_G}                                       -to [get_ports {VZ80_DATA[*]}] 1.00
set_min_delay -from {VZ80_RDn}                                              -to [get_ports {VZ80_DATA[*]}] 1.00
set_min_delay -from {VZ80_IORQn}                                            -to [get_ports {VZ80_DATA[*]}] 1.00
set_min_delay -from {VIDEO_RDn}                                             -to [get_ports {VZ80_DATA[*]}] 1.00
set_min_delay -from {VZ80_ADDR[*]}                                          -to [get_ports {VZ80_DATA[*]}] 1.00
set_min_delay -from {VWAITn_A21_V_CSYNC}                                    -to [get_ports {VZ80_DATA[*]}] 1.00
set_min_delay -from {VZ80_A20_RFSHn_V_HSYNCn}                               -to [get_ports {VZ80_DATA[*]}] 1.00
set_min_delay -from {VZ80_A19_HALTn_V_VSYNCn}                               -to [get_ports {VZ80_DATA[*]}] 1.00
set_min_delay -from {VZ80_A18_INTn_V_R}                                     -to [get_ports {VZ80_DATA[*]}] 1.00
set_min_delay -from {VZ80_A17_NMIn_V_COLR}                                  -to [get_ports {VZ80_DATA[*]}] 1.00
set_min_delay -from {VZ80_A16_WAITn_V_B}                                    -to [get_ports {VZ80_DATA[*]}] 1.00

#**************************************************************
# Set Input Transition
#**************************************************************
