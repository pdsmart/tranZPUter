000000 IDENTIFICATION DIVISION.
000000******************************************************************
000000*                                                                *
000000*  COPYRIGHT (C) 1982,1982 MICRO FOCUS LTD.                      *
000000*                                                                *
000000*            MICRO FOCUS LTD.                                    *
000000*            58, ACACIA ROAD,                                    *
000000*            ST. JOHNS WOOD,                                     *
000000*            LONDON NW8 6AG.                                     *
000000*                                                                *
000000*            TEL.   01 722 8843/4/5/6/7                          *
000000*            TELEX  28536 MICROF G                               *
000000*                                                                *
000000******************************************************************
000000*
000000 PROGRAM-ID. COMMAND LINE INTERPRETOR.
000000 AUTHOR. MICRO FOCUS LTD.
000000 INSTALLATION. MICRO FOCUS - SWINDON.
000000 DATE-WRITTEN. 6TH DECEMBER 1982.
000000 DATE-COMPILED. 6TH DECEMBER 1982.
000000*
000000 ENVIRONMENT DIVISION.
000000 SOURCE-COMPUTER. 8080.
000000 OBJECT-COMPUTER. 8080.
000000 SPECIAL-NAMES. CONSOLE IS CRT.
000000/*****************************************************************
000000*                                                                *
000000*  DATA USED BY THE CLI TO STORE THE USER'S INSTRUCTIONS.        *
000000*                                                                *
000000******************************************************************
000000*
000000 DATA DIVISION.
000000 WORKING-STORAGE SECTION.
000000*
000000 01  TEMP           PIC 9(2) COMP.
000000 01  SUB1           PIC 9(2) COMP.
000000 01  SUB2           PIC 9(2) COMP.
000000 01  SUB2-SAV       PIC 9(2) COMP.
000000 01  TMAX           PIC 9(2) COMP.
000000 01  CHOICE         PIC X.
000000*
000000 01  RTS-ROUTINES.
000000   02  POKE-CLI     PIC X VALUE X"91".
000000   02  CHAIN        PIC X VALUE X"84".
000000   02  GET-CHAR     PIC X VALUE X"D8".
000000   02  SOUND-ALARM  PIC X VALUE X"E5".
000000*
000000* DISPLAY LINES
000000*
000000 01  INIT-LINE.
000000   02  INIT-LINE-1  PIC X(68) VALUE "COBOL: A(nimate) C(ompile) D(
000000-      "rive) F(orms2) Q(uit) R(un) S(witches)".
000000   02  FILLER       PIC X(4).
000000   02  INIT-CHOICE  PIC X.
000000*
000000 01  FILE-QUESTION-LINE.
000000   02  FQL-1        PIC X(22) VALUE "Enter name of file to ".
000000   02  VERB         PIC X(8).
000000*
000000* COMMAND-LINE COMPONENTS
000000*
000000 01  SWITCH-AREA.
000000   02  FILLER       PIC X VALUE "(".
000000   02  SWITCHES     PIC X(40) VALUE SPACE.
000000*
000000 01  FILE-NAME      PIC X(16).
000000*
000000 01  CLI-REST       PIC X(80).
000000*
000000 01  WORK-AREA.
000000   02  WORK-BYTE    PIC 9(2) OCCURS 80 COMP.
000000*
000000 01  OUTPUT-CLI              VALUE SPACE.
000000   02  OUT-BYTE     PIC 9(2) OCCURS 128 COMP.
000000*
000000 01  PROG-AREA.
000000   02  DRIVE        PIC X    VALUE SPACE.
000000   02  FILLER       PIC X    VALUE ":".
000000   02  PROG-NAME    PIC X(16).
000000*
000000/*****************************************************************
000000*                                                                *
000000*  MAIN ENTRY TO CLI PROGRAM. IS USED BY ORDINARY ENTRY TO       *
000000*  COMMAND LINE INTERPRETOR, AS WELL AS BY PROGRAMS WHICH ARE    *
000000*  RETURNING CONTROL TO THE CLI FOR CONTINUATION COMMANDS.       *
000000*                                                                *
000000******************************************************************
000000*
000000 PROCEDURE DIVISION.
000000 MAIN-ENTRY.
000000*
000000*  TEST IF SCREEN SHOULD BE CLEARED. IF "X" ON COMMAND LINE, THEN
000000*  THIS IS A SECOND OR SUBSEQUENT ENTRY, AND THE SCREEN SHOULD
000000*  NOT BE CLEARED.
000000*
000000     ACCEPT WORK-AREA FROM CONSOLE.
000000     IF   WORK-AREA NOT = "X"
000000          DISPLAY SPACE.
000000     CALL SOUND-ALARM.
000000*
000000 LOOP.
000000     MOVE SPACE TO INIT-CHOICE.
000000     DISPLAY INIT-LINE.
000000     DISPLAY LOW-VALUE AT 0170.
000000     CALL GET-CHAR USING CHOICE.
000000     DISPLAY SPACE.
000000     MOVE CHOICE TO INIT-CHOICE.
000000     DISPLAY INIT-LINE.
000000*
000000     IF   CHOICE = "A" OR "a"
000000          MOVE "ANIMATE:" TO VERB
000000          MOVE "ANIMATE.COM" TO PROG-NAME
000000          GO TO FILE-QUESTION.
000000     IF   CHOICE = "C" OR "c"
000000          MOVE "COMPILE:" TO VERB
000000          MOVE "COBOL.COM" TO PROG-NAME
000000          GO TO FILE-QUESTION.
000000     IF   CHOICE = "D" OR "d"
000000          GO TO DRIVE-SET.
000000     IF   CHOICE = "F" OR "f"
000000          MOVE "FORMS2.COM" TO PROG-NAME
000000          MOVE 0 TO SUB2
000000          GO TO LOADER.
000000     IF   CHOICE = "Q" OR "q"
000000          GO TO EXITING.
000000     IF   CHOICE = "R" OR "r"
000000          MOVE "RUN:" TO VERB
000000          MOVE "RUN.COM" TO PROG-NAME
000000          GO TO FILE-QUESTION.
000000     IF   CHOICE = "S" OR "s"
000000          GO TO SWITCH-SET.
000000     CALL SOUND-ALARM.
000000     GO TO LOOP.
000000*
000000/*****************************************************************
000000*                                                                *
000000*  CODE TO HANDLE FILENAME OF PROGRAM TO BE COMPILED, ANIMATED   *
000000*  OR EXECUTED.                                                  *
000000*                                                                *
000000******************************************************************
000000*
000000 FILE-QUESTION.
000000     MOVE SPACE TO FILE-NAME.
000000     DISPLAY FILE-QUESTION-LINE AT 0201.
000000     ACCEPT FILE-NAME AT 0232.
000000     IF   FILE-NAME = SPACES
000000          GO TO LOOP.
000000*
000000     PERFORM CLEAR-LINES.
000000     MOVE SPACE TO CLI-REST.
000000     DISPLAY "Any further command line ?" AT 0201.
000000     ACCEPT CLI-REST AT 0301.
000000*
000000     MOVE 0 TO SUB2.
000000     IF   "RUN.COM" = PROG-NAME
000000          IF   SPACE NOT = SWITCHES
000000               MOVE SWITCH-AREA TO WORK-AREA
000000               MOVE 41 TO TMAX
000000               MOVE 0 TO SUB1
000000               PERFORM TRANSFER-BUFFER
000000               ADD 1 TO SUB2
000000               MOVE 41 TO OUT-BYTE (SUB2).
000000     MOVE FILE-NAME TO WORK-AREA.
000000     MOVE 0 TO SUB1.
000000     MOVE 16 TO TMAX.
000000     PERFORM TRANSFER-BUFFER.
000000     MOVE CLI-REST TO WORK-AREA.
000000     MOVE 0 TO SUB1.
000000     MOVE 80 TO TMAX.
000000     PERFORM TRANSFER-BUFFER.
000000     IF   SUB2 > 80
000000          GO TO CLI-OVF.
000000*
000000*  COMMAND LINE NOW CREATED, CHAIN TO THE NEXT PROGRAM. THIS
000000*  IS DONE BY SETTING A COMMAND LINE FOR THE RTS TO EXECUTE.
000000*
000000 LOADER.
000000     CALL POKE-CLI USING SUB2, OUTPUT-CLI.
000000     PERFORM CLEAR-LINES.
000000     DISPLAY "Loading ..." at 0201.
000000     DISPLAY LOW-VALUE AT 0301.
000000     IF   DRIVE = SPACE
000000          CALL CHAIN USING PROG-NAME
000000     ELSE
000000          CALL CHAIN USING PROG-AREA.
000000*
000000/*****************************************************************
000000*                                                                *
000000*  SUPPORT CLI ROUTINES, USED TO MANIPULATE THE FIELDS BEFORE    *
000000*  CONTROL IS TRANSFERRED TO A SUPPORT PROGRAM.                  *
000000*                                                                *
000000******************************************************************
000000*
000000 SWITCH-SET.
000000     MOVE SPACE TO SWITCHES.
000000     DISPLAY "Switches:" AT 0201.
000000     ACCEPT SWITCHES AT 0211.
000000     INSPECT SWITCHES REPLACING
000000                      ALL "(" BY SPACE
000000                      ALL ")" BY SPACE.
000000     GO TO LOOP.
000000*
000000 DRIVE-SET.
000000     DISPLAY "Enter Drive:" AT 0201.
000000     ACCEPT DRIVE AT 0214.
000000     GO TO LOOP.
000000*
000000 EXITING.
000000     DISPLAY "Returning to CP/M" AT 0201.
000000     DISPLAY LOW-VALUE AT 0301.
000000     STOP RUN.
000000*
000000/*****************************************************************
000000*                                                                *
000000*  WORK ROUTINES USED TO MANIPULATE THE SCREEN.                  *
000000*                                                                *
000000******************************************************************
000000*
000000 CLI-OVF.
000000     PERFORM CLEAR-LINES.
000000     DISPLAY "Command buffer overflow" AT 0301.
000000     GO TO LOOP.
000000*
000000 CLEAR-LINES.
000000     MOVE SPACE TO WORK-AREA.
000000     DISPLAY WORK-AREA AT 0201.
000000     DISPLAY WORK-AREA AT 0301.
000000*
000000 TRANSFER-BUFFER.
000000     ADD 1 TO SUB1.
000000     ADD 1 TO SUB2.
000000     MOVE WORK-BYTE (SUB1) TO TEMP.
000000     IF   TEMP NOT = 32
000000          MOVE SUB2 TO SUB2-SAV
000000          MOVE TEMP TO OUT-BYTE (SUB2).
000000     IF   SUB1 < TMAX
000000          GO TO TRANSFER-BUFFER.
000000     MOVE SUB2-SAV TO SUB2.
000000     ADD 1 TO SUB2.
000000*
