unit memman;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

(***************************************)
(* Copyright (C) 2003, SHIRAISHI Kazuo *)
(***************************************)


interface

procedure MemoryGet(var p:pointer; size:integer);
procedure MemoryFree(var p:pointer; size:integer);
procedure MemoryManInit;

implementation
//{$IFDEF CPU64}
uses base;
//{$ENDIF}

type
  PPointer=^pointer;
  PMemory=^TMemory;
  TMemory=record
     next:pointer;
     memory:array[0..{dummy}16383] of pointer;
  end;

type
  TMemMan=class
     mother:PMemory;
     FreeList:pointer;
     size:integer;
     count:integer;
   function get:pointer;
   procedure release(p:pointer);
   procedure expand;
   procedure init;
   procedure FreeSegment(segment:Pmemory);
   constructor create(s,c:integer);
   destructor destroy;override;
end;

procedure TMemman.expand;
var
  i:integer;
  p:pointer;
  SectionSize:integer;
  segment:^PMemory;
begin
  SectionSize:=size div sizeof(Pointer);
  segment:=@mother;
  while segment^<>nil  do
        segment:=@segment^^.next;
  getmem(segment^,size*count+sizeof(Pointer));
  with segment^^ do
     begin
       next:=nil;
       i:=(Count-1)*SectionSize;
       memory[i]:=nil;
       while i>0 do
        begin
          p:=@memory[i];
          dec(i,SectionSize);
          memory[i]:=p
        end;
       FreeList:=@memory[0];
     end;
end;

constructor TMemMan.create(s,c:integer);
begin
   inherited create;
   size:=s;
   count:=c;
end;

procedure TMemMan.FreeSegment(segment:Pmemory);
begin
  if segment<>nil then
     begin
       FreeSegment(segment^.next);
       FreeMem(segment,size*count+sizeof(Pointer))
     end;
end;

destructor TMemMan.destroy;
begin
  FreeSegment(mother);
  inherited destroy;
end;

procedure TMemMan.init;
begin
  FreeSegment(mother);
  mother:=nil;
  FreeList:=nil;
end;

function TMemMan.get:pointer;
begin
  if FreeList=nil then
                      expand;
  result:=FreeList  ;
  FreeList:=PPointer(Result)^;
end;

procedure TMemMan.release(p:pointer);
begin
   PPointer(p)^:=FreeList;
   FreeList:=p;
end;

var
   MemMan16,MemMan24,MemMan128,MemMan1024,MemMan4096,MemMan16384:TMemMan;

procedure MemoryGet(var p:pointer; size:integer);
begin
  //{$IFDEF CPU64}
   if size<=0 then setexception(TooBigRational)
   else
  //{$ENDIF}
   if size<=16 then
      p:=MemMan16.get
   else if size<=24 then
      p:=MemMan24.get
   else if size<=128 then
      p:=MemMan128.get
   else if size<=1024 then
      p:=MemMan1024.get
   else if size<=4096 then
      p:=MemMan4096.get
   else if size<=16384 then
      p:=MemMan16384.get
   else
      GetMem(p,size)
end;

procedure MemoryFree(var p:pointer; size:integer);
begin
   if size<=16 then
      MemMan16.release(p)
   else if size<=24 then
      MemMan24.release(p)
   else if size<=128 then
      MemMan128.release(p)
   else if size<=1024 then
      MemMan1024.release(p)
   else if size<=4096 then
      MemMan4096.release(p)
   else if size<=16384 then
      MemMan16384.release(p)
   else
      FreeMem(p,size)
end;


procedure MemoryManInit;
begin
   MemMan16.init;
   MemMan24.init;
   MemMan128.init;
   MemMan1024.init;
   MemMan4096.init;
   MemMan16384.init;
end;


initialization
   MemMan16:=TMemMan.create(16,2048);
   MemMan24:=TMemMan.create(24,1024);
   MemMan128:=TMemMan.create(128,32);
   MemMan1024:=TMemMan.create(1024,8);
   MemMan4096:=TMemMan.create(4096,4);
   MemMan16384:=TMemMan.create(16384,4);
finalization
   MemMan16.free;
   MemMan24.free;
   MemMan128.free;
   MemMan1024.free;
   MemMan4096.free;
   MemMan16384.free;

end.
