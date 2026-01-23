unit math2sub;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

(***************************************)
(* Copyright (C) 2008, SHIRAISHI Kazuo *)
(***************************************)


interface
uses SysUtils;

const degree:extended=180./pi;
var
   ln2,ln10:extended;

function roundext(x:extended):extended;

function cosh(x:extended):extended;
function sinh(x:extended):extended;
function tanh(x:extended):extended;
function sindeg(x:extended):extended;
function cosdeg(x:extended):extended;
function tandeg(x:extended):extended;
function cotdeg(x:extended):extended;
function secdeg(x:extended):extended;
function cscdeg(x:extended):extended;
function deg(x:extended):extended;
function rad(x:extended):extended;
function asinsub(x,h,j:extended):extended;
function acossub(x,h,j:extended):extended;
function asin(x:extended):extended;
function acos(x:extended):extended;
function angle(x,y:extended):extended;
function ANGLEdeg(x,y:extended):extended;
function random50:extended;
function random52:extended;
procedure InitSeed;
procedure MyRandomize;
procedure MyRandomize2(t:extended);
function MyTime:extended;
function mydate:extended;

implementation
uses
     base,float,mt19937;

const
    c360:extended=360;
    c180:extended=180;
    c90 :extended= 90;

function roundext(x:extended):extended;
assembler;
asm
   fld x
   frndint
end;





function cosh(x:extended):extended;
begin
   cosh:=(exp(x)+exp(-x))/2.0
end;

function sinh(x:extended):extended;
var
   k,i:integer;
   t,t0,s,x1,x2:extended;
begin
    if abs(x)>=1e-1 then
           sinh:=(exp(x)-exp(-x))/2
    else
       begin
           x2:=x*x;
           t:=x;
           s:=x;
           k:=1;
           repeat
             t0:=t;
             s:=s*x2;
             inc(k);
             i:=k;
             inc(k);
             i:=i*k;
             s:=s/i;
             t:=t+s;
           until t=t0;
           sinh:=t;
       end;
end;

function tanh(x:extended):extended;
var
   s,t:extended;
begin
   if x>=1000.0 then
      tanh:=1.0
   else if x<=-1000.0 then
      tanh:=-1.0
   else
      tanh:=sinh(x)/cosh(x);
end;


const pi2:extended=2*pi;
      pihalf:extended=pi/2;
      piquar:extended=pi/4;


function sindeg(x:extended):extended;
begin
    if x<0 then
                 sindeg:=-sindeg(-x)
    else if x>=c360 then
                 sindeg:=sindeg(x-int(x/c360) * c360)
    else if x>c90 then
                 sindeg:=sindeg(c180-x)
    else
                 sindeg:=system.sin(x/degree)
end;

function cosdeg(x:extended):extended;
begin
    cosdeg:=sindeg(x+c90)
end;


function tandeg(x:extended):extended;
begin
    tandeg:=sindeg(x)/cosdeg(x);
end;



function cotdeg(x:extended):extended;
begin
    cotdeg:=cosdeg(x)/sindeg(x);
end;




function secdeg(x:extended):extended;
begin
   secdeg:=1/cosdeg(x);
end;

function cscdeg(x:extended):extended;
begin
   cscdeg:=1/sindeg(x);
end;


function deg(x:extended):extended;
begin
    deg:=x*(180/pi);
end;


function rad(x:extended):extended;
begin
    rad:=x*(pi/180)
end;

function asinsub(x,h,j:extended):extended;
                    { h=1-x,j=1+x}
var
   y:extended;
begin
   if h=0 then
       y:=pi/2
   else if j=0 then
       y:=-pi/2
   else if (h>0) and (j>0) then
       y:=arctan(x/sqrt(h*j))
   else
       begin
         setexceptionwith('ASIN',3007);
         y:=0;
       end;
   asinsub:=y;
end;

function acossub(x,h,j:extended):extended;
                    { h=1-x,j=1+x}
var
  y:extended;
begin
  if h>=0.1 then
        acossub:=pi/2-asinsub(x,h,j)
  else if h>=0 then
     begin
        //j:=1+x;
        y:=arctan(sqrt(h*j)/x);
        acossub:=y;
     end
  else
     begin
          setexceptionwith('ACOS',3007);
          acossub:=0;
     end;
end;


function asin(x:extended):extended;
begin
     asin:=asinsub(x,1-x,1+x)
end;

function acos(x:extended):extended;
begin
     acos:=acossub(x,1-x,1+x)
end;


function angle(x,y:extended):extended;
var
    z:extended;
begin
    if x>0 then
          z:=arctan(y/x)
    else if (x<0) and (y>0) then
          z:=arctan(y/x)+pi
    else if (x<0) and (y<>0) then
          z:=arctan(y/x)-pi
    else if (x<0) and (y=0) then
          z:=pi
    else if (x=0) and (y>0) then
          z:=pi/2
    else if (x=0) and (y<0) then
          z:=-pi/2
    else    {無効演算}
         inValidOperation;

    angle:=z
end;

function ANGLEdeg(x,y:extended):extended;
begin
    result:=angle(x,y)*degree
end;



{***********}
{Date & Time}
{***********}

const
    DaysOfMonth:array[1..12] of word =(31,28,31,30,31,30,31,31,30,31,30,31);

function mydate:Extended;
var
   y,m,d,w:word;
   leap:boolean;
   i:integer;
begin
   decodedate(date,y,m,d);
   leap:= (y mod 4 = 0) and((y mod 100 <>0) or (y mod 400=0))  ;
   y:=y mod 100;
   for i:=1 to m-1 do d:=d+daysofmonth[i];
   if (m>2) and leap then inc(d);
   mydate:=longint(1000)*y +d
end;

function MyTime:extended;
var
   t:double;
begin
   t:=time;
   t:=t-INT(t);
   result:=RoundExt(t*8640000)/100.;
end;

{**************}
{Random Numbers}
{**************}

function random53:extended; //resolution 53bit
begin
  result:=((Int64(genrand_int32 shr 5) shl 26)+(genrand_int32 shr 6))
           *(1.0/9007199254740992.0);
end;

function random52:extended; //resolution 52bit
begin
  result:=((Int64(genrand_int32 shr 5) shl 25)+(genrand_int32 shr 7))
           *(1.0/4503599627370496.0);
end;

function random50:extended; //resolution 50bit
begin
  result:=((Int64(genrand_int32 shr 5) shl 23)+(genrand_int32 shr 9))
           *(1.0/1125899906842624.0);
end;

procedure InitSeed;
begin
  init_genrand(19650218);
end;

procedure MyRandomize;
var
  x:extended;
begin
    x:=MyDate;
    x:=x-1000*int(x/1000);
    init_genrand(System.round((x*86400+mytime)*100)+1);
    x:=random50;    //乱数を1個捨てる
end;


procedure MyRandomize2(t:extended);
var
   c:cardinal;
begin
   try
      c:=System.Trunc(t);
      init_genrand(c);
   except
   end;
end;



initialization
   ln2:=ln(2);
   ln10:=ln(10);
finalization
end.
