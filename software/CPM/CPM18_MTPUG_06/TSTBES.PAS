program tstbes;		{ -> 344 }
{ test the bessel function }
{ the Gamma function is included }

var	done	:boolean;
	x,ordr	: real;


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
	gam:=gam/(x+1);
      gamma:=gam
    end	{ x<0 }
end;		{ gamma function }

function bessj(x,n: real): real;
{ cylindrical Bessel function of the first kind }
{ the gamma function is required }

const	tol	= 1.0E-4;
	pi	= 3.1415926;

var	i		: integer;
	term,new_term,
	sum,x2		: real;

begin	{ bessj }
  x2:=x*x;
  if (x=0.0)and(N=1.0) then bessj:=0.0
  else if x>15 then { asymptotic expansion }
    bessj:=sqrt(2/(pi*x))*cos(x-pi/4-n*pi/2)
  else
    begin
      if n=0.0 then sum:=1.0
      else sum:=exp(n*ln(x/2))/gamma(n+1.0);
      new_term:=sum;
      i:=0;
  repeat
    i:=i+1;
    term:=new_term;
    new_term:=-term*x2*0.25/(i*(n+1));
    sum:=sum+new_term
  until abs(new_term)<=abs(sum*tol);
  bessj:=sum
 end	{ if}
end;	{ bessj }

begin		{ main }
  done:=false;
  repeat
    write('Order: ');
    readln(ordr);
    if ordr<-25.0 then done:=true
    else
      begin
	write('X: ');
	readln(x);
	writeln('J Bessel is ',bessj(x,ordr))
     end
  until done
end.
