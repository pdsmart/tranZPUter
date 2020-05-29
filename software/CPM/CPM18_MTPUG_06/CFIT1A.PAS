program cfit1A;		{ -> 142 }
{ Pascal program to perform a linear least-squares fit }

const	max	= 20;

type	index	= 1..max;
	ary	= array[index] of real;

var	x,y,y_calc	: ary;
	n		: integer;
	first,done	: boolean;
	seed,a,b	: real;

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
var	i	: integer;

begin
  writeln;
  writeln('    I      X     Y');
  for i:=1 to n do
    writeln(i:3,x[i]:8:1,y[i]:9:2);
  writeln
end;		{ write_data }

begin	{ MAIN program }
  cls;
  seed:=4.0;
  first:=true;
  done:=false;
  repeat
    get_data(x,y,n);
    if not done then
      begin
	write_data;
	{ ***** --->  more lines to be added here ********* }
    end
  until done
end.
