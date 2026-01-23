unit textfile;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}
(***************************************)
(* Copyright (C) 2017, SHIRAISHI Kazuo *)
(***************************************)


interface
uses  Classes, LCLVersion, Dialogs, SysUtils,Controls,Forms,ComCtrls, Clipbrd, fileutil ,
     {$IFDEF Windows} Windows, {$ENDIF}
     textfrm,base,variabl;
type
    string1=string[1];
    Fnamestr=AnsiString;


    TTextDevice=class
       Name:AnsiString;
       zonewidth:integer;
       margin:integer;
       TabCount:integer;
       leng:integer;
       EOL:string[2];
       AMode:AccessMode;
       OrgType:OrganizationType;
       isopen:boolean;
       EchoOn:boolean;
       constructor create;
       procedure open(FName:FNameStr; am:AccessMode; og:OrganizationType; len:integer);virtual;
       procedure close;virtual;
       procedure erase(rs:tpRecordSetter;insideofwhen:boolean);virtual;
       procedure setpointer(rs:tpRecordSetter; insideofWhen:boolean);virtual;
       procedure AppendStr(const s:AnsiString);virtual;
       procedure Tab(n:integer);
       procedure NewZone;
       procedure NewLine;
       procedure NewLineifneed;
       procedure flush;virtual;abstract;
       procedure WBuffClear;
       procedure WriteSeparator(ClaimNewLine:boolean);
       procedure setmargin(n:integer);
       procedure setzonewidth(n:integer);
       procedure setEndOfLine(const s:string);
       procedure setCoding(const s:string);virtual;
       function askmargin:integer;
       function askzonewidth:integer;
       function AskCharacterPending:integer;virtual;
       function AskFileSize:int64;virtual;
       procedure CheckForInput(option:IOoptions);
       procedure CheckForOutput(option:IOoptions);
       procedure initInput(LineNumb:integer;const prom:AnsiString; TimeLimit:double);virtual;
       procedure SetPrompt(const prom:ansistring);virtual;
       procedure CharacterInput(var s:AnsiString; option:IOoptions );virtual;abstract;
       function ReadData(vc:TVarList; count:integer; cont:boolean; option:IOoptions):boolean;
       function InputData(vc:TVarList; count:integer; cont:boolean; option:IOoptions):boolean;
       procedure LineInput(vc:TVarList; count:integer; option:IOoptions);
       procedure InputVariLen(vc:TVarList; var count:integer; option:IOoptions);
       function DataFoundForRead:boolean;virtual;
       function DataFoundForWrite:boolean;virtual;
       function choose(i1,i2,i3,i4:integer):integer;virtual;abstract;
       function RecType:RecordType;virtual;
       function Datum:AnsiString;virtual;
       function askpointer:Ansistring;virtual;
       function TrueFile:boolean;virtual;
       function AskTypeAhead:boolean;virtual;
     private
           WBuff:AnsiString;
           CurrentChar:string1;
           RBuff:AnsiString;
           rcp:integer;
           index:integer;
           index0:integer;
           prom2:ansistring;
       function readline:boolean;virtual; abstract;
       procedure saveFilePos;virtual;
       function readNewLine:boolean;virtual;
       procedure NextChar;virtual;
       function punctuate:boolean;virtual;
       function readEOL:boolean;virtual;
       function ReadItem(var s:AnsiString; var quoted:boolean):boolean; virtual;
       procedure ReInput ;virtual;
       procedure echo;virtual;
       function ReadByte:char;virtual;abstract;
     public
   end;

    TConsole=class(TTextDevice)
       constructor create;
       destructor destroy;override;
       procedure open(FName:FNameStr; am:AccessMode; og:OrganizationType; len:integer);override;
       procedure flush;override;
       procedure initInput(LineNumb:integer;const prom:AnsiString; TimeLimit:double);override;
       procedure SetPrompt(const prom:ansistring);override;
       procedure CharacterInput(var s:AnsiString; option:IOoptions);override;
       function choose(i1,i2,i3,i4:integer):integer;override;
       function AskCharacterPending:integer;override;
       function AskTypeAhead:boolean;override;
       procedure DataRequest;
    private
       function readline:boolean;override;
       procedure  ReInput ;override;
       procedure echo;override;
     public
    end;

type
    StringFunction =function(const s:String):String;

type
    TTextfile=class(TTextDevice)
           CharFile:TFileStream;
           isDevice:boolean;
       constructor create;
       destructor destroy;override;
       procedure open(FName:FNameStr; am:AccessMode; og:OrganizationType; len:integer );override;
       procedure close;override;
       procedure erase(rs:tpRecordSetter; insideofwhen:boolean);override;
       procedure setpointer(rs:tpRecordSetter; insideofWhen:boolean );override;
       procedure CharacterInput(var s:AnsiString; option:IOoptions);override;
       procedure flush;override;
       procedure setCoding(const s:string);override;
       function DataFoundForRead:boolean;override;
       function DataFoundForWrite:boolean;override;
       function choose(i1,i2,i3,i4:integer):integer;override;
       function askpointer:Ansistring;override;
       function TrueFile:boolean;override;
       function AskFileSize:Int64;override;
       function AskCharacterPending:integer;override;
       function AskTypeAhead:boolean;override;
    private
           exFilePos:Int64;
           importing,exporting:StringFunction;
       function readline:boolean;override;
       procedure saveFilePos;override;
       function ReadByte:char;override;
   end;

    TInternalFile=class(TTextFile)
       function RecType:RecordType;override;
       procedure AppendStr(const s:AnsiString);override;
       procedure CharacterInput(var s:AnsiString; option:IOoptions);override;
       function Datum:AnsiString;override;
       function choose(i1,i2,i3,i4:integer):integer;override;
       function AskCharacterPending:integer;override;
       function AskTypeAhead:boolean;override;
       //procedure setCoding(const s:string);override;
    private
       function punctuate:boolean;override;
       function readline:boolean;override;         //2007.5.7
       //procedure NextChar;override;              //2007.5.7
       //function readNewLine:boolean;override;    //2007.5.7
       //function readEOL:boolean;override;        //2007.5.7
   end;

    TCSVfile=class(TInternalFile)
       function RecType:RecordType;override;
    private
       function punctuate:boolean;override;
    end;


   TDataSeqV2 = class(TTextDevice)
        DataList:TStringList;
        DataPointer:NativeInt;
        LabelNumbers:TStringList;
      constructor create;
      destructor destroy;override;
      procedure setLabelNumber(labelNumber:integer);
      procedure Restore(LabelNumber:integer);
      procedure pushDataPointer;
      procedure PopDataPointer;
      function DataFoundForRead:boolean;override;
      function choose(i1,i2,i3,i4:integer):integer;override;
     private
      function ReadItem(var s:AnsiString; var quoted:boolean):boolean;override;
      function readNewLine:boolean;override;
      function punctuate:boolean;override;
      function readEOL:boolean;override;
    public
   end;

    TLocalPrinter=class(TTextDevice)
           TextBuff:AnsiString;
       constructor create;
       destructor destroy;override;
       procedure open(FName:FNameStr; am:AccessMode; og:OrganizationType; len:integer);override;
       procedure close;override;
       procedure flush;override;
       procedure erase(rs:tpRecordSetter; insideofwhen:boolean);override;
       procedure CharacterInput(var s:AnsiString; option:IOoptions);override;
       function choose(i1,i2,i3,i4:integer):integer;override;
     private
       procedure  closeexec;
    end;


var
  console:TConsole=nil;
  LocalPrinter:TLocalPrinter=nil;

{******************}
{TChannelCollection}
{******************}
type
    PTextDevice=class(TVar)
         ttext:TTextDevice;
         destructor destroy;override;
         function NewElement:TVar;override;
    end;

var PConsole:PTextDevice=nil;       //2008.11.3


implementation
uses
     myutils,MainFrm,texthand,inputdlg,struct,charinp,sconsts,printdlg,
     MyThread;
type
ECommError = class(Exception);


function TestCtrlBreak(var svCtrlBreakHit:boolean):boolean;
begin
   result:=false;
   if ctrlBreakHit then
      if (ThreadMessageDLG(s_TestCtrlBreak,mtCustom,[mbYes,mbNo],0)=mrYes) then
        begin
           raise EStop.create;
           result:=true
        end
      else
        begin
          ctrlBreakHit:=false;
          svCtrlBreakHit:=true;
        end;

end;

const
  BOM=#239#187#191;

function UTF8TOANSI(const s:string):string;
begin
   if COPY(s,1,3)=BOM then
      result:=UTF8TOANSI(COPY(s,4,Length(s)-3))
   else
      result:=System.Utf8ToAnsi(s)
end;



function Identity(const s:string):string;
begin
  result:=s
end;

constructor TTextDevice.create;
begin
    inherited create;
    name:='';
    margin:=MaxInt;
    zonewidth:=24;
    WBuff:='';
    TabCount:=0;
    leng:=maxint;
    EOL:=SConsts.EOL;

end;


procedure TTextDevice.open(FName:FNameStr; am:AccessMode; og:OrganizationType; len:integer);
begin
end;

procedure TTextDevice.close;
begin
end;

procedure TTextDevice.erase(rs:tpRecordSetter; insideofwhen:boolean);
begin
   //if insideofwhen then setexception(7311);
    ReportException(InsideOfWhen , 7311);
end;


procedure TTextDevice.setpointer(rs:tpRecordSetter; insideofWhen:boolean);
begin
   if (rs<>rsNone) then
        ReportException(InsideOfWhen , choose(7002,7002,7205,7205));
end;

procedure TTextDevice.saveFilePos;
begin
end;

procedure TtextDevice.appendStr(const s:AnsiString);
begin
   if (TabCount>0) and (TabCount + length(s) > margin) then
      newLine;
   WBuff:=WBuff + s;
   TabCount:=TabCount+Length(s);
end;

function spaces(n:integer):ansistring;
const
   space32='                                ';
var
  q,r:integer;
begin
  result:='';
  if n>0 then
    begin
      q:=n div 32;
      r:=n mod 32;
      while q>0 do
          begin
             result:=result+space32;
             dec(q)
          end;
      result:=result + copy(space32,1,r);
    end;
end;

procedure TTextDevice.Tab(n:integer);
begin
   if (n<1) then
      n:=1      ;
   n:=(n-1) mod margin {+1} ;
   if TabCount>n then newline;
   appendstr(spaces(n-TabCount));
end;

procedure TTextDevice.setmargin(n:integer);
begin
    if RecType<>rcDisplay then setexception(7312);
    if aMode=amInput then setexception(7313);
    if n>=zonewidth then
       margin:=n
    else
       setexceptionwith(s_MarginError,4006);
end;

procedure TTextDevice.setzonewidth(n:integer);
begin
    if RecType<>rcDisplay then setexception(7312);
    if aMode=amInput then setexception(7313);
    if (n<=margin) and (n>0) then
        zonewidth:=n
    else
       setexceptionwith(s_ZoneWidthError,4007);
end;

procedure TTextDevice.setEndOfLine(const s:string);
begin
  if Length(s) in [1,2] then
     EOL:=s;
end;

procedure TTextDevice.setCoding(const s:string);
begin
  setexception(8999)
end;


procedure TTextDevice.NewZone;
var
   i,j:integer;
begin
   i:=TabCount mod zonewidth;
   if i>0 then
      begin
          j:=zonewidth-i;
          if TabCount+j<margin then
             appendstr(spaces(j))
          else
            newline     ;
      end;
end;

procedure TTextDevice.NewLine;
begin
   WBuff:=WBuff +  EOL ;
   flush;
   TabCount:=0;
end;

procedure TTextDevice.NewLineIfNeed;
begin
    if TabCount>0 then
       NewLine;
end;

procedure TTextDevice.WriteSeparator(ClaimNewLine:boolean);
begin
    if (OrgType=OrgStream) or ClaimNewLine then
        newline
    else
        AppendStr(',')
end;

function TTextDevice.askmargin:integer;
begin
 askmargin:=margin
end;

function TTextDevice.askZonewidth:integer;
begin
 askzonewidth:=zonewidth
end;

(*
var
cache:array[0..255{65535}]of ansistring;
point0:byte{word}=0;
point1:byte{word}=0;
len:integer=0;

procedure drop(s:ansistring);
begin
     if len+length(s)>$10000{64KB} then
        textoutExec;
     cache[point0]:=s;
     inc(point0);
     len:=len+length(s);
     if byte{word}(point1-point0)=1 then
        textoutExec;
end;

procedure TextoutExec;
var
  s:AnsiString;
  c:PAnsiChar;
  p0,p1:byte{word};

begin
    if point0=point1 then exit;
     p0:=point0;
     p1:=point1;
     point1:=point0;
     setlength(s,len+1);
     len:=0;
     //c:=Pchar(s);
     c:=@s[1];
     while p1<>p0 do
          begin
            c:=StrEcopy(c,PChar(cache[p1]));
            cache[p1]:='';
            inc(p1);
          end;
     TextForm.AppendString(s);
end;
*)

(*
procedure TextoutExec;
var
  s:string;
begin
     while point1<>point0 do
     begin
        s:=s+ cache[point1];
        cache[point1]:='';
        inc(point1);
     end;
     TextForm.AppendString(s);
end;
*)




procedure TConsole.flush;
begin
  TextForm.drop(Wbuff); //TextForm.AppendString(WBuff);
  WBuffClear;
 end;

procedure TTextDevice.WBuffClear;
begin
   WBuff:='';
end;

procedure TTextDevice.CheckForInput(option:IOoptions);
begin
    if not isopen then  setexception(7004);
    if not (ioReadWrite in option) and (rectype<>rcDisplay) then setexception(7318);
    if Amode=amOutput then  setexception(7303);
    if (orgType=orgStream) and (ioSkipRest in option) then setexception(7321);
end;

procedure TTextDevice.CheckForOutput(option:IOoptions);
begin
    if not isopen then  setexception(7004);
    if not (ioReadWrite in option) and (rectype<>rcDisplay) then setexception(7317);
    if Amode=amInput then  setexception(7302);
end;

procedure TTextDevice.initInput(LineNumb:integer;const prom:AnsiString; TimeLimit:double);
begin
end;

procedure TTextDevice.SetPrompt(const prom:ansistring);
begin
end;

function TTextDevice.ReadData(vc:TVarList; count:integer; cont:boolean; option:IOoptions):boolean;
var
   index:integer;
   s:ansiString;
   q:boolean;
begin
    ReadNewLine;
    result:=false;
    if extype<>0 then exit ;
    result:=true;
    index:=0;
    try
       while (index<count) and (extype=0)
           and ReadItem(s,q)
           and TVar(vc.Items[index]).readDataV2(s,q,(self is TInternalFile) and (Orgtype<>orgSTREAM))
           and  ((index=count-1) and not cont or punctuate)  do
                   inc(index);
    except
      on E:EExtype do
         //   if (extype=8001) or (extype=8101) then raise;        //Ver. 8.0.1.3
         //extypeの値を残す
    end;
    if extype=8001 then  begin result:=false; exit end;            //Ver. 8.0.1.3
    if (extype=8101) then
       if (s='') and (self is TInternalFile)  then  //Ver. 8.0.1.3
         with (self as TInternalFile).charfile do
            if (Orgtype<>orgSTREAM)or(position<size) then
               begin extype:=8120; result:=false; exit end
             else
               begin extype:=8011; result:=false; exit end
        else setexception(extype);

    if not cont and (ioSkipRest in option) then
               while (CurrentChar<>'')and  not(CurrentChar[1] in [#13, #10]) do
                                                                       nextchar;
    if (extype div 10) =100 then
               begin extype:=choose(1006,1008,1008,1008); {prom2:='overflow '} end;
    if extype=1106 then
               begin extype:=choose(1053,1105,1105,1105); {prom2:='overflow '} end;
    if extype=4001 then
                extype:=8101;   // choose(8101,8101,8101,8120);
    if extype=8102 then
                extype:=8105;
    if extype>0 then setexception(extype);


    if index<count then
                     setexception(8012);

    if not cont and not ReadEOL then
       if  CurrentChar=',' then
                      setexception(8013)
       else
                      setexception(8105);

end;

function TTextDevice.InputData(vc:TVarList; count:integer; cont:boolean; option:IOoptions):boolean;
var
   s:ansiString;
   q:boolean;
begin
    if rectype<>rcDisplay then setexception(7318);
    ReadNewLine;
    result:=false;
    if extype<>0 then exit ;
    result:=true;

    index0:=-1;
    index:=0;
    repeat
       prom2:='';
       try
         while (index<count) and (extype=0)  and
             ReadItem(s,q) and TVar(vc.Items[index]).readDataV2(s,q,false)
              and ((index=count-1) and not cont or punctuate)  do
                      inc(index)   ;
       except
         // extypeの値を残す
       end;
       if not cont and (ioSkipRest in option) then
          while CurrentChar<>'' do nextchar;
       if (extype div 10)=100 then
             begin extype:=choose(1006,1007,1008,1008); prom2:='overflow ' end
       else if extype=1106 then
             begin extype:=choose(1053,1054,1105,1105); prom2:='overflow ' end
       else if (extype=4001) or (extype=8101) then
             begin extype:=choose(8101,8103,8101,8120); prom2:='syntax error' end
       else if (extype=0) and not cont and not ReadEOL then
            begin prom2:='extra data'; extype:=choose(8013,8003,8013,8013) end
       else if (extype=0) and (index<count) then
             begin prom2:='too few data'; extype:=choose(8012,8002,8012,8012) end;
       if (prom2<>'') and not (ioWhenInside in option) then
                                                            ReInput;
    until (index=count) or (extype<>0);
    //echo;
    if extype>0 then setexception(extype);
end;

procedure TTextDevice.InputVariLen(vc:TVarList; var count:integer; option:IOoptions);
var
   s:ansiString;
   q:boolean;
begin
    if rectype<>rcDisplay then setexception(7318);

    ReadNewLine;
    index0:=-1;
    index:=0;
    repeat
         prom2:='';
           repeat
              if (vc.count<=index) then
                    setexception(5001);
              try
                if  ReadItem(s,q) and TVar(vc.Items[index]).readDataV2(s,q,false) then
                  begin
                   count:=index+1;
                   if punctuate then
                    inc(index);
                  end;
              except
                 // extypeの値を残す
              end;
           until (CurrentChar='') or (extype<>0);

         if (extype>=1000) and (extype<1010) then
                     begin extype:=1007; prom2:='overflow ' end
         else if extype=1106 then
             begin extype:=choose(1053,1054,1105,1105); prom2:='overflow ' end
         else if extype=8101 then
               begin extype:=choose(8101,8103,8101,8120); prom2:='syntax error'  end
         else if currentchar<>'' then
               begin prom2:='extra data'; extype:=choose(8105,8102,8105,8120) end;
         if (prom2<>'') and not (ioWhenInside in option) then
               ReInput ;
    until (count=index+1) and (currentchar='') or (extype<>0);
    if extype>0 then setexception(extype);
end;

procedure TTextDevice.LineInput(vc:TVarList; count:integer; option:IOoptions);
var
    s:boolean;
begin
    if rectype<>rcDisplay then setexception(7318);
    s:=true;
    index:=0;
    while index<count do
        begin
          prom2:='';
          RBuff:='';
          repeat
            extype:=0;
            s:=s and readline;
            try
              if s then TVar(vc.items[index]).read(RBuff);
            except
              if extype=1106 then
                extype:=choose(1053,1054,1105,1105);
              prom2:='overflow';
            end;
          until extype<>1054;
          inc(index);
        end;
    if extype>0 then setexception(extype);
end;

function TTextDevice.rectype:RecordType;
begin
   rectype:=rcDisplay
end;

function TTextDevice.Datum:AnsiString;
begin
  result:='UNKNOWN'
end;

function TTextDevice.askpointer:AnsiString;
begin
  result:='UNKNOWN'
end;

function TTextDevice.TrueFile:boolean;
begin
   result:=false
end;


constructor TConsole.create;
begin
    inherited create;
    //point0:=0;
    //point1:=0;
    //CacheInit;
    isopen:=true;
    margin:=InitialMargin;
    EchoOn:=true;
    with TextForm do
      begin
         if keepText then
             //SendMessage(memo1.Handle,EM_SETSEL,maxint,maxint)
             memo1.selstart:=length(memo1.lines.Text)   //要検討
         else
             memo1.clearAll;
         setReadOnly(true);
         if TextMode then
            begin
                   show;
                   WindowState:=wsNormal;
                   SetFPUMask(OriginalCW);
                   Application.ProcessMessages;
                   BringToFront;
                   Application.ProcessMessages;
            end
         else
            hide;    //WindowState:=wsMinimized;
      end;
end;

destructor TConsole.destroy ;
begin
   TextForm.textoutexec;
   with TextForm.memo1 do
      begin
         enabled:=true;
         if textmode then
             repaint;
      end;
   inherited destroy;
end;

procedure TConsole.open(FName:FNameStr; am:AccessMode; og:OrganizationType; len:integer);
begin
   setexception(7003);
end;


procedure TConsole.initInput(LineNumb:integer;const prom:AnsiString; TimeLimit:double);
begin
    InputDialog.LineNumber:=LineNumb;
    InputDialog.TimeLimit:=TimeLimit;
    CharInput.LineNumber:=LineNumb;
    CharInput.TimeLimit:=TimeLimit;
    RBuff:='';
    CurrentChar:='';
    rcp:=0;
    setPrompt(prom);
    prom2:='';
end;

procedure TConsole.SetPrompt(const prom:ansistring);
begin
     InputDialog.Label1.Caption:=prom;
     CharInput.label1.caption:=prom;
end;

function TConsole.ReadLine:boolean;
begin
   DataRequest;
   ReadLine:= (base.extype=0)
end;

procedure  TTextDevice.ReInput;
begin
end;

procedure  TConsole.ReInput;
begin
   extype:=0;
   index:=index0 + 1 ;
   DataRequest;
   rcp:=1;
   nextchar;
end;

Procedure TTextDevice.echo;
begin
end;

Procedure TConsole.echo;
begin
    if EchoOn then
      begin
          if prom2<>'' then
          begin
            appendstr(prom2);
            newline
          end;
          appendstr(InputDialog.Label1.Caption);
          appendStr(Rbuff);
          newline
      end;
end;

procedure  TConsole.DataRequest;
label
  L1;
begin
    sleep(50);
    with InputDialog do
       begin
         Edit1.Text:=RBuff;
         Label2.caption:=prom2;
 L1:    //  Execute;
        RunThread.ExecInputDlg;
        if not frag then setexception(8401);  // Time out
        if modalresult<>mrOk then
              if ThreadMessageDlg(s_ConfirmAbort,mtConfirmation,[mbYes,mbNo],0)=mrYes then
                   raise EStop.create
              else
                   goto L1 ;
         RBuff:=edit1.text;
        end;
    echo;
    // if CtrlBreakHit then
    //     debugdg.BreakPr('inquiry');
end;

procedure TConsole.CharacterInput(var s:ansistring; option:IOoptions);
var
  t:AnsiString;
begin
  sleep(50);
  charInput.option:=option;
  RunThread.ExecCharInput;
  //CharacterInputRequest:=true;
  //While CharacterInputRequest do (TThread.CurrentThread).Yield;
  t:=charInput.c1;
  if charinput.Timeout then setexception(8401);
  if echoOn then
        if t<>'' then begin appendstr(t);flush; end;  //2018/09/18
  if t<>'' then s:=t;
end;


constructor TTextFile.create;
begin
   inherited create;
   WBuff:='';
   importing:=identity;   //0.6.4.5
   exporting:=identity;   //0.6.4.5
end;


destructor TTextFile.destroy;
begin
    if isopen then close;
    inherited destroy;
end;





procedure TTextFile.open(FName:FNameStr; am:AccessMode; og:OrganizationType; len:integer);
var
   IOR:integer;
   ermess:ansistring;
   mode:word;
begin
       //IdleImmediately;
       if FName='' then setexception(7101);
       if isOpen   then setexception(7003);
       if (rectype=rcDISPLAY) and (og=orgSTREAM) then setexception(7101);
       if len<=0 then setexception(7051);
       name:=FName;
       leng:=len;
       margin:=len;
       if isDeviceName(FName) then
          isDevice:=true
       else if (ExtractFileExt(FName)='') and not FileExists(Fname) then
          Name:=Name+'.TXT';

       AMode:=am;
       OrgType:=og;

       Case Amode of
         aminput:  if FileExists(Fname) then
                      mode:=fmOpenRead +fmShareCompat
                   else
                      setexceptionWith(Fname, 7102);
         else      if FileExists(Fname) then
                      mode:=fmOpenReadWrite	 +fmShareCompat
                   else
                      mode:=fmCreate +fmShareCompat ;
       end;

       try
          CharFile:=TFileStream.create(FName,mode);
       except
          On E:Exception do
               setExceptionWith(Fname+EOL+E.message,7101);
       end;

       if Amode=amOutput then
          CharFile.Seek(0,soFromEnd);

   isOpen:=true;
   currentChar:='';
end;


procedure TTextFile.close;
var
   IOR:integer;
begin
   if isOpen then
   begin
     isopen:=false;
     charfile.Free;
     CharFile:=nil;
   end;
end;


type TMyHandleStream=Class(THandleStream)
    Procedure SetSize1(size:Int64);
  end;
Procedure TMyHandleStream.SetSize1(size:int64);
begin
    SetSize(size)
end;

procedure TTextFile.erase(rs:tpRecordSetter; insideofwhen:boolean);
begin
    if not isopen then setexception(7004);
    if AMode=amOutIn then
       begin
          if rs=rsBegin then CharFile.Position:=0;
          with TMyHandleStream.Create(CharFile.Handle) do
             begin
              SetSize1(CharFile.Position);
              Free;
             end;
       end
    else
       setexception(7301) ;
end;

procedure TTextFile.setpointer(rs:tpRecordSetter; insideofWhen:boolean);
begin
   if isDevice then
   else
   try
     case rs of
      rsNone:  ;
      rsBEGIN: CharFile.Seek(0,soFromBeginning);
      rsEND:   CharFile.Seek(0,soFromEnd);
      rsSAME:  CharFile.Seek(exFilePos,soFromBeginning);
      rsNEXT:  Flush;
     end;
     saveFilePos;
     wbuff:='';
   except
     // if insideofWhen then setexception(7205);
         ReportException(InsideOfWhen , 7205);
    end;
end;


procedure TTextFile.saveFilePos;
begin
   if not isDevice then
     exFilePos:=CharFile.Position
end;

function TTextFile.readline:boolean;   //2011.4.24
  procedure TestEOFChar;
   var
      svFilePos:INT64;
      c:char;
   begin
      with CharFile do
        if Position<Size then
             begin
                svFilePos:=Position;
                Read(c,1);
                if (c=#26) and (position=size) then
                else
                   Position:=svFilePos
             end
   end;
var
   svFilePos:INT64;
   c:char;
   n:integer;
begin
    readline:=false;

    RBuff:='';
    with CharFile do
       begin
         svFilePos:=Position;
         n:=0;
         while (read(c,1)>0) and not(c in [#13, #10]) do inc(n);
         Position:=svFilePos;
         SetLength(RBuff,n);
         read(Rbuff[1],n);
         if read(c,1)>0 then
            if (c=#13) and (read(c,1)>0) then
               if c=#10 then
                   TestEOFChar  // 次の文字がCtrl-Zでその次がEOFならCtrl-Z(1Ah)を読み飛ばす
               else
                   Position:=Position-1;
       end;
    RBuff:=importing(RBuff);
    readline:=(extype=0);
end;

function TInternalFile.readline:boolean;           //2011.4.24
var
   svFilePos:INT64;
   c:char;
   n:integer;
begin
    readline:=false;

    RBuff:='';
    with CharFile do
        begin
          svFilePos:=Position;
          n:=0;
          while (read(c,1)>0) and not(c in [#13,#10]) do
            begin
              inc(n);
              if c='"' then          // 引用符に囲まれた文字列を保護。
                repeat
                  inc(n);
                until (read(c,1)=0) or (c='"') ;
            end;

          Position:=svFilePos;
          SetLength(RBuff,n);
          read(Rbuff[1],n);
          if read(c,1)>0 then
             if (c=#13) and (read(c,1)>0) then
                if c<>#10 then
                    Position:=Position-1;

        end;

    RBuff:=importing(RBuff);
    readline:=(extype=0);
end;





procedure TTextFile.CharacterInput(var s:ansistring; option:IOoptions);
var
  c:char;
begin
  c:=ReadByte;
  s:=c;
  if ioCharacterByte in option then
     exit
  {$IFDEF Windows}
  else if @importing<>@identity then
     begin
         if isDBCSLeadByte(byte(c))  then
                    s:=s+ReadByte;
         s:=Importing(s)
     end
  {$ENDIF}
  else
     begin
        Case byte(c) of
          $c0 .. $df: s:=s+ReadByte;
          $e0 .. $ef: begin
                     s:=s+ReadByte;
                     s:=s+ReadByte;
                    end;
          $f0 .. $f7: begin
                     s:=s+ReadByte;
                     s:=s+ReadByte;
                     s:=s+ReadByte;
                    end;
        end;
     end;
end;

Function TTextFile.ReadByte:char;
begin
   try
      CharFile.read(result,1)
   except
      setexception(7303);
   end
end;


procedure TTextFile.flush;
var
   n:integer;
   s:string;
begin
   s:=exporting(WBuff);
   s:=WBuff;
   n:=length(s);
   try
      CharFile.Write(s[1],n);
   except
       setexception(9000);
   end;
   WBuffClear;
end;

procedure TTextFile.setCoding(const s:string);
begin
  if Uppercase(s)='SYSTEM' then
  begin
     importing:=NativeToUTF8;      //AnsiToUTF8は機能しない
     exporting:=UTF8ToNative;
  end
  else if UpperCase(s)='UTF-8' then
  begin
     importing:=identity;
     exporting:=identity;
  end
  else
    setexception(8999);
end;


function TTextDevice.ReadNewLine:boolean;
begin
   result:=true;
   //if CurrentChar='' then    //2007.5.7
      begin
         prom2:='';
         RBuff:='';
         ReadLine;
         rcp:=1;
         NextChar;
      end
   //else                      //2007.5.7
   //   result:=false;         //2007.5.7
end;

procedure TTextDevice.NextChar;
begin
    CurrentChar:=copy(RBuff,rcp,1);
    if rcp<=length(RBuff) then inc(rcp);
end;

function TTextDevice.punctuate:boolean;
begin
    result:=CurrentChar=','  ;
    if result then
       begin
         nextChar;
         while (CurrentChar=' ') do NextChar ;       //space cut
         if currentChar='' then
            begin index0:=index; {echo;} setprompt('? ') ;ReadNewLine end;
       end;
end;



function TTextDevice.ReadEOL:boolean;
begin
    result:=(CurrentChar='') and (rcp>length(RBuff));
end;

function TTextDevice.DataFoundForRead:boolean;
begin
   result:=True;
end;

function TTextDevice.DataFoundForWrite:boolean;
begin
   result:=false;
end;

function TTextFile.DataFoundForRead:boolean;
begin
   if isDevice then
      result:=true
   else
   begin
      result:=false;
      with CharFile do result:=(Position<size);
      if not result then extype:=7305;
   end;
end;

function TTextFile.DataFoundForWrite:boolean;
begin
   if isDEvice then
      result:=false
   else
     begin
        result:=true;
        with CharFile do result := Position<Size;
        if result then extype:=7308;
     end;
end;



function TTextFile.askpointer:ansistring;
begin
  if isOpen then
     if TrueFile then
       with CharFile do
         if Position>=Size then
            result:='END'
         else if Position=0 then
            result:='BEGIN'
         else
            result:='MIDDLE'
     else
        result:='UNKNOWN'
  else
     result:=''

end;

function TTextFile.TrueFile:boolean;
begin
   //result:= Windows.GetFileType(TFileRec(CharFile).handle) =FILE_TYPE_DISK;
   //result:= GetFileType((CharFile.handle)) =FILE_TYPE_DISK;
   result:=not isDevice
end;

procedure TInternalFile.appendStr(const s:AnsiString);
begin
   WBuff:=WBuff + s;
   if length(WBuff)>leng then setexception(8301);
end;

(*
procedure TInternalFile.NextChar;
var
   e:boolean;
   c:char;
begin
    CurrentChar:='';
    try
         read(CharFile,c);
         CurrentChar:=c;
    except
    end;
end;
*)

function TInternalFile.punctuate:boolean;
begin
   result:=false;
   if (OrgType=orgSEQ) then
      begin
       result:=(CurrentChar=',');
       if result then nextChar;
      end
   else if (OrgType=orgSTREAM) then
       result:=readEOL and ReadNewLine;
end;

function TCSVFile.punctuate:boolean;
begin
   result:=(CurrentChar=',');
   if result then
       nextChar
   else
       result:=readEOL and ReadNewLine;  //ver 7.5.1
end;


(* //2007.5.7
function TInternalFile.ReadNewLine:boolean;
begin
   result:=true;
   if (CurrentChar='') or (CurrentChar=chr(10)) then
       NextChar
   else
      result:=false;
end;

function TInternalFile.ReadEOL:boolean;
begin
    ReadEOL:=true;
    if CurrentChar=EOL[1] then
       begin
          if length(EOL)=2 then
                     NextChar
       end
    else
        ReadEOL:=false  ;
end;
*)

function TInternalFile.rectype:RecordType;
begin
   rectype:=rcInternal
end;

function TCSVFile.rectype:RecordType;
begin
   rectype:=rcCSV
end;

procedure TInternalFile.CharacterInput(var s:AnsiString; option:IOoptions);
begin
  setexception(7451)
end;

function TTextDevice.ReadItem(var s:AnsiString; var quoted:boolean):boolean;
label L1;
begin
    result:=false;
    quoted:=false;
    s:='';
    while (CurrentChar=' ') do NextChar ;       //space cut
    if CurrentChar='"' then               // string constant
       begin
            quoted:=true;
            repeat
                NextChar;
                if (CurrentChar='"') then
                   begin
                       NextChar;
                       if CurrentChar<>'"' then goto L1;
                   end;
                s:=s + CurrentChar;
            until CurrentChar='';
            setexception(choose(8105,8102,8105,8120));
          L1:
            while CurrentChar=' ' do NextChar ;   //space cut
       end
    else
      begin
        While (CurrentChar<>'') and not (CurrentChar[1] in [#13, #10, ',']) do
           begin
              s:=s + CurrentChar;
              NextChar;
           end;
        while (length(s)>0) and (s[length(s)]=' ') do delete(s,length(s),1);
      end;
   result:=(extype=0)
end;

function TInternalFile.Datum:AnsiString;
var
   curChar:string[1];
   p:int64;
begin
  with CharFile do
    begin
      if Position>=Size then
         result:='NONE'
      else
         begin
            p:=Position;
            curchar:=currentchar;
            nextchar;
            while currentChar=' ' do nextChar;
            if currentchar='"' then
               result:='STRING'
            else
               result:='NUMERIC';
            seek(p,soFromBeginning);
            currentchar:=curchar;
         end;
    end;
end;


constructor TDataSeqV2.create;
begin
    inherited create;
    isOpen:=true;
    DataList:=TstringList.create;
    LabelNumbers:=TStringList.create;
    DataPointer:=0;
end;

destructor TDataSeqV2.destroy;
begin
    LabelNumbers.free;
    DataList.Free;
    inherited destroy;
end;

procedure TDataSeqV2.setLabelNumber(labelNumber:integer);
begin
    if LabelNumber>0 then
       begin
          while LabelNumbers.count<DataList.count do LabelNumbers.add('');
          LabelNumbers.add(Strint(LabelNumber));
       end;
end;


procedure TDataSeqV2.Restore(LabelNumber:integer);
begin
   if LabelNumber=0 then
      DataPointer:=0
   else
      Datapointer:=LabelNumbers.Indexof(Strint(LabelNumber))
end;


procedure TDataSeqV2.pushDataPointer;
begin
    stack.add(pointer(DataPointer));
end;

procedure TDataSeqV2.PopDataPointer;
begin
    with stack do
       begin
          pointer(DataPointer):=items[count-1];
          delete(count-1);
       end;
end;

function TDataSeqV2.ReadItem(var s:AnsiString; var quoted:boolean):boolean;
begin
    quoted:=false;
    if DataPointer<DataList.count then
       begin
          s:=DataList.strings[DataPointer];
          inc(DataPointer) ;
          if (length(s)>0) and (s[1]='"') then
             begin
                quoted:=true;
                delete(s,1,1)
             end
       end
    else
       begin
           extype:=8001;  //setexception(8001);     //Ver. 8.0.1.3
           s:=''  ;
      end;
    ReadItem:=(extype=0);
 end;

function TDataSeqV2.ReadNewLine;
begin
   result:=true;
end;

function TDataSeqV2.punctuate;
begin
   result:=true;
end;

function TDataSeqV2.ReadEOL;
begin
   result:=true;
end;


function TDataSeqV2.DataFoundForRead:boolean;
begin
   result:=(DataList<>nil) and (DataPointer<DataList.count);
   if not result then extype:=8001;

end;

function TDataSeqV2.choose(i1,i2,i3,i4:integer):integer;
begin
   choose:=i1
end;

function TConsole.choose(i1,i2,i3,i4:integer):integer;
begin
   choose:=i2
end;

function TTextFile.choose(i1,i2,i3,i4:integer):integer;
begin
   choose:=i3
end;

function TInternalFile.choose(i1,i2,i3,i4:integer):integer;
begin
   choose:=i4
end;

function TTextDevice.AskCharacterPending:integer;
begin
  result:=-1
end;

function TConsole.AskCharacterPending:integer;
begin
  result:=length(charinput.c) ;
  if UseCharInput then
     CharInput.show;
end;


function TTextDevice.AskFileSize:int64;
begin
  result:=0
end;

function TTextFile.AskFileSize:Int64;
begin
  Result:=CharFile.Size;
end;


function TTextDevice.AskTypeAhead:boolean;
begin
   result:=false
end;

function TConsole.AskTypeAhead:boolean;
begin
   result:=true
end;

function TTextFile.AskCharacterPending:integer;
begin
  with CharFile do
     if Position>=Size then
        result:=0
     else
        result:=1
end;

function TInternalFile.AskCharacterPending:integer;
begin
  result:=-1
end;

function TInternalFile.AskTypeAhead:boolean;
begin
   result:=false
end;

function TTextFile.AskTypeAhead:boolean;
begin
   result:=true
end;


constructor TLocalPrinter.create;
begin
  inherited create;
  AMode:=amOUTPUT;
  TextBuff:='';
  EchoOn:=false;
end;

destructor TLocalPrinter.destroy;
begin
   if TextBuff<>'' then close;
   inherited destroy
end;

procedure TLocalPrinter.open(FName:FNameStr; am:AccessMode; og:OrganizationType; len:integer);
begin
     isOpen:=true;
end;

procedure TLocalPrinter.close;
begin
  isOpen:=false;
  if TextBuff='' then exit;
  TmyThread(TThread.CurrentThread).SyncExec(closeexec);
end;

procedure TLocalPrinter.closeexec;
var
  Lines:TStringList;
begin
  Lines:=TStringList.Create;
  try
    try
         Lines.text:=TextBuff;
         with TPrintDialog1.create(TextForm) do
         begin
            if ShowModal=mrOk then
               PrintMemo(Lines);
            free;
         end;
        Lines.Text:='';
        TextBuff:='';
    finally
      lines.Free;
    end;
  except
    on E:Exception do
       MessageDlg('Printer Error'+EOL+E.Message, mtError, [mbOK], 0)
   end;
end;

procedure TLocalPrinter.flush;
begin
    TextBuff:=TextBuff + WBuff;
    WBuff:='';
end;

procedure TLocalPrinter.CharacterInput(var s:AnsiString; option:IOoptions);
begin
  setexception(7451)
end;

function TLocalPrinter.choose(i1,i2,i3,i4:integer):integer;
begin
   result:=i3
end;

procedure TLocalPrinter.erase(rs:tpRecordSetter; insideofwhen:boolean);
begin
   TextBuff:=''
end;




{******************}
{TChannelCollection}
{******************}

function PTextDevice.NewElement:TVar;
begin
    NewElement:=PTextDevice.create
end;

destructor PTextDevice.destroy;
begin
    if not (ttext is TLocalPrinter) then ttext.free;
    inherited destroy;
end;

initialization
    PConsole:=PTextDevice.Create;        //2008.11.3

finalization
    PConsole.Free;

end.
