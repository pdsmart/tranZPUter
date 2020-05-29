program newdr;	{ -> 243 }
var	x,x2	: real;
	alldone	: boolean;
	error	: boolean;

external procedure cls;

procedure func(x: real;
		var fx,dfx: real);
begin
  fx:=x*x-2.0;
  dfx:=2.0*x
end;	{ func }

procedure newton(var x: real);
const 	tol	= 1.0E-6;

var	fx,dfx,dx,x1:	real;

begin	{ newton }
  repeat
    x1:=x;
    func(x,fx,dfx);
    dx:=fx/dfx;
    x:=x1-dx;
    writeln('x=',x1,'  fx=',fx,'  dfx=',dfx);
  until abs(dx)<=abs(tol*x)
end;	{ newton }

begin		{ main program }
  cls;
  writeln;
  x:=2.0;	{ first guess }
  newton(x);
  writeln;
  writeln(chr(7),'The solution is ',x);
  writeln
end.
