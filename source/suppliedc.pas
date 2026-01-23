unit suppliedc;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}


(***************************************)
(* Copyright (C) 2003, SHIRAISHI Kazuo *)
(***************************************)


interface

{*************}
implementation
{*************}

uses SysUtils,
    base,texthand,arithmet,math2sub,variabl,
    express,expressc,struct,helpctex,confopt;


{******************}
{supplied functions}
{******************}

procedure CAbs(var x:complex);
begin
  with x do
    begin
      x:=SQRT(SQR(x)+SQR(y));
      y:=0;
    end;  
end;

function ABSfnc:TPrincipal;
begin
    ABSfnc:=UnaryC(CABS,1003,'ABS')
end ;

procedure CSQRT(var x:complex);
var
  t:extended;
begin
  if x.x>=0.0 then
    if x.y=0.0 then
        x.x:=sqrt(x.x)
    else
    begin
       x.x:=sqrt((sqrt(sqr(x.x)+sqr(x.y))+x.x)/2.0);
       x.y:=x.y/(2.0*x.x);
    end
  else
  begin
       t:=sqrt((sqrt(sqr(x.x)+sqr(x.y))-x.x)/2.0);
       if x.y<0 then t:=-t;
       x.x:=x.y/(2.0*t);
       x.y:=t;
  end;
end;

function SQRfnc:TPrincipal;
begin
   SQRfnc:=UnaryCOrdinal(CSQRT,3005,'SQR')
end;

procedure CCONJ(var x:complex);
begin
   x.y:=-x.y
end;

function CONJfnc:TPrincipal;
begin
   CONJfnc:=UnaryCOrdinal(CCONJ,1003,'SQR')
end;

procedure CEXP(var x:complex);
begin
   x:=complexEXP(x)
end;

function EXPfnc:TPrincipal;
begin
    EXPfnc:=UnaryC(CExp,1003,'EXP')
end;

procedure CLOG(var x:complex);
var
  r,t:extended;
begin
  r:=SQRT(SQR(x.x)+SQR(x.y));
  t:=angle(x.x,x.y);
  x.x:=ln(r);
  x.y:=t;
end;

function LOGfnc:TPrincipal;
begin
    LOGfnc:=UnaryC(CLOG,3004,'LOG')
end;

procedure CARG(var x:complex);
begin
    x.x:=angle(x.x, x.y);
    x.y:=0
end;

procedure CARGdeg(var x:complex);
begin
    x.x:=angledeg(x.x, x.y);
    x.y:=0
end;

function ARGfnc:TPrincipal;
begin
    if confirmedDegrees then
      ARGfnc:=UnaryC(CARGdeg,3008,'ARG')
    else 
      ARGfnc:=UnaryC(CARG,3008,'ARG')
end;

{******************}
{ Complex Functions}
{******************}

procedure CCOMPLEX(var x,y:complex);
var
   z:complex;
begin
   z.x:=x.x-y.y;
   z.y:=x.y+y.x;
   x:=z
end;

function COMPLEXfnc:TPrincipal;
begin
  COMPLEXfnc:=BinaryCOrdinal(CComplex,3000,'COMPLEX')
end;

procedure CRe(var x:complex);
begin
    x.y:=0
end;

function REfnc:TPrincipal;
begin
  REfnc:=UnaryCOrdinal(CRe,3000,'RE')
end;

procedure CIm(var x:complex);
begin
    x.x:=x.y;
    x.y:=0
end;

function IMfnc:TPrincipal;
begin
  IMfnc:=UnaryCOrdinal(CIm,3000,'RE')
end;


{***********}
{initialize}
{*********}

procedure  FunctionTableInit;
begin
   if PrecisionMode=PrecisionComplex then
   begin
       SuppliedFunctionTableInit('ABS',ABSfnc );
       SuppliedFunctionTableInit('SQR',SQRfnc );
       SuppliedFunctionTableInit('EXP' ,EXPfnc );
       SuppliedFunctionTableInit( 'LOG' , LOGfnc);

       SuppliedFunctionTableInit('COMPLEX' ,  COMPLEXfnc);
       SuppliedFunctionTableInit('RE'    ,REfnc );
       SuppliedFunctionTableInit('IM' ,IMfnc );
       SuppliedFunctionTableInit('CONJ' ,CONJfnc );
       SuppliedFunctionTableInit('ARG' ,ARGfnc );

    {**************}
    {reserved words}
    {**************}
   end;
end;

begin
   tableInitProcs.accept(FunctionTableInit);
end.
