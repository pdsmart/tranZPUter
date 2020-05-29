program erfsimp;		{ -> 323 }

{ integration by Simpson's method }

const	tol		= 1.0E-4;
	pi		= 3.141593;

var	done		: boolean;
	sum,upper,lower,
	erf,twopi	: real;

external procedure cls;

function fx(x: real): real;
begin
  fx:=exp(-x*x)
end;		{ function fx }


procedure simps(function f(x: real): real;
		lower,upper,tol	: real;
		var sum		: real);

{ numerical integration by Simpson's rule }
{ function is f, limits are lower and upper }
{ with number of regions equal to pieces }
{ partition is delta_x, answer is sum }

var	i		: integer;
	x,delta_x,even_sum,
	odd_sum,end_sum,
	sum1		: real;
	pieces		: integer;
begin
  pieces:=2;
  delta_x:=(upper-lower)/pieces;
  odd_sum:=f(lower+delta_x);
  even_sum:=0.0;
  end_sum:=f(lower)+f(upper);
  sum:=(end_sum+4.0*odd_sum)*delta_x/3.0;
  writeln(pieces:5,sum);
  repeat
    pieces:=pieces*2;
    sum1:=sum;
    delta_x:=(upper-lower)/pieces;
    even_sum:=even_sum+odd_sum;
    odd_sum:=0.0;
    for i:=1 to pieces div 2 do
      begin
	x:=lower+delta_x*(2.0*i-1.0);
	odd_sum:=odd_sum+f(x)
      end;
    sum:=(end_sum+4.0*odd_sum+2.0*even_sum)*delta_x/3.0;
  until abs(sum-sum1)<=abs(tol*sum1)
end;	{ simps }

begin		{ main program }
  cls;
  done:=false;
  twopi:=2.0/sqrt(pi);
  lower:=0.0;

  repeat
    writeln;
    writeln('Erf? ');
    readln(upper);
    if upper<0.0 then done:=true
    else if upper=0.0 then
      writeln('Erf of 0.0 is 0.0')

	else	{ upper>0 }
	  begin
	    simps(fx,lower,upper,tol,sum);
	    erf:=twopi*sum;
	    writeln('Erf of ',upper:7:2,', is ',erf:8:4)
        end
    until done
end.
