unit convdlg;

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

(***************************************)
(* Copyright (C) 2003, SHIRAISHI Kazuo *)
(***************************************)


interface

uses
   SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
   StdCtrls, ExtCtrls, LResources, Buttons;

type
  TConvtDlg =  class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    HelpBtn: TButton;
    Bevel1: TBevel;
    RadioGroup1: TRadioGroup;
    RadioGroup2: TRadioGroup;
    RadioGroup3: TRadioGroup;
    procedure HelpBtnClick(Sender: TObject);
  private
    { Private 宣言 }
  public
    { Public 宣言 }
  end;

var
  ConvtDlg: TConvtDlg;

implementation
uses htmlhelp;
{$R *.lfm}

procedure TConvtDlg.HelpBtnClick(Sender: TObject);
begin
  OpenHelp(HelpContext);
end;


initialization



end.
