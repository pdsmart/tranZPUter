program trap2;		{ -> 266 }
{ integration by the trapezoidal rule }

const	tol		= 1.0E-4;
var	sum,upper,lower	: real;

external procedure cls;

function fx(x: real): real;
{ find f(x)=1/x }
{ watch out for x=0 ! }
begin
  fx:=1.0/x
end;

procedure trapez(lower,upper,tol: real;
		var sum		: real);

{ numerical integration by the trapezoid method }
{ function is FX, limits are LOWER and UPPER }
{ with number of regions equal to PIECES }
{ fixed partition is DELTA_X, answer is SUM }

var	pieces,i			: integer;
	x,delta_x,end_sum,mid_sum,sum1	: real;
begin
  pieces:=1;
  delta_x:=(upper-lower)/pieces;
  end_sum:=fx(lower)+fx(upper);
  sum:=end_sum*delta_x/2.0;
  writeln('    1',sum);
  mid_sum:=0.0;
  repeat
    pieces:=pieces*2;
    sum1:=sum;
    delta_x:=(upper-lower)/pieces;
    for i:=1 to pieces div 2 do
    begin
      x:=lower+delta_x*(2.0*i-1.0);
      mid_sum:=mid_sum+fx(x)
    end;
  sum:=(end_sum+2.0*mid_sum)*delta_x*0.5;
  writeln(pieces:5,sum)
  until abs(sum-sum1)<=abs(tol*sum)
end;		{ TRAPEZ }

begin		{ main program }
  cls;
  lower:=1.0;
  upper:=9.0;
  writeln;
  trapez(lower,upper,tol,sum);
  writeln;
  writeln(chr(7),'area=',sum)
end.
