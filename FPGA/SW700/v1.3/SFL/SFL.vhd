-- megafunction wizard: %Serial Flash Loader%
-- GENERATION: STANDARD
-- VERSION: WM1.0
-- MODULE: altserial_flash_loader 

-- ============================================================
-- File Name: SFL.vhd
-- Megafunction Name(s):
-- 			altserial_flash_loader
--
-- Simulation Library Files(s):
-- 			altera_mf
-- ============================================================
-- ************************************************************
-- THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
--
-- 13.1.0 Build 162 10/23/2013 SJ Full Version
-- ************************************************************


--Copyright (C) 1991-2013 Altera Corporation
--Your use of Altera Corporation's design tools, logic functions 
--and other software and tools, and its AMPP partner logic 
--functions, and any output files from any of the foregoing 
--(including device programming or simulation files), and any 
--associated documentation or information are expressly subject 
--to the terms and conditions of the Altera Program License 
--Subscription Agreement, Altera MegaCore Function License 
--Agreement, or other applicable license agreement, including, 
--without limitation, that your use is for the sole purpose of 
--programming logic devices manufactured by Altera and sold by 
--Altera or its authorized distributors.  Please refer to the 
--applicable agreement for further details.


LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY altera_mf;
USE altera_mf.all;

ENTITY SFL IS
	PORT
	(
		noe_in		: IN STD_LOGIC 
	);
END SFL;


ARCHITECTURE SYN OF sfl IS




	COMPONENT altserial_flash_loader
	GENERIC (
		enable_quad_spi_support		: NATURAL;
		enable_shared_access		: STRING;
		enhanced_mode		: NATURAL;
		intended_device_family		: STRING;
		lpm_type		: STRING
	);
	PORT (
			noe	: IN STD_LOGIC 
	);
	END COMPONENT;

BEGIN

	altserial_flash_loader_component : altserial_flash_loader
	GENERIC MAP (
		enable_quad_spi_support => 0,
		enable_shared_access => "OFF",
		enhanced_mode => 1,
		intended_device_family => "Cyclone IV E",
		lpm_type => "altserial_flash_loader"
	)
	PORT MAP (
		noe => noe_in
	);



END SYN;

-- ============================================================
-- CNX file retrieval info
-- ============================================================
-- Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Cyclone IV E"
-- Retrieval info: LIBRARY: altera_mf altera_mf.altera_mf_components.all
-- Retrieval info: CONSTANT: ENABLE_QUAD_SPI_SUPPORT NUMERIC "0"
-- Retrieval info: CONSTANT: ENABLE_SHARED_ACCESS STRING "OFF"
-- Retrieval info: CONSTANT: ENHANCED_MODE NUMERIC "1"
-- Retrieval info: CONSTANT: INTENDED_DEVICE_FAMILY STRING "Cyclone IV E"
-- Retrieval info: USED_PORT: noe_in 0 0 0 0 INPUT NODEFVAL "noe_in"
-- Retrieval info: CONNECT: @noe 0 0 0 0 noe_in 0 0 0 0
-- Retrieval info: GEN_FILE: TYPE_NORMAL SFL.vhd TRUE
-- Retrieval info: GEN_FILE: TYPE_NORMAL SFL.inc FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL SFL.cmp TRUE
-- Retrieval info: GEN_FILE: TYPE_NORMAL SFL.bsf FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL SFL_inst.vhd TRUE
-- Retrieval info: LIB_FILE: altera_mf
