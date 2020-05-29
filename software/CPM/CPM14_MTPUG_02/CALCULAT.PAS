{$S+}  { Turn on recursion ability, must be first line in Pascal/MT+	}
{$X+}  { Turn on run-time error checking				}

Program Handcalc ;

{   This program is intended to act as a scientific calculator, with	}
{   exponentiation and trancendental functions.				}

Const
	Func_Len  = 6;	{ No. of characters allowed in a function name	}
	Num_Funcs = 20;	{ No. of functions recognized			}
	Pi        = 3.1415926535897323846264338; { This is silly of course }
						{ but the numbers are correct }

Type
	Functions = (ArcTangent, Cosine, Logrithm, Sine, Square, Square_Root,
			Exponent, Tangent, CoTangent, Secant, CoSecant,
			ArcSine, ArcCosine, ArcCotangent, ArcSecant,
			ArcCoSecant, Pie, Radians, Log, Factorial,
			Non_Function);

	Set_of_Funcs = Set of Functions;
	Func_Name = array [1..Func_Len] of char;
	Func_Rec  = record
			Name	: Func_Name;
			Func_Type : Functions
		    end;
	Func_List = array [1..Num_Funcs] of Func_Rec;

Var
	Answer		: real;
	Buf		: String;
	Z		: integer;	{ Index into Buf }
	F_Names		: Func_List;
	Non_Parm_Funcs	: Set_of_Funcs;
	Debug_Mode	: boolean;

Procedure ScreenClr;

	Var
		I : integer;

	begin { ScreenClr }
	{ If your terminal can clear the screen (with say a Control-Z) then }
	{ output what ever characters are needed in place of this loop      }

	For I := 1 to 24 do
		Writeln

	end;  { ScreenClr }

Procedure Initialization;

     Var
	I : integer;

     Procedure Init_Funcs;

	begin { Init_Funcs }
		{ The order of the strings in F_Names must be alphabetical }
		{ This should be remembered when adding new functions	   }
	F_Names[1].Name := 'ARCCOS';	F_Names[1].Func_Type := ArcCosine;
	F_Names[2].Name := 'ARCCOT';	F_Names[2].Func_Type := ArcCoTangent;
	F_Names[3].Name := 'ARCCSC';	F_Names[3].Func_Type := ArcCoSecant;
	F_Names[4].Name := 'ARCSEC';	F_Names[4].Func_Type := ArcSecant;
	F_Names[5].Name := 'ARCSIN';	F_Names[5].Func_Type := ArcSine;
	F_Names[6].Name := 'ARCTAN';	F_Names[6].Func_Type := ArcTangent;
	F_Names[7].Name := 'COS   ';	F_Names[7].Func_Type := Cosine;
	F_Names[8].Name := 'COT   ';	F_Names[8].Func_Type := CoTangent;
	F_Names[9].Name := 'CSC   ';	F_Names[9].Func_Type := CoSecant;
	F_Names[10].Name:= 'EXP   ';	F_Names[10].Func_Type:= Exponent;
	F_Names[11].Name:= 'FACTOR';	F_Names[11].Func_Type:= Factorial;
	F_Names[12].Name:= 'LN    ';	F_Names[12].Func_Type:= Logrithm;
	F_Names[13].Name:= 'LOG   ';	F_Names[13].Func_Type:= Log;
	F_Names[14].Name:= 'PI    ';	F_Names[14].Func_Type:= Pie;
	F_Names[15].Name:= 'RADIAN';	F_Names[15].Func_Type:= Radians;
	F_Names[16].Name:= 'SEC   ';	F_Names[16].Func_Type:= Secant;
	F_Names[17].Name:= 'SIN   ';	F_Names[17].Func_Type:= Sine;
	F_Names[18].Name:= 'SQR   ';	F_Names[18].Func_Type:= Square;
	F_Names[19].Name:= 'SQRT  ';	F_Names[19].Func_Type:= Square_Root;
	F_Names[20].Name:= 'TAN   ';	F_Names[20].Func_Type:= Tangent;
	Non_Parm_Funcs := [Pie]
	end;  { Init_Funcs }

     begin { Initialization }
		{ Clear the screen }
     ScreenClr;
     Writeln ('Calculator');
     Writeln;
     Writeln ('by Warren A. Smith  --  July 29, 1981');
     Write (Skip_Line(4));
     Writeln ('A ''?'' at the beginning of a line will bring up a listing');
     Writeln ('  of possible functions and operators that may be used.');
     Writeln;
     Writeln ('A dollar sign ''$'' at the beginning of a line will');
     Writeln ('  cause this program to terminate.');
     Writeln;
     Debug_Mode := FALSE;
     Init_Funcs
     end;  { Initialization }

Function Skip_Line (N : integer) : char;

    Var
	I : integer;

    begin { Skip_Line }
    For I := 1 to N do
	Writeln;
    Skip_Line := chr(0)
    end;  { Skip_Line }

Function Tab (N : integer) : char;

    Var
	I : integer;

    begin { Tab }
    For I := 1 to N do
	Write (' ')
    end;  { Tab }

Function Upper (In_Char : char) : char;

     begin { Upper }
     If (In_Char >= 'a') AND (In_Char <= 'z') then
         Upper := chr(ord(In_Char) + (ord('A') - ord('a')))
     else
         Upper := In_Char
     end;  { Upper }

Procedure Help;

    Var
	Response : char;

    begin { Help }
     ScreenClr;
     Writeln ('  The currently available functions are :');
     Writeln;
     Writeln ('    ArcCosine   - ArcCos    ArcCotangent     - ArcCot');
     Writeln ('    ArcCosecant - ArcCsc    ArcSecant        - ArcSec');
     Writeln ('    ArcSine     - ArcSin    ArcTangent       - ArcTan');
     Writeln ('    Cosine      - Cos       CoTangent        - Cot   ');
     Writeln ('    CoSecant    - Csc       Natural Exponent - Exp   ');
     Writeln ('    Natural Log - Ln        Secant           - Sec   ');
     Writeln ('    Sine        - Sin       Square           - Sqr   ');
     Writeln ('    Square Root - Sqrt      Tangent          - Tan   ');
     Writeln ('    Log base 10 - Log       Factorial        - Factor');
     Writeln ('    Value of Pi - Pi				    ');
     Writeln;
     Writeln ('  Allowable operators are:');
     Writeln ('      ''+'', ''-'', ''*'', ''/'', and ''^'' (exponentiation)');
     Writeln;
     Writeln ('  Upper case and lower case are irrelevant in function names');
     Writeln ('  A ''$'' will end the program, a ''!'' turns on debug mode ');
     Writeln;
     Writeln ('Hit the carriage return to proceed.');
     Read (Response);
    end;  { Help }

Function Eoln : boolean;

    begin { Eoln }
    Eoln := Z > Length(Buf)
    end;  { Eoln }

Procedure Slough_Blanks;

    begin { Slough_Blanks }
    While (Buf[Z] = ' ') AND (not Eoln) do
       Z := Z + 1
    end;  { Slough_Blanks }

Procedure Get_Expr;

    begin { Get_Expr }
    Repeat
	Writeln;
	Writeln ('Type in an expression to be solved.');
	Readln (Buf);
	Z := 1;
	Slough_Blanks
    Until not Eoln
    end;  { Get_Expr }

Function Expr : real;

     Var
	Unary,
	Answer	: real;

     Function Term : real;

	Var
		Answer	: real;

	Function Expon : real;

	    Var
		Answer : real;

	    Function XtoY (X, Y : real) : real;

		begin { XtoY }
		If X >= 0.0 then
		    XtoY := exp(Y * Ln(X))
		else
		    XtoY := 0.0
		end;  { XtoY }

	    Function Factor : real;

	       Var
			Answer,
			X	: real;
			Func	: Functions;

		Procedure Read (Var Answer : real);

		     Var
			Fact_Power : real;

		     begin { Read }
		     Answer := 0.0;
		     Slough_Blanks;
		     While Digit (Buf[Z]) AND not Eoln do
			begin
			Answer := Answer * 10.0 + (Ord(Buf[Z])-Ord('0'));
			Z := Z + 1
			end;
		     If (Buf[Z] = '.') AND not Eoln then
			begin
			Z := Z + 1;
			Fact_Power := 1.0;
			While Digit (Buf[Z]) AND not Eoln do
			    begin
			    Fact_Power := Fact_Power / 10.0;
			    Answer := Answer+(Ord(Buf[Z])-Ord('0'))*Fact_Power;
			    Z := Z + 1
			    end
			end
		     end;  { Read }

		Function Digit (In_Char : char) : boolean ;

		     begin { Digit }
		     Digit := In_Char in ['0','1','2','3','4','5','6','7',
					  '8','9']
		     end;  { Digit }

		Function Letter (Var In_Char : char) : boolean;

		     begin { Letter }
		     In_Char := Upper (In_Char);
		     Letter := In_Char in ['A','B','C','D','E','F','G','H',
					   'I','J','K','L','M','N','O','P',
					   'Q','R','S','T','U','V','W','X',
					   'Y','Z']
		     end;  { Letter }

		Function Get_Func_Type : Functions;

		     Var
			ID : Func_Name;
			Index : integer;

		     Function Search_Funcs (ID : Func_Name) : Functions;

			  Var
				I, J, K	: integer;

			  begin { Search_Funcs }
			  I := 1;
 			  J := Num_Funcs;
			  Repeat
			       K := (I+J) DIV 2;      { Binary search }
			       With F_Names[K] do
				   begin
				   If Name <= ID  then
					I := K+1;

				   If Name >= ID then
					J := K-1
				   end

			  Until I > J;
 			  If F_Names[K].Name <> ID then
			       Search_Funcs := Non_Function
			  else
			       Search_Funcs := F_Names[K].Func_Type
			  end;  { Search_Funcs }

		     begin { Get_Func_Type }
		     Index := 1;
		     Repeat
			  ID [Index] := Buf[Z];
			  Z := Z + 1;
			  Index := Index + 1
		     Until Not Letter(Buf[Z]) OR Eoln OR (Index > Func_Len);
		     While Index <= Func_Len do
			  begin
			  ID [Index] := ' ';
			  Index := Index + 1
			  end;

		     Get_Func_Type := Search_Funcs (ID)
		     end;  { Get_Func_Type }

		Function Tan (X : real) : real;

		    begin { Tan }
		    Tan := Sin(X) / Cos(X)
		    end;  { Tan }

		Function Cot (X : real) : real;

		    begin { Cot }
		    Cot := Cos(X) / Sin(X)
		    end;  { Cot }

		Function Sec (X : real) : real;

		    begin { Sec }
		    Sec := 1.0 / Cos(X)
		    end;  { Sec }

		Function Csc (X : real) : real;

		    begin { Csc }
		    Csc := 1.0 / Sin(X)
		    end;  { Csc }

		Function ArcSin (X : real) : real;

		    begin { ArcSin }
		    ArcSin := ArcTan(X / Sqrt(1.0 - Sqr(X)))
		    end;  { ArcSin }

		Function ArcCos (X : real) : real;

		    begin { ArcCos }
		    ArcCos := Pi / 2.0 - ArcTan (X / Sqrt(1.0 - Sqr(X)))
		    end;  { ArcCos }

		Function ArcCot (X : real) : real;

		    begin { ArcCot }
		    ArcCot := Pi / 2.0 - ArcTan (X)
		    end;  { ArcCot }

		Function ArcSec (X : real) : real;

		    begin { ArcSec }
		    ArcSec := ArcTan (Sqrt(Sqr(X) - 1.0))
		    end;  { ArcSec }

		Function ArcCsc (X : real) : real;

		    begin { ArcCsc }
		    ArcCsc := ArcTan (1.0 / Sqrt(Sqr(X) - 1.0))
		    end;  { ArcCsc }

		Function Radian (X : real) : real;

		    begin { Radian }
		    Radian := X * (Pi / 180.0)
		    end;  { Radian }

		Function Log10 (X : real) : real;

		    begin { Log10 }
		    Log10 := Ln(X) / Ln(10.0)
		    end;  { Log10 }

		Function Factorl (X : real) : real;

		    Var
			Int_X, I	: integer;
			Product		: real;

		    begin { Factorl }
		    Int_X := Round(X);
		    If Int_X = 0 then
			Factorl := 1.0
		    else
			begin
			Product := 1.0;
			For I := 2 to Int_X do
			    Product := Product * I;
			Factorl := Product
			end
		    end;  { Factorl }

		begin { Factor }
		Slough_Blanks;
		If Digit (Buf[Z]) OR (Buf[Z] = '.') then
		     Read (Answer)
		else
		     If Buf[Z] = '(' then
			  begin
			  Z := Z + 1;
			  Answer := Expr;
			  If Buf[Z] <> ')' then
				begin
				Write (Tab(Z-1),'^ ');
				Writeln ('*** '')'' expected')
				end
			  else
				Z := Z + 1
			  end
		     else
			  If Letter (Buf[Z]) then
				begin
				Func := Get_Func_Type;
				Slough_Blanks;
				If not (Func in Non_Parm_Funcs) then
				    begin
				    If Buf[Z] = '(' then
					begin
					Z := Z + 1;
					Answer := Expr
					end
				    else
					begin
					Write (Tab(Z-1), '^ ');
					Write ('*** ''('' expected, answer ');
					Writeln ('may be in error')
					end;
				    Slough_Blanks;
				    If Buf[Z] = ')' then
					Z := Z + 1
				    else
					begin
					Write (Tab(Z-1), '^ ');
					Write ('*** '')'' expected, answer ');
					Writeln ('may be in error')
					end
				    end;
				Case Func of
				    Logrithm    : Answer := Ln (Answer);
				    Exponent    : Answer := Exp (Answer);
				    Log		: Answer := Log10 (Answer);
				    Square      : Answer := Sqr (Answer);
				    Square_Root : Answer := Sqrt (Answer);
				    Factorial	: Answer := Factorl (Answer);
				    Cosine	: Answer :=
							Cos (Radian(Answer));
				    Sine	: Answer :=
							Sin (Radian(Answer));
				    ArcTangent  : Answer :=
						       ArcTan (Radian(Answer));
				    Tangent	: Answer :=
							 Tan (Radian(Answer));
				    CoTangent   : Answer :=
							 Cot (Radian(Answer));
				    Secant	: Answer :=
							 Sec (Radian(Answer));
				    CoSecant    : Answer :=
							 Cos (Radian(Answer));
				    ArcSine	: Answer :=
						       ArcSin (Radian(Answer));
				    ArcCosine   : Answer :=
						       ArcCos (Radian(Answer));
				    ArcCoTangent: Answer :=
						       ArcCot (Radian(Answer));
				    ArcSecant   : Answer :=
						       ArcSec (Radian(Answer));
				    ArcCoSecant : Answer :=
							ArcCsc (Answer);
				    Pie		: Answer := Pi;
				    Radians	: Answer := Radian (Answer);
				    Non_Function: begin
						  Write (Tab(Z-1), '^ ');
						  Writeln
						('*** Uninown function name')
						  end
				    end; { CASE }
				Slough_Blanks
				end
			  else
				begin
				Write (Tab(Z-1), '^ ');
				Write ('*** Unknown Syntax, answer may ');
				Writeln ('be in error')
				end;
		If Debug_Mode then
		    Writeln ('Result from FACTOR = ', Answer:20:8);
		Factor := Answer
		end;  { Factor }

	    begin { Expon }
	    Answer := Factor;
	    Slough_Blanks;
	    While Buf[Z] = '^' do
		begin
		Z := Z + 1;
		Answer := XtoY (Answer, Factor);
		Slough_Blanks
		end;
	    If Debug_Mode then
		Writeln ('Result from EXPON = ', Answer:20:8);
	    Expon := Answer
	    end;  { Expon }

	  begin { Term }
	  Answer := Expon;
	  Slough_Blanks;
	  While Buf[Z] in ['*', '/'] do
		begin
		If Buf[Z] = '*' then
		     begin
		     Z := Z + 1;
		     Answer := Answer * Expon
		     end
		else
		     begin
		     Z := Z + 1;
		     Answer := Answer / Expon;
		     end;
		Slough_Blanks
		end;
	  If Debug_Mode then
		Writeln ('Result from TERM = ', Answer:20:8);
	  Term := Answer
	  end;  { Term }

     begin { Expr }
     Slough_Blanks;
     Unary := 1.0;
     If Buf[Z] in ['+','-'] then
	begin
	If Buf[Z] = '-' then
	    Unary := -1.0;
	Z := Z + 1
	end;
     Answer := Unary * Term;
     Slough_Blanks;
     While Buf[Z] in ['+', '-'] do
	begin
	If Buf[Z] = '+' then
	    begin
	    Z := Z + 1;
	    Answer := Answer + Term
	    end
	else
	    begin
	    Z := Z + 1;
	    Answer := Answer - Term
	    end;
	Slough_Blanks
	end;
     If Debug_Mode then
	Writeln ('Result from EXPR =', Answer:20:8);
     Expr := Answer
     end;  { Expr }

begin { Main }
Initialize;
Get_Expr;
While Buf[Z] <> '$' do
     begin
     If Buf[Z] = '?' then
	Help
     else
	If Buf[Z] = '!' then
	    Debug_Mode := not Debug_Mode
	else
	    If Buf[Z] <> '$' then
		begin
		Answer := Expr;
		Writeln;
		Writeln ('The answer is :', Answer:9:6)
		end;
     Get_Expr
     end;
Writeln;
Writeln ('Program ended');
Writeln
end.
