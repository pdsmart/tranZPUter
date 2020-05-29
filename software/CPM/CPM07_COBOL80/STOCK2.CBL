       IDENTIFICATION DIVISION.
       PROGRAM-ID. GOODS-IN.
       AUTHOR. MICRO FOCUS LTD.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. MDS-800.
       OBJECT-COMPUTER. MDS-800.
       SPECIAL-NAMES. CONSOLE IS CRT.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT STOCK-FILE ASSIGN "STOCK.IT"
           ORGANIZATION INDEXED
           ACCESS DYNAMIC
           RECORD KEY STOCK-CODE.
           SELECT TRANS-FILE
           ASSIGN "STOCK.TRS"
           ORGANIZATION SEQUENTIAL.
      /
       DATA DIVISION.
       FILE SECTION.
       FD  STOCK-FILE; RECORD 32.
       01  STOCK-ITEM.
           02  STOCK-CODE PIC X(4).
           02  STOCK-DESCRIPT PIC X(24).
           02  UNIT-SIZE PIC 9(4).
       FD  TRANS-FILE; RECORD 30.
       01  TRANS-RECORD.
           02  TRAN-NO PIC 9(4).
           02  TF-STOCK-CODE PIC X(4).
           02  TF-QUANTITY PIC 9(8).
           02  TF-ORDER-NO PIC X(6).
           02  TF-DATE PIC X(8).
       WORKING-STORAGE SECTION.
       01  STOCK-INWARD-FORM.
           02  PRG-TITLE PIC X(20) VALUE "       GOODS INWARD".
           02  FILLER PIC X(140).
           02  CODE-HDNG PIC X(23) VALUE "STOCK CODE       <    >".
           02  FILLER PIC X(57).
           02  ORDER-NO-HDNG PIC X(23) VALUE "ORDER NO       <      >".
           02  FILLER PIC X(57).
           02  DATE-HDNG PIC X(24) VALUE "DELIVERY DATE  MM/DD/YY".
           02  FILLER PIC X(56).
           02  UNITS-HDNG PIC X(23) VALUE "NO OF UNITS      <    >".
       01  STOCK-RECEIPT REDEFINES STOCK-INWARD-FORM.
           02  FILLER PIC X(178).
           02  SR-STOCK-CODE PIC X(4).
           02  FILLER PIC X(74).
           02  SR-ORDER-NO PIC X(6).
           02  FILLER PIC X(73).
           02  SR-DATE.
               04  SR-MM PIC 99.
               04  FILLER PIC X.
               04  SR-DD PIC 99.
               04  FILLER PIC X.
               04  SR-YY PIC 99.
           02  FILLER PIC X(75).
           02  SR-NO-OF-UNITS PIC 9(4).
       01  CONFIRM-MSG REDEFINES STOCK-INWARD-FORM.
           02  FILLER PIC X(184).
           02  CM-STOCK-DESCRIPT PIC X(24).
           02  FILLER PIC X(352).
           02  UNIT-SIZE-HDNG PIC X(18).
           02  CM-UNIT-SIZE PIC 9(4).
           02  FILLER PIC X(58).
           02  QUANTITY-HDNG PIC X(14).
           02  CM-QUANTITY PIC 9(8).
           02  FILLER PIC X(58).
           02  OK-HDNG PIC X(3).
           02  CM-Y-OR-N PIC X.
      /
       PROCEDURE DIVISION.
       START-PROC.
           OPEN I-O STOCK-FILE.
           OPEN OUTPUT TRANS-FILE.
           DISPLAY SPACE.
           MOVE 0 TO TRAN-NO.
           DISPLAY STOCK-INWARD-FORM.
       GET-INPUT.
           ACCEPT STOCK-RECEIPT.
           IF SR-STOCK-CODE = SPACE GO TO END-IT.
           IF SR-NO-OF-UNITS NOT NUMERIC GO TO INVALID-ENTRY.
           MOVE SR-STOCK-CODE TO STOCK-CODE.
           READ STOCK-FILE; INVALID GO TO INVALID-CODE.
      *VALID ENTRY, CALCULATE AND DISPLAY TOTAL QUANTITY IN TO CONFIRM
           MOVE STOCK-DESCRIPT TO CM-STOCK-DESCRIPT.
           MOVE "UNIT SIZE" TO UNIT-SIZE-HDNG.
           MOVE UNIT-SIZE TO CM-UNIT-SIZE.
           MOVE "QUANTITY IN" TO QUANTITY-HDNG.
           MOVE UNIT-SIZE TO TF-QUANTITY.
           MULTIPLY SR-NO-OF-UNITS BY TF-QUANTITY.
           MOVE TF-QUANTITY TO CM-QUANTITY.
           MOVE "OK?" TO OK-HDNG.
           DISPLAY CONFIRM-MSG.
           ACCEPT CM-Y-OR-N AT 1004.
           IF CM-Y-OR-N = "Y" PERFORM WRITE-TRANS.
      *CLEAR INPUT DATA ON SCREEN
           MOVE SPACE TO CONFIRM-MSG.
           MOVE "MM/DD/YY" TO SR-DATE.
           DISPLAY STOCK-RECEIPT.
           DISPLAY CONFIRM-MSG.
           GO TO GET-INPUT.
       WRITE-TRANS.
           ADD 1 TO TRAN-NO.
           MOVE STOCK-CODE TO TF-STOCK-CODE.
           MOVE SR-ORDER-NO TO TF-ORDER-NO.
           MOVE GET-INPUT TO TF-DATE.
           WRITE TRANS-RECORD.
       INVALID-ENTRY.
           DISPLAY "NON-NUMERIC NO OF UNITS" AT 0325.
           GO TO GET-INPUT.
       INVALID-CODE.
           DISPLAY "INVALID CODE           " AT 0325.
           GO TO GET-INPUT.
       END-IT.
           CLOSE STOCK-FILE.
           CLOSE TRANS-FILE.
           DISPLAY SPACE.
           DISPLAY "END OF PROGRAM".
           STOP RUN.
