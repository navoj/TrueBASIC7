unit listbox;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

interface

uses
  SysUtils, Types, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons;

type
  TListForm = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    RadioGroup1: TRadioGroup;
  private
    { Private 宣言 }
  public
    { Public 宣言 }
  end;

var
  ListForm: TListForm;

implementation
{$R *.lfm}

end.
