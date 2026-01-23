unit colordlg;

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

(***************************************)
(* Copyright (C) 2003, SHIRAISHI Kazuo *)
(***************************************)


interface

uses Types, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, LResources;

type
  TColorIndexDlg = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    HelpBtn: TBitBtn;
    RadioGroup1: TRadioGroup;
    procedure HelpBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private 宣言 }
  public
    procedure execute;
  end;

var
  ColorIndexDlg: TColorIndexDlg;

implementation
uses graphsys,toolfrm, paintfrm,htmlhelp;
{$R *.lfm}

procedure TColorIndexDlg.execute;
begin
     if ShowModal=mrOk then
       begin
         MyPalette.PaletteNumber:=RadioGroup1.ItemIndex;
         PaintForm.initial;
         ToolBox.refresh
       end;
end;





procedure TColorIndexDlg.HelpBtnClick(Sender: TObject);
begin
  OpenHelp(HelpContext);
end;

procedure TColorIndexDlg.FormCreate(Sender: TObject);
begin
   RadioGroup1.ItemIndex:=0;
end;

initialization


end.
