program gausid;		{ -> 129 }
{ pascal program to perform simultaneous solution }
{ by Gauss-Seidel }
{ procedure SEID is included }

const	maxr	= 8;
	maxc	= 8;

type	ary	= array[1..maxr] of real;
	arys	= array[1..maxc] of real;
	ary2s	= array[1..maxr,1..maxc] of real;

var	y	: ary;
	coef	: arys;
	a	: ary2s;
	n,m	: integer;
	first,
	error	: boolean;

external procedure cls;

procedure get_data
	(var a	: ary2s;
	 var y	: ary;
	 var n,m: integer);
{ get values for n and arrays a,y }

var	i,j	: integer;

begin
  writeln;
  repeat
    write('How many equations? ');
    readln(n);
    if first then first:=false else cls
  until n<maxr;
  m:=n;
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
	write(' C:');
	read(y[i]);
	readln		{ clear the line }
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
  else if n<0 then n:=-n;
  m:=n
end;		{ procedure get_data }

procedure write_data;
{ print out the answers }

var	i : integer;

begin
  for i:=1 to m do
    write(coef[i]:9:5);
  writeln
end;		{ write_data }

procedure seid
	(a	: ary2s;
	y	: ary;
	var coef: arys;
	ncol	: integer;
       var error: boolean);
{ matrix solution by Gauss Seidel }

const	tol	= 1.0E-4;
	max	= 100;

var	done	: boolean;
       i,j,k,l,n: integer;

	nextc,hold,
	sum,lambda,
	ab,big	: real;

begin
  repeat
    write('Relaxation factor? ');
    readln(lambda)
  until (lambda<2) and (lambda>0.0);
  error:=false;
  n:=ncol;
  for i:=1 to n-1 do
    begin
      big:=abs(a[i,i]);
      l:=i;
      for j:=i+1 to n do
	begin
	{ search for largest element }
	  ab:=abs(a[j,i]);
	  if ab>big then
	    begin
	      big:=ab;
	      l:=j
	    end
      end;		{ j-loop }
    if big=0.0 then error:=true
    else
      begin
	if l<>i then
	  begin
	  { interchange rows to put }
	  { largest element on diagonal }
	  for j:=1 to n do
	    begin
	      hold:=a[l,j];
	      a[l,j]:=a[i,j];
	      a[i,j]:=hold
	    end;
	  hold:=y[l];
	  y[l]:=y[i];
	  y[i]:=hold
	end	{ if l<>i }
      end	{ if big }
    end;	{ i-loop }
  if a[n,n]=0.0 then error:=true
  else
    begin
      for i:=1 to n do
	coef[i]:=0.0;		{ initial guess }
      i:=0;
      repeat
	i:=i+1;
	done:=true;
	for j:=1 to n do
	  begin
	    sum:=y[j];
	    for k:=1 to n do
	      if j<>k then
		sum:=sum-a[j,k]*coef[k];
	    nextc:=sum/a[j,j];
	    if abs(nextc-coef[j])>tol then
	      begin
		done:=false;
		if nextc*coef[j]<0.0 then
		  nextc:=(coef[j]+nextc)*0.5
	      end;
	    coef[j]:=lambda*nextc+(1.0-lambda)*coef[j];
	    writeln(i:4,',coef(',j,')=',coef[j])
	end		{ j-loop }
      until done or (i>max)
  end;	{ if a[n,n]=0 }
  if i>max then error:=true;
  if error then writeln('ERROR: Matrix is singular')
end;		{ SEID }

begin		{ MAIN program }
  first:=true;
  cls;
  writeln;
  writeln('Simultaneous solution by Gauss-Seidel');
  repeat
    get_data(a,y,n,m);
    if n>1 then
      begin
	seid(a,y,coef,n,error);
	if not error then write_data
      end
  until n<2
end.
