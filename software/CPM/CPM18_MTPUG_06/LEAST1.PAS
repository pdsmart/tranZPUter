{$S+ }
program least1;		{ --> 191 }
{ Pascal Program to perform a liner least-squares fit using a parabolic }
{	curve. Aeperate procedure PLOT needed }

const	maxr	= 20;
	maxc	= 3;

type	ary	= array[1..maxr] of real;
	arys	= array[1..maxc] of real;
	ary2s	= array[1..maxc,1..maxc] of real;

var	x,y,y_calc	: ary;
	coef		: arys;
	nrow,ncol	: integer;
	correl_coef	: real;


external procedure cls;

procedure get_data(var x,y: ary;
		   var nrow: integer);
{ get values for n and arrays x,y }

var	i	: integer;

begin
  nrow:=9;
  writeln;
  for i:=1 to nrow do x[i]:=i;
  y[1]:=2.07;	y[2]:=8.6;
  y[3]:=14.42;	y[4]:=15.8;
  y[5]:=18.92;	y[6]:=17.96;
  y[7]:=12.98;	y[8]:=6.45;
  y[9]:=0.27;
end;		{ procedure get_data }

procedure write_data;
{ print out the answers }
var	i	: integer;
begin
  writeln;
  writeln('  I      X       Y       YCALC');
  for i:=1 to nrow do
    writeln(i:3,x[i]:8:1,y[i]:9:2,y_calc[i]:9:2);
  writeln; writeln(' Coefficients ');
  for i:=1 to ncol do
    writeln(coef[i]:8:4);
  writeln;
  writeln('Correlation coefficient is ',correl_coef:8:5)
end;		{ write_data }

procedure solve(a: ary2s;
		y: arys;
	 var coef: arys;
	     nrow: integer;
	var error: boolean);

var	b	: ary2s;
	i,j	: integer;
	det	: real;


function deter(a: ary2s): real;
	{ calculate the determinant of a 3-by-3matrix }
begin
  deter:=a[1,1]*(a[2,2]*a[3,3]-a[3,2]*a[2,3])
	-a[1,2]*(a[2,1]*a[3,3]-a[3,1]*a[2,3])
	+a[1,3]*(a[2,1]*a[3,2]-a[3,1]*a[2,2])
end;



procedure setup(var b	: ary2s;
		var coef: arys;
		j	: integer);

var	i	: integer;

begin	{ setup }
  for i:=1 to nrow do
    begin
      b[i,j]:=y[i];
      if j>1 then b[i,j-1]:=a[i,j-1]
    end;
  coef[j]:=deter(b)/det
end;		{ setup }

begin	{ procedure solve }
  error:=false;
  for i:=1 to nrow do
    for j:=1 to nrow do
      b[i,j]:=a[i,j];
  det:=deter(b);
  if det=0.0 then
    begin
      error:=true;
      writeln(chr(7),'ERROR: matrix is singular')
    end
  else
    begin
      setup(b,coef,1);
      setup(b,coef,2);
      setup(b,coef,3)
    end		{ esle }
end;		{ procedure solve }


procedure linfit(x,y: ary;
		 var y_calc: ary;
		 var coef:   arys;
		     nrow:   integer;
		 var ncol:   integer);

{ least squares fit to a parabola }
{ nrow sets of x and y pair points }

var	a		: ary2s;
	g		: arys;
	i		: integer;
	error		: boolean;

	sum_x,sum_y,sum_xy,sum_x2,
	sum_y2,xi,yi,sxy,syy,
	sxx,sum_x3,sum_x4,sum_2y,
	denom,srs,x2	: real;

begin 		{ linfit }
  ncol:=3;	{ polynomial terms }
  sum_x:=0.0;
  sum_y:=0.0;
  sum_xy:=0.0;
  sum_x2:=0.0;
  sum_y2:=0.0;
  sum_x3:=0.0;
  sum_x4:=0.0;
  sum_2y:=0.0;
  for i:=1 to nrow do
    begin
      xi:=x[i];
      yi:=y[i];
      x2:=xi*xi;
      sum_x:=sum_x+xi;
      sum_y:=sum_y+yi;
      sum_xy:=sum_xy+xi*yi;
      sum_x2:=sum_x2+x2;
      sum_y2:=sum_y2+yi*yi;
      sum_x3:=sum_x3+xi*x2;
      sum_x4:=sum_x4+x2*x2;
      sum_2y:=sum_2y+x2*yi
    end;
  a[1,1]:=nrow;
  a[2,1]:=sum_x;	a[1,2]:=sum_x;
  a[3,1]:=sum_x2;	a[1,3]:=sum_x2;
  a[2,2]:=sum_x2;	a[3,2]:=sum_x3;
  a[2,3]:=sum_x3;	a[3,3]:=sum_x4;
  g[1]:=sum_y;
  g[2]:=sum_xy;
  g[3]:=sum_2y;
  solve(a,g,coef,ncol,error);
  srs:=0.0;
  for i:=1 to nrow do
    begin
      y_calc[i]:=coef[1]+coef[2]*x[i]+coef[3]*sqr(x[i]);
      srs:=srs+sqr(y[i]-y_calc[i])
    end;
  correl_coef:=sqrt(1.0-srs/(sum_y2-sqr(sum_y)/nrow))
end;		{ linfit }

{ external procedure plot(x,y,y_calc: ary; nrow: integer);
}

{$I C:PLOT.LIB }		{ get ptocedure PLOT }

begin		{ MAIN program }
  cls;
  get_data(x,y,nrow);
  linfit(x,y,y_calc,coef,nrow,ncol);
  write_data;
  plot(x,y,y_calc,nrow)
end.		{ MAIN }
