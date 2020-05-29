program erfd4;		{ -> 334 }

{ evaluation of the gaussian error function }

var	x,er,ec		: real;
	done		: boolean;

external procedure cls;

function erf(x: real): real;
{ infinite series expansion of the Gaussian error function }

const	sqrtpi		= 1.7724538;
	t2		= 0.66666667;
	t3		= 0.66666667;
	t4		= 0.07619048;
	t5		= 0.01693122;
	t6		= 3.078403E-3;
	t7		= 4.736005E-4;
	t8		= 6.314673E-5;
	t9		= 7.429027E-6;
	t10		= 7.820028E-7;
	t11		= 7.447646E-8;
	t12		= 6.476214E-9;

var	x2,sum		: real;
	i		: integer;

begin
  x2:=x*x;
  sum:=t5+x2*(t6+x2*(t7+x2*(t8+x2*(t9+x2*(t10+x2*(t11+x2*t12))))));
  erf:=2.0*exp(-x2)/sqrtpi*(x*(1+x2*(t2+x2*(t3+x2*(t4+x2*sum)))))
end;	{ function erf }

function erfc(x: real): real;
{ complement of error function }
const	sqrtpi		= 1.7724538;

var	x2,v,sum	: real;

begin
  x2:=x*x;
  v:=1.0/(2.0*x2);
  sum:=v/(1+8*v/(1+9*v/(1+10*v/(1+11*v/(1+12*v)))));
  sum:=v/(1+3*v/(1+4*v/(1+5*v/(1+6*v/(1+7*sum)))));
  erfc:=1.0/(exp(x2)*x*sqrtpi*(1+v/(1+2*sum)))
end;		{ function ercf }

begin		{ main }
  cls;
  done:=false;
  writeln;
  repeat
    write('Arg? ');
    readln(x);
    if x<0.0 then done:=true
    else
      begin
	if x=0.0 then
	  begin
	    er:=0.0;
	    ec:=1.0
	  end
	else
	  begin
	    if x<1.5 then
	      begin
		er:=erf(x);
		ec:=1.0-er
	      end
	    else
	      begin
		ec:=erfc(x);
		er:=1.0-ec
	    end	{ if }
	end;
	writeln('X= ',x:6:2,', Erf= ',er:7:4,', Erfc= ',ec)
      end	{ if }
    until done
end.
