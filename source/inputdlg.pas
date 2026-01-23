unit inputdlg;

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

(***************************************)
(* Copyright (C) 2003, SHIRAISHI Kazuo *)
(***************************************)


interface

uses  Types, Classes, Graphics, Forms, Controls, Buttons,
     SysUtils, Dialogs,  StdCtrls, LResources;

type

  { TInputDialog }

  TInputDialog = class(TForm)
    Edit1: TEdit;
    OKBtn: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    help1: TBitBtn;
    CancelBtn: TBitBtn;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormResize(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
     height0:integer;
  public
     frag:boolean;
     LineNumber:integer;
     TimeLimit:TDateTime;
     procedure execute;
   end;

var
  InputDialog: TInputDialog;

implementation
uses
     base,texthand,MainFrm;
{$R *.lfm}

procedure TInputDialog.execute;
begin
   caption:=TextHand.getMemoLine(LineNumber);
   SelectLine(TextHand.memo,LineNumber);

   frag:=false;
   show;
   setfocus;
   repeat
       sleep(10);
       Application.ProcessMessages;
   until frag or (now>=timelimit);
   close;
   {$IFNDEF LclQt5}               //Qt5だと有害なので回避
   {$IFNDEF LclQt6}               //Qt6だと有害なので回避
   position:=poDefault;        // 次回以後，表示位置を強制しない
   {$ENDIF}
   {$ENDIF}
end;


procedure TInputDialog.FormResize(Sender: TObject);
begin
     if Height0=0 then
        Height0:=Height
     else
        Height:=Height0;
     Edit1.Left:=7;
     Edit1.width:=width-22;
     with Help1 do Left:=Self.width-12-width;
     with CancelBtn do Left:=Help1.Left-width-4;
     with OkBtn do Left:=CancelBtn.Left-width-4;
end;

procedure TInputDialog.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if Frag=false then
     ModalResult:=mrCancel;
end;

procedure TInputDialog.FormActivate(Sender: TObject);
begin
    Edit1.SetFocus
end;

procedure TInputDialog.OKBtnClick(Sender: TObject);
begin
    frag:=true;

end;

procedure TInputDialog.CancelBtnClick(Sender: TObject);
begin
      frag:=true;
end;



procedure TInputDialog.FormCreate(Sender: TObject);
begin

end;



initialization



end.
