program solvgj;		{ -> 84 }
{ pascal program to perform simultaneous solution by Gauss-Jordan elimination}

const	maxr	= 8;
	maxc	= 8;

type	ary	= array[1..maxr] of real;
	arys	= array[1..maxc] of real;
	ary2s	= array[1..maxr,1..maxc] of real;

var	y	: arys;
	coef	: arys;
	a,b	: ary2s;
	n,m,i,j	: integer;
	first,
	error	: boolean;

external procedure cls;

procedure get_data(var a: ary2s;
		   var y: arys;
		   var n,m: integer);

{ get the values for n and arrays a,y }

var	i,j	: integer;

begin
  writeln;
  repeat
    write('How many equations? ');
    readln(n);
    if first then first:=false else cls;
    m:=n
  until n<maxr;
  if n>1 then
    begin
      for i:=1 to n do
	begin
	  writeln('Equation',i:3);
	  for j:=1 to n do
	    begin
	      write(j:3,':');
	      read(a[i,j])
	    end;
	  write(',C:');
	  readln(y[i])	{ clear line }
	end;
      writeln;
      for i:=1 to n do
	begin
	  for j:=1 to m do
	    write(a[i,j]:7:4,' ');
	  writeln(':',y[i]:7:4)
	end;
      writeln
    end		{ if n>1 }
end;	{ procedure get_data }

procedure write_data;

{ print out the answers }

var	i	: integer;

begin
  for i:=1 to m do
    write(coef[i]:9:5);
  writeln
end;	{ write_data }



{external procedure gaussj
 (var		b : ary2s;
		y : arys;
  var	     coef : arys;
	     ncol : integer;
  var	    error : boolean);}

{$I C:GAUSSJ.LIB}

begin		{ MAIN program }
  first:=true;
  cls;
  writeln;
  writeln('Simultanuns solution by Gauss-Jordan elimination');
  repeat
    get_data(a,y,n,m);
    if n>1 then
      begin
	for i:=1 to n do
	  for j:=1 to n do
	    b[i,j]:=a[i,j];	{ setup work array }
	gaussj(b,y,coef,n,error);
	if not error then write_data
      end
  until n<2
end.
