 unit struct;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

(***************************************)
(* Copyright (C) 2006, SHIRAISHI Kazuo *)
(***************************************)

{$X+}


{********}
interface
{********}
uses Classes,SysUtils, Graphics, Forms, Dialogs, Controls, math,
     listcoll, base,texthand,arithmet,variabl,textfile;

procedure setPrecisionMode(precMode:tpPrecision; initial:boolean);
var MixedArithmetic:boolean;

procedure KeyWordTablesFreeAll;


{*********}
{TIdTable}
{*********}

type
   TIdTable =class(TObjectList)
      function KeyOf(item:TObject):AnsiString;override;
      function inquire(const name:AnsiString; var index:integer;
                                    var dim:integer):boolean;
      function search2(const mnam,nam:AnsiString; var index:integer):boolean;
      procedure InitComplete(arith:tpPrecision);
      procedure popStack;
      procedure PushStack;
      procedure getVar;
      procedure FreeVar;
      function channelsub(ch:integer; CanInsert:boolean):PTextDevice;
   end;


const
   MaxNumberOfParams=256;
type
   PVarArray=^TVarArray;
   TVarArray=array[0..MaxNumberOfParams-1] of TVar;

{******************}
{LabelNumbers Table}
{******************}
type
    TStatement=class;
    PLabelNumberPair =^LabelNumberPair;
    LabelNumberPair=record
          Labelnumb:integer;
          statement:TStatement;
          prefect  :TStatement;
    end;


    TLabelNumberTable=class(TSortedListCollection)
       procedure FreeItem(Item:pointer);override;
       function Compare(key1,key2:pointer):integer;override;
       procedure AddItem(p:TStatement);
   end;


{****************}
{Statement}
{****************}

      TRoutine=class;
      TProgramUnit=class;
      TModule=class;
      TWhenException=class;

      TStatement=class(TMyObject)
               linenumb:  integer;
               labelnumb: integer;
               next:      TStatement;
               previous:  TStatement;
               eldest:    TStatement;
               WhenBlock: TWhenException;
               proc:      TRoutine;
               PUnit:     TProgramUnit;
               StopKeySence:procedure of Object;
            constructor create(prev,eld:TStatement) ;
            constructor TStatementCreate(prev,eld:TStatement);
            procedure CollectLabelInfo(t:TLabelNumberTable);virtual;
            procedure SequentiallyExecute;
            procedure exec;virtual;
            function insideofwhen:LongBool;
            destructor destroy;override;
            function SetBreakPoint(i:integer; b:boolean):boolean;virtual;
            function ChangeStopkeySence(b:boolean):boolean;
            function ExecutiveNext:TStatement;
          private
            function ExceptionHandle:boolean;
            function NotSubStatement:boolean;
            procedure stopkeysence0;
            procedure stopkeysence1;
            procedure BreakPoint;
            procedure Trace;
            procedure TraceReport;
      end;


     TWhenException=class(TStatement)
       public
            block:TStatement;
            UseBlock:TStatement;
            svextype:integer;
            svStatementEx:TStatement;
          constructor create(prev,eld:TStatement);
          procedure CollectLabelInfo(t:TLabelNumberTable);override;
          destructor destroy;override;
          procedure exec;override;
          function runHandler(StatementEx:TStatement):boolean; //正常終了のとき真
          function ExecHandler:TStatement;virtual;
          function SetBreakPoint(i:integer; b:boolean):boolean;override;
     end;


   TTerminal=class(TStatement)
      statement:TStatement;
     procedure exec;override;
   end;


{*******}
{routine}
{*******}
   TypeProcedure=Procedure;
   //ObjectBooleanFunction = function :boolean  of Object;
   TRunProcedure =procedure(params:TObjectList; DoAfter:TypeProcedure) of object;
   TEvalProcedure =procedure(params:TObjectList; DoAfter:TypeProcedure ) of object;

   TRoutine=class(TObject)
          resultVar :TIdrec;
          name      :AnsiString;
          VarTable  :TIdTable;
          paramcount:integer;
          block     :TStatement;
          run       :TRunProcedure;
          DoBefore  :procedure;
          GotoList  :TList;
          kind      :char;      {#0:MainProgram, M:module, D:def, F:function, S:sub, P:picture, H:Handler}
          ByVal     :boolean;
          NoBeamOff:boolean;
        constructor create(const n:Ansistring; k:char; maxlen:integer);
        destructor  destroy;override;
        procedure SetResultVar(arith:tpPrecision);
        procedure ResultVarGetVar;virtual;abstract;
        //procedure exec(params:TObjectList; DoAfter:TypeProcedure);virtual;
        procedure MakeParameter;
        procedure RoutineBody;virtual;
        procedure deleteStatements;
        procedure VarTablesRebuild;virtual;abstract;
        procedure LabelComplete;
        function  isfunction:boolean;
        function  SetBreakPoint(i:integer; b:boolean):boolean;
       private
        function noEffect:boolean;
        procedure RunNaive(params:TObjectList; DoAfter:TypeProcedure);
        procedure RunOrdinary(params:TObjectList; DoAfter:TypeProcedure);
     end;

{**********}
{TTarceList}
{**********}


   TTraceList=class(TStringList)
    public
     constructor create;
     destructor destroy;override;
     procedure addString(const name,value:ansistring);
     function getString(const name:ansistring):ansistring;
     procedure merge(VarTable:TIdTable);
   end;

{*******************}
{External procedures}
{*******************}
   OptionAppearance=(ApNone,ApUnit,ApModule);

   TProgramUnit=class(TRoutine)
          LineNumb:integer;
          parent:TModule;
          ExternalVarTable:TIdTable;
          ExternalSubTable:TIdTable;
          DataSeq  :TDataSeqV2;
          ImageList:TStringList;
          TraceList:TTraceList;
          Arithmetic:tpPrecision;
          ArrayBase:shortint;
          AngleDegrees:boolean;
          CharacterByte:boolean;
          debug:boolean;
          optionArithmet:OptionAppearance;
          optionAngle   :OptionAppearance;
          OptionBase    :OptionAppearance;
          OptionCollate :OptionAppearance;
          DimAppeared:boolean;
       constructor create(const n:Ansistring; k:char; maxlen:integer; p:TModule);
       function channelsub(ch:integer; CanInsert:boolean):PTextDevice;
       function channel(ch:integer):TTextDevice;
       procedure openPrinter(ch:integer);
       procedure open(ch:integer;const FName:FNameStr; am:AccessMode;
                      rc:Recordtype; og:OrganizationType; len:integer);
       procedure close(ch:integer);
       destructor destroy;override;
       procedure RoutineBody;override;
       procedure VarTablesRebuild;override;
      private
       procedure RunWithData(params:TObjectList; DoAfter:TypeProcedure);
       procedure RunWithNoData(params:TObjectList; DoAfter:TypeProcedure);
       //procedure EvalWithData(params:TObjectList; DoAfter:TypeProcedure);
       //procedure EvalWithNoData(params:TObjectList; DoAfter:TypeProcedure);
   end;


{*********}
 {Module}
{*********}

   TModule=class(TProgramUnit)
    public
        ShareVarTable:TidTable;
        ShareSubTable:TIdTable;
       constructor create(const n:Ansistring;k:char);
       procedure RunModule;
       procedure RunMain;
       procedure RoutineBody;override;
       procedure VarTablesRebuild;override;
       destructor destroy;override;
   end;


function module(const nam:AnsiString):TModule;

{****************}
{Local Procedures}
{****************}

Type
   TLocalProc=class(TRoutine)
         parent:TProgramUnit;
      constructor create(const n:Ansistring; k:char; maxlen:integer);
      procedure VarTablesRebuild;override;
    end;

type
   TDEF=class(TLocalProc)
      constructor create(const n:Ansistring; k:char; maxlen:integer);
   end;


{ ********* }
{ THandler  }
{********** }


   THandler=class(TLocalProc)
          WhenUseBlockStack:TObjectList;
      constructor create(const n:Ansistring; k:char);
      destructor destroy;override;
      procedure  run(p:TWhenException);
   end;



{*****************}
{ Procedures Table}
{*****************}
type
    TProcTbl=class(TObjectList)
          function inquire(const name:AnsiString; var p:TRoutine ):boolean;
          function keyof(Item:TObject):AnsiString;override;
          procedure deleteStatements;
          procedure VarTablesRebuild;
          procedure ShareVarTableGetVar;
          procedure ShareVarTableFreeVar;
          function SetBreakPoint(i:integer; b:boolean):boolean;
          procedure RunModules;
    end;

{******************}
{Control Exceptions}
{******************}
type
    EControlException=class(Exception)
      constructor create;
    end  ;

    ERetry=class(EControlException);
    EContinue=class(EControlException);
    EReturn=class(EControlException);
    EStop=class(EControlException);

    EExitFunction=class(EControlException);
    EExitSub=class(EControlException);
    EExitPicture=class(EControlException);

    EExitHandler=class(EControlException)
       When:TWhenException;
       constructor create(when1:TWhenException);
    end;

    EExitDo=class(EControlException)
         NextSt:TStatement;
       constructor create(St:TStatement);
    end;
type
  TGotoTag=record
              prefect:Tstatement;
              statement:TStatement;
             end;

{    EGoto=class(EControlException)
        GotoTag:TGotoTag;
      constructor create(prefect1,statement1:TStatement);
    end;
}
(*
const
      ExitDo = -1;
      ExitFor= -2;
      ExitFunction= -3;
      Exitsub= -4;
      ExitPicture= -5;
      {ExitHandler =-6;}
      ReTry  =-7;
      continue=-8;
      exitGoto=-9;
      Return  =-10;
      endWhen =-11;
      STOP   =-12;
*)

{*******}
{GOTO st}
{*******}

type
   TGOTO=class(Tstatement)
           numb:integer;
           prefect:TStatement;
           statement:TStatement;
       constructor create(prev,eld:TStatement);
       procedure FillInfo(LabelNumbertable:TLabelNumberTable);virtual;
       procedure exec;override;
    end;

type
   TControlException=class of EControlException;
type
     TEXIT=class(TStatement)
          typ:TControlException;
        constructor create(prev,eld:TStatement; t:TControlException);
        procedure exec;override;
     end;

{****************}
{Global Variables}
{****************}
var
    CurrentProgram:TProcTbl;
    MainProgram:TModule;

{翻訳時}
var
    LocalRoutine:TLocalProc ;
    ProgramUnit:TProgramUnit ;
    CurModule:TModule;

{実行時}
var
   CurrentStatement:TStatement;
   NextStatement:TStatement;
   CurrentOperation:TMyObject;

type
  TBreakFlags=record
     case integer of
       1: (LongFlag:longbool);
       2: (ctrlBreak:boolean; TraceMode:boolean; TraceChannelPlus1:word);
     end;
var
  BreakFlags:TBreakFlags=(LongFlag:false) ;
  ctrlBreakHit: boolean absolute BreakFlags;

function RunBlock(statement:TStatement):TStatement;
                   // 結果は次に実行する文。
                   // USEブロックからEXIT DO文で抜けるために用いる。
                   // 通常はnil。

procedure propagateException;

{****************}
{select procedure}
{****************}
type
   string10=string[10];
   StatementFunction = function(prev,eld:TStatement) :TStatement;
   statementspec=(declative,imperative,structural,terminal,singular);
   PrcSelectee = record
        name : string10;
        spec : statementspec;
        prc  : StatementFunction;
   end;

   PPrcSelectee = ^PrcSelectee;

   TPrcSelection = class(TstringCollection)
         procedure accept(n:string10; s:statementspec; f:StatementFunction );
         function find(s:String ;  var prc:StatementFunction ; var sp:statementspec):boolean;
         procedure freeItem(item:pointer);override;
   end;

var
   statementTable        : TprcSelection;

procedure statementtableInitDeclative (n:string10 ; f:StatementFunction);
procedure statementtableInitImperative(n:string10 ; f:StatementFunction);
procedure statementtableInitStructural(n:string10 ; f:StatementFunction);
procedure statementtableInitTerminal  (n:string10 ; f:StatementFunction);
procedure statementtableInitSingular  (n:string10 ; f:StatementFunction);

{*****************}
{supplied function}
{*****************}


type
   string11 = string[11];
   Simplefunction = function :TPrincipal;
   PFncSelectee = ^TFncSelectee;
   TFncSelectee = record
        name : string11;
        Fnc  : Simplefunction;
   end;


   TFncselection = class(TstringCollection)
         function find(s:String ; var Func:simplefunction):boolean;
         procedure accept(const n:string11; f:simplefunction);
         procedure freeitem(item:pointer);override;
   end;


var
   suppliedFunctionTable : TFncSelection;
   reservedWordTable : TFncSelection;

procedure  SuppliedFunctionTableInit(n:string11; f:simplefunction);
procedure  reservedWordTableInit(n:string11; f:simplefunction);

{*****************************************}
{ Table Initializing procedures Collection}
{*****************************************}
type
   proc = procedure;
   TProcsCollection=class(TListCollection)
       procedure call;
       procedure accept(f:proc);
       procedure freeItem(Item:pointer);override;
   end;

var
  TableInitProcs:TProcsCollection=nil;

{********}
{compiler}
{********}


procedure compile;
function routineHeadLocal:TLocalProc;
function block(prev:TStatement):TStatement;
//procedure SetEldest(p:TStatement);
function last(p:TStatement):TStatement;
function LabelStatement(prev,eld:TStatement):TStatement;


var
   {DOnest:integer=0;}
   USEnest:integer =0;

var
   DoStack:Tlist;
   ForStack:TList;
   WhenStack:Tlist;
   WhenUseStack:Tlist;

procedure MaxLenDeclaration(sp:SetOfTokenSpec; var maxlen:integer);
procedure DoNothing;

procedure ReportException(InsideOfWhen:boolean; t:integer); overload;
procedure ReportException(InsideOfWhen:boolean; t:integer; s:string); overload;

procedure NoCallBack(Proc:TRoutine);
var PrepareCallBack: procedure(Proc:TRoutine)= NoCallBack;

{************}
implementation
{************}
uses
     debuglst,helpctex,control, float,
     express,expressn,expressf, expressc,expressr,confopt,
     debug,debugdg,tracefrm,sconsts,merge,MyThread,GraphQue,extdll;

var NonFatalExRaised:boolean=false;
    RecentLabelNumber:integer;

procedure ReportException(InsideOfWhen:boolean; t:integer;s:string);
var
   s1,s2,ss:string;
begin
  if InsideOfWhen  then
              setexception(t)
  else
    begin
      str(t,s1);
      s2:=ErrorMes(t);
      ss:='Exception raised'+EOL
           +memo.Lines[CurrentStatement.linenumb]+EOL
                                  +'EXTYPE '+s1+EOL;
      if s2<>'' then
          ss:=ss+s2+EOL;
      if s<>'' then
          ss:=ss+s+EOL;
      TraceForm.Drop(ss);
      TraceFormRequest:=true;

      NonFatalExRaised:=true;
   end;
end;

procedure ReportException(InsideOfWhen:boolean; t:integer );
begin
   ReportException(InsideOfWhen, t, '');
end;


{*******************}
{TNonSortedCollection}
{*******************}


{********}
{TIdTable}
{********}





function TIdTable.KeyOf(item:TObject):AnsiString;
begin
    keyOf:=TIdRec(item).name
end;

function TIdTable.inquire(const name:AnsiString; var index:integer;
                              var dim:integer):boolean;
var
    rec:TIdRec;
    s:boolean;
begin
    s:=search(name,index);
    inquire:=s;
    if s then
          begin
              rec:=TIdRec(items[index]);
              dim:=rec.dim
          end;
end;

function TIdTable.search2(const mnam,nam:AnsiString; var index:integer):boolean;
var
   found:boolean;
begin
   index:=0;
   found:=false;
   while (index<count) and not found do
      with TIdRec(items[index]) do
           if (mnam=modulename) and (nam=name) then
                found:=true
            else
                index:=index+1;
   search2:=found;
end;

procedure TIdTable.InitComplete(arith:tpPrecision);
var
  i:integer;
begin
  for i:=0 to count-1 do
      TIdrec(items[i]).InitComplete(arith)
end;


{**********}
{TTarceList}
{**********}
type
   TStringObject=class(TObject)
      str:AnsiString;
     constructor create(const s:AnsiString);
     destructor destroy;override;
   end;

constructor TStringObject.create(const s:AnsiString);
begin
   inherited create;
   str:=s;
end;

destructor TStringObject.destroy;
begin
   str:='';
   inherited destroy;
end;

var
   TraceAgreed:boolean=false;

constructor TTraceList.create;
begin
   inherited create;
   sorted:=true;
end;

destructor TTraceList.destroy;
var
   i:integer;
begin
   for i:=0 to count-1 do
       objects[i].free;
   inherited destroy;
end;

procedure TTraceList.addString(const name,value:ansistring);
var
   i:integer;
begin
   if find(name,i) then
    begin
        objects[i].free;
        objects[i]:=TStringObject.create(value)
    end
   else
    addObject(name, TStringObject.create(value))
end;

function TTraceList.getString(const name:ansistring):ansistring;
var
   index:integer;
begin
   if find(name,index) then result:=(objects[index] as TStringObject).str
   else result:=''
end;

procedure TTraceList.merge(VarTable:TIdTable);
var
   idrec:TIdRec;
   a:TArray;
   index,i,j,k,l:integer;
   v:array4;
   s:ansistring;
begin
  if varTable=nil then exit;
  for index:=0 to VarTable.count-1 do
  begin
      idrec:=TIdRec(VarTable.Items[index]);
      with idrec do
      begin
          if (dim>=0) and (name<>'') and (kindchar in ['n','s']) and (subs<>nil)then
          case dim of
             0:   addString(name,subs.str2);
             1..4:begin
                    a:=TArray(subs.ptr);
                    if (a.Amount>1000) and BreakFlags.TraceMode and (Not traceAgreed)
                       then
                         case ThreadMessageDlg(s_ConfirmTraceWithLargeArray,
                                       mtInformation,
                                       [mbYes,mbNo],
                                       IDH_DEBUG) of
                          mrYes:  TraceAgreed:=true;
                          mrNo:  begin
                                  BreakFlags.TraceMode:=false;
                                  RunThread.ExecTraceFormMinimize;
                                  exit;
                                 end;
                         end;

                    for i:=a.lbound[1] to a.lbound[1]+a.size[1]-1 do
                      for j:=a.lbound[2] to a.lbound[2]+a.size[2]-1 do
                        for k:=a.lbound[3] to a.lbound[3]+a.size[3]-1 do
                          for l:=a.lbound[4] to a.lbound[4]+a.size[4]-1 do
                          begin
                              s:=name+'('+strint(i);
                              if dim>1 then s:=s+','+strint(j);
                              if dim>2 then s:=s+','+strint(k);
                              if dim>3 then s:=s+','+strint(l);
                              s:=s+')';
                              v[1]:=i; v[2]:=j; v[3]:=k; v[4]:=l;
                              with a do AddString(s,Itemstr2(PositionOf(v)));
                              //Idle;
                          end;
                  end;
           end;
      end;
  end;
end;


{************}
{TProgramUnit}
{************}


{**********}
{TStatement}
{**********}

constructor TStatement.create(prev,eld:TStatement);
begin
    inherited create;
    PUnit:=ProgramUnit;
    if localRoutine<>nil then
                proc:=LocalRoutine
    else
                proc:=ProgramUnit;
    linenumb:=lineNumber;
    labelnumb:=labelnumber;
    if (LabelNumber>0) and (LabelNumber<RecentLabelNumber) then
       seterrOnLine(LineNumber, s_LineNumberDescent, IDH_LINENUMBER);
    RecentLabelNumber:=LabelNumber;

    previous:=prev;
    if eld=nil then
       eldest:=self
    else
       eldest:=eld;
    with WhenStack do WhenBlock:=items[count-1];
    ChangeStopkeySence(false);
end;

constructor TStatement.TStatementCreate(prev,eld:TStatement);
begin
    create(prev,eld);
end;


destructor TStatement.destroy;
begin
   next.free;
   inherited destroy
end;

procedure TStatement.CollectLabelInfo(t:TlabelNumberTable);
begin
  t.addItem(self);
  if next<>nil then next.CollectlabelInfo(t);
end;

function TStatement.ChangeStopkeySence(b:boolean):boolean;
begin
  result:=true;
  if b then
       StopKeySence:=BreakPoint
  else if PUnit.arithmetic in [PrecisionHigh,PrecisionRational] then
             StopKeySence:=StopkeySence1
  else
             StopKeySence:=StopkeySence0
end ;



function TStatement.SetBreakPoint(i:integer; b:boolean):boolean;
begin
  if i=LineNumb then
     result:=changeStopKeySence(b)
  else
     result:=(next<>nil) and next.SetBreakPoint(i,b);
end;


{*****}
{Block}
{*****}


function TStatement.NotSubStatement:boolean;
begin
   if (previous=nil) or (previous.lineNumb<>linenumb) then
      NotSubStatement:=true
   else
      NotSubStatement:=false
end;



{******************}
{LabelNumbers Table}
{******************}

procedure TLabelNumberTable.FreeItem(Item:pointer);
begin
    if item<>nil then
        begin
            dispose(PLabelNumberPair(item))
        end
end;

function TLabelNumberTable.Compare(key1,key2:pointer):integer;
var
  i:integer;
begin
    i:=LabelNumberPair(key2^).labelNumb - LabelNumberPair(key1^).LabelNumb;
    if i<0 then Compare:=-1 else if i=0 then Compare:=0 else Compare:=1;
end;

procedure TLabelNumberTable.AddItem(p:TStatement);
var
   pair:^LabelNumberPair;
   i:integer;
begin
  if (p.labelnumb>0) and (p.NotsubStatement) then
     if Search(@p.labelnumb,i)then
         begin
            if PLabelNumberPair(items[i])^.statement.LineNumb <> p.linenumb then
                  seterrOnLine(p.linenumb,s_DuplicatedLineNumber,IDH_LINENUMBER);
         end
     else
         begin
            new(pair);
            pair^.labelnumb:=p.labelnumb;
            pair^.prefect:=p.eldest;
            pair^.statement:=p;
            insert(pair);
         end;
end;


{********}
{TRoutine}
{********}

constructor TRoutine.create(const n:ansistring; k:char; maxlen:integer);
begin
    inherited create;
    vartable:=TIdTable.create(0);
    GotoList:=TList.create;
    name:=n;
    kind:=k;
    ByVal:=(kind='F') or (JISDef and (Kind='D')) ;
    run:=RunOrdinary;
    DoBefore:=DoNothing;
    //eval:=EvalOrdinary;
end;

procedure TRoutine.SetResultVar(arith:tpPrecision);
begin
 if ResultVar<>nil then
    begin
       ResultVar.initComplete(arith);
       ResultVar.getVar;
    end;
end;

destructor  TRoutine.destroy;
begin
    OnIdTableFree:=true;
    vartable.free;
    ResultVar.free;
    OnIdTableFree:=false;
    gotolist.free;
    inherited destroy;
end;

procedure TRoutine.deleteStatements;
begin
   block.free;
   block:=nil
end;


constructor TLocalProc.create(const n:ansistring; k:char; maxlen:integer);
begin
    inherited create(n,k,maxlen);
    parent:=ProgramUnit;
end;

constructor TDEF.create(const n:Ansistring; k:char; maxlen:integer);
begin
    inherited create(n,k,maxlen);
    Run:=RunNaive;
end;

constructor TProgramUnit.create(const n:ansistring; k:char; maxlen:integer; p:TModule);
begin
    inherited create(n,k,maxlen);
    parent:=p;

    LineNumb:=lineNumber;
    ExternalVarTable:=TIdTable.create(0);
    ExternalSubTable:=TIdTable.create(0);
    DataSeq:=TDataSeqV2.create;
    ImageList:=TStringList.create;
    Arithmetic:=InitialPrecisionMode;
    // ver.8.1.3.3
    case DefaultOptionArith of
          MainProgramArith:
             if kind<>#0{main program} then arithmetic:=MainProgram.arithmetic;
          ToolBarArith:
              ;
          ArithDecimal:
             arithmetic:=PrecisionNormal;
    end;
    //
    if MinimalBasic then ArrayBase:=0
                    else ArrayBase:=1;
    AngleDegrees:=false;
    CharacterByte:=InitialCharacterByte;
    //debug:=initialdebug;
    //BreakFlags.TraceChannelPlus1:=0;
    if parent<>nil then
       begin
          if parent.OptionArithmet=ApModule then
                begin
                    OptionArithmet:=ApUnit;
                    arithmetic:=parent.arithmetic; //ver. 4.10で追加 ,99/9/24
                end;
          if parent.OptionBase=ApModule then
                begin
                    OptionBase:=ApUnit;
                    ArrayBase:=parent.ArrayBase;
                end;
          if parent.OptionAngle=ApModule then
                begin
                    OptionAngle:=ApUnit;
                    AngleDegrees:=parent.AngleDegrees;
                end;
          if parent.OptionCollate=ApModule then
                begin
                    OptionCollate:=ApUnit;
                    CharacterByte:=parent.CharacterByte;
                end;
       end;
end;

procedure TRoutine.LabelComplete;
var
   LabelNumberTable:TLabelNumberTable;
   i:integer;
begin
    LabelNumberTable:=TLabelNumberTable.create;
    block.CollectLabelInfo(LabelNumberTable);
    with GotoList do
       for i:=0 to count-1 do
            (TObject(items[i]) as TGOTO).FillInfo(LabelNumbertable);
    LabelNumberTable.free;

end;

procedure TLocalProc.VarTablesRebuild;
begin
   setResultVar(parent.arithmetic);
   VarTable.initcomplete(parent.arithmetic);
end;

procedure TProgramUnit.VarTablesRebuild;
begin
   setResultVar(arithmetic);
   VarTable.initcomplete(arithmetic);
   case arithmetic of
            PrecisionNormal:  DoBefore:=SetOpModeDecimal;
            PrecisionHigh:    DoBefore:=SetOpModeHigh;
            precisionNative:  DoBefore:=SetOpModeNative;
            precisionComplex: DoBefore:=SetOpModeNative;
            PrecisionRational:DoBefore:=SetOpModeRational;
   end;
end;

procedure TModule.VarTablesRebuild;
begin
  inherited VarTablesRebuild;
  ShareVarTable.initcomplete(arithmetic);
end;


function  TRoutine.SetBreakPoint(i:integer; b:boolean):boolean;
begin
  result:=Block.SetBreakPoint(i,b)
end;

procedure TGOTO.FillInfo(LabelNumbertable:TLabelNumberTable);
var
  i:integer;
  p:TStatement;
begin
   if LabelNumberTable.search(@numb,i) then
      with LabelNumberpair(LabelNumberTable.items[i]^) do
           begin
               p:=self.eldest;
               while (p<>nil) and (p<>prefect) and (p.previous<>nil) do
                     p:=p.previous.eldest;
               if p=prefect then
                  begin
                        self.statement:=statement;
                        self.prefect:=prefect;
                  end
               else
                   seterrOnLine(self.linenumb,
                             Format(s_CanNotBrachLine,[strint(numb)]),IDH_CONTROL);
           end
    else
       begin
          seterronLine(self.linenumb,Format(s_LineNotFound,[strint(numb)]),IDH_JIS_8);
       end;
end;

destructor TProgramUnit.Destroy;
begin
    DataSeq.free;
    ExternalVarTable.free;
    ExternalSubTable.free;
    //GotoList.free;
    ImageList.free;
    TraceList.free;
    inherited  destroy;
end;


{
procedure TProgramUnit.evalWithData(params:TObjectList; DoAfter:TypeProcedure);
begin
   DataSeq.pushDataPointer;
   evalWithNoData(params,DoAfter);
   DataSeq.popDataPointer;
end;
}
Var
  DummyParameter:TObjectList;
procedure  TModule.RunModule;
begin
   case Arithmetic of
            PrecisionNormal:  SetOpModeDecimal;
            PrecisionHigh:    SetOpModeHigh;
            precisionNative:  SetOpModeNative;
            precisionComplex: SetOpModeNative;
            PrecisionRational:SetOpModeRational;
       end;
   run(DummyParameter,DoNothing);
end;

procedure  TModule.RunMain;
begin
  runModule
end;

function TRoutine.isfunction:boolean;
begin
   isfunction:=ResultVar<>nil;
end;


constructor THandler.create(const n:ansistring; k:char);
begin
    inherited create(n,k,maxint);
    WhenUseBlockStack:=TObjectList.create(4);
end;

destructor THandler.destroy;
begin
    WhenUseBlockStack.free;
    inherited destroy;
end;

constructor TModule.create(const n:ansistring;k:char);
begin
   inherited create(n,k,maxint,self);
   ShareVarTable:=TIdTable.create(0);
   ShareSubTable:=TIdTable.create(0);
end;

destructor TModule.destroy;
begin
  ShareVarTable.free;
  ShareSubTable.free;
  inherited destroy;
end;


function module(const nam:AnsiString):TModule;
var
  routine:TRoutine;
begin
  module:=nil;
  if nam='' then
     module:=MainProgram
  else if CurrentProgram.inquire(nam,routine) and (routine.kind='M') then
     module:=routine as TModule
  else if nam=MainProgram.name then
     module:=MainProgram
  else
     seterr('MODULE ' + nam + s_IsNotFound,IDH_MODULE);
end;

{***************}
{procedure table}
{***************}

function TProcTbl.inquire(const name:AnsiString; var p:TRoutine ):boolean;
var
    index:integer;
    s:AnsiString;
    c:boolean;
begin
    c:=false;
    if pos('.',name)=0 then
       begin
         s:=programunit.name + '.' + name;
         c:=search(s,index);
         if (not c) and (CurModule<>nil)  and (CurModule.kind='M') then
            begin
              s:=CurModule.name + '.' + name;
              c:=search(s,index) ;
            end;
       end;
    if not c then
        c:=search(name,index);
        
    //非互換プログラム
    if not c and (pos('.',name)=0) and  (CurModule=MainProgram) then
       begin
           s:=CurModule.name + '.' + name;
           c:=search(s,index)
              and ( (pass=1)
                   or (MessageDlg(s_AllowGlobalInternalProc + EOL + name,
                                     mtWarning,
                                    [mbYes, mbNo],
                                     IDH_PUBLIC                 ) =  mrYes))
       end;

    if c then p:=TRoutine(items[index]) else p:=nil;
    inquire:=c
end;

function TProcTbl.keyof(item:TObject):AnsiString;
begin
    keyof:=TRoutine(item).name;
end;

procedure TProcTbl.deleteStatements;
var
   i:integer;
   p:TObject;
begin
   for i:=0 to count-1 do
      begin
          p:=items[i];
          (p as TRoutine).deleteStatements
      end;
end;

procedure TProcTbl.VarTablesRebuild;
var
   i:integer;
   p:TObject;
begin
   for i:=0 to count-1 do
      begin
          p:=items[i];
          (p as TRoutine).VarTablesRebuild;
      end;
end;

procedure TProcTbl.ShareVarTableGetVar;
var
   i:integer;
   p:TObject;
begin
   for i:=0 to count-1 do
      begin
          p:=items[i];
          if (p is TModule) then
             (p as Tmodule).ShareVarTable.getvar;
      end;
end;

procedure TProcTbl.ShareVarTableFreeVar;
var
   i:integer;
   p:TObject;
begin
   for i:=0 to count-1 do
      begin
          p:=items[i];
          if (p is TModule) then
             (p as Tmodule).Sharevartable.FreeVar;
      end;
end;

procedure TProcTbl.RunModules;
var
  i:integer;
begin
  try
    for i:=1 to count-1 do
      if TObject(items[i]) is TModule then
               TModule(items[i]).RunModule;
    TModule(items[0]).RunMain;
  except
    on EStop do ;
  end;
end;

function  TProcTbl.SetBreakPoint(i:integer; b:boolean):boolean;
var
   j:integer;
   p:TObject;
begin
   result:=false;
   for j:=0 to count-1 do
      begin
          p:=items[j];
          result:=result or (p as TRoutine).SetBreakPoint(i,b)
      end;
end;


{*************}
{TPrcSeleciton}
{*************}
procedure TPrcSelection.accept(n:string10; s:statementspec; f:StatementFunction );
var
   p   :PPrcSelectee;
begin
       new(p);
       p^.name:=n;
       p^.spec:=s;
       p^.prc:=f;
       insert(p);
end;


function TPrcSelection.find(s:String ;  var prc:StatementFunction ; var sp:statementspec):boolean;
var
   i:integer;
   c:boolean;
   ss:string[31];
begin
   ss:=s;
   c:=search(@ss,i);
   if c then
      begin
          prc:=PPrcSelectee(items[i])^.prc;
          sp:=PPrcSelectee(items[i])^.spec;
      end;
   find:=c
end;

procedure TPrcSelection.freeItem(item:pointer);
begin
    dispose(PPrcSelectee(item))
end;

{*************}
{TFncSelection}
{*************}


function TFncSelection.find;
var
   i:integer;
   t:boolean;
   ss:string[31];
begin
   ss:=s;
   t:=search(@ss,i);
   if t then Func:=PFncSelectee(items[i])^.Fnc;
   find:=t
end;

procedure TFncSelection.accept(const n:string11; f:simplefunction);
var
       p       :PfncSelectee;
begin
       new(p);
       p^.name:=n;
       p^.fnc:=f;
       insert(p);
end;

procedure TFncSelection.freeitem(item:pointer);
begin
   dispose(PfncSelectee(item))
end;

{*******}
{compile}
{*******}
function LabelStatement(prev,eld:TStatement):TStatement;
begin
   if (pass=2) and (LabelNumber>0) then
      LabelStatement:=TStatement.create(prev,eld)
   else
      LabelStatement:=nil
end;

(*
function statement(prev,eld:TStatement):TStatement;
var
    prc:StatementFunction;
    p:TStatement;
    svcp:^TokenSave;
    sp:statementspec;
    s:boolean;
begin
    p:=nil;
    s:=true;
    sp:=declative;  //2000.3.18
    while (not outoftext)  and  (p=nil)  and s do
    begin
        statusmes.clear;               //2001.1.9
        HelpContext:=0;                //2001.3.4
        if statementTable.find(token,prc,sp) then
            begin
                 new(svcp);
                 savetoken(svcp^);
                 gettoken;
                 p:=prc(prev,eld);
                 if (sp=terminal) then
                     restoretoken(svcp^)
                 else
                     nextline;
                 dispose(svcp);
            end
        else if (token='') then
            begin
              p:=LabelStatement(prev,eld);
              nextline
            end
        else
            begin
               p:=tryLETst(prev,eld);
               IF p<>nil then
                  nextline
               else
                  s:=false   ;
            end;
    end;

    if (p<>nil) and (sp<>terminal) then
       if pass=1 then
            statement(p,p.eldest).free   //メモリの断片化防止
       else
            Last(p).next:=statement(p,p.eldest);

    statement:=p;
end;
*)

function statement(prev,eld:TStatement):TStatement;
var
    prc:StatementFunction;
    p:TStatement;
    sp:statementspec;
    s:boolean;
    svcp:TokenSave;
begin
    p:=nil;
    s:=true;
    sp:=declative;  //2000.3.18
    while (not outoftext)  and  (p=nil)  and s do
    begin
        statusmes.clear;               //2001.1.9
        HelpContext:=0;                //2001.3.4
        if statementTable.find(token,prc,sp) then
            begin
                 savetoken(svcp);
                 gettoken;
                 p:=prc(prev,eld);
                 if (sp=terminal) then
                    restoretoken(svcp)
                 else
                    nextline;
            end
        else if (token='') then
            begin
              p:=LabelStatement(prev,eld);
              nextline
            end
        else
            begin
               p:=tryLETst(prev,eld);
               IF p<>nil then
                  nextline
               else
                  s:=false   ;
            end;
    end;

    if (p<>nil) and (sp<>terminal) then
      try
         if pass=1 then
            statement(p,p.eldest).free   //メモリの断片化防止
         else
            Last(p).next:=statement(p,p.eldest);
      except
         p.free;
         raise
      end;
    statement:=p;
end;

function block(prev:TStatement):TStatement;
var
    p:TStatement;
begin
   inc(indent);
   p:=statement(prev,nil);
   //SetEldest(p);
   block:=p;
   dec(indent);
end;
{
procedure SetEldest(p:TStatement);
var
   b:TStatement;
begin
   if p<>nil then
      begin
            b:=p;
            while b<>nil do
                begin
                   b.eldest:=p;
                   b:=b.next;
                end;
      end;
end;
}
{**************}
{last statement}
{**************}

function last(p:TStatement):TStatement;
 begin
            if p=nil then
               last:=nil
            else if p.next=nil then
               last:=p
            else
               last:=last(p.next)
 end;


{*******}
{routine}
{*******}

procedure MaxLenDeclaration(sp:SetOfTokenSpec; var maxlen:integer);
var
  c1:integer;
  n:number;
begin
  if (sp=[SIdf]) and (token='*') then
     begin
          gettoken;
          NumericConstant(n);
          maxlen:=LongIntVal(n,c1);
          if c1>0 then maxlen:=maxint;
     end;
end;

{
function getparameter:AnsiString;
begin
    getparameter:=token;
    if (tokenspec=Nidf) or (tokenspec=SIdf) then
       gettoken
    else if token='#' then
       begin
          gettoken;
          if (tokenspec=Nrep)  and  (pos ('.',token)=0) then
             begin
                getparameter:=prevtoken+token;
                gettoken;
             end
          else
             seterrExpected('整数',IDH_FILE);
       end
     else
       seterrExpected('識別名',IDH_FUNCTION)
end;
}

var
   routineindex:integer;

function routineHeadMain:TModule;
begin
  if (pass=1) then
     begin
       result:=TModule.create('',#0);
       CurrentProgram.add(result);
     end
  else
    begin
       result:=TModule(currentprogram.items[routineindex]);
       inc(routineindex);
    end;
end;



procedure RoutineHead(var routine:TProgramUnit; insideModule:boolean);
var
   name:AnsiString;
   name2:AnsiString;
   index:integer;
   maxlen:integer;
   kind:char;
begin
  kind:=PrevToken[1];
  name:=GetIdentifier;

  if insideModule then
      name2:=curmodule.name+'.'+name
  else
      name2:=name;

  maxlen:=maxint;
  MaxlenDeclaration([prevTokenSpec],maxlen);

  if (pass=1) then
    begin
      if CurrentProgram.search(name2,index) then
             seterr(s_DuplicaltedRoutineName,IDH_FUNCTION) ;

      if kind='M' then
            routine:=TModule.create(name,'M')
      else
            routine:=TProgramUnit.create(name2,kind,maxlen,CurModule);

      if (kind='F') or (kind='D') then
         begin
            Routine.ResultVar:=TIdRec.initpF(name,maxlen);
         end;

      CurrentProgram.add(routine);

    end
  else
    begin
            routine:=TProgramUnit(currentprogram.items[routineindex]);
            inc(routineindex);
    end;
end;

function routineHeadLocal:TLocalProc;
var
   name:AnsiString;
   name2:AnsiString;
   index:integer;
   maxlen:integer;
   kind:char;
begin
  result:=nil;
  kind:=PrevToken[1];
  name:=GetIdentifier;


  name2:=programunit.name+'.'+name;

  maxlen:=maxint;
  MaxlenDeclaration([prevTokenSpec],maxlen);

  if (pass=1) then
    begin
      if CurrentProgram.search(name2,index) then
             seterr(s_DuplicaltedRoutineName,IDH_FUNCTION) ;

      if kind='D' then
         result:=TDEF.create(name2,kind,maxlen)
      else if kind='H' then
         result:=THANDLER.create(name2,kind)
      else
         result:=TLocalProc.create(name2,kind,maxlen);

      CurrentProgram.add(Result);

      if kind in ['F','D'] then
         begin
            result.ResultVar:=TIdRec.initpF(name,maxlen);

            // EXTERNAL FUNCTION宣言をテスト　                         //2007.3.30　
            if ProgramUnit.ExternalVarTable.search2('',name,index)then
                         seterr(name+s_IsDeclaredAsExternalFunction,IDH_FUNCTION);

            with programunit.VarTable do
              if not search(name,index) then
                 add(TIdrec.initF('',name,intern))
              else
                 if TIdRec(items[index]).dim<>-1 then
                         seterr(name+s_DuplicatedVariableName,IDH_FUNCTION)
                 else if TIdRec(items[index]).tag=extern then
                         seterr(name+s_IsDeclaredAsExternalFunction,IDH_FUNCTION)
                 else if TIdRec(items[index]).tag=undeterm then
                         TIdRec(items[index]).tag:=intern;
        end;
    end
  else
    begin
            result:=TLocalProc(currentprogram.items[routineindex]);
            inc(routineindex);
    end;
end;

procedure NoCallBack(Proc:TRoutine);
begin
  seterr('No CallBack available',IDH_DLL)
end;

//var PrepareCallBack: procedure(Proc:TRoutine)= NoCallBack;

procedure TRoutine.MakeParameter;
var
   //paramcount:integer;
   index:integer;
   nam:AnsiString;
   dim:shortint;
begin
  {parameters}
  paramcount:=0;
  if kind in [#0,'F','S','P','D'] then
    if token='(' then
       begin
           gettoken;
           repeat
              inc(paramcount);
             if (kind in ['S','P']) and test('#') then
                  begin
                     if (tokenspec=Nrep)
                         and (pos ('.',token)=0) and (pos ('E',token)=0)
                         and not isZero(@tokenValue) then
                        begin
                           while token[1]='0' do delete(token,1,1);
                           nam:=prevtoken+token;
                           gettoken;
                           if pass=1 then
                             with VarTable do
                               if not search(nam,index) then
                                   add(TIdRec.initpCh(nam))
                               else
                                   seterr(s_DuplicatedParameter+nam,IDH_FUNCTION)  ;
                        end
                       else
                           seterrExpected(s_Integer,IDH_FILE);
                  end
            else
                begin
                 nam:=getidentifier;
                 if test('(') then
                     begin
                        dim:=1;
                        while test(',') do inc(dim);
                        check(')',IDH_FUNCTION);
                        if pass=1 then
                           with VarTable do
                              if not search(nam,index) then
                                    add(TIdRec.initpA(nam,dim))
                              else
                                    seterr(s_DuplicatedParameter+nam,IDH_FUNCTION) ;
                     end
                 else
                     if pass=1 then
                           with VarTable do
                              if not search(nam,index) then
                                 add(TIdRec.initpSimple(nam))
                              else
                                    seterr(s_DuplicatedParameter+nam,IDH_FUNCTION)  ;
               end;
            until test(',')=false;
            check(')',IDH_FUNCTION);
       end;
   //if paramcount>MaxNumberOfParams then seterr('引数の最大個数は'+
   //                               strint(MaxNumberOfParams)+'です',IDH_LIMIT);

   //  NoBeamOff option for Pictures
   {
    if (token=',') and (Kind='P') then
        begin
           gettoken;
           check('NOBEAMOFF',IDH_PICTURE);
           NoBeamOff:=true;
        end;
     }
   if test(',') then
     begin
       case Kind of
       'P':
         begin
          check('NOBEAMOFF',IDH_PICTURE);
          NoBeamOff:=true;
         end;
       'F','S':
         begin
           if token='CALLBACK' then
              begin
                 gettoken;
                 PrepareCallBack(self);
              end
         end;

       end;
      end;
end;

procedure checktoken2(const c:AnsiString; hc:integer);
begin
    if token=c then
        gettoken
    else if OutOfText then
         begin
            if not permitMicrosoft
               and (autocorrect[ac_end]
                      or confirm(c+s_IsExpected+s_ConfirmInsert,hc)) then
               inserttext(c)
            else                     //2022.1.3
               seterrExpected(c,hc)  //2022.1.3
         end
    else
           seterrIllegal(token,hc)
end;

procedure setPrecisionMode(precMode:tpPrecision; initial:boolean);
begin
   if (precisionmode<>precmode) or initial then
   begin
       if ProgramUnit<>MainProgram then
          MixedArithmetic:=not initial or (precisionmode<>precmode);
          
       precisionmode:=precmode;
       KeyWordTablesFreeAll;
       case PrecMode of
            PrecisionNormal:  begin SetOpModeDecimal; SwitchToDecimalMode  end;
            PrecisionHigh:    begin SetOpModeHigh;    SwitchToDecimalMode  end;
            precisionNative:  begin SetOpModeNative;  SwitchToNativeMode   end;
            precisionComplex: begin SetOpModeNative;  SwitchToComplexMode  end;
            PrecisionRational:begin SetOpModeRational;SwitchToRationalMode end;
       end;

       TableInitProcs.call;
   end;
end;

procedure KeyWordTablesFreeAll;
begin
       statementTable.freeall;
       suppliedFunctionTable.freeall;
       reservedwordTable.freeall;
end;

procedure TRoutine.routinebody;
begin
    block:=struct.block(nil);
    if (pass=2)  then
         LabelComplete;
    checktoken2('END',0);
end;

procedure TProgramUnit.routinebody;
begin
    setPrecisionMode(arithmetic, false);
    inherited routinebody ;
    if DataSeq.DataList.count=0 then
       begin
          run:=RunWithNoData;
          //eval:=EvalWithNoData;
       end
     else
       begin
          run:=RunWithData;
          //eval:=EvalWithData;
       end;
    if pass=1 then confirmArithmetic;
end;

procedure TModule.routinebody;
begin
   inherited routinebody;
   //ShareVartable.InitComplete
end;

{*********}
{FUNCTION }
{*********}

function PROCst(prev,eld:TStatement):TStatement;
var
   kind:string[9];
begin
  result:=nil;
  try
     if (LocalRoutine<>nil)
        or (indent>0) and (CurModule=MainProgram)
        or (indent>1)
        then seterrillegal(prevtoken,IDH_FUNCTION) ;
     if (ProgramUnit=CurModule) and (ProgramUnit<>MainProgram) then
        seterr(s_InternalRoutineCanntotbeInProcedure,IDH_MODULE);
     kind:=prevtoken;
     result:=Tstatement.create(prev,eld);
     LocalRoutine:=routineHeadLocal;
     LocalRoutine.MakeParameter;
     nextline;
     if kind[1]='H' then inc(usenest);
     LocalRoutine.routinebody;
     if kind[1]='H' then dec(usenest);
     checkToken(kind,IDH_FUNCTION);
     localroutine:=nil
  except
     result.free;
     raise
  end;
end;

procedure ExtPROCst(insideModule:boolean);
var
   SvProgramUnit:TProgramUnit;
   SvCurModule:TModule;
   kind:string[9];
begin
     kind:=prevtoken;
     SvProgramUnit:=ProgramUnit;
     SvCurModule:=CurModule;

     routineHead(ProgramUnit,insideModule);
     if ProgramUnit is TModule then
        CurModule:=ProgramUnit as TModule;
     ProgramUnit.MakeParameter;
     nextline;
     ProgramUnit.routinebody;

     checkToken(kind,IDH_FUNCTION);
     programunit:=SvProgramUnit;
     CurModule:=SvCurModule;
end;



{**************}
{when-exception}
{**************}
type
     TWhenUse=class(TWhenException)
          handler:THandler;
         constructor create(prev,eld:TStatement);
         function ExecHandler:TStatement;override;
        private
      end;


function WHENst(prev,eld:TStatement):TStatement;
begin
    if usenest>0 then
           seterr(s_ProtectionBlockInsideExceptionHandler,IDH_WHEN_EXCEPTION);

    checktoken('EXCEPTION',IDH_WHEN_EXCEPTION);
    if token='USE' then
       WHENst:=TWhenUse.create(prev,eld)
    else
       WHENst:=TWhenException.create(prev,eld)
end;

function USEst(prev,eld:TStatement):TStatement;
begin
   result:=TTerminal.create(prev,eld)
end;


constructor TWhenException.create(prev,eld:TStatement);
var
   dummy:integer;
begin
    inherited create(prev,eld);
    checkToken('IN',IDH_WHEN_EXCEPTION);
    nextline;
    dummy:=WhenStack.add(self);
    Block:=struct.block(self);
    checktoken1('USE',IDH_WHEN_EXCEPTION);
    nextline;
    inc(USEnest);
    with WhenStack do delete(count-1);
    dummy:=WhenUseStack.add(self);
    UseBlock:=struct.block(nil);     {1997.3.10  goto文で抜けられないように}
    dec(USEnest);
    with WhenUseStack do delete(count-1);
    checktoken1('END',IDH_WHEN_EXCEPTION);
    checktoken1('WHEN',IDH_WHEN_EXCEPTION);
end;

destructor TWhenException.destroy;
begin
   Block.free;
   UseBlock.free;
   inherited destroy;
end;

procedure TWhenException.CollectLabelInfo(t:TLabelNumberTable);
begin
   t.additem(self);
   if Block<>nil then Block.CollectLabelInfo(t);
   if UseBlock<>nil then  UseBlock.CollectLabelInfo(t);
   if next<>nil then next.CollectLabelInfo(t);
end;

function TWhenException.SetBreakPoint(i:integer; b:boolean):boolean;
begin
   if i=lineNumb then
      result:=changeStopKeySence(b)
   else
      result:=(Block<>nil) and Block.setBreakPoint(i,b)
         or (UseBlock<>nil) and UseBlock.SetBreakPoint(i,b)
         or (next<>nil) and next.SetBreakPoint(i,b)
end;

constructor TWhenUse.create(prev,eld:TStatement);
var
   dummy:integer;
   name:AnsiString;
begin
    inherited TStatementcreate(prev,eld);
    checkToken('USE',IDH_WHEN_EXCEPTION);
    name:=GetIdentifier;
    if (pass=2) then
      if CurrentProgram.inquire(name,TRoutine(Handler)) then
         begin
             if handler.kind<>'H' then seterr(name+s_IsNotHandler,IDH_HANDLER);
         end
      else
         seterr('handler '+name+s_IsNotFound,IDH_HANDLER);

    nextline;
    {inc(WHENnest);}
    dummy:=WhenStack.add(self);
    Block:=struct.block(self);
    {dec(WHENnest);}
    with WhenStack do delete(count-1);
    checktoken1('END',IDH_WHEN_EXCEPTION);
    checktoken1('WHEN',IDH_WHEN_EXCEPTION);
end;


{**************}
{END statements}
{**************}
constructor TEXIT.create(prev,eld:TStatement; t:TControlException);
begin
   inherited create(prev,eld);
   typ:=t
end;

var
  ENDline:integer=-1;

function ENDst(prev,eld:TStatement):TStatement;
begin
  if token='' then
    begin
      result:=TStatement.create(prev,eld);
      if indent>0 then
          begin
             //result.free;    1998.10.18
             if autocorrect[ac_end] and
                  confirm(s_ConfirmEndToStop,IDH_END) then
                begin
                   ReplacePrevToken('STOP');
                   result.free;    //1998.10.18
                   raise ERecompile.create('');
                end
          end
       else
          ENDline:=linenumber
    end
  else if (token='IF') or (token='SELECT')  or
       ((token='WHEN') and (eld<>nil) and (eld.previous is TWhenUse)) then
    begin
      result:=TTerminal.create(prev,eld);
      ENDline:=-1;
    end
  else
    begin
      result:=TStatement.create(prev,eld);
      ENDline:=-1;
    end;
end;

function ENDTABst(prev,eld:TStatement):TStatement;
begin
   if permitMicrosoft then
      begin
         result:=STOPst(prev,eld);
         if pass=2 then
                   replacePrevtoken('END');
      end
   else
       begin
          replacePrevtoken('END');
          ENDTABst:=ENDst(prev,eld);
       end;
end;


{*******}
{compile}
{*******}
var
   confirmedDATAst:boolean=false;

procedure ExternalProcedures;
var
    s:ansistring;
begin
   if token='MODULE' then
      begin
          gettoken;
          ExtPROCst(false);
      end
   else
      begin
          if pass=2 then
                checktoken1('EXTERNAL',IDH_FUNCTION)
           else if token='EXTERNAL' then
                gettoken;

           if (token='FUNCTION') or (token='SUB') or (TOKEN='PICTURE') then
              begin
                 if (pass=1) and (prevtoken<>'EXTERNAL') and
                   confirm('EXTERNAL'+s_IsExpected+s_InquireInsert,
                                                  IDH_EXTERNAL_FUNCTION) then
                      inserttext('EXTERNAL ');

                 gettoken;
                 ExtPROCst(false);
              end
           else if (Token='END') and (nexttoken='')          //2018.09.05
                and (LineNumber=MemoLineCount-1)  then
              begin
                replacetoken('') ;
                GetToken;
              end
           else if permitMicrosoft and (ENDLine>0)  then
             begin
                  s:=texthand.GetMemoLine(ENDline);
                  insert(#9,s,pos('END',uppercase(s))+3);
                  texthand.setmemoLine(ENDline,s);
                 raise ERecompile.create('');
             end
           else if (token='DATA') and (ENDline>0)
                and (confirmedDATAst or confirm(s_ConfirmMoveDataLIne,IDH_END)) then
              begin
               //with texthand do
                   begin
                      s:=getMemoLine(ENDline);
                      deleteMemoLine(ENDline);
                      insertMemoLine(linenumber,s);
                   end;
               confirmedDATAst:=true;
               raise ERECompile.create('');
              end
          else if prevtoken<>'EXTERNAL' then
             if (ENDline>0) and (labelNumber>0)
                  and autocorrect[ac_end]
                  and confirm(s_ConfirmEndToStop2,IDH_END) then
               begin
                  s:=texthand.getMemoline(ENDline);
                  insert('STOP !',s,pos('END',uppercase(s)));
                  texthand.setMemoLine(ENDline,s);
                 raise ERecompile.create('');
               end;
          end;
end;

procedure compile;
begin
  {main}
     routineindex:=0;
     linenumber:=-1;
     labelnumber:=0;
     RecentLabelNumber:=0;
     trying:=0;
     initline;
     CurModule:=nil;
     programunit:=nil;
     localroutine:=nil;
     MainProgram:=routineHeadMain;
     CurModule:=MainProgram ;
     programunit:=MainProgram;
     nextline;
     MainProgram.routinebody;
     ProgramUnit:=nil;

  {external procedures}
     repeat
        labelnumber:=0;
        RecentLabelNumber:=0;
        NextLineGlobal;
        if token='' then break;
        while token='REM' do
           begin skip; NextLineGlobal; end;
        while token='MERGE' do
           begin MergeFile; NextLineGlobal; end;
        ExternalProcedures;
     until false;

end;

{******************}
{Control Exceptions}
{******************}
constructor EControlException.create;
begin
   inherited create('')
end;

constructor EExitHandler.create(when1:TWhenException);
begin
  inherited create;
  When:=when1;
end;

constructor EExitdo.create(St:TStatement);
begin
  inherited create;
  NextSt:=st
end;

{
constructor EGoto.create(prefect1,statement1:TStatement);
begin
   inherited create;
   GotoTag.prefect:=prefect1;
   GotoTag.statement:=statement1;
end;
}
{*********}
{GOTO }
{*********}

constructor TGOTO.create(prev,eld:TStatement);
var
    long:longint;
    dummy:integer;
    routine:TRoutine;
begin
    inherited create(prev,eld);
    if nonnegativeintegralnumber(long) and (long>0) then
         numb:=long
    else
          seterrexpected(s_LineNumber,IDH_JIS_8);
    if pass=2 then
       begin
          routine:=localroutine;
          if routine=nil then routine:=programunit;
          dummy:=routine.GotoList.add(self);
       end;
end;


{********}
{EXTERNAL}
{********}
function EXTERNALst(prev,eld:TStatement):TStatement;
begin
   if (ProgramUnit<>nil) and ((ProgramUnit=MainProgram)or not (ProgramUnit is TModule)) then
           seterrIllegal(PrevToken,IDH_FUNCTION);

   EXTERNALst:=nil;
   if (token='FUNCTION') or (token='SUB') or (TOKEN='PICTURE') then
     begin
        gettoken;
        ExtPROCst(true);
     end
end;

{****************}
{EXECUTE ROUTINES}
{****************}
procedure TIdTable.popStack;
var
   i:integer;
begin
   for i:=count-1 downto 0 do
       TIdRec(items[i]).popStack
end;

procedure TIdTable.PushStack;
var
   i:integer;
begin
   for i:=0 to count-1 do
           TIdRec(items[i]).pushStack;
end;

procedure TIdTable.getVar;
var
i:integer;
begin
   for i:=0 to count -1 do
      with TIdrec(items[i]) do
         if (dim>=0) xor prm then getVar;
end;

procedure TIdTable.FreeVar;
var
  i:integer;
begin
  for i:=count -1 downto 0  do
     with TIdRec(items[i]) do
        if (dim>=0) xor prm then freeVar;
end;        

function TIdTable.channelsub(ch:integer; CanInsert:boolean):PTextDevice;
var
   name:AnsiString;
   index:integer;
   idrec:TIdrec;
begin
   channelsub:=nil;

   if ch<0 then exit;                                  //2008.11.3
   if ch=0 then begin channelsub:=PConsole; exit end;  //2008.11.3

   name:='#'+strint(ch);
   if search(name,index)then
      channelsub:=TIdRec(items[index]).subs.ptr as PTextDevice
   else if CanInsert then
     begin
      idrec:=Tidrec.initCh('',name,intern);
      idRec.pushStack;
      idRec.getVar;
      insert(index,idrec);
      ChannelSub:=idrec.subs.ptr as Ptextdevice;
    end;
end;

function TProgramUnit.channelsub(ch:integer ;CanInsert:boolean):PTextDevice;
var
   ptext:PTextDevice;
begin
    ptext:=VarTable.channelsub(ch,false);
    if (ptext=nil) and (parent<>nil) then
        ptext:=parent.ShareVarTable.channelsub(ch,false);
    if (ptext=nil) and CanInsert then
        ptext:=VarTable.ChannelSub(ch,true);
    channelsub:=ptext;
end;

function TProgramUnit.channel(ch:integer):TTextDevice;
var
   ptext:PTextDevice;
begin
    if ch=0 then
       channel:=console
    else
       begin
            ptext:=channelsub(ch,true);
            if (ptext<>nil) and (ptext.ttext<>nil) then
               channel:=ptext.ttext
            else
               channel:=nil
       end;
end;

procedure TProgramUnit.openPrinter(ch:integer);
var
   ptext:PTextDevice;
begin
   if ch<>0 then
      begin
         ptext:=channelsub(ch,true);
         if (ptext<>nil) and  (ptext.ttext<>nil) then
             setexception(7003)
         else if (ptext<>nil) then
            if  LocalPrinter.isopen then
                setexception(9004)
            else
            begin
              ptext.ttext:=LocalPrinter;
              ptext.ttext.open('',amOutput,orgSEQ,maxint)
            end;
      end;
end;

procedure TProgramUnit.open(ch:integer;const FName:FNameStr; am:AccessMode;
                           rc:Recordtype; og:OrganizationType; len:integer);
var
   ptext:PTextDevice;
begin
   if ch<>0 then
      begin
         ptext:=channelsub(ch,true);
         if (ptext<>nil) and  (ptext.ttext<>nil) then
             setexception(7003)
         else if (ptext<>nil) then
            with ptext do
            begin
               if rc=rcDisplay then
                   ttext:=TTextFile.create
               else if rc=rcInternal then
                   ttext:=TInternalFile.create
               else
                   ttext:=TCSVfile.create;

               ttext.open(Fname,am,og,len);
            end
      end;
end;

procedure TProgramUnit.close(ch:integer);
var
   ptext:PTextDevice;
begin
   if ch<>0 then
      begin
         ptext:=channelsub(ch,false);
         if (ptext<>nil) and (ptext.ttext<>nil) then
           with ptext do
           begin
             ttext.close;
             if not (ttext is TLocalPrinter) then
                ttext.free;
             ttext:=nil;
           end
      end;
end;


function ExtypeOf(p:pointer):integer;
begin
  if (p>@TDIV.evalF) and (p<@TADD.evalF) then
    result:=3001
  else if (p>@LongIntRound) and (p<@opposite) then
       result:=2001
  else
       result:=3000;
end;

procedure TStatement.stopkeysence0;
begin
   if BreakFlags.LongFlag then
      begin
          trace;
          if  CtrlBreakHit then
              inspectbox(self)
      end;
end;

procedure TStatement.stopkeysence1;
begin
   //IdleImmediately;
   stopkeySence0;
end;

procedure TStatement.BreakPoint;
begin
  trace;

  inspectbox(self) ;


end;
{
procedure TStatement.run;
begin
  if self=nil then exit;
  stopkeysence;
  CurrentStatement:=self;
  exec;
  next.run;
end;
}
procedure TStatement.SequentiallyExecute;
begin
  if self<>nil then
  begin
    exec;
    next.SequentiallyExecute;
  end;
end;

procedure TStatement.exec;
begin
  {do nothing}
end;



function TStatement.ExceptionHandle:boolean;
var
  When1:TWhenException;
begin
    result:=false;
    When1:=WhenBlock;
    While (result=false) and (When1<>nil) do
    begin
        try
            result:=When1.RunHandler(self)
        except
           on ERetry do
              begin
                NextStatement:=self;
                result:=true
              end ;
           on EContinue do
              begin
                 NextStatement:=ExecutiveNext;
                 result:=true
              end ;
           on E1:EExitHandler do when1:=E1.When.WhenBlock;
        end;
     end;
end;

{
function TStatement.ConstructiveNext: TStatement;
begin
   result:=next
end;
}
procedure TStatement.Trace;
begin
   with BreakFlags do
     if (TraceChannelPlus1>0)or TraceMode then
       TraceReport;
end;

procedure TSTatement.TraceReport;
var
   ch:TTextDevice;
   NewList:TTraceList;
   i:integer;
   s1,s2:string;
   procedure AppendStr(const s:String; c:TColor );
   begin
      if BreakFlags.TraceMode then
         TraceForm.Drop(s+EOL);
       {
       with TraceForm.Memo1 do
         begin
           Lines.BeginUpdate;
           with Lines do text:=text + s + EOL;
           Lines.EndUpdate;
           SelStart:=Length(text);
         end;
       }
      if ch<>nil then
         begin
           ch.appendStr(s);
           ch.NewLine;
         end;
   end;
begin
   if PUnit=nil then exit;
   WaitReady;               //2025.05.25  //ver.0.8.4.1
   //IdleImmediately;

   ch:=nil;
   if BreakFlags.TraceChannelPlus1>0 then
      ch:=PUnit.channel( BreakFlags.TraceChannelPlus1 - 1 );

   NewList:=TTraceList.create;
   if PUnit.TraceList<>nil then
      NewList.Capacity:=PUnit.TraceList.Capacity;
   if Punit is TModule then
      NewList.merge(TModule(PUnit).SharevarTable);
   if (PUnit.parent<>nil) and (PUnit.parent is TModule) then
      NewList.merge(Tmodule(Punit.parent).ShareVarTable);
   NewList.merge(PUnit.VarTable);
   if (proc<>nil) and (proc<>PUnit) then
      NewList.merge(Proc.VarTable);
   With NewList do Capacity:=Count;

   if Punit.TraceList<>nil then
      begin
        for i:=0 to NewList.count-1 do
          begin
            s1:=NewList.Strings[i];
            s2:=(NewList.Objects[i] as TStringObject).str;
            if s2<>Punit.TraceList.GetString(s1) then
               AppendStr(s1+'='+s2,clBlue);
            //Idle;
           end;
        PUnit.TraceList.free;
      end;
   PUnit.TraceList:=NewList;

   AppendStr(texthand.getMemoLine(linenumb),clBlack);

end;

function TStatement.insideofwhen:LongBool;
begin
   insideofWhen:=LongBool(WhenBlock)
end;

procedure ExecNonFatalException;
var
   svbkDirective:Longint;
   //svBreakFlags:TBreakFlags;
begin
   //svBreakFlags:=BreakFlags;
   svbkDirective:= bkDirective;
   bkDirective:=BkContinue;
   inspectBox(CurrentStatement);
   NonFatalExRaised:=false;
   bkDirective:=svbkDirective;
   //BreakFlags:=svBreakFlags;
end;


function RunBlock(statement:TStatement):TStatement;
begin
   result:=nil;
   NextStatement:=statement;
   while NextStatement<>nil do
   try
      while NextStatement<>nil do
      begin
        CurrentStatement:=NextStatement;
        with CurrentStatement do
          begin
            NextStatement:=next;
            stopkeysence;
            exec;
          end;

        //if NonFatalExRaised then         ver. 8.1.1.2で廃止（復活も可）
        //   ExecNonFatalException;
      end;
   except
       on E:EControlException do
          begin
             if (E is EReturn) then
                  begin
                    exline:=CurrentStatement.lineNumb;
                    SetException(10002);
                  end
             else if (E is EExitDo) then
                  begin
                     NextStatement:=nil; // RunBlockを抜ける
                     Result:=EExitDo(E).NextSt
                  end
             else
                 raise;                // 例外を再生成
          end;
       on E:Exception do
          begin
              //{$IFNDEF Windows}      // Windowsでも必要な模様（詳細不明）
             if (E is EMathError) or (E is EDivByZero) then
                begin
                   ClearExceptions(False);
                   SetFPUMask(controlword);
                end;
               //{$ENDIF}
             if E is EOverflow then
               if CurrentOperation<>nil then
                    extype:=CurrentOperation.OverflowErCode
               else
                    extype:=1002
            else if E is EMathError then
               begin
                 if CurrentOperation<>nil then
                     extype:=CurrentOperation.InvalidErCode
                 else if E is EOverflow then
                       extype:=1002
                 else if E is EZeroDivide then
                       extype:=3001
                 else
                      extype:=ExtypeOf(ExceptAddr);
               end
            else if E is EExtype then
               begin
                if CurrentOperation<>nil then
                   if extype=1002 then
                      extype:=CurrentOperation.OverflowErCode
                   else if extype=3001 then
                      extype:=CurrentOperation.InvalidErCode;
               end
            else
               if E is EdivByZero then
                  if CurrentOperation<>nil then
                       extype:=CurrentOperation.InvalidErCode
                   else
                       extype:=3001
            else
                raise ;

            if CurrentOperation<>nil then
               begin
                  statusMes.add(CurrentOperation.OpName);
                  CurrentOperation:=nil;
               end;

            if CurrentStatement.InsideOfWhen
               and currentStatement.ExceptionHandle then
            else
            begin
               if extype<100000 then
                  begin
                    exline:=CurrentStatement.lineNumb;
                    if DebugDlg.listpointer<0 then
                         SetDebugDlg(CurrentStatement);
                  end;
               if (E is EMathError) or (E is EdivByZero)  then
                 begin
                      raise EExtype.create('')
                 end
               else
                 raise
            end;
          end;
   end;


end;

procedure DoNothing;
begin
end;


procedure TRoutine.RunNaive(params:TObjectList; DoAfter:TypeProcedure );
var
  v:TVar;
  i,j:integer;
  exsize:integer;
  VarArray:PVarArray;
  svCurrentStatement,svNextStatement:TStatement;
begin
  if stacksize1>=StackLimit1 then
                        setexception(stackoverflow);
  //idle;

//  paramscount:=params.count;

  i:=paramcount*sizeof(Pointer);
 {$IFDEF CPU32}
  {$IFNDEF Darwin}
  asm
     sub esp,i
     mov VarArray,esp
  end;
  {$ELSE}
  GetMem(VarArray,i);
  {$ENDIF}
 {$ELSE}
  GetMem(VarArray,i);
 {$ENDIF}


  for j:=0 to paramcount - 1 do
     begin
       //  VarArray^[j]:=TArticle(params.items[j]).substance0(ByVal);
       //  VarArray^[j].Roundvari;          //2012.2.28
       v:=TArticle(params.items[j]).substance0(ByVal);
       v.Roundvari;
       VarArray^[j]:=v;
     end;

  exsize:=VarTable.count;
  VarTable.PushStack;
  for j:=0 to paramcount - 1 do
     TIdrec(VarTable.items[j]).subs.ptr:=VarArray[j];
  for j:=paramcount to VarTable.count-1 do
     TIdrec(VarTable.items[j]).GetVar;

  i:=paramcount*sizeof(Pointer);
 {$IFDEF CPU32}
  {$IFNDEF Darwin}
  asm
     add esp,i
  end;
  {$ELSE}
  FreeMem(VarArray,i);
  {$ENDIF}
 {$ELSE}
  FreeMem(VarArray,i);
 {$ENDIF}


  svCurrentStatement:=CurrentStatement;
  svNextStatement:=NextStatement;
  if @DoAfter<>@DoNothing then
                       DoBefore;
  try
        runBlock(block)
  finally
     DoAfter;
     CurrentStatement:=svCurrentStatement;
     NextStatement:=svNextStatement;

     for j:=VarTable.count -1 downto paramcount do
        TIdrec(VarTable.items[j]).FreeVar;
     for j:=paramcount - 1  downto 0 do
        TArticle(params.items[j]).disposesubstance0(TIdRec(VarTable.items[j]).subs.ptr, ByVal);
     VarTable.popStack;
     VarTable.Count:=exsize;   //2013.5.23 副プログラム内でファイルをOPEN CLOSEするとエラーになるバグを修正
     propagateException;
  end;

end;

procedure TRoutine.RunOrdinary(params:TObjectList; DoAfter:TypeProcedure);
begin
  try
     RunNaive(Params,DoAfter);
  except
     On E:EControlException do
       if    (kind='F') and (E is EExitFunction)
          or (kind='S') and (E is EExitSub)
          or (kind='P') and (E is EExitPicture)
       then
       else
          raise
  end;
end;


procedure propagateException;
begin
    if (extype>0) and (extype<100000) then
       inc(extype,100000)
    else if (extype<0) and (extype>-100000) then
       inc(extype,-100000)   ;
end;

function TRoutine.NoEffect:boolean;
begin
    NoEffect:=true;
end;

procedure TProgramUnit.runWithNoData(params:TObjectList; DoAfter:TypeProcedure);
var
  SvTraceChannel:word;
begin
   SvTraceChannel:=BreakFlags.TraceChannelPlus1;
   BreakFlags.TraceChannelPlus1:=0;
   try
     RunOrdinary(params,DoAfter);
   finally
     BreakFlags.TraceChannelPlus1:=SvTraceChannel;
   end;
end;
{
procedure TProgramUnit.evalWithNoData(params:TObjectList; DoAfter:TypeProcedure);
var
  SvTraceChannel:word;
begin
   SvTraceChannel:=BreakFlags.TraceChannelPlus1;
   BreakFlags.TraceChannelPlus1:=0;
   evalOrdinary(params,DoAfter);
   BreakFlags.TraceChannelPlus1:=SvTraceChannel;
end;
}
procedure TProgramUnit.runWithData(params:TObjectList; DoAfter:TypeProcedure);
begin
   DataSeq.pushDataPointer;
   try
     runWithNoData(params,DoAfter);
   finally
     DataSeq.popDataPointer;
   end;
end;

procedure THandler.run(p:TWhenException);
var
  svCurrentStatement,svNextStatement:TStatement;
begin
  if stacksize1>=StackLimit1 then
                 setexception(stackoverflow);
  //idle;

  WhenUseBlockStack.add(p);
  svCurrentStatement:=CurrentStatement;
  svNextStatement:=NextStatement;
  try
      runBlock(block);
  finally
     CurrentStatement:=svCurrentStatement;
     NextStatement:=svNextStatement;
     with  WhenUseBlockStack do delete(count-1);
  end;
end;

procedure TEXIT.exec;
begin
    //idle;
    raise typ.create;
end;

function TStatement.ExecutiveNext:TStatement;
var
  p:Tstatement;
begin
   p:=self;
   while p.next=nil do
   begin
      p:=p.eldest.previous;
   end;
   result:=p.next
end;


procedure TTerminal.exec;
begin
  if Statement=nil then
    NextStatement:=ExecutiveNext
  else
    NextStatement:=Statement.next
end;

procedure TWhenException.exec;
begin
    NextStatement:=Block;
end;

function TWhenException.RunHandler(StatementEx:TStatement):boolean;
begin
      result:=false;
      svextype:=extype;
      svStatementEX:=StatementEX;
      extype:=0;
      statusmes.Clear;              //2006.1.15 
      nextStatement:=execHandler;
      if NextStatement=nil then
         nextStatement:=next;
      result:=true;
end;

function TWhenException.ExecHandler:TStatement;
begin
   result:=RunBlock(UseBlock);
end;

function TWhenUse.ExecHandler:TStatement;
begin
   if (handler<>nil) then handler.Run(self);
   result:=nil;
end;

procedure TGOTO.exec;
begin
   //idle;
   NextStatement:=statement;
end;


{***************}
{TProcsCollection}
{***************}
procedure TProcsCollection.accept(f:proc);
begin
    insert(@f)
end;

procedure TProcsCollection.call;
var
   i:integer;
   f:proc;
begin
   for i:=0 to count-1 do  begin  @f:=items[i]; f end
end;


procedure TProcsCollection.freeItem(item:pointer);
begin
   { do nothing}
end;





{***********}
{initializer}
{***********}


procedure statementtableInitDeclative(n:string10 ; f:StatementFunction);
begin
       statementtable.accept(n,declative,f)
end;

procedure statementtableInitImperative(n:string10 ; f:StatementFunction);
begin
       statementtable.accept(n,imperative,f)
end;

procedure statementtableInitStructural(n:string10 ; f:StatementFunction);
begin
       statementtable.accept(n,structural,f)
end;

procedure statementtableInitTerminal(n:string10 ; f:StatementFunction);
begin
       statementtable.accept(n,terminal,f)
end;

procedure statementtableInitSingular(n:string10 ; f:StatementFunction);
begin
       statementtable.accept(n,singular,f)
end;

procedure  SuppliedFunctionTableInit(n:string11; f:simplefunction);
begin
       SuppliedFunctionTable.accept(n,f)
end;

procedure  reservedWordTableInit(n:string11; f:simplefunction);
begin
       reservedWordTable.accept(n,f)
end;

{**********}
{Initialize}
{**********}

procedure statementTableinit;
begin
  StatementTableInitStructural('EXTERNAL',EXTERNALst);
  statementtableInitStructural('FUNCTION',PROCst);
  statementtableInitStructural('SUB',PROCst);
  statementtableInitStructural('PICTURE',PROCst);
  statementtableInitStructural('HANDLER',PROCst);
  statementtableInitTerminal('END',ENDst);
  statementTableinitImperative('END'#9,ENDTABst);
  statementTableinitStructural('WHEN',WHENst);
  statementtableInitTerminal('USE',USEst);
end;



initialization
stack:=TStack.create(4096);
//stack.capacity:=4096;

currentprogram:=TProctbl.create(4);

statementTable:=TprcSelection.create;
statementTable.capacity:=96;
if TableInitProcs=nil then
   TableInitProcs:=TProcsCollection.create;  //97.10.12 初期化順に疑念発生，express.pasに移動
TableInitProcs.accept(statementtableinit);

DummyParameter:=TObjectList.create(0);

finalization
TableInitProcs.free;
Dummyparameter.free;
statementTable.free;
currentprogram.free;
stack.free;
end.



