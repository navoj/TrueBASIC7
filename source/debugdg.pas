unit debugdg;

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

(***************************************)
(* Copyright (C) 2003, SHIRAISHI Kazuo *)
(***************************************)


interface

uses  Classes, Graphics, Forms, Controls, Buttons,SysUtils,
   LResources, StdCtrls, ExtCtrls, ComCtrls, Dialogs,
   ListColl;

type ShowResult=(srNone,srOK,srCancel);
type
   TDebugList=class
      linenumb:integer;
      //statement:ansistring;
      ValuesList:TStringList;
      constructor create;
      destructor destroy;override;
   end;

type
   TBooleanArray=array[0..maxint-1] of boolean;
   PBooleanArray=^TBooleanArray;


type

  { TDebugDlg }

  TDebugDlg = class(TForm)
    RadioGroup1: TRadioGroup;
    ListBox1: TListBox;
    OKBtn: TBitBtn;
    HelpBtn: TBitBtn;
    Label2: TLabel;
    cancel1: TBitBtn;
    BreakPoint1: TButton;
    BackButton: TSpeedButton;
    ForwardButton: TSpeedButton;
    BackButton2: TSpeedButton;
    CheckBox1: TCheckBox;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormWindowStateChange(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure cancel1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure BreakPoint1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BackButtonClick(Sender: TObject);
    procedure ForwardButtonClick(Sender: TObject);
    procedure BackButton2Click(Sender: TObject);
    procedure RadioGroup1Enter(Sender: TObject);
  private
     WidthMin,HeightMin:integer;
     width0,Height0:integer;
     BreakPoints:TList;
     procedure setHScrolBar(p:TListBox);

  public
     lists:TListcollection;
     sr:ShowResult;
     listpointer:integer;
     procedure execute;
     procedure init;
     procedure addlist(list:TDebuglist);
     procedure showlist(i:integer);
     procedure setFont;
  end;

var
  DebugDlg: TDebugDlg;

const
   BreakPointColor=clFuchsia;


implementation
uses
     SynHighlighterPosition, SynEditHighlighter,
     base,texthand,struct, MainFrm,debug,htmlhelp,paintfrm, textfrm, tracefrm;
{$R *.lfm}
constructor TDebugList.create;
begin
    ValuesList:=TStringList.create;
end;

destructor TDebugList.destroy;
begin
   ValuesList.Clear;
   ValuesList.free;
   inherited destroy;
end;

procedure TDebugDlg.setHScrolBar(p:TListBox);
var
   i,w,t:integer;
begin
(*
   with p do
   begin
     w:=0;
     for i:=0 to items.count-1 do
        begin
           t:=label2.canvas.textwidth(items[i]);
          if w<t then
             w:=t;
        end;
     perform(LB_SETHORIZONTALEXTENT,w,0)
   end;
*)   
end;

procedure TDebugDlg.init;
var
    i,LineNo:integer;
begin
   lists.FreeAll;
   listpointer:=-1;

   with BreakPoints do
     for i:=0 to BreakPoints.Count -1 do
       begin
         LineNo:=Integer(List[i]);
         FrameForm.BreakHighlighter.ClearTokens(LineNo);
         with FrameForm do
         BreakHighlighter.AddToken(LineNo,255,DefaultAttr);
       end;
   BreakPoints.Clear;

   if BreakFlags.LongFlag then
      BreakPoint1Click(self);                //ver. 8.1.5.3 //2025.11.22


end;

procedure TDebugDlg.addlist(list:TDebugList);
begin
   lists.add(list);
   //ShowList(lists.count-1);
end;

procedure TDebugDlg.showlist(i:integer);
var
   list:TDebugList;
begin
   if (i>=0) and (i<Lists.count) then
     begin
        listpointer:=i;
        list:=Lists.items[i];
        label2.caption:=texthand.getMemoLine(list.linenumb);
        ListBox1.Items:=list.ValuesList;
        if list.linenumb<>currentLineNumb then
           begin
             DeshowCurrentLine;
             showCurrentLine(list.linenumb);
           end;
     end;
   BackButton.Enabled:=(i>0);
   BackButton2.enabled:=(i>0);
   ForwardButton.enabled:=(i<Lists.count-1);
end;

procedure SwitchMenues(s:boolean);
begin
   paintform.File1.Enabled:=s;
   paintform.Edit1.Enabled:=s;
   paintform.Open1.Enabled:=not s;
   paintform.Exit1.Enabled:=not s;
   paintform.Paste1.Enabled:=not s;
   //paintform.PopupMenu1.AutoPopup:=s;

   textform.File1.Enabled:=s;
   textform.Edit1.Enabled:=s;
   //textform.Open1.Enabled:=not s;
   textform.Exit1.Enabled:=not s;
   TextForm.PopupMenu1.AutoPopup:=s;     //LCLでは機能しない

   TraceForm.File1.Enabled:=s;
   TraceForm.Edit1.Enabled:=s;
   //TraceForm.Open1.Enabled:=not s;
   TraceForm.Exit1.Enabled:=not s;
   TraceForm.PopupMenu1.AutoPopup:=s;     //LCLでは機能しない

end;

procedure TDebugDlg.execute;
begin

   sr:=srNone;
   setHscrolBar(listBox1);
    SwitchMenues(true);
   show;
   setFocus;
   //ActiveControl:=ListBox1;
   repeat
      sleep(10);
      Application.ProcessMessages;
      //IdleImmediately;
   until sr<>srNone;
   close;
   SwitchMenues(false);

end;


procedure TDebugDlg.OKBtnClick(Sender: TObject);
begin
      sr:=srOk;
end;

procedure TDebugDlg.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
   if sr=srNone then CanClose:=false
end;



procedure TDebugDlg.FormWindowStateChange(Sender: TObject);
begin
    if WindowState<>wsNormal then WindowState:=wsNormal
end;

procedure TDebugDlg.HelpBtnClick(Sender: TObject);
begin
  OpenHelp(HelpContext);
end;

procedure TDebugDlg.cancel1Click(Sender: TObject);
begin
    sr:=srCancel;

end;

procedure TDebugDlg.FormCreate(Sender: TObject);
begin
    with TMyIniFile.create('Debug') do
      begin
        RestoreFont(ListBox1.Font);
        free
      end;
     top:=0;
     left:=screen.width-width-6;
     if left>FrameForm.left+FrameForm.width +6 then
             left :=FrameForm.left+FrameForm.width + 6;
     WidthMin:=width div 2;
     HeightMin:=Height div 2;
     //width0:=width;                    //2025.08.27
     //Height0:=height;                  //2025.08.27
     lists:=TListCollection.create;
     BreakPoints:=TList.create;
     BorderIcons:=[];
end;

procedure TDebugDlg.FormDestroy(Sender: TObject);
begin
    BreakPoints.Free;
    lists.Free;

    with TMyIniFile.create('Debug') do
      begin
         StoreFont(ListBox1.Font);
         Free
      end;
end;

procedure TDebugDlg.FormResize(Sender: TObject);
var
    dx,dy:integer;
begin
    if width0=0 then width0:=width;    // 2025.09.09
    if height0=0 then height0:=height; // 2025.09.09

    if width<WidthMin then width:=WidthMin ;
    if height<HeightMin then height:=HeightMin;
    dx:=width-width0;
    dy:=height-Height0;
    //if dy mod 2 =1 then begin height:=height-1; dec(dy) end;//なぜかこれを生かすと不具合
    width0:=width;
    Height0:=height;
      with RadioGroup1 do left:=left+dx;
      with CheckBox1 do left:=left+dx;
      with OkBtn do left:=left+dx;
      with HelpBtn do left:=left+dx;
      with Cancel1 do left:=left+dx;
      with BreakPoint1 do left:=left+dx;
      with BackButton do left:=left+dx;
      with BackButton2 do left:=left+dx;
      with ForwardButton do left:=left+dx;
      with ListBox1 do width:=width+dx;
      with ListBox1 do height:=height+dy;

end;

procedure TDebugDlg.BreakPoint1Click(Sender: TObject);
var
   styles:TFontStyles;
   LineNo:integer;
   Attr1, Attr2: TtkTokenKind;
begin

   with TextHand.memo do
   begin
       Lines.BeginUpdate;
       LineNo:=CaretY-1;       //SendMessage(Handle,EM_EXLINEFROMCHAR,0,SelStart);
                               //SelStart:=SendMessage(Handle,EM_LINEINDEX,LineNo,0);
                               //SelLength:=Length(Lines[LineNo]);
                               //styles:=selattributes.style;
       if BreakPoints.IndexOf(Pointer(LineNo))>=0  {fsUnderLIne in styles} then
         begin
               with BreakPoints do delete(IndexOf(Pointer(LineNo)));
               FrameForm.BreakHighlighter.ClearTokens(LineNo);
               with FrameForm do
                 BreakHighlighter.AddToken(LineNo,255,DefaultAttr);
               //SelAttributes.style:=SelAttributes.style-[fsUnderLIne];
               //SelAttributes.Color:=DefAttributes.Color;
               CurrentProgram.SetBreakPoint(LineNo,false);
         end
       else if CurrentProgram.SetBreakPoint(LineNo,true) then
         begin
             BreakPoints.add(Pointer(LineNo));
             with FrameForm do
               BreakHighlighter.AddToken(LineNo,255,BreakAttr);
             //SelAttributes.style:=SelAttributes.style+[fsUnderLine];
             //SelAttributes.Color:=BreakPointColor;
         end;
       //SelLength:=0;
       //SelAttributes:=DefAttributes;
       Lines.EndUpdate;
       Application.ProcessMessages;
   end;


end;

procedure TDebugDlg.BackButtonClick(Sender: TObject);
begin
    showlist(listpointer-1)
end;

procedure TDebugDlg.ForwardButtonClick(Sender: TObject);
begin
   showlist(listpointer+1)
end;

procedure TDebugDlg.BackButton2Click(Sender: TObject);
begin
   showlist(0)
end;

procedure TDebugDlg.RadioGroup1Enter(Sender: TObject);
begin
  if ActiveControl=RadioGroup1 then
     ActiveControl:=FindNextControl(RadioGroup1,true,true,false)
end;

procedure TDebugDlg.setFont;
var
  Dialog1:TFontDialog;
begin
  Dialog1:=FrameForm.FontDialog1;
  //Dialog1.Device:=fdScreen;
  Dialog1.Font.Assign(ListBox1.Font);
  if Dialog1.Execute then
     ListBox1.Font.assign(Dialog1.Font);
 
end;

initialization


end.
