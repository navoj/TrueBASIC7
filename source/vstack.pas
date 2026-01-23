unit vstack;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

(***************************************)
(* Copyright (C) 2003, SHIRAISHI Kazuo *)
(***************************************)


interface

function getmemory(size:integer):pointer;
procedure freememory(size:integer);
procedure InitMemory;

implementation
{$IFDEF Linux}
{$IFDEF CPU32}
{$DEFINE Linux32}
{$ENDIF}
{$ENDIF}

uses
{$IFDEF LINUX32}
  Libc,
{$ENDIF}
   base ;

var
  StackBase:pointer;
  StackBottom:pointer;
  StackLimit:pointer;

function getmemory(size:integer):pointer;
begin
  if NativeInt(StackLimit)-NativeInt(StackBottom)<size then
                   setexception(VirtualStackOverflow);
  GetMemory:=StackBottom;
  Inc(NativeInt(StackBottom),size);
end;

procedure freememory(size:integer);
begin
  Dec(NativeInt(StackBottom),size);
end;

procedure InitMemory;
begin
  StackBottom:=StackBase
end;


var
   StackSize:NativeUInt={$IFDEF CPU64} $10000000 {256MB} {$ELSE}$2000000 {32MB}{$ENDIF};

{$IFDEF Linux32}
procedure setMaxStackSize;
var
  pagesize, physpages:NativeInt;
  physmemory:int64;
begin
  pagesize:=sysconf(_SC_PHYS_PAGES );
  physpages:=sysconf(_SC_AVPHYS_PAGES );
    StackSize:= $2000000  {32MB} ;
  if (pagesize>0) and (physpages>0) then
    begin
       physmemory:=int64(pagesize)*physpages;
       if physmemory>$24000000 {512MB+64MB} then
          stacksize:= $20000000 {512MB}
       else if physmemory>=$6000000 {32MB+64MB} then
          stacksize:=physmemory-$4000000 {64MB}
    end;
end;
{$ENDIF}

procedure ReadIniFile;
var
   IniFile:TMyIniFile;
begin
  IniFile:=TMyIniFile.create('Frame');
  with IniFile do
    begin
      StackSize:=ReadInteger('VirtualMemory',StackSize div $100000) * $100000;
      free;
    end;
  if StackSize> $40000000 {1GB} then StackSize:=$40000000;
end;

initialization

{$IFDEF Linux32}

 setmaxstacksize;
 ReadIniFile;

 StackBase:=mmap(nil, StackSize, PROT_READ or PROT_WRITE
                  , MAP_PRIVATE or MAP_ANONYMOUS, 0, 0);
 while StackBase=MAP_FAILED do
    begin
       dec(StackSize, $4000000{64MB});
       StackBase:=mmap(nil, StackSize, PROT_READ or PROT_WRITE
                          , MAP_PRIVATE or MAP_ANONYMOUS, 0, 0);
    end;

{$ELSE}
 GetMem(StackBase,StackSize);
{$ENDIF}
 StackBottom:=StackBase;
 NativeUInt(StackLimit):=NativeUInt(StackBase)+StackSize;


finalization
{$IFDEF Linux32}

{$ELSE}
 FreeMem(stackBase,StackSize);
{$ENDIF}

end.