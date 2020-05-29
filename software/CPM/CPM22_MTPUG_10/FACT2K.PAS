
PROGRAM FACT2K(INFILE,INPUT,OUTPUT);

CONST    k = 4;
         n = 16;   {n=2**k}

TYPE    VECTOR = ARRAY[1..n] OF REAL;

VAR          M : ARRAY[1..n,1..k] OF INTEGER;
         I,J,L : INTEGER;
        COUNT1 : INTEGER;
        COUNT2 : INTEGER;
         INDEX : INTEGER;
         COUNT : INTEGER;
      IORESULT : INTEGER; 
             Y : VECTOR;
           SSQ : REAL;
        SSQ_YI : REAL;
        INFILE : TEXT;

PROCEDURE YATES( INDEX : INTEGER; X : VECTOR; VAR Y : VECTOR);
   {performs Yates' algorithm for the 2**k factorial design.}
   {See p. 461 of Guttman, Wilks, & Hunter for details.     }

   VAR   I,J : INTEGER;
   BEGIN
   J:=0;
   FOR I:=1 TO INDEX DO
      BEGIN
      J:=J+2;
      Y[I      ]:=X[J] + X[J-1];
      Y[I+INDEX]:=X[J] - X[J-1]
      END
   END;



BEGIN
OPEN(INFILE,'FACT2K.IN',IORESULT);
RESET(INFILE);

COUNT1:=n DIV 2;
COUNT2:=1;
FOR J:=1 TO k DO
   BEGIN
   INDEX:=1;
   FOR I:=1 TO COUNT1 DO
      BEGIN
      FOR L:=1 TO COUNT2 DO
         BEGIN
         M[INDEX       ,J]:=-1;
         M[INDEX+COUNT2,J]:=+1;
         INDEX:=INDEX+1
         END;
      INDEX:=INDEX+COUNT2
      END;
   COUNT2:=2*COUNT2;
   COUNT1:=COUNT1 DIV 2
   END;

WRITELN('     Data in Yates Order');
WRITELN('  *************************');
FOR I:=1 TO n DO
   BEGIN
   READLN(INFILE,Y[I]);
   WRITE(Y[I]:10:2,' ':5);
   FOR J:=1 TO K DO
      BEGIN
      IF M[I,J]=1 THEN
         WRITE('+')
      ELSE WRITE('-');
      WRITE(' ':2)
      END;
   WRITELN
   END;

COUNT:=n DIV 2;
FOR J:=1 TO k DO
   YATES(COUNT,Y,Y);

WRITELN;  WRITELN;
WRITELN('  Average = ',Y[1]/n:10:2); WRITELN;

SSQ:=Y[1]*Y[1];
WRITELN(' ':5,' Estimated       Effect Contrib. to         Identification');
WRITELN(' ':5,'  Effects     Treatment Sum of Squares        of Effects' );
WRITELN(' ':5,'***********************************************************');
WRITELN;

FOR I:=2 TO n DO
   BEGIN
   SSQ_YI:=Y[I]*Y[I];
   WRITE(' ':2,Y[I]/COUNT:10:2, ' ':11,SSQ_YI/n:10:2, ' ':21);
   FOR J:=1 TO k DO
      IF M[I,J]=1 THEN WRITE(J:1);
   WRITELN;
   SSQ:=SSQ + SSQ_YI
   END;

WRITELN;
WRITELN(' Sum of Squares = ',SSQ:10:2)

END.
