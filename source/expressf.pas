unit expressf;
{$IFDEF FPC}
  {$MODE DELPHI} {$H+}
{$ENDIF}

(***************************************)
(* Copyright (C) 2006, SHIRAISHI Kazuo *)
(***************************************)


interface
uses variabl,express,arithmet,variabls,float;

procedure SwitchToNativeMode;

function MicrosoftNExpression:TPrincipal;


type
    TNExpression=class(TPrincipal)
       constructor create;
       procedure EvalN(var n:number);override;
       function evalX:extended;override;
       function evalInteger:integer;override;
       function evalLongint:integer;override;
       function str:ansistring;override;
       function str2:ansistring;override;
       function compare(p:TPrincipal):integer;override;
       function kind:char;override;
       function substance0(ByVal:boolean):TVar;override;
       procedure disposeSubstance0(p:TVar; ByVal:boolean);override;
       function substance1:TVar;override;
       procedure disposeSubstance1(p:TVar);override;
    end;

type
   TFundBinOp=class(TNExpression)
          constructor create(e1,e2:TPrincipal);virtual;
          function OverflowErCode:integer;override;
          function InvalidErCode:integer;override;
     end;


 Type
   TFundBinOpNormal=class(TFundBinOp)
             exp1,exp2:TPrincipal;
          constructor create(e1,e2:TPrincipal);override;
          destructor destroy;override;
      end;
type
   TADD=class(TFundBinOpNormal)
          function evalF:double;override;
   end;

   TSUB=class(TFundBinOpNormal)
          function evalF:double;override;
   end;

   TMUL=class(TFundBinOpNormal)
          function evalF:double;override;
   end;

   TDIV=class(TFundBinOpNormal)
          function evalF:double;override;
   end;

Type
   TFundBinOpwithConst=class(TFundBinOp)
             exp1:TPrincipal;
             ValueF:double;
          constructor create(e1,e2:TPrincipal);override;
          destructor destroy;override;
      end;
type
   TADDNC=class(TFundBinOpWithConst)
          function evalF:double;override;
   end;

   TSUBNC=class(TFundBinOpWithConst)
          function evalF:double;override;
   end;

   TMULNC=class(TFundBinOpWithConst)
          function evalF:double;override;
    end;

   TDIVNC=class(TFundBinOpWithConst)
          function evalF:double;override;
   end;

type
   TADDCN=class(TFundBinOpWithConst)
          function evalF:double;override;
    end;

   TSUBCN=class(TFundBinOpWithConst)
          function evalF:double;override;
   end;

   TMULCN=class(TFundBinOpWithConst)
          function evalF:double;override;
   end;

   TDIVCN=class(TFundBinOpWithConst)
          function evalF:double;override;
   end;

implementation
uses struct,math,base,texthand,helpctex,sconsts;



type
   TUnaryOp=class(TNExpression)
             exp:TPrincipal;
             opF:FloatFunction1;
             opX:ExtendedFunction1;
             overflowcode:smallint;
             invalidcode:smallint;
             name:ansistring;
          constructor create(e:TPrincipal;
                                 op1:FloatFunction1;op2:extendedfunction1;
                                       er1,er2:smallint;const n:ansistring);virtual;
          function evalF:double;override;
          function OverflowErCode:integer;override;
          function InvalidErCode:integer;override;
          function OpName:string;override;
          destructor destroy;override;
     end;

   TBinaryOp=class(TNExpression)
             exp1,exp2:TPrincipal;
             opF:FloatFunction2;
             opX:ExtendedFunction2;
             overflowcode:smallint;
             invalidcode:smallint;
             name:ansistring;
          constructor create(e1,e2:TPrincipal;
                              op1:FloatFunction2;op2:extendedfunction2;
                                        er1,er2:smallint;const n:ansistring);virtual;
          function evalF:double;override;
          function OverflowErCode:integer;override;
          function InvalidErCode:integer;override;
          function OpName:string;override;
          destructor destroy;override;
     end;

type
   TNConstant=class(TNExpression)
              valueF:double;
           constructor create(var n:number);
           constructor create2(x:double);
           function evalF:double;override;
           destructor destroy;override;
           function isConstant:boolean;override;
       end;

type
   TNFunction=class(TNExpression)
          exe   :TCALL;
          constructor create(idr:TIdrec);
          function evalF:double;override;
          destructor destroy;override;
     end;

type
     TUnaryOpClass = class of TUnaryOp;
     TBinaryOpClass = class of TBinaryOp;

{*****************}
{numeric expresion}
{*****************}

constructor TNExpression.create;
begin
   inherited create;
end;



function TNexpression.kind:char;
begin
   kind:='n'
end;



constructor TNFunction.create(idr:TIdrec);
begin
   inherited Create;
   exe:=TCALL.createF(idr) ;
end;

destructor TNFunction.destroy;
begin
   exe.free;
   inherited destroy
end;

type
  TFpuSave = record
    p:array [0..6] of Cardinal;
    f:array [0..7] of extended;
  end;

{*********}
{TNConstant}
{*********}



constructor TNConstant.create(var n:number);
var
  flag:boolean;
begin
  inherited create;
  flag:=false;
  {$IFNDEF WINDOWS};SetFPUMask(NormalCW);{$ENDIF}
  try
    valueF:=extendedval(N);
  except
    {$IFNDEF WINDOWS}ClearExceptions(False);{$ENDIF}
    flag:=true;
  end;
  {$IFNDEF WINDOWS}SetFPUMask(OriginalCW);{$ENDIF}
  if flag  then
      seterr(s_TooLargeConstant,IDH_JIS_5);
end;

constructor TNConstant.create2(x:double);
begin
    inherited create;
    valueF:=x;
end;

destructor TNConstant.destroy;
begin
   inherited destroy;
end;

function TNConstant.isConstant:boolean;
begin
   isConstant:=true
end;




{*****************}
{numeric operation}
{*****************}


constructor TunaryOp.create(e:TPrincipal; op1:FloatFunction1; op2:ExtendedFunction1;
                            er1,er2:smallint;const n:ansistring);
begin
    inherited  create;
    exp:=e;
    opF:=op1;
    opX:=op2;
    overflowcode:=er1;
    invalidcode:=er2;
    name:=n;
end;

destructor TunaryOp.destroy;
begin
   exp.free;
   inherited destroy;
end;

constructor TBinaryOp.create(e1,e2:TPrincipal; op1:FloatFunction2; op2:ExtendedFunction2;
                              er1,er2:smallint;const n:ansistring );
begin
    inherited  create;
    exp1:=e1;
    exp2:=e2;
    opF:=op1;
    opX:=op2;
    overflowcode:=er1;
    invalidcode:=er2;
    name:=n;
end;

destructor TBinaryOp.destroy;
begin
   exp1.free;
   exp2.free;
   inherited destroy;
end;

function UnaryOp( e:TPrincipal;op1:FloatFunction1;op2:extendedfunction1;
                   er1,er2:smallint;opclass:TUnaryOpClass;const name:ansistring):TPrincipal;
{$MAXFPUREGISTERS 0}
var
   p:TPrincipal;
   n:number;
   x:double;
   flag:boolean;
begin
   p:=opClass.create(e,op1,op2,er1,er2,name);
   if e.isConstant then
     begin
       flag:=true;
      {$IFNDEF WINDOWS} SetFPUMask(NormalCW);{$ENDIF}
       try
          x:=p.evalF;
       except
        {$IFNDEF WINDOWS}ClearExceptions(False);{$ENDIF}
         flag:=false;
       end;
        {$IFNDEF WINDOWS}SetFPUMask(OriginalCW);{$ENDIF}
       if flag then
         begin
           p.free;
           p:=TNConstant.create2(x);
         end
       else
         extype:=0;
     end;
    UnaryOp:=p
end;


function BinaryOp( e1,e2:TPrincipal;  op1:FloatFunction2; op2:ExtendedFunction2;
                 er1,er2:smallint; opclass:TBinaryOpClass;const name:ansistring):TPrincipal;
{$MAXFPUREGISTERS 0}
var
   p:TPrincipal;
   n:number;
   x:double;
   flag:boolean;
begin
   p:=opClass.create(e1,e2,op1,op2,er1,er2,name);
   if e1.isConstant and e2.isConstant then
     begin
       flag:=true;
      {$IFNDEF WINDOWS}SetFPUMask(NormalCW);{$ENDIF}
       try
          x:=p.evalF;
       except
         {$IFNDEF WINDOWS} ClearExceptions(False);{$ENDIF}
         flag:=false;
       end;
       {$IFNDEF WINDOWS}SetFPUMask(OriginalCW);{$ENDIF}
       if flag then
         begin
            p.free;
            p:=TNConstant.create2(x);
         end
       else
         begin
           extype:=0;
         end;
      end;
   BinaryOp:=p
end;


type
   TPower=class(TBinaryOp)
          function evalF:double;override;
   end;

   TOppose=class(TUnaryOp)
          function evalF:double;override;
   end;

   TSquare=class(TUnaryOp)
          function evalF:double;override;
   end;

   TMSYEN=class(TBinaryOp)
          function evalF:double;override;
   end;

   TMSMOD=class(TBinaryOp)
          function evalF:double;override;
   end;





function OpSquare(e1:TPrincipal):TPrincipal;
begin
  result:=UnaryOp(e1,nil{float.Square},nil,1002,1002,TSquare{TUnaryOp},'^')
end;

function  OpUnaryMinus(e1:TPrincipal):TPrincipal;
begin
     result:=UnaryOp(e1,nil,nil,1002,1002,TOppose,'-');
end;

function OpPower(e1,e2:TPrincipal):TPrincipal;
begin
   result:=BinaryOp(e1,e2,nil,nil,1002,1002,TPower,'^')
end;

function OpMSYen(e1,e2:TPrincipal):TPrincipal;
begin
    result:=BinaryOp(e1,e2, nil,nil,1002,1002,TMSYEN,'\');
end;

function OpMSMod(e1,e2:TPrincipal):TPrincipal;
begin
    result:=BinaryOp(e1,e2, nil,nil,1002,1002,TMSMOD,'MOD');
end;



type
   TFundBinOpClass=class of TFundBinOp;

constructor TFundBinOp.create(e1,e2:TPrincipal);
begin
   inherited create;
end;

function TFundBinOp.OverflowErCode:integer;
begin
   result:=1002;
end;

function TFundBinOp.InvalidErCode:integer;
begin
   result:=3001
end;



constructor TFundBinOpNormal.create(e1,e2:TPrincipal);
begin
   inherited create(e1,e2);
   exp1:=e1;
   exp2:=e2;
end;

destructor TFundBinOpNormal.destroy;
begin
   exp2.free;
   exp1.Free;
   inherited destroy;
end;



constructor TFundBinOpWithConst.create(e1,e2:TPrincipal);
begin
   inherited create(e1,e2);
   exp1:=e1;
   valueF:=TNConstant(e2).valueF;
   e2.free;
end;

destructor TFundBinOpwithConst.destroy;
begin
   exp1.free;
   inherited destroy;
end;




function FundBinOp(e1,e2:TPrincipal;
             OpNN,OPNC,OPCN:TFundBinOpClass):TPrincipal;
var
   p:TPrincipal;
   x:double;
   flag:boolean;
begin
  if e1.isConstant then
     begin
        if e2.isConstant then
           begin
             p:=OpNN.create(e1,e2);
             flag:=true;
            {$IFNDEF WINDOWS}SetFPUMask(NormalCW);{$ENDIF}
             try
                x:=p.evalF;
            except
             {$IFNDEF WINDOWS}ClearExceptions(False); {$ENDIF}
                flag:=false
             end;
            {$IFNDEF WINDOWS}SetFPUMask(OriginalCW);{$ENDIF}
            if flag then
               begin
                  p.free;
                  p:=TNConstant.create2(x);
               end
             else
                begin
                 extype:=0;
                end;
           end
        else
            p:=OpCN.create(e2,e1);
      end
   else
      begin
        if e2.isConstant then
            p:=OpNC.create(e1,e2)
        else
            p:=OpNN.create(e1,e2);
      end;
   FundBinOp:=p
end;


function OpTimes(e1,e2:TPrincipal):TPrincipal;
begin
  result:=FundBinOp(e1,e2,TMUL,TMULNC,TMULCN);
end;

function OpDivide(e1,e2:TPrincipal):TPrincipal;
begin
  result:=FundBinOp(e1,e2,TDIV,TDIVNC,TDIVCN);
end;

function OpPlus(e1,e2:TPrincipal):TPrincipal;
begin
  result:=FundBinOp(e1,e2,TADD,TADDNC,TADDCN);
end;

function OpMinus(e1,e2:TPrincipal):TPrincipal;
begin
  result:=FundBinOp(e1,e2,TSUB,TSUBNC,TSUBCN);
end;



function NConst(var n:number):TPrincipal;
begin
   NConst:=TNConstant.create(n)
end;

function NFunction(idr:TIdrec):TPrincipal;
begin
   NFunction:=TNFunction.create(idr)
end;

function NewNumericVariN:TVar;
begin
   result:=TNvar.create
end;

function
   NewNumericArrayN(dim:integer;const lbound,ubound:Array4):TVar;
begin
   result:=TNArray.create(dim,lbound,ubound,0)
end;


{*********}
{Micorsoft}
{*********}

procedure MSOR(var x,y:double);
begin
    x:=  LongIntRound(x)
      or LongIntRound(y);
end;

procedure MSAND(var x,y:double);
begin
    x:=  LongIntRound(x)
     and LongIntRound(y);
end;

procedure MSNOT(var x:double);
begin
    x:=not LongIntRound(x);
end;

type
   TMSComparison=class(TNExpression)
       exp:TLogical;
    constructor create(x:TLogical);
     function evalF:double;override;
    destructor destroy;override;
   end;

function MSComparison:TPrincipal;
var
   x:TPrincipal ;
   f:comparefunction;
   sp:tokenspecification;
begin
   sp:=tokenspec;
   if token='(' then sp:=nexttokenspec;
   case sp of
      SCon,Sidf:
        begin
          x:=SExpression;
          repeat
                findcomparefunction(token,f);
                gettoken;
                x:=TMSComparison.create(TComparisonS.create(x,SExpression,f)) ;
          until  tokenspec<>relational;
        end;
      else
        begin
          x:=JISNExpression;
          while tokenspec=relational do
              begin
                findcomparefunction(token,f);
                gettoken;
                x:=TMSComparison.create(TComparisonN.create(x,JISNExpression,f))
              end;
        end;
   end;
   while tokenspec=relational do
       begin
         findcomparefunction(token,f);
         gettoken;
         if x.kind='n' then
            x:=TMSComparison.create(TComparisonN.create(x,JISNExpression,f))
         else
            x:=TMSComparison.create(TComparisonS.create(x,SExpression,f)) ;
       end;
   result:=x;
end;

constructor TMSComparison.create(x:TLogical);
begin
   inherited create;
   exp:=x;
end;

function TMSComparison.evalF:double;
begin
   result:=-shortint(exp.evalBool);
end;

destructor TMSComparison.destroy;
begin
   exp.free;
   inherited destroy;
end;


function MSNotFactor:TPrincipal;
begin
   if token='NOT' then
         begin
          gettoken;
          result:=UnaryOp(MSNotFactor, MSNOT, nil,1002,1002,TUnaryOp,'NOT');
         end
   else
      result:=MSComparison;
end;


function MSAndTerm:TPrincipal;
var
    exp:TPrincipal ;
    op:char;
begin
    MSAndTerm:=nil;
    exp:=MSNotFactor;
    while (token='AND') and (exp<>nil)  do
       begin
           gettoken;
           exp:=BinaryOp(exp,MSNotFactor,MSAND,nil,1002,1002,TBinaryOp,'AND');
       end;
    MSAndTerm:=exp
end;

function MicrosoftNExpression:TPrincipal;
var
    exp:TPrincipal ;
    op:char;
begin
    MicrosoftNExpression:=nil;
    exp:=MSAndTerm;
    while (token='OR') and (exp<>nil)  do
       begin
           gettoken;
           exp:=BinaryOp(exp,MSAndTerm,MSOR, nil,1002,1002,TBinaryOp,'OR');
       end;
    MicrosoftNExpression:=exp
end;



{************}
{Unary Binary}
{************}

function Unary(op1:unaryoperation; op2:floatfunction1;er2:smallint;const name:ansistring):TPrincipal;
begin
   Unary:=UnaryOp(argumentN1,op2,nil,1003,er2,ExpressF.TUnaryOp,name)
end;

function Binary(op1:binaryoperation; op2:floatfunction2; er2:smallint;const name:ansistring):TPrincipal;
var
   a1:TPrincipal;
begin
   a1:=argumentN2a;
   Binary:=BinaryOp(a1,ArgumentN2b,op2,nil,1003,er2,ExpressF.TBinaryOp,name)

end;

type
  TUnaryX=class(TUnaryOp)
      function evalF:double;override;
   end;

  TBinaryX=class(TBinaryOp)
     function evalF:double;override;
   end;


function UnaryX(op2:extendedfunction1;er2:smallint;const name:ansistring):TPrincipal;
begin
    UnaryX:=UnaryOp(argumentN1,nil,op2,1003,er2,TUnaryX,name)
end;

function BinaryX(op2:extendedfunction2; er2:smallint;const name:ansistring):TPrincipal;
var
   a1:TPrincipal;
begin
   a1:=argumentN2a;
   BinaryX:=BinaryOp(a1,ArgumentN2b,nil,op2,1003,er2,TBinaryX,name)
end;

{**********}
{NOperation}
{**********}
type
  TNOperation=class(TNExpression)
       Op:TPrincipal;
    constructor Create(e1:TPrincipal);
    function evalF:double; override;
    destructor destroy;override;
  end;

constructor TNOperation.Create(e1:TPrincipal);
begin
   inherited create;
   op:=e1;
end;

destructor TNOperation.destroy;
begin
   op.free;
   inherited destroy;
end;

function NOperation(op:TPrincipal):TPrincipal ;
begin
   result:=TNOperation.create(op);
end;

{****************}
{Execute Routines}
{****************}

function TNExpression.evalX:extended;
begin
   result:=evalF;

end;

function TNExpression.str:ansistring;
var
    n:number;
begin
    convert(evalF,n);
    str:=Dstr(n)+' '
end;


function TNExpression.str2:ansistring;
var
  svsigniwidth:integer;
begin
    svsigniwidth:=signiwidth;
    signiwidth:=17;
    str2:=str;
    signiwidth:=svsigniwidth;

end;

function TNExpression.evalInteger:longint;
var
   n:double;
begin
   n:=evalF;
   if n>=maxint then result:=maxint
   else if n<=MinInt then result:=MinInt
   else result:=system.round(n);
end;

function TNExpression.evalLongint:longint;
begin
   result:=LongIntRound(evalF);
end;

procedure TNExpression.EvalN(var n:number);
begin
   convert(evalF,n)
end;


function TNExpression.substance0(ByVal:boolean):TVar;
begin
    substance0:=TorthoFVar.createF(evalF)
end;

procedure TNExpression.disposeSubstance0(p:TVar; ByVal:boolean);
begin
     p.free;
end;

function TNExpression.substance1:TVar;
begin
   substance1:=TorthoFVar.createF(evalF)
end;


procedure TNExpression.disposeSubstance1(p:TVar);
begin
     p.free;
end;

function TNExpression.compare(p:TPrincipal):integer;
var
   n1,n2:double;
begin
   n1:=evalF;
   n2:=p.evalF;
   compare:=fcompare(n1,n2);
end;





function TNFunction.evalF:double;
begin
   result:=exe.evalF;
end;

function TNConstant.evalF:double;
begin
    result:=valueF;
end;

const
    minstack=sizeof(Number)*6 ;



function TUnaryOp.evalF:double;
begin
   result:=exp.evalF;
   currentoperation:=self;
   opF(result);
   currentoperation:=nil;
 end;

function TUnaryOp.OverflowErCode:integer;
begin
   result:=OverFlowCode
end;

function TUnaryOp.InvalidErCode:integer;
begin
   result:=InvalidCode;
end;

function TUnaryOp.OpName:string;
begin
   result:=name;
end;

function TBinaryOp.OverflowErCode:integer;
begin
   result:=OverFlowCode
end;

function TBinaryOp.InvalidErCode:integer;
begin
   result:=InvalidCode;
end;

function TBinaryOp.OpName:string;
begin
   result:=name;
end;





function TBinaryOp.evalF:double;
{$MAXFPUREGISTERS 0}
var
   y:double;
begin
   result:=exp1.evalF;
   y:=exp2.evalF;
   opF(result,y);
end;


function TDIV.evalF:double;       //ここから
{$MAXFPUREGISTERS 0}
begin
  result:=exp1.evalF
               /exp2.evalF;
 end;

function TDIVCN.evalF:double;
begin
   result:=ValueF
           / exp1.evalF
end;

function TDIVNC.evalF:double;
begin
   result:=exp1.evalF
          / ValueF;
end;


function TADD.evalF:double;   //ここまで　アドレス範囲をstruct.extypeof関数で使用する
{$MAXFPUREGISTERS 0}
begin
   result:=exp1.evalF+exp2.evalF;
end;

function TSUB.evalF:double;
{$MAXFPUREGISTERS 0}
begin
   result:=exp1.evalF-exp2.evalF;
end;

function TMUL.evalF:double;
{$MAXFPUREGISTERS 0}
begin
  result:=exp1.evalF*exp2.evalF;
end;


function TADDNC.evalF:double;
begin
   result:=exp1.evalF
          + ValueF;
end;

function TSUBNC.evalF:double;
begin
   result:=exp1.evalF
           - ValueF;
end;

function TMULNC.evalF:double;
begin
   result:=exp1.evalF
          * ValueF;
end;


function TADDCN.evalF:double;
begin
   result:=ValueF
           + exp1.evalF;
end;

function TSUBCN.evalF:double;
begin
   result:=ValueF
           - exp1.evalF;
end;

function TMULCN.evalF:double;
begin
   result:=ValueF
           * exp1.evalF;
end;




function PowerSub(Base,Exponent:extended):extended;
begin
    if ABS(BASE-1)>0.125 then
       Result:=NPXPower(Base,Exponent) {Exp(Exponent * Ln(Base)) }
    else
       Result:=NPXPower1Plus(Base-1,Exponent);
    {$IFDEF CPU64} // bug? on FPC
    if abs(result)>maxnumberDouble  then
       setexception(1002);
    {$ENDIF}
end;

function Power(Base, Exponent: Extended): double {結果を丸めて誤差を消去};
begin
  if Exponent = 0.0 then
     Result := 1.0
  else if Base>0 then
       result:=Powersub(base,exponent)
  else if Base=0 then
     begin
       if Exponent>0 then
          result:=0
       else if Exponent=0 then
          result:=1
       else
          begin
            result:=0;
            setexception(3003)
          end
     end
  else if Frac(Exponent)=0 then
       if Frac(Exponent/2)=0 then
          result:=power(-base,exponent)
       else
          result:=-power(-base,exponent)
  else
      begin
        result:=0.0;
        setexception(3002) ;
      end;
end;

{$IFDEF Linux}
function TPower.evalF:double;
var
   x,y:double;
begin
   x:=exp1.evalF;
   y:=exp2.evalF;
   CurrentOperation:=self;
   result:=power(x,y);
   CurrentOperation:=nil;
end;
{$ELSE}
function TPower.evalF:double;
begin
   result:=power(exp1.evalF,exp2.evalF);
 end;
{$ENDIF}

function TOppose.evalF:double;
begin
    result := - exp.evalF;
end;

function TSquare.evalF:double;
begin
   result:=exp.evalF;
   Result:=Result*Result;
 end;

function TMSYEN.evalF:double;
var
    a,b:longint;
begin
    a:=LongIntRound(exp1.evalF);
    b:=LongIntRound(exp2.evalF);
    result:=a div b;
end;

function TMSMOD.evalF:double;
var
    a,b:longint;
begin
    a:=LongIntRound(exp1.evalF);
    b:=LongIntRound(exp2.evalF);
    result:=a mod b;
end;

function DstrX(x:extended):ansistring;
var
   n:number;
begin
   convert(x,n);
   result:=Dstr(n)
end;

function TUnaryX.evalF:double;
begin
   result:=exp.evalF;
   currentoperation:=self;
   result:=opX(result);
   asm fwait end;
   currentoperation:=nil;
end;

function TBinaryX.evalF:double;
{$MAXFPUREGISTERS 0}
var
    m:double;
begin
   result:=exp1.evalF;
   m:=exp2.evalF;
   result:=opX(result,m);
end;

function TNOperation.evalF:double;
begin
   result:=op.evalF
end;

{************}
{NSubscripted}
{************}

type
   TNSubscripted=class(TSubscripted)
       function evalX:extended;override;
       function evalF:double;override;
       function evalInteger:integer;override;  //桁あふれはmaxint
       function evalLongint:longint;override;  //桁あふれはEInvalidOp
       function str:ansistring;override;
       function str2:ansistring;override;

       function compare(exp:TPrincipal):integer;override;
       function sign:integer;override;

       procedure substOne;override;
       procedure assign(exp:TPrincipal);override;
       procedure assignwithNoRound(exp:TPrincipal);override;
       procedure assignX(x:extended);override;
       procedure assignLongint(i:longint);override;

       function substance0(ByVal:boolean):TVar;override;
       procedure disposesubstance0(p:TVar; ByVal:boolean);override;
       function substance1:TVar;override;
       procedure disposesubstance1(p:TVar);override;
      private
         function position:integer;virtual;abstract;
   end;

   TNSubscripted1=class(TNSubscripted)
      private
         function position:integer;override;
   end;

   TNSubscripted2=class(TNSubscripted)
      private
         function position:integer;override;
   end;

   TNSubscripted3=class(TNSubscripted)
      private
         function position:integer;override;
   end;

   TNSubscripted4=class(TNSubscripted)
      private
         function position:integer;override;
   end;


function TNSubscripted1.position:integer;
begin
   result:=TArray(subs.ptr).position1(Subscript[1].evalLongint);
end;

function TNSubscripted2.position:integer;
begin
   result:=TArray(subs.ptr).position2(Subscript[1].evalLongint,
                                        Subscript[2].evalLongint);
end;

function TNSubscripted3.position:integer;
var
  subsc:Array4;
begin
   subsc[1]:=Subscript[1].evalLongint;
   subsc[2]:=Subscript[2].evalLongint;
   subsc[3]:=Subscript[3].evalLongint;
   result:=TArray(subs.ptr).positionof(subsc)
end;

function TNSubscripted4.position:integer;
var
  subsc:array4;
begin
   subsc[1]:=Subscript[1].evalLongint;
   subsc[2]:=Subscript[2].evalLongint;
   subsc[3]:=Subscript[3].evalLongint;
   subsc[4]:=Subscript[4].evalLongint;
   result:=TArray(subs.ptr).positionof(subsc)
end;

procedure  TNSubscripted.substOne;
begin
   TFArray(subs.ptr).dary^[position]:=1;
end;


procedure TNSubscripted.assign(exp:TPrincipal);
begin
    TFArray(subs.ptr).dary^[position]:=exp.evalF;
end;

procedure TNSubscripted.assignwithNoRound(exp:TPrincipal);
begin
    TFArray(subs.ptr).dary^[position]:=exp.evalF;
end;

procedure  TNSubscripted.assignX(x:extended);
begin
    TFArray(subs.ptr).dary^[position]:=x;
end;

procedure TNSubscripted.assignLongint(i:longint);
begin
    TFArray(subs.ptr).dary^[position]:=i;
end;

function TNSubscripted.evalX:extended;
begin
   result:=TFArray(subs.ptr).dary^[position];
end;

function TNSubscripted.evalF:double;
begin
   result:=TFArray(subs.ptr).dary^[position];
end;

function TNSubscripted.evalInteger:Integer;
var
   d:double;
begin
   d:=TFArray(subs.ptr).dary^[position];
   if d>=maxint then result:=maxint
   else if d<=minint then result:=minint
   else result:=System.Round(d)
end;

function TNSubscripted.evalLongint:longint;
begin
  result:=LongIntRound
                                          (TFArray(subs.ptr).dary^[position]);
end;

function TNSubscripted.str:ansistring;
var
   p:TVar;
begin
    p:=Substance0(false);
    if p<>nil then
       str:=p.str
    else
       str:='';
    DisposeSubstance0(p,false);
end;

function TNSubscripted.str2:ansistring;
var
   p:TVar;
begin
    p:=Substance0(false);
    if p<>nil then
       str2:=p.str2
    else
       str2:='';
    DisposeSubstance0(p,false);
end;


function TNSubscripted.substance0(byVal:boolean):TVar;
begin
  if ByVal then
     result:=substance1
  else
     substance0:=TrefFVar.createRef(TFArray(subs.ptr).dary^[position]);
end;

procedure TNSubscripted.disposesubstance0(p:TVar; ByVal:boolean);
begin
   p.Free
end;

function TNSubscripted.substance1:TVar;
begin
    result:=TorthoFVar.createF(TFArray(subs.ptr).dary^[position]);
end;

procedure TNSubscripted.disposesubstance1(p:TVar);
begin
     p.free
end;

function TNSubscripted.compare(exp:TPrincipal):integer;
var
   d:Double;
begin
   d:=exp.evalF;
   compare:=fcompare(TFArray(subs.ptr).dary^[position],d);
end;

function TNSubscripted.sign:integer;
begin
   result:=fsign(TFArray(subs.ptr).dary^[position])
end;




function NSubscripted1(idr:TIdrec; p:SubscriptArray):TVariable;
begin
   result:=TNSubscripted1.create(idr,p);
end;

function NSubscripted2(idr:TIdrec; p:SubscriptArray):TVariable;
begin
   result:=TNSubscripted2.create(idr,p);
end;

function NSubscripted3(idr:TIdrec; p:SubscriptArray):TVariable;
begin
   result:=TNSubscripted3.create(idr,p);
end;

function NSubscripted4(idr:TIdrec; p:SubscriptArray):TVariable;
begin
   result:=TNSubscripted4.create(idr,p);
end;



{***********}
{NComparison}
{***********}

type
    TEqual=class(TLogicalBiOp)
          function evalBool:boolean;override;
    end;

    TNotEqual=class(TLogicalBiOp)
          function evalBool:boolean;override;
    end;

    TGreater=class(TLogicalBiOp)
          function evalBool:boolean;override;
    end;

    TGreaterOrEq=class(TLogicalBiOp)
          function evalBool:boolean;override;
    end;

    TSmaller=class(TLogicalBiOp)
          function evalBool:boolean;override;
    end;

    TSmallerOrEq=class(TLogicalBiOp)
          function evalBool:boolean;override;
    end;

type
    TLogicalSingle=class(TNegation)
          const0:double;
          constructor create(e1,e2:TPrincipal);
    end;

    TEqualConst=Class(TLogicalSingle)
          function evalBool:boolean;override;
    end;

    TNotEqualConst=Class(TLogicalSingle)
          function evalBool:boolean;override;
    end;

    TGreaterConst=Class(TLogicalSingle)
          function evalBool:boolean;override;
    end;

    TGreaterOrEqConst=Class(TLogicalSingle)
          function evalBool:boolean;override;
    end;

    TSmallerConst=Class(TLogicalSingle)
          function evalBool:boolean;override;
    end;

    TSmallerOrEqConst=Class(TLogicalSingle)
          function evalBool:boolean;override;
    end;

constructor TLogicalSingle.create(e1,e2:TPrincipal);
begin
    inherited create(e1);
    const0:=e2.evalF;
    e2.free;          //2011.3.9
end;

function TEqual.evalBool:boolean;
begin
  result:=(exp1.evalF=exp2.evalF)
end;

function TNotEqual.evalBool:boolean;
begin
  result:=(exp1.evalF<>exp2.evalF)
end;

function TGreater.evalBool:boolean;
begin
  result:=(exp1.evalF>exp2.evalF)
end;

function TGreaterOrEq.evalBool:boolean;
begin
  result:=(exp1.evalF>=exp2.evalF)
end;

function TSmaller.evalBool:boolean;
begin
  result:=(exp1.evalF<exp2.evalF)
end;

function TSmallerOrEq.evalBool:boolean;
begin
  result:=(exp1.evalF<=exp2.evalF)
end;

function TEqualConst.evalBool:boolean;
begin
    result:=exp.evalF=const0
end;

function TNotEqualConst.evalBool:boolean;
begin
    result:=exp.evalF<>const0
end;

function TGreaterConst.evalBool:boolean;
begin
    result:=exp.evalF>const0
end;

function  TGreaterOrEqConst.evalBool:boolean;
begin
    result:=exp.evalF>=const0
end;

function TSmallerConst.evalBool:boolean;
begin
    result:=exp.evalF<const0
end;

function TSmallerOrEqConst.evalBool:boolean;
begin
    result:=exp.evalF<=const0
end;


function NComparison(f:comparefunction; e1,e2:TPrincipal):TLogical;
begin
    if (@f=@Equals) then
       if e2.isConstant then
         NComparison:=TEqualConst.create(e1,e2)
       else
         NComparison:=TEqual.create(e1,e2)
    else if (@f=@NotEquals) then
       if e2.isConstant then
          NComparison:=TNotEqualConst.create(e1,e2)
       else
          NComparison:=TNotEqual.create(e1,e2)
    else if (@f=@Greater) then
       if e2.isConstant then
          NComparison:=TGreaterConst.create(e1,e2)
       else
          NComparison:=TGreater.create(e1,e2)
    else if (@f=@NotLess) then
       if e2.isConstant then
          NComparison:=TGreaterOrEqConst.create(e1,e2)
       else
          NComparison:=TGreaterOrEq.create(e1,e2)
    else if (@f=@Less) then
       if e2.isConstant then
          NComparison:=TSmallerConst.create(e1,e2)
       else
          NComparison:=TSmaller.create(e1,e2)
    else if (@f=@NotGreater) then
       if e2.isConstant then
          NComparison:=TSmallerOrEqConst.create(e1,e2)
       else
          Ncomparison:=TSmallerOrEq.create(e1,e2);
end;

{***********}
{Mode Switch}
{***********}

procedure SwitchToNativeMode;
begin
   Express.NConst:=NConst;
   EXpress.OpPower:=OpPower;
   EXpress.OpUnaryMinus:=OpUNaryMinus;
   EXpress.OpSquare:=OpSquare;
   Express.OpTimes:=OpTimes;
   Express.OpDivide:=OpDivide;
   Express.OpPlus:=OpPlus;
   Express.OpMinus:=OpMinus;
   Express.OpMSYen:=OpMsYen;
   Express.OpMsMod:=OpMsMod;
   Express.NFunction:=NFunction;
   Express.Unary:=Unary;
   Express.Binary:=Binary;
   Express.UnaryX:=UnaryX;
   Express.BinaryX:=BinaryX;
   Express.NOperation:=NOperation;

   Express.NSubscripted1:=Nsubscripted1;
   Express.NSubscripted2:=Nsubscripted2;
   Express.NSubscripted3:=Nsubscripted3;
   Express.NSubscripted4:=Nsubscripted4;

   EXpress.NComparison:=NComparison;
end;

{******************}
{supplied functions}
{******************}


{**************}
{reserved words}
{**************}

function MAXNUMfnc:TPrincipal;
begin
   MAXNUMfnc:=ExpressF.TNConstant.create2(maxnumberDouble)
end;

function PIfnc:TPrincipal;
begin
    PIfnc:=TNConstant.create2(pi) ;
end;


{**********}
{initialize}
{**********}

procedure  FunctionTableInit;
begin
 if PrecisionMode=PrecisionNative then
   begin
       ReservedWordTableInit('MAXNUM' , MAXNUMfnc );
       if not permitMicrosoft  then
          ReservedWordTableInit(  'PI' ,  PIfnc);
   end;
end;

begin
if TableInitProcs=nil then
   TableInitProcs:=TProcsCollection.create;  //98.4.1 初期化順に疑念発生，express.pasに移動
   tableInitProcs.accept(FunctionTableInit);
end.

