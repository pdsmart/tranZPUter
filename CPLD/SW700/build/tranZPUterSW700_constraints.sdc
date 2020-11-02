## Generated SDC file "tranZPUterSW700.out.sdc"

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

# Standard mainboard clock. If using tranZPUter on a different host then set to the host frequency.
create_clock -name {SYSCLK} -period 282.486 -waveform { 0.000 141.243 } [get_ports { SYSCLK }]

# For K64F
create_clock -name {CTLCLK} -period 50.000 -waveform { 0.000 25.000 }   [ get_ports { CTLCLK }]

# For basic board with oscillator.
#create_clock -name {CTLCLK} -period 20.000 -waveform { 0.000 10.000 }   [ get_ports { CTLCLK }]
#create_clock -name {cpld512:cpldl512Toplevel|CTLCLKi} -period 280.000 -waveform { 0.000 140.000 } [ get_keepers {cpld512:cpldl512Toplevel|CTLCLKi} ]
##create_clock -name {Z80_CLK} -period 50.000 -waveform { 0.000 25.000 } [get_ports { CTLCLK }]


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

set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {CTL_BUSACKn}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {CTL_BUSRQn}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {CTL_WAITn}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {SYS_BUSRQn}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {SYS_WAITn}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {Z80_ADDR[0]}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {Z80_ADDR[1]}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {Z80_ADDR[2]}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {Z80_ADDR[3]}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {Z80_ADDR[4]}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {Z80_ADDR[5]}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {Z80_ADDR[6]}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {Z80_ADDR[7]}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {Z80_ADDR[8]}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {Z80_ADDR[9]}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {Z80_ADDR[10]}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {Z80_ADDR[11]}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {Z80_ADDR[12]}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {Z80_ADDR[13]}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {Z80_ADDR[14]}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {Z80_ADDR[15]}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {Z80_BUSACKn}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {Z80_DATA[0]}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {Z80_DATA[1]}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {Z80_DATA[2]}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {Z80_DATA[3]}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {Z80_DATA[4]}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {Z80_DATA[5]}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {Z80_DATA[6]}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {Z80_DATA[7]}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {Z80_HALTn}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {Z80_IORQn}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {Z80_M1n}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {Z80_MREQn}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {Z80_RESETn}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {Z80_RFSHn}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {Z80_WRn}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {Z80_RDn}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {R_IN}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {G_IN}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {B_IN}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {COLR_IN}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {CSYNC_IN}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {CVIDEO_IN}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {HSYNC_IN}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {VSYNC_IN}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {VDATA[0]}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {VDATA[1]}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {VDATA[2]}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {VDATA[3]}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {VDATA[4]}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {VDATA[5]}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {VDATA[6]}]
set_input_delay -add_delay  -clock [get_clocks {SYSCLK}]  1.000 [get_ports {VDATA[7]}]

#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {CTL_CLKSLCT}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {CTL_HALTn}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {CTL_M1n}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {CTL_RFSHn}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {RAM_CSn}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {RAM_OEn}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {RAM_WEn}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {SVCREQn}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {SYS_BUSACKn}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_BUSRQn}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_DATA[0]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_DATA[1]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_DATA[2]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_DATA[3]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_DATA[4]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_DATA[5]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_DATA[6]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_DATA[7]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_ADDR[0]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_ADDR[1]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_ADDR[2]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_ADDR[3]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_ADDR[4]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_ADDR[5]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_ADDR[6]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_ADDR[7]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_ADDR[8]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_ADDR[9]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_ADDR[10]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_ADDR[11]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_ADDR[12]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_ADDR[13]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_ADDR[14]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_ADDR[15]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_HI_ADDR[12]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_HI_ADDR[13]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_HI_ADDR[14]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_HI_ADDR[15]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_HI_ADDR[16]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_HI_ADDR[17]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_HI_ADDR[18]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_MEM[0]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_MEM[1]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_MEM[2]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_MEM[3]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_MEM[4]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_WAITn}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_INTn}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_NMIn}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_MREQn}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {Z80_CLK}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {VADDR[0]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {VADDR[1]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {VADDR[2]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {VADDR[3]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {VADDR[4]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {VADDR[5]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {VADDR[6]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {VADDR[7]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {VADDR[8]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {VADDR[9]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {VADDR[10]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {VADDR[11]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {VADDR[12]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {VADDR[13]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {VADDR[14]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {VADDR[15]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {VDATA[0]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {VDATA[1]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {VDATA[2]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {VDATA[3]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {VDATA[4]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {VDATA[5]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {VDATA[6]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {VDATA[7]}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {VZ80_CLK}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {VZ80_IORQn}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {VZ80_RDn}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {VZ80_WRn}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {V_R}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {V_G}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {V_B}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {V_COLR}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {V_CSYNC}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {V_CVIDEO}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {V_HSYNC}]
set_output_delay -add_delay  -clock [get_clocks {SYSCLK}]  5.000 [get_ports {V_VSYNC}]

# For K64F
set_output_delay -add_delay  -clock [get_clocks {CTLCLK}]  5.000 [get_ports {Z80_CLK}]

# For basic board with oscillator.
#set_output_delay -add_delay  -clock [get_clocks {cpld512:cpldl512Toplevel|CTLCLKi}]  5.000 [get_ports {Z80_CLK}]


#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************

# For K64F
set_false_path -from [get_clocks {CTLCLK}] -to [get_clocks {SYSCLK}]
set_false_path -from [get_clocks {SYSCLK}] -to [get_clocks {CTLCLK}]

# For basic board with oscillator.
#set_false_path -from [get_clocks {cpld512:cpldl512Toplevel|CTLCLKi}] -to [get_clocks {SYSCLK}]
#set_false_path -from [get_clocks {cpld512:cpldl512Toplevel|CTLCLKi}] -to [get_clocks {CTLCLK}]
#set_false_path -from [get_clocks {SYSCLK}] -to [get_clocks {cpld512:cpldl512Toplevel|CTLCLKi}]
#set_false_path -from [get_clocks {SYSCLK}] -to [get_clocks {CTLCLK}]

# For both configurations.
set_false_path -from {cpld512:cpldl512Toplevel|KEY_SUBSTITUTE} -to {cpld512:cpldl512Toplevel|CTLCLK_Q}
set_false_path -from {cpld512:cpldl512Toplevel|MEM_MODE_LATCH[4]} -to {cpld512:cpldl512Toplevel|CTLCLK_Q}
set_false_path -from {cpld512:cpldl512Toplevel|MEM_MODE_LATCH[3]} -to {cpld512:cpldl512Toplevel|CTLCLK_Q}
set_false_path -from {cpld512:cpldl512Toplevel|MEM_MODE_LATCH[2]} -to {cpld512:cpldl512Toplevel|CTLCLK_Q}
set_false_path -from {cpld512:cpldl512Toplevel|MEM_MODE_LATCH[1]} -to {cpld512:cpldl512Toplevel|CTLCLK_Q}
set_false_path -from {cpld512:cpldl512Toplevel|MEM_MODE_LATCH[0]} -to {cpld512:cpldl512Toplevel|CTLCLK_Q}

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

