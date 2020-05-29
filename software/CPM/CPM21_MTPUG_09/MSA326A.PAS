PROGRAM solveasystem (input, output)
(****************************************************************************
  L A W R E N C E   A D K I N S ,  MSA 326  SECT 01  COMPUTER PROJECT NO. 1.
  Conte and DeBoore, page 90(2.8-6)  Spring, 1979
 ****************************************************************************
Solve  F(X,Y)  =  (Exp(X)) + (X*Y) - 1  = 0
and    G(X,Y)  =  (Sin(X*Y)) + X + Y    = 0
Using the scheme
  X[I+1] = X[I] - ((EXP(X[I])) + (X[I]*Y[I]) - 1) / ((EXP(X[I]))+Y[I]
  Y[I+1] = Y[I] - ((SIN(X[I+1] * Y[I]) + (X[I+1]) + (Y[I])-1) / 
           (X[I+1] * COS(X[I+1] * Y[I]) + 1))
Using the initial approximations X[0] = 0.1, Y[0] = 0.5.
 ****************************************************************************)


CONST n = 20; epsilon = 5.0E-08;
VAR x, y, fofxy, gofxy, fpofxy, gpofxy: real;
    i: integer;
FUNCTION convergence: boolean;
  BEGIN convergence := (abs(fofxy)<=epsilon) AND (abs(gofxy)<=epsilon) END;

BEGIN
readln (x,y); i:=0; 
writeln ('RESULTS OF ITERATION OF THIS PROBLEM.');
writeln; writeln; 
writeln ('I       X               Y               F(X,Y)        G(X,Y)');
writeln;
REPEAT
  fofxy := (exp(x)) + (x*y) - 1;  (*f(x,y)*)
  write (i:2,'     ',x:9:6,'     ',y:9:6,'     ',fofxy:9:6,'     ');
  fpofxy := exp(x) + y;           (*f'(x,y)*)
  x:=x- (fofxy/fpofxy);
  gofxy := sin(x*y) + x + y - 1;  (*g(x,y)*)
  writeln (gofxy:9:6);
  gpofxy := (x * cos(x*y)) + 1;   (*g'(x,y)*)
  y := y - (gofxy/gpofxy);
  i:=i+1
UNTIL (i=21) OR convergence;
writeln; writeln;
IF NOT convergence
THEN BEGIN
     writeln; write ('****ERROR**** ITERATION FUNCTION FAILED TO ');
     writeln ('CONVERGE IN ',n:2, ' ITERATIONS.');
     END
END.