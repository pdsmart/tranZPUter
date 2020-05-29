15 OUT 1,132 : REM Write the DATETIME read Opcode
20 SEC = INP(0) : REM Read a RTC parameter
30 MINUTES = INP(0) : REM Read a RTC parameter
40 HOURS = INP(0) : REM Read a RTC parameter
50 DAY = INP(0) : REM Read a RTC parameter
60 MNTH = INP(0) : REM Read a RTC parameter
70 YEAR = INP(0) : REM Read a RTC parameter
80 TEMP = INP(0) : REM Read a RTC parameter
83 IF TEMP < 128 THEN 90 : REM Two complement correction
85 TEMP = TEMP - 256
90 PRINT
100 PRINT "THE TIME IS: ";
110 PRINT HOURS; : PRINT ":"; : PRINT MINUTES; : PRINT ":"; : PRINT SEC
120 PRINT "THE DATE IS: ";
125 YEAR= YEAR+ 2000
130 PRINT DAY; : PRINT "/"; : PRINT MNTH; : PRINT "/"; : PRINT YEAR
135 PRINT "THE TEMPERATURE IS: ";
140 PRINT TEMP; : PRINT "C"
145 PRINT
