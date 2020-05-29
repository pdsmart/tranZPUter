{ die ln-funktion bei MT+ ist fuer Werte kleiner 1E-5 aeussertst langsam,
  so dass man das Gefuehl bekommt, das dass Programm sich aufhaengt. In-
  folgedessen konnte ich dieses Programm nicht verifizieren. -Juergen }

program diffus;	{ --> 302 }

{ Pascal program to perform a linear least-squares fit }
{ for the diffusion of Zn and Cu }
{ with Gauss-Jordan routine }
{ Sperate modules needed:
			GAUSSJ,
			PLOT }


const	maxr	= 20;		{ data prints }
	maxc	= 4;		{ polynomial terms }
	r	= 1.987;	{ gas constant }

type	ary	= array[1..maxr] of real;
	arys	= array[1..maxc] of real;
	ary2	= array[1..maxr,1..maxc] of real;
	ary2s	= array[1..maxc,1..maxc] of real;

var
	x,y,y_calc	: ary;
	t,d,resid	: ary;
	coef,sig	: arys;
	nrow,ncol	: integer;
	correl_coef,srs	: real;


external procedure cls;

procedure get_data(var x,y,t,d: ary;
		   var nrow: integer);
{ get values for nrow and arrays t,d }

var	i	: integer;
begin
  nrow:=7;
  t[1]:=600.0;	d[1]:=1.4E-12;
  t[2]:=650.0;	d[2]:=5.5E-12;
  t[3]:=700.0;	d[3]:=1.8E-11;
  t[4]:=750.0;	d[4]:=6.1E-11;
  t[5]:=800.0;	d[5]:=1.6E-10;
  t[6]:=850.0;	d[6]:=4.4E-10;
  t[7]:=900.0;	d[7]:=1.2E-9;
  for i:=1 to nrow do
    begin
      x[i]:=1.0/(t[i]+273.0);
      y[i]:=ln(d[i])
    end
end;		{ procedure get data }


procedure write_data;
{ print out the answers }
var	i	: integer;
begin
  writeln;
  writeln;
  writeln('  I      TC        D    DCALC');
  for i:=1 to nrow do
    writeln(i:3,t[i]:8:0,d[i],' ',y_calc[i]);
  writeln; writeln(' Coefficients ');
  writeln(coef[1],' constant term');
  for i:=2 to ncol do
    writeln(coef[i]);		{ other terms }
  writeln;
  writeln('D0=',(exp(coef[1])):7:2,' cm sq/sec.');
  writeln('Q =',(-r*coef[2]/1000.0):8:2,'kcal/mole');
  writeln;writeln('SRS= ',srs:7:3)
end;		{ write_data }

{procedure square(x: ary2;
		 y: ary;
	     var a: ary2s;
	     var g: arys;
	 nrow,ncol: integer);}
{ matrix multiplication routine }
{ a= transpose x times x }
{ g= y times x }

{$I C:SQUARE.LIB }

{external procedure gaussj(var b:	ary2s;
			      y:	arys;
			  var coef:	arys;
			  ncol:		integer;
			  var error:	boolean);
}
{$I GAUSSJ.LIB }

procedure linfit(x,		{ independant variable }
		 y: ary;	{ dependent variable }
		 var y_calc: ary;	{ calculated dep. variable }
		 var resid:  ary;	{ array of residuals }
		 var coef:   arys;	{ coefficients }
		 var sig:    arys;	{ error on coefficients }
		 nrow:       integer;	{ length of array }
		 var ncol:   integer);	{ number of terms }

{ least squares fit to nrow sets of x and y pairs of points }
{ Seperate procedures needed:
	SQUARE -> form square coefficient matrix
	GAUSSJ -> Gauss-Jordan elimination }

var	xmatr		: ary2;		{ data matrix }
	a		: ary2s;	{ coefficient matrix }
	g		: arys;		{ constant vector }
	error		: boolean;
	i,j,nm		: integer;
	see,a1		: real;

begin		{ procedure linfit }
  ncol:=2;	{ number of terms }
  for i:=1 to nrow do
    begin		{ setup matrix }
      xmatr[i,1]:=1.0;	{ first column }
      xmatr[i,2]:=x[i]	{ second column }
    end;
  square(xmatr,y,a,g,nrow,ncol);
  gaussj(a,g,coef,ncol,error);
  srs:=0.0;
  a1:=exp(coef[1]);
  for i:=1 to nrow do
    begin
      y_calc[i]:=a1*exp(coef[2]*x[i]);
      if y[i]<>0.0 then resid[i]:=y_calc[i]/y[i]-1.0
      else resid[i]:=y[i]/y_calc[i]-1.0;
      srs:=srs+sqr(resid[i])
    end
end;	{ linfit }


begin		{ main program }
  cls;
  get_data(x,y,t,d,nrow);
  linfit(x,y,y_calc,resid,coef,sig,nrow,ncol);
  write_data
end.
