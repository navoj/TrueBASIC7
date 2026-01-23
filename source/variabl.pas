unit variabl;
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
uses SysUtils,Classes,LCLProc,
     base,arithmet,rational;


type
    Complex=record
      x:double ;
      y:double ;
    end;

    PComplex=^Complex;

type
    TMyObject=class(TObject)
         function OverflowErCode:integer;virtual;
         function InvalidErCode:integer;virtual;
         function OpName:string;virtual;
    end;

type
    TVar=Class;

    TArticle=class(TMyObject)
         function substance0(ByVal:boolean):TVar;virtual; abstract;
         procedure disposesubstance0(p:TVar; ByVar:Boolean);virtual;abstract;
         function substance1:TVar;virtual; abstract;
         procedure disposesubstance1(p:TVar);virtual;abstract;
    end;

   TPrincipal=Class(TArticle)
         procedure evalN(var n:number);virtual;abstract;
         function evalX:extended;virtual;
         function evalF:double;virtual;                 //evalFは2進モード専用
         procedure evalC(var c:complex);virtual;
         procedure evalR(var r:PNumeric);virtual;abstract;
         function evalS:ansistring;virtual;abstract;
         function evalBool:boolean;virtual;abstract;
         function evalInteger:integer;virtual;abstract;  //桁あふれはmaxint
         function evalLongint:longint;virtual;abstract;  //桁あふれはEInvalidOp
         function str:ansistring;virtual;abstract;
         function str2:ansistring;virtual;abstract;
         function format(const form:ansiString; var index,code:integer):ansistring;
         function kind:char;virtual;abstract;
         function isConstant:boolean;virtual;
         function compare(exp:TPrincipal):integer;virtual;abstract;

    end;


  TVariable=class(TPrincipal)
           function sign:integer;virtual;abstract;
           procedure substS(const s:ansistring);virtual;abstract;
           procedure substOne;virtual;abstract;
           procedure assign(exp:TPrincipal);virtual;abstract;
           procedure assignwithNoRound(exp:TPrincipal);virtual;abstract;
           procedure assignX(x:extended); virtual;abstract;
           procedure assignLongint(i:longint); virtual;abstract;
        end;

   TPointingVariable=class(TVariable)
           function point:TVar;virtual;abstract;

           procedure evalN(var n:number);override;
           function evalX:extended;override;
           function evalF:double;override;
           procedure evalC(var c:complex);override;
           procedure evalR(var r:PNumeric);override;
           function evalS:ansistring;override;
           function evalInteger:integer;override;  //桁あふれはmaxint
           function evalLongint:longint;override;  //桁あふれはEInvalidOp
           function str:ansistring;override;
           function str2:ansistring;override;
           function compare(exp:TPrincipal):integer;override;

           function substance0(ByVal:boolean):TVar;override;
           procedure disposesubstance0(p:TVar; ByVal:boolean);override;
           function substance1:TVar;override;
           procedure disposesubstance1(p:TVar);override;

           procedure substS(const s:ansistring);override;
           procedure substOne;override;
           procedure assign(exp:TPrincipal);override;
           procedure assignwithNoRound(exp:TPrincipal);override;
           procedure assignX(x:extended);override;
           procedure assignLongint(i:longint);override;
   end;

   TidRec=class;
   TSubstance=class;

   ObjectProcedure = procedure of Object;
{******}
{TIdRec}
{******}

   TIdTag=(undeterm,intern,extern,IdShare,IdPublic);
   TIdRec = class(TObject)
                  subs     :TSubstance;
                  ModuleName:AnsiString;
                  name     :AnsiString;
                  prm      :boolean;   { parameter }
                  dim      :shortint;  { -1 for function, 0 for simple var}
                  kindchar :char ;     {'n' for numeric ,'s' for string, 'c' for channel}
                  tag      :TIdTag;
                  lbound,ubound:Array4;   {default dimension}
                  maxlen   :integer;
     procedure InitComplete(arith:tpPrecision);
     constructor InitSimple(const nam:AnsiString; t:TIdTag; maxlen1:integer);
     constructor InitpSimple(const nam:AnsiString);
     constructor InitF(const mnam,nam:AnsiString; t:TIdTag);
     constructor InitpF(const nam:AnsiString; maxlen1:integer);
     constructor InitA(const nam:AnsiString; d:shortint; t:TIdTag);
     constructor InitpA(const nam:AnsiString; d:shortint);
     constructor InitArray(const nam:AnsiString; d:shortint;const  lb,ub:Array4; t:TIdTag; m:integer);
     constructor InitpArray(const nam:AnsiString; d:shortint;const  lb,ub:Array4);
     constructor InitCh(const mnam,nam:AnsiString; t:TIdTag);
     constructor InitpCh(const nam:AnsiString);
     constructor InitSimpleExt(const mnam,nam:AnsiString);
     constructor InitAExt(const mnam,nam:AnsiString; d:shortint);
     destructor destroy;override;

     procedure setdim(const lb,ub:Array4);
     procedure setdim1(d:shortint);

     procedure pushstack;
     procedure popstack;
     procedure getvar;
     procedure freeVar;
    private
     procedure Init(const nam:AnsiString; p:boolean; d:shortint; t:TIdTag);
   end;


   TSubstance=class(TPointingVariable)
        ptr:   TVar;
        idr:   TIdrec;
        GetVar:ObjectProcedure;
       procedure getVar1;
       procedure getvar2;virtual;abstract;
       procedure freevar;
       procedure PushStack;
       procedure PopStack;
       constructor create(idr0:TIdRec; kindchar:char; dim:shortint; prm:boolean);
       function kind:char;override;
       function isConstant:boolean;override;
       function DebugStr:string;                                //ver.8.1.3.1
       procedure add(p:TSubstance);virtual;abstract;

       function point:TVar;override;
       function substance0(ByVal:boolean):TVar;override;
       procedure disposesubstance0(p:TVar; ByVal:boolean);override;
       function substance1:TVar;override;
       procedure disposesubstance1(p:TVar);override;

       procedure freeInstance;override;
       procedure FreeAnyway;
      private
       procedure getNone;
    end;

   TNVari=class(Tsubstance)
       procedure getVar2; override;
       procedure evalN(var n:number);override;
       function evalInteger:integer;override;  //桁あふれはmaxint
       function evalLongint:longint;override;  //桁あふれはEInvalidOp
       function str:ansistring;override;
       function str2:ansistring;override;
       function compare(exp:TPrincipal):integer;override;

       function sign:integer;override;
       procedure add(p:TSubstance);override;

       procedure substOne;override;
       procedure assign(exp:TPrincipal);override;
       procedure assignwithNoRound(exp:TPrincipal);override;
       procedure assignX(x:extended);override;
       procedure assignLongint(i:longint);override;
   end;

  TFVari=class(Tsubstance)
       procedure getVar2; override;
       function evalX:extended;  override;
       function evalF:double; override;
       function evalInteger:integer;override;  //桁あふれはmaxint
       function evalLongint:longint;override;  //桁あふれはEInvalidOp
       function str:ansistring;override;
       function str2:ansistring;override;
       function compare(exp:TPrincipal):integer;override;

       function sign:integer;override;
       procedure add(p:TSubstance);override;

       procedure substOne;override;
       procedure assign(exp:TPrincipal);override;
       procedure assignwithNoRound(exp:TPrincipal);override;
       procedure assignX(x:extended);override;
       procedure assignLongint(i:longint);override;
   end;

   TorthoFVari=class(TFVari)
       function evalX:extended;  override;
       function evalF:double; override;
       function evalInteger:integer;override;  //桁あふれはmaxint
       function evalLongint:longint;override;  //桁あふれはEInvalidOp
       function compare(exp:TPrincipal):integer;override;
       function sign:integer;override;
       procedure add(p:TSubstance);override;
       procedure substOne;override;
       procedure assign(exp:TPrincipal);override;
       procedure assignwithNoRound(exp:TPrincipal);override;
       procedure assignX(x:extended);override;
       procedure assignLongint(i:longint);override;
   end;

   TCVari=class(Tsubstance)
       procedure getVar2; override;
       function evalX:extended;  override;
       procedure evalC(var c:complex);override;
       function evalInteger:integer;override;  //桁あふれはmaxint
       function evalLongint:longint;override;  //桁あふれはEInvalidOp
       function str:ansistring;override;
       function str2:ansistring;override;
       function compare(exp:TPrincipal):integer;override;

       function sign:integer;override;
       procedure add(p:TSubstance);override;

       procedure substOne;override;
       procedure assign(exp:TPrincipal);override;
       procedure assignwithNoRound(exp:TPrincipal);override;
       procedure assignX(x:extended);override;
       procedure assignLongint(i:longint);override;
   end;

   TRVari=class(Tsubstance)
       procedure getVar2; override;
       function evalX:extended;override;
       procedure evalR(var r:PNumeric);override;
       function evalInteger:integer;override;  //桁あふれはmaxint
       function evalLongint:longint;override;  //桁あふれはEInvalidOp
       function str:ansistring;override;
       function str2:ansistring;override;
       function compare(exp:TPrincipal):integer;override;

       function sign:integer;override;
       procedure add(p:TSubstance);override;

       procedure substOne;override;
       procedure assign(exp:TPrincipal);override;
       procedure assignwithNoRound(exp:TPrincipal);override;
       procedure assignX(x:extended);override;
       procedure assignLongint(i:longint);override;
   end;

   TSVari=class(Tsubstance)
       procedure getVar2; override;
       function evalS:ansistring;override;
       function str:ansistring;override;
       function str2:ansistring;override;
       function compare(exp:TPrincipal):integer;override;

       procedure substS(const s:ansistring);override;
       procedure assign(exp:TPrincipal);override;
       procedure assignwithNoRound(exp:TPrincipal);override;
   end;


   TNAVari=class(TNVari)
       procedure getVar2; override;
   end;

   TFAVari=class(TFVari)
       procedure getVar2; override;
   end;

   TCAVari=class(TCVari)
       procedure getVar2; override;
   end;

   TRAVari=class(TRVari)
       procedure getVar2; override;
   end;

   TSAVari=class(TSVari)
       procedure getVar2; override;
   end;

   TChVari=class(Tsubstance)
       procedure getVar2; override;
   end;


   Tvar=class(TObject)
     public
        //procedure substN(var n:number);virtual; abstract;
        procedure substS(const s:ansistring);virtual; abstract;
        procedure substZero;virtual;
        procedure substOne;virtual; abstract;
        procedure copyfrom(p:TVar);virtual;abstract;
        procedure assign(exp:TPrincipal);
        procedure assignwithRound(exp:TPrincipal);virtual;
        procedure assignwithNoRound(exp:TPrincipal);virtual;abstract;
        procedure assignX(x:extended);virtual;abstract;
        //function assignF(x:double):boolean;virtual;abstract;
        procedure assignLongInt(i:longint);virtual;abstract;
        //procedure getN(var n:number);virtual; abstract;
        procedure getX(var x:extended);virtual;abstract;
        //procedure getF(var x:double);virtual;abstract;
        function  getS:ansistring;virtual; abstract;
        //procedure getC(var c:complex);virtual; abstract;
        //procedure getR(var r:PNumeric);virtual;abstract;
        function EvalInteger:Integer;virtual;abstract;
        function EvalLongint:longint;virtual;abstract;
        procedure swap(p:TVar);virtual;abstract;
        procedure read(const s:ansiString);virtual;abstract;
        procedure readData(const s:ansiString);virtual;
        function readDataV2(const s:ansiString; q,i:boolean):boolean;virtual;
        function str:ansiString;virtual;
        function str2:ansiString;virtual;abstract;
        function DebugStr:string;virtual;                                  //ver.8.1.3.1
        function format(const form:ansiString; var index,code:integer):ansistring;virtual;abstract;
        function NewElement:TVar;virtual;abstract;
        function newcopy:TVar;virtual;abstract;
        procedure add(p:TVar);virtual;abstract;
        procedure multiply(p:TVar);virtual;abstract;
        procedure addwithNoRound(p:TVar);virtual;abstract;
        procedure multiplyWithNoRound(p:TVar);virtual;abstract;
        procedure subtract(p:TVar);virtual;abstract;
        function compare(p:TVar):integer;virtual;abstract;
        function compareP(exp:TPrincipal):integer;virtual;abstract;
        function sign:integer;virtual;abstract;
        procedure Roundvari;virtual;
     end;

   TAutoVar=Class(TVar)
        class function NewInstance: TObject;override;
        procedure FreeInstance;override;
   end;


var OnIdTableFree:Boolean=false;

{*******************}
{ TObjectList class }
{*******************}
const
  MaxListSize = (Maxint div 16)+1;

type
  PObjectArray = ^TObjectArray;
  TObjectArray = array[0..MaxListSize - 1] of TObject;

  TObjectList = class(TObject)
  private
    FList: PObjectArray;
    FCount: Integer;
    FCapacity: Integer;
    function Get(Index: Integer): TObject;
    procedure Grow;
    procedure Put(Index: Integer; Item: TObject);
    procedure SetCapacity(NewCapacity: Integer);
    procedure SetCount(NewCount: Integer);
    procedure Clear;
    function Expand: TObjectList;
  public
    constructor create(IniSize:integer);
    destructor Destroy; override;
    function Add(Item: TObject): Integer;
    procedure Insert(Index: Integer; Item: TObject);
    procedure Delete(Index: Integer);
    procedure deleteall;
    procedure FreeItem(item:TObject);
    procedure FreeAll;
    property Capacity: Integer read FCapacity write SetCapacity;
    property Count: Integer read FCount write SetCount;
    property Items[Index: Integer]: TObject read Get write Put; default;
    //property List: PObjectArray read FList;
    function KeyOf(item:TObject):AnsiString;virtual; abstract;
    function search(const key:AnsiString; var index:integer):boolean;
  end;


  TAutoList = class(TObject)
  private
    FList: PObjectArray;
    FCount: Integer;
    FCapacity: Integer;
    function Get(Index: Integer): TObject;
    procedure Put(Index: Integer; Item: TObject);
    procedure SetCapacity(NewCapacity: Integer);
    procedure SetCount(NewCount: Integer);
    procedure Clear;
  public
    constructor create(IniSize:integer);
    destructor Destroy; override;
    function Add(Item: TObject): Integer;
    //procedure Insert(Index: Integer; Item: TObject);
    procedure Delete(Index: Integer);
    procedure deleteall;
    procedure FreeItem(item:TObject);
    procedure FreeAll;
    property Capacity: Integer read FCapacity write SetCapacity;
    property Count: Integer read FCount write SetCount;
    property Items[Index: Integer]: TObject read Get write Put; default;
    //property List: PObjectArray read FList;
  end;

type
  TVarList=class(TAutoList)
       function newelement:TVar;virtual;abstract;
       procedure atfree(i:integer);

       constructor createNewElement(size:integer; m:integer);
       constructor createDup(p:TVarList);
       function duplicate:TVarList;virtual;abstract;
   private
         maxlen:integer;
       function multiply(a:TVarList; n:integer):boolean;
       function sumUp(p:Tvar; n:integer):boolean;  {pに和が入る}
       function dotproduct(a:TVarList; n:integer):TVar;
       procedure matadd(a:TVarList; n:integer);
       procedure subtract(a:TVarList; n:integer);
       procedure scalarmulti(a:TVar; n:integer);

  end;


 {*************}
 {pointer stack}
 {*************}
type
   TStack=class(TObjectList)
         procedure push(p:TVar);
         function pop:TVar;
   end;
var
   stack:TStack;

procedure clearArray4(var a:Array4);

type
   TArray = class(TAutoVar)
         dim       : integer;   {1..4}
         lbound    : array4;
         size      : Array4;
         maxlen    : integer;
       constructor create(d:integer;const lb,ub:array4; m:integer );virtual;
       constructor createNative(d:integer;const sz:array4);virtual;
       constructor createFrameCopy(p:TArray);virtual;
       constructor createMatrix(i,j:integer);
       //destructor destroy;override;

       function position1(i:integer):integer;
       function position2(i,j:integer):integer;
       function PositionOf(subsc:array4):integer;
       function positionNative(const subsc:array4 ):integer;

       procedure SubstIDN;virtual;abstract;

       procedure ItemGetX(i:integer; var x:Extended);virtual;abstract;
       procedure ItemGetF(i:integer; var x:double);virtual;abstract;
       procedure ItemAssignX(i:integer; x:extended);virtual;abstract;
       procedure ItemAssignLongInt(i:integer; c:longint);virtual;abstract;
       function ItemEvalInteger(i:integer):integer;virtual;abstract;
       function ItemStr(i:integer):string;virtual;abstract;
       function ItemStr2(i:integer):string;virtual;abstract;
       procedure ItemRead(i:integer; s:string);virtual;abstract;
       function DebugString(MaxLength:integer):string;
       function MaxSize:integer;virtual;abstract;

       function matsubst(p:TArray):boolean;virtual;abstract;
       function redim0(const lb,ub:array4):boolean;
       function redim(const lb,ub:array4):boolean;
       function RedimNative(const sz:array4; CanCreate:boolean):boolean; virtual;abstract;
       //function redim1(len:integer):boolean;
       procedure GetUbound(var ubound:array4);
       function amount:integer;

       function str:ansiString;override;       //2006.2.1 追加　CHAIN文で使用
       function str2:ansiString;override;       //2006.2.1 追加　CHAIN文で使用
       procedure read(const s:ansiString);override;   //2006.2.1 追加　PROGRAM文で使用

       procedure scalarMulti(p:TVar);virtual;abstract;

       procedure matadd(a1,a2:TArray);
       procedure matsbt(a1,a2:TArray);
       procedure matproduct(a1,a2:TArray);virtual;abstract;
       function dotproduct(a:TArray):TVar;virtual;abstract;
       procedure CrossProduct(a1,a2:TArray);
       function inverse:TArray;virtual;abstract;
       function trn:Tarray;virtual;abstract;

       function ItemSubstance0(i:integer; ByVal:boolean):TVar;virtual;abstract;
       function ItemSubstance1(i:integer):TVar;virtual;abstract;
       procedure DisposeSubstance0(p:Tvar; ByVal:boolean);virtual;abstract;
       procedure DisposeSubstance1(p:Tvar );virtual;abstract;

      protected
       function NewAry(s:integer):TVarList;virtual;abstract;
       constructor createDup(p:TArray);virtual;
       procedure CrossProductSub(a,b:TArray);virtual;abstract;

      private
       procedure ConvertNative(var subsc:array4);
       procedure SetSize(const ub:array4);
   end;

type
   TLegacyArray=class(TArray)
         ary       : TVarList;
       constructor create(d:integer;const lb,ub:array4; m:integer );override;
       constructor createNative(d:integer;const sz:array4);override;
       constructor createFrameCopy(p:TArray);override;
       destructor destroy;override;
       procedure substOne;override;
       procedure substZero;override;
       procedure SubstIDN;override;

       procedure ItemGetX(i:integer; var x:Extended);override;
       procedure ItemGetF(i:integer; var x:double);override;
       procedure ItemAssignX(i:integer; x:extended);override;
       procedure ItemAssignLongInt(i:integer; c:longint);override;
       function ItemEvalInteger(i:integer):integer;override;
       function ItemStr(i:integer):string;override;
       function ItemStr2(i:integer):string;override;
       function MaxSize:integer;override;
       procedure ItemRead(i:integer; s:string);override;

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

       function RedimNative(const sz:array4; CanCreate:boolean):boolean;override;
       function point(subsc:array4):TVar;
       function point1(i:integer):TVar;
       function point2(i,j:integer):TVar;
       function point3(i,j,k:integer):TVar;
       function point4(i,j,k,l:integer):TVar;
       function pointij(i,j:integer):TVar;  //Native mode
      protected
       function pointNative(const subsc:array4):TVar;
       constructor createDup(p:TArray);override;
       procedure CrossProductSub(a,b:TArray);override;

   end;

type
    TNewArray=class(TArray)
         function ItemStr(i:integer):string;override;
         function ItemStr2(i:integer):string;override;
         procedure ItemRead(i:integer; s:string);override;
    end;


procedure CalcSize(dim:integer;const lb,ub:array4; var sz:array4);

{****}
{Svar}
{****}
type
   TSVar=class(TAutoVar)
         maxlen:integer;
        public
          constructor create(m:integer);
          destructor destroy;override;
          procedure substS(const s:ansistring);override;
          procedure copyfrom(p:TVar);override;
          procedure assignwithNoRound(exp:TPrincipal);override;
          {procedure getN(var n:number);override;}
          {procedure getF(var x:extended);override;}
          function getS:ansistring;override;
          procedure swap(p:TVar);override;
          procedure read(const s:ansiString);override;
          procedure readData(const s:ansiString);override;
          function readDataV2(const s:ansiString; q,i:boolean):boolean;override;
          function str:ansiString;override;
          function str2:ansiString;override;
          function NewElement:TVar;override;
          function newcopy:TVar;override;
          function compare(p:TVar):integer;override;
          function compareP(exp:TPrincipal):integer;override;
          function format(const form:ansiString; var index,code:integer):ansistring;override;
          function substSubstring(i,j:integer; const s:ansistring; CharacterByte:boolean):boolean;
       private
         value:ansistring;
          constructor createS(const s:ansiString);
          function substSubstringNormal(i,j:integer; const s:ansistring):boolean;
          function substSubstringNative(i,j:integer; const s:ansistring):boolean;
    end;

  TSvarList = class(TVarList)
    private
        procedure setMaxlen;
        function newelement:TVar;override;
        function duplicate:TVarList;override;
  end;

  TSArray=class(TLegacyArray)
          procedure setMaxlen(m:integer);
          function NewElement:TVar;override;
          function newcopy:TVar;override;
          function ItemGetS(i:integer):string;
          procedure ItemSubstS(i:integer; s:string);
          procedure accomplishSubString(i1,i2:integer; CharacterByte:boolean);
          procedure ConcatLeft(s:string);
          procedure ConcatRight(s:string);
          procedure Concat(a2:TArray);
          procedure SubstSubstring(i1,i2:integer; a:TSArray; CharacterByte:boolean);

        protected
          function NewAry(s:integer):TVarList;override;
  end;

function quoted(s:ansistring):ansistring;
function MyCharToByteIndex(const s:Ansistring; i:integer):integer;
function substring(const s:ansistring; i,j:integer; CharacterByte:boolean):Ansistring;
function Arrayamount(const size:array4):integer;
{************}
implementation
{************}
uses LazUTF8,
     myutils,float,format,struct,variabls,variablc,variablr,textfile,vstack,
     sconsts,texthand,helpctex;


destructor TObjectList.Destroy;
begin
  FreeAll;
  Clear;
  inherited Destroy;
end;

constructor TObjectList.create(IniSize:integer);
begin
  inherited create;
  setCapacity(IniSize);
end;

function TObjectList.Add(Item: TObject): Integer;
begin
  Result := FCount;
  if Result = FCapacity then Grow;
  FList^[Result] := Item;
  Inc(FCount);
end;

procedure TObjectList.Insert(Index: Integer; Item: TObject);
begin
  if (Index < 0) or (Index > FCount) then exit; //Error(SListIndexError, Index);
  if FCount = FCapacity then Grow;
  if Index < FCount then
    System.Move(FList^[Index], FList^[Index + 1],
      (FCount - Index) * SizeOf(Pointer));
  FList^[Index] := Item;
  Inc(FCount);
end;

procedure TObjectList.Clear;
begin
  SetCount(0);
  SetCapacity(0);
end;

procedure TObjectList.Delete(Index: Integer);
begin
  if (Index < 0) or (Index >= FCount) then Exit;
  Dec(FCount);
  if Index < FCount then
    System.Move(FList^[Index + 1], FList^[Index],
      (FCount - Index) * SizeOf(Pointer));
end;

function TObjectList.Expand: TObjectList;
begin
  if FCount = FCapacity then Grow;
  Result := Self;
end;

function TObjectList.Get(Index: Integer): TObject;
begin
 // if (Index < 0) or (Index >= FCount) then Error(SListIndexError, Index);
  Result := FList^[Index];
end;

procedure TObjectList.Grow;
var
  Delta: Integer;
begin
  if Fcapacity >= 16384 then
               Delta:=16384
  else if FCapacity >= 16 then
               Delta := FCapacity
  else  Delta := 4 ;
  SetCapacity(FCapacity + Delta);
end;

procedure TObjectList.Put(Index: Integer; Item: TObject);
begin
  FList^[Index] := Item;
end;

procedure TObjectList.SetCapacity(NewCapacity: Integer);
begin
  if (NewCapacity<FCount) or  (NewCapacity > MaxListSize) then
                                           setexception(5000);
  if NewCapacity mod 4 <>0 then NewCapacity:=(((NewCapacity div 4)+1)*4);
  if NewCapacity <> FCapacity then
  begin
    ReallocMem(FList, NewCapacity * SizeOf(TObject));
    FCapacity := NewCapacity;
  end;
end;

procedure TObjectList.SetCount(NewCount: Integer);
begin
  if NewCount > FCapacity then SetCapacity(NewCount);
  if NewCount > FCount then
    FillChar(FList^[FCount], (NewCount - FCount) * SizeOf(Pointer), 0);
  FCount := NewCount;
end;

procedure TObjectList.deleteAll;
var
   i:integer;
begin
   for i:=count-1 downto 0 do
                Delete(i);
end;

procedure TObjectList.FreeItem(item:TObject);
begin
    Item.Free;
end;

procedure TObjectList.FreeAll;
var
  Temp: TObject;
  i:integer;
begin
   for i:=count-1 downto 0 do
   begin
        Temp := Items[i];
        FreeItem(Temp);               { Delete Item }
        Delete(i);               { Free item from list }
   end;
end;

function TObjectList.search(const key:AnsiString; var index:integer):boolean;
var
   found:boolean;
begin
   index:=0;
   found:=false;
   while (index<count) and not found do
       begin
            if key=KeyOf(items[index]) then
                found:=true
            else
                index:=index+1;
       end;
  search:=found;
end;

{*********}
{TAutoList}
{*********}
destructor TAutoList.Destroy;
begin
  FreeAll;
  Clear;
  inherited Destroy;
end;

constructor TAutoList.create(IniSize:integer);
begin
  inherited create;
  setCapacity(IniSize);
end;

function TAutoList.Add(Item: TObject): Integer;
begin
  Result := FCount;
  if Result = FCapacity then SetException(5001);
  FList^[Result] := Item;
  Inc(FCount);
end;

procedure TAutoList.Clear;
begin
  SetCount(0);
  SetCapacity(0);
end;

procedure TAutoList.Delete(Index: Integer);
begin
  if (Index < 0) or (Index >= FCount) then Exit;
  Dec(FCount);
  if Index < FCount then
    System.Move(FList^[Index + 1], FList^[Index],
      (FCount - Index) * SizeOf(Pointer));
end;

function TAutoList.Get(Index: Integer): TObject;
begin
  Result := FList^[Index];
end;

procedure TAutoList.Put(Index: Integer; Item: TObject);
begin
  FList^[Index] := Item;
end;

procedure TAutoList.SetCapacity(NewCapacity: Integer);
begin
  if NewCapacity>0 then
    if FCapacity=0 then
       begin
         FList:=GetMemory(NewCapacity * SizeOf(TObject));
         FCapacity := NewCapacity;
       end
    else
       setexception(SystemErr)
  else if FCapacity>0 then
      begin
         FreeMemory(FCapacity * SizeOf(TObject));
         FCapacity := NewCapacity;
      end
end;

procedure TAutoList.SetCount(NewCount: Integer);
begin
  if NewCount > FCapacity then SetCapacity(NewCount);
  if NewCount > FCount then
    FillChar(FList^[FCount], (NewCount - FCount) * SizeOf(Pointer), 0);
  FCount := NewCount;
end;

procedure TAutoList.deleteAll;
var
   i:integer;
begin
   for i:=count-1 downto 0 do
                Delete(i);
end;

procedure TAutoList.FreeItem(item:TObject);
begin
    Item.Free;
end;

procedure TAutoList.FreeAll;
var
  Temp: TObject;
  i:integer;
begin
   for i:=count-1 downto 0 do
   begin
        Temp := Items[i];
        FreeItem(Temp);               { Delete Item }
        Delete(i);               { Free item from list }
   end;
end;



{****}
{TVar}
{****}

procedure clearArray4(var a:array4);
var
   i:integer;
begin
  for i:=1 to 4 do a[i]:=0
end;

class function TAutoVar.NewInstance: TObject;
begin
   result:=InitInstance(getMemory(instancesize));
end;

procedure TAutoVar.FreeInstance;
begin
   freeMemory(instanceSize)
end;



function TVar.str:ansistring;
begin
   str:='';
end;

function TVar.DebugStr:string;                                   //ver.8.1.3.1
begin
  result:=str2;
end;


procedure TVar.assign(exp:TPrincipal);
begin
   if self<>nil then
      assignwithRound(exp)
end;

procedure TVar.assignWithRound(exp:TPrincipal);
begin
   assignwithNoRound(exp);
   RoundVari
end;


procedure TVar.RoundVari;
begin
     {何もしない}
end;

procedure TVar.SubstZero;
begin
end;

{******}
{TStack}
{******}


procedure TStack.push(p:TVar);
begin
     add(p);
end;

function TStack.pop:TVar;
begin
    pop:=TVar(items[count-1]);
    delete(count-1)
end;

{******}
{TIdRec}
{******}

procedure TIdRec.Init(const nam:AnsiString; p:boolean; d:shortint; t:TIdTag);
begin
     inherited create;
     ModuleName:='';
     maxlen:=maxint;
     name     :=nam;
     prm      :=p;
     dim      :=d;
     tag      :=t;

     if dim>4 then setErr(s_DimmensionError,IDH_Array); //配列次元最大値を4とする

     if (length(name)>0) and (name[1]='#') then
           kindchar:='c'
     else if (length(name)>0) and (name[length(name)]='$') then
          kindchar:='s'
     else
          kindchar:='n';

     case KindChar of
     'c': subs:=TchVari.create(self,KindChar,dim,prm);
     's': if dim<=0 then
            subs:=TSVari.create(self,KindChar,dim,prm)
          else
            subs:=TSAVari.create(self,KindChar,dim,prm);
     else
          begin
             subs:=TSubstance.create(self,kindchar,dim,prm);
             if pass=2 then initcomplete(programunit.arithmetic);
          end;
     end;
end;

constructor TSubstance.create(idr0:TIdRec;  kindchar:char; dim:shortint; prm:boolean);
begin
  inherited create;
  idr:=idr0;
  if (dim<0) xor (prm) then
     GetVar:=GetNone
  else
     GetVar:=getVar1;

end;

procedure TIdRec.InitComplete(arith:tpPrecision);
begin
    if kindchar<>'n' then exit;
    subs.freeAnyway;
    case arith of
      PrecisionNormal:
        if dim<=0 then
           subs:=TNVari.create(self,KindChar,dim,prm)
        else
           subs:=TNAVari.create(self,KindChar,dim,prm);
      PrecisionHigh  :
        if dim<=0 then
           subs:=TNVari.create(self,KindChar,dim,prm)
        else
           subs:=TNAVari.create(self,KindChar,dim,prm);
      PrecisionNative:
        if dim<=0 then
           subs:=TFVari.create(self,KindChar,dim,prm)
        else
           subs:=TFAVari.create(self,KindChar,dim,prm);
      PrecisionComplex:
        if dim<=0 then
           subs:=TCVari.create(self,KindChar,dim,prm)
        else
           subs:=TCAVari.create(self,KindChar,dim,prm);
      PrecisionRational:
        if dim<=0 then
           subs:=TRVari.create(self,KindChar,dim,prm)
        else
           subs:=TRAVari.create(self,KindChar,dim,prm);
     end;
end;

constructor TIdRec.InitF(const mnam,nam:AnsiString; t:TidTag);
begin
   init(nam,false,-1,t);
   moduleName:=mnam;

end;

constructor TIdRec.InitpF(const nam:AnsiString; maxlen1:integer);
begin
   init(nam,true,-1,intern);
   maxlen:=maxlen1;

end;

constructor TIdRec.InitSimple(const nam:AnsiString; t:TIdTag; maxlen1:integer);
begin
   init(nam,false,0,t);
   maxlen:=maxlen1;
end;

constructor TIdRec.InitpSimple(const nam:AnsiString);
begin
   init(nam,true,0,intern);
end;

constructor TIdRec.InitA(const nam:AnsiString; d:shortint; t:TIdTag);
begin
   init(nam,false,d,t);
end;

constructor TIdRec.InitpA(const nam:AnsiString; d:shortint);
begin
     Init(nam,true ,d,intern)
end;


constructor TIdRec.InitArray(const nam:AnsiString; d:shortint;const lb,ub:Array4; t:TIdTag; m:integer);
begin
     Init(nam,false ,d,t) ;
     setdim(lb,ub);
     maxlen:=m;
end;
constructor TIdRec.InitpArray(const nam:AnsiString; d:shortint;const lb,ub:Array4);
begin
     Init(nam,true ,d,intern) ;
     setdim(lb,ub)
end;

constructor TIdRec.InitCh(const mnam,nam:AnsiString; t:TIdTag);
begin
   initSimple(nam,t,maxint);
   ModuleName:=mnam
end;

constructor TIdRec.InitpCh(const nam:AnsiString);
begin
   initpSimple(nam);
end;

destructor TIdrec.destroy;
begin
   subs.Freeanyway;
   inherited destroy;
end;

procedure TIdrec.GetVar;
begin
   if subs<>nil then subs.GetVar
end;

procedure TIdrec.FreeVar;
begin
   if subs<>nil then subs.FreeVar
end;

procedure TIdrec.PushStack;
begin
   if subs<>nil then subs.pushStack;
end;

procedure TIdrec.PopStack;
begin
   if subs<>nil then subs.popStack;
end;

procedure TSubstance.PushStack;
begin
    stack.push(ptr);
end;

procedure TSubstance.PopStack;
begin
   ptr:=stack.pop;
end;

procedure TSubstance.GetNone;
begin
  //何もしない
end;

procedure TSubstance.Getvar1;
begin
  getVar2;
end;

procedure TNVari.Getvar2;
begin
    ptr:=TNVar.create;
end;

procedure TFvari.Getvar2;
begin
    ptr:=TorthoFVar.create;
end;

procedure TCVari.Getvar2;
begin
    ptr:=TOrthoCVar.create;
end;

procedure TRVari.Getvar2;
begin
    ptr:=TRVar.create;
end;

procedure TSVari.Getvar2;
begin
    ptr:=TSvar.create(idr.maxlen);
end;

procedure TNAVari.Getvar2;
begin
    with idr do ptr:=TNArray.create(dim,lbound,ubound,0);
end;

procedure TFAVari.GetVar2;
begin
    with idr do ptr:=TFArray.create(dim,lbound,ubound,0);
end;

procedure TCAVari.GetVar2;
begin
    with idr do ptr:=TCArray.create(dim,lbound,ubound,0);
end;

procedure TRAVari.GetVar2;
begin
    with idr do ptr:=TRArray.create(dim,lbound,ubound,0);
end;

procedure TSAVari.GetVar2;
begin
    with idr do ptr:=TSArray.create(dim,lbound,ubound,maxlen) ;
end;

Procedure TChVari.GetVar2;
begin
    ptr:=PTextDevice.create
end;

procedure TSubstance.FreeVar;
begin
   ptr.free;
end;


constructor TIdRec.InitSimpleExt(const mnam,nam:AnsiString);
begin
    initSimple(nam,extern,maxlen);
    ModuleName:=mnam
end;

constructor TIdRec.InitAExt(const mnam,nam:AnsiString; d:shortint);
begin
   InitA(nam,d,extern);
   ModuleName:=mnam
end;


procedure TIdRec.setdim(const lb,ub:Array4);
begin
   lbound:=lb;
   ubound:=ub;
end;

procedure TIdRec.setdim1(d:shortint);
var
  lb,ub:Array4;
  i:integer;
begin
  dim:=d;
  for i:=1 to 3 do lb[i]:=programUnit.ArrayBase;
  for i:=1 to dim do ub[i]:=10;
  setdim(lb,ub);
end;

procedure TSubstance.freeInstance;
begin
   if OnIdTableFree then
      inherited FreeInstance;
end;

procedure TSubstance.FreeAnyway;
var
  sv:boolean;
begin
  sv:=OnIdtableFree;
  OnIdTableFree:=true;
  free;
  OnIdTableFree:=sv;
end;

function TCVari.evalX:extended;
begin
   ptr.getX(result)
end;

procedure TCVari.evalC(var c:complex);
begin
   TBasisCVar(ptr).getC(c)
end;

function TRVari.evalX:extended;
begin
   ptr.getX(result)
end;

procedure TRVari.evalR(var r:PNumeric);
begin
   TRVar(ptr).getR(r)
end;

function TSVari.evalS:ansistring;
begin
   result:=ptr.getS
end;

function TNVari.evalInteger:integer;  //桁あふれはmaxint
begin
  result:= ptr.EvalInteger
end;

function TNVari.evalLongint:longint;  //桁あふれはEInvalidOp
begin
  result:=ptr.EvalLongint
end;

function TCVari.evalInteger:integer;  //桁あふれはmaxint
begin
  result:= ptr.EvalInteger
end;

function TCVari.evalLongint:longint;  //桁あふれはEInvalidOp
begin
  result:=ptr.EvalLongint
end;

function TRVari.evalInteger:integer;  //桁あふれはmaxint
begin
  result:= ptr.EvalInteger
end;

function TRVari.evalLongint:longint;  //桁あふれはEInvalidOp
begin
  result:=ptr.EvalLongint
end;

function TNVari.str:ansistring;
begin
  result:=ptr.str
end;



function TNVari.str2:ansistring;
begin
   result:=ptr.str2
end;

function TFVari.str:ansistring;
begin
  result:=ptr.str
end;

function TFVari.str2:ansistring;
begin
   result:=ptr.str2
end;

function TCVari.str:ansistring;
begin
  result:=ptr.str
end;

function TCVari.str2:ansistring;
begin
   result:=ptr.str2
end;

function TRVari.str:ansistring;
begin
  result:=ptr.str
end;

function TRVari.str2:ansistring;
begin
   result:=ptr.str2
end;

function TSVari.str:ansistring;
begin
  result:=ptr.str
end;

function TSVari.str2:ansistring;
begin
   result:=ptr.str2
end;


function TNVari.compare(exp:TPrincipal):integer;
begin
   result:=ptr.compareP(exp)
end;

function TCVari.compare(exp:TPrincipal):integer;
begin
   result:=ptr.compareP(exp)
end;

function TRVari.compare(exp:TPrincipal):integer;
begin
   result:=ptr.compareP(exp)
end;

function TSVari.compare(exp:TPrincipal):integer;
begin
   result:=ptr.compareP(exp)
end;

function TSubstance.kind:char;
begin
   result:=idr.kindchar
end;

function TSubstance.isConstant:boolean;
begin
   result:=false
end;

function TSubstance.DebugStr:string;                                //ver.8.1.3.1
begin
  result:=ptr.DebugStr;
end;

function TSubstance.point:TVar;
begin
     point:=ptr
end;

function TSubstance.substance0(ByVal:boolean):TVar;
begin
  if ByVal then
    result:=substance1
  else
    result:=ptr;
end;

procedure TSubstance.disposesubstance0(p:TVar; ByVal:boolean);
begin
  if ByVal then
     disposesubstance1(p)

end;

function TSubstance.substance1:TVar;
begin
   result:=ptr.newcopy
end;

procedure TSubstance.disposesubstance1(p:TVar);
begin
   p.free
end;


{*****}
{Array}
{*****}


constructor TVarList.createNewElement(size:integer; m:integer);
var
   i:integer;
begin
   inherited create(size);
   maxlen:=m;
   i:=0 ;
   while (i<size) do
        begin
           add(newelement);
           inc(i)
        end;
end;


constructor TVarList.createDup(p:TVarList);
var
   i:integer;
   size:integer;
begin
   inherited create(p.count);
   size:=p.count;
   maxlen:=maxint;
   i:=0;
   while (i<size) do
        begin
           add(TVar(p.items[i]).newcopy);
           inc(i)
        end;
end;

procedure TVarList.atfree(i:integer);
begin
   TVar(items[i]).free;
   delete(i);
end;


procedure TVarList.matadd(a:TVarList; n:integer);
var
   i:integer;
   p,q:TVar;
begin
   for i:=0 to n-1 do
       begin
         p:=TVar(items[i]);
         q:=TVar(a.items[i]);
         p.add(q)
       end;
end;

procedure TVarList.scalarMulti(a:TVar; n:integer);
var
   i:integer;
   p:TVar;
begin
   for i:=0 to n-1 do
       begin
         p:=TVar(items[i]);
         p.multiply(a)
       end;
end;

procedure TVarList.subtract(a:TVarList; n:integer);
var
   i:integer;
   p,q:TVar;
begin
   for i:=0 to n-1 do
       begin
         p:=TVar(items[i]);
         q:=TVar(a.items[i]);
         p.subtract(q)
       end;
end;



function TVarList.multiply(a:TVarList; n:integer):boolean;
var
   i:integer;
   s:boolean;
   p,q:TVar;
begin
   s:=true;
   for i:=0 to n-1 do
       begin
         p:=TVar(items[i]);
         q:=TVar(a.items[i]);
         p.multiply(q)
       end;
   result:=s;
   if extype=1002 then extype:=1005
end;

function TVarList.sumUp(p:Tvar; n:integer):boolean;  {pに和が入る}
var
   i:integer;
   s:boolean;
   q:TVar;
begin
   s:=true;
   for i:=0 to n-1 do
       begin
         q:=TVar(items[i]);
         p.add(q)
       end;
   result:=s;
end;


function TVarList.dotproduct(a:TVarList; n:integer):TVar;
var
   p:TVar;
   b:TVarList;
begin
   p:=newelement;
   b:=duplicate;
   if b.multiply(a,n) and b.sumup(p,n) then dotproduct:=p
   else
      begin dotproduct:=nil;p.free end;
   b.free;
end;





{******}
{TArray}
{******}
type
   TArrayClass = class of TArray;



function Arrayamount(const size:array4):integer;
var
   b:int64;
   i:integer;
begin
   b:=1;
   for i:=1 to 4 do
       begin
          b:=b*size[i];
          if b>MaxListSize then  setexception(ArraySizeOverflow);
       end;
   if extype=0 then
      Arrayamount:=b
   else
      Arrayamount:=0
end;

function TArray.amount:integer;
begin
   amount:=Arrayamount(size)
end;

destructor TLegacyArray.destroy;
begin
    ary.free;
    inherited destroy;
end;

function TArray.str:ansiString;
var
  s:TStringList;
  i:integer;
begin
  s:=TStringList.create;
  s.add(IntToStr(dim));
  for i:=1 to 4 do
     s.add(IntToStr(lbound[i]));
  for i:=1 to 4 do
     s.add(IntToStr(size[i]));
  for i:=0 to amount-1 do
       s.add(trim(ItemStr(i)));
  result:=s.commatext;
  s.free;
end;

function TArray.str2:ansistring;
begin
   result:=quoted(str);
end;

procedure TArray.read(const s:ansiString);    //program文で使う
var
  list:TStringList;
  i:integer;
  sz:array4;
begin
  list:=TStringList.Create;
  with list do
    try
      CommaText:=s;
      if count<10 then
          setexception(4301);
      try
        if strToInt(Strings[0])<>dim then
            setexception(4302);
        for i:=1 to 4 do
           lbound[i]:=StrToInt(Strings[i]);
        for i:=5 to 8 do
           sz[i-4]:=StrToInt(Strings[i]);
        //if RedimNative(sz, false) then
        if RedimNative(sz, true) then         //2020.06.19
           for i:=9 to Count-1 do
              ItemRead(i-9,Strings[i])

      except
        on EConvertError do
           setexception(4301);
      end;
    finally
      list.Free
    end;

end;


constructor TArray.createNative(d:integer;const sz:array4 );
begin
    inherited create;
    dim:=d;
    size:=sz;
end;

constructor TlegacyArray.createNative(d:integer;const sz:array4 );
begin
    inherited createNative(d,sz);
    ary:=newary(amount);
end;

constructor TArray.create(d:integer;const lb,ub:array4; m:integer );
begin
    inherited create;
    dim:=d;
    maxlen:=m;
    lbound:=lb;
    SetSize(ub);
end;

constructor TlegacyArray.create(d:integer;const lb,ub:array4; m:integer );
begin
    inherited create(d,lb,ub,m);
    ary:=newary(amount);
end;


constructor TArray.createFrameCopy(p:TArray);
begin
    inherited create;
    dim:=p.dim;
    maxlen:=p.maxlen;
    size:=p.size;
    lbound:=p.lbound;
end;

constructor TlegacyArray.createFrameCopy(p:TArray);
begin
    inherited createFrameCopy(p);
    ary:=newary(amount);
end;

constructor TArray.createMatrix(i,j:integer);
var
   sz:array4;
begin
   sz[1]:=i;
   sz[2]:=j;
   sz[3]:=1;
   sz[4]:=1;
   createnative(2,sz);
end;


procedure CalcSize(dim:integer;const lb,ub:array4; var sz:array4);
var
  i:integer;
begin
   for i:=1 to 4 do
          if i<=dim then
             begin
                 sz[i]:=ub[i]-lb[i]+1;
                 if sz[i]<0 then setexception(6005) ;  //2000.2.6
                 if sz[i]>maxListSize then setexception(ArraySizeOverflow) ;
             end
          else
             sz[i]:=1;
end;



procedure TArray.SetSize(const ub:array4);
begin
   calcsize(dim,lbound,ub,size)
end;



function TLegacyArray.RedimNative(const sz:array4; CanCreate:boolean):boolean;
var
    i,NewSize:integer;
begin
    NewSize:=ArrayAmount(sz);
    for i:=1 to dim do
        if (sz[i]<0) or NoSizeZeroArray and (sz[i]=0)  then setexception(6005) ;  //2021.12.29
    i:=Ary.Capacity-NewSize;
    if CanCreate and (Ary.Capacity=0) then
        begin
          ary.Capacity:=NewSize;
          while i<0 do
           begin
             ary.add(ary.newElement);
             inc(i)
           end;
        end
      else if Ary.count<NewSize then
           begin setexception(5001); result:=false; exit end;
    size:=sz;
    RedimNative:=true
end;

function TArray.redim(const lb,ub:array4):boolean;
var
    sz:array4 ;
begin
    redim:=false;
    calcsize(dim,lb,ub,sz);
    if extype=0 then
       begin
           redim:=RedimNative(sz, false);
           lbound:=lb;
           size:=sz;
       end;
end;

function TArray.redim0(const lb,ub:array4):boolean;
var
    sz:array4 ;
begin
    redim0:=false;
    calcsize(dim,lb,ub,sz);
    if extype=0 then
       begin
           redim0:=RedimNative(sz, true);
           lbound:=lb;
           size:=sz;
       end;
end;


{
function TArray.redim1(len:integer):boolean;
var
   sz:array4;
begin
    sz:=size;
    sz[1]:=len;
    redim1:=RedimNative(sz)
end;
}

function TArray.positionNative(const subsc:array4 ):integer;
begin
   case dim of
     1:positionNative:=subsc[1];
     2:positionNative:=subsc[1]*size[2]+subsc[2];
     3:positionNative:=(subsc[1]*size[2]+subsc[2])*size[3]+subsc[3];
     4:positionNative:=((subsc[1]*size[2]+subsc[2])*size[3]+subsc[3])*size[4]+subsc[4];
  end;
end;

procedure TArray.ConvertNative(var subsc:array4);
var
   i:integer;
begin
   for i:=1 to 4 do
          if i<=dim then
             begin
                dec(subsc[i],lbound[i]);
                if (subsc[i]<0) or (subsc[i]>=size[i]) then
                   if (lbound[i]=1) and (subsc[i]=-1) then
                        setexceptionwith(s_GuideOptionBase,2001)
                   else
                        setexception(2001)
             end
          else
             subsc[i]:=0
end;

function TLegacyArray.pointNative(const subsc:array4):TVar;
var
  i:integer;
begin
   i:=positionNative(subsc);
   if extype=0 then
      pointNative:=TVar(ary.items[i])
   else
      pointNative:=nil;
end;

function TArray.PositionOf(subsc:array4 ):integer;
begin
   ConvertNative(subsc);
   result:=positionNative(subsc);
end;

function TArray.position1(i:integer):integer;
begin
   result:=i-lbound[1];
   if (result<0) or (result>=size[1]) then
      if (lbound[1]=1) and (i=0) then
             setexceptionwith(s_GuideOptionBase,2001)
       else
            setexception(2001);
end;

function TArray.position2(i,j:integer):integer;
var
   index1,index2:integer;
begin
   index1:=i-lbound[1];
   index2:=j-lbound[2];
   if (index1>=0) and (index1<size[1])
      and (index2>=0) and (index2<size[2]) then
         result:=index1*size[2]+index2
   else
       if (lbound[1]=1) and (i=0) or (lbound[2]=1) and (j=0) then
                       setexceptionwith(s_GuideOptionBase,2001)
                   else
                       setexception(2001)
end;



function TlegacyArray.point( subsc:array4):TVar;
begin
   ConvertNative(subsc);
   point:=pointNative(subsc)
end;

function TlegacyArray.point1(i:integer):TVar;
var
   index:integer;
begin
   index:=i-lbound[1];
   if (index>=0) and (index<size[1]) then
      result:=TVar(ary.Items[index])
   else
      if (lbound[1]=1) and (i=0) then
                       setexceptionwith(s_GuideOptionBase,2001)
                   else
                       setexception(2001)
end;

function TLegacyArray.point2(i,j:integer):TVar;
var
   index1,index2:integer;
begin
   index1:=i-lbound[1];
   index2:=j-lbound[2];
   if (index1>=0) and (index1<size[1])
      and (index2>=0) and (index2<size[2]) then
         result:=TVar(ary.Items[index1*size[2]+index2])
   else
       if (lbound[1]=1) and (i=0) or (lbound[2]=1) and (j=0) then
                       setexceptionwith(s_GuideOptionBase,2001)
                   else
                       setexception(2001)
end;

function TLegacyArray.point3(i,j,k:integer):TVar;
var
   subsc:array4;
begin
   subsc[1]:=i;
   subsc[2]:=j;
   subsc[3]:=k;
   result:=point(subsc);
end;

function TLegacyArray.point4(i,j,k,l:integer):TVar;
var
   subsc:array4;
begin
   subsc[1]:=i;
   subsc[2]:=j;
   subsc[3]:=k;
   subsc[4]:=l;
   result:=point(subsc);
end;

function TLegacyArray.pointij(i,j:integer):TVar;
begin
   {asume size[3]=1}
   {no check overflow}
   pointij:=TVar(ary.items[(i*size[2]+j)])
end;

function TLegacyArray.ItemSubstance0(i:integer; ByVal:boolean):TVar;
begin
   if ByVal then
      result:=ItemSubstance1(i)
   else
      result:=TVar(ary.Items[i])
end;

function TLegacyArray.ItemSubstance1(i:integer):TVar;
begin
   result:=TVar(ary.Items[i]).newcopy
end;

procedure TLegacyArray.DisposeSubstance0(p:Tvar; ByVal:boolean);
begin
   if ByVal then
      DisposeSubstance1(p);
end;

procedure TLegacyArray.DisposeSubstance1(p:Tvar );
begin
   p.Free
end;

constructor TArray.createDup(p:TArray);
begin
     inherited create;
     dim:=p.dim;
     lbound:=p.lbound;
     size:=p.size;
     maxlen:=maxint;
end;

constructor TLegacyArray.createDup(p:TArray);
begin
     inherited createDup(p);
     ary:=TLegacyArray(p).ary.duplicate;
end;

procedure TLegacyArray.substOne;
var
  i:integer;
begin
  for i:=0 to amount -1 do
      TVar(ary.Items[i]).substOne;
end;

procedure TlegacyArray.substZero;
var
  i:integer;
begin
  for i:=0 to amount -1 do
      TVar(ary.Items[i]).substZero;
end;

procedure TlegacyArray.SubstIDN;
var
   i:integer;
   subsc:array4;
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
           pointNative(subsc).substone;
        end;
end;

procedure TLegacyArray.ItemAssignX(i:integer; x:extended);
begin
   TVar(ary.Items[i]).assignX(x);
end;

procedure TlegacyArray.ItemGetX(i:integer; var x:Extended);
begin
   TVar(ary.Items[i]).getX(x);
end;

procedure TlegacyArray.ItemGetF(i:integer; var x:Double);
var
   y:extended;
begin
   TVar(ary.Items[i]).getX(y);
   x:=y
end;

procedure TLegacyArray.ItemAssignLongInt(i:integer; c:longint);
begin
   TVar(ary.Items[i]).assignLongInt(c);
end;

function TLegacyArray.ItemEvalInteger(i:integer):integer;
begin
   result:=TVar(ary.Items[i]).EvalInteger;
end;

function TLegacyArray.ItemStr(i:integer):string;
begin
   result:=TVar(ary.Items[i]).str
end;

function TLegacyArray.ItemStr2(i:integer):string;
begin
   result:=TVar(ary.Items[i]).str2
end;

procedure TLegacyArray.ItemRead(i:integer; s:string);
begin
   TVar(ary.Items[i]).read(s)
end;

function TArray.DebugString(MaxLength:integer):string;
var
   i:integer;
begin
   result:='';
   i:=0;
   while  (length(result)<MaxLength) and (i<amount) do
     begin
       result:=result+' '+ItemStr(i);
       inc(i);
     end;
end;

function TLegacyArray.MaxSize:integer;
begin
   result:=ary.Count;
end;

function TlegacyArray.matsubst(p:TArray):boolean;
var
    i:integer;
begin
    if self=p then begin matsubst:=true; exit end;     {ポインタの比較と解釈}
    matsubst:=false;
    if p=nil then exit;
    i:=ary.count-arrayAmount(p.size);
    if (i<0) then
        begin setexception(5001); result:=false; exit end;

    size:=p.size;
    for i:=0 to arrayAmount(size)-1 do
        TVar(ary.items[i]).copyfrom(TVar(TLegacyArray(p).ary.items[i]));

    matsubst:=true;
end;

procedure TLegacyArray.add(p:Tvar);
var
   n:integer;
begin
   n:=amount;
   if n<>TArray(p).amount then setexception(6001);
   ary.matadd(TLegacyArray(p).ary, n)
end;

procedure TLegacyArray.subtract(p:Tvar);
var
   n:integer;
begin
   n:=amount;
   if n<>TArray(p).amount then setexception(6001);
   ary.subtract(TlegacyArray(p).ary, n)
end;

procedure TLegacyArray.scalarMulti(p:Tvar);
begin
   ary.scalarmulti(p, amount)
end;

procedure TArray.matadd(a1,a2:TArray);
var
   p:TArray;
begin
   if (a1.size[1]<>a2.size[1])
      or (a1.dim>1) and (a1.size[2]<>a2.size[2]) then
                       setexception(6001);
   p:=TArrayClass(self.classType).createDup(a1);
   if (p<>nil) then
     begin
       p.add(a2);
       matsubst(p) ;
       p.free;
    end
   else
    setexception(OutOfMemory) ;
end;

procedure TArray.matsbt(a1,a2:TArray);
var
   p:TArray;
begin
   if (a1.size[1]<>a2.size[1])
      or (a1.dim>1) and (a1.size[2]<>a2.size[2]) then
           setexception(6001);
   p:=TArrayClass(self.classType).createDup(a1);
   if (p<>nil) then
      begin
        p.subtract(a2);
        matsubst(p);
        p.free;
      end;

end;

procedure TArray.GetUbound(var ubound:array4);
var
   i:integer;
begin
   for i:=1 to 4 do ubound[i]:=lbound[i]+size[i]-1
end;

{***********}
{mat product}
{***********}

procedure matProductsub(a1,a2,a:TLegacyArray); {a:=a1*a2} {aも初期化済みのこと}
var
   i,j,k,len:integer;
   dim:integer;
   n,x,y:TVar;
   size :array4;
   sz:array[1..2]of integer;
   p:TArray;
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

  p:=TArrayClass(a.classtype).createNative(dim,size);

  with TlegacyArray(p) do
    begin
       for i:=0 to sz[1]-1 do
           for j:=0 to sz[2]-1 do
             begin
                n:=pointij(i,j);
                n.substzero;
                for k:=0 to len-1 do
                    begin
                        x:=(a1.pointij(i,k)).newcopy;
                        y:=(a2.pointij(k,j)){.newcopy} ;
                        x.multiplywithNoRound(y);
                        n.addwithNoRound(x);
                        x.free;
                        {y.free;}
                     end;
                n.RoundVari;
             end;
    end;

  a.matsubst(p);
  p.free;
end;

procedure TLegacyArray.matProduct(a1,a2:Tarray);
begin
   matproductsub(TlegacyArray(a1),TlegacyArray(a2),self);
end;

function TLegacyArray.dotproduct(a:TArray):TVar;
begin
  if amount<>a.amount then setexception(6001);
  result:=ary.dotproduct(TLegacyArray(a).ary, amount)
end;


procedure TArray.CrossProduct(a1,a2:TArray);
var
  p:TArray;
begin
   if (a1.amount<>3) or (a2.amount<>3) then setexception(6001);
   p:=TArrayClass(self.classtype).createFrameCopy(a1);
   p.CrossProductSub(a1,a2);
   matsubst(p);
   p.Free;
end;

procedure TlegacyArray.CrossProductSub(a,b:TArray);
var
   i:integer;
   x,y:TVar;
begin
   for i:=0 to 2 do
     begin
       Tvar(ary[i mod 3]).substZero;
       x:=TVar(TLegacyArray(a).ary[(i+1) mod 3]).newcopy;
       x.multiplyWithNoRound(TVar(TLegacyArray(b).ary[(i+2) mod 3]));
       y:=TVar(TLegacyArray(b).ary[(i+1) mod 3]).newcopy;
       y.multiplyWithNoRound(TVar(TLegacyArray(a).ary[(i+2) mod 3]));
       TVar(ary[i mod 3]).AddWithNoRound(x);
       TVar(ary[i mod 3]).Subtract(y);
       x.free;
       y.Free;
    end;
end;



function matsbt(a1,a2:TArray):Tarray;
begin
   TVar(result):=a1.newcopy;
   if result<>nil then
     TArray(result).subtract(a2);
end;


function TlegacyArray.trn:TArray;
var
   p:TArray;
   i,j:integer;
label
   EXIT;
begin
   if (dim=2)  then
           begin
                p:=TArrayClass(self.classtype).createMatrix(size[2],size[1]);
                p.lbound[1]:=lbound[2];
                p.lbound[2]:=lbound[1];
                for i:=0 to size[1]-1 do
                    for j:=0 to size[2]-1  do
                        begin
                          TLegacyArray(p).pointij(j,i).copyfrom(pointij(i,j));
                        end;
           end
   else
           begin
              setexception(6003);
              p:=nil;
           end;
  trn:=p
end;

{*********}
{TPricipal}
{*********}


function TPrincipal.evalF:double;
var
   n:number;
begin
   evalN(n);
   result:=extendedval(n);
end;

function TPrincipal.evalX:extended;
begin
   result:=evalF
end;

procedure TPrincipal.evalC(var c:complex);
begin
   c.x:=evalX; c.y:=0.0;
end;

function TMyObject.OverflowErCode:integer;
begin
   result:=1002
end;

function TMyObject.InvalidErCode:integer;
begin
   result:=3000
end;

function TMyObject.OpName:string;
begin
  result:=''
end;




function TPrincipal.format(const form:ansiString; var index,code:integer):ansistring;
var
   p:TVar;
begin
   p:=substance0(false);
   result:=p.format(form,index,code);
   disposeSubstance0(p,false)
end;

function TPrincipal.isConstant:boolean;
begin
   isConstant:=false
end;

{*********}
{TVariable}
{*********}

procedure TNVari.evalN(var n:number);
begin
  TNVar(ptr).getN(n)
end;

function TNVari.sign:integer;
begin
  result:=ptr.sign
end;

procedure TNVari.add(p:TSubstance);
begin
   ptr.add(p.point)
end;

procedure  TNVari.substOne;
begin
    ptr.substOne;
end;

procedure TNVari.assign(exp:TPrincipal);
begin
    ptr.assign(exp);
end;

procedure TNVari.assignwithNoRound(exp:TPrincipal);
begin
    ptr.assignwithNoRound(exp);
end;

procedure  TNVari.assignX(x:extended);
begin
    ptr.assignX(x);
end;

procedure TNVari.assignLongint(i:longint);
begin
    ptr.assignLongint(i);
end;

{******}
{TFVari}
{******}
function TFVari.evalInteger:integer;  //桁あふれはmaxint
begin
  result:= ptr.EvalInteger
end;

function TFVari.evalLongint:longint;  //桁あふれはEInvalidOp
begin
  //result:=ptr.EvalLongint
  //result:=TFvar(ptr).evalLongint
  result:=LongIntRound(TbasisFvar(ptr).getValue);
end;

function TFVari.compare(exp:TPrincipal):integer;
begin
   result:=ptr.compareP(exp)
end;

function TFVari.sign:integer;
begin
  result:=ptr.sign
end;

function TFVari.evalX:extended;
begin
   ptr.getX(result)
end;

function TFVari.evalF:double;
begin
   TBasisFVar(ptr).GetF(result)
end;

procedure TFVari.add(p:TSubstance);
begin
   ptr.add(p.point)
end;

procedure  TFVari.substOne;
begin
   ptr.substOne;
end;

procedure TFVari.assign(exp:TPrincipal);
begin
   ptr.assign(exp);
end;

procedure TFVari.assignwithNoRound(exp:TPrincipal);
begin
   ptr.assignwithNoRound(exp);
end;

procedure  TFVari.assignX(x:extended);
begin
   ptr.assignX(x);
end;

procedure TFVari.assignLongint(i:longint);
begin
   ptr.assignLongint(i);
end;


{***********}
{TorthoFVari}
{***********}
function TorthoFVari.evalInteger:integer;  //桁あふれはmaxint
begin
  //result:= ptr.EvalInteger
  result:=TorthoFVar(ptr).evalInteger
end;

function TorthoFVari.evalLongint:longint;  //桁あふれはEInvalidOp
begin
  //result:=ptr.EvalLongint
  //result:=TFvar(ptr).evalLongint
  result:=LongIntRound(TorthoFVar(ptr).value);
end;

function TorthoFVari.compare(exp:TPrincipal):integer;
var
   x:double;
begin
   //result:=ptr.compareP(exp)
   x:=exp.evalF;
   result:=fcompare(TorthoFVar(ptr).value,x)
end;

function TorthoFVari.sign:integer;
begin
  //result:=ptr.sign
  result:=fsign(TorthoFVar(ptr).value)
end;

function TorthoFVari.evalX:extended;
begin
   //ptr.getX(result)
   result:=TorthoFVar(ptr).value
end;

function TorthoFVari.evalF:double;
begin
   result:=TorthoFVar(ptr).value     //高速化　2006.2.17
end;

procedure TorthoFVari.add(p:TSubstance);
var
   q:^double;
begin
   //ptr.add(p.point)
   q:=@(TorthoFVar(ptr).value);        //高速化　2006.2.17
   q^:=q^+TorthoFVar(p.ptr).value;
end;

procedure  TorthoFVari.substOne;
begin
   // ptr.substOne;
   TorthoFVar(ptr).value:=1;
end;

procedure TorthoFVari.assign(exp:TPrincipal);
begin
   // ptr.assign(exp);
   TorthoFVar(ptr).value:=exp.evalF      //高速化　2006.2.17
end;

procedure TorthoFVari.assignwithNoRound(exp:TPrincipal);
begin
   // ptr.assignwithNoRound(exp);
      TorthoFVar(ptr).value:=exp.evalF   //高速化　2006.2.17
end;

procedure  TorthoFVari.assignX(x:extended);
begin
   // ptr.assignX(x);
   TorthoFVar(ptr).value:=x;
end;

procedure TorthoFVari.assignLongint(i:longint);
begin
   // ptr.assignLongint(i);
   TorthoFVar(ptr).value:=i;
end;


{******}
{TCVari}
{******}

function TCVari.sign:integer;
begin
  result:=ptr.sign
end;

procedure TCVari.add(p:TSubstance);
begin
   ptr.add(p.point)
end;

procedure  TCVari.substOne;
begin
    ptr.substOne;
end;

procedure TCVari.assign(exp:TPrincipal);
begin
    ptr.assign(exp);
end;

procedure TCVari.assignwithNoRound(exp:TPrincipal);
begin
    ptr.assignwithNoRound(exp);
end;

procedure  TCVari.assignX(x:extended);
begin
    ptr.assignX(x);
end;

procedure TCVari.assignLongint(i:longint);
begin
    ptr.assignLongint(i);
end;

{******}
{TRvari}
{******}

function TRVari.sign:integer;
begin
  result:=ptr.sign
end;

procedure TRVari.add(p:TSubstance);
begin
   ptr.add(p.point)
end;

procedure  TRVari.substOne;
begin
    ptr.substOne;
end;

procedure TRVari.assign(exp:TPrincipal);
begin
    ptr.assign(exp);
end;

procedure TRVari.assignwithNoRound(exp:TPrincipal);
begin
    ptr.assignwithNoRound(exp);
end;

procedure  TRVari.assignX(x:extended);
begin
    ptr.assignX(x);
end;

procedure TRVari.assignLongint(i:longint);
begin
    ptr.assignLongint(i);
end;

{******}
{TSVari}
{******}


procedure TSVari.substS(const s:ansistring);
begin
    ptr.substS(s);
end;

procedure TSVari.assign(exp:TPrincipal);
begin
    ptr.assign(exp);
end;

procedure TSVari.assignwithNoRound(exp:TPrincipal);
begin
    ptr.assignwithNoRound(exp);
end;



{*********}
{TVariable}
{*********}

function TPointingVariable.compare(exp:TPrincipal):integer;
begin
   result:=point.compareP(exp)
end;

procedure TPointingVariable.substS(const s:ansistring);
begin
    point.substS(s);
end;
procedure  TPointingVariable.substOne;
begin
    point.substOne;
end;

procedure TPointingVariable.assign(exp:TPrincipal);
begin
    point.assign(exp);
end;

procedure TPointingVariable.assignwithNoRound(exp:TPrincipal);
begin
    point.assignwithNoRound(exp);
end;

procedure  TPointingVariable.assignX(x:extended);
begin
    point.assignX(x);
end;

procedure TPointingVariable.assignLongint(i:longint);
begin
    point.assignLongint(i);
end;

procedure TPointingVariable.evalN(var n:number);
begin
   TNVar(point).getN(n) ;
end;

function TPointingVariable.evalX:extended;
begin
   point.getX(result) ;
end;

function TPointingVariable.evalF:double;
begin
   TbasisFVar(point).getF(result) ;         //evalFは2進モード専用
end;

procedure TPointingVariable.evalC(var c:complex);
begin
   TBasisCVar(point).getC(c) ;
end;

procedure TPointingVariable.evalR(var r:PNumeric);
begin
   TRVar(point).getR(r) ;
end;

function TPointingVariable.evalS:ansistring;
begin
   result:=point.getS ;
end;

function TPointingVariable.evalInteger:Integer;
begin
   evalInteger:=point.EvalInteger ;
end;

function TPointingVariable.evalLongint:longint;
begin
   evalLongint:=point.EvalLongint ;
end;



function TPointingVariable.str:ansistring;
var
   p:TVar;
begin
    p:=point;
    if p<>nil then
       str:=p.str
    else
       str:=''
end;

function TPointingVariable.str2:ansistring;
var
   p:TVar;
begin
    p:=point;
    if p<>nil then
       str2:=p.str2
    else
       str2:=''
end;


function TPointingVariable.substance0(byVal:boolean):TVar;
begin
  if ByVal then
     result:=substance1
  else
     substance0:=point
end;

procedure TPointingVariable.disposesubstance0(p:TVar; ByVal:boolean);
begin
   if ByVal then
     DisposeSubstance1(p)
end;

function TPointingVariable.substance1:TVar;
var
   p:TVar;
begin
       p:=point;
       if p<>nil then
             substance1:=point.newcopy
       else
             substance1:=nil
end;

procedure TPointingVariable.disposesubstance1(p:TVar);
begin
     p.free
end;




{*****}
{TSVar}
{*****}

procedure TSvar.substS(const s:ansistring);
begin
    value:=s;
    if length(value)>maxLen then
         setexception(1106);
end;

procedure TSVar.copyfrom(p:TVar);
begin
    substS(TSvar(p).value)
end;

procedure TSVar.assignwithNoRound(exp:TPrincipal);
begin
   substS(exp.evalS);
end;

function TSVar.getS:ansistring;
begin
    result:=value;
end;

procedure TSVar.swap(p:tVar);
var
  s:ansistring;
begin
  s:=value;
  substS(TSVar(p).value);
  TSVar(p).SubstS(s);
end;


procedure TSvar.read(const s:ansiString);
begin
    substS(s)
end;

procedure TSvar.readData(const s:ansiString);
begin
   read(s)
end;

procedure TVar.ReadData(const s:ansistring);
begin
   if s='' then SubstZero else read(s)
end;

function TVar.ReadDataV2(const s:ansistring; q,i:boolean):boolean;
begin
   result:=not q;
   if i then readdata(s) else read(s);
   if not i and q then setexception(8101);
   if extype=4001 then extype:=8101;
end;

function  TSvar.ReadDataV2(const s:ansistring; q,i:boolean):boolean;
begin
   result:=true;
   read(s);
end;




function TSvar.str:ansiString;
begin
     str:=value;
end;

function quoted(s:ansistring):ansistring;
var
   i:integer;
begin
    {"を二重にして""で括る}
     i:=1;
     while i<=length(s) do
     begin
        if s[i]='"' then
           begin
              insert('"',s,i) ;
              inc(i);
           end;
        inc(i)
     end;
     result:='"'+s+'"'
end;

function TSvar.str2:ansiString;
begin
     str2:=quoted(value);
end;

constructor TSVar.create(m:integer);
begin
   inherited create;
   maxlen:=m
end;

constructor TSVar.createS(const s:ansiString);
begin
    inherited create;
    maxlen:=maxint;
    value:=s;
end;

destructor TSVar.destroy;
begin
   value:='';
   inherited destroy;
end;

function TSVar.newcopy:TVar;
begin
   result:=TSVar.createS(value);
end;

function TSVar.NewElement:TVar;
begin
   result:=TSVar.create(maxlen);
end;

function TSvar.compare(p:TVar):integer;
begin
   result:=CompareStr(value, TSvar(p).value)
end;

function TSvar.compareP(exp:TPrincipal):integer;
begin
   result:=CompareStr(value,exp.evalS);
end;

function TSvar.format(const form:ansiString; var index,code:integer):ansistring;
begin
    format:=formatStr(value,form,index,code)
end;

function TSvar.substSubstring(i,j:integer; const s:ansistring; CharacterByte:boolean):boolean;
begin
   if CharacterByte then
      result:=SubstSubstringNative(i,j,s)
   else
      result:=SubstSubStringNormal(i,j,s)
end;

function MyCharToByteIndex(const s:Ansistring; i:integer):integer;
var
  k:integer;
begin
  //k:=CharToByteIndex(s,i);
  {todo 1}k:=i; //assume single byte
  if (k=0) and (i>0) then k:=length(s)+1;
  result:=k
end;


(*
function TSvar.substSubstringNormal(i,j:integer; const s:ansistring):boolean;
var
   len:integer;
   p:integer;
begin
    result:=false;
    if self=nil then exit;
    if i<=0 then i:=1;  //1998.4.6
    len:=bytetocharlen(value,length(value));
    if j>len then j:=len;
    i:=MYchartobyteindex(value,i);
    j:=MYchartobyteindex(value,j);
    if j>0 then
       ReadMBC(j,value); //if IsDBCSLeadByte(byte(value[j])) then inc(j);
    if j-i+1 =length(s) then
       for p:=i to j do        //2006.5.6
           value[p]:=s[p-i+1]
    else
       begin
          delete(value,i,j-i+1);
          insert(s,value,i);
       end;
    substSubStringNormal:=true;
end;
*)

function TSvar.substSubstringNormal(i,j:integer; const s:ansistring):boolean;
var
   len:integer;
   p:integer;
begin
    result:=false;
    if self=nil then exit;
    if i<=0 then i:=1;  //1998.4.6
    len:=UTF8Length(value);  //2017.4.10
    if j>len then j:=len;
    
    Utf8delete(value,i,j-i+1);
    Utf8insert(s,value,i);

    substSubStringNormal:=true;
end;

function TSvar.substSubstringNative(i,j:integer; const s:ansistring):boolean;
var
   p:integer;
begin
    result:=false;
    if self=nil then exit;
    if i<=0 then i:=1;      //1998.4.6
    if j>length(value) then j:=length(value);
    if j-i+1 =length(s) then
       for p:=i to j do        //2006.5.6
           value[p]:=s[p-i+1]
    else
       begin
         delete(value,i,j-i+1);
         insert(s,value,i);
       end;
    substSubStringNative:=true;
end;



{*********}
{TSvarList}
{*********}

function substring(const s:ansistring; i,j:integer; CharacterByte:boolean):Ansistring;
begin
   if CharacterByte then
        if i<=j then
           result:=copy(s,i,j-i+1)
        else
           result:=''
   else
   if i<=j then
      result:=UTF8copy(s,i,j-i+1)
   else
      result:=''

end;

(*
function substring(const s:ansistring; i,j:integer; CharacterByte:boolean):Ansistring;
var
  i1,j1:integer;
   ch:byte;
begin
   if CharacterByte then
        if i<=j then
           result:=copy(s,i,j-i+1)
        else
           result:=''
   else
      begin
        i1:=MyCharToByteIndex(s,i);
        j1:=MyCharToByteIndex(s,j);
        if (length(s)>0) and (j1>0) then
           begin
                             // char(ch):=s[j1];
             ReadMBC(j1, s); //if IsDBCSLeadByte(ch) then inc(j1);
           end;
        if i1<=j1 then
           result:=copy(s,i1,j1-i1+1)
        else
           result:=''   ;
      end;
end;
*)



procedure TSVarList.setmaxlen;
var
   i:integer;
begin
   for i:=count-1 downto 0 do
       with  TSVar(TObject(items[i])) do
         begin
           maxlen:=self.maxlen;
           if length(value)>maxlen then
              begin
                 setexception(1106);
                 value:=copy(value,1,maxlen);
              end;   
         end;  
end;


function TSVarList.duplicate:TVarList;
begin
   duplicate:=TSVarList.createdup(self)
end;

function TSvarList.NewElement:TVar;
begin
   NewElement:=TSvar.create(maxlen)
end;

procedure TSArray.setMaxlen(m:integer);
begin
  with  (ary as TSVarList) do
    begin
       maxlen:=m;
       setMaxLen
    end;
end;

function TSArray.NewAry(s:integer):TVarList;
begin
    NewAry:=TSVarList.createNewElement(s,maxlen)
end;

function TSArray.newcopy:TVar;
begin
    newCopy:=TSArray.createdup(self)
end;

function TSArray.NewElement:TVar;
begin
    result:=TSArray.createFrameCopy(self)
end;

function TSArray.ItemGetS(i:integer):string;
begin
   result:=TSVar(ary.Items[i]).getS
end;

procedure TSArray.ItemSubstS(i:integer; s:string);
begin
   TSVar(ary.Items[i]).substS(s);
end;

procedure TSArray.accomplishSubString(i1,i2:integer; CharacterByte:boolean);
var
   i:integer;
   s:string;
begin
   for i:=0 to amount-1 do
     with TSVar(ary.items[i]) do
         begin
           s:=getS;
           SubstS(Substring(s,i1,i2,CharacterByte));
         end;
end;

procedure TSArray.ConcatLeft(s:string);
var
   i:integer;
begin
   for i:=0 to amount-1 do
      with TSVar(ary.items[i]) do
         SubstS(s + GetS)
end;

procedure TSArray.ConcatRight(s:string);
var
   i:integer;
begin
   for i:=0 to amount-1 do
      with TSVar(ary.items[i]) do
         SubstS(GetS + s)
end;

procedure TSArray.Concat(a2:TArray);
var
  i:integer;
  s,t:String;
begin
   if (self.size[1]=a2.size[1])
      and ((self.dim<2) or (self.size[2]=a2.size[2]))
      and ((self.dim<3) or (self.size[3]=a2.size[3]))
      and ((self.dim<4) or (self.size[3]=a2.size[4])) then
        for i:=0 to amount-1 do
            with TSVar(ary.items[i]) do
                 begin
                    s:=getS;
                    t:=TSvar(TSArray(a2).ary.items[i]).getS;
                    SubstS(s + t);
                 end
   else
         setexception(6101);
end;




procedure TSArray.SubstSubstring(i1,i2:integer; a:TSArray; CharacterByte:boolean);
var
  cont:boolean;
  i:integer;
  s:string;
begin
   cont:=true;
   for i:=1 to dim do
       cont:=cont and (size[i]=a.size[i]);
   if cont then
      for i:=0 to amount-1 do
          begin
             s:=TSVar(a.ary.items[i]).getS;
             TSVar(ary.items[i]).substSubstring(i1,i2,s,CharacterByte )
          end
   else
       setexception(6101);
end;


{*********}
{TNewArray}
{*********}

function TNewArray.ItemStr(i:integer):string;
var
   p:TVar;
begin
   p:=ItemSubstance0(i,false);
   result:=p.str;
   DisposeSubstance0(p,false);
end;

function TNewArray.ItemStr2(i:integer):string;
var
   p:TVar;
begin
   p:=ItemSubstance0(i,false);
   result:=p.str2;
   DisposeSubstance0(p,false);
end;

procedure TNewArray.ItemRead(i:integer; s:string);
var
   p:TVar;
begin
   p:=ItemSubstance0(i,false);
   p.read(s);
   DisposeSubstance0(p,false);
end;


end.
