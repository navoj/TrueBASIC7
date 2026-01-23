unit expressc;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}
(***************************************)
(* Copyright (C) 2006, SHIRAISHI Kazuo *)
(***************************************)


interface
uses  SysUtils,  Math,
  variabl,express,struct,arithmet,variablc,float ;

procedure SwitchToComplexMode;

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

      function evalX:extended;override;
      procedure EvalN(var n:number);override;
     end;

type
   ComplexFunction1=procedure(var x:complex);
   ComplexFunction2=procedure(var x,y:complex);

type
   TUnaryOpOrdinal=class(TNExpression)
             exp:TPrincipal;
             opC:ComplexFunction1;
          constructor create(e:TPrincipal; op1:FloatFunction1;
                             op2:extendedfunction1;op3:ComplexFunction1;
                             er1,er2:smallint;const n:ansistring);virtual;
          procedure evalC(var x:complex);override;
          destructor destroy;override;
     end;

   TBinaryOpOrdinal=class(TNExpression)
             exp1,exp2:TPrincipal;
             opC:ComplexFunction2;
          constructor create(e1,e2:TPrincipal;op1:FloatFunction2;
                              op2:extendedfunction2; op3:ComplexFunction2;
                              er1,er2:smallint;const n:ansistring);virtual;
          procedure evalC(var x:complex);override;
          destructor destroy;override;
     end;


type
   TUnaryOp=class(TUnaryOpOrdinal)
             opF:FloatFunction1;
             opX:ExtendedFunction1;
             overflowcode:smallint;
             invalidcode:smallint;
             name:ansistring;
          constructor create(e:TPrincipal; op1:FloatFunction1;
                             op2:extendedfunction1;op3:ComplexFunction1;
                             er1,er2:smallint;const n:ansistring);override;
          procedure evalC(var x:complex);override;
          function OverflowErCode:integer;override;
          function InvalidErCode:integer;override;
          function OpName:string;override;
     end;

   TBinaryOp=class(TBinaryOpOrdinal)
             opF:FloatFunction2;
             opX:ExtendedFunction2;
             overflowcode:smallint;
             invalidcode:smallint;
             name:ansistring;
          constructor create(e1,e2:TPrincipal;op1:FloatFunction2;
                              op2:extendedfunction2; op3:ComplexFunction2;
                              er1,er2:smallint;const n:ansistring);override;
          procedure evalC(var x:complex);override;
          function OverflowErCode:integer;override;
          function InvalidErCode:integer;override;
          function OpName:string;override;
     end;


function UnaryCOrdinal(op2:complexfunction1;er2:smallint;const name:ansistring):TPrincipal;
function BinaryCOrdinal(op2:complexfunction2; er2:smallint;const name:ansistring):TPrincipal;
function UnaryC(op2:complexfunction1;er2:smallint;const name:ansistring):TPrincipal;
function BinaryC(op2:complexfunction2; er2:smallint;const name:ansistring):TPrincipal;

function ComplexExp(const c:complex):complex;

implementation
uses
  base,texthand,helpctex,sconsts;

type
   TNConstant=class(TNExpression)
              valueC:complex;
           constructor create(var n:number);
           constructor create2(x:complex);
           procedure evalC(var x:complex);override;
           destructor destroy;override;
           function isConstant:boolean;override;
       end;

type
   TNFunction=class(TNExpression)
          exe   :TCALL;
          constructor create(idr:TIdrec);
          procedure evalC(var x:complex);override;
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

procedure  TNFunction.evalC(var x:complex);
begin
   exe.evalC(x)
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
       CInit(valueC,extendedval(N),0);
    except
       {$IFNDEF WINDOWS}ClearExceptions(False);{$ENDIF}
       flag:=true;
    end;
     {$IFNDEF WINDOWS}SetFPUMask(OriginalCW);{$ENDIF}
    if flag  then
       seterr(s_TooLargeConstant,IDH_JIS_5);
end;

constructor TNConstant.create2(x:complex);
begin
    inherited create;
    valueC:=x;
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


constructor TunaryOpOrdinal.create(e:TPrincipal;op1:FloatFunction1;
                             op2:extendedfunction1;op3:ComplexFunction1;
                            er1,er2:smallint;const n:ansistring);
begin
    inherited  create;
    exp:=e;
    opC:=op3;
end;

constructor TunaryOp.create(e:TPrincipal;op1:FloatFunction1;
                             op2:extendedfunction1;op3:ComplexFunction1;
                            er1,er2:smallint;const n:ansistring);
begin
    inherited  create(e,op1,op2,op3,er1,er2,n);
    opF:=op1;
    opX:=op2;
    overflowcode:=er1;
    invalidcode:=er2;
    name:=n;
end;

destructor TunaryOpOrdinal.destroy;
begin
   exp.free;
   inherited destroy;
end;

constructor TBinaryOpOrdinal.create(e1,e2:TPrincipal; op1:FloatFunction2;
                              op2:extendedfunction2; op3:ComplexFunction2;
                              er1,er2:smallint;const n:ansistring );
begin
    inherited  create;
    exp1:=e1;
    exp2:=e2;
    opC:=op3;
end;

constructor TBinaryOp.create(e1,e2:TPrincipal; op1:FloatFunction2;
                              op2:extendedfunction2; op3:ComplexFunction2;
                              er1,er2:smallint;const n:ansistring );
begin
    inherited  create(e1,e2,op1,op2,op3,er1,er2,n);
    opF:=op1;
    opX:=op2;
    overflowcode:=er1;
    invalidcode:=er2;
    name:=n;
end;

destructor TBinaryOpOrdinal.destroy;
begin
   exp1.free;
   exp2.free;
   inherited destroy;
end;



function UnaryOp( e:TPrincipal;op1:FloatFunction1;op2:extendedfunction1;
                            op3:ComplexFunction1;er1,er2:smallint;
                            opclass:TUnaryOpClass;const name:ansistring):TPrincipal;
var
   p:TPrincipal;
   n:number;
   x:complex;
   flag:boolean;
begin
   p:=opClass.create(e,op1,op2,op3,er1,er2,name);
   if e.isConstant then
        begin
          flag:=true;
          {$IFNDEF WINDOWS};SetFPUMask(NormalCW);{$ENDIF}
          try
            p.evalC(x);
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
               begin
                 extype:=0;
               end;
         end;
   UnaryOp:=p
end;


function BinaryOp( e1,e2:TPrincipal;op1:FloatFunction2;op2:extendedfunction2; op3:ComplexFunction2;
                 er1,er2:smallint; opclass:TBinaryOpClass;const name:ansistring):TPrincipal;
var
   p:TPrincipal;
   n:number;
   x:complex;
   flag:boolean;
begin
   p:=opClass.create(e1,e2,op1,op2,op3,er1,er2,name);
   if e1.isConstant and e2.isConstant then
      begin
         flag:=true;
         {$IFNDEF WINDOWS};SetFPUMask(NormalCW);{$ENDIF}
         try
            p.evalC(x);
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
           begin
             extype:=0;
           end;
      end;
   BinaryOp:=p
end;

(*
function IntPower(c:complex; i: longint): complex;
var
  x,y,t:extended;
  j: longint;
begin
  j := system.Abs(i);
  x:=c.x; y:=c.y;
  result.x:=1.0;  result.y:=0.0;      //Result := 1.0;
  while j > 0 do
   begin
     while not Odd(j) do
     begin
      j := j shr 1;
      t:=sqr(x)-sqr(y); y:=2*x*y; x:=t ;   // X := X * X
     end;
     Dec(j);
     t:=x*result.x-y*result.y; result.y:=y*result.x+x*result.y; result.x:=t; //Result := Result * X
  end;
  if i < 0 then
     begin
        t:=sqr(result.x)+sqr(result.y); result.x:=result.x/t; result.y:=result.y/t;  //Result := 1.0 / Result
     end;
end;
*)

{************}
{Unary Binary}
{************}

type
   TUnaryF=class(TUnaryOP)
          procedure evalC(var c:complex);override;
     end;

   TBinaryF=class(TBinaryOP)
          procedure evalC(var c:complex);override;
     end;

type
  TUnaryX=class(TUnaryOp)
     procedure evalC(var x:complex); override;
   end;

  TBinaryX=class(TBinaryOp)
    procedure evalC(var x:complex);override;
   end;





function Unary(op1:unaryoperation; op2:floatfunction1;er2:smallint;const name:ansistring):TPrincipal;
begin
    Unary:=UnaryOp(argumentN1,op2,nil,nil,1003,er2,TUnaryF,name)
end;

function Binary(op1:binaryoperation; op2:floatfunction2; er2:smallint;const name:ansistring):TPrincipal;
var
   a1:TPrincipal;
begin
   a1:=argumentN2a;
   Binary:=BinaryOp(a1,ArgumentN2b,op2,nil,nil,1003,er2,TBinaryF,name)
end;

function UnaryX(op2:extendedfunction1;er2:smallint;const name:ansistring):TPrincipal;
begin
    UnaryX:=UnaryOp(argumentN1,nil,op2,nil,1003,er2,TUnaryX,name)
end;

function BinaryX(op2:extendedfunction2; er2:smallint;const name:ansistring):TPrincipal;
var
   a1:TPrincipal;
begin
   a1:=argumentN2a;
   BinaryX:=BinaryOp(a1,ArgumentN2b,nil,op2,nil,1003,er2,TBinaryX,name)
end;

function UnaryCOrdinal(op2:complexfunction1;er2:smallint;const name:ansistring):TPrincipal;
begin
   UnaryCOrdinal:=
      ExpressC.UnaryOp(argumentN1,nil,nil,op2,1003,er2,ExpressC.TUnaryOpOrdinal,name)
end;

function BinaryCOrdinal(op2:complexfunction2; er2:smallint;const name:ansistring):TPrincipal;
var
   a1:TPrincipal;
begin
   a1:=argumentN2a;
   BinaryCOrdinal:=
   ExpressC.BinaryOp(a1,ArgumentN2b,nil,nil,op2,1003,er2,ExpressC.TBinaryOpOrdinal,name)

end;

function UnaryC(op2:complexfunction1;er2:smallint;const name:ansistring):TPrincipal;
begin
   UnaryC:=ExpressC.UnaryOp(argumentN1,nil,nil,op2,1003,er2,ExpressC.TUnaryOp,name)
end;

function BinaryC(op2:complexfunction2; er2:smallint;const name:ansistring):TPrincipal;
var
   a1:TPrincipal;
begin
   a1:=argumentN2a;
   BinaryC:=ExpressC.BinaryOp(a1,ArgumentN2b,nil,nil,op2,1003,er2,ExpressC.TBinaryOp,name)

end;

{**********}
{NOperation}
{**********}
type
  TNOperation=class(TNExpression)
       Op:TPrincipal;
    constructor Create(e1:TPrincipal);
    procedure evalC(var x:complex); override;
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
var
  c:complex;
begin
  evalC(c) ;
  if c.y<>0 then setExceptionNonReal;
  result:=c.x
end;

procedure TNExpression.EvalN(var n:number);
begin
   convert(evalX,n)
end;


function TNExpression.str:ansistring;
var
    x:complex;
    n:number;
begin
    evalC(x);
    str:=CStr(x)+' '
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

function TNExpression.evalInteger:integer;
var
   n:double;
begin
   n:=EvalX;
   if n>=maxint then   result:=maxint
   else if n<=MinInt then result:=MinInt
   else result:=system.round(n);
end;

function TNExpression.evalLongint:longint;
begin
   result:=LongIntRound(evalX);
end;

function TNExpression.substance0(ByVal:boolean):TVar;
var
    x:complex;
begin
    evalC(x);
    substance0:=TOrthoCVar.createC(x)
end;

procedure TNExpression.disposeSubstance0(p:TVar; ByVal:boolean);
begin
     p.free;
end;

function TNExpression.substance1:TVar;
var
    x:complex;
begin
    evalC(x);
    substance1:=TOrthoCVar.createC(x)
end;

procedure TNExpression.disposeSubstance1(p:TVar);
begin
     p.free;
end;

function TNExpression.compare(p:TPrincipal):integer;
var
   n1,n2:double;
begin
    n1:=evalX;
    n2:=p.evalX;
    compare:=fcompare(n1,n2);
end;

procedure  TNConstant.evalC(var x:complex);
begin
    x:=valueC;
end;

function FPUerState:bytebool;assembler;inline;
asm
   fstsw  ax
   and    ax, 0Dh
   FCLEX
end;

{
procedure testComplex( const opName:string; overflowcode, invalidcode:integer);
var
   a:ByteBool;
begin
   a:=FPUerState;
   if ByteBool(a) then
      if bytebool(byte(a) and 10) then
          setexceptionwith(opName,overflowcode)
      else
          setexceptionwith(opName,invalidcode);
end;
}

procedure TUnaryOpOrdinal.evalC(var x:complex);
begin
    exp.evalC(x);
    opC(x);
    //TestComplex(opName, OverflowErCode, InvalidErCode);
end;

procedure TUnaryOp.evalC(var x:complex);
begin
    exp.evalC(x);
    currentoperation:=self;
    opC(x);
    asm fwait end;
    currentoperation:=nil;

    //TestComplex(opName, OverflowErCode, InvalidErCode);
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

procedure  TBinaryOpOrdinal.evalC(var x:complex);
var
    m:complex;
begin
    exp1.evalC(x);
    exp2.evalC(m);
    opC(x,m);
    //TestComplex( opName, OverflowErCode, InvalidErCode);
end;

procedure  TBinaryOp.evalC(var x:complex);
var
    m:complex;
begin
    exp1.evalC(x);
    exp2.evalC(m);
    currentoperation:=self;
    opC(x,m);
    asm fwait end; currentoperation:=nil;
    //TestComplex( opName, OverflowErCode, InvalidErCode);
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

function IntPower(const c:complex; i: longint): complex;
var
  x,t:ExtComplex;
begin
  x.initC(c);
  if i<0 then
     begin
       i:=-i;
       x.inverse;
     end;
  t.init(1,0);             //Result := 1.0;
  while i > 0 do
   begin
     while not Odd(i) do
     begin
      i := i shr 1;
      x.square;            // X := X * X
     end;
     Dec(i);
     t.multiply(@x);       //Result := Result * X
  end;
  result.x:=t.x; result.y:=t.y
end;



function PowerSub(Base,Exponent:extended):extended;
begin
     if ABS(BASE-1)>0.125 then
       Result :=NPXPower(Base,Exponent) {Exp(Exponent * Ln(Base)) }
    else
       Result:=NPXPower1Plus(Base-1,Exponent);
end;

function ComplexExp(const c:complex):complex;
var
    e:extended;
begin
    e:=exp(c.x);
    result.x:=e*cos(c.y);
    result.y:=e*sin(c.y);
end;

function ComplexPower(Base:extended; Exponent: complex): complex;
var
   t:extended;
   y:Complex;
begin
   if Exponent.y=0.0 then
      begin
        result.x:=PowerSub(base,Exponent.x);
        result.y:=0;
      end
   else
      begin
         t:=ln(Base);
         y.x:=t*Exponent.x;
         y.y:=t*Exponent.y;
         result:=ComplexExp(y)
      end;
end;

function Power(const Base, Exponent: complex): complex;
begin
  if (Exponent.x=0) and (exponent.y=0) then
     CInit(result,1.0,0)   //Result := 1.0
  else if (Base.x=0)and (Base.y=0) and ((Exponent.y<>0) or (exponent.x<0)) then
          setexception(3003)
  else if (Exponent.y=0) and  (frac(exponent.x)=0.0) and
          (Exponent.x > -Maxint) and (Exponent.x < MaxInt)   then
       Result := IntPower(Base, Trunc(Exponent.x))
  else if (Base.y=0.0) and (Base.x>0.0) then
         result:=ComplexPower(base.x, Exponent)
  else if (Base.x=0)and (Base.y=0) and (Exponent.y=0.0) and (Exponent.x>0) then
       CInit(result,0,0)
  else
     begin
        CInit(result,0,0);
        if (Base.x=0)and (Base.y=0) then
           setexception(3003)
        else
           setexception(3002) ;
      end;
end;

procedure CPower( var x,y:complex);
begin
    x:=Power(x,y)
end;

{$IFDEF CPU32}
procedure CSquare(var x:complex);assembler;
asm
   fld qword ptr [eax]      //x.x
   fld qword ptr [eax+$08]  //x.y
   fld  st(1)              // x.x
   fmul st,st(0)           // x.x^2
   fld  st(1)              // x.y
   fmul st,st(0)           // x.y^2
   fsub                    // x.x^2-x.y^2
   fstp qword ptr [eax]
   fmulp st(1),st          // x.x*x.y
   fadd st,st(0)           // 2*x.x*x.y
   fstp qword ptr [eax+$08]
   wait
 end;
{$ELSE}
procedure CSquare(var x:complex);
var
   z:complex;
begin
   z.x:= sqr(x.x)-sqr(x.y);
   z.y:=2*x.x * x.y;
   x:=z;
end;
{$ENDIF}

procedure COppose(var x:complex);
begin
    x.x:=-x.x; x.y:=-x.y
end;


function OpPower(e1,e2:TPrincipal):TPrincipal;
begin
   result:=BinaryOp(e1,e2,nil,nil,CPower,1002,1002,TBinaryOp,'^')
end;

function OpSquare(e1:TPrincipal):TPrincipal;
begin
  result:=UnaryOp(e1,nil,nil,CSquare,1002,1002,TUnaryOpOrdinal,'^')
end;

function  OpUnaryMinus(e1:TPrincipal):TPrincipal;
begin
     result:=UnaryOp(e1,nil,nil, COppose,1002,1002,TUnaryOpOrdinal,'-');
end;

function OpTimes(e1,e2:TPrincipal):TPrincipal;
begin
    result:=BinaryOp(e1,e2,nil,nil,CMultiply,  1002,1002,TBinaryOpOrdinal,'*');
end;

function OpDivide(e1,e2:TPrincipal):TPrincipal;
begin
    result:=BinaryOp(e1,e2,nil,nil,CDiv     ,  1002,3001,TBinaryOpOrdinal,'/');
end;

function OpPlus(e1,e2:TPrincipal):TPrincipal;
begin
    result:=BinaryOp(e1,e2, nil,nil,CAdd, 1002,1002,TBinaryOpOrdinal,'+');
end;

function OpMinus(e1,e2:TPrincipal):TPrincipal;
begin
    result:=BinaryOp(e1,e2, nil,nil,CSub, 1002,1002,TBinaryOpOrdinal,'-');
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


function NewNumericVariC:TVar;
begin
   result:=TOrthoCVar.create
end;

function
   NewNumericArrayC(dim:integer;const lbound,ubound:Array4):TVar;
begin
   result:=TCArray.create(dim,lbound,ubound,0)
end;

procedure TUnaryF.evalC(var c:complex);
begin
    exp.evalC(c);
    if (c.y=0) then
       begin
          currentoperation:=self;
          opF(c.x);
          asm fwait end; currentoperation:=nil;
      end
    else
        setexceptionwith(name + '('+CStr(c)+')',3000)  ;
end;

procedure  TBinaryF.evalC(var c:complex);
var
    m:complex;
begin
    exp1.evalC(c);
    exp2.evalC(m);
    if (c.y=0) and (m.y=0) then
       begin
          opF(c.x,m.x);
        end
    else
             setexceptionwith(name + '('+CStr(c)+','+CStr(m)+')',3000)  ;
end;


procedure TUnaryX.evalC(var x:complex);
var
   y:complex;
   b:bytebool;
begin
       exp.evalC(y);
       if y.y=0.0 then
         begin
           x.y:=0.0;
           currentoperation:=self;
           x.x:=opX(y.x);
           asm fwait end;
           currentoperation:=nil;
         end
      else
          setexceptionwith(name+'('+CStr(y)+')',3000);
end;

procedure  TBinaryX.evalC(var x:complex);
var
    y,z:complex;
    b:bytebool;
begin
    exp1.evalC(y);
    exp2.evalC(z);
       if (y.y=0.0) and (z.y=0.0) then
         begin
            x.y:=0.0;
            x.x:=opX(y.x,z.x);
         end
       else
         setexceptionwith(name+'('+CStr(y)+','+CStr(z)+')',3000);
end;

procedure TNOperation.evalC(var x:complex);
begin
   op.EvalC(x)
end;

{************}
{NSubscripted}
{************}
type
   TNSubscripted=class(TSubscripted)
       function evalX:extended;override;
       procedure evalC(var c:complex);override;
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
   CInit(TCArray(subs.ptr).CAry^[position],1,0);
end;


procedure TNSubscripted.assign(exp:TPrincipal);
var
  c:complex;
begin
    exp.evalC(c);
    TCArray(subs.ptr).CAry^[position]:=c;
end;

procedure TNSubscripted.assignwithNoRound(exp:TPrincipal);
var
  c:complex;
begin
    exp.evalC(c);
    TCArray(subs.ptr).CAry^[position]:=c;
end;

procedure  TNSubscripted.assignX(x:extended);
begin
   CInit(TCArray(subs.ptr).CAry^[position],x,0);
end;

procedure TNSubscripted.assignLongint(i:longint);
begin
   CInit(TCArray(subs.ptr).CAry^[position],i,0);
end;

function TNSubscripted.evalX:extended;
begin
   result:=(TCArray(subs.ptr).CAry^[position]).x;
end;

procedure TNSubscripted.evalC(var c:complex);
begin
   c:=TCArray(subs.ptr).CAry^[position];
end;


function TNSubscripted.evalInteger:Integer;
var
   c:complex;
begin
   c:=TCArray(subs.ptr).CAry^[position];
   if c.y<>0 then setExceptionNonReal;
   if c.x>=maxint then result:=maxint
   else if c.x<=minint then result:=minint
   else result:=System.Round(c.x)
end;

function TNSubscripted.evalLongint:longint;
begin
  result:=LongIntRound
                                     (TCArray(subs.ptr).CAry^[position].x);
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
     substance0:=TrefCVar.createRef(TCArray(subs.ptr).CAry^[position]);
end;

procedure TNSubscripted.disposesubstance0(p:TVar; ByVal:boolean);
begin
   p.Free
end;

function TNSubscripted.substance1:TVar;
begin
    result:=TorthoCVar.createC(TCArray(subs.ptr).CAry^[position]);
end;

procedure TNSubscripted.disposesubstance1(p:TVar);
begin
     p.free
end;

function TNSubscripted.compare(exp:TPrincipal):integer;
var
   c:Complex;
begin
   exp.evalC(c);
   compare:=Ccompare(TCArray(subs.ptr).CAry^[position],c);
end;

function TNSubscripted.sign:integer;
var
   c:complex;
begin
   c:=TCArray(subs.ptr).CAry^[position];
   sign:=fsign(c.x);
   if (c.y<>0) then setexceptionwith(s_ImaginaryHasNoSign,3000);
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


function TEqual.evalBool:boolean;
var
  c1,c2:complex;
begin
  exp1.evalC(c1);
  exp2.evalC(c2);
  result:=(c1.x=c2.x) and (c1.y=c2.y)
end;

function TNotEqual.evalBool:boolean;
var
  c1,c2:complex;
begin
  exp1.evalC(c1);
  exp2.evalC(c2);
  result:=(c1.x<>c2.x) or (c1.y<>c2.y)
end;


function TGreater.evalBool:boolean;
var
  c1,c2:complex;
begin
  exp1.evalC(c1);
  exp2.evalC(c2);
  if (c1.y=0) and (c2.y=0) then
      result:=(c1.x>c2.x)
   else
      setexceptionwith(s_ImaginaryInComparable,3000);
end;


function TGreaterOrEq.evalBool:boolean;
var
  c1,c2:complex;
begin
  exp1.evalC(c1);
  exp2.evalC(c2);
  if (c1.y=0) and (c2.y=0) then
      result:=(c1.x>=c2.x)
   else
      setexceptionwith(s_ImaginaryInComparable,3000);
end;

function TSmaller.evalBool:boolean;
var
  c1,c2:complex;
begin
  exp1.evalC(c1);
  exp2.evalC(c2);
  if (c1.y=0) and (c2.y=0) then
      result:=(c1.x<c2.x)
   else
      setexceptionwith(s_ImaginaryInComparable,3000);
end;

function TSmallerOrEq.evalBool:boolean;
var
  c1,c2:complex;
begin
  exp1.evalC(c1);
  exp2.evalC(c2);
  if (c1.y=0) and (c2.y=0) then
      result:=(c1.x<=c2.x)
   else
      setexceptionwith(s_ImaginaryInComparable,3000);
end;



function NComparison(f:comparefunction; e1,e2:TPrincipal):TLogical;
begin
    if (@f=@Equals) then
         NComparison:=TEqual.create(e1,e2)
    else if (@f=@NotEquals) then
          NComparison:=TNotEqual.create(e1,e2)
    else if (@f=@Greater) then
          NComparison:=TGreater.create(e1,e2)
    else if (@f=@NotLess) then
          NComparison:=TGreaterOrEq.create(e1,e2)
    else if (@f=@Less) then
          NComparison:=TSmaller.create(e1,e2)
    else if (@f=@NotGreater) then
          Ncomparison:=TSmallerOrEq.create(e1,e2);
end;

{***********}
{Mode Switch}
{***********}
procedure SwitchToComplexMode;
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
   c:complex;
begin
   c.x:=maxnumberDouble; c.y:=0;
   MAXNUMfnc:=expressC.TNConstant.create2(c)
end;

function PIfnc:TPrincipal;
var
   c:complex;
begin
    c.x:=pi; c.y:=0;
    PIfnc:=TNConstant.create2(c) ;
end;

{**********}
{initialize}
{**********}

procedure  FunctionTableInit;
begin
 if precisionMode=PrecisionComplex then
   begin
       ReservedWordTableInit('MAXNUM' , MAXNUMfnc );
       ReservedWordTableInit(  'PI' ,  PIfnc);
   end;
end;

begin
   tableInitProcs.accept(FunctionTableInit);
end.

