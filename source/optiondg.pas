unit optiondg;

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

(***************************************)
(* Copyright (C) 2003, SHIRAISHI Kazuo *)
(***************************************)


interface

uses Types,  Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls,  CheckLst, LResources,Dialogs;

type
  TOptionDlg = class(TForm)
    RadioGroup1: TRadioGroup;
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    HelpBtn: TBitBtn;
    Label1: TLabel;
    CheckListBox1: TCheckListBox;
    CheckBox1: TCheckBox;
    procedure RadioGroup1Click(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private 宣言 }
  public
    { Public 宣言 }
  end;

var OptionDlg:TOptionDlg;

procedure SetOption;


implementation
uses
     base,toolfrm,htmlhelp;
{$R *.lfm}
procedure SetOption;
begin
   with OptionDlg do
   begin
       RadioGroup1.TabOrder:=0;
       RadioGroup1.ItemIndex:=byte(InitialPrecisionMode0);
       CheckListBox1.checked[0]:=UseTranscendentalFunction;
       CheckBox1.checked:=signiwidthMore;

       if ShowModal=mrOK then
        begin
          InitialPrecisionMode0:=tpPrecision(RadioGroup1.ItemIndex);
          UseTranscendentalFunction:=CheckListBox1.checked[0];
          signiwidthMore:=CheckBox1.checked;
        end;
   end;
   ToolBox.refresh;
end;




procedure TOptionDlg.RadioGroup1Click(Sender: TObject);
begin
       CheckListBox1.visible:=(RadioGroup1.ItemIndex in [4]);
       CheckBox1.visible:=(RadioGroup1.ItemIndex in [0,2,3]);
end;

procedure TOptionDlg.HelpBtnClick(Sender: TObject);
begin
  //Application.HelpContext(HelpContext);
  OpenHelp(HelpContext)
end;

procedure TOptionDlg.FormShow(Sender: TObject);
begin
   RadioGroup1Click(self)
end;

initialization

end.
