unit supplied;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

(***************************************)
(* Copyright (C) 2006, SHIRAISHI Kazuo *)
(***************************************)


interface
uses  SysUtils,Classes, LCLProc,
    variabl,arithmet,rational;

function reservedwordfnc:TPrincipal;
{$IFDEF Windows}
function SJisToJis(N:WORD):WORD;
{$ENDIF}

type
  TMiscInt=class(TPrincipal)
     // evalLongIntを定義することによって定義されるoperation
     CharacterByte:boolean;
    constructor create;
    procedure evalN(var n:number);override;
    function evalF:double;override;
    procedure evalC(var x:complex);override;
    procedure evalR(var r:PNumeric);override;
   end;

type
  TMiscReal=class(TPrincipal)
     // evalXを定義することによって定義されるoperation
     // 数値の変換によって桁あふれが発生するような場合には適用しない。
    procedure evalN(var n:number);override;
    function evalF:double;override;
    procedure evalC(var x:complex);override;
    procedure evalR(var r:PNumeric);override;
   end;


implementation
uses LazUTF8,
    myutils,float,
    base,express,variabls,variablc,variablr,struct,texthand,
    helpctex,math2,math2sub,graphsys,sconsts, matexpr;

function ABSfnc:TPrincipal;
begin
    ABSfnc:=Unary(arithmet.absolute,FABS,1003,'ABS')
end ;


function CEILfnc:TPrincipal;
begin
    CEILfnc:=Unary(arithmet.ceil,FCEIL,1003,'CEIL')
end ;

function EPSfnc:TPrincipal;
begin
  if ProgramUnit.arithmetic=PrecisionNormal then
    EPSfnc:=Unary(arithmet.EpsDecimal,FEPS,1003,'EPS')
  else
    EPSfnc:=Unary(arithmet.EpsNative,FEPS,1003,'EPS')
end ;

procedure FFP(var x:double);
begin
   x:=x-INT(x);
end;

function FPfnc:TPrincipal;
begin
    FPfnc:=Unary(arithmet.FractPart,FFP,1003,'FP')
end ;


function INTfnc:TPrincipal;
begin
    INTfnc:=Unary(arithmet.BASICINT,FFloor,1003,'INT')
end ;


procedure FIP(var x:double);
begin
    x:=int(x) ;
end;


function IPfnc:TPrincipal;
begin
    IPfnc:=Unary(Arithmet.intpart,FIP,1003,'IP')
end ;




function MAXfnc:TPrincipal;
begin
   MAXfnc:=Binary(arithmet.max,FMAX,1003,'MAX')
end;



function MINfnc:TPrincipal;
begin
   MINfnc:=Binary(arithmet.min,FMIN,1003,'MIN')
end;


function MODfnc:TPrincipal;
begin
   MODfnc:=Binary(arithmet.BasicMOD,Float.BasicMod,3006,'MOD')
end;

procedure FRemainder(var x,y:double);
begin
   x:=x-y*int(x/y)
end;

function REMAINDERfnc:TPrincipal;
begin
   REMAINDERfnc:=Binary(arithmet.remainder,FRemainder,3006,'REMAINDER')
end;


function power10(i:integer):extended;
var
   x,y:extended;
begin
    x:=10.;
    y:=1.;
    if i<0 then begin x:=1./x ; i:=-i end;
    while i>0 do
        begin
           if i mod 2 =1 then
              y:=y*x;
           i:=i div 2;
           if i>0 then x:=x*x;
        end;
    power10:=y
end;

procedure round2(var x,n:double);
var
   e:extended;
begin
     e:=power10(LongIntRound(n));
     x:=x*e+0.5;
     FFLOOR(x);
     x:=x/e;
end;

procedure truncate(var x,n:double);
var
   e:extended;
begin
     e:=power10(LongIntRound(n));
     x:=x*e;
     x:=int(x);
     x:=x/e;
end;

function ROUNDfnc:TPrincipal;
var
   svcp:^tokensave;
   exp:TPrincipal;
   token1:string;
begin
   new(svcp);
   savetoken(svcp^);
   check('(',IDH_FUNCTIONS);
   exp:=NExpression;
   exp.free;
   token1:=token;
   try
     restoretoken(svcp^);
     if token1=')' then
       ROUNDfnc:=Unary(arithmet.intround,float.FROUND,1002,'ROUND')
     else
       ROUNDfnc:=Binary(arithmet.round,round2,1002,'ROUND');
   finally
     dispose(svcp);
   end;
end;

procedure sgn(var n:number);
begin
   initinteger(n,arithmet.sgn(@n));
end;

procedure FSIGN(var x:double);
begin
  x:=float.fsign(x)
end;

function SGNfnc:TPrincipal;
begin
    SGNfnc:=Unary(sgn,FSIGN,1002,'SGN')
end ;


function TRUNCATEfnc:TPrincipal;
begin
    TRUNCATEfnc:=Binary(Arithmet.truncate,truncate,1002,'TRUNCATE')
end ;


{*********}
{extension}
{*********}

procedure perm(var n,r:number; var x:number);
var
   a,y:number;
   k,i:longint;
   c:integer;
begin
   a.init(@n);
   k:=longintval(r,c);
   if (c=0) and isinteger(r) and (arithmet.sgn(@r)>=0) then
      begin
          y.initone;
          i:=0;
          while (i<k) do
                   begin
                     arithmet.mlt(y,a,y);
                     arithmet.sbt(a,one^,a);
                     inc(i);
                     //idle
                   end;
          x.init(@y);
      end
   else
      setexception(4000);
end;

procedure comb(var n,r:number; var x:number);
var
   a,b,y:number;
   k,i:longint;
   c:integer;
begin
   a.init(@n);
   b.init(@r);
   y.init(@n);
   qtt2(y);
   if isinteger(n) and (arithmet.sgn(@n)>0) and (arithmet.compare(r,y)>0) then
      arithmet.sbt(n,r,b);

   k:=longintval(b,c);
   if (c=0) and isinteger(b) then
      if (arithmet.sgn(@b)>=0) then
        begin
            y.initone;
            b.initone;
            i:=0;
            while (i<k) do
                   begin
                      arithmet.mlt(y,a,y);
                      arithmet.qtt(y,b,y);
                      arithmet.sbt(a,one^,a);
                      arithmet.add(b,one^,b);
                      inc(i) ;
                      //idle
                   end;
            x.init(@y);

        end
      else
        x.initzero
   else
      setexception(4000);
end;

procedure fact(var n:number);
begin
  perm(n,n,n)
end;

function permX(n,r:double):double;
var
   i,k:longint;
begin
   if Frac(r)<>0 then  setexception(4000);
   k:=LongIntRound(r);
   if k<0 then
      begin
         result:=0;
         setexception(3000)
      end
   else
      begin
         result:=1;
         for i:=1 to k do
             begin
                result:=result*n;
                n:=n-1;
             end;
      end;
end;

function combX(n,r:double):double;
var
   i,k:longint;
   m:double;
   x:extended;
begin
   if Frac(r)<>0 then  setexception(4000);
   //FROUND(r);
   k:=LongIntRound(r);
   if k<0 then
     x:=0
   else if (k>n/2) and (n=int(n)) and (n>0) then
     x:=combX(n,n-r)
   else
     begin
        x:=1;
        m:=1;
        for i:=1 to k do
           begin
             x:=x*n/m;
             n:=n-1;
             m:=m+1;
          end;
     end;
   result:=x;
end;

function factX(n:double):double;
begin
   result:=permX(n,n)
end;

procedure Fperm(var n,r:double);
begin
   n:=permX(n,r)
end;

procedure Fcomb(var n,r:double);
begin
   n:=combX(n,r)
end;

procedure Ffact(var n:double);
begin
   n:=factX(n)
end;

function FACTfnc:TPrincipal;
begin
    FACTfnc:=Unary(fact,Ffact,4000,'FACT')
end ;

function PERMfnc:TPrincipal;
begin
   PERMfnc:=Binary(perm,Fperm,4000,'PERM')
end;

function COMBfnc:TPrincipal;
begin
   COMBfnc:=Binary(comb,Fcomb,4000,'COMB')
end;

{*************}
{reserved word}
{*************}



function reservedwordfnc:TPrincipal;
begin
     seterr(prevtoken+s_IsReserved,IDH_RESERVED);
     reservedwordfnc:=nil
end;

{************}
{SQR function}
{************}
function MySqrt(x:extended):extended;
begin
  result:=sqrt(x)
end;

function SQRfnc1:TPrincipal;
begin
   SQRfnc1:=UnaryX(MySqrt,3005,'SQR')
end;

function SQRfnc2:TPrincipal;
begin
     SQRfnc2:=Unary(arithmet.sqrlong,FSQRT,3005,'SQR')
end;

{***********************}
{miscellaneous Functions}
{***********************}

procedure TMiscReal.evalN(var n:number);
begin
   convert(EvalX,n);
end;

function TMiscReal.evalF:double;
begin
   result:=evalX;
end;

procedure TMiscReal.evalC(var x:complex);
begin
     x.x:=evalX; x.y:=0;
end;

procedure TMiscReal.evalR(var r:PNumeric);
var
   n:number;
begin
   convert(EvalX,n);
   disposeNumeric(r);
   r:=NewRationalFromNumber(@n);
end;

type
  RealFunction=function:extended;

  TNoArgReal=class(TMiscReal)
     op:Realfunction;
    constructor create(f:realFunction);
    function evalX:extended;override;
  end;

constructor TNoArgReal.create(f:realFunction);
begin
   inherited create;
   op:=f
end;

function TNoArgReal.evalX:extended;
begin
   result:=op ;
end;


function DATEfnc:TPrincipal;
begin
   DATEfnc:=NOperation(TNoArgReal.create(mydate))
end;

function TIMEfnc:TPrincipal;
begin
   TIMEfnc:=NOperation(TNoArgReal.create(myTime))
end;

function RNDfnc:TPrincipal;
begin
   if token='(' then
      seterr(s_RND, IDH_RANDOM);
   if precisionMode in [PrecisionNative,PrecisionComplex] then
      RNDfnc:=NOperation(TNoArgReal.create(Math2Sub.random52))
   else
      RNDfnc:=NOperation(TNoArgReal.create(Math2Sub.random50))
end;

{********}
{TMiscInt}
{********}

constructor TMiscInt.create;
begin
   Inherited create;
   CharacterByte:=ProgramUnit.CharacterByte;
end;

procedure TMiscInt.evalN(var n:number);
begin
   initlongint(n,EvalLongInt)
end;

function TMiscInt.evalF:double;
begin
     result:=evalLongint
end;

procedure TMiscInt.evalC(var x:complex);
begin
   x.x:=evalLongint;
   x.y:=0
end;

procedure TMiscInt.evalR(var r:PNumeric);
var
   i:longint;
begin
   i:=EvalLongInt;
   disposeNumeric(r);
   r:=NewRationalLongInt(i)
end;

{*************}
{lbound,ubound}
{*************}

type
   TLbound=class(TMiscInt)
       mat:TMatrix;
       exp:TPrincipal;
       dir:char;
    constructor create(k:char);
    destructor destroy;override;
    function evalLongint:longint;override;
    end;

function  LBOUNDfnc:TPrincipal;
begin
    LBOUNDfnc:=NOperation(TLBound.create('L'))
end;

function UBOUNDfnc:TPrincipal;
begin
     UBOUNDfnc:=NOperation(TLBound.create('U'))
end;

constructor TLBound.create(k:char);
begin
    inherited create;
    dir:=k;
    check('(',IDH_ARRAY_FUNCTION);
    mat:=matrix;
    if token=',' then
        begin
           gettoken;
           exp:=Nexpression;
        end;
   check(')',IDH_ARRAY_FUNCTION);
   if (mat.idr.dim>1) and (exp=nil) then
                   seterrdimension(IDH_ARRAY_FUNCTION) ;
end;

destructor TLBound.destroy;
begin
     mat.free;
     exp.free;
    inherited destroy;
end;

function TLBound.evalLongint:longint;
var
    i:longint;
    b:integer;
    p:TArray;
    ubound:Array4;
begin
    TVar(p):=mat.point;
    if exp=nil then
        i:=1
    else
        i:=exp.evalLongint;
    if (i>0) and  (i<=mat.idr.dim) then
      begin
          case dir of
             'L': i:=p.lbound[i];
             'U': begin p.getubound(ubound); i:=ubound[i]; end;
          end;
          evallongint:=i;
      end
    else
        begin
           case dir of
              'L':b:=4008;
              'U':b:=4009;
           end;
           setexception(b);
        end;
end;


{**************}
{SIZE functions}
{**************}

type
   TSize=class(TMiscInt)
       mat:TMatrix;
       exp:TPrincipal;
    constructor create;
    destructor destroy;override;
    function evalLongint:longint;override;
    end;

constructor TSize.create;
begin
    inherited create;
    check('(',IDH_ARRAY_FUNCTION);
    mat:=matrix;
    if token=',' then
        begin
           gettoken;
           exp:=Nexpression;
        end;
   check(')',IDH_ARRAY_FUNCTION);
end;

destructor TSize.destroy;
begin
     mat.free;
     exp.free;
    inherited destroy;
end;

function TSize.evalLongint:longint;
var
    i:longint;
    //b:integer;
    p:TArray;
    //ubound:Array4;
begin
    TVar(p):=mat.point;
    if exp=nil then
      begin
        result:=1;
        with p do
           for i:=1 to dim do
             result:=result*size[i]
      end
    else
      begin
        i:=exp.evalLongint;
        if (i>0) and  (i<=mat.idr.dim) then
           result:=p.size[i]
        else
           setexception(4004);
      end;
end;

function SIZEfnc:TPrincipal;
begin
     SIZEfnc:=NOperation(TSize.create)
end;


{*************}
{LEN functions}
{*************}

type
    TLEN=class(TMiscInt)
       exp:TPrincipal;
      constructor create;
      function evalLongint:longint;override;
      destructor destroy;override;
    end;

    TBLEN=class(TLEN)
      function evalLongint:longint;override;
    end;

constructor TLEN.create;
begin
    inherited create;
    check('(',IDH_STRING_FUNCTIONS);
    exp:=SExpression;
    check(')',IDH_STRING_FUNCTIONS);
end;

destructor TLEN.destroy;
begin
    exp.free;
    inherited destroy;
end;

function TLEN.evalLongint:longint;
begin
   result:=Utf8length(exp.evalS);
end;

function TBLEN.evalLongint:longint;
begin
    result:=length(exp.evalS);
end;

function  BLENfnc:TPrincipal;
begin
    BLENfnc:=NOperation(TBLEN.create)
end;

function  LENfnc:TPrincipal;
begin
   if ProgramUnit.CharacterByte then
      Lenfnc:=BLENFnc
   else
      LENfnc:=NOperation(TLEN.create)
end;

type
   TMAXLEN=class(TMiscInt)
        mat:TSubstance;
      constructor create;
      function evalLongint:longint;override;
      //destructor destroy;override;
    end;

function  MAXLENfnc:TPrincipal;
begin
    MAXLENfnc:=NOperation(TMAXLEN.create)
end;

constructor TMAXLEN.create;
var
  idr:TIdRec;
begin
    inherited create;
    check('(',IDH_STRING_FUNCTIONS);
    idr:=IdRecord(true);
    if (idr=nil) or (idr.kindchar<>'s') then seterrExpected(s_StringVariable,480);
    Gettoken;
    check(')',IDH_STRING_FUNCTIONS);
    mat:=idr.subs;
end;

function TMAXLEN.evalLongint:longint;
begin
    if mat.idr.dim>0 then
      result:=(mat.ptr as TArray).maxlen
    else
      result:=(mat.ptr as TSVar).maxlen;
end;

{
destructor TMAXLEN.destroy;
begin
   idr.free;
   inherited destroy;
end;
}

{********}
{ MAXSIZE}
{********}

type
   TMAXSIZE=class(TMiscInt)
       mat:TMatrix;
    constructor create;
    destructor destroy;override;
    function evalLongint:longint;override;
    end;

constructor TMAXSIZE.create;
begin
    inherited create;
    check('(',IDH_ARRAY_FUNCTION);
    mat:=matrix;
    check(')',IDH_ARRAY_FUNCTION);
end;

destructor TMAXSIZE.destroy;
begin
     mat.free;
     inherited destroy;
end;

function TMAXSIZE.evalLongint:longint;
var
    p:TArray;
begin
    TVar(p):=mat.point;
    if p<>nil then
       result:=p.MaxSize
    else
       result:=0;
end;


function  MAXSIZEfnc:TPrincipal;
begin
    MAXSIZEfnc:=NOperation(TMAXSIZE.create)
end;


{************}
{ORD function}
{************}
{$IFDEF Windows}
{$ASMMODE intel}
function SJisToJis(N:WORD):WORD; register; assembler;
asm
   {$IFDEF CPU64}
    mov  ax,di
   {$ENDIF}
    shl  ah,1
    sub  al,1fh
    js   @1
    cmp  al,61h
    adc  al,0deh
@1: add  ax,1fa1h
    and  ax,7f7fh
end;
{$ENDIF}

function EUCToJis(N:WORD):WORD;
begin
   if hi(N)=$8E then
      result:=lo(N)
   else
      result:=N and $7F7F
end;

function BasicOrd(s:AnsiString; CharacterByte:boolean):longint;
var
   i:integer;
   charlen:integer;
begin
   if Length(s)=1 then
      BasicOrd:=ord(s[1])
   else if (Length(s)=3) and (byte(s[1])<128) then
      begin
         s:=AnsiUpperCase(s);
         if (length(s)=3) and (copy(s,1,2)='LC') then
             BasicOrd:=ord(s[3])+32
         else
         begin
             for i:=0 to 39 do
                 if s=CharNameTBL1[i] then begin BasicOrd:=CharNameTBL2[i]; exit end;
             BasicOrd:=0;
             setexceptionwith('ORD',4003);
         end ;
      end
   else if characterbyte then
      begin
             basicORD:=0;
             setexceptionwith('ORD',4003);
      end
   else
      begin
         BASICOrd:=UTF8CharacterToUnicode(PChar(s),charlen);
         if charlen<length(s) then  setexceptionwith('ORD',4003);
      end;                                end;

type
   TORD=class(TLEN)
      function evalLongint:longint;override;
    end;

function  ORDfnc:TPrincipal;
begin
    ORDfnc:=NOperation(TORD.create)
end;

function TORD.evalLongint:longint;
begin
    result:=BasicOrd(exp.evalS,CharacterByte);

end;

{************}
{POS function}
{************}

type
   TPos=class(TMiscInt)
      exp1,exp2,exp3:TPrincipal;
      constructor create;
      function evalLongint:longint;override;
      destructor destroy;override;
    end;

constructor TPos.create;
begin
    inherited create;
    check('(',IDH_STRING_FUNCTIONS);
    exp1:=SExpression;
    check(',',IDH_STRING_FUNCTIONS);
    exp2:=SExpression;
    if token=',' then
        begin
             gettoken;
             exp3:=NExpression;
        end;
    check(')',IDH_STRING_FUNCTIONS);
end;

destructor TPos.destroy;
begin
     exp1.free;
     exp2.free;
     exp3.free;
     inherited destroy;
end;

function pos2(const a,b:ansistring):integer;
begin
   if b<>'' then
      pos2:=pos(b,a)
   else
      pos2:=1;
end;

function pos3(const a,b:ansistring; m:integer):integer;
var
   temp1,temp3:integer;
   temp2:ansistring;
begin
   if m<=length(a) then
     begin
       temp1:=max(1,min(m,length(a)+1));
       temp2:=copy(a,temp1,maxint);
       temp3:=pos2(temp2,b);
       if temp3=0 then
          pos3:=0
       else
          pos3:=temp3+temp1-1
     end
   else
     pos3:=0;
end;

function UTF8Pos2(const a,b:ansistring):integer;
begin
   if b<>'' then
      result:=UTF8Pos(b,a)
   else
      result:=1;
end;

function UTF8Pos3(const a,b:ansistring; m:integer):integer;
var
   temp1,temp3:integer;
   temp2:ansistring;
begin
   if m<=Utf8length(a) then
     begin
       temp1:=max(1,min(m,Utf8length(a)+1));
       temp2:=Utf8copy(a,temp1,maxint);
       temp3:=UTF8Pos2(temp2,b);
       if temp3=0 then
          Result:=0
       else
          Result:=temp3+temp1-1
     end
   else
     result:=0;
end;


function TPos.evalLongint:longint;
var
   a,b:ansistring;
   m:longint;
begin
    //m:=1;
    result:=0;
    a:=exp1.evalS;
    b:=exp2.evalS;
    if exp3=nil then
           begin
              if CharacterByte then
                result:=pos2(a,b)
              else
                result:=UTF8Pos2(a,b)
           end
    else
          begin
             m:=exp3.evalInteger;
             if CharacterByte then
                 result:=pos3(a,b,m)
             else
                 result:=UTF8Pos3(a,b,m)

          end;
end;

function  POSfnc:TPrincipal;
begin
    POSfnc:=NOperation(TPos.create)
end;

{****}
{BVAL}
{****}
type
   TBVAL=class(TMiscReal)
      exp:TPrincipal;
      bin:boolean;
      constructor create;
      function evalX:Extended;override;
      destructor destroy;override;
    end;

function  BVALfnc:TPrincipal;
begin
    BVALfnc:=NOperation(TBVAL.create)
end;

constructor TBVAL.create;
begin
    inherited create;
    check('(',IDH_STRING_FUNCTIONS);
    exp:=SExpression;
    check(',',IDH_STRING_FUNCTIONS);
    if token='2' then
       begin gettoken; bin:=true end
    else
       checkToken1('16',IDH_STRING_FUNCTIONS);
    check(')',IDH_STRING_FUNCTIONS);
end;

function TBVAL.evalX:extended;
var
  s:ansistring;
  i:integer;
  t:extended;
  c:char;
Label
  ErrorExit;
begin
    s:=exp.evalS;
    if bin then
       begin
          result:=0.;
          t:=1.;
          i:=length(s);
          while i>0 do
            begin
               case s[i] of
                  '0' : ;
                  '1' : result:=result + t;
                  else  goto ErrorExit;
               end;
               t:=t*2.;
               dec(i)
            end;
       end
    else
       begin
          result:=0;
          t:=1.;
          i:=length(s);
          while i>0 do
            begin
               c:=s[i];
               case c of
                  '0'..'9' : result:=result + t * (ord(c)-ord('0'));
                  'A'..'F' : result:=result + t * (ord(c)-ord('A')+10);
                  'a'..'f' : result:=result + t * (ord(c)-ord('a')+10);
                  else  goto ErrorExit;
               end;
               t:=t*16.;
               dec(i)
            end;
       end;
    exit;

 ErrorExit:
    setexceptionwith('BVAL',4201);
end;

destructor TBVAL.destroy;
begin
    exp.free;
    inherited destroy;
end;

{************}
{VAL function}
{************}
type
   TVAL=class(TLEN)       //TLENのconstructorを流用する
     procedure evalN(var n:number);override;
     function evalF:double;override;
     procedure evalC(var x:complex);override;
     procedure evalR(var r:PNumeric);override;
     function OverflowErCode:integer;override;
     function OpName:string;override;
   end;

function  VALfnc:TPrincipal;
begin
    VALfnc:=NOperation(TVAL.create)
end;

function TVAL.OverflowErCode:integer;
begin
  result:=1004
end;

function TVal.OpName:string;
begin
  result:='VAL'
end;

procedure TVAL.evalN(var n:number);
var
    t:ansistring;
begin
    t:= exp.evalS;
    try
       Nval(t,n);
       checkrangedecimal(n,1004);
    except
       on EExtype do
       begin
          if extype>=3000 then
             extype:=4001;
          if (extype>=1000) and (extype <1004) then
             extype:=1004;
          if extype>0 then
             statusmes.add('VAL("'+t+'")');
          raise
       end;
    end;
end;

function TVAL.evalF:double;
var
   n:number;
begin
  evalN(n);
  currentOperation:=self;
  result:=extendedVal(n);
  currentoperation:=nil;
end;

procedure TVAL.evalC(var x:complex);
begin
    x.x:=evalF;
    x.y:=0
end;

procedure TVAL.evalR(var r:PNumeric);
var
   n:number;
begin
   evalN(n);
   disposeNumeric(r);
   r:=NewRationalFromNumber(@n);
end;

{******}
{EXTYPE}
{******}
type
    TEXTYPE=class(TMiscInt)
          whenBlock:TWhenException;
        constructor create;
        function evalLongint:longint;override;
      end;

constructor TEXTYPE.create;
begin
   inherited create;
   with WhenUseStack do WhenBlock:=items[count-1];
   if WhenBlock=nil then seterr(prevtoken+s_CantBelongHere,IDH_WHEN);
end;

function TEXTYPE.evalLongint:longint;
begin
     result:=whenBlock.svextype;
end;

type
    TEXTYPEinHandler=class(TMiscInt)
          Handler:THandler;
        constructor create;
        function evalLongint:longint;override;
      end;

constructor TEXTYPEinHandler.create;
begin
   inherited create;
   handler:=LocalRoutine as THandler;
end;

function TEXTYPEinHandler.evalLongint:longint;
begin
     with handler.WhenUseBlockStack do
          result:=TWhenException(items[count-1]).svextype;
end;


function EXTYPEfnc:TPrincipal;
begin
  if (LocalRoutine=nil) or not (LocalRoutine is THandler) then
     EXTYPEfnc:=NOperation(TEXTYPE.create)
  else
     EXTYPEfnc:=NOperation(TEXTYPEinHandler.create)
end;


type
   TEXLINE=class(TEXTYPE)
        function evalLongint:longint;override;
   end;

function TEXLINE.evalLongint:longint;
begin
     result:=whenBlock.svStatementEx.LabelNumb;
end;

type
   TEXLINEinHandler=class(TEXTYPEinHandler)
        function evalLongint:longint;override;
   end;

function TEXLINEinHandler.evalLongint:longint;
begin
     with handler.WhenUseBlockStack do
          result:=TWhenException(items[count-1]).svStatementEx.labelnumb;
end;

function EXLINEfnc:TPrincipal;
begin
  if (LocalRoutine=nil) or not (LocalRoutine is THandler) then
     EXLINEfnc:=NOperation(TEXLINE.create)
  else
     EXLINEfnc:=NOperation(TEXLINEinHandler.create)
end;

{*************}
{DOT function }
{*************}


type
   TDOT=class(TPrincipal)
       mat1,MAT2:TMatrix;
    constructor create;
    destructor destroy;override;
    procedure evalN(var n:number);override;
    function evalF:double;override;
    procedure evalC(var x:complex);override;
    procedure evalR(var x:PNumeric);override;
    function overflowErCode:integer;override;
    end;

function  DOTfnc:TPrincipal;
begin
    DOTfnc:=NOperation(TDOT.create)
end;

constructor TDOT.create;
begin
    inherited create;
    check('(',IDH_ARRAY_FUNCTION);
    mat1:=Nmatrix;
    check(',',IDH_ARRAY_FUNCTION);
    mat2:=Nmatrix;
    check(')',IDH_ARRAY_FUNCTION);
    if (mat1=nil) or (mat2=nil) or (mat1.idr.dim<>1) or (mat2.idr.dim<>1) then
                              begin seterrDimension(IDH_ARRAY_FUNCTION);{done;fail} end;
end;

destructor TDoT.destroy;
begin
     mat1.free;
     mat2.free;
    inherited destroy;
end;

procedure TDoT.evalN(var n:number);
var
   p:TVar;
begin
    currentOperation:=self;
    p:=TArray(mat1.point).dotproduct(TArray(mat2.point));
    if p<>nil then
      begin
        TNVar(p).getN(n);
        p.free;
      end;
    currentoperation:=nil;
end;

function TDoT.evalF:double;
var
   p:TVar;
begin
    currentOperation:=self;
    p:=TArray(mat1.point).dotproduct(TArray(mat2.point));
    if p<>nil then
       begin
            TbasisFVar(p).getF(result);
            p.free;
       end;
    currentoperation:=nil;
end;

procedure TDoT.evalC(var x:complex);
var
   p:TVar;
begin
    currentOperation:=self;
    p:=TArray(mat1.point).dotproduct(TArray(mat2.point));
    if p<>nil then
       begin
            TBasisCVar(p).getC(x);
            p.free;
       end;
    currentoperation:=nil;
end;


procedure TDoT.evalR(var x:PNumeric);
var
   p:TVar;
begin
    currentOperation:=self;
    p:=TArray(mat1.point).dotproduct(TArray(mat2.point));
    if p<>nil then
       begin
            TRVar(p).getR(x);
            p.free;
       end;
    currentoperation:=nil;
end;

function TDOT.overflowErCode:integer;
begin
  result:=1009
end;

{*************}
{DET function }
{*************}

type
  TDET=class(TPrincipal)
       //mat:TMatrix;
       matexp1:TMatExp;                                         //ver.8.1.5.0
    constructor create;
    destructor destroy;override;
    procedure evalN(var n:number);override;
    function evalF:double;override;
    procedure evalC(var x:complex);override;
    procedure evalR(var x:PNumeric);override;
    function overflowErCode:integer;override;
  end;

function  DETfnc:TPrincipal;
begin
    DETfnc:=NOperation(TDET.create)
end;

constructor TDET.create;
begin
    inherited create;
    check('(',IDH_ARRAY_FUNCTION);
    matexp1:=matexp;
    // if (mat.idr.dim<>2) then
    //            begin seterrdimension(IDH_ARRAY_FUNCTION) ;{done;fail} end;
    check(')',IDH_ARRAY_FUNCTION);
end;

destructor TDET.destroy;
begin
    matexp1.free;
    inherited destroy;
end;

procedure TDET.evalN(var n:number);
var
    p:TNArray;
    d:integer;
    sz:array4;
begin
    matexp1.AskActSize(d,sz);
    p:=TNArray.createNative(d,sz);
    matexp1.evalA(p);
    currentOperation:=self;
    (p as TNArray).determinant(n);
    currentoperation:=nil;
    p.free;
end;

function TDET.evalF:double;
var
    p:TFArray;
    d:integer;
    sz:array4;
begin
    matexp1.AskActSize(d,sz);
    p:=TFArray.createNative(d,sz);
    matexp1.evalA(p);
    currentOperation:=self;
    (p as TFArray).determinant(result);
    currentoperation:=nil;
    p.free;
end;

procedure TDET.evalC(var x:complex);
var
    p:TArray;
    d:integer;
    sz:array4;
begin
    matexp1.AskActSize(d,sz);
    p:=TCArray.createNative(d,sz);
    matexp1.evalA(p);
    currentOperation:=self;
    (p as TCArray).determinant(x);
    currentoperation:=nil;
    p.free;
end;

procedure TDET.evalR(var x:PNumeric);
var
    p:TArray;
    d:integer;
    sz:array4;
begin
    matexp1.AskActSize(d,sz);
    p:=TRArray.createNative(d,sz);
    matexp1.evalA(p);
    currentOperation:=self;
    (p as TRArray).determinant(x);
    currentoperation:=nil;
    p.free;
end;

function TDET.overflowErCode:integer;
begin
  result:=1009
end;

{**********}
{ColorIndex}
{**********}
type
   TColorIndex=class(TMiscInt)
      exp1,exp2,exp3:TPrincipal;
      constructor create;
      function evalLongint:longint;override;
      destructor destroy;override;
    end;

constructor TColorIndex.create;
begin
    inherited create;
    check('(',IDH_STRING_FUNCTIONS);
    exp1:=NExpression;
    check(',',IDH_STRING_FUNCTIONS);
    exp2:=NExpression;
    check(',',IDH_STRING_FUNCTIONS);
    exp3:=NExpression;
    check(')',IDH_STRING_FUNCTIONS);
end;

destructor TColorIndex.destroy;
begin
     exp1.free;
     exp2.free;
     exp3.free;
     inherited destroy;
end;

function TColorIndex.evalLongint:longint;
var
    r,g,b: extended;
    //m:longint;
begin
    r:=exp1.evalX;
    g:=exp2.evalX;
    b:=exp3.evalX;

    if (r<0) or (r>1) or (g<0) or (g>1) or (b<0) or (b>1) then
         result:=-1
    else
         result:=
           MyPalette.colorindex(LongIntRound(r*255)
                                +LongIntRound(g*255)*$100
                                +LongIntRound(b*255)*$10000);

end;

function  ColorIndexfnc:TPrincipal;
begin
    ColorIndexfnc:=NOperation(TColorIndex.create)
end;




{**********}
{initialize}
{**********}


procedure  FunctionTableInit;
begin
   if (PrecisionMode=PrecisionNormal) or
      (PrecisionMode=PrecisionRational) and UseTranscendentalFunction then
       SuppliedFunctionTableInit('SQR' , SQRfnc1)
   else if PrecisionMode in [PrecisionHigh,PrecisionNative] then
       SuppliedFunctionTableInit('SQR' , SQRfnc2)
   else if (PrecisionMode=PrecisionRational) and not UseTranscendentalFunction then
       SuppliedFunctionTableInit('SQR' , NotExistFnc)
    ;
   if precisionMode in [PrecisionNormal, PrecisionHigh,PrecisionNative] then
       SuppliedFunctionTableInit('ABS',ABSfnc );

   if precisionMode in [PrecisionNormal,PrecisionHigh,PrecisionNative,PrecisionComplex] then
    begin
       SuppliedFunctionTableInit('CEIL' ,  CEILfnc);
       SuppliedFunctionTableInit('FP', FPfnc);
       SuppliedFunctionTableInit('INT' ,INTfnc );
       SuppliedFunctionTableInit('IP' ,IPfnc );
       SuppliedFunctionTableInit('MAX' , MAXfnc);
       SuppliedFunctionTableInit('MIN' ,  MINfnc);
       SuppliedFunctionTableInit('MOD' ,  MODfnc );
       SuppliedFunctionTableInit('REMAINDER' , REMAINDERfnc);
       SuppliedFunctionTableInit('SGN',SGNfnc );
       SuppliedFunctionTableInit('ROUND' ,ROUNDfnc );
       SuppliedFunctionTableInit('TRUNCATE',TRUNCATEfnc );
       SuppliedFunctionTableInit('EPS' ,  EPSfnc);

       SuppliedFunctionTableInit('FACT',FACTfnc );
       SuppliedFunctionTableInit('PERM',PERMfnc );
       SuppliedFunctionTableInit('COMB',COMBfnc );
     end;

   if (PrecisionMode=PrecisionRational) then
       SuppliedFunctionTableInit('EPS' ,NotExistFnc);


       SuppliedFunctionTableInit('POS',POSfnc );
       SuppliedFunctionTableInit('VAL',VALfnc );
       SuppliedFunctionTableInit('LEN',LENfnc );
       SuppliedFunctionTableInit('BLEN',BLENfnc );
       SuppliedFunctionTableInit('MAXLEN',MAXLENfnc );
       SuppliedFunctionTableInit('MAXSIZE',MAXSIZEfnc );
       SuppliedFunctionTableInit('ORD',ORDfnc );
       SuppliedFunctionTableInit('BVAL',BVALfnc );

       SuppliedFunctionTable.accept('LBOUND',LBOUNDfnc);
       SuppliedFunctionTable.accept('UBOUND',UBOUNDfnc);
       SuppliedFunctionTable.accept('SIZE',  SIZEfnc);

       SuppliedFunctionTable.accept('DET',   DETfnc);
       SuppliedFunctionTable.accept('DOT',   DOTfnc);

       SuppliedFunctionTableInit('COLORINDEX',ColorIndexfnc );

    {**************}
    {reserved words}
    {**************}
       ReservedWordTableInit('TIME', TIMEfnc);
       ReservedWordTableInit('DATE', DATEfnc);
       ReservedWordTableInit('RND' , RNDfnc );

       ReservedWordTableInit('EXTYPE', EXTYPEfnc );
       ReservedWordTableInit('EXLINE', EXLINEfnc);

       ReservedWordTableInit('NOT',  RESERVEDWORDfnc);
       ReservedWordTableInit('ELSE' ,RESERVEDWORDfnc);
       ReservedWordTableInit('PRINT',RESERVEDWORDfnc);
       ReservedWordTableInit('REM',  RESERVEDWORDfnc);
       ReservedWordTableInit('CON',  RESERVEDWORDfnc);
       ReservedWordTableInit('IDN',  RESERVEDWORDfnc);
       ReservedWordTableInit('ZER',  RESERVEDWORDfnc);
       ReservedWordTableInit('NUL$', RESERVEDWORDfnc);
       ReservedWordTableInit('TRANSFORM',RESERVEDWORDfnc);

end;

begin
   tableInitProcs.accept(FunctionTableInit);
end.
