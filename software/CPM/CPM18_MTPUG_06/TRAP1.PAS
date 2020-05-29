program trap1;		{ -> 264 }
{ integration by the trapezoidal rule }

var	done		: boolean;
	sum,upper,lower	: real;
	pieces		: integer;

function fx(x: real): real;
{ find f(x)=1/x }
{ watch out for x=0 ! }
begin
  fx:=1.0/x
end;

procedure trapez(lower,upper	: real;
		 pieces		: integer;
		var sum		: real);
{ numerical integration by the trapezoid method }
{ function is FX, limits are LOWER and UPPER }
{ with number of regions equal to PIECES }
{ fixed partition is DELTA_X, answer is SUM }

var	i			: integer;
	x,delta_x,esum,psum	: real;
begin
  delta_x:=(upper-lower)/pieces;
  esum:=fx(lower)+fx(upper);
  psum:=0.0;

  for i:=1 to pieces do
    begin
      x:=lower+i*delta_x;
      psum:=psum+fx(x)
    end;
  sum:=(esum+2.0*psum)*delta_x*0.5
end;		{ TRAPEZ }

begin		{ main program }
  done:=false;
  lower:=1.0;
  upper:=9.0;
  writeln;
  repeat
    write('How many sections? ');
    readln(pieces);
    if pieces<0 then done:=true

    else
      begin
	trapez(lower,upper,pieces,sum);
	writeln('area=',sum)
      end
  until done
end.
