(******************************************************
*
*		POWER TABLE PROGRAM
*
*	This program was extracted from the book PROGRAMMING
*  IN PASCAL by Peter Grogono during a self-study effort.
*  It is a simple enough program but it shows how to build
*  tables very easily. I had to modify it of course, so that
*  it would run with Pascal/Z.
*
*  Adaptation by Charlie Foster, Oct 1980
*  Donated to the Pascal/Z Users Group
*******************************************************)

PROGRAM powertable;

VAR
	tablesize, base, square, cube, quad : INTEGER;
BEGIN
	WRITELN;
	WRITE ('How many numbers do you want to tabulate?-->  ');
	READ (tablesize);
	WRITELN;
	WRITELN (' ':30,'TABLE');
	WRITELN;
	FOR base := 1 TO tablesize DO
	  BEGIN
		square := sqr (base);
		cube := base * square;
		quad := sqr (square);
		WRITELN (base:2,' ',square:4,' ',cube:5,' ',
			quad:6,' ',1/base:12,' ',1/square:12,
			' ',1/cube:12,' ',1/quad:12)
	  END	(* for loop *)
END.		(* MAIN *)
