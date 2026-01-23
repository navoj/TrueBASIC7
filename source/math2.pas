unit math2;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}
(***************************************)
(* Copyright (C) 2003, SHIRAISHI Kazuo *)
(***************************************)


{$DEFINE extended}
{$N+}


interface
uses SysUtils, math,
    variabl,arithmet,rational;

type
  TmiscX=class(TPrincipal)
     // evalXを定義することによって定義されるoperation
    procedure evalN(var n:number);override;
    function evalF:double;override;
    procedure evalC(var x:complex);override;
    procedure evalR(var r:PNumeric);override;
   end;

  function NotExistFnc:TPrincipal;

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

procedure shrinks(var n:number;var y:extended;var i:longint);
var
   c:integer;
   sign:integer;
   x,q,xx:number;
   svprecision,svlimit:integer;
begin
    svprecision:=precision;
    svlimit:=limit;
    precision:=5;
    limit:=precision+1;
    sign:=1;
    x.init(@n);
    if arithmet.sgn(@x)<0 then begin arithmet.oppose(x); sign:=-1 end;
    divide(x,decimalhalfpi^,q,x);
    i:=longintval(q,c);
    while c<>0 do
        begin
            initinteger(xx,4);
            remainder(q,xx,q);
            i:=longintval(q,c)
        end;

    if (i and 1)<>0 then arithmet.sbt(decimalhalfpi^,x,x);
    y:=extendedval(x);
    if sign<0 then y:=-y;
    precision:=svprecision;
    limit:=svlimit;
end;

function sinrad(var x:number):extended;
var
   y:extended;
   i:longint;
begin
   shrinks(x,y,i);
   if (i and 2)=0 then
      sinrad:=system.sin(y)
   else
      sinrad:=-system.sin(y)
end;

procedure shrinkc(var n:number;var y:extended;var i:longint);
var
   c:integer;
   x,q,xx:number;
   svprecision,svlimit:integer;
begin
    svprecision:=precision;
    svlimit:=limit;
    precision:=5;
    limit:=precision+1;
    x.init(@n);
    arithmet.absolute(x);
    divide(x,decimalhalfpi^,q,x);
    i:=longintval(q,c);
    while c<>0 do
        begin
            initinteger(xx,4);
            remainder(q,xx,q);
            i:=longintval(q,c)
        end;
    if (i and 1)=0 then arithmet.sbt(decimalhalfpi^,x,x);
    y:=extendedval(x);
    precision:=svprecision;
    limit:=svlimit;
end;
function cosrad(var x:number):extended;
var
   y:extended;
   i:longint;
begin
   shrinkc(x,y,i);
   dec(i);
   if (i and 2)<>0 then
      cosrad:=system.sin(y)
   else
      cosrad:=-system.sin(y)
end;

function tanrad(var x:number):extended;
begin
 try
   result:=sinrad(x)/cosrad(x);
 except
   {$IFNDEF WINDOWS}
   ClearExceptions(False);
   SetFPUMask(controlword);
   {$ENDIF}
   setexceptionwith('TAN',1003);
 end;
end;

function cotrad(var x:number):extended;
begin
  try
   result:=cosrad(x)/sinrad(x);
  except
     {$IFNDEF WINDOWS}
     ClearExceptions(False);
     SetFPUMask(controlword);
     {$ENDIF}
     setexceptionwith('TAN',1003);
  end;
end;

function cscrad(var x:number):extended;
begin
  try
    result:=1./sinrad(x);
  except
     {$IFNDEF WINDOWS}
     ClearExceptions(False);
     SetFPUMask(controlword);
     {$ENDIF}
     setexceptionwith('CSC',1003);
  end;
end;

function secrad(var x:number):extended;
begin
  try
    result:=1./cosrad(x);
  except
     {$IFNDEF WINDOWS}
     ClearExceptions(False);
     SetFPUMask(controlword);
     {$ENDIF}
     setexceptionwith('SEC',1003);
  end;

end;


procedure NSinRad(var n:number);
begin
    convert(sinrad(n),n);
end;

procedure NCosRad(var n:number);
begin
    convert(cosrad(n),n);
end;

procedure NTANRad(var n:number);
begin
    convert(TANrad(n),n);
end;

procedure NSECRad(var n:number);
begin
    convert(secrad(n),n);
end;

procedure NCSCRad(var n:number);
begin
    convert(cscrad(n),n);
end;

procedure NCOTrad(var n:number);
begin
    convert(COTrad(n),n);
end;

procedure FSEC(var x:double);
begin
   x:=1/cos(x)
end;

procedure Fcsc(var x:double);
begin
     x:=1/sin(x)
end;

function SINfnc:TPrincipal;
begin
    if confirmedDegrees then
         SINfnc:=UnaryX(sindeg,1003,'SIN')
    else
         SINfnc:=Unary(Nsinrad,FSIN,1003,'SIN')
end;

function COSfnc:TPrincipal;
begin
    if confirmedDegrees then
         COSfnc:=UnaryX(cosdeg,1003,'COS')
    else
         COSfnc:=Unary(Ncosrad,FCOS,1003,'COS')
end;

function TANfnc:TPrincipal;
begin
    if confirmedDegrees then
         TANfnc:=UnaryX(tandeg,1003,'TAN')
    else
         TANfnc:=Unary(Ntanrad,FTAN,1003,'TAN')
end;

function CSCfnc:TPrincipal;
begin
    if confirmedDegrees then
         CSCfnc:=UnaryX(CSCdeg,1003,'CSC')
    else
         CSCfnc:=Unary(NCSCrad,FCSC,1003,'CSC')
end;

function SECfnc:TPrincipal;
begin
    if confirmedDegrees then
         SECfnc:=UnaryX(secdeg,1003,'SEC')
    else
         SECfnc:=Unary(Nsecrad,FSEC,1003,'SEC')
end;

function COTfnc:TPrincipal;
begin
    if confirmedDegrees then
         COTfnc:=UnaryX(cotdeg,1003,'COT')
    else
         COTfnc:=Unary(Ncotrad,FCOT,1003,'COT')
end;

{*********************}
{inverse trigonometric}
{*********************}


function asinN(var n:number):extended;
var
  h,j:number;
begin
  arithmet.sbt(one^,n,h);
  arithmet.add(one^,n,j);
  asinN:=asinsub(extendedval(n),extendedval(h),extendedval(j))
end;

function acosN(var n:number):extended;
var
  h,j:number;
begin
  arithmet.sbt(one^,n,h);
  arithmet.add(one^,n,j);
  acosN:=acossub(extendedval(n),extendedval(h),extendedval(j))
end;

function asinNdeg(var n:number):extended;
begin
   asinNdeg:=asinN(n)*degree;
end;

function acosNdeg(var n:number):extended;
begin
    acosNdeg:=acosN(n)*degree;
end;


procedure NASIN(var n:number);
begin
    convert(ASINN(n),n);
end;

procedure NACOS(var n:number);
begin
    convert(ACOSN(n),n);
end;

procedure NASINdeg(var n:number);
begin
    convert(ASinNdeg(n),n);
end;

procedure NACOSdeg(var n:number);
begin
    convert(ACOSNdeg(n),n);
end;

procedure FASINdeg(var x:double);
begin
   x:=asin(x)*degree
end;

procedure FASIN(var x:double);
begin
   x:=asin(x)
end;

procedure FACOS(var x:double);
begin
    x:=acos(x)
end;

procedure FACOSdeg(var x:double);
begin
    x:=acos(x)*degree
end;

function ATN(x:extended):extended;
begin
   result:=arctan(x)
end;

function ATNdeg(x:extended):extended;
begin
   result:=arctan(x)*degree
end;

function ASINfnc:TPrincipal;
begin
    if confirmedDegrees then
      ASINfnc:=Unary(NASINdeg,FASINdeg,3007,'ASIN')
    else
      ASINfnc:=Unary(NASIN,FASIN,3007,'ASIN')
end;

function ACOSfnc:TPrincipal;
begin
    if confirmedDegrees then
      ACOSfnc:=Unary(NACOSdeg,FACOSdeg,3007,'ACOS')
    else
      ACOSfnc:=Unary(NACOS,FACOS,3007,'ACOS')
end;


function ATNfnc:TPrincipal;
begin
    if confirmedDegrees then
      ATNfnc:=UnaryX(ATNdeg,1003,'ATN')
    else
      ATNfnc:=UnaryX(ATN,1003,'ATN')
end;

function ANGLEfnc:TPrincipal;
begin
    if confirmedDegrees then
      ANGLEfnc:=BinaryX(Angledeg,3008,'ANGLE')
    else
      ANGLEfnc:=BinaryX(angle,3008,'ANGLE')
end;

{********************}
{hyperbolic functions}
{********************}

function SINHfnc:TPrincipal;
begin
    SINHfnc:=UnaryX(sinh,1003,'SINH')
end;

function COSHfnc:TPrincipal;
begin
    COSHfnc:=UnaryX(cosh,1003,'COSH')
end;

function TANHfnc:TPrincipal;
begin
    TANHfnc:=UnaryX(tanh,1003,'TAN')
end;

{******}
{Others}
{******}

function DEGfnc:TPrincipal;
begin
    DEGfnc:=UnaryX(deg,1003,'DEG')
end;

function MyEXP(x:extended):extended;
begin
    result:=exp(x)
end;

function EXPfnc:TPrincipal;
begin
    EXPfnc:=UnaryX(MyExp,1003,'EXP')
end;



procedure Nlog(var n:number);
begin
    convert(logN(n),n);
end;

procedure FLOG(var x:double);
begin
    x:=ln(x)
end;

function LOGfnc:TPrincipal;
begin
    LOGfnc:=Unary(NLOG,FLOG,3004,'LOG')
end;

procedure Nlog2(var n:number);
begin
    convert(logN(n)/ln2,n);
end;

procedure FLOG2(var x:double);
begin
    x:=ln(x)/ln2
end;

function LOG2fnc:TPrincipal;
begin
    LOG2fnc:=Unary(NlOG2,FLOG2,3004,'LOG')
end;

procedure Nlog10(var n:number);
begin
    convert(logN(n)/ln10,n);
end;

procedure FLOG10(var x:double);
begin
    x:=ln(x)/ln10
end;

function LOG10fnc:TPrincipal;
begin
    LOG10fnc:=Unary(NLOG10,FLOG10,3004,'LOG10')
end;

function RADfnc:TPrincipal;
begin
    RADfnc:=UnaryX(Rad,1003,'RAD')
end;

{
procedure  FSQRT (var x:extended);assembler;
asm
    fld tbyte ptr [x]
    FSQRT
    fstp tbyte ptr [x]
end;
}
{********}
{Graphics}
{********}


procedure TmiscX.evalN(var n:number);
begin
   convert(evalX,n)
end;

function TmiscX.evalF:double;
begin
     result:=evalX
end;

procedure TmiscX.evalC(var x:complex);
begin
   x.x:=evalX;
   x.y:=0
end;

procedure TmiscX.evalR(var r:PNumeric);
var
   n:number;
begin
   convert(evalX,n);
   disposeNumeric(r);
   r:=NewRationalfromNumber(@n);
end;

type
   TMiscUnaryX=class(TMiscX)
       exp:TPrincipal;
       f:extendedfunction1;
    constructor create(f1:extendedfunction1);
    destructor destroy;override;
    function evalX:extended;override;
   end;


constructor TMiscUnaryX.create;
begin
    inherited create;
    f:=f1;
    check('(',IDH_ARRAY_FUNCTION);
    exp:=NExpression;
   check(')',IDH_ARRAY_FUNCTION);
end;

destructor TMiscUnaryX.destroy;
begin
     exp.free;
    inherited destroy;
end;

function TMiscUnaryX.evalX:extended;
begin
   result:=f(exp.evalX);
end;

type
   TMiscUnaryXdouble=class(TMiscX)
       exp:TPrincipal;
       f:doublefunction1;
    constructor create(f1:doublefunction1);
    destructor destroy;override;
    function evalX:extended;override;
   end;

constructor TMiscUnaryXdouble.create;
   begin
       inherited create;
       f:=f1;
       check('(',IDH_ARRAY_FUNCTION);
       exp:=NExpression;
      check(')',IDH_ARRAY_FUNCTION);
   end;

destructor TMiscUnaryXdouble.destroy;
   begin
        exp.free;
       inherited destroy;
   end;

function TMiscUnaryXdouble.evalX:extended;
begin
      result:=f(exp.evalX);
end;




function PixelXfnc:TPrincipal;
begin
    PixelXfnc:=NOperation(TMIscUnaryXdouble.create(PixelX))
end;

function PixelYfnc:TPrincipal;
begin
    PixelYfnc:=NOperation(TMIscUnaryXdouble.create(PixelY))
end;

function ProblemXfnc:TPrincipal;
begin
    ProblemXfnc:=NOperation(TMIscUnaryXdouble.create(WindowX))
end;

function ProblemYfnc:TPrincipal;
begin
    ProblemYfnc:=NOperation(TMIscUnaryXdouble.create(WindowY))
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
   if (PrecisionMode in [PrecisionNormal,PrecisionNative,PrecisionComplex] )
   or (PrecisionMode = PrecisionRational)and UseTranscendentalFunction  then
   begin
       if PrecisionMode<>PrecisionComplex then
        begin
          SuppliedFunctionTableInit('EXP' ,EXPfnc );
          SuppliedFunctionTableInit('LOG' ,LOGfnc);
        end;
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
   end
else if  (PrecisionMode = PrecisionRational) and not UseTranscendentalFunction  then
   begin
       SuppliedFunctionTableInit('ACOS' ,NotExistFnc);
       SuppliedFunctionTableInit('ANGLE',NotExistFnc);
       SuppliedFunctionTableInit('ASIN' ,NotExistFnc);
       SuppliedFunctionTableInit('ATN'  ,NotExistFnc);
       SuppliedFunctionTableInit('COS'  ,NotExistFnc);
       SuppliedFunctionTableInit('COSH' ,NotExistFnc);
       SuppliedFunctionTableInit('COT'  ,NotExistFnc);
       SuppliedFunctionTableInit('CSC'  ,NotExistFnc);
       SuppliedFunctionTableInit('DEG'  ,NotExistFnc);
       SuppliedFunctionTableInit('EXP'  ,NotExistFnc);
       SuppliedFunctionTableInit('LOG'  ,NotExistFnc);
       SuppliedFunctionTableInit('LOG10',NotExistFnc);
       SuppliedFunctionTableInit('LOG2' ,NotExistFnc);
       SuppliedFunctionTableInit('RAD'  ,NotExistFnc);
       SuppliedFunctionTableInit('SEC'  ,NotExistFnc);
       SuppliedFunctionTableInit('SIN'  ,NotExistFnc);
       SuppliedFunctionTableInit('SINH' ,NotExistFnc);
       SuppliedFunctionTableInit('TAN'  ,NotExistFnc);
       SuppliedFunctionTableInit('TANH' ,NotExistFnc);
  end;

       SuppliedFunctionTableInit('PIXELX',PixelXfnc);
       SuppliedFunctionTableInit('PIXELY',PixelYfnc);
       SuppliedFunctionTableInit('WORLDX',ProblemXfnc);
       SuppliedFunctionTableInit('WORLDY',ProblemYfnc);
       SuppliedFunctionTableInit('PROBLEMX',ProblemXfnc);
       SuppliedFunctionTableInit('PROBLEMY',ProblemYfnc);
       SuppliedFunctionTableInit('WINDOWX',ProblemXfnc);
       SuppliedFunctionTableInit('WINDOWY',ProblemYfnc);
end;



procedure statementTableinit;
begin
end;

begin
   tableInitProcs.accept(statementTableinit);
   tableInitProcs.accept(FunctionTableInit);
end.
