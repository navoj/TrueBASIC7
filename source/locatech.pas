unit locatech;

{$MODE Delphi}

interface

uses
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TLocateChoiceForm = class(TForm)
    OkBtn: TButton;
    ListBox1: TListBox;
    procedure OkBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    exIndex:integer;
    Button:integer;
  public
    function choice(dev0,ini0:integer; Capts:TstringList):integer;
  end;

var
  LocateChoiceForm: TLocateChoiceForm;

implementation
 uses base;
{$R *.lfm}

function TLocateChoiceForm.choice(dev0,ini0:integer;Capts:TstringList):integer;
begin
  Button:=0;
   Show;
   with Listbox1 do
      begin
        items.assign(Capts);
        if ini0=0 then
           ItemIndex:=exIndex
        else
           ItemIndex:=ini0-1;
        Height:=Items.Count*itemHeight+4;
      end;
   ClientHeight:=ListBox1.Height+ OkBtn.Height ;
   OkBtn.enabled:=true;
   BringToFront;
   repeat
          sleep(20);
          application.ProcessMessages;
   until Button<>0;
   with ListBox1 do
      begin
        if Button=1 then
           result := ItemIndex + 1
        else
           result := 0;
        exIndex:=ItemIndex;
      end;
   OkBtn.enabled:=false;
end;

procedure TLocateChoiceForm.OkBtnClick(Sender: TObject);
begin
    Button:=1;
end;

procedure TLocateChoiceForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   Button:=-1;
end;

end.
