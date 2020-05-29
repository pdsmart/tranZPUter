(*====================================================================*)
(*  PROGRAM TITLE: PASCAL CROSS-REFERENCING PROGRAM                   *)
(*                                                                    *)
(*  PROGRAM NAME: XREF                                                *)
(*                                                                    *)
(*  LAST UPDATE:  14-JUL-81 by Warren A. Smith                        *)
(*                                                                    *)
(*      NOTE: THIS PROGRAM WAS ORIGINALLY WRITTEN BY N. WIRTH AND     *)
(*      ADAPTED FOR UCSD PASCAL (I.4 - THE PUBLIC DOMAIN VERSION)     *)
(*      BY SHAWN FANNING (IN 1978) AND SUBSEQUENTLY ADAPTED FOR       *)
(*      PASCAL/MT+ BY MIKE LEHMAN (IN 1981). THIS VERSION WAS THEN    *)
(*      MODIFIED BE WARREN A. SMITH TO TRY TO GET BACK TO ISO STAN-   *)
(*      DARD PASCAL AND TO ADD THE ADDITIONAL FEATURE OF MAPPING      *)
(*      OUT THE COMPOUND STATEMENTS. THIS IS A PUBLIC DOMAIN PROGRAM. *)
(*      IF YOU MAKE REVISIONS, ETC. PLEASE LEAVE THE AUTHOR           *)
(*      AND ALL MODIFIERS NAMES IN THE SOURCE FILE.  THANK YOU.       *)
(*                                                                    *)
(*  PROGRAM SUMMARY:                                                  *)
(*                                                                    *)
(*     THIS PROGRAM PRODUCES A CROSS-REFERENCE LISTING FOR ANY        *)
(*   PASCAL PROGRAM.  OCCURENCES ONLY ARE LISTED.  NO DISTINCTION IS  *)
(*   MADE BETWEEN DEFINITIONS AND REFERENCES.  IT WILL ALSO GIVE A    *)
(*   GRAPHICAL REPRESENTATION OF THE BLOCK STRUCTURE OF THE PROGRAM.  *)
(*   THIS FEATURE WAS ADDED BY WARREN A. SMITH (IN JULY 1981)         *)
(*====================================================================*)


PROGRAM XREF;

(*CROSS REFERENCE GENERATOR FOR PASCAL PROGRAMS.  N.WIRTH, 7.5.74*)
(*'QUADRATIC QUOTIENT' HASH METHOD*)

CONST
      P  = 749;           (*SIZE OF HASHTABLE*)
      NK =  45;           (*NO. OF KEYWORDS*)
      PAGESIZE = 60;	  (*LINES PER PAGE*)
      ALFALEN  =  8;      (*SIZE OF IDENTIFIERS*)
      REFSPERLINE = 15;
      REFSPERITEM =  5;
      NESTMAX = 10 ;

TYPE
     ALFA = PACKED ARRAY[1..ALFALEN] OF CHAR;
     INDEX = 0..P;
     ITEMPTR = ^ITEM;
     WORD = RECORD
               KEY: ALFA;
               FIRST, LAST: ITEMPTR;
               FOL: INDEX
            END ;
     NUMREFS = 1..REFSPERITEM;
     REFTYPE = (COUNT, PTR);
     ITEM = RECORD
               REF   : ARRAY[NUMREFS] OF INTEGER;
               CASE REFTYPE OF
                  COUNT: (REFNUM: NUMREFS);
                  PTR: (NEXT: ITEMPTR)
            END ;
     BUFFER = PACKED ARRAY[0..131] OF CHAR;

VAR
    TOP: INDEX;        (*TOP OF CHAIN LINKING ALL ENTRIES IN T*)
    I,LINECOUNT,BUFCURSOR: INTEGER;        (*CURRENT LINE NUMBER*)
    FF,CH: CHAR;          (*CURRENT CHAR SCANNED *)
    BUF : BUFFER;
    T: ARRAY [INDEX] OF WORD;        (*HASH TABLE*)
    KEY: ARRAY [1..NK] OF ALFA;      (* RESERVED KEYWORD TABLE *)
    ERROR,                           (* ERROR FLAG *)
    LISTING: BOOLEAN;                (* LISTING OPTION *)
    INFILE: TEXT;
    LST : TEXT;                 
    LSTFILENAME : STRING;
    INPUT_LINE : STRING;
    PAGE_NUM,
    NESTLVL,
    LAST_KEY : INTEGER ;
    ABORT,
    LITERAL,
    ACOMMENT,
    BCOMMENT,
    EOL,
    NESTUP,
    NESTDN : BOOLEAN ;
    BAR : CHAR ;

FUNCTION UPPER (CH : CHAR) : CHAR ;

  BEGIN (* UPPER *)
  IF (CH >= 'a') AND (CH <= 'z') THEN
    UPPER := CHR(ORD(CH) + (ORD('A') - ORD('a')))
  ELSE
    UPPER := CH
  END ; (* UPPER *)

PROCEDURE INITIALIZE;
VAR
  I : INTEGER;

PROCEDURE FIRSTHALF;
BEGIN
   KEY[ 1] := 'AND     ';
   KEY[ 2] := 'ARRAY   ';
   KEY[ 3] := 'BEGIN   ';
   KEY[ 4] := 'BOOLEAN ';
   KEY[ 5] := 'CASE    ';
   KEY[ 6] := 'CHAR    ';
   KEY[ 7] := 'CONST   ';
   KEY[ 8] := 'DIV     ';
   KEY[ 9] := 'DOWNTO  ';
   KEY[10] := 'DO      ';
   KEY[11] := 'ELSE    ';
   KEY[12] := 'END     ';
   KEY[13] := 'EXIT    ';
   KEY[14] := 'FILE    ';
   KEY[15] := 'FOR     ';
   KEY[16] := 'FUNCTION';
END;

PROCEDURE SECONDHALF;
BEGIN
   KEY[17] := 'GOTO    ';
   KEY[18] := 'IF      ';
   KEY[19] := 'IN      ';
   KEY[20] := 'INPUT   ';
   KEY[21] := 'INTEGER ';
   KEY[22] := 'MOD     ';
   KEY[23] := 'NIL     ';
   KEY[24] := 'NOT     ';
   KEY[25] := 'OF      ';
   KEY[26] := 'OR      ';
   KEY[27] := 'OUTPUT  ';
   KEY[28] := 'PACKED  ';
   KEY[29] := 'PROCEDUR';
   KEY[30] := 'PROGRAM ';
   KEY[31] := 'REAL    ';
   KEY[32] := 'RECORD  ';
   KEY[33] := 'REPEAT  ';
   KEY[34] := 'SET     ';
   KEY[35] := 'STRING  ';
   KEY[36] := 'TEXT    ';
   KEY[37] := 'THEN    ';
   KEY[38] := 'TO      ';
   KEY[39] := 'TYPE    ';
   KEY[40] := 'UNTIL   ';
   KEY[41] := 'VAR     ';
   KEY[42] := 'WHILE   ';
   KEY[43] := 'WITH    ';
   KEY[44] := 'WRITE   ';
   KEY[45] := 'WRITELN ';
END;

BEGIN (* INITIALIZE *)
   FOR I := 1 TO 25 DO      { clear the screen }
     WRITELN ;
   WRITELN('Pascal Program Xref Utility');
   WRITELN('This program is public domain');
   WRITELN('Contributed by Warren A. Smith  --  July 14, 1981');
   FOR I := 1 TO 13 DO
     WRITELN ;
   FF:=CHR(12);
   ERROR := FALSE;
   FOR I := 0 TO P DO
      T[I].KEY := '        ';
   FIRSTHALF;
   SECONDHALF;
   LINECOUNT:= 1;
   TOP := P;
   PAGE_NUM := 1 ;
   LITERAL := FALSE ;
   ACOMMENT := FALSE ;
   BCOMMENT := FALSE ;
   NESTLVL := 0 ;
   LAST_KEY := 0 ;
   BAR := '|' ;
   CH  := ' '
END; (* INITIALIZE *)

PROCEDURE OPENFILES;
VAR                                       
    I : INTEGER ;
    NUMBLOCKS: INTEGER;
    OPENOK: BOOLEAN;
    OPENERRNUM : INTEGER;
    LISTOPTION: CHAR;
    FILENAME: STRING;

BEGIN (* OPEN *)
   WRITELN ;
   WRITELN ('An answer of a $ character to any question') ;
   WRITELN ('   will cause the program to abort.') ;
   ABORT := FALSE ;
   REPEAT
      WRITELN;
      WRITELN('Type in the name of the file you want cross-referenced.' );
      WRITELN('   The file will also have the compound statements displayed');
      WRITELN('   if you select the list option.  ');
      READLN( FILENAME );
      IF LENGTH(FILENAME) > 0 THEN
        BEGIN
        FOR I := 1 TO LENGTH(FILENAME) DO
          FILENAME[I] := UPPER(FILENAME[I]) ;
        ABORT := FILENAME[1] = '$' ;
        IF NOT ABORT THEN
          BEGIN

{---------------------------------------------------------------}
{    This section is implementation dependent.  It will work	}
{    for UCSD Pascal or Pascal/MT+ but not for Pascal/Z.	}
{    For Pascal/Z, use 						}
{      RESET (FILENAME,INFILE);					}
{---------------------------------------------------------------}
{}        ASSIGN(INFILE,FILENAME);			       {}
{}        RESET(INFILE);				       {}
{---------------------------------------------------------------}

          OPENERRNUM := IORESULT;
          OPENOK     := ( OPENERRNUM <> 255 );
          ABORT      := EOF (INFILE) ;
          IF NOT OPENOK THEN
            WRITELN( '*** INPUT OPEN ERROR #', OPENERRNUM )
          ELSE
            IF ABORT THEN
              WRITELN ('*** FILE ', FILENAME,' IS EMPTY, PROGRAM ABORTING')
          END
        END;
   UNTIL OPENOK OR ABORT;

   IF NOT ABORT THEN
     BEGIN
     WRITELN;
     WRITELN('Destination file or device name?');
     WRITE  ('  The default is LST: - ');
     READLN(LSTFILENAME);
     WRITELN;
     IF LENGTH (LSTFILENAME) <= 0 THEN
       LSTFILENAME := 'LST:' ;
     ABORT := LSTFILENAME [1] = '$' ;
     IF NOT ABORT THEN
       BEGIN
       FOR I := 1 TO LENGTH(LSTFILENAME) DO
         LSTFILENAME[I] := UPPER(LSTFILENAME[I]) ;

{---------------------------------------------------------------}
{    This section is implementation dependent.  It will work	}
{    for UCSD Pascal or Pascal/MT+ but not for Pascal/Z.	}
{    For Pascal/Z, use 						}
{      REWRITE (LSTFILENAME, LST);				}
{---------------------------------------------------------------}
{}     ASSIGN(LST,LSTFILENAME);				       {}
{}     REWRITE(LST)					       {}
{---------------------------------------------------------------}
       END
     END ;

   IF NOT ABORT THEN
     BEGIN
     REPEAT
       WRITE( 'Do you want a listing (y or n)? ' );
       READ( LISTOPTION );
       WRITELN ;
       ABORT := LISTOPTION = '$'
     UNTIL ABORT OR (LISTOPTION IN ['Y','y','N','n']);
     IF NOT ABORT THEN
       BEGIN
       LISTING := NOT(LISTOPTION in ['N','n']) ;
       WRITELN ;
       IF LISTING THEN
         WRITELN ('LIST OPTION ON')
       ELSE
         WRITELN
       END
     END
END; (* OPEN *)

FUNCTION TAB (NUM : INTEGER) : CHAR ;

  VAR
      I : INTEGER ;

  BEGIN
  FOR I := 1 TO NUM DO
    WRITE (LST, ' ') ;
  TAB := CHR(0)
  END ; (* TAB *)

PROCEDURE LPWRITELN;
VAR
  I : INTEGER;
BEGIN
  BUF[BUFCURSOR]:=CHR(13);
  BUFCURSOR:=BUFCURSOR+1;
  FOR I := 0 TO BUFCURSOR-1 DO
    WRITE(LST,BUF[I]);
  BUFCURSOR:=0;
  LINECOUNT:=LINECOUNT+1;
  IF (LINECOUNT MOD PAGESIZE) = 0 THEN
    PAGE(LST);
END;

PROCEDURE PUTALFA(S:ALFA);
BEGIN
  MOVELEFT(S[1],BUF[BUFCURSOR],8);
  BUFCURSOR:=BUFCURSOR+8;
END;

PROCEDURE PUTNUMBER(NUM: INTEGER);
VAR I,IPOT:INTEGER;
    A: ALFA;
    CH: CHAR;
    ZAP:BOOLEAN;
    
BEGIN
  ZAP:=TRUE;
  IPOT:=10000;
  A[1]:=' ';
  FOR I:= 2 TO 6 DO
    BEGIN
      CH:=CHR(NUM DIV IPOT + ORD('0'));
      IF I <> 6 THEN
        IF ZAP THEN
           IF CH = '0' THEN
             CH:=' '
           ELSE ZAP:=FALSE;
      A[I]:=CH;
      NUM:=NUM MOD IPOT;
      IPOT:=IPOT DIV 10;
    END;
  A[7]:=' ';
  MOVELEFT(A,BUF[BUFCURSOR],7);
  BUFCURSOR:=BUFCURSOR+7;
END;

PROCEDURE SEARCH( ID: ALFA );          (*MODULO P HASH SEARCH*)
(*GLOBAL: T, TOP*)
VAR
    I,J,H,D  : INTEGER;
    X    : ITEMPTR;
    F    : BOOLEAN;

BEGIN
   J:=0;
   FOR I:= 1 TO ALFALEN DO
     J:= J*10+ORD(ID[I]);
   H  := ABS(J) MOD P;
   F  := FALSE;
   D  := 1;
   REPEAT
      IF T[H].KEY = ID
         THEN
            BEGIN (*FOUND*)
               F := TRUE;
               IF T[H].LAST^.REFNUM = REFSPERITEM
                  THEN
                     BEGIN
                         NEW(X);
                         X^.REFNUM := 1;
                         X^.REF[1] := LINECOUNT;
                         T[H].LAST^.NEXT:= X;
                         T[H].LAST      := X;
                     END
                 ELSE
                    WITH T[H].LAST^ DO
                       BEGIN
                          REFNUM      := REFNUM + 1;
                          REF[REFNUM] := LINECOUNT
                       END
            END
         ELSE
            IF T[H].KEY = '        '
               THEN
                  BEGIN (*NEW ENTRY*)
                     F  := TRUE;
                     NEW(X);
                     X^.REFNUM := 1;
                     X^.REF[1] := LINECOUNT;
                     T[H].KEY   := ID;
                     T[H].FIRST := X;
                     T[H].LAST  := X;
                     T[H].FOL   := TOP;
                     TOP := H
                  END
               ELSE
                  BEGIN (*COLLISION*)
                     H := H+D;
                     D := D+2;
                     IF H >= P
                        THEN
                           H := H - P;
                     IF D = P
                        THEN
                           BEGIN
                              WRITELN(OUTPUT,'TBLE OVFLW');
                              ERROR := TRUE
                           END ;
                  END
   UNTIL F OR ERROR
END (*SEARCH*) ;



PROCEDURE PRINTWORD(W: WORD);
VAR
    L: INTEGER;
    X: ITEMPTR;
    NEXTREF : INTEGER;
    THISREF: NUMREFS;
BEGIN
   PUTALFA(W.KEY);
   X := W.FIRST;
   L := 0;
   REPEAT
      IF L = REFSPERLINE
         THEN
            BEGIN
               L := 0;
               LPWRITELN;
               PUTALFA('        ');
            END ;
      L := L+1;
      THISREF := (L-1) MOD REFSPERITEM + 1;
      NEXTREF := X^.REF[ THISREF ];
      IF THISREF = X^.REFNUM
         THEN
            X := NIL
         ELSE
            IF THISREF = REFSPERITEM
               THEN
                  X := X^.NEXT;
      PUTNUMBER(NEXTREF);
   UNTIL X = NIL;
  LPWRITELN;
END (*PRINTWORD*) ;

PROCEDURE PRINTTABLE;

VAR
    I,J,M: INDEX;

BEGIN
   I := TOP;
   WHILE I <> P DO
      BEGIN (*FIND MINIMAL WORD*)
         M := I;
         J := T[I].FOL;
         WHILE J <> P DO
            BEGIN
               IF T[J].KEY < T[M].KEY
                  THEN
                     M := J;
               J := T[J].FOL
            END ;
         PRINTWORD(T[M]);
         IF M <> I THEN 
           BEGIN
             T[M].KEY:=T[I].KEY;
             T[M].FIRST:=T[I].FIRST;
             T[M].LAST:=T[I].LAST;
           END;
         I := T[I].FOL
      END
END (*PRINTTABLE*) ;

PROCEDURE OUTPUT_LINE (BUF : BUFFER) ;
  
  VAR
      I : INTEGER ;

  PROCEDURE FILL_LINE (VAR LINE : BUFFER) ;
    
    VAR I : INTEGER ;
          
    BEGIN (* FILL_LINE *)
    I := 1 ;
    WHILE (LINE[I] = ' ') DO
      BEGIN
      LINE[I] := '-' ;
      I := I + 1
      END
    END ; (* FILL_LINE *)



  PROCEDURE PRTNEST (VAR LINE : BUFFER) ;
  
    VAR COL : INTEGER ;


    BEGIN (* PRTNEST *)
    FOR COL := 1 TO NESTLVL - 1 DO
      WRITE (LST, BAR, '  ') ;
    IF NESTLVL > 0 THEN
      IF NESTUP OR NESTDN THEN
        BEGIN
        IF NESTDN THEN
          BEGIN
          WRITE (LST, BAR, '  ') ;
          WRITE (LST, 'E--') ;
          FOR COL := NESTLVL+2 TO NESTMAX DO
            WRITE (LST, '---')
          END
        ELSE
          BEGIN
          WRITE (LST, 'B--') ;
          FOR COL := NESTLVL+1 TO NESTMAX DO
            WRITE (LST, '---')
          END ;
        FILL_LINE (LINE)
        END
      ELSE
        BEGIN
        WRITE (LST, BAR, '  ') ;
        FOR COL := NESTLVL+1 TO NESTMAX DO
          WRITE (LST, '   ')
        END
    ELSE
      IF NESTDN THEN
        BEGIN
        WRITE (LST, 'E--') ;
        FOR COL := 2 TO NESTMAX DO
          WRITE (LST, '---') ;
        FILL_LINE (LINE)
        END
      ELSE
        FOR COL := 1 TO NESTMAX DO
          WRITE (LST, '   ')
    END ; (* PRTNEST *)
        
  BEGIN (* OUTPUT_LINE *)
  IF ((LINECOUNT MOD PAGESIZE) = 0) OR (PAGE_NUM = 1) THEN
    BEGIN
    IF LISTING THEN
      BEGIN
      PAGE (LST) ;
      WRITELN (LST, TAB(70), 'PAGE ', PAGE_NUM:1) ;
      WRITELN (LST) ;
      PAGE_NUM := PAGE_NUM + 1
      END ;
    IF (LSTFILENAME <> 'CON:') AND ((LINECOUNT MOD PAGESIZE) = 0) THEN
      WRITELN (OUTPUT, '< ', LINECOUNT:4, ',', MEMAVAIL:5, ' >')
    END ;
  WRITE (LST, LINECOUNT:4, '  ') ;
  PRTNEST (BUF) ;
  FOR I := 1 TO BUFCURSOR DO
    WRITE (LST, BUF[I]) ;
  WRITELN (LST) ;
  IF LSTFILENAME <> 'CON:' THEN
    WRITE (OUTPUT, '.')
  END ; (* OUTPUT_LINE *)


PROCEDURE GETNEXTCHAR;
VAR I : INTEGER;

BEGIN (* GETNEXTCHAR *)
IF BUFCURSOR >= LENGTH (INPUT_LINE) THEN
  BEGIN
  EOL := TRUE ;
  CH := ' ' ;
  ERROR := EOF(INFILE)
  END
ELSE
  BEGIN
  BUFCURSOR := BUFCURSOR + 1 ;
  CH := INPUT_LINE [BUFCURSOR] ;
  BUF [BUFCURSOR] := CH ;
  CH := UPPER(CH)
  END
END; (* GETNEXTCHAR *)


PROCEDURE GETIDENTIFIER;
VAR
    J,K,I: INTEGER;
    ID: ALFA;

BEGIN (* GETIDENTIFIER *)
   I := 0;
   ID := '        ';
   REPEAT
      IF I < ALFALEN
         THEN
            BEGIN
               I := I+1;
               ID[I] := CH
            END;
      GETNEXTCHAR
   UNTIL ( NOT(((CH>='A') AND (CH<='Z')) OR (CH='_')
                OR ((CH>='0') AND (CH<='9')))) OR (ERROR);
   I := 1;
   J := NK;
   REPEAT
      K := (I+J) DIV 2;      (*BINARY SEARCH*)
      IF KEY[K] <= ID
         THEN
            I := K+1;

      IF KEY[K] >= ID
         THEN
            J := K-1;

   UNTIL I > J;
   IF KEY[K] <> ID THEN
     SEARCH(ID)
   ELSE
     BEGIN
       IF (K=3) OR ((K=5) AND (LAST_KEY<>32)) OR     { BEGIN or CASE }
          (K=32) OR (K=33) THEN                      { RECORD or REPEAT }
         BEGIN
           LAST_KEY := K ;
           IF NESTLVL = NESTMAX THEN
             WRITE (LST, '----Too many levels')
           ELSE
             BEGIN
               NESTLVL := NESTLVL + 1 ;
               NESTUP := TRUE
             END
         END ;
       IF (K=12) OR (K=40) THEN          { END or UNTIL }
         IF NESTLVL = 0 THEN
           WRITE (LST, '----Nesting error  ')
         ELSE
           BEGIN
             NESTLVL := NESTLVL - 1 ;
             NESTDN := TRUE
           END
     END

END; (* GETIDENTIFIER *)

BEGIN (* CROSSREF *)

   INITIALIZE;

   OPENFILES;
   
   WHILE NOT EOF(INFILE) AND (NOT ABORT) DO
      BEGIN
      BUFCURSOR:= 0;
      NESTUP := FALSE ;
      NESTDN := FALSE ;
      READLN (INFILE, INPUT_LINE) ;
      IF LENGTH (INPUT_LINE) > 0 THEN
        BEGIN
        EOL := FALSE ;
        BUFCURSOR := BUFCURSOR + 1 ;
        CH := INPUT_LINE [BUFCURSOR] ;
        BUF [BUFCURSOR] := CH ;
        CH := UPPER (CH)
        END
      ELSE
        BEGIN
        EOL := TRUE ;
        CH := ' '
        END ;
      WHILE NOT EOL DO
        BEGIN
        IF ((CH >= 'A') AND (CH <= 'Z')) AND (NOT LITERAL) AND
           (NOT ACOMMENT) AND (NOT BCOMMENT) THEN
          GETIDENTIFIER
        ELSE
          IF (CH = '''') OR LITERAL THEN
            BEGIN
              REPEAT
                GETNEXTCHAR;
              UNTIL (CH = '''') OR (ERROR) OR EOL;
              LITERAL := EOL ;
              GETNEXTCHAR
            END
          ELSE
            IF (CH = '{') OR ACOMMENT THEN
              BEGIN
                WHILE (CH <> '}') AND (NOT ERROR) AND (NOT EOL) DO
                  GETNEXTCHAR ;
                ACOMMENT := EOL ;
                GETNEXTCHAR
              END
            ELSE
              IF (CH = '(') OR BCOMMENT THEN
                BEGIN
                  IF NOT BCOMMENT THEN
                    GETNEXTCHAR;
                  IF (CH = '*') OR BCOMMENT THEN
                    BEGIN
                      IF NOT BCOMMENT THEN
                        GETNEXTCHAR;
                      REPEAT
                        WHILE (CH <> '*') AND (NOT ERROR) AND (NOT EOL) DO
                          GETNEXTCHAR ;
                        BCOMMENT := EOL ;
                        IF NOT EOL THEN
                          GETNEXTCHAR
                      UNTIL (CH = ')') OR ERROR OR EOL ;
                      IF NOT EOL THEN
                        GETNEXTCHAR
                    END
                END
              ELSE
                GETNEXTCHAR;

        END; (* WHILE *)
      EOL := FALSE ;
      OUTPUT_LINE (BUF) ;
      LINECOUNT := LINECOUNT + 1
      END ;
   IF NOT ABORT THEN
     BEGIN
     PAGE(LST);
     LINECOUNT := 0;
     BUFCURSOR := 0;
     PRINTTABLE;
     PAGE(LST);
     CLOSE(LST,I);
     IF I = 255 THEN
       WRITELN('Error closing output file')
     END
END.
