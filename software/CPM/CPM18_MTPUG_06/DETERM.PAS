program determ;		{ -> 55 }
{ pascal program to calculate the determinant of a 3-by-3matrix }

type	ary2	= array[1..3,1..3] of real;

var	a	: ary2;
	n	: integer;
	yesno	: char;
	d	: real;

external procedure cls;

procedure get_data(var a: ary2;
		   var n: integer);

{ get values for n and arrays x,y }

var	i,j	: integer;

begin
  n:=3;
  writeln;
  for i:=1 to n do
    begin
	for j:=1 to n do
	  begin
	    write(j:3,':');
	    readln(a[i,j])
	end	{ j-loop }
  end;		{ i-loop }
  writeln;
  for i:=1 to n do
    begin
	for j:=1 to n do
	  write(a[i,j]:7:4,' ');
	writeln
	end;
    writeln
    end;	{ procedure get_data }




function deter(a: ary2): real;
	{ calculate the determinant of a 3-by-3matrix }

var
	sum	: real;

begin
  sum:=a[1,1]*(a[2,2]*a[3,3]-a[3,2]*a[2,3])
	-a[1,2]*(a[2,1]*a[3,3]-a[3,1]*a[2,3])
	+a[1,3]*(a[2,1]*a[3,2]-a[3,1]*a[2,2]);
  deter:=sum
end;



begin		{ MAIN program }
  cls;
  repeat
    get_data(a,n);
    d:=deter(a);
    writeln('The determinant is',d);
    writeln;
    write('More?');
    readln(yesno);
    cls
  until (yesno<>'Y')and(yesno<>'y')
end.
