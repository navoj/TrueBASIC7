unit paintfrm;

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

(***************************************)
(* Copyright (C) 2017, SHIRAISHI Kazuo *)
(***************************************)


interface

uses Types,Classes, Graphics, Forms, Controls, Menus,
  StdCtrls, Dialogs, {Printers,} SysUtils, Clipbrd,  ComCtrls,  ExtCtrls,
  graphic , LResources, lcltype, lclintf, FileUtil;


type

  { TPaintForm }

  TPaintForm = class(TForm)
    Copy2: TMenuItem;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    N2: TMenuItem;
    PopupMenu1: TPopupMenu;
    Print1: TMenuItem;
    N3: TMenuItem;
    SaveAs1: TMenuItem;
    Save1: TMenuItem;
    N4: TMenuItem;
    Close1: TMenuItem;
    Edit1: TMenuItem;
    Copy1: TMenuItem;
    Run1: TMenuItem;
    Break1: TMenuItem;
    SaveDialog1: TSaveDialog;
    FontDialog1: TFontDialog;
    OpenDialog1: TOpenDialog;
    Option1: TMenuItem;
    Size1: TMenuItem;
    Color1: TMenuItem;
    Font1: TMenuItem;
    RunOption1: TMenuItem;
    K1: TMenuItem;
    K2: TMenuItem;
    Open1: TMenuItem;
    Paste1: TMenuItem;
    Show1: TMenuItem;
    E1: TMenuItem;
    StatusBar1: TStatusBar;
    PaintBox1: TPaintBox;
    procedure Copy2Click(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure Print1Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure Paste1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Break1Click(Sender: TObject);
    procedure SaveAs1Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure OPtion1Click(Sender: TObject);
    procedure Size1Click(Sender: TObject);
    procedure Font1Click(Sender: TObject);
    procedure Color1Click(Sender: TObject);
    procedure K1Click(Sender: TObject);
    procedure K2Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    {
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    }
    procedure PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

    procedure PaintBox1Click(Sender: TObject);
    procedure E1Click(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure TimerDraw;

  private
    mouseX,mouseY:integer;
    MouseClick:boolean;
    mousestate:TShiftState;
    MainFormMonitor:TMonitor;
    function FrameFormMoved:boolean;
    procedure SizeAdjust;
    procedure ClearRect(p:PRect);            //ver.8.1.3.1
    //procedure CMMouseLeave(var Message:TMessage);message CM_MOUSELEAVE;
  public
     BitMap1:TBitMap;
     BitMapHeight:integer;
     BitMapWidth:integer;
    procedure Clear;
    procedure initial;
    procedure SetSize1;
    procedure setsize2;
    function  getpoint(var a,b:integer):boolean;
    procedure MoveMouse(a,b:integer);
    procedure MousePol(var a,b:integer; var l,r:boolean);
    function SetBitmapSize(w,h:integer):boolean;
    function OpenFile(FileName: string):boolean;
    function SaveFile(FileName: string):boolean;

  end;
var
    paintform:TPaintForm;

implementation
uses
     MainFrm,base,optiondg,colordlg, printbmp,
     myutils, arithmet,struct,sconsts, sizedlg, graphsys, MyThread;
{$R *.lfm}
const InitialCaption='BASIC';
var
   RightMargin:integer=8;
   BottomMargin:integer=60;

procedure TPaintForm.FormCreate(Sender: TObject);
begin
    autosize:=true;                //2025.06.01
    Caption:=InitialCaption;
    OpenDialog1.Title:=s_OpenFile;
    SaveDialog1.Title:=s_SaveFile;

    Break1.ShortCut:=ShortCut(Word(BreakKey), [ssCtrl]);
    BitMap1:= TBitMap.Create;
    ScreenBMPGraphSys.SetUp;
    HiddenDrawMode:=false;

    with TMyIniFile.create('Graphics') do
      begin
         axescolor0:=ReadInteger('AxisColor',axescolor0);
         free
      end;
    with TMyIniFile.create('PaintFont') do
       begin
         RestoreFont(Font);
         RightMargin:=ReadInteger('RightMargin',RightMargin);
         BottomMargin:=ReadInteger('BottomMargin',BottomMargin);
         free
       end;


    //ScreenBMPGraphSys.SetUp;
    MainFormMonitor:=FrameForm.Monitor;
    SetSize1;
    SizeAdjust;

    hide;   //Visible:=false;   //Windowstate:=wsMinimized;
    //Application.ProcessMessages;

end;

procedure TPaintForm.FormDestroy(Sender: TObject);
begin
   BitMap1.Free;
   BitMap1:=nil;

   with TMyIniFile.create('Graphics') do
   begin
       WriteInteger('AxisColor',axescolor0);
       free
   end;
   with TMyIniFile.create('PaintFont') do
     begin
        StoreFont(Font);
        free
     end;

end;


procedure TPaintForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caHide; //{$IFDEF LclGtk2}caHide {$ELSE} caMiniMize{$ENDIF};
end;

procedure TPaintForm.Exit1Click(Sender: TObject);
begin
  FrameForm.Close1Click(Sender);
end;

procedure TPaintForm.Close1Click(Sender: TObject);
begin
  Close;  { Close the form }
end;

procedure TPaintForm.Print1Click(Sender: TObject);
begin
     PrintBitMap(BitMap1);
end;


procedure TPaintForm.Copy1Click(Sender: TObject);
begin
  ClipBoard.Assign(BitMap1);
end;


procedure TPaintForm.ClearRect(p:PRect);     //ver.8.1.3.1
var
       svBrushColor:TColor;
begin
  with BitMap1.Canvas do
    begin
      svBrushColor:=Brush.Color ;
      Brush.color:=Mypalette.pal[0] or $2000000;
      FillRect(p^);
      Brush.Color:=svBrushColor;
    end;
end;

procedure TPaintForm.clear;                         //ver.8.1.3.1
var
    NewRect:TRect;
begin
    NewRect:=Rect(0,0,Bitmap1.width,Bitmap1.Height);
    ClearRect(@NewRect);
   if not HiddenDrawMode then
       paintBox1.repaint;

end;


procedure TpaintForm.Initial;
begin
    MyPalette.PaletteDisabled:=false;
    MyPalette.PaletteNumber:=ColorIndexDlg.RadioGroup1.ItemIndex;

    BitMap1.Canvas.Font.assign(Font);
    PaintBox1.Canvas.Font.assign(Font);

   if not KeepGraphic then
    begin
       SetSize1;
       clear;
    end;

   MouseState:=[];  //2021.02.08

end;


procedure TPaintForm.SetSize1;
begin
 try
   with OptionSizeDlg do
     if BmpSize >=BMP321 then
        begin
          case BmpSize of
             BMP321:  BitMapHeight:= 321;
             BMP401:  BitMapHeight:= 401;
             BMP501:  BitMapHeight:= 501;
             BMP641:  BitMapHeight:= 641;
             BMP801:  BitMapHeight:= 801;
             BMP1001: BitMapHeight:=1001;
             BMP1281: BitMapHeight:=1281;
             BMP1601: BitMapHeight:=1601;
             BMP2001: BitMapHeight:=2001;
          end;
          BitMapWidth:=BitMapHeight;
        end
     else
        begin
          BitMapWidth:=640;
          case BmpSize of
             BMPpc9801: BitMapHeight:=400;
             BMPdosv: BitMapHeight:=480;
          end;
        end;
    BitMap1.width:=BitMapWidth;
    BitMap1.Height:=BitMapHeight;

    SetSize2;
 except
  with OptionSizeDlg do
    if BMPsize<>BMP321 then
     begin
       BmpSize:=BMP321;
       SetSize1
     end;
 end;
end;



procedure TPaintForm.setsize2;
begin
    PaintBox1.Width:=Bitmap1.width;
    PaintBox1.Height:=Bitmap1.Height ;
    // visible:=true;              //ver. 8.1.3.1
    ClientWidth := Bitmap1.Width +2; { Adjust clientwidth to match }
    ClientHeight := Bitmap1.Height + 1 + Statusbar1.height;   { Adjust clientheight to match }
    if FrameFormMoved then sizeadjust;
    ScreenBMPGraphSys.InitCoordinate ;
    //show;  //if not Visible then visible:=true;              //ver. 8.1.3.1
end;

function TPaintForm.FrameFormMoved:boolean;
begin
  result:=(MainformMonitor<>FrameForm.Monitor);
  if result then
         MainformMonitor:=FrameForm.Monitor;
end;

procedure TPaintForm.SizeAdjust;
var
   ScreenClientWidth,ScreenClientHeight:integer;
   left0,top0:integer;
 begin
  // ScreenClientWidth:=GetSystemMetrics(SM_CXFULLSCREEN);
  // ScreenClientHeight:=GetSystemMetrics(SM_CYFULLSCREEN)+
  //                        GetSystemMetrics(SM_CYCAPTION);
    ScreenClientWidth:= FrameForm.Monitor.WorkareaRect.Right
                       -FrameForm.Monitor.WorkareaRect.Left;
    ScreenClientHeight:=FrameForm.Monitor.WorkareaRect.Bottom
                       -FrameForm.Monitor.WorkareaRect.Top;



    //scrollBox1.AutoScroll:=false;
    if width<ScreenClientWidth then
       left0:=ScreenClientwidth-width
    else
       left0:=0;
    if Height{$IFDEF Windows}+25{$ENDIF}<ScreenClientHeight then
       top0:=ScreenClientHeight-Height{$IFDEF Windows}-25{$ENDIF}
    else
       top0:=0;
    if left0+width>ScreenClientWidth then width:=ScreenClientwidth-left0;
    if top0+Height>ScreenClientHeight then Height:=ScreenClientHeight-top0;

    left:=left0+FrameForm.Monitor.Left;
    top:=top0+FrameForm.Monitor.top;

    //scrollBox1.AutoScroll:=true;
 end;

procedure TPaintForm.FormResize(Sender: TObject);
var
  h,w:integer;
begin
   if Bitmap1=nil then exit;

   w:=Bitmap1.Width + 2;
   h:=BitMap1.Height + 1 + StatusBar1.height;
   if ClientWidth>w then
                   ClientWidth:=w;
   if ClientHeight>h then
                   ClientHeight:=h;
   {Debug}{TODO 0}
   //writeln('ClientHeight= ',ClientHeight);
   //writeln('      Height= ',      Height);

   refresh;
   //Application.Processmessages;    //Harmfull on Fedora19
end;


procedure TPaintForm.Font1Click(Sender: TObject);
begin
    FontDialog1.Font:=Font;
    if FontDialog1.execute then
        Font:=FontDialog1.Font;
    BitMap1.Canvas.Font.assign(Font);
    PaintBox1.Canvas.Font.assign(Font);
end;

procedure TPaintForm.Color1Click(Sender: TObject);
begin
    ColorIndexDlg.execute;
end;

procedure TPaintForm.K1Click(Sender: TObject);
begin
   k1.checked:=true;
   k2.checked:=false;
   KeepGraphic:=false
end;

procedure TPaintForm.K2Click(Sender: TObject);
begin
   k1.checked:=false;
   k2.checked:=true;
   KeepGraphic:=true
end;


procedure TPaintForm.Open1Click(Sender: TObject);
begin
  with OpenDialog1 do
  begin
    options:=[ofPathMustExist,ofFileMustExist];
    Filter :=
    {$IFDEF Linux}
       'Image Files|*.BMP;*.PNG;*.JPG;*.JPEG;*.GIF;*.TIFF;*.TIF;*.XPM;*.bmp;*.png;*.jpg;*.jpeg;*.gif;*.tiff;*.tif;*.xpm';
    {$ELSE}
       'Image Files|*.BMP;*.PNG;*.JPG;*.JPEG;*.GIF;*.TIFF;*.TIF;*.XPM';
    {$ENDIF}
    DefaultExt:='bmp';
    if Execute then
       if OpenFile(FileName) then
          Caption :=FileName
       else
          showMessage('unknown format') ;
  end;
end;

procedure TPaintForm.Copy2Click(Sender: TObject);
begin
    Copy1Click(Sender);
end;




function TPaintForm.OpenFile(FileName: string):boolean;
var
  ext:string;
  gra:TGraphic;
begin
  result:=false;
  application.ProcessMessages;        //ver.8.1.3.2
  sleep(20);                          //ver.8.1.3.2

  Paintbox1.Visible:=false;
  try
      ext:=UpperCase( ExtractFileExt(FileName));
      //FileName:=UTF8ToSys(FileName);
       if ext='' then
            Bitmap1.LoadFromFile(FileName+'.bmp')
       else if (ext='.BMP') then
            Bitmap1.LoadFromFile(FileName)
       else
          begin
             gra:=nil;
             if ext='.PNG' then
                  gra:=TPortableNetworkGraphic.create
             else if (ext='.JPG') or (ext='.JPEG') or (ext='.JPE') then
                  gra:=TJpegImage.Create
             else if (ext='.TIFF') or (ext='.TIF') then
                  gra:=TTiffImage.create
             else if ext='.XPM' then
                  gra:=TPixmap.create
             else if ext='.GIF' then
                  gra:=TGifImage.create
             else
                  result:=false;
             if gra<>nil then
             begin
               gra.LoadFromFile(FileName);
               Bitmap1.assign(gra);
               gra.free;
             end;
          end;
      result:=true;
  except
  end;
  setSize2;
  Paintbox1.Visible:=true;
end;

 function TPaintForm.SaveFile(FileName: string):boolean;
 var
    gra:TGraphic;
    ext:string;
 begin
    result:=false;
    ext:=UpperCase( ExtractFileExt(FileName));
    //FileName:=UTF8ToSys(FileName);
    try
        if ext='' then
             Bitmap1.SaveToFile(FileName+'.bmp')
        else if (ext='.BMP') then
             Bitmap1.SaveToFile(FileName)
        else
           begin
              gra:=nil;
              if ext='.PNG' then
                   gra:=TPortableNetworkGraphic.create
              else if (ext='.JPG') or (ext='.JPEG') or (ext='.JPE') then
                   gra:=TJpegImage.Create
              else if (ext='.TIFF') or (ext='.TIF') then
                   gra:=TTiffImage.create
              else if ext='.XPM' then
                   gra:=TPixmap.create
              //else if ext='.GIF' then
              //     gra:=TGifImage.create
              else
                   result:=false;
              if gra<>nil then
              begin
                 gra.assign(Bitmap1);
                 gra.SaveToFile(FileName);
                 gra.free;
              end;
           end;
        result:=true;
    except
    end;
    refresh;
end;


function TPaintForm.SetBitmapSize(w,h:integer):boolean;
var
   svWidth,svHeight:integer;
   rect1:TRect;                         //ver.8.1.3.1
begin
   result:=true;
   application.ProcessMessages;        //ver.8.1.3.2
   sleep(20);                          //ver.8.1.3.2
   Paintbox1.Visible:=false;
   svWidth:=BitMap1.Width;
   svHeight:=Bitmap1.Height;
   if (w>1) and (h>1) then
     try
       Bitmap1.width:=w;
       Bitmap1.height:=h;
     except
       Bitmap1.Width:=svWidth;
       Bitmap1.Height:=svheight;
       result:=false;
     end
   else
     result:=false;

   if w>svWidth then                             //ver.8.1.3.1
     begin
        rect1:=Rect(svWidth,0,w,h);
        ClearRect(@rect1);
     end;
   if h>svHeight then
     begin
        rect1:=Rect(0,svHeight,w,h);
        ClearRect(@rect1);
     end;

     SetSize2;
     Paintbox1.Visible:=true;
end;

procedure TPaintForm.Save1Click(Sender: TObject);
begin
    if Caption=InitialCaption then
       SaveAs1Click(Sender)
    else
       SaveFile(Caption)
end;

procedure TPaintForm.SaveAs1Click(Sender: TObject);
var
  Fname:string;
begin
    SaveDialog1.Filter:='BitMap|*.bmp|PNG|*.png|JPEG|*.jpg|TIFF|*.tiff';
    if Caption=InitialCaption then
       begin
           SaveDialog1.FileName:='';
       end
    else
       begin
          SaveDialog1.InitialDir:=ExtractFileDir(Caption);
          SaveDialog1.FileName:=ChangeFileExt(ExtractFilename(Caption),'');
       end;
    if SaveDialog1.Execute and (SaveDialog1.Filename<>'') then
      begin
        Fname:=SaveDialog1.FileName;
        if ExtractFileExt(FName)='' then
          case SaveDialog1.FilterIndex of
             0: Fname:=FName+'.bmp';
             1: Fname:=FName+'.png';
             2: Fname:=FName+'.jpg';
             3: Fname:=FName+'.tiff';
          end;
        if SaveFile(FName) then
           Caption:=FName
        else
           showMessage('unknown format');
      end;
    refresh;
end;

procedure TPaintForm.OPtion1Click(Sender: TObject);
begin
    SetOption
end;

procedure TPaintForm.Size1Click(Sender: TObject);
begin
    OptionSizeDlg.Execute;
    SetSize1;
    SizeAdjust;
end;

procedure TPaintForm.Paste1Click(Sender: TObject);
begin
  //if ClipBoard.Provides('image/delphi.bitmap')  then
   begin
     Paintbox1.Visible:=false;
     BitMap1.Assign(ClipBoard);
     SetSize2;
     Paintbox1.Visible:=true;
   end;
end;

procedure TPaintForm.Break1Click(Sender: TObject);
begin
    CtrlBreakHit:=true ;
    FrameForm.SetBreakMessage;
end;


procedure TPaintForm.PaintBox1Click(Sender: TObject);
begin
    MouseClick:=true;
end;



procedure TPaintForm.E1Click(Sender: TObject);
begin
   FrameForm.BringToFront
end;

procedure TPaintForm.PaintBox1Paint(Sender: TObject);
begin
  with PaintBox1.canvas do
    begin
     Lock;
     Draw(0,0,BitMap1);
     unLock;
    end;
end;

procedure TPaintForm.TimerDraw;
begin

  if RepaintRequest and not hiddenDrawMode then
     begin
       RepaintRequest:=false;
       paintBox1.repaint;
     end;

end;

{
procedure TPaintForm.CMMouseLeave(var Message:TMessage);
begin
   inherited;
   With statusBar1 do
   begin
      Panels[0].text := '';
      Panels[0].text := '';
   end;
   mousestate:=[];    //2004.8.22
   Set8087CW(controlword);
end;
}




function  TPaintForm.GetPoint(var a,b:integer):boolean;
var
   svCtrlBreakHit:boolean;
begin
   result:=false;
   svCtrlBreakHit:=CtrlBreakHit;
   CtrlBreakHit:=false;
   MouseClick:=false;
   repeat
       Application.ProcessMessages;//sleep(10);//IdleImmediately;
       if CtrlBreakHit then
          if MessageDlg(s_ConfirmToBreak,mtConfirmation,[mbOk,mbAbort],0)=mrAbort then
             exit  //raise EStop.create
          else
             begin
                CtrlBreakHit:=false;
                svCtrlBreakHit:=true;
             end;
   until MouseClick ;
   a:=mouseX;
   b:=mouseY;
   result:=true;
   CtrlBreakHit:=CtrlBreakHit or svCtrlBreakHit;
end;

procedure TPaintForm.MoveMouse(a,b:integer);
var
   P:TPoint;
begin
  P.X:= a;
  P.Y:= b;
  Mouse.CursorPos:=PaintBox1.ClientToScreen(P);
end;


procedure TPaintForm.MousePol(var a,b:integer; var l,r:boolean);
begin
   //IdleImmediately;
   a:=mouseX;
   b:=mouseY;
   l:=ssleft in mousestate;
   r:=ssright in mousestate;
end;


(*
procedure TPaintForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
   a,b:number;
begin
    //Set8087CW(controlword);
    MouseX:=x;
    MouseY:=y;

    if (sender=Paintbox1) and not invalidCoordinate  then
     begin
      convert(ScreenBMPGraphSys.Virtualx(x),a);
      convert(ScreenBMPGraphSys.Virtualy(y),b);
      round9(a);
      round9(b);
      StatusBar1.Panels[0].text:=DStr(a);
      StatusBar1.Panels[1].text:=DStr(b);
     end
     else
     begin
      StatusBar1.Panels[0].text:='';
      StatusBar1.Panels[1].text:='';
     end
end;
*)

procedure TPaintForm.PaintBox1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
   a,b:number;
begin
    MouseX:=x;
    MouseY:=y;

    if (sender=Paintbox1) and not invalidCoordinate  then
     begin
      convert(ScreenBMPGraphSys.Virtualx(x),a);
      convert(ScreenBMPGraphSys.Virtualy(y),b);
      round9(a);
      round9(b);
      StatusBar1.Panels[0].text:=DStr(a);
      StatusBar1.Panels[1].text:=DStr(b);
     end
     else
     begin
      StatusBar1.Panels[0].text:='';
      StatusBar1.Panels[1].text:='';
     end;
end;


procedure TPaintForm.PaintBox1MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    mousestate:=shift;
    mouseX:=x;
    mouseY:=y;
{$IFDEF LclGTK2} //Bug?
    MouseState:=[];
{$ENDIF}
{$IFDEF LclQt5} //Bug?
    MouseState:=[];
{$ENDIF}
{$IFDEF LclQt6} //Bug?
   // MouseState:=[];
{$ENDIF}
{$IFDEF LclCarbon} //Bug?
    MouseState:=[];
{$ENDIF}
{$IFDEF LclCocoa} //Bug?
  //  MouseState:=[];
{$ENDIF}
end;

procedure TPaintForm.PaintBox1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    mousestate:=shift;
    mouseX:=x;
    mouseY:=y;
end;

initialization

finalization

end.
