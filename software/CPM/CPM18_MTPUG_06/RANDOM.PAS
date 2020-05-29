module random;	{29}

function random(dummy: integer): real;

{ random number 0-1 }

		{ DEFINE SEED=4.0 AS GLOBAL !!!!!!!! }

{ adapted from HP-35 applications programs }

const
 pi	= 3.14159;

var
 x	: real;
 i	: integer;

begin	{ RANDOM }
 x:=seed+pi;
 x:=exp(5.0*ln(x));
 seed:=x-trunc(x);
 random:=seed
end;		{ RANDOM }

modend.
