unit setask;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}
(***************************************)
(* Copyright (C) 2003, SHIRAISHI Kazuo *)
(***************************************)


interface

uses SysUtils,FileUtil,
     variabl,struct;

function  SETst(prev,eld:TStatement):TStatement;
//function  ASKst(prev,eld:TStatement):TStatement;

type TSetF=class(TStatement)
         chn:TPrincipal;
        constructor create(prev,eld:TStatement; ch:TPrincipal);
        destructor destroy;override;
      end;

     TSetFE=class(TSetF)
          exp:TPrincipal;
        constructor create(prev,eld:TStatement; c:TPrincipal);
        destructor destroy;override;
      end;

     TsetFS=class(TSetF)
          exp:TPrincipal;
        constructor create(prev,eld:TStatement; c:TPrincipal);
        destructor destroy;override;
      end;

function  DefaultAnotherSETst(prev,eld:TStatement; chn:TPrincipal):TStatement;
var
   AnotherSetSt:function(prev,eld:TStatement; chn:TPrincipal):TStatement=DefaultAnotherSETst;

implementation

uses Forms,
     base,texthand,textfile,express,io,graphic,print,charinp,helpctex;

constructor TSetF.create(prev,eld:TStatement; ch:TPrincipal);
begin
    inherited create(prev,eld);
    chn:=ch;
end;

destructor TSetF.destroy;
begin
     chn.free;
     inherited destroy;
end;

type
   TSetPointer=class(TsetF)
         rs:tpRecordSetter;
         IfThere:TStatement;
         Recovery:TStatement;
       constructor create(prev,eld:TStatement; ch:TPrincipal);
       procedure exec;override;
       destructor destroy;override;
    end;

constructor TSetPointer.create(prev,eld:TStatement; ch:TPrincipal);
begin
    inherited create(prev,eld,ch);
    rs:=rsNone;
    RecordSetterClause(rs);
    if (rs<>rsNone) and (token=',') and (Nexttoken='IF') then
       gettoken;
    if token='IF' then
       if nextToken='THERE' then
          IfThere:=IfThereClause(self)
       else if nexttoken='MISSING' then
          recovery:=IORecovery(self);
end;

destructor TSetPointer.destroy;
begin
   IfThere.free;
   Recovery.free;
   inherited destroy;
end;

procedure TSetPointer.exec;
var
    ch:TTextDevice;
begin

   ch:=channel(chn,proc,Punit);
   if (ch=nil) or not ch.isopen then
       begin setexception(7004);exit end;
   //IdleImmediately;
   ch.setpointer(rs,insideofWhen);
   if (ifthere<>nil) and ch.DaTaFoundForWrite and (extype=7308) then
      begin extype:=0; ifthere.exec end;
   if (recovery<>nil) and not ch.DaTaFoundForRead and (extype=7305) then
      begin extype:=0; recovery.exec end;

end;



constructor TSetFE.create(prev,eld:TStatement; c:TPrincipal);
begin
   inherited create(prev,eld,c);
   exp :=nexpression;
end;

destructor TSetFE.destroy;
begin
   exp.free;
   inherited destroy
end;


type
    TsetMargin=class(TSetFE)
       procedure exec;override;
    end;

type
    TsetZoneWidth=class(TSetFE)
       procedure exec;override;
    end;

procedure TSetMargin.exec;
var
   ch:TTextDevice;
begin
    ch:=channel(chn,proc,Punit);
    if ch<>nil then
      ch.setmargin(exp.evalInteger)
    else
      setexception(7004)
end;

procedure TSetZoneWidth.exec;
var
   ch:TTextDevice;
begin
   ch:=channel(chn,Proc,Punit);
   if ch<>nil then
      ch.setzonewidth(exp.evalInteger)
   else
      setexception(7004);

end;

constructor TSetFS.create(prev,eld:TStatement; c:TPrincipal);
begin
   inherited create(prev,eld,c);
   exp :=SExpression;
end;

destructor TSetFS.destroy;
begin
   exp.free;
   inherited destroy
end;

type
  TSetEndOfLIne=class(TSetFS)
       procedure exec;override;
  end;

procedure TSetEndOfLIne.exec;
var
   ch:TTextDevice;
   s:AnsiString;
begin
    s:=exp.evalS;
    //if extype<>0 then exit;
    if (length(s)=1) and (s[1] in [#13,#10])
        or (s=#13#10)   then
       begin
           ch:=channel(chn,Proc,Punit);
           if ch<>nil then
             ch.SetEndOfLine(s)
       end
    else
       // if insideOfWhen then}
       //  setexception(7000);
       ReportException(InsideOfWhen , 7000);

end;

type
  TSetCoding=class(TSetFS)
       procedure exec;override;
  end;

procedure TSetCoding.exec;
var
   ch:TTextDevice;
   s:AnsiString;
begin
    s:=exp.evalS;
    ch:=channel(chn,Proc,PUnit);
    if ch<>nil then
       ch.SetCoding(s)
    else
       //if insideOfWhen then
       //  setexception(7000);
       ReportException(InsideOfWhen , 7000);

end;


type
  TSetEcho=class(TSetFS)
       procedure exec;override;
  end;

procedure TSetECho.exec;
var
   ch:TTextDevice;
   s:AnsiString;
begin
    ch:=channel(chn,Proc,Punit);
    s:=exp.evalS;
    //if extype<>0 then exit;
    s:=uppercase(s);
    if s='ON' then
      ch.echoOn:=true
    else if s='OFF' then
      ch.echoOn:=false
    else
      setexception(4103);
end;

Type
    TSetDirectory=class(TStatement)
       exp:TPrincipal;
       constructor create(prev,eld:TStatement);
       procedure exec;override;
       destructor destroy;override;
    end;

constructor TSetDirectory.create(prev,eld:TStatement);
begin
  inherited create(prev,eld);
  exp:=SExpression;
end;

destructor TSetDirectory.destroy;
begin
  exp.free;
  inherited destroy
end;

procedure TsetDirectory.exec;
var
   s:string;
   extype:integer;
begin
   s:=exp.evalS;
   try
     chDir(s)
   except
     on E:EInOutError do
       begin
         if E.ErrorCode=21 then
            extype:=9002
         else
            extype:=9008;
         setexception(extype);
       end;
     on E:Exception do
        begin
           setexception(9000);
        end;
   end;
end;



function  SETst(prev,eld:TStatement):TStatement;
var
    chn:TPrincipal;
begin
   SETst:=nil;
   if token='DIRECTORY' then
     begin
        gettoken;
        SETst:=TSetDirectory.create(prev,eld);
     end
    else
     begin
        chn:=ChannelExpression;
        if chn<>nil then
                     checktoken(':',IDH_SET_POINTER);
        if (token='POINTER') then
           begin
               gettoken;
               SETst:=TSetPointer.create(prev,eld,chn);
           end
        else if (token='IF') then
           begin
               SETst:=TSetPointer.create(prev,eld,chn);
           end
        else if (token='MARGIN')  then
             begin
                 gettoken;
                 SETst:=TSetmargin.create(prev,eld,chn);
             end
         else if (token='ZONEWIDTH')  then
             begin
                 gettoken;
                 SETst:=TSetZoneWidth.create(prev,eld,chn);
             end
         else if (token='ECHO')  then
             begin
                 gettoken;
                 SETst:=TSetECHO.create(prev,eld,chn);
             end
         else if (token='ENDOFLINE')  then
             begin
                 gettoken;
                 SETst:=TSetEndOfLine.create(prev,eld,chn);
             end
         else if (token='CODING')  then
             begin
                 gettoken;
                 SETst:=TSetCoding.create(prev,eld,chn);
             end
         else
             SetSt:=AnotherSetSt(prev,eld,chn)
     end;
end;

function  DefaultAnotherSETst(prev,eld:TStatement; chn:TPrincipal):TStatement;
begin
    result:=nil;
    seterrIllegal(token,0)
end;

{***}
{ASK}
{***}

function AskMargin(ch:TTextDevice):integer;
begin
     if  (ch.rectype=rcDisplay) then
        AskMargin:=ch.Margin
     else
        AskMargin:=0;
end;

function AskZoneWidth(ch:TTextDevice):integer;
begin
     if (ch.rectype=rcDisplay)then
        AskZoneWidth:=ch.ZoneWidth
     else
        AskZoneWidth:=0;
end;

function AskCharacterPending(ch:TTextDevice):integer;
begin
     //IdleImmediately;
     result:=ch.AskCharacterPending
end;


function AskFILETYPE(ch:TTextDevice):AnsiString;
begin
    if ch.TrueFile then
          result:='FILE'
    else
          result:='DEVICE'
end;

function AskEcho(ch:TTextDevice):AnsiString;
begin
    if ch.echoOn then
           result:='ON'
    else
           result:='OFF'
end;


type
  TAskDirectory=class(TStatement)
    exp:TStrVari;
    constructor create(prev,eld:TStatement);
    procedure exec;override;
    destructor destroy;override;
   end;

constructor TAskDirectory.create(prev,eld:TStatement);
begin
   inherited create(prev,eld);
   exp:=StrVari;
end;

procedure TAskDirectory.exec;
begin
      exp.SubstS(GetCurrentDir)
end;

destructor TAskDirectory.destroy;
begin
    exp.free;
    inherited destroy;
end;



type
  TAskStartDir=class(TAskDirectory)
        procedure exec;override;
end;

procedure TAskStartDir.exec;
begin
    exp.substS(ExcludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)));
end;

type
  TAskEnvVar=Class(TStatement)
      exp:TPrincipal;
      vari:TStrVari;
     constructor create(prev,eld:TStatement);
     destructor destroy;override;
     procedure exec;override;
  end;

constructor TAskEnvVar.create(prev,eld:TStatement);
begin
    inherited create(prev,eld);
    check('(',IDH_FILE_ENLARGE);
    exp:=SExpression;
    check(')',IDH_FILE_ENLARGE);
    vari:=StrVari;
end;

destructor TAskEnvVar.destroy;
begin
   exp.free;
   vari.free;
   inherited destroy
end;

procedure TAskEnvVar.exec;
var
   s:string;
begin
   s:=exp.evalS;
   vari.substS(GetEnvironmentVariable(s));
end;

type
  TAskFile=class(TStatement)
    chn:TPrincipal;
    expAccess,expDatum,expErasable,expFileType,expName,
    expOrganization,expPointer,expRecsize1,expRecType,expSetter,
    expCharin,expTypeahead,expEchoControl,expEcho:TStrVari;
    expMargin,expRecSize2,expZonewidth,expCharacterPending,expFilesize:TVariable;
    constructor create(prev,eld:TStatement; c:TPrincipal);
    procedure exec;override;
    destructor destroy;override;
   end;

function  ASKst(prev,eld:TStatement):TStatement;
var
   chn:TPrincipal;
begin
   if token='DIRECTORY' then
     begin
       gettoken;
       ASKst:=TAskDirectory.create(prev,eld);
     end
   else if token='STARTDIR' then
       begin
          gettoken;
          result:=TAskStartDir.create(prev,eld);
       end
    else if token='ENVIRONMENTVARIABLE' then
     begin
       gettoken;
       ASKst:=TASkEnvVar.create(prev,eld);
     end
  else
     begin
        chn:=ChannelExpression;
        if chn<>nil then
                     checktoken(':',IDH_SET_MARGIN);
        if (chn<>nil)
           or (token='MARGIN')
           or (token='ZONEWIDTH')
           or (token='CHARIN')
           or (token='TYPEAHEAD')
           or (token='ECHO')
           or ((token='CHARACTER') and (nexttoken='PENDING')) then
           ASKst:=TAskFile.create(prev,eld,chn)
        else
           ASKst:=Graphic.ASKst(prev,eld);
     end;
end;

constructor TAskFile.create(prev,eld:TStatement; c:TPrincipal);
begin
   inherited create(prev,eld);
   chn:=c;
   repeat
         if token='MARGIN' then
            begin
                 gettoken;
                 expMargin:=NVariable;
            end
         else if token='ZONEWIDTH' then
            begin
                 gettoken;
                 expZonewidth:=NVariable;
            end
         else if token='ACCESS' then
            begin
                 gettoken;
                 expACCESS:=StrVari;
            end
         else if token='DATUM' then
            begin
                 gettoken;
                 expDatum:=StrVari;
            end
         else if token='ERASABLE' then
            begin
                 gettoken;
                 expErasable:=StrVari;
            end
         else if token='SETTER' then
            begin
                 gettoken;
                 ExpSetter:=StrVari;
            end
         else if token='FILETYPE' then
            begin
                 gettoken;
                 expFiletype:=StrVari;
            end
         else if token='FILESIZE' then //規格外
            begin
                 gettoken;
                 expFilesize:=NVariable;
            end
         else if token='NAME' then
            begin
                 gettoken;
                 expName:=StrVari;
            end
         else if token='ORGANIZATION' then
            begin
                 gettoken;
                 expOrganization:=StrVari;
            end
         else if token='POINTER' then
            begin
                 gettoken;
                 expPointer:=StrVari;
            end
         else if token='RECTYPE' then
            begin
                 gettoken;
                 expRectype:=StrVari;
            end
         else if token='RECSIZE' then
            begin
                 gettoken;
                 expRecsize1:=StrVari;
                 expRecsize2:=NVariable;
            end
         else if (token='ECHO') and (NextToken='CONTROL') then
            begin
                 gettoken;gettoken;
                 expEchoControl:=StrVari;
            end
         else if token='ECHO' then
            begin
                 gettoken;
                 expEcho:=StrVari;
            end
         else if token='TYPEAHEAD' then
            begin
                 gettoken;
                 expTypeAhead:=StrVari;
            end
         else if (token='CHARACTER') and (NextToken='PENDING') then
            begin
                 gettoken;gettoken;
                 expCharacterPending:=NVariable;
            end
         else if token='CHARIN' then
            begin
                 gettoken;
                 expCharin:=StrVari;
            end
      until not test(',');
end;

destructor TAskFile.destroy;
begin
    chn.free;
    expAccess.free;
    expDatum.free;
    expErasable.free;
    expFileType.free;
    expName.free;
    expOrganization.free;
    expPointer.free;
    expRecsize1.free;
    expRecType.free;
    expSetter.free;
    expCharin.free;
    expTypeahead.free;
    expEchoControl.free;
    expEcho.free;
    expMargin.free;
    expRecSize2.free;
    expZonewidth.free;
    expCharacterPending.free;
    inherited destroy;
end;



procedure TAskFile.exec;
var
  ch:TTextDevice;
begin
  ch:=channel(chn,proc,Punit);
  if (ch<>nil) and ch.isopen then
     begin
      if expAccess<>nil then
         expAccess.SubstS(AccessModeLiteral[ch.AMode]);
      if expDatum<>nil then
         expDatum.substS(ch.Datum);
      if expErasable<>nil then
         expErasable.substS(
            YesNoLiteral[((ch.amode=amOUTIN) and ch.TrueFile) or (ch is TLocalPrinter)]);
      if expFileType<>nil then
         expFiletype.substS(askFileType(ch));
      if expFileSize<>nil then
         expFilesize.assignX(ch.askfilesize);
      if expName<>nil then
         expName.substS(ch.Name);
      if expOrganization<>nil then
         expOrganization.substS(OrganizationTypeLiteral[ch.OrgType]);
      if expPointer<>nil then
         expPointer.substS(ch.askPointer);
      if expRecType<>nil then
         expRecType.SubstS(RecordTypeLiteral[ch.Rectype]);
      if expSetter<>nil then
         expSetter.substS(YesNoLiteral[ch.TrueFile]);
      if expCharin<>nil then
         expCharin.substS(
            YesNoLiteral[(ch.rectype=rcDisplay) and (ch.AMode in [amOutin,amInput])]);
      if expTypeahead<>nil then
         begin
            expTypeAhead.substS(YesNoLiteral[ch.AskTypeAhead] );
            if UseCharInput and (ch=console) then
                  charinput.show;
         end;
      if expEchoControl<>nil then
         expEchoControl.substS(YesNoLiteral[ch=console]);
      if expEcho<>nil then
         expEcho.substS(askEcho(ch));
      if expMargin<>nil then
         expMargin.assignLongint(askMargin(ch));
      if expZonewidth<>nil then
         expZonewidth.assignLongint(askZonewidth(ch));
      if expCharacterPending<>nil then
         expCharacterPending.assignLongint(askCharacterPending(ch));

      if expRecsize1<>nil then
         expRecSize1.substS('VARIABLE');
      if expRecSize2<>nil then
         expRecSize2.assignLongint(ch.leng);
     end
  else
     begin
      if expAccess<>nil then
         expAccess.SubstS('');
      if expDatum<>nil then
         expDatum.substS('');
      if expErasable<>nil then
         expErasable.substS('');
      if expFileType<>nil then
         expFiletype.substS('');
      if expName<>nil then
         expName.substS('');
      if expOrganization<>nil then
         expOrganization.substS('');
      if expPointer<>nil then
         expPointer.substS('');
      if expRecType<>nil then
         expRecType.SubstS('');
      if expSetter<>nil then
         expSetter.substS('');
      if expCharin<>nil then
         expCharin.substS('');
      if expTypeahead<>nil then
         expTypeAhead.substS('');
      if expEchoControl<>nil then
         expEchoControl.substS('');
      if expEcho<>nil then
         expEcho.substS('');
      if expMargin<>nil then
         expMargin.assignLongint(0);
      if expZonewidth<>nil then
         expZonewidth.assignLongint(0);
      if expCharacterPending<>nil then
         expCharacterPending.assignLongint(0);

      if expRecsize1<>nil then
         expRecSize1.substS('');
      if expRecSize2<>nil then
         expRecSize2.assignLongint(0);
     end ;
end;




procedure statementTableinit;
begin
   StatementTableInitImperative('ASK',ASKst);
end;

begin
    tableInitProcs.accept(statementTableinit) ;
end.
