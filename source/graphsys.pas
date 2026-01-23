unit graphsys;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}
(***************************************)
(* Copyright (C) 2025, SHIRAISHI Kazuo *)
(***************************************)


interface
uses Types,ExtCtrls,Graphics,LCLType, Classes, SysUtils, Forms, Math,
     Interfaces, LCLIntf, LCLProc, GraphType,  Printers, printdlg,
     base,MyUtils;

type
  GraphModeType=(ScreenBitMapMode,PrtDirectMode);
var 
   NextGraphMode:GraphmodeTYpe=ScreenBitmapMode;
var
   AlignTop:boolean=false;
   AdditionalMargin:integer=0;
   MymmWidth:integer=10000;
   MymmHeight:integer=10000;


type
   tjHorizontal=(tjLEFT,tjCENTER,tjRIGHT);
   tjVirtical=(tjTOP,tjCAP,tjHALF,tjBASE,tjBOTTOM);
const
   Hjustification:array[tjHorizontal]of string[6]=('LEFT','CENTER','RIGHT');
   Vjustification:array[tjVirtical]of string[6]=('TOP','CAP','HALF','BASE','BOTTOM');


const
   TextHeightMulti=1.25;

const
   maxcolor=255;
var
   axescolor0:integer=15;
   axescolor:integer=15;

{**********}
{TMyPalette}
{**********}

const
   White=$00FFFFFF;
   Black=$00000000;
   Blue= $00FF0000;
   Green=$0000FF00;
   Red  =$000000FF;
   Cyan =Blue+Green;
   Yellow=Green+Red;
   Magenta=Red+Blue;

type
  TMyPalette=class
     private
        PrivatePaletteNumber :integer ; {0～2}
        function getPal(c:integer):TColor;
        procedure setPal(c:integer; cl:TColor);
        procedure InitMyPalette(n:integer);
     public
        pal: array[0..maxcolor]of TColor;
        PaletteDisabled:boolean;
        function ColorIndex(color:TColor):integer;
        property palette[c:integer]:TColor read getPal write setPal ; default;
        property PaletteNumber :integer read privatePaletteNumber write InitMyPalette;
   end;

  TMyPalette16=array[0..15]of TColor;

const
   MyPalette0:TMyPalette16=(White,Black,Blue,Green,Red,Cyan,Yellow,Magenta,
               clGray,clNavy,clGreen,clTeal,clMaroon,clOlive,clPurple,clSilver);

   MyPalette1:TMyPalette16=(Black,Blue,Green,Cyan,Red,Magenta,Yellow,White,
               clGray,clNavy,clGreen,clTeal,clMaroon,clPurple,clOlive,clSilver);

   MyPalette2:TMyPalette16=(Black,Blue,Red,Magenta,Green,Cyan,Yellow,White,
                  clGray,clNavy,clPurple,clMaroon,clGreen,clTeal,clOlive,clSilver);
var
     MyPalette:TMyPalette;

type
   TAreaStyle=(asHollow, asSolid, asHatch);
   
{***********}
{ TGraphSys }
{***********}


type
  TLineBuff=Array[0..247]of TPoint;
  PLineBuff=^TLineBuff;

type
 TGraphSys=Class

     latex,latey:longint;
     clip:boolean;
     Hjustify:tjHorizontal;
     Vjustify:tjVirtical;
     PenStyle:TPenStyle;

     left,right,bottom,top:double;
     VPleft,VPright,VPbottom,VPtop:double;
     DWleft,DWright,DWbottom,DWtop:double;
     DVleft,DVright,DVbottom,DVtop:integer;
     DevRect:TRect;
     ClipRect:TRect;

     linecolor,areacolor,textcolor:integer;
     textangle:integer; {度}
     linewidth:integer;
     AreaStyleIndex:byte;
     AreaStyle:TAreaStyle;
     TextHeight0:double;
     iBKmode:integer;
     TextHeightChanged:boolean;

 procedure SetWindow(l,r,b,t:double);
 function virtualX(vx:integer):double;
 function VirtualY(vy:integer):double;
 function deviceX(x:double):longint;
 function deviceY(y:double):longint;
 function ConvToDeviceX(x:double; var i:integer):boolean;
 function ConvToDeviceY(y:double; var j:integer):boolean;

    constructor create;
    destructor destroy; override;
    function GWidth:double;
    function GHeight:double;
    procedure setupClipRect; virtual; abstract;
    procedure SetTextHeight(const x:double);
    function AskTextHeight:double;
    procedure askDeviceSize(var w,h:double; var s:string);
    procedure clear;                       virtual;
    procedure SetUpCoordinateSubSystem;

    procedure InitGraphic;
    procedure InitCoordinate;

    procedure SetViewport(l,r,b,t:double);
    procedure SetDeviceWindow(l,r,b,t:double);
    function SetDeviceViewport(l,r,b,t:double):boolean;
    procedure SetClip(c:boolean);
    procedure plotto0(x2,y2:integer);
    procedure PutText(const n,m:double; const s:string);
    procedure GraphText(const n,m:double; const s:string);
    procedure PlotText(const n,m:double; const s:string);
    procedure PlotLetters(const n,m:double; const s:string);

    procedure finish;  virtual;abstract;
    function SetBitmapSize(w,h:integer):boolean;virtual;
    function OpenFile(FileName: string):boolean; virtual;
    function SaveFile(FileName: string):boolean; virtual;
    procedure putpixel(a,b:longint; pointcolor:integer);
    procedure line(a1,b1,a2,b2:integer; c:integer; ps:TPenStyle; w:integer);
    procedure putmark0(a,b:integer; pointstyle:integer; pointcolor:integer);
    procedure setlinecolor(c:integer); virtual;
    procedure settextcolor(c:integer);  virtual;
    procedure SetPenStyle(ps:TPenStyle); virtual;
    procedure setlinewidth(c:integer);   virtual;
    procedure SetTextFont(const name:AnsiString; size:integer);
    procedure AskTextFont(var name:AnsiString; var size:integer);
    procedure getpoint(var a,b:integer);virtual;
    procedure MoveMouse(a,b:integer);virtual;
    procedure MousePol(var a,b:integer; var l,r:boolean); virtual;
    procedure TextOut(x,y:integer; const s:ansistring; angle:integer);
    procedure TextOutSub(x,y:integer; const s:ansistring; angle:integer);virtual;
    procedure SetRasterMode(b:TPenMode);virtual;
    procedure setHiddenDrawMode(b:boolean);virtual;
    procedure SetTextBkMode(ibk:integer);virtual;

    function ColorIndexOf(a,b:integer):integer;virtual;
    function setcolormode(s:ansistring):boolean;
    function AskColorMode:Ansistring;
    function textwidth(const s:ansistring):integer;
    function textheight(const s:ansistring):integer;
    procedure AskDeviceViewport(var l,r,b,t:double);

    procedure MSPaint( x,y:integer; ac, bc:integer);  virtual;
    procedure MSCircle(x1,y1,x2,y2:integer; lc,ac:integer; f:boolean); virtual;
    procedure MSMoveTo(a,b:integer);
    procedure MSLineTo(a,b:integer);
    procedure MSScreen(c:integer);virtual;abstract;

    procedure Flood(x,y:integer);     virtual;
    procedure FloodFill(x,y:integer); virtual;
    procedure Polygon(const Points:array of TPoint);
    procedure Polyline(const Points:array of TPoint);
    procedure ColorPolyGon(const Points:array of TPoint; c:integer{色指標});
    procedure PolyBezier(const Points:array of TPoint);

    procedure SetAreaStyle(s:TAreaStyle);
    procedure SetAreaStyleIndex(i:integer);

    function xdirection(const x0,y0:double):integer;
    procedure SetBeam(t:boolean);

    {$IF DEFINED(LclQt5)or DEFINED(LclQt6)}
    function testClipRect(x1,y1:integer):boolean;virtual;
    {$ELSE}
    function testClipRect(x1,y1:integer):boolean;
    {$ENDIF}

   private
       beam0:boolean;
       MyRgn:HRGN;
     Canvas1:TCanvas;
     HMulti,HShift,VMulti,VShift:double;
     DevHeight,DevWidth:longint;
     LineBuff:PLineBuff;
     LineBuffCount:integer;

    procedure start; virtual;abstract;
    procedure InitCoordSub;  virtual;
    procedure SetDefaultCoordinate;
    procedure makeClipRect;
    procedure ColorPolyGonSub(const Points:array of TPoint; c:integer{色指標});
    procedure PolyGonSub(const Points:array of TPoint);
    procedure PolyLineSub(const Points:array of TPoint);
    procedure segment(x1,y1,x2,y2:integer); virtual;abstract;
    procedure SegmentBackwardSub( x1,y1,x2,y2:integer);
    procedure SegmentBackward( x1,y1,x2,y2:integer);
    procedure SegmentForward( x1,y1,x2,y2:integer);
    procedure StyledLine(x2,y2:integer);
    procedure LineBuffFlush;
    procedure ClearScreen;virtual;
    function PixelsPerMeter:double;virtual;abstract;
    procedure ProjectiveText(const n,m:double; const s:string; PlotStm:boolean);
    procedure SetCanvasTextHeight(const x:double);
    function GetCanvasTextHeight:double;
    procedure LineSub( a1,b1,a2,b2:integer; cl:TColor; ps:TPenStyle; w:integer);
    //procedure SetPixel(a,b:integer; c:TColor);

    public
    property beam:boolean read beam0 write SetBeam;

  end;

type

  TScreenBMPGraphSys=class(TGraphSys)
     Bitmap1:TBitmap;
    procedure setup;
    procedure setupClipRect;override;
    procedure finish; override;

    function OpenFile(FileName: string):boolean;override;
    function saveFile(FileName: string):boolean;override;
    procedure clear; override;
    procedure setlinecolor(c:integer); override;
    procedure settextcolor(c:integer);  override;
    procedure SetPenStyle(ps:TPenStyle); override;
    procedure setlinewidth(c:integer);   override;
    procedure getpoint(var a,b:integer);override;
    function ColorIndexOf(a,b:integer):integer;override;
    procedure MoveMouse(a,b:integer);override;
    procedure MousePol(var a,b:integer; var l,r:boolean); override;
    procedure SetRasterMode(b:TPenMode);override;
    procedure setHiddenDrawMode(b:boolean);override;
    function SetBitmapSize(w,h:integer):boolean;override;
    procedure MSPaint( x,y:integer; ac, bc:integer);  override;
    procedure MSCircle(x1,y1,x2,y2:integer; lc,ac:integer; f:boolean); override;
    procedure MSScreen(c:integer);override;

    procedure Flood( x,y:integer);     override;
    procedure FloodFill( x,y:integer); override;
   {$IF DEFINED(LclQt5)or DEFINED(LclQt6)}
    function testClipRect(x1,y1:integer):boolean;override;
   {$ENDIF}

   private
     procedure start;  override;
     procedure InitCoordSub;  override;
     function PixelsPerMeter:double;override;
     procedure segment(x1,y1,x2,y2:integer);override;

  end;

  TBackwardBMPGraphSys=class(TScreenBMPGraphSys)
    procedure segment(x1,y1,x2,y2:integer); override;
  end;

  TMetaPrtGraphSys=class(TGraphSys)
    procedure setupClipRect;override;
    procedure segment(x1,y1,x2,y2:integer); override;
    procedure TextOutSub(x,y:integer; const s:ansistring; angle:integer); override;
  private
    procedure InitCoordSub;  override;
    procedure SetDefaultMargin;
    function PixelsPerMeter:double;override;
  end;



  TPrtDirectGraphSys=class(TMetaPrtGraphSys)
    constructor create;
    procedure clear; override;
    procedure start;  override;
    procedure finish; override;
    procedure SetTextBkMode(ibk:integer);override;
   private
    procedure ClearScreen;override;
  end;

var
   ScreenBMPGraphSys:TScreenBMPGraphSys;
   PrtDirectGraphSys:TPrtDirectGraphSys;
   MyGraphSys : TGraphSys;


{*************}
{miscellaneous}
{*************}


var restrict: function(n:longint):integer;

var
    HiddenDrawMode:boolean = false;

type
 TBeamMode=(bmRigorous, bmImmortal);
const
 s_Rigorous='RIGOROUS';
 s_Immortal='IMMORTAL';
var  BeamMode:TBeamMode;

var
    //ForwardPlot:boolean ={$IF Defined (LCLCarbon) or Defined (LCLQt)}true{$ELSE}false{$IFEND};
    GeometricPenOnly:boolean = false;
    TextProblemCoordinate:boolean = true;          //ver.8.1.3
    //TextPhysicalCoordinate:boolean = true;         //ver.8.1.3
    InitialBeamMode:TBeamMode=BMImmortal;          //ver.8.1.3 2024.12.16

var
   invalidCoordinate:boolean=false;
const
   TextPhysicalCoordinate:boolean = true;


implementation

uses
 float,paintfrm,locatefrm,draw,graphic,MyThread,graphopt;

{**********}
{TMyPalette}
{**********}


function TMyPalette.getPal(c:integer):TColor;
begin
   if PaletteDisabled then
      result:=c
   else
      result:=pal[c and 255] or $2000000
end;

procedure TMyPalette.setPal(c:integer; cl:TColor);
begin
   pal[c and 255]:=cl and $ffffff;
end;

function TMyPalette.ColorIndex(color:TColor):integer;
var
  i:integer;
begin
  if color=-1 then
     result:=-1
  else
  begin
  color:=color and $ffffff;
  if PaletteDisabled then
     result:=color
  else
     begin
       result:=-1;
       i:=0;
       while i<=maxcolor do
          if Pal[i]=color then
                begin
                  result:=i;
                  break
                end
           else
                inc(i);
     end;
  end;   
end;

procedure TMyPalette.InitMyPalette(n:integer);
var
   i,j,k:integer;
   r,g,b:byte;
   P:^TMyPalette16;
begin
   PaletteDisabled:=false;

    for j:=0 to 63 do
      begin
          r:=255-( ( (j       and 1)*2 + ((j shr 3) and 1))*85);
          g:=255-( (((j shr 1)and 1)*2 + ((j shr 4) and 1))*85);
          b:=255-( (((j shr 2)and 1)*2 + ((j shr 5) and 1))*85);
          Palette[j]:=RGB(r,g,b);
          Palette[j+64]:=RGB(r xor 128,g xor 128 ,b xor 128);
          Palette[j+128]:=RGB(r xor 192,g xor 192 ,b xor 192);
          Palette[j+192]:=RGB(r xor 140,g xor 140 ,b xor 143);
      end;

   P:=@MyPalette0;
   case n of
     0: ;
     1:P:=@MyPalette1;
     2:P:=@MyPalette2;
   end;

   for i:=0 to 15 do
   begin
       k:=self.ColorIndex(P^[i]);
       for j:=k downto i+1 do
              Palette[j]:=Palette[j-1];
       Palette[i]:=P^[i];
   end;
(*
   for i:=16 to 255 do
      begin
          Palette[i]:=(i mod 7)*42 + (i mod 6)*51 *256 + (i mod 5)*63 * 65536;
          //Palette[i]:=(i mod 7)*42 + (i mod 4)*85 *256 + (i mod 3)*127 * 65536;
      end;
*)
end;

{********************}
{BitMap GetPixelColor}
{********************}
type TColorRec=packed record
     red,green,blue,spare:byte
end;
type TPixelData=array[0..3]of byte;
     PPixeldata=^TPixelData;

function GetPixelColor(BitMap1:TBitmap; x,y:integer):TColor;
var
   RawImage: TRawImage;
   PixelPtr:PPixelData;
   PixelData:TColorRec;
   redIx,greenIx,blueIx:byte;
   BytePerPixel: byte;
begin
  with Bitmap1 do                                             //2014.1.1
    if (x<0) or (y<0) or (x>=width) or (y>=height) then
       begin result:=-1; exit end;

   if bitmap1.PixelFormat=pf24bit then
   begin
     RawImage := Bitmap1.RawImage;
     PixelPtr:=PPixelData(RawImage.Data);
     with  RawImage.Description do
       begin
         BytePerPixel:=BitsPerPixel div 8;
         Inc(PByte(PixelPtr),BytesPerLine * y + BytePerPixel * x);
         RedIx  :=RedShift div 8;
         GreenIx:=GreenShift div 8;
         BlueIx :=BlueShift div 8;
         if ByteOrder=riboMSBFirst then
             begin
               RedIx:=BytePerPixel-1-RedIx;
               GreenIx:=BytePerPixel-1-GreenIx;
               BlueIx:=BytePerPixel-1-BlueIx;
             end;
         Pixeldata.red:=PixelPtr^[RedIx];
         Pixeldata.green:=PixelPtr^[GreenIx];
         Pixeldata.blue:=PixelPtr^[BlueIx];
         PixelData.spare:=0;
       end;
     result:=TColor(PixelData);
   end
  else
    result:=bitmap1.Canvas.Pixels[x,y];

end;




{*********}
{TGraphSys}
{*********}


function MySelectClipRGN( DC: HDC; RGN: HRGN):LongInt;
var
   SvCw:CWrec;
begin
    SvCW:=GetFPUMask;
    SetFPUMask(OriginalCW);     //2014.1.23
    result:=SelectClipRgn( DC, RGN);
    SetFPUMask(SvCw);
end;



constructor TGraphSys.create;
begin


   VPleft:=0;
   VPright:=1;
   VPbottom:=0;
   VPtop:=1;

   DWleft:=0;
   DWright:=1;
   DWbottom:=0;
   DWtop:=1;

   clip:=true;

   Hjustify:=tjLEFT;
   Vjustify:=tjBOTTOM;
   iBKmode:=TRANSPARENT;

end;


procedure TScreenBMPGraphSys.setup;
// PaintForm.FormCreateから呼ばれて，set upを完了させる。
begin
   Canvas1:=PaintForm.Bitmap1.Canvas;
   Bitmap1:=PaintForm.Bitmap1;
end;

constructor TPrtDirectGraphSys.create;
begin
   inherited create;
   //Canvas1:=printer.Canvas;
end;


destructor TGraphSys.destroy;
begin
   if LineBuff<>nil then Dispose(LineBuff);
   inherited destroy
end;



procedure TGraphSys.clear;
var
    NewRect:TRect;
    svBrushColor:TColor;
begin
   LineBuffFlush;
  MySelectClipRgn(Canvas1.Handle,0);
  NewRect:=Rect(0,0,DevWidth+1,DevHeight+1);
  with Canvas1 do
    begin
      svBrushColor:=Brush.Color;
      Brush.color:=Mypalette.pal[0] ;
      FillRect(NewRect);
      Brush.Color:=svBrushColor;
    end;
  MySelectClipRgn(Canvas1.Handle,MyRgn);
end;

procedure TScreenBMPGraphSys.Clear;
begin
   inherited clear;
end;

procedure TPrtDirectGraphSys.Clear;
begin
   LineBuffFlush;
{todo 1 printer}
   printer.NewPage;
end;

procedure TGraphSys.initGraphic;
begin
   MyPalette.PaletteDisabled:=false;
   TextHeightChanged:=false;

   start;

    linecolor:=1;
    areacolor:=1;
    textcolor:=1;
    penstyle:=psSolid;
    linewidth:=1;
    TextHeight0:=0.01;
    TextAngle:=0;
    axescolor:=axescolor0;
    Hjustify:=tjLEFT;
    Vjustify:=tjBOTTOM;
    clip:=true;
    HiddenDrawMode:=false;
    iBKmode:= TRANSPARENT;
    AreaStyle:=asSolid;
    AreaStyleIndex:=1;

   InitCoordinate ;

   setlinecolor(linecolor);
   settextcolor(textcolor);
   setpenstyle(penstyle);
   setlinewidth(linewidth);
   setRasterMode(pmCopy);

end;

procedure TGraphSys.InitCoordinate;
begin
    VPleft:=0; VPright:=1; VPbottom:=0; VPtop:=1;
    DWleft:=0; DWright:=1; DWbottom:=0; DWtop:=1;
    InitCoordSub;

    if permitMicrosoft then
      SetWindow(0,GWidth,GHeight,0)
    else
      SetWindow(0,1,0,1)
end;



procedure TGraphSys.SetViewport(l,r,b,t:double);
begin
    beam:=false;
    invalidCoordinate:=true;
      VPleft:=l;
      VPright:=r;
      VPbottom:=b;
      VPtop:=t;
      setupCliprect;
      SetUpCoordinateSubSystem;
    invalidCoordinate:=false;
end;

procedure TGraphSys.SetDeviceWindow(l,r,b,t:double);
begin
   beam:=false;
   invalidCoordinate:=true;
      DWleft:=l;
      DWright:=r;
      DWbottom:=b;
      DWtop:=t;
      setupCliprect;
      SetUpCoordinateSubSystem;
   invalidCoordinate:=false;
   clearScreen;
end;


procedure TGraphSys.InitCoordSub;
begin
end;

procedure TScreenBMPGraphSys.InitCoordSub;
begin
    //inherited InitCoordSub;
    DevWidth:=PaintForm.BitMap1.width-1;
    DevHeight:=PaintForm.BitMap1.height-1;

    DVleft:=0;
    DVright:=DevWidth;
    DVbottom:=0;
    DVtop:=DevHeight;

    SetDefaultCoordinate;
    setUpClipRect;
end;

procedure TMetaPrtGraphSys.InitCoordSub;
begin
    //inherited initCoordsub;

    {ToDo 1 Printer}

    DevWidth:=printer.PageWidth-1-2;
    DevHeight:=printer.PageHeight-1-2;

    DVleft:=0;
    DVright:=DevWidth;
    DVbottom:=0;
    DVtop:=DevHeight;

    setDefaultMargin;
    setUpClipRect;
end;



procedure TGraphSys.SetDefaultCoordinate;
begin

   DwLeft:=0;
   DwRight:=1;
   DwBottom:=0;
   DwTop:=1;
   if DvRight>=DvTop then
        DwTop:=DvTop/DvRight
   else
        DwRight:=DvRight/DvTop;

   VpLeft:=DwLeft;
   VpRight:=DwRight;
   VpBottom:=DwBottom;
   VpTop:=DwTop;
end;


function intersection(rect1,rect2:TRect):TRect;
begin
   result:=rect2;
   if rect1.left>result.left then result.left:=rect1.left;
   if rect1.right<result.right then result.right:=rect1.right;
   if rect1.top>result.top then result.top:=rect1.top;
   if rect1.bottom<result.bottom then result.bottom:=rect1.bottom;
end;

procedure TGraphSys.makeClipRect;
var
   rect2:TRect;
   svCW:CWRec;
begin
   svCW:=GetFPUMask;
   SetFPUMask(OriginalCW);
   {DevRect を装置窓の縦横比に一致させる}
    with DevRect do
      begin
         if (bottom-top)/(right-left)>(DWtop-DWbottom)/(DWright-DWleft) then
            top:=bottom-round((right-left)*(DWtop-DWbottom)/(DWright-DWleft))
         else if (bottom-top)/(right-left)<(DWtop-DWbottom)/(DWright-DWleft) then
            right:=left+round((bottom-top)*(DWright-DWleft)/(DWtop-DWbottom))
      end;

  {ClipRectの設定}
  ClipRect:=DevRect;
  rect2:=ClipRect;
  if clip then
   with ClipRect do
     begin
       Rect2.left:=  left + floor((right- left)*(VPleft -DWleft)/(DWright-DWleft));
       Rect2.right:= left +  ceil((right- left)*(VPright-DWleft)/(DWright-DWleft));
       Rect2.top:=   bottom+floor((top-bottom)*(VPtop   -DWbottom)/(DWtop-DWbottom));
       Rect2.bottom:=bottom +ceil((top-bottom)*(VPBottom-DWbottom)/(DWtop-DWbottom));
     end;
  ClipRect:=intersection(Cliprect,rect2);
  SetFPUmask(svCW);
end;



procedure TScreenBMPGraphSys.setupClipRect;
begin
  DevRect.left:=DVleft;
  DevRect.right:=DVright;
  DevRect.top:=DevHeight-DVTop;
  DevRect.bottom:=DevHeight-DVBottom;

  makeClipRect;

  if MyRgn<>0 then
      begin
         MySelectClipRgn(Canvas1.Handle,0);
         DeleteObject(MyRgn);
      end;

  if (ClipRect.left=0) and (ClipRect.Right=DevWidth)
      and (ClipRect.Top=0) and (ClipRect.Bottom=DevHeight)then
     MyRgn:=0
  else
     MyRgn := CreateRectRgn(ClipRect.left, ClipRect.top, ClipRect.right+1, ClipRect.bottom+1) ;

  MySelectClipRgn(Canvas1.Handle,MyRgn);
end;



procedure TMetaPrtGraphSys.setupClipRect;
begin

   DevRect.left:=DVleft + 1;
   DevRect.right:=DVright + 1;
   DevRect.top:=DevHeight-DVTop + 1;
   DevRect.bottom:=DevHeight-DVBottom + 1;

   makeClipRect;

   if MyRgn<>0 then
      begin
         MySelectClipRgn(Canvas1.Handle,0);
         DeleteObject(MyRgn);
      end;
   MyRgn := CreateRectRgn(ClipRect.left -1 ,ClipRect.top -1 , ClipRect.right +2 , ClipRect.bottom +2 );

   MySelectClipRgn(Canvas1.Handle,MyRgn);
end;


procedure TMetaPrtGraphSys.setDefaultMargin;
var
  dvL,dvR,dvB,dvT,a,h,w:double;
begin
  a:=AdditionalMargin/1000;
  AskDeviceViewport(dvL,dvR,dvB,dvT);
  dvL:=dvL+a;
  dvR:=dvR-a;
  dvB:=dvB+a;
  dvT:=dvT-a;
  if AlignTop then
    begin
      h:=dvT-dvB;
      w:=dvR-dvL;
      if h>w then
         dvB:=dvT-w;
    end;
  setDeviceViewPort(dvL,dvR,dvB,dvT);

end;

function TGraphSys.deviceX(x:double):longint;
var
   z:double;
begin
  try
     z:=(x-left)*HMulti+HShift;
     result:=LongIntRound(z);
  except
     {$IFNDEF Windows} RecoverFloatException; {$ENDIF}
     if z>0 then
        result:=maxint
     else
        result:=minint
  end;
end;

function TGraphSys.deviceY(y:double):longint;
var
  z:double;
begin
  try
    z:=(y-bottom)*VMulti+VShift;
    result:=LongIntRound(z);
  except
    {$IFNDEF Windows} RecoverFloatException; {$ENDIF}
     if z>0 then
        result:=maxint
     else
        result:=minint
  end;
end;

function TGraphSys.ConvToDeviceX(x:double; var i:integer):boolean;
var
   z:double;
begin
  try
     z:=(x-left)*HMulti+HShift;
     if abs(z)<maxint  then              //2022.05.01 Ver. 8.1.1.6
       begin
        i:=LongIntRound(z);
        result:=true;
       end
     else
       begin
         result:=false;
         i:=minint
       end;
  except
     {$IFNDEF Windows} RecoverFloatException; {$ENDIF}
      result:=false;
      i:=minint
  end;
end;

function TGraphSys.ConvToDeviceY(y:double; var j:integer):boolean;
var
  z:double;
begin
  try
      z:=(y-bottom)*VMulti+VShift;
      if abs(z)<maxint  then             //2022.05.01 Ver. 8.1.1.6
       begin
        j:=LongIntRound(z);
        result:=true;
       end
      else
        begin
         result:=false;
         j:=minint
        end;
  except
      {$IFNDEF Windows} RecoverFloatException; {$ENDIF}
      result:=false;
      j:=minint
  end;
end;



procedure TGraphSys.SetUpCoordinateSubSystem;
begin
  ClearExceptions(false);
  try
     HMulti:=(DevRect.right- DevRect.left)/(DWright-DWleft)*(VPright-VPleft)/(right-left);
     HShift:=DevRect.left + (VPleft-DWleft)*(DevRect.right- DevRect.left)/(DWright-DWleft);
     VMUlti:=(DevRect.top- DevRect.bottom)/(DWtop-DWbottom)*(VPtop-VPbottom)/(top-bottom);
     VShift:=DevRect.bottom + (VPbottom-DWbottom)*(DevRect.top- DevRect.bottom)/(DWtop-DWbottom);
     If TextHeightChanged then
        SetCanvasTextHeight(TextHeight0);
  except
      {$IFNDEF Windows} RecoverFloatException; {$ENDIF}
       setexception(SystemErr);
  end;
end;

procedure TGraphSys.SetWindow(l,r,b,t:double);
begin
   beam:=false;
   invalidCoordinate:=true;
     left:=l;
     right:=r;
     bottom:=b;
     top:=t;
     SetUpCoordinateSubSystem;
   invalidCoordinate:=false;
end;

function TGraphSys.virtualX(vx:integer):double;
begin
   virtualX:=(vx-HShift)/HMulti + left;
end;

function TGraphSys.VirtualY(vy:integer):double;
begin
   virtualY:=(vy-VShift)/VMulti + bottom;
end;



function TGraphSys.GWidth:double;
begin
    result:=DevRect.right-DevRect.Left;
end;

function TGraphSys.GHeight:double;
begin
    result:=DevRect.bottom-DevRect.top;
end;


procedure TGraphSys.ColorPolyGonSub( const Points:array of TPoint; c:integer);
var
   svBrushColor:TColor;
   svPenColor:TColor;
   svBrushStyle:TBrushStyle;
   svPenStyle:TpenStyle;
   svPenWidth:integer;
   svCw:CWRec;
begin
  if MyRgn<>0 then  MySelectClipRgn(Canvas1.Handle,MyRgn);

  with Canvas1 do
    begin
     svBrushColor:=Brush.Color;
     svBrushStyle:=Brush.Style;
     svPenColor:=Pen.Color;
     svPenStyle:=Pen.Style;          //2018.12.03
     svPenWidth:=Pen.Width;

     Brush.Color:=MyPalette[c] ;
     Pen.Color:=MyPalette[c] ;
     pen.width:=1;                   //2008.1.29
     Pen.Style:=psSolid;             //2018.12.03

     case AreaStyle of
       asSolid: Brush.Style:=bsSolid;
       asHollow:Brush.Style:=bsClear;
       asHatch: Brush.Style:=TBrushStyle( AreaStyleIndex + 1);
     end;
     SetBkColor(Canvas1.Handle,MyPalette.pal[0] );

    SvCw:=GetFPUMask;
    SetFPUMask(OriginalCW);     //2014.1.23
      Polygon(Points);
    SetFPUMask(SvCw);

    Brush.Color:=svBrushColor;
    Brush.Style:=svBrushStyle;
    Pen.Color:=svPenColor;
    Pen.Width:=svpenWidth;
    Pen.Style:= svPenStyle;        //2018.12.03
    end;
end;



procedure TGraphSys.PolyGonSub(const Points:array of TPoint);
begin
  ColorPolyGonSub(Points,areacolor)
end;

procedure TGraphSys.ColorPolyGon(const Points:array of TPoint; c:integer{色指標});
begin
   ColorPolyGonSub(Points,c);
end;

procedure TGraphSys.Polygon(const Points:array of TPoint);
begin
   PolyGonSub(Points);
end;

procedure TGraphSys.PolyLineSub(const Points:array of TPoint);
var
   svCw:CWRec;
begin
   if MyRgn<>0 then  MySelectClipRgn(Canvas1.Handle,MyRgn);
   svCw:=GetFPUMask;
   SetFPUMask(OriginalCW);     //2014.1.23
   Canvas1.PolyLine(Points);
   SetFPUMask(SvCw);
end;

procedure TGraphSys.Polyline(const Points:array of TPoint);
var
   svCw:CWRec;
begin
   if MyRgn<>0 then  MySelectClipRgn(Canvas1.Handle,MyRgn);
   SvCW:=GetFPUMask;
   SetFPUMask(OriginalCW);     //2014.1.23
   Canvas1.Polyline(Points);
   SetFPUMask(svCW);
end;


procedure TGraphSys.SetTextHeight(const x:double);
begin
   TextHeight0:=x;
   SetCanvasTextHeight(x);
   TextHeightChanged:=true;
end;

function TGraphSys.AskTextHeight:double;   //2013.12.21
begin
  if textheightchanged then
     result:=TextHeight0
  else
     result:=GetCanvasTextHeight;
end;

procedure TGraphsys.SetCanvasTextHeight(const x:double);
var
   i:integer;
begin
    try
      i:=LongIntRound(abs(VMulti*x*TextHeightMulti));
      if i<=0 then i:=1;               //2007.5.18　
      Canvas1.Font.height:=-i;
    except
      {$IFNDEF Windows} RecoverFloatException; {$ENDIF}
    end;
end;


function TGraphSys.GetCanvasTextHeight:double;
begin
   result:=abs(-Canvas1.Font.Height)/TextHeightMulti/abs(VMulti)
end;


procedure TGraphSys.SetTextFont(const name:AnsiString; size:integer);
begin
    if name<>'' then
       begin
          Canvas1.Font.Charset:=DEFAULT_CHARSET;    //OEM_CHARSET;
          Canvas1.Font.name:=name;
       end;
    if size>0 then
       begin
         Canvas1.Font.size:=size;
         TextHeightChanged:=false;    //2013.12.21
       end;
end;

procedure TGraphSys.AskTextFont(var name:AnsiString; var size:integer);
begin
    name:=Canvas1.Font.name;
    size:=Canvas1.Font.size
end;


{
procedure TGraphSys.SetPixel(a,b:integer; c:TColor);
begin
    canvas1.Pixels[a,b]:=c;
end;
}

procedure TGraphSys.putpixel(a,b:longint; pointcolor:integer);
begin
   if MyRgn<>0 then  MySelectClipRgn(Canvas1.Handle,MyRgn);
   if testClipRect(a,b) then
      if testClipRect(a,b) then
      canvas1.Pixels[a,b]:=MyPalette[pointcolor];
end;

(*
procedure TextOutRotate(Canvas: TCanvas; x, y: Integer; const s: AnsiString; a:integer);
begin
    Canvas.Start;
    QPainter_SetBackGroundColor(Canvas.handle, QColor(MyPalette.pal[0]) );
    QPainter_SetBackGroundMode(Canvas.handle,iBkMode);
    QPainter_translate(Canvas.Handle,X,Y);
    QPainter_rotate(Canvas.Handle,-a);
    Canvas.TextOut(0,0,s);
    QPainter_rotate(Canvas.Handle,a);
    QPainter_translate(Canvas.Handle,-X,-Y);
    Canvas.Stop;
end;
*)


procedure TextOutRotate(Canvas: TCanvas; x, y: Integer; const s: AnsiString; a:integer);
var
  lfText: TLOGFONT;
  hfNew, hfOld: HFONT;
begin
  {$IFDEF LclCarbon}    //  bug or unfinshed ?
  FillChar(lfText,SizeOf(TLOGFONT),0);
  lfText.lfHeight:=Canvas.Font.Height;
  {$ENDIF}
  GetObject(Canvas.Font.Handle, sizeof(TLOGFONT), @lfText);
   lfText.lfEscapement := a * 10; // 角度
  lfText.lfOrientation := lfText.lfEscapement;
  hfNew := CreateFontIndirect(lfText);
  hfOld := SelectObject(Canvas.Handle, hfNew);
  Canvas.TextOut(x, y, s);
  SelectObject(Canvas.Handle, hfOld);
  DeleteObject(hfNew);
end;


procedure TGraphSys.textoutSub(x,y:integer; const s:ansistring; angle:integer);
begin
   if MyRgn<>0 then  MySelectClipRgn(Canvas1.Handle,MyRgn);
    settextcolor(textcolor);
    SetBkColor(Canvas1.Handle,MyPalette.pal[0] );
    SetBkMode(Canvas1.Handle,iBkMode);
    textOutRotate(Canvas1,x,y,s,Angle);
end;

 procedure TMetaPrtGraphSys.textoutSub(x,y:integer; const s:ansistring; angle:integer);
begin
    if MyRgn<>0 then  MySelectClipRgn(Canvas1.Handle,MyRgn);
    settextcolor(textcolor);
    //SetBkColor(Canvas1.Handle,MyPalette.pal[0] );
    //SetBkMode(Canvas1.Handle,iBkMode);
    textOutRotate(Canvas1,x,y,s,Angle);
end;
procedure TGraphSys.setlinecolor(c:integer);
var
  col:TColor;
begin
    LineBuffFlush;
    linecolor:=c;
    col:=MyPalette[c] ;
    Canvas1.pen.color:=col;
end;

procedure TScreenBMPGraphSys.setlinecolor(c:integer);
begin
  inherited setlinecolor(c);
end;

procedure TGraphSys.settextcolor(c:integer);
begin
    textcolor:=c;
    Canvas1.Font.Color:=MyPalette[textcolor] ;
end;

procedure TScreenBMPGraphSys.settextcolor(c:integer);
begin
    inherited settextcolor(c);
end;

procedure TGraphSys.SetPenStyle(ps:TPenStyle);
begin
    LineBuffFlush;
    PenStyle:=ps;
    Canvas1.pen.style:=ps;
end;

procedure TScreenBMPGraphSys.SetPenStyle(ps:TPenStyle);
begin
    inherited SetPenStyle(ps);
end;

procedure TGraphSys.setlinewidth(c:integer);
begin
    LineBuffFlush;
    Canvas1.pen.width:=c;
    LineWidth:=c;
end;

procedure TScreenBMPGraphSys.setlinewidth(c:integer);
begin
    inherited setlinewidth(c);
end;

procedure TGraphSys.SetRasterMode(b:TPenMode);
begin
     Canvas1.Pen.Mode:=b;
     Canvas1.Pen.Mode:=b;
end;

procedure TScreenBMPGraphSys.SetRasterMode(b:TPenMode);
begin
     Canvas1.Pen.Mode:=b;
end;


procedure TGraphSys.setHiddenDrawMode(b:boolean);
begin

end;

procedure TScreenBMPGraphSys.setHiddenDrawMode(b:boolean);
begin
  if RepaintRequest and not (HiddenDrawMode and b) then
       begin
          //sleep(16);
          RepaintExec;
          Application.ProcessMessages;
       end;
  HiddenDrawMode:=b ;
end;

procedure TGraphSys.SetTextBkMode(ibk:integer);
begin
  iBKMode:=ibk;
end;

procedure TPrtDirectGraphSys.SetTextBkMode(ibk:integer);
begin
  //{$IFDEF Linux}
  //{$ELSE}
  inherited SetTextBkMode(ibk);
  //{$ENDIF}
end;

function restrict9x(n:longint):integer;
begin
   if n>16383 then
      result:=16383
   else if n<-16384 then
      result:=-16384
   else
      result:=n
end;

function restrict16(n:longint):integer;
begin
   if n>32767 then
      result:=32767
   else if n<-32768 then
      result:=-32768
   else
      result:=n
end;

function restrictNT(n:longint):integer;    //  2009.4.18  ver 7.3.1
begin
   if n>134217727 then
      result:=134217727
   else if n<-134217728 then
      result:=-134217728
   else
      result:=n
end;

function restrictNone(n:longint):integer;
begin
      result:=n
end;

var
   ShrinkRange: procedure(var lx,ly,vx,vy:longint);

procedure  ShrinkRange9x(var lx,ly,vx,vy:longint);
var
  x,x1,x2,y,y1,y2: double;
begin
  x1:=lx;y1:=ly;x2:=vx;y2:=vy;
  if abs(x2-x1)>=16364 then
     begin
        if x2<x1 then
            begin
                 x:=x1; x1:=x2; x2:=x; y:=y1; y1:=y2; y2:=y;
            end;
        if (x1<-8192) then
           begin
              x:=-8192;y:=round((y2-y1)/(x2-x1)*(x-x1)+y1);
              x1:=x;y1:=y
           end;
        if (x2>8192) then
           begin
              x:=8192;y:=round((y2-y1)/(x2-x1)*(x-x2)+y2);
              x2:=x;y2:=y
           end;
     end;
  if abs(y2-y1)>=16364 then
     begin
        if y2<y1 then
            begin
                 x:=x1; x1:=x2; x2:=x; y:=y1; y1:=y2; y2:=y;
            end;
        if (y1<-8192) then
           begin
              y:=-8192;x:=round((x2-x1)/(y2-y1)*(y-y1)+x1);
              y1:=y;x1:=x
           end;
        if (y2>8192) then
           begin
              y:=8192;x:=round((x2-x1)/(y2-y1)*(y-y2)+x2);
              y2:=y;x2:=x
           end;
     end;
  lx:=round(x1);
  ly:=round(y1);
  vx:=round(x2);
  vy:=round(y2);
end;

procedure  ShrinkRange16(var lx,ly,vx,vy:longint);
var
  x,x1,x2,y,y1,y2: double;
begin
  x1:=lx;y1:=ly;x2:=vx;y2:=vy;
  if abs(x2-x1)>=16364*2 then
     begin
        if x2<x1 then
            begin
                 x:=x1; x1:=x2; x2:=x; y:=y1; y1:=y2; y2:=y;
            end;
        if (x1<-8192*2) then
           begin
              x:=-8192*2;y:=round((y2-y1)/(x2-x1)*(x-x1)+y1);
              x1:=x;y1:=y
           end;
        if (x2>8192*2) then
           begin
              x:=8192*2;y:=round((y2-y1)/(x2-x1)*(x-x2)+y2);
              x2:=x;y2:=y
           end;
     end;
  if abs(y2-y1)>=16364*2 then
     begin
        if y2<y1 then
            begin
                 x:=x1; x1:=x2; x2:=x; y:=y1; y1:=y2; y2:=y;
            end;
        if (y1<-8192*2) then
           begin
              y:=-8192*2;x:=round((x2-x1)/(y2-y1)*(y-y1)+x1);
              y1:=y;x1:=x
           end;
        if (y2>8192*2) then
           begin
              y:=8192*2;x:=round((x2-x1)/(y2-y1)*(y-y2)+x2);
              y2:=y;x2:=x
           end;
     end;
  lx:=round(x1);
  ly:=round(y1);
  vx:=round(x2);
  vy:=round(y2);
end;

procedure  ShrinkRangeNT(var lx,ly,vx,vy:longint);
var
  x,x1,x2,y,y1,y2: double;
begin
  x1:=lx;y1:=ly;x2:=vx;y2:=vy;
  if abs(x2-x1)>=67108864 then
     begin
        if x2<x1 then
            begin
                 x:=x1; x1:=x2; x2:=x; y:=y1; y1:=y2; y2:=y;
            end;
        if (x1<-67108864) then
           begin
              x:=-67108864;y:=round((y2-y1)/(x2-x1)*(x-x1)+y1);
              x1:=x;y1:=y
           end;
        if (x2>67108864) then
           begin
              x:=67108864;y:=round((y2-y1)/(x2-x1)*(x-x2)+y2);
              x2:=x;y2:=y
           end;
     end;
  if abs(y2-y1)>=67108864 then
     begin
        if y2<y1 then
            begin
                 x:=x1; x1:=x2; x2:=x; y:=y1; y1:=y2; y2:=y;
            end;
        if (y1<-67108864) then
           begin
              y:=-67108864;x:=round((x2-x1)/(y2-y1)*(y-y1)+x1);
              y1:=y;x1:=x
           end;
        if (y2>67108864) then
           begin
              y:=67108864;x:=round((x2-x1)/(y2-y1)*(y-y2)+x2);
              y2:=y;x2:=x
           end;
     end;
  lx:=round(x1);
  ly:=round(y1);
  vx:=round(x2);
  vy:=round(y2);
end;

procedure  ShrinkRangeNone(var lx,ly,vx,vy:longint);
begin
  //Do Nothing
end;

type
   longrec=record
       low:word;
       high:smallint;
   end;

function iabs(n:longint):longint;
begin
    if n>=0 then
       iabs:=n
    else
       iabs:=-n;
end;
procedure TGraphSys.SegmentBackwardSub( x1,y1,x2,y2:integer);
var
   P:array[0..1]of TPoint;
begin
   P[0].X:=x2;
   P[0].Y:=y2;
   P[1].X:=x1;
   P[1].Y:=y1;
   PolyLinesub(P);
end;

procedure TGraphSys.SegmentBackward( x1,y1,x2,y2:integer);
// 始点を描かず，終点を描く
begin
  if PenStyle<>psSolid then SetBkMode(Canvas1.Handle,TRANSPARENT);
  if (x1=x2) and (y1=y2) then
       if testClipRect(x1,y1) then
         canvas1.Pixels[x1,y1]:=Canvas1.pen.color
       else
  else
    begin
       if (  ((longrec(x1).high+1) shr 1)
          or ((longrec(y1).high+1) shr 1)
          or ((longrec(x2).high+1) shr 1)
          or ((longrec(y2).high+1) shr 1) =0)
        and (iabs(x2-x1)<16384) and (iabs(y2-y1)<16384) then
        else
           ShrinkRange(x1,y1,x2,y2);
        if (PenStyle=psSolid)
            or not GeometricPenOnly
               and ((linewidth=1) and (SetBkMode(Canvas1.Handle,TRANSPARENT)<>0))
                                                                           then
            begin
               Canvas1.MoveTo(restrict(x2),restrict(y2));
               Canvas1.LineTo(restrict(x1),restrict(y1));
           end
        else
           SegmentBackwardSub(x1,y1,x2,y2)
    end;
end;

procedure TScreenBMPGraphSys.segment(x1,y1,x2,y2:integer);
begin
  if MyRgn<>0 then  MySelectClipRgn(Canvas1.Handle,MyRgn);
  SegmentForward(x1,y1,x2,y2)
end;

procedure TBackwardBMPGraphSys.segment(x1,y1,x2,y2:integer);
begin
   if MyRgn<>0 then  MySelectClipRgn(Canvas1.Handle,MyRgn);
   SegmentBackward(x1,y1,x2,y2)
end;

procedure TMetaPrtGraphSys.segment(x1,y1,x2,y2:integer);
begin
  if MyRgn<>0 then  MySelectClipRgn(Canvas1.Handle,MyRgn);
    if not beam then     //if (x1=x2) and (y1=y2) then
     with Canvas1 do
     begin
       MoveTo(restrict(x2),restrict(y2));
       //Pixels[x2,y2]:=pen.color;
     end
  else if PenStyle<>psSolid then
       SegmentBackwardSub(x2,y2,x1,y1)
  else
    with Canvas1 do
    begin
       LineTo(restrict(x2),restrict(y2));
       //Pixels[x2,y2]:=pen.color;
   end;
end;

procedure TGraphSys.SegmentForward( x1,y1,x2,y2:integer);
// 始点を描かず，終点を描く
begin
  if MyRgn<>0 then  MySelectClipRgn(Canvas1.Handle,MyRgn);
  if not beam then     //if (x1=x2) and (y1=y2) then
     with Canvas1 do
     begin
       MoveTo(restrict(x2),restrict(y2));
       if testClipRect(x2,y2) then
          Pixels[x2,y2]:=pen.color;
     end
  else if PenStyle<>psSolid then
       SegmentBackwardSub(x2,y2,x1,y1)
  else
    with Canvas1 do
    begin
       LineTo(restrict(x2),restrict(y2));
       if testClipRect(x2,y2) then
          Pixels[x2,y2]:=pen.color;
   end;
end;


procedure TGraphSys.plotto0(x2,y2: integer);
var
   x1,y1:integer;
begin
   if PenStyle=psSolid then
     begin
       if beam then
          begin
            x1:=latex;
            y1:=latey
          end
       else
          begin
             x1:=x2;
             y1:=y2
          end;
        segment(x1,y1,x2,y2);
     end
   else
     begin
       if beam and (LineBuffCount=0) then
          StyledLine(latex,latey);
       StyledLine(x2,y2);
     end;
   latex:=x2;
   latey:=y2;
   beam:=true;
end;

procedure TGraphSys.StyledLine(x2,y2:integer);
begin
  {$IFDEF LCLGTK2}
   x2:=restrict(x2);
   y2:=restrict(y2);
  {$ENDIF}
   if LineBuff=nil then New(LineBuff);
   if LineBuffCount>High(TLineBuff) then LineBuffFlush;
   with LineBuff^[LineBuffCount] do
      begin x:=x2; y:=y2 end;
   inc(LineBuffCount);
end;

procedure TGraphSys.LineBuffFlush;
begin
  if LineBuffCount>0 then
    begin
       PolyLine(Slice(LineBuff^, LineBuffCount));
       LineBuffCount:=0;
    end;

end;

procedure TGraphSys.setBeam(t:boolean);
begin
  if t=false then
     LineBuffFlush;
  beam0:=t;
end;

procedure TGraphSys.LineSub( a1,b1,a2,b2:integer; cl:TColor; ps:TPenStyle; w:integer);
var
   svPenColor:TColor;
   svPenStyle:TPenstyle;
   svWidth:integer;
   svBrushColor:TColor;
begin
 with Canvas1 do
   begin
    svPenColor:=Pen.Color;
    svPenStyle:=Pen.Style;
    svWidth:=Pen.Width;
    svBrushColor:=Brush.Color;
    Pen.Color:=cl;
    Pen.Style:=ps;
    Pen.Width:=w;
    Brush.Color:=MyPalette.pal[0];
    moveto(a1,b1);
    lineto(a2,b2);
    if testClipRect(a2,b2) then
       Pixels[a2,b2]:=cl;
    Pen.Color:=svPenColor;
    Pen.Style:=svPenStyle;
    Pen.Width:=svWidth;
    Brush.Color := svBrushColor;   //2013.12.28
   end;
end;

procedure TGraphSys.line(a1,b1,a2,b2:integer; c:integer; ps:TPenStyle; w:integer);
var
   cl:TColor;
begin
  if MyRgn<>0 then  MySelectClipRgn(Canvas1.Handle,MyRgn);
   cl:=MyPalette[c] ;
   LineSub(a1,b1,a2,b2,cl,ps,w)
end;


procedure TGraphSys.putmark0(a,b:integer; pointstyle:integer; pointcolor:integer);
  procedure put(dx,dy:integer);
  begin
      putPixel(a+dx,b+dy,pointcolor)
  end;
begin
    case pointstyle of
      1:  {･}
                 put(0,0);
      2:  {+}
           begin
                 put(0,0);
                 put(0,1);
                 put(0,2);
                 put(0,-1);
                 put(0 , -2);
                 put( -1,0 );
                 put( +1,0 );
                 put( -2,0 );
                 put( +2,0 );
          end;
      3: {*}
          begin
                 put(0 ,0 )  ;
                 put(0 , +1);
                 put(0 , +2);
                 put(0 , -1);
                 put(0 , -2);
                 put( -1, 0);
                 put( +1, 0);
                 put( -2, +1);
                 put( -2, -1);
                 put( +2, +1);
                 put( +2, -1);
          end;
       4: {o}
          begin
                 put( +2, -1);
                 put( +2,  0 );
                 put( +2, +1);
                 put( -2, -1);
                 put( -2,  0 );
                 put( -2, +1);
                 put( -1, +2);
                 put( 0 , +2);
                 put( +1, +2);
                 put( -1, -2);
                 put( 0 , -2);
                 put( +1, -2);
          end;
       5: {x}
           begin
                 put( 0, 0)  ;
                 put( -1, +1);
                 put( -2, +2);
                 put( -1, -1);
                 put( -2, -2);
                 put( +1, +1);
                 put( +2, +2);
                 put( +1, -1);
                 put( +2, -2);
           end;
       6: {■}
          begin
                 put( +1, +1);
                 put( +1,  0);
                 put( +1, -1);
                 put(  0, +1);
                 put(  0,  0);
                 put(  0, -1);
                 put( -1, +1);
                 put( -1,  0);
                 put( -1, -1);
          end;
       7: {●}
          begin
                 put( +2, +1);
                 put( +2,  0);
                 put( +2, -1);
                 put( +1, +2);
                 put( +1, +1);
                 put( +1,  0);
                 put( +1, -1);
                 put( +1, -2);
                 put(  0, +2);
                 put(  0, +1);
                 put(  0,  0);
                 put(  0, -1);
                 put(  0, -2);
                 put( -1, +2);
                 put( -1, +1);
                 put( -1,  0);
                 put( -1, -1);
                 put( -1, -2);
                 put( -2, +1);
                 put( -2,  0);
                 put( -2, -1);
          end;

    end;
end;

type TACanvas=class(TCanvas)
  end;

{$IF DEFINED(LclQt5)or DEFINED(LclQt6)}
function TGraphSys.testClipRect(x1,y1:integer):boolean;
 begin
  result:=true;
end;

function TScreenBMPGraphSys.testClipRect(x1,y1:integer):boolean;
var
 Rect1:Trect;
 point1:TPoint;
begin
  result:=true;
  if TACanvas(Canvas1).GetClipping  then
     begin
      Rect1:= TACanvas(Canvas1).GetClipRect;
      Point1.X:=x1;
      Point1.y:=y1;
      result:=Rect1.Contains(point1)
     end
end;
{$ELSE}
 function TGraphSys.testClipRect(x1,y1:integer):boolean;inline;
 begin
  result:=true;
end;
{$ENDIF}

type
   PPointlist=^pointlist;
   pointlist=record
        size :integer;
        count:integer;
        list:array[0..8190] of integer;
   end;

function newlist(n:integer):PPointlist;
begin
   GetMem(Pointer(result),sizeof(integer)*(2+n));
   result^.size:=n;
   result^.count:=0;
end;

procedure disposelist(p:PPointlist);
begin
   if p<>nil then FreeMem(pointer(p),sizeof(integer)*(2+p^.size))
end;

procedure insertlist(p:PPointList;n:integer);
var
   i,k:integer;
begin
  with p^ do
    begin
       k:=0;
       while  (k<count) and (list[k]<n) do inc(k);
       for i:=count-1 downto k do list[i+1]:=list[i];
       list[k]:=n;
       inc(count);
    end;
end;

procedure TGraphSys.GetPoint(var a,b:integer);
begin

end;

procedure TGraphSys.MoveMouse(a,b:integer);
begin
end;

procedure TGraphSys.MousePol(var a,b:integer; var l,r:boolean);
begin

end;

procedure TScreenBMPGraphSys.GetPoint(var a,b:integer);
begin
      PaintForm.GetPoint(a,b)
end;

procedure TScreenBMPGraphSys.MoveMouse(a,b:integer);
begin
      PaintForm.MoveMouse(a,b)
end;

procedure TScreenBMPGraphSys.MousePol(var a,b:integer; var l,r:boolean);
begin
      PaintForm.MousePol(a,b,l,r)
end;

function TGraphSys.ColorIndexOf(a,b:integer):integer;
begin
  result:=-1;
end;

function TScreenBMPGraphSys.ColorIndexOf(a,b:integer):integer;
begin
  ColorIndexOf:=MyPalette.ColorIndex(Canvas1.Pixels[a,b]);
end;




type TBMPRec=packed record
     blue,green,red,spare:byte
end;



function TGraphSys.setcolormode(s:ansistring):boolean;
begin
    result:=true;
    s:=AnsiUpperCase(s);
    if s='NATIVE' then
      if MyPalette.PaletteDisabled=false then
         begin
           MyPalette.PaletteDisabled:=true;
           graphic.PointColor:=MyPalette.pal[PointColor] and $ffffff;
           SetLineColor(MyPalette.pal[lineColor] and $ffffff);
           AreaColor:=MyPalette.pal[AreaColor] and $ffffff;
           SetTextColor(MyPalette.pal[textColor] and $ffffff);
           axescolor:=MyPalette.pal[15] and $ffffff;
         end
      else
    else if s='REGULAR' then
      if MyPalette.PaletteDisabled=true then
         begin
           MyPalette.PaletteDisabled:=false;
           graphic.PointColor:=1;
           SetLineColor(1);
           AreaColor:=1;
           SetTextColor(1);
           axescolor:=axescolor0
         end
      else
    else
       result:=false;
end;

function TGraphSys.AskColorMode:Ansistring;
begin
    if MyPalette.PaletteDisabled then
       Result:='NATIVE'
    else
       Result:='REGULAR'
end;
       
function TGraphSys.OpenFile(FileName: string):boolean;
begin
    result:=false
end;

function TScreenBMPGraphSys.OpenFile(FileName: string):boolean;
begin
  result:=PaintForm.OpenFile(FileName)
end;

function TScreenBMPGraphSys.saveFile(FileName: string):boolean;
begin
   result:=PaintForm.saveFile(FileName)
end;

function TGraphSys.SaveFile(FileName:string):boolean;
begin
      result:=false
end;

function TGraphSys.SetBitmapSize(w,h:integer):boolean;
begin
    result:=true
end;

function TScreenBMPGraphSys.SetBitmapSize(w,h:integer):boolean;
begin
   result:=PaintForm.SetBitmapSize(w,h) ;
end;


procedure rotate(var x,y:integer; a:integer);
var
  xx,yy,c,s:single;
begin
  c:=cos(a*PI/180);
  s:=sin(a*Pi/180);
  xx:=x*c + y*s;
  yy:=y*c - x*s;
  x:=System.Round(xx);
  y:=System.Round(yy);
end;

procedure TGraphSys.TextOut(x,y:integer; const s:ansistring; angle:integer);
var
  dx,dy:integer;
begin
  case Hjustify of
    tjLEFT:  dx:=0;
    tjCENTER:dx:=-(textwidth(s) div 2);
    tjRIGHT: dx:=-textwidth(s);
  end;
  case Vjustify of
    tjTOP:   dy:=0;
    tjCAP:   dy:=-(textheight(s) div 8);
    tjHALF:  dy:=-(textheight(s) div 2);
    tjBASE:  dy:=-(textheight(s)*7 div 8);
    tjBOTTOM:dy:=-textheight(s);
  end;
  Rotate(dx,dy,angle);
  x:=x+dx;
  y:=y+dy;
  TextOutSub(x,y,s,angle);
end;

procedure TGraphSys.PutText(const n,m:double; const s:string);
var
  x,y:integer;
begin
  {$IFDEF WINDOWS}
  x:=restrict(deviceX(n));
  y:=restrict(deviceY(m));
  {$ENDIF}
  if ConvToDeviceX(n,x) and ConvToDeviceY(m,y) then    //2009.6.22
     TextOut(x,y,s,textangle);
end;

function YMulti(const x0,y0:double):double;
var
  x,y,r,dx,dy:double;
begin
  if CurrentTransForm=nil then
     result:=1
   else
     with CurrentTransform do
       begin
          x := x0*xx + y0*xy + xo;
          y := x0*yx + y0*yy + yo;
          r := x0*ox + y0*oy + oo;
          dx:=xy/r - x*oy/r/r;      // xのy0に関する偏微係数
          dy:=yy/r - y*oy/r/r;      // yのy0に関する偏微係数　
          result:=Sqrt(sqr(dx)+sqr(dy))
      end;
end;

function TGraphSys.xdirection(const x0, y0:double):integer;
var
  x,y,r,dx,dy:double;
begin
  if CurrentTransform=nil then
     result:=0
  else
    try
      with CurrentTransform do
       begin
          x := x0*xx + y0*xy + xo;
          y := x0*yx + y0*yy + yo;
          r := x0*ox + y0*oy + oo;
          dx:=xx/r - x*ox/r/r;      // xのx0に関する偏微係数
          dy:=yx/r - y*ox/r/r;      // yのx0に関する偏微係数　
          result:=System.Round(ArcTan2(dy*(-VMulti), dx*HMulti)*180/pi)
       end;
    except
      {$IFNDEF Windows} RecoverFloatException; {$ENDIF}
      result:=0;
    end;
end;

procedure TGraphSys.PlotLetters(const n,m:double; const s:string);
var
  x,y:integer;
  svTextHeight:double;
begin
  svTextHeight:=GetCanvasTextHeight;
  SetCanvasTextHeight(svTextHeight*ymulti(n,m));
  {$IFDEF WINDOWS}
  x:=restrict(deviceX(n));
  y:=restrict(deviceY(m));
  {$ENDIF}
  if ConvToDeviceX(n,x) and ConvToDeviceY(m,y) then    //2009.6.22
     TextOut(x,y,s,(textangle + XDirection(n,m)) mod 360);
  SetCanvasTextHeight(svTextHeight);
end;

procedure TGraphSys.GraphText(const n,m:double; const s:string);
begin
  if TextProblemCoordinate then
    ProjectiveText(n,m,s,false)
  else
    PutText(n,m,s)
end;

procedure TGraphSys.PlotText(const n,m:double; const s:string);
begin
 if (CurrentTransForm<>nil)
     and not (currentTransform.IsSimilarPositive and (ABS(1+VMulti/HMulti)<1e-2))
  or TextProblemCoordinate
  or (Canvas1.pen.Mode<>pmCopy) then      //2014.1.6
     ProjectiveText(n,m,s,true)
 else
     PlotLetters(n,m,s)
end;



procedure TGraphSys.ProjectiveText(const n,m:double; const s:string; PlotStm:boolean);
var
   svCW:CWRec;
var
   a,b,i,j:integer;
   a0,b0,a1,b1,a2,b2,a3,b3,aMin,aMax,bMin,bMax:integer;
   color,bkcolor,color0,color1:TColor;
   dx,dy:integer;
   pxmax,pymax:integer;
   x0,y0,x,y:double;
   px,py,r:double;
   svDrawMode:boolean;
   TextHeightWhole:double;
   rt0,rt1:double;
   bmp2:TBitmap;
   NewRect:TRect;

   procedure FontToDevice(i,j:integer; var a,b:integer);
   var
      x1,y1:integer;
      x,y,x2,y2:double;
   begin
      x1:=i-dx;
      y1:=j-dy;
      x2:= x1*rt0+y1*rt1;
      y2:=-x1*rt1+y1*rt0;
      y:=y0-y2/bmp2.Height*TextHeightWhole;
      x:=x0+x2/bmp2.Height*TextHeightWhole;
      if PlotStm then currentTransform.transform(x,y);
      a:=DeviceX(x);
      b:=DeviceY(y);
   end;
label Label1;
begin
   //仮想座標系におけるtextheight を求める
  with Canvas1.Font do
    if Height=0 then //bug?
       size:=9;

  if  TextHeightChanged then                            //2013.12.27
      TextHeightWhole:=TextHeight0 *TextHeightMulti
  else
    if TextProblemCoordinate then
       TextHeightWhole:=0.01 *TextHeightMulti
    else
       TextHeightWhole:=GetCanvasTextHeight *TextHeightMulti ;

  if TextHeightWhole=0 then Exit;


  rt0:=cos(Pi*TextAngle/180);
  rt1:=sin(Pi*TextAngle/180);

  x0:=n;
  y0:=m;
  if PlotStm then currenttransform.invtransform(x0,y0);
  // x0, y0は絵定義の中の仮想座標系における描画開始点

  svDrawMode:=HiddenDrawMode;
  SetHiddenDrawMode(true);
  svCW:=GetFPUMask;
  SetFPUMask(OriginalCW);     //2014.1.23
  bmp2:=TBitmap.Create;
  try
    with bmp2 do
      begin
      {$IF DEFINED(Windows) or DEFINED(LclQt5)or DEFINED(LclQt6)}
        pixelFormat:=pf1bit;
        Monochrome:=true;
        case Length(s) of
           1.. 15:Height:=2048;
          16.. 31:Height:=1024;
          32.. 63:Height:= 512;
          64..127:Height:= 256;
         128..255:Height:= 128;
          else    Height:=  64;
        end;
      {$ELSE}
       {$IFDEF CPU64}
           {$IFDEF Darwin}
          //pixelFormat:=pf8bit;
          //Monochrome:=true;
          case Length(s) of
              1.. 15:Height:=2048;
             16.. 31:Height:=1024;
             32.. 63:Height:= 512;
             64..127:Height:= 256;
            128..255:Height:= 128;
             else    Height:=  64;
           end;
           {$ELSE}
           case Length(s) of
              1.. 15:Height:= 512;
             16.. 31:Height:= 256;
             32.. 63:Height:= 128;
             64..127:Height:=  64;
            128..255:Height:=  32;
             else    Height:=  16;
           end;
         {$ENDIF}
       {$ELSE}
         case Length(s) of
            1.. 15:Height:=256;
           16.. 31:Height:=128;
           32.. 63:Height:= 64;
           64..127:Height:= 32;
          128..255:Height:= 16;
           else    Height:= 16;
         end;
       {$ENDIF}
      {$ENDIF}

       Canvas.Font.Assign(Canvas1.Font);
     {$IFDEF Linux}
       Canvas.Font.Height:=(Height div 16)*9;
       Width:=Canvas.TextWidth(s);
     {$ELSE}
       Canvas.Font.Height:=Height;
       Width:=Canvas.TextWidth(s);
     {$ENDIF}

         NewRect:=Rect(0,0,width,Height);
         with Canvas do
            begin
              Brush.color:=clWhite;
              FillRect(NewRect);
            end;
         bkcolor:=GetPixelColor(bmp2,0,0) {Canvas.Pixels[0,0]};

         Canvas.Font.Color:=clBlack;
         //Canvas.Font.Style:=[fsBold];
         Canvas.TextOut(0,0,s);
         case Hjustify of
            tjLEFT:  dx:=0;
            tjCENTER:dx:=width div 2;
            tjRIGHT: dx:=width;
         end;
         case Vjustify of
            tjTOP:   dy:=0;
            tjCAP:   dy:=(height div 8);
            tjHALF:  dy:=(height div 2);
            tjBASE:  dy:=(height * 7) div 8;
            tjBOTTOM:dy:= height-1;
         end;
      end;

Label1:
    FontToDevice(0,0,a0,b0);
    FontToDevice(bmp2.width-1,0,a1,b1);
    FontToDevice(bmp2.width-1,bmp2.Height-1,a2,b2);
    FontToDevice(0,bmp2.Height-1,a3,b3);
    Amin:=min(min(a0,a1),min(a2,a3));
    Amax:=max(max(a0,a1),max(a2,a3));
    Bmin:=min(min(b0,b1),min(b2,b3));
    Bmax:=max(max(b0,b1),max(b2,b3));
    {
    // 文字サイズの下限を定める
    if (AMax-AMin)+(BMax-Bmin)<length(s)+2 then
      begin
        TextHeightWhole:=TextHeightWhole*1.25;
        Goto Label1;
      end;
    }
    FontToDevice(bmp2.width div 2,bmp2.Height div 2,a0,b0);
    if (a0<AMin) or (a0>AMax) or (b0<BMin) or (b0>bmax) then
      begin
        AMin:=0; AMax:=DevWidth-1;
        BMin:=0; BMax:=DevHeight-1;
      end;



    // 描画
    color1:=Canvas1.Font.color;
    color0:=Mypalette.pal[0];      //背景色
    r:=bmp2.Height/TextHeightWhole;
    pxmax:=bmp2.Width-1;
    pymax:=bmp2.Height-1;
    for b:=max(BMin,ClipRect.top)  to Min(Bmax,Cliprect.Bottom) do
      for a:=max(Amin,ClipRect.Left) to Min(AMax,Cliprect.Right) do
        begin
          try
             x:=virtualX(a);
             y:=virtualY(b);
             if PlotStm then currenttransform.invtransform(x,y);
             // この時点で，x,yは絵定義中の仮想座標
             // x,yが文字の点であるか否かを調べる。
             py:=(y0-y)*r ;
             px:=(x-x0)*r ;
             i:=System.Round(px*rt0 - py*rt1 + dx);
             j:=System.Round(px*rt1 + py*rt0 + dy);
             if (0<=j) and (j<=pymax) and (0<=i) and (i<=pxmax) then
               begin
                 color:=GetPixelColor(bmp2,i,j) {bmp2.Canvas.Pixels[i,j]};
                 if testClipRect(a,b) then
                   if (color<>bkColor) then
                     Canvas1.Pixels[a,b]:=color1
                   else if iBkMode=OPAQUE then
                     Canvas1.Pixels[a,b]:=color0
              end;
           except
             on EMathError do ;
             on EInvalidOp do ;
           end;
         end;
  finally
    bmp2.Free;
    MyGraphSys.setHiddenDrawMode(SvDrawMode);
    SetFPUMask(SvCW);     //2014.1.23
  end;
end;




function TGraphSys.textwidth(const s:ansistring):integer;
begin
   textwidth:=Canvas1.textwidth(s)
end;

function TGraphSys.textheight(const s:ansistring):integer;
begin
   textheight:=Canvas1.textheight(s)
end;

function TScreenBMPGraphSys.PixelsPerMeter:double;
begin
  result:=Screen.PixelsPerInch*10000/254;
end;

function TMetaPrtGraphSys.PixelsPerMeter:double;
begin
     result:=printer.XDPI*10000/254;
end;



function TGraphSys.SetDeviceViewport(l,r,b,t:double):boolean;
var
  ppm:double;
  l0,r0,b0,t0:integer;
begin
  ppm:=PixelsPerMeter;
  l0:=system.round(l*ppm);
  r0:=system.round(r*ppm);
  b0:=system.round(b*ppm);
  t0:=system.round(t*ppm);
  if (l0<r0) and (b0<t0)
      and (l0>=0) and (r0<=DevWidth)
      and (b0>=0) and (t0<=DevHeight) then
    begin
      DVleft:=l0;
      DVright:=r0;
      DVbottom:=b0;
      DVtop:=t0;
      setupClipRect;
      setupCoordinatesubsystem;
      clearScreen;
      result:=true;
    end
  else
    result:=false
end;



procedure TGraphSys.askDeviceSize(var w,h:double; var s:string);
var
  ppm:double;
begin
  ppm:=PixelsPerMeter;
  w:=DevWidth/ppm;
  h:=DevHeight/ppm;
  s:='METERS';
end;



procedure TGraphSys.AskDeviceViewport(var l,r,b,t:double);
var
  ppm:double;
begin
  ppm:=PixelsPerMeter;
  l:=DVleft/ppm;
  r:=DVright/ppm;
  b:=DVbottom/ppm;
  t:=DVtop/ppm;
end;

procedure TGraphSys.SetClip(c:boolean);
begin
   clip:=c;
   setupClipRect;
end;   

procedure TGraphSys.ClearScreen;
begin
  clear;
end;

procedure TPrtDirectGraphSys.ClearScreen;
begin
end;

procedure TGraphSys.PolyBezier( const Points:array of TPoint);
begin
   Canvas1.PolyBezier(Points);
end;

procedure TGraphSys.SetAreaStyle(s:TAreaStyle);
begin
   AreaStyle:=s;
end;

procedure TGraphSys.SetAreaStyleIndex(i:integer);
begin
   AreaStyleIndex:=i
end;



 {***************}
 {Flood Floodfill}
 {***************}
 procedure TGraphSys.Flood(x,y:integer);
var
   svBrushColor:TColor;
begin
   with Canvas1 do
     begin
       svBrushColor:=Brush.Color;
       Brush.Color:=MyPalette[areacolor] ;
       FloodFill(x,y,pixels[x,y],fsSurface);
       Brush.Color:=svBrushColor;
     end;
end;


procedure TGraphSys.FloodFill( x,y:integer);
var
   svBrushColor:TColor;
begin
   with Canvas1 do
    begin
       svBrushColor:=Brush.Color;
       Brush.Color:=MyPalette[areacolor] ;
       FloodFill(x,y,MyPalette[linecolor] ,fsBorder);
       Brush.Color:=svBrushColor;
    end;
end;

procedure TScreenBMPGraphSys.Flood( x,y:integer);
var
   svBrushColor:TColor;
begin
   if MyRgn<>0 then  MySelectClipRgn(Canvas1.Handle,MyRgn);
   with Canvas1 do
     begin
       svBrushColor:=Brush.Color;
       Brush.Color:=MyPalette[areacolor] ;
       FloodFill(x,y,GetPixelColor(bitmap1,x,y),fsSurface);
       Brush.Color:=svBrushColor;
     end;
   if not HiddenDrawMode then
    {$IFDEF Windows}
     PaintForm.repaint;
    {$ELSE}
    RepaintRequest:=true;
    {$ENDIF}
end;



procedure TScreenBMPGraphSys.FloodFill( x,y:integer);
begin
   if MyRgn<>0 then  MySelectClipRgn(Canvas1.Handle,MyRgn);
   inherited FloodFill(x,y);
   if not HiddenDrawMode then
    {$IFDEF Windows}
     PaintForm.repaint;
    {$ELSE}
    RepaintRequest:=true;
    {$ENDIF}
end;


{***************}
{Microsoft BASIC}
{***************}



procedure TScreenBMPGraphSys.MSScreen(c:integer);
begin
   case c of
     2,3,87:
      PaintForm.setBitMapSize(640,400);
     11,12:
      PaintForm.setBitMapSize(640,480);
   end;

   if c in [3,12,87] then
    begin
       case c of
        3 :MyPalette.PaletteNumber:=2;
        12,87:MyPalette.PaletteNumber:=1;
       end;
       PaintForm.clear;
       linecolor:=7;
       setlinecolor(7);
    end;
end;
procedure TGraphSys.MSMoveTo(a,b:integer);
begin
   Canvas1.Moveto(a,b);
end;

procedure TGraphSys.MSLineTo(a,b:integer);
begin
   Canvas1.lineto(a,b);
end;

procedure TGraphSys.MSPaint( x,y:integer; ac, bc:integer);
var
   svBrushColor:TColor;
   BorderColor:TColor;
begin
   svBrushColor:=Canvas1.Brush.Color;
   Canvas1.Brush.Color:=MyPalette[ac] ;
   BorderColor:=MyPalette[bc] ;
   Canvas1.FloodFill(x,y,BorderColor,fsBorder);
   Canvas1.Brush.Color:=svBrushColor;
   Canvas1.MoveTo(x,y);
end;

procedure TScreenBMPGraphSys.MSPaint( x,y:integer; ac, bc:integer);
begin
   inherited MSPaint(x,y,ac,bc);

end;

procedure MSCircleSub(Canvas:TCanvas;
                                x1,y1,x2,y2:integer; lc,ac:integer; f:boolean);

var
   svBrushColor,svPenColor:TColor;
   svBrushStyle:TBrushStyle;
begin
 with Canvas do
 begin
   svPenColor:=Pen.Color;
   svBrushColor:=Brush.Color;
   Pen.Color:=MyPalette[lc] ;
   Brush.Color:=MyPalette[ac] ;
   svBrushStyle:=Brush.Style;
   if F then
      Brush.Style:=BSSolid
   else
      Brush.Style:=BSClear;
   Ellipse(x1,y1,x2,y2);

   Pen.Color:=svPenColor;
   Brush.Color:=svBrushColor;
   Brush.Style:=svBrushStyle;
 end;
end;

procedure TGraphSys.MSCircle(x1,y1,x2,y2:integer; lc,ac:integer; F:boolean);
begin
  MSCircleSub(Canvas1,x1,y1,x2,y2,lc,ac,F);
end;

procedure TScreenBMPGraphSys.MSCircle(x1,y1,x2,y2:integer; lc,ac:integer; F:boolean);
begin
  MSCircleSub(Canvas1,x1,y1,x2,y2,lc,ac,F);

end;

{****************}
{Start and Finish}
{****************}


procedure TScreenBMPGraphSys.start;
begin
  {$IFDEF Windows}
    restrict:=restrictNT;
    ShrinkRange:=ShrinkRangeNT;
{$ELSE}
  {$IFDEF LCLGtk2}
    restrict:=restrict16;
    ShrinkRange:=ShrinkRange16;
  {$ELSE}
    restrict:=restrictNone;
    ShrinkRange:=ShrinkRangeNone;
  {$ENDIF}
{$ENDIF}

end;


procedure TPrtDirectGraphSys.start;
begin
    restrict:=restrictNone;
    ShrinkRange:=ShrinkRangeNone;

   MyPalette.PaletteNumber:=0;
   {todo 1 printer}

   with PrintDialog1 do
     begin
       cancelButton.Visible:=false;
       ShowModal;
       cancelButton.Visible:=true;
     end;

   if printer.Printers.Count>0 then
    begin
      Canvas1:=printer.Canvas;
      Canvas1.Font.PixelsPerInch:=Printer.XDPI;
      Canvas1.Font.Assign(GraphOptDlg.FontDialog1.Font);
      printer.BeginDoc;
    end
   else setexception(9002);
end;


procedure TScreenBMPGraphSys.finish;
begin
  LineBuffFlush;
  MySelectClipRgn(Canvas1.Handle,0);
  DeleteObject(MyRgn);
  MyRgn:=0;
  HiddenDrawMode:=false;

end;

procedure TPrtDirectGraphSys.finish;
begin
  LineBuffFlush;
{todo 1 printer}
  with printer do
   if printing then
     begin
        MySelectClipRgn(Canvas1.Handle,0);
        DeleteObject(MyRgn);
        MyRgn:=0;
        EndDoc;
     end;

end;


initialization

    MyPalette:=TMyPalette.create;
    MyPalette.PaletteNumber:=0;

    ScreenBMPGraphSys:=
              {$IF Defined(LCLCarbon) or Defined(LCLCocoa) }
                  TScreenBMPGraphSys.create;
              {$ELSE}
                  TBackwardBMPGraphSys.create;
              {$IFEND};
    PrtDirectGraphSys:=TPrtDirectGraphSys.create;
    MyGraphSys:=nil;



finalization

   ScreenBMPGraphSys.Free;
   PrtDirectGraphSys.free;
   MyPalette.Free;

end.
