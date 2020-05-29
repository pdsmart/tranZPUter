program least3;		{ --> 209 }
{ Pascal program to perform a linear least-squares fit }
{ with Gauss-Jordan routine }
{ Sperate modules needed:
			GAUSSJ,
			PLOT }

const	maxr	= 20;		{ data prints }
	maxc	= 4;		{ polynomial terms }

type	ary	= array[1..maxr] of real;
	arys	= array[1..maxc] of real;
	ary2	= array[1..maxr,1..maxc] of real;
	ary2s	= array[1..maxc,1..maxc] of real;

var	x,y,y_calc	: ary;
	resid		: ary;
	coef,sig	: arys;
	nrow,ncol	: integer;
	correl_coef	: real;
	first,done	: boolean;

external procedure cls;

procedure get_data(var x: ary;		{ independant variable }
		   var y: ary;		{ dependant variable }
		   var nrow: integer);	{ length of vectors }
{ get values for n and arrays x,y }

var	i	: integer;

begin
  nrow:=9;
  for i:=1 to nrow do x[i]:=i;
  y[1]:=2.07;	y[2]:=8.6;
  y[3]:=14.42;	y[4]:=15.8;
  y[5]:=18.92;	y[6]:=17.96;
  y[7]:=12.98;	y[8]:=6.45;
  y[9]:=0.27;
end;		{ proceddure get data }

procedure write_data;
{ print out the answers }
var	i	: integer;
begin
  if first then first:=false else cls;
  writeln;
  writeln;
  writeln('  I      X       Y      YCALC    RESID');
  for i:=1 to nrow do
    writeln(i:3,x[i]:8:1,y[i]:9:2,y_calc[i]:9:2,resid[i]:9:2);
  writeln; writeln(' Coefficients errors ');
  writeln(coef[1],' ',sig[1],' Constant term');
  for i:=2 to ncol do
    writeln(coef[i],' ',sig[i]);		{ other terms }
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
{$I SQUARE.LIB }

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
  for i:=1 to nrow do
    begin		{ setup matrix }
      xi:=x[i];
      xmatr[i,1]:=1.0;	{ first column }
      for j:=2 to ncol do	{ other columns}
	xmatr[i,j]:=xmatr[i,j-1]*xi
    end;
  square(xmatr,y,a,g,nrow,ncol);
  gaussj(a,g,coef,ncol,error);
  sum_y:=0.0;
  sum_y2:=0.0;
  srs:=0.0;
  for i:=1 to nrow do
    begin
      yi:=y[i];
      yc:=0.0;
      for j:=1 to ncol do
	yc:=yc+coef[j]*xmatr[i,j];
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

{external procedure plot(x,y,z: ary; nrow: integer);
}
{$I C:PLOT.LIB }

begin		{ main program }
  cls;
  first:=true;
  done:=false;
  writeln;
  get_data(x,y,nrow);
  repeat
    repeat
      write('Order of polynomial fit? ');
      readln(ncol)
    until ncol<5;
    if ncol<1 then done:=true	{ quit if ncol<1 }
    else
      begin
	ncol:=ncol+1;		{ order is one less }
	linfit(x,y,y_calc,resid,coef,sig,nrow,ncol);
	write_data;
	plot(x,y,y_calc,nrow)
    end	{ else }
  until done
end.
