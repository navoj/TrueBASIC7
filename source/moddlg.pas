unit moddlg;

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

(***************************************)
(* Copyright (C) 2003, SHIRAISHI Kazuo *)
(***************************************)


interface

uses  SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, Buttons, ExtCtrls,
      texthand,helpctex, LResources;
      
type
  TMODDialog = class (TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    HelpBtn: TButton;
    RadioGroup1: TRadioGroup;
    RadioGroup2: TRadioGroup;
    Label1: TLabel;
    procedure HelpBtnClick(Sender: TObject);
  private
    { Private 宣言 }
  public
    { Public 宣言 }
  end;

var
  MODDialog: TMODDialog;

function confirmMod:integer;

implementation
 uses htmlhelp;
 {$R *.lfm}

procedure TMODDialog.HelpBtnClick(Sender: TObject);
begin
  OpenHelp(HelpContext);
end;

var FirstDo:boolean=true;

function confirmMod:integer;
begin
   selecttoken;
   if FirstDo then begin MODDialog.radiogroup1.itemindex:=2; FirstDo:=false end;
   with MODDialog do
    if (radiogroup2.itemindex=1) or (showmodal=mrOK) then
       result:=radiogroup1.itemindex
    else
       seterrillegal(token,IDH_MOD);
end;



initialization



end.

