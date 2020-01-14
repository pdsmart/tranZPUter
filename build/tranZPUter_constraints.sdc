## Generated SDC file "E115_zpu.out.sdc"

## Copyright (C) 2017  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 17.1.1 Internal Build 593 12/11/2017 SJ Standard Edition"

## DATE    "Sat Jun 22 23:32:00 2019"

##
## DEVICE  "EP4CE115F23I7"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk_12} -period 83.333 -waveform { 0.000 0.500 } [get_ports {CLOCK_12M}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {SYSCLK} -source [get_ports {CLOCK_12M}] -duty_cycle 50.000 -multiply_by 25 -divide_by 3 -phase 0 -master_clock {clk_12} {mypll|altpll_component|auto_generated|pll1|clk[0]}
create_generated_clock -name {MEMCLK} -source [get_ports {CLOCK_12M}] -duty_cycle 50.000 -multiply_by 25 -divide_by 4 -phase 0 -master_clock {clk_12} {mypll|altpll_component|auto_generated|pll1|clk[1]} 

#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

derive_clock_uncertainty
#set_clock_uncertainty -rise_from [get_clocks {SYSCLK}] -rise_to [get_clocks {SYSCLK}]  0.020  
#set_clock_uncertainty -rise_from [get_clocks {SYSCLK}] -fall_to [get_clocks {SYSCLK}]  0.020  
#set_clock_uncertainty -fall_from [get_clocks {SYSCLK}] -rise_to [get_clocks {SYSCLK}]  0.020  
#set_clock_uncertainty -fall_from [get_clocks {SYSCLK}] -fall_to [get_clocks {SYSCLK}]  0.020
#set_clock_uncertainty -rise_from [get_clocks {SYSCLK}] -rise_to [get_clocks {SYSCLK}]  0.020  
#set_clock_uncertainty -rise_from [get_clocks {SYSCLK}] -fall_to [get_clocks {SYSCLK}]  0.020  
#set_clock_uncertainty -rise_from [get_clocks {SYSCLK}] -rise_to [get_clocks {MEMCLK}]  0.020  
#set_clock_uncertainty -rise_from [get_clocks {SYSCLK}] -fall_to [get_clocks {MEMCLK}]  0.020  
#set_clock_uncertainty -fall_from [get_clocks {SYSCLK}] -rise_to [get_clocks {SYSCLK}]  0.020  
#set_clock_uncertainty -fall_from [get_clocks {SYSCLK}] -fall_to [get_clocks {SYSCLK}]  0.020  
#set_clock_uncertainty -fall_from [get_clocks {SYSCLK}] -rise_to [get_clocks {MEMCLK}]  0.020  
#set_clock_uncertainty -fall_from [get_clocks {SYSCLK}] -fall_to [get_clocks {MEMCLK}]  0.020  
#set_clock_uncertainty -rise_from [get_clocks {MEMCLK}] -rise_to [get_clocks {SYSCLK}]  0.020  
#set_clock_uncertainty -rise_from [get_clocks {MEMCLK}] -fall_to [get_clocks {SYSCLK}]  0.020  
#set_clock_uncertainty -rise_from [get_clocks {MEMCLK}] -rise_to [get_clocks {MEMCLK}]  0.020  
#set_clock_uncertainty -rise_from [get_clocks {MEMCLK}] -fall_to [get_clocks {MEMCLK}]  0.020  
#set_clock_uncertainty -fall_from [get_clocks {MEMCLK}] -rise_to [get_clocks {SYSCLK}]  0.020  
#set_clock_uncertainty -fall_from [get_clocks {MEMCLK}] -fall_to [get_clocks {SYSCLK}]  0.020  
#set_clock_uncertainty -fall_from [get_clocks {MEMCLK}] -rise_to [get_clocks {MEMCLK}]  0.020  
#set_clock_uncertainty -fall_from [get_clocks {MEMCLK}] -fall_to [get_clocks {MEMCLK}]  0.020


#**************************************************************
# Set Input Delay
#**************************************************************

# Delays for async signals - not necessary, but might as well avoid
# having unconstrained ports in the design
#set_input_delay -clock sysclk -min 0.5 [get_ports {UART_RXD}]
#set_input_delay -clock sysclk -max 0.5 [get_ports {UART_RXD}]


#**************************************************************
# Set Output Delay
#**************************************************************

#set_output_delay -add_delay  -clock [get_clocks {sysclk}]  0.500 [get_ports {LED[0]}]
#set_output_delay -add_delay  -clock [get_clocks {sysclk}]  0.500 [get_ports {LED[1]}]
#set_output_delay -add_delay  -clock [get_clocks {sysclk}]  0.500 [get_ports {LED[2]}]
#set_output_delay -add_delay  -clock [get_clocks {sysclk}]  0.500 [get_ports {LED[3]}]
#set_output_delay -add_delay  -clock [get_clocks {sysclk}]  0.500 [get_ports {LED[4]}]
#set_output_delay -add_delay  -clock [get_clocks {sysclk}]  0.500 [get_ports {LED[5]}]
#set_output_delay -add_delay  -clock [get_clocks {sysclk}]  0.500 [get_ports {LED[6]}]
#set_output_delay -add_delay  -clock [get_clocks {sysclk}]  0.500 [get_ports {LED[7]}]


#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************

set_false_path -from [get_keepers {USER_BTN*}] 
#set_false_path -from [get_keepers {SW*}] 
#set_false_path -from [get_cells {myVirtualToplevel|RESET_n}]

#set_false_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1[*][*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]  

#**************************************************************
# Set Multicycle Path
#**************************************************************
#set_multicycle_path -from [get_clocks {SYSCLK}] -to [get_clocks {SYSCLK}] -setup -start 1
#set_multicycle_path -from [get_clocks {SYSCLK}] -to [get_clocks {SYSCLK}] -hold -end 1
## Setup
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|IO_DATA_READ[*]}]                                            -to [get_keepers {zpu_soc:myVirtualToplevel|SinglePortBootBRAM:\ZPUBRAMEVO:ZPUBRAM|altsyncram:*}] -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|IO_DATA_READ[*]}]                                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxTOS.word[*]}]             -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1FetchIdx[*]}]        -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1[*][*]}]             -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1StartAddr[*]}]       -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|divQuotientFractional[*]}]  -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|divStart}]                  -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|idimFlag}]                  -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|l1State*}]                  -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoWriteIdx[*]}]         -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|NOS*}]                      -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                     -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|sp[*]}]                     -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|state*}]                    -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS*}]                      -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1[*]*}]               -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoWriteIdx[*]}]         -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|NOS*}]                      -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                     -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|sp[*]}]                     -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS*}]                      -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1FetchIdx[*]}]        -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1[*][*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|divQuotientFractional[*]}]  -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1[*][*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|divStart}]                  -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1[*][*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|idimFlag}]                  -setup -end 2

#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1[*][*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*].addr[*]}]                -setup -start 2

#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1[*][*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoWriteIdx[*]}]         -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1[*][*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|NOS*}]                      -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1[*][*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                     -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1[*][*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|sp[*]}]                     -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1[*][*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|state*}]                    -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1[*][*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS*}]                      -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|SinglePortBootBRAM:\ZPUBRAMEVO:ZPUBRAM|*}]            -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|SinglePortBRAM:\ZPURAMEVO:ZPURAM|*}]                  -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1[*][*]}]             -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteAddr[*]}]       -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteByte}]          -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteHword}]         -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]               -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoReadIdx[*]}]          -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoWriteIdx[*]}]         -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|NOS*}]                      -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                     -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|sp[*]}]                     -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS*}]                      -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|SinglePortBootBRAM:\ZPUBRAMEVO:ZPUBRAM|*}]            -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|SinglePortBRAM:\ZPURAMEVO:ZPURAM|*}]                  -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1[*][*]}]             -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteAddr[*]}]       -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]               -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoReadIdx[*]}]          -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoWriteIdx[*]}]         -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|NOS.word[*]}]               -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                     -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|sp[*]}]                     -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS*}]                      -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|divComplete}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|dividendCopy[*]}]                  -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|dividendCopy[*]}]           -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|dividendCopy[*]}]                  -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|divResult*}]                -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|divisorCopy[*]}]                   -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|dividendCopy[*]}]           -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|divisorCopy[*]}]                   -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|divResult*}]                -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|divStart}]                         -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|evo_L2cache:CACHEL2|altsyncram:*}] -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1[*][*]}]             -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|idimFlag}]                         -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*].addr[*]}]         -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|IO_DATA_READ[*]}]                                     -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|SinglePortBootBRAM:\ZPUBRAMEVO:ZPUBRAM|*}]            -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|SinglePortBRAM:\ZPURAMEVO:ZPURAM|*}]                  -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|uart:UART1|TX_FIFO*}]                                 -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteAddr[*]}]       -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteData[*]}]       -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]               -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_DATA_OUT[*]}]           -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxNOS.word[*]}]             -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxTOS.word[*]}]             -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoReadIdx[*]}]                 -to [get_keepers {zpu_soc:myVirtualToplevel|SinglePortBootBRAM:\ZPUBRAMEVO:ZPUBRAM|*}]            -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoReadIdx[*]}]                 -to [get_keepers {zpu_soc:myVirtualToplevel|SinglePortBRAM:\ZPURAMEVO:ZPURAM|*}]                  -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoReadIdx[*]}]                 -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteAddr[*]}]       -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoReadIdx[*]}]                 -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteByte}]          -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoReadIdx[*]}]                 -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteData[*]}]       -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoReadIdx[*]}]                 -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteHword}]         -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoReadIdx[*]}]                 -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2Write}]              -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoReadIdx[*]}]                 -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]               -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoReadIdx[*]}]                 -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_DATA_OUT[*]}]           -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoReadIdx[*]}]                 -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoReadIdx[*]}]          -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                       -to [get_keepers {zpu_soc:myVirtualToplevel|SinglePortBootBRAM:\ZPUBRAMEVO:ZPUBRAM|*}]            -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                       -to [get_keepers {zpu_soc:myVirtualToplevel|SinglePortBRAM:\ZPURAMEVO:ZPURAM|*}]                  -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                       -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteAddr[*]}]       -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                       -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteByte}]          -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                       -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteData[*]}]       -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                       -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteHword}]         -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                       -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2Write}]              -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                       -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]               -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                       -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_DATA_OUT[*]}]           -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                       -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoReadIdx[*]}]          -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoWriteIdx[*]}]                -to [get_keepers {zpu_soc:myVirtualToplevel|SinglePortBootBRAM:\ZPUBRAMEVO:ZPUBRAM|*}]            -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoWriteIdx[*]}]                -to [get_keepers {zpu_soc:myVirtualToplevel|SinglePortBRAM:\ZPURAMEVO:ZPURAM|*}]                  -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoWriteIdx[*]}]                -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteAddr[*]}]       -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoWriteIdx[*]}]                -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]               -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoWriteIdx[*]}]                -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoReadIdx[*]}]          -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoWriteIdx[*]}]                -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxNOS.valid}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxNOS.valid}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                     -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxNOS.valid}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|sp[*]}]                     -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxNOS.valid}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.word[*]}]               -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxNOS.word[*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                     -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxNOS.word[*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.word[*]}]               -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxTOS.valid}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxTOS.valid}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoWriteIdx[*]}]         -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxTOS.valid}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                     -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxTOS.valid}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|sp[*]}]                     -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxTOS.valid}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.word[*]}]               -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxTOS.word[*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*].addr[*]}]         -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxTOS.word[*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                     -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxTOS.word[*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.word[*]}]               -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|NOS.valid}]                        -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|NOS.valid}]                        -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                     -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|NOS.valid}]                        -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|sp[*]}]                     -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|NOS.valid}]                        -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.word[*]}]               -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|NOS.word[*]}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                     -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|NOS.word[*]}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.word[*]}]               -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|SinglePortBootBRAM:\ZPUBRAMEVO:ZPUBRAM|*}]            -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|SinglePortBRAM:\ZPURAMEVO:ZPURAM|*}]                  -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1FetchIdx[*]}]        -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1[*][*]}]             -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1StartAddr[*]}]       -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2StartAddr[*]}]       -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteAddr[*]}]       -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|divQuotientFractional[*]}]  -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|divStart}]                  -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|idimFlag}]                  -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|inBreak}]                   -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|l1State*}]                  -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]               -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoReadIdx[*]}]          -setup -end 2

#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*].addr[*]}]                -setup -end 2

#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoWriteIdx[*]}]         -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|NOS*}]                      -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                     -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|sp[*]}]                     -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|state*}]                    -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|state.State_Execute}]       -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS*}]                      -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|sp[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.word[*]}]               -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|state*}]                           -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.valid}]                        -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.valid}]                        -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                     -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.valid}]                        -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|sp[*]}]                     -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.valid}]                        -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.word[*]}]               -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.word[*]}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                     -setup -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.word[*]}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.word[*]}]               -setup -end 2
## Hold
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1FetchIdx[*]}]        -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|SinglePortBootBRAM:\ZPUBRAMEVO:ZPUBRAM|*}]            -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|SinglePortBRAM:\ZPURAMEVO:ZPURAM|*}]                  -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]               -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|dividendCopy[*]*}]                 -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|dividendCopy[*]*}]          -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|dividendCopy[*]*}]                 -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|divResult[*]*}]             -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|divisorCopy[*]}]                   -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|dividendCopy[*]*}]          -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|divisorCopy[*]}]                   -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|divResult[*]*}]             -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|IO_DATA_READ[*]}]                                     -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|SinglePortBootBRAM:\ZPUBRAMEVO:ZPUBRAM|*}]            -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|SinglePortBRAM:\ZPURAMEVO:ZPURAM|*}]                  -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]               -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*].data[*]}]                -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteData[*]}]       -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*].data[*]}]                -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_DATA_OUT[*]}]           -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoReadIdx[*]}]                 -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoReadIdx[*]}]          -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxTOS.word[*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                     -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1FetchIdx[*]}]        -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1StartAddr[*]}]       -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2StartAddr[*]}]       -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                     -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|state*}]                           -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.word[*]}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.word[*]}]               -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxTOS.word[*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.word[*]}]               -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxNOS.word[*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.word[*]}]               -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1[*][*]}]             -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1FetchIdx[*]}]        -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1[*][*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                     -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1[*][*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|state*}]                    -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteAddr[*]}]       -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]               -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|divComplete}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|divStart}]                         -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteData[*]}]       -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_DATA_OUT[*]}]           -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxTOS.word[*]}]             -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*].addr[*]}]                -to [get_keepers {zpu_soc:myVirtualToplevel|SinglePortBootBRAM:\ZPUBRAMEVO:ZPUBRAM|*}]            -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*].addr[*]}]                -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteAddr[*]}]       -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*].addr[*]}]                -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]               -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoReadIdx[*]}]                 -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteByte}]          -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoReadIdx[*]}]                 -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteData[*]}]       -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoReadIdx[*]}]                 -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteHword}]         -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoReadIdx[*]}]                 -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_DATA_OUT[*]}]           -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoWriteIdx[*]}]                -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxNOS.valid}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxNOS.valid}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.word[*]}]               -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxTOS.valid}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxTOS.valid}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                     -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxTOS.valid}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|sp[*]}]                     -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxTOS.valid}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.word[*]}]               -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|NOS.valid}]                        -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|NOS.valid}]                        -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.word[*]}]               -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|NOS.word[*]}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.word[*]}]               -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.word[*]}]               -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|sp[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.word[*]}]               -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.word[*]}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                     -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|IO_DATA_READ[*]}]                                            -to [get_keepers {zpu_soc:myVirtualToplevel|SinglePortBootBRAM:\ZPUBRAMEVO:ZPUBRAM|altsyncram:*}] -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|IO_DATA_READ[*]}]                                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxTOS.word[*]}]             -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1FetchIdx[*]}]        -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1[*][*]}]             -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1StartAddr[*]}]       -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|divQuotientFractional[*]}]  -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|divStart}]                  -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|idimFlag}]                  -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|l1State*}]                  -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoWriteIdx[*]}]         -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|NOS*}]                      -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                     -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|sp[*]}]                     -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|state*}]                    -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS*}]                      -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1[*]*}]               -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoWriteIdx[*]}]         -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|NOS*}]                      -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                     -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|sp[*]}]                     -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS*}]                      -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1FetchIdx[*]}]        -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1[*][*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|divQuotientFractional[*]}]  -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1[*][*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|divStart}]                  -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1[*][*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|idimFlag}]                  -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1[*][*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1[*][*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoWriteIdx[*]}]         -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1[*][*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|NOS*}]                      -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1[*][*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                     -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1[*][*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|sp[*]}]                     -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1[*][*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|state*}]                    -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1[*][*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS*}]                      -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|SinglePortBootBRAM:\ZPUBRAMEVO:ZPUBRAM|*}]            -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|SinglePortBRAM:\ZPURAMEVO:ZPURAM|*}]                  -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1[*][*]}]             -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteAddr[*]}]       -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteByte}]          -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteHword}]         -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]               -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoReadIdx[*]}]          -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoWriteIdx[*]}]         -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|NOS*}]                      -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                     -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|sp[*]}]                     -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2FetchIdx[*]}]               -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS*}]                      -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|SinglePortBootBRAM:\ZPUBRAMEVO:ZPUBRAM|*}]            -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|SinglePortBRAM:\ZPURAMEVO:ZPURAM|*}]                  -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1[*][*]}]             -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteAddr[*]}]       -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]               -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoReadIdx[*]}]          -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoWriteIdx[*]}]         -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|NOS.word[*]}]               -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                     -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|sp[*]}]                     -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2StartAddr[*]}]              -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS*}]                      -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|divComplete}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|dividendCopy[*]}]                  -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|dividendCopy[*]}]           -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|dividendCopy[*]}]                  -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|divResult*}]                -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|divisorCopy[*]}]                   -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|dividendCopy[*]}]           -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|divisorCopy[*]}]                   -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|divResult*}]                -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|divStart}]                         -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|evo_L2cache:CACHEL2|altsyncram:*}] -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1[*][*]}]             -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|idimFlag}]                         -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*].addr[*]}]         -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|IO_DATA_READ[*]}]                                     -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|SinglePortBootBRAM:\ZPUBRAMEVO:ZPUBRAM|*}]            -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|SinglePortBRAM:\ZPURAMEVO:ZPURAM|*}]                  -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|uart:UART1|TX_FIFO*}]                                 -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteAddr[*]}]       -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteData[*]}]       -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]               -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_DATA_OUT[*]}]           -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxNOS.word[*]}]             -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxTOS.word[*]}]             -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoReadIdx[*]}]                 -to [get_keepers {zpu_soc:myVirtualToplevel|SinglePortBootBRAM:\ZPUBRAMEVO:ZPUBRAM|*}]            -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoReadIdx[*]}]                 -to [get_keepers {zpu_soc:myVirtualToplevel|SinglePortBRAM:\ZPURAMEVO:ZPURAM|*}]                  -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoReadIdx[*]}]                 -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteAddr[*]}]       -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoReadIdx[*]}]                 -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteByte}]          -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoReadIdx[*]}]                 -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteData[*]}]       -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoReadIdx[*]}]                 -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteHword}]         -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoReadIdx[*]}]                 -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2Write}]              -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoReadIdx[*]}]                 -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]               -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoReadIdx[*]}]                 -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_DATA_OUT[*]}]           -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoReadIdx[*]}]                 -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoReadIdx[*]}]          -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                       -to [get_keepers {zpu_soc:myVirtualToplevel|SinglePortBootBRAM:\ZPUBRAMEVO:ZPUBRAM|*}]            -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                       -to [get_keepers {zpu_soc:myVirtualToplevel|SinglePortBRAM:\ZPURAMEVO:ZPURAM|*}]                  -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                       -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteAddr[*]}]       -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                       -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteByte}]          -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                       -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteData[*]}]       -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                       -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteHword}]         -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                       -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2Write}]              -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                       -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]               -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                       -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_DATA_OUT[*]}]           -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                       -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoReadIdx[*]}]          -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoWriteIdx[*]}]                -to [get_keepers {zpu_soc:myVirtualToplevel|SinglePortBootBRAM:\ZPUBRAMEVO:ZPUBRAM|*}]            -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoWriteIdx[*]}]                -to [get_keepers {zpu_soc:myVirtualToplevel|SinglePortBRAM:\ZPURAMEVO:ZPURAM|*}]                  -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoWriteIdx[*]}]                -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteAddr[*]}]       -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoWriteIdx[*]}]                -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]               -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoWriteIdx[*]}]                -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoReadIdx[*]}]          -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoWriteIdx[*]}]                -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxNOS.valid}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxNOS.valid}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                     -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxNOS.valid}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|sp[*]}]                     -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxNOS.valid}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.word[*]}]               -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxNOS.word[*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                     -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxNOS.word[*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.word[*]}]               -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxTOS.valid}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxTOS.valid}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoWriteIdx[*]}]         -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxTOS.valid}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                     -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxTOS.valid}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|sp[*]}]                     -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxTOS.valid}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.word[*]}]               -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxTOS.word[*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*].addr[*]}]         -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxTOS.word[*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                     -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxTOS.word[*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.word[*]}]               -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|NOS.valid}]                        -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|NOS.valid}]                        -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                     -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|NOS.valid}]                        -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|sp[*]}]                     -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|NOS.valid}]                        -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.word[*]}]               -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|NOS.word[*]}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                     -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|NOS.word[*]}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.word[*]}]               -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|SinglePortBootBRAM:\ZPUBRAMEVO:ZPUBRAM|*}]            -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|SinglePortBRAM:\ZPURAMEVO:ZPURAM|*}]                  -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1FetchIdx[*]}]        -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1[*][*]}]             -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL1StartAddr[*]}]       -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2StartAddr[*]}]       -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteAddr[*]}]       -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|divQuotientFractional[*]}]  -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|divStart}]                  -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|idimFlag}]                  -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|inBreak}]                   -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|l1State*}]                  -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]               -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoReadIdx[*]}]          -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifoWriteIdx[*]}]         -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|NOS*}]                      -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                     -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|sp[*]}]                     -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|state*}]                    -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|state.State_Execute}]       -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS*}]                      -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|sp[*]}]                            -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.word[*]}]               -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|state*}]                           -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.valid}]                        -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxFifo[*]*}]                -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.valid}]                        -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                     -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.valid}]                        -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|sp[*]}]                     -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.valid}]                        -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.word[*]}]               -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.word[*]}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|pc[*]}]                     -hold -start 1
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.word[*]}]                      -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|TOS.word[*]}]               -hold -start 1

#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|SDRAM:\ZPUSDRAMEVO:ZPUSDRAM|sdDone}]                         -to [get_keepers {zpu_soc:myVirtualToplevel|SDRAM:\ZPUSDRAMEVO:ZPUSDRAM|cpuBusy}]                 -hold -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|SDRAM:\ZPUSDRAMEVO:ZPUSDRAM|sdDone}]                         -to [get_keepers {zpu_soc:myVirtualToplevel|SDRAM:\ZPUSDRAMEVO:ZPUSDRAM|sdDoneLast}]              -hold -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|SDRAM:\ZPUSDRAMEVO:ZPUSDRAM|DATA_OUT[*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|SinglePortBootBRAM:\ZPUBRAMEVO:ZPUBRAM|*}]            -hold -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|SDRAM:\ZPUSDRAMEVO:ZPUSDRAM|DATA_OUT[*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|SinglePortBRAM:\ZPURAMEVO:ZPURAM|*}]                  -hold -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|SDRAM:\ZPUSDRAMEVO:ZPUSDRAM|DATA_OUT[*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteAddr[*]}]       -hold -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|SDRAM:\ZPUSDRAMEVO:ZPUSDRAM|DATA_OUT[*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|cacheL2WriteData[*]}]       -hold -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|SDRAM:\ZPUSDRAMEVO:ZPUSDRAM|DATA_OUT[*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_ADDR[*]}]               -hold -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|SDRAM:\ZPUSDRAMEVO:ZPUSDRAM|DATA_OUT[*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|MEM_DATA_OUT[*]}]           -hold -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|SDRAM:\ZPUSDRAMEVO:ZPUSDRAM|DATA_OUT[*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxNOS.word[*]}]             -hold -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|SDRAM:\ZPUSDRAMEVO:ZPUSDRAM|DATA_OUT[*]}]                    -to [get_keepers {zpu_soc:myVirtualToplevel|zpu_core_evo:\ZPUEVO:ZPU0|mxTOS.word[*]}]             -hold -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|SDRAM:\ZPUSDRAMEVO:ZPUSDRAM|isReady}]                        -to [get_keepers {zpu_soc:myVirtualToplevel|SDRAM:\ZPUSDRAMEVO:ZPUSDRAM|cpuBusy}]                 -hold -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|SDRAM:\ZPUSDRAMEVO:ZPUSDRAM|isReady}]                        -to [get_keepers {zpu_soc:myVirtualToplevel|SDRAM:\ZPUSDRAMEVO:ZPUSDRAM|cpuDataIn[*]}]            -hold -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|SDRAM:\ZPUSDRAMEVO:ZPUSDRAM|isReady}]                        -to [get_keepers {zpu_soc:myVirtualToplevel|SDRAM:\ZPUSDRAMEVO:ZPUSDRAM|cpuDQM[*]}]               -hold -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|SDRAM:\ZPUSDRAMEVO:ZPUSDRAM|isReady}]                        -to [get_keepers {zpu_soc:myVirtualToplevel|SDRAM:\ZPUSDRAMEVO:ZPUSDRAM|sdDoneLast}]              -hold -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|SDRAM:\ZPUSDRAMEVO:ZPUSDRAM|sdDone}]                         -to [get_keepers {zpu_soc:myVirtualToplevel|SDRAM:\ZPUSDRAMEVO:ZPUSDRAM|sdIsWriting}]             -hold -end 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|SDRAM:\ZPUSDRAMEVO:ZPUSDRAM|isReady}]                        -to [get_keepers {zpu_soc:myVirtualToplevel|SDRAM:\ZPUSDRAMEVO:ZPUSDRAM|sdBank[*]}]               -hold -start 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|SDRAM:\ZPUSDRAMEVO:ZPUSDRAM|isReady}]                        -to [get_keepers {zpu_soc:myVirtualToplevel|SDRAM:\ZPUSDRAMEVO:ZPUSDRAM|sdCol[*]}]                -hold -start 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|SDRAM:\ZPUSDRAMEVO:ZPUSDRAM|isReady}]                        -to [get_keepers {zpu_soc:myVirtualToplevel|SDRAM:\ZPUSDRAMEVO:ZPUSDRAM|sdIsWriting}]             -hold -start 2
#set_multicycle_path -from [get_keepers {zpu_soc:myVirtualToplevel|SDRAM:\ZPUSDRAMEVO:ZPUSDRAM|isReady}]                        -to [get_keepers {zpu_soc:myVirtualToplevel|SDRAM:\ZPUSDRAMEVO:ZPUSDRAM|sdRow[*]}]                -hold -start 2

#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

