program solvgv;		{ -> 96 }
{ pascal program to perform simultaneous solution by gauss-jordan elimination }
{ with multiple constant vectors }

const	maxr	= 7;
	maxc	= 7;

type	ary2s	= array[1..maxr,1..maxc] of real;

var	dummy	: char;
	a,y	: ary2s;
	n,nvec	: integer;
	first,
	error	: boolean;
	determ	: real;

external procedure cls;
external procedure revon;
external procedure revoff;

procedure get_data(var a: ary2s;
		   var y: ary2s;
		   var n,nvec: integer);
{ get values for n,nvec and arrays a,y }

var	i,j	: integer;

begin
  if not first then cls else first:=false;
  writeln;
  repeat
    write('How many equations? ');
    readln(n)
  until n<maxr;
  if n>1 then
    begin
      write('How many constant vectors? ');
      readln(nvec);
      for i:=1 to n do
	begin
	  for j:=1 to n do
	    begin
	      write(j:3,': ');
	      read(a[i,j]);
	      if (j mod n+nvec)=0 then writeln
	    end;
        if nvec>0 then
	  begin
	    for j:=1 to nvec do
	      begin
		write('        C:');
		read(y[i,j])
	      end;
	    readln
	  end
     end;		{ i-loop }

  writeln;
  write('      Matrix');
  if nvec>0 then write('      Constants');
  writeln;
  for i:=1 to n do
    begin
      for j:=1 to n do
	write(a[i,j]:7:4,' ');
      for j:=1 to nvec do
	write(':',y[i,j]:7:4);
      writeln
  end;			{ i-loop }
  writeln
  end		{ if n>1 }
 end;	{ procedure get_data }

procedure write_data;
	{ print out answers }

var	i,j	: integer;

begin
  if nvec>0 then
    begin
      writeln('Solution ');
      for i:=1 to n do
	begin
	  for j:=1 to nvec do
	    write(y[i,j]:9:5);
	  writeln
	end
  end	{ if }
 else
  begin
    writeln('      Inverse');
    for i:=1 to n do
      begin
	for j:=1 to n do
	  write(a[i,j]:9:5);
	writeln
      end;
    writeln;
    write('Determinant is ',determ:10:5)
  end;		{ else }
 writeln
end;	{ write_data }


procedure gausjv
	(var	b	: ary2s;	{ square matrix of coefficients }
	 var	w	: ary2s;	{ constant vector matrix }
	 var	determ	: real;		{ the determinant }
		ncol	: integer;	{ order of matrix }
		nv	: integer;	{ number of constants }
	var	error	: boolean);	{ true if matrix is singular }

{ Gauss Jordan matrix inversion and solution }
{  B(n,n) coefficients matrix becomes inverse }
{  W(n,m) constant vector(s) become solution vector }
{  determ is the determinant }
{  error=1 if singular }
{  INDEX(n,3) }
{  NV is the number of vectors }

label 99;

var
	index	: array[1..maxc,1..3] of integer;
	i,j,k,l,
	irow,icol,
	n,l1	: integer;
	pivot,hold,
	sum,ab,
	t,big	: real;

procedure swap(var a,b: real);
var	hold	: real;

begin
	hold:=a;
	a:=b;
	b:=hold
end;	{ procedure swap }


procedure gausj2;
  label 98;
  var	i,j,k,l,l1	: integer;


procedure gausj3;

var	l	: integer;

begin		{ procedure gausj3 }
	{ interchange rows to put pivot on diagonal }
  if irow<>icol then
    begin
      determ:=-determ;
      for l:=1 to n do
	swap(b[irow,l],b[icol,l]);
      if nv>0 then
	for l:=1 to nv do
	  swap(w[irow,l],w[icol,l])
   end	{ if irow<>icol }
end;	{ gausj3 }

begin		{ procedure gausj2 }
	{ actual start of gaussj }
  error:=false;
  n:=ncol;
  for i:=1 to n do
    index[i,3]:=0;
  determ:=1.0;
  for i:=1 to n do
    begin
    { search for the largest element }
    big:=0.0;
    for j:=1 to n do
      begin
	if index[j,3]<>1 then
	  begin
	    for k:=1 to n do
	     begin
	     if index[k,3]>1 then
	      begin
		writeln(chr(7),'ERROR: matrix is singular');
		error:=true;
		goto 98		{ abort }
	      end;
	if index[k,3]<1 then
	  if abs(b[j,k])>big then
	    begin
	      irow:=j;
	      icol:=k;
	      big:=abs(B[j,k])
 	    end
	   end		{ k-loop }
        end		{ if }
    end;	{ j-loop }
  index[icol,3]:=index[icol,3]+1;
  index[i,1]:=irow;
  index[i,2]:=icol;
    gausj3;		{ further subdivision of gaussj }
			{ divide pivot row by pivot column }
  pivot:=b[icol,icol];
  determ:=determ*pivot;
  b[icol,icol]:=1.0;
  for l:=1 to n do
    b[icol,l]:=b[icol,l]/pivot;
  if nv>0 then
    for l:=1 to nv do
      w[icol,l]:=w[icol,l]/pivot;
  { reduce nonpivot rows }
  for l1:=1 to n do
    begin
      if l1<>icol then
	begin
	  t:=b[l1,icol];
	  b[l1,icol]:=0;
	  for l:=1 to n do
	    b[l1,l]:=b[l1,l]-b[icol,l]*t;
	  if nv>0 then
	    for l:=1 to nv do
	      w[l1,l]:=w[l1,l]-w[icol,l]*t
      end	{ if l1<>icol }
   end		{ for l1 }
  end;	{ i-loop }
98:
end;		{ gausj2 }

begin		{ GAUS-JORDAN main program }
  gausj2;	{ first half of gaussj }
  if error then goto 99;
  { interchange columns }
  for i:=1 to n do
    begin
      l:=n-i+1;
      if index[l,1]<>index[l,2] then
	begin
	  irow:=index[l,1];
	  icol:=index[l,2];
	  for k:=1 to n do
	    swap(b[k,irow],b[k,icol])
	end	{ if index }
  end;		{ i-loop }
for k:=1 to n do
  if index[k,3]<>1 then
    begin
      writeln(chr(7),'ERROR: matrix is singular');
      error:=true;
      goto 99	{ abort }
    end;
99:
end;		{ procedure gaussj }


begin	{ main program }
  first:=true;
  cls;
  writeln;
  revon;
  writeln('Simultaneous solution by Gauss-Jordan');
  writeln('Multiple constant vectors, or matrix inverse');
  revoff;
  repeat
    get_data(a,y,n,nvec);
    if n>1 then
      begin
	gausjv(a,y,determ,n,nvec,error);
	if not error then write_data;
	read(dummy)
	end
  until n<2
end.
