unit numberdg;

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

(***************************************)
(* Copyright (C) 2003, SHIRAISHI Kazuo *)
(***************************************)


interface

uses  SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
  Buttons, ExtCtrls, LResources;

type

  { TNumberDlg }

  TNumberDlg = class(TForm)
    Cancelbtn: TButton;
    OKBtn: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
  private
    { Private 宣言 }
  public
    { Public 宣言 }
  end;

var
  NumberDlg: TNumberDlg;

implementation
 {$R *.lfm}

initialization



end.
