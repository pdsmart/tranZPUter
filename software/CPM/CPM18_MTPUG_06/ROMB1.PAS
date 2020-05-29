program romb1;		{ -> 281 }
{ integration by the romberg method }

const	tol		= 1.0E-4;
var	done		: boolean;
	sum,upper,lower	: real;

external procedure cls;

function fx(x: real): real;
{ find f(x)= 1.0/x; watch out for x=0 }
begin
  fx:=1.0/x
end;

procedure romb(function f(x:real): real;
		lower,upper,tol: real;
			var ans: real);
{ numerical integration by the Romberg method }
var
	nx			: array[1..16] of integer;
	t			: array[1..136] of real;
	done,error		: boolean;
	pieces,nt,i,ii,n,nn,
	l,ntra,k,m,j		: integer ;
	delta_x,c,sum,fotom,x	: real ;
begin
  done:=false;
  error:=false;
  pieces:=1;
  nx[1]:=1;
  delta_x:=(upper-lower)/pieces;
  c:=(f(lower)+f(upper))*0.5;
  t[1]:=delta_x*c;
  n:=1;
  nn:=2;
  sum:=c;
  repeat
    n:=n+1;
    fotom:=4.0;
    nx[n]:=nn;
    pieces:=pieces*2;
    l:=pieces-1;
    delta_x:=(upper-lower)/pieces;
    { compute trapezoidal sum for 2^(n-1)+1 points }
    for ii:=1 to (l+1) div 2 do
      begin
	i:=ii*2-1;
	x:=lower+i*delta_x;
	sum:=sum+f(x)
      end;
    t[nn]:=delta_x*sum;
    write(pieces:5,t[nn]);
    ntra:=nx[n-1];
    k:=n-1;
    { compute n-th row of T array }
    for m:=1 to k do
      begin
	j:=nn+m;
	nt:=nx[n-1]+m-1;
	t[j]:=(fotom*t[j-1]-t[nt])/(fotom-1.0);
	fotom:=fotom*4.0
      end;
    writeln(j:4,t[j]);
    if n>4 then
      begin
	if t[nn+1]<>0.0 then
	  if (abs(t[ntra+1]-t[nn+1])<=abs(t[nn+1]*tol))
	    or (abs(t[nn-1]-t[j])<=abs(t[j]*tol)) then
	      done:=true
	  else if n>15 then
	    begin
	      done:=true;
	      error:=true
	    end
	end;	{ if n>4 }
    nn:=j+1
  until done;
  ans:=t[j]
end;		{ ROMBERG }

begin		{ main program }
  cls;
  lower:=1.0;
  upper:=9.0;
  writeln;
  romb(fx,lower,upper,tol,sum);
  writeln;
  writeln(chr(7),'Area= ',sum)
end.
