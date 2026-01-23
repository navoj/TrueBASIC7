unit expressn;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}
(***************************************)
(* Copyright (C) 2006, SHIRAISHI Kazuo *)
(***************************************)


interface
uses  SysUtils,
      variabl,express,arithmet,variabls,float;

procedure SwitchToDecimalMode;

{********************}
{numerical expression}
{********************}
 type
    TNexpression=class(TPrincipal)
      constructor create;
      function evalX:extended;override;
      function evalInteger:integer;override;
      function evalLongint:longint;override;
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
   TUnaryOpOrdinal=class(TNExpression)
             exp:TPrincipal;
             opN:unaryoperation;
          constructor create(e:TPrincipal;
                                   op1:unaryoperation;op2:extendedfunction1;
                                        er1,er2:smallint;const n:ansistring);virtual;
          procedure evalN(var n:number);override;
          destructor destroy;override;
     end;

   TBinaryOpOrdinal=class(TNExpression)
             exp1,exp2:TPrincipal;
             opN:binaryoperation;
         constructor create(e1,e2:TPrincipal;
                             op1:binaryoperation;op2:extendedfunction2;
                                        er1,er2:smallint;const n:ansistring);virtual;
          procedure evalN(var n:number);override;
          destructor destroy;override;
     end;

   TUnaryOp=class(TUnaryOpOrdinal)
             opX:extendedfunction1;
             overflowcode:smallint;
             invalidcode:smallint;
             name:ansistring;
          constructor create(e:TPrincipal;
                             op1:unaryoperation;op2:extendedfunction1;
                             er1,er2:smallint;const n:ansistring);override;
          procedure evalN(var n:number);override;
          function OverflowErCode:integer;override;
          function InvalidErCode:integer;override;
          function OpName:string;override;
     end;

   TBinaryOp=class(TBinaryOpOrdinal)
             opX:extendedfunction2;
             overflowcode:smallint;
             invalidcode:smallint;
             name:ansistring;
          constructor create(e1,e2:TPrincipal;
                            op1:binaryoperation;op2:extendedfunction2;
                            er1,er2:smallint;const n:ansistring);override;
          procedure evalN(var n:number);override;
          function OverflowErCode:integer;override;
          function InvalidErCode:integer;override;
          function OpName:string;override;
     end;

{
function UnaryOp( e:TPrincipal;op1:unaryoperation;op2:extendedfunction1;
                  er1,er2:smallint; opclass:TUnaryOpClass; name:ansistring):TPrincipal;
function BinaryOp( e1,e2:TPrincipal; op1:binaryoperation;op2:extendedfunction2;
                 er1,er2:smallint; opclass:TBinaryOpClass; name:ansistring):TPrincipal;
}

implementation
uses
      struct,math,base,texthand,helpctex,math3;
      
type
   TNConstant=class(TNExpression)
              valueN:Pnumber;
           constructor create(var n:number);
           procedure evalN(var n:number);override;
           destructor destroy;override;
           function isConstant:boolean;override;
       end;

type
   TNFunction=class(TNExpression)
          exe   :TCALL;
          constructor create(idr:TIdrec);
          procedure evalN(var n:number);override;
          destructor destroy;override;
     end;

type
     TUnaryOpClass = class of TUnaryOpOrdinal;
     TBinaryOpClass = class of TBinaryOpOrdinal;

     {******************}
{numeric expresion}
{*****************}

constructor TNExpression.create;
begin
   inherited create;
end;

function TNExpression.evalX:extended;
var
   n:number;
begin
   evalN(n);
   result:=extendedval(n)
end;

function TNExpression.str:ansistring;
var
    n:number;
begin
    evalN(n);
    checkrangedecimal(n,OverflowErCode);
    str:=Dstr(n)+' '
end;

function TNExpression.str2:ansistring;
begin
    str2:=str
end;

function TNExpression.evalInteger:integer;
var
   c:integer;
   n:number;
begin
   evalN(n);
   result:=longintval(n,c);
   if c>0 then result:=maxint
   else if c<0 then result:=MinInt;
end;

function TNExpression.evalLongint:longint;
var
   c:integer;
   n:number;
begin
   evalN(n);
   result:=longintval(n,c);
   if c<>0 then SetException(2001);
//   if c<>0 then raise EInValidOp.create('');
end;

{
function TNExpression.format(f:string):string;
begin
     format:=str
end;
}

function TNexpression.kind:char;
begin
   kind:='n'
end;


function TNExpression.substance0(ByVal:boolean):TVar;
var
    n:number;
begin
    evalN(n);
    substance0:=TNVar.createN(@n)
end;
(*
var
    n:number;
    p:TNvar;
begin
     p:=TNvar.create;
     if evalN(n) and (p<>nil) then
           begin
               p.substN(n) ;
               substance0:=p
           end
     else
           begin
                  p.free;
                  substance0:=nil
           end;
end;
*)
procedure TNExpression.disposeSubstance0(p:TVar; ByVal:boolean);
begin
     p.free;
end;

function TNExpression.substance1:TVar;
var
    n:number;
begin
    evalN(n);
    substance1:=TNVar.createN(@n)
end;
(*
var
    n:number;
    p:TNvar;
begin
     p:=TNvar.create;
     if evalN(n) and (p<>nil) then
           begin
               p.substN(n) ;
               substance1:=p
           end
     else
           begin
                  p.free;
                  substance1:=nil
           end;
end;
*)
procedure TNExpression.disposeSubstance1(p:TVar);
begin
     p.free;
end;

function TNExpression.compare(p:TPrincipal):integer;
var
   n1,n2:number;
begin
   evalN(n1);
   p.evalN(n2);
   compare:=arithmet.compare(n1,n2)
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

procedure TNFunction.evalN(var n:number);
begin
   exe.evalN(n)
end;



{*********}
{TNConstant}
{*********}



constructor TNConstant.create(var n:number);
var
   m:number;
begin
    inherited  create;
    m.init(@n);
    roundexpression(m);
    roundprecision(m);
    subst(valueN,m);
end;

procedure TNConstant.evalN(var n:number);
begin
    n.init(valueN);
    checkrangedecimal(n,1001);
end;

destructor TNConstant.destroy;
begin
   disposeNumber(valueN);
   inherited destroy;
end;

function TNConstant.isConstant:boolean;
begin
   isConstant:=true
end;




{*****************}
{numeric operation}
{*****************}
const
    minstack=sizeof(Number)*6 ;



constructor TunaryOpOrdinal.create(e:TPrincipal; op1:unaryoperation;
                         op2:extendedfunction1; er1,er2:smallint;const n:ansistring);
begin
    inherited  create;
    exp:=e;
    opN:=op1;
end;

constructor TunaryOp.create(e:TPrincipal; op1:unaryoperation;
                         op2:extendedfunction1; er1,er2:smallint;const n:ansistring);
begin
    inherited  create(e,op1,op2,er1,er2,n);
    opX:=op2;
    overflowcode:=er1;
    invalidcode:=er2;
    name:=n;
end;

procedure TUnaryOpOrdinal.evalN(var n:number);
begin
    exp.evalN(n);
    opN(n)
end;

procedure TUnaryOp.evalN(var n:number);
begin
    exp.evalN(n);
    CurrentOperation:=self;
    opN(n);
    checkrangedecimal(n,OverflowErCode);
    CurrentOperation:=nil;
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

destructor TUnaryOpOrdinal.destroy;
begin
   exp.free;
   inherited destroy;
end;

constructor TBinaryOpOrdinal.create(e1,e2:TPrincipal; op1:binaryoperation;
                        op2:ExtendedFunction2; er1,er2:smallint;const n:ansistring );
begin
    inherited  create;
    exp1:=e1;
    exp2:=e2;
    opN:=op1;
end;

constructor TBinaryOp.create(e1,e2:TPrincipal; op1:binaryoperation;
                        op2:ExtendedFunction2; er1,er2:smallint;const n:ansistring );
begin
    inherited  create(e1,e2,op1,op2,er1,er2,n);
    opX:=op2;
    overflowcode:=er1;
    invalidcode:=er2;
    name:=n;
end;

procedure  TBinaryOpOrdinal.evalN(var n:number);
var
    m:number;
begin
    exp1.evalN(n) ;
    exp2.evalN(m) ;
    opN(n,m,n)
end;

procedure  TBinaryOp.evalN(var n:number);
var
    m:number;
begin
    exp1.evalN(n) ;
    exp2.evalN(m) ;
    CurrentOperation:=self;
    opN(n,m,n)    ;
    checkrangedecimal(n,OverflowErCode);
    CurrentOperation:=nil;
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

destructor TBinaryOpOrdinal.destroy;
begin
   exp1.free;
   exp2.free;
   inherited destroy;
end;




function UnaryOp( e:TPrincipal;op1:unaryoperation;op2:extendedfunction1;
                   er1,er2:smallint;opclass:TUnaryOpClass;const name:ansistring):TPrincipal;
var
   p:TPrincipal;
   n:number;
   flag:boolean;
begin
   p:=opClass.create(e,op1,op2,er1,er2,name);
   if e.isConstant then
      begin
        flag:=true;
        try
            p.evalN(n)
        except
            flag:=false;
            extype:=0;
        end;
        if flag then
          begin
            p.free;
            p:=TNConstant.create(n);
          end;
      end;
   UnaryOp:=p
end;


function BinaryOp( e1,e2:TPrincipal; op1:binaryoperation; op2:extendedfunction2;
                  er1,er2:smallint; opclass:TBinaryOpClass;const name:ansistring):TPrincipal;
var
   p:TPrincipal;
   n:number;
   flag:boolean;
begin
   p:=opClass.create(e1,e2,op1,op2,er1,er2,name);
   if e1.isConstant and e2.isConstant then
      begin
       flag:=false;
       try
           p.evalN(n);
           checkRangeDecimal(n,0);
       except
           extype:=0;
           flag:=false;
       end;
       if flag then
          begin
                p.free;
                p:=TNConstant.create(n);
          end
      end;
   BinaryOp:=p
end;

function OpPower(e1,e2:TPrincipal):TPrincipal;
begin
  case ProgramUnit.arithmetic of
    PrecisionNormal:
      result:=BinaryOp(e1,e2,arithmet.power,nil,1002,3002,TBinaryOp,'^');
      PrecisionHigh:
      result:=BinaryOp(e1,e2,math3.powerHP,nil,1002,3002,TBinaryOp,'^');    //ver.8.1.6
  end;
end;

function OpSquare(e1:TPrincipal):TPrincipal;
begin
  result:=UnaryOp(e1,arithmet.Square,nil,1002,1002,TUnaryOpOrdinal,'^')
end;

function  OpUnaryMinus(e1:TPrincipal):TPrincipal;
begin
     result:=UnaryOp(e1,arithmet.opposite,nil,1002,1002,TUnaryOpOrdinal,'-');
end;

function OpTimes(e1,e2:TPrincipal):TPrincipal;
begin
    result:=BinaryOp(e1,e2, arithmet.mlt,nil,  1002,1002,TBinaryOpOrdinal,'*');
end;

function OpDivide(e1,e2:TPrincipal):TPrincipal;
begin
    result:=BinaryOp(e1,e2,arithmet.qtt,nil,  1002,3001,TBinaryOpOrdinal,'/');
end;

function OpPlus(e1,e2:TPrincipal):TPrincipal;
begin
    result:=BinaryOp(e1,e2,arithmet.Add,nil, 1002,1002,TBinaryOpOrdinal,'+');
end;

function OpMinus(e1,e2:TPrincipal):TPrincipal;
begin
    result:=BinaryOp(e1,e2, arithmet.sbt,nil, 1002,1002,TBinaryOpOrdinal,'-');
end;

function OpMSYen(e1,e2:TPrincipal):TPrincipal;
begin
    setErr('',COMPILE_OPTION_SYNTAX);
end;

function OpMSMod(e1,e2:TPrincipal):TPrincipal;
begin
    setErr('',COMPILE_OPTION_SYNTAX);
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

{************}
{Unary Binary}
{************}

function Unary(op1:unaryoperation; op2:floatfunction1;er2:smallint;const name:ansistring):TPrincipal;
begin
    Unary:=UnaryOp(argumentN1,op1,nil,1003,er2,ExpressN.TUnaryOp,name)
end;

function Binary(op1:binaryoperation; op2:floatfunction2; er2:smallint;const name:ansistring):TPrincipal;
var
   a1:TPrincipal;
begin
   a1:=argumentN2a;
   Binary:=BinaryOp(a1,ArgumentN2b,op1,nil,1003,er2,ExpressN.TBinaryOp,name)
end;


type
  TUnaryX=class(TUnaryOp)
     procedure evalN(var n:number);override;
   end;

  TBinaryX=class(TBinaryOp)
    procedure evalN(var n:number);override;
   end;

procedure TUnaryX.evalN(var n:number);
var
   x:extended;
begin
   exp.evalN(n);
   currentoperation:=self;
   try
       x:=opX(extendedval(n));
    except
       on EOverflow do
             setexceptionwith(name+'('+DStr(n)+')',overflowcode);
       on EMathError do
             setexceptionwith(name+'('+DStr(n)+')',invalidcode);
    end;
{
   if isInfinite(x) then
      setexceptionwith(name+'('+DStr(n)+')',overflowcode)
   else if isNan(x) then
      setexceptionwith(name+'('+DStr(n)+')',invalidcode);
}
   convert(x,n);
   currentoperation:=nil;
end;

procedure TBinaryX.evalN(var n:number);
var
    m:number;
    x:extended;
begin
    exp1.evalN(n);
    exp2.evalN(m);
    try
       x:=opX(extendedval(n),extendedval(m));
    except
       on EOverflow do
             setexceptionwith(name+'('+DStr(n)+','+DStr(m)+')',overflowcode);
       on EMathError do
             setexceptionwith(name+'('+DStr(n)+','+DStr(m)+')',invalidcode) ;
    end;
    if isInfinite(x) then
            setexceptionwith(name+'('+DStr(n)+','+DStr(m)+')',overflowcode)
    else if isNan(x) then
            setexceptionwith(name+'('+DStr(n)+','+DStr(m)+')',invalidcode) ;
    convert(x,n);
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
    procedure evalN(var n:number); override;
    destructor destroy;override;
  end;

constructor TNOperation.Create(e1:TPrincipal);
begin
   inherited create;
   op:=e1;
end;

procedure TNOperation.evalN(var n:number);
begin
   op.EvalN(n)
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

{************}
{NSubscripted}
{************}

function NSubscripted1(idr:TIdrec; p:SubscriptArray):TVariable;
begin
   result:=TSubscripted1.create(idr,p);
end;

function NSubscripted2(idr:TIdrec; p:SubscriptArray):TVariable;
begin
   result:=TSubscripted2.create(idr,p);
end;

function NSubscripted3(idr:TIdrec; p:SubscriptArray):TVariable;
begin
   result:=TSubscripted3.create(idr,p);
end;

function NSubscripted4(idr:TIdrec; p:SubscriptArray):TVariable;
begin
   result:=TSubscripted4.create(idr,p);
end;



{***********}
{NComparison}
{***********}

function NComparison(f:comparefunction; e1,e2:TPrincipal):TLogical;
begin
   NComparison:=TComparisonN.create(e1,e2,f)
end;


{***********}
{Mode Switch}
{***********}

procedure SwitchToDecimalMode;
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
   //struct.NewNumericVari:=NewNumericVariN;
   //struct.NewNumericArray:=NewNumericArrayN;
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
var
   n:number;
begin
      MAXNUMfnc:=ExpressN.TNConstant.create(arithmet.MAXNUM^)
end;

function PIfnc:TPrincipal;
begin
    PIfnc:=TNConstant.create(arithmet.decimalPI^) ;
end;


{***********}
{initialize}
{*********}


procedure  FunctionTableInit;
begin
 if PrecisionMode in [PrecisionNormal, PrecisionHigh]  then
   begin
       ReservedWordTableInit('MAXNUM', MAXNUMfnc );
       ReservedWordTableInit('PI'    , PIfnc);
   end;
end;


begin
   tableInitProcs.accept(FunctionTableInit);
   SwitchToDecimalMode;
end.
