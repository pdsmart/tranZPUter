PROGRAM  PAGE10;

{ This program is a CP/M utility for use with an  80 by 24 CRT.
It types out a page at a time to the screen.

First version  1 August 1980

By    T. W. Lougheed
      Dept. of T. & A. Mechanics
      Thurston Hall, Cornell U.
      Ithaca,  NY  14853

      home phone 272-4993

Last version  10 February 1981   }


CONST  HEIGHT = 24;  { Dimensions of the screen in real characters. }
       WIDTH  = 80;

       { ASCII controll-codes. }

       EOF = $1A;  { CP/M  End-of-file marker:  ^Z. }
       BRK = $10;  { Data-link escape: break:  ^P. }
       ESC = $1B;  { Escape. }
       NAK = $15;  { Negative acknowledge:  ^U. }
       CAN = $18;  { Cancel:  ^X. }
       BS  = $08;  { Backspace: ^H. }
       TAB = $09;  { Horizontal tab: ^I. }
       CR  = $0D;  { Caraige-return: ^M. }
       LF  = $0A;  { Linefeed:  ^J. }
       VT  = $0B;  { Vertical tab:  ^K. }
       FF  = $0C;  { Formfeed:  ^L. }
       DEL = $7F;  { Rubout. }

VAR    C, D     : CHAR;
       K, L     : INTEGER;
           { Count of characters and lines for paging. }
           { K = last character written on current line, L = current line. }
       CANCELED : BOOLEAN;
           { Flag used to stop looping. }
       FNAME    : STRING[127];
           { The name of the source file. }
       SOURCE   : FILE OF PACKED ARRAY [1..4096] OF CHAR;
           { Note: NOT A TEXT-FILE!  This means no meddling by PASCAL with
           the data from the file.  We will read from the file using the
           procedure  GNB  (Get Next Byte)  supplied with PASCAL/MT.
           Given the array-limits  1..4096  it reads  32  records at a time,
           which causes less rattle on the drives than one record at a time. }
       COMMANDS,
       POSITIVE,
       NEGATIVE : SET OF CHAR;
           { Types of responses to the  "... more "  prompt. }




{ Inserts into  FNAME  the data in the  CP/M  command buffer at $0080. }

PROCEDURE  CPM_COMMAND_LINE;
   VAR BUFFER : ABSOLUTE[ $0080 ] PACKED ARRAY[0..127] OF CHAR;
   BEGIN
   MOVE( BUFFER, FNAME, 127 );
   END;

{ Erases the screen for an IMSAI VIO board. }

PROCEDURE  CLEAR;
   BEGIN  WRITE( CHR(EOF) );  END;



BEGIN { PAGE }

POSITIVE := [ ' ', 'y', 'Y', 'g', 'G', 'c', 'C', CHR(CR), CHR(LF) ];
NEGATIVE := [ 'q', 'Q', 'n', 'N', 'e', 'E', 'x', 'X',
   CHR(CAN), CHR(NAK), CHR(EOF), CHR(ESC), CHR(BRK) ];
COMMANDS := POSITIVE + NEGATIVE;

{ Get the file name from the buffer. }
CPM_COMMAND_LINE;

REPEAT
   { If none available, then ask for one. }
   IF (LENGTH( FNAME ) = 0) OR (FNAME = ' ') THEN
      REPEAT  WRITE( 'File ?  ' );  READ( FNAME )  UNTIL LENGTH( FNAME ) > 0;
   { Open the source file.  K <> 255 if everything's okay. }
   OPEN( SOURCE, FNAME, K );
   IF K >= 249 THEN BEGIN
      WRITE( 'Unable to open file "', FNAME,
       '", BDOS error ', K:3, '.  Quit ?  ' );
      READ( D );  WRITELN;
      IF D IN [ 'q', 'Q', 'y', 'Y', 'e', 'E' ] THEN EXIT;
      FNAME := '';
      END;
   UNTIL  K < 249;


{ Cosmetics. }
CLEAR;
WRITELN( '------------------------------------------------------------------',
 '-------------' );



{ Preparation for paging loop. }

C := GNB( SOURCE );   K := 0;  { Character last printed (LF). }
CANCELED := FALSE;    L := 2;  { Line currently on. }


{ Central loop. }

REPEAT

   { Choose what to do with the character. }

   CASE ORD(C) OF
      LF  : BEGIN  K := 0;  L := L + 1  END;
      TAB : BEGIN 
         IF K < 71    { If it will fit on this line. }
            THEN REPEAT
               WRITE( ' ' );    K := K + 1;
               UNTIL (K > 1) AND ((K-1) MOD 8 = 0)
            ELSE BEGIN WRITELN; L := L + 1; K := 0 END;
         END;
      FF, VT :
         WHILE L < HEIGHT - 1 DO BEGIN  WRITELN; L := L + 1 END;
      ELSE IF K < WIDTH THEN BEGIN  WRITE( C ); K := K + 1 END
         ELSE WRITE( CHR(BS), C );  { No scroll-over. }
      END;


   { When the following is indeed true, one presumably is at the beginning
   of the last line on the screen. }

   IF L + 1 >= HEIGHT THEN BEGIN

      WRITE( CHR(CR), ' ':69, '... more ' );  READ( D );

      WHILE  NOT (D IN COMMANDS) OR (D = '?') DO BEGIN
         WRITELN;
         WRITELN( 'To continue paging, type a blank or <CR>.' );
         WRITELN( 'To stop paging type "N", "Q", "X", ^X, ^U,',
          ' <BRK>, or <ESC>.' );
         WRITE( ' ':70, '... more ' );  READ( D );
         END;

      CANCELED :=  D IN NEGATIVE;

      IF NOT CANCELED THEN BEGIN
         CLEAR;
         L := 1;             { Which puts the cursor back at the top. }
         END;

      END;


   C := GNB( SOURCE );
   UNTIL  (C = CHR(EOF)) OR CANCELED;

{ Cosmetic sign-off. }
WRITELN( '-----------------------------------------------------------------',
 '--------------' );
WRITELN( 'PAGE                      version 10                     file  "',
 FNAME, '"' );
WRITELN;

END { PAGE }
.

