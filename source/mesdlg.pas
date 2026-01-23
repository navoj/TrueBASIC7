unit mesdlg;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  Buttons, StdCtrls, ExtCtrls;

type

  { TMessageDialog }

  TMessageDialog = class(TForm)
    HelpBtn: TBitBtn;
    Label1: TLabel;
    OkBtn: TBitBtn;
    Panel1: TPanel;
    procedure HelpBtnClick(Sender: TObject);
  private
    helpContext:integer;
  public
    { public declarations }
  end; 

var
  MessageDialog: TMessageDialog;

procedure ShowMessageDialog(s:ansistring; hcx:integer);

implementation
 uses htmlhelp;
 {$R *.lfm}
{ TMessageDialog }

procedure TMessageDialog.HelpBtnClick(Sender: TObject);
begin
  OpenHelp(HelpContext)
end;

procedure ShowMessageDialog(s:ansistring; hcx:integer);
begin
  with MessageDialog do
    begin
      HelpContext:=hcx;
      Label1.caption:=s;
      showModal
    end;
end;


initialization


end.

