unit syntaxdg;

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

(***************************************)
(* Copyright (C) 2003, SHIRAISHI Kazuo *)
(***************************************)


interface

uses
  SysUtils,  Classes, Graphics, Controls,
  StdCtrls, Forms,  CheckLst, ExtCtrls, LResources, Buttons;

type
  TSyntaxDlg = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Help1: TButton;
    RadioGroup1: TRadioGroup;
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    CheckListBox1: TCheckListBox;
    procedure Help1Click(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
  end;

var
  SyntaxDlg: TSyntaxDlg;

implementation
 uses htmlhelp;
 {$R *.lfm}

procedure TSyntaxDlg.Help1Click(Sender: TObject);
begin
    OpenHelp(HelpContext);
end;

procedure TSyntaxDlg.RadioGroup1Click(Sender: TObject);
begin
       CheckListBox1.visible:=(RadioGroup1.ItemIndex=0)
end;

initialization

end.
