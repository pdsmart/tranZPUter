(****************************************************
*
*		CHAR COMPARE PROGRAM
*
*	Written by Bob Harsch during a debugging
* excercise. It was done hastily but it was such a
* good idea that I cleaned it and now its part of our
* utilities.
*
* Donated to the Pascal/Z Users Group, Oct 1980
* Modified by Charlie Foster
*****************************************************
*
*		INSTRUCTIONS
*
*	The two files that you want to compare need to
* have their names changed to F1.DAT and F2.DAT.  Then
* all you have to do is type PCOMPAR. It will go thro
* the entire program and list all differences and list
* those in HEX, DECIMAL and ASCII. The line numbers are
* in reference to 100H.
*
******************************************************)

PROGRAM COMPAREFILES;

TYPE	BYTE=0..255;

VAR	F1,F2 : FILE OF BYTE;
	B1,B2 : BYTE;
	COUNT : INTEGER;


PROCEDURE HEX(N: INTEGER);

VAR 	       I : INTEGER;
        HEXDIGIT : ARRAY [1..4] OF INTEGER;
	
BEGIN
	FOR I := 1 TO 4 DO
	  BEGIN
	    HEXDIGIT[I] := N MOD 16;
		      N := N DIV 16
	  END;
	FOR I:= 4 DOWNTO 1 DO
	  IF HEXDIGIT[I] > 9
	    THEN WRITE(CHR( ORD('A')+HEXDIGIT[I]-10 ):1)
		ELSE WRITE(HEXDIGIT[I]:1);
	WRITE(' ');
END; (* OF HEX *)


FUNCTION CHRCHK(B: BYTE): CHAR;

BEGIN
  IF (B < 32) OR (B > 126)
    THEN CHRCHK := '.'
	ELSE CHRCHK := CHR(B)
END; (* OF CHRCHK *)


BEGIN	(* MAIN PROGRAM *)

 RESET('F1.DAT',F1);   
 RESET('F2.DAT',F2);
  WRITELN('HEX-ADDR  HEX-B1-B2    DEC-B1-B2   CHR1-CHR2');
  WRITELN('--------------------------------------------');
COUNT := 256;
  REPEAT
    READ(F1,B1);
    READ(F2,B2);
	IF B1 <> B2 THEN
	BEGIN
  	  HEX(COUNT); 
	  WRITE(' ':5);
	  HEX(B1);
	  HEX(B2);
	  WRITE('   ',B1:3,'  ',B2:3);
	  WRITE('      ',CHRCHK(B1),'  ',CHRCHK(B2));
	  WRITELN;
	END;
	COUNT := COUNT + 1;
  UNTIL EOF(F1) OR EOF(F2);
END.
