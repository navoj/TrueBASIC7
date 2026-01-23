unit variablc;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

{$A+}

(***************************************)
(* Copyright (C) 2006, SHIRAISHI Kazuo *)
(***************************************)

interface
uses sysUtils, math,
     base,arithmet,variabl;

type

   TBasisCVar=class(TAutoVar)     {Hardware Floating Point Variable }
       public
          //procedure substN(var n:number);override;
          //procedure getN(var n:number);override;
          procedure GetC(var c:complex);virtual;abstract;
          procedure substC(c:complex);virtual;abstract;
          function GetValue:complex;virtual;abstract;
          function GetPValue:PComplex;virtual;abstract;

          procedure copyfrom(p:TVar);override;
          procedure read(const s:ansiString);override;
          procedure readData(const s:ansiString);override;
          function str:ansiString;override;
          function str2:ansiString;override;
          function format(const form:ansiString; var index,code:integer):ansistring;override;
     end;

     TOrthoCVar=Class(TBasisCVar)
          Value:complex;
          procedure GetC(var c:complex);override;
          procedure substC(c:complex);override;
          function GetValue:complex;override;
          function GetPValue:PComplex;override;

          procedure substZero;override;
          procedure substOne;override;
          procedure assignwithRound(exp:TPrincipal);override;
          procedure assignwithNoRound(exp:TPrincipal);override;
          procedure assignX(x:extended);override;
          procedure assignLongint(i:longint);override;
          procedure getX(var x:extended);override;
          function evalInteger:integer;override;
          function evalLongint:longint;override;
          function NewElement:TVar;override;
          function newcopy:TVar;override;
          procedure add(p:TVar);override;
          procedure multiply(p:TVar);override;
          procedure subtract(p:TVar);override;
          procedure addWithNoRound(p:TVar);override;
          procedure multiplyWithNoRound(p:TVar);override;
          function compare(p:TVar):integer;override;
          function compareP(exp:TPrincipal):integer;override;
          function sign:integer;override;
          procedure swap(p:TVar);override;
          constructor createC(const c:complex);
          constructor create;
        private
     end;

     TrefCVar=Class(TBasisCVar)
          PValue:PComplex;
          procedure GetC(var c:complex);override;
          procedure substC(c:complex);override;
          function GetValue:complex;override;
          function GetPValue:PComplex;override;

          procedure substZero;override;
          procedure substOne;override;
          procedure assignwithRound(exp:TPrincipal);override;
          procedure assignwithNoRound(exp:TPrincipal);override;
          procedure assignX(x:extended);override;
          procedure assignLongint(i:longint);override;
          procedure getX(var x:extended);override;
          function evalInteger:integer;override;
          function evalLongint:longint;override;
          function NewElement:TVar;override;
          function newcopy:TVar;override;
          procedure add(p:TVar);override;
          procedure multiply(p:TVar);override;
          procedure subtract(p:TVar);override;
          procedure addWithNoRound(p:TVar);override;
          procedure multiplyWithNoRound(p:TVar);override;
          function compare(p:TVar):integer;override;
          function compareP(exp:TPrincipal):integer;override;
          function sign:integer;override;
          procedure swap(p:TVar);override;
          constructor createRef(var c:Complex);
        private
     end;
(*
   TCVar=class(TAutoVar)
       public
          constructor create;
          //procedure substN(var n:number);override;
          procedure substC(var c:complex);
          procedure substZero;override;
          procedure substOne;override;
          procedure copyfrom(p:TVar);override;
          procedure assignwithRound(exp:TPrincipal);override;
          procedure assignwithNoRound(exp:TPrincipal);override;
          procedure assignX(x:extended);override;
          procedure assignLongint(i:longint);override;
          //procedure getN(var n:number);override;
          procedure getX(var x:extended);override;
          procedure getC(var x:complex);  //override;
          function evalInteger:integer;override;
          function evalLongint:longint;override;
          procedure swap(p:TVar);override;
          procedure read(const s:ansiString);override;
          procedure readData(const s:ansiString);override;
          function str:ansiString;override;
          function str2:ansiString;override;
          function format(const form:ansiString; var index,code:integer):ansistring;override;
          function NewElement:TVar;override;
          function newcopy:TVar;override;
          procedure add(p:TVar);override;
          procedure multiply(p:TVar);override;
          procedure subtract(p:TVar);override;
          procedure addWithNoRound(p:TVar);override;
          procedure multiplyWithNoRound(p:TVar);override;
          function compare(p:TVar):integer;override;
          function compareEQ(p:TVar):integer;override;
          function compareP(exp:TPrincipal):integer;override;
          function compareEQP(exp:TPrincipal):integer;override;
          function sign:integer;override;
          constructor createC(const c:complex);
       private
          value:complex;
          constructor createF(x:double);
     end;
*)



type
     TComplexArray=array [0..1023] of Complex;
     PComplexArray=^TComplexArray;

     TCArray=class(TNewArray)
         CAry:PComplexArray;
         constructor create(d:integer;const lb,ub:Array4; m:integer );override;
         constructor createNative(d:integer;const sz:Array4);override;
         constructor createFrameCopy(p:TArray);override;
         destructor destroy;override;
         procedure substOne;override;
         procedure substZero;override;
         procedure SubstIDN;override;

         procedure ItemGetC(i:integer; var c:Complex);
         procedure ItemAssignC(i:integer; c:Complex);
         procedure ItemGetX(i:integer; var x:Extended);override;
         procedure ItemGetF(i:integer; var x:Double);override;
         procedure ItemAssignX(i:integer; x:extended);override;
         procedure ItemAssignLongInt(i:integer; c:longint);override;
         function ItemEvalInteger(i:integer):integer;override;
         function MaxSize:integer;override;

         function ItemSubstance0(i:integer; ByVal:boolean):TVar;override;
         function ItemSubstance1(i:integer):TVar;override;
         procedure DisposeSubstance0(p:Tvar; ByVal:boolean);override;
         procedure DisposeSubstance1(p:Tvar );override;

         function matsubst(p:TArray):boolean;override;
         procedure add(p:TVar);override;
         procedure subtract(p:TVar);override;
         procedure scalarMulti(p:TVar);override;
         procedure matproduct(a1,a2:TArray);override;
         function dotproduct(a:TArray):TVar;override;
         function trn:Tarray;override;

         function RedimNative(const sz:Array4; CanCreate:boolean):boolean;override;
         function determinant(var n:complex):boolean;
         function NewElement:TVar;override;
         function newcopy:TVar;override;
         function inverse:TArray;override;
      protected
         constructor createDup(p:TArray);override;
         procedure CrossProductSub(a,b:TArray);override;
      private
         CArySize:integer;
         procedure initArray;
     end;

(*
type
     TCArray=class(TlegacyArray)
          function NewElement:TVar;override;
          function newcopy:TVar;override;
          function determinant(var n:complex):boolean;
          function inverse:TArray;override;
          procedure matproduct(a1,a2:TArray);override;
       protected
          function NewAry(s:integer):TVarList;override;
       private
     end;
*)

procedure CInit(var x:complex; a,b:double);
procedure CAdd(var x,y:complex);
procedure CSub(var x,y:complex);
procedure CMultiply(var x,y:complex);
procedure CDiv (var  x,y:complex);
function CEqual(var x,y:complex):boolean;
function CEqZero(var x:complex):boolean;
function CCompare(var x,y:complex):integer;
function CCompareEQ(var x,y:complex):integer;
function CStr(var x:complex):AnsiString;

procedure setExceptionNonReal;

type
  PExtComplex=^ExtComplex;
  ExtComplex=packed object
      x:extended ;
      y:extended ;
      procedure init(a,b:extended);
      procedure initC(c:complex);
      procedure add(p:PExtComplex);
      procedure multiply(p:PExtComplex);
      procedure divide(p:PExtComplex);
      procedure subtract(p:PExtComplex);
      procedure oppose;
      procedure square;
      procedure inverse;
      function iszero:boolean;
      procedure GetC(var c:complex);
    end;


implementation
uses   format,float,sconsts;




{ Complex Arithmetic}

procedure CInit(var x:complex; a,b:double);
begin
   x.x:=a; x.y:=b
end;

procedure CAdd(var x,y:complex);
begin
      x.x:=x.x+y.x;
      x.y:=x.y+y.y;
      //TestFPU;
end;

procedure CSub(var x,y:complex);
begin
      x.x:=x.x-y.x;
      x.y:=x.y-y.y;
      //TestFPU;
end;

{$IFDEF CPU32}
procedure CMultiplySub(var x,y:complex);assembler;
asm
   fld qword ptr [eax]      //x.x
   fld qword ptr [eax+$08]  //x.y
   fld qword ptr [edx]      //y.x
   fld qword ptr [edx+$08]  //y.y
   fld  st(3)              // x.x
   fmul st,st(1)           // x.x*y.y
   fld  st(3)              // x.y
   fmul st,st(3)           // x.y*y.x
   fadd                    // x.x*y.y+x.y*y.x
   fstp qword ptr [eax+$08]
   fmulp st(2),st          // x.y*y.y
   fmulp st(2),st          // x.x*y.x
   fsub                    // x.x*y.x-x.y*y.y
   fstp qword ptr [eax]
   wait
 end;

procedure CMultiply(var x,y:complex); inline;
begin
   CMultiPlySub(x,y);
   //TestFPU
end;
{$ELSE}

procedure CMultiply(var x,y:complex);
var
  z:complex;
begin
   z.x:=x.x * y.x - x.y * y.y;
   z.y:=x.x * y.y + x.y * y.x;
   x:=z;
end;
{$ENDIF}

(*
procedure CDiv (var  x,y:complex);assembler;
asm
   fld qword ptr [eax]      //x.x
   fld qword ptr [eax+$08]  //x.y
   fld qword ptr [edx]      //y.x
   fld qword ptr [edx+$08]  //y.y
   fld st(1)               //y.x
   fmul st,st(0)           //y.x^2
   fld st(1)               //y.y
   fmul st,st(0)           //y.y^2
   fadd                    //y.x^2+y.y^2
   fdiv  st(2),st          // y.x←y.x/(y.x^2+y.y^2)
   fdivp st(1),st          // y.y←y.y/(y.x^2+y.y^2)
   fld  st(2)              // x.y
   fmul st,st(2)           // x.y*y.x
   fld  st(4)              // x.x
   fmul st,st(2)           // x.x*y.y
   fsub                    // x.y*y.x-x.x*y.y
   fstp qword ptr [eax+$08]
   fmulp st(2),st          // x.y*y.y
   fmulp st(2),st          // x.x*y.x
   fadd                    // x.x*y.x+x.y*y.y
   fstp qword ptr [eax]
   wait
 end;
*)


procedure CDiv (var  x,y:complex);
{$MAXFPUREGISTERS 0}
var
  z:complex;
  n:extended;
begin
   n:= sqr(y.x) + sqr(y.y);
   if n=0 then begin setexception(3001); exit end;
   z.x:=(x.x * y.x + x.y * y.y)/n;
   z.y:=(x.y * y.x - x.x * y.y)/n;
   x:=z;
   //TestFPU;
end;

function CEqual(var x,y:complex):boolean;
begin
   result:=(x.x=y.x) and (x.y=y.y)
end;

function  CEqZero(var x:complex):boolean;
begin
   result:=(x.x=0) and (x.y=0)
end;

function CCompare(var x,y:complex):integer;
begin
   if (x.y=0) and (y.y=0) then
      CCompare:=fcompare(x.x, y.x)
   else
      setexceptionwith(s_ImaginaryInComparable,3000);
end;

function CCompareEQ(var x,y:complex):integer;
begin
   if (x.x=y.x) and (x.y=y.y) then
      CCompareEQ:=0                          //一致するとき0
   else
      CCompareEQ:=1;                         //一致しないとき1
end;

function CStr(var x:complex):AnsiString;
var
  n:number;
begin
    convert(x.x,n);
    result:=Dstr(n);
    if x.y<>0 then
    begin
       convert(x.y,n);
       result:='(' + result +' '+ DStr(n) + ')';
    end;
end;


{*****}
{TCVar}
{*****}

procedure TbasisCVar.copyfrom(p:TVar);
begin
   substC(TbasisCVar(p).getValue)
end;


constructor TorthoCVar.create;
begin
     inherited create;
     {value:=0;}
end;


procedure TorthoCVar.substZero;
begin
    value.x:=0;
    value.y:=0;
end;

procedure TorthoCVar.substOne;
begin
    value.x:=1;
    value.y:=0;
end;

procedure TorthoCVar.assignWithRound(exp:TPrincipal);
var
   c:complex;
begin
   exp.evalC(c);
   value:=c;
end;

procedure TorthoCVar.assignwithNoRound(exp:TPrincipal);
begin
   assignWithRound(exp)
end;

procedure TorthoCVar.assignX(x:extended);
begin
    value.x:=x;
    value.y:=0;
end;

procedure TorthoCVar.assignLongint(i:longint);
begin
      value.x:=i;
      value.y:=0;
end;


procedure  TorthoCVar.getC(var c:complex);
begin
     c:=value ;
end;

procedure TorthoCVar.substC(c:complex);
begin
   value:=c
end;

function TorthoCvar.GetValue:complex;
begin
  result:=value
end;

function TorthoCvar.GetPValue:PComplex;
begin
  result:=@value
end;

procedure  TorthoCVar.getX(var x:extended);
begin
     x:=value.x ;
end;

function TorthoCVar.EvalInteger:Integer;
begin
  if Value.y<>0 then setExceptionNonReal;
  if value.x>maxint then result:=maxint
  else if value.x <minInt then result:=MinInt
  else result:=system.round(value.x);
end;

function TorthoCVar.EvalLongint:longint;
begin
    result:=LongIntRound(value.x);
end;


function TorthoCVar.newcopy:TVar;
begin
   result:=TorthoCVar.createC(value);
end;

function TorthoCVar.NewElement:TVar;
begin
   result:=TorthoCVar.create;
end;

constructor TorthoCVar.createC(const c:complex);
begin
    inherited create;
    value:=c;
end;

procedure TorthoCVar.add(p:TVar);
begin
    CAdd(value,TbasisCVar(p).getPValue^);
end;

procedure TorthoCVar.multiply(p:TVar);
begin
   CMultiply(value,TbasisCVar(p).getPValue^);
end;

procedure TorthoCVar.subtract(p:TVar);
begin
   CSub(value,TbasisCVar(p).getPValue^);
end;

procedure TorthoCVar.addwithNoRound(p:TVar);
begin
   CAdd(value,TbasisCVar(p).getPValue^);
end;

procedure TorthoCVar.multiplywithNoRound(p:TVar);
begin
   multiply(p);
end;

function TorthoCVar.compare(p:TVar):integer;
begin
    compare:=Ccompare(value,TbasisCVar(p).getPValue^)
end;


function TorthoCVar.compareP(exp:TPrincipal):integer;
var
   c:complex;
begin
   exp.evalC(c);
   compareP:=Ccompare(value,c)
end;

function TorthoCVar.sign:integer;
begin
   sign:=fsign(value.x);
   if (value.y<>0) then setexceptionwith(s_ImaginaryHasNoSign,3000);
end;

procedure TorthoCVar.swap(p:TVar);
var
   c:complex;
begin
   c:=value;
   value:=TBasisCVar(p).GetValue;
   TBasisCVar(p).SubstC(c);
end;



constructor TrefCVar.createRef(var c:Complex);
begin
  inherited create;
  PValue:=@c
end;


procedure TrefCVar.substZero;
begin
   CInit(PValue^,0,0);
end;

procedure TrefCVar.substOne;
begin
   CInit(PValue^,1,0);
end;


procedure TrefCVar.assignWithRound(exp:TPrincipal);
var
   c:Complex;
begin
   exp.evalC(c);
   PValue^:=c;
end;

procedure TrefCVar.assignwithNoRound(exp:TPrincipal);
begin
   assignWithRound(exp);
end;

procedure TrefCVar.assignX(x:extended);
begin
    CInit(PValue^,x,0);
end;

procedure TrefCVar.assignLongint(i:longint);
begin
    CInit(PValue^,i,0);
end;


procedure  TrefCVar.getC(var c:Complex);
begin
     c:=PValue^ ;
end;

procedure TrefCVar.substC(c:complex);
begin
   PValue^:=c
end;

function TrefCVar.GetValue:complex;
begin
  result:=PValue^
end;

function TrefCVar.GetPValue:PComplex;
begin
  result:=PValue
end;

procedure  TrefCVar.getX(var x:extended);
begin
     x:=PValue^.x ;
end;

function TrefCVar.EvalInteger:Integer;
begin
  if PValue^.y<>0 then setExceptionNonReal;
  if PValue^.x>maxint then result:=maxint
  else if PValue^.x <minInt then result:=MinInt
  else result:=system.round(PValue^.x);
end;

function TrefCVar.EvalLongint:longint;
begin
    result:=LongIntRound(PValue^.x);
end;


function TrefCVar.newcopy:TVar;
begin
   result:=TorthoCVar.createC(PValue^);
end;

function TrefCVar.NewElement:TVar;
begin
   result:=TorthoCVar.create;
end;


procedure TrefCVar.add(p:TVar);
begin
   CAdd(PValue^,TbasisCVar(p).getPValue^);
end;

procedure TrefCVar.multiply(p:TVar);
begin
   CMultiply(PValue^, TbasisCVar(p).getPValue^);
end;

procedure TrefCVar.subtract(p:TVar);
begin
   CSub(PValue^,TbasisCVar(p).getPValue^);
end;

procedure TrefCVar.addwithNoRound(p:TVar);
begin
   CAdd(PValue^,TbasisCVar(p).getPValue^);
end;

procedure TrefCVar.multiplywithNoRound(p:TVar);
begin
   CAdd(PValue^,TbasisCVar(p).getPValue^);
end;

function TrefCVar.compare(p:TVar):integer;
begin
    compare:=Ccompare(PValue^,TbasisCVar(p).getPValue^)
end;


function TrefCVar.compareP(exp:TPrincipal):integer;
var
   c:complex;
begin
   exp.evalC(c);
   compareP:=Ccompare(PValue^,c)
end;

function TrefCVar.sign:integer;
begin
   sign:=fsign(PValue^.x);
   if (PValue^.y<>0) then setexceptionwith(s_ImaginaryHasNoSign,3000);
end;

procedure TrefCVar.swap(p:TVar);
var
   c:complex;
begin
   c:=PValue^;
   TbasisCVar(p).getC(PValue^);
   TbasisCVar(p).substC(c)
end;

(*
constructor TCVar.create;
begin
     inherited create;
     {value:=0;}
end;

procedure TCVar.substC(var c:complex);
begin
    value:=c;
    {
    value.x:=c.x;
    value.y:=c.y;
    }
end;

{
 procedure TCVar.substN(var n:number);
begin
    value.x:=extendedVal(n);
    value.y:=0;
end;
}

procedure TCVar.substZero;
begin
    value.x:=0;
    value.y:=0;
end;

procedure TCVar.substOne;
begin
    value.x:=1;
    value.y:=0;
end;

procedure TCVar.copyfrom(p:TVar);
begin
    value:=TCVar(p).value
end;

procedure TCVar.assignWithRound(exp:TPrincipal);
var
   c:complex;
begin
   exp.evalC(c);
   substC(c);
end;

procedure TCVar.assignwithNoRound(exp:TPrincipal);
var
   c:complex;
begin
   exp.evalC(c);
   substC(c);
end;

procedure TCVar.assignX(x:extended);
begin
    value.x:=x;
    value.y:=0;
end;

procedure TCVar.assignLongint(i:longint);
begin
      value.x:=i;
      value.y:=0;
end;
*)
procedure setExceptionNonReal;
begin
   SetexceptionWith(s_ImaginaryNotAvailable,1000)
end;

(*
procedure  TCVar.getX(var x:extended);
var
   c:Complex;
begin
   c:=GetValue;
   x:=c.x ;
   if c.y<>0.0 then  setExceptionNonReal ;
end;

procedure  TCVar.getC(var x:complex);
begin
     x:=getValue ;
end;
*)
(*
function TBasisCVar.evalInteger:integer;
var
   d:Double;
begin
  if GetValue.y<>0 then setExceptionNonReal;
  d:=GetValue.x;
  if d>maxint then result:=maxint
  else if d<MinInt then result:=MinInt
  else result:=system.round(d);
end;

function TBasisCVar.evalLongint:longint;
begin
  result:=LongIntRound(GetValue.x);
end;

procedure TCVar.swap(p:TVar);
var
   c:complex;
begin
   c:=value;
   value:=TCVar(p).value;
   TCVar(p).value:=c
end;
*)

procedure TBasisCVar.read(const s:ansiString);
var
   code:integer;
   c:complex;
   i,j,k:integer;
   s1,s2:ansistring;
begin
   i:=pos('(',s);
   if i=0 then
    begin
        try
           Val(s,c.x,code);            {!!!!!!!!!!要修正!!!!!!!!!}
           if code<>0 then setexception(8101);
        except
           on EMathError do setexception(1006);
        end;
        c.y:=0;
        SubstC(c);
    end
   else
    begin
      j:=i+2;
      while (j<=length(s)) and (s[j]<>' ') do inc(j);
      k:=pos(')',s);
      s1:=copy(s,i+1,j-i-1);
      s2:=copy(s,j+1,k-j-1);
      try
         Val(s1,c.x,code);            {!!!!!!!!!!要修正!!!!!!!!!}
         if code<>0 then setexception(8101);
         Val(s2,c.y,code);             {!!!!!!!!!!要修正!!!!!!!!!}
         if code<>0 then setexception(8101);
       except
         on EMathError do setexception(1006);
      end;
      SubstC(c);
    end;
end;

procedure TBasisCVar.readdata(const  s:ansiString);
begin
   read(s)
end;

function TBasisCVar.str:ansiString;
begin
   result:=CStr(GetPValue^)+' '
end;

function TBasisCVar.str2:ansiString;
var
  svsigniwidth:integer;
begin
    svsigniwidth:=signiwidth;
    signiwidth:=17;
    str2:=str;
    signiwidth:=svsigniwidth;
end;

function TBasisCVar.format(const form:ansiString; var index,code:integer):ansistring;
var
  n:number;
begin
    // 実部に対してのみ適用する。
    convert(GetValue.x,n);
    result:=formatnum(componentsN(n),form,index,code);
    if GetValue.y<>0 then setexceptionWith(s_FormatInvalidForImaginary,8202)
end;

(*
function TCVar.newcopy:TVar;
begin
   result:=TCVar.createC(value);
end;

function TCVar.NewElement:TVar;
begin
   result:=TCVar.create;
end;

constructor TCVar.createF(x:double);
begin
    inherited create;
    value.x:=x;
end;

constructor TCVar.createC(const c:complex);
begin
    inherited create;
    value:=c;
end;

procedure TCVar.add(p:TVar);
begin
    CAdd(value, TCVar(p).value);
end;

procedure TCVar.multiply(p:TVar);
begin
    CMultiply(value, TCvar(p).value);
end;

procedure TCVar.subtract(p:TVar);
begin
    CSub(value,TCVar(p).value);
end;

procedure TCVar.addwithNoRound(p:TVar);
begin
   add(p);
end;

procedure TCVar.multiplywithNoRound(p:TVar);
begin
   multiply(p);
end;

function TCVar.compare(p:TVar):integer;
begin
    compare:=CCompare(value, TCVar(p).value);
end;

function TCVar.compareEQ(p:TVar):integer;
begin
    compareEQ:=CCompareEQ(value, TCVar(p).value);
end;


function TCVar.compareP(exp:TPrincipal):integer;
var
   c:complex;
begin
   exp.evalC(c);
   compareP:=CCompare(value,c);
end;

function TCVar.compareEQP(exp:TPrincipal):integer;
var
   c:complex;
begin
   exp.evalC(c);
   compareEQP:=CCompareEQ(value,c);
end;

function TCVar.sign:integer;
begin
   sign:=fsign(value.x);
   if (value.y<>0) then setexceptionwith(s_ImaginaryHasNoSign,3000);
end;
*)


{*****}
{Array}
{*****}

constructor TCArray.create(d:integer;const lb,ub:Array4; m:integer );
begin
    inherited create(d,lb,ub,m);
    InitArray;
end;

constructor TCArray.createNative(d:integer;const sz:Array4 );
begin
    inherited createNative(d,sz);
    InitArray;
end;

constructor TCArray.createFrameCopy(p:TArray);
begin
    inherited createFrameCopy(p);
    InitArray;
end;

function TCArray.RedimNative(const sz:Array4; CanCreate:boolean):boolean;
var
    i:integer;
begin
    for i:=1 to dim do
        if (sz[i]<0) or NoSizeZeroArray and (sz[i]=0)  then setexception(6005) ;  //2021.12.29
    if (CArySize>0) and (CArysize<arrayamount(sz)) then
           begin setexception(5001); result:=false; exit end;
    size:=sz;
    if CArySize=0 then
          initArray;
    RedimNative:=true
end;

constructor TCArray.createDup(p:TArray);
begin
     inherited createDup(p);
     initArray;
     move(TCArray(p).CAry^, CAry^, CArySize*sizeof(Complex))
end;

procedure TCArray.substOne;
var
  i:integer;
begin
  for i:=0 to amount -1 do
      CInit(CAry^[i],1,0);
end;

{$IFDEF CPU32}
procedure clear(var a; n:LongInt);assembler;
asm
   push   edi
   mov    edi,a
   mov    ecx,n
   xor    eax,eax
   rep    stosd
   pop    edi
end;
{$ENDIF}
{$IFDEF CPU64}
procedure clear(var a; n:LongInt);assembler;
asm               {rdi}{esi}
   xor    rcx,rcx
   mov    ecx,n
   xor    eax,eax
   rep    stosd
end;
{$ENDIF}


procedure TCArray.substZero;
var
  i:integer;
begin
//  for i:=0 to amount -1 do
//      CAry^[i]:=0;
  i:=Amount;
  if i>0 then
     clear(CAry^,4*i);
end;

procedure TCArray.SubstIDN;
var
   i:integer;
   subsc:Array4;
begin
    if size[1]<>size[2] then
                        setException(6004) ;
    SubstZero;
    for i:=0 to size[1]-1 do
        begin
           subsc[1]:=i;
           subsc[2]:=i;
           subsc[3]:=0;
           subsc[4]:=0;
           CInit(CAry^[positionNative(subsc)],1,0);
        end;
end;

function TCArray.ItemSubstance1(i:integer):TVar;
begin
   result:=TOrthoCVar.createC(CAry^[i]);
end;

procedure TCArray.DisposeSubstance1(p:Tvar );
begin
   p.Free
end;

function TCArray.ItemSubstance0(i:integer; ByVal:boolean):TVar;
begin
   if ByVal then
      result:=ItemSubstance1(i)
   else
      result:=TrefCVar.createRef(CAry^[i]);
end;

procedure TCArray.DisposeSubstance0(p:Tvar; ByVal:boolean);
begin
   p.Free;
end;

function TCArray.ItemEvalInteger(i:integer):integer;
{$MAXFPUREGISTERS 0}
var
   d:Double;
begin
   d:=CAry^[i].x;
  if d>maxint then result:=maxint
  else if d <minInt then result:=MinInt
  else result:=system.round(d);
end;

procedure TCArray.ItemGetX(i:integer; var x:Extended);
begin
    x:=(CAry^[i]).x;
end;

procedure TCArray.ItemGetF(i:integer; var x:Double);
begin
    x:=(CAry^[i]).x;
end;

procedure TCArray.ItemGetC(i:integer; var c:complex);
begin
    c:=CAry^[i];
end;

procedure TCArray.ItemAssignC(i:integer; c:complex);
begin
   CAry^[i]:=c;
end;

procedure TCArray.ItemAssignX(i:integer; x:extended);
begin
   CInit(CAry^[i],x,0);
end;

procedure TCArray.ItemAssignLongInt(i:integer; c:longint);
begin
   CInit(CAry^[i],c,0);
end;

function TCArray.MaxSize:integer;
begin
   result:=CArySize;
end;

function TCArray.matsubst(p:TArray):boolean;
var
    i:integer;
begin
    if self=p then begin matsubst:=true; exit end;     {ポインタの比較と解釈}
    matsubst:=false;
    if p=nil then exit;
    i:=CArySize-arrayAmount(p.size);
    if (i<0) then
        begin setexception(5001); result:=false; exit end;

    size:=p.size;
    move(TCArray(p).CAry^, CAry^, amount*sizeof(Complex));
    // for i:=0 to arrayAmount(size)-1 do
    //     CAry^[i]:=TCArray(p).CAry^[i];
    matsubst:=true;
end;

procedure TCArray.add(p:Tvar);
var
   i:integer;
begin
  if amount<>TArray(p).amount then setexception(6001);
  for i:=0 to amount -1 do
      CAdd(CAry^[i],TCArray(p).CAry^[i]);
end;

procedure TCArray.subtract(p:Tvar);
var
   i:integer;
begin
  if amount<>TArray(p).amount then setexception(6001);
  for i:=0 to amount -1 do
      CSub(CAry^[i],TCArray(p).CAry^[i]);
end;

procedure TCArray.scalarMulti(p:Tvar);
var
   i:integer;
   c:complex;
begin
  c:=TBasisCVar(p).GetValue;
  for i:=0 to amount -1 do
      CMultiply(CAry^[i],c);
end;


(*
function TCArray.NewAry(s:integer):TVarList;
begin
    NewAry:=TCVarList.createNewElement(s,0)
end;
*)

function TCArray.newcopy:TVar;
begin
    newCopy:=TCArray.createdup(self)
end;

function TCArray.NewElement:TVar;
begin
    result:=TCArray.createFrameCopy(self)
end;

procedure TCArray.initArray;
begin
   CArysize:=amount;
   if CArysize >0 then
      CAry:=AllocMem(sizeof(Complex)*CArysize);
end;


destructor TCArray.destroy;
begin
    if CAry<>nil then FreeMem(CAry,sizeof(Complex)*CArysize);
   inherited destroy
end;




{*******}
{TCArray}
{*******}

type
   IntArray=array [0..255] of integer;
   PIntArray=^IntArray;

  ExtComplexArray=array[0..65535] of ExtComplex;
  PExtComplexArray=^ExtComplexArray;



procedure matinv(size:integer; p,q:PExtComplexArray; var det:extComplex);
{$MAXFPUREGISTERS 0}
  function a(i,j:integer):PExtComplex;
  begin
     result:=@p^[i+j*size]
  end;
  function b(i,j:integer):PExtComplex;
  begin
     result:=@q^[i+j*size]
  end;
var
  i,j,k:integer;
  t,u,temp,temp1,temp2:extComplex;
  eps:double;
label
  EXIT;
begin
  eps:=1; FEPS(eps);  eps:=eps/2;

  for k:=0 to size-1 do
      b(k,k)^.init(1,0);
  det.init(1,0);
  for k:=0 to size-1 do
     begin
        i:=k;
        while  (i<size) and (a(i,k)^.iszero) do inc(i);
        if i=size then
           begin det.init(0,0); goto EXIT end
        else if i<>k then
           begin
             for j:=0 to size-1 do
               begin
                   temp:=a(i,j)^; a(i,j)^:=a(k,j)^; a(k,j)^:=temp;
                   temp:=b(i,j)^; b(i,j)^:=b(k,j)^; b(k,j)^:=temp
               end;
             det.oppose;
           end;

        t:=a(k,k)^;
        det.multiply(@t);
        for i:=k+1 to size-1 do
            a(k,i)^.divide(@t);
        for i:=0 to size-1 do
            b(k,i)^.divide(@t);

        for j:=0 to size-1 do
          if j<>k then
           begin
            u:=a(j,k)^;
            for i:=k+1 to size-1 do
                 begin
                   temp1:=a(k,i)^;
                   temp1.multiply(@u);
                   temp2:=a(j,i)^;
                   temp:=temp2;
                   temp.subtract(@temp1);
                   if abs(temp.x)<abs(temp2.x)*EPS then temp.x:=0;
                   if abs(temp.y)<abs(temp2.y)*EPS then temp.y:=0;
                   a(j,i)^:=temp;
                 end;
            for i:=0 to size-1 do
                 begin
                   temp1:=b(k,i)^;
                   temp1.multiply(@u);
                   temp2:=b(j,i)^;
                   temp:=temp2;
                   temp.subtract(@temp1);
                   if abs(temp.x)<abs(temp2.x)*EPS then temp.x:=0;
                   if abs(temp.y)<abs(temp2.y)*EPS then temp.y:=0;
                   b(j,i)^:=temp;
                 end;
           end;
        //idle;
     end;
  EXIT:
end;


function TCArray.inverse:TArray;
var
  i,j:integer;
  det:extComplex;
  c:Complex;
  a,b:PExtComplexArray;
begin
  result:=nil;
  if (dim=2) and (size[1]=size[2]) then
    begin
      getmem(a,size[1]*size[2]*sizeof(extComplex));
      b:=AllocMem(size[1]*size[2]*sizeof(extComplex));
      try
        for i:=0 to size[1]-1 do
          for j:=0 to size[2]-1 do
            begin
                ItemGetC(i*size[2]+j, c);
                //TCVar(pointij(i,j)).getC(c);
                a^[i+j*size[1]].init(c.x,c.y);
            end;
        try
          matinv(size[1],a,b,det);
        except
          on E:Exception do
             if (E is EMathError) or (E is EDivByZero) then
                begin
                   {$IFNDEF WINDOWS}
                   ClearExceptions(False);
                   SetFPUMask(controlword);
                   {$ENDIF}
                   SetException(1005);
                end;
          else
              raise;
        end;
        if det.iszero then
           setexception(3009)
        else
          begin
            result:=TCArray.createNative(dim,size);
            if result=nil then
               setexception(ArraySizeOverflow)
            else
            begin
              result.lbound:=lbound;
              try
                for i:=0 to size[1]-1 do
                 for j:=0 to size[2]-1 do
                  begin
                     b^[i+j*size[1]].getC(c);
                     with TCArray(result) do ItemAssignC(i*size[2]+j,c);
                     //TCVar(TCArray(result).pointij(i,j)).substC(c);
                  end;
              except
                on E:Exception do
                  if (E is EMathError) or (E is EDivByZero) then
                    begin
                       {$IFNDEF WINDOWS}
                       ClearExceptions(False);
                       SetFPUMask(controlword);
                       {$ENDIF}
                       SetException(1005)
                    end;
                else
                  raise;
              end;
            end;
          end;
      finally
        freemem(a,size[1]*size[2]*sizeof(extComplex));
        freemem(b,size[1]*size[2]*sizeof(extComplex));
      end
    end
  else
              setexception(6003);
end;




function TCArray.determinant(var n:complex):boolean;
var
  i,j:integer;
  det:extComplex;
  c:complex;
  a,b:PExtComplexArray;
begin
  if (dim=2) and (size[1]=size[2]) then
    begin
      getmem(a,size[1]*size[2]*sizeof(extComplex));
      b:=AllocMem(size[1]*size[2]*sizeof(extComplex));
      try
        for i:=0 to size[1]-1 do
          for j:=0 to size[2]-1 do
            begin
                ItemGetC(i*size[2]+j,c);
                //TCVar(pointij(i,j)).getC(c);
                a^[i+j*size[1]].init(c.x,c.y);
            end;
        try
          matinv(size[1],a,b,det);
          CInit(n,det.x,det.y);
        except
          on EMathError do
            begin
              {$IFNDEF WINDOWS}
              ClearExceptions(False);
              SetFPUMask(controlword);
              {$ENDIF}
              setexception(1009);
            end;
        end;
      finally
        freemem(a,size[1]*size[2]*sizeof(extComplex));
        freemem(b,size[1]*size[2]*sizeof(extComplex));
      end
    end
  else
     setexception(6002);
  result:=true;
  if extype div 10=100 then extype:=1009;

end;


procedure ExtComplex.init(a,b:extended);
begin
    x:=a; y:=b
end;

procedure ExtComplex.initC(c:complex);
begin
   x:=c.x; y:=c.y
end;

procedure ExtComplex.add(p:PExtComplex);
begin
  x:=x+p^.x; y:=y+p^.y
end;

procedure ExtComplex.subtract(p:PExtComplex);
begin
  x:=x-p^.x;
  y:=y-p^.y;
end;

{$IFDEF CPU32}
procedure ExtComplex.multiply(p:PExtComplex);assembler;
asm
   fld tbyte ptr [eax]      //x.x
   fld tbyte ptr [eax+$0A]  //x.y
   fld tbyte ptr [edx]      //y.x
   fld tbyte ptr [edx+$0A]  //y.y
   fld  st(3)              // x.x
   fmul st,st(1)           // x.x*y.y
   fld  st(3)              // x.y
   fmul st,st(3)           // x.y*y.x
   fadd                    // x.x*y.y+x.y*y.x
   fstp tbyte ptr [eax+$0A]
   fmulp st(2),st          // x.y*y.y
   fmulp st(2),st          // x.x*y.x
   fsub                    // x.x*y.x-x.y*y.y
   fstp tbyte ptr [eax]
   wait
end;

procedure ExtComplex.divide(p:PExtComplex);assembler;
asm
   fld tbyte ptr [eax]      //x.x
   fld tbyte ptr [eax+$0A]  //x.y
   fld tbyte ptr [edx]      //y.x
   fld tbyte ptr [edx+$0A]  //y.y
   fld st(1)               //y.x
   fmul st,st(0)           //y.x^2
   fld st(1)               //y.y
   fmul st,st(0)           //y.y^2
   fadd                    //y.x^2+y.y^2
   fdiv  st(2),st          // y.x←y.x/(y.x^2+y.y^2)
   fdivp st(1),st          // y.y←y.y/(y.x^2+y.y^2)
   fld  st(2)              // x.y
   fmul st,st(2)           // x.y*y.x
   fld  st(4)              // x.x
   fmul st,st(2)           // x.x*y.y
   fsub                    // x.y*y.x-x.x*y.y
   fstp tbyte ptr [eax+$0A]
   fmulp st(2),st          // x.y*y.y
   fmulp st(2),st          // x.x*y.x
   fadd                    // x.x*y.x+x.y*y.y
   fstp tbyte ptr [eax]
   wait
 end;

procedure ExtComplex.square;assembler;
asm
   fld tbyte ptr [eax]      //x.x
   fld tbyte ptr [eax+$0A]  //x.y
   fld  st(1)              // x.x
   fmul st,st(0)           // x.x^2
   fld  st(1)              // x.y
   fmul st,st(0)           // x.y^2
   fsub                    // x.x^2-x.y^2
   fstp tbyte ptr [eax]
   fmulp st(1),st          // x.x*x.y
   fadd st,st(0)           // 2*x.x*x.y
   fstp tbyte ptr [eax+$0A]
   wait
 end;

procedure ExtComplex.inverse;assembler;
asm
   fld tbyte ptr [eax]     //x
   fld tbyte ptr [eax+$0A] //y
   fld  st(1)              // x
   fmul st,st(0)           // x^2
   fld  st(1)              // y
   fmul st,st(0)           // y^2
   faddp st(1),st          // x^2+y^2
   fdiv  st(2),st          // x←x/(x^2+y^2)
   fdivp st(1),st          // y←y/(x^2+y^2)
   fchs                    // y←-y/(x^2+y^2)
   fstp tbyte ptr [eax+$0A]
   fstp tbyte ptr [eax]
   wait
 end;
{$ELSE}

procedure ExtComplex.multiply(p:PExtComplex);
var
  tx,ty:extended;
begin
  tx:=x * p^.x - y * p^.y;
  ty:=x * p^.y + y * p^.x;
  x:=tx;
  y:=ty
end;

procedure ExtComplex.divide(p:PExtComplex);
var
  d,tx,ty:extended;
begin
  d:=sqr(p^.x) + sqr(p^.y);
  tx:=(x * p^.x + y * p^.y)/d;
  ty:=(y * p^.x - x * p^.y)/d;
  x:=tx;
  y:=ty
end;

procedure ExtComplex.square;
var
  tx,ty:extended;
begin
  tx:=x; ty:=y;
  x:=sqr(tx)-sqr(ty);
  y:=2*tx*ty;
end;

procedure ExtComplex.inverse;
var
  d:extended;
begin
  d:=sqr(x)+sqr(y);
  x:=x/d;
  y:=-y/d;
end;
{$ENDIF}


procedure ExtComplex.oppose;
begin
  x:=-x;
  y:=-y
end;

function ExtComplex.iszero:boolean;
begin
  result:=(x=0) and (y=0)
end;

procedure ExtComplex.GetC(var c:complex);
begin
  c.x:=x; c.y:=y
end;

{***********}
{mat product}
{***********}

procedure matProductsub(a1,a2,a:TCArray); {a:=a1*a2} {aも初期化済みのこと}
var
   i,j,k,len:integer;
   dim:integer;
   x,y,c:Complex;
   n,xx,yy:extComplex;
   size :Array4;
   sz:array[1..2]of integer;
   p:TCArray;
begin
  p:=nil;

  if (a1=nil) or (a2=nil) then exit;
  dim:=2;
  len:=a2.size[1];
  if (a1.size[a1.dim]<>len) then
           setexception(6001);
  if a1.dim=2 then
     begin
          sz[1]:=a1.size[1];
          sz[2]:=a2.size[2];
          size[1]:=sz[1];
          size[2]:=sz[2];
          if a2.dim=1 then dim:=1;
     end
  else  {a1^.dim=1}
     begin
          sz[1]:=1;
          sz[2]:=a2.size[2];
          size[1]:=sz[2];
          size[2]:=1;
          dim:=1;
     end;
  size[3]:=1;
  size[4]:=1;

  p:=TCArray.createNative(dim,size);

  try
     with p do
       for i:=0 to sz[1]-1 do
           for j:=0 to sz[2]-1 do
             begin
                n.init(0,0);
                for k:=0 to len-1 do
                    begin
                         with a1 do ItemgetC(i*size[2]+k, x);
                         //TCVar(a1.pointij(i,k)).getC(x);
                         with a2 do ItemGetC(k*size[2]+j, y);
                         //TCVar(a2.pointij(k,j)).getC(y);
                         xx.initC(x);
                         yy.initC(y);
                         xx.multiply(@yy);
                         n.add(@xx);
                     end;
                n.GetC(c);
                ItemAssignC(i*size[2]+j, c);
                //TCvar(pointij(i,j)).substC(c);
             end;
       a.matsubst(p);
  finally
       p.free;
  end;
end;



(*
procedure TCArray.matProduct(a1,a2:Tarray);
begin
  matproductsub(TCArray(a1),TCArray(a2),self);
end;
*)

procedure TCArray.matProduct(a1,a2:Tarray);
begin
   matproductsub(TCArray(a1),TCArray(a2),self);
end;

function TCArray.dotproduct(a:TArray):TVar;
var
   i:integer;
   x,c:complex;
begin
  if amount<>TArray(a).amount then setexception(6001);
  CInit(x,0,0);
  for i:=0 to amount-1 do
    begin
    //2012.4.6    Ver.0.6.2.0
       c:= TCArray(a).CAry^[i];
       c.y:=-c.y;
       CMultiply(c,CAry^[i]);
       Cadd(x,c);
    end;
  result:=TOrthoCVar.createC(x);
end;


procedure TCArray.CrossProductSub(a,b:TArray);
var
   i:integer;
   x,y:complex;
begin
   if CArySize<3 then setexception(6001);
   for i:=0 to 2 do
     begin
       CInit(CAry^[i mod 3],0,0);
       x:=TCArray(a).CAry[(i+1) mod 3];
       CMultiply(x,TCArray(b).CAry[(i+2) mod 3]);
       y:=TCArray(b).CAry[(i+1) mod 3];
       CMultiply(y,TCArray(a).CAry[(i+2) mod 3]);
       CAdd(CAry^[i mod 3],x);
       CSub(CAry^[i mod 3],y);
    end;
end;

type
   TArrayClass = class of TArray;

function TCArray.trn:TArray;
var
   p:TArray;
   i,j:integer;
begin
   if (dim=2)  then
     begin
       p:=TArrayClass(self.classtype).createMatrix(size[2],size[1]);
        p.lbound[1]:=lbound[2];
        p.lbound[2]:=lbound[1];
        for i:=0 to size[1]-1 do
          for j:=0 to size[2]-1  do
             TCArray(p).CAry^[j*TCArray(p).size[2]+i]:=CAry^[i*size[2]+j];
     end
   else
           begin
              setexception(6003);
              p:=nil;
           end;
  trn:=p
end;




end.
