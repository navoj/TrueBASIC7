unit afdg;

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

(***************************************)
(* Copyright (C) 2003, SHIRAISHI Kazuo *)
(***************************************)


interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,  CheckLst, LResources, Buttons, ColorBox;


type

  { TAutoFormatDlg }

  TAutoFormatDlg = class(TForm)
    ColorBox1: TColorBox;
    ColorBox2: TColorBox;
    ColorBox3: TColorBox;
    ColorBox4: TColorBox;
    ColorBox5: TColorBox;
    ColorBox6: TColorBox;
    ColorBox7: TColorBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    OKBtn: TButton;
    CancelBtn: TButton;
    HelpBtn: TButton;
    CheckListBox1: TCheckListBox;
    programCharset1: TRadioGroup;
    procedure CheckListBox1ClickCheck(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure programCharset1Click(Sender: TObject);
  private
    procedure EnableColorBoxes(s:boolean);
  public
    { Public 宣言 }
  end;

var
  AutoFormatDlg: TAutoFormatDlg;
  AutoFormatKw:boolean=true;
  KeywordColoring:boolean=false;
  ProgramFileCharsetUTF8:boolean=true;


procedure  setAutoFormat;

implementation
uses base,htmlhelp,MainFrm,kwlist;

{$R *.lfm}


procedure TAutoFormatDlg.HelpBtnClick(Sender: TObject);
begin
  OpenHelp(HelpContext);
  //Application.HelpContext(HelpContext);
end;

procedure TAutoFormatDlg.CheckListBox1ClickCheck(Sender: TObject);
begin
     EnableColorBoxes(CheckListBox1.checked[1]);
end;

procedure TAutoFormatDlg.programCharset1Click(Sender: TObject);
begin

end;

procedure  setAutoFormat;
begin
 with AutoFormatDlg do
  begin
    //OkBtn.Focused;
    {$IFNDEF Windows}
    ProgramCharset1.enabled:=false;
    {$ENDIF}
    CheckListBox1.checked[0]:=AutoFormatKw;
    CheckListBox1.checked[1]:=KeywordColoring;
    EnableColorBoxes(CheckListBox1.checked[1]);
    ColorBox1.Selected:=BlockAttri.Foreground;
    ColorBox2.Selected:=DeclativeAttri.Foreground;
    ColorBox3.Selected:=ImperativeAttri.Foreground;
    ColorBox4.Selected:=ParamsAttri.Foreground;
    ColorBox5.Selected:=StringAttri.Foreground;
    ColorBox6.Selected:=CommentAttri.Foreground;
    ColorBox7.Selected:=BranchAttri.Foreground;
    ProgramCharset1.ItemIndex:=byte(ProgramFileCharsetUTF8);
    if ShowModal=mrOk then
      begin
        AutoFormatKw:=CheckListBox1.checked[0];
        KeywordColoring := CheckListBox1.checked[1];
        BlockAttri.Foreground      := ColorBox1.Selected;
        DeclativeAttri.Foreground  := ColorBox2.Selected;
        ImperativeAttri.Foreground := ColorBox3.Selected;
        ParamsAttri.Foreground     := ColorBox4.Selected;
        StringAttri.Foreground     := ColorBox5.Selected;
        CommentAttri.Foreground    := ColorBox6.Selected;
        BranchAttri.Foreground     := ColorBox7.Selected;
        with FrameForm do
        if KeywordColoring then
            Memo1.Highlighter:=SynHLBasic
        else
            Memo1.Highlighter:=SynAnySyn1;

        byte(ProgramFileCharsetUTF8) := ProgramCharset1.ItemIndex;
      end;
  end;
end;

procedure TAutoFormatDlg.EnableColorBoxes(s:boolean);
begin
    Label1.Visible:=s;
    Label2.Visible:=s;
    Label3.Visible:=s;
    Label4.Visible:=s;
    Label5.Visible:=s;
    Label6.Visible:=s;
    Label7.Visible:=s;
   ColorBox1.Visible:=s;
   ColorBox2.Visible:=s;
   ColorBox3.Visible:=s;
   ColorBox4.Visible:=s;
   ColorBox5.Visible:=s;
   ColorBox6.Visible:=s;
   ColorBox7.Visible:=s;
end;

initialization
    with TMyIniFile.create('AutoFormat') do
       begin
         AutoFormatKw:=ReadBool('kw',AutoFormatKw);
         KeywordColoring := ReadBool('Coloring',KeywordColoring);
         {$IFDEF Windows}
         ProgramFileCharsetUTF8:=ReadBool('cs',ProgramFileCharsetUTF8);
         {$ENDIF}
         free
        end;

finalization

      with TMyIniFile.create('AutoFormat') do
         begin
             WriteBool('kw',AutoFormatKw);
             WriteBool('Coloring',KeywordColoring);
            {$IFDEF Windows}
             WriteBool('cs',ProgramFileCharsetUTF8);
             {$ENDIF}
             free
         end;

end.

