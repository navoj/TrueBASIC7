unit MyThread;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}
interface

uses    Classes, SysUtils,Graphics,
        Forms,Dialogs, Controls, extctrls;


 procedure RepaintExec;
 procedure MainTask;
 var
      MsgDlgRequest:boolean=false;
      RepaintRequest:boolean = true;

 function ThreadMessageDlg(const aMsg: String; DlgType: TMsgDlgType;
                            Buttons: TMsgDlgButtons; HelpCtx: LongInt):Integer;


 type
      TMethod = procedure of object;
      TyProcedure=procedure;
 Type
   TMyThread = class(TThread)
  private
     procedure ExecuteDebugDlg;
     procedure ExecuteMesDlg;
     procedure ExecuteInputDlg;
     procedure ExecuteCharInput;
     procedure ExecuteOpenDlg;
     procedure ExecuteSelectDirectory;
     procedure ExecuteTraceFormMinimize;
  protected
     procedure Execute; override;
  public
     Constructor Create;
     procedure ExecDebugDlg;
     procedure ExecMesDlg;
     procedure ExecInputDlg;
     procedure ExecCharInput;
     procedure ExecOpenDlg;
     procedure ExecSelectDirectory;
     procedure ExecTraceFormMinimize;
     procedure SyncExec(p:TMethod);
   end;
var
    RunThread:TMyThread;

implementation
uses  Math,
  base,myutils,charinp,textfrm,textfile,paintfrm,graphsys,graphque,debugdg,debug,
  tracefrm,struct,compiler,inputdlg,extensio,printdlg,sconsts;

var
  MsgText:string;
  MsgDlgType: TMsgDlgType;
  DlgButtons: TMsgDlgButtons;
  DlgHelpContext:integer;
  DlgResult:integer;

function ThreadMessageDlg(const aMsg: String; DlgType: TMsgDlgType;
                          Buttons: TMsgDlgButtons; HelpCtx: LongInt):Integer;
begin
    MsgText:=aMsg;
    MsgDlgType:=DlgType;
    DlgButtons:=Buttons;
    DlgHelpContext:=HelpCtx;
    RunThread.ExecMesDlg;
    result:=DlgResult
end;

{***********}
{RepaintExec}
{***********}
var recenttime:Qword;
{$IFDEF Windows}
procedure RepaintExec;
begin
if RepaintRequest then
   begin
     RepaintRequest:=false;
     PaintForm.PaintBox1Paint(nil);
   end;
 end;
{$ELSE}
procedure RepaintExec;
begin
    recenttime:=GetTickCount64;
    RepaintRequest:=false;
    PaintForm.RePaint;
    SetFPUMask(OriginalCW);
    Application.ProcessMessages;
end;
{$ENDIF}

procedure MainTask;
var
d:Dword;
begin
    GraphOutExec;

   if RepaintRequest and not HiddenDrawMode
      and (GetTickCount64-recenttime>=20) then
     begin
        RepaintExec;
     end;

    with textform do
      if not TextOutWorking then
       TextOutExec;

    if TraceFormRequest=true then
       begin
         TraceFormRequest:=false;
         with TraceForm do
           begin
             Show;
             if WindowState=wsMinimized then WindowState:=wsNormal;
           end;
        end;

    with TraceForm do
      if not TextOutWorking then
       TextOutExec;

    if CtrlBreakHit then
       begin
        // {$IFDEF Windows} AllThreadsList.Suspend;{$ENDIF}
        // DebugDLG.Execute;
        // CtrlBreakHit:=false;
        // {$IFDEF Windows}AllThreadsList.Resume;{$ENDIF}
       end;

    //ClearExceptions(false);
    SetFPUMask(OriginalCW);
    Application.ProcessMessages;
 end;

constructor TMyThread.create;
begin
  inherited create(false,StackLimit1+$80000);
end;

procedure TMyThread.execute;
begin
  ExecuteOnThread;
end;

procedure TmyThread.ExecuteDebugDlg;
begin
  ExecInspectBox;
end;

procedure TMyThread.ExecDebugDlg;
begin
   Synchronize(ExecuteDebugDlg);
end;

procedure TMyThread.ExecuteMesDlg;
begin
   DlgResult:=MessageDlg(MsgText,MsgDlgType,DlgButtons,DlgHelpContext);
end;

procedure TMyThread.ExecMesDlg;
begin
   Synchronize(ExecuteMesDlg);
end;

procedure TMyThread.ExecuteInputDlg;
begin
    InputDialog.execute;
end;

procedure  TMyThread.ExecInputDlg;
begin
    Synchronize(ExecuteInputDlg);
 end;

procedure TMyThread.ExecuteCharInput;
begin
    CharInput.execute;
end;

procedure TMyThread.ExecCharInput;
begin
    Synchronize(ExecuteCharInput)
end;

procedure TMyThread.ExecuteOpenDlg;
begin
    extensio.opendlg.execute;
end;

procedure TMyThread.ExecOpenDlg;
begin
   Synchronize(ExecuteOpenDlg)
end;

procedure TMyThread.ExecuteSelectDirectory;
begin
   if SelectDirectory(s_Select_Directory, '', DirName) then
    else
      DirName:='';
end;

procedure TMyThread.ExecSelectDirectory;
begin
   Synchronize(ExecuteSelectDirectory)
end;

procedure TMyThread.ExecuteTraceFormMinimize;
begin
    TraceForm.WindowState:=wsMinimized;
end;

procedure TMyThread.ExecTraceFormMinimize;
begin
    Synchronize(ExecuteTraceFormMinimize)
end;

procedure TMyThread.SyncExec(p:TMethod);
begin
  synchronize(p);
end;


initialization
    recenttime:=GetTickCount64;

finalization

end.

