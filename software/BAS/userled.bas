01 REM ****************************************
02 REM
03 REM Z80-MBC2 USER led blink demo:
04 REM
05 REM Blink USER led until USER key is pressed
06 REM
07 REM ****************************************
08 REM
13 PRINT "Press USER key to exit"
14 LEDUSER = 0 : REM USER LED write Opcode (0x00)
15 KEYUSER = 128 : REM USER KEY read Opcode (0x80)
16 PRINT "Now blinking..."
18 OUT 1,LEDUSER : REM Write the USER LED write Opcode
20 OUT 0,1 : REM Turn USER LED on
30 GOSUB 505 : REM Delay sub
40 OUT 1,LEDUSER : REM Write the USER LED write Opcode
45 OUT 0,0 : REM Turn USER LED off
50 GOSUB 505 : REM Delay
60 GOTO 18
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
700 OUT 1,LEDUSER : REM Write the USER LED write Opcode
710 OUT 0,0 : REM Turn USER LED off
720 PRINT "Terminated by USER Key"
