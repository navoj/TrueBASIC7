unit optina;

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

(***************************************)
(* Copyright (C) 2003, SHIRAISHI Kazuo *)
(***************************************)


interface

uses
  SysUtils,  Classes, Graphics, Controls,
  StdCtrls, Forms, CheckLst , LResources, Buttons;

type
  TOptionAC = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Help1: TButton;
    CheckListBox1: TCheckListBox;
    Label1: TLabel;
    CheckListBox2: TCheckListBox;
    Label2: TLabel;
    Label3: TLabel;
    CheckListBox3: TCheckListBox;
    Label4: TLabel;
    CheckListBox4: TCheckListBox;
    procedure FormCreate(Sender: TObject);
    procedure Help1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    public
      procedure execute;
  end;

var
  OptionAC: TOptionAC;



implementation
uses base, htmlhelp, sconsts, confopt;
{$R *.lfm}

procedure TOptionAC.FormCreate(Sender: TObject);
var
   i:integer;
   IniFile:TMyIniFile;
   {$IFDEF LclGTK2}
   const c0=8;
   {$ELSE}
   const c0=1;
   {$ENDIF}
begin
    //サイズの補正
    //with CheckListBox1 do Height:=(ItemHeight+c0)*items.Count+2;
    //with CheckListBox2 do Height:=(ItemHeight+c0)*items.Count+2;
    //with CheckListBox3 do Height:=(ItemHeight+c0)*items.Count+2;
   ;

    with CheckListBox1 do
      for i:=ac_let to ac_remark do
          checked[i]:=true;

   IniFile:=TMyIniFile.create('OptionAC');
   for i:=0 to ac_end do
            AutoCorrect[i]:=IniFile.ReadBool(IntToStr(i),AutoCorrect[i]);
   IniFile.free;
end;

procedure TOptionAC.Help1Click(Sender: TObject);
begin
  OpenHelp(HelpContext);
end;

procedure TOptionAC.FormDestroy(Sender: TObject);
var
   i:integer;
   IniFile:TMyIniFile;
begin
       IniFile:=TMyIniFile.create('OptionAC');
       for i:=0 to ac_end do
                IniFile.WriteBool(IntToStr(i),AutoCorrect[i]);
       IniFile.free;
end;

procedure TOptionAC.execute;
var
   i:integer;
begin
      for i:=0 to ac_end do
          CheckListBox1.checked[i]:=AutoCorrect[i];
      OptionAC.CheckListBox2.Visible:=not MinimalBasic;
      OptionAC.Label2.Visible:=not MinimalBasic;
      CheckListBox2.checked[0]:=InsertDIMst;
      CheckListBox2.checked[1]:=(InitialOptionBase=0);
      CheckListBox3.checked[0]:=InsertOptionArithmetic;
      CheckListBox4.Checked[0]:=AutoIndent;
      if showModal=mrOK then
      begin
         for i:=0 to ac_end do
            AutoCorrect[i]:=CheckListBox1.checked[i];
         InsertDIMst:=CheckListBox2.checked[0];
         Boolean(InitialOptionBase):= not CheckListBox2.checked[1];
         InsertOptionArithmetic:=CheckListBox3.checked[0];
         AutoIndent:=CheckListBox4.Checked[0];
      end;

end;

initialization

end.
