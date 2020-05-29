
program tstgam;		{ -> 340 }
{ test the gamma function }

var	x	: real;

external procedure cls;

function gamma(x: real): real;
const	pi	= 3.1415926;

var	i,j	: integer;
	y,gam	: real;

begin		{ gamma function }
  if x>=0.0 then
    begin
      y:=x+2.0;
      gam:=sqrt(2*pi/y)*exp(y*ln(y)+(1-1/(30*y*y))/(12*y)-y);
      gamma:=gam/(x*(x+1))
    end
  else		{ x<0 }
    begin
      j:=0;
      y:=x;
      repeat
	j:=j+1;
	y:=y+1.0
      until y>0.0;
      gam:=gamma(y);		{ recursive call }
      for i:=0 to j-1 do
	gam:=gam/(x+i);
      gamma:=gam
    end	{ x<0 }
end;		{ gamma function }

begin
  cls;
  writeln;
  repeat
    repeat
      write('X: ');
      read(x)
    until x<>0.0;
    writeln('Gamma is ',gamma(x))
  until x<-22.0;
end.
