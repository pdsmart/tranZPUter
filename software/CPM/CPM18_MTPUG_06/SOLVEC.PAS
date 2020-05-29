program solvec;		{ -> 119 }
{ pascal program to perform simultaneous solution by Gauss-Jordan elimination}
{ for complex coefficients }

const	maxr	= 8;
	maxc	= 8;

type	ary	= array[1..maxr] of real;
	arys	= array[1..maxc] of real;
	ary2s	= array[1..maxr,1..maxc] of real;
	aryc2	= array[1..maxr,1..maxc,1..2] of real;
	aryc	= array[1..maxr,1..2] of real;

var	y	: arys;
	coef	: arys;
	a,b	: ary2s;
	n,m,i,j	: integer;
	error	: boolean;

external procedure cls;
external procedure revon;
external procedure revoff;



procedure get_data(var a: ary2s;
		   var y: arys;
		   var n,m: integer);

{ get complex values for n and arrays a,y }

var	c	: aryc2;
	v	: aryc;
	i,j,k,l	: integer;

procedure show;
	{ print original data }
var	i,j,k	: integer;

begin	{ show }
  writeln;
  for i:=1 to n do
    begin
      for j:=1 to m do
	for k:=1 to 2 do
	  write(c[i,j,k]:7:4,' ');
      writeln(':',v[i,1]:7:4,':',v[i,2]:7:4)
    end;
  n:=2*n;
  m:=n;
  writeln;
  for i:=1 to n do
    begin
      for j:=1 to m do
	write(a[i,j]:7:4,' ');
      writeln(':',y[i]:9:5)
    end;
  writeln
end;		{ show }

begin		{ procedure get_data }
  writeln;
  repeat
    write('How many equations? ');
    readln(n);
    m:=n
  until n<maxr;
  if n>1 then
    begin
      for i:=1 to n do
	begin
	  writeln('Equation',i:3);
	  k:=0;
	  l:=2*i-1;
	  for j:=1 to n do
	    begin
	      k:=k+1;
	      write('Real',j:3,':');
	      read(c[i,j,1]);		{ read real part }
	      a[l,k]:=c[i,j,1];
	      a[l+1,k+1]:=c[i,j,1];
	      k:=k+1;
	      write('Imag',j:3,':');
	      read(c[i,j,2]);		{ imaginary part }
	      a[l,k]:=-c[i,j,2];
	      a[l+1,k-1]:=c[i,j,2]
	    end;		{ j-loop }
	  write('Real const:');
	  read(v[i,1]);		{ real constant }
	  y[l]:=v[i,1];
	  write('Imag const:');
	  readln(v[i,2]);	{ imag constant }
	  y[l+1]:=v[i,2]
	end;		{ i-loop }
      show		{ the original DATA }
    end		{ if n>1 }
end;	{ procedure get_data }


procedure write_data;

{ print out the answers }

var	i,j	: integer;
	re,im	: real;

function mag(x,y: real): real;
{ polar magnitude }
begin
  mag:=sqrt(sqr(x)+sqr(y))
end;	{ function mag }

function atan(x,y: real): real;
{ arctan in degrees }
const pi180 = 57.2957795;
var	  a : real;

begin	{ atan }
  if x=0.0 then
    if y=0.0 then atan:=0.0
    else atan:=90.0
  else	{ x<>0 }
    if y=0.0 then atan:=0.0
  else { x and y <>0 }
    begin
      a:=arctan(abs(y/x))*pi180;
      if x>0.0 then
	if y>0.0 then atan:=a	{ x,y>0 }
	else atan:=-a		{ x>0, y<0 }
      else		{ x<0 }
	if y>0.0 then atan:=180.0-a	{ x<0, y>0 }
	else atan:=180.0+a		{ x,y<0 }
  end		{ else }
end;	{ function atan }
begin
  writeln('   REAL    Imaginary  Magnitude Angle');
  for i:=1 to (m div 2) do
    begin
      j:=2*i-1;
      re:=coef[j];
      im:=coef[j+1];
      writeln(re:11:5,im:11:5,mag(re,im):11:5,atan(re,im):11:5)
    end;	{ for }
   writeln
end;		{ write_data }



{external procedure gaussj
 (var		b : ary2s;
		y : arys;
  var	     coef : arys;
	     ncol : integer;
  var	    error : boolean);}

{$I C:GAUSSJ.LIB}

begin		{ MAIN program }
  cls;
  writeln;
  writeln;
  revon;
  writeln('Simultaneous solution with complex coefficients');
  writeln('by Gauss-Jordan elimination');
  revoff;
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
