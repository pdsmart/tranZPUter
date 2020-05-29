program fitpol;		{ -> 295 }
{ Pascal program to perform a linear least-squares fit }
{ to the ratio of 2 polynomials }
{ with Gauss-Jordan routine }
{ Sperate modules needed:
			GAUSSJ}


const	maxr	= 20;		{ data prints }
	maxc	= 4;		{ polynomial terms }

type
	ary	= array[1..maxr] of real;
	arys	= array[1..maxc] of real;
	ary2	= array[1..maxr,1..maxc] of real;
	ary2s	= array[1..maxc,1..maxc] of real;

var
	x,y,y_calc	: ary;
	resid		: ary;
	coef,sig	: arys;
	nrow,ncol	: integer;
	correl_coef	: real;

external procedure cls;

procedure get_data(var x: ary;		{ independant variable }
		   var y: ary;		{ dependant variable }
		   var nrow: integer);	{ length of vectors }
{ get values for n and arrays x,y }

var	i	: integer;

begin
  { clausing factors }
  nrow:=10;
  x[1]:=0.1;	y[1]:=0.9524;
  x[2]:=0.2;	y[2]:=0.9092;
  x[3]:=0.5;	y[3]:=0.8013;
  x[4]:=1.0;	y[4]:=0.6720;
  x[5]:=1.2;	y[5]:=0.6322;
  x[6]:=1.5;	y[6]:=0.5815;
  x[7]:=2.0;	y[7]:=0.5142;
  x[8]:=3.0;	y[8]:=0.4201;
  x[9]:=4.0;	y[9]:=0.3566;
  x[10]:=6.0;	y[10]:=0.2755;
end;		{ procedure get data }

procedure write_data;
{ print out the answers }
var	i	: integer;
begin
  writeln;
  writeln;
  writeln('  I      X      Y      YCALC      RESID');
  for i:=1 to nrow do
    writeln(i:3,x[i]:8:1,y[i]:9:4,y_calc[i]:9:4,resid[i]:9:4);
  writeln; writeln(' Coefficients errors ');
  writeln(coef[1]:8:5,' ',sig[1],' constant term');
  for i:=2 to ncol do
    writeln(coef[i]:8:5,' ',sig[i]);		{ other terms }
  writeln;
  writeln('Correlation coefficient is ',correl_coef:8:5)
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
	xi,yi,yc,srs,see,
	sum_y,sum_y2	: real;

begin		{ procedure linfit }
  ncol:=4;	{ number of terms }
  for i:=1 to nrow do
    begin		{ setup matrix }
      xi:=x[i];
      yi:=y[i];
      xmatr[i,1]:=1.0;	{ first column }
      xmatr[i,2]:=-xi*yi;	{ second column }
      xmatr[i,3]:=xi;	{ third column }
      xmatr[i,4]:=-sqr(xi)*yi
    end;
  square(xmatr,y,a,g,nrow,ncol);
  gaussj(a,g,coef,ncol,error);
  sum_y:=0.0;
  sum_y2:=0.0;
  srs:=0.0;
  for i:=1 to nrow do
    begin
      xi:=x[i];
      yi:=y[i];
      yc:=coef[1]+(-coef[2]*yi+coef[3]-coef[4]*xi*yi)*xi;
      y_calc[i]:=yc;
      resid[i]:=yc-yi;
      srs:=srs+sqr(resid[i]);
      sum_y:=sum_y+yi;
      sum_y2:=sum_y2+yi*yi
    end;
  correl_coef:=sqrt(1.0-srs/(sum_y2-sqr(sum_y)/nrow));
  if nrow=ncol then nm:=1
  else nm:=nrow-ncol;
  see:=sqrt(srs/nm);
  for i:=1 to ncol do		{ errors on solution }
    sig[i]:=see*sqrt(a[i,i])
end;	{ linfit }


begin		{ main program }
  cls;
  get_data(x,y,nrow);
  linfit(x,y,y_calc,resid,coef,sig,nrow,ncol);
  write_data
end.
