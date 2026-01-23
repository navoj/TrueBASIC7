unit textfrm;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}
(***************************************)
(* Copyright (C) 2008, SHIRAISHI Kazuo *)
(***************************************)


interface

uses SysUtils, Types, Classes, Clipbrd, Graphics, Forms, Controls, Menus,
  StdCtrls, Dialogs,  ComCtrls, ExtCtrls  , LResources, SynEdit;

type

  { TTextForm }

  TTextForm = class(TForm)
    copy2: TMenuItem;
    Cut2: TMenuItem;
    Delete2: TMenuItem;

    MainMenu1: TMainMenu;
    Edit1: TMenuItem;
    Cut1: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    Delete1: TMenuItem;
    N4: TMenuItem;
    paste2: TMenuItem;
    PopupMenu1: TPopupMenu;
    SelectAll1: TMenuItem;
    File1: TMenuItem;
    Exit1: TMenuItem;
    N1: TMenuItem;
    Print1: TMenuItem;
    N2: TMenuItem;
    SaveAs1: TMenuItem;
    Save1: TMenuItem;
    N3: TMenuItem;
    Close1: TMenuItem;
    SaveDialog1: TSaveDialog;
    FontDialog1: TFontDialog;

    Run1: TMenuItem;
    FindDialog1: TFindDialog;
    ReplaceDialog1: TReplaceDialog;
    Find1: TMenuItem;
    Repalce1: TMenuItem;
    FindNext1: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    Memo1: TSynEdit;
    SelectAll2: TMenuItem;
    WordWrap1: TMenuItem;
    Break1: TMenuItem;
    Option1: TMenuItem;
    RunOption1: TMenuItem;
    Font1: TMenuItem;
    N7: TMenuItem;
    K1: TMenuItem;
    K2: TMenuItem;
    KS1: TMenuItem;
    FromTop: TMenuItem;
    FromCurrent: TMenuItem;
    Undo1: TMenuItem;
    protected1: TMenuItem;
    StatusBar1: TStatusBar;
    Show1: TMenuItem;
    E1: TMenuItem;
    M1: TMenuItem;

    procedure copy2Click(Sender: TObject);
    procedure Cut2Click(Sender: TObject);
    procedure Delete2Click(Sender: TObject);
    procedure memo1Change(Sender: TObject);
    procedure memo1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure paste2Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure Cut1Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure Paste1Click(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure SelectAll1Click(Sender: TObject);
    procedure SaveAs1Click(Sender: TObject);
    procedure Print1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SelectAll2Click(Sender: TObject);
    procedure WordWrap1Click(Sender: TObject);
    procedure Break1Click(Sender: TObject);
    procedure Find1Click(Sender: TObject);
    procedure Repalce1Click(Sender: TObject);
    procedure FindNext1Click(Sender: TObject);
    procedure FindDialog1Find(Sender: TObject);
    procedure ReplaceDialog1Find(Sender: TObject);
    procedure ReplaceDialog1Replace(Sender: TObject);
    procedure Font1Click(Sender: TObject);
    procedure K1Click(Sender: TObject);
    procedure K2Click(Sender: TObject);
    procedure FromTopClick(Sender: TObject);
    procedure FromCurrentClick(Sender: TObject);
    procedure Undo1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure protected1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure E1Click(Sender: TObject);
    procedure M1Click(Sender: TObject);
    procedure Memo1KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    overwriteMode:boolean;
    cache:array[0..65535]of ansistring;
    point0:word;
    point1:word;
    len:integer;
    procedure Find(Sender: TObject);
    procedure Replace(Sender: TObject);
    function search(const FText:ansistring; Options1:TFindOptions):boolean;
    procedure UpdateCursorPos;
    procedure setStatusBar;
    procedure AppendString(const s:string);
  public
     TextOutWorking:boolean;
    function FileFilter:string;virtual;
    function FileExt:string;virtual;
    function IniFileSection:string;virtual;
    procedure setReadOnly(s:boolean);
    procedure TextoutExec;
    procedure drop(s:ansistring);
  end;


var
   TextForm:TTextForm;
var
   InitialMargin:integer=2400; //1600;

implementation
uses
     myutils,MainFrm,base,struct,sconsts, printdlg, findtext, afdg,textfile;
{$R *.lfm}

function TTextForm.FileFilter:string;
begin
   result:=s_TextFile+'|*.txt'
end;

function TTextForm.FileExt:string;
begin
   result:='.txt'
end;

const IniFileSection0:string='Text';

function TTextForm.IniFileSection:string;
begin
   result:=IniFileSection0
end;


procedure TTextForm.Save1Click(Sender: TObject);
var
   i:integer;
begin
  if Pos(FileExt,Caption)>0 then
  begin
    // Memo1.Lines.SaveToFile(Caption);     //Syneditがエラーを起こす
    With TStringList.Create do
      begin
         for i:=0 to Memo1.Lines.Count-1 do
             Add(memo1.lines[i]);
         SaveToFile(Caption);
         Clear; Free;
      end;
    Memo1.Modified := false;
  end
  else
    SaveAs1Click(Sender)

end;

procedure TTextForm.Cut2Click(Sender: TObject);
begin
  Cut1Click(Sender)
end;

procedure TTextForm.Delete2Click(Sender: TObject);
begin
   Delete1Click(Sender)
end;

procedure TTextForm.memo1Change(Sender: TObject);
begin

end;

procedure TTextForm.memo1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   //UpdateCursorPos
end;

procedure TTextForm.paste2Click(Sender: TObject);
begin
    Paste1Click(Sender)
end;

procedure TTextForm.copy2Click(Sender: TObject);
begin
     copy1Click(Sender)
end;

procedure TTextForm.SaveAs1Click(Sender: TObject);
begin
     SaveDialog1.Filter:=FileFilter;
     SaveDialog1.FileName :=ChangeFileExt(Caption,FileExt);
     SaveDiaLog1.DefaultExt:='txt';
     if SaveDialog1.Execute then
     begin
         Caption := SaveDialog1.FileName;
         Save1Click(Sender);
     end;
end;

procedure TTextForm.Exit1Click(Sender: TObject);
begin
  FrameForm.Close1Click(Sender);
end;

procedure TTextForm.Close1Click(Sender: TObject);
begin
  Close; { Close the edit form }
end;



procedure TTextForm.Cut1Click(Sender: TObject);
begin
  Memo1.CutToClipBoard;
end;

procedure TTextForm.Copy1Click(Sender: TObject);
begin
  Memo1.CopyToClipBoard;
end;

procedure TTextForm.Paste1Click(Sender: TObject);
begin
  Memo1.PasteFromClipBoard;
end;

procedure TTextForm.Delete1Click(Sender: TObject);
begin
  Memo1.ClearSelection;
end;

procedure TTextForm.SelectAll1Click(Sender: TObject);
begin
  Memo1.SelectAll;
end;

procedure TTextForm.Print1Click(Sender: TObject);
begin
  PrintDialog1.Execute(memo1);
end;

procedure TTextForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
      Action:={$IFDEF LclGtk2}caHide {$ELSE} caMiniMize{$ENDIF}
end;

procedure TTextForm.SelectAll2Click(Sender: TObject);
begin
    SelectAll1Click(Sender)
end;







procedure TTextForm.WordWrap1Click(Sender: TObject);
begin
(*
  with Memo1 do begin
    WordWrap := not WordWrap;
    if WordWrap then
      ScrollBars := ssVertical
    else
      ScrollBars := ssBoth;
    WordWrap1.Checked := WordWrap;
  end;
*)
end;


procedure TTextForm.Break1Click(Sender: TObject);
begin
    CtrlBreakHit:=true;
    FrameForm.SetBreakMessage;
end;

procedure TTextForm.Find1Click(Sender: TObject);
begin
  FindDialog1.FindText:=Memo1.seltext;
  //Memo1.sellength:=0;
  if fromTop.checked then
     memo1.selstart:=0;
  FindDialog1.Execute;
  FindNext1.Enabled := True;
end;

procedure TTextForm.Repalce1Click(Sender: TObject);
begin
  ReplaceDialog1.FindText:=Memo1.seltext;
  //Memo1.sellength:=0;
  if fromTop.checked then
     memo1.selstart:=0;
  ReplaceDialog1.Execute;

end;

procedure TTextForm.FindNext1Click(Sender: TObject);
begin
  Find(FindDialog1);
end;

procedure TTextForm.FindDialog1Find(Sender: TObject);
begin
     Find(Sender);
end;

procedure TTextForm.ReplaceDialog1Find(Sender: TObject);
begin
      Find(Sender)
end;

procedure TTextForm.ReplaceDialog1Replace(Sender: TObject);
begin
    Replace(Sender);
end;

procedure TTextForm.Font1Click(Sender: TObject);
begin
    FontDialog1.Font:=Memo1.Font;
    if FontDialog1.execute then
        Memo1.Font:=FontDialog1.Font;
end;

procedure TTextForm.K1Click(Sender: TObject);
begin
   k1.checked:=true;
   k2.checked:=false;
   KeepText:=false
end;

procedure TTextForm.K2Click(Sender: TObject);
begin
   k1.checked:=false;
   k2.checked:=true;
   KeepText:=true
end;

function TTextForm.search(const FText:ansistring; Options1:TFindOptions):boolean;
var
   p:integer;
   s:TFindOptions;
   InitialPos:integer;
begin
  result:=false;
  if FText='' then exit;        // ver. 8.1.5.2  //2025/11/05

  s:=[];
  if frMatchCase in Options1 then s:=s+[frMatchCase];
  with memo1 do
        begin
          InitialPos:=SelEnd;  //selstart+selLength;
          if frWholeWord in Options1 then
             p:=findword(memo1,FText,InitialPos,length(Memo1.text)-InitialPos-1,s)
          else
             //p:=findtext(FText,InitialPos,SearchLength,s);
             p:=SearchText(memo1,FText,InitialPos,length(Memo1.text)-InitialPos-1,s);
          if p>=0 then
            begin
               selstart:=p;
               Selend:=p+Length(FText);   //selLength:=length(FText);
               result:=true;
            end
          else
             begin
               selStart:=SelStart+length(FText);
               SelEnd:=SelStart;   //selLength:=0;
               result:=false;
             end;
        end;
   Application.Processmessages;
end;

procedure TTextForm.Find(Sender: TObject);
begin
   with (Sender as TFindDialog) do
   if Search( FindText, Options) then
   else
     CloseDialog;   // ShowMessage( FindText + EOL + s_NotFound);
end;

procedure TTextForm.Replace(Sender: TObject);      //ver. 8.1.5.2 //2025.11.06
var
  Found: Boolean;
begin
  with Memo1 do
    begin
      beginupdate;

      with ReplaceDialog1 do
        begin
          if (Memo1.SelText=FindText)
             or not(frMatchcase in options)
             and ( AnsiCompareText(Memo1.SelText, FindText) = 0)  then
                 SelText := ReplaceText;
          Found := Search( FindText, Options);
          while Found and (frReplaceAll in Options) do
              begin
                 SelText := ReplaceText;
                 Found := Search( FindText, Options);
              end;
        end;

       endupdate;
    end;
  if (not Found)  then
       ReplaceDialog1.CloseDialog

end;


procedure TTextForm.FromTopClick(Sender: TObject);
begin
   FromTop.checked:=true;
   FromCurrent.checked:=false;
end;

procedure TTextForm.FromCurrentClick(Sender: TObject);
begin
   FromTop.checked:=false;
   FromCurrent.checked:=true;
end;

procedure TTextForm.Undo1Click(Sender: TObject);
begin
      Memo1.Undo;
      //SendMessage(Memo1.Handle,WM_UNDO,0,0);
end;

procedure TTextForm.FormCreate(Sender: TObject);
begin
    SaveDialog1.Title:=s_SaveFile;
    Break1.ShortCut:=ShortCut(Word(BreakKey), [ssCtrl]);
    //Memo1.Perform(EM_SETOPTIONS, ECOOP_OR, ECO_SELECTIONBAR);
    WordWrap1.visible:=false;

    with TMyIniFile.create(IniFileSection) do
    begin
      RestoreFont(Memo1.Font);
      if IniFileSection=IniFileSection0 then
         InitialMargin:=ReadInteger('InitialMargin',InitialMargin);
      free
    end;
    Visible:=false;
    //WindowState:=wsMinimized;
    //Application.ProcessMessages;

   TextOutWorking:=false;
   point0:=0;
   point1:=0;
   len:=0;

   ReplaceDialog1.Options:=[frDown,frHideEntireScope,frHidePromptOnReplace,frHideUpDown]; //ver 8.1.5.1

end;


procedure TTextForm.FormDestroy(Sender: TObject);
begin
    with TMyIniFile.create(IniFileSection) do
      begin
        StoreFont(Memo1.Font);
        if IniFileSection=IniFileSection0 then
             WriteInteger('InitialMargin',InitialMargin);
        free;
      end;
end;

procedure TTextForm.setStatusBar;
begin
   if memo1.readonly then
            begin
              StatusBar1.Panels[0].text:=s_Protected;
              StatusBar1.Panels[0].Bevel:=pbNone;
            end
   else if OverWriteMode then
            begin
              StatusBar1.Panels[0].text:=s_OverWrite;
              StatusBar1.Panels[0].Bevel:=pbRaised;
            end
   else
            begin
              StatusBar1.Panels[0].text:=s_Insert;
              StatusBar1.Panels[0].Bevel:=pbLowered;
            end;
end;

procedure TTextForm.setReadOnly(s:boolean);
begin
    protected1.checked:=s;
    memo1.readonly:=s;
    SetStatusBar;
end;

procedure TTextForm.protected1Click(Sender: TObject);
begin
   setReadOnly(not protected1.checked)
end;

procedure TTextForm.FormResize(Sender: TObject);
begin
   memo1.refresh;
end;

procedure TTextForm.E1Click(Sender: TObject);
begin
   FrameForm.bringToFront
end;

procedure TTextForm.UpdateCursorPos;
var
  CharPos: TPoint;
begin
  try                          //ver. 8.1.3.8
  CharPos.Y := Memo1.CaretY;   //ver. 8.1.3.8
  CharPos.X := Memo1.CaretX;   //ver. 8.1.3.8
  StatusBar1.Panels[1].Text := Format('%6d:%4d', [CharPos.y, CharPos.x]);
  StatusBar1.Update;
  except

  end;
end;

procedure TTextForm.M1Click(Sender: TObject);
begin
    initialMargin:=max(24,StrToIntDef(InputBox(s_Margin,s_InitialMargin,intToStr(initialMargin)),InitialMargin))
end;

procedure TTextForm.Memo1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    UpdateCursorPos
end;

procedure TTextForm.AppendString(const s:string);
begin
    with memo1 do
     begin
        Lines.BeginUpdate;
        SelText:=s;
        Lines.EndUpdate;
     end;
end;

procedure TTextForm.TextoutExec;
var
  s,t:AnsiString;
  c:PAnsiChar;
  p0,p1,p2:word;
  len:integer;
begin
   if point0=point1 then exit;

   TextOutWorking:=true;
      p0:=point0;
     p1:=point1;
     p2:=p1;
     len:=0;
     while p2<>p0 do
             begin
               len:=len+length(cache[p2]);
               inc(p2);
             end;
     setlength(s,len+1);
      //c:=Pchar(s);
     c:=@s[1];
     while p1<>p0 do
          begin
            c:=StrEcopy(c,PChar(cache[p1]));
            cache[p1]:='';
            inc(p1);
          end;
     t:=s;
     point1:=p0;
     AppendString(t);
    TextOutWorking:=false;
end;

//var DropCriticalSection: TRTLCriticalSection;

procedure TTextForm.drop(s:ansistring);
begin
    //EnterCriticalSection(DropCriticalSection);
    while word(point0+1)=point1 do (TThread.CurrentThread).Yield;
    cache[point0]:=s;
    inc(point0);
    //LeaveCriticalSection(DropCriticalSection);
end;

initialization

end.
