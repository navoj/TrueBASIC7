unit about;

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

(***************************************)
(* Copyright (C) 2025, SHIRAISHI Kazuo *)
(***************************************)


interface

uses  Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ComCtrls, ExtCtrls, LResources,LCLIntf;

type

  { TAboutBox }

  TAboutBox = class(TForm)
    Web: TLabel;
    Panel1: TPanel;
    OKButton: TBitBtn;
    ProductName: TLabel;
    Copyright: TLabel;
    Comments: TLabel;
    Memo1: TMemo;
    version: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure WebClick(Sender: TObject);
  private
    { Private 宣言 }
  public
    { Public 宣言 }
  end;

var
  AboutBox: TAboutBox;


implementation
uses LCLVersion,
     sconsts;
{$R *.lfm}

procedure TAboutBox.FormCreate(Sender: TObject);
begin
   ProductName.left:=10;
   Comments.left:=20;
   version.Left:=100;
   version.Caption:='Version 8.1.6.0 '
                    {$IFDEF CPUX86_64}+' (x86_64)'{$ENDIF}
                    {$IFDEF LCLQt}+' Qt'{$ENDIF}
                    {$IFDEF LCLQt5}+' Qt5'{$ENDIF}
                    {$IFDEF LCLQt6}+' Qt6'{$ENDIF}
                    {$IFDEF LCLGTK2}+' GTK2'{$ENDIF}
                    {$IFDEF LCLGTK3}+' GTK3'{$ENDIF}
                    +'  (LCL '+lcl_version+')';
   Copyright.left:=20;
   CopyRight.Caption:='Copyright(C) 2025 SHIRAISHI Kazuo';
   Web.Font.Color:=clBlue;
   {$IFDEF LCLGTK2}
   memo1.enabled:=false;
   {$ENDIF}
end;

procedure TAboutBox.WebClick(Sender: TObject);
begin
   OpenURL(s_URL);
end;



initialization



end.

