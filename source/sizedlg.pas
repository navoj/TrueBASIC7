unit sizedlg;

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

(***************************************)
(* Copyright (C) 2003, SHIRAISHI Kazuo *)
(***************************************)


interface

uses Types,  Classes, Graphics, Forms, Controls, Buttons,
     StdCtrls, ExtCtrls , LResources;
type
  TypBmpSize=(BMPpc9801,BMPdosv,BMP321,BMP401,BMP501,BMP641,BMP801,BMP1001,BMP1281,BMP1601,BMP2001);
type
  TOptionSizeDlg = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    HelpBtn: TBitBtn;
    RadioGroup1: TRadioGroup;
    procedure FormCreate(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
  private
   {  }
  public
    BmpSize:TypBmpSize;
    procedure execute;
end;

var
  OptionSizeDlg: TOptionSizeDlg;

implementation
uses htmlhelp;
 {$R *.lfm}
procedure TOptionSizeDlg.execute;
begin
    with RadioGroup1 do
       begin
          itemindex:=Byte(BmpSize);
          if showmodal=mrOk then
             Byte(BmpSize):=ItemIndex
       end;
end;

procedure TOptionSizeDlg.FormCreate(Sender: TObject);
var
   h:integer;
begin
   with Screen do
      if Height<=Width then
         h:=Height
      else
         h:=Width;
   if h>=1200 then
      BMPSize:=BMP1001
   else if h>=800+160 then
      BMPSize:=BMP801
   else if h>=640+160 then
      BmpSize:=BMP641
   else if h>=500+160 then
      BmpSize:=BMP501
   else if h>=400+160 then
      BmpSize:=BMP401
   else
      BmpSize:=BMP321;
end;

procedure TOptionSizeDlg.HelpBtnClick(Sender: TObject);
begin
  OpenHelp(HelpContext);

end;

initialization

end.
