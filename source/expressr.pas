unit expressr;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}
(***************************************)
(* Copyright (C) 2006, SHIRAISHI Kazuo *)
(***************************************)


interface
 uses SysUtils,
      variabl,express,arithmet,rational,variablr,float ;
 
procedure SwitchToRationalMode;

{********************}
{numerical expression}
{********************}
 type
    TNexpression=class(TPrincipal)
      constructor create;
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

      //function evalF:double;override;
      function evalX:extended;override;
      procedure EvalN(var n:number);override;
     end;

type
   RationalFunction1=procedure (var r:PNumeric);
   RationalFunction2=procedure (a,b:PNumeric; var x:PNumeric);


type
   TUnaryOp=class(TNExpression)
             exp:TPrincipal;
             opN:unaryoperation;
             opF:FloatFunction1;
             opX:ExtendedFunction1;
             opR:RationalFunction1;
             overflowcode:smallint;
             invalidcode:smallint;
             name:ansistring;
          constructor create(e:TPrincipal;
                             op0:UnaryOperation;
                             op1:FloatFunction1;
                             op2:extendedfunction1;
                             op3:RationalFunction1;
                             er1,er2:smallint;
                             const n:ansistring);virtual;
          procedure evalR(var r:PNumeric);override;
          destructor destroy;override;
     end;

   TBinaryOp=class(TNExpression)
             exp1,exp2:TPrincipal;
             opN:binaryoperation;
             opF:FloatFunction2;
             opX:ExtendedFunction2;
             opR:RationalFunction2;
             overflowcode:smallint;
             invalidcode:smallint;
             name:ansistring;
          constructor create(e1,e2:TPrincipal;
                              op0:BinaryOperation;   op1:FloatFunction2;
                              op2:extendedfunction2; op3:RationalFunction2;
                              er1,er2:smallint;const n:ansistring);virtual;
          procedure evalR(var r:PNumeric);override;
          destructor destroy;override;
     end;

function UnaryR(op2:rationalfunction1;er2:smallint;const name:ansistring):TPrincipal;
function BinaryR(op2:rationalfunction2;er2:smallint;const name:ansistring):TPrincipal;

implementation
uses
     struct,math,base,texthand,math2,supplied,helpctex,sconsts;
     
type
   TNConstant=class(TNExpression)
              valueR:PNumeric;
           constructor create(var n:number);
           constructor create2(r:PNumeric);
           procedure   evalR(var r:PNumeric);override;
           destructor destroy;override;
           function isConstant:boolean;override;
       end;

type
   TNFunction=class(TNExpression)
          exe   :TCALL;
          constructor create(idr:TIdrec);
          procedure   evalR(var r:PNumeric);override;
          destructor destroy;override;
     end;

type
     TUnaryOpClass = class of TUnaryOp;
     TBinaryOpClass = class of TBinaryOp;
{******************}
{numeric expresion}
{*****************}

constructor TNExpression.create;
begin
   inherited create;
end;

(*
function TNExpression.evalF:double;
var
  r:PNumeric;
begin
  r:=nil;
  evalR(r);
  r^.getF(result);
  disposeNumeric(r);
end;
*)

function TNExpression.evalX:extended;
var
  r:PNumeric;
begin
  r:=nil;
  evalR(r);
  r^.getX(result);
  disposeNumeric(r);
end;

procedure TNExpression.EvalN(var n:number);
var
   r:PNumeric;
begin
   r:=nil;
   evalR(r);
   r^.getN(n);
   disposeNumeric(r)
end;


function TNExpression.str:ansistring;
var
    r:PNumeric;
begin
    r:=nil;
    evalR(r);
    str:=StrFraction(r)+' ';
    disposeNumeric(r)
end;

function TNExpression.str2:ansistring;
begin
    str2:=str

end;

function TNExpression.evalInteger:integer;
var
   r:PNumeric;
   i:longint;
   c:integer;
begin
   r:=nil;
   evalR(r);
   if r<>nil then
   begin
      r^.getLongInt(i,c);
      result:=i;
      if c>0 then result:=maxint
      else if c<0 then result:=MinInt;
      disposeNumeric(r);
   end
   else
      result:=0;
end;

function TNExpression.evalLongint:longint;
var
   r:PNumeric;
   i:longint;
   c:integer;
begin
   r:=nil;
   evalR(r);
   if r<>nil then
   begin
      r^.getLongInt(i,c);
      result:=i;
      disposeNumeric(r);
      if c<>0 then SetException(2001);
//      if c<>0 then raise EInvalidOp.create('');
   end
   else
      result:=0;
end;

function TNexpression.kind:char;
begin
   kind:='n'
end;


function TNExpression.substance0(ByVal:boolean):TVar;
var
    r:PNumeric;
begin
    r:=nil;
    evalR(r);
    substance0:=TRVar.createR(r);
end;

procedure TNExpression.disposeSubstance0(p:TVar; ByVal:boolean);
begin
     p.free;
end;

function TNExpression.substance1:TVar;
var
    r:PNumeric;
begin
    r:=nil;
    evalR(r);
    substance1:=TRVar.createR(r);
end;

procedure TNExpression.disposeSubstance1(p:TVar);
begin
     p.free;
end;

function TNExpression.compare(p:TPrincipal):integer;
var
   r1,r2:PNumeric;
begin
   r1:=nil; r2:=nil;
   evalR(r1);
   p.evalR(r2);
   compare:=rational.compare(r1,r2);
   disposeNumeric(r1);
   disposeNumeric(r2);
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

procedure TNFunction.evalR(var r:PNumeric);
begin
   exe.evalR(r)
end;



{*********}
{TNConstant}
{*********}



constructor TNConstant.create(var n:number);
begin
    inherited create;
    valueR:=NewRationalFromNumber(@n);
end;

constructor TNConstant.create2(r:PNumeric);
begin
    inherited create;
    valueR:=r;
end;

procedure  TNConstant.evalR(var r:PNumeric);
begin
    r:=valueR^.newcopy;
end;

destructor TNConstant.destroy;
begin
   disposeNumeric(valueR);
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


constructor TunaryOp.create(e:TPrincipal;op0:UnaryOperation; op1:FloatFunction1;
                             op2:extendedfunction1;op3:RationalFunction1;
                            er1,er2:smallint;const n:ansistring);
begin
    inherited  create;
    exp:=e;
    opN:=op0;
    opF:=op1;
    opX:=op2;
    opR:=op3;
    overflowcode:=er1;
    invalidcode:=er2;
    name:=n;
end;

procedure TUnaryOp.evalR(var r:PNumeric);
begin
   exp.evalR(r);
   opR(r);
end;


destructor TunaryOp.destroy;
begin
   exp.free;
   inherited destroy;
end;

constructor TBinaryOp.create(e1,e2:TPrincipal;
                              op0:BinaryOperation;   op1:FloatFunction2;
                              op2:extendedfunction2; op3:RationalFunction2;
                              er1,er2:smallint;const n:ansistring );
begin
    inherited  create;
    exp1:=e1;
    exp2:=e2;
    opN:=op0;
    opF:=op1;
    opX:=op2;
    opR:=op3;
    overflowcode:=er1;
    invalidcode:=er2;
    name:=n;
end;

procedure TBinaryOp.evalR(var r:PNumeric);
var
    s:PNumeric;
begin
    s:=nil;
    exp1.evalR(r);
    exp2.evalR(s);
    try
      opR(r,s,r);
    finally
      disposeNumeric(s);
    end;
end;

destructor TBinaryOp.destroy;
begin
   exp1.free;
   exp2.free;
   inherited destroy;
end;



function UnaryOp( e:TPrincipal;op0:UnaryOperation;op1:FloatFunction1;
                            op2:extendedfunction1;op3:RationalFunction1;
                            er1,er2:smallint;opclass:TUnaryOpClass;
                            const name:ansistring):TPrincipal;
var
   p:TPrincipal;
   r:PNumeric;
   flag:boolean;
begin
   r:=nil;
   p:=opClass.create(e,op0,op1,op2,op3,er1,er2,name);
   if e.isConstant then
      begin
         flag:=true;
         try
            p.evalR(r)
         except
            extype:=0;
            flag:=false;
         end;
         if flag then
            begin
                 p.free;
                 p:=TNConstant.create2(r);
            end;
      end;
   UnaryOp:=p
end;


function BinaryOp( e1,e2:TPrincipal;op0:BinaryOperation;op1:FloatFunction2;
                              op2:extendedfunction2; op3:RationalFunction2;
                 er1,er2:smallint; opclass:TBinaryOpClass;const name:ansistring):TPrincipal;
var
   p:TPrincipal;
   //n:number;
   x:PNumeric;
   flag:boolean;
begin
   x:=nil;
   p:=opClass.create(e1,e2,op0,op1,op2,op3,er1,er2,name);
   if e1.isConstant and e2.isConstant then
     begin
       flag:=true;
       try
          p.evalR(x)
       except
          flag:=false;
          extype:=0;
       end;
       if flag then
          begin
              p.free;
              p:=TNConstant.create2(x);
          end;
     end;
   BinaryOp:=p
end;


function IntPower(c:PNumeric; i: longint): PNumeric;
var
  x,t:PNumeric;
  j: longint;
begin
  x:=c^.newCopy;
  t:=rational.constOne^.newcopy;    //t:=1
  j := system.Abs(i);
  while j > 0 do
   begin
     while not Odd(j) do
     begin
      j := j shr 1;
      rational.mlt(x,x,x) ;   // X := X * X
     end;
     Dec(j);
     rational.mlt(t,x,t);   //  t := t * X
  end;
  disposeNumeric(x);

  if i < 0 then
     begin
        x:=rational.constone^.newcopy;
        rational.qtt(x,t,t);  //t := 1 / t
        disposeNumeric(x);
     end;
  result:=t;
end;


procedure RPower( a,b:PNumeric; var x:PNumeric);
var
   r:PNumeric;
   i:longint;
   c:integer;
begin
   if  b^.iszero then
      begin
        disposeNumeric(x);
        x:=rational.constOne^.newcopy;
      end
   else if  a^.isZero and (b^.sign<0) then
      setexception(3003)
   else if b^.isInteger then
      begin
        b^.getLongInt(i,c);
        if c=0 then
          begin
            r:=IntPower(a,i);
            disposeNumeric(x);
            x:=r
          end
        else
          setexceptionwith(s_RPowerIndex,1000);       //2010.3.28
       end
   else
      setexception(3002);
end;

procedure RSquare(var x:PNumeric);
begin
   rational.mlt(x,x,x)
end;

procedure RAdd(var x,y:PNumeric);
begin
   rational.add(x,y,x)
end;

procedure RSbt(var x,y:PNumeric);
begin
   rational.sbt(x,y,x)
end;

procedure RMultiply(var x,y:PNumeric);
begin
   rational.mlt(x,y,x)
end;

procedure RQtt(var x,y:PNumeric);
begin
   rational.qtt(x,y,x)
end;


function OpPower(e1,e2:TPrincipal):TPrincipal;
begin
   result:=BinaryOp(e1,e2,nil,nil,nil,RPower,1002,3002,TBinaryOp,'^')
end;

function OpSquare(e1:TPrincipal):TPrincipal;
begin
  result:=UnaryOp(e1,nil,nil,nil,RSquare,1002,1002,TUnaryOp,'^')
end;

function  OpUnaryMinus(e1:TPrincipal):TPrincipal;
begin
     result:=UnaryOp(e1,nil,nil,nil, Rational.Opposite,1002,1002,TUnaryOp,'-');
end;

function OpTimes(e1,e2:TPrincipal):TPrincipal;
begin
    result:=BinaryOp(e1,e2,nil,nil,nil,rational.mlt,  1002,1002,TBinaryOp,'*');
end;

function OpDivide(e1,e2:TPrincipal):TPrincipal;
begin
    result:=BinaryOp(e1,e2,nil,nil,nil,rational.qtt  ,  1002,3001,TBinaryOp,'/');
end;

function OpPlus(e1,e2:TPrincipal):TPrincipal;
begin
    result:=BinaryOp(e1,e2,nil, nil,nil,Rational.Add, 1002,1002,TBinaryOp,'+');
end;

function OpMinus(e1,e2:TPrincipal):TPrincipal;
begin
    result:=BinaryOp(e1,e2,nil, nil,nil,Rational.Sbt, 1002,1002,TBinaryOp,'-');
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


function NewNumericVariR:TVar;
begin
   result:=TRVar.create
end;

function
   NewNumericArrayR(dim:integer;const lbound,ubound:Array4):TVar;
begin
   result:=TRArray.create(dim,lbound,ubound,0)
end;

{************}
{Unary Binary}
{************}

type
   TUnaryN=class(TUnaryOP)
          procedure evalR(var r:PNumeric);override;
     end;

   TBinaryN=class(TBinaryOP)
          procedure evalR(var r:PNumeric);override;
     end;

procedure TUnaryN.evalR(var r:PNumeric);
var
  q:PNumeric;
  n:number;
begin
    q:=nil;
    exp.evalR(q);
    q^.getN(n);
    disposeNumeric(q);
    opN(n);
    disposeNUmeric(r);
    r:=NewRationalFromNumber(@n);

   // setexceptionwith(name ,3000)  ;
end;

procedure TBinaryN.evalR(var r:PNumeric);
var
    p,q:PNumeric;
    m,n:number;
begin
    p:=nil;q:=nil;
    exp1.evalR(p);
    exp2.evalR(q);
    p^.getN(m);
    q^.getN(n);
    disposeNumeric(p);
    disposeNumeric(q);
    opN(m,n,m);
    disposeNUmeric(r);
    r:=NewRationalFromNumber(@m);
    //else
    //     setexceptionwith(name ,3000)  ;

end;

type
  TUnaryX=class(TUnaryOp)
     procedure evalR(var r:PNumeric);override;
   end;

  TBinaryX=class(TBinaryOp)
    procedure evalR(var r:PNumeric);override;
   end;

procedure TUnaryX.evalR(var r:PNumeric);
var
   q:PNumeric;
   x:extended;
   n:number;
   //b:bytebool;
begin
    q:=nil;
    exp.evalR(q);
    q^.getX(x);
    disposeNumeric(q);
            try
              x:=opX(x);
              convert(x,n);
              r:=NewRationalfromNumber(@n);
            except
               on EOverflow do
                  setexceptionwith(name,overflowcode);
               on EMathError do
                  setexceptionwith(name,invalidcode);
               on EDivByZero do
                  setexceptionwith(name,invalidcode);
            end;
      // else
      //      setexceptionwith(name,invalidcode) ;
end;

procedure TBinaryX.evalR(var r:PNumeric);
var
    p,q:PNumeric;
    x,y:extended;
    n:number;
    //b:bytebool;
begin
    p:=nil;q:=nil;
    exp1.evalR(p);
    exp2.evalR(q);
    p^.getX(x);
    q^.getX(y);
    disposeNumeric(p);
    disposeNumeric(q);
            try
               x:=opX(x,y);
               convert(x,n);
               r:=NewRationalFromNumber(@n);
            except
              on EOverflow do
                  setexceptionwith(name,overflowcode) ;
              on EMathError do
                  setexceptionwith(name,invalidcode);
               on EDivByZero do
                  setexceptionwith(name,invalidcode);
            end;
         //   else
     //    setexceptionwith(name,invalidcode);
end;





function Unary(op1:unaryoperation; op2:floatfunction1;er2:smallint;const name:ansistring):TPrincipal;
begin
    Unary:=UnaryOp(argumentN1,op1,op2,nil,nil,1003,er2,TUnaryN,name)
end;

function Binary(op1:binaryoperation; op2:floatfunction2; er2:smallint;const name:ansistring):TPrincipal;
var
   a1:TPrincipal;
begin
   a1:=argumentN2a;
   Binary:=BinaryOp(a1,ArgumentN2b,op1,op2,nil,nil,1003,er2,TBinaryN,name)
end;

function UnaryX(op2:extendedfunction1;er2:smallint;const name:ansistring):TPrincipal;
begin
    UnaryX:=UnaryOp(argumentN1,nil,nil,op2,nil,1003,er2,TUnaryX,name)
end;

function BinaryX(op2:extendedfunction2; er2:smallint;const name:ansistring):TPrincipal;
var
   a1:TPrincipal;
begin
   a1:=argumentN2a;
   BinaryX:=BinaryOp(a1,ArgumentN2b,nil,nil,op2,nil,1003,er2,TBinaryX,name)
end;

function UnaryR(op2:RationalFunction1;er2:smallint;const name:ansistring):TPrincipal;
begin
   UnaryR:=ExpressR.UnaryOp(argumentN1,nil,nil,nil,op2,1003,er2,ExpressR.TUnaryOp,name)
end;

function BinaryR(op2:RationalFunction2; er2:smallint;const name:ansistring):TPrincipal;
var
   a1:TPrincipal;
begin
   a1:=argumentN2a;
   BinaryR:=ExpressR.BinaryOp(a1,ArgumentN2b,nil,nil,nil,op2,1003,er2,ExpressR.TBinaryOp,name)

end;


{**********}
{NOperation}
{**********}
type
  TNOperation=class(TNExpression)
       Op:TPrincipal;
    constructor Create(e1:TPrincipal);
    procedure evalR(var r:PNumeric);override;
    destructor destroy;override;
  end;

constructor TNOperation.Create(e1:TPrincipal);
begin
   inherited create;
   op:=e1;
end;

procedure TNOperation.evalR(var r:PNumeric);
begin
   op.evalR(r)
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
procedure SwitchToRationalMode;
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
   //struct.NewNumericVari:=NewNumericVariC;
   //struct.NewNumericArray:=NewNumericArrayC;
   Express.Unary:=Unary;
   Express.Binary:=Binary;
   Express.UnaryX:=UnaryX;
   Express.BinaryX:=BinaryX;
   Express.NOperation:=NOperation;

   Express.NSubscripted1:=Nsubscripted1;
   Express.NSubscripted2:=Nsubscripted2;
   Express.NSubscripted3:=Nsubscripted3;

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
     seterr(prevtoken+s_IsReserved,IDH_FUNCTIONS_EPS);
     result:=nil
   //MAXNUMfnc:=ExpressR.TNConstant.create2(Rational.ConstMaxNum^.newcopy)
end;

(* {debug}
const
constdecimalPI_6:decimalnumber =(places:6; sign:1; tag:1; expn:1 ;
         frac: (3,141592653,589793238,462643383,279502884,197169399));

function PIfnc:TPrincipal;
begin
    if ConstPi=nil then ConstPi:=NewRationalFromNumber(@ConstdecimalPI_6);
    PIfnc:=TNConstant.create2(constPi.NewCopy) ;
end;
*)

function PIfnc:TPrincipal;
begin
    if ConstPi=nil then ConstPi:=NewRationalFromNumber(@ConstdecimalPI);
    PIfnc:=TNConstant.create2(constPi.NewCopy) ;
end;



{**********}
{initialize}
{**********}

procedure  FunctionTableInit;
begin
 if precisionMode=PrecisionRational then
   begin
       ReservedWordTableInit('MAXNUM' , MAXNUMFnc );
       if UseTranscendentalFunction then
          ReservedWordTableInit('PI'    , PIfnc)
       else
          ReservedWordTableInit('PI' ,NotExistFnc);
   end;
end;

begin
   tableInitProcs.accept(FunctionTableInit);
end.

