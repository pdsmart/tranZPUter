EESchema Schematic File Version 4
LIBS:tranZPUter-SW-700_v1_2-cache
EELAYER 29 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 2 6
Title "tranZPUter SW 700 (Z80 Host Upgrade)"
Date "2020-08-17"
Rev "1.2a"
Comp ""
Comment1 "CPU frequency and addition of FPGA to generate advanced video features."
Comment2 "within the Banked RAM, connecting to the base for I/O as needed. Capability to change the"
Comment3 "MZ-80A version, it adds 512K Banked RAM and a CPLD. The CPU can run standalone"
Comment4 "Logic to lift the original Z80 off the main board and add to it's capabilities. Based on the"
$EndDescr
Text Label 1800 2800 0    31   ~ 0
Z80_D0
Text Label 1800 2900 0    31   ~ 0
Z80_D1
Text Label 1800 3000 0    31   ~ 0
Z80_D2
Text Label 1800 3100 0    31   ~ 0
Z80_D3
Text Label 1800 3200 0    31   ~ 0
Z80_D4
Text Label 1800 3300 0    31   ~ 0
Z80_D5
Text Label 1800 3400 0    31   ~ 0
Z80_D6
Text Label 1800 3500 0    31   ~ 0
Z80_D7
Text Label 1800 1100 0    31   ~ 0
Z80_A0
Text Label 1800 1200 0    31   ~ 0
Z80_A1
Text Label 1800 1300 0    31   ~ 0
Z80_A2
Text Label 1800 1400 0    31   ~ 0
Z80_A3
Text Label 1800 1500 0    31   ~ 0
Z80_A4
Text Label 1800 1600 0    31   ~ 0
Z80_A5
Text Label 1800 1700 0    31   ~ 0
Z80_A6
Text Label 1800 1800 0    31   ~ 0
Z80_A7
Text Label 1800 1900 0    31   ~ 0
Z80_A8
Text Label 1800 2000 0    31   ~ 0
Z80_A9
Text Label 1800 2100 0    31   ~ 0
Z80_A10
Text Label 1800 2200 0    31   ~ 0
Z80_A11
Text Label 1800 2300 0    31   ~ 0
Z80_A12
Text Label 1800 2400 0    31   ~ 0
Z80_A13
Text Label 1800 2500 0    31   ~ 0
Z80_A14
Text Label 1800 2600 0    31   ~ 0
Z80_A15
Entry Wire Line
	2100 2900 2200 2800
Entry Wire Line
	2100 3000 2200 2900
Entry Wire Line
	2100 3100 2200 3000
Entry Wire Line
	2100 3200 2200 3100
Entry Wire Line
	2100 3300 2200 3200
Entry Wire Line
	2100 3400 2200 3300
Entry Wire Line
	2100 3500 2200 3400
Entry Wire Line
	2100 3600 2200 3500
Entry Wire Line
	2000 2800 2100 2900
Entry Wire Line
	2000 2900 2100 3000
Entry Wire Line
	2000 3000 2100 3100
Entry Wire Line
	2000 3100 2100 3200
Entry Wire Line
	2000 3200 2100 3300
Entry Wire Line
	2000 3300 2100 3400
Entry Wire Line
	2000 3400 2100 3500
Entry Wire Line
	2000 3500 2100 3600
Entry Wire Line
	2000 1100 2100 1200
Entry Wire Line
	2000 1200 2100 1300
Entry Wire Line
	2000 1300 2100 1400
Entry Wire Line
	2000 1400 2100 1500
Entry Wire Line
	2000 1500 2100 1600
Entry Wire Line
	2000 1600 2100 1700
Entry Wire Line
	2000 1700 2100 1800
Entry Wire Line
	2000 1800 2100 1900
Entry Wire Line
	2000 1900 2100 2000
Entry Wire Line
	2000 2000 2100 2100
Entry Wire Line
	2000 2100 2100 2200
Entry Wire Line
	2000 2200 2100 2300
Entry Wire Line
	2000 2300 2100 2400
Entry Wire Line
	2000 2400 2100 2500
Entry Wire Line
	2000 2500 2100 2600
Entry Wire Line
	2000 2600 2100 2700
Entry Wire Line
	2100 1200 2200 1100
Entry Wire Line
	2100 1300 2200 1200
Entry Wire Line
	2100 1400 2200 1300
Entry Wire Line
	2100 1500 2200 1400
Entry Wire Line
	2100 1600 2200 1500
Entry Wire Line
	2100 1700 2200 1600
Entry Wire Line
	2100 1800 2200 1700
Entry Wire Line
	2100 1900 2200 1800
Entry Wire Line
	2100 2000 2200 1900
Entry Wire Line
	2100 2100 2200 2000
Entry Wire Line
	2100 2200 2200 2100
Entry Wire Line
	2100 2300 2200 2200
Entry Wire Line
	2100 2400 2200 2300
Entry Wire Line
	2100 2500 2200 2400
Entry Wire Line
	2100 2600 2200 2500
Entry Wire Line
	2100 2700 2200 2600
Entry Wire Line
	550  1300 650  1200
Entry Wire Line
	550  1500 650  1400
Entry Wire Line
	550  1800 650  1700
Entry Wire Line
	550  1900 650  1800
Entry Wire Line
	550  2200 650  2100
Entry Wire Line
	550  2300 650  2200
Entry Wire Line
	550  2400 650  2300
Entry Wire Line
	550  2500 650  2400
Entry Wire Line
	550  2800 650  2700
Entry Wire Line
	550  2900 650  2800
Entry Wire Line
	550  3000 650  2900
Entry Wire Line
	550  3100 650  3000
Entry Wire Line
	550  3350 650  3250
Entry Wire Line
	550  3450 650  3350
Text Label 650  1200 0    31   ~ 0
~Z80_RESET~
Text Label 650  1400 0    31   ~ 0
Z80_CLK
Text Label 650  1700 0    31   ~ 0
~Z80_NMI~
Text Label 650  1800 0    31   ~ 0
~Z80_INT~
Text Label 650  2100 0    31   ~ 0
~Z80_M1~
Text Label 650  2200 0    31   ~ 0
~Z80_RFSH~
Text Label 650  2300 0    31   ~ 0
~Z80_WAIT~
Text Label 650  2400 0    31   ~ 0
~Z80_HALT~
Text Label 650  2700 0    31   ~ 0
~Z80_RD~
Text Label 650  2800 0    31   ~ 0
~Z80_WR~
Text Label 650  2900 0    31   ~ 0
~Z80_MREQ~
Text Label 650  3000 0    31   ~ 0
~Z80_IORQ~
Text Label 650  3250 0    31   ~ 0
~Z80_BUSRQ~
Text Label 900  3350 2    31   ~ 0
~Z80_BUSACK~
Entry Bus Bus
	550  3900 650  4000
$Comp
L Device:C_Small C?
U 1 1 64BF0B15
P 1450 800
AR Path="/64BF0B15" Ref="C?"  Part="1" 
AR Path="/64B13D23/64B16B2E/64BF0B15" Ref="C?"  Part="1" 
AR Path="/6D0E6B67/64BF0B15" Ref="C2"  Part="1" 
F 0 "C2" V 1400 900 31  0000 C CNN
F 1 "100nF" V 1550 800 31  0000 C CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 1450 800 50  0001 C CNN
F 3 "~" H 1450 800 50  0001 C CNN
	1    1450 800 
	0    1    1    0   
$EndComp
$Comp
L power:GNDPWR #PWR?
U 1 1 64BF0B1B
P 1800 800
AR Path="/64BF0B1B" Ref="#PWR?"  Part="1" 
AR Path="/64B13D23/64B16B2E/64BF0B1B" Ref="#PWR?"  Part="1" 
AR Path="/6D0E6B67/64BF0B1B" Ref="#PWR06"  Part="1" 
F 0 "#PWR06" H 1800 600 50  0001 C CNN
F 1 "GNDPWR" H 1800 700 31  0000 C CNN
F 2 "" H 1800 750 50  0001 C CNN
F 3 "" H 1800 750 50  0001 C CNN
	1    1800 800 
	1    0    0    -1  
$EndComp
$Comp
L power:GNDPWR #PWR?
U 1 1 64BF0B5B
P 1350 3800
AR Path="/64BF0B5B" Ref="#PWR?"  Part="1" 
AR Path="/64B13D23/64B16B2E/64BF0B5B" Ref="#PWR?"  Part="1" 
AR Path="/6D0E6B67/64BF0B5B" Ref="#PWR04"  Part="1" 
F 0 "#PWR04" H 1350 3600 50  0001 C CNN
F 1 "GNDPWR" H 1350 3700 31  0000 C CNN
F 2 "" H 1350 3750 50  0001 C CNN
F 3 "" H 1350 3750 50  0001 C CNN
	1    1350 3800
	1    0    0    -1  
$EndComp
Entry Bus Bus
	500  650  600  550 
Wire Wire Line
	650  1200 900  1200
Wire Wire Line
	650  1400 900  1400
Wire Wire Line
	650  1700 900  1700
Wire Wire Line
	650  1800 900  1800
Wire Wire Line
	650  2100 900  2100
Wire Wire Line
	650  2200 900  2200
Wire Wire Line
	650  2300 900  2300
Wire Wire Line
	650  2400 900  2400
Wire Wire Line
	650  2700 900  2700
Wire Wire Line
	650  2800 900  2800
Wire Wire Line
	650  2900 900  2900
Wire Wire Line
	650  3000 900  3000
Wire Wire Line
	650  3250 900  3250
Wire Wire Line
	650  3350 900  3350
$Comp
L Memory_RAM:IS62C5128BL-45TLI U?
U 1 1 64BF0D00
P 1300 5300
AR Path="/64BF0D00" Ref="U?"  Part="1" 
AR Path="/64B13D23/64B16B2E/64BF0D00" Ref="U?"  Part="1" 
AR Path="/6D0E6B67/64BF0D00" Ref="U1"  Part="1" 
F 0 "U1" H 1300 5450 39  0000 C CNN
F 1 "IS62C5128" H 1350 5350 31  0000 C CNN
F 2 "Package_SO:TSOP-II-32_21.0x10.2mm_P1.27mm" H 1300 5400 50  0001 C CNN
F 3 "https://www.alliancememory.com/wp-content/uploads/pdf/AS6C4008.pdf" H 1300 5400 50  0001 C CNN
	1    1300 5300
	1    0    0    -1  
$EndComp
Entry Wire Line
	500  4400 600  4500
Entry Wire Line
	500  4300 600  4400
Entry Wire Line
	500  4500 600  4600
Entry Wire Line
	500  4600 600  4700
Entry Wire Line
	500  4700 600  4800
Entry Wire Line
	500  4800 600  4900
Entry Wire Line
	500  4900 600  5000
Entry Wire Line
	500  5000 600  5100
Entry Wire Line
	500  5100 600  5200
Entry Wire Line
	500  5200 600  5300
Entry Wire Line
	500  5300 600  5400
Entry Wire Line
	500  5400 600  5500
Entry Wire Line
	500  5500 600  5600
Entry Wire Line
	500  5600 600  5700
Entry Wire Line
	500  5700 600  5800
Entry Wire Line
	500  5800 600  5900
Entry Wire Line
	500  5900 600  6000
Entry Wire Line
	500  6000 600  6100
Entry Wire Line
	500  6100 600  6200
Entry Wire Line
	2000 4400 2100 4300
Entry Wire Line
	2000 4500 2100 4400
Entry Wire Line
	2000 4600 2100 4500
Entry Wire Line
	2000 4700 2100 4600
Entry Wire Line
	2000 4800 2100 4700
Entry Wire Line
	2000 4900 2100 4800
Entry Wire Line
	2000 5000 2100 4900
Entry Wire Line
	2000 5100 2100 5000
$Comp
L Device:C_Small C?
U 1 1 64BF0DBC
P 1400 4150
AR Path="/64BF0DBC" Ref="C?"  Part="1" 
AR Path="/64B13D23/64B16B2E/64BF0DBC" Ref="C?"  Part="1" 
AR Path="/6D0E6B67/64BF0DBC" Ref="C1"  Part="1" 
F 0 "C1" V 1350 4250 31  0000 C CNN
F 1 "100nF" V 1500 4150 31  0000 C CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 1400 4150 50  0001 C CNN
F 3 "~" H 1400 4150 50  0001 C CNN
	1    1400 4150
	0    1    1    0   
$EndComp
$Comp
L power:GNDPWR #PWR?
U 1 1 64BF0DC2
P 1600 4150
AR Path="/64BF0DC2" Ref="#PWR?"  Part="1" 
AR Path="/64B13D23/64B16B2E/64BF0DC2" Ref="#PWR?"  Part="1" 
AR Path="/6D0E6B67/64BF0DC2" Ref="#PWR05"  Part="1" 
F 0 "#PWR05" H 1600 3950 50  0001 C CNN
F 1 "GNDPWR" H 1600 4050 31  0000 C CNN
F 2 "" H 1600 4100 50  0001 C CNN
F 3 "" H 1600 4100 50  0001 C CNN
	1    1600 4150
	1    0    0    -1  
$EndComp
Wire Wire Line
	1300 4200 1300 4150
Wire Wire Line
	1500 4150 1600 4150
Text Label 600  4400 0    31   ~ 0
Z80_A0
Text Label 600  4500 0    31   ~ 0
Z80_A1
Text Label 600  4600 0    31   ~ 0
Z80_A2
Text Label 600  4700 0    31   ~ 0
Z80_A3
Text Label 600  4800 0    31   ~ 0
Z80_A4
Text Label 600  4900 0    31   ~ 0
Z80_A5
Text Label 600  5000 0    31   ~ 0
Z80_A6
Text Label 600  5100 0    31   ~ 0
Z80_A7
Text Label 600  5200 0    31   ~ 0
Z80_A8
Text Label 600  5300 0    31   ~ 0
Z80_A9
Text Label 600  5400 0    31   ~ 0
Z80_A10
Text Label 600  5500 0    31   ~ 0
Z80_A11
Text Label 600  5600 0    31   ~ 0
Z80_RA12
Text Label 600  5700 0    31   ~ 0
Z80_RA13
Text Label 600  5800 0    31   ~ 0
Z80_RA14
Text Label 600  5900 0    31   ~ 0
Z80_RA15
Text Label 800  6000 2    31   ~ 0
Z80_A16
Text Label 800  6100 2    31   ~ 0
Z80_A17
Text Label 800  6200 2    31   ~ 0
Z80_A18
Text Label 1800 4400 0    31   ~ 0
Z80_D0
Text Label 1800 4500 0    31   ~ 0
Z80_D1
Text Label 1800 4600 0    31   ~ 0
Z80_D2
Text Label 1800 4700 0    31   ~ 0
Z80_D3
Text Label 1800 4800 0    31   ~ 0
Z80_D4
Text Label 1800 4900 0    31   ~ 0
Z80_D5
Text Label 1800 5000 0    31   ~ 0
Z80_D6
Text Label 1800 5100 0    31   ~ 0
Z80_D7
$Comp
L power:+5V #PWR?
U 1 1 64BF0EDB
P 1050 4150
AR Path="/64BF0EDB" Ref="#PWR?"  Part="1" 
AR Path="/64B13D23/64B16B2E/64BF0EDB" Ref="#PWR?"  Part="1" 
AR Path="/6D0E6B67/64BF0EDB" Ref="#PWR02"  Part="1" 
F 0 "#PWR02" H 1050 4000 50  0001 C CNN
F 1 "+5V" H 1150 4250 50  0000 C CNN
F 2 "" H 1050 4150 50  0001 C CNN
F 3 "" H 1050 4150 50  0001 C CNN
	1    1050 4150
	1    0    0    -1  
$EndComp
Text GLabel 10800 6450 2    31   BiDi ~ 0
Z80_D[0..7]
Text GLabel 10900 1250 2    31   BiDi ~ 0
~Z80_RD~
Text GLabel 10900 1350 2    31   BiDi ~ 0
~Z80_WR~
Text GLabel 10850 1450 2    31   BiDi ~ 0
~Z80_MREQ~
Text GLabel 10850 1550 2    31   BiDi ~ 0
~Z80_IORQ~
Text GLabel 10900 1650 2    31   Output ~ 0
~Z80_WAIT~
Text GLabel 10900 1750 2    31   Output ~ 0
~Z80_NMI~
Text GLabel 10900 1850 2    31   Output ~ 0
~Z80_INT~
Text GLabel 10900 2350 2    31   BiDi ~ 0
~CTL_M1~
Text GLabel 10850 2550 2    31   BiDi ~ 0
~CTL_RFSH~
Text GLabel 10850 2650 2    31   BiDi ~ 0
~CTL_HALT~
Text GLabel 10850 1950 2    31   Input ~ 0
~Z80_RESET~
Text GLabel 10850 2150 2    31   Input ~ 0
~CTL_BUSRQ~
Text GLabel 10800 2050 2    31   Output ~ 0
~Z80_BUSACK~
Entry Wire Line
	10400 1950 10500 2050
Entry Wire Line
	10400 1850 10500 1950
Entry Wire Line
	10400 1750 10500 1850
Entry Wire Line
	10400 1650 10500 1750
Entry Wire Line
	10400 1550 10500 1650
Entry Wire Line
	10400 1450 10500 1550
Entry Wire Line
	10400 1350 10500 1450
Entry Wire Line
	10400 1250 10500 1350
Entry Wire Line
	10400 1150 10500 1250
Entry Wire Line
	10400 2050 10500 2150
Entry Wire Line
	10400 2250 10500 2350
Entry Wire Line
	10400 2350 10500 2450
Entry Wire Line
	10400 2550 10500 2650
Wire Wire Line
	10500 1250 10900 1250
Wire Wire Line
	10500 1350 10900 1350
Wire Wire Line
	10500 1450 10850 1450
Wire Wire Line
	10500 1550 10850 1550
Wire Wire Line
	10500 1650 10900 1650
Wire Wire Line
	10500 1750 10900 1750
Wire Wire Line
	10500 1850 10900 1850
Wire Wire Line
	10500 1950 10850 1950
Wire Wire Line
	10500 2050 10800 2050
Wire Wire Line
	10500 2150 10850 2150
Wire Wire Line
	10500 2350 10900 2350
Wire Wire Line
	10500 2550 10850 2550
Wire Wire Line
	10500 2650 10850 2650
Text GLabel 10800 6350 2    31   BiDi ~ 0
Z80_A[0..18]
Text GLabel 10800 2250 2    31   Input ~ 0
~CTL_BUSACK~
Entry Wire Line
	10400 2150 10500 2250
Wire Wire Line
	10500 2250 10800 2250
Entry Wire Line
	10400 2750 10500 2850
Text GLabel 10900 2850 2    31   Input ~ 0
CTLCLK
Text GLabel 10750 3150 2    31   Output ~ 0
Z80_MEM[0..4]
Entry Bus Bus
	10400 3050 10500 3150
Text GLabel 10800 2950 2    31   Output ~ 0
CTL_CLKSLCT
Entry Wire Line
	10400 2850 10500 2950
Wire Wire Line
	10500 2950 10800 2950
Wire Wire Line
	10500 2850 10900 2850
$Bitmap
Pos 10950 750 
Scale 2.000000
Data
89 50 4E 47 0D 0A 1A 0A 00 00 00 0D 49 48 44 52 00 00 00 2D 00 00 00 2D 08 03 00 00 00 0D C4 12 
A8 00 00 00 03 73 42 49 54 08 08 08 DB E1 4F E0 00 00 00 30 50 4C 54 45 02 00 00 10 00 00 42 00 
00 BD 00 00 8C 00 00 FF 00 00 21 00 00 73 00 00 DE 00 00 EF 00 00 31 00 00 52 00 00 9C 00 00 AD 
00 00 63 00 00 CE 00 00 24 3F 4B FE 00 00 00 01 74 52 4E 53 00 40 E6 D8 66 00 00 02 31 49 44 41 
54 48 89 95 95 E1 B6 A5 20 08 85 15 41 50 51 DE FF 6D 07 AD 33 77 2A 5B 73 2E 3F EA 2C FB A2 ED 
06 39 21 3C 22 3E 97 DE 03 D2 6F 68 A4 FC 3D CC 44 F2 3D 2E 44 C4 CF E5 08 2F 42 A8 D4 CB 4A 6E 
10 9B 50 DB E2 4A B7 34 9D 46 64 B2 BD 55 8D EA 6D 21 01 A4 BA 57 E2 B9 F5 5F BD F3 62 94 5F 8A 
10 0B FD 18 1E 53 81 8C 01 53 E6 3D 0E A5 E3 DF 27 D9 37 D7 A7 FF 42 7B DA 7A 85 8F C6 84 C0 11 
2A 8C 30 64 4F 23 46 3E E9 48 E6 DF 8A BE 93 B7 72 8D 81 71 F0 F9 B4 D5 90 48 20 EC AD 9E A9 07 
06 E5 D3 43 8E BD A0 15 78 A3 2B 36 A7 2B 9E AF 72 12 2F EE 9B D7 A1 A1 62 EC A1 9F C2 23 50 21 
7C D3 11 12 A4 11 2C A6 25 9C 5D 41 D3 4D 8B 9D 11 53 B0 1A A5 2E 64 CC A4 B5 8F 57 5A 2D 78 21 
09 72 9F 56 CE D7 85 DE 8F 52 1F 43 9C 46 26 D0 09 67 23 EA 6F 70 A5 AC 84 89 8A AD 94 11 0A 3D 
E9 CC 63 ED 2A 77 77 80 12 CE 5A 8A 0D F4 C4 1E 77 B3 FD B8 90 58 32 47 CB 00 AF 4C 1E BD D0 27 
6E 0D 92 9D 5D 4F CB BA 18 5D E3 6E 04 59 8E AE 02 73 45 2A 2D D7 44 1D 00 4F D8 EE 46 50 65 D2 
AA 55 24 0B B7 A2 20 B5 4B EC 07 7D B7 5B A9 1A A5 C8 3E 49 5A 6A 46 05 B0 12 E1 91 BC DC 9B 95 
89 AB 74 96 E8 A7 BD 60 4E 02 54 D5 F4 A0 1F 4D D2 7C 0D 3C 55 6A EA 63 03 1B B3 59 CB 98 64 63 
F6 AC 09 91 AE 0F A3 8E 75 75 4D 85 BB FA 16 9F 87 26 4F 79 8C 9E 2A 31 A7 F9 5B 75 6E CF 54 37 
87 71 E6 2E 8D A7 CF D8 79 7E 5E 35 CD DF DB 0E 39 68 9B B4 E0 E4 0A 8A 1B CF 70 1F 71 3F 4A 1A 
8D D5 14 EB 36 CC 86 93 69 7B D6 41 AD 03 35 29 6E 35 B9 95 56 DB 72 6E 5C 66 DC E5 0D 6F D1 E6 
A3 B7 AF 99 19 65 4D 65 DC 4D F2 83 96 75 C7 E3 AC 0C 5A C3 C9 EE 3D F5 11 5F 0A 1C F7 63 6F 7D 
69 81 37 29 7A 16 59 8F AE CB 8F 56 BD 04 9E 5B CA 67 DB 8D F7 C9 B0 72 9E ED 86 2F FF 30 97 18 
9F 7F 96 58 FF 43 2E 48 BF 48 F9 BB F8 03 46 6A 13 C0 29 E6 4E 60 00 00 00 00 49 45 4E 44 AE 42 
60 82 
EndData
$EndBitmap
Entry Wire Line
	10400 2650 10500 2750
Text GLabel 10900 2750 2    31   Output ~ 0
SYSCLK
Wire Wire Line
	10500 2750 10900 2750
Text GLabel 10900 3050 2    31   Output ~ 0
~SVCREQ~
Text Notes 4500 1150 0    31   ~ 0
Clock Select\nWhenever the main board is being accessed\nor the frequency is set to default, the system\nclock is used (2MHz on an MZ-80A. 3.58MHz\non an MZ-700). If the main board is disabled \nand the frequency is changed to XMHz then \nthe clock supplied by the K64F is used.\n
Text Notes 2300 4900 0    31   ~ 0
Memory Map\nDefined in the CPLD.\nMemory can potentially be\nmapped in 1byte chunks\nbetween the expansion\nmemory and system \nboard memory.\nGenerally though\nthe mapping will \nmirror Sharp MZ\nseries machines.
Text Label 3950 2450 0    31   ~ 0
~SYS_WAIT~
$Comp
L CPU:Z80CPU U2
U 1 1 619CF9CA
P 1350 2300
F 0 "U2" H 1350 3100 31  0000 C CNN
F 1 "Z80CPU" H 1350 3000 31  0000 C CNN
F 2 "Package_DIP:DIP-40_W15.24mm_Socket" H 1350 2700 50  0001 C CNN
F 3 "www.zilog.com/manage_directlink.php?filepath=docs/z80/um0080" H 1350 2700 50  0001 C CNN
	1    1350 2300
	1    0    0    -1  
$EndComp
Wire Wire Line
	1800 2600 2000 2600
Wire Wire Line
	1800 2500 2000 2500
Wire Wire Line
	1800 2400 2000 2400
Wire Wire Line
	1800 2300 2000 2300
Wire Wire Line
	1800 2200 2000 2200
Wire Wire Line
	1800 2100 2000 2100
Wire Wire Line
	1800 2000 2000 2000
Wire Wire Line
	1800 1900 2000 1900
Wire Wire Line
	1800 1800 2000 1800
Wire Wire Line
	1800 1700 2000 1700
Wire Wire Line
	1800 1600 2000 1600
Wire Wire Line
	1800 1500 2000 1500
Wire Wire Line
	1800 1400 2000 1400
Wire Wire Line
	1800 1300 2000 1300
Wire Wire Line
	1800 1200 2000 1200
Wire Wire Line
	1800 1100 2000 1100
Text Label 2200 1100 0    31   ~ 0
Z80_A0
Text Label 2200 1200 0    31   ~ 0
Z80_A1
Text Label 2200 2600 0    31   ~ 0
Z80_A15
Text Label 2200 2500 0    31   ~ 0
Z80_A14
Text Label 2200 2400 0    31   ~ 0
Z80_A13
Text Label 2200 2300 0    31   ~ 0
Z80_A12
Text Label 2200 2200 0    31   ~ 0
Z80_A11
Text Label 2200 2100 0    31   ~ 0
Z80_A10
Text Label 2200 2000 0    31   ~ 0
Z80_A9
Text Label 2200 1900 0    31   ~ 0
Z80_A8
Text Label 2200 1800 0    31   ~ 0
Z80_A7
Text Label 2200 1700 0    31   ~ 0
Z80_A6
Text Label 2200 1500 0    31   ~ 0
Z80_A4
Text Label 2200 1600 0    31   ~ 0
Z80_A5
Text Label 2200 1400 0    31   ~ 0
Z80_A3
Text Label 2200 1300 0    31   ~ 0
Z80_A2
Wire Wire Line
	2200 2600 2400 2600
Wire Wire Line
	2200 2500 2400 2500
Wire Wire Line
	2200 2400 2400 2400
Wire Wire Line
	2200 2300 2400 2300
Wire Wire Line
	2200 2200 2400 2200
Wire Wire Line
	2200 2100 2400 2100
Wire Wire Line
	2200 2000 2400 2000
Wire Wire Line
	2200 1900 2400 1900
Wire Wire Line
	2200 1800 2400 1800
Wire Wire Line
	2200 1700 2400 1700
Wire Wire Line
	2200 1600 2400 1600
Wire Wire Line
	2200 1500 2400 1500
Wire Wire Line
	2200 1400 2400 1400
Wire Wire Line
	2200 1300 2400 1300
Wire Wire Line
	2200 1200 2400 1200
Wire Wire Line
	2200 1100 2400 1100
Wire Wire Line
	1800 3500 2000 3500
Wire Wire Line
	1800 3400 2000 3400
Wire Wire Line
	1800 3300 2000 3300
Wire Wire Line
	1800 3200 2000 3200
Wire Wire Line
	1800 3100 2000 3100
Wire Wire Line
	1800 3000 2000 3000
Wire Wire Line
	1800 2900 2000 2900
Wire Wire Line
	1800 2800 2000 2800
Text Label 2200 2800 0    31   ~ 0
Z80_D0
Text Label 2200 2900 0    31   ~ 0
Z80_D1
Text Label 2200 3000 0    31   ~ 0
Z80_D2
Text Label 2200 3100 0    31   ~ 0
Z80_D3
Text Label 2200 3200 0    31   ~ 0
Z80_D4
Text Label 2200 3300 0    31   ~ 0
Z80_D5
Text Label 2200 3400 0    31   ~ 0
Z80_D6
Text Label 2200 3500 0    31   ~ 0
Z80_D7
Wire Wire Line
	2200 2800 2400 2800
Wire Wire Line
	2200 2900 2400 2900
Wire Wire Line
	2200 3000 2400 3000
Wire Wire Line
	2200 3100 2400 3100
Wire Wire Line
	2200 3200 2400 3200
Wire Wire Line
	2200 3300 2400 3300
Wire Wire Line
	2200 3400 2400 3400
Wire Wire Line
	2200 3500 2400 3500
Wire Wire Line
	1300 4150 1050 4150
Connection ~ 1300 4150
$Comp
L CPU:Z80CPU_EXTENDER2 U3
U 1 1 6201F37D
P 2850 2300
F 0 "U3" H 2850 3100 31  0000 C CNN
F 1 "EXTENDER" H 2850 3000 31  0000 C CNN
F 2 "MZ80FPGA:DIP-40_W15.24mm_Extender_NoCourtyard" H 2850 2700 50  0001 C CNN
F 3 "www.zilog.com/manage_directlink.php?filepath=docs/z80/um0080" H 2850 2700 50  0001 C CNN
	1    2850 2300
	-1   0    0    -1  
$EndComp
Wire Wire Line
	1550 800  1800 800 
Wire Wire Line
	1350 700  1350 800 
Wire Wire Line
	1350 700  2850 700 
Connection ~ 1350 800 
$Comp
L Device:C_Small C?
U 1 1 62740E26
P 2950 800
AR Path="/62740E26" Ref="C?"  Part="1" 
AR Path="/64B13D23/64B16B2E/62740E26" Ref="C?"  Part="1" 
AR Path="/6D0E6B67/62740E26" Ref="C3"  Part="1" 
F 0 "C3" V 2900 900 31  0000 C CNN
F 1 "100nF" V 3050 800 31  0000 C CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 2950 800 50  0001 C CNN
F 3 "~" H 2950 800 50  0001 C CNN
	1    2950 800 
	0    1    1    0   
$EndComp
$Comp
L power:GNDPWR #PWR?
U 1 1 62741729
P 3300 800
AR Path="/62741729" Ref="#PWR?"  Part="1" 
AR Path="/64B13D23/64B16B2E/62741729" Ref="#PWR?"  Part="1" 
AR Path="/6D0E6B67/62741729" Ref="#PWR010"  Part="1" 
F 0 "#PWR010" H 3300 600 50  0001 C CNN
F 1 "GNDPWR" H 3300 700 31  0000 C CNN
F 2 "" H 3300 750 50  0001 C CNN
F 3 "" H 3300 750 50  0001 C CNN
	1    3300 800 
	1    0    0    -1  
$EndComp
Wire Wire Line
	3050 800  3300 800 
Wire Wire Line
	2850 700  2850 800 
Connection ~ 2850 800 
Text Label 3950 2350 0    31   ~ 0
~SYS_BUSRQ~
Entry Wire Line
	3500 3000 3600 3100
Entry Wire Line
	3500 2900 3600 3000
Entry Wire Line
	3500 2800 3600 2900
Wire Wire Line
	3300 2700 3500 2700
Wire Wire Line
	3300 2800 3500 2800
Wire Wire Line
	3300 2900 3500 2900
Wire Wire Line
	3300 3000 3500 3000
Entry Wire Line
	3500 2300 3600 2400
Text Label 3300 2300 0    31   ~ 0
~SYS_WAIT~
Text Label 3300 2700 0    31   ~ 0
~Z80_RD~
Text Label 3300 2800 0    31   ~ 0
~Z80_WR~
Text Label 3300 2900 0    31   ~ 0
~Z80_MREQ~
Text Label 3300 3000 0    31   ~ 0
~Z80_IORQ~
Entry Wire Line
	3500 1800 3600 1900
Entry Wire Line
	3500 1700 3600 1800
Entry Wire Line
	3500 1400 3600 1500
Wire Wire Line
	3300 1700 3500 1700
Wire Wire Line
	3300 1800 3500 1800
Text Label 3300 1200 0    31   ~ 0
~Z80_RESET~
Text Label 3300 1700 0    31   ~ 0
~Z80_NMI~
Text Label 3300 1800 0    31   ~ 0
~Z80_INT~
Entry Wire Line
	3500 1200 3600 1300
Entry Wire Line
	3500 2700 3600 2800
Wire Wire Line
	3300 1200 3500 1200
Wire Wire Line
	3300 2300 3500 2300
Wire Wire Line
	3300 1400 3500 1400
Text Label 3300 1400 0    31   ~ 0
SYSCLK
Entry Wire Line
	3500 2100 3600 2200
Wire Wire Line
	3300 2100 3500 2100
Text Label 3300 2100 0    31   ~ 0
~CTL_M1~
Entry Wire Line
	3500 2200 3600 2300
Wire Wire Line
	3500 2200 3300 2200
Text Label 3300 2200 0    31   ~ 0
~CTL_RFSH~
Entry Wire Line
	3500 2400 3600 2500
Wire Wire Line
	3300 2400 3500 2400
Text Label 3300 2400 0    31   ~ 0
~CTL_HALT~
Entry Wire Line
	3500 3350 3600 3450
Wire Wire Line
	3500 3350 3300 3350
Text Label 3300 3350 0    31   ~ 0
~SYS_BUSACK~
Entry Wire Line
	3500 3250 3600 3350
Wire Wire Line
	3300 3250 3500 3250
Text Label 3300 3250 0    31   ~ 0
~SYS_BUSRQ~
Entry Bus Bus
	3500 4000 3600 3900
$Comp
L power:GNDPWR #PWR?
U 1 1 636A8B05
P 2850 3800
AR Path="/636A8B05" Ref="#PWR?"  Part="1" 
AR Path="/64B13D23/64B16B2E/636A8B05" Ref="#PWR?"  Part="1" 
AR Path="/6D0E6B67/636A8B05" Ref="#PWR08"  Part="1" 
F 0 "#PWR08" H 2850 3600 50  0001 C CNN
F 1 "GNDPWR" H 2850 3700 31  0000 C CNN
F 2 "" H 2850 3750 50  0001 C CNN
F 3 "" H 2850 3750 50  0001 C CNN
	1    2850 3800
	1    0    0    -1  
$EndComp
Text Label 3950 2550 0    31   ~ 0
~SYS_BUSACK~
Entry Bus Bus
	2000 550  2100 650 
Entry Bus Bus
	2150 4000 2250 4100
Entry Bus Bus
	2150 4000 2250 4100
Entry Bus Bus
	2100 7450 2200 7550
Entry Bus Bus
	3600 7550 3700 7450
Wire Wire Line
	10500 3050 10900 3050
$Comp
L power:+5V #PWR?
U 1 1 5F782DBB
P 2850 700
AR Path="/5F782DBB" Ref="#PWR?"  Part="1" 
AR Path="/64B13D23/64B16B2E/5F782DBB" Ref="#PWR?"  Part="1" 
AR Path="/6D0E6B67/5F782DBB" Ref="#PWR07"  Part="1" 
F 0 "#PWR07" H 2850 550 50  0001 C CNN
F 1 "+5V" H 2865 873 50  0000 C CNN
F 2 "" H 2850 700 50  0001 C CNN
F 3 "" H 2850 700 50  0001 C CNN
	1    2850 700 
	1    0    0    -1  
$EndComp
Entry Bus Bus
	500  7650 600  7750
Entry Wire Line
	3700 6050 3800 5950
Entry Wire Line
	3700 5950 3800 5850
Entry Wire Line
	3700 5850 3800 5750
Entry Wire Line
	3700 5750 3800 5650
Entry Wire Line
	3700 5650 3800 5550
Entry Wire Line
	3600 4750 3700 4650
Text Label 5850 6850 0    31   ~ 0
Z80_A6
Text Label 5850 6750 0    31   ~ 0
Z80_A7
Text Label 5850 6650 0    31   ~ 0
Z80_A8
Text Label 5850 6550 0    31   ~ 0
Z80_A9
Text Label 5850 6450 0    31   ~ 0
Z80_A10
Text Label 5850 6350 0    31   ~ 0
Z80_A11
Text Label 5850 6250 0    31   ~ 0
Z80_A12
Text Label 5850 6150 0    31   ~ 0
Z80_A13
Text Label 5850 6050 0    31   ~ 0
Z80_A14
Text Label 5850 5950 0    31   ~ 0
Z80_A15
Text Label 5850 5850 0    31   ~ 0
Z80_A16
Text Label 5850 5750 0    31   ~ 0
Z80_A17
Text Label 5850 5650 0    31   ~ 0
Z80_A18
Entry Wire Line
	3600 4450 3700 4350
Entry Wire Line
	3600 3250 3700 3150
Entry Wire Line
	3600 3150 3700 3050
Entry Wire Line
	3600 3050 3700 2950
Entry Wire Line
	3600 2950 3700 2850
Entry Wire Line
	3600 2850 3700 2750
Text Label 3950 6150 0    31   ~ 0
Z80_D0
Text Label 3950 6050 0    31   ~ 0
Z80_D1
Entry Wire Line
	3600 2750 3700 2650
Entry Wire Line
	3600 2650 3700 2550
Entry Wire Line
	3600 2550 3700 2450
Entry Wire Line
	3600 2450 3700 2350
Entry Wire Line
	3600 2350 3700 2250
Entry Wire Line
	3600 4950 3700 4850
Entry Wire Line
	3600 4850 3700 4750
Entry Wire Line
	3600 5450 3700 5350
Entry Wire Line
	3600 5350 3700 5250
Entry Wire Line
	3600 5250 3700 5150
Entry Wire Line
	3600 5150 3700 5050
Entry Wire Line
	3600 5050 3700 4950
Text Label 3950 4950 0    31   ~ 0
Z80_MEM0
Text Label 3950 5050 0    31   ~ 0
Z80_MEM1
Text Label 3950 5150 0    31   ~ 0
Z80_MEM2
Text Label 3950 5250 0    31   ~ 0
Z80_MEM3
Text Label 3950 5350 0    31   ~ 0
Z80_MEM4
Text Label 3950 4050 0    31   ~ 0
~Z80_WR~
Text Label 3950 4150 0    31   ~ 0
~Z80_RD~
Text Label 3950 4250 0    31   ~ 0
~Z80_IORQ~
Text Label 3950 4350 0    31   ~ 0
~Z80_MREQ~
Text Label 3950 3850 0    31   ~ 0
~Z80_M1~
Text Label 3950 3950 0    31   ~ 0
~Z80_RFSH~
Text Label 3950 3750 0    31   ~ 0
~Z80_WAIT~
Text Label 3950 4850 0    31   ~ 0
~Z80_HALT~
Text Label 3950 3550 0    31   ~ 0
~Z80_BUSRQ~
Text Label 3950 3650 0    31   ~ 0
~Z80_BUSACK~
Text Label 3950 4450 0    31   ~ 0
~Z80_NMI~
Text Label 3950 4550 0    31   ~ 0
~Z80_INT~
Text Label 3950 4750 0    31   ~ 0
Z80_CLK
Entry Wire Line
	2150 5400 2250 5300
Entry Wire Line
	2150 5500 2250 5400
Entry Wire Line
	2150 5600 2250 5500
Text Label 1850 5400 0    31   ~ 0
~RAM_CS~
Text Label 1850 5500 0    31   ~ 0
~RAM_OE~
Text Label 1850 5600 0    31   ~ 0
~RAM_WE~
Entry Wire Line
	3800 6050 3700 6150
Entry Wire Line
	6200 6050 6300 6150
Entry Wire Line
	6200 5950 6300 6050
Wire Wire Line
	5650 5850 6200 5850
Wire Wire Line
	5650 5750 6200 5750
Wire Wire Line
	5650 5450 6200 5450
Entry Wire Line
	6400 2150 6500 2250
Entry Wire Line
	6400 2050 6500 2150
Entry Wire Line
	6400 1950 6500 2050
Entry Wire Line
	6400 1850 6500 1950
Entry Wire Line
	6400 1750 6500 1850
Entry Wire Line
	6400 1650 6500 1750
Entry Wire Line
	6400 1550 6500 1650
Entry Wire Line
	6400 1450 6500 1550
Entry Wire Line
	6400 1350 6500 1450
Text Label 3950 4650 0    31   ~ 0
~RAM_CS~
Text Label 3950 2650 0    31   ~ 0
~RAM_OE~
Text Label 3950 2750 0    31   ~ 0
~RAM_WE~
Text Label 3950 2250 0    31   ~ 0
~SVCREQ~
Connection ~ 2850 700 
$Comp
L power:GNDPWR #PWR?
U 1 1 647CBEAC
P 1300 6600
AR Path="/647CBEAC" Ref="#PWR?"  Part="1" 
AR Path="/64B13D23/64B16B2E/647CBEAC" Ref="#PWR?"  Part="1" 
AR Path="/6D0E6B67/647CBEAC" Ref="#PWR03"  Part="1" 
F 0 "#PWR03" H 1300 6400 50  0001 C CNN
F 1 "GNDPWR" H 1300 6450 31  0000 C CNN
F 2 "" H 1300 6550 50  0001 C CNN
F 3 "" H 1300 6550 50  0001 C CNN
	1    1300 6600
	1    0    0    -1  
$EndComp
Wire Wire Line
	1300 6400 1300 6600
Wire Bus Line
	600  550  2000 550 
Wire Bus Line
	10500 3150 10750 3150
Entry Wire Line
	6200 6250 6300 6350
Entry Wire Line
	6200 6350 6300 6450
Entry Wire Line
	6200 6450 6300 6550
Entry Wire Line
	6200 6550 6300 6650
Entry Wire Line
	6200 6650 6300 6750
Entry Wire Line
	6200 6750 6300 6850
Entry Wire Line
	6200 6850 6300 6950
Entry Wire Line
	6200 5450 6300 5550
Entry Wire Line
	6200 5750 6300 5850
Entry Wire Line
	6200 5750 6300 5850
Entry Wire Line
	6200 5850 6300 5950
Wire Wire Line
	5650 5950 6200 5950
Wire Wire Line
	5650 6050 6200 6050
Wire Wire Line
	5650 6150 6200 6150
Wire Wire Line
	5650 6250 6200 6250
Wire Wire Line
	5650 6350 6200 6350
Wire Wire Line
	5650 6450 6200 6450
Wire Wire Line
	5650 6550 6200 6550
Wire Wire Line
	5650 6650 6200 6650
Wire Wire Line
	5650 6750 6200 6750
Wire Wire Line
	5650 6850 6200 6850
Entry Wire Line
	3800 6150 3700 6250
Entry Wire Line
	3600 4650 3700 4550
Text GLabel 10850 2450 2    31   Input ~ 0
~CTL_WAIT~
Wire Wire Line
	10500 2450 10850 2450
Entry Wire Line
	10400 2450 10500 2550
Entry Wire Line
	3600 4250 3700 4150
Entry Wire Line
	3600 4150 3700 4050
Entry Wire Line
	3600 4350 3700 4250
Entry Wire Line
	3600 4250 3700 4150
Entry Wire Line
	3600 4050 3700 3950
Entry Wire Line
	3600 3850 3700 3750
Entry Wire Line
	3600 3750 3700 3650
Entry Wire Line
	3600 3850 3700 3750
Entry Wire Line
	3600 3650 3700 3550
Entry Wire Line
	3600 3950 3700 3850
Entry Wire Line
	3600 3950 3700 3850
Entry Wire Line
	3700 5550 3800 5450
Entry Wire Line
	3600 3550 3700 3450
Entry Wire Line
	3600 3450 3700 3350
Entry Wire Line
	3600 3350 3700 3250
Wire Wire Line
	3500 6800 2500 6800
Wire Wire Line
	2500 6800 2500 6000
Text Label 3500 6800 2    31   ~ 0
~CTL_WAIT~
Wire Wire Line
	2600 6000 2600 6700
Wire Wire Line
	3500 6700 2600 6700
Wire Wire Line
	2700 6000 2700 6600
Wire Wire Line
	3500 6500 2800 6500
Wire Wire Line
	2800 6500 2800 6000
Wire Wire Line
	2900 6400 3500 6400
Wire Wire Line
	2900 6000 2900 6400
Connection ~ 2600 5750
Wire Wire Line
	2500 5750 2600 5750
Wire Wire Line
	2500 5800 2500 5750
$Comp
L Device:R_Small R?
U 1 1 5FA83353
P 2500 5900
AR Path="/5FA83353" Ref="R?"  Part="1" 
AR Path="/64B13D23/64B16B2E/5FA83353" Ref="R?"  Part="1" 
AR Path="/6D0E6B67/5FA83353" Ref="R1"  Part="1" 
F 0 "R1" H 2500 5800 31  0000 L CNN
F 1 "6K8" V 2500 5850 31  0000 L CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 2500 5900 50  0001 C CNN
F 3 "~" H 2500 5900 50  0001 C CNN
	1    2500 5900
	1    0    0    -1  
$EndComp
Text Label 3500 6700 2    31   ~ 0
~CTL_HALT~
Entry Wire Line
	3500 6200 3600 6300
Entry Wire Line
	3500 6800 3600 6900
Wire Wire Line
	3000 6000 3000 6300
Wire Wire Line
	3000 6300 3500 6300
Wire Wire Line
	3100 6200 3500 6200
Wire Wire Line
	3100 6200 3100 6000
Connection ~ 3000 5750
Wire Wire Line
	3100 5750 3100 5800
Wire Wire Line
	3000 5750 3100 5750
$Comp
L Device:R_Small R?
U 1 1 62D37B2F
P 3100 5900
AR Path="/62D37B2F" Ref="R?"  Part="1" 
AR Path="/64B13D23/64B16B2E/62D37B2F" Ref="R?"  Part="1" 
AR Path="/6D0E6B67/62D37B2F" Ref="R7"  Part="1" 
F 0 "R7" H 3100 5800 31  0000 L CNN
F 1 "6K8" V 3100 5850 31  0000 L CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 3100 5900 50  0001 C CNN
F 3 "~" H 3100 5900 50  0001 C CNN
	1    3100 5900
	1    0    0    -1  
$EndComp
Entry Wire Line
	3500 6700 3600 6800
Text Label 3500 6200 2    31   ~ 0
CTLCLK
Wire Wire Line
	2700 6600 3500 6600
Text Label 3500 6300 2    31   ~ 0
~CTL_BUSACK~
Entry Wire Line
	3500 6600 3600 6700
Connection ~ 2900 5750
Wire Wire Line
	3000 5750 3000 5800
Wire Wire Line
	2900 5750 3000 5750
$Comp
L Device:R_Small R?
U 1 1 62D37B13
P 3000 5900
AR Path="/62D37B13" Ref="R?"  Part="1" 
AR Path="/64B13D23/64B16B2E/62D37B13" Ref="R?"  Part="1" 
AR Path="/6D0E6B67/62D37B13" Ref="R6"  Part="1" 
F 0 "R6" H 3000 5800 31  0000 L CNN
F 1 "6K8" V 3000 5850 31  0000 L CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 3000 5900 50  0001 C CNN
F 3 "~" H 3000 5900 50  0001 C CNN
	1    3000 5900
	1    0    0    -1  
$EndComp
Entry Wire Line
	3500 6400 3600 6500
Entry Wire Line
	3500 6300 3600 6400
Entry Wire Line
	3500 6500 3600 6600
Wire Wire Line
	2900 5700 2900 5750
Wire Wire Line
	2800 5750 2900 5750
Text Label 3500 6500 2    31   ~ 0
~CTL_BUSRQ~
Connection ~ 2800 5750
Wire Wire Line
	2900 5750 2900 5800
Connection ~ 2700 5750
Wire Wire Line
	2800 5750 2800 5800
Wire Wire Line
	2700 5750 2800 5750
Wire Wire Line
	2700 5750 2700 5800
Wire Wire Line
	2600 5750 2700 5750
Wire Wire Line
	2600 5800 2600 5750
$Comp
L Device:R_Small R?
U 1 1 62D37AF8
P 2600 5900
AR Path="/62D37AF8" Ref="R?"  Part="1" 
AR Path="/64B13D23/64B16B2E/62D37AF8" Ref="R?"  Part="1" 
AR Path="/6D0E6B67/62D37AF8" Ref="R2"  Part="1" 
F 0 "R2" H 2600 5800 31  0000 L CNN
F 1 "6K8" V 2600 5850 31  0000 L CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 2600 5900 50  0001 C CNN
F 3 "~" H 2600 5900 50  0001 C CNN
	1    2600 5900
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R?
U 1 1 62D37AEE
P 2700 5900
AR Path="/62D37AEE" Ref="R?"  Part="1" 
AR Path="/64B13D23/64B16B2E/62D37AEE" Ref="R?"  Part="1" 
AR Path="/6D0E6B67/62D37AEE" Ref="R3"  Part="1" 
F 0 "R3" H 2700 5800 31  0000 L CNN
F 1 "6K8" V 2700 5850 31  0000 L CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 2700 5900 50  0001 C CNN
F 3 "~" H 2700 5900 50  0001 C CNN
	1    2700 5900
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R?
U 1 1 62D37AE4
P 2800 5900
AR Path="/62D37AE4" Ref="R?"  Part="1" 
AR Path="/64B13D23/64B16B2E/62D37AE4" Ref="R?"  Part="1" 
AR Path="/6D0E6B67/62D37AE4" Ref="R4"  Part="1" 
F 0 "R4" H 2800 5800 31  0000 L CNN
F 1 "6K8" V 2800 5850 31  0000 L CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 2800 5900 50  0001 C CNN
F 3 "~" H 2800 5900 50  0001 C CNN
	1    2800 5900
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R?
U 1 1 62D37ADA
P 2900 5900
AR Path="/62D37ADA" Ref="R?"  Part="1" 
AR Path="/64B13D23/64B16B2E/62D37ADA" Ref="R?"  Part="1" 
AR Path="/6D0E6B67/62D37ADA" Ref="R5"  Part="1" 
F 0 "R5" H 2900 5800 31  0000 L CNN
F 1 "6K8" V 2900 5850 31  0000 L CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 2900 5900 50  0001 C CNN
F 3 "~" H 2900 5900 50  0001 C CNN
	1    2900 5900
	1    0    0    -1  
$EndComp
Text Label 3500 6600 2    31   ~ 0
~CTL_RFSH~
Text Label 3500 6400 2    31   ~ 0
~CTL_M1~
$Comp
L power:+5V #PWR?
U 1 1 64BF0B0F
P 2900 5700
AR Path="/64BF0B0F" Ref="#PWR?"  Part="1" 
AR Path="/64B13D23/64B16B2E/64BF0B0F" Ref="#PWR?"  Part="1" 
AR Path="/6D0E6B67/64BF0B0F" Ref="#PWR09"  Part="1" 
F 0 "#PWR09" H 2900 5550 50  0001 C CNN
F 1 "+5V" H 2900 5850 50  0000 C CNN
F 2 "" H 2900 5700 50  0001 C CNN
F 3 "" H 2900 5700 50  0001 C CNN
	1    2900 5700
	-1   0    0    -1  
$EndComp
Text Label 3950 2950 0    31   ~ 0
~CTL_WAIT~
Text Label 3950 2850 0    31   ~ 0
CTL_CLKSLCT
Text Label 3950 3350 0    31   ~ 0
~CTL_BUSACK~
Text Label 3950 3150 0    31   ~ 0
~CTL_BUSRQ~
Text Label 3950 3450 0    31   ~ 0
~CTL_HALT~
Text Label 3950 3050 0    31   ~ 0
~CTL_RFSH~
Text Label 3950 3250 0    31   ~ 0
~CTL_M1~
Text Label 3950 5450 0    31   ~ 0
Z80_D7
Text Label 3950 5550 0    31   ~ 0
Z80_D6
Text Label 3950 5650 0    31   ~ 0
Z80_D5
Text Label 3950 5750 0    31   ~ 0
Z80_D4
Text Label 3950 5850 0    31   ~ 0
Z80_D3
Text Label 3950 5950 0    31   ~ 0
Z80_D2
Wire Wire Line
	3700 3450 4350 3450
Wire Wire Line
	3700 3550 4350 3550
Wire Wire Line
	3700 3650 4350 3650
Wire Wire Line
	3700 4050 4350 4050
Wire Wire Line
	3700 3950 4350 3950
Wire Wire Line
	3700 3850 4350 3850
Wire Wire Line
	3700 3750 4350 3750
Wire Wire Line
	3700 4550 4350 4550
Wire Wire Line
	3700 4450 4350 4450
Wire Wire Line
	3700 4350 4350 4350
Wire Wire Line
	3700 4250 4350 4250
Wire Wire Line
	3700 4150 4350 4150
Wire Wire Line
	3700 3250 4350 3250
Wire Wire Line
	3700 3350 4350 3350
Wire Wire Line
	3700 2750 4350 2750
Wire Wire Line
	3700 2650 4350 2650
Wire Wire Line
	3700 2850 4350 2850
Wire Wire Line
	3700 2950 4350 2950
Wire Wire Line
	3700 3050 4350 3050
Wire Wire Line
	3700 3150 4350 3150
Wire Wire Line
	3700 2450 4350 2450
Wire Wire Line
	3700 2350 4350 2350
Wire Wire Line
	3700 2550 4350 2550
Wire Wire Line
	3700 4850 4350 4850
Wire Wire Line
	3700 2250 4350 2250
Entry Bus Bus
	6200 7750 6300 7650
Entry Bus Bus
	3600 650  3700 550 
Entry Bus Bus
	6650 7550 6750 7450
Entry Bus Bus
	6750 6550 6850 6450
Entry Bus Bus
	10300 550  10400 650 
Entry Bus Bus
	6300 6450 6400 6350
Wire Bus Line
	6400 6350 10800 6350
Entry Wire Line
	3600 4550 3700 4450
Entry Wire Line
	3800 1750 3900 1850
Entry Wire Line
	3800 1650 3900 1750
Entry Wire Line
	3800 1550 3900 1650
Entry Wire Line
	3800 1450 3900 1550
Entry Wire Line
	3800 1350 3900 1450
Entry Wire Line
	3800 1250 3900 1350
Entry Wire Line
	6200 6150 6300 6250
Text Label 7150 2950 0    31   ~ 0
VDATA0
Text Label 7150 3050 0    31   ~ 0
VDATA1
Text Label 7150 3150 0    31   ~ 0
VDATA2
Text Label 7150 3250 0    31   ~ 0
VDATA3
Text Label 7150 3350 0    31   ~ 0
VDATA4
Text Label 7150 3450 0    31   ~ 0
VDATA5
Text Label 7150 3550 0    31   ~ 0
VDATA6
Text Label 7150 3650 0    31   ~ 0
VDATA7
Entry Wire Line
	6500 3650 6600 3550
Entry Wire Line
	6500 3750 6600 3650
Entry Wire Line
	6500 3850 6600 3750
Entry Wire Line
	6500 3950 6600 3850
Entry Wire Line
	6500 4050 6600 3950
Entry Wire Line
	6500 4150 6600 4050
Text Label 7150 1350 0    31   ~ 0
VADDR0
Text Label 7150 1450 0    31   ~ 0
VADDR1
Text Label 7150 1550 0    31   ~ 0
VADDR2
Text Label 7150 1650 0    31   ~ 0
VADDR3
Text Label 7150 1750 0    31   ~ 0
VADDR4
Text Label 7150 1850 0    31   ~ 0
VADDR5
Text Label 7150 1950 0    31   ~ 0
VADDR6
Text Label 7150 2050 0    31   ~ 0
VADDR7
Text Label 7150 2150 0    31   ~ 0
VADDR8
Text Label 7150 2250 0    31   ~ 0
VADDR9
Text Label 7150 2350 0    31   ~ 0
VADDR10
Text Label 7150 2450 0    31   ~ 0
VADDR11
Text Label 7150 2550 0    31   ~ 0
VADDR12
Text Label 7150 2650 0    31   ~ 0
VADDR13
Text Label 7150 4050 0    31   ~ 0
VZ80_CLK
Text Label 7150 3950 0    31   ~ 0
~VZ80_IORQ~
Text Label 7150 3850 0    31   ~ 0
~VZ80_WR~
Text Label 7150 3750 0    31   ~ 0
~VZ80_RD~
$Comp
L epm7128slc84:EP3C25E144C8N-1 U?
U 1 1 60BC1402
P 8300 2950
AR Path="/689FAE6F/60BC1402" Ref="U?"  Part="1" 
AR Path="/600002AE/60BC1402" Ref="U?"  Part="1" 
AR Path="/6E14A406/60BC1402" Ref="U?"  Part="1" 
AR Path="/5FE56B77/60BC1402" Ref="U?"  Part="1" 
AR Path="/6D0E6B67/60BC1402" Ref="U5"  Part="1" 
F 0 "U5" H 8300 4600 50  0000 C CNN
F 1 "EP3C25E144C8N" H 8300 1250 50  0000 C CNN
F 2 "Package_QFP:EQFP-144-1EP_20x20mm_P0.5mm_EP6.61x5.615mm" H 9000 1150 50  0001 L CNN
F 3 "https://www.altera.com/content/dam/altera-www/global/en_US/pdfs/literature/hb/max2/max2_mii5v1.pdf" H 9950 2150 50  0001 C CNN
	1    8300 2950
	1    0    0    -1  
$EndComp
$Comp
L tranZPUter-SW-700_v1_2-rescue:EPM7512AEQFP144-7-epm7128slc84 U4
U 1 1 5F055E35
P 5000 4250
AR Path="/5F055E35" Ref="U4"  Part="1" 
AR Path="/6D0E6B67/5F055E35" Ref="U4"  Part="1" 
F 0 "U4" H 5000 7200 39  0000 C CNN
F 1 "EPM7512AEQFP144" H 5000 1600 31  0000 C CNN
F 2 "Package_QFP:TQFP-144_20x20mm_P0.5mm" H 5850 1350 50  0001 L CNN
F 3 "https://www.altera.com/content/dam/altera-www/global/en_US/pdfs/literature/hb/max2/max2_mii5v1.pdf" H 5000 4250 50  0001 C CNN
	1    5000 4250
	1    0    0    -1  
$EndComp
Wire Wire Line
	3700 4950 4350 4950
Wire Wire Line
	3700 5050 4350 5050
Wire Wire Line
	3700 5150 4350 5150
Wire Wire Line
	3700 5250 4350 5250
Wire Wire Line
	3700 5350 4350 5350
Wire Wire Line
	3700 4650 4350 4650
Wire Wire Line
	3700 4750 4350 4750
Wire Bus Line
	3700 550  10300 550 
Wire Wire Line
	3800 5450 4350 5450
Wire Wire Line
	3800 5550 4350 5550
Wire Wire Line
	3800 5650 4350 5650
Wire Wire Line
	3800 5750 4350 5750
Wire Wire Line
	3800 5850 4350 5850
Wire Wire Line
	3800 5950 4350 5950
Wire Wire Line
	3800 6050 4350 6050
Wire Wire Line
	3800 6150 4350 6150
Entry Wire Line
	3800 6450 3900 6350
Entry Wire Line
	3800 6550 3900 6450
Entry Wire Line
	3800 6650 3900 6550
Entry Wire Line
	3800 6750 3900 6650
Entry Wire Line
	3800 6850 3900 6750
Entry Wire Line
	3800 6950 3900 6850
Wire Wire Line
	3900 6350 4350 6350
Wire Wire Line
	3900 6450 4350 6450
Wire Wire Line
	3900 6550 4350 6550
Wire Wire Line
	3900 6650 4350 6650
Wire Wire Line
	3900 6750 4350 6750
Wire Wire Line
	3900 6850 4350 6850
Text Label 3950 6350 0    31   ~ 0
Z80_A0
Text Label 3950 6450 0    31   ~ 0
Z80_A1
Text Label 3950 6550 0    31   ~ 0
Z80_A2
Text Label 3950 6650 0    31   ~ 0
Z80_A3
Text Label 3950 6750 0    31   ~ 0
Z80_A4
Text Label 3950 6850 0    31   ~ 0
Z80_A5
Text Label 5850 5550 0    31   ~ 0
Z80_RA15
Wire Bus Line
	6750 6550 6750 7450
Wire Bus Line
	6850 6450 10800 6450
Entry Bus Bus
	3700 7750 3800 7650
Text Label 3950 2150 0    31   ~ 0
VADDR0
Text Label 3950 2050 0    31   ~ 0
VADDR1
Text Label 3950 1950 0    31   ~ 0
VADDR2
Text Label 3950 1850 0    31   ~ 0
VADDR3
Text Label 3950 1750 0    31   ~ 0
VADDR4
Text Label 3950 1650 0    31   ~ 0
VADDR5
Wire Wire Line
	3900 2150 4350 2150
Wire Wire Line
	3900 2050 4350 2050
Wire Wire Line
	3900 1950 4350 1950
Wire Wire Line
	3900 1850 4350 1850
Wire Wire Line
	3900 1750 4350 1750
Wire Wire Line
	3900 1650 4350 1650
Entry Wire Line
	6400 3050 6500 3150
Entry Wire Line
	6400 2950 6500 3050
Entry Wire Line
	6400 2850 6500 2950
Entry Wire Line
	6400 2750 6500 2850
Entry Wire Line
	6400 2650 6500 2750
Entry Wire Line
	6400 2550 6500 2650
Entry Wire Line
	6400 2450 6500 2550
Entry Wire Line
	6400 2350 6500 2450
Entry Wire Line
	6400 2250 6500 2350
Entry Wire Line
	6500 2350 6600 2250
Entry Wire Line
	6500 2450 6600 2350
Entry Wire Line
	6500 2550 6600 2450
Entry Wire Line
	6500 2650 6600 2550
Entry Wire Line
	6500 2750 6600 2650
Entry Wire Line
	6500 2850 6600 2750
Entry Wire Line
	6500 2950 6600 2850
Entry Wire Line
	6500 3050 6600 2950
Entry Wire Line
	6500 3150 6600 3050
Entry Wire Line
	6500 1450 6600 1350
Entry Wire Line
	6500 1550 6600 1450
Entry Wire Line
	6500 1650 6600 1550
Entry Wire Line
	6500 1750 6600 1650
Entry Wire Line
	6500 1850 6600 1750
Entry Wire Line
	6500 1950 6600 1850
Entry Wire Line
	6500 2050 6600 1950
Entry Wire Line
	6500 2150 6600 2050
Entry Wire Line
	6500 2250 6600 2150
Entry Wire Line
	6400 3450 6500 3550
Entry Wire Line
	6400 3350 6500 3450
Entry Wire Line
	6400 3250 6500 3350
Entry Wire Line
	6400 3150 6500 3250
Entry Wire Line
	6500 3250 6600 3150
Entry Wire Line
	6500 3350 6600 3250
Entry Wire Line
	6500 3450 6600 3350
Entry Wire Line
	6500 3550 6600 3450
Wire Wire Line
	5650 1350 6400 1350
Wire Wire Line
	5650 1450 6400 1450
Wire Wire Line
	5650 1550 6400 1550
Wire Wire Line
	5650 1650 6400 1650
Wire Wire Line
	5650 1750 6400 1750
Wire Wire Line
	5650 1850 6400 1850
Wire Wire Line
	5650 1950 6400 1950
Wire Wire Line
	5650 2050 6400 2050
Wire Wire Line
	5650 2150 6400 2150
Wire Wire Line
	5650 2250 6400 2250
Wire Wire Line
	5650 2350 6400 2350
Wire Wire Line
	5650 2450 6400 2450
Wire Wire Line
	5650 2550 6400 2550
Wire Wire Line
	5650 2650 6400 2650
Wire Wire Line
	5650 2750 6400 2750
Wire Wire Line
	5650 2850 6400 2850
Wire Wire Line
	5650 2950 6400 2950
Wire Wire Line
	5650 3050 6400 3050
Wire Wire Line
	5650 3150 6400 3150
Wire Wire Line
	5650 3350 6400 3350
Wire Wire Line
	5650 3250 6400 3250
Wire Wire Line
	5650 3450 6400 3450
Wire Wire Line
	6600 1350 7500 1350
Wire Wire Line
	6600 1450 7500 1450
Wire Wire Line
	6600 1550 7500 1550
Wire Wire Line
	6600 1650 7500 1650
Wire Wire Line
	6600 1750 7500 1750
Wire Wire Line
	6600 1850 7500 1850
Wire Wire Line
	6600 1950 7500 1950
Wire Wire Line
	6600 2050 7500 2050
Wire Wire Line
	6600 2150 7500 2150
Wire Wire Line
	6600 2250 7500 2250
Wire Wire Line
	6600 2350 7500 2350
Wire Wire Line
	6600 2450 7500 2450
Wire Wire Line
	6600 2550 7500 2550
Wire Wire Line
	6600 2650 7500 2650
Wire Wire Line
	6600 2950 7500 2950
Wire Wire Line
	6600 3050 7500 3050
Wire Wire Line
	6600 3150 7500 3150
Wire Wire Line
	6600 3250 7500 3250
Wire Wire Line
	6600 3350 7500 3350
Wire Wire Line
	6600 3450 7500 3450
Wire Wire Line
	6600 3550 7500 3550
Wire Wire Line
	6600 3650 7500 3650
Entry Bus Bus
	3800 800  3900 700 
Entry Bus Bus
	6400 700  6500 800 
Text Label 3950 1550 0    31   ~ 0
VADDR6
Text Label 3950 1450 0    31   ~ 0
VADDR7
Text Label 3950 1350 0    31   ~ 0
VADDR8
Text Label 9200 1350 0    31   ~ 0
V_CSYNC
Text Label 9200 1950 0    31   ~ 0
V_COLR
Text Label 9200 1850 0    31   ~ 0
V_R
Text Label 9200 1750 0    31   ~ 0
V_B
Text Label 9200 1650 0    31   ~ 0
V_G
Text Label 9200 1550 0    31   ~ 0
~V_VSYNC~
Text Label 9200 1450 0    31   ~ 0
~V_HSYNC~
Text Label 7150 4150 0    31   ~ 0
~VWAIT~
Text Label 5850 4850 0    31   ~ 0
COLR_IN
Text Label 5850 4750 0    31   ~ 0
R_IN
Text Label 5850 4650 0    31   ~ 0
B_IN
Text Label 5850 4550 0    31   ~ 0
G_IN
Text Label 5850 4450 0    31   ~ 0
~VSYNC_IN~
Text Label 5850 4350 0    31   ~ 0
~HSYNC_IN~
Text Label 5850 4250 0    31   ~ 0
CVIDEO_IN
Text Label 7150 2750 0    31   ~ 0
VADDR14
Text Label 7150 2850 0    31   ~ 0
VADDR15
Wire Wire Line
	6600 2750 7500 2750
Wire Wire Line
	6600 2850 7500 2850
Wire Wire Line
	6600 3750 7500 3750
Wire Wire Line
	6600 3850 7500 3850
Wire Wire Line
	6600 3950 7500 3950
Wire Wire Line
	6600 4050 7500 4050
Text Label 5850 4150 0    31   ~ 0
CSYNC_IN
Entry Bus Bus
	9750 700  9850 800 
Entry Wire Line
	9750 1350 9850 1450
Entry Wire Line
	9750 1450 9850 1550
Entry Wire Line
	9750 1550 9850 1650
Entry Wire Line
	9750 1650 9850 1750
Entry Wire Line
	9750 1750 9850 1850
Entry Wire Line
	9750 1850 9850 1950
Entry Wire Line
	9750 1950 9850 2050
Wire Wire Line
	9150 1350 9750 1350
Wire Wire Line
	9150 1450 9750 1450
Wire Wire Line
	9150 1550 9750 1550
Wire Wire Line
	9150 1650 9750 1650
Wire Wire Line
	9150 1750 9750 1750
Wire Wire Line
	9150 1850 9750 1850
Wire Wire Line
	9150 1950 9750 1950
Entry Wire Line
	6400 3750 6500 3850
Entry Wire Line
	6400 3650 6500 3750
Entry Wire Line
	6400 3550 6500 3650
Entry Wire Line
	6400 3950 6500 4050
Entry Wire Line
	6400 3850 6500 3950
Wire Wire Line
	5650 3550 6400 3550
Wire Wire Line
	5650 3650 6400 3650
Wire Wire Line
	5650 3750 6400 3750
Wire Wire Line
	5650 3850 6400 3850
Wire Wire Line
	5650 3950 6400 3950
Entry Wire Line
	6300 4450 6400 4550
Entry Wire Line
	6300 4350 6400 4450
Entry Wire Line
	6300 4250 6400 4350
Entry Wire Line
	6300 4850 6400 4950
Entry Wire Line
	6300 4750 6400 4850
Entry Wire Line
	6300 4650 6400 4750
Entry Wire Line
	6300 4550 6400 4650
Wire Wire Line
	5650 4250 6300 4250
Wire Wire Line
	5650 4350 6300 4350
Wire Wire Line
	5650 4450 6300 4450
Wire Wire Line
	5650 4550 6300 4550
Wire Wire Line
	5650 4650 6300 4650
Wire Wire Line
	5650 4750 6300 4750
Wire Wire Line
	5650 4850 6300 4850
Entry Wire Line
	6300 4150 6400 4250
Wire Wire Line
	5650 4150 6300 4150
Entry Bus Bus
	6400 6150 6500 6250
Entry Wire Line
	3800 1950 3900 2050
Entry Wire Line
	3800 1850 3900 1950
Wire Wire Line
	3900 1550 4350 1550
Wire Wire Line
	3900 1450 4350 1450
Entry Wire Line
	3800 2050 3900 2150
Wire Wire Line
	3900 1350 4350 1350
Text Label 5850 3350 0    31   ~ 0
V_CSYNC
Text Label 5850 3250 0    31   ~ 0
~VWAIT~
Text Label 5850 3450 0    31   ~ 0
~V_HSYNC~
Text Label 5850 3550 0    31   ~ 0
~V_VSYNC~
Text Label 5850 3650 0    31   ~ 0
V_G
Text Label 5850 3750 0    31   ~ 0
V_B
Text Label 5850 3850 0    31   ~ 0
V_R
Text Label 5850 3950 0    31   ~ 0
V_COLR
Text Label 5850 2850 0    31   ~ 0
~VZ80_RD~
Text Label 5850 2950 0    31   ~ 0
~VZ80_WR~
Text Label 5850 3050 0    31   ~ 0
~VZ80_IORQ~
Text Label 5850 3150 0    31   ~ 0
VZ80_CLK
Text Label 5850 1850 0    31   ~ 0
VADDR14
Text Label 5850 1950 0    31   ~ 0
VADDR15
Text Label 5850 1750 0    31   ~ 0
VADDR13
Text Label 5850 1650 0    31   ~ 0
VADDR12
Text Label 5850 1550 0    31   ~ 0
VADDR11
Text Label 5850 1450 0    31   ~ 0
VADDR10
Text Label 5850 1350 0    31   ~ 0
VADDR9
Text Label 5850 2750 0    31   ~ 0
VDATA7
Text Label 5850 2650 0    31   ~ 0
VDATA6
Text Label 5850 2550 0    31   ~ 0
VDATA5
Text Label 5850 2450 0    31   ~ 0
VDATA4
Text Label 5850 2350 0    31   ~ 0
VDATA3
Text Label 5850 2250 0    31   ~ 0
VDATA2
Text Label 5850 2150 0    31   ~ 0
VDATA1
Text Label 5850 2050 0    31   ~ 0
VDATA0
NoConn ~ 7500 4250
NoConn ~ 7500 4350
NoConn ~ 7500 4450
NoConn ~ 9150 2150
NoConn ~ 9150 2250
NoConn ~ 9150 2350
Entry Wire Line
	10400 2950 10500 3050
Text GLabel 10850 6000 2    31   Input ~ 0
CSYNC_IN
Text GLabel 10850 5900 2    31   Input ~ 0
CVIDEO_IN
Text GLabel 10850 5800 2    31   Input ~ 0
~HSYNC_IN~
Text GLabel 10850 5700 2    31   Input ~ 0
~VSYNC_IN~
Text GLabel 10850 5600 2    31   Input ~ 0
COLR_IN
Text GLabel 10950 5500 2    31   Input ~ 0
G_IN
Text GLabel 10950 5400 2    31   Input ~ 0
B_IN
Text GLabel 10950 5300 2    31   Input ~ 0
R_IN
Wire Wire Line
	10850 6000 10700 6000
Wire Wire Line
	10850 5900 10700 5900
Wire Wire Line
	10850 5800 10700 5800
Wire Wire Line
	10850 5700 10700 5700
Wire Wire Line
	10700 5600 10850 5600
Wire Wire Line
	10950 5500 10700 5500
Wire Wire Line
	10950 5400 10700 5400
Wire Wire Line
	10950 5300 10700 5300
Entry Wire Line
	10600 6100 10700 6000
Entry Wire Line
	10600 6000 10700 5900
Entry Wire Line
	10600 5900 10700 5800
Entry Wire Line
	10600 5800 10700 5700
Entry Wire Line
	10600 5700 10700 5600
Entry Wire Line
	10600 5600 10700 5500
Entry Wire Line
	10600 5500 10700 5400
Entry Wire Line
	10600 5400 10700 5300
Entry Bus Bus
	10500 6250 10600 6150
Wire Bus Line
	6500 6250 10500 6250
Text GLabel 10700 4450 2    39   Output ~ 0
RGB_R[0..4]
Text GLabel 10700 4750 2    39   Output ~ 0
RGB_B[0..4]
Text GLabel 10700 3800 2    39   Output ~ 0
~HSYNC_OUT~
Text GLabel 10700 3950 2    39   Output ~ 0
~VSYNC_OUT~
Text GLabel 10700 4100 2    39   Output ~ 0
~CSYNC_OUT~
Text GLabel 10700 4250 2    39   Output ~ 0
CSYNC_OUT
Text GLabel 10750 3650 2    39   Output ~ 0
COLR_OUT
Wire Wire Line
	10750 3650 10500 3650
Wire Wire Line
	10700 3800 10500 3800
Wire Wire Line
	10700 3950 10500 3950
Wire Wire Line
	10700 4100 10500 4100
Wire Wire Line
	10700 4250 10500 4250
Entry Bus Bus
	10400 4350 10500 4450
Entry Bus Bus
	10400 4500 10500 4600
Entry Bus Bus
	10400 4650 10500 4750
Wire Bus Line
	10500 4750 10700 4750
Wire Bus Line
	10500 4600 10700 4600
Wire Bus Line
	10500 4450 10700 4450
Entry Wire Line
	10400 3550 10500 3650
Entry Wire Line
	10400 3700 10500 3800
Entry Wire Line
	10400 3850 10500 3950
Entry Wire Line
	10400 4000 10500 4100
Entry Wire Line
	10400 4150 10500 4250
Entry Wire Line
	9500 4250 9600 4350
Entry Wire Line
	9500 4150 9600 4250
Entry Wire Line
	9500 4050 9600 4150
Entry Wire Line
	9500 3950 9600 4050
Entry Wire Line
	9500 3750 9600 3850
Entry Wire Line
	9500 3650 9600 3750
Entry Wire Line
	9500 3550 9600 3650
Entry Wire Line
	9500 3450 9600 3550
Entry Wire Line
	9500 3250 9600 3350
Entry Wire Line
	9500 3150 9600 3250
Entry Wire Line
	9500 3050 9600 3150
Entry Wire Line
	9500 2950 9600 3050
Entry Wire Line
	9500 2850 9600 2950
Entry Wire Line
	9500 2750 9600 2850
Entry Wire Line
	9500 2650 9600 2750
Entry Wire Line
	9500 2550 9600 2650
Wire Wire Line
	9150 2550 9500 2550
Wire Wire Line
	9150 2650 9500 2650
Wire Wire Line
	9150 2750 9500 2750
Wire Wire Line
	9150 2850 9500 2850
Wire Wire Line
	9150 2950 9500 2950
Wire Wire Line
	9150 3050 9500 3050
Wire Wire Line
	9150 3150 9500 3150
Wire Wire Line
	9150 3250 9500 3250
Wire Wire Line
	9150 3450 9500 3450
Wire Wire Line
	9150 3550 9500 3550
Wire Wire Line
	9150 3650 9500 3650
Wire Wire Line
	9150 3750 9500 3750
Wire Wire Line
	9150 3950 9500 3950
Wire Wire Line
	9150 4050 9500 4050
Wire Wire Line
	9150 4150 9500 4150
Wire Wire Line
	9150 4250 9500 4250
Text Label 9200 2450 0    31   ~ 0
COLR_OUT
Text Label 9200 2550 0    31   ~ 0
~CSYNC_OUT~
Text Label 9200 2650 0    31   ~ 0
CSYNC_OUT
Text Label 9200 2750 0    31   ~ 0
~VSYNC_OUT~
Text Label 9200 2850 0    31   ~ 0
~HSYNC_OUT~
Text Label 9200 3950 0    31   ~ 0
RGB_B0
Text Label 9200 4050 0    31   ~ 0
RGB_B1
Text Label 9200 4150 0    31   ~ 0
RGB_B2
Text Label 9200 4250 0    31   ~ 0
RGB_B3
Text Label 9200 2950 0    31   ~ 0
RGB_R0
Text Label 9200 3050 0    31   ~ 0
RGB_R1
Text Label 9200 3150 0    31   ~ 0
RGB_R2
Text Label 9200 3250 0    31   ~ 0
RGB_R3
Text Label 9200 3450 0    31   ~ 0
RGB_G0
Text Label 9200 3550 0    31   ~ 0
RGB_G1
Text Label 9200 3650 0    31   ~ 0
RGB_G2
Text Label 9200 3750 0    31   ~ 0
RGB_G3
Wire Wire Line
	9150 2450 9500 2450
Entry Wire Line
	9500 2450 9600 2550
Entry Bus Bus
	9600 4650 9700 4750
Entry Bus Bus
	10300 4750 10400 4650
Wire Bus Line
	10300 4750 9700 4750
Text GLabel 10700 4600 2    39   Output ~ 0
RGB_G[0..4]
Wire Wire Line
	600  4400 850  4400
Wire Wire Line
	600  4500 850  4500
Wire Wire Line
	600  4600 850  4600
Wire Wire Line
	600  4700 850  4700
Wire Wire Line
	600  4800 850  4800
Wire Wire Line
	600  4900 850  4900
Wire Wire Line
	600  5000 850  5000
Wire Wire Line
	600  5100 850  5100
Wire Wire Line
	600  5200 850  5200
Wire Wire Line
	600  5300 850  5300
Wire Wire Line
	600  5400 850  5400
Wire Wire Line
	600  5500 850  5500
Wire Wire Line
	600  5600 850  5600
Wire Wire Line
	600  5700 850  5700
Wire Wire Line
	600  5800 850  5800
Wire Wire Line
	600  5900 850  5900
Wire Wire Line
	600  6000 850  6000
Wire Wire Line
	600  6100 850  6100
Wire Wire Line
	600  6200 850  6200
Wire Wire Line
	1750 4400 2000 4400
Wire Wire Line
	1750 4500 2000 4500
Wire Wire Line
	1750 4600 2000 4600
Wire Wire Line
	1750 4700 2000 4700
Wire Wire Line
	1750 4800 2000 4800
Wire Wire Line
	1750 4900 2000 4900
Wire Wire Line
	1750 5000 2000 5000
Wire Wire Line
	1750 5100 2000 5100
Wire Wire Line
	1750 5400 2150 5400
Wire Wire Line
	1750 5500 2150 5500
Wire Wire Line
	1750 5600 2150 5600
Wire Wire Line
	5650 5350 6200 5350
Entry Wire Line
	6200 5350 6300 5450
Wire Wire Line
	5650 5250 6200 5250
Entry Wire Line
	6200 5250 6300 5350
Wire Wire Line
	5650 5650 6200 5650
Entry Wire Line
	6200 5650 6300 5750
Wire Wire Line
	5650 5550 6200 5550
Entry Wire Line
	6200 5550 6300 5650
Text Label 5850 5450 0    31   ~ 0
Z80_RA14
Text Label 5850 5350 0    31   ~ 0
Z80_RA13
Text Label 5850 5250 0    31   ~ 0
Z80_RA12
NoConn ~ 4350 6250
NoConn ~ 5650 5150
NoConn ~ 5650 5050
NoConn ~ 5650 4950
Entry Wire Line
	9500 3350 9600 3450
Wire Wire Line
	9150 3350 9500 3350
Text Label 9200 3350 0    31   ~ 0
RGB_R4
Entry Wire Line
	9500 3850 9600 3950
Wire Wire Line
	9150 3850 9500 3850
Text Label 9200 3850 0    31   ~ 0
RGB_G4
Entry Wire Line
	9500 4350 9600 4450
Wire Wire Line
	9150 4350 9500 4350
Text Label 9200 4350 0    31   ~ 0
RGB_B4
NoConn ~ 5650 4050
NoConn ~ 9150 2050
Entry Wire Line
	6500 4250 6600 4150
Wire Wire Line
	6600 4150 7500 4150
Wire Bus Line
	3900 700  9750 700 
Wire Bus Line
	600  7750 6200 7750
Wire Bus Line
	2200 7550 6650 7550
Wire Bus Line
	650  4000 3500 4000
Wire Bus Line
	2250 4100 2250 5500
Wire Bus Line
	3800 6450 3800 7650
Wire Bus Line
	9850 800  9850 2050
Wire Bus Line
	3800 800  3800 2050
Wire Bus Line
	10400 3550 10400 4650
Wire Bus Line
	6400 4250 6400 6150
Wire Bus Line
	10600 5400 10600 6150
Wire Bus Line
	3700 5550 3700 7450
Wire Bus Line
	550  1300 550  3900
Wire Bus Line
	6300 5350 6300 7650
Wire Bus Line
	9600 2550 9600 4650
Wire Bus Line
	500  650  500  7650
Wire Bus Line
	2100 650  2100 2700
Wire Bus Line
	2100 2900 2100 7450
Wire Bus Line
	10400 650  10400 3050
Wire Bus Line
	6500 800  6500 4250
Wire Bus Line
	3600 650  3600 6900
$EndSCHEMATC
