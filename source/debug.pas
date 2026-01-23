unit debug;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}
(***************************************)
(* Copyright (C) 2003, SHIRAISHI Kazuo *)
(***************************************)



interface
uses struct;
procedure ExecInspectBox;
function inspectBox(statement:TStatement):boolean;
procedure ShowCurrentLine(lineNumb:integer);
procedure DeshowCurrentLine;
var
   CurrentLineNumb:integer;
   DebugRequest:boolean=false;
   TraceFormRequest:boolean=false;

implementation

uses  StdCtrls, Graphics, Forms, ComCtrls, Classes,
      myutils, express,debugdg,base,texthand,variabl,textfile,debuglst,helpctex,tracefrm,
      sconsts,MainFrm,compiler,MyThread;



var
   prevline:integer;

procedure ShowCurrentLine(lineNumb:integer);
begin
   CurrentLineNumb:=LineNumb;
   SelectLine(TextHand.memo,LineNumb);
(*
       with TextHand.memo do
             begin
                Lines.BeginUpdate;
                HideSelection:=true;
                SelStart:=SendMessage(Handle,EM_LINEINDEX,LineNumb,0);
                SelLength:=Length(Lines[LineNumb]);
                SelAttributes.Color:=clGreen;
                SelAttributes.Style:=SelAttributes.Style+[fsBold];

                SelLength:=0;
                SelAttributes.Color:=DefAttributes.Color;
                SelAttributes.Style:=DefAttributes.Style;
                SendMessage(Handle,EM_SCROLLCARET,0,0) ;
                Lines.EndUpdate;
                (owner as TForm).BringToFront;
             end;
 *)
end;

procedure DeshowCurrentLine;
begin
   with Texthand.memo do SelEnd:=SelStart; //Texthand.memo.SelLength:=0;
(*
       with Texthand.memo do
           begin
              Lines.BeginUpdate;
              SelStart:=SendMessage(Handle,EM_LINEINDEX,CurrentLineNumb,0);
              SelStart:=LineIndex(lines.Text,CurrentLineNumb);
              SelLength:=Length(Lines[CurrentLineNumb]);
              if fsUnderLine in SelAttributes.Style then
                 SelAttributes.Color:=BreakPointColor
              else
                 SelAttributes.Color:=DefAttributes.color;
              SelAttributes.Style:=SelAttributes.Style-[fsBold];
              SelLength:=0;
              HideSelection:=false;
              Lines.EndUpdate;
           end;
*)
end;

Var
   DebugLine:integer;

procedure ExecInspectBox;
begin
       showCurrentLine(DebugLine);
       FrameForm.StatusBar1.Panels[3].text:=s_OnRuunnig;
       FrameForm.StatusBar1.update;
       SetFPUMask(OriginalCW);
       Application.ProcessMessages;

       with debugdlg do
            ShowList(lists.count-1);
       with DebugDlg do
          begin
              RadioGroup1.visible:=true;
              RadioGroup1.ItemIndex:=Ord(bkDirective);
              CheckBox1.Checked:=BreakFlags.TraceMode;
              Execute;;

              BreakFlags.TraceMode:=CheckBox1.Checked;
              BkDirective:=RadioGroup1.ItemIndex;
              if sr=srCancel then
                                 BkDirective:=BkCancel;
          end;

       if bkDirective<>bkCancel then
          DeshowCurrentLine;
       Application.ProcessMessages;
       if BreakFlags.TraceMode then
          TraceFormRequest:=true;

end;

var PUnitPrev:TProgramUnit=nil;

function inspectBox(statement:TStatement):boolean;
begin
  inspectBox:=true;
  if (extype<0) or (statement.ClassType=TStatement) then exit;

  try
  with statement do
    begin
       if (bkdirective=bkstep) and (prevline=linenumb)
            and (previous<>nil) and (previous.linenumb=linenumb) then exit;    {1998.9.24修正}

       if (bkdirective=bkstepRestricted) and (Statement.Punit<>PunitPrev) then exit; //Ver. 8.1.5.3

       setDebugDlg(statement);

       prevline:=linenumb;
       DebugLine:=LineNumb;

       RunThread.ExecDebugDlg;
       case bkdirective of
           bkcontinue:
               ctrlBreakHit:=false;
           bkStepRestricted:                                                    //Ver. 8.1.5.3
               begin
                  ctrlBreakHit:=true;
                  PunitPrev:=statement.punit;                                  //Ver. 8.1.5.3
               end;
           bkstep:
               ctrlBreakHit:=true;
           bkcancel:
               begin
                 inspectbox:=false ;
                 ctrlBreakHit:=true;
                 Punit.TraceList.free;
                 Punit.TraceList:=nil;
                 raise EStop.create;
               end;
       end;                                end;
   finally
   end;
end;



type
    TBreak=class(TStatement)
       procedure exec;override;
    end;

procedure TBreak.exec;
begin
  if not Punit.debug then exit;
  if InsideOfWhen then
       setexception(10007)
  else
       inspectbox(self);
end;



type

     TDebug=class(TStatement)
           state:boolean;
       constructor create(prev,eld:TStatement);
       procedure exec;override;
     end;

     TTRace=class(TStatement)
           state:boolean;
           chn:TPrincipal;
       constructor create(prev,eld:TStatement);
       procedure exec;override;
     end;

constructor TDebug.create(prev,eld:TStatement);
begin
   inherited create(prev,eld);
   if token='ON' then
       begin
          gettoken;
          state:=true;
       end
   else if token='OFF' then
       begin
          gettoken;
          state:=false;
       end
   else
       seterrExpected('ON or OFF',IDH_DEBUG);
end;

constructor TTrace.create(prev,eld:TStatement);
begin
   inherited create(prev,eld);
   if token='ON' then
       begin
          gettoken;
          state:=true;
          if Token='TO' then
            begin
               GetToken;
               Check('#',IDH_DEBUG);
               chn:=NExpression;
            end;
       end
   else if token='OFF' then
       begin
          gettoken;
          state:=false;
       end
   else
       seterrExpected('ON or OFF',IDH_DEBUG);
end;

procedure TDebug.exec;
begin
    Punit.debug:=state;
end;

procedure TTrace.exec;
var
   i:longint;
   ch:TTextDevice;
   traceChannel:integer;
begin
    if PUnit.Debug then
      if state then
        begin
            TraceChannel:=0;
            if chn<>nil then
               begin
                  i:=chn.evalInteger;
                  if i>=0 then
                      begin
                          ch:=PUnit.channel(i);
                          if ch<>nil then
                             with ch do
                                  if isOpen and (AMode in [amOutIn,amOutput])
                                     and (RecType=rcDisplay)  then
                                      TraceChannel:=i
                                  else
                                      setexception(7402)

                          else
                             setexception(7401)
                      end
                  else
                      Setexception(7001) ;
               end
        end
      else
        TraceChannel:=-1;
   BreakFlags.TraceChannelPlus1:=TraceChannel+1
end;

function DEBUGst(prev,eld:TStatement):TStatement;
begin
       DEBUGst:=TDebug.create(prev,eld);
end;

function BREAKst(prev,eld:TStatement):TStatement;
begin
   BREAKst:=TBreak.create(prev,eld);
end;

function TRACEst(prev,eld:TStatement):TStatement;
begin
       TRACEst:=TTRACE.create(prev,eld);
       TextMode:=true;
end;



{**********}
{initialize}
{**********}
procedure statementTableinit;
begin
       statementTableinitImperative('DEBUG',DEBUGst);
       statementTableinitImperative('BREAK',BREAKst);
       statementTableinitImperative('TRACE',TRACEst);
   prevline:=-1;
end;


begin
   if TableInitProcs=nil then
      TableInitProcs:=TProcsCollection.create; //
   tableInitProcs.accept(statementTableinit);
end.
