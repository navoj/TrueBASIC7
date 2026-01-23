unit math3;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}
(***************************************)
(* Copyright (C) 2003, SHIRAISHI Kazuo *)
(***************************************)


{$DEFINE double}
{$N+}


interface
uses SysUtils,Math,
    variabl,arithmet;

procedure powerHP(var a,b:Number; var x:Number);


implementation
uses
    base,float,struct,express,
    texthand,confopt,helpctex,graphic,math2sub,sconsts;

{*******}
{Classes}
{*******}

{********************}
{Indivisual functions}
{********************}

{*************}
{Trigonometric}
{*************}


type
  MinimalNumber  = object
                 places:LongInt;      {length in words} {1place=10000}
                 sign:  shortint;
                 tag:   byte;
                 expn:  smallint;
                 frac:  array[1..1] of LongInt;
  end;

  ShortNumber1  = object(ShortNumber)
                    fracEx: LongInt;
    end;

  ShortNumber2  = object(ShortNumber)
                    fracEx: array[1..2]of  LongInt;
    end;

  ShortNumber36  = object(ShortNumber)
                   fracEx: array[1..36]of  LongInt;
    end;


  accuratenumber  = object
                  places:LongInt;      {length in words} {1place=10000}
                  sign:  shortint;
                  tag:   byte;
                  expn:  smallint;
                  frac:  array[1..highprecision+1] of LongInt;
    end;

const
  constHalfPI:accuratenumber =(places:Highprecision+1; sign:1; tag:1; expn:1 ;
        frac: (1,570796326,794896619,231321691,639751442,098584699,
                 687552910,487472296,153908203,143104499,314017412,
                 671058533,991074043,256641153,323546922,304775291,
                 115862679,704064240,558725142,051350969,260552779,
                 822311474,477465190,982214405,487832966,723064237,
                 824116893,391582635,600954572,824283461,730174305,
                 227163324,106696803,630124570,636862293,503303157,
                 794087440,760460481,414627045,857682183,946295180,
                 005665265,274410233,260692073,475970755,804716528,
                 635182879,795976546,093058690,966305896,552559274,
                 037231189,981374783,675942876,362445613,969091505,
                 974564916,836681220,328321543,010697473,197612368,
                 595351089,930471851,385269608,588146588,376192337,
                 409233834,702566000,284063572,631780413,892885671,
                 378894804,586818589,360734220,450612476,715073274,
                 792685525,396139844,629461771,009978056,064510980,
                 432017209,079906814,887385654,980259353,605674999,
                 999186489,024975529,865866408,048159297,512229727,
                 673454151,321261154,126672342,517630965,594085505,
                 001568919,376443293,766604190,710308588,834573651,
                 799126745,214377734,365579781,431941176,893796875,
                 978890928,890266085,613403306,500963938,305597954,
                 608210099,469047628));

   constHalfPIDiff:accuratenumber =(places:Highprecision+1; sign:1; tag:1; expn:-112 ;
        frac:  ( 600532742,931639432,968076690,913984115,150976017,
                 650926484,497886811,299706945,624860887,641739565,
                 757787428,621227075,347975414,766558430,863927944,
                 537549190,877318732,469659627,530200463,850835569,
                 504924412,006429180,801781853,830052355,090971477,
                 798099473,383918724,724127689,887363423,552023767,
                 323104023,342129534,745646656,838514494,576052376,
                 081028483,012029019,075096755,626691215,017793820,
                 123748236,631957099,636302134,961398391,177390818,
                 004670860,820609962,293157515,143091487,277853374,
                 919252747,294293463,497845463,605398754,651477660,
                 582672493,601377980,118240332,749559940,917398876,
                 783184903,713271263,931275909,208787336,445488886,
                 396900040,823530008,072624596,086608607,386175070,
                 720986784,274080680,578676276,066737870,924734219,
                 261661953,697071667,273881208,431259491,784742781,
                 049609611,092136275,127128443,835895247,300826733,
                 402494313,616395893,042892191,413983988,340727050,
                 476941893,180475340,032112562,602558696,492448042,
                 064244313,472802120,982642511,105330593,153372139,
                 311019597,472523561,856893480,478182185,958643733,
                 882328786,981206945,432916322,997906695,239013795,
                 049732882,039475634,723419917));


var  HalfPI:PNumber;



procedure shrink(const n:number; var y:number; var i:longint);
var
   c:integer;
   sign:integer;
   x,q,xx:number;
   //svprecision,svlimit:integer;
   cont:boolean;
begin
    //svprecision:=precision;
    //svlimit:=limit;
    //precision:=HighPrecision+1;
    //limit:=precision+1;
    sign:=1;
    x.init(@n);
    if arithmet.sgn(@x)<0 then begin arithmet.oppose(x); sign:=-1 end;
    divide(x,halfpi^,q,x);
    i:=longintval(q,c);
    while c<>0 do
        begin
            initinteger(xx,4);
            remainder(q,xx,q);
            i:=longintval(q,c)
        end;

    if (i and 1)<>0 then arithmet.sbt(halfpi^,x,x);
    if sign<0 then
         arithmet.oppose(x);
    y.init(@x);

    //precision:=svprecision;
    //limit:=svlimit;
end;

procedure ComplementaryAngle(var a:Number; var x:Number);
//var
//   svprecision,svlimit:integer;
 begin
//   svprecision:=precision;
//   svlimit:=limit;
//   precision:=HighPrecision+1;
//   limit:=precision+1;

    arithmet.sbt(Pnumber(@constHalfPi)^,a,x);
    arithmet.add(x, PNumber(@constHalfPIDiff)^,x);

//   precision:=svprecision;
//   limit:=svlimit;
end;

const
  const1E1008: MinimalNumber = (places:1; sign:1; tag:1; expn:112; frac:(100000000)); {1E1008}
var
   con1E1008:Pnumber;

function SINsub(x:Number):Number;
var
   i,n:integer;
   t,nn,x2:Number;
   a:array[1..240]of Number;
begin
   arithmet.mlt(x,x,x2);
   n:=1;
   arithmet.mlt(x,con1e1008^,a[n]);
   while  (n<240) and (a[n].sign<>0) and (a[n].expn>=0) do
   begin
      initinteger(nn,2*n);
      initinteger(t,2*n+1);
      arithmet.mlt(nn,t,nn);
      arithmet.mlt(a[n],x2,a[n+1]);
      inc(n);
      arithmet.qtt(a[n],nn,a[n]);
      arithmet.oppose(a[n]);
   end;

   t.initzero;
   for i:=n downto 1 do
       arithmet.add(t,a[i],t);
   arithmet.qtt(t,con1e1008^,result)
end;

function COSsub(x:Number):Number;
var
   i,n:integer;
   t,nn,x2:Number;
   a:array[1..240]of Number;
begin
   arithmet.mlt(x,x,x2);
   n:=1;
   a[n]:=con1e1008^;
   while (n<240) and (a[n].sign<>0) and (a[n].expn>=0) do
   begin
      initinteger(nn,2*n-1);
      initinteger(t,2*n);
      arithmet.mlt(nn,t,nn);
      arithmet.mlt(a[n],x2,a[n+1]);
      inc(n);
      arithmet.qtt(a[n],nn,a[n]);
      arithmet.oppose(a[n]);
   end;

   t.initzero;
   for i:=n downto 1 do
       arithmet.add(t,a[i],t);
   arithmet.qtt(t,con1e1008^,result)
end;

function cos_core(x:Number):Number;forward;
function sin_core(x:Number):Number;    {-pi/2=<x<=pi/2}
var
   y,z:Number;
begin
   if x.sign<0 then
      begin
          arithmet.oppose(x);
          result:=sin_core(x);
          arithmet.oppose(result);
      end
   else   {x>=0}
      begin
          //arithmet.sbt(halfPI^,x,y);
          ComplementaryAngle(x,y);
          if arithmet.compare(x,y)>0 then
             result:=cossub(y)
          else
            result:=sinsub(x)
      end;
end;

function cos_core(x:number):Number;
var
   y,z:Number;
begin
   if x.sign<0 then
      begin
          arithmet.oppose(x);
          result:=cos_core(x);
      end
   else   {x>=0}
      begin
          //arithmet.sbt(HalfPI^,x,y);
          ComplementaryAngle(x,y);
          if arithmet.compare(x,y)>0 then
             result:=sinsub(y)
          else
            result:=cossub(x)
      end;
end;

function sinrad(var x:number):Number;
var
   y:Number;
   i:longint;
begin
   shrink(x,y,i);
   result:=sin_core(y);
   if (i and 2)<>0 then
      arithmet.oppose(result)
end;


function cosrad(var x:number):Number;
var
   y:number;
   i:longint;
begin
   shrink(x,y,i);
   result:=cos_core(y);
   dec(i);
   if (i and 2)=0 then
       arithmet.oppose(result)
end;


function tanrad(var x:number):Number;
var
   y,z:Number;
begin
   y:=sinrad(x);
   z:=cosrad(x);
   arithmet.qtt(y,z,result);
   //TestExtended(result,'TAN',1003,1003);
end;

function cotrad(var x:number):Number;
var
   y,z:Number;
begin
   y:=sinrad(x);
   z:=cosrad(x);
   arithmet.qtt(z,y,result);
   //TestExtended(result,'COT',1003,1003);
end;

function cscrad(var x:number):Number;
var
   y:Number;
begin
    y:=sinrad(x);
    arithmet.qtt(arithmet.one^,y,result);
    //TestExtended(result,'CSC',1003,1003);
end;

function secrad(var x:number):Number;
var
   y:Number;
begin
    y:=cosrad(x);
    arithmet.qtt(arithmet.one^,y,result);
    //TestExtended(result,'SEC',1003,1003);
end;

type
  NumberFunction = function (var n:number):Number;

function GetValue(f:NumberFunction; n:Number):Number;
var
    svprecision,svlimit:integer;
begin
    svprecision:=precision;
    svlimit:=limit;
    precision:=HighPrecision+1;
    limit:=precision+1;
    try
      result:=f(n);
    finally
      precision:=svprecision;
      limit:=svlimit;
    end;
    RoundPrecision(result)
end;

procedure NSinRad(var n:number);
begin
    //n:=sinrad(n);
   n:=getvalue(sinrad,n)
end;

procedure NCosRad(var n:number);
begin
   // n:=cosrad(n);
   n:=getvalue( cosrad,n)
end;

procedure NTANRad(var n:number);
begin
   // n:=TANrad(n);
   n:=getvalue(TANrad,n)
end;

procedure NSECRad(var n:number);
begin
   // n:=secrad(n);
   n:=getvalue(secrad,n)
end;

procedure NCSCRad(var n:number);
begin
   // n:=cscrad(n);
   n:=getvalue(cscrad,n)
end;

procedure NCOTrad(var n:number);
begin
   // n:=COTrad(n);
   n:=getvalue(cotrad,n)
end;

function rad(var n:Number):Number;
var
    t180:Number;
begin
   initinteger(t180,180);
   arithmet.mlt(n,decimalPi^,result);
   arithmet.qtt(result,t180,result);
end;

function deg(var n:Number):Number;
var
    t180:Number;
begin
   initinteger(t180,180);
   arithmet.qtt(n,decimalPi^,result);
   arithmet.mlt(result,t180,result);
end;

procedure NRad(var n:Number);
begin
   n:=getvalue(rad,n)
end;

procedure NDeg(var n:Number);
begin
   n:=getvalue(deg,n)
end;

function DEGfnc:TPrincipal;
begin
    DEGfnc:=Unary(Ndeg,nil,1003,'DEG')
end;

function RADfnc:TPrincipal;
begin
    RADfnc:=Unary(NRad,nil, 1003,'RAD')
end;

const
  const90: MinimalNumber = (places:1; sign:1; tag:1; expn:1; frac:(90));

procedure shrink90(const n:number; var y:number; var i:longint);
var
   c:integer;
   sign:integer;
   x,q,xx:number;
   cont:boolean;
begin
    sign:=1;
    x.init(@n);
    if arithmet.sgn(@x)<0 then begin arithmet.oppose(x); sign:=-1 end;
    divide(x,PNumber(@const90)^,q,x);
    i:=longintval(q,c);
    while c<>0 do
        begin
            initinteger(xx,4);
            remainder(q,xx,q);
            i:=longintval(q,c)
        end;

    if (i and 1)<>0 then arithmet.sbt(PNumber(@const90)^,x,x);
    if sign<0 then
         arithmet.oppose(x);
    y.init(@x);
 end;

function sindeg(var n:Number):Number;
var
   t:Number;
var
   y:Number;
   i:longint;
begin
   shrink90(n,y,i);
   t:=rad(y);
   result:=sin_core(t);
   if (i and 2)<>0 then
      arithmet.oppose(result)
end;

procedure NSinDeg(var n:number);
begin
   n:=getvalue(sindeg,n)
end;

function cosdeg(var n:Number):Number;
var
   t:Number;
   y:number;
   i:longint;
begin
   shrink90(n,y,i);
   t.init(@y);
   arithmet.absolute(t);
   if arithmet.compare(t,Pnumber(@const90)^)=0 then
      result.initzero
   else
     begin
       t:=rad(y);
       result:=cos_core(t);
       dec(i);
       if (i and 2)=0 then
              arithmet.oppose(result)
    end;
end;

procedure NCosDeg(var n:number);
begin
   n:=getvalue(cosdeg,n)
end;

function TANdeg(var n:Number):Number;
var
   t:Number;
begin
   result:=SinDeg(n);
   t:=CosDeg(n);
   arithmet.qtt(result,t,result);
end;

procedure NTANDeg(var n:number);
begin
   // n:=TANrad(n);
   n:=getvalue(TANdeg,n)
end;

function secdeg(var n:Number):Number;
begin
   result:=cosdeg(n);
   arithmet.qtt(arithmet.one^,result,result);
end;

procedure NSECDeg(var n:number);
begin
   // n:=secrad(n);
   n:=getvalue(secdeg,n)
end;

function cscdeg(var n:Number):Number;
begin
   result:=sindeg(n);
   arithmet.qtt(arithmet.one^,result,result);
end;

procedure NCSCDeg(var n:number);
begin
   // n:=cscrad(n);
   n:=getvalue(cscdeg,n)
end;

function cotdeg(var n:Number):Number;
var
   t:Number;
begin
   result:=CosDeg(n);
   t:=SinDeg(n);
   arithmet.qtt(result,t,result);
end;

procedure NCOTDeg(var n:number);
begin
   // n:=COTrad(n);
   n:=getvalue(cotdeg,n)
end;

function SINfnc:TPrincipal;
begin
    if confirmedDegrees then
         SINfnc:=Unary(Nsindeg,nil,1003,'SIN')
    else
         SINfnc:=Unary(Nsinrad,nil,1003,'SIN')
end;

function COSfnc:TPrincipal;
begin
    if confirmedDegrees then
         COSfnc:=Unary(Ncosdeg,nil,1003,'COS')
    else
         COSfnc:=Unary(Ncosrad,nil,1003,'COS')
end;

function TANfnc:TPrincipal;
begin
    if confirmedDegrees then
         TANfnc:=Unary(Ntandeg,nil,1003,'TAN')
    else
         TANfnc:=Unary(Ntanrad,nil,1003,'TAN')
end;

function CSCfnc:TPrincipal;
begin
    if confirmedDegrees then
         CSCfnc:=Unary(NCSCdeg,nil,1003,'CSC')
    else
         CSCfnc:=Unary(NCSCrad,nil,1003,'CSC')
end;

function SECfnc:TPrincipal;
begin
    if confirmedDegrees then
         SECfnc:=Unary(Nsecdeg,nil,1003,'SEC')
    else
         SECfnc:=Unary(Nsecrad,nil,1003,'SEC')
end;

function COTfnc:TPrincipal;
begin
    if confirmedDegrees then
         COTfnc:=Unary(Ncotdeg,nil,1003,'COT')
    else
         COTfnc:=Unary(Ncotrad,nil,1003,'COT')
end;

{*********************}
{inverse trigonometric}
{*********************}



function asinN(var n:number):double;
var
  h,j:number;
begin
  arithmet.sbt(one^,n,h);
  arithmet.add(one^,n,j);
  asinN:=asinsub(extendedval(n),extendedval(h),extendedval(j))
end;

function acosN(var n:number):double;
var
  h,j:number;
begin
  arithmet.sbt(one^,n,h);
  arithmet.add(one^,n,j);
  acosN:=acossub(extendedval(n),extendedval(h),extendedval(j))
end;


function ASIN_Newton(var n:Number):Number;
var
   i:integer;
   t,tt,f0,f1,g0,t0,e:Number;
begin
   convert(asinN(n),t);
   for i:=1 to 1000 do
      begin
        f0:=sin_core(t);
        g0:=cos_core(t);
        arithmet.sbt(f0,n,f1);
        arithmet.qtt(f1,g0,t0);
        arithmet.sbt(t,t0,tt);
        arithmet.absolute(f1);
        e:=f1;
        arithmet.epsnative(e);
        if arithmet.compare(f1,e)<=0 then
           break;
        // if iszero(@f1) then  break;
        t:=tt
      end;
   result:=tt;
end;

function ACOS_Newton(var n:Number):Number;
var
   i:integer;
   t,tt,f0,f1,g0,t0,e:Number;
begin
   convert(acosN(n),t);
   for i:=1 to 1000 do
      begin
        f0:=cos_core(t);
        g0:=sin_core(t);
        arithmet.oppose(g0);
        arithmet.sbt(f0,n,f1);
        arithmet.qtt(f1,g0,t0);
        arithmet.sbt(t,t0,tt);
        arithmet.absolute(f1);
        e:=f1;
        arithmet.epsnative(e);
        if arithmet.compare(f1,e)<=0 then break;
        t:=tt
      end;
   result:=tt;
end;

{
function ACOS_sub(Var n:Number):Number;  //nが1に近いとき
var
   t,t2:Number;
begin
   t.initone;
   arithmet.sbt(t,n,t);  //t=1-n
   initinteger(t2,2);
   arithmet.mlt(t,t2,t);
   arithmet.sqrlong(t);
   result:=t;
end;
}
function ACOS_sub(Var n:Number):Number;  //nが1に近いとき
var
   t,t1,t2,c6,c12,c24:Number;
begin
   initinteger(c6,6);
   initinteger(c12,12);
   initinteger(c24,24);
   arithmet.mlt(c24,n,t);
   arithmet.add(t,c12,t);  //t=24n+12
   sqrlong(t);            //t=√(24n+12)
   arithmet.add(c6,t, t);   //t=6+√(24n+12)
   arithmet.sbt(arithmet.one^,n,t1);
   arithmet.mlt(c24,t1,t1);  //t1:=24(1-n)
   arithmet.qtt(t1,t,result);
   sqrlong(result)           //ACOS_sub=√(t1/t)
end;

function ASINrad(var n:Number):Number;

const  constNearly1: ShortNumber36 = (places:39; sign:1; tag:1; expn:0;
                        frac:(999999999,999999999,999999999);
                      fracEx:(999999999,999999999,999999999,
                              999999999,999999999,999999999,
                              999999999,999999999,999999999,
                              999999999,999999999,999999999,
                              999999999,999999999,999999999,
                              999999999,999999999,999999999,
                              999999999,999999999,999999999,
                              999999999,999999999,999999999,
                              999999999,999999999,999999999,
                              999999999,999999999,999999999,
                              999999999,999999999,999999999,
                              999999999,999999999,999999999));
var
  t:Number;
begin
  if n.sign<0 then
     begin
       arithmet.oppose(n);
       result:=ASINrad(n);
       arithmet.oppose(result)
     end
  else  {n>=0}
     begin
         if arithmet.compare(n,arithmet.one^)>0 then
           setexception(3007);

         if arithmet.compare(n,PNumber(@constNearly1)^)>=0 then
           begin
             t:=ACOS_sub(n);
             //arithmet.sbt(halfPi^,t,result)
             ComplementaryAngle(t,result);
           end
        else
           result:=ASIN_Newton(n);
     end;
end;


function ACOSrad(var n:Number):Number;
const
    const1Em300: MinimalNumber = (places:1; sign:1; tag:1; expn:-33; frac:(1000000)); {1e-300}
var
  t,t1:Number;
begin
  t:=n;
  arithmet.absolute(t);
  t1.initone;
  if arithmet.compare(t,t1)>0 then
      setexception(3007);

  arithmet.sbt(t1, PNumber(@const1Em300)^, t1);
  if arithmet.compare(t,t1)>=0 then
           begin
             result:=ACOS_sub(t);
             if n.sign<0 then
               arithmet.sbt(decimalPi^,result,result)
           end
        else
           begin
              //result:=ACOS_Newton(n);
              t:=ASIN_Newton(n);
              //arithmet.sbt(halfPi^,t,result)
              ComplementaryAngle(t,result);
           end;

end;

function ATNrad(var n:Number):Number;
var
  t,t1:Number;
begin
  t1.initone;
  arithmet.mlt(n,n,t);
  arithmet.add(t,t1,t);
  sqrlong(t);
  arithmet.qtt(n,t,t);
  result:=ASINrad(t);
end;

procedure NASIN(var n:number);
begin
   // convert(ASINN(n),n);
   n:=getvalue(ASINrad,n)
end;

procedure NACOS(var n:number);
begin
   // convert(ACOSN(n),n);
   n:=getvalue(ACOSrad,n)
end;


procedure NATN(var n:number);
begin
   // convert(ACOSN(n),n);
   n:=getvalue(ATNrad,n)
end;

function ASINdeg(var n:number):number;
begin
    result:=ASINrad(n);
    result:=deg(result);
end;

function ACOSdeg(var n:Number):Number;
begin
  result:=ACOSrad(n);
  result:=deg(result);
end;

function ATNdeg(var n:Number):Number;
begin
  result:=ATNrad(n);
  result:=deg(result);
end;

procedure NASINdeg(var n:number);
begin
   n:=getvalue(ASINdeg,n)
end;

procedure NACOSdeg(var n:number);
begin
   n:=getvalue(ACOSdeg,n)
end;

procedure NATNdeg(var n:number);
begin
   n:=getvalue(ATNdeg,n)
end;



function ASINfnc:TPrincipal;
begin
    if confirmedDegrees then
      ASINfnc:=Unary(NASINdeg,nil,3007,'ASIN')
    else
      ASINfnc:=Unary(NASIN,nil,3007,'ASIN')
end;

function ACOSfnc:TPrincipal;
begin
    if confirmedDegrees then
      ACOSfnc:=Unary(NACOSdeg,nil,3007,'ACOS')
    else
      ACOSfnc:=Unary(NACOS,nil,3007,'ACOS')
end;


function ATNfnc:TPrincipal;
begin
    if confirmedDegrees then
      ATNfnc:=Unary(NATNdeg,nil,1003,'ATN')
    else
      ATNfnc:=Unary(NATN,nil,1003,'ATN')
end;

{
function NAngle_sub(x,y:Number):Number;    //asin version
var
  t,x2,y2:Number;
begin
  arithmet.mlt(x,x,x2);
  arithmet.mlt(y,y,y2);
  arithmet.add(x2,y2,t);
  sqrlong(t);
  arithmet.qtt(y,t,t);
  result:=ASINrad(t);
end;

procedure NAngle(var x,y:Number; var z:Number);
var
  signx,signy:shortint;
begin
  signx:=x.sign;
  signy:=y.sign;
   z:=NAngle_sub(x,y);
   if signx<0 then
      if signy>=0 then
         arithmet.sbt(decimalPi^,z,z)
      else
        begin
         arithmet.add(decimalPi^,z,z);
         arithmet.oppose(z);
        end;
end;
}

type
  NumberRoutine=procedure(var x,y:Number; var z:Number);

procedure CarryOutHP(f:NumberRoutine; var x,y:Number; var z:Number);
var
  svprecision,svlimit:integer;
begin
   svprecision:=precision;
   svlimit:=limit;
   precision:=HighPrecision+1;
   limit:=precision+1;
   try
     f(x,y,z)
   finally
     precision:=svprecision;
     limit:=svlimit;
   end;
  RoundPrecision(z)
 end;

procedure NAngle_sub(var x,y:Number; var z:Number);     //acos version
var
  signy:smallint;
  t,x2,y2:Number;
begin
  signy:=y.sign;

  arithmet.mlt(x,x,x2);
  arithmet.mlt(y,y,y2);
  arithmet.add(x2,y2,t);
  sqrlong(t);
  arithmet.qtt(x,t,t);
  z:=ACOSrad(t);

  if signy<0 then
       arithmet.oppose(z);
end;

procedure NAngleDeg_sub(var x,y:Number; var z:Number);     //acos version
begin
  NAngle_sub(x,y,z);
  z:=deg(z)
end;

 procedure NAngle(var x,y:Number; var z:Number);
 begin
   CarryOutHP(Nangle_sub,x,y,z)
 end;

 procedure NAngledeg(var x,y:Number; var z:Number);
 begin
   CarryOutHP(NangleDeg_sub,x,y,z)
 end;

function ANGLEfnc:TPrincipal;
begin
    if confirmedDegrees then
      ANGLEfnc:=Binary(NAngleDeg,nil, 3008,'ANGLE')
    else
      ANGLEfnc:=Binary(NANGLE,nil,3008,'ANGLE')
end;



{*********}
{EXP & LOG}
{*********}

function EXPsub(x:Number):number;
var
   i,n:integer;
   t:Number;
   a:array[1..455]of Number;
begin
   n:=1;
   a[n]:=con1e1008^;
   while (n<455) and (a[n].sign<>0) and (a[n].expn>=0) do
   begin
      initinteger(t,n);
      arithmet.mlt(a[n],x,a[n+1]);
      inc(n);
      arithmet.qtt(a[n],t,a[n]);
   end;

   t.initzero;
   for i:=n downto 1 do
       arithmet.add(t,a[i],t);
   arithmet.qtt(t,con1e1008^,result)
end;

const
   const2: MinimalNumber = (places:1; sign:1; tag:1; expn:1; frac:(2));

function EXPn(var x:Number):Number;
var
   t:Number;
begin
  if x.sign<0 then
     try
         t.init(@x);
         arithmet.oppose(t);
         t:=Expn(t);
         arithmet.qtt(arithmet.one^,t,result)
     except
       extype:=0;
       result.initzero;
     end
  else if x.sign=0 then
    result.initone
  else
      if arithmet.compare(x,arithmet.one^)>0 then
        begin
          arithmet.qtt(x, Pnumber(@const2)^, result);
          result:=EXPn(result);
          arithmet.mlt(result,result,result)
        end
      else
        result:=EXPsub(x)
end;

procedure NExp(var n:number);
begin
   n:=getvalue(expN,n)
end;


function EXPfnc:TPrincipal;
begin
    EXPfnc:=Unary(NExp,nil,1003,'EXP')
end;

function Log_sub(x:number):Number;     // 1<=x<=3
var
   h,h2,k,t,c2,e:Number;
   n:integer;
begin
   arithmet.sbt(x,arithmet.one^,h);
   arithmet.add(x,arithmet.one^,t);
   arithmet.qtt(h,t,h);          // h=(x-1)/(x+1)
   t.initzero;
   n:=1;
   k:=h;
   arithmet.mlt(h,h,h2);          // h2=h^2
   initinteger(c2,2);
   repeat
      initinteger(h,n);
      arithmet.qtt(k,h,h);
      arithmet.add(t,h,t);       //t=t+k/n
      n:=n+2;
      arithmet.mlt(k,h2,k);   //k=k*h2
   until (k.sign=0) or (k.expn<=minExpnDecimal) ;

   arithmet.mlt(t,c2,t);          // Newton method
   e:=ExpN(t);
   arithmet.sbt(e,x,h);
   arithmet.qtt(h,e,h);
   arithmet.sbt(t,h,result);
end;

function LogN(var n:Number):Number;
var
   t,x:Number;
begin
  if n.sign<=0 then
    setexception(3004)
  else if arithmet.compare(n,arithmet.one^)<0 then
    begin
       t.initone;
       arithmet.qtt(t,n,t);
       result:=LogN(t);
       arithmet.oppose(result);
    end
  else
    begin
      initinteger(t,3);
      if arithmet.compare(n,t)>0 then
        begin
           t.init(@n);
           sqrlong(t);
           x:=logN(t);
           initinteger(t,2);
           arithmet.mlt(x,t,result)
        end
      else
        result:=Log_sub(n)
    end;

end;


procedure Nlog(var n:number);
begin
    n:=getvalue(logN,n);
end;



function LOGfnc:TPrincipal;
begin
    LOGfnc:=Unary(NLOG,nil,3004,'LOG')
end;

var log2,log10:Number;
var NotInitialized:boolean=true;

procedure InitConsts;
var
   t:Number;
begin
   initinteger(t,2);
   log2:=logN(t);
   initinteger(t,10);
   log10:=logN(t);
   NotInitialized:=false;
end;

function Log2N(var n:number):Number;
begin
  if NotInitialized then
                    InitConsts;
  result:=LogN(n);
  arithmet.qtt(result,log2,result);
end;

procedure Nlog2(var n:number);
begin
    n:=getvalue(log2N,n);
end;

function LOG2fnc:TPrincipal;
begin
    LOG2fnc:=Unary(NlOG2,nil,3004,'LOG')
end;

function Log10N(var n:number):Number;
begin
  if NotInitialized then
                    InitConsts;
  result:=LogN(n);
  arithmet.qtt(result,log10,result);
end;

procedure Nlog10(var n:number);
begin
    n:=getvalue(log10N,n);
end;


function LOG10fnc:TPrincipal;
begin
    LOG10fnc:=Unary(NLOG10,nil,3004,'LOG10')
end;


procedure LongintPower(var a:Number; b:longint; var x:Number);     //2010.3.28
var
   y,xx:number;
begin
    xx.initone;
    if b<>0 then
      begin
        y.init(@a);
        if b>0 then
           begin
              while b<>0 do
                  begin
                     if b mod 2<>0 then arithmet.mlt(xx,y,xx);
                     b:=b div 2;
                     if b<>0 then arithmet.mlt(y,y,y);
                  end;
           end
        else
           try
              while b<>0 do
                  begin
                     if b mod 2<>0 then arithmet.mlt(xx,y,xx);
                     b:=b div 2;
                     if b<>0 then arithmet.mlt(y,y,y);
                  end;
              arithmet.qtt(one^,xx,xx);     {y:=1/y}
           except
             on E:EExtype do
               if extype=1002 then
                  begin
                    extype:=0;
                    xx.initzero;
                  end
               else if extype=3001 then
                  setexception(1002)
               else
                  raise E;
           end;
      end;
    x.init(@xx);
end;

function nearly1(var n:number):boolean;   // abs(n-1)<10^(-341)
var
   t:number;
begin
  arithmet.sbt(n,arithmet.one^,t);
  nearly1:=(t.expn<=-37);
end;

function log1plus(x:Number):Number;
var
   t:number;
   xx:array[1..32]of Number;
   i,j,k:integer;
begin
   xx[1].init(@x);
   i:=1;
   for k:=2 to 32 do
      begin
         j:=k-i;
         arithmet.mlt(xx[i],xx[j],xx[k]);
         inc(j);
         if i=j then i:=i*2;
      end;

   result.initzero;
   for k:=32 downto 1 do
     begin
        initinteger(t,k);
        arithmet.qtt(xx[k],t,t);
        if k mod 2 =0 then
           arithmet.sbt(result,t,result)
        else
           arithmet.add(result,t,result);
     end;

end;

procedure Power1plus(var a,b:Number; var x:number);
var
   t:Number;
begin
   t:=log1plus(a);
   arithmet.mlt(b,t,t);
   x:=expN(t);
end;

procedure approxPower(var a,b:Number; var x:number);
var
   t:number;
begin
   t:=logN(a);
   arithmet.mlt(b,t,t);
   x:=expN(t);
end;

procedure RegularPower(var a,b:Number; var x:number);
var
    i:longint;
    c:integer;
    a1,m,n,t:number;
begin
  a1.init(@a);
  if sgn(@a)<=0 then
      begin
        setexception(3004);
        x.initzero
      end

  else if nearly1(a) then
      begin
        arithmet.sbt(a,one^,a1);
        Power1plus(a1,b,x)
      end

  else //if compareabs(b,PNumber(@const1024)^)<0 then
    begin
      m.init(@b);
      intpart(m);
      arithmet.sbt(b,m,n);
      i:=longintval(m,c);
      if c=0 then
         begin
           LongintPower(a,i,x);
           if iszero(@n) then
             begin
               //RoundConv(x);
               //checkrangedecimal(x,1002)
             end
           else
             begin
               //convert1002(extendedVal(x)*NPXPower(extendedval(a),extendedval(n)),x);
               approxpower(a,n,t);
               arithmet.mlt( x,t,x);
             end
         end
      else
         begin
           //convert1002(NPXpower(ExtendedVal(a),ExtendedVal(b)),x);
           ApproxPower(a,b,x);
         end;
    end;
end;

procedure power(var a,b:Number; var x:number);
var
   n,y:number;
begin
   if (b.places=0) then
       x.initone
   else if a.sign>0 then
      begin
         regularPower(a,b,y);
         x.init(@y)
      end
   else if a.sign=0 then
       begin
               if b.sign>0 then
                   x.initzero
               else if b.sign=0 then
                   x.initone
               else
                   setexception(3003)
       end
   else {if a<0 then}
       begin
            if isinteger(b) then
                begin
                      n.init(@a);
                      n.sign:=-n.sign;
                      power(n,b,y);
                      n.init(@b);
                      qtt2(n);
                      if not isinteger(n) then
                           y.sign:=-y.sign;
                      x.init(@y);
                end
            else
                      setexception(3002);
       end;
end;

procedure powerHP(var a,b:Number; var x:number);
begin
   CarryOutHP(power,a,b,x)
end;

{********************}
{hyperbolic functions}
{********************}

function sinh_sub(var x:Number):Number;
var
   k,i:integer;
   t,t0,s,c,x2:Number;
begin
   //x2:=x*x;
   arithmet.mlt(x,x,x2);
   t.init(@x);
   s.init(@x);
   k:=1;
   repeat
     t0.init(@t);
     //s:=s*x2;
     arithmet.mlt(s,x2,s);
     inc(k);
     i:=k;
     inc(k);
     i:=i*k;
     //s:=s/i;
     initinteger(c,i);
     arithmet.qtt(s,c,s);
     //t:=t+s;
     arithmet.add(t,s,t);
     //until t=t0;
     arithmet.sbt(t,t0,c);
     until c.sign=0;
  result:=t;
end;

function sinh(var n:Number):Number;
var
   t,a,b:Number;
begin
  if iszero(@n) then
      result:=arithmet.zero^
  else if n.expn<=-2 then
      result:=sinh_sub(n)
  else
     begin
       a:=ExpN(n);
       t.init(@n);
       arithmet.oppose(t);
       b:=ExpN(t);
       initinteger(t,2);
       arithmet.sbt(a,b,result);
       arithmet.qtt(result,t,result)
     end;
end;

function cosh(var n:Number):Number;
var
   t,a,b:Number;
begin
   a:=ExpN(n);
   t.init(@n);
   arithmet.oppose(t);
   b:=ExpN(t);
   arithmet.add(a,b,result);
   initinteger(t,2);
   arithmet.add(a,b,result);
   arithmet.qtt(result,t,result)
end;

function tanh(var n:Number):Number;
var
   t,a,b:Number;
begin
   a:=sinh(n);
   t.init(@n);
   arithmet.oppose(t);
   b:=cosh(t);
   arithmet.qtt(a,b,result)
end;

procedure Nsinh(var n:number);
begin
   n:=getvalue(sinh,n)
end;

function SINHfnc:TPrincipal;
begin
    SINHfnc:=Unary(Nsinh,nil,1003,'SINH')
end;

procedure Ncosh(var n:number);
begin
   n:=getvalue(cosh,n)
end;

function COSHfnc:TPrincipal;
begin
    COSHfnc:=Unary(Ncosh,nil,1003,'COSH')
end;

procedure Ntanh(var n:number);
begin
   n:=getvalue(tanh,n)
end;

function TANHfnc:TPrincipal;
begin
    TANHfnc:=Unary(Ntanh,nil,1003,'TAN')
end;




{*************}
{Registeration}
{*************}

function NotExistFnc:TPrincipal;
begin
    NotExistFnc:=nil;
    seterr(Format(s_InvalidFunctionOnMode,
                  [prevtoken,PrecisionText[PrecisionMode]]),RUN_OPTION)
end;



procedure  FunctionTableInit;
begin
   if (PrecisionMode = PrecisionHigh)   then
   begin
       SuppliedFunctionTableInit('ACOS', ACOSfnc);
       SuppliedFunctionTableInit('ANGLE',ANGLEfnc );
       SuppliedFunctionTableInit('ASIN', ASINfnc );
       SuppliedFunctionTableInit('ATN' , ATNfnc );
       SuppliedFunctionTableInit('COS' , COSfnc);
       SuppliedFunctionTableInit('COSH', COSHfnc );
       SuppliedFunctionTableInit('COT',  COTfnc);
       SuppliedFunctionTableInit('CSC' , CSCfnc);
       SuppliedFunctionTableInit('DEG' , DEGfnc );
       SuppliedFunctionTableInit('LOG10',LOG10fnc );
       SuppliedFunctionTableInit('LOG2' ,LOG2fnc);
       SuppliedFunctionTableInit('RAD' , RADfnc);
       SuppliedFunctionTableInit('SEC',  SECfnc);
       SuppliedFunctionTableInit('SIN',  SINfnc);
       SuppliedFunctionTableInit('SINH', SINHfnc);
       SuppliedFunctionTableInit('TAN' , TANfnc);
       SuppliedFunctionTableInit('TANH' ,TANHfnc);
       SuppliedFunctionTableInit('EXP' ,EXPfnc );
       SuppliedFunctionTableInit('LOG' ,LOGfnc);
   end


end;


procedure statementTableinit;
begin
end;



begin
   pointer(Halfpi):=@constHalfPI;
   pointer(con1e1008):=@const1E1008;
   tableInitProcs.accept(statementTableinit);
   tableInitProcs.accept(FunctionTableInit);
end.
