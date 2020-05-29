program erfd;		{ -> 326 }

{ evaluation of the gaussian error function }

var	x,ans		: real;
	done		: boolean;

function erf(x: real): real;
{ infinite series expansion of the Gaussian error function }

const	sqrtpi		= 1.7724538;
	tol		= 1.0E-6;

var	x2,sum,sum1,term: real;
	i		: integer;

begin
  if x=0.0 then erf:=0.0
  else if x>4.0 then erf:=1.0
  else
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
  end	{ if }
end;	{ erf }

begin		{ main }
  done:=false;
  writeln;
  repeat
    write('Arg? ');
    readln(x);
    if x<0.0 then done:= true
    else
      begin
	ans:=erf(x);
	writeln('Erf of ',x:6:3,' is ',ans:9:5)
      end
  until done
end.
