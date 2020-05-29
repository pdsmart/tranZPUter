program means;		{ -> 26 }
{find mean and standard deviation }

const	max	= 80;

type	ary 	= array[1..max]of real;

var	x	: ary;
	i,n	: integer;
	mean,std: real;

external procedure cls;

procedure meanstd
		(x		: ary;	{array of values}
		 length		: integer;
		 var mean	: real;
		 var std_dev	: real);

var
		i		: integer;
		sum_x,sum_sq	: real;



begin {main}
 sum_x:=0;
 sum_sq:=0;
 for i:=1 to length do
	begin
	 sum_x:=sum_x+x[i];
	 sum_sq:=sum_sq+x[i]*x[i]
	end;
 mean:=sum_x/length;
 std_dev:=sqrt((sum_sq-sqr(sum_x)/length)/(length-1))
end	{ procedure meanstd };

begin	{ MAIN program }
 cls;
 writeln;
 writeln('Calculation of mean and standard deviation');
 repeat
	write('How many points? ');
	readln(n)
 until n<=max;
 for i:=1 to n do
	begin
	 write(i:3,':');
	 readln(x[i])
	end;
 meanstd(x,n,mean,std);
 writeln(chr(7),'For ',n:3,' points, mean= ',mean:8:4,' sigma= ',std:8:4)
end.	{ MAIN program }
