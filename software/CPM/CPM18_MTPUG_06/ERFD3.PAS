program erfd3;		{ -> 330 }
{ evaluation of the gaussian error function }

var	x,er,ec		: real;
	done		: boolean;

external procedure cls;

function erf(x: real): real;
{ infinite series expansion of the Gaussian error function }

const	sqrtpi		= 1.7724538;
	tol		= 1.0E-4;

var	x2,sum,sum1,term: real;
	i		: integer;

begin
      x2:=x*x;
      sum:=x;
      term:=x;
      i:=0;
      repeat
	i:=i+1;
	sum1:=sum;
	term:=2.0*term*x2/(1.0+2.0*i);
	sum:=term+sum1
      until term<tol*sum;
      erf:=2.0*sum*exp(-x2)/sqrtpi
end;	{ erf }

function erfc(x: real): real;
{ complement of error function }
const	sqrtpi		= 1.7724538;
	terms		= 12;

var	x2,u,v,sum	: real;
	i		: integer;
begin
  x2:=x*x;
  v:=1.0/(2.0*x2);
  u:=1.0+v*(terms+1.0);
  for i:=terms downto 1 do
    begin
      sum:=1.0+i*v/u;
      u:=sum
    end;
  erfc:=exp(-x2)/(x*sum*sqrtpi)
end;		{ ercf }

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
	writeln('X= ',x,' Erf= ',er:7:4,', Erfc= ',ec)
      end	{ if }
    until done
end.
