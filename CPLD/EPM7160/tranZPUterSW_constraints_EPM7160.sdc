## Generated SDC file "tranZPUterSW.out.sdc"

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
## VERSION "Version 13.0.1 Build 232 06/12/2013 Service Pack 1 SJ Web Edition"

## DATE    "Fri Jun 26 22:10:05 2020"

##
## DEVICE  "EPM7160STC100-10"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {SYSCLK} -period 500.000 -waveform { 0.000 250.000 } [get_ports { SYSCLK }]
create_clock -name {CTLCLK} -period 50.000 -waveform { 0.000 25.000 } [get_ports { CTLCLK }]


#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************



#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {CTLCLK}]
set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {CTL_BUSACKn}]
set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {CTL_BUSRQn}]
set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {CTL_WAITn}]
set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {SYSCLK}]
set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {SYS_BUSRQn}]
set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {SYS_WAITn}]
set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {Z80_ADDR[0]}]
set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {Z80_ADDR[1]}]
set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {Z80_ADDR[2]}]
set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {Z80_ADDR[3]}]
set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {Z80_ADDR[4]}]
set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {Z80_ADDR[5]}]
set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {Z80_ADDR[6]}]
set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {Z80_ADDR[7]}]
set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {Z80_ADDR[8]}]
set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {Z80_ADDR[9]}]
set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {Z80_ADDR[10]}]
set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {Z80_ADDR[11]}]
set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {Z80_ADDR[12]}]
set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {Z80_ADDR[13]}]
set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {Z80_ADDR[14]}]
set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {Z80_ADDR[15]}]
set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {Z80_BUSACKn}]
set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {Z80_DATA[0]}]
set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {Z80_DATA[1]}]
set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {Z80_DATA[2]}]
set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {Z80_DATA[3]}]
set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {Z80_DATA[4]}]
set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {Z80_DATA[5]}]
set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {Z80_DATA[6]}]
set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {Z80_DATA[7]}]
set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {Z80_HALTn}]
set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {Z80_IORQn}]
set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {Z80_M1n}]
set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {Z80_MREQn}]
set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {Z80_RDn}]
set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {Z80_RESETn}]
set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {Z80_RFSHn}]
set_input_delay -add_delay  -clock [get_clocks {CTLCLK}]  1.000 [get_ports {Z80_WRn}]


#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -add_delay  -clock [get_clocks {CTLCLK}]  5.000 [get_ports {CTL_CLKSLCT}]
set_output_delay -add_delay  -clock [get_clocks {CTLCLK}]  5.000 [get_ports {CTL_HALTn}]
set_output_delay -add_delay  -clock [get_clocks {CTLCLK}]  5.000 [get_ports {CTL_M1n}]
set_output_delay -add_delay  -clock [get_clocks {CTLCLK}]  5.000 [get_ports {CTL_RFSHn}]
set_output_delay -add_delay  -clock [get_clocks {CTLCLK}]  5.000 [get_ports {ENIOWAIT}]
set_output_delay -add_delay  -clock [get_clocks {CTLCLK}]  5.000 [get_ports {RAM_CSn}]
set_output_delay -add_delay  -clock [get_clocks {CTLCLK}]  5.000 [get_ports {RAM_OEn}]
set_output_delay -add_delay  -clock [get_clocks {CTLCLK}]  5.000 [get_ports {RAM_WEn}]
set_output_delay -add_delay  -clock [get_clocks {CTLCLK}]  5.000 [get_ports {SVCREQn}]
set_output_delay -add_delay  -clock [get_clocks {CTLCLK}]  5.000 [get_ports {SYSREQn}]
set_output_delay -add_delay  -clock [get_clocks {CTLCLK}]  5.000 [get_ports {SYS_BUSACKn}]
set_output_delay -add_delay  -clock [get_clocks {CTLCLK}]  5.000 [get_ports {TZ_BUSACKn}]
set_output_delay -add_delay  -clock [get_clocks {CTLCLK}]  5.000 [get_ports {Z80_BUSRQn}]
set_output_delay -add_delay  -clock [get_clocks {CTLCLK}]  5.000 [get_ports {Z80_CLK}]
set_output_delay -add_delay  -clock [get_clocks {CTLCLK}]  5.000 [get_ports {Z80_DATA[0]}]
set_output_delay -add_delay  -clock [get_clocks {CTLCLK}]  5.000 [get_ports {Z80_DATA[1]}]
set_output_delay -add_delay  -clock [get_clocks {CTLCLK}]  5.000 [get_ports {Z80_DATA[2]}]
set_output_delay -add_delay  -clock [get_clocks {CTLCLK}]  5.000 [get_ports {Z80_DATA[3]}]
set_output_delay -add_delay  -clock [get_clocks {CTLCLK}]  5.000 [get_ports {Z80_DATA[4]}]
set_output_delay -add_delay  -clock [get_clocks {CTLCLK}]  5.000 [get_ports {Z80_DATA[5]}]
set_output_delay -add_delay  -clock [get_clocks {CTLCLK}]  5.000 [get_ports {Z80_DATA[6]}]
set_output_delay -add_delay  -clock [get_clocks {CTLCLK}]  5.000 [get_ports {Z80_DATA[7]}]
set_output_delay -add_delay  -clock [get_clocks {CTLCLK}]  5.000 [get_ports {Z80_HI_ADDR[16]}]
set_output_delay -add_delay  -clock [get_clocks {CTLCLK}]  5.000 [get_ports {Z80_HI_ADDR[17]}]
set_output_delay -add_delay  -clock [get_clocks {CTLCLK}]  5.000 [get_ports {Z80_HI_ADDR[18]}]
set_output_delay -add_delay  -clock [get_clocks {CTLCLK}]  5.000 [get_ports {Z80_MEM[0]}]
set_output_delay -add_delay  -clock [get_clocks {CTLCLK}]  5.000 [get_ports {Z80_MEM[1]}]
set_output_delay -add_delay  -clock [get_clocks {CTLCLK}]  5.000 [get_ports {Z80_MEM[2]}]
set_output_delay -add_delay  -clock [get_clocks {CTLCLK}]  5.000 [get_ports {Z80_MEM[3]}]
set_output_delay -add_delay  -clock [get_clocks {CTLCLK}]  5.000 [get_ports {Z80_MEM[4]}]
set_output_delay -add_delay  -clock [get_clocks {CTLCLK}]  5.000 [get_ports {Z80_WAITn}]
set_output_delay -add_delay  -clock [get_clocks {CTLCLK}]  5.000 [get_ports {VADDR[11]}]
set_output_delay -add_delay  -clock [get_clocks {CTLCLK}]  5.000 [get_ports {VADDR[12]}]
set_output_delay -add_delay  -clock [get_clocks {CTLCLK}]  5.000 [get_ports {VADDR[13]}]
set_output_delay -add_delay  -clock [get_clocks {CTLCLK}]  5.000 [get_ports {VMEM_CSn}]


#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

