program simq1;		{ -> 67 }
{ pascal program to solve three simultaneous equations by Cramer's rule }

const	rmax	= 3;
	cmax	= 3;

type	arys	= array[1..cmax] of real;
	ary2s	= array[1..rmax,1..cmax] of real;

var	y,coef	: arys;
	a	: ary2s;
	n	: integer;
	yesno	: char;
	error	: boolean;

external procedure cls;

procedure get_data(var a: ary2s;
		   var y: arys;
		   var n: integer);

{ get the values for n, and arrays a,y }

var	i,j	: integer;

begin	{ procedure get_data }
  writeln;
  n:=rmax;
  for i:=1 to n do
    begin
      writeln(' Equation',i:3);
      for j:=1 to n do
	begin
	  write(j:3,':');
	  read(a[i,j])
	end;
      write(',C:');
      readln(y[i])
    end;
  writeln;
  for i:=1 to n do
    begin
      for j:=1 to n do
	  write(a[i,j]:7:4,' ');
	  writeln(':',y[i]:7:4)
	end;
     writeln
end;		{ procedure get_data }

procedure write_data;
	{ print out the answeres }

var	i	: integer;

begin	{ write_data }
  for i:=1 to n do
    write(coef[i]:9:5);
  writeln
end;		{ write_data }


procedure solve(a: ary2s;
		y: arys;
	 var coef: arys;
		n: integer;
	var error: boolean);

var
	b	: ary2s;
	i,j	: integer;
	det	: real;



function deter(a: ary2s): real;
{ pascal program to calculate the determinant of a 3-by-3matrix }

var
	sum	: real;

begin	{ function deter }
  sum:=a[1,1]*(a[2,2]*a[3,3]-a[3,2]*a[2,3])
	-a[1,2]*(a[2,1]*a[3,3]-a[3,1]*a[2,3])
	+a[1,3]*(a[2,1]*a[3,2]-a[3,1]*a[2,2]);
  deter:=sum
end;	{ function deter }



procedure setup(var b: ary2s;
	     var coef: arys;
		    j: integer);

var	i	: integer;

begin	{ setup }
  for i:=1 to n do
    begin
      b[i,j]:=y[i];
      if j>1 then b[i,j-1]:=a[i,j-1]
    end;
  coef[j]:=deter(b)/det
end;	{ setup }

begin		{ procedure solve }
  error:=false;
  for i:=1 to n do
    for j:=1 to n do
      b[i,j]:=a[i,j];
  det:=deter(b);
  if det=0.0 then
    begin
      error:=true;
      writeln(chr(7),'ERROR: matrix is singular.')
    end
  else
    begin
      setup(b,coef,1);
      setup(b,coef,2);
      setup(b,coef,3);
    end	{ else }
end;	{procedure solve }


begin		{ MAIN program }
  cls;
  writeln;
  writeln('Simultaneous solution by Cramers rule');
  repeat
    get_data(a,y,n);
    solve(a,y,coef,n,error);
    if not error then write_data;
    writeln;
    write('More?');
    readln(yesno);
    cls
  until(yesno<>'Y')and(yesno<>'y')
end.
