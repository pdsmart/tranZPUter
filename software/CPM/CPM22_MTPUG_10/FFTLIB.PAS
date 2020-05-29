


MODULE FFTLIB;
{Library of routines used in the computation of discrete}
{Fourier transforms                                     }

{$M DEBUG        }
{$M LOG2         }
{$M POST_PROCESS }
{$M SHUFFLE      }
{$M FFT          }

{$M *}

CONST  ARRAY_SIZE = 2048;
               pi = 3.141592654;

TYPE     TRANSFORM_TYPE = (FORWRD,INVERSE);
                 XARRAY = ARRAY[1..ARRAY_SIZE] OF REAL;

VAR       N : EXTERNAL INTEGER;
         NU : EXTERNAL INTEGER;
        N_2 : EXTERNAL INTEGER;
        N_4 : EXTERNAL INTEGER;
          X : EXTERNAL XARRAY;
       MODE : EXTERNAL TRANSFORM_TYPE;


PROCEDURE DEBUG;
   VAR  I : INTEGER;
   BEGIN
   WRITELN;
   FOR I:=1 TO  N DO WRITELN('X[',I:2,']=',X[I]:8:2);
   WRITELN; WRITELN
   END;



FUNCTION LOG2( FACTOR : INTEGER) : INTEGER;
   VAR LOG : INTEGER;
   BEGIN
   LOG:=0;
   WHILE FACTOR>=2 DO
      BEGIN
      LOG:=LOG+1;
      FACTOR:=FACTOR DIV 2
      END;
   LOG2:=LOG
   END;




PROCEDURE POST_PROCESS(MODE : TRANSFORM_TYPE);
   {      Post-processing for forward real transforms     }
   {      Pre-processing  for inverse real transform      }
   {                                                      }
   { When using POST, the method of storage follows the   }
   { following pattern:                                   }
   {                                                      }
   {                                                      }
   {                                                      }
   {        Action            Locations of array X[i]     }
   {    --------------       --------------------------   }
   {                                                      }
   {    Post-Processing      first (N/2+1) are real       }
   {   (Forward Real FT)     next  (N/2-1) are imaginary  }
   {                                                      }
   {                                                      }
   {    Pre-Processing       first (N/2)   are real       }
   {   (Inverse Real FT)     next  (N/2)   are imaginary  }
   {                                                      }
   {                                                      }
   { This storage scheme is necessary to insure that the  }
   { composition of the inverse FT with a forward FT re-  }
   { turns the original input array.  If one desires the  }
   { results of the forward FT, then output a zero instead}
   { of X[N/2+1]; this is because the imaginary component }
   { of the first Fourier coefficient is always zero for  }
   { real data.  With the zero in place, however, the     }
   { array is not invertible (i.e., the N/2+1 real compo- }
   { nent is necessary for the inverse computation).      }

VAR       L,M,I : INTEGER;
           IPN2 : INTEGER;
           MPN2 : INTEGER;
            ARG : REAL;
      DELTA_ARG : REAL;
    IPCOS_RMSIN : REAL;
    IPSIN_RMCOS : REAL;
        IC0,IC1 : REAL;
        IS0,IS1 : REAL;
          RP,RM : REAL;
          IP,IM : REAL;

   BEGIN
   ARG:=pi/N_2;
   IC0:=COS(ARG);
   IS0:=SIN(ARG);
   IC1:=1.0;
   IS1:=0.0;

   CASE MODE OF

       FORWRD : BEGIN
                RP      :=  X[1] + X[N_2+1];
                X[N_2+1]:=  X[1] - X[N_2+1]
                END;

      INVERSE : BEGIN
                IS0:=-IS0;
                IC1:=-1.0;
                RP      :=( X[1] + X[N_2+1] )/2;
                X[N_2+1]:=( X[1] - X[N_2+1] )/2
                END
      END;

   X[1]:=RP;
   X[N_2+N_4+1]:=-X[N_2+N_4+1];

   FOR I:=2 TO N_4 DO
      BEGIN
      M:=N_2 - I + 2;
      IPN2:=I + N_2;
      MPN2:=M + N_2;

      RP :=IC1*IC0 - IS1*IS0;   {compute sine and cosine for next}
      IS1:=IC1*IS0 + IS1*IC0;   {angles using de Moivre's Theorem}
      IC1:=RP;

      RP:=( X[  I ] + X[  M ] )/2;
      RM:=( X[  I ] - X[  M ] )/2;

      IP:=( X[IPN2] + X[MPN2] )/2;
      IM:=( X[IPN2] - X[MPN2] )/2;

      IPCOS_RMSIN:=IP*IC1 - RM*IS1;     { IP*COS(Y) - RM*SIN(Y) }
      IPSIN_RMCOS:=IP*IS1 + RM*IC1;     { IP*SIN(Y) + RM*COS(Y) }

      X[  I ]:= RP + IPCOS_RMSIN;
      X[  M ]:= RP - IPCOS_RMSIN;

      X[IPN2]:= IM - IPSIN_RMCOS;
      X[MPN2]:=-IM - IPSIN_RMCOS;

      END
   END;



PROCEDURE SHUFFLE(MODE : TRANSFORM_TYPE);
   {Shuffle points from alternate real-imaginary to 1st-half real,}
   {2nd-half imaginary if MODE=FORWRD.  The procedure is reversed }
   {if MODE=INVERSE.                                              }

   VAR          I,J,K,L : INTEGER;
                  IPCM1 : INTEGER;
          CELL_DISTANCE : INTEGER;
             CELL_COUNT : INTEGER;
            POINT_COUNT : INTEGER;
                  XTEMP : REAL;

   BEGIN
   {choose whether to start with large cells and go down or start}
   {with small cells and increase.                               }

   CASE MODE OF

       FORWRD : BEGIN
                CELL_DISTANCE:=N DIV 2;
                CELL_COUNT:=1;
                POINT_COUNT:=N DIV 4
                END;

      INVERSE : BEGIN
                CELL_DISTANCE:=2;
                CELL_COUNT:=N DIV 4;
                POINT_COUNT:=1
                END
      END;

   FOR L:=1 TO NU DO
      BEGIN 
      I:=2;
      FOR J:=1 TO CELL_COUNT DO
         BEGIN
         FOR K:=1 TO POINT_COUNT DO
            BEGIN
            IPCM1:=I + CELL_DISTANCE - 1;
            XTEMP:=X[I];
            X[I]:=X[IPCM1];
            X[IPCM1]:=XTEMP;
            I:=I+2
            END;
         I:=I + CELL_DISTANCE
         END;

      CASE MODE OF

          FORWRD : BEGIN
                   CELL_DISTANCE:=CELL_DISTANCE DIV 2;
                   CELL_COUNT:=CELL_COUNT*2;
                   POINT_COUNT:=POINT_COUNT DIV 2
                   END;

         INVERSE : BEGIN
                   CELL_DISTANCE:=CELL_DISTANCE*2;
                   CELL_COUNT:=CELL_COUNT DIV 2;
                   POINT_COUNT:=POINT_COUNT*2
                   END
         END
      END
   END;



PROCEDURE FFT(MODE : TRANSFORM_TYPE);
   {FFT algorithm--operates on n/2 complex data points.}
   {The i-th complex data value is assumed to be stored}
   {in the array X[1..n] such that:                    }
   {                                                   }
   {          X[ i       ] = real component            }
   {          X[ i + n/2 ] = imaginary component       }
   {                                                   }
   {FFT returns the complex result in the same fashion.}

VAR         CELL_COUNT : INTEGER;
         CELL_DISTANCE : INTEGER;
           POINT_COUNT : INTEGER;
        IPN2,JPN2,KPN2 : INTEGER;
               I,J,K,L : INTEGER;
                    I2 : INTEGER;
                  IMAX : INTEGER;
                 INDEX : INTEGER;
             COS0,SIN0 : REAL;
             COSY,SINY : REAL;
           R2COS_I2SIN : REAL;
           I2COS_R2SIN : REAL;
                TEMP_R : REAL;
                TEMP_I : REAL;
                 XTEMP : REAL;
                    K1 : REAL;

   FUNCTION BIT_REVERSAL( J,NU : INTEGER) : INTEGER;
      {bit invert the number J by NU bits}
      VAR     I,IB : INTEGER;
      BEGIN
      IB:=J MOD 2;
      FOR I:=2 TO NU DO
         BEGIN
         J:=J DIV 2;
         IB:=IB*2 + J MOD 2
         END;
      BIT_REVERSAL:=IB
      END;

   BEGIN
   {shuffle the complex data (n/2 entries) into bit-inverted order}
   FOR I:=2 TO N_2-1 DO
      BEGIN
      K:=BIT_REVERSAL(I-1,NU) + 1;
      IF I>K THEN  {swap the real and imaginary components}
         BEGIN
         IPN2:=I + N_2;      {imaginary}
         KPN2:=K + N_2;      { indices }

         TEMP_R:=X[  K ];
         TEMP_I:=X[KPN2];

         X[  K ]:=X[  I ];
         X[KPN2]:=X[IPN2];

         X[  I ]:=TEMP_R;
         X[IPN2]:=TEMP_I
         END
      END;


   {do first pass specially, since it has no multiplication}
   I:=1;
   FOR J:=1 TO N_4 DO
      BEGIN
      K:=I+1;
      IPN2:=I+N_2;
      KPN2:=IPN2+1;
      K1:=     X[  I ] + X[  K ];
      X[  K ]:=X[  I ] - X[  K ];
      X[  I ]:=K1;
      K1:=     X[IPN2] + X[KPN2];
      X[KPN2]:=X[IPN2] - X[KPN2];
      X[IPN2]:=K1;
      I:=I+2
      END;

   {set up for 2nd pass ARG = pi/2}
   COS0:=0.0;
   IF MODE=FORWRD THEN SIN0:= 1.0
                  ELSE SIN0:=-1.0; 
   CELL_COUNT:=N_2 DIV 4;
   POINT_COUNT:=2;
   CELL_DISTANCE:=4;

   {each pass after the 1st starts here}
   FOR I2:=2 TO NU DO
      BEGIN 
      COSY:=1.0;
      SINY:=0.0;
      FOR INDEX:=1 TO POINT_COUNT DO
         BEGIN
         I:=INDEX;

         FOR L:=1 TO CELL_COUNT DO
            BEGIN
            J:=I + POINT_COUNT;
            IPN2:=I + N_2;
            JPN2:=J + N_2;

            IF INDEX=1 THEN  {no sine or cosine terms}
               BEGIN
               R2COS_I2SIN:=X[  J ];
               I2COS_R2SIN:=X[JPN2] 
               END
            ELSE
               BEGIN
               R2COS_I2SIN:=X[  J ]*COSY + X[JPN2]*SINY;
               I2COS_R2SIN:=X[JPN2]*COSY - X[  J ]*SINY
               END;
 
            X[  J ]:=X[  I ] - R2COS_I2SIN;  {Note:  these assignments}
            X[  I ]:=X[  I ] + R2COS_I2SIN;  {must be in this order if}
            X[JPN2]:=X[IPN2] - I2COS_R2SIN;  {temporary variables are } 
            X[IPN2]:=X[IPN2] + I2COS_R2SIN;  {to be avoided.          }
            I:=I + CELL_DISTANCE
            END;

         K1  :=COSY*COS0 - SINY*SIN0;  {using de Moivre's Theorem}
         SINY:=SINY*COS0 + COSY*SIN0;
         COSY:=K1;

         END;

      {pass done--change cell distance and number of cells}
      CELL_COUNT:=CELL_COUNT DIV 2;
      POINT_COUNT:=POINT_COUNT*2;
      CELL_DISTANCE:=CELL_DISTANCE*2;

      SIN0:=SQRT((1.0 - COS0)/2.0);  {use half-angle formulas to compute}
      COS0:=SQRT((1.0 + COS0)/2.0);  {sin & cos of ARG:=ARG/2           }

      IF MODE=INVERSE THEN SIN0:= -SIN0
      END;              
 
   IF MODE=INVERSE THEN
      FOR I:=1 TO N DO X[I]:=X[I]/N_2
   END;


MODEND.
