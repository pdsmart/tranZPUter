PROGRAM EIGENVALUE (INPUT,OUTPUT);
(****************************************************************************
LAWRENCE ADKINS, MSA 326, SECT 1, COMPUTER PROJECT NO. 3.
CONTE AND DEBOORE, PAGE 180 (3.9-5), SPRING, 1979
 ****************************************************************************
USE THE POWER METHOD TO ESTIMATE THE MAXIMUM-MODULUS EIGENVALUE, AND A 
CORRESPONDING EIGENVECTOR FOR THE TRIDIAGONAL MATRIX A OF ORDER N=20
WITH A[I,I] = 4, A[I+1,I] = A[I,I+1] = -1  FOR I=1,2,...,N, 
AND COMPARE THE RESULT WITH THE EXACT MAXIMUM EIGENVALUE OBTAINED BY
  LAMBDA = 4 + (-2) * COS ((J*PI)/N+1) ,  J=1,2,...,N
WHERE WE CHOOSE J=1 IN ORDER TO OBTAIN THE MAXIMUM EIGENVALUE.
 ****************************************************************************)
CONST N=20; KK=1; EPSILON=0.005; MAXIT=10; D=4; E=-1; PI=3.1415926;
TYPE VECTOR = ARRAY [1..N] OF REAL;
     MATRIX = ARRAY [1..N,1..N] OF REAL;
VAR B, BM: MATRIX;
    RATIO, BMZ, ZM, BZM, Z: VECTOR;
    I,J,K: 1..N; M: INTEGER;
    SUM, DIFFERENCE, RMAX, RMIN, LAMBDA: REAL;
PROCEDURE CREATEMATRIX;
  BEGIN
  FOR K:=1 TO N
  DO BEGIN
     FOR J:=1 TO N DO B[K,J] := 0;
     Z[K] := 1
     END;
  B[1,1] := D; B[1,2] := E;
  FOR K:= 2 TO N-1
  DO BEGIN B[K,K-1] := E; B[K,K] := D; B[K,K+1] := E END; 
  B[N,N-1] := E; B[N,N] := D
  END;
PROCEDURE INITIALIZE;
  BEGIN
  M:= 0;
  FOR I:= 1 TO N
  DO BEGIN
     FOR J:= 1 TO N DO BM[I,J] := 0;
     BM[I,I] := 1
     END
  END;
PROCEDURE MULTVECTOR (B:MATRIX; X: VECTOR; VAR Y: VECTOR);
  BEGIN
  FOR J:= 1 TO N (* ALL ROWS OF B*)
  DO BEGIN
     SUM := 0;
     FOR I:= 1 TO N (*ALL COLUMNS OF B*)
     DO SUM := SUM + B[J,I] * X[I];
     Y[J] := SUM
     END
  END;
PROCEDURE MULTZM;
  BEGIN  FOR J := 1 TO N DO ZM[J] := (1/BMZ[KK])*BMZ[J]  END;
PROCEDURE DIVRATIO;
  BEGIN  FOR J:= 1 TO N DO RATIO[J] := ABS(BZM[J]/ZM[J]) END;
PROCEDURE MAXMINCHECK;
  BEGIN
  RMAX := 0; RMIN := RATIO [1];
  FOR J := 2 TO N
  DO BEGIN
     IF RATIO [J] < RMIN THEN RMIN := RATIO[J];
     IF RATIO [J] > RMAX THEN RMAX := RATIO[J]
     END
  END;
PROCEDURE WRITETABLE;
  BEGIN
  WRITE (M:2, '    ');
  FOR J:= 1 TO N
  DO BEGIN
     IF J<> 1 THEN WRITE ('      ');
     WRITE (BMZ[J]:14:6, '    ', ZM[J]:14:6, '    ');
     WRITE (BZM[J]:14:6, '    ', RATIO[J]:14:6, '    ');
     IF J=N THEN WRITELN (DIFFERENCE:14:6);
     WRITELN
     END
  END;
PROCEDURE MULTMATRIX;
  VAR C:MATRIX;
  BEGIN
  FOR I:= 1 TO N 
  DO BEGIN
     FOR J:= 1 TO N
     DO BEGIN
        SUM := 0;
        FOR K:= 1 TO N DO SUM := SUM + B[I,K] * BM[K,J];
        C[I,J] := SUM
        END
     END;
  FOR I:= 1 TO N DO FOR J:= 1 TO N DO BM[I,J] := C[I,J]
  END;
PROCEDURE COMPARE;
  BEGIN
  WRITELN; WRITELN; WRITELN;
  WRITELN ('COMPARE THIS RESULT WITH THE EXACT MAXIMUM EIGENVALUE...');
  WRITELN; WRITELN (' J         LAMBDA(J)'); WRITELN;
  FOR J:= 1 TO N 
  DO BEGIN
     LAMBDA := D + (2*E * COS((J*PI)/(N+1)));
     WRITELN (J:2, '    ', LAMBDA)
     END
  END;

BEGIN  CREATEMATRIX; INITIALIZE;
WRITE ('RESULTS OF USE OF THE POWER METHOD IN FINDING LARGEST EIGENVALUE');
WRITELN ('OF THE INPUTTED MATRIX'); WRITELN;
WRITE ('M               BMZ                ZM               BZM            ');
WRITELN('BMZ/ZM         RMAX-RMIN');
WRITE ('ITER.                       NUMERATOR       DENOMINATOR            ');
WRITELN(' RATIO        DIFFERENCE');
WRITELN;
REPEAT
  MULTVECTOR (BM,Z,BMZ);  (*BMZ:=BM*Z*)
  MULTZM;  (*ZM:=(1/BMZ[KK])*BMZ*)
  MULTVECTOR (B,ZM, BZM); (*BZM:=B*ZM*)
  DIVRATIO;  (*RATIO:=BZM/ZM*)
  MAXMINCHECK;  (*CHECK IF RATIO IS CANDIDATE FOR RMAX OR RMIN*)
  DIFFERENCE := ABS(RMAX-RMIN);
  WRITETABLE; (*PRINT OUT THE VECTORS IN A TABLE*)
  MULTMATRIX; (*BM:=B*BM*)
  M:=M+1
UNTIL (M=MAXIT+1) OR (DIFFERENCE < EPSILON);
COMPARE
END.

  