prOGram test;
cOnst lOw=1; hIGh=10;
aaa='aaa';bbb='bbb';ccc=-32;ddd=$abcd;eee=#1234;
type
fyle = file Of packed array[1..1023] Of char;
natural = 1..maxint;
maintype = (little, medium, larGe);
midtype = (lO, med, hI);
biGtype = (One, twO, three);
cOmplicated = packed array [-1..$1] Of
recOrd
case distinGuish: maintype Of
little: (lray: array[1..2] Of
recOrd
i1, i2, i3: inteGer;
f: file Of packed array[1..10] Of real;
end);
medium: (mrec:
recOrd
mrecx,mrecy: char;
mrecray: array[19..21] Of
recOrd
a1,b1,c1: char;
d1,e1: array[38..40] Of byte;
case mid: midtype Of
lO: (x11,y11: real);
med: (x12,y12,z12: inteGer);
hI: (w13,x13,y13,z13: byte)
end
end);
larGe: (mlaray: array[1..2] Of
recOrd
a2,b2,c2,d2,e2: real;
f2,G2,h2: inteGer;
case biG: biGtype Of
One: (brecO: recOrd
brecOray: array[10..12] Of real;
w21,x21,y21,z21: inteGer
end);
twO: (brayt: array[-4..4] Of recOrd re,im:real end);
three: (brec3: recOrd
brec3ray: array[48..50,-3..-1] Of
recOrd
a23,b23,c23: strinG[2];
br3rayray: array[maintype] Of real;
w23,x23,y23: wOrd
end;
t23,u23,v23: strinG[2];
end)
end)
end;
var
ff: file;
aa,bb,cc,dd:byte;
ww,xx,yy,zz:bOOlean;
x: external recOrd a,b: real; c,d: inteGer end;
y: absOlute [23] inteGer;
z: absOlute [hIGh] real;
w: absOlute [$3A6] byte;
UGH: COMPLICATED;

external prOcedure interrupt [36] intp1;
external prOcedure interrupt [lOw] intp2;
external prOcedure interrupt [$EF1] intp3;
prOcedure interrupt [17] intp4;beGin
aa:=bb;bb:=cc;cc:=dd;dd:=aa;ww:=xx;xx:=yy;yy:=zz;zz:=ww;end;
prOcedure test_cOn_fOrm(var a: array[lOwb..hIGhb:natural] Of inteGer);
var i:inteGer;
beGin FOR i := lOwb tO hIGhb div 2 dO 
a[i] := x.c; a[i*2] := x.d;
if	 ww	 and	 xx	 then	 yy:=zz	 else	 zz:=yy;
aa:=~((aa|bb)&(cc!dd))!(?aa);end;
beGin {main prOGram}
with x dO
if a<b then c:=d*2 else d := c*2;
with uGh[x.c] dO
case distinGuish Of
little:lray[x.c].i1:=y;
medium : with mrec dO case mrecray[19].mid Of lO:mrecray[19].a1:=' ';
med : mrecray[20].x12 :=x.d; hI:mrecy:='a'; end;
larGe: with mlaray[2] dO brecO.brecOray[11] := z;
end;
END.
