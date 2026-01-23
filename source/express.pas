unit express;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}
(***************************************)
(* Copyright (C) 2006, SHIRAISHI Kazuo *)
(***************************************)



{********}
interface
{********}
uses  Classes,  SysUtils,Forms, Dialogs, Controls,
      base,arithmet,rational,float,texthand,variabl,textfile,struct;

type
    extendedFunction1=function (x:extended):extended;
    extendedFunction2=function (x,y:extended):extended;
    doubleFunction1=function(x:double):double;

{********}
{compiler}
{********}

{******}
{matrix}
{******}
type
    TMatrix=class(TSubstance)
    end;

{******************}
{logical expression}
{******************}
type
    comparefunction=function(i:integer):boolean;

type
    TLogical=class(TPrincipal)
    end;

    TLogicalBiOp=class(TLogical)
           exp1,exp2:TPrincipal;
        constructor create(e1,e2:TPrincipal);
        destructor destroy;override;
      end;

     TDisjunction=class(TLogicalBiOp)
          function evalBool:boolean;override;
     end;

     TConjunction=class(TLogicalBiOp)
          function evalBool:boolean;override;
     end;

     TNegation=class(TLogical)
            exp:TPrincipal;
          constructor create(e:TPrincipal);
          function evalBool:boolean;override;
          destructor destroy;override;
     end;

    TComparison=class(TLogicalBiOp)
          op:comparefunction;
          constructor create(e1,e2:TPrincipal; f:comparefunction);
          function evalBool:boolean;override;
     end;

    TComparisonN= class(TComparison)
    end;

    TComparisonS= class(TComparison)
    end;



function Equals(i:integer):boolean;
function NotEquals(i:integer):boolean;
function Less(i:integer):boolean;
function Greater(i:integer):boolean;
function NotGreater(i:integer):boolean;
function NotLess(i:integer):boolean;

procedure  findcomparefunction(const r:string; var f:comparefunction);

function primary:TPrincipal ;
function StringPrimary:TPrincipal ;
function NExpression:TPrincipal;
function NConstant:TPrincipal;
var      NFunction:function(idr:TIdrec):TPrincipal;
function ChExpression:TPrincipal;
function ChannelExpression:TPrincipal;
function channel(chn:TPrincipal; Proc:TRoutine; PUnit:TProgramUnit):TTextDevice;
function SExpression:TPrincipal;
function NSExpression:TPrincipal;
function SConstant:TPrincipal;
function matrix:TMatrix;
function Nmatrix:TMatrix;
function Smatrix:TMatrix;
function SMatrixDim(n:shortint):TMatrix;
function NMatrixDim(n:shortint):TMatrix;
function article:TPrincipal;
function principal(idrec:TIdRec):TPrincipal;
function simpleVariable:TSubstance;
function variable:TVariable;
function NVariable:TVariable;
//function SVariable:TVariable;
function VariableOrFunctionRef:TPrincipal;
//function Variablesub(var k:integer):TVariable;
function relationalExpression:TLogical;
function IdRecord(CanInsert:boolean):TIdRec;

function reservedword(name:ShortString):boolean;


function tryLETst(prev,eld:TStatement):TStatement;


{**************}
{CALL statement}
{**************}

type
   TCALL=class(TStatement)
          params:TObjectList;
          Routine:TRoutine;
          DoAfter:procedure;
        constructor createF(idr:TIdrec);             // for function,def
        constructor Create(prev,eld:TStatement; kind:char);    // for sub,picture
        destructor destroy;override;
        procedure exec;override;
        procedure evalN(var n:number);     {for function refererence}
        function evalF:double;             {for function refererence}
        procedure evalC(var x:complex);    {for function refererence}
        procedure evalR(var r:PNumeric);   {for function refererence}
        function evalS:ansistring;         {for function refererence}
       private
        procedure init(routine1:TRoutine);virtual;
        procedure TestArithmetic;
        procedure setDos;
        function GetRoutine(idr:TIdrec; kind:char):TRoutine;
   end;


{*****************}
{string expression}
{*****************}

type
   TStrExpression=class(TPrincipal)
           function compare(p:TPrincipal):integer;override;
           function str:ansistring;override;
           function str2:ansistring;override;
           function kind:char;override;
           function substance0(ByVal:boolean):TVar;override;
           procedure disposeSubstance0(p:TVar; ByVal:boolean);override;
           function substance1:TVar;override;
           procedure disposeSubstance1(p:TVar);override;
     end;

type
   TStrConstant=class(TStrExpression)
            value:ansistring;
           constructor create(const s:ansistring);
           function evalS:ansistring;override;
           destructor destroy;override;
           function isConstant:boolean;override;
       end;


{**********}
{TInputVari}
{**********}
 type
  TInputVari=class(TVar)
       vari:TVariable;
      constructor create(vari1:TVariable);
      function readDataV2(const s:ansiString; q,i:boolean):boolean;override;
      destructor destroy;override;
  end;

  TStrVari=class(TInputVari)
       index1,index2:TPrincipal;
       CharacterByte:boolean;
      constructor create(vari1:TVariable);
      procedure substS(const s:ansistring);override;
      procedure read(const s:ansiString);override;
      function readDataV2(const s:ansiString; q,i:boolean):boolean;override;
      destructor destroy;override;
  end;
function InputVari(StrOnly:boolean):TInputVari;
function StrVari:TStrVari;

{*********}
{Arguments}
{*********}
function argumentN1:TPrincipal;
function argumentN2a:TPrincipal;
function argumentN2b:TPrincipal;

var Unary:function(op1:unaryoperation; op2:floatfunction1;er2:smallint;const name:ansistring):TPrincipal;
var Binary:function(op1:binaryoperation; op2:floatfunction2; er2:smallint;const name:ansistring):TPrincipal;
var UnaryX:function(op2:extendedfunction1;er2:smallint;const name:ansistring):TPrincipal;
var BinaryX:function(op2:extendedfunction2; er2:smallint;const name:ansistring):TPrincipal;
var NOperation:function(op:TPrincipal):TPrincipal;

var NConst:function(var n:number):TPrincipal;
var OpPower:function(e1,e2:TPrincipal):TPrincipal;
var OpUnaryMinus:function(e1:TPrincipal):TPrincipal;
var OpSquare:function(e1:TPrincipal):TPrincipal;
var OpTimes:function(e1,e2:TPrincipal):TPrincipal;
var OpDivide:function(e1,e2:TPrincipal):TPrincipal;
var OpPlus:function(e1,e2:TPrincipal):TPrincipal;
var OpMinus:function(e1,e2:TPrincipal):TPrincipal;
var OpMSYen:function(e1,e2:TPrincipal):TPrincipal;
var OpMSMod:function(e1,e2:TPrincipal):TPrincipal;

type
   SubscriptArray=Array[1..4]of TPrincipal;

var NSubscripted1: function(idr:TIdrec; p:SubscriptArray):TVariable;
var NSubscripted2: function(idr:TIdrec; p:SubscriptArray):TVariable;
var NSubscripted3: function(idr:TIdrec; p:SubscriptArray):TVariable;
var NSubscripted4: function(idr:TIdrec; p:SubscriptArray):TVariable;


var NComparison: function(f:comparefunction; exp1,exp2:TPrincipal):TLogical;
type
    TLogicalNumeric=Class(TLogical)
        exp:TPrincipal;
        constructor create;
        function evalBool:boolean;override;
        destructor destroy;override;
     end;
function JISNExpression:TPrincipal;

procedure GetSubstringIndex(exp1,exp2:TPrincipal; var i,j:Longint);
procedure SubstringQualifier(var exp1,exp2:tPrincipal);
function GetRoutine(idr:TIdrec; kind:char):TRoutine;

type
   TSubscripted=class(TPointingVariable)
               subs:TSubstance;
               dim:integer;
               subscript:SubscriptArray;
           constructor create(idr:TIdrec; p:SubscriptArray);
           destructor destroy;override;
           function kind:char;override;
       end;

   TSubscripted1=class(TSubscripted)
           function point:TVar;override;
       end;
   TSubscripted2=class(TSubscripted)
           function point:TVar;override;
       end;
   TSubscripted3=class(TSubscripted)
           function point:TVar;override;
       end;
   TSubscripted4=class(TSubscripted)
           function point:TVar;override;
       end;


var
   ResultVarStatic:boolean=false;


implementation

uses
     myutils,helpctex,moddlg ,expressf,sconsts ;

{************}
{TSubscripted}
{************}

constructor TSubscripted.create(idr:TIdRec; p:Subscriptarray);
var
   i:integer;
begin
   inherited  create;
   subs:=idr.subs;
   dim:=idr.dim;
   subscript:=p
end;

destructor TSubscripted.destroy;
var
   i:integer;
begin
   for i:=1 to dim do
       subscript[i].free ;
   inherited destroy;
end;

function TSubscripted.kind:char;
begin
     kind:=subs.kind
end;




{**************************}
{function referece and CALL}
{**************************}

type
    TConcat=class(TStrExpression)
        exp1,exp2:TPrincipal;
      constructor create(e1,e2:TPrincipal);
      destructor  destroy;override;
      function evalS:ansistring;override;
    end;

type
   TConstVariable=class(TVariable)
             vari:TVariable;
           constructor create(exp:TVariable);
           destructor destroy;override;
           function substance0(ByVal:boolean):TVar;override;
           procedure disposesubstance0(p:TVar; ByVal:boolean);override;
           function substance1:TVar;override;
           procedure disposesubstance1(p:TVar);override;
   end;

constructor TConstVariable.create(exp:TVariable);
begin
    inherited create;
    vari:=exp;
end;

destructor  TConstVariable.destroy;
begin
   vari.free;
   inherited destroy;
end;


procedure TestSubscripted;forward;

procedure TCall.TestArithmetic;
begin
   if (routine is TProgramUnit)
      and (punit.arithmetic<>(routine as TProgramUnit).arithmetic) then
      seterr(Format(s_IsNotAgreeArithmetic,[routine.name]),IDH_OPTION_ARITHMETIC)
end;

procedure TCall.setDos;
begin
  if (routine is TProgramUnit) and (punit.arithmetic<>(routine as TProgramUnit).arithmetic) then
  begin
     case  PUnit.arithmetic of
            PrecisionNormal:  DoAfter:=SetOpModeDecimal;
            PrecisionHigh:    DoAfter:=SetOpModeHigh;
            precisionNative:  DoAfter:=SetOpModeNative;
            precisionComplex: DoAfter:=SetOpModeNative;
            PrecisionRational:DoAfter:=SetOpModeRational;
     end;

  end;
end;

function GetRoutine(idr:TIdrec; kind:char):TRoutine;
var
   routine:TRoutine;
   nam:AnsiString;
begin
     GetRoutine:=nil;
      with idr do
         if modulename<>'' then
            nam:=modulename + '.' + name
         else
            nam:=name;
      if CurrentProgram.inquire(nam,routine)
           and ((routine.isfunction and (kind='F')) or(routine.kind=kind)) then
         GetRoutine:=routine
      else if pass=2 then
         begin
            statusmes.add(Format(s_BodyIsNotFound,[idr.name]));
            if (kind='F')  and
               (token<>'SHIFT') and (token<>'SCALE') and (token<>'ROTATE')
               and (token<>'SHEAR')  and (nexttoken='(') then
               TestSubscripted
            else
               seterr('',IDH_FUNCTION);
         end;
end;

function TCall.GetRoutine(idr:TIdrec; kind:char):TRoutine;
begin
  result:=express.GetRoutine(idr, kind);
   //非互換プログラム 他プログラムユニットの内部手続き
  if (result<>nil) and (result is TLocalProc) and (TLocalProc(result).parent<>Punit)
     and (pass=2)
     and (MessageDlg(s_AllowGlobalInternalProc + EOL + idr.modulename + '.' +idr.name,
                                     mtWarning,
                                    [mbYes, mbNo],
                                     IDH_PUBLIC)<>mrYes) then
     result:=nil
end;


function lastChar(const s:string):char;
begin
   if s<>'' then
      result:=s[length(s)]
   else
      result:=#0;
end;

procedure TCALL.init(routine1:TRoutine);
var
   i:integer;
   table:TIdTable;
   exp:TPrincipal;
   svtoken:string;
begin
   DoAfter:=DoNothing;
   case pass of
   1:
      begin
         gettoken;
         if token='(' then
            begin
              gettoken;
              repeat
                 exp:=article;
                 exp.free;
              until test(',')=false;
              check(')',IDH_FUNCTION);
            end;
      end;
   2: begin
         routine:=routine1;
         if routine<>nil then
            begin
               gettoken;
               table:=routine.VarTable;
               params:=TObjectList.create(table.count);
               if routine.isfunction then
                  if lastChar(routine.name)<>'$' then
                    TestArithmetic;
               i:=0;
               with table do
               while (i<count) and TIdRec(items[i]).prm do
                   begin
                        if i=0 then check('(',IDH_FUNCTION)
                               else check(',',IDH_FUNCTION);
                        svtoken:=token;
                        exp:=principal(TIdRec(items[i]));
                        if (TIdRec(items[i]).kindchar='n') then TestArithmetic;
                        if (not routine.isfunction) and (svtoken='(')
                                   and (exp is TVariable) then
                            exp:=TConstVariable.create(TVariable(exp));
                        params.add(exp);
                        inc(i);
                   end;
                if i>0 then check(')',IDH_FUNCTION);
                setDos;
            end
      end;
   end;
end;

constructor TCall.createF(idr:TIdrec);
begin
   inherited create(nil,nil);
   init(GetRoutine(idr,'F'))
end;

constructor TCall.Create(prev,eld:TStatement; kind:char);
var
   idr:TIdrec;
   index:integer;
   mnam,nam:ansistring;
   module1:TModule;
begin
   inherited create(prev,eld);
   mnam:=Modifier(token);
   nam:=Identifier(token);
   if mnam<>'' then
      begin
         idr:=TIdrec.InitF(mnam,nam,extern);
         try
           init(GetRoutine(idr,kind));
         finally
           idr.free;
         end;
      end
   else if Identifier(ProgramUnit.name)=nam then //外部手続きの再帰呼出し　//2013.12.8
       begin
          idr:=TIdrec.InitF(Modifier(ProgramUnit.name),nam,extern);
          try
            init(GetRoutine(idr,kind));
          finally
            idr.free;
          end;
       end
   else if ProgramUnit.ExternalSubTable.search(nam,index) then
      begin
        idr:=TIdrec(ProgramUnit.ExternalSubTable.items[index]);
        init(GetRoutine(idr,kind))
      end
   else if CurModule.ShareSubTable.search(nam,index) then   //2013.12.7
      begin
        idr:=TIdrec( CurModule.ShareSubTable.items[index]);
        init(GetRoutine(idr,kind))
      end
   else
      begin
           if ForceSubPictDeclare  then   //2013.12.9
              idr:=TIdrec.initF('',programunit.name + '.' + nam,intern)
           else
             idr:=TIdrec.initF('',nam,undeterm);
         try
           init(GetRoutine(idr,kind));
         finally
           idr.free;
         end;
      end;

   if ForceSubPictDeclare and (pass=2)
       and (routine<>nil)  and  (routine is TProgramUnit) then
         // Moduleの外部手続きがPUBLIC宣言されていることをテスト      //2013.12.8
         begin
            module1:=TprogramUnit(routine).parent;
            if (module1<>nil) and (module1<>mainprogram) and (module1<>CurModule) then
              if  (routine.kind in ['S','P']) and
                  ( not module1.ShareSubTable.search(nam,index)
                    or (TIdRec(module1.ShareSubtable.items[index]).tag<>idPublic))
                or
                  (routine.kind = 'F') and
                  ( not module1.ShareVarTable.search(nam,index)
                    or (TIdRec(module1.ShareVartable.items[index]).tag<>idPublic))
                 then
                seterr(Format(s_NotPublicDeclaredIn,[module1.name,nam]),IDH_MODULE);
         end;


end;

destructor TCALL.destroy;
begin
   params.free;
   inherited destroy
end;


{*********************}
{Numerical Expressions}
{*********************}

function NConstant:TPrincipal;
var
   n:number;
begin
   numericconstant(n);
   NConstant:=NConst(n)
end;

function primary:TPrincipal ;
var
   x:number;
begin
   if test('(') then
     begin
        primary:=NExpression;
        checktoken(')',IDH_NUMBER);
     end
   else if tokenspec=Nrep then
     begin
         x:=tokenValue;
         getToken;
         primary:=NConst(x);
     end
   else if tokenspec=NIdf then
     begin
        result:=VariableOrFunctionRef;
        if (result=nil)  or  (result.kind<>'n') then
           seterr(token+s_CantBelongHere + EOL + s_ExpressionIncorrect,IDH_NUMBER);
     end
   else
     seterr(s_ExpressionIncorrect +EOL + token + s_CantBelongHere  , IDH_NUMBER)   ;


end;

function Negation:TPrincipal;forward;

function factor:TPrincipal ;
var
   exp:TPrincipal;
begin
   exp:=primary;
   while (Token='^') and (exp<>nil)  do
      begin
        gettoken;
        if token='-' then
           exp:=OpPower(exp,negation)
        else if token='2' then
            begin
               gettoken;
               exp:=OpSquare(exp)
            end
        else
               exp:=OpPower(exp,primary);
      end;
   factor:=exp;
end;

procedure insertParenthesis;
var
   svcp:tokensave;
   exp:TPrincipal;
begin
    savetoken(svcp);
    gettoken;
    exp:=factor;
    exp.free;
    if  NoContinuation and (AutoCorrect[ac_exp] or
        confirmFrom(svcp,
                  extract(svcp)+s_CanBeParenthesized,IDH_MICROSOFT_OP)) then
     begin
       insertkeyword('(',svcp);
       inserttext(')');
       raise ERecompile.create('');
     end
    else
     restoreToken(svcp);
end;

function Negation:TPrincipal;
begin
   Negation:=nil;
   if token='-' then
      if permitMicrosoft then
         begin
          gettoken;
          Negation:=OpUnaryMinus(factor);
         end
      else
        begin
          insertParenthesis;
          Negation:=factor;
        end
   else
      Negation:=factor;
end;


function term:TPrincipal;
 var
    exp:TPrincipal ;
    op:char;
 begin
    exp:=factor;
    while ((token='*') or (token='/')) and (exp<>nil)  do
       begin
           op:=token[1];
           gettoken;
           case  op of
                '*': exp:=OpTimes(exp, negation);
                '/': exp:=OpDivide(exp, negation);
           end;
       end;
    term:=exp
 end;

function YenTerm:TPrincipal;
var
  svcp1,svcp2:tokensave;

  exp,exp2:TPrincipal;
begin
   savetoken(svcp1);
   exp:=Term;
   Result:=exp;

   if permitMicrosoft then
      while (token='\') do
         begin
            gettoken;
            Result:=OpMSYen(result,Term);
         end
   else if (token='\') and NoContinuation and AutoCorrect[ac_exp] then
                           //2018.09.03   and AutoCorrect[ac_exp] 追加
     case confirmMod of
        0:begin
            savetoken(svcp2);
            gettoken;
            exp2:=Term;
            exp.free;
            exp2.free;
            inserttext('))');
            replaceKeyword('/(',svcp2);
            insertkeyword('INT(',svcp1);
            raise ERecompile.create('');
         end;
        1:begin
            savetoken(svcp2);
            gettoken;
            exp2:=Term;
            exp.free;
            exp2.free;
            inserttext('))');
            replaceKeyword('/(',svcp2);
            insertkeyword('IP(',svcp1);
            raise ERecompile.create('');
         end;
        2:begin
            savetoken(svcp2);
            gettoken;
            exp2:=Term;
            exp.free;
            exp2.free;
            inserttext('))');
            replaceKeyword(')/ROUND(',svcp2);
            insertkeyword('IP(ROUND(',svcp1);
            raise ERecompile.create('');
         end;
      end
end;


function ModTerm:TPrincipal;
var
  svcp1,svcp2:tokensave;

  exp,exp2:TPrincipal;
begin
   savetoken(svcp1);
   exp:=YenTerm;
   result:=exp;

   if permitMicrosoft then
      while (token='MOD') do
         begin
            gettoken;
            Result:=OpMSMod(result,YenTerm);
         end
   else if (token='MOD') and NoContinuation and AutoCorrect[ac_exp] then
                             //2018.09.03   and AutoCorrect[ac_exp] 追加
      case confirmMod of
        0:begin
            savetoken(svcp2);
            gettoken;
            exp2:=YenTerm;
            exp.free;
            exp2.free;
            inserttext(')');
            replaceKeyword(',',svcp2);
            insertkeyword('MOD(',svcp1);
            raise ERecompile.create('');
         end;
        1:begin
            savetoken(svcp2);
            gettoken;
            exp2:=YenTerm;
            exp.free;
            exp2.free;
            inserttext(')');
            replaceKeyword(',',svcp2);
            insertkeyword('REMAINDER(',svcp1);
            raise ERecompile.create('');
         end;
        2:begin
            savetoken(svcp2);
            gettoken;
            exp2:=YenTerm;
            exp.free;
            exp2.free;
            inserttext('))');
            replaceKeyword('),ROUND(',svcp2);
            insertkeyword('REMAINDER(ROUND(',svcp1);
            raise ERecompile.create('');
         end;
      end
   else
      ModTerm:=exp
end;

function JISNExpression:TPrincipal;
 var
   exp:TPrincipal;
   op:char;
 begin
    if token='+' then
       begin
            gettoken;
            exp:=ModTerm
       end
    else if token='-' then
        begin
             gettoken;
             exp:=OpUnaryMinus(term);
        end
    else
        exp:=ModTerm;

    while ((token='+') or (token='-')) and (exp<>nil)  do
        begin
           op:=token[1];
           gettoken;
           case  op of
               '+': exp:=OpPlus(exp,ModTerm);
               '-': exp:=OpMinus(exp,ModTerm);
           end;
        end;

    JISNExpression:=exp
end;

//function MicrosoftNExpression:TPrincipal;forward;

function NExpression:TPrincipal;
begin
   if permitMicrosoft then
      result:=MicrosoftNExpression
   else
      result:=JISNExpression
end;

{******************}
{string expression }
{******************}

type
   TStrFunction=class(TStrExpression)
          exe   :TCALL;
         constructor create(idr:TIdrec);
         function evalS:ansistring;override;
         destructor destroy;override;
     end;




{*****************}
{string expression}
{*****************}




function TStrExpression.kind:char;
begin
   kind:='s'
end;

{
function TStrExpression.format(f:string):string;
begin
     format:=str
end;
}

constructor TStrFunction.create(idr:TIdrec);
begin
   inherited  create;
   exe:=TCALL.createF(idr) ;
end;

destructor TStrFunction.destroy;
begin
   exe.free;
   inherited destroy
end;

constructor TStrConstant.create(const s:ansistring);
begin
     inherited create;
     value:=s
end;

destructor TStrConstant.destroy;
begin
    value:='';
    inherited destroy
end;

function TStrConstant.isConstant:boolean;
begin
   isConstant:=true
end;



{******************}
{logical expression}
{******************}


constructor TLogicalBiOp.create(e1,e2:TPrincipal);
begin
   inherited  create;
   exp1:=e1;
   exp2:=e2;
   (*if (exp1=nil) or (exp2=nil) then begin destroy;fail end*)
end;


destructor TLogicalBiOp.destroy;
begin
    exp1.free;
    exp2.free;
    inherited destroy
end;

{****************}
{logical operation}
{*****************}


constructor TComparison.create(e1,e2:TPrincipal; f:comparefunction);
begin
    inherited  create(e1,e2);
    op:=f
end;



{****************}
{logical operation}
{*****************}

constructor TNegation.create(e:TPrincipal);
begin
    inherited create;
    exp:=e ;
end;

destructor  TNegation.destroy;
begin
    exp.free;
    inherited destroy;
end;

{********}
{compiler}
{********}

function subscript(idr:TIdRec):Subscriptarray;
var
   i:integer;
   exp:TPrincipal;
   d:integer;
begin
   for i:=1 to 4 do result[i]:=nil;
      check('(',IDH_ARRAY);
      with idr do
         if tag=undeterm then
            begin
                d:=0;
                repeat
                  inc(d);
                  result[d]:=NExpression;
                until (d=4) or (test(',')=false) ;
                check(')',IDH_ARRAY);
                tag:=intern;
                setdim1(d);
            end
         else
            begin
                for i:=1 to dim do
                    begin
                        exp:=NExpression;
                        result[i]:=exp;
                        if i<dim then check(',',IDH_ARRAY);
                    end;
                check(')',IDH_ARRAY);
            end;
end;

procedure TestSubscripted;      //2011.3.8
var
   idr:TIdRec;
   p:SubscriptArray;
   s:ansistring;
   i:integer;
begin
  if insertDimst and not OptionExplicit then
   begin
     idr:=TIdrec.InitA(token,1,Undeterm);
     try
        gettoken;
        p:=subscript(idr);
        s:='10';
        i:=idr.dim;
        while i>1 do  begin s:=s+',10'; dec(i) end;
        insertLine(linenumber,'DIM '+idr.name+'('+s+')');
        raise EReCompile.create('');
     finally
        idr.free;
     end;
   end
 else
     gettoken;
end;



function reservedword(name:ShortString):boolean;
var
   index:integer;
   s:boolean;
begin
   s:=ReservedwordTable.search(@name,index);
   if s then  seterr(name+s_IsReserved,IDH_RESERVED);
   reservedword:=s;
end;

function ColonIncluded:boolean;
var
   svcp:tokensave;
begin
   savetoken(svcp);
   gettoken;
   repeat
      gettoken;
      while token='(' do
         FindCorrespondingParenthesis;
   until (token=':') or (token=')') or (tokenspec=tail);
   result:=(token=':');
   restoretoken(svcp);
end;

function IdRecord(CanInsert:boolean):TIdRec;
var
  index,index1: integer;
  idr:TIdRec;
  func: SimpleFunction;
  module1:TModule;
  mnam:AnsiString;
  nam:ansistring;
begin
  IdRecord:=nil;
  //if  (tokenspec<>NIdf) and (tokenspec<>SIdf) then
  //    begin seterrExpected('識別名',IDH_RESERVED);exit;end;

  mnam:=modifier(token);
  nam:=identifier(token);
  if mnam<>'' then
     begin
        if ForceFunctionDeclare
          and not ProgramUnit.ExternalVarTable.search2(mnam,nam,index1) then
            seterr(token+s_IsNotExternalDeclared,IDH_MODULE);

        module1:=nil;
        if pass=2 then  module1:=module(mnam);
        if (module1<>nil) and module1.ShareVarTable.search(nam,index1) then
           begin
              Idr:=TIdRec(module1.ShareVartable.items[index1]);
              Idrecord:=idr;
              if (idr.tag<>idPublic) then
                   seterr(Format(s_NotPublicDeclaredIn,[mnam,nam]),IDH_MODULE);
              if (tokenspec=NIdf) and (module1.Arithmetic<>programunit.Arithmetic) then
                   seterr(s_DisAgreeArithmetic,IDH_MODULE);

           end
        else if ProgramUnit.ExternalVarTable.search2(mnam,nam,index1) then
             idrecord:=TIdRec(ProgramUnit.ExternalVarTable.items[index1]);
     end
  else if (LocalRoutine<>nil)
       and LocalRoutine.isFunction and (LocalRoutine.ResultVar.name=token) then
     IdRecord:=LocalRoutine.ResultVar
  else if (LocalRoutine<>nil) and LocalRoutine.VarTable.search(token,index1) then
     IdRecord:=TIdRec(LocalRoutine.VarTable.items[index1])
  else if ProgramUnit.isFunction and (ProgramUnit.ResultVar.name=token) then
     IdRecord:=ProgramUnit.ResultVar
  else if ProgramUnit.VarTable.search(token,index) then
     IdRecord:=TIdRec(ProgramUnit.VarTable.items[index])
  else if (CurModule<>nil) and CurModule.ShareVarTable.search(token,index1) then
     begin
       IdRecord:=TIdRec(CurModule.ShareVarTable.items[index1]);
       if (tokenspec=NIdf) and (CurModule.Arithmetic<>programunit.Arithmetic) then
                    seterr(s_DisAgreeArithmetic,IDH_MODULE);
     end
  else if ProgramUnit.ExternalVarTable.search(token,index1) then
     begin
        idr:=TIdRec(ProgramUnit.ExternalVarTable.items[index1]);
        if (pass=1) or (idr.dim<0) then
           IdRecord:=idr
        else
           begin
             module1:=module(idr.moduleName);
             if (module1<>nil) and module1.ShareVarTable.search(token,index1) then
                IdRecord:=TIdRec(module1.ShareVartable.items[index1])
           end
     end
  else if CanInsert then
    begin
      if (nexttoken='(') then
          if MinimalBasic and not SuppliedFunctionTable.find(token,func) then
             ProgramUnit.VarTable.insert(index,TIdRec.initA(token,1,Undeterm))
          else if (tokenSpec=Sidf) and  ColonIncluded then
              ProgramUnit.VarTable.insert(index,TIdRec.initSimple(token,intern,maxint))
          else
              exit
      else if not OptionExplicit
              or (LineNumber=0) and (mainprogram.name<>''){PROGRAM-line} then
              ProgramUnit.VarTable.insert(index,TIdRec.initSimple(token,intern,maxint))
           else
              setErr(token+s_IsNotDeclared,IDH_DECLARE) ;
       IdRecord:=TIdRec(ProgramUnit.VarTable.items[index]);
    end;
end;




function  Variablesub(var k:integer):TVariable;
var
  IdRec:TIdRec;
begin
  Variablesub:=nil;
  if reservedword(token) then exit;

  idrec:=IdRecord(true);
  if IdRec=nil then exit;

  gettoken;
  with IdRec do
    if kindchar='n' then
      begin
        k:=dim;
        case k of
            0: Variablesub:=IdRec.subs;
            1: Variablesub:=NSubScripted1(IdRec,Subscript(IdRec));
            2: Variablesub:=NSubScripted2(IdRec,Subscript(IdRec));
            3: Variablesub:=NSubScripted3(IdRec,Subscript(IdRec));
            4: Variablesub:=NSubScripted4(IdRec,Subscript(IdRec));
           -1: if prm then
                      Variablesub:=IdRec.subs
               else
                      seterr(prevtoken +s_IsFunctionName,IDH_RESERVED);
        end;
      end
    else
      begin
        k:=dim;
        case k of
            0: Variablesub:=IdRec.subs;
            1: Variablesub:=TSubScripted1.create(IdRec,Subscript(IdRec));
            2: Variablesub:=TSubScripted2.create(IdRec,Subscript(IdRec));
            3: Variablesub:=TSubScripted3.create(IdRec,Subscript(IdRec));
            4: Variablesub:=TSubScripted4.create(IdRec,Subscript(IdRec));
           -1: if prm then
                      Variablesub:=IdRec.subs
               else
                      seterr(prevtoken +s_IsFunctionName,IDH_RESERVED);
        end;
      end;
end;

function variable:TVariable;
var
   p:TVariable;
   k:integer;
begin
   variable:=nil;
   p:=variablesub(k);
   if (p<>nil) and  (k>=0) then
      variable:=p
   else     {function reference}
      begin
          seterrExpected(s_VarName,IDH_RESERVED)  ;
          p.free
      end;
end;

function  NVariable:TVariable;
begin
   result:=Variable;
   if (result<>nil) and  (result.kind<>'n') then
      seterrExpected(s_NumVar,IDH_RESERVED);
end;


function simpleVariable:TSubstance;
var
   p:TPrincipal;
   k:integer;
begin
   p:=nil;
   if tokenspec=NIdf then
      begin
          p:=variablesub(k);
          if (p<>nil) and (k<>0) then
                begin
                    p.free;
                    p:=nil
                end;
      end;
   if p=nil then
                seterrRestricted(s_SimpleVar,IDH_RESERVED);
   simplevariable:=p as TSubstance
end;


{********}
{compiler}
{********}
function  NSExpression1:TPrincipal;
var
   svcp:^tokensave;
begin
   new(svcp);
   savetoken(svcp^);
   try
      try
         inc(trying);
         result:=NExpression;
      except
         on SyntaxError do
         begin
             restoreToken(svcp^);
             result:=SExpression;
             statusmes.clear;
             HelpContext:=0;
         end;
      end;
   finally
      dispose(svcp);
      dec(trying);
   end;
end;

function  NSExpression:TPrincipal;
var
   sp:tokenspecification;
begin
   sp:=tokenspec;
   if token='(' then sp:=NextTokenspecWithinParenthesis;   //   sp:=nexttokenspec;//2006.1.15
   case sp of
      SCon,Sidf:NSExpression:=SExpression;
      NRep,NIdf:NSExpression:=NExpression;
      else      NSExpression:=NSExpression1;
   end;
end;



function article:TPrincipal;
var
   svcp:^tokensave;
begin
   if token='#' then
      article:=ChExpression
   else
      begin
          new(svcp);
          inc(trying);
          try
              savetoken(svcp^);
              try
                  article:=NSExpression;
              except
                  on SyntaxError do
                     begin
                       restoreToken(svcp^);
                       article:=matrix;
                       statusmes.clear;
                       HelpContext:=0;
                     end;
              end;
          finally
              dispose(svcp);
              dec(trying);
          end;
      end;
end;



{********************}
{numerical Expression}
{********************}

function NMatrixDim(n:shortint):TMatrix;
begin
  result:=NMatrix;
  if result.idr.dim<>n then SeterrDimension(IDH_Array_Parameter);
end;

function SMatrixDim(n:shortint):TMatrix;
begin
  result:=SMatrix;
  if result.idr.dim<>n then SeterrDimension(IDH_Array_Parameter);
end;


function principal(idrec:TIdRec):TPrincipal;
begin
   principal:=nil;
   case idrec.kindchar of
      'n': if idrec.dim =0 then
                 principal:=NExpression
            else if idrec.dim>0 then
                 principal:=NMatrixDim(idrec.dim) ;
       's':if idrec.dim =0 then
                  principal:=sexpression
           else if idrec.dim>0 then
                  principal:=SMatrixDim(idrec.dim) ;
       'c': principal:=ChExpression;
    end;
end;


function VariableOrFunctionRef:TPrincipal;  { variable | function reference}
var
  func: SimpleFunction;
  idr:TIdRec;

begin
  VariableOrFunctionRef:=nil;

  if ReservedWordTable.find(token,func) then
      begin
          gettoken;
          VariableOrFunctionRef:=func
      end
  else
      begin
         idr:=IdRecord(true);
         if idr<>nil then
            with idr do
              if kindchar='n' then
                 case dim of
                    0: begin
                          gettoken;
                          VariableOrFunctionRef:=idr.subs;
                        end;
                    1: begin
                           gettoken;
                           VariableOrFunctionRef:=
                                      NSubscripted1(idr,Subscript(idr));
                         end;
                    2: begin
                           gettoken;
                           VariableOrFunctionRef:=
                                      NSubscripted2(idr,Subscript(idr));
                         end;
                    3: begin
                           gettoken;
                           VariableOrFunctionRef:=
                                      NSubscripted3(idr,Subscript(idr));
                         end;
                    4: begin
                           gettoken;
                           VariableOrFunctionRef:=
                                      NSubscripted4(idr,Subscript(idr));
                         end;
                    -1 : if idr.kindchar='n' then
                            VariableOrFunctionRef:=NFunction(idr)
                         else
                             VariableOrFunctionRef:=TStrFunction.create(idr);
                 end
              else
                 case dim of
                    0: begin
                          gettoken;
                          VariableOrFunctionRef:=idr.subs;
                        end;
                    1: begin
                           gettoken;
                           VariableOrFunctionRef:=
                                      TSubscripted1.create(idr,Subscript(idr));
                         end;
                    2: begin
                           gettoken;
                           VariableOrFunctionRef:=
                                      TSubscripted2.create(idr,Subscript(idr));
                         end;
                    3: begin
                           gettoken;
                           VariableOrFunctionRef:=
                                      TSubscripted3.create(idr,Subscript(idr));
                         end;
                    4: begin
                           gettoken;
                           VariableOrFunctionRef:=
                                      TSubscripted4.create(idr,Subscript(idr));
                         end;
                    -1 : if idr.kindchar='n' then
                            VariableOrFunctionRef:=NFunction(idr)
                         else
                             VariableOrFunctionRef:=TStrFunction.create(idr);
                 end
         else if SuppliedFunctionTable.find(token,func) then
              begin
                  gettoken;
                  VariableOrFunctionRef:=func
              end
          else if not (ForceFunctionDeclare or OptionExplicit) then
             try
                 idr:=TIdrec.initF(modifier(token),identifier(token),intern);
                 if tokenspec=NIdf then
                     VariableOrFunctionRef:=NFunction(idr)
                 else if tokenspec=SIDf then
                     VariableOrFunctionRef:=TStrFunction.create(idr);
             finally
                 idr.free;
             end  ;
      end;
end;



{**********}
{ string   }
{**********}

type
   TSubstring=class(TStrExpression)
        exp:TPrincipal;
        exp1,exp2:TPrincipal;
        CharacterByte:boolean;
      constructor create(e:TPrincipal);
      destructor  destroy;override;
      function evalS:ansistring;override;
    end;

procedure SubstringQualifier(var exp1,exp2:tPrincipal);
begin
    check('(',IDH_SUBSTRING);
    exp1:=NExpression;
    check(':',IDH_SUBSTRING);
    exp2:=NExpression;
    check(')',IDH_SUBSTRING);
end;

constructor TSubString.create(e:TPrincipal);
begin
    inherited  create;
    CharacterByte:=ProgramUnit.CharacterByte;
    exp:=e;
    SubstringQualiFier(exp1,exp2);
end;

destructor TSubString.destroy;
begin
    exp.free;
    exp1.free;
    exp2.free;
    inherited destroy;
end;

function StringPrimary:TPrincipal ;
var
   exp:TPrincipal;
begin
   if token='(' then
        begin
           check('(',IDH_STRING);
           stringprimary:=SExpression;
           checktoken(')',IDH_STRING);
        end
   else if tokenspec=Scon then
         begin
            StringPrimary:=TStrConstant.create(tokenstring);
            gettoken;
         end
   else if tokenspec=SIdf then
        begin
           exp:=VariableOrFunctionRef;
           if (exp=nil) or  (exp.kind<>'s') then
              seterr( token +  s_CantBelongHere + EOL +s_IllegalStringVar,IDH_String);
           if (token='(') and (exp is TVariable) then
              StringPrimary:=TSubString.create(exp)
           else
              StringPrimary:=exp ;
        end
    else
        seterr(s_IllegalStringVar + EOL+ token +  s_CantBelongHere ,IDH_STRING);
end;

constructor TConcat.create(e1,e2:TPrincipal);
begin
    inherited create;
    exp1:=e1;
    exp2:=e2;
end;

destructor TConcat.destroy;
begin
   exp1.free;
   exp2.free;
   inherited destroy;
end;

var
   confirmedA:boolean=false;

function confirmA:boolean;
begin
    confirmA:=false;
    if permitMicrosoft then
        confirmA:=true
    else if autocorrect[ac_string] {or confirmedA or
       confirm(s_ConfirmPlusSignToAnpersand,IDH_MICROSOFT_OP)} then
       begin
         replacetoken('&');
         confirmedA:=true;
         confirmA:=true;
       end;
end;


function SExpression:TPrincipal;
var
   exp:TPrincipal;
begin
   exp:=stringprimary;
   while ((Token='&') or (token='+') and confirmA) and (exp<>nil)  do
         begin
               gettoken;
               exp:=TConcat.create(exp,stringprimary);
         end;
   SExpression:=exp;
end;

{**************}
{constant term }
{**************}

function SConstant:TPrincipal;
begin
   if tokenspec=SCon then
       SConstant:=stringprimary
   else
       begin
          seterrrestricted(s_Constant,IDH_STRING);
          SConstant:=nil
       end
end;


{******}
{matrix}
{******}

function Matrix:TMatrix;
var
  idr:TidRec;
begin
  matrix:=nil;
  idr:=Idrecord(false);
  if (idr<>nil) and (idr.dim>0) then
     begin
        matrix:=TMatrix(idr.subs);
        gettoken;
     end
  else
     seterr(token+s_IsNotArrayName,IDH_MAT);
end;


function  Nmatrix:TMatrix;
begin
   result:=matrix;
   if (result<>nil) and (result.kind<>'n') then
     begin
        result.Free;
        result:=nil;
        seterrExpected(s_NumArrayName,IDH_MAT);
     end;
end;

function  Smatrix:TMatrix;
begin
   result:=matrix;
   if (result<>nil) and (result.kind<>'s') then
      begin
         result.Free;
         seterrExpected(s_StringArrayName,IDH_MAT_STRING);
      end;   
end;


{*******************}
{ logical expression}
{*******************}


procedure  findcomparefunction(const r:string; var f:comparefunction);
begin
   if r='=' then f:=Equals
   else if r='<' then f:=Less
   else if (r='<=') or (r='=<') then f:=NotGreater
   else if r='>' then f:=Greater
   else if (r='>=') or (r='=>') then f:=NotLess
   else if (r='<>') or (r='><') then f:=NotEquals
   else if r='' then  seterrExpected(s_ComparisonExp,IDH_LOGICAL)
   else seterrIllegal(r,IDH_LOGICAL) ;
end;



function comparison:TLogical;     //TComparison;
var
   e1,e2:TPrincipal ;
   f:comparefunction;
begin
   comparison:=nil;
   e1:=NSExpression;
   if e1=nil then exit;
   findcomparefunction(token,f);
   gettoken;
   if e1.kind='n' then
     begin
        e2:=NExpression;
        Comparison:=NComparison(f,e1,e2)
     end
   else
      comparison:=tComparisonS.create(e1,SExpression,f) ;
end;

function Disjunction :TLogical;forward;

function relationalPrimary:TLogical;
var
   svcp:^tokensave;
begin
   if Token= '(' then
      begin
          new(svcp);
          inc(trying);
          try
             saveToken(svcp^);
             try                                    //数値式，文字列式の括弧か？
                 relationalprimary:=comparison;
              except
                 On SyntaxError do
                    begin
                      restoretoken(svcp^);
                      gettoken;                       //　括弧は論理一次子の括弧
                      relationalprimary:=disjunction;
                      checktoken(')',IDH_LOGICAL);
                      statusmes.clear;
                      HelpContext:=0;
                    end;
             end;
          finally
             dispose(svcp);
             dec(trying);
          end;
      end
   else
      relationalprimary:=comparison;
end;

function relationalTerm:TLogical;
begin
   if token='NOT' then
       begin
            gettoken;
            relationalTerm:=TNegation.create(relationalPrimary)
       end
   else
       begin
           relationalTerm:=relationalprimary;
       end;
end;

function conjunction :TLogical;
var
    b:TLogical;
begin
   b:=relationalTerm;
   while token='AND' do
         begin
             gettoken;
             b:=TConjunction.create(b,relationalTerm)
         end;
   conjunction:=b
end;

function Disjunction :TLogical;
var
   b:Tlogical;
begin
   b:=conjunction;
   while token='OR' do
          begin
             gettoken;
             b:=TDisjunction.create(b,conjunction)
          end ;
   disjunction:=b
end;

function relationalExpression :TLogical;
begin
  if permitMicrosoft then
     relationalExpression:=TLogicalNumeric.create
  else
     relationalExpression:=Disjunction
end;


{************}
{LET statement}
{************}
type
  TLet=class(TStatement)
        vari:TVariable;
        exp :TPrincipal;
       constructor create(prev,eld:TStatement; vari1:Tvariable; exp1:Tprincipal);
       destructor destroy;override;
       procedure exec;override;
    end;

   TLetWithNoRound=class(TLet)
       procedure exec;override;
   end;

constructor TLet.create(prev,eld:TStatement; vari1:Tvariable; exp1:Tprincipal);
begin
   inherited create(prev,eld);
   vari:=vari1;
   exp:=exp1;
end;

destructor TLet.destroy;
begin
    vari.free;
    exp.free;
    inherited destroy
end;


type
  TLetMulti0=class(TStatement)
        varis:TObjectList;    {collection of TVariable}
        exp :TPrincipal;
      constructor create(prev,eld:TStatement);
      destructor destroy;override;
    end;

type
  TLetMultiN=class(TLetMulti0)
      constructor create(prev,eld:TStatement);
      procedure exec;override;
    end;

constructor TLetMulti0.create(prev,eld:TStatement);
begin
    inherited create(prev,eld);
    varis:=TObjectList.create(4);
end;

constructor TLetMultiN.create(prev,eld:TStatement);
var
   k:integer;
   p:TPrincipal;
begin
    inherited create(prev,eld);
    repeat
        p:=Variablesub(k);
        varis.add(p);
        if (p=nil) or (p.kind<>'n')  then seterr('',IDH_LET);
        if k<0 then seterrillegal(s_FunctionName,IDH_LET);
    until not test(',');
    check('=',IDH_LET);
    exp:=NExpression;

end;

destructor TLetMulti0.destroy;
begin
    varis.free;
    exp.free;
    inherited destroy
end;

{**********}
{TInputVari}
{**********}

function InputVari(StrOnly:Boolean):TInputVari;
var
   vari:TVariable;
   k:integer;
begin
    vari:=Variablesub(k);
    if(vari=nil) or (k<0) then
      begin
        vari.Free;
        seterrillegal(s_FunctionName,IDH_LET);
      end;
    if StrOnly and (vari.Kind<>'s') then
      begin
        vari.Free;
        SetErr(s_OnlyStringVar,IDH_LINE_INPUT);
      end;
    if vari.kind='n' then
      result:=TInputVari.create(vari)
    else if vari.kind='s' then
      result:=TStrVari.create(vari);
end;

constructor TInputVari.create(vari1:TVariable);
begin
    inherited create;
    vari:=vari1;
end;

function StrVari:TStrVari;
var
   vari:TVariable;
   k:integer;
begin
    vari:=Variablesub(k);
    if k<0 then
       begin
         vari.Free;
         seterrillegal(s_FunctionName,IDH_LET);
       end;  
    result:=TStrVari.create(vari)
end;

constructor TStrVari.create(vari1:TVariable);
begin
    inherited create(vari1);
    if (vari1=nil) or (vari1.kind<>'s')  then
                          seterrexpected(s_StringIdentifier,IDH_String);
    if token='(' then
         SubstringQualifier(index1,index2);
    CharacterByte:=ProgramUnit.CharacterByte;
end;

destructor TInputVari.destroy;
begin
   vari.free;
   inherited destroy;
end;

destructor TStrVari.destroy;
begin
   index1.free;
   index2.free;
   inherited destroy;
end;

type
  TLetMultiS=class(TLetMulti0)
      constructor create(prev,eld:TStatement);
      procedure exec;override;
    end;

constructor TLetMultiS.create(prev,eld:TStatement);
begin
    inherited Create(prev,eld);
    repeat
        varis.add(StrVari);
    until not test(',');
    trying:=0;
    check('=',IDH_LET);
    exp:=SExpression;
end;

type
    SVTriple=record
       sv:TSVar;
       i1,i2:longint;
    end;

    SVArray=array[0..1023] of SVTriple;

function LETst(prev,eld:TStatement):TStatement;
var
   vari:Tvariable;
   svcp:TokenSave;
   sp:char;
   k:integer;
begin
   LETst:=nil;
   savetoken(svcp);
   vari:=Variablesub(k);
   if (vari<>nil) then
      begin
        sp:=vari.kind;
        if (k<0) then
           begin
              check('=',IDH_LET);
              trying:=0;
              case sp of
               'n': Letst:=TLetwithNoRound.create(prev,eld,vari,NExpression);
               's': Letst:=TLetwithNoRound.create(prev,eld,vari,SExpression);
              end;
           end
        else if sp='n' then
           if token=',' then
              begin
                vari.Free;
                restoretoken(svcp);
                Letst:=TLetMultiN.create(prev,eld);
              end
           else
              begin
                check('=',IDH_LET);
                trying:=0;
                Letst:=Tlet.create(prev,eld,vari,NExpression);
              end
        else if sp='s' then
          begin
            vari.Free;
            restoretoken(svcp);
            Letst:=TLetMultiS.create(prev,eld);
        end;
      end
   else
      if ((tokenspec=NIdf) or (tokenspec=SIdf)) and (nexttoken='(') then
        begin
          vari.Free;
          TestSubscripted;
          seterr(s_ArrayShouldBeDeclared,IDH_ARRAY);
        end ;
end;



function tryLETst(prev,eld:TStatement):TStatement;
                      {条件が合わなければnilを返す}
var
   p:TStatement;
   svcp:^TokenSave;
begin
   tryLETst:=nil;
   if (token='ELSEIF') or (token='ELSE') or (token='USE')
                                         or (token='CASE') then exit;
   if NextTokenBeyondParenthesis2<>'=' then  exit;

   if permitMicroSoft then
      begin TryLETst:=LETst(prev,eld);exit end;

   p:=nil;
   new(svcp);
   try
       savetoken(svcp^);
       try
           inc(trying);
           p:=LETst(prev,eld);
           if AutoCorrect[ac_let] or
              confirm(s_ConfirmInsertLET,IDH_MICROSOFT_OP) then
              begin
                TryLETst:=p;
                insertKeyWord('LET ',svcp^) ;
              end
           else
              begin
                 p.Free;
                 restoretoken(svcp^);
              end;
       except
          On SyntaxError do
             restoretoken(svcp^);
       end;
   finally
        dispose(svcp);
        dec(trying);
   end;
end;

{*************}
{DEFst        }
{*************}
type
    TDefN = class(TLetwithNoRound)
       constructor create(prev,eld:TStatement; routine:TRoutine);
    end;

    TDefS = class(TLetwithNoRound)
       constructor create(prev,eld:TStatement; routine:TRoutine);
    end;

constructor TDefN.create(prev,eld:TStatement; routine:TRoutine);
begin
    inherited TStatementcreate(prev,eld);
    vari:=routine.ResultVar.subs;
    check('=',IDH_DEF);
    exp:=NExpression ;
end;

constructor TDefS.create(prev,eld:TStatement; routine:TRoutine);
begin
    inherited TStatementcreate(prev,eld);
    vari:=routine.ResultVar.subs;
    check('=',IDH_DEF);
    exp:=SExpression ;
end;




function DEFst(prev,eld:TStatement):TStatement;
var
   sp:tokenspecification;
begin
     if (LocalRoutine<>nil)
        or (indent>0) and (CurModule=MainProgram)
        or (indent>1)   
        then  seterrillegal(prevtoken,IDH_DEF) ;
     if (ProgramUnit=CurModule) and (ProgramUnit<>MainProgram) then
        seterr(s_InternalRoutineCanntotbeInProcedure,IDH_MODULE);
     DEFst:=TStatement.create(prev,eld) ;
     sp:=tokenspec;
     LocalRoutine:=routineHeadLocal;
     LocalRoutine.MakeParameter;
     case sp of
           NIdf: LocalRoutine.block:=TDefN.create(prev,eld,LocalRoutine);
           SIdf: LocalRoutine.block:=TDefS.create(prev,eld,LocalRoutine);
      end;
     localRoutine:=nil;
end;

{*********}
{Arguments}
{*********}

function argumentN1:TPrincipal;
begin
     check('(',IDH_FUNCTIONS);
     argumentN1:=Nexpression;
     checktoken(')',IDH_FUNCTIONS);
end;

function argumentN2a:TPrincipal;
begin
     check('(',IDH_FUNCTIONS);
     argumentN2a:=Nexpression;
     check(',',IDH_FUNCTIONS);
end;

function argumentN2b:TPrincipal;
begin
     argumentN2b:=Nexpression;
     checktoken(')',IDH_FUNCTIONS);
end;

{*********}
{Micorsoft}
{*********}

constructor TLogicalNumeric.create;
begin
   inherited create;
   exp:=NExpression;
end;

function TLogicalNumeric.evalBool:boolean;
begin
   evalBool:=(exp.evalX<>0)
end;

destructor TLogicalNumeric.destroy;
begin
   exp.free;
   inherited destroy
end;

{********}
{TChannel}
{********}
type
   TChannel=class(TPrincipal)
          exp:TPrincipal;
          PUnit:TProgramUnit;
        constructor create;
        destructor destroy;override;
        function substance0(ByVal:boolean):TVar;override;
        procedure disposesubstance0(p:TVar; ByVal:boolean);override;
        function substance1:TVar;override;
        procedure disposesubstance1(p:TVar);override;
        function kind:char;override;
        function InvalidErCode:integer;override;

   end;

constructor TChannel.create;
begin
    inherited create;
    checkToken('#',IDH_FILE);
    exp:=NExpression;
    Punit:=programUnit;
end;

destructor TChannel.destroy;
begin
   exp.free;
   inherited destroy;
end;

function ChExpression:TPrincipal;
begin
   chExpression:=TChannel.create;
end;

function channel(chn:TPrincipal;Proc:TRoutine; PUnit:TProgramUnit):TTextDevice;
var
   ch:integer;
   ptext:PTextDevice;
begin
    result:=nil;
    if chn=nil then
       result:=console
    else
      begin
        ch:=chn.evalInteger;
        if proc<>nil then
           begin
              ptext:=Proc.VarTable.channelsub(ch,false);
              if (ptext<>nil) and (ptext.ttext<>nil) then
                 result:=ptext.ttext;
           end;
        if result=nil then
           channel:=PUnit.channel(ch)
      end;
end;

function ChannelExpression:TPrincipal;
begin
    if token='#' then
       begin
            gettoken;
            ChannelExpression:=NExpression;
       end
    else
       ChannelExpression:=nil;
end;

{****************}
{Execute Routines}
{****************}

function TSubscripted1.point:TVar;
begin
    point:=TlegacyArray(subs.point).point1(Subscript[1].evalLongint)
end;

function TSubscripted2.point:TVar;
begin
    point:=TlegacyArray(subs.point).point2(Subscript[1].evalLongint,
                                     Subscript[2].evalLongint);
end;

function TSubscripted3.point:TVar;
var
  subsc:Array4;
begin
    subsc[1]:=Subscript[1].evalLongint;
    subsc[2]:=Subscript[2].evalLongint;
    subsc[3]:=Subscript[3].evalLongint;
    point:=TlegacyArray(subs.point).point(subsc)
end;

function TSubscripted4.point:TVar;
var
  subsc:array4;
begin
    subsc[1]:=Subscript[1].evalLongint;
    subsc[2]:=Subscript[2].evalLongint;
    subsc[3]:=Subscript[3].evalLongint;
    subsc[4]:=Subscript[4].evalLongint;
    point:=TlegacyArray(subs.point).point(subsc)
end;

function TConstVariable.substance1:TVar;
begin
    substance1:=vari.substance1
end;


procedure TConstVariable.disposesubstance1(p:TVar);
begin
  vari.disposesubstance1(p)
end;

function TConstVariable.substance0(ByVal:boolean):TVar;
begin
    substance0:=vari.substance1
end;

procedure TConstVariable.disposesubstance0(p:TVar; ByVal:boolean);
begin
    vari.disposesubstance1(p)
end;

procedure TCALL.exec;
begin
  routine.run(params,DoAfter);
end;

function TCALL.evalS:ansistring;
begin
  if Routine is TDEF or ResultVarStatic then
    begin
     routine.run(params,DoAfter);
     result:=routine.resultvar.subs.evalS;
    end
  else
    with Routine do
      begin
         ResultVar.pushstack;
         ResultVar.getvar;
         try
           run(params,DoAfter);
           result:=resultvar.subs.evalS;
         finally
           resultvar.freeVar;
           Resultvar.popstack;
         end;
     end
end;

procedure TCALL.evalN(var n:number);
begin
  if Routine is TDEF or ResultVarStatic then
    with routine do
      begin
        run(params,DoNothing);
        ResultVar.subs.evalN(n);
      end
  else
    with Routine do
      begin
         ResultVar.pushstack;
         ResultVar.getvar;
         try
           run(params,DoNothing);
           ResultVar.subs.evalN(n);
         finally
           resultvar.freeVar;
           Resultvar.popstack;
         end;
     end
end;

function TCALL.evalF:double;
begin
  if Routine is TDEF or ResultVarStatic then
    with routine do
      begin
        run(params,DoNothing);
        result:=resultvar.subs.evalF;
      end
  else
    with Routine do
      begin
         ResultVar.pushstack;
         ResultVar.getvar;
         try
           run(params,DoNothing);
           result:=resultvar.subs.evalF;
         finally
           resultvar.freeVar;
           Resultvar.popstack;
         end;
     end
end;

procedure TCALL.evalC(var x:complex);
begin
  if Routine is TDEF or ResultVarStatic then
     with routine do
       begin
         run(params,DoNothing);
         ResultVar.subs.evalC(x);
       end
  else
    with Routine do
      begin
         ResultVar.pushstack;
         ResultVar.getvar;
         try
           run(params,DoNothing);
           ResultVar.subs.evalC(x);
         finally
           resultvar.freeVar;
           Resultvar.popstack;
         end;
      end
end;

procedure TCALL.evalR(var r:PNumeric);
begin
  if Routine is TDEF or ResultVarStatic then
     with routine do
       begin
         run(params,DoNothing);
         ResultVar.subs.evalR(r);
       end
  else
    with Routine do
      begin
         ResultVar.pushstack;
         ResultVar.getvar;
         try
           run(params,DoNothing);
           ResultVar.subs.evalR(r);
         finally
           resultvar.freeVar;
           Resultvar.popstack;
         end;
     end
end;


function TStrExpression.str:ansistring;
begin
    str:=evalS;
end;

function TStrExpression.str2:ansistring;
begin
    str2:=quoted(evalS)
end;

function TStrExpression.substance0(ByVal:boolean):TVar;
begin
     result:=TSvar.create(maxint);
     result.substS(evalS);
end;

procedure TStrExpression.disposeSubstance0(p:TVar; ByVal:boolean);
begin
     TSvar(p).free;
end;

function TStrExpression.substance1:TVar;
begin
     result:=TSvar.create(maxint);
     result.substS(evalS);
end;

procedure TStrExpression.disposeSubstance1(p:TVar);
begin
     TSvar(p).free;
end;

function TStrExpression.Compare(p:TPrincipal):integer;
begin
   compare:=CompareStr(evalS,p.evalS)
end;

function TStrFunction.evalS:ansistring;
begin
  result:=exe.evalS ;
end;

function TStrConstant.evalS:ansistring;
begin
    result:=value;
end;

function TComparison.evalbool:boolean;
var
    i:integer;
begin
    i:=exp1.compare(exp2);
    evalBool:=op(i)
end;

function Equals(i:integer):boolean;
begin
   Equals:=(i=0)
end;

function NotEquals(i:integer):boolean;
begin
   NotEquals:=(i<>0)
end;

function Less(i:integer):boolean;
begin
   Less:=(i<0)
end;

function Greater(i:integer):boolean;
begin
   Greater:=(i>0)
end;

function NotGreater(i:integer):boolean;
begin
   NotGreater:=(i<=0)
end;

function NotLess(i:integer):boolean;
begin
   NotLess:=(i>=0)
end;

function TNegation.evalBool:boolean;
begin
     evalBool:= not exp.evalBool;
end;

function TConjunction.evalBool:boolean;
begin
    evalBool:=exp1.evalBool and exp2.evalBool
end;

function TDisjunction.evalBool:boolean;
begin
    evalbool:=exp1.evalBool or exp2.evalBool
end;


procedure GetSubstringIndex(exp1,exp2:TPrincipal; var i,j:Longint);
var
  c,d:integer;
begin
   i:=exp1.evalInteger;
   j:=exp2.evalInteger;
   if i<=0 then i:=1;
   if j<0 then j:=0;
end;

function TSubString.evalS:ansistring;
var
   i,j:longint;
   s:ansistring;
begin
   s:=exp.evalS;
   GetSubStringIndex(exp1,exp2,i,j);
   result:=substring(s,i,j,CharacterByte);
end;

function TConcat.evalS:ansistring;
begin
  result := exp1.evalS +  exp2.evalS;
end;

procedure  TLet.exec;
begin
   vari.assign(exp);
end;

procedure TLetWithNoRound.exec;
begin
   vari.assignwithNoRound(exp)
end;

procedure TLetMultiN.exec;
var
    p:TVar;
    c:TList;
    i:integer;
    dummy:integer;
label
    EXIT;
begin
    c:=TList.create;
    i:=0;
    while (i<varis.count) do
       begin
          p:=TVariable(varis.items[i]).substance0(false);
          if p<>nil then
             dummy:=c.add(p)
          else
             goto EXIT;
          inc(i);
       end;
    p:=TVar(c.items[0]);
    p.assign(exp);
    i:=1;
    while (i<c.count)  do
       begin
          TVar(c.items[i]).copyfrom(p);
          TVariable(varis.items[i]).disposesubstance0( TVar(c.items[i]),false);
          inc(i);
       end;
    TVariable(varis.items[0]).disposesubstance0(p,false);

  EXIT:
    c.free;
end;

function TInputVari.readDataV2(const s:ansiString; q,i:boolean):boolean;
var
   p:TVar;
begin
   result:=false;
   p:=vari.substance0(false);
   if p<>nil then result:=p.readDataV2(s,q,i);
   vari.disposeSubstance0(p,false);
end;

function TStrVari.readDataV2(const s:ansiString; q,i:boolean):boolean;
begin
   result:=true;
   SubstS(s)
end;

procedure TStrVari.read(const s:ansiString);
begin
   SubstS(s)
end;

procedure TStrVari.substS(const s:ansistring);
var
  i1,i2:integer;
  c1,c2:integer;
  p:TSVar;
begin
  i1:=0; i2:=maxint;
  if (index1<>nil) and (index2<>nil) then
     begin
         i1:=index1.evalInteger;
         i2:=index2.evalInteger;
     end;
  if (i1=0) and (i2=maxint) then
    begin if vari<>nil then vari.substS(s) end
  else
     if vari<>nil then
        begin
           Tvar(p):=vari.Substance0(false);
           TSvar(p).substSubString(i1,i2,s,CharacterByte);
           vari.disposesubstance0(p,false);
        end   
end;

procedure TLetMultiS.exec;
var
    p:^SVArray;
    i:integer;
    e1,e2:TPrincipal;
    s:AnsiString;
    //cont:boolean;
begin
    p:=AllocMem(sizeof(SVTriple)*varis.count);
    i:=0;
    try
      while (i<varis.count) do
          with p^[i] do
          begin
            TVar(sv):=TStrVari(varis.items[i]).vari.substance0(false);
            e1:=TStrVari(varis.items[i]).index1;
            e2:=TStrVari(varis.items[i]).index2;
            i1:=0;
            i2:=maxint;
            if e1<>nil then i1:=e1.evalInteger;
            if e2<>nil then i2:=e2.evalInteger;
            inc(i);
          end;

      s:=exp.evalS;

      i:=0;
      while i<varis.count do
         begin
           with p^[i] do
             begin
                if (i1=0) and (i2=maxint) then
                  sv.substS(s)
                else
                  sv.substSubString(i1,i2,s,Punit.CharacterByte );
                TStrVari(varis.items[i]).vari.disposesubstance0(TVar(sv),false)
             end;
            inc(i);
         end;
    finally
      freemem(p,sizeof(SVTriple)*varis.count);
    end;
end;

function TChannel.substance0(ByVal:boolean):TVar;
var
    i:longint;
begin
    substance0:=nil;
    i:=exp.evalLongint;
    if i>=0 then
         substance0:=PUnit.ChannelSub(i,true)
      else
         setexception(7001) ;
end;

function TChannel.InvalidErCode:integer;
begin
  result:=7001
end;

function TChannel.substance1:TVar;
begin
    substance1:=substance0(true)
end;


procedure TChannel.disposesubstance0(p:TVar; ByVal:boolean);
begin
end;

procedure TChannel.disposesubstance1(p:TVar);
begin
end;

function TChannel.kind:char;
begin
   result:='c'
end;


{**********}
{Initialize}
{**********}
procedure statementTableinit;
begin
       statementTableinitImperative('LET',LETst);
       statementTableinitStructural('DEF',DEFst);
end;


initialization
   suppliedFunctionTable:=TFncSelection.create;
   suppliedFunctionTable.capacity:=96;
   reservedwordTable:=TFncSelection.create;
   if TableInitProcs=nil then
      TableInitProcs:=TProcsCollection.create; //97.10.12 初期化順に疑念発生，struct.pasより移動
   tableInitProcs.accept(statementTableinit);

finalization
   reservedwordTable.free;
   suppliedFunctionTable.free;
end.
