PROGRAM TRIDMATRIX (INPUT,OUTPUT);
(****************************************************************************
LAWRENCE ADKINS, MSA 326, SECT. 1, COMPUTER PROJECT NO. 2.
CONTE AND DEBOORE, PAGE 123 (3.2-9)  SPRING, 1979
 ****************************************************************************
USE THE TRID PROCEDURE TO SOLVE THE LINEAR SYSTEM
             - 2*(1+H*H) * X(1) + X(2)   = 1
      X(I-1) - 2*(1+H*H) * X(I) + X(I+1) = 0, FOR I=2,3,...,N-1
      X(N-1) - 2*(1+H*H) * X(N)          = 1
FOR N=30, H=0.1
 ****************************************************************************)

CONST N=30; H=0.1
VAR X,A,B,C,D: ARRAY[1..N] OF REAL;
    M: REAL; K: INTEGER;
PROCEDURE CREATEMATRIX;
  BEGIN
  FOR K=1 TO N
  DO BEGIN A[K] := 1; D[K] := -2*(1+H*H); C[K] := 1; B[K] := 0 END;
  A[1] := 0; C[N] := 0; B[1] := 1; B[N] := 1
  END;
PROCEDURE TRID;
  PROCEDURE DIAGERROR;
    BEGIN
    WRITELN ('**ERROR** FOUND A ZERO-VALUED DIAGONAL ELEMENT. PGM ABORTED.');
    HALT
    END;
  BEGIN  (*ELIMINATION*)
  FOR K:= 2 TO N
  DO BEGIN
     IF D[K-1] = 0 
     THEN DIAGERROR
     ELSE BEGIN
          M := A[K] / D[K-1];
          D[K] := D[K] - (M* C[K-1]);
          B[K] := B[K] - (M* B[K-1])
          END
     END;
  IF D[N] = 0 
  THEN DIAGERROR
  ELSE BEGIN  (*BACK SUBSTITUTION*)
       WRITELN; WRITELN; WRITELN ('THE SOLUTION VECTOR Y IS '); WRITELN;
       WRITELN ('K          Y(K)'); WRITELN;
       X[N] := B[N] / D[N];  WRITELN (N:2,'    ',X[N]);
       FOR K:= N-1 DOWNTO 1 
       DO BEGIN
          X[K] := (B[K] - (C[K] * X[K+1])) / D[K];
          WRITELN (K*2, '    ', X[K])
          END
       END;
  WRITELN; WRITELN
  END;
BEGIN  CREATEMATRIX; TRID  END.
