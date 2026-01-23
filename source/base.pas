unit base;
 {$IFDEF FPC}
  {$MODE DELPHI} {$H+}
{$ENDIF}
(***************************************)
(* Copyright (C) 2016, SHIRAISHI Kazuo *)
(***************************************)



interface
uses  Classes, StdCtrls, ComCtrls, SysUtils, IniFiles, Graphics, math, Synedit,
      Types, Forms,Controls, FileUtil,
      {$IFDEF WINDOWS}windows,LazUTF8,{$ENDIF}
      sconsts;

function UTF8ToNative(const s:string):string;
function NativeToUTF8(const s:string):string;

const
   MinInt=-maxint-1;
type
   tpPrecision=(PrecisionNormal,PrecisionHigh,PrecisionNative,PrecisionComplex,PrecisionRational);
const
   PrecisionText:array[tpPrecision]of AnsiString=(s_decimal,s_1000digits,s_Binary,s_complex,s_rational);
   PrecisionLiteral:array[tpPrecision]of AnsiString=('DECIMAL','DECIMAL_HIGH','NATIVE','COMPLEX','RATIONAL');
type
   IOOption=(ioReadWrite,ioCharacterByte,ioSkipRest,ioWhenInside,ioClear,ioNoWait);
   IOOptions=set of IOOption;
    tpRecordSetter=(rsNone,rsBEGIN,rsEND,rsNEXT,rsSAME);
    AccessMode=(amOUTIN,amINPUT,amOUTPUT);
    RecordType=(rcDISPLAY,rcINTERNAL,rcCSV);
    OrganizationType=(orgSEQ,orgSTREAM);
const
    AccessModeLiteral:array[AccessMode]of AnsiString=('OUTIN','INPUT','OUTPUT');
    RecordTypeLiteral:array[RecordType] of ansistring =('DISPLAY','INTERNAL','CSV');
    OrganizationTypeLiteral:array[OrganizationType] of Ansistring=('SEQUENTIAL','STREAM');
    YesNoLiteral:array[false..true]of AnsiString=('NO','YES');
type
   Array4 = array[1..4] of longint;


var
  paramIndex:integer;      //コマンドパラメータのindex；実行中はプログラムファイル名の位置をさす。

type
    EExtype=class(Exception);

var
   extype :integer      =0;
var
   pass     :integer    =0;
   exline   :integer    =0;
   expos    :integer    =0;
   exinsertcount:integer=0;
   helpContext:integer  =0;

const
    bkCancel=0;
    bkStep=1;
    bkStepRestricted=2;                           //ver. 8.1.5.3
    bkContinue=3;
var
    bkDirective:integer=bkCancel;
var
   GraphMode:boolean=false;
   TextMode:boolean=false;
   KeepGraphic:boolean=false;
   KeepText:boolean=false;
   UseCharInput:boolean=false;
   InitialPrecisionMode0:tpPrecision=PrecisionNormal;
   InitialPrecisionMode:tpPrecision=PrecisionNormal;
   PrecisionMode :tpPrecision=PrecisionNormal;
   initialOptionBase:byte=1;
   initialAngleDegrees:boolean=false;
   initialCharacterByte0:boolean=false;
   initialCharacterByte:boolean=false;
   JISFormat:boolean=false;
   //JISSetWindow:boolean=false;
   JISDim:boolean=false;
   JISDef:boolean=false;
   NoSizeZeroArray:boolean=false;
   ForNextBroadOwn:boolean=false;
   ForceFunctionDeclare:boolean=false;
   ForceSubPictDeclare:boolean=false;
   UseTranscendentalFunction:boolean=false;
   DisableAbbreviatedPLOT:boolean=false;
   signiwidthMore:boolean=false;
   MinimalBasic:boolean=false;
   PermitMicrosoft:boolean=false;
   InsertDIMst:boolean=false;
   OptionExplicit:boolean=false;
   AutoIndent:boolean=true;
   GreekIdf:boolean=false;
   KanjiIdf:boolean=false;
const
   ac_let=0;
   ac_input=1;
   ac_using=2;
   ac_next=3;
   ac_string=4;
   ac_remark=5;
   ac_exp=6;
   ac_while=7;
   ac_multi=8;
   ac_end=9;
var
   AutoCorrect:array[0..ac_end]of boolean=(true,true,true,true,true,true,false,false,false,false);
var
   shift_F5:string='LET ';
   shift_F6:string='PRINT ';
   shift_F7:string='OPTION ANGLE DEGREES';
var
  ExecutingNow:boolean=false;
var
  NoInitialize:boolean=false;
  NoRun:boolean=false;
  OpenAndRun:boolean=false;
  NoBackUp:boolean=true;
  TestRegisterID:boolean=false;

{$IFDEF CPU32}
var      initialESP:cardinal;
function stacksize1:integer;assembler;
var      StackLimit1:integer=$700000;
{$ENDIF}
{$IFDEF CPU64}
var      initialRSP:NativeUint;
function stacksize1:NativeInt;assembler;
var      StackLimit1:NativeInt=$D00000;
{$ENDIF}


procedure setexception(t:integer);
procedure setexceptionwith(const s:string; t:integer);

const
      outofmemory=-100;
      StackOverflow=-101;
      VirtualStackOverflow=-102;
      ArraySizeOverflow=-103;
      TooBigRational=-104;
      TextOverFlow=-108;
      SystemErr=-109;



{***}
{FPU}
{***}

//const RoundMost :WORD = $1372; //近い方の値に丸め
const RoundNins :WORD = $177F; //－∞方向に切り捨て
const RoundPlus :WORD = $1B7F; //＋∞方向に切り上げ
const RoundZero :WORD = $1F7F; //０方向の値に丸め

 type CWrec={$IFDEF CPU64}TFPUExceptionMask{$ELSE}Word{$ENDIF};

 procedure SetFPUMask(cw:CWrec);inline;
 function GetFPUmask:CWrec;inline;
 procedure RecoverFloatException; inline;

 const MaskCW={$IFDEF CPU64}
              [exInvalidOp, exDenormalized, exZeroDivide, exOverflow, exUnderflow, exPrecision]
              {$ELSE}$137f{$ENDIF};

 const NormalCW={$IFDEF CPU64}[exDenormalized,exUnderflow, exPrecision]{$ELSE}$1372{$ENDIF};
 var   ControlWord:CWrec=NormalCW;
 var   OriginalCW:CWrec;

//const
//   maxnumber1:array[0..4]of word=($ffff,$ffff,$ffff,$ffff,$7ffe);
//var
//   maxnumber:extended absolute maxnumber1;
const
   maxnumber2:array[0..3]of word=($ffff,$ffff,$ffff,$7fef);
var
   maxnumberDouble:double absolute maxnumber2;


{*****************}
{Utility functions}
{*****************}

function max(a,b:integer):integer;
function min(a,b:integer):integer;

procedure  upper(var s:string);
procedure  lower(var s:string);

function imod(a,b:integer):integer;
function Spaces(n:integer):ansistring;
procedure SelectLine(memo:TSynEdit;i:integer);

//procedure Idle;
//procedure IdleImmediately;
var
   HideSyntaxMenu:boolean=false;
   IniFileReadOnly:boolean=false;


function IniFileName:string;
procedure InitializeEnv;

type
   TMyIniFile=class(TObject)
     Ini:TIniFile;
     section:string;
     readOnly:boolean;
     constructor create(const section1:string);
     destructor  destroy; override;
     function ReadInteger (const Ident: string; Default: integer): integer;
     function ReadString (const Ident: string; const Default: string): string;
     function ReadBool (const Ident: string; Default: Boolean): Boolean;
     procedure   WriteInteger(const Ident: string; Value: integer);
     procedure   Writestring(const Ident: string; const Value:string);
     procedure   WriteBool(const Ident: string; Value: Boolean);
     procedure   RestoreFont(font: TFont);
     procedure   StoreFont(font: TFont);
   end;



type
   TStatusMes=class(TObject)
       procedure Clear;
       function add(const s:string):integer;
       function murge:string;
       function murgeWithOR:string;
       procedure insert(const s:string);
     private
       mes:array[0..3] of string[80];
   end;
var
   statusmes:TStatusmes;




const
  CharNameTBL1:array[0..39] of string[3] =
           ('NUL','SOH','STX','ETX','EOT','ENQ','ACK','BEL','BS','HT',
            'LF' ,'VT' ,'FF' ,'CR' ,'SO' ,'SI' ,'DLE','DC1','DC2','DC3',
            'DC4','NAK','SYN','ETB','CAN','EM' ,'SUB','ESC','FS' ,'GS' ,
            'RS' ,'US' ,'SP' ,'UND','GRA','LBR','VLN','RBR','TIL','DEL');
  CharNameTBL2:array[0..39] of byte =
           (  0, 1, 2, 3, 4, 5, 6, 7, 8, 9,
             10,11,12,13,14,15,16,17,18,19,
             20,21,22,23,24,25,26,27,28,29,
             30,31,32,95,96,123,124,125,126,127);

var
  DrawTimeInterval:integer=10;

function ErrorMes(extype:integer):ansistring;
procedure SetErrorMes(extype:integer; var mes:string; var hc:integer);

{++++++++++++}
implementation
{++++++++++++}

uses
      myutils, mainfrm, texthand, helpctex,rational;

function ErrorMes(extype:integer):ansistring;
var
  hc:integer;
begin
  setErrorMes(extype,result,hc)
end;

procedure SetErrorMes(extype:integer; var mes:string; var hc:integer);
begin
      hc:=0;
      case extype mod 100000 of
           0      : mes:='' ;
        1001      : mes:=s_Extype1001;
        1002      : mes:=s_Extype1002;
        1003      : mes:=s_Extype1003;
        1005      : mes:=s_Extype1005;
        1006      : mes:=s_Extype1006;
        1007      : mes:=s_Extype1007;
        1008      : mes:=s_Extype1008;
        1009      : mes:=s_Extype1009;
        1050..1106: mes:=s_Extype1050;
        1004,
        1010..1049,
        1107..1999: mes:=s_Extype1000;

        2001      : begin mes:=s_Extype2001; hc:=IDH_ARRAY end;
        3000      : MES:=s_Extype3000;
        3001      : mes:=s_Extype3001;
        3002      : mes:=s_Extype3002;
        3003      : mes:=s_Extype3003;
        3004      : mes:=s_Extype3004;
        3005      : mes:=s_Extype3005;
        3006      : mes:=s_Extype3006;
        3007      : mes:=s_Extype3007;
        3008      : mes:=s_Extype3008;
        3009      : MES:=s_Extype3009;
        4000..4299:
               begin
                    mes:=s_Extype4000;
                    case extype mod 100000 of
                      4001: mes:=mes + '(VAL)';
                      4002: mes:=mes + '(CHR$)';
                      4003: mes:=mes + '(ORD)';
                      4004: mes:=mes + '(SIZE)';
                      4005: mes:=mes + '(TAB)';
                      4006: mes:=mes + '(SET MARGIN)';
                      4007: mes:=mes + '(SET ZONEWIDTH)';
                      4008: mes:=mes + '(LBOUND)';
                      4009: mes:=mes + '(UBOUND)';
                      4010: mes:=mes + '(REPEAT$)';
                      4101: mes:=mes + '(SET CLIP)';
                      4102: mes:=mes + '(SET TEXT JUSTIFY)';
                      else
                    end;
               end;
        5001,5002 : begin mes:=s_Extype5001; hc:=IDH_MAT  end;
        6001..6402: mes:=s_Extype6001;
        7001      : mes:=s_Extype7001;
        7003      : mes:=s_Extype7003;
        7004      : mes:=s_Extype7004;
        7101      : mes:=s_Extype7101;
        7102      : mes:=s_Extype7102;
        7103      : mes:=s_Extype7103;
        7301      : begin mes:=s_EXtype7301; hc:=IDH_ERASE end;
        7302      : mes:=s_EXtype7302;
        7303      : mes:=s_EXtype7303;
        7305      : mes:=s_Extype7305;
        7308      : mes:=s_Extype7308;
        7317      : mes:=s_Extype7317;
        7318      : mes:=s_Extype7318;

        7005..7100,7104..7300,7311..7316,7320..7402
                  : mes:=s_Extype7000;
        8001      : mes:=s_Extype8001;
        8011      : mes:=s_Extype8011;
        8012      : mes:=s_Extype8012;
        8013      : mes:=s_Extype8013;
        8101      : mes:=s_Extype8101;
        8002,8003,8102,8103: mes:=s_Extype8002;
        8105      : mes:=s_Extype8105;
        8120      : mes:=s_Extype8120;
        8201      : begin mes:=s_Extype8201; hc:=IDH_PRINT_USING end;
        8202      : begin mes:=s_Extype8202; hc:=IDH_PRINT_USING end;
        8203      : begin mes:=s_Extype8203; hc:=IDH_PRINT_USING end;
        8204      : begin mes:=s_Extype8204; hc:=IDH_PRINT_USING end;
        8401      : mes:=s_Extype8401;
        8402      : mes:=s_Extype8402;
        9000      : mes:=s_Extype9000;
        9002      : mes:=s_Extype9002;
        9003      : mes:=s_Extype9003;
        9004      : mes:=s_Extype9004;
        9102      : mes:=s_Extype9102;
        10002     : mes:=s_Extype10002;
        10004     : mes:=s_Extype10004;
        11004     : begin mes:=s_Extype11004; hc:=IDH_SELECT end;
        11051     : begin mes:=s_Extype11051; hc:=IDH_WINDOW end;
        12004     : mes:=s_Extype12004;
        outofmemory : mes:=s_OutoOfMemory;
        virtualStackOverflow:begin mes:=s_VStackOverflow; hc:=IDH_STACK_LIMIT end;
        stackoverflow:begin mes:=s_StackOverflow; hc:=IDH_STACK_LIMIT; end;
        ArraySizeOverflow: begin mes:=s_ArraySizeOverflow; hc:=IDH_LIMIT end;
        TextOverFlow: mes:=s_OutputOverflow;
        RToNOverflow:begin mes:=S_RToNOverflow; hc:=IDH_RATIONAL end;
        systemErr   : mes:='system error';
        TooBigRational: mes:='Too big rational';
        else          mes:=''   ;
     end;
end;

function UTF8ToNative(const s:string):string;
begin
  {$IFDEF Windows}
  Result:=UTF8ToWinCP(s)
  {$ELSE}
  Result:=s
  {$ENDIF}
end;

function NativeToUTF8(const s:string):string;
begin
  {$IFDEF Windows}
  Result:=WinCPToUTF8(s)
  {$ELSE}
  Result:=s
  {$ENDIF}
end;

procedure  upper(var s:string);
var
     i:integer;
begin
     i:=0;
     while i<length(s) do
        begin
            inc(i);
            if s[i] in ['a'..'z'] then
                   s[i]:=chr(ord(s[i])-32)
            else
                   ReadMBC(i,s); //if IsDBCSLeadByte(byte(s[i])) then inc(i);
        end;
end;

procedure  lower(var s:string);
var
     i:integer;
begin
     i:=0;
     while i<length(s) do
        begin
            inc(i);
            if s[i] in ['A'..'Z'] then
                   s[i]:=chr(ord(s[i])+32)
            else
                   ReadMBC(i,s); //if IsDBCSLeadByte(byte(s[i])) then inc(i);
        end;
end;


function max(a,b:integer):integer;
begin
  if a>b then
     max:=a
  else
     max:=b
end;

function min(a,b:integer):integer;
begin
  if a>b then
     min:=b
  else
     min:=a
end;

{$IFDEF CPU32}
function stacksize1:integer;assembler;
asm
   mov    eax,initialESP
   sub    eax,esp
end;
{$ENDIF}
{$IFDEF CPU64}
function stacksize1:NativeInt;assembler;
asm
   mov    rax,[initialRSP+rip]
   sub    rax,rsp
end;
{$ENDIF}

{**************}
{error handling}
{**************}

procedure setexception(t:integer);
begin
  setexceptionwith('',t)
end;

procedure setexceptionwith(const s:string; t:integer);
begin
    extype :=t;
    statusmes.add(s);
    raise EExtype.create('');
end;


function imod(a,b:integer):integer;
var
n:integer;
begin
   if a>=0 then
      imod:=a mod b
   else
      begin
         n:=a mod b;
         if n<>0 then inc(n,b);
         imod:=n
      end;
end;

function Spaces(n:integer):ansistring;
var
  i:integer;
  s:ansistring;
begin
  s:='';
  for i:=1 to n do s:=s+' ';
  Spaces:=s
end;

procedure SelectLine(memo:TSynEdit;i:integer);
begin
   with memo do
      begin
         (memo.owner as TForm).BringToFront;
         CaretX:=1;
         CaretY:=i+1;
         SelectLine;   //SelLength:=q-p -Length(EOL);
      end;
 end;


{********}
{INI File}
{********}

function IniFileName:string;
begin
{$IFNDEF Win32}
   result:=GetEnvironmentVariable('HOME') + '/.basic.ini'
{$ELSE}
   result:= ChangeFileExt(Application.ExeName,'.ini')
{$ENDIF}
end;


constructor TMyIniFile.create(const section1:string);
begin
   inherited create;
   Ini:=TIniFile.create(iniFileName);
   section:=section1;
   ReadOnly:=NoInitialize or IniFileReadOnly;
end;

destructor TMyIniFile.destroy;
begin
   if Ini<>nil then ini.free;
   section:='';
   inherited destroy;
end;


function TMyIniFile.ReadInteger (const Ident: string; Default: integer): integer;
begin
  if ini<>nil then
    result:=ini.ReadInteger(section,ident,default)
end;

function TMyIniFile.ReadString (const Ident: string; const Default: string): string;
begin
   if ini<>nil then
    result:=ini.ReadString(section,ident,default)
end;

function TMyIniFile.ReadBool (const Ident: string; Default: Boolean): Boolean;
begin
  if ini<>nil then
    result:=ini.ReadBool(section,ident,default)
end;

procedure   TMyIniFile.WriteInteger(const Ident: string; Value: integer);
begin
   if not readonly then
     if ini<>nil then
      try
       ini.WriteInteger(section,ident,value)
      except
      end
end;

procedure   TMyIniFile.Writestring(const Ident: string; const Value:string);
begin
   if not readonly then
     if ini<>nil then
       try
        ini.WriteString(section,ident,value)
       except
       end
end;

procedure   TMyIniFile.WriteBool(const Ident: string; Value: Boolean);
begin
   if not readonly then
     if ini<>nil then
      try
       ini.WriteBool(section,ident,value)
      except
      end
end;

procedure   TMyIniFile.RestoreFont(font: TFont);
begin
 with font do
   begin
      Charset:=TFontCharset(ReadInteger('FontCharset',Ord(charset)));
      Name:=ReadString('FontName',Name);
      Size:=ReadInteger('FontSize',Size);
      //if size=0 then size:=7;         // 2013.2.23 ver 0.6.3.9
      Pitch:=TFontPitch(ReadInteger('FontPitch',Ord(Pitch)));
   end;
end;

procedure   TMyIniFile.StoreFont(font: TFont);
begin
  with font do
   begin
      WriteInteger('FontCharset',Ord(charset));
      WriteString('FontName',Name);
      WriteInteger('FontSize',Size);
      WriteInteger('FontPitch',Ord(Pitch));
   end;
end;


procedure ReadIniFile;
var
   IniFile:TMyIniFile;
begin
    IniFile:=TMyIniFile.create('Frame');
    with IniFile do
       begin
         byte(InitialPrecisionMode0):=ReadInteger('OptionArithmetic',byte(InitialPrecisionMode0));
         InitialOptionBase:=ReadInteger('OptionBase',InitialOptionbase);
         InsertDIMst:=      ReadBool('InsertDIM',InsertDIMst);
         PermitMicrosoft:=  ReadBool('Microsoft',PermitMicrosoft);
         MinimalBasic:=     ReadBool('MinimalBasic',MinimalBasic);
         IniFileReadOnly:=  ReadBool('IniFileReadOnly',IniFileReadOnly);
         NoRun:=            ReadBool('NoRun',NoRun);
         AutoIndent:=       ReadBool('AutoIndent',AutoIndent);
         OptionExplicit:=   ReadBool('OptionExplicit',OptionExplicit);
         shift_F5:=ReadString('Shift_F5',Shift_F5);
         shift_F6:=ReadString('Shift_F6',Shift_F6);
         shift_F7:=ReadString('Shift_F7',Shift_F7);
         TestRegisterID:=   ReadBool('TestRegisterID',TestRegisterID);
       end;
     IniFile.free;
end;

procedure WriteIniFile;
var
   IniFile:TMyIniFile;
begin
      IniFile:=TMyIniFile.create('Frame');
      with IniFile do
      begin
          WriteBool('AutoIndent',AutoIndent);
          WriteBool('OptionExplicit',OptionExplicit);
          WriteString('Shift_F5',Shift_F5);
          WriteString('Shift_F6',Shift_F6);
          WriteString('Shift_F7',Shift_F7);
      end;
      IniFile.free;
end;

procedure InitializeEnv;
begin
  if Application.MessageBox(PChar(s_InitEnv),AppTitle,mb_OKCANCEL)=IDOk then
  begin
    IniFileReadOnly:=true;
    DeleteFile(PChar(IniFileName));
  end;
end;


{**********}
{TStatusMes}
{**********}



procedure TStatusmes.Clear;
var
   i:integer;
begin
   for i:=0 to 3 do
       mes[i]:='';
end;

function TStatusMes.add(const s:string):integer;
var
   i:integer;
begin
   result:=-1;
   for i:=0 to 3 do
      if mes[i]=s then exit;
   result :=0;
   while (result<4) and (mes[result]<>'') do inc(result);
   if result<4 then mes[result]:=s;
end;


function TStatusMes.murge:string;
var
   i:integer;
begin
   result:=mes[0];
   for i:=1 to 3 do
     if mes[i]<>'' then result:= result + EOL + mes[i];
end;

function TStatusMes.murgeWithOR:string;
var
   i:integer;
begin
   if mes[0]=''  then
      result:='Syntax Error'
   else
   begin
     result:=mes[0];
     for i:=1 to 3 do
       if mes[i]<>'' then
          result:=result +s_or + mes[i];
   end;
end;


procedure TStatusMes.insert(const s:string);
begin
    mes[0]:=s + EOL + mes[0]
end;




function FPUerState:bytebool;assembler;
asm
   fstsw  ax
   and    ax, 0Dh
   FCLEX
end;




procedure SetFPUMask(cw:CWrec);inline;
begin
  {$IFDEF CPU64}
  ClearExceptions(False);
  SetExceptionMask(cw)
  {$ELSE}
  Set8087CW(cw)
  {$ENDIF}
end;

function GetFPUmask:CWrec;inline;
begin
  {$IFDEF CPU64}
  result:=GetExceptionMask
  {$ELSE}
  result:=Get8087CW
  {$ENDIF}
end;

procedure RecoverFloatException; inline;
begin
  ClearExceptions(False);
  SetFPUMask(NormalCW);
end;



initialization
SetRoundMode(rmNearest);
{$IFDEF Windows}
originalCW:=getFPUMask;
{$ELSE}  //Linux, Mac
 originalCW:=MaskCW;
 SetFPUMask(OriginalCW); //Linux,Mac では，FPU割り込みを無効化しておく。
{$ENDIF}
ControlWord:=OriginalCW;

  paramIndex:=1;
  while (ParamIndex<=ParamCount) and (copy(ParamStr(paramIndex),1,1)='-')  do
       begin
          if ParamStr(paramIndex)='-NI' then NoInitialize:=true;
          if ParamStr(paramIndex)='-OR' then OpenAndRun:=true;
          if ParamStr(paramIndex)='-NR' then NoRun:=true;
          inc(paramIndex);
       end;

  readIniFile;

 //if c_Language='E' then
 //   initialCharacterByte0:=true;

  statusmes:=TStatusMes.create;


finalization
  WriteIniFile;
  statusmes.free;


end.
