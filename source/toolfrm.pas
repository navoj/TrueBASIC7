unit toolfrm;

{$IFDEF FPC}
  {$MODE DELPHI}  {$H-}
{$ENDIF}

(***************************************)
(* Copyright (C) 2003, SHIRAISHI Kazuo *)
(***************************************)


interface

uses
  SysUtils, Types, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ComCtrls, ExtCtrls, LResources;

type
    ItemsRecord=record
        item1   :PString;
        item2   :PString;
        hint    :PString;
        Helpctx :THelpContext;
    end;

    TTemplateList=class(TList)
            destructor  destroy;override;
        private
            ListBox:^TListBox;
            procedure NewItemChar(s1:char);
            procedure NewItemUnpack(const s:string);
            procedure NewItem3(const s1,s2:string; hc:THelpContext);
            function item1(i:integer):string;
            function item2(i:integer):string;
            function hint(i:integer):string;
            function HelpCtx(i:integer):ThelpContext;
        public
            procedure InsertItem(i:integer);
            procedure DisplayHint(label0:TLabel; i:integer);
    end;

type

  { TToolBox }

  TToolBox = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    ListBox1: TListBox;
    TabSheet2: TTabSheet;
    ListBox2: TListBox;
    TabSheet3: TTabSheet;
    ListBox3: TListBox;
    Label1: TLabel;
    Label2: TLabel;
    Panel1: TPanel;
    OkBtn: TBitBtn;
    HelpBtn: TBitBtn;
    CancelBtn: TBitBtn;
    procedure CancelBtnClick(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure ListBox1DblClick(Sender: TObject);
    procedure ListBox2Click(Sender: TObject);
    procedure ListBox2DblClick(Sender: TObject);
    procedure ListBox3DblClick(Sender: TObject);
    procedure ListBox3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure TabbedNotebook1Change(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);
  private
      StatementsList,FunctionsList,CharactorsList:TTemplateList;
      procedure Unpack(const FName:string; List1:TTemplateList);
  public
      procedure refresh;
  end;

var
  ToolBox: TToolBox;



implementation
uses helpctex,sconsts, MainFrm,htmlhelp;
{$R *.lfm}


procedure  TTemplateList.NewItemUnpack(const s:string);
begin
  with TStringList.create do
  begin
    try
       try
          commatext:=s;
          if count=3 then
             NewItem3(strings[0],strings[1],StrToIntDef(strings[2],0))
          else
             showMessage(TemplateErrMes+s);
       finally
          free
       end;
    except
       showMessage(TemplateErrMes+s);
    end;
  end;
end;




procedure  TTemplateList.NewItem3(const s1,s2:string; hc:THelpContext);
var
   p:^ItemsRecord;
   t1,t2,t3:string;
   i:integer;
Begin
   if (s1[1]=' ') and (length(s1)>1) then
      begin  t1:='';t2:='';t3:=s1 end
   else
      begin
        i:=Pos('!',s1);
        if i=0 then i:=255;
        t1:=copy(s1,1,i-1);
        t2:=copy(s1,i+1,255);
        t3:=t1+t2;
        while pos(s_Tilde,t2)>0 do
          begin
                i:=pos(s_Tilde,t2);
                t2:=copy(t2,1,i-1)+EOL+EOL+copy(t2,i+2,255);
          end;
      end;
   ListBox^.items.add(t3);
   new(p);
   with p^ do
        begin
            item1:=NewStr(t1);
            item2:=newStr(t2);
            Hint:=NewStr(s2);
            HelpCtx:=hc;
        end;
   add(p);
end;


procedure  TTemplateList.NewItemChar(s1:char);
var
   p:^ItemsRecord;
Begin
   ListBox^.items.add(s1);
   new(p);
   with p^ do
        begin
            item1:=NewStr(s1);
            item2:=newStr('');
            Hint:=NewStr('');
            HelpCtx:=0;
        end;
   add(p);
end;


destructor  TTemplateList.destroy;
var
    p:^ItemsRecord;
begin
    While count>0 do
      begin
          p:=Items[0];
          with p^ do
               begin
                  DisposeStr(item1);
                  DisposeStr(item2);
                  DisposeStr(hint);
               end;
          dispose(p);        //2011.3.8
          delete(0);
      end;
    inherited Destroy;
end;

(*
function TTemplateList.item1(i:integer):string;
var
    p:^ItemsRecord;
begin
    if (i>= 0) and (i<count) then
       begin
           p:=Items[i];
           result:=(p^.item1)^;
       end
    else
       result:='';
end;


function TTemplateList.item2(i:integer):string;
var
    p:^ItemsRecord;
begin
    if (i>= 0) and (i<count) then
       begin
           p:=Items[i];
           result:=(p^.item2)^;
       end
    else
       result:='';
end;


function TTemplateList.hint(i:integer):string;
var
    p:^ItemsRecord;
begin
    if (i>= 0) and (i<count) then
       begin
           p:=Items[i];
           result:=(p^.hint)^;
       end
    else
       result:='';
end;
*)


function TTemplateList.item1(i:integer):string;
var
    p:Pstring;
begin
    p:=nil;
    if (i>= 0) and (i<count) then
        p:=ItemsRecord(Items[i]^).Item1;
    if p<>nil then
        result:=p^
    else
        result:='';
end;


function TTemplateList.item2(i:integer):string;
var
    p:Pstring;
begin
    p:=nil;
    if (i>= 0) and (i<count) then
        p:=ItemsRecord(Items[i]^).Item2;
    if p<>nil then
        result:=p^
    else
        result:='';
end;

function TTemplateList.hint(i:integer):string;
var
    p:Pstring;
begin
    p:=nil;
    if (i>= 0) and (i<count) then
        p:=ItemsRecord(Items[i]^).hint;
    if p<>nil then
        result:=p^
    else
        result:='';
end;

function TTemplateList.helpCtx(i:integer):THelpContext;
var
    p:^ItemsRecord;
begin
    if (i>= 0) and (i<count) then
       begin
           p:=Items[i];
           result:=p^.HelpCtx;
       end
    else
       result:=0;
end;

procedure TTemplateList.InsertItem(i:integer);
var
   s:string;
   p,cp:integer;
begin
  if FrameForm.Memo1.ReadOnly then exit;

  FrameForm.BackUp:=FrameForm.memo1.lines.text;
  FrameForm.UnDoFromBackUp:=true;
  with FrameForm.memo1 do
    begin
       //SelLength:=0;
       s:=Item1(i);
       cp:=SelStart;
       // VCLではselstartは挿入したテキストの次に移動するのに対し，
       // CLXではテキストを挿入したときselstartは移動しない。
       beginupdate;
         SeLtext:=s;
         SelStart:=cp+length(s);
         p:=selstart;
         //SelLength:=0;
         SelText:=Item2(i);
         selstart:=p;
       endupdate;
       //Sellength:=0;
    end;
end;

procedure TTemplateList.DisplayHint(label0:TLabel; i:integer);
begin
    Label0.Caption:=Hint(i)
end;


procedure TToolBox.CancelBtnClick(Sender: TObject);
begin
   close
end;

procedure TToolBox.HelpBtnClick(Sender: TObject);
begin
  OpenHelp(HelpContext)
end;

procedure TToolBox.OKBtnClick(Sender: TObject);
begin
   if PageControl1.Activepage=TabSheet1 then
         ListBox1DblClick(Sender)
   else if PageControl1.Activepage=TabSheet2 then
         ListBox2DblClick(Sender)
   else if PageControl1.Activepage=TabSheet3 then
         ListBox3DblClick(Sender);

end;

procedure TToolBox.ListBox1Click(Sender: TObject);
begin
       StatementsList.DisplayHint(label1,ListBox1.ItemIndex);
       HelpContext:=StatementsList.HelpCtx(ListBox1.ItemIndex);
       ListBox1.HelpContext:=HelpContext;
       HelpBtn.HelpContext:=HelpContext;
       ListBox1.ShowHint:=false;
end;

procedure TToolBox.ListBox1DblClick(Sender: TObject);
begin
    StatementsList.InsertItem(ListBox1.ItemIndex)
end;

procedure TToolBox.ListBox2Click(Sender: TObject);
begin
       FunctionsList.DisplayHint(label2,ListBox2.ItemIndex) ;
       HelpContext:=FunctionsList.HelpCtx(ListBox2.ItemIndex);
       ListBox2.HelpContext:=HelpContext;
       ListBox2.ShowHint:=false;
end;

procedure TToolBox.ListBox2DblClick(Sender: TObject);
begin
    FunctionsList.InsertItem(ListBox2.ItemIndex)
end;

procedure TToolBox.ListBox3DblClick(Sender: TObject);
begin
    CharactorsList.InsertItem(ListBox3.ItemIndex)
end;

procedure TToolBox.ListBox3Click(Sender: TObject);
begin
    HelpContext:=insert_keyword
end;

procedure TToolBox.Unpack(const FName:string; List1:TTemplateList);
var
   s:string;
   F:TextFile;
begin
  assignFile(F,FName);
  try
    reset(F);
    while not EOF(F) do
    begin
        readLn(F,s);
        List1.NewItemUnpack(s);
    end;
    closeFile(F);
  except
    on E:Exception do
       showMessage(FName+EOL+ E.Message)
  end;
end;


procedure TToolBox.FormCreate(Sender: TObject);
var
   ch:char;
begin

   left:=Screen.width-width-4;
   height:=Screen.Height-100;
   top:=Screen.Height-Height-64;

   StatementsList:=TTemplateList.create;
   StatementsList.ListBox:=@ListBox1;
   FunctionsList:=TTemplateList.create;
   FunctionsList.ListBox:=@ListBox2;
   CharactorsList:=TTemplateList.create;
   CharactorsList.ListBox:=@ListBox3;

  Unpack(ExtractFilePath(Application.ExeName)+'basic.kws',StatementsList);
  Unpack(ExtractFilePath(Application.ExeName)+'basic.kwf',FunctionsList);

  with CharactorsList do
     begin
        for ch:=' ' to '~' do
               NewItemChar(ch);
     end;
end;

procedure TToolBox.FormDestroy(Sender: TObject);
begin
   StatementsList.Free;
   ListBox1.Items.Clear;
   FunctionsList.Free;
   ListBox2.Items.Clear;
   CharactorsList.Free;
   ListBox3.Items.Clear;
end;

procedure TToolBox.refresh;
begin
end;

procedure TToolBox.FormActivate(Sender: TObject);
begin
    HelpContext:=INSERT_KEYWORD;
    //sendMessage(PageControl1.Handle,TCS_RIGHTJUSTIFY,0,0);
end;

procedure TToolBox.TabbedNotebook1Change(Sender: TObject; NewTab: Integer;
  var AllowChange: Boolean);
begin
       HelpContext:=INSERT_KEYWORD
end;



initialization
ToolBox:=nil

end.
