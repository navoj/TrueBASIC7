unit MainFrm;

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

(***************************************)
(* Copyright (C) 2008, SHIRAISHI Kazuo *)
(***************************************)

interface

uses Types, Classes, LCLVersion,Graphics, Forms, Controls, Menus, SysUtils,
  ExtCtrls, StdCtrls, Dialogs, ComCtrls, ImgList,
  LResources, SynEdit,  SynHighlighterAny,
  SynHighlighterPosition, SynEditHighlighter,
  Clipbrd, Helpintfs, FileUtil,
  Interfaces, LCLIntf, LCLType, LCLProc,
  {$IFNDEF Windows}
   unix,
  {$ENDIF}
  basicHL,
  base, textfrm, paintfrm, myutils;

type

  { TFrameForm }

  TFrameForm = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    MenuItem1: TMenuItem;
    Commentize1: TMenuItem;
    Commentize2: TMenuItem;
    GraphOpt1: TMenuItem;
    MenuItem2: TMenuItem;
    MultiByteCharEdit: TMenuItem;
    OpenDialog2: TOpenDialog;
    UnCommentize2: TMenuItem;
    Uncommentize1: TMenuItem;
    N2: TMenuItem;
    Open1: TMenuItem;
    New1: TMenuItem;
    merge1: TMenuItem;
    Save1: TMenuItem ;
    SaveAs1: TMenuItem;
    Print1:TMenuItem;
    
    Edit1: TMenuItem;
    Cut1: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    Delete1: TMenuItem;
    SynAnySyn1: TSynAnySyn;
    Memo1: TSynEdit;
    Undo1: TMenuItem;
    N4: TMenuItem;
    SelectAll1: TMenuItem;
    Find1: TMenuItem;
    Repalce1: TMenuItem;
    FindNext1: TMenuItem;
    N5: TMenuItem;
    ToolBox1: TMenuItem;
    deleteLabelNumber1: TMenuItem;
    AddLabelNumber1: TMenuItem;
    CaseChange1: TMenuItem;
    WordWrap1: TMenuItem;
    Run1: TMenuItem;
    Run2: TMenuItem;
    Trace1: TMenuItem;
    step1: TMenuItem;
    Break1: TMenuItem;
    Option1: TMenuItem;
    option2: TMenuItem;
    AutoCorrect1: TMenuItem;
    Syntax1: TMenuItem;
    Compatibility1: TMenuItem;
    Font1: TMenuItem;
    N6: TMenuItem;
    N3: TMenuItem;
    Window1: TMenuItem;
    TextOut1: TMenuItem;
    Graphic1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    Contents1: TMenuItem;
    L1: TMenuItem;
    N1: TMenuItem;
    Debug1: TMenuItem;
    ButtonFrame1: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    AutoFormat1: TMenuItem;
    N7: TMenuItem;
    S1: TMenuItem;
    I1: TMenuItem;

    StatusBar1: TStatusBar;
    ToolbarImages: TImageList;
    ToolBar1: TToolBar;
    tbNew: TToolButton;
    TBOpen: TToolButton;
    TBSave: TToolButton;
    TBPrint: TToolButton;
    ToolButton15: TToolButton;
    TBCut: TToolButton;
    TBCopy: TToolButton;
    TBPaste: TToolButton;
    TBUndo: TToolButton;
    ToolButton12: TToolButton;
    TBRun: TToolButton;
    TBStep: TToolButton;
    TBBreak: TToolButton;
    ToolButton16: TToolButton;
    TBHelp: TToolButton;
    ShowToolBar1: TMenuItem;
    TBDecimal: TToolButton;
    TBHighPrecision: TToolButton;
    TBBinary: TToolButton;
    TBDeg: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton3: TToolButton;
    TBComplex: TToolButton;
    TBRational: TToolButton;


    SaveDialog1: TSaveDialog;
    FontDialog1: TFontDialog;
    OpenDialog1: TOpenDialog;
    FindDialog1: TFindDialog;
    ReplaceDialog1: TReplaceDialog;

    PopupMenu1: TPopupMenu;
    popupRun1: TMenuItem;
    Popupstep1: TMenuItem;
    N12: TMenuItem;
    Cut2: TMenuItem;
    copy2: TMenuItem;
    paste2: TMenuItem;
    Delete2: TMenuItem;
    SelectAll2: TMenuItem;
    N15: TMenuItem;
    PopUpBreak1: TMenuItem;

    procedure Commentize1Click(Sender: TObject);
    procedure Commentize2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormResize(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure GraphOpt1Click(Sender: TObject);
    procedure Memo1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MultiByteCharEditClick(Sender: TObject);
    //procedure FormActivate(Sender: TObject);

    procedure New1Click(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure Break1Click(Sender: TObject);
    procedure Font1Click(Sender: TObject);
    procedure option2Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure TextOut1Click(Sender: TObject);
    procedure Graphic1Click(Sender: TObject);
    procedure Contents1Click(Sender: TObject);
    procedure Search1Click(Sender: TObject);
    procedure compatibility1Click(Sender: TObject);
    procedure AutoCorrect1Click(Sender: TObject);
    procedure Syntax1Click(Sender: TObject);
    procedure ShowToolBar1Click(Sender: TObject);

    procedure tbNewClick(Sender: TObject);
    procedure TBOpenClick(Sender: TObject);
    procedure TBSaveClick(Sender: TObject);
    procedure TBPrintClick(Sender: TObject);
    procedure TBCutClick(Sender: TObject);
    procedure TBCopyClick(Sender: TObject);
    procedure TBPasteClick(Sender: TObject);
    procedure TBUndoClick(Sender: TObject);
    procedure TBRunClick(Sender: TObject);
    procedure TBStepClick(Sender: TObject);
    procedure TBBreakClick(Sender: TObject);
    procedure TBHelpClick(Sender: TObject);
    procedure TBDecimalClick(Sender: TObject);
    procedure TBHighPrecisionClick(Sender: TObject);
    procedure TBBinaryClick(Sender: TObject);
    procedure TBDegClick(Sender: TObject);
    procedure TBComplexClick(Sender: TObject);
    procedure TBRationalClick(Sender: TObject);

    procedure L1Click(Sender: TObject);
    procedure Debug1Click(Sender: TObject);
    procedure ButtonFrame1Click(Sender: TObject);
    procedure N9Click(Sender: TObject);
    procedure AutoFormat1Click(Sender: TObject);
    procedure I1Click(Sender: TObject);
    procedure MenuFont1Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Cut1Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure Paste1Click(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure SelectAll1Click(Sender: TObject);
    procedure SaveAs1Click(Sender: TObject);
    procedure Print1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Uncommentize1Click(Sender: TObject);
    procedure UnCommentize2Click(Sender: TObject);
    procedure WordWrap1Click(Sender: TObject);
    procedure Find1Click(Sender: TObject);
    procedure Repalce1Click(Sender: TObject);
    procedure FindNext1Click(Sender: TObject);
    procedure Find(Sender: TObject);
    procedure Replace(Sender: TObject);
    procedure FindDialog1Find(Sender: TObject);
    procedure ReplaceDialog1Find(Sender: TObject);
    procedure ReplaceDialog1Replace(Sender: TObject);
    procedure Run2Click(Sender: TObject);
    procedure step1Click(Sender: TObject);
    procedure ToolBox1Click(Sender: TObject);
    procedure Undo1Click(Sender: TObject);
    procedure deleteLabelNumber1Click(Sender: TObject);
    procedure merge1Click(Sender: TObject);
    procedure SelectAll2Click(Sender: TObject);
    procedure Popupstep1Click(Sender: TObject);
    procedure Cut2Click(Sender: TObject);
    procedure copy2Click(Sender: TObject);
    procedure paste2Click(Sender: TObject);
    procedure Delete2Click(Sender: TObject);
    procedure popupRun1Click(Sender: TObject);
    procedure PopUpBreak1Click(Sender: TObject);
    procedure Edit1Click(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure AddLabelNumber1Click(Sender: TObject);
    procedure CaseChange1Click(Sender: TObject);

    procedure Memo1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Memo1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

    function CloseQuery:boolean;override;
    
  private
     executing:boolean;
     OverWriteMode:boolean;
     searchLength:integer;
    procedure SetOptionMenues(b:byte);
    procedure SetPrecisionButtons(mode:tpPrecision) ;

    function search(const FText:ansistring; Options1:TFindOptions):boolean;
    function curText:ansistring;
    procedure UpdateCursorPos;
    procedure PrepareSearch;
    procedure AutoFormat(a:integer; RegId:boolean);
    function SaveAs:boolean;
    function Save:boolean;
    procedure Commentize(f:boolean);
  public
     backup:ansistring;
     UnDoFromBackUp:boolean;
     AngleConfirmed:boolean;
     ArithmeticConfirmed:boolean;
     BreakHighlighter: TSynPositionHighlighter;
     BreakAttr, DefaultAttr:TtkTokenKind;
     SynHLBasic: TSynHLBasic;
    procedure ActiveFormChange(Sender: TObject);
    function ValidComponent(component:TComponent):boolean;
    function OpenTextFile(Filename: string):boolean;
    procedure SetStatusBar1(OverWriteMode:boolean);
    procedure SetAngleButtons(s:boolean);
    procedure SetBreakMessage;
end;

var
  FrameForm: TFrameForm;
var
  ToTerminate:boolean=false;
  ToOpen:boolean=false;
  ToOpenFile:string='';


implementation
uses
  StrUtils,
  optiondg,compadlg,toolfrm,texthand, optina,syntaxdg,tracefrm,
  debugdg, fkeydlg, struct,afdg,sconsts, about, printdlg, graphopt,
  findText,kwlist,  Compiler,htmlhelp,kedit,textfile;
{$R *.lfm}

var
  InitialDir:ansistring='.';

var
    ScalingFactor:double=1.0;
    Width0:integer=0;
    EldWidth:integer;

procedure TFrameForm.FormCreate(Sender: TObject);
var
  s:string;
begin

    Caption:=AppTitle;
    OpenDialog1.Title:=s_OpenFile;
    SaveDialog1.Title:=s_SaveFile;

    Screen.OnActiveFormChange := ActiveFormChange;

  {$IFDEF DARWIN}
   Run2.ShortCut:= 119 ;
   Step1.ShortCut:=ShortCut(119, [ssShift]);
   ToolBox1.ShortCut:=ShortCut(VK_K, [ssMeta]);
   Open1.shortCut:=ShortCut(VK_O,[ssMeta]);
   New1.shortCut:=ShortCut(VK_N,[ssMeta]);
   Save1.shortCut:=ShortCut(VK_S,[ssMeta]);
   SaveAS1.ShortCut:=ShortCut(VK_S,[ssShift,ssMeta]);
   Cut1.shortCut:=ShortCut(VK_X,[ssMeta]);
   Copy1.shortCut:=ShortCut(VK_C,[ssMeta]);
   Paste1.shortCut:=ShortCut(VK_V,[ssMeta]);
   SelectAll1.ShortCut:=shortCut(VK_A,[ssMeta]);
   Undo1.shortcut:=ShortCut(VK_Z,[ssMeta]);
   PopUpRun1.shortCut:=ShortCut(VK_R,[ssMeta]);
   PopUpStep1.shortCut:=ShortCut(VK_S,[ssMeta]);
   PopUpBreak1.shortCut:=ShortCut(VK_B,[ssMeta]);
  {$ENDIF}
   MultiByteCharEdit.ShortCut:=shortcut(vk_K,[ssAlt]);
  {$IFDEF Windows}
   multibyteCharEdit.ShortCut:=0;
  {$ENDIF}

   with TMyIniFile.create('Frame') do
       begin
         BreakKey:=ReadString('BreakKey',BreakKey)[1];
         Left:=ReadInteger('Left',Left);
         Top:=ReadInteger('Top',Top);
         EldWidth:=ReadInteger('Width',Width);        //2025.08.26
         Width:=EldWidth;                             //2025.08.26
         Height:=ReadInteger('Height',Height);
         HideSyntaxMenu:=ReadBool('HideSyntaxMenu',HideSyntaxMenu);
         NoBackUp:=ReadBool('NoBackUp',NoBackUp);
         BasExt:=ReadString('BasExt',BasExt);
         LibExt:=ReadString('LibExt',LibExt);
         InitialDir:=ReadString('InitialDir', InitialDir);
         OpenDialog1.InitialDir:=InitialDir;
         InitialDir:=ReadString('InitialDir', InitialDir);
         SaveDialog1.InitialDir:=InitialDir;
         Run2.ShortCut:=ReadInteger('RunShortCut',Run2.ShortCut);
         Step1.ShortCut:=ReadInteger('StepShortCut',Step1.ShortCut);
         s:=ReadString('MultiByteCharEdit','');
         if s<>'' then MultiByteCharEdit.ShortCut:=TextToShortCut(s);
         if ToolBar1.Flat<>ReadBool('Flat',ToolBar1.flat) then
                                   ButtonFrame1Click(self);
         if ToolBar1.visible <> ReadBool('ToolBar',ToolBar1.visible) then
                                   ShowToolBar1Click(self);
         //Timer1.Interval:=ReadInteger('TimerInterval',50);
         if ReadOnly then
            I1.Enabled:=false;
         free
       end;

     with TMyIniFile.create('EditorFont') do
         begin
             RestoreFont(Memo1.Font);
             free
         end;

     if permitMicrosoft then MinimalBasic:=true;
     SetOptionMenues(0);
     if MinimalBasic then SetOptionMenues(1);
     if permitMicrosoft then  SetOptionMenues(2);
     if HideSyntaxMenu then
         begin
             syntax1.enabled:=false;
             MinimalBasic:=false;
             PermitMicrosoft:=false;
             SetOptionMenues(0);
         end;
   FrameForm.StatusBar1.Panels[3].text:=statusBarMems3;

   // ToolBar1.Height:=27;

     Break1.ShortCut:=ShortCut(Word(BreakKey), [ssCtrl]);
     executing:=false;
     OverWriteMode:=false;
     TBBreak.Enabled:=false;
     //  WindowState:=wsNormal

  // BreakPoint Highlighter
  BreakHighlighter:=TSynPositionHighlighter.Create(Self);
  BreakAttr:=BreakHighlighter.CreateTokenID('BreakPoint', BreakPointColor,clNone,[fsUnderline]);
  DefaultAttr:=BreakHighlighter.CreateTokenID('Default', ClNone,clNone,[]);
  //Timer1.Enabled:=false;

  SynHLBasic:=TSynHLBasic.Create(self);
  with memo1 do
     if KeywordColoring then
        Highlighter:=SynHLBasic
     else
        Highlighter:=SynAnySyn1;

  ReplaceDialog1.Options:=[frDown,frHideEntireScope,frHidePromptOnReplace,frHideUpDown]; //ver 8.1.5.1

end;




procedure TFrameForm.FormDestroy(Sender: TObject);
begin
      //Application.HelpCommand(HELP_QUIT,0);
      if width0>0 then ScalingFactor:=Width0/EldWidth;
      with TMyIniFile.create('Frame') do
      begin
          WriteInteger('Left',Round(Left/ScalingFactor));
          WriteInteger('Top',Round(Top/ScalingFactor));
          WriteInteger('Width',Round(Width/ScalingFactor));
          WriteInteger('Height',Round(Height/ScalingFactor));
          WriteBool('Flat',ToolBar1.Flat);
          WriteBool('ToolBar',ToolBar1.visible);
          WriteInteger('RunShortCut',Run2.ShortCut);
          WriteInteger('StepShortCut',Step1.ShortCut);
          WriteString('MultiByteCharEdit',ShortCutToText(MultiByteCharEdit.shortCut));
          //WriteInteger('TimerInterval',Timer1.Interval);
          Free
      end;

     with TMyIniFile.create('EditorFont') do
         begin
             StoreFont(Memo1.Font);
             free
         end;

end;

procedure TFrameForm.FormShow(Sender: TObject);
begin
  if ToTerminate then
     Application.Terminate  ;

  if ToOpen then
     begin
       TextForm.hide;    //WindowState:=wsMinimized;
       PaintForm.hide;   //WindowState:=wsMinimized;
       TraceForm.hide;  //.WindowState:=wsMinimized;
       OpenTextFile(ToOpenFile);
       Application.ProcessMessages;

       ToOpen:=false;
       BringToFront;
     end;

  if width0=0 then width0:=width;


end;

(*
procedure TFrameForm.FormActivate(Sender: TObject);
begin
    FrameForm.setStatusBar1(OverWriteMode);
    with FrameForm do
      begin
        TBCut.enabled:=not executing;
        TBPaste.enabled:=not executing;
        TBUndo.enabled:=not executing;
      end;
    UpdateCursorPos ;

end;
*)

procedure TFrameForm.FormResize(Sender: TObject);
begin
   memo1.refresh;
end;

procedure TFrameForm.ActiveFormChange(Sender: TObject);
begin
end;

procedure TFrameForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   windowState:=wsNormal;
   toolbox.close;
end;

procedure TFrameForm.FormDeactivate(Sender: TObject);
begin
    //FindDialog1.closeDialog;
    //ReplaceDialog1.closeDialog;
end;

procedure TFrameForm.GraphOpt1Click(Sender: TObject);
begin
  GraphOptDlg.execute;
end;


procedure TFrameForm.Memo1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  //UpdateCursorPos
end;


procedure TFrameForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  MsgVal: integer;
  FileName: string;
begin
  if executing then
     begin
      //ShowMessage(s_CannotQuit);
      Break1Click(Sender);
      CanClose:=false;
      exit
     end
  else
     begin
        FileName := OpenDialog1.FileName;
        if Memo1.Modified then
         begin
          MsgVal := MessageDlg(Format(CloseMsg, [FileName]),
                    mtConfirmation, [mbYes,mbNo,mbCancel], 0);
          case MsgVal of
            mrYes:    CanClose:=Save;
            mrNo:     CanClose:=true;
            mrCancel: CanClose:=false;
          end;
        end
       else
        CanClose:=true;
     end;
end;

function TFrameForm.ValidComponent(component:TComponent):boolean;
var
   i:integer;
begin
   ValidComponent:=true;
   i:=ComponentCount;
   while i>0 do
       begin
           dec(i);
           if Components[i]=component then exit
       end;
   ValidComponent:=false
end;




function TFrameForm.CloseQuery:boolean;
begin
  FormCloseQuery(Self,result)
end;

var PrevIndex:integer=0;

const
  BOM=#239#187#191;

{
function ReadSJISFile(const fname:string):string;
var
      p:PChar;
      i,k:integer;
      s:TFileStream;
begin
  with TFileStream.Create(fname,fmOpenRead) do
         try
             k:=size;
             p:=Allocmem(k+1);
             try
                for i:=0 to k-1 do
                   Read(p[i],1);
             if copy(p,1,3)=BOM then //UTF8
                result:=copy(p,4,k-3)
             else
                Result:=NativeToUTF8(p);
             finally
                FreeMem(p,k+1);
             end;
         finally
           free;
         end;
end;
}
function ReadSJISFile(const fname:string):string;
begin
   with TStringList.Create do
      begin
         LoadFromFile(fname);
         if copy(text,1,3)=BOM then //UTF8
             result:=copy(text,4,length(text)-3)
          else
             result:=NativeToUTF8(text);
         free;
      end;
end;

function TFrameForm.OpenTextFile(FileName: string):boolean;
const DefaultText:string=EOL+'END'+EOL;
begin
  result:=false;
  Hint:='';
  previndex:=0;

 OpenDialog1.FileName:=FileName;
 if FileName <> '' then
       try
          if  ProgramFileCharsetUTF8  then
             Memo1.LINES.LoadFromFile(FileName)
          else
             with Memo1.lines do
                begin
                  beginUpdate;
                  Text:=ReadSJISFile(FileName);
                  EndUpdate
                end;

          Memo1.Modified:=false;
          Caption := AppTitle + ' [ ' + FileName + ' ]';
          result:=true;
       except
          MessageDlg(s_Extype9003+EOL+FileName,mtError, [mbOk],0);
       end
  else
       begin
          OpenDialog1.FileName:='NoName'+BasExt;
          Memo1.ClearAll;
          if not permitMicrosoft then
             //Memo1.seltext:=DefaultText;       //This causes an error on Linux Lazarus 0.9.24
             with Memo1.Lines do
               begin
                 BeginUpdate;
                 text:=DefaultText;
                 endUpdate;
               end;
          Memo1.SelStart:=0;
          Memo1.Modified:=false;
          Caption:=AppTitle;
          result:=true;
       end;
  if (CompareStr(UpperCase(ExtractFileExt(FileName)), BASExt) = 0) or
      (FileName = '') then
     begin
       N7.visible:=false;
       WordWrap1.visible:=false
     end ;
end;


procedure TFrameForm.New1Click(Sender: TObject);
begin
  if executingNow then exit;
  if memo1.Modified and not CloseQuery then exit;
  OpenTextFile('');
end;

procedure TFrameForm.Open1Click(Sender: TObject);
begin
  if executingNow then exit;
  if memo1.Modified and not CloseQuery then exit;
  OpenDialog1.Filter :=
      s_program+'|*'+BasExt+';*.BAS;*.BAK|'
      +s_Library+'|*'+LibExt+';*.Lib;*.LIB|'
      +s_TextFile+'|*.txt;*.TXT;*.log;*.LOG|';
  OpenDialog1.DefaultExt :=copy(BasExt,2,3);
  if OpenDialog1.Execute then
     OpenTextFile(OpenDialog1.FileName);
end;


function TFrameForm.Save:boolean;
var
   i:integer;
begin
  with OpenDialog1 do
    begin
    if (FileName = '') or (Pos('NoName',FileName)>0 )then
      result:=SaveAs
    else
    begin
      if  ProgramFileCharsetUTF8 then
          //Memo1.Lines.SaveToFile(FileName)   Syneditがエラーを起こす
          With TStringList.Create do
            begin
               for i:=0 to Memo1.Lines.Count-1 do
                   Add(memo1.lines[i]);
               SaveToFile(FileName);
               Clear; Free;
            end
      else
         With TStringList.Create do
            begin
               for i:=0 to Memo1.Lines.Count-1 do
                   Add(UTF8toNative(memo1.lines[i]));
               SaveToFile(FileName);
               Clear; Free;
            end ;
      Memo1.Modified := false;
      Caption := AppTitle + ' [ ' + FileName + ' ]';   //2017.1.3 ver.0.6.5.2
      result:=true;
    end;
  end;
end;


procedure TFrameForm.Save1Click(Sender: TObject);
begin
   save;
end;


function TFrameForm.SaveAs:boolean;
begin
  With FrameForm.SaveDialog1 do
  begin
     Filter:=s_program+'|*'+BasExt+'|'+s_library+'|*'+LibExt+'|'+s_TextFile+'|*.TXT';
     FileName := OpenDialog1.FileName;
     DefaultExt:=copy(BasExt,2,3);
     result:=Execute;
     if result then
     begin
      OpenDialog1.FileName := FileName;
      result:=Save;
     end;
  end;
end;

procedure TFrameForm.SaveAs1Click(Sender: TObject);
begin
   SaveAs
end;


procedure TFrameForm.Close1Click(Sender: TObject);
begin
  Close;
end;

procedure TFrameForm.Break1Click(Sender: TObject);
begin
   with DebugDlg  do
          if WindowState<>wsNormal then WindowState:=wsNormal;
    ctrlBreakHit:=true;
    SetBreakMessage;
end;


procedure TFrameForm.Font1Click(Sender: TObject);
var
   i:integer;
begin
  FontDialog1.Font.assign(Memo1.Font);
  if FontDialog1.Execute then
     begin
        Memo1.Font.assign(FontDialog1.Font);
     end;
end;

procedure TFrameForm.option2Click(Sender: TObject);
begin
   Optiondg.setoption;
   SetPrecisionButtons(InitialPrecisionMode0);
end;

procedure TFrameForm.SetPrecisionButtons(mode:tpPrecision);
begin
   case Mode of
      PrecisionNormal:  TBDecimal.down:=true;
      PrecisionHigh:    TBHighprecision.Down:=true;
      PrecisionNative:  TBBinary.down:=true;
      PrecisionComplex: TBComplex.down:=true;
      PrecisionRational:TBRational.down:=true;
   end;
end;

procedure TFrameForm.SetAngleButtons(s:boolean);
begin
   TBdeg.down:=s;
end;


procedure TFrameForm.compatibility1Click(Sender: TObject);
begin
   setCompatibility
end;


procedure TFrameForm.AutoCorrect1Click(Sender: TObject);
begin
   optionAC.execute;                                     //ver.8.1.3.3


end;


procedure TFrameForm.SetOptionMenues(b:byte);
const
    mes:array[0..2]of string=(s_Standard,s_Minimal,s_MS);
var
    s:boolean;
begin
   StatusBar1.Panels[2].text:=mes[b];
   case b of
      0,1:begin
            s:=true;
            setPrecisionButtons(InitialPrecisionMode0);
            SetAngleButtons(InitialAngleDegrees);
          end;
      else begin    {Microsoft BASIC}
            s:=false;
            setPrecisionButtons(PrecisionNative);
            SetAngleButtons(false);
          end;
    end;
    option2.enabled:=s;
    Compatibility1.enabled:=s;
    Autocorrect1.enabled:=s;
    TBDecimal.enabled:=s;
    TBHighPrecision.enabled:=s;
    TBComplex.enabled:=s;
    TBRational.enabled:=s;
    TBDeg.enabled:=s;
end;

procedure TFrameForm.Syntax1Click(Sender: TObject);
var
   b:byte;
begin
   with SyntaxDlg do
   begin
       b:=byte(MinimalBasic);
       RadioGroup1.ItemIndex:=b;
       if permitMicrosoft then RadioGroup1.ItemIndex:=2;
       CheckListBox1.checked[0]:=OptionExplicit;

       if ShowModal=mrOK then
         begin
            MinimalBasic:=RadioGroup1.Itemindex>0;
            permitMicrosoft:=(RadioGroup1.Itemindex=2);
            SetOptionMenues(RadioGroup1.ItemIndex);
            OptionExplicit:=(CheckListBox1.checked[0]) and not MinimalBasic;
         end;
   end;
end;



procedure TFrameForm.SetStatusBar1(OverWriteMode:boolean);
begin
         if OverWriteMode then
            begin
              StatusBar1.Panels[0].text:=s_Overwrite;
              StatusBar1.Panels[0].Bevel:=pbRaised;
            end
         else
            begin
              StatusBar1.Panels[0].text:=s_insert;
              StatusBar1.Panels[0].Bevel:=pbLowered;
            end;
end;

procedure TFrameForm.TextOut1Click(Sender: TObject);
begin
    with TextForm do
      begin
        show;
        WindowState:=wsNormal;
        BringToFront
      end;
end;

procedure TFrameForm.Graphic1Click(Sender: TObject);
begin
    with Paintform do
      begin
        show;
        WindowState:=wsNormal;
        BringToFront;
        Repaint;
      end;
end;





procedure TFrameForm.TBOpenClick(Sender: TObject);
begin
   Open1Click(sender)
end;

procedure TFrameForm.TBSaveClick(Sender: TObject);
begin
   SaveAs1click(sender)
end;

procedure TFrameForm.TBPrintClick(Sender: TObject);
begin
   Print1click(sender)
end;

procedure TFrameForm.TBCutClick(Sender: TObject);
begin
  Cut1click(sender)
end;

procedure TFrameForm.TBCopyClick(Sender: TObject);
begin
   Copy1click(sender)
end;


procedure TFrameForm.TBPasteClick(Sender: TObject);
begin
   Paste1click(sender)
end;


procedure TFrameForm.TBUndoClick(Sender: TObject);
begin
   Undo1click(sender)
end;

procedure TFrameForm.TBRunClick(Sender: TObject);
begin
  Run2click(sender)
end;


procedure TFrameForm.TBStepClick(Sender: TObject);
begin
  Step1click(sender)
end;



procedure TFrameForm.TBBreakClick(Sender: TObject);
begin
  Break1click(sender)
end;

procedure TFrameForm.TBHelpClick(Sender: TObject);
begin
    Search1Click(Sender)
    //Contents1Click(sender)
end;

procedure TFrameForm.TBDecimalClick(Sender: TObject);
begin
     InitialPrecisionMode0:=PrecisionNormal
end;

procedure TFrameForm.TBHighPrecisionClick(Sender: TObject);
begin
     InitialPrecisionMode0:=PrecisionHigh
end;

procedure TFrameForm.TBBinaryClick(Sender: TObject);
begin
    InitialPrecisionMode0:=PrecisionNative
end;

procedure TFrameForm.TBComplexClick(Sender: TObject);
begin
    InitialPrecisionMode0:=PrecisionComplex
end;

procedure TFrameForm.TBRationalClick(Sender: TObject);
begin
    InitialPrecisionMode0:=PrecisionRational
end;


procedure TFrameForm.TBDegClick(Sender: TObject);
begin
   InitialAngleDegrees:=not InitialAngleDegrees;
end;


procedure TFrameForm.L1Click(Sender: TObject);
begin
    with TraceForm do
      begin
        show;
        if WindowState=wsMinimized then
           WindowState:=wsNormal;
        BringToFront
      end;
end;

procedure TFrameForm.Debug1Click(Sender: TObject);
begin
     DebugDlg.setFont;
end;

procedure TFrameForm.ShowToolBar1Click(Sender: TObject);
begin
    with ShowToolBar1 do
      begin
        Checked:=not checked;
        ToolBar1.visible:=checked;
        ButtonFrame1.Enabled:=checked;
      end;
end;

procedure TFrameForm.ButtonFrame1Click(Sender: TObject);
begin
   with ButtonFrame1 do
   begin
      checked:=not checked;
      Toolbar1.Flat:=not checked;
   end;

end;

procedure TFrameForm.N9Click(Sender: TObject);
begin
   FkeysDlg.Execute
end;


procedure TFrameForm.AutoFormat1Click(Sender: TObject);
begin
   AFDg.SetAutoFormat;
end;

procedure TFrameForm.SetBreakMessage;
begin
  StatusBar1.Panels[3].text:=s_To_Break;
  StatusBar1.update;
end;

procedure TFrameForm.I1Click(Sender: TObject);
begin
  InitializeEnv;
end;

procedure TFrameForm.tbNewClick(Sender: TObject);
begin
     New1Click(Sender)
end;

procedure TFrameForm.MenuFont1Click(Sender: TObject);
begin
  FontDialog1.Font:=Font;
  if FontDialog1.Execute then
        Font:=FontDialog1.Font;
end;

procedure TFrameForm.Exit1Click(Sender: TObject);
begin
  FrameForm.Close1Click(Sender);
end;


procedure TFrameForm.Cut1Click(Sender: TObject);
begin
  if executing then exit;
  with Memo1 do
  begin
      Lines.BeginUpdate;
      CutToClipBoard;
      Lines.EndUpdate;
  end;
  UnDoFromBackUp:=false;
end;

procedure TFrameForm.Copy1Click(Sender: TObject);
begin
  Memo1.CopyToClipBoard;
  UnDoFromBackUp:=false;
end;

function TestBlankLine(s:string):boolean;
var
   i,j,count:integer;
begin
   count:=0;
   result:=false;
   i:=POSex(EOL,s,1);
   while i>0  do
       begin
         j:=POSex(EOL,s,i+1);
         if j=0 then break;
         if j>i+LENGTH(EOL) then exit;
         i:=j+1;
         i:=POSex(EOL,s,i);
         inc(count);
       end;
    if count>2 then result:=true;
end;

function AdjustBlankLine(s:string):string;
var
   i:integer;
begin
   if  TestBlankLine(s) then
   begin
       i:=1;
       while i>0  do
       begin
         i:=POSex(EOL,s,i);
         if i=0 then break;
         if copy(s,i+length(EOL),length(EOL))=EOL then delete(s,i,length(EOL));
         i:=i+1;
       end;
   end;
   result:=s;
end;

procedure TFrameForm.Paste1Click(Sender: TObject);
var
   s:string;
begin
  if executing then exit;
  //Memo1.PasteFromClipBoard;
  s:=AdjustBlankLine(clipboard.astext);
  with memo1 do
    begin
      BeginUpdate;
      seltext:=s;
      endupdate;
    end;
  UnDoFromBackUp:=false;
end;



procedure TFrameForm.Delete1Click(Sender: TObject);
begin
  if executing then exit;
  Memo1.ClearSelection;
  UnDoFromBackUp:=false;
end;

procedure TFrameForm.SelectAll1Click(Sender: TObject);
begin
  Memo1.SelectAll;
end;

procedure TFrameForm.Undo1Click(Sender: TObject);
begin
    if UnDoFromBackup then
      memo1.lines.text:=backUp
    else
      Memo1.Undo;
end;


procedure TFrameForm.WordWrap1Click(Sender: TObject);
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

procedure TFrameForm.PrepareSearch;
var
  s:string;
begin
  s:=Memo1.seltext;
  if MultiLine(s) then
     SearchLength:=Memo1.selend - memo1.SelStart -1
  else
     begin
        SearchLength:=Length(Memo1.text)-1;
        memo1.selstart:=0;
        FindDialog1.FindText:=s;
        ReplaceDialog1.FindText:=s;
     end;
  //Memo1.sellength:=0;
end;

procedure TFrameForm.Find1Click(Sender: TObject);
begin
  PrepareSearch;
  FindDialog1.Execute;
  FindNext1.Enabled :=True;
end;

procedure TFrameForm.Repalce1Click(Sender: TObject);
begin
  if executing then exit;
  backUp:=Memo1.lines.text;
  UnDoFromBackUp:=true;

  PrepareSearch;
  ReplaceDialog1.Execute;
  FindNext1.Enabled := False;
end;

procedure TFrameForm.FindNext1Click(Sender: TObject);
begin
  Find(FindDialog1);
end;

function TFrameForm.search(const FText:ansistring; Options1:TFindOptions):boolean;
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
             p:=findword(memo1,FText,InitialPos,SearchLength,s)
          else
             //p:=findtext(FText,InitialPos,SearchLength,s);
             p:=SearchText(memo1,FText,InitialPos,SearchLength,s);
          if p>=0 then
            begin
               selstart:=p;
               Selend:=p+Length(FText);   //selLength:=length(FText);
               searchLength:=searchlength-(p-initialPos)-length(FText);
               result:=true;
            end
          else
             begin
               selStart:=SelStart+length(FText);
               SelEnd:=SelStart;   //selLength:=0;
               result:=false;
             end;
        end;
end;

procedure TFrameForm.Find(Sender: TObject);
begin
  with Sender as TFindDialog do
    if Search( FindText, Options) then
    else
      CloseDialog;      //ShowMessage( FindText + EOL + s_NotFound);
end;

procedure TFrameForm.Replace(Sender: TObject);       //ver. 8.1.5.2 //2025.11.06
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



procedure TFrameForm.FindDialog1Find(Sender: TObject);
begin
     Find(Sender);
end;

procedure TFrameForm.ReplaceDialog1Find(Sender: TObject);
begin
      Find(Sender)
end;

procedure TFrameForm.ReplaceDialog1Replace(Sender: TObject);
begin
    Replace(Sender);
end;


procedure TFrameForm.ToolBox1Click(Sender: TObject);
begin
    if not memo1.ReadOnly then
       try
           ToolFrm.ToolBox.show
       except
            showmessage('System Error')
       end;
end;



procedure TFrameForm.About1Click(Sender: TObject);
begin

       AboutBox.ShowModal

end;


procedure TFrameForm.Contents1Click(Sender: TObject);
begin
   OpenHelp('')
   //Application.HelpKeyWord('')
   //Application.HelpCommand(11,0)
end;


procedure TFrameForm.Search1Click(Sender: TObject);
var
    s:shortstring;
begin
    s:=Trim(Memo1.SelText);
    if s='' then s:=(curText);
    OpenHelp(s)
         //Application.HelpKeyword(s)
         //s:=s+chr(0);
         //Application.HelpCommand(HELP_PARTIALKEY,LongInt(@s[1]))
end;


procedure TFrameForm.Run2Click(Sender: TObject);
begin
   backup:=memo1.lines.text;
   UnDoFromBackUp:=true;
   while executing do sleep(10);
   executing:=true;
   RunNormal;
   executing:=false;
end;

procedure TFrameForm.step1Click(Sender: TObject);
begin
   backup:=memo1.lines.text;
   UnDoFromBackUp:=true;
   while executing do sleep(10);
   executing:=true;
   RunStep;
   executing:=false;
end;


procedure TFrameForm.deleteLabelNumber1Click(Sender: TObject);
begin
      backup:=memo1.lines.text;
      UndoFromBackUp:=true;
      deleteLabelNumber(memo1)
end;

procedure TFrameForm.merge1Click(Sender: TObject);
var
  s:TStringList;
begin
  OpenDialog2.Filter :=
        s_Library+'|*.lib|'+s_Program+'|*.bas|'+s_TextFile+'|*.txt';
  OpenDialog2.DefaultExt := 'lib';
  if OpenDialog2.Execute then
    begin
        s:=TStringList.Create;
        s.loadFromFile(OpenDialog2.FileName);
        with memo1.lines do
          begin
            beginUpdate;
            addstrings(s);
            endupdate;
          end;
        memo1.modified:=true;
        s.clear;
        s.free;
      end;
end;

procedure TFrameForm.SelectAll2Click(Sender: TObject);
begin
     SelectAll1Click(Sender)
end;

procedure TFrameForm.Popupstep1Click(Sender: TObject);
begin
     step1Click(Sender)
end;

procedure TFrameForm.Cut2Click(Sender: TObject);
begin
    Cut1Click(Sender)
end;

procedure TFrameForm.copy2Click(Sender: TObject);
begin
       copy1Click(Sender)
end;

procedure TFrameForm.paste2Click(Sender: TObject);
begin
     paste1Click(sender)
end;

procedure TFrameForm.Delete2Click(Sender: TObject);
begin
     Delete1Click(Sender)
end;

procedure TFrameForm.popupRun1Click(Sender: TObject);
begin
       Run2Click(Sender)
end;

procedure TFrameForm.PopUpBreak1Click(Sender: TObject);
begin
    break1Click(Sender)
end;

procedure TFrameForm.Edit1Click(Sender: TObject);
var
   b:boolean;
begin
    b:= memo1.seltext<>'' ;
    with cut1 do enabled:=(not executing) and b;
    copy1.enabled:=b;
    with delete1 do enabled:=(not executing) and b;
    paste1.Enabled:=not executing;
end;

procedure TFrameForm.PopupMenu1Popup(Sender: TObject);
var
   b:boolean;
begin
    b:= memo1.seltext<>'' ;
    cut2.enabled:=(not executing) and b;
    copy2.enabled:=b;
    delete2.enabled:=(not executing) and b;
    paste2.enabled:=(not executing) ;
end;


const
   KeyWordChar:set of char=['0'..'9','A'..'Z','a'..'z','$','_'];
   PunctuationChar:set of char=[#13,#10,' ','&'..'/',':'..'>','^'];



function TFrameForm.curText:ansistring;
var
   i,j:integer;
   s:ansistring;
begin
    result:='';
    i:=memo1.selstart;
    j:=i;
    s:=memo1.text;
    while (i>1) and (s[i-1] in KeyWordChar) do dec(i);
    while s[j] in KeyWordChar do inc(j);
    result:=copy(s,i,j-i)
end;

procedure TFrameForm.AddLabelNumber1Click(Sender: TObject);
begin
      backup:=memo1.lines.text;
      UndoFromBackUp:=true;
      AddLabelNumber(memo1);
end;

procedure TFrameForm.CaseChange1Click(Sender: TObject);
begin
      backup:=memo1.lines.text;
      UndoFromBackUp:=true;
      CaseChange(memo1);
end;

procedure TFrameForm.UpdateCursorPos;
var
  CPos: TPoint;
begin
  if  executing then  exit;
  try                                          //ver.8.1.3.8
    CPos.Y := Memo1.CaretY;
    CPos.X := Memo1.CaretX;
    FrameForm.StatusBar1.Panels[1].text:=Format('%6d:%4d', [CPos.y, CPos.x]);
  except
    FrameForm.StatusBar1.Panels[1].text:='';
  end;
end;


procedure TFrameForm.Memo1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  procedure insert(const s:string);
     begin
         backUp:=Memo1.lines.Text;
         with memo1 do
           begin
             beginupdate;
             seltext:=s;
             SelStart:=SelStart+length(s);
             endupdate;
           end;
          //Memo1.SelLength:=0;
         UndoFromBackUp:=true;
     end;
begin
  if (shift=[]) then
    case Key of
      vk_F1:begin
             Search1Click(Sender);
            end;
      vk_insert:if memo1.ReadOnly=false then
                 begin
                   OverWriteMode:=not OverWriteMode;
                   FrameForm.SetStatusBar1(OverWriteMode);
                   ;
                 end;
    end
  else if  (shift=[ssshift]) and (memo1.ReadOnly=false) then
    case Key of
      vk_F5:insert(shift_F5);
      vk_F6:insert(shift_F6);
      vk_F7:insert(shift_F7);
      //vk_F8:insert(shift_F8);
    end ;

  if  Memo1.selStart=Memo1.SelEnd then                  // 2022.03.17     //ver. 8.1.1.4
     begin
        if not ExecutingNow and AutoFormatKw  then
           case key of                                     // 2025.08.26  //ver. 8.1.4.6
             vk_up: AutoFormat(1,false);
             vk_SPACE: AutoFormat(0,false);
             vk_down: AutoFormat(-1,false);
             vk_RETURN: AutoFormat(-1,TestRegisterID) ;    // 2025.08.08  //ver. 8.1.4.5
           end;
     end;

  if  Memo1.selStart=Memo1.SelEnd then                  // 2022.03.17     //ver. 8.1.1.4
     begin
        UpdateCursorPos;
     end;
end;



procedure TFrameForm.Memo1KeyDown(Sender: TObject; var Key: Word;  Shift: TShiftState);
begin
end;



function Texthand_Initline:boolean;
begin
  result:=true;
  try
     Texthand.Initline;
  except
     on e:SyntaxError do
        result:=false;
  end;
end;

function count(substr,s:string):integer;
var
   p:integer;
begin
  result:=0;
  p:=1;
  while (p>0) and (p<length(s)) do
     begin
       p:=PosEx(substr,s,p+1);
       if p>0 then inc(result)
     end;
end;

procedure RegisterId;
var
   i:integer;
   CurrentTBL: TKeyWordList1;

begin
  CurrentTBL:=nil;
  if  texthand_initline then
    begin
        try
          while tokenspec<>tail do
            begin
             if tokenspec in [NIdf,SIdf] then
                if CurrentTBL=nil then
                   begin
                     if StatementKwList.find(token,i)   then
                        begin
                          CurrentTBL:=TKeyWordList1(StatementKwList.objects[i]);
                          if not (CurrentTBL.kind in
                              [kdDIM, kdDeclare, kdDEF, kdFunctionSubPicture]) then
                              break;
                        end
                     else
                        break;
                   end
                else if  CurrentTBL.find(token,i) then
                         CurrentTBL:=TKeyWordList1(CurrentTBL.objects[i])
                else
                     keyWordList2.PulOut(token);
            gettoken;
          end;

      except
         NextTokenSpec:=tail;    //dummy;
      end;
    end;
end;

var AutoFormatExecuting:boolean=false;
procedure TFrameForm.AutoFormat(a:integer; RegId:boolean);
var
   i,j:integer;
   c1,c2:char;
   len:integer;
   CurPos:TPoint;
   s:string;
   CurrentTBL: TKeyWordList1;
   FunctionsAllowed, DEForLET, AfterTHEN:boolean;
begin
  if executing then exit;
  if AutoFormatExecuting then exit;
  AutoFormatExecuting:=true;
  //j:=PrevLine;

  CurPos:=Memo1.CaretXY;
  j:=CurPos.y-1;
  j:=j+a;
  if (j<0) or (j>=Memo1.Lines.Count) or (pass<>0) then exit;
  s:=Memo1.Lines[j];
  if count('"',s) mod 2 > 0 then exit;

  if TextHand.memo<>nil then exit;
  texthand.memo:=Memo1;
  try           //ver. 8.1.5.2     //2025.11.07
    texthand.linenumber:=j;
    CurrentTBL:=nil;
    FunctionsAllowed:=false;
    DEForLET:=false;
    AfterTHEN:=false;

    if  texthand_initline then
    begin
      Memo1.beginupdate(false);    //2022.03.17   //ver. 8.1.1.4
      try
        try
         while tokenspec<>tail do
            begin
               if DEForLET and (token<>'') and ((token[1]='=')or(Token[1]='(')) then
                   begin
                      DEForLET:=false;
                      FunctionsAllowed:=true
                   end
               else if (CurrentTbl<>nil) and
                       (CurrentTbl.Count>0) and
                       (CurrentTbl.kind=kdAny) then
                  begin
                     if CurrentTbl.TogetherWith<>nil then
                        if CurrentTBL.TogetherWith.Find(token,i)    then
                              ReplaceToken2(token);
                     CurrentTBL:=TKeyWordList1(CurrentTBL.objects[0])
                  end
               else if tokenspec in [NIdf,SIdf,Relational] then
                  if CurrentTBL=nil then
                     begin
                       if StatementKwList.find(token,i)   then
                          begin
                            ReplaceToken2(token);
                            CurrentTBL:=TKeyWordList1(StatementKwList.objects[i]);
                            if  CurrentTBL.kind in [kdREM,kdDataImage] then
                                break
                            else if  CurrentTBL.kind in [kdDEF,kdLET] then
                                DEForLET:=true
                            else
                                FunctionsAllowed:=CurrentTBL.functionAllowed;
                          end
                       else
                          break;
                      end
                   else   // CurrentTBL<>nil
                      begin
                        if CurrentTBL=CommentRange then exit;
                        if  CurrentTBL.find(token,i) then
                           begin
                              ReplaceToken2(token);
                              if (CurrentTBL.kind=kdIF) and (token='THEN') then
                                begin
                                  CurrentTBL:=nil;                //THEN 以降に，再度，文が来る
                                  AfterTHEN:=true
                                end
                              else
                                 CurrentTBL:=TKeyWordList1(CurrentTBL.objects[i]);
                           end
                        else if AfterTHEN and (token='ELSE') then
                            begin
                               ReplaceToken2(token);
                               CurrentTBL:=nil;                  //ELSE 以降に，再度，文が来る
                            end
                        else if ReservedWord.Find(token,i)
                             or (CurrentTBL.TogetherWith<>nil)
                                    and CurrentTBL.TogetherWith.Find(token,i)
                             or FunctionsAllowed and keyWordList2.find(token,i)
                             or (CurrentTBL.kind in [kdMAT,kdDRAW])
                                    and keyWordList3.find(token,i)     then
                              ReplaceToken2(token);
                      end;

               //if (token='DATA') or (token='IMAGE') or (token='REM') then
               //    skip
               //else
                   gettoken;
            end;
         except
           NextTokenSpec:=tail;    //dummy;
         end;
       finally
         Memo1.endupdate;          //2022.03.17   //ver. 8.1.1.4
         Memo1.CaretXY:=CurPos;
      end;
    end;
    if RegId then
                  RegisterID;

  finally                         //ver.8.1.5.2    ??2025.11.07
    texthand.memo:=nil;
    AutoFormatExecuting:=false;
  end;
end;

 (*
var PrevLine:integer=-1;
procedure TFrameForm.AutoFormat;
var
   i,j:integer;
   c1,c2:char;
   len:integer;
   ExPos:TPoint;
begin
  if executing then exit;
  j:=PrevLine;
  ExPos:=Memo1.CaretXY;
  prevLine:=Memo1.CaretY-1;
  if (j<0) or (pass<>0) then exit;
  if TextHand.memo<>nil then exit; //再入防止

  memo1.beginupdate;    //2022.03.17   //ver. 8.1.1.4
  texthand.memo:=memo1;
  texthand.linenumber:=j;

     texthand.initline;
     while tokenspec<>tail do
        begin
           if tokenspec in [NIdf,SIdf] then
              begin
                 if keyWordList1.find(token,i)
                    or ((token='ANGLE') and (PrevToken='OPTION'))
                    or ((token='SIZE') and (PrevToken='DEVICE'))
                    or  keyWordList2.find(token,i) then
                    ReplaceToken2(token);
              end;
           if (token='DATA') or (token='IMAGE') or (token='REM') then
               skip
           else
               gettoken;
        end;

   texthand.memo:=nil;
   Memo1.CaretXY:=exPos;
   memo1.endupdate;          //2022.03.17   //ver. 8.1.1.4
end;
*)
(*
procedure TFrameForm.Memo1KeyUp(Sender: TObject; var Key: Word;  Shift: TShiftState);
begin
  if Memo1.sellength=0 then
     begin
        if not ExecutingNow and AutoFormatKw and (key = vk_RETURN) then
                             AutoFormat;
        UpdateCursorPos;
     end;
end;


procedure TFrameForm.AutoFormat;
var
   i,j:integer;
begin
  if executing then exit;
  if TextHand.memo<>nil then exit; //再入防止


  j:=PrevIndex;
  PrevIndex:=Memo1.SelStart;
  if  (j>0)
       and (length(Memo1.lines.Text)>j)
       and (Memo1.lines.text[j] in KeyWordChar )
       and (Memo1.lines.text[j+1] in PunctuationChar )
       and (Pass=0) then
    begin
       texthand.memo:=memo1;
       //memo1.lines.BeginUpdate;
       //texthand.linenumber:=SendMessage(memo1.handle,EM_LINEFROMCHAR,j,0);
       texthand.linenumber:=LineFromChar(memo1,j);
       try
         texthand.initline;
         while tokenspec<>tail do
            begin
               if tokenspec in [NIdf,SIdf] then
                  begin
                     if keyWordList1.find(token,i)
                        or ((token='ANGLE') and (PrevToken='OPTION'))
                        or ((token='SIZE') and (PrevToken='DEVICE'))
                        or  keyWordList2.find(token,i) then
                        ReplaceToken2(token);
                  end;
               if (token='DATA') or (token='IMAGE') or (token='REM') then
                   skip
               else
                   gettoken;
            end;
       except
         on e:exception do
       end;
       texthand.memo:=nil;
       Memo1.SelStart:= PrevIndex;
       //memo1.lines.EndUpdate;
    end;

end;
*)

procedure TFrameForm.Print1Click(Sender: TObject);
begin
   PrintDialog1.Execute(memo1);
end;

procedure TFrameForm.Timer1Timer(Sender: TObject);
begin
  //PaintForm.TimerDraw;
  //with TextForm do
  //  if Not TextOutWorking then
  //    TextoutExec;
end;

procedure TFrameForm.Commentize1Click(Sender: TObject);
begin
     Commentize(true);
end;

procedure TFrameForm.Commentize2Click(Sender: TObject);
begin
     Commentize(true);
end;




procedure TFrameForm.Uncommentize1Click(Sender: TObject);
begin
    Commentize(false);
end;

procedure TFrameForm.UnCommentize2Click(Sender: TObject);
begin
     Commentize(false);
end;

procedure TFrameForm.Commentize(f:boolean);
var
   i,l1,l2,j,len:integer;
   s:string;
begin
  if executing then exit;
  with Memo1 do
  begin
    //len:=sellength;
    len:=length(selText);
    if len>0 then dec(len);
    //l1:= SendMessage(Memo1.Handle, EM_EXLINEFROMCHAR, 0,SelStart);
    //l2:= SendMessage(Memo1.Handle, EM_EXLINEFROMCHAR, 0,SelStart + len);
    l1:=LineFromChar(Memo1,SelStart);
    l2:=LineFromChar(Memo1,SelStart+len);
    Lines.beginupdate;
    for i:=l1 to l2 do
      begin
        s:=lines[i];
        if f then
           s:='!'+s
        else
           begin
             j:=1;
             while (j<=Length(s)) and (s[j]=' ') do inc(j);
             if (j<=Length(s)) and (s[j]='!')  then  delete(s,1,j)
           end;
        lines[i]:=s;
      end;
    Lines.endupdate;
  end;
end;

procedure TFrameForm.MultiByteCharEditClick(Sender: TObject);
begin
  With KanjiEdit do
  begin
    if showmodal=mrOk then
       with memo1 do
         begin
             beginUpdate;
             SelText:=Edit1.text;
             endupdate;
         end;
    Edit1.text:=''
  end;
end;




initialization



end.
