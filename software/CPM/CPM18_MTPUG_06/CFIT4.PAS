program cfit4;		{164}

{ plot service included }
{ Pascal program to perform a linear least-squares fit }

const	max	= 20;

type	index	= 1..max;
	ary	= array[index] of real;

var	x,y,y_calc	: ary;
	n		: integer;
	first,done	: boolean;
	a,b,correl_coef,
	sigma_a,sigma_b,
	see,seed	: real;

external procedure cls;

function random(dummy: integer): real;
{ random number 0-1 }
{ define seed=4.0 as global }

const	pi	= 3.14159;

var	x	: real;
	i	: integer;

begin	{ RANDOM }
  x:=seed+pi;
  x:=exp(5.0*ln(x));
  seed:=x-trunc(x);
  random:=seed
end;	{ RANDOM }



procedure get_data(var x,y: ary;
		   var n: integer);
{ get values for n and arrays x,y }
{ y is randomly scattered about a straight line }

const	a = 2.0;
	b = 5.0;

var	i,j	: integer;
	fudge	: real;

begin
  write('Fudge? ');
  readln(fudge);
  if fudge<0.0 then done:=true
  else
    begin
      repeat
	write('How many points? ');
	readln(n)
      until (n>2) and (n<=max);
      if first then first:=false else cls;
      for i:=1 to n do
	begin
	  j:=n+1-i;
	  x[i]:=j;
	  y[i]:=(a+b*j)*(1.0+(2.0*random(0)-1.0)*fudge)
      end	{ for-loop }
    end		{ if }
end;		{ procedure get_data }


procedure write_data;
{ print out the answers }
var	i,j	: integer;

begin
  writeln;
  writeln('  I      X       Y      YCALC');
  for i:=1 to n do
    writeln(i:3,x[i]:8:1,y[i]:9:2,y_calc[i]:9:2);
  writeln;
  writeln('Intercept is ',a:8:3,', sigma is ',sigma_a:8:3);
  writeln('    Slope is ',b:8:2,', sigma is ',sigma_b:8:3);
  writeln;
  writeln('Correlation coeffizient is ',correl_coef:7:4);
  for j:=1 to 40 do for i:=1 to 10000 do; cls
end;		{ write_data }

{$I C:LINFIT2.LIB }

{$I PLOT.LIB }

begin	{ MAIN program }
  seed:=4.0;
  cls;
  first:=true;
  done:=false;
  repeat
    get_data(x,y,n);
    if not done then
      begin
	linfit(x,y,y_calc,a,b,n);
	write_data;
	plot(x,y,y_calc,n);
    end
  until done
end.
