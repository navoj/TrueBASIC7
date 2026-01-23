unit listcoll;
{$IFDEF FPC}
  {$MODE DELPHI}{$H-}
{$ENDIF}

(***************************************)
(* Copyright (C) 2003, SHIRAISHI Kazuo *)
(***************************************)


interface

uses Classes;

type
(*
  TForEachProc = procedure(O: TObject);
  TFirstLastFunc = function(O: TObject): Boolean;
*)

  TListCollection = class(TList)
  public
    procedure clear(i:integer);
    {function at(index:integer):pointer;}
    procedure atDelete(index:integer);
    procedure atInsert(index:integer; item:pointer);
    procedure deleteall;
    procedure insert(item:pointer);
    procedure FreeItem(item:pointer);virtual;
    procedure FreeAll;
    destructor Destroy; override;
   (*
    procedure ForEach(Proc: TForEachProc);
    function FirstThat(TestFunc: TFirstLastFunc): TObject;
    function LastThat(TestFunc: TFirstLastFunc): TObject;
    *)
  end;

  TSortedListCollection = class(TListCollection)
       procedure insert(item:pointer);
       function search(key:pointer; var index:integer):boolean;
       function compare(key1,key2:pointer):integer;virtual;abstract;
     private
       function keyof(item:pointer):pointer;
  end;

  TStringCollection = Class(TSortedListCollection)
        function compare(key1,key2:pointer):integer;override;
        procedure freeitem(item:pointer);override;
  end;



implementation

type  PString=^ShortString;
function newStr(s:ShortString):PString;forward;
procedure DisposeStr(p:PString);forward;

procedure TListCollection.clear(i:integer);
begin
  ;
end;

{
function TListCollection.at(index:integer):pointer;
begin
   result:=items[index]
end;
}

procedure TListCollection.atDelete(index:integer);
begin
    inherited delete(index);
end;

procedure TListCollection.atInsert(index:integer; item:pointer);
begin
    inherited insert(index,item);
end;

procedure TListCollection.deleteAll;
var
   i:integer;
begin
   for i:=count-1 downto 0 do
                Delete(i);
  (*
  while count>0 do
    begin
        Delete(0);               { Free item from list }
    end;           { until out of items }
  *)
end;

procedure TListCollection.insert(item:pointer);
begin
   inherited add(item)
end;

procedure TListCollection.FreeItem(item:pointer);
begin
    if item<>nil then  (TObject(item) as TObject).Free;
end;

procedure TListCollection.FreeAll;
var
  Temp: pointer;
  i:integer;
begin
   for i:=count-1 downto 0 do
   begin
        Temp := Items[i];
        FreeItem(Temp);               { Delete Item }
        Delete(i);               { Free item from list }
   end;

  (*
  while count>0 do
    begin
        Temp := Items[0];
        FreeItem(Temp);               { Delete Item }
        Delete(0);               { Free item from list }
    end;
              { until out of items }
    *)
end;



destructor TListCollection.Destroy;
begin
  FreeAll;
  inherited Destroy;         { call the inherited }
end;

function TSortedListCollection.search(key:pointer; var index:integer):boolean;
begin
    index:=0;
    while (index<count) and (compare(key,items[index])<0) do
                                                          inc(index);
    search:=(index<count) and (compare(key,items[index])=0)
end;

function TSortedListCollection.keyof(item:pointer):pointer;
begin
   keyof:=item
end;

procedure TSortedListCollection.insert(item:pointer);
var
   index:integer;
begin
   if not search(KeyOf(item),index) then atInsert(index,item)
end;


function TStringCollection.compare(key1,key2:pointer):integer;
begin
    if key1=nil then
       if key2=nil then
          compare:=0
       else
          compare:=-1
    else if key2=nil then compare :=1
    else if PString(key1)^<PString(key2)^ then compare:=-1
    else if PString(key1)^=PString(key2)^ then compare:=0
    else compare:=1
end;

procedure TStringCollection.freeitem(item:pointer);
begin
    DisposeStr(PString(item))
end;


function newStr(s:ShortString):PString;
begin
   if length(s)>0 then
     begin
           GetMem(Result,Length(s)+1);
           Result^:=s
     end
   else
     result:=nil
end;

procedure DisposeStr(p:PString);
begin
    if  p<>nil then FreeMem(p,length(PString(p)^)+1);
end;

(*
procedure TListCollection.ForEach(Proc: TForEachProc);
var
  i: integer;
begin
  for i := 0 to Count - 1 do           { iterate throught the list }
    Proc(Items[i]);                    { call proc and pass each item }
end;

function TListCollection.FirstThat(TestFunc: TFirstLastFunc): TObject;
var
  Func: TFirstLastFunc;
  i: integer;
begin
  for i := 0 to Count - 1 do           { iterate throught the list }
    if TestFunc(Items[i]) then begin   { call TestFunc and pass each item }
      Result := Items[i];              { return the first match }
      Break;
    end;
end;

function TListCollection.LastThat(TestFunc: TFirstLastFunc): TObject;
var
  i: integer;
begin
  for i := Count - 1 downto 0 do       { iterate backward through the list }
    if TestFunc(Items[i]) then begin   { call TestFunc and pass each item }
      Result := Items[i];              { return the first match }
      Break;
    end;
end;
*)

end.
