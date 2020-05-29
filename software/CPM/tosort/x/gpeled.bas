01 REM ************************************************
02 REM
03 REM Z80-MBC2 GPE led blink demo:
04 REM
05 REM Blink a led attached to PIN 8 (GPA5) of the GPIO 
06 REM connector (J7) until USER key is pressed
07 REM (see A040618 schematic).
08 REM The GPE option must be installed.
09 REM
10 REM ************************************************
11 REM
12 REM Demo HW wiring (see A040618 schematic):
13 REM
14 REM    GPIO
15 REM    (J7)
16 REM  +-----+
17 REM  | 1 2 |
18 REM  | 3 4 |   LED         RESISTOR
19 REM  | 5 6 |                 680
20 REM  | 7 8-+--->|-----------/\/\/--+
21 REM  | 9 10|                       |
22 REM  |11 12|                       |
23 REM  |13 14|                       |
24 REM  |15 16|                       |
25 REM  |17 18|                       |
26 REM  |19 20+-----------------------+ GND
27 REM  +-----+  
28 REM    
29 REM ************************************************
30 REM
31 PRINT "Press USER key to exit"
32 REM
33 REM * * * * SET USED OPCODES FOR I/O
34 REM 
35 KEYUSER = 128 : REM USER KEY read Opcode (0x80)
36 IODIRA = 5 : REM IODIRA write Opcode (0x05)
37 GPIOA = 3 : REM GPIOA write Opcode (0x03)
38 REM
50 OUT 1,IODIRA : OUT 0,0 : REM Set all GPAx as output (IODIRA=0x00)
60 PRINT "Now blinking GPA5 (GPIO port pin 8)..."
64 REM
65 REM * * * * * BLINK LOOP
66 REM
70 OUT 1,GPIOA : OUT 0,32 : REM Set GPA5=1, GPAx=0 (GPIOA=B00100000=32)
80 GOSUB 505 : REM Delay sub
90 OUT 1,GPIOA : OUT 0,0 : REM Clear all pins GPAx (MCP23017)
100 GOSUB 505 : REM Delay sub
130 GOTO 70
490 REM
500 REM * * * * * DELAY SUB
501 REM
505 FOR J=0 TO 150
506 OUT 1,KEYUSER : REM Write the USER KEY read Opcode
507 IF INP(0)=1 THEN GOTO 700 : REM Exit if USER key is pressed
510 NEXT J
520 RETURN
690 REM
691 REM * * * * * PROGRAM END
692 REM
700 OUT 1,GPIOA : OUT 0,0 : REM Clear all pins GPAx (MCP23017)
720 PRINT "Terminated by USER Key"
