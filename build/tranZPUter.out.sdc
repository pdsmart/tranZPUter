## Generated SDC file "tranZPUter.out.sdc"

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

## DATE    "Tue Sep 17 13:54:17 2019"

##
## DEVICE  "10CL025YU256C8G"
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

create_generated_clock -name {SYSCLK} -source [get_ports {CLOCK_12M}] -duty_cycle 50.000 -multiply_by 25 -divide_by 3 -master_clock {clk_12} [get_nets {mypll|altpll_component|_clk0}] 
create_generated_clock -name {MEMCLK} -source [get_ports {CLOCK_12M}] -duty_cycle 50.000 -multiply_by 50 -divide_by 3 -master_clock {clk_12} [get_nets {mypll|altpll_component|_clk1}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {SYSCLK}] -rise_to [get_clocks {SYSCLK}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {SYSCLK}] -fall_to [get_clocks {SYSCLK}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {SYSCLK}] -rise_to [get_clocks {MEMCLK}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {SYSCLK}] -fall_to [get_clocks {MEMCLK}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {SYSCLK}] -rise_to [get_clocks {SYSCLK}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {SYSCLK}] -fall_to [get_clocks {SYSCLK}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {SYSCLK}] -rise_to [get_clocks {MEMCLK}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {SYSCLK}] -fall_to [get_clocks {MEMCLK}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {MEMCLK}] -rise_to [get_clocks {SYSCLK}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {MEMCLK}] -fall_to [get_clocks {SYSCLK}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {MEMCLK}] -rise_to [get_clocks {MEMCLK}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {MEMCLK}] -fall_to [get_clocks {MEMCLK}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {MEMCLK}] -rise_to [get_clocks {SYSCLK}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {MEMCLK}] -fall_to [get_clocks {SYSCLK}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {MEMCLK}] -rise_to [get_clocks {MEMCLK}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {MEMCLK}] -fall_to [get_clocks {MEMCLK}]  0.020


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

set_false_path -from [get_keepers {USER_BTN*}] 


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

