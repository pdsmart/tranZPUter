## Generated SDC file "softZPU_constraints.sdc"

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

#**************************************************************
# Set Multicycle Path
#**************************************************************
set_multicycle_path -from [get_clocks {VZ80_CLK}]     -to [get_clocks {CPUCLK_75MHZ}]      -setup -end 2
set_multicycle_path -from [get_clocks {VZ80_CLK}]     -to [get_clocks {CPUCLK_75MHZ}]      -hold -end 1

set_multicycle_path -from [get_clocks {CPUCLK_75MHZ}] -to [get_clocks {VZ80_CLK}]          -setup -start 3
set_multicycle_path -from [get_clocks {CPUCLK_75MHZ}] -to [get_clocks {VZ80_CLK}]          -hold -end 2

set_multicycle_path -from [get_clocks {CPUCLK_75MHZ}] -to [get_clocks {VIDCLK_8MHZ}]       -setup -end 2
set_multicycle_path -from [get_clocks {CPUCLK_75MHZ}] -to [get_clocks {VIDCLK_8MHZ}]       -hold -end 1

set_multicycle_path -from [get_clocks {CPUCLK_75MHZ}] -to [get_clocks {VIDCLK_8_86719MHZ}] -setup -end 2
set_multicycle_path -from [get_clocks {CPUCLK_75MHZ}] -to [get_clocks {VIDCLK_8_86719MHZ}] -hold -end 1

set_multicycle_path -from [get_clocks {CPUCLK_75MHZ}] -to [get_clocks {VIDCLK_16MHZ}]      -setup -end 2
set_multicycle_path -from [get_clocks {CPUCLK_75MHZ}] -to [get_clocks {VIDCLK_16MHZ}]      -hold -end 1

set_multicycle_path -from [get_clocks {CPUCLK_75MHZ}] -to [get_clocks {VIDCLK_17_7344MHZ}] -setup -end 2
set_multicycle_path -from [get_clocks {CPUCLK_75MHZ}] -to [get_clocks {VIDCLK_17_7344MHZ}] -hold -end 1

set_multicycle_path -from [get_clocks {CPUCLK_75MHZ}] -to [get_clocks {VIDCLK_25_175MHZ}]  -setup -end 2
set_multicycle_path -from [get_clocks {CPUCLK_75MHZ}] -to [get_clocks {VIDCLK_25_175MHZ}]  -hold -end 1

set_multicycle_path -from [get_clocks {CPUCLK_75MHZ}] -to [get_clocks {VIDCLK_40MHZ}]      -setup -end 2
set_multicycle_path -from [get_clocks {CPUCLK_75MHZ}] -to [get_clocks {VIDCLK_40MHZ}]      -hold -end 1

set_multicycle_path -from [get_clocks {CPUCLK_75MHZ}] -to [get_clocks {VIDCLK_65MHZ}]      -setup -end 2
set_multicycle_path -from [get_clocks {CPUCLK_75MHZ}] -to [get_clocks {VIDCLK_65MHZ}]      -hold -end 1

set_multicycle_path -from [get_clocks {CPUCLK_75MHZ}] -to [get_clocks {CLOCK_50}]          -setup -end 2
set_multicycle_path -from [get_clocks {CPUCLK_75MHZ}] -to [get_clocks {CLOCK_50}]          -hold -end 1

set_multicycle_path -from [get_clocks {CPUCLK_75MHZ}] -to [get_clocks {SYS_CLK}]           -setup -end 2
set_multicycle_path -from [get_clocks {CPUCLK_75MHZ}] -to [get_clocks {SYS_CLK}]           -hold -end 1

set_multicycle_path -from {softZPU:\CPU1:ZPUCPU|zpu_core_evo:ZPU0|pc[*]} -to {softZPU:\CPU1:ZPUCPU|zpu_core_evo:ZPU0|mxFifo[*].addr[*]} -setup -end 2
set_multicycle_path -from {softZPU:\CPU1:ZPUCPU|zpu_core_evo:ZPU0|pc[*]} -to {softZPU:\CPU1:ZPUCPU|zpu_core_evo:ZPU0|mxFifo[*].addr[*]} -hold -end 1


#**************************************************************
# Set Maximum Delay
#**************************************************************
set_max_delay -from {softZPU:\CPU1:ZPUCPU|ZPU80_BUSACKn}                    -to [get_ports {VZ80_ADDR[*]}] 50.00
set_max_delay -from {softZPU:\CPU1:ZPUCPU|\Z80BUS:Z80_ADDR[*]}              -to [get_ports {VZ80_ADDR[*]}] 50.00
set_max_delay -from {softZPU:\CPU1:ZPUCPU|\Z80BUS:Z80_BYTE_ADDR[*]}         -to [get_ports {VZ80_ADDR[*]}] 50.00
set_max_delay -from {softZPU:\CPU1:ZPUCPU|ZPU_RESETn}                       -to [get_ports {VZ80_ADDR[*]}] 50.00
set_max_delay -from {softZPU:\CPU1:ZPUCPU|zpu_core_evo:ZPU0|MEM_BUSACK}     -to [get_ports {VZ80_ADDR[*]}] 50.00
set_max_delay -from {softZPU:\CPU1:ZPUCPU|zpu_core_evo:ZPU0|MEM_BUSACK}     -to [get_ports {VZ80_DATA[*]}] 50.00
 
#**************************************************************
# Set Minimum Delay
#**************************************************************
set_min_delay -from {softZPU:\CPU1:ZPUCPU|ZPU80_BUSACKn}                    -to [get_ports {VZ80_ADDR[*]}] 0.00
set_min_delay -from {softZPU:\CPU1:ZPUCPU|\Z80BUS:Z80_ADDR[*]}              -to [get_ports {VZ80_ADDR[*]}] 0.00
set_min_delay -from {softZPU:\CPU1:ZPUCPU|\Z80BUS:Z80_BYTE_ADDR[*]}         -to [get_ports {VZ80_ADDR[*]}] 0.00
set_min_delay -from {softZPU:\CPU1:ZPUCPU|ZPU_RESETn}                       -to [get_ports {VZ80_ADDR[*]}] 0.00
set_min_delay -from {softZPU:\CPU1:ZPUCPU|zpu_core_evo:ZPU0|MEM_BUSACK}     -to [get_ports {VZ80_ADDR[*]}] 0.00
set_min_delay -from {softZPU:\CPU1:ZPUCPU|zpu_core_evo:ZPU0|MEM_BUSACK}     -to [get_ports {VZ80_DATA[*]}] 0.00
 
#**************************************************************
# Set Input Transition
#**************************************************************
