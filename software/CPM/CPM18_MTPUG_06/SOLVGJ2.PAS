program solvgj2;		{ -> 111 }
{ pascal program to perform simultaneous solution by Gauss-Jordan elimination}
{ there may be more equations than unknowns }

const	maxr	= 8;
	maxc	= 8;

type	ary	= array[1..maxr] of real;
	arys	= array[1..maxc] of real;
	ary2s	= array[1..maxr,1..maxc] of real;
	ary2	= ary2s;	{ for square }

var	y	: ary;
	coef,yy	: arys;
	a,b	: ary2s;
	n,m,i,j	: integer;
	first,
	error	: boolean;

external procedure cls;

procedure get_data(var a: ary2s;
		   var y: ary;
		   var n,m: integer);

{ get the values for n and arrays a,y }

var	i,j	: integer;

begin
  writeln;
  repeat
    write('How many unknowns? ');
    readln(m);
    if first then first:=false else cls;
  until m<maxc;
  if m>1 then
    begin
      repeat
	write('How many equations? ');
	readln(n)
      until n>=m;
	for i:=1 to n do
	begin
	  writeln('Equation',i:3);
	  for j:=1 to m do
	    begin
	      write(j:3,':');
	      read(a[i,j])
	    end;
	  write(',C:');
	  readln(y[i])	{ clear line }
	end;	{ i-loop }
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

{external procedure square
 (		y : ary;
  var		a : ary2s;
  var		g : arys;
	nrow,ncol : integer);}

{$I C:SQUARE.LIB}

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
  writeln('Best fit to simultaneous equations');
  writeln('By Gauss-Jordan');
  repeat
    get_data(a,y,n,m);
    if m>1 then
      begin
	square(a,y,b,yy,n,m);
	gaussj(b,yy,coef,m,error);
	if not error then write_data
      end
  until m<2
end.
