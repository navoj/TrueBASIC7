unit variabls;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

(***************************************)
(* Copyright (C) 2006, SHIRAISHI Kazuo *)
(***************************************)

interface
uses sysUtils, math,
arithmet,base,variabl;
type


   TNvar=class(TAutoVar)
       public
          constructor create;
          destructor destroy;override;
          procedure substN(var n:number);  //override;
          procedure substZero;override;
          procedure substOne;override;
          procedure copyfrom(p:TVar);override;
          procedure assignwithNoRound(exp:TPrincipal);override;
          procedure assignX(x:extended);override;
          procedure assignLongint(i:longint);override;
          procedure getN(var n:number);     //override;
          procedure getX(var x:extended);override;
          function EvalInteger:integer;override;
          function EvalLongint:longint;override;
          procedure swap(p:TVar);override;
          procedure read(const s:ansiString);override;
          //procedure readData(const s:ansiString);override;
          function str:ansiString;override;
          function str2:ansiString;override;
          function DebugStr:string;override;                        //ver.8.1.3.1
          function format(const form:ansiString; var index,code:integer):ansistring;override;
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
          procedure Roundvari;override;
          constructor createN(p:PNumber);
       private
          value:Pnumber;
          procedure sbtDirect(var p,eps:number);
          procedure divDirect(var p:number);
     end;

   TBasisFVar=class(TAutoVar)     {Hardware Floating Point Variable }
       public
          //procedure substN(var n:number);override;
          //procedure getN(var n:number);override;
          procedure getF(var x:double);virtual;abstract;
          procedure substF(x:double);virtual;abstract;
          function GetValue:double;virtual;abstract;
          function GetPValue:PDouble;virtual;abstract;

          procedure copyfrom(p:TVar);override;
          procedure read(const s:ansiString);override;
          //procedure readData(const s:ansiString);override;
          function str:ansiString;override;
          function str2:ansiString;override;
          function format(const form:ansiString; var index,code:integer):ansistring;override;
     end;

     TorthoFVar=Class(TbasisFVar)
          Value:double;
          procedure getF(var x:double);override;
          procedure substF(x:double);override;
          function GetValue:double;override;
          function GetPValue:PDouble;override;

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
          constructor createF(const x:double);
          constructor create;
        private
     end;

     TrefFVar=Class(TbasisFVar)
          PValue:PDouble;
          procedure getF(var x:double);override;
          procedure substF(x:double);override;
          function GetValue:double;override;
          function GetPValue:PDouble;override;

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
          constructor createRef(var d:Double);
        private
     end;


type
  TNvarList = class(TVarList)
    private
       function newelement:TVar;override;
       function duplicate:TVarList;override;
  end;


type
  TFvarList = class(TVarList)
    private
       function newelement:TVar;override;
       function duplicate:TVarList;override;
  end;


type
     TNArray=class(TLegacyArray)
          function NewElement:TVar;override;
          function newcopy:TVar;override;
          procedure determinant(var n:number);
          function inverse:TArray;override;
       protected
          function NewAry(s:integer):TVarList;override;
       private
          function MatInv(var det:number):TNArray;
          procedure RoundEachVari;
     end;

type
     TDoubleArray=array [0..1023] of Double;
     PDoubleArray=^TDoubleArray;

     TFArray=class(TNewArray)
         dary:PDoubleArray;
         constructor create(d:integer;const lb,ub:Array4; m:integer );override;
         constructor createNative(d:integer;const sz:Array4);override;
         constructor createFrameCopy(p:TArray);override;
         destructor destroy;override;
         procedure substOne;override;
         procedure substZero;override;
         procedure SubstIDN;override;

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
         procedure determinant(var n:double);
      protected
         constructor createDup(p:TArray);override;
         procedure CrossProductSub(a,b:TArray);override;
         function NewElement:TVar;override;
         function newcopy:TVar;override;
         function inverse:TArray;override;
      private
         darysize:integer;
         procedure initArray;
     end;

implementation
uses format,float,vstack;



procedure TNvar.RoundVari;
var
  n:number;
begin
   n.init(value);
   roundvariable(n);
   substN(n);
end;

constructor TNVar.create;
begin
     inherited create;
    // arithmet.subst(value,zero^);
      arithmet.subst(value,null^);             //ver.8.1.3.1
end;

destructor TNVar.destroy;
begin
    disposeNumber(value);
    inherited destroy
end;



procedure TNvar.substN(var n:number);
begin
    arithmet.subst(value,n);
end;

{
procedure TNvar.substF(const x:double);
var
    n:number;
begin
    convert(x,n);
    arithmet.subst(value,n);
end;
}

procedure TNvar.substZero;
begin
    arithmet.subst(value,arithmet.zero^);
end;

procedure TNvar.substOne;
begin
    arithmet.subst(value,arithmet.one^);
end;

procedure TNvar.copyfrom(p:TVar);
begin
    //TNvar(p).value^.TestAsigned;      //TestAsigned を有効にすると，続行可能例外3101を生成する

    arithmet.subst(value,TNvar(p).value^)
end;


procedure TNvar.assignwithNoRound(exp:TPrincipal);
var
   n:Number;
begin
   exp.evalN(n);
   substN(n);
end;

procedure  TNvar.assignX(x:extended);
var
   n:number;
begin
    convert(x,n);
    round15(n);
    arithmet.subst(value,n);
end;

procedure TNvar.assignLongint(i:longint);
var
   n:number;
begin
    initlongint(n,i);
    arithmet.subst(value,n);
end;

procedure TNvar.getN(var n:number);
begin
     n.init(value);
end;

procedure TNvar.getX(var x:extended);
begin
     x:=extendedVal(Pnumber(value)^) ;
end;

function TNvar.evalInteger:Integer;
var
  c:integer;
begin
    result:=LongIntVal(PNumber(value)^,c);
    if c>0 then result:=maxint
    else if c<0 then result:=MinInt;
end;

function TNvar.evalLongint:longint;
var
  c:integer;
begin
    result:=LongIntVal(PNumber(value)^,c);
    if c<>0 then raise EInvalidOp.create('');
end;

procedure TNVar.swap(p:TVar);
var
   n:PNumber;
begin
   {ポインタの交換}
   n:=value;
   value:=TNvar(P).value;
   TNvar(p).value:=n
end;




procedure TNvar.read(const s:ansiString);
var
   n:number;
begin
   NVal(s,n);
   RoundVariable(n);
   substN(n);
   if extype=1002 then extype:=1006;
end;


function TNvar.str:ansiString;
var
   n:number;
begin
    //value^.TestAsigned;

    n.init(value);
    str:=Dstr(n)+' ';
end;

function TNvar.str2:ansiString;
begin
    Str2:=str;
end;

var  DebugString0:string='0';

function TNVar.DebugStr:string;                                     //ver.8.1.3.1
begin
   if (value^.tag=0) then
     result:=DebugString0
   else
     result:=str ;
end;

function TNvar.format(const form:ansiString; var index,code:integer):ansistring;
begin
   result:=formatnum(componentsN(value^),form,index,code);
end;


function TNvar.newcopy:TVar;
begin
   result:=TNvar.createN(value);
end;

function TNvar.NewElement:TVar;
begin
   result:=TNvar.create;
end;

constructor TNvar.createN(p:PNumber);
begin
    inherited create;
    substN(p^);
end;

procedure TNvar.add(p:TVar);
var
   n:number;
begin
  //TNvar(p).value^.TestAsigned;

  arithmet.add(value^,TNvar(p).value^,n);
  RoundVariable(n) ;
  substN(n);
end;

procedure TNvar.subtract(p:TVar);
var
   n:number;
begin
  //TNvar(p).value^.TestAsigned;

   arithmet.sbt(value^,TNVar(p).value^,n);
   RoundVariable(n) ;
   substN(n);
end;

procedure TNvar.multiply(p:TVar);
var
   n:number;
begin
  //TNvar(p).value^.TestAsigned;

  arithmet.mlt(value^,TNVar(p).value^,n);
  RoundVariable(n) ;
  substN(n);
end;

procedure TNvar.addWithNoRound(p:TVar);
var
   n:number;
begin
  arithmet.add(value^,TNVar(p).value^,n);
  substN(n);
end;

procedure TNvar.multiplyWithNoRound(p:TVar);
var
   n:number;
begin
  arithmet.mlt(value^,TNVar(p).value^,n);
  substN(n);
end;

procedure TNvar.sbtDirect(var p,eps:Number);
var
   n,temp,temp1:number;
begin
  arithmet.sbt(value^,p,n);
  temp.init(@n); arithmet.absolute(temp);
  temp1.init(value); arithmet.absolute(temp1);
  arithmet.mlt(temp1,eps,temp1);
  if arithmet.compare(temp,temp1)<=0 then
                              n.initzero;
  substN(n);
end;

procedure TNvar.divDirect(var p:Number);
var
   n:number;
begin
  arithmet.qtt(value^,p,n);
  substN(n);
end;

function TNvar.compare(p:TVar):integer;
begin
  //TNvar(p).value^.TestAsigned;
  //value^.TestAsigned;

   compare:=arithmet.compare(value^,TNVar(p).value^)
end;

function TNvar.compareP(exp:TPrincipal):integer;
var
   n:number;
begin
  //value^.TestAsigned;

  exp.evalN(n);
   compareP:=arithmet.compare(value^,n)
end;


function TNvar.sign:integer;
begin
   sign:=sgn(value)
end;

{*****}
{TFVar}
{*****}

procedure TbasisFVar.read(const s:ansiString);
{$MAXFPUREGISTERS 0}
var
   c:integer;
   x:double;
begin
  try
   Val(s,x,c);         {!!!!!!!!!!要修正!!!!!!!!!}
   if c<>0 then setexception(8101);
   substF(x);
  except
   on EMathError do
     begin
       {$IFNDEF WINDOWS}
       ClearExceptions(False);
       SetFPUMask(controlword);
       {$ENDIF}
       setexception(1006)
     end;
  end;
end;


function TbasisFVar.str:ansiString;
var
  n:number;
begin
    convert(getValue,n);
    str:=Dstr(n)+' ';
end;

function TbasisFVar.str2:ansiString;
var
  svsigniwidth:integer;
begin
    svsigniwidth:=signiwidth;
    signiwidth:=17;
    str2:=str;
    signiwidth:=svsigniwidth;
end;

function TbasisFVar.format(const form:ansiString; var index,code:integer):ansistring;
var
  n:number;
begin
    convert(getValue,n);
    result:=formatnum(componentsN(n),form,index,code);
end;

procedure TbasisFVar.copyfrom(p:TVar);
begin
   substF(TbasisFVar(p).getValue)
end;


constructor TorthoFVar.create;
begin
     inherited create;
     {value:=0;}
end;

{
procedure TFVar.substN(var n:number);
begin
    value:=extendedVal(n);
end;
}

procedure TorthoFVar.substZero;
begin
    value:=0;
end;

procedure TorthoFVar.substOne;
begin
    value:=1;
end;

{
procedure TbasisFVar.assignWithRound(exp:TPrincipal);
begin
   exp.evalFPU;
   substFromFPU;
end;

procedure TbasisFVar.assignwithNoRound(exp:TPrincipal);
begin
   exp.evalFPU;
   substFromFPU;
end;
}

procedure TorthoFVar.assignWithRound(exp:TPrincipal);
begin
   value:=exp.evalF;
end;

procedure TorthoFVar.assignwithNoRound(exp:TPrincipal);
begin
   value:=exp.evalF;
end;

procedure TorthoFVar.assignX(x:extended);
begin
    value:=x;
end;

procedure TorthoFVar.assignLongint(i:longint);
begin
      value:=i;
end;

{
procedure TorthoFVar.getN(var n:number);
begin
     arithmet.convert(value,n);
end;
}

procedure  TorthoFVar.getF(var x:double);
begin
     x:=value ;
end;

procedure TorthoFVar.substF(x:double);
begin
   value:=x
end;

function TorthoFvar.GetValue:double;
begin
  result:=value
end;

function TorthoFvar.GetPValue:PDouble;
begin
  result:=@value
end;

procedure  TorthoFVar.getX(var x:extended);
begin
     x:=value ;
end;

function TorthoFVar.EvalInteger:Integer;
begin
  if value>maxint then result:=maxint
  else if value <minInt then result:=MinInt
  else result:=system.round(value);
end;

function TorthoFVar.EvalLongint:longint;
begin
    result:=LongIntRound(value);
end;


function TorthoFVar.newcopy:TVar;
begin
   result:=TorthoFVar.createF(value);
end;

function TorthoFVar.NewElement:TVar;
begin
   result:=TorthoFVar.create;
end;

constructor TorthoFVar.createF(const x:double);
begin
    inherited create;
    value:=x;
end;

procedure TorthoFVar.add(p:TVar);
begin
    value:=value+TbasisFVar(p).getValue;
end;

procedure TorthoFVar.multiply(p:TVar);
begin
   value:=value*TbasisFVar(p).getValue;
end;

procedure TorthoFVar.subtract(p:TVar);
begin
    value:=value-TbasisFVar(p).getValue;
end;

procedure TorthoFVar.addwithNoRound(p:TVar);
begin
    value:=value+TbasisFVar(p).getValue;
end;

procedure TorthoFVar.multiplywithNoRound(p:TVar);
begin
    value:=value*TbasisFVar(p).getValue;
end;

function TorthoFVar.compare(p:TVar):integer;
{$MAXFPUREGISTERS 0}
var
  y:double;
begin
    y:=TbasisFVar(p).getValue;
    compare:=fcompare(value,y)
end;


function TorthoFVar.compareP(exp:TPrincipal):integer;
{$MAXFPUREGISTERS 0}
var
   y:double;
begin
   y:=exp.evalF;
   compareP:=fcompare(value,y)
end;

function TorthoFVar.sign:integer;
begin
   sign:=fsign(value);
end;

procedure TorthoFVar.swap(p:TVar);
{$MAXFPUREGISTERS 0}
var
   x:double;
begin
   x:=Value;
   TbasisFVar(p).getF(value);
   TbasisFVar(p).substF(x)
end;


constructor TrefFVar.createRef(var d:Double);
begin
  inherited create;
  PValue:=@d
end;

{
procedure TFVar.substN(var n:number);
begin
    value:=extendedVal(n);
end;
}

procedure TrefFVar.substZero;
begin
    PValue^:=0;
end;

procedure TrefFVar.substOne;
begin
    PValue^:=1;
end;

{
procedure TbasisFVar.assignWithRound(exp:TPrincipal);
begin
   exp.evalFPU;
   substFromFPU;
end;

procedure TbasisFVar.assignwithNoRound(exp:TPrincipal);
begin
   exp.evalFPU;
   substFromFPU;
end;
}

procedure TrefFVar.assignWithRound(exp:TPrincipal);
begin
   PValue^:=exp.evalF;
end;

procedure TrefFVar.assignwithNoRound(exp:TPrincipal);
begin
   PValue^:=exp.evalF;
end;

procedure TrefFVar.assignX(x:extended);
begin
    PValue^:=x;
end;

procedure TrefFVar.assignLongint(i:longint);
begin
      PValue^:=i;
end;

{
procedure TrefFVar.getN(var n:number);
begin
     arithmet.convert(PValue^,n);
end;
}

procedure  TrefFVar.getF(var x:double);
begin
     x:=PValue^ ;
end;

procedure TrefFVar.substF(x:double);
begin
   PValue^:=x
end;

function TrefFVar.GetValue:double;
begin
  result:=PValue^
end;

function TrefFVar.GetPValue:PDouble;
begin
  result:=PValue
end;

procedure  TrefFVar.getX(var x:extended);
begin
     x:=PValue^ ;
end;

function TrefFVar.EvalInteger:Integer;
begin
  if PValue^>maxint then result:=maxint
  else if PValue^ <minInt then result:=MinInt
  else result:=system.round(PValue^);
end;

function TrefFVar.EvalLongint:longint;
begin
    result:=LongIntRound(PValue^);
end;


function TrefFVar.newcopy:TVar;
begin
   result:=TorthoFVar.createF(PValue^);
end;

function TrefFVar.NewElement:TVar;
begin
   result:=TorthoFVar.create;
end;


procedure TrefFVar.add(p:TVar);
begin
    PValue^:=PValue^+TbasisFVar(p).getValue;
end;

procedure TrefFVar.multiply(p:TVar);
begin
   PValue^:=PValue^*TbasisFVar(p).getValue;
end;

procedure TrefFVar.subtract(p:TVar);
begin
    PValue^:=PValue^-TbasisFVar(p).getValue;
end;

procedure TrefFVar.addwithNoRound(p:TVar);
begin
    PValue^:=PValue^+TbasisFVar(p).getValue;
end;

procedure TrefFVar.multiplywithNoRound(p:TVar);
begin
    PValue^:=PValue^*TbasisFVar(p).getValue;
end;

function TrefFVar.compare(p:TVar):integer;
{$MAXFPUREGISTERS 0}
var
  y:double;
begin
    y:=TbasisFVar(p).getValue;
    compare:=fcompare(PValue^,y)
end;


function TrefFVar.compareP(exp:TPrincipal):integer;
{$MAXFPUREGISTERS 0}
var
   y:double;
begin
   y:=exp.evalF;
   compareP:=fcompare(PValue^,y)
end;

function TrefFVar.sign:integer;
begin
   sign:=fsign(PValue^);
end;

procedure TrefFVar.swap(p:TVar);
{$MAXFPUREGISTERS 0}
var
   x:double;
begin
   x:=PValue^;
   TbasisFVar(p).getF(PValue^);
   TbasisFVar(p).substF(x)
end;



{*******}
{VarList}
{*******}


function TNVarList.duplicate:TVarList;
begin
   duplicate:=TNVarList.createdup(self)
end;

function TFVarList.duplicate:TVarList;
begin
   duplicate:=TFVarList.createdup(self)
end;


function TNvarList.NewElement:TVar;
begin
   NewElement:=TNvar.create
end;

function TFvarList.NewElement:TVar;
begin
   NewElement:=TorthoFVar.create
end;


{*****}
{Array}
{*****}


function TNArray.NewAry(s:integer):TVarList;
begin
    NewAry:=TNVarList.createNewElement(s,0)
end;

function TNArray.newcopy:TVar;
begin
    newCopy:=TNArray.createdup(self)
end;

function TNArray.NewElement:TVar;
begin
    result:=TNArray.createFrameCopy(self)
end;

function TFArray.newcopy:TVar;
begin
    newCopy:=TFArray.createdup(self)
end;

function TFArray.NewElement:TVar;
begin
    result:=TFArray.createFrameCopy(self)
end;

function TNArray.MatInv(var det:number):TNarray;
var
  i,j,k:integer;
  t,u,temp:number;
  eps:number;
  svLimit:longint;
  v:TNVar;
label
  EXIT;
begin
  svLimit:=limit;
  eps.initone;
  if PrecisionMode=PrecisionNormal then
      arithmet.epsDecimal(eps)
  else
    begin
       arithmet.epsNative(eps);
       Limit:=maxplace-1;
    end;
  qtt2(eps);

  result:=TNArray.createMatrix(size[1],size[2]);
  try
    try
      if result=nil then begin det.initzero ; goto exit end;
      result.lbound:=lbound;

      for k:=0 to size[1]-1 do
          TNVar(result.pointij(k,k)).substOne;

      det.initone;
      for k:=0 to size[1]-1 do
         begin
            i:=k;
            while  (i<size[1]) and (TNVar(pointij(i,k)).sign=0) do
                                                                      inc(i);
            if i=size[1] then
               begin det.initzero; goto EXIT end
            else if i<>k then
               begin
                  for j:=0 to size[1]-1 do
                  begin
                     TNVar(pointij(i,j)).swap( TNVar(pointij(k,j)) );
                     TNVar(result.pointij(i,j) ).swap(TNVar(result.pointij(k,j)));
                  end;
                  oppose(det);
               end;

            TNVar(pointij(k,k)).getN(t);
            arithmet.mlt(det,t,det);
            for i:=k+1 to size[1]-1 do
                 TNVar(pointij(k,i) ).divDirect(t);
            for i:=0 to size[1]-1 do
                begin
                  v:= TNVar(result.pointij(k,i));
                  if v.sign<>0 then
                                 v.divDirect(t);
                end;
            for j:=0 to size[1]-1 do
              if j<>k then
               begin
                TNvar(pointij(j,k)).getN(u);
                for i:=k+1 to size[1]-1 do
                     begin
                       TNvar(pointij(k,i)).getN(temp);
                       arithmet.mlt(temp,u,temp);
                       TNVar(pointij(j,i)).sbtdirect(temp,eps);
                     end;
                for i:=0 to size[1]-1 do
                   begin
                      v:=TNVar(result.pointij(k,i));
                      if v .sign<>0 then
                        begin
                          v.getN(temp);
                          arithmet.mlt(temp,u,temp);
                          TNVar(result.pointij(j,i)).sbtdirect(temp,eps);
                        end;
                   end;
               end;
            //idle;
         end;
       result.RoundEachVari;
       EXIT:
      finally
       limit:=svLimit;
      end;
    except
       result.free;
       raise
    end;
end;

procedure TNarray.determinant(var n:number);
var
   p,q:TNArray;
begin
  if not ((dim=2) and (size[1]=size[2])) then
     setexception(6002);

  p:=TNArray.createdup(self);
  try
    q:=p.MatInv(n);
    q.free;
  finally
    p.free;
    if extype div 10=100 then extype:=1009;
  end;
  CheckRangeDecimal(n,1009)
end;

function TNArray.inverse:TArray;
var
  det: number;
  p:TNArray;
begin
   if not ((dim=2) and (size[1]=size[2])) then
     setexception(6003);

   p:=TNArray.createdup(self);
   try
     result:=p.MatInv(det);
   finally
     p.free;
   end;
   if det.sign=0 then
     begin
        result.free;
        result:=nil;
       setexception(3009)
     end;
end;


procedure TNArray.RoundEachVari;
var
  i:integer;
begin
  with ary do
    for i:=0 to count-1 do
         TNVar(items[i]).roundvari;
end;



{*******}
{TFArray}
{*******}


type
   IntArray=array [0..255] of integer;
   PIntArray=^IntArray;

type
  PExtended=^extended;
  ExtendedArray=array[0..65535] of extended;
  PExtendedArray=^ExtendedArray;

destructor TFArray.destroy;
begin
    if dary<>nil then FreeMem(dary,sizeof(Double)*darysize);
   inherited destroy
end;


procedure TFArray.initArray;
begin
   darysize:=amount;
   if darysize >0 then
      dary:=AllocMem(sizeof(Double)*darysize);
end;

constructor TFArray.createNative(d:integer;const sz:Array4 );
begin
    inherited createNative(d,sz);
    InitArray;
end;


constructor TFArray.create(d:integer;const lb,ub:Array4; m:integer );
begin
    inherited create(d,lb,ub,m);
    InitArray;
end;

constructor TFArray.createFrameCopy(p:TArray);
begin
    inherited createFrameCopy(p);
    InitArray;
end;

(*
function TFArray.RedimNative(const sz:Array4; CanCreate:boolean):boolean;
var
    i,NewSize:integer;
begin
    for i:=1 to dim do
        if sz[i]<=0 then setexception(6005) ;  //2000.2.7
    if (darysize>0) and (darysize<arrayamount(sz)) then
           begin setexception(5001); result:=false; exit end;
    size:=sz;
    if darysize=0 then
          initArray;
    RedimNative:=true
end;
*)

function TFArray.RedimNative(const sz:Array4; CanCreate:boolean):boolean;
var
    i,NewSize:integer;
begin
    NewSize:=arrayamount(sz);
    for i:=1 to dim do
        if (sz[i]<0) or NoSizeZeroArray and (sz[i]=0)  then setexception(6005) ;  //2021.12.29
    if (darysize>0) and (darysize<NewSize) then
           begin setexception(5001); result:=false; exit end;
    if darysize=0 then
      begin
       dary:=AllocMem(sizeof(Double)*NewSize);
       size:=sz;                              //AllocMemの成功後にsizeをセットする
       darysize:=amount;
      end;
    RedimNative:=true
end;

constructor TFArray.createDup(p:TArray);
begin
     inherited createDup(p);
     initArray;
     move(TFArray(p).dary^, dary^, darysize*sizeof(Double))
end;

procedure TFArray.substOne;
var
  i:integer;
begin
  for i:=0 to amount -1 do
      dary^[i]:=1;
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
asm              {rdi}{esi}
   xor    rcx,rcx
   mov    ecx,n
   xor    eax,eax
   rep    stosd
end;
{$ENDIF}


procedure TFArray.substZero;
var
  i:integer;
begin
//  for i:=0 to amount -1 do
//      dary^[i]:=0;
  i:=Amount;
  if i>0 then
     clear(dary^,2*i);
end;

procedure TFArray.SubstIDN;
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
           dary^[positionNative(subsc)]:=1;
        end;
end;

function TFArray.ItemSubstance1(i:integer):TVar;
begin
   result:=TorthoFVar.createF(dary^[i]);
end;

procedure TFArray.DisposeSubstance1(p:Tvar );
begin
   p.Free
end;

function TFArray.ItemSubstance0(i:integer; ByVal:boolean):TVar;
begin
   if ByVal then
      result:=ItemSubstance1(i)
   else
      result:=TrefFVar.createRef(dary^[i]);
end;

procedure TFArray.DisposeSubstance0(p:Tvar; ByVal:boolean);
begin
   p.Free;
end;

procedure TFArray.ItemGetX(i:integer; var x:Extended);
begin
    x:=dary^[i];
end;

procedure TFArray.ItemGetF(i:integer; var x:Double);
begin
    x:=dary^[i];
end;

procedure TFArray.ItemAssignX(i:integer; x:extended);
begin
   dary^[i]:=x;
end;

procedure TFArray.ItemAssignLongInt(i:integer; c:longint);
begin
   dary^[i]:=c;
end;

function TFArray.ItemEvalInteger(i:integer):integer;
var
   d:Double;
begin
   d:=dary^[i];
  if d>maxint then result:=maxint
  else if d <minInt then result:=MinInt
  else result:=system.round(d);
end;

function TFArray.MaxSize:integer;
begin
   result:=darysize;
end;

function TFArray.matsubst(p:TArray):boolean;
var
    i:integer;
begin
    if self=p then begin matsubst:=true; exit end;     {ポインタの比較と解釈}
    matsubst:=false;
    if p=nil then exit;
    i:=darysize-arrayAmount(p.size);
    if (i<0) then
        begin setexception(5001); result:=false; exit end;

    size:=p.size;
    move(TFArray(p).dary^, dary^, amount*sizeof(Double));
    // for i:=0 to arrayAmount(size)-1 do
    //     dary^[i]:=TFArray(p).dary^[i];

    matsubst:=true;
end;

procedure TFArray.add(p:Tvar);
var
   i:integer;
begin
  if amount<>TArray(p).amount then setexception(6001);
  for i:=0 to amount -1 do
      dary^[i]:=dary^[i]+TFArray(p).dary^[i]; 
end;

procedure TFArray.subtract(p:Tvar);
var
   i:integer;
begin
  if amount<>TArray(p).amount then setexception(6001);
  for i:=0 to amount -1 do
      dary^[i]:=dary^[i]-TFArray(p).dary^[i];
end;

procedure TFArray.scalarMulti(p:Tvar);
var
   i:integer;
   d:Double;
begin
  d:=TbasisFVar(p).GetValue;
  for i:=0 to amount -1 do
      dary^[i]:=d*dary^[i];
end;



procedure matinv(size:integer; p:PExtendedArray;  pv:PIntArray; var det:extended);
{$MAXFPUREGISTERS 0}
  function a(i,j:integer):PExtended;
  begin
     result:=@p^[i+j*size]
  end;
var
  i,j,k,tmp:integer;
  t,u,temp:extended;
  eps:double;
label
  EXIT;
begin
  eps:=1; FEPS(eps); eps:=eps/2;
  for k:=0 to size-1 do pv^[k]:=k;
  det:=1;
  for k:=0 to size-1 do
     begin
        i:=k;
        while  (i<size) and (a(i,k)^=0.0) do inc(i);
        if i=size then
           begin det:=0.0; goto EXIT end
        else if i<>k then
           begin
              tmp:=pv^[i]; pv^[i]:=pv^[k]; pv^[k]:=tmp;
              for j:=0 to size-1 do
                  begin  temp:=a(i,j)^; a(i,j)^:=a(k,j)^; a(k,j)^:=temp end;
              det:=-det;
           end;

        t:=a(k,k)^;
        det:=det*t;
        for i:=0 to size-1 do
            a(k,i)^:=a(k,i)^/t;
        a(k,k)^:=1.0/t;
        for j:=0 to size-1 do
          if j<>k then
           begin
            u:=a(j,k)^;
            for i:=0 to k-1 do
                 begin
                   a(j,i)^:=a(j,i)^-a(k,i)^*u;
                 end;
            a(j,k)^:=-u/t;
            for i:=k+1 to size-1 do
                 begin
                   temp:=a(j,i)^-a(k,i)^*u;
                   if abs(temp)<abs(a(j,i)^)*EPS then temp:=0;
                   a(j,i)^:=temp;
                 end
           end;
        //idle;
     end;
  EXIT:
end;

function TFArray.inverse:TArray;
{$MAXFPUREGISTERS 0}
var
  i,j:integer;
  det:extended;
  p:PExtendedArray;
  pv:PIntArray;
begin
   result:=nil;
   if (dim=2) and (size[1]=size[2]) then
   begin
     getmem(pv,size[1]*sizeof(integer)+size[1]*size[2]*sizeof(extended));
     try
        try
            p:=@pv^[size[1]];
            for i:=0 to size[1]-1 do
              for j:=0 to size[2]-1 do
                ItemGetX(i*size[2]+j, p^[i+j*size[1]]);
            matinv(size[1],p,pv,det);
            if det=0 then
               setexception(3009)
            else
              begin
                result:=TFArray.createNative(dim,size);
                if result=nil then
                   setexception(ArraySizeOverflow)
                else
                begin
                  result.lbound:=lbound;
                  try
                    for i:=0 to size[1]-1 do
                      for j:=0 to size[2]-1 do
                        result.ItemAssignX(i*size[2]+pv[j],p^[i+j*size[1]]);
                  except
                    on EMathError do
                       begin
                       end;
                    on EDivByZero do
                       begin
                       end;
                  end;
                end;
              end;
        finally
            freemem(pv,size[1]*sizeof(integer)+size[1]*size[2]*sizeof(extended));
        end
     except
           result.free;
           result:=nil;
           raise;
     end;
   end
  else
     setexception(6003);
end;

procedure TFArray.determinant(var n:double);
{$MAXFPUREGISTERS 0}
var
  i,j:integer;
  det:extended;
  a:PExtendedArray;
  pv:PIntArray;
begin
  if (dim=2) and (size[1]=size[2]) then
   begin
     getmem(pv,size[1]*sizeof(integer));
     getmem(a,size[1]*size[2]*sizeof(extended));
     try
        for i:=0 to size[1]-1 do
          for j:=0 to size[2]-1 do
            ItemGetX(i*size[2]+j,a^[i+j*size[1]]);

        matinv(size[1],a,pv,det);
        n:=det;
     finally
        freemem(a,size[1]*size[2]*sizeof(extended));
        freemem(pv,size[1]*sizeof(integer));
     end
   end
  else
     setexception(6002);
end;


{***********}
{mat product}
{***********}
type
   TArrayClass = class of TArray;

procedure matProductsub(a1,a2,a:TArray); {a:=a1*a2} {aも初期化済みのこと}
{$MAXFPUREGISTERS 0}
var
   i,j,k,len:integer;
   dim:integer;
   n,x,y:extended;
   size :Array4;
   sz:array[1..2]of integer;
   p:TArray;
begin
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

  p:=TArrayClass(a.classtype).createNative(dim,size);
  with p do
       try
          for i:=0 to sz[1]-1 do
               for j:=0 to sz[2]-1 do
                 begin
                    n:=0;
                    for k:=0 to len-1 do
                        begin
                             with a1 do ItemGetX(i*size[2]+k,x);
                             with a2 do ItemGetX(k*size[2]+j,y);
                             n:=n+x*y;
                         end;
                    ItemAssignX(i*size[2]+j,n);
                 end;
           a.matsubst(p);
        finally
           free;
        end;
end;

procedure TFArray.matProduct(a1,a2:Tarray);
begin
   matproductsub(a1,a2,self);
end;

function TFArray.dotproduct(a:TArray):TVar;
{$MAXFPUREGISTERS 0}
var
   i:integer;
   x:extended;
begin
  if amount<>TArray(a).amount then setexception(6001);
  x:=0;
  for i:=0 to amount-1 do
        x:=x+ dary^[i]* TFArray(a).dary^[i];
  result:=TorthoFVar.createF(x);
end;


procedure TFArray.CrossProductSub(a,b:TArray);
{$MAXFPUREGISTERS 0}
var
   i:integer;
   x,y:extended;
begin
   if darysize<3 then setexception(6001);
   for i:=0 to 2 do
     begin
       dary^[i mod 3]:=0;
       x:=TFArray(a).dary[(i+1) mod 3];
       x:=x*(TFArray(b).dary[(i+2) mod 3]);
       y:=TFArray(b).dary[(i+1) mod 3];
       y:=y*(TFArray(a).dary[(i+2) mod 3]);
       dary^[i mod 3]:=dary^[i mod 3]+x-y;
    end;
end;




function TFArray.trn:TArray;
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
             TFArray(p).dary^[j*TFArray(p).size[2]+i]:=dary^[i*size[2]+j];
     end
   else
           begin
              setexception(6003);
              p:=nil;
           end;
  trn:=p
end;

end.
