unit stringdg;
 {$IFDEF FPC}
  {$MODE DELPHI}  {$H+}
{$ENDIF}

(***************************************)
(* Copyright (C) 2003, SHIRAISHI Kazuo *)
(***************************************)


interface

uses
   SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Buttons,
   StdCtrls, ExtCtrls, LResources;

type
  TStringDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    HelpBtn: TButton;
    RadioGroup1: TRadioGroup;
    Label1: TLabel;
    Label2: TLabel;
    procedure HelpBtnClick(Sender: TObject);
  private
    { Private 宣言 }
  public
    procedure execute;
  end;

var
  StringDlg:TStringDlg; 

implementation
uses
      base,htmlhelp;
//{$R *.dfm}

procedure TStringDlg.HelpBtnClick(Sender: TObject);
begin
  OpenHelp(HelpContext);
end;

procedure TStringDlg.execute;
begin
       RadioGroup1.TabOrder:=0;
       RadioGroup1.ItemIndex:=byte(InitialCharacterByte0);

       if ShowModal=mrOK then
        begin
          InitialCharacterByte0:=boolean(RadioGroup1.ItemIndex);
        end;
end;

Initialization
{$I stringdg.lrs}
end.
