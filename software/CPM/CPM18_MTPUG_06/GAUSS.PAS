program gaus;	{ -> 75 }
{ pascal program to perform simultaneous solution by Gaussian elimination }
{ procedure GAUSS is included }

const	maxr	= 8;
	maxc	= 8;

type	ary	= array[1..maxr] of real;
	arys	= array[1..maxc] of real;
	ary2s	= array[1..maxr,1..maxc] of real;

var	y	: arys;
	coef	: arys;
	a	: ary2s;
	n,m	: integer;
	first,
	error	: boolean;

external procedure cls;

procedure get_data(var a: ary2s;
		   var y: arys;
		 var n,m: integer);

{ get values for n and arrays a,y }

var	i,j	: integer;

begin
  writeln;
  repeat
    write('How many equations? ');
    readln(n);
    if not first then cls else first:=false;
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
	  read(y[i]);
	  readln	{ clear line }
	end;
      writeln;
      for i:=1 to n do
	begin
	  for j:=1 to m do
	    write(a[i,j]:7:4);
	  writeln(':',y[i]:7:4)
	end;
     writeln
    end		{ if n>1 }
end;	{ procedure get_data}

procedure write_data;
	{ print out the answeres }

var	i	: integer;

begin
  for i:=1 to m do
    write(coef[i]:9:5);
  writeln
end;		{ write_data }

procedure gauss
	       (a	: ary2s;
		y	: arys;
	    var coef	: arys;
		ncol	: integer;
	    var error	: boolean);

{ matrix solution by Gaussian Elimination }

var
	b	: ary2s;	{ work array, nrow,ncol }
	w	: arys;		{ work array, ncol long }
	i,j,i1,k,
	l,n	: integer;
	hold,sum,
	t,ab,big: real;

begin
  error:=false;
  n:=ncol;
  for i:=1 to n do
    begin	{ copy to work arrays }
      for j:=1 to n do
	b[i,j]:=a[i,j];
      w[i]:=y[i]
    end;
  for i:=1 to n-1 do
    begin
      big:=abs(b[i,i]);
      l:=i;
      i1:=i+1;
      for j:=i1 to n do
	begin		{ search for largest element }
	  ab:=abs(b[j,i]);
	  if ab>big then
	    begin
	      big:=ab;
	      l:=j
	    end
         end;
    if big=0.0 then error:= true
    else
      begin
	if l<>i then
	  begin
	    { interchange rows to put largest element on diagonal }
	    for j:=1 to n do
	      begin
		hold:=b[l,j];
		b[l,j]:=b[i,j];
		b[i,j]:=hold
	      end;
	      hold:=w[l];
	      w[l]:=w[i];
	      w[i]:=hold
	    end;	{ if l<>i }
	  for j:=i1 to n do
	    begin
	      t:=b[j,i]/b[i,i];
	      for k:=i1 to n do
		b[j,k]:=b[j,k]-t*b[i,k];
	      w[j]:=w[j]-t*w[i]
	    end	{ j-loop }
	  end	{ if big }
	end;	{ i-loop }
      if b[n,n]=0.0 then error:=true
      else
	begin
	  coef[n]:=w[n]/b[n,n];
	  i:=n-1;
	  { back substitution }
	  repeat
	    sum:=0.0;
	    for j:=i+1 to n do
	      sum:=sum+b[i,j]*coef[j];
	    coef[i]:=(w[i]-sum)/b[i,i];
	    i:=i-1
	  until i=0
	end;	{ if b[n,n]=0 }
      if error then writeln(chr(7),'ERROR: Matrix is singular')
end;	{ GAUSS }

begin		{ MAIN }
  first:=true;
  cls;
  writeln;
  writeln('Simultaneous solution by Gauss elimination');
  repeat
    get_data(a,y,n,m);
    if n>1 then
      begin
	gauss(a,y,coef,n,error);
	if not error then write_data
      end
  until n<2
end.
