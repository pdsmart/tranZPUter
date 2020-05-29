program matr1;		{ -> 50 }
{ pascal program to perform matrix multiplication }

const	rmax	= 9;
	cmax	= 3;


type	ary	= array[1..rmax] of real;
	arys	= array[1..cmax] of real;
	ary2	= array[1..rmax,1..cmax] of real;
	ary2s	= array[1..cmax,1..cmax] of real;

var	y		: ary;
	g		: arys;
	x		: ary2;
	a		: ary2s;
	nrow,ncol	: integer;

external procedure cls;

procedure get_data(var x: ary2;
		   var y: ary;
	   var nrow,ncol: integer);

{ get the values for nrow, ncol, and arrays x,y }

var	i,j	: integer;

begin
  nrow:=5;
  ncol:=3;
  for i:=1 to nrow do
    begin
	x[i,1]:=1;
	for j:=2 to ncol do
	  x[i,j]:=i*x[i,j-1];
	y[i]:=2*i
    end
end;		{ procedure get_data }



procedure write_data;

{ print out the answeres }

var
  i,j	: integer;

begin
  cls;
  writeln;
  writeln('          X             Y');
  for i:=1 to nrow do
    begin
	for j:=1 to ncol do
	  write(x[i,j]:7:1,' ');
	writeln(':',y[i]:7:1)
    end;
  writeln('          A             G');
  for i:=1 to ncol do
    begin
	for j:=1 to ncol do
	  write(a[i,j]:7:1,' ');
	writeln(':',g[i]:7:1)
    end
end;		{ write_data }


procedure square(x: ary2;
		 y: ary;
	     var a: ary2s;
	     var g: arys;
	 nrow,ncol: integer);

{ matrix multiplication routine }
{ a= transpose x times x }
{ g= y times x }

var
 i,k,l	: integer;

begin		{ square }
  for k:=1 to ncol do
    begin
	for l:=1 to k do
	  begin
	    a[k,l]:=0;
	    for i:=1 to nrow do
	    begin
		  a[k,l]:=a[k,l]+x[i,l]*x[i,k];
		  if k<>l then a[l,k]:=a[k,l]
	    end
	 end;		{ l-loop }
	 g[k]:=0;
	 for i:=1 to nrow do
	 g[k]:=g[k]+y[i]*x[i,k]
  end	{ k-loop }
end;	{ square }


begin	{ MAIN program }
  get_data(x,y,nrow,ncol);
  square(x,y,a,g,nrow,ncol);
  write_data
end.
