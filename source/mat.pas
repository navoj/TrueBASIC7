unit mat;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}
(***************************************)
(* Copyright (C) 2006, SHIRAISHI Kazuo *)
(***************************************)

interface
uses SysUtils,
     variabl,struct,express;

type
    TMatRedim=class(TObject)
         constructor create(m1:TMatrix; idn:boolean);
         destructor destroy;override;
         function exec:boolean;
       private
         mat1:TMatrix;             {copy pointer; cannot dispose}
         lb,ub:array[1..4] of TPrincipal;
         optionbase:integer;
         function execute(a:TArray):boolean;
      end;

function MatRedim(m1:TMatrix; idn:boolean):TMatRedim;
function scalarMulti:TPrincipal; {nilのこともある}

type
   TMAT=class(TStatement)
          mat1:TMatrix;
        destructor destroy;override;
        function OverflowErCode:integer;override;
      end;

implementation
uses
    base,TextHand,HelpCtex,io,print,graphic,affine,draw,textfile,using,supplied,
    matexpr,sconsts;


type
   TMATTransformation=class(TMAT)
       transform:TObjectList;
     constructor create(prev,eld:TStatement; m1:TMatrix);
     destructor destroy;override;
     procedure exec;override;
    end;

type
   TMAToperation=class(TMAT)
       mat2:TMatrix;
       mat3:TMatrix;
       op:char;
     constructor create(prev,eld:TStatement; m1,m2:TMatrix);
     destructor destroy;override;
     procedure exec;override;
    end;

    TMATConst=class(TMAT)
        exp:TPrincipal;
        redim:TMatRedim;
        direction:string[3];
      constructor create(prev,eld:TStatement; m1:TMatrix; e:TPrincipal);
      destructor destroy;override;
      procedure exec;override;
      end;

    TMatScalarMulti=class(Tmat)
        exp:TPrincipal;
        mat2:TMatrix;
      constructor create(prev,eld:TStatement; m1,m2:TMatrix; e:TPrincipal);
      procedure exec;override;
      destructor destroy;override;
    end;


   TMatFunction=class(TMat)    {abstarct}
         mat2:TMatrix;
      constructor create(prev,eld:TStatement; m1:TMatrix);
      destructor destroy;override;
   end;

   TMatInv=class(TMatFunction)
      constructor create(prev,eld:TStatement; m1:TMatrix);
      procedure exec;override;
   end;

   TMatTRN=class(TMatFunction)
      procedure exec;override;
   end;

   TMatCross=class(TMat)
         mat2,mat3:TMatrix;
      constructor create(prev,eld:TStatement; m1:TMatrix);
      destructor destroy;override;
      procedure exec;override;
   end;


function MatOperation(prev,eld:TStatement;  mat1:TMatrix):TStatement;forward;

function MATstring(prev,eld:TStatement; mat1:TMatrix):TStatement;forward;



function MatOperation1(prev,eld:TStatement):TStatement;  //ver.8.1.5.0
var
   mat1:TMatrix;
   svcp:TokenSave;
   t:string;
begin
   result:=nil;
   mat1:=matrix;
   if mat1=nil then exit;
   if mat1.kind='n' then
   begin
      inc(trying);
      try
         savetoken(svcp);
         result:=CombinedMatOperation(prev,eld,mat1);
         if  (tokenspec<>tail) and (token<>'ELSE') then           //Ver.8.1.5.0
            raise SyntaxError.create('');
      except
         on E:SyntaxError do
         begin
           t:=statusmes.murge;
           if (pos('ZER',t)>0) or (pos('IDN',t)>0) or (pos('CON',t)>0)
             or (pos('CROSS',t)>0) or (pos('ROW',t)>0) or (pos('COLUMN',t)>0) then
               statusmes.clear;
           try
             restoretoken(svcp);
             result:=MatOperation(prev,eld,mat1);
             if (tokenspec<>tail) and (token<>'ELSE') then
                 raise SyntaxError.create('');
           except
             on E:SyntaxError do
                 begin
                   restoretoken(svcp);
                   result:=TMatTransformation.create(prev,eld,mat1);
                 end;
            end;
         end;
      end;
      dec(trying);
      statusmes.clear;
      HelpContext:=0;
   end
   else
     result:=MatString(prev,eld,mat1);
end;

function MatRedim(m1:TMatrix; idn:boolean):TMatRedim;
begin
   if token='(' then
         matredim:=TMatRedim.create(m1,idn)
   else
         MatRedim:=nil
end;

destructor TMAT.destroy;
begin
    mat1.free;
    inherited destroy
end;

{*****************}
{MATRIX operations}
{*****************}

function scalarMulti:TPrincipal; {nilのこともある}
var
  func: SimpleFunction;
  idr:TIdRec;
begin
   scalarMulti:=nil;
   if tokenspec=Nidf then
      begin
         if ReservedWordTable.find(token,func)
                      and (@func=@RESERVEDWORDfnc) then     //CON, IDN, ZER
               exit;
         idr:=IdRecord(false);
         if (idr<>nil) then
            begin
              if (idr.dim>0) and (nexttoken<>'(') then    //数値配列名
               exit
            end
         else if (NextToken='(')
              and not SuppliedFunctionTable.find(token,func) then  //数値配列関数
                  exit;
      end;
   scalarMulti:=primary;
end;

(*
function scalarMulti:TPrincipal; {nilのこともある}
var
  p:TPrincipal;
  svcp:^tokensave;
begin
   p:=nil;
   new(svcp);
   inc(trying);
   try
     savetoken(svcp^);
     try
       p:=primary;
     except
       on SyntaxError do
         begin
           restoretoken(svcp^);
           p.free;
           p:=nil;
         end;
     end;
   finally
       dec(trying);
       dispose(svcp)
   end;
   scalarMulti:=p;
end;
*)

constructor TMAToperation.create(prev,eld:TStatement; m1,m2:TMatrix);
begin
    inherited create(prev,eld);
    mat1:=m1;
    mat2:=m2;
    op:=token[1];
    gettoken;
    mat3:=Nmatrix;
    case op of
      '+','-': if (mat1.idr.dim=mat2.idr.dim) and (mat2.idr.dim=mat3.idr.dim) then
               else begin seterrDimension(IDH_MAT) ; {done; fail} end;
      '*':  if (mat1.idr.dim=1) and (mat2.idr.dim=1) and (mat3.idr.dim=2)
            or (mat1.idr.dim=1) and (mat2.idr.dim=2) and (mat3.idr.dim=1)
            or (mat1.idr.dim=2) and (mat2.idr.dim=2) and (mat3.idr.dim=2) then
            else begin seterrDimension(IDH_MAT) ; {done; fail} end;
    end;
end;

destructor TMAToperation.destroy;
begin
    mat3.free;
    mat2.free;
    inherited destroy
end;

procedure TMAToperation.exec;
var
  a1,a2,a3:TArray;
begin
    TVar(a1):=mat1.point;
    TVar(a2):=mat2.point;
    TVar(a3):=mat3.point;
    CurrentOperation:=self;
    case op of
      '+' :   a1.matadd(a2,a3);
      '-' :   a1.matsbt(a2,a3);
      '*' :   a1.matproduct(a2,a3);
    end;
    CurrentOperation:=nil;
end;

function TMAT.OverflowErCode:integer;
begin
  result:=1005
end;


constructor TMatRedim.create(m1:TMatrix; idn:boolean);
var
   i:integer;
begin
   inherited create;
   optionbase:=programunit.ArrayBase;
   mat1:=m1;

          gettoken;
          i:=1;
          repeat
                  ub[i]:=nexpression;
                  if token='TO' then
                      begin
                         gettoken;
                         lb[i]:=ub[i];
                         ub[i]:=nexpression;
                     end;
                  inc(i);
          until (i>mat1.idr.dim) or (test(',')=false);
          check(')',IDH_MAT);
          //if idn and (i=2) then begin i:=3; lb[2]:=lb[1]; ub[2]:=ub[1] end;
          //if (i<>mat1.idr.dim+1) or (idn and (mat1.idr.dim<>2))  then
          if (idn and ((mat1.idr.dim<>2) or (i>3)))
             or (not idn and (i<>mat1.idr.dim+1)) then
                                      begin seterrdimension(IDH_MAT);fail end;
end;


destructor TMatRedim.destroy;
var
   i:integer;
begin
   if ub[1]=ub[2] then
   begin
      lb[1].free;
      ub[1].free;
   end
   else
    for i:=1 to 4 do
       begin
          lb[i].free;
          ub[i].free;
       end;
    inherited destroy;
end;

function TMatRedim.exec:boolean;
begin
   exec:=execute(TArray(mat1.point));
end;

function TMatRedim.execute(a:TArray):boolean;
var
   i:integer;
   lbound,ubound:Array4;
begin
   for i:=1 to mat1.idr.dim do
       begin
           if ub[i]<>nil then
              ubound[i]:=ub[i].evalLongint
           else
              ubound[i]:=ubound[1];
           if (lb[i]<>nil) then
               lbound[i]:=lb[i].evalLongint
           else
               lbound[i]:=optionbase;
       end;
   execute:=a.redim(lbound,ubound);
end;

constructor Tmatconst.create(prev,eld:TStatement; m1:TMatrix; e:TPrincipal);
begin
    inherited create(prev,eld);
    mat1:=m1;
    exp:=e;
    direction:=token;
    if (direction='IDN') and (mat1.idr.dim<>2) then seterrDimension(IDH_MAT);
    gettoken;
    redim:=MatRedim(m1,(direction ='IDN'));
    {if  err then begin done;fail end;}
end;

destructor TMatconst.destroy;
begin
     exp.free;
     redim.free;
    inherited destroy;
end;


procedure Tmatconst.exec;
var
   p:TArray;
   i:integer;
   n:TVar;
   subsc:Array4;
   s:boolean;
begin
   s:=true;
   if exp<>nil then
      begin
         n:=exp.substance1;             // 2010.3.11
         if n=nil then exit
      end;
   TVar(p):=mat1.point;
   subsc:=p.Lbound;
   s:=s and ( redim=nil) or redim.exec ;
   p.lbound:=subsc;
   if not s then exit;
   if direction='ZER' then
      p.substZero
   else if direction='CON' then
      p.substOne
   else if direction='IDN' then
       p.substIDN;

  if exp<>nil then
     begin
        p.scalarMulti(n) ;
        exp.disposesubstance1(n);     // 2010.3.11
     end;
end;

constructor TMatScalarMulti.create(prev,eld:TStatement; m1,m2:TMatrix; e:TPrincipal);
begin
    inherited create(prev,eld);
    mat1:=m1;
    mat2:=m2;
    exp:=e;
    (*    if (mat2=nil) then begin done;fail end; *)
    if (mat1.idr.dim<>mat2.idr.dim) then
                 begin seterrdimension(IDH_MAT); {done;fail} end;
end;

destructor TMatScalarMulti.destroy;
begin
    mat2.free;
    exp.free;
    inherited destroy;
end;

procedure TMatScalarMulti.exec;
var
  a1,a2:TArray;
  n:TVar;
begin
    TVar(a1):=mat1.point;
    TVar(a2):=mat2.point;
    if exp=nil then
       a1.matsubst(a2)
    else
       begin
          n:=exp.substance1;
          a1.matsubst(a2);
          a1.scalarmulti(n);
          exp.disposesubstance1(n);
       end;
end;


constructor TMatFunction.create(prev,eld:TStatement; m1:TMatrix);
begin
    inherited  create(prev,eld);
    mat1:=m1;
    gettoken; {'INV' or 'TRN'}
    gettoken; {'('}
    mat2:=NMatrix;
    check(')',IDH_MAT);
    if (mat1.idr.dim=2) and (mat2.idr.dim in [1,2]) then                //ver.8.1.5.0
       //Ok
    else seterrDimension(IDH_MAT) ;
end;

constructor TMatInv.create(prev,eld:TStatement; m1:TMatrix);            //ver.8.1.5.0
begin
  inherited create(prev,eld,m1);
    if mat2.idr.dim=2 then
       //Ok
    else seterrDimension(IDH_MAT)

end;

destructor TMatFunction.destroy;
begin
   mat2.free;
   inherited destroy
end;

procedure TMatInv.exec;
var
  a1,a2,p:TArray;
begin
    TVar(a1):=mat1.point;
    TVar(a2):=mat2.point;
    currentOperation:=self;
    p:=a2.inverse;
    currentOperation:=nil;
    a1.matsubst(p);
    p.free;
end;

procedure TMatTRN.exec;
var
  a1,a2,p:TArray;
begin
    TVar(a1):=mat1.point;
    TVar(a2):=mat2.point;
    with a2 do                                   //Ver.8.1.5.0
         if dim=1 then
            begin
              dim:=2;
              size[2]:=size[1];
              size[1]:=1;
            end;

    p:=a2.trn;
    a1.matsubst(p);
    p.free;
end;

constructor TMatCross.create(prev,eld:TStatement; m1:TMatrix);
begin
    inherited  create(prev,eld);
    mat1:=m1;
    gettoken; {'CROSS'}
    gettoken; {'('}
    mat2:=NMatrix;
    check(',',IDH_MAT);
    mat3:=NMatrix;
    check(')',IDH_MAT);
    if (mat1.idr.dim=1) and (mat2.idr.dim=1) and (mat3.idr.dim=1) then
    else  seterrDimension(IDH_MAT)
end;

destructor TMatCross.destroy;
begin
   mat3.free;
   mat2.free;
   inherited destroy
end;

procedure TMatCross.exec;
var
  a1,a2,a3:TArray;
begin
    TVar(a1):=mat1.point;
    TVar(a2):=mat2.point;
    TVar(a3):=mat3.point;
    currentOperation:=self;
    a1.CrossProduct(a2,a3);
    currentOperation:=nil;
end;


constructor TMatTransformation.create(prev,eld:TStatement; m1:TMatrix);
begin
   inherited create(prev,eld);
   mat1:=m1;
   check('=',IDH_MAT);
   transform:=transformation;
   if (mat1.idr.dim<>2) or (transform=nil) then
                         seterr('',IDH_MAT_TRANSFORM);
end;

destructor TMatTransformation.destroy;
begin
   transform.free;
   inherited destroy
end;

procedure TMatTransformation.exec;
var
  a:TAffine;
  p:TArray;
  sz:array4;
begin
  a:=Taffine.create;
  CurrentOperation:=self;
  try
        a.make(transform);
          TVar(p):=mat1.point;
          sz[1]:=4;
          sz[2]:=4;
          sz[3]:=1;
          sz[4]:=1;
          if p.RedimNative(sz,false) then
            with p do
            begin
             ItemAssignX(         0, a.xx);
             ItemAssignX(1*size[2] , a.xy);
             ItemAssignX(2*size[2] , a.xz);
             ItemAssignX(3*size[2] , a.xo);

             ItemAssignX(          1,a.yx);
             ItemAssignX(1*size[2]+1,a.yy);
             ItemAssignX(2*size[2]+1,a.yz);
             ItemAssignX(3*size[2]+1,a.yo);

             ItemAssignX(          2,a.zx);
             ItemAssignX(1*size[2]+2,a.zy);
             ItemAssignX(2*size[2]+2,a.zz);
             ItemAssignX(3*size[2]+2,a.zo);

             ItemAssignX(          3,a.ox);
             ItemAssignX(1*size[2]+3,a.oy);
             ItemAssignX(2*size[2]+3,a.oz);
             ItemAssignX(3*size[2]+3,a.oo);
            end;
  finally
       a.free;
       if extype=5001 then extype:=5002
  end;
  currentoperation:=nil;
end;


{*************}
{MAT Operation}
{*************}

function MatOperation(prev,eld:TStatement; mat1:TMatrix):TStatement;
var
   mat2:TMatrix;
   exp:TPrincipal;
begin
   MatOperation:=nil;

   try
      check('=',IDH_MAT);
   except
       mat1.free;
       exit
   end;


   if (token='INV') and (nexttoken='(') and (NextTokenBeyondParenthesis<>'*') then
      MatOperation:=TMatINV.create(prev,eld,mat1)

   else if (token='TRN') and (nexttoken='(') and (NextTokenBeyondParenthesis<>'*')then
      MatOperation:=TMatTRN.create(prev,eld,mat1)

   else if (token='CROSS') and (nexttoken='(')and (NextTokenBeyondParenthesis<>'*') then
      MatOperation:=TMatCROSS.create(prev,eld,mat1)


   else
      begin
         exp:=scalarMulti;
         if exp<>nil then
                check('*',IDH_MAT);
         if (token='ZER') or (token='IDN') or (token='CON') then  {reserved words}
            MatOperation:=TMatConst.create(prev,eld, mat1,exp)
         else
           begin
             mat2:=Nmatrix;
             if (exp=nil) and ((token='+') or (token='-') or (token='*')) then
                    MatOperation:=TMAToperation.create(prev,eld,mat1,mat2)
             else
                    MatOperation:=TMatScalarMulti.create(prev,eld,mat1,mat2,exp);
             if token='*' then seterrillegal(token,IDH_MAT); //変形指示MAT文かも？
           end;
      end;
end;



{********}
{redim st}
{********}
type
     TREDIM=class(TMAT)
           redim:TMatRedim;
         constructor create(prev,eld:TStatement);
         destructor destroy;override;
         procedure exec;override;
     end;

constructor TREDIM.create(prev,eld:TStatement);
begin
    inherited TStatementCreate(prev,eld);
    mat1:=matrix;
    redim:=Matredim(mat1,false);
    if redim=nil then seterr('',IDH_MAT_REDIM);
end;

procedure  TREDIM.exec;
begin
   redim.exec;
end;

destructor TREDIM.destroy;
begin
   redim.free;
   inherited destroy;
end;

function REDIMst(prev,eld:TStatement):TStatement;
begin
     Redimst:=TREDIM.create(prev,eld)
end;

{*************}
{string MAT st}
{*************}

function StringScalar:TPrincipal; {nilのこともある}
var
   svcp:tokensave;
   p:TPrincipal;
begin
   p:=nil;
   savetoken(svcp);
   inc(trying);
   try
       p:=StringPrimary;
   except
       on SyntaxError do
         begin
            restoretoken(svcp);
            p.free;
            p:=nil;
         end;
   else
      dec(trying);
      raise;
   end;
   StringScalar:=p;
end;


type
   TArrayOp=Class
     function get:TArray;virtual;abstract;
   end;

   TStringArray=class(TArrayOp)
       mat2:TMatrix;
      constructor create(m2:TMatrix);
      function get:TArray;override;
      destructor destroy;override;
    end;

    TStringArraySubstring=class(TStringArray)
       exp1,exp2:TPrincipal;
       CharacterByte:Boolean;
      constructor create(m2:TMatrix);
      function get:TArray;override;
      destructor destroy;override;
    end;

   TStringNullArray=Class(TArrayOp)
       mat1:TMatrix;          //copy pointer. should not be FREEed.
      constructor create(m1:TMatrix);
      function get:TArray;override;
    end;

   TStringNullArrayRedim=Class(TStringNullArray)
       redim:TMatRedim;
      constructor create(m1:TMatrix);
      function get:TArray;override;
      destructor destroy;override;
    end;

   TStringArrayConcatLeft=class(TArrayOp)
       exp1:TPrincipal;
       Array2:TArrayOp;
      constructor create(e1:TPrincipal; a2:TArrayOp);
      function get:TArray;override;
      destructor destroy;override;
   end;

   TStringArrayConcatRight=class(TArrayOp)
       Array1:TArrayOp;
       exp2:TPrincipal;
      constructor create(a1:TArrayOp; e2:TPrincipal);
      function get:TArray;override;
      destructor destroy;override;
   end;

   TStringArrayConcat=class(TArrayOp)
       Array1,Array2:TArrayOp;
      constructor create(a1,a2:TArrayOp);
      function get:TArray;override;
      destructor destroy;override;
   end;


constructor TStringArray.create(m2:TMatrix);
begin
  inherited create;
  mat2:=m2;
end;

function TStringArray.get:TArray;
begin
   TVar(result):=mat2.point.newcopy;
end;

destructor TStringArray.destroy;
begin
    mat2.free;
    inherited destroy;
end;

constructor TStringArraySubstring.create(m2:TMatrix);
begin
    inherited create(m2);
    SubstringQualifier(exp1,exp2);
    CharacterByte:=ProgramUnit.CharacterByte;
end;

function TStringArraySubstring.get:TArray;
var
   i1,i2:integer;
   i:integer;
   s:AnsiString;
begin
 result:=nil;
 GetSubstringIndex(exp1,exp2,i1,i2);
 result:=inherited get;
 TSArray(result).accomplishSubString(i1,i2,CharacterByte);
end;


destructor TStringArraySubstring.destroy;
begin
   exp1.free;
   exp2.free;
   inherited destroy;
end;

constructor TStringNullArray.create(m1:TMatrix);
begin
   inherited create;
   mat1:=m1;
end;

function TStringNullArray.get:TArray;
begin
   TVar(result):=mat1.point.NewElement
end;

constructor TStringNullArrayRedim.create(m1:TMatrix);
begin
  inherited create(m1);
  redim:=MatRedim(mat1,false);
end;

function TStringNullArrayRedim.get:TArray;
begin
  result:=inherited get;
  redim.execute(result);
end;

destructor TStringNullArrayRedim.destroy;
begin
 redim.free;
 inherited destroy;
end;

constructor TStringArrayConcatLeft.create(e1:TPrincipal; a2:TArrayOp);
begin
   inherited create;
   exp1:=e1;
   Array2:=a2;
end;

function  TStringArrayConcatLeft.get:TArray;
var
  t:ansistring;
  i:integer;
begin
  t:=exp1.evalS;
  result:=array2.get;
  TSArray(result).ConcatLeft(t);
end;


destructor  TStringArrayConcatLeft.destroy;
begin
  exp1.free;
  Array2.free;
  inherited destroy;
end;

constructor TStringArrayConcatRight.create(a1:TArrayOp; e2:TPrincipal);
begin
   inherited create;
   Array1:=a1;
   exp2:=e2;
end;

function TStringArrayConcatRight.get:TArray;
var
  t:ansistring;
  i:integer;
begin
  result:=array1.get;
  t:=exp2.evalS;
  TSArray(result).ConcatRight(t);
end;

destructor TStringArrayConcatRight.destroy;
begin
  Array1.free;
  exp2.free;
  inherited destroy;
end;

constructor TStringArrayConcat.create(a1,a2:TArrayOp);
begin
   inherited create;
   Array1:=a1;
   Array2:=a2;
end;

function TStringArrayConcat.get:TArray;
var
  s,t:ansistring;
  a2:TArray;
  i:integer;
begin
  result:=array1.get;
  a2:=array2.get;
  try
    try
      TSArray(result).Concat(a2);
    finally
      a2.free;
    end;
  except
    result.Free;
    raise;
  end;
end;

destructor TStringArrayConcat.destroy;
begin
   Array1.free;
   Array2.free;
   inherited destroy;
end;

function StringArrayPrimary(mat1:TMatrix):TArrayOp;
var
   mat2:TMatrix;
begin
   if token='NUL$' then
      begin
         gettoken;
         if token='(' then
            result:=TStringNullArrayRedim.create(mat1)
         else
            result:=TStringNullArray.create(mat1)
      end
   else
      begin
         mat2:=SMatrix;
         if mat2.idr.dim<>mat1.idr.dim then seterrDimension(IDH_MAT_STRING);
         if token='(' then
            result:=TStringArraySubstring.create(mat2)
         else
            result:=TStringArray.create(mat2)
      end;
   //gettoken;
end;

function StringArrayOperation(mat1:TMatrix):TArrayOp;
var
   exp1,exp2:TPrincipal;
begin
   exp1:=StringScalar;
   if exp1<>nil then
      begin
         check('&',IDH_MAT_STRING);
         result:=TStringArrayConcatLeft.create(exp1,StringArrayPrimary(mat1))
      end
   else
      begin
         result:=StringArrayPrimary(mat1);
         if token='&' then
            begin
                gettoken;
                exp2:=StringScalar;
                if exp2<>nil then
                   result:=TStringArrayConcatRight.create(result,exp2)
                else
                   result:=TStringArrayConcat.create(result,StringArrayPrimary(mat1))
            end;
      end;
   //gettoken;
end;


type
   TStringMAT=class(TMat)
      ArrayOp:TArrayOp;
      constructor create(prev,eld:TStatement; m1:TMatrix);
      procedure createsub;virtual;
      procedure exec;override;
      destructor destroy;override;
   end;

   TStringMatSubstring=Class(TStringMat)
      exp1,exp2:TPrincipal; // substring
      procedure createsub;override;
      procedure exec;override;
      destructor destroy;override;
    end;

constructor TStringMat.create(prev,eld:TStatement; m1:TMatrix);
begin
   inherited Create(prev,eld);
   mat1:=m1;
   createsub;
   ArrayOp:=StringArrayOperation(mat1);
end;

procedure TStringMat.CreateSub;
begin
   check('=',IDH_MAT_STRING);
end;

procedure TStringMatSubstring.CreateSub;
begin
   SubstringQualifier(exp1,exp2);
   check('=',IDH_MAT_STRING);
end;

procedure TStringMat.exec;        //2011.3.9修正
var
a:TArray;
begin
   a:=ArrayOp.get;
   try
   (mat1.point as TArray).matSubst(a);
   (mat1.point as TSArray).setmaxlen(mat1.idr.maxlen);
   finally
     a.free;
   end;
end;

procedure TStringMatSubstring.exec;
var
  s:ansistring;
  a:TSArray;
  i1,i2:integer;
  i:integer;
  cont:boolean;
begin
  getSubstringIndex(exp1,exp2,i1,i2);
  TArray(a):=ArrayOp.get;
  try
    TSArray(mat1.point).SubstSubstring(i1,i2,a,PUnit.CharacterByte);
  finally
    a.free;
  end;
end;

destructor TStringMAT.destroy;
begin
      ArrayOp.free;
      inherited destroy;
end;

destructor TStringMatSubstring.destroy;
begin
   exp1.free;
   exp2.free;
   inherited destroy;
end;

function MATstring(prev,eld:TStatement; mat1:TMatrix):TStatement;
begin
   if token='(' then
      result:=TStringMatSubstring.create(prev,eld,mat1)
   else
      result:=TStringMat.create(prev,eld,mat1);
end;



{**************}
{MAT statements}
{**************}

function MATst(prev,eld:TStatement):TStatement;
begin
  MATst:=nil;
  if (token='[') and (nexttokenspec in [NIdf{,Sidf}]) then               //Ver.8.1.5.0
           Matst:=CompositeMat(prev,eld)
  else if (token='TRN') and (nexttoken='(') then                         //Ver.8.1.5.0
           MATst:=TRNmatst(prev,eld)
  else if ((token='ROW')or(token='COLUMN')) and (nexttoken='(') then     //Ver.8.1.5.1
           MATst:=ROWCOLUMNst(prev,eld)
   else if (nexttoken='=') {or (nexttoken='.')} or (tokenspec=SIdf) then
          MATst:=MAToperation1(prev,eld)
  else if token='READ' then
           begin
                gettoken;
                MATst:=MatReadst(prev,eld)
           end
  else if token='INPUT' then
           begin
                 gettoken;
                 MATst:=MatINPUTst(prev,eld)
           end
  else if token='LINE' then
           begin
                 gettoken;
                 checktoken('INPUT',IDH_MAT_INPUT);
                 MATst:=MatLineINPUTst(prev,eld)
           end
  else if token='PRINT' then
           begin
                  gettoken;
                  MatSt:=MatPrintst(prev,eld);
           end
  else if token='WRITE' then
           begin
                  gettoken;
                  MatSt:=MatWritest(prev,eld);
           end
  else  if (token='PLOT') or (token='GRAPH') then
          begin
                  gettoken;
                  matst:=MATPLOTst(prev,eld)
          end
  else  if (token='LOCATE') or (token='GET') then
          begin
                  gettoken;
                  matst:=MATLOCATEst(prev,eld)
          end
  else if token='REDIM' then
           begin
                gettoken;
                MATst:=Redimst(prev,eld)
           end
  else
          begin
             seterrillegal(token,IDH_MAT);
          end;
end;

procedure statementTableinit;
begin
   StatementTableInitImperative('MAT',MATst);
   StatementTableInitImperative('REDIM',REDIMst);
end;

begin
   tableInitProcs.accept(statementTableinit);
end.
