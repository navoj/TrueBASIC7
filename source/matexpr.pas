unit matexpr;

{$mode Delphi}

interface

uses
  Classes, SysUtils,  Contnrs,
  base, struct, variabl, express;



 type
  TMatExp=class(TMyObject)
         ArrayClassType:TClass;
         optionbase:shortint;
         dim:shortint;
      constructor create;
      function OverflowErCode:integer;override;
      function OpName:string;override;
      procedure AskActSize(var d:integer; var sz:array4);virtual;abstract;
      procedure evalA(const a:TArray);virtual;abstract;
    private
      function isRowVector:boolean;virtual;
      function isColumnVector:Boolean;virtual;
      function isSqareMatrix:boolean;virtual;

  end;

 function MatExp:TmatExp;
 function CompositeMat(prev,eld:TStatement):TStatement;
 function CombinedMatOperation(prev,eld:TStatement;mat1:TMatrix):TStatement;
 function TRNmatst(prev,eld:TStatement):TStatement;
 function ROWCOLUMNst(prev,eld:TStatement):TStatement;


implementation
uses
   texthand, HelpCtex,  mat,  sconsts, variabls, variablc, variablr;

type
   TArrayClass = class of TArray;


{*****************}
{Matrix Expression}
{*****************}
{
 constructor TStackrecycle.create;
 begin
   inherited create(true);             //freeすると，追加したobjectもfreeされる。
 end;
}
 constructor TMatExp.create;
 begin
   inherited create;
   optionbase:=programunit.ArrayBase;

   case programunit.arithmetic of
       PrecisionNormal,PrecisionHigh:ArrayClassType:=TNArray;
       PrecisionNative              :ArrayClassType:=TFArray;
       PrecisionComplex             :ArrayClassType:=TCArray;
       PrecisionRational            :ArrayClassType:=TRArray;
   end;

 end;

 function  TMatExp.OverflowErCode:integer;
 begin
   result:=1005
 end;

function TMatExp.OpName:string;
begin
   result:='Matrix exppression'
end;

function TMatExp.isRowVector:boolean;
begin
   result:=false;
end;

function TMatExp.isColumnVector:Boolean;
begin
   result:=false;
end;

function TMatExp.isSqareMatrix:boolean;
begin
   result:=false;
end;


{**********}
{TMatMatrix}
{**********}

type
  TMatMatrix=class(TMatExp)
      mat1:TMatrix;
     constructor create(mat01:TMatrix);
     destructor destroy;override;
     procedure evalA(const a:TArray);override;
     procedure AskActSize(var d:integer; var sz:array4);override;
  private
     function isRowVector:boolean;override;
     function isColumnVector:Boolean;override;
     function isSqareMatrix:boolean;override;
  end;

 constructor TMatMatrix.create(mat01:TMatrix);
 begin
   inherited create;
   mat1:=mat01;
   dim:=mat1.idr.dim;

 end;

destructor TMatMatrix.destroy;
begin
    mat1.free;
    inherited destroy;
end;

procedure  TMatMatrix.evalA(const a:TArray);
begin
  a.matsubst(mat1.ptr as TArray);               //copyを返す
end;

procedure TMatMatrix.AskActSize(var d:integer; var sz:array4);   //実行時
var
   p:TArray;
begin
    p:=mat1.ptr as TArray;
    with p do
     begin
        d:=dim;
        sz:= Size;
     end;
 end;

function TMatMatrix.isRowVector:boolean;
begin
   with mat1.idr do
      result:=(dim=1) or (dim=2) and (ubound[1]=lbound[1]);
end;

function TMatMatrix.isColumnVector:Boolean;
begin
  with mat1.idr do
      result:=(dim=1) or (dim=2) and (ubound[2]=lbound[2]);
end;

function TMatMatrix.isSqareMatrix:boolean;
begin
   with mat1.idr do
      result:=(dim=2) and (ubound[1]-lbound[1]=ubound[2]-lbound[2]);
end;


{****************}
{TCompositeMatrix}
{****************}

type TVarList=class( Contnrs.TobjectList);

type
  TCompositeMatrix=Class(Tmatexp)
     VarList:TVarList;
     constructor create(VarList0:TvarList);
     destructor destroy;override;
     procedure AskActSize(var d:integer; var sz:array4);override;
     procedure evalA(const a:TArray);override;
  private
      function isRowVector:boolean;override;
  end;
{
 TCompositeMatrixN=Class(TCompositeMatrix)
    procedure evalA(const a:TArray);override;
  end;

 TCompositeMatrixF=Class(TCompositeMatrix)
   procedure evalA(const a:TArray);override;
  end;

 TCompositeMatrixC=Class(TCompositeMatrix)
    procedure evalA(const a:TArray);override;
 end;

 TCompositeMatrixR=Class(TCompositeMatrix)
    procedure evalA(const a:TArray);override;
 end;
 }

constructor TCompositeMatrix.create(VarList0:TvarList);
begin
  inherited create;
  VarList:=VarList0;
  dim:=1
end;

destructor TCompositeMatrix.destroy;
begin
  VarList.free;
  inherited destroy;
end;

function TCompositeMatrix.isRowVector:boolean;
begin
   result:=true;
end;

procedure TCompositeMatrix.AskActSize(var d:integer; var sz:array4);
begin
  d:=dim;
  sz[1]:=VarList.count;
  sz[2]:=1;
  sz[3]:=1;
  sz[4]:=1;
end;


procedure TCompositeMatrix.evalA(const a:TArray);
var
  i,n:integer;
  p:TVar;
  exp:TPrincipal;
begin
  n:=VarList.count;
  with a do
   for i:=0 to n-1 do
          begin
             p:=a.ItemSubstance0(i,false);
             p.assign(VarList[i] as TPrincipal);
             a.DisposeSubstance0(p,false);
          end;

  if a.dim=2 then
      with a do
        begin
           size[2]:=size[1];
           size[1]:=1
        end

end;

{
procedure TCompositeMatrixN.evalA(const a:TArray);
var
  i,n:integer;
  v:TVar;
  exp:TPrincipal;
begin
  n:=VarList.count;
  //a:= TNArray.createMatrix(n,1);
   with TNArray(a) do
   for i:=0 to n-1 do
          begin
             exp:= VarList[i] as TPrincipal;
             (ary[i] as TVar).assign(exp);
          end;
   with a do for i:=1 to 4 do lbound[i]:=optionbase;
   if a.dim=2 then
      with a do
        begin
           size[2]:=size[1];
           size[1]:=1
        end

end;

procedure  TCompositeMatrixF.evalA(const a:TArray);
var
  i,n:integer;
  v:TVar;
  exp:TPrincipal;
begin
  n:=VarList.count;
  //a:= TFArray.createMatrix(n,1);
  with TFArray(a) do
   for i:=0 to n-1 do
          begin
             exp:= VarList[i] as TPrincipal;
             TFArray(a).dary^[i]:=exp.evalF;
          end;
  with a do for i:=1 to 4 do lbound[i]:=optionbase;
  if a.dim=2 then
      with a do
        begin
           size[2]:=size[1];
           size[1]:=1
        end
end;

procedure  TCompositeMatrixC.evalA(const a:TArray);
var
  i,n:integer;
  v:TVar;
  exp:TPrincipal;
  c:complex;
begin
  n:=VarList.count;
  //a:= TCArray.createMatrix(n,1);
   with TCArray(a) do
     for i:=0 to n-1 do
            begin
               exp:= VarList[i] as TPrincipal;
               exp.evalC(c);
               TCArray(a).cary^[i]:=c;
            end;
   with a do for i:=1 to 4 do lbound[i]:=optionbase;
   if a.dim=2 then
      with a do
        begin
           size[2]:=size[1];
           size[1]:=1
        end
 end;

 procedure TCompositeMatrixR.evalA(const a:TArray);
var
  i,n:integer;
  v:TVar;
  exp:TPrincipal;
  c:complex;
begin
  n:=VarList.count;
  //a:= TRArray.createMatrix(n,1);
  with TRArray(a) do
   for i:=0 to n-1 do
          begin
             exp:= VarList[i] as TPrincipal;
             (ary[i] as TVar).assign(exp);
          end;
   with a do for i:=1 to 4 do lbound[i]:=optionbase;
   if a.dim=2 then
      with a do
        begin
           size[2]:=size[1];
           size[1]:=1
        end
end;
}

type
  TMatOPIDN=class(TMatExp)
      exp:TPrincipal;
   constructor create(e:TPrincipal);
   destructor destroy;override;
   procedure AskActSize(var d:integer; var sz:array4);override;
   procedure evalA(const a:TArray);override;
  private
    function isSqareMatrix:boolean;override;
  end;

constructor TMatOPIDN.create(e:TPrincipal);
begin
  inherited create;
  dim:=2;
  exp:=e;
end;

destructor TMatOPIDN.destroy;
begin
  exp.free;
  inherited destroy;
end;

function TMatOPIDN.isSqareMatrix:boolean;
begin
   result:=true;
end;

procedure TMatOPIDN.AskActSize(var d:integer; var sz:array4);
var i:integer;
begin
  d:=2;
  i:=0;
  if exp<>nil then
     if exp.isConstant then
        i:=exp.evalLongint
     else if CurrentStatement<>nil  then   //実行時
          i:=exp.evalLongint;

  sz[1]:=i;
  sz[2]:=i;
  sz[3]:=1;
  sz[4]:=1;
end;


procedure TMatOPIDN.evalA(const a:TArray);
begin
  a.SubstIDN;
end;


type
  TmatOp1=Class(TmatExp)
     matexp1:TMatExp;
    constructor create(matexp01:TMatExp);
    destructor destroy;override;
    procedure AskActSize(var d:integer; var sz:array4);override;
  private
      function isRowVector:boolean;override;
      function isColumnVector:Boolean;override;
      function isSqareMatrix:boolean;override;
   end;

constructor TmatOp1.create(matexp01:TMatExp);
begin
   inherited create;
   matexp1:=matexp01;
   dim:=matexp1.dim;
end;

destructor TmatOp1.destroy;
begin
  matexp1.free;
  inherited destroy;
end;

function TmatOp1.isRowVector:boolean;
begin
  result:=matexp1.isRowVector;
end;

function TmatOp1.isColumnVector:Boolean;
begin
  result:=matexp1.isColumnVector;
end;

function TmatOp1.isSqareMatrix:boolean;
begin
  result:=matexp1.isSqareMatrix;
end;

procedure TmatOp1.AskActSize(var d:integer; var sz:array4);
begin
   matexp1.AskActSize(d,sz);
end;


type
  TMatOpTRN=class(TMatOp1)
    constructor create(matexp01:TMatExp);
    procedure AskActSize(var d:integer; var sz:array4);override;
    procedure evalA(const a:TArray);override;
  private
     function isRowVector:boolean;override;
     function isColumnVector:Boolean;override;

  end;

constructor TMatOpTRN.create(matexp01:TMatExp);
begin
  inherited create(matexp01);
  if dim=1 then
        dim:=2;
  if dim<>2 then
         seterrDimension(IDH_MAT);
end;

function TMatOpTRN.isRowVector:Boolean;
begin
  result:=matexp1.isColumnVector;
end;

function TMatOpTRN.isColumnVector:boolean;
begin
  result:=matexp1.isRowVector;
end;

procedure exchange(var i,j:Longint);
var
  k:longint;
begin
  k:=i;
  i:=j;
  j:=k;
end;

procedure TMatOpTRN.AskActSize(var d:integer; var sz:array4);
var
  t:integer;
begin
  matexp1.AskActSize(d,sz);
  if d=2 then
     exchange(sz[1],sz[2])
  else if d=1 then
    d:=2
  else
    setexception(6001) ;
end;


procedure TMatOpTRN.evalA(const a:TArray);
var
  a2,p:TArray;
  d:integer;
  sz:array4;
begin
  matexp1.AskActSize(d,sz);
  a2:=TarrayClass(ArrayClassType).createNative(d,sz);
  MatExp1.evalA(a2);
  //matexp1が1次元のとき，a2を(n×1)行列に擬態する。
   if d=1 then
      a.matSubst(a2)
   else
      begin
         p:=a2.trn;
         try
           if a.dim=1 then     //aが1次元のとき，(1×n)行列pを1次元配列に擬態する。
             with p do
              begin
                 if size[1]<>1 then
                    setexception(6001);
                 dim:=1;
                 size[1]:=size[2];
                 size[2]:=1
              end;
           a.matsubst(p);
         finally
           p.free;
         end;
      end;
   a2.free;
end;


type
  TMatOpInv=class(TMatOp1)
    constructor create(matexp01:TMatExp);
    procedure evalA(const a:TArray);override;
    function InvalidErCode:integer;override;
    function OpName:string;override;
  end;

constructor TMatOpInv.create(matexp01:TMatExp);
begin
     inherited create(matexp01);
     if dim<>2 then
         seterrDimension(IDH_MAT);
end;
{
 procedure TMatOpInv.evalA(const a:TArray);
 var
  a2,p:TArray;
begin
   a2:=TArrayClass(a.ClassType).createFrameCopy(a);
   MatExp1.evalA(a2);
   currentOperation:=self;
   p:=a2.inverse;
   a.matsubst(p);
   currentOperation:=nil;
   p.free;
   a2.free;
end;
}
procedure TMatOpInv.evalA(const a:TArray);
var
 p:TArray;
begin
  MatExp1.evalA(a);
  currentOperation:=self;
  p:=a.inverse;
  a.matsubst(p);
  currentOperation:=nil;
  p.free;
end;


function TMatOpInv.InvalidErCode:integer;
begin
   result:=3009
end;

function TMatOpInv.OpName:string;
begin
  result:='MAT INV'
end;

type
  TMatOpCnj=class(TMatOp1)
    procedure evalA(const a:TArray);override;
  end;

procedure CCONJ(var x:complex);
begin
   x.y:=-x.y
end;

 procedure TMatOpCnj.evalA(const a:TArray);
 var
      i,n:integer;
begin
  MatExp1.evalA(a);
  if ArrayClassType=TCArray then
     begin
      n:=a.amount;
      with TCArray(a) do
         begin
            for i:=0 to n-1 do
                    cconj(TCArray(a).cary^[i]) ;
         end;
     end


end;


type
  TMatPower=Class(TmatOp1)
     exp1:TPrincipal;          //指数
     constructor create(matexp01:TMatexp; exp01:TPrincipal);
     destructor destroy;override;
     procedure evalA(const a:TArray);override;
  end;

constructor TMatPower.create(matexp01:TMatexp; exp01:TPrincipal);
begin
  inherited create(Matexp01);
  if (dim<>2) or not isSqareMatrix then
      seterrDimension(IDH_MAT);
  exp1:=exp01;
end;

destructor TMatPower.destroy;
begin
  exp1.free;
  inherited destroy
end;

procedure TMatPower.evalA(const a:TArray);
var
     i,n:integer;
     a1,a2:TArray;
begin
    n:=exp1.evalLongint;
    if n=0 then
       a.substIDN
    else
        begin
             MatExp1.evalA(a);
             if n>0 then
                begin
                   TVar(a1):=a.newcopy;
                   for i:=2 to n do
                      a.matproduct(a,a1);
                   a1.free;
                end
             else {if n<0 then}
                begin
                   n:=-n;
                   a1:=a.inverse;
                   a.matsubst(a1);
                   a1.free;
                   TVar(a1):=a.newcopy;
                   for i:=2 to n do
                       a.matproduct(a,a1);
                  a1.free;
                end ;
        end;
end;

type
    TMatScalar=Class(TmatOp1)
     exp1:TPrincipal;          //スカラー
     constructor create(exp01:TPrincipal; matexp01:TMatexp);
     destructor destroy;override;
     procedure evalA(const a:TArray);override;
    end;

constructor TMatScalar.create(exp01:TPrincipal; matexp01:TMatexp);
begin
  inherited create(matexp01);
  exp1:= exp01
end;

destructor TMatScalar.destroy;
begin
  exp1.free;
  inherited destroy;
end;

procedure TMatScalar.evalA(const a:TArray);
var
  n:TVar;
begin
   matexp1.evalA(a);
   if exp1<>nil then
       begin
          n:=exp1.substance1;
          a.scalarmulti(n);
          exp1.disposesubstance1(n);
       end;
end;

type
    TmatOp2=Class(TmatExp)
      matexp1,matexp2:TMatExp;
     constructor create(matexp01,matexp02:TMatExp);
     destructor destroy;override;
    private
        function isRowVector:boolean;override;
        function isColumnVector:Boolean;override;
        function isSqareMatrix:boolean;override;
    end;

    TMatMulti=Class(TmatOp2)
     constructor create(matexp01,matexp02:TMatExp);
     procedure AskActSize(var d:integer; var sz:array4);override;
     procedure evalA(const a:TArray);override;
    private
   end;

    TMatAdd=Class(TmatOp2)
     constructor create(matexp01,matexp02:TMatExp);
     procedure AskActSize(var d:integer; var sz:array4);override;
     procedure evalA(const a:TArray);override;
    private
    end;

    TMatSbt=Class(TMatAdd)
     procedure evalA(const a:TArray);override;
    end;

constructor TmatOp2.create(matexp01,matexp02:TMatExp);
begin
    inherited create;
    matexp1:=matexp01;
    matexp2:=matexp02;
end;

destructor TmatOp2.destroy;
begin
  matexp1.free;
  matexp2.free;
  inherited destroy;
end;

function TmatOp2.isRowVector:boolean;
begin
  result:=matexp1.isRowVector;
end;

function TmatOp2.isColumnVector:Boolean;
begin
  result:=matexp2.isColumnVector;
end;

function TmatOp2.isSqareMatrix:boolean;
begin
  result:=matexp1.isSqareMatrix and matexp2.isSqareMatrix
end;

constructor TmatMulti.create(matexp01,matexp02:TMatExp);
begin
  inherited create(matexp01,matexp02);
  if (matexp1.dim=1) and (matexp2.dim=2) then
     dim:=1
  else if (matexp1.dim=2)  and (matexp2.dim=2) then
     begin
        dim:=2;
        //if matexp2.trndim=1 then
        //   trndim:=1;
     end
  else
     seterrDimension(IDH_MAT);
end;

constructor TmatAdd.create(matexp01,matexp02:TMatExp);
begin
  inherited create(matexp01,matexp02);
  dim:=matexp1.dim;
  if dim<>matexp2.dim then
     seterrDimension(IDH_MAT);
end;


procedure TMatMulti.AskActSize(var d:integer; var sz:array4);
var
    d1,d2:integer;
    sz1,sz2:array4;
begin

    matexp1.AskActSize(d1,sz1);
    matexp2.AskActSize(d2,sz2);
    if d1=1 then
       begin
         d:=1;
         sz:=sz1
       end
    else
       begin
          d:=2;
          sz[1]:=sz1[1];
          sz[2]:=sz2[2];
          sz[3]:=1;
          sz[4]:=1;
          if (sz1[2]<>sz2[1]) then
          setexception(6001)
      end;
end;

procedure TMatMulti.evalA(const a:TArray);
var
      a1,a2:TArray;
      d:integer;
      sz:array4;
begin
    matexp1.AskActSize(d,sz);
    a1:=TArrayClass(ArrayClassType).createNative(d,sz);
    matexp1.evalA(a1);
    matexp2.AskActSize(d,sz);
    a2:=TArrayClass(ArrayClassType).createNative(d,sz);
    matexp1.evalA(a1);
    matexp2.evalA(a2);
    try
      if a.dim=1 then
         if not ((a1.dim=1) or ((a1.dim=2) and (a1.size[1]=1))) then
            setexception(6001);
       CurrentOperation:=self;
       a.matproduct(a1,a2);
       CurrentOperation:=nil;
    finally
         a2.free;
         a1.free;
      end;
end;

function SameSize(d:integer; var size1,size2:array4):boolean;
var
  i:integer;
begin
  result:=true;
  for i:=1 to d do
      if size1[i]<>size2[i] then result:=false
end;


procedure TMatAdd.AskActSize(var d:integer; var sz:array4);
var
    d2:integer;
    sz2:array4;
begin
    matexp1.AskActSize(d,sz);
    matexp2.AskActSize(d2,sz2);
    if (d<>d2) or not samesize(d,sz,sz2) then
       setexception(6001)
end;

procedure TMatAdd.evalA(const a:TArray);
var
  a1,a2:TArray;
  d:integer;
   sz:array4;
begin
  matexp1.AskActSize(d,sz);
  a1:=TArrayClass(ArrayClassType).createNative(d,sz);
  matexp1.evalA(a1);
  matexp2.AskActSize(d,sz);
  a2:=TArrayClass(ArrayClassType).createNative(d,sz);
  matexp2.evalA(a2);
    a.matadd(a1,a2);
    a2.free;
    a1.free;
end;

procedure TMatSbt.evalA(const a:TArray);
var
  a1,a2:TArray;
  d:integer;
   sz:array4;
begin
  matexp1.AskActSize(d,sz);
  a1:=TArrayClass(ArrayClassType).createNative(d,sz);
  matexp1.evalA(a1);
  matexp2.AskActSize(d,sz);
  a2:=TArrayClass(ArrayClassType).createNative(d,sz);
  matexp2.evalA(a2);
    a.matsbt(a1,a2);
    a2.free;
    a1.free;
end;

function CompositeMatrix:TMatExp;
var
  VarList:TVarList;
  exp:TPrincipal;
begin
  VarList:=TVarList.create;
  try
     repeat
         exp:= NExpression ;
         VarList.add(exp);
     until not test(',');
     result:=TCompositeMatrix.create(VarList);
     {
     case programunit.arithmetic of
        PrecisionNormal,PrecisionHigh:result:=TCompositeMatrixN.create(VarList);
        PrecisionNative              :result:=TCompositeMatrixF.create(VarList);
        PrecisionComplex             :result:=TCompositeMatrixC.create(VarList);
        PrecisionRational            :result:=TCompositeMatrixR.create(VarList);
     end;
     }
  except
     VarList.free;
     result:=nil;
  end;
end;


{*******************}
{MAT ROW, MAT COLUMN}
{*******************}

type
   TMatRow1=class(TMatMatrix)                       //単一行を抽出した1次元ベクトル
      exp1:TPrincipal;
     constructor create(mat0:TMatrix; exp01:TPrincipal);
     destructor destroy;override;
     procedure evalA(const a:TArray);override;
     procedure AskActSize(var d:integer; var sz:array4);override;
  private
     procedure checkdim;
   end;

   TMatColumn1=class(TMatRow1)                   //単一列を抽出した1次元ベクトル
     procedure evalA(const a:TArray);override;
     procedure AskActSize(var d:integer; var sz:array4);override;
   private
   end;



constructor TMatRow1.create(mat0:TMatrix; exp01:TPrincipal);
begin
    inherited  create(mat0);
    dim:=1;
    exp1:=exp01;
    checkDim;
end;

destructor TMatRow1.destroy;
begin
   exp1.free;
   inherited destroy
end;

procedure TMatRow1.checkDim;
begin
  if  mat1.idr.dim=2 then
  else
       seterrDimension(IDH_MAT)
 end;

procedure TMatRow1.AskActSize(var d:integer; var sz:array4);
var
  d0:integer;
  sz0:array4;
begin
  inherited AskActSize(d0,sz0);
  d:=1;
  sz[1]:=sz0[2];
  sz[2]:=1;
  sz[3]:=1;
  sz[4]:=1;
end;


procedure TMatRow1.evalA(const a:TArray);                             //行を抽出してmat1に代入する
var
  a2:TArray;
  i,j,n:integer;
  p1,p2:TVar;
  d:integer;
  sz:array4;
begin
  n:=exp1.evallongint;
  a2:=mat1.ptr as TArray;
  if a.maxsize<a2.size[2] then
         setexception(5001);
  a.size[1]:=a2.size[2];
  for i:=0 to a.size[1] -1 do
      begin
         p1:=a.ItemSubstance0(i,false);
         with a2 do
             p2:=ItemSubstance0(position2(n,lbound[2]+i),false);
         p1.copyfrom(p2);
         a2.DisposeSubstance0(p2,false);
         a.DisposeSubstance0(p1,false);
      end;
end;

procedure TMatColumn1.AskActSize(var d:integer; var sz:array4);
var
  d0:integer;
  sz0:array4;
begin
  inherited AskActSize(d0,sz0);
  d:=1;
  sz[1]:=sz0[1];
  sz[2]:=1;
  sz[3]:=1;
  sz[4]:=1;
end;

procedure TMatColumn1.evalA(const a:TArray);
var
  a2,p:TArray;
  i,j,n:integer;
  p1,p2:TVar;
  d:integer;
  sz:array4;
begin
  n:=exp1.evallongint;
  a2:=mat1.ptr as TArray;
  if a.maxsize<a2.size[1] then
         setexception(5001);
  a.size[1]:=a2.size[1];

   for i:=0 to a.size[1]-1 do
       begin
         p1:=a.ItemSubstance0(i,false);
         with a2 do
              p2:=ItemSubstance0(position2(lbound[1]+i,n),false);
         p1.copyfrom(p2);
         a2.DisposeSubstance0(p2,false);
         a.DisposeSubstance0(p1,false);
       end;

end;

type
 TMatRow2=class(TMatMatrix)                        //複数行を抽出した2次元配列
     mat2:TMatrix;
     exp1:TPrincipal;
     exp2:tPrincipal;
  constructor create(mat0:TMatrix; exp01,exp02:TPrincipal);
  destructor destroy;override;
  procedure AskActSize(var d:integer; var sz:array4);override;
  procedure evalA(const a:TArray);override;
  private procedure checkdim;
end;

TMatColumn2=class(TMatRow2)                   //複数列を抽出した2次元配列
 procedure AskActSize(var d:integer; var sz:array4);override;
 procedure evalA(const a:TArray);override;
end;


constructor TMatRow2.create(mat0:TMatrix; exp01,exp02:TPrincipal);
begin
  begin
      inherited  create(mat0);
      dim:=2;
      exp1:=exp01;
      exp2:=exp02;
      checkDim;
  end;
end;

destructor TMatRow2.destroy;
begin
   exp2.free;
   exp1.free;
   inherited destroy
end;

procedure TMatRow2.checkDim;
begin
     if  mat1.idr.dim=2  then
     else
       seterrDimension(IDH_MAT)
end;

procedure TMatRow2.AskActSize(var d:integer; var sz:array4);
var
  d0:integer;
  sz0:array4;
  m,n:integer;
begin
  with mat1.ptr as TArray do
      sz:= Size;
  m:=exp1.evalLongint;
  n:=exp2.evalLongint;
  d:=2;
  sz[1]:=max(n-m+1,0);
end;

procedure TMatRow2.evalA(const a:TArray);                   //複数行を抽出した2次元配列
var
  a1,a2:TArray;
  i,j,m,n:integer;
  p1,p2:TVar;
  d:integer;
  sz:array4;
begin
  m:=exp1.evallongint;
  n:=exp2.evallongint;

  with mat1.ptr as TArray do
       sz:= Size;
  sz[1]:=max(n-m+1,0);
  a1:=TArrayClass(ArrayClassType).createNative(d,sz);

  a2:=mat1.ptr as TArray;

  for j:=0 to n-m do
    for i:=0 to a2.size[2] -1 do
      begin
         with a1 do
             p1:=ItemSubstance0(position2(j+lbound[1],lbound[2]+i),false);
         with a2 do
             p2:=ItemSubstance0(position2(j+m,lbound[2]+i),false);
         p1.copyfrom(p2);
         a2.DisposeSubstance0(p2,false);
         a1.DisposeSubstance0(p1,false);
      end;
  a.matsubst(a1);
  a1.free;
end;

procedure TMatColumn2.AskActSize(var d:integer; var sz:array4);
var
  d0:integer;
  sz0:array4;
  m,n:integer;
begin
  with mat1.ptr as TArray do
      sz:= Size;
  m:=exp1.evalLongint;
  n:=exp2.evalLongint;
  d:=2;
  sz[2]:=max(n-m+1,0);
end;


procedure TMatColumn2.evalA(const a:TArray);                   //複数列を抽出した2次元配列
var
  a1,a2:TArray;
  i,j,m,n:integer;
  p1,p2:TVar;
  d:integer;
  sz:array4;
begin
  m:=exp1.evallongint;
  n:=exp2.evallongint;

  with mat1.ptr as TArray do
       sz:= Size;
  sz[2]:=max(n-m+1,0);
  a1:=TArrayClass(ArrayClassType).createNative(d,sz);

  a2:=mat1.ptr as TArray;

  for j:=0 to n-m do
    for i:=0 to a2.size[1] -1 do
      begin
         with a1 do
             p1:=ItemSubstance0(position2(lbound[1]+i, j+lbound[2]),false);
         with a2 do
             p2:=ItemSubstance0(position2(lbound[1]+i, j+m),false);
         p1.copyfrom(p2);
         a2.DisposeSubstance0(p2,false);
         a1.DisposeSubstance0(p1,false);
      end;
  a.matsubst(a1);
  a1.free;
end;

function RowOrColumnFnc:TMatExp;
var
  token0:string;
  mat2:TMatrix;
  exp1,exp2:TPrincipal;
begin
  token0:=token; //'ROW' or 'COLUMN'
  gettoken;
  gettoken;      //'('
  mat2:=NMatrix;
  check(',',IDH_MAT);
  exp1:=NExpression;
  if token<>':' then
     begin
       if token0='ROW' then
          result:=TMatRow1.create(mat2,exp1)
       else
          result:=TMatColumn1.create(mat2,exp1)
     end
  else  // token=':'
     begin
       gettoken;
       exp2:=NExpression;
       if token0='ROW' then
          result:=TMatRow2.create(mat2,exp1,exp2)
       else
          result:=TMatColumn2.create(mat2,exp1,exp2)
     end;
  check(')',IDH_MAT);
end;


function matPrimary:TMatExp;
var
   svcp:TokenSave;

begin
   if token='(' then
     begin
       gettoken;
       result:=matexp;
       checktoken(')',IDH_MAT);
     end
   else if token='['  then
     begin
        gettoken;
        result:=Compositematrix;
        checktoken(']',IDH_MAT);
     end
   else if tokenspec=NIdf then
           if (token='IDN') and (NextToken='(') then
              begin
                 gettoken;
                 gettoken;
                 result:=TMatOpIDN.create(NExpression);
                 checkToken(')',IDH_MAT);
              end
           else  if (token='TRN') and (nextToken='(') then
              begin
                 gettoken;
                 gettoken;
                 result:=TMatOpTRN.create(MatExp) ;
                 checktoken(')',IDH_MAT);
              end
           else if (token='INV') and (nextToken='(') then
              begin
                 gettoken;
                 gettoken;
                 result:=TMatOpINV.create(MatExp);
                 checktoken(')',IDH_MAT);
               end
           else if (token='CNJ') and (nextToken='(') then
               begin
                  gettoken;
                  gettoken;
                  result:=TMatOpCNJ.create(MatExp);
                  checktoken(')',IDH_MAT);
                 end
           else if ((token='ROW') or (token='COLUMN')) and (nexttoken='(') then
                result:=RowOrColumnFnc
           else
                result:=TMatMatrix.create(matrix)

   else
     seterr(token + s_CantBelongHere  , IDH_MAT)   ;


end;


 function MatFactor:TMatExp ;
 var
    exp:TMatExp;
 begin
    exp:=MatPrimary;
    while (Token='^') and (exp<>nil)  do
          begin
            gettoken;
            exp:=TMatPower.create(exp,Primary);
          end;
    result:=exp;
end;

function MatTerm:TMatExp;
var
    pri:Tprincipal;
    exp:TMatExp ;
    svcp:TokenSave;
 begin
    try
       savetoken(svcp);
       //pri:=primary;
       pri:=ScalarMulti;            // ver.8.1.5.1
       if token='*' then
          gettoken
       else
          begin
             restoretoken(svcp);
             pri:=nil;
          end;
    except
       restoretoken(svcp);
       statusmes.clear;            // ver.8.1.5.1
       pri:=nil;
    end;

    exp:=MatFactor;
    while (token='*')  and (exp<>nil)  do
       begin
           gettoken;
           exp:=TMatMulti.create(exp, MatFactor);
        end;
    if pri=nil then
       result:=exp
    else
       result:=TMatScalar.create(pri,exp)
 end;


function MatExp:TmatExp;
var
   exp:TMatExp;
   op:char;
 begin
   exp:=MatTerm;
   while ((token='+') or (token='-')) and (exp<>nil)  do
        begin
           op:=token[1];
           gettoken;
           case  op of
               '+': exp:=TMatAdd.create(exp,MatTerm);
               '-': exp:=TMatSbt.create(exp,MatTerm);
           end;
        end;
   result:=exp
end;



{***********************}
{Complete MAT Operartion}     //ver.8.1.5.0
{***********************}
type
    TMatSubst=class(Tmat)
       MatExp1:TMatExp;
     constructor create(prev,eld:TStatement; m1:TMatrix; e1:TMatExp);
     procedure exec;override;
     destructor destroy;override;
     private
      procedure CreateDimTest;virtual;
    end;

type
    TTRNMatSubst=class(TMatSubst)
      procedure exec;override;
     private
      procedure CreateDimTest;override;
    end;

constructor TMatSubst.create(prev,eld:TStatement; m1:TMatrix; e1:TMatExp);
begin
  inherited create(prev,eld);
  mat1:=m1;
  MatExp1:=e1;
  CreateDimTest;
end;


procedure  TMatSubst.createDimTest;
begin
   if  mat1.idr.dim = MatExp1.dim then
       exit;
   if (mat1.idr.dim=1) and (MatExp1.dim=2) then
      if matexp1.isRowVector then
            exit;
   if (mat1.idr.dim=2) and (MatExp1.dim=1) then
       with mat1.idr do
         if ubound[1]=lbound[1] then                //Row Vector
             exit;
   seterrDimension(IDH_MAT);
end;


procedure  TTRNMatSubst.createDimTest;
begin
   if (mat1.idr.dim=1) and (MatExp1.dim=2) then
      if matexp1.isColumnVector then
            exit;
   if (mat1.idr.dim=2) and (MatExp1.dim=2) then
            exit;
    if (mat1.idr.dim=2) and (MatExp1.dim=1) then
        with mat1.idr do
         if ubound[2]=lbound[2] then                //Column Vector
             exit;
    seterrDimension(IDH_MAT);
end;



destructor TMatSubst.destroy;
begin
  MatExp1.free;
  mat1.free;
  inherited destroy;
end;

procedure TMatSubst.exec;
var
   a1,a2:TArray;
   d:integer;
   sz:array4;
begin
   TVar(a1):=mat1.point;
   if a1.dim = MatExp1.dim then
      MatExp1.evalA(a1)
   else if (a1.dim=1) and (Matexp1.dim=2) then
       begin
           matexp1.AskActSize(d,sz);
           if sz[1]=1 then
             begin
              a1.dim:=2;                          //2次元に擬態する
              MatExp1.evalA(a1);
               with a1 do
                begin
                   dim:=1;
                   exchange(size[1],size[2])
                end;
             end
           else
             setexception(6001)
       end
   else if (a1.dim=2) and (a1.size[1]=1) and (Matexp1.dim=1) then
       begin
           with a1 do
            begin
               dim:=1;
               exchange(size[1],size[2]);
            end;
           MatExp1.evalA(a1);
           with a1 do
            begin
               dim:=2;
               exchange(size[1],size[2]);
            end;
       end
   else
       setexception(6001);
end;


function CombinedMatOperation(prev,eld:TStatement;mat1:TMatrix):TStatement;
var
   matexp1:TMatExp;
begin
  if token='=' then
     begin
      gettoken;
      matexp1:=MatExp;
      result:=TmatSubst.create(prev,eld, mat1, matexp1)
     end
end;

{********}
{TRNMatst}
{********}

procedure TTRNMatSubst.exec;
var
   a1,a2,a3:TArray;
   d,svd:integer;
   sz,svsz:array4;
begin
   TVar(a1):=mat1.point;
   if a1.dim=1 then
      begin
       a1.dim:=2;
       MatExp1.evalA(a1);
       if a1.size[2]<>1 then
           setexception(6001);
       a1.dim:=1;
      end
   else
      begin
           svd:=a1.dim;
           svsz:=a1.size;
           d:=2;
           sz:=svsz;
           if svd=2 then
              begin
               sz[1]:=svsz[2];
               sz[2]:=svsz[1];
              end;
           a2:=TarrayClass(a1.ClassType).createNative(d,sz);
           try
            MatExp1.evalA(a2);
            a3:=a2.TRN;
            a1.matsubst(a3);
            a3.free;
           finally
            a2.free;
           end;
      end;
end;

function CompositeTRNMatst(prev,eld:TStatement):TStatement; forward;
function TRNmatst(prev,eld:TStatement):TStatement;
var
      mat1:TMatrix;
      matexp1:TMatExp;
begin
   gettoken;  //'TRN'
   gettoken;  //'('
   if token='[' then
      result:=CompositeTRNMatst(prev,eld)
   else
      begin
         mat1:=matrix;
         checktoken(')',IDH_MAT);
         if token='=' then
              begin
               gettoken;
               matexp1:=MatExp;
               result:=TTRNmatSubst.create(prev,eld, mat1, matexp1)
              end
      end;
   end;

{***************}
{Composite MATst}
{***************}
type TCompositeMatSubst=class(TStatement)
    VarList:TVarList;
    matexp1:TMatExp;
    trn:boolean;
      constructor create(prev,eld:TStatement; VarList0:TVarList; matexp0:TMatExp; trn0:boolean);
      procedure exec;override;
      destructor destroy;override;
    end;

constructor TCompositeMatSubst.create(prev,eld:TStatement; VarList0:TVarList; matexp0:TMatExp; trn0:boolean);
begin
  inherited create(prev,eld);
  VarList:=VarList0;
  matexp1:=matexp0;
  trn:=trn0;
end;

destructor TCompositeMatSubst.destroy;
begin
   matexp1.free;
   VarList.Free;
   inherited destroy;
end;

procedure TCompositeMatSubst.exec;
var
   i:integer;
   n:integer;
   v:TSubstance;
   p:Tvar;
   a2,a3:TArray;
begin
   n:=VarList.Count;
   a2:=TArrayClass(MatExp1.ArrayClassType).createMatrix(n,1);
   if not trn then
      a2.dim:=1;
   try
    MatExp1.evalA(a2);
    if n=a2.amount then
       begin
        for i:=0 to n-1 do
            begin
               v:=(VarList[i] as TSubstance);
               p:=a2.ItemSubstance0(i,false);
               v.point.copyfrom(p);
               a2.DisposeSubstance0(p,false);
            end;
        end
    else
       setexception(6001);
   finally
    a2.free;
  end;
end;


function CompositeMat(prev,eld:TStatement):TStatement;
var
   VarList: TVarList;
   matexp1:TMatExp;
begin
    VarList:=TVarList.create;
    gettoken;  //'['
    VarList.add(NVariable);
    while test(',') do
           VarList.add(NVariable);
    checkToken(']',IDH_MAT);
    if token='=' then
       begin
        gettoken;
        matexp1:=MatExp;
          if matexp1=nil then
             seterror('Matrix Unknown error',IDH_MAT)
          else if (matexp1.dim=1) or matexp1.isRowVector then
             result:=TCompositeMatSubst.create(prev,eld, VarList, matexp1,false)
          else
             seterrdimension(IDH_MAT);
       end
end;

function CompositeTRNMatst(prev,eld:TStatement):TStatement;
var
   VarList: TVarList;
   matexp1:TMatExp;
begin
    VarList:=TVarList.create;
    gettoken;  //'['
    VarList.add(NVariable);
    while test(',') do
           VarList.add(NVariable);
    checkToken(']',IDH_MAT);
    checktoken(')',IDH_MAT);
    if token='=' then
       begin
        gettoken;
        matexp1:=MatExp;
        if matexp1=nil then
           seterror('Matrix Unknown error',IDH_MAT)
        else if (matexp1.dim=1) or matexp1.isColumnVector then
           result:=TCompositeMatSubst.create(prev,eld, VarList, matexp1,true)
       end
end;


{********************}
{ROWMatst COLUMNMatst}
{********************}
type
    TROWCOLUMNmatst=Class(TMAT)
        matexp1:TMatExp;
        exp1:TPrincipal;
        exp2:TPrincipal;
       constructor create(prev,eld:TStatement; mat0:TMatrix;
                                matexp0:TMatExp;exp01,exp02:Tprincipal);
       destructor destroy;override;
      private
         procedure checkDim;virtual;abstract;
     end;

    TROWmatst=class(TROWCOLUMNmatst)               //行挿入
     procedure exec;override;
     private
     procedure checkDim;override;
    end;

    TCOLUMNmatst=class(TROWCOLUMNmatst)            //列挿入
     procedure exec;override;
     private
     procedure checkDim;override;
    end;

 constructor TROWCOLUMNmatst.create(prev,eld:TStatement; mat0:TMatrix;
                          matexp0:TMatExp;exp01,exp02:Tprincipal);
begin
  inherited create(prev,eld);
  mat1:=mat0;
  matexp1:=matexp0;
  exp1:=exp01;
  exp2:=exp02;
  checkDim;
end;

 destructor TROWCOLUMNmatst.destroy;
 begin
   exp2.Free;
   exp1.free;
   matexp1.Free;
   inherited destroy;
  end;

 procedure TROWmatst.checkDim;
 begin
   if (mat1.idr.dim=2)
     and  ((exp2<>nil)and (matexp1.dim=2)
         or (exp2=nil)and (matexp1.dim=1)) then
      exit
   else
   seterrDimension(IDH_MAT)
 end;

 procedure TCOLUMNmatst.checkDim;
 begin
   if (mat1.idr.dim=2)
      and    ((exp2<>nil)and (matexp1.dim=2)
          or ((exp2=nil) and (matexp1.dim=1))) then
         exit
      else
      seterrDimension(IDH_MAT)
  end;

 procedure TROWmatst.exec;
 var
   m,n:integer;
   i,j:integer;
   p1,p2:Tvar;
   a1,a2,a3:TArray;
   d:integer;
   sz:Array4;
begin
  TVar(a1):=mat1.point;
  MatExp1.AskActSize(d,sz);
  m:=exp1.evalLongint;
  if exp2=nil then    //matexp1.dim=1
     begin
           if a1.size[2]<>sz[1] then //列数不一致
             setexception(6001);
           a2:=TArrayClass(MatExp1.ArrayClassType).createnative(1,sz);
           try
            MatExp1.evalA(a2);
            if a2.amount<=a1.size[2] then
               begin
                for i:=0 to a2.amount -1 do
                    begin
                       p2:=a2.ItemSubstance0(i,false);
                       with a1 do
                          p1:=ItemSubstance0(position2(m,lbound[2]+i) ,false);
                       p1.copyfrom(p2);
                       a1.DisposeSubstance0(p1,false);
                       a2.DisposeSubstance0(p2,false);
                     end;
                end
            else
               setexception(6001);
           finally
            a2.free;
           end;
     end
  else                 //matexp1.dim=2
     begin
      if a1.size[2]<>sz[2] then //列数不一致
         setexception(6001);
       n:=exp2.evalLongint;
       m:=m-a1.lbound[1];   //インデックスm,nを0ベースに変換
       n:=n-a1.lbound[1];
       a2:=TArrayClass(MatExp1.ArrayClassType).createMatrix(sz[1],sz[2]);
       try
          MatExp1.evalA(a2);
          a3:=TArrayClass(MatExp1.ArrayClassType).createMatrix(a1.size[1]+sz[1]+m-n-1,sz[2]);
          if a3.amount>a1.maxsize then
             setexception(5001);
          for i:=0 to a3.size[1]-1 do
              for j:=0 to a3.size[2]-1 do
                  begin
                     with a3 do p1:=ItemSubstance0(position2(lbound[1]+i,lbound[2]+j),false);
                     if i<m then
                        begin
                           with a1 do
                             p2:=ItemSubstance0(position2(lbound[1]+i,lbound[2]+j),false);
                           p1.copyfrom(p2);
                           a1.DisposeSubstance0(p2,false);
                        end
                     else if i<m+sz[1] then
                        begin
                          with a2 do
                            p2:=ItemSubstance0(position2(lbound[1]+i-m,lbound[2]+j),false);
                          p1.copyfrom(p2);
                          a2.DisposeSubstance0(p2,false);
                        end
                     else
                       begin
                          with a1 do
                            p2:=ItemSubstance0(position2(lbound[1]+i+n-m+1-sz[1],lbound[2]+j),false);
                          p1.copyfrom(p2);
                          a1.DisposeSubstance0(p2,false);
                       end;
                     a3.DisposeSubstance0(p1,false);
                   end;
          a1.matsubst(a3);
       finally
          a3.free;
          a2.free;
       end;

     end;
end;



  procedure TCOLUMNmatst.exec;
 var
   m,n:integer;
   i,j:integer;
   p1,p2:Tvar;
   a1,a2,a3:TArray;
   d:integer;
   sz:Array4;
begin
  TVar(a1):=mat1.point;
  MatExp1.AskActSize(d,sz);
  m:=exp1.evalLongint;
  if exp2=nil then    //matexp1.dim=1
     begin
           if a1.size[1]<>sz[1] then //行数不一致
             setexception(6001);
           a2:=TArrayClass(MatExp1.ArrayClassType).createnative(1,sz);
           try
            MatExp1.evalA(a2);
            if a2.amount<=a1.size[1] then
               begin
                for i:=0 to a2.amount -1 do
                    begin
                       p2:=a2.ItemSubstance0(i,false);
                       with a1 do
                          p1:=ItemSubstance0(position2(lbound[1]+i,m) ,false);
                       p1.copyfrom(p2);
                       a1.DisposeSubstance0(p1,false);
                       a2.DisposeSubstance0(p2,false);
                     end;
                end
            else
               setexception(6001);
           finally
            a2.free;
           end;
     end
  else                 //matexp1.dim=2
     begin
      if a1.size[1]<>sz[1] then //行数不一致
         setexception(6001);
       n:=exp2.evalLongint;
       m:=m-a1.lbound[1];   //インデックスm,nを0ベースに変換
       n:=n-a1.lbound[1];
       a2:=TArrayClass(MatExp1.ArrayClassType).createMatrix(sz[1],sz[2]);
       try
          MatExp1.evalA(a2);
          a3:=TArrayClass(MatExp1.ArrayClassType).createMatrix(sz[1],a1.size[2]+sz[2]+m-n-1);
          if a3.amount>a1.maxsize then
             setexception(5001);
              for j:=0 to a3.size[2]-1 do
                for i:=0 to a3.size[1]-1 do
                  begin
                     with a3 do p1:=ItemSubstance0(position2(lbound[1]+i,lbound[2]+j),false);
                     if j<m then
                        begin
                           with a1 do
                             p2:=ItemSubstance0(position2(lbound[1]+i,lbound[2]+j),false);
                           p1.copyfrom(p2);
                           a1.DisposeSubstance0(p2,false);
                        end
                     else if j<m+sz[2] then
                        begin
                          with a2 do
                            p2:=ItemSubstance0(position2(lbound[1]+i,lbound[2]+j-m),false);
                          p1.copyfrom(p2);
                          a2.DisposeSubstance0(p2,false);
                        end
                     else
                       begin
                          with a1 do
                            p2:=ItemSubstance0(position2(lbound[1]+i,lbound[2]+j+n-m+1-sz[2]),false);
                          p1.copyfrom(p2);
                          a1.DisposeSubstance0(p2,false);
                       end;
                     a3.DisposeSubstance0(p1,false);
                   end;
          a1.matsubst(a3);
       finally
          a3.free;
          a2.free;
       end;

     end;
end;

function ROWCOLUMNst(prev,eld:TStatement):TStatement;
var
      mat1:TMatrix;
      matexp1:TMatExp;
      exp1,exp2:TPrincipal;
      Rowst:boolean;
begin
   Rowst:=(token='ROW');
   gettoken;  //'ROW' ,'COLUMN'
   gettoken;  //'('
   mat1:=matrix;
   checktoken(',',IDH_MAT);
   exp1:=NExpression;
   if token=':' then
     begin
      gettoken;
      exp2:=NExpression;
     end
   else
      exp2:=nil;
   checktoken(')',IDH_MAT);
   checktoken('=',IDH_MAT);
   matexp1:=MatExp;
   if Rowst then
      result:=TROWmatst.create(prev,eld, mat1, matexp1,exp1,exp2)
   else
      result:=TCOLUMNmatst.create(prev,eld, mat1, matexp1,exp1,exp2)

end;

end.

