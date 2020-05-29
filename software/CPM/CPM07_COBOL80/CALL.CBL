000000******************************************************************
000000*
000000* Program "Call" called by "Testcall"; this is COBOL version;
000000* compare with functionally equivalent assembler version.
000000*
000000******************************************************************
000000 Working-storage section.
000000 01  temp pic 9(2) comp.
000000 01  text-buffer value space.
000000     02 tbuf-table pic x occurs 80.
000000 Linkage section.
000000 01  mess-text.
000000     02 mtex-table pic x occurs 80.
000000 01  mess-size pic 9(2) comp.
000000 Procedure division using mess-size,mess-text.
000000 l.
000000     move 0 to temp perform move-byte until temp = mess-size.
000000     display text-buffer.
000000     exit program.
000000 move-byte.
000000     add 1 to temp move mtex-table (temp) to tbuf-table (temp).
000000******************************************************************
000000*
000000* End of demonstration program "Call"
000000*
000000******************************************************************
