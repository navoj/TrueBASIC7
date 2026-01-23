unit hselect;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  Menus, ExtCtrls, StdCtrls;

type

  { THelpSelector }

  THelpSelector = class(TForm)
    Button1: TButton;
    RadioGroup1: TRadioGroup;
    procedure Button1Click(Sender: TObject);
    procedure Button1Enter(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  HelpSelector: THelpSelector;


implementation
{$R *.lfm}

function HelpSelect(list:TStrings):integer;
begin
  with HelpSelector do
  begin
    RadioGroup1.items:=list;
    showmodal;
    result:=RadioGroup1.ItemIndex
  end;
end;

{ THelpSelector }

procedure THelpSelector.Button1Click(Sender: TObject);
begin

end;

procedure THelpSelector.Button1Enter(Sender: TObject);
begin
  ModalResult:=mrOk
end;

initialization


end.

