unit fkeydlg;

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}
(***************************************)
(* Copyright (C) 2003, SHIRAISHI Kazuo *)
(***************************************)


interface

uses
    SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
    StdCtrls, ExtCtrls , LResources, Buttons,Menus;

type

  { TFkeysDlg }

  TFkeysDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    HelpBtn: TButton;
    Bevel1: TBevel;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Step: TRadioGroup;
    Run: TRadioGroup;
    procedure HelpBtnClick(Sender: TObject);
    procedure StepClick(Sender: TObject);
  private
    { Private 宣言 }
  public
    procedure execute;
  end;

var
  FkeysDlg: TFkeysDlg;

implementation
uses
     base,MainFrm,htmlhelp;
{$R *.lfm}
procedure TFkeysDlg.HelpBtnClick(Sender: TObject);
begin
  OpenHelp(HelpContext);
end;

procedure TFkeysDlg.StepClick(Sender: TObject);
begin

end;


procedure TFkeysDlg.execute;
begin
  Edit1.Text:=Shift_F5;
  Edit2.Text:=Shift_F6;
  Edit3.Text:=Shift_F7;
  Run.ItemIndex:=(FrameForm.Run2.ShortCut)-119 ;
  Step.ItemIndex:=byte(FrameForm.Step1.ShortCut=121);

  If ShowModal=mrOk then
     begin
        Shift_F5:=Edit1.Text;
        Shift_F6:=Edit2.Text;
        Shift_F7:=Edit3.Text;

        FrameForm.Run2.ShortCut:=Run.ItemIndex + 119 ;
        
        case Step.itemIndex of
          0:begin
              FrameForm.Step1.ShortCut:=ShortCut(119, [ssShift]);
            end;
          1:begin
              FrameForm.Step1.ShortCut:=121;
            end;
        end;
     end;
end;

initialization


end.
