MODULE  FORGRAPH;

{ This is an examplary function for use with the graphing procedure. }

FUNCTION  F( X :REAL) :REAL;
   BEGIN
   { Happens to be an unnormalized probability amplitude function
   from quantum mechanics -- for a simple-harmonic potential well,
   I think.  Whatever it is, it looks nice. }
   F := SQR(COS(X))/EXP(SQR(X));
   END;

MODEND.
