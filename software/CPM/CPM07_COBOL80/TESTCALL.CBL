000000******************************************************************
000000*
000000* Program "Testcall" to demonstrate L/II COBOL calling mechanism
000000*
000000******************************************************************
000000 Working-storage section.
000000 01  progname pic x(4).
000000 01  message-size pic 9(2) comp value 60.
000000 01  message-text pic x(60) value
000000     "This message is sent via a called program to the screen.".
000000 Procedure division.
000000     move "call" to progname.
000000     call progname using message-size,message-text
000000          overflow display "call overflowed".
000000******************************************************************
000000*
000000* End of demonstration program "Testcall"
000000*
000000******************************************************************
