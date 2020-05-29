program tstsort;		{ -> 172 }
{ test speed of sorting routine }

const	max	= 1000;

type	ary	= array[1..300] of real;

var	x	: ary;
	n,i	: integer;
	seed	: real;
	first	: boolean;

external procedure cls;

{$I RANDOM.LIB }

procedure print;
var	i 	: integer;

begin
  writeln;
  for i:=1 to n do
    begin
      write(x[i]:7:2);
      if (i mod 10)=0 then writeln
    end
end;

procedure { bubble- } sort(var a: ary; n: integer);
var	i,j	: integer;
	hold	: real;

begin		{ procedure sort }
  for i:=1 to n-1 do
    for j:=i+1 to n do
      begin
	if a[i]>a[j] then
	  begin
	    hold:=a[i];
	    a[i]:=a[j];
	    a[j]:=hold
	  end
    end		{ for }
end;		{ procedure sort }

begin		{ MAIN program }
  cls;
  seed:=4.0;
  repeat
    repeat
      writeln;
      write('How many points? ');
      readln(n)
    until n<=max;
    if first then first:=false else cls;
    for i:=1 to n do
      x[i]:=100*random(0);
    print;
    write(chr(7));
    sort(x,n);		{ random numbers }
    write(chr(7));
    print;
    writeln(' random ');
    write(chr(7));
    sort(x,n);		{ sorted numbers }
    write(chr(7));
    print;
    writeln(' sorted ');
    for i:=1 to n do
      x[i]:=n+1-i;
    write(chr(7));
    print;
    writeln(' reversed ');
  until n<5
end.
