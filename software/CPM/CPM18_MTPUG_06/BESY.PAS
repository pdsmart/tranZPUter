program besy;		{ -> 348 }
{ evaluation of Bessel function of the second kind }

var	x,ordr	: real;
	done	: boolean;

external procedure cls;

function bessy(x,n: real): real;
{ cylindical bessel function of the second kind }
const	small	= 1.0E-8;
	euler	= 0.57721566;
	pi	= 3.1415926;
	pi2	= 0.63661977;	{ 2/pi }
var	j	: integer;

	x2,sum,sum2,t,t2,
	ts,term,xx,y0,y1,
	ya,yb,yc,ans,a,b,
	sina,cosa		: real;

begin			{ function bessy }
  if x<12 then
    begin
      xx:=0.5*x;
      x2:=xx*xx;
      t:=ln(xx)+euler;
      sum:=0.0;
      term:=t;
      y0:=t;
      j:=0;
      repeat
	j:=j+1;
	if j<>1 then sum:=sum+1/(j-1);
	ts:=t-sum;
	term:=-x2*term/(j*j)*(1-1/(j*ts));
	y0:=y0+term
      until abs(term)<small;
      term:=xx*(t-0.5);
      sum:=0.0;
      y1:=term;
      j:=1;
      repeat
	j:=j+1;
	sum:=sum+1/(j-1);
	ts:=t-sum;
	term:=(-x2*term)/(j*(j-1))*((ts-0.5/j)/(ts+0.5/(j-1)));
	y1:=y1+term
      until abs(term)<small;
      y0:=pi2*y0;
      y1:=pi2*(y1-1/x);
      if n=0.0 then ans:=y0
      else if n=1.0 then ans:=y1
      else
	begin		{ find y by recursion }
	  ts:=2.0/x;
	  ya:=y0;
	  yb:=y1;
	  for j:=2 to trunc(n+0.01) do
	    begin
	      yc:=ts*(j-1)*yb-ya;
	      ya:=yb;
	      yb:=yc
	    end;
	  ans:=yc
	end;
      bessy:=ans;
    end		{ x<12 }
  else		{ x>11, asymtotic expansion }
    bessy:=sqrt(2/(pi*x))*sin(x-pi/4-n*pi/2)
end;	{ function bessy }

begin
  cls;
  done:=false;
  writeln;
  repeat
    write('Order? ');
    readln(ordr);
    if ordr<0.0 then done:=true
    else
      begin
	repeat
	  write('Arg? ');
	  readln(x)
	until x>=0.0;
      writeln('Y Bessel is ',bessy(x,ordr))
    end		{ if }
  until done
end.
