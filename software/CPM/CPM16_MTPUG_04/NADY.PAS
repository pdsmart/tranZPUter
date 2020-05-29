PROGRAM NAD_ENTRY_V4;
{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{+  PROGRAM TITLE:	Name and Address Entry			+}
{+			version #4				+}
{+								+}
{+  WRITTEN BY: 	Raymond E. Penley			+}
{+  DATE WRITTEN:	Sept 25, 1980				+}
{+								+}
{+  WRITTEN FOR:	A Name And Address (NAD) data entry	+}
{+			program.  The output is written 	+}
{+			specifically in the format that the	+}
{+			word processor Magic Wand uses. 	+}
{+								+}
{+  SUMMARY							+}
{+  I. EDITING ENTRIES. 					+}
{+	The program has a very limited editing capability.	+}
{+	Before typing the return key if an entry is not 	+}
{+	correct then just type the ESCAPE key. This will	+}
{+	erase the entire line just entered. You then have to	+}
{+	reinput that entry.  No other editing is available	+}
{+	while in the program. Extensive editing must be 	+}
{+	done outside the data entry program such as with	+}
{+	the word processor.					+}
{+								+}
{+ II. TERMINATION.						+}
{+	When at the FULL NAME data entry item simply entering	+}
{+	a carriage return only will end the session, update	+}
{+	and close the output file.				+}
{+								+}
{+ III. RECORD FORMAT USED.					+}
{+	LINE #							+}
{+	1	RECORD #nn	< FILLED IN BY PROGRAM >	+}
{+	2	FULL NAME					+}
{+	3	ADDRESS LINE 1	< USED FOR A ONE LINE ADDRESS >	+}
{+	4	ADDRESS LINE 2	< LEAVE BLANK IF ONLY 1 LINE  >	+}
{+	5	CITY						+}
{+	6	STATE		< USE POST OFFICE 2 CHAR CODES >+}
{+	7	ZIP CODE					+}
{+	8	SALUTATION					+}
{+	9	CODES		< ANY TYPE OF CODES YOU REQUIRE>+}
{+	10	BLANK LINE					+}
{+								+}
{+								+}
{+ IV. INPUT/OUTPUT FILES					+}
{+   INPUT is from a video terminal (must have cursor		+}
{+	addressing)						+}
{+   OUTPUT FILE is an ASCII text file with file name		+}
{+	per your specifications.				+}
{+								+}
{+   MODIFICATION RECORD					+}
{+     SEPT 24, 80  -ADDED LIMITED EDITING CAPABILITY.		+}
{+		     ENTERING AN ESCAPE CHAR WILL ALLOW ONE TO  +}
{+		     REDO THAT LINE OVER AGAIN.			+}
{+     NOV 22, 80   -ADDED TELEVIDEO TERMINAL FUNCTIONS.	+}
{+								+}
{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

CONST
  Default = 80;	 { Default length of all strings }
  FileIdLength = 14;
  ESC_CODE = 27; {ASCII Escape code}
  NewLine = 13;  {ASCII carriage return code}

TYPE
  TermType	= (ADM, TVI, SOROC, H19, SOL);
  BYTE		= 0..255;
  dflt_string	= string default;
  FID		= string FileIdLength;
  max_string	= string 255;
  sequence	= packed array [1..2] of char;
  S$0		= string 0;
  S$255		= string 255;

VAR
  bell		: char;
  clear		: char;
  current_record: integer;
  done		: boolean;
  esc		: char;
  filename	: FID;
  home		: char;
  Terminal	: TermType;

  f1_line,f2_line,
  f3_line,f4_line,
  f5_line,f6_line,
  f7_line,f8_line,

  f1_col,f2_col,
  f3_col,f4_col,
  f5_col,f6_col,
  f7_col,f8_col: BYTE;

  LineDelete,			{ Delete line that cursor is on    }
  LineErase,			{ Erase from cursor to end of line }
  HintOn,			{ Half Intensity On		   }
  HintOff,			{ Half Intensity Off		   }
  INVON,			{ Inverse Video On		   }
  INVOFF	: sequence;	{ Inverse Video Off		   }

  ADDR1,
  ADDR2,
  CITY,
  CODES,
  FULLNAME,
  SALUTE,
  STATE,
  ZIP		: DFLT_STRING;

  FOUT		: TEXT;

{$C- <<<<<<<<<<<<<<<<<<<CONTROL-C CHECKING OFF>>>>>>>>>>>>>>>>>>>>>>}
{$F- <<<<<<<<<<<<<<FLOATING POINT MATH CHECKING OFF>>>>>>>>>>>>>>>>>}
{$M- <<<<<<<<<<<<<<INTEGER MULT & DIVD CHECKING OFF>>>>>>>>>>>>>>>>>}

FUNCTION LENGTH(X:S$255):INTEGER;EXTERNAL;

PROCEDURE SETLENGTH(VAR X:S$0; Y:INTEGER);EXTERNAL;

PROCEDURE KEYIN(VAR C:CHAR);EXTERNAL;

PROCEDURE WRITEONE;
BEGIN
  WRITELN(FOUT,'RECORD #',CURRENT_RECORD:1);
  WRITELN(FOUT,FULLNAME);
  WRITELN(FOUT,ADDR1);
  IF ( LENGTH(ADDR2)>0 ) THEN
     WRITELN(FOUT,ADDR2)
  ELSE
     WRITELN(FOUT);
  WRITELN(FOUT,CITY);
  WRITELN(FOUT,STATE);
  WRITELN(FOUT,ZIP);
  WRITELN(FOUT,SALUTE);
  WRITELN(FOUT,CODES);
  WRITELN(FOUT);
END;


PROCEDURE PLOT(row, column: BYTE);
{ Sequence
	ESC + "=" + CHR( LINE+31 ) + CHR( COLUMN+31 )
}
BEGIN
  WRITE(CHR(27), CHR(61), CHR(31+row), CHR(31+column));
END;


PROCEDURE EraseLine(VAR row,column: BYTE);
{ Erase current line from cursor to end of line }
BEGIN
  CASE Terminal OF
    ADM, SOROC:
	 BEGIN
	   PLOT(row,column);
	   WRITE( ' ':(80-column+1) );
	   PLOT(row,column)
	 END;

    TVI: BEGIN
	   PLOT(row,column);
	   WRITE( LineErase )
	 END
  END {CASE}
END;


PROCEDURE CLEAR_ALL;
BEGIN
  EraseLine(f1_line,f1_col);
  EraseLine(f2_line,f2_col);
  EraseLine(f3_line,f3_col);
  EraseLine(f4_line,f4_col);
  EraseLine(f5_line,f5_col);
  EraseLine(f6_line,f6_col);
  EraseLine(f7_line,f7_col);
  EraseLine(f8_line,f8_col);
END;

PROCEDURE QUIRY(VAR row, column: BYTE;
		VAR ANSWER: DFLT_STRING);
VAR
  CIX	: CHAR;
  DONE,
  VALID : BOOLEAN;

BEGIN
  PLOT(row, column);
  REPEAT
    SETLENGTH(ANSWER,0);
    DONE := FALSE;
    WHILE NOT ( DONE ) DO
      BEGIN
	KEYIN(CIX);
	VALID := ( ORD(CIX)<>ESC_CODE );
	IF NOT ( VALID ) THEN {REDO FROM START}
	  BEGIN
	    DONE := TRUE;
	    SETLENGTH(ANSWER,0);
	    EraseLine(row,column);
	  END
	ELSE
	  IF ( ORD(cix)=NewLine ) THEN
	     DONE := TRUE
	  ELSE
	    BEGIN
	      WRITE(CIX);
	      APPEND(ANSWER,CIX);
	    END;
      END {WHILE};
  UNTIL ( VALID );
END {OF QUIRY};


PROCEDURE FILLONE(VAR DONE: BOOLEAN);
BEGIN
  PLOT(2,12);WRITELN( INVON, 'RECORD #', CURRENT_RECORD:1, ' ', INVOFF );
  QUIRY(f1_line,f1_col,FULLNAME);
  IF ( LENGTH(FULLNAME) = 0 ) THEN
     DONE := TRUE
    {EXIT(FILLONE); }
  ELSE
    BEGIN
      DONE := FALSE;
      QUIRY(f2_line,f2_col,SALUTE);
      QUIRY(f3_line,f3_col,ADDR1);
      QUIRY(f4_line,f4_col,ADDR2);
      QUIRY(f5_line,f5_col,CITY);
      QUIRY(f6_line,f6_col,STATE);
      QUIRY(f7_line,f7_col,ZIP);
      QUIRY(f8_line,f8_col,CODES)
    END
END {OF FILLONE};


PROCEDURE WRITE_MASK;
BEGIN
  WRITE( CLEAR, HOME );
  WRITELN;
  WRITELN;
  WRITELN;
  WRITELN;
  WRITELN('FULL NAME: .......');WRITELN;
  WRITELN('SALUTATION: ......');WRITELN;
  WRITELN('ADDRESS LINE 1: ..');WRITELN;
  WRITELN('ADDRESS LINE 2: ..');WRITELN;
  WRITELN('CITY: ............');WRITELN;
  WRITELN('STATE: ...........');WRITELN;
  WRITELN('ZIP: .............');WRITELN;
  WRITELN('CODE(s): .........');
END;


PROCEDURE INIT;
BEGIN
  Terminal := ADM;	{ Select the correct terminal type }
  BELL := CHR(7);
  HOME := CHR(30);	{ Home the cursor but do not clear the screen }
  CLEAR := CHR(26);	{ Completely clear the terminal screen }
  ESC := CHR(27);

{+++++++++++++++++++++++++++++++++++++++++++++++++++}
{+ These string sequences pertain to the Televideo +}
{+ terminal.					   +}
{+++++++++++++++++++++++++++++++++++++++++++++++++++}
	{ inverse video ON }
  INVON[1] := ESC;
  INVON[2] := 'j';
	{ inverse video OFF }
  INVOFF[1] := ESC;
  INVOFF[2] := 'k';
	{ delete the line the cursor is on }
  LineDelete[1] := ESC;
  LineDelete[2] := 'R';
	{ erase from the cursor to the end of the line }
  LineErase[1] := ESC;
  LineErase[2] := 't';
	{ half intensity ON }
  HintOn[1] := ESC;
  HintOn[2] := ')';
	{ half intensity OFF }
  HintOff[1] := ESC;
  HintOff[2] := '(';

{ f?_line = starting line for field n in the MASK   }
{ f?_col  = starting column for field n in the MASK }
  f1_line :=  5;	f1_col := 20;{ FIELD #1 }
  f2_line :=  7;	f2_col := 20;{ FIELD #2 }
  f3_line :=  9;	f3_col := 20;{ FIELD #3 }
  f4_line := 11;	f4_col := 20;{ FIELD #4 }
  f5_line := 13;	f5_col := 20;{ FIELD #5 }
  f6_line := 15;	f6_col := 20;{ FIELD #6 }
  f7_line := 17;	f7_col := 20;{ FIELD #7 }
  f8_line := 19;	f8_col := 20;{ FIELD #8 }
END;


BEGIN{ Main program NAD entry }
  INIT;
  WRITE( CLEAR );
  { OPEN FILES }
  SETLENGTH(FILENAME,0);
  WRITELN;
  WRITE(' FILE: ');
  READLN(FILENAME);
  APPEND(FILENAME,CHR(13));
  RESET(FILENAME,FOUT);
  {++++++++++++++++++++++++++++++++++++++++++++++++++++++}
  {+  IF FILE ALREADY EXISTS THEN INFORM OPERATOR THAT	+}
  {+  HE WILL DESTROY EXISTING FILE, AND TERMINATE.	+}
  {++++++++++++++++++++++++++++++++++++++++++++++++++++++}
  IF NOT ( EOF(FOUT) ) THEN
    BEGIN
      WRITE( BELL );
      WRITELN
	( ' ':12,INVON,'        FILE ALREADY EXISTS          ', INVOFF );
      WRITELN
	( ' ':12,INVON,' THIS PROGRAM WILL DESTROY YOUR FILE ', INVOFF );
    END
  ELSE
    BEGIN
      REWRITE( FILENAME, FOUT);
      WRITELN;
      WRITE('Enter beginning Record No. ');
      READLN(CURRENT_RECORD);
      WRITE_MASK;
      REPEAT
	FILLONE(DONE);
	IF NOT ( DONE ) THEN
	  BEGIN
	    CLEAR_ALL;
	    WRITEONE;
	  END;
	CURRENT_RECORD := CURRENT_RECORD + 1
      UNTIL ( DONE );
      WRITE( CLEAR );
    END;
END.{ Program NAD Entry }
