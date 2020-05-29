program least3;		{ --> 226 }
{ Pascal program to perform a linear least-squares fit }
{ on the properties of steam with Gauss-Jordan routine }
{ Seperate modules needed:
			 GAUSSJ}


const	maxr	= 20;		{ data prints }
	maxc	= 4;		{ polynomial terms }

type	ary	= array[1..maxr] of real;
	arys	= array[1..maxc] of real;
	ary2	= array[1..maxr,1..maxc] of real;
	ary2s	= array[1..maxc,1..maxc] of real;

var	p,t,v,
	y,y_calc	: ary;
	resid		: ary;
	coef,sig	: arys;
	nrow,ncol	: integer;
	correl_coef	: real;

external procedure cls;

procedure get_data(var p,t: ary;	{ independant variable }
		   var v:   ary;	{ dependant variable }
		   var nrow: integer);	{ length of vectors }
{ get values for n and arrays x,y }

var	i	: integer;

begin
  nrow:=12;
  t[1]:=400;	p[1]:=120;	v[1]:=4.079;
  t[2]:=450;	p[2]:=120;	v[2]:=4.36;
  t[3]:=500;	p[3]:=120;	v[3]:=4.633;
  t[4]:=400;	p[4]:=140;	v[4]:=3.466;
  t[5]:=450;	p[5]:=140;	v[5]:=3.713;
  t[6]:=500;	p[6]:=140;	v[6]:=3.952;
  t[7]:=400;	p[7]:=160;	v[7]:=3.007;
  t[8]:=450;	p[8]:=160;	v[8]:=3.228;
  t[9]:=500;	p[9]:=160;	v[9]:=3.440;
  t[10]:=400;	p[10]:=180;	v[10]:=2.648;
  t[11]:=450;	p[11]:=180;	v[11]:=2.850;
  t[12]:=500;	p[12]:=180;	v[12]:=3.042;
  for i:=1 to nrow do
    t[i]:=t[i]+460.0	{ convert to Rankine }
end;		{ proceddure get data }

procedure write_data;
{ print out the answers }
var	i	: integer;
begin
  writeln;
  writeln('  I      P      T      V        Y    YCALC     %RES');
  for i:=1 to nrow do
    writeln(i:3,p[i]:7:1,t[i]:7:1,v[i]:7:3,y[i]:9:2,y_calc[i]:9:2,
		(100.0*resid[i]/y[i]):9:2);
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

procedure linfit(p,t,v: ary;	{ independant variable }
		 var y: ary;	{ dependent variable }
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

const	r = 85.76;	{ gas constant for steam }

var	xmatr		: ary2;		{ data matrix }
	a		: ary2s;	{ coefficient matrix }
	g		: arys;		{ constant vector }
	error		: boolean;
	i,j,nm		: integer;
	power,yi,yc,srs,see,
	sum_y,sum_y2	: real;

begin		{ procedure linfit }
  ncol:=2;	{ number of terms }
  for i:=1 to nrow do
    begin		{ setup matrix }
      power:=t[i];
      xmatr[i,1]:=p[i]/power;	{ first column }
      xmatr[i,2]:=sqrt(p[i]);	{ second column }
      y[i]:=v[i]*p[i]-r*t[i]/144.0
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

begin		{ main program }
  cls;
  get_data(p,t,v,nrow);
  linfit(p,t,v,y,y_calc,resid,coef,sig,nrow,ncol);
  write_data
end.
