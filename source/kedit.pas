unit kedit;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls,LCLType;

type

   { TKanjiEdit }

   TKanjiEdit = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    procedure Edit1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    Showed:boolean;
  public

  end; 

var
  KanjiEdit: TKanjiEdit;

implementation
uses  MainFrm;
{$R *.lfm}

procedure TKanjiEdit.FormShow(Sender: TObject);
begin
 if height<20 then height:=27;
 if showed then exit;
 top := FrameForm.Top + FrameForm.height;
 left:= FrameForm.Left + (FrameForm.Width - Width) div 2;
 showed:=true;
end;

var prevkey:word=0;
procedure TKanjiEdit.Edit1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 {$IFDEF Darwin}
   if (key=vk_RETURN) and (PrevKey<>0) then
       key:=0;
   prevkey:=key;
  {$ENDIF}
end;

initialization

end.

