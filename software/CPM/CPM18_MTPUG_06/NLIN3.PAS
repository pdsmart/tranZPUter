{ die ln-funktion bei MT+ ist fuer Werte kleiner 1E-5 aeussertst langsam,
  so dass man das Gefuehl bekommt, das dass Programm sich aufhaengt. In-
  folgedessen konnte ich dieses Programm nicht verifizieren. -Juergen }

program nlin3;		{ -> 310 }
{ Pascal program to perform a nonlinear least-squares fit for the diffusion
	of Zn in CU }

const	maxr	= 20;		{ data prints }
	maxc	= 4;		{ polynomial terms }
	r	= 1.987;	{ gas constant }
type
	index	= 1..maxr;
	ary	= array[index] of real;
	arys	= array[1..maxc] of real;
	ary2	= array[1..maxr,1..maxc] of real;

var
	x,y,y_calc	: ary;
	t,d,ex		: ary;
	coef		: arys;
	i,n		: integer;
	nrow,ncol	: integer;
	done,error	: boolean;
	correl_coef,srs,
	a,b,x2		: real;

external procedure cls;

procedure get_data(var x,y: ary;
		   var n: integer);
{ get values for n and arrays t,d }

var	i	: integer;

begin
  n:=7;
  t[1]:=600.0;	d[1]:=1.4E-12;
  t[2]:=650.0;	d[2]:=5.5E-12;
  t[3]:=700.0;	d[3]:=1.8E-11;
  t[4]:=750.0;	d[4]:=6.1E-11;
  t[5]:=800.0;	d[5]:=1.6E-10;
  t[6]:=850.0;	d[6]:=4.4E-10;
  t[7]:=900.0;	d[7]:=1.2E-9;
  for i:=1 to n do
    begin
      x[i]:=1.0/(t[i]+273.0);
      y[i]:=d[i]
    end
end;		{ proceddure get data }

procedure write_data;
{ print out the answers }
var	i	: integer;
begin
  writeln;
  writeln;
  writeln('     I      TC     D      DCALC');
  for i:=1 to n do
    writeln(i:3,t[i]:8:0,d[i],' ',y_calc[i]);
  writeln; writeln(' Coefficients ');
  writeln(coef[1],' constant term');
  for i:=2 to ncol do
    writeln(coef[i]);		{ other terms }
  writeln;
  writeln('D0=',a:7:2,' cm sq/sec.');
  writeln('Q =',(-r*b/1000.0):8:2,'kcal/mole');
  writeln;writeln('SRS= ',srs:8:4)
end;		{ write_data }

procedure func(b: real;
      var fb,dfb: real);
var	i		: integer;
	s1,s2,s3,s4,s5,s6,
	ex1,ex2,xi,
	x2,yi,y2	: real;
begin
  s1:=0.0;
  s2:=0.0;
  s3:=0.0;
  s4:=0.0;
  s5:=0.0;
  s6:=0.0;
    for i:=1 to n do
      begin
	xi:=x[i];
	x2:=xi*xi;
	yi:=y[i];
	y2:=yi*yi;
	ex1:=exp(b*xi);
	ex[i]:=ex1;
	ex2:=ex1*ex1;
	s1:=s1+xi*ex2/y2;
	s2:=s2+ex1/yi;
	s3:=s3+xi*ex1/yi;
	s4:=s4+ex2/y2;
	s5:=s5+2.0*x2*ex2/y2;
	s6:=s6+x2*ex1/yi
      end;
    fb:=s1*s2-s3*s4;
    dfb:=s2*s5-s1*s3-s4*s6;
    a:=s2/s4
end;		{ func }


procedure newton(var x: real);
const	tol		= 1.0E-6;
	max		= 20;
var	fx,dfx,dx,x1	: real;
	i		: integer;

begin	{ newton }
  error:=false;
  i:=0;
  repeat
    i:=i+1;
    x1:=x;
    func(x,fx,dfx);
    if dfx=0.0 then
      begin
	error:=true;
	x:=1.0;
	writeln('ERROR: slope zero')
      end
    else
      begin
	dx:=fx/dfx;
	x:=x1-dx;
      end
  until
    error or
      (i>max) or
	(abs(dx)<=abs(tol*x));
  if i>max then
    begin
      writeln(chr(7),'ERROR: no convergence in ',max,' loops');
      error:=true
    end
end;		{ newton }

procedure nlin(x,y:	ary;
	var y_calc:	ary;
	       n:	integer);
{ fits the diffusion equation through n sets of x and y pairs of points }
var
	resid		: ary;
	matr		: ary2;
	i		: integer;
	xi,yi,sum_x,
	sum_y,sum_y2,b1,
	sum_xy,sum_x2	: real;
begin		{ nlin }
  ncol:=2;	{ number of terms }
  sum_x:=0.0;
  sum_y:=0.0;
  sum_xy:=0.0;
  sum_x2:=0.0;
  for i:=1 to n do
    begin
      xi:=x[i];
      yi:=ln(y[i]);
      sum_x:=sum_x+xi;
      sum_y:=sum_y+yi;
      sum_y2:=sum_y2+yi*yi;
      sum_xy:=sum_xy+xi*yi;
      sum_x2:=sum_x2+xi*xi
    end;
  b:=(sum_xy-sum_x*sum_y/n)/(sum_x2-sqr(sum_x)/n);
  newton(b);
  coef[1]:=a;
  coef[2]:=b;
  srs:=0.0;
  for i:=1 to n do
    begin
      y_calc[i]:=a*ex[i];
      if y[i]<>0.0 then
	resid[i]:=y_calc[i]/y[i]-1.0
      else resid[i]:=y[i]/y_calc[i]-1.0;
      srs:=srs+sqr(resid[i])
    end
end;	 	{ nlin }


begin		{ main program }
  cls;
writeln(' start get_data ');
  get_data(x,y,n);
writeln(' start nlin ');
  nlin(x,y,y_calc,n);
writeln(' start write_data ');
  write_data
end.
