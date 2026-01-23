unit myutils;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

(***************************************)
(* Copyright (C) 2007, SHIRAISHI Kazuo *)
(***************************************)


interface
uses Dialogs,StdCtrls,SynEdit,
{$IFDEF FPC}
  LCLType;
{$ELSE}
  Windows;
{$ENDIF}

  function LineFromChar(memo:TSynEdit; n:integer):integer; //line index from char pos
  function LineIndex(memo:TSynEdit; n:integer):integer;    //line index to char pos
  procedure ReadMBC(var i:integer; const s:AnsiString);
  function isDeviceName(const FName:string):LongBool;
  procedure NotAvailableMessage;

const
{$IFDEF FPC}
  mb_YesNo=LCLType.mb_YesNo;
  mb_OKCANCEL=LCLType.mb_OKCANCEL;
  IDOk=LCLType.IDOk;
  IDYES=LCLType.IDYES;
  vk_F1=LCLType.vk_F1;
  vk_F5=LCLType.vk_F5;
  vk_F6=LCLType.vk_F6;
  vk_F7=LCLType.vk_F7;
  vk_F8=LCLType.vk_F8;
  vk_insert=LCLType.vk_insert;
  TRANSPARENT=LCLType.TRANSPARENT;
  OPAQUE=LCLType.OPAQUE;
  OEM_CHARSET=LCLType.OEM_CHARSET;
{$ELSE}
  mb_YesNo=Windows.mb_YesNo;
  mb_OKCANCEL=Windows.mb_OKCANCEL;
  IDOk=Windows.IDOk;
  IDYES=Windows.IDYES;
  vk_F1=Windows.vk_F1;
  vk_F5=Windows.vk_F5;
  vk_F6=Windows.vk_F6;
  vk_F7=Windows.vk_F7;
  vk_F8=Windows.vk_F8;
  vk_insert=Windows.vk_insert;
  TRANSPARENT=Windows.TRANSPARENT;
  OPAQUE=Windows.OPAQUE;
  OEM_CHARSET=Windows.OEM_CHARSET;
{$ENDIF}

implementation
uses
  Types,
{$IFDEF UNIX}
   baseUnix,Unix,UnixType,
{$ENDIF}
{$IFDEF Linux}
  {$IFDEF CPU32}LibC,{$ENDIF}
{$ENDIF}
   SysUtils,
   SConsts,Base;





function LineFromChar(memo:TSynEdit; n:integer):integer; //line index from char pos
var
   svSelStart:integer;
begin
  with memo do
  begin
    Lines.BeginUpdate;
    svSelStart:=SelStart;
    SelStart:=n;
    //Sellength:=0;
    result:=CaretY-1;
    SelStart:=svSelStart;
    Lines.EndUpdate;
  end;
end;

function LineIndex(memo:TSynEdit; n:integer):integer;    //line index to char pos
var
  svSelStart:integer;
begin
  result:=0;
  with memo do
  begin
    Lines.BeginUpdate;
    svSelStart:=SelStart;
    CaretX:=1;
    CaretY:=n+1;
    result:=selStart;
    SelStart:=svSelStart;
    lines.endUpdate;
  end;
end;



(*
function  isDBCSLeadByte(ch:byte):boolean;
  begin
     result:=char(ch) in LeadBytes;
  end;

procedure ReadMBC(var i:integer; const s:AnsiString);
begin
   if isDBCSLeadByte(byte(s[i])) then
         inc(i);
end;
*)

  //assume UTF-8
procedure ReadMBC(var i:integer; const s:AnsiString);
var
   b:byte;
begin
   b:=byte(s[i]);
   if b>=$c0 then
      if b<$e0 then
         inc(i)
      else if b<$f0 then
         inc(i,2)
      else if b<$f8 then
         inc(i,3)
      else if b<$fc then
         inc(i,4)
      else if b<$fe then
         inc(i,5);
end;

 procedure NotAvailableMessage;
begin
   Messagedlg('This feature not available yet.' ,mterror,[mbok],0)
end;


{$IFDEF Windows}
type
  LPCSTR  = PChar;
  LPSTR   = Pchar;
function QueryDosDevice(lpDeviceName:LPCSTR; lpTargetPath:LPSTR; ucchMax:DWORD):DWORD; stdcall; external 'kernel32' name 'QueryDosDeviceA';

function isDeviceName(const FName:string):LongBool;
var
   buf:array[0..255] of char;
   s:ansistring;
   w:DWORD;
begin
   s:=Utf8ToNative(Fname);
   w:=QueryDosDevice(PChar(s),@buf,255);
   result:=(FName='PRN') or (w>0)
   end;
{$ELSE}
{$IFDEF Unix}
function isTrueFile(const s:string):boolean;
 var
  buf: Stat;
begin
  result:=false;
  if (FPSTAT(PChar(s),buf)=0)                    // 0.6.4.6
  and ((buf.st_mode and STAT_IFMT)=STAT_IFREG)then
    result:=true
end;

function isDeviceName(const FName:string):LongBool;
begin
   result:=not isTrueFile(FName)
end;
{$ELSE}
function isDeviceName(const FName:string):LongBool;
begin
   result:=false;  //dummy
end;
{$ENDIF}
{$ENDIF}


{$IFDEF LINUX}
{$IFDEF CPU32}
procedure SetSysStackSize;
var
  rlim:rlimit;
begin
  if (getrlimit(RLIMIT_STACK, @rlim)=0 ) then
           StackLimit1:=rlim.rlim_cur-$00100000;

end;
{$ELSE}
procedure SetSysStackSize;
begin
           StackLimit1:=$00800000-$00100000;
end;
{$ENDIF}
{$ELSE}
procedure SetSysStackSize;
begin
           StackLimit1:=$00800000-$00100000;
end;
{$ENDIF}


begin

 SetSysStackSize
end.

