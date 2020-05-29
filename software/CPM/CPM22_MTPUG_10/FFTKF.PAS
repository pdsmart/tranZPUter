


PROGRAM FOURIER(INPUT,OUTPUT,INFILE,OUTFILE);
{Real FFT with single sine look-up per pass}

CONST  ARRAY_SIZE = 2048;
               pi = 3.141592654;

TYPE     TRANSFORM_TYPE = (FORWRD,INVERSE);
                 XARRAY = ARRAY[1..ARRAY_SIZE] OF REAL;

VAR       I : INTEGER;
          N : INTEGER;
         NU : INTEGER;
        N_2 : INTEGER;
        N_4 : INTEGER;
      DUMMY : INTEGER;
   IORESULT : INTEGER;
     INFILE : TEXT;
    OUTFILE : TEXT;
          X : XARRAY;
       MODE : TRANSFORM_TYPE;

        {*** found in FFTLIB.ERL ***}
EXTERNAL PROCEDURE DEBUG;

EXTERNAL FUNCTION LOG2( FACTOR : INTEGER) : INTEGER;

EXTERNAL PROCEDURE POST_PROCESS(MODE : TRANSFORM_TYPE);

EXTERNAL PROCEDURE SHUFFLE(MODE : TRANSFORM_TYPE);
   
EXTERNAL PROCEDURE FFT(MODE : TRANSFORM_TYPE);


BEGIN
OPEN(INFILE,'FFT.IN',IORESULT);
RESET(INFILE);

write('Input n:  '); readln(n);
for i:=1 to n do
   read(infile,x[i]);


writeln('Initial'); writeln;
debug;

N_2:=N DIV 2;   {Definition of N_2 = # of complex data points, n/2}
N_4:=N_2 DIV 2;
NU:=LOG2(N_2);
   
SHUFFLE(FORWRD);
writeln('Shuffle'); writeln;
debug;

FFT(FORWRD);
writeln('FFT'); writeln;
debug;

POST_PROCESS(FORWRD);
writeln('Post'); writeln;
debug
END.
