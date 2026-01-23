unit graphic;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

(***************************************)
(* Copyright (C) 2006, SHIRAISHI Kazuo *)
(***************************************)



{********}
interface
{********}
uses Graphics, Types,Forms,Dialogs,SysUtils,Classes, Math,GraphType,
     struct,variabl,GraphQue;

type
   TAskStatus=Class(Tstatement)
      Status:TVariable;
     procedure StatusInit;
     destructor destroy;override;
   end;
function  ASKst(prev,eld:TStatement):TAskStatus;


function PixelX(x:double):double;
function PixelY(x:double):double;
function WindowX(x:double):double;
function WindowY(x:double):double;
{
procedure putMark(vx,vy:integer);
procedure mouseErase;
procedure MouseShow;
}
procedure setpointcolor(c:integer);
procedure setpointstyle(c:integer);
function getpointstyle:integer;
function getpointcolor:integer;
procedure setTextColor(c:integer);
function getTextColor:integer;

var
   SetTextJustifySt:function(prev,eld:TStatement):TStatement;
   PlotTextst:      function(prev,eld:TStatement):TStatement;


function MATPLOTst(prev,eld:TStatement):TStatement;
function MATLOCATEst(prev,eld:TStatement):TStatement;
function  MSLINEst(prev,eld:TStatement):TStatement;

 type
   TBeamOff=class(TGraphCommand)
     procedure execute;override;
   end;

 type
   TBeamOn=class(TGraphCommand)
     procedure execute;override;
   end;


 type
      setprocedure=procedure(c:integer);


 Type TSetPrc=Class(TGraphCommand)
   setprc:setprocedure;
   i:longint;
   constructor create(prc0:setprocedure; i0:longint);
   procedure execute;override;
 end;



 type TPutmark0=class(TGraphCommand)
     a,b:integer;
     PointStyle:integer;
     PointColor:integer;
   constructor create(a0,b0:integer);
   procedure execute;override;
  end;

 Type
   TPolyLine=class(TGraphCommand)
     Points:array of TPoint;
     constructor create(const Points0:array of TPoint);
     procedure execute;override;
     destructor destroy;override;
   end;

 type TPolygon=class(TPolyLine)
  procedure execute;override;
end;

   {Virtual Coordinates graphics}

function SetBeamMode(s:AnsiString):boolean;
function AskBeamMode:AnsiString;


procedure BeamOff;
var  beam:boolean=true;
var  pointstyle:integer=3;
var  pointcolor:integer=1;

procedure initGraphics;

{************}
implementation
{************}
uses
     MyUtils,base,float,texthand,express, variablc, textfile,
     mat,setask,helpctex,
     draw,sconsts,confopt,graphsys,locatefrm,mainfrm,locatech,MyThread;


{Virtual Coordinates graphics}

procedure TBeamOff.execute;
   begin
      MyGraphSys.beam:=false;
   end;

procedure TBeamOn.execute;
    begin
       MyGraphSys.beam:=true;
    end;

procedure BeamOff;
begin
  if beam then
    begin
      AddQueue(TBeamOff.create);
      Beam:=false;
    end;
end;

procedure BeamOn;
begin
  if beam=false then
    begin
      AddQueue(TBeamOn.create);
      beam:=true;
    end;
end;

{********}
{graphics}
{********}


type
    TCustomSetWindow=class(TStatement)
       x1,x2,y1,y2:TPrincipal;
       destructor destroy;override;
       procedure exec;override;
       function execute(var l,r,b,t:double):boolean;virtual;
      end;

    TSetWindow=class(TCustomSetWindow)
       constructor create(prev,eld:TStatement);
    end;

   TSetDeviceViewPort=class(TSetWindow)
       procedure exec;override;
       function execute(var l,r,b,t:double):boolean;override;
    end;

   TSetDeviceWindow=class(TSetDeviceViewport)
       procedure exec;override;
    end;

   TSetViewPort=class(TSetDeviceViewport)
       procedure exec;override;
    end;


constructor TsetWindow.create(prev,eld:TStatement);
label
   errorExit;
begin
    inherited create(prev,eld);
    graphmode:=true;
    x1:=nexpression;
    check(',',IDH_WINDOW);
    x2:=nexpression;
    check(',',IDH_WINDOW);
    y1:=nexpression;
    check(',',IDH_WINDOW);
    y2:=nexpression;
end;

destructor TCustomSetWindow.destroy;
begin
    x1.free;
    x2.free;
    y1.free;
    y2.free;
    inherited destroy
end;


function TCustomSetWindow.execute(var l,r,b,t:double):boolean;
begin
      if currenttransform<>nil then
               setexception(11004);
      l:=x1.evalX;
      r:=x2.evalX;
      b:=y1.evalX;
      t:=y2.evalX;
      if ((l=r) or (b=t)) then
       //  if InsideOfWhen or not JISSetWindow then
       //       setexception(11051)
        begin
          ReportException(InsideOfWhen , 11051);
          result:=false
        end
      else
         result:=true;
 end;

Type TTSetWindow=class(TGraphCommand)
       l,r,b,t:double;
       constructor create(x1,x2,y1,y2:double);
       procedure execute;override;
end;

constructor TTSetWindow.create(x1,x2,y1,y2:double);
begin
      inherited create;
      l:=x1;
      r:=x2;
      b:=y1;
      t:=y2;
end;

procedure TTSetWindow.execute;
begin
   MyGraphSys.setWindow(l,r,b,t)
end;

procedure TCustomSetWindow.exec;
var
  l,r,b,t:double;
begin
  if execute(l,r,b,t)then
     addQueue(TTSetWindow.create(l,r,b,t));
  WaitReady;       //2018.7.19  Ver. 8.0.1.2
end;

function TSetDeviceViewport.execute(var l,r,b,t:double):boolean;
begin
   result:=false;
   if inherited execute(l,r,b,t) then
      if (l<r) and (b<t) then
         result:=true
      else
        //if InsideOfWhen or not JISSetWindow then
        //      setexception(11051);
        ReportException(InsideOfWhen  , 11051);
end;

function TestInterval(const l,r,b,t:double):boolean;
begin
   result:=(0<=l) and (r<=1) and (0<=b) and (t<=1)
end;

Type TTSetViewPort=Class(TTsetWindow)
            procedure execute;override;
end;

procedure TTsetViewPort.execute;
begin
    MyGraphSys.setViewport(l,r,b,t)
end;

procedure TSetViewPort.exec;
var
  l,r,b,t:double;
begin
  if execute(l,r,b,t)then
     if testInterval(l,r,b,t) then
        addQueue(TTSetViewPort.create(l,r,b,t))
     else
       //if InsideOfWhen or not JISSetWindow then
       // setexception(11052);
       ReportException( InsideOfWhen,11052);
end;

Type TTSetDeviceWindow=Class(TTsetWindow)
            procedure execute;override;
end;

procedure TTSetDeviceWindow.execute;
begin
    MyGraphSys.setDeviceWindow(l,r,b,t)
end;

procedure TSetDeviceWindow.exec;
var
  l,r,b,t:double;
begin
  if execute(l,r,b,t)then
     if testInterval(l,r,b,t) then
        AddQueue(TTsetDeviceWindow.create(l,r,b,t))
     else
       //if insideofwhen or not JISSetWindow then
       //  setexception(11053) ;
       ReportException( insideofwhen  , 11053);
end;

Type TTSetDeviceViewPort=class(TResetBoolean)
       l,r,b,t:double;
       pw:PBoolean;
       constructor create(var s,w:boolean; x1,x2,y1,y2:double);
       procedure ExecCore;override;
end;

constructor TTSetDeviceViewPort.create(var s,w:boolean; x1,x2,y1,y2:double);
begin
      inherited create(s);
      l:=x1;
      r:=x2;
      b:=y1;
      t:=y2;
      pw:=@w;
end;

procedure TTSetDeviceViewPort.ExecCore;
begin
    pw^:=MyGraphSys.SetDeviceViewport(l,r,b,t)
end;

procedure TSetDeviceViewPort.exec;
var
   l,r,b,t:double;
   s,w:boolean;
begin
  if execute(l,r,b,t) then
     begin
       AddQueue(TTSetDeviceViewPort.create(s,w,l,r,b,t));
       while s do (TThread.CurrentThread).Yield  ;
       if w then
         else
           //if insideofwhen or not JISSetWindow then
           //  setexception(11054) ;
           REportException( insideofwhen , 11054);
     end;
end;


type
    TSetColorMix=class(TStatement)
       ColorIndex,Red,Green,Blue:TPrincipal;
       constructor create(prev,eld:TStatement);
       destructor destroy;override;
       procedure exec;override;
      end;




constructor TsetColorMix.create(prev,eld:TStatement);
begin
    graphmode:=true;
    inherited create(prev,eld);
    Check('(',IDH_SET_COLOR_MIX);
    ColorIndex:=nexpression;
    check(')',IDH_SET_COLOR_MIX);
    Red:=nexpression;
    check(',',IDH_SET_COLOR_MIX);
    Green:=nexpression;
    check(',',IDH_SET_COLOR_MIX);
    Blue:=nexpression;
end;

destructor TSetColorMix.destroy;
begin
    ColorIndex.free;
    Red.free;
    Green.free;
    Blue.free;
    inherited destroy
end;

procedure SetColorMix(c:byte;r,g,b:byte);
var
   col:TColor;
begin
  col:=r+g*DWord($100)+b*DWord($10000) ;
  with MyGraphSys do
    begin
       MyPalette[c]:=col ;
       setlinecolor(linecolor);
       settextcolor(textcolor);
    end;   
end;
type
   TTsetColorMix=class(TGraphCommand)
       c,r,g,b:byte;
       constructor create(c0,r0,g0,b0:byte);
       procedure execute;override;
   end;

constructor  TTsetColorMix.create(c0,r0,g0,b0:byte);
begin
  inherited create;
  c:=c0; r:=r0; g:=g0; b:=b0;
end;

procedure TTsetColorMix.execute;
begin
  setcolormix(c,r,g,b);
end;



// SET COLOR MIX を描画スレッドに委譲

procedure TSetColorMix.exec;
var
   er,eg,eb:double;
   cc:longint;
   r,g,b:byte;
begin
    //WaitReady;               //描画コマンドの完了を待つ //廃止 ver. 8.1.4.0 2025.05.16
      cc:=ColorIndex.evalInteger;
      er:=Red.evalX ;
      eg:=Green.evalX;
      eb:=Blue.evalX;

      if (cc<0) or (cc>maxColor) or MyPalette.PaletteDisabled then
         //if InsideOfWhen or not JISSetWindow then
          //     setexception(11085);
          ReportException( InsideOfWhen  ,11085);

      if (er<0) or (er>1) or (eg<0) or (eg>1) or (eb<0) or (eb>1) then
         //if InsideOfWhen or not JISSetWindow then
         //      setexception(11088);
         ReportException( InsideOfWhen  ,11088);
     r:=LongIntRound(er*255);
     g:=LongIntRound(eg*255);
     b:=LongIntRound(eb*255);
     //setcolormix(cc,r,g,b);
     addqueue(TTSetColorMix.Create(cc,r,g,b));
end;


const
    MaxLineStyle=5;
    MaxPointStyle=7;
    MaxAreaStyleIndex=6;


procedure setlinecolor(c:integer);
begin
    c:=c and $ffffff;
    MyGraphSys.setlinecolor(c);
end;

procedure setlineStyle(c:integer);
var
   s:TPenStyle;
begin
    case c of
      1:  s:=psSolid;
      2:  s:=psDash;
      3:  s:=psDot;
      4:  s:=psDashDot;
      5:  s:=psDashDotDot;
     else
    end;
    MyGraphSys.setPenStyle(s);
end;

procedure setlineWidth(c:integer);
begin
    MyGraphSys.setlinewidth(c);
end;

procedure setpointcolor(c:integer);
begin
    c:=c and $ffffff;
    PointColor:=c;
end;

procedure setpointstyle(c:integer);
begin
    if (c>0) and (c<=maxpointstyle) then
    pointstyle:=c;
end;

procedure setareacolor(c:integer);
begin
    c:=c and $ffffff;
    MyGraphSys.areacolor:=c ;
end;

procedure settextcolor(c:integer);
begin
    c:=c and $ffffff;
    MyGraphSys.settextcolor(c);
end;

procedure seteverycolor(c:integer);
begin
    setlinecolor(c);
    //setpointcolor(c);    //2020.10.13 ver.8.1.0.7
    setareacolor(c);
    settextcolor(c)
end;

procedure setaxiscolor(c:integer);
begin
    GraphSys.axescolor:=c
end;    

procedure setAreaStyleIndex(c:integer);
begin
    MyGraphSys.setAreaStyleIndex(c);
end;

type
     TSET=class(TStatement)
          exp:TPrincipal;
          setprc:setprocedure;
          idxmax:integer;
          ercode:integer;
        constructor create(prev,eld:TStatement; s:setprocedure; imax:integer; erc:integer);
        constructor createColor(prev,eld:TStatement; s:setprocedure);
        procedure exec;override;
        destructor destroy;override;
      end;

constructor TSet.create(prev,eld:TStatement; s:setprocedure; imax:integer; erc:integer);
begin
   inherited create(prev,eld);
   exp :=nexpression;
   setprc:=s;
   idxmax:=imax;
   ercode:=erc;
end;

constructor TSet.createColor(prev,eld:TStatement; s:setprocedure);
begin
   inherited create(prev,eld);
   exp :=NSExpression;
   setprc:=s;
   idxmax:=255;
   ercode:=11085;
end;


destructor TSet.destroy;
begin
   exp.free;
   inherited destroy
end;



constructor TSetPrc.create(prc0:setprocedure; i0:longint);
begin
  inherited create;
  setprc:=prc0;
  i:=i0;
end;

procedure TSetPrc.execute;
begin
  setprc(i);
end;

procedure TSet.exec;
var
   s:ansistring;
   color:longint;
   i:longint;
begin
    if exp.kind<>'s' then
       begin
          i:=exp.evalInteger;
          if  not MyPalette.PaletteDisabled
             and ((i<0) or (i>idxmax)) then
                 ReportException(InsideOfWhen,ercode);

          if @setprc=@setpointcolor then
             setprc(i)
          else if  @setprc=@seteverycolor then
             begin
                setpointcolor(i);
                AddQueue(TSetPrc.create(setprc,i))
             end
          else
            AddQueue(TSetPrc.create(setprc,i))
       end
    else
       begin
          s:=exp.evalS;
          for i:=1 to length(s) do s[i]:=upcase(s[i]);
          if (s='BLACK') or (s='黒') then
             color:=Black
          else if (s='BLUE')or (s='青')  then
             color:=Blue
          else if (s='RED') or (s='赤') then
             color:=Red
          else if s='MAGENTA' then
             color:=Magenta
          else if (s='GREEN') or (s='緑') then
             color:=Green
          else if s='CYAN' then
             color:=cyan
          else if (s='YELLOW') or (s='黄') then
             color:=Yellow
          else  if (s='WHITE') or (s='白') then
             color:=White
          else if s='GRAY' then
             color:=clGray
          else if s='NAVY' then
             color:=clNAVY
          else if s='SILVER' then
             color:=clSILVER
          else if s='LIME' then
             color:=clGREEN
          else
             begin
               color:=Black;
               //if insideofwhen or not JISSetWindow then
               //                  setexception(11085);
               ReportException(insideofwhen , 11085);
             end;
         i:=MyPalette.ColorIndex(color);
         if i>=0 then
            if @setprc=@setpointcolor then
               setprc(i)
            else
               AddQueue(TSetPrc.create(setprc,i));
       end;
end;

type
     TSet1=class(TSet)
         procedure exec;override;
     end;

procedure TSet1.exec;
var
   i:longint;
begin
   i:=exp.evalInteger;
   if (i<1) or (i>idxmax) then
       //if InsideOfWhen or not JISSetWindow then
       //     setexception(ercode)
       //else
       //     i:=1;
      begin
        i:=1;
        ReportException(InsideOfWhen , ercode)
      end;
    AddQueue(TSetPrc.create(setprc,i));
end;

type
     TSetDirect=class(TSet)
         procedure exec;override;
     end;

procedure TSetDirect.exec;
var
   i:longint;
begin
   i:=exp.evalInteger;
   if (i<1) or (i>idxmax) then
       begin
         i:=1;
         ReportException(InsideOfWhen,ercode) ;
       end;
       //  if InsideOfWhen or not JISSetWindow then
       //     setexception(ercode)
       //else
       //     i:=1;
    setprc(i);
end;

type
     TSetDrawMode=class(TStatement)
        mode:char;
        constructor create(prev,eld:TStatement);
        procedure exec;override;
      end;

constructor TSetDrawMode.create(prev,eld:TStatement);
begin
   inherited create(prev,eld);
   if (token='EXPLICIT')
     or (token='HIDDEN')
     //{$IFNDEF Darwin}
     or (token='MERGE')
     or (token='XOR')
     or (token='NOTXOR')
     //{$ENDIF}
     or (token='OVERWRITE')  then
         mode:=token[1]
     //{$IFNDEF Darwin}
    else if token='MASK' then
         mode:='A'
     //{$ENDIF}
  else
      seterrIllegal(token,0);

   gettoken;
end;

type TTSetDrawMode=class(TGraphCommand)
   mode:char;
   constructor create(mode0:char);
   procedure execute;override;
 end;

constructor TTSetDrawMode.create(mode0:char);
begin
  inherited create;
  mode:=mode0;
end;

procedure TTSetDrawMode.execute;
begin
   case mode of
   'E':  MyGraphSys.setHiddenDrawMode(false);
   'H':  MyGraphSys.setHiddenDrawMode(true) ;
   'N':  MyGraphSys.setRasterMode(pmNotXor) ;
   'O':  MyGraphSys.setRasterMode(pmCopy)   ;
   'A':  MyGraphSys.setRasterMode(pmMask)   ;
   'M':  MyGraphSys.setRasterMode(pmMerge) ;
   'X':  MyGraphSys.setRasterMode(pmXor) ;
   end;
end;

procedure TSetDrawMode.exec;
begin
    AddQueue(TTsetDrawMode.create(mode))
end;

{SET TEXT HEIGHT}
type
     TSetTextHeight=class(TStatement)
          exp:TPrincipal;
        constructor create(prev,eld:TStatement);
        procedure exec;override;
        destructor destroy;override;
      end;

constructor TSetTextHeight.create(prev,eld:TStatement);
begin
   inherited create(prev,eld);
   exp :=nexpression;
end;

destructor TSetTextHeight.destroy;
begin
   exp.free;
   inherited destroy
end;

type TTSetTextHeight=class(TGraphCommand)
   x:double;
   constructor create(x0:double);
   procedure execute;override;
end;


constructor TTSetTextHeight.create(x0:double);
begin
    inherited create;
    x:=x0;
end;

procedure TTSetTextHeight.execute;
begin
    MyGraphSys.SetTextHeight(x)
end;

procedure TSetTextHeight.exec;
var
   x:double;
begin
   x:=exp.evalX;
   if x>0 then
      addQueue(TTSetTextHeight.create(x))
   else //if insideofWhen or not JISSetWindow then
        //setexception(11073);
      ReportException(insideofWhen, 11073)
end;

{ask text height}


{SET TEXT ANGLE}
type
     TSetTextAngle=class(TStatement)
          exp:TPrincipal;
        constructor create(prev,eld:TStatement);
        procedure exec;override;
        destructor destroy;override;
      end;

constructor TSetTextAngle.create(prev,eld:TStatement);
begin
   inherited create(prev,eld);
   exp :=nexpression;
end;

destructor TSetTextAngle.destroy;
begin
   exp.free;
   inherited destroy
end;

type
     TTSetTextAngle=class(TGraphCommand)
        x:double;
        constructor create(x0:double);
        procedure execute;override;
     end;
 constructor TTSetTextAngle.create(x0:double);
begin
    inherited create;
    x:=x0;
end;
 procedure TTSetTextAngle.execute;
 begin
   MyGraphSys.textangle:=SysTem.Round(x - Floor(x/360.0 ) * 360.0 );
 end;

procedure TSetTextAngle.exec;
var
   x:double;
   a:integer;
begin
   x:=exp.evalX;
   if not PUnit.Angledegrees then
      x:=x * 180. / PI;
   addQueue(TTSetTextAngle.create(x));
end;


type
     TSetClip=class(TStatement)
          exp:TPrincipal;
        constructor create(prev,eld:TStatement);
        procedure exec;override;
        destructor destroy;override;
      end;

constructor TSetClip.create(prev,eld:TStatement);
begin
   inherited create(prev,eld);
   exp :=sexpression;
end;

destructor TSetClip.destroy;
begin
   exp.free;
   inherited destroy
end;

Type TTSetClip=class(TGraphCommand)
   b:boolean;
   constructor create(b0:boolean);
   procedure execute;override;
end;

constructor TTSetClip.create(b0:boolean);
begin
  inherited create;
  b:=b0;
end;

procedure TTSetClip.execute;
begin
    MyGraphSys.setclip(b)
end;

procedure TSetClip.exec;
var
   s:string;
   b:boolean;
begin
   s:=UpperCase(exp.evalS);
   with MyGraphSys do
   if s='ON' then AddQueue(TTsetClip.create(true))
   else if s='OFF' then AddQueue(TTsetClip.create(false))
   else
      //if InsideOfWhen or not JISSetWindow then
      //                  setexception(4101);
      ReportException(insideofwhen, 4101)
 end;

{SET TEXT Font}
type
     TSetTextFont=class(TStatement)
          exp1,exp2:TPrincipal;
        constructor create(prev,eld:TStatement);
        procedure exec;override;
        destructor destroy;override;
      end;

constructor TSetTextFont.create(prev,eld:TStatement);
begin
   inherited create(prev,eld);
   exp1 :=SExpression;
   //checktoken(',',IDH_GRAPH_EXT);
   if test(',') then             //2013.12.21
   exp2:=NExpression;
end;

destructor TSetTextFont.destroy;
begin
   exp1.free;
   exp2.free;
   inherited destroy
end;


procedure TSetTextFont.exec;
var
   s:ansistring;
   i:integer;
begin
   s:=exp1.evalS;
   if exp2<>nil then i:=exp2.evalInteger else i:=0;    //2013.12.21
   WaitReady;
   MyGraphSys.SetTextFont(s,i);
end;


{TSetTextBk}
type
     TTSetTextBk= class(TGraphCommand)
        ibk:integer;
        constructor create(ibk0:integer);
        procedure execute;override;
     end;

constructor TTSetTextBk.create(ibk0:integer);
begin
   inherited create;
   ibk:=ibk0;
end;
procedure TTSetTextBk.execute;
 begin
   MyGraphSys.SetTextBkMode(ibk);
 end;


type
     TSetTextBk=class(TStatement)
          exp:TPrincipal;
        constructor create(prev,eld:TStatement);
        procedure exec;override;
        destructor destroy;override;
      end;

constructor TSetTextBk.create(prev,eld:TStatement);
begin
   inherited create(prev,eld);
   exp :=sexpression;
end;

destructor TSetTextBk.destroy;
begin
   exp.free;
   inherited destroy
end;

procedure TSetTextBk.exec;
var
   s:string;
   ibk:integer;
begin
   s:=UpperCase(exp.evalS);
   if s='TRANSPARENT' then iBK:=TRANSPARENT
   else if s='OPAQUE' then iBK:=OPAQUE
   else setexception(11000);
   addQueue(TTSetTextBk.create(ibk));

end;

type
  TSetAreaStyle=class(TSetTextBk)
        procedure exec;override;
  end;

procedure TSetAreaStyle.exec;
var
   s:String;
   c:TAreaStyle;
begin
   s:=UpperCase(exp.evalS);
   if s='HOLLOW' then c:=asHollow
   else if s='SOLID' then c:=asSolid
   else if s='HATCH' then c:=asHatch
   else setexception(11000);
   WaitReady;
   MyGraphSys.SetAreaStyle(c);
end;



type
     TSetBitmapSize=class(TStatement)
          exp1,exp2:TPrincipal;
        constructor create(prev,eld:TStatement);
        procedure exec;override;
        destructor destroy;override;
      end;

constructor TSetBitmapSize.create(prev,eld:TStatement);
begin
   inherited create(prev,eld);
   exp1 :=NExpression;
   checktoken(',',IDH_GRAPH_EXT);
   exp2:=NExpression;
end;

destructor TSetBitmapSize.destroy;
begin
   exp1.free;
   exp2.free;
   inherited destroy
end;

type
     TTSetBitmapSize=Class(TResetBoolean)
        a,b:longint;
        pr:PBoolean;
        constructor create(var s:boolean; a0,b0:longint; var r:boolean);
        procedure execCore;override;
     end;

constructor TTSetBitmapSize.create (var s:boolean; a0,b0:longint; var r:boolean);
begin
   inherited create(s);
   a:=a0; b:=b0;
   pr:=@r;
end;

procedure  TTSetBitmapSize.execCore;
begin
    pr^:=MyGraphSys.setBitmapSize(a,b)
end;

procedure TSetBitmapSize.exec;
var
   s:boolean;
   r:boolean;
begin
   r:=true;
   addQueue(TTSetBitmapSize.create(s, exp1.evalLongInt,exp2.evalLongInt,r));
   while s do (TThread.CurrentThread).Yield  ;
   if r=false then setexception(9050)
end;


type
     TSetColorMode=class(TStatement)
          exp1:TPrincipal;
        constructor create(prev,eld:TStatement);
        destructor destroy;override;
        procedure exec;override;
      end;

constructor TSetColorMode.create(prev,eld:TStatement);
begin
   inherited create(prev,eld);
   exp1:=SExpression;
end;

destructor TSetColorMode.destroy;
begin
     exp1.free;
    inherited destroy
end;


procedure TSetColorMode.exec;
begin
  WaitReady;
  MyGraphSys.setcolormode(exp1.evalS);
end;

type
   TSetBeamMode=class(TsetColorMode)
        procedure exec;override;
end;

procedure TSetBeamMode.exec;
begin
  WaitReady;
  setBeamMode(exp1.evalS);
  WaitReady;    // 実行スレッドからBeamModeを参照することを許す
end;


function  SETst(prev,eld:TStatement):TStatement;
begin
    setst:=nil;
    if token='WINDOW' then
       begin
            gettoken;
            SETst:=TSetWindow.create(prev,eld);
       end
    else if  (token='VIEWPORT') then
       begin
            gettoken;
            SETst:=TSetViewport.create(prev,eld);
       end
    else if (token='DEVICE') then
        begin
           gettoken;
           if (token='WINDOW')  then
                 begin
                     gettoken;
                     SETst:=TSetDeviceWindow.create(prev,eld)
                 end
          else if(token='VIEWPORT') then
               begin
                    gettoken;
                    SETst:=TSetDeviceViewport.create(prev,eld)
               end
        end
    else if  (token='CLIP') then
       begin
            gettoken;
            SETst:=TSetClip.create(prev,eld);
       end
    else if  (token='LINE') then
        begin
            gettoken;
            if  (token='COLOR')  then
                begin
                    gettoken;
                    SETst:=TSet.createColor(prev,eld,setlinecolor)
                end
            else if(token='STYLE') then
               begin
                    gettoken;
                    SETst:=TSet1.create(prev,eld,setlinestyle,maxlinestyle,11062)
               end
            else if(token='WIDTH') then
               begin
                    gettoken;
                    SETst:=TSet1.create(prev,eld,setlinewidth,maxint,11062)
               end
        end
    else if (token='POINT') then
        begin
           gettoken;
           if (token='COLOR')  then
                 begin
                     gettoken;
                     SETst:=TSet.createColor(prev,eld,setpointcolor)
                 end
          else if(token='STYLE') then
               begin
                    gettoken;
                    SETst:=TSetDirect.create(prev,eld,setpointstyle,maxpointstyle,11056)
               end
        end
    else if (token='AREA') then
        begin
           gettoken;
           if (token='COLOR') then
              begin
                 gettoken;
                 SETst:=TSet.createColor(prev,eld,setareacolor)
              end

           else if(token='STYLE') then
              begin
                gettoken;
                if token='INDEX' then
                   begin
                      gettoken;
                      SETst:=TSet1.create(prev,eld,SetAreaStyleIndex,MaxAreaStyleIndex,11000)
                   end
                else
                    SETst:=TSetAreaStyle.create(prev,eld)
              end

        end
    else if (token='TEXT') then
        begin
           gettoken;
           if (token='COLOR')  then
                 begin
                     gettoken;
                     SETst:=TSet.createColor(prev,eld,settextcolor)
                 end

           else if(token='JUSTIFY') then
               begin
                    gettoken;
                    SETst:=SetTextJustifySt(prev,eld);
               end
           else if(token='HEIGHT') then
               begin
                    gettoken;
                    SETst:=TSetTextHeight.create(prev,eld);
               end
           else if(token='ANGLE') then
               begin
                    gettoken;
                    confirmedDegrees;
                    SETst:=TSetTextAngle.create(prev,eld);
               end
           else if(token='FONT') then
               begin
                    gettoken;
                    SETst:=TSetTextFont.create(prev,eld);
               end

           else if(token='BACKGROUND')  then
               begin
                    gettoken;
                    SETst:=TSetTextBk.create(prev,eld);
               end

        end
    else if (token='COLOR')  then
        begin
           gettoken;
           if token='MIX' then
              begin
                 gettoken;
                 SETst:=TSetColorMix.create(prev,eld)
              end
           else if token='MODE' then
              begin
                 gettoken;
                 SETst:=TSetColorMode.create(prev,eld)
              end
           else
              SETst:=TSet.createColor(prev,eld,seteverycolor);
        end
    else if (token='DRAW')  then
        begin
           gettoken;
           checkToken('MODE',0);
           SETst:=TSetDrawMode.create(prev,eld);
        end
    else if (token='AXIS') then
        begin
           gettoken;
           if (token='COLOR')  then
                 begin
                     gettoken;
                     SETst:=TSet.createColor(prev,eld,setaxiscolor)
                 end
        end
    else if (token='BITMAP') and (NextGraphMode=ScreenBitMapMode)then
        begin
           gettoken;
           if (token='SIZE')  then
                 begin
                     gettoken;
                     SETst:=TSetBitMapSize.create(prev,eld)
                 end
        end
    else if (token='BEAM')  then
        begin
           gettoken;
           checkToken('MODE',0);
           SETst:=TSetBeamMode.create(prev,eld);
        end
    else
        SETst:=SetAsk.SETst(prev,eld);
end;


{**************}
{ASK statements}
{**************}
procedure TAskStatus.StatusInit;
begin
   if status<>nil then
      status.assignLongint(0)
end;

destructor TaskStatus.destroy;
begin
    status.free;
    inherited destroy;
end;

type
  TAskWindow=class(TaskStatus)
    exp1,exp2,exp3,exp4:TVariable;
    constructor create(prev,eld:TStatement);
    procedure exec;override;
    destructor destroy;override;
   end;


constructor TAskWindow.create(prev,eld:TStatement);
begin
   inherited create(prev,eld);
   exp1:=nvariable;
   check(',',IDH_WINDOW);
   exp2:=nvariable;
   check(',',IDH_WINDOW);
   exp3:=nvariable;
   check(',',IDH_WINDOW);
   exp4:=nvariable;
end;

procedure TAskWindow.exec;
begin
  StatusInit;
  WaitReady;
  with MyGraphSys do
    begin
      exp1.assignX(left);
      exp2.assignX(right);
      exp3.assignX(bottom);
      exp4.assignX(top)  ;
    end;  
end;

destructor TAskWindow.destroy;
begin
    exp1.free;
    exp2.free;
    exp3.free;
    exp4.free;
    inherited destroy;
end;

type
   TAskViewport=class(TAskWindow)
    procedure exec;override;
   end;

procedure TAskViewPort.exec;
begin
  StatusInit;
  WaitReady;
  with MyGraphSys do
    begin
      exp1.assignX(VPleft);
      exp2.assignX(VPright);
      exp3.assignX(VPbottom);
      exp4.assignX(VPtop)  ;
    end;  
end;

type
   TAskDeviceWindow=class(TAskWindow)
    procedure exec;override;
   end;

procedure TAskDeviceWindow.exec;
begin
  StatusInit;
  WaitReady;
  with MyGraphSys do
    begin
      exp1.assignX(DWleft);
      exp2.assignX(DWright);
      exp3.assignX(DWbottom);
      exp4.assignX(DWtop)  ;
    end;
end;



type
   TAskDeviceViewport=class(TAskWindow)
    procedure exec;override;
   end;

procedure TAskDeviceViewport.exec;
var
   l,r,b,t:double;
begin
   StatusInit;
   WaitReady;
   MyGraphSys.AskDeviceViewPort(l,r,b,t);
      exp1.assignX(l);
      exp2.assignX(r);
      exp3.assignX(b);
      exp4.assignX(t);
end;


type
    getfunction=function:integer;

function getmaxlinestyle:integer;
begin
     getmaxlinestyle:=MaxLineStyle
end;

function getmaxpointstyle:integer;
begin
     getmaxpointstyle:=MaxPointStyle
end;

type
  TAsk=class(TaskStatus)
    exp:TVariable;
    get:getfunction;
    constructor create(prev,eld:TStatement; g:getfunction);
    procedure exec;override;
    destructor destroy;override;
   end;

constructor TAsk.create(prev,eld:TStatement; g:getfunction);
begin
   inherited create(prev,eld);
   exp:=nvariable;
   get:=g;
end;

procedure TAsk.exec;
begin
    StatusInit;
    WaitReady;
    exp.assignLongint(get)
end;

destructor TAsk.destroy;
begin
    exp.free;
    inherited destroy;
end;

function getlinecolor:integer;
begin
    getlinecolor:=MyGraphSys.linecolor;
end;

function getlinestyle:integer;
begin
    getlinestyle:=Integer(MyGraphSys.PenStyle) + 1;
end;

function getlinewidth:integer;
begin
    getlinewidth:=MyGraphSys.linewidth;
end;

function getpointcolor:integer;
begin
    getpointcolor:=pointcolor;
end;

function getpointstyle:integer;
begin
    getpointstyle:=pointstyle;
end;

function getareacolor:integer;
begin
    getareacolor:=MyGraphSys.areacolor;
end;

function gettextcolor:integer;
begin
    gettextcolor:=MyGraphSys.textcolor;
end;

function getmaxcolor:integer;
begin
    if mypalette.PaletteDisabled then
      result:=$ffffff
    else
      result:=GraphSys.maxcolor;
end;

function getaxiscolor:integer;
begin
    getaxiscolor:=GraphSys.axescolor;
end;

function getMaxPointDevice:integer;
begin
  result:=1
end;

function getMaxMultiPointDevice:integer;
begin
  result:=1
end;


function getMaxChoiceDevice:integer;
begin
  result:=1
end;

const MaxValueDEvice=20;

function getMaxValueDevice:integer;
begin
  result:=MaxValueDevice
end;

function getAreaStyleIndex:integer;
begin
  result:=MyGraphSys.AreaStyleIndex;
end;

type
  TAskTextHeight=class(TAsk)
    procedure exec;override;
  end;

procedure TAskTextHeight.exec;
begin
   StatusInit;
   WaitReady;
   exp.assignX(MyGraphSys.AskTextHeight);
end;

type
  TAskTextAngle=class(TAsk)
    procedure exec;override;
  end;

procedure TAskTextAngle.exec;
var
   x:double;
begin
   StatusInit;
   WaitReady;
   x:=MyGraphSys.TextAngle;
   if not Punit.AngleDegrees then x:=x/180.0*PI;
   exp.assignX(x);
end;


type
  TAskPixelSize=class(TaskStatus)
    exp1,exp2,exp3,exp4:TPrincipal;
    var1,var2:TVariable;
    constructor create(prev,eld:TStatement);
    procedure exec;override;
    destructor destroy;override;
   end;

constructor TAskPixelSize.create(prev,eld:TStatement);
begin
   inherited create(prev,eld);
   if token='(' then
      begin
        check('(',IDH_PIXEL_SIZE);
        exp1:=NExpression;
        check(',',IDH_PIXEL_SIZE);
        exp2:=NExpression;
        check(';',IDH_PIXEL_SIZE);
        exp3:=NExpression;
        check(',',IDH_PIXEL_SIZE);
        exp4:=NExpression;
        check(')',IDH_PIXEL_SIZE);
      end;
   var1:=NVariable;
   check(',',IDH_PIXEL_SIZE);
   var2:=NVariable;
end;

destructor TAskPixelSize.destroy;
begin
   exp1.free;
   exp2.free;
   exp3.free;
   exp4.free;
   var1.free;
   var2.free;
   inherited destroy;
end;

procedure TAskPixelSize.exec;

const eps=1e-15;
var
   n1,n2,n3,n4,t:double;
   //x1,x2,y1,y2:double;
   x1,x2,y1,y2:integer;
begin
   StatusInit;
   WaitReady;
   if exp1=nil then
         begin
           var1.assignX(MyGraphSys.GWidth);
           var2.assignX(MyGraphSys.GHeight)
         end
   else
      begin
        n1:=exp1.evalX;
        n2:=exp2.evalX;
        n3:=exp3.evalX;
        n4:=exp4.evalX;
        with MyGraphSys do
        if (n1-n3)*(right-left)>0 then begin t:=n3; n3:=n1; n1:=t end;    //2011.11.6
        with MyGraphSys do
        if (n2-n4)*(top-bottom)<0 then begin t:=n4; n4:=n2; n2:=t end;    //2011.11.6


        x1:=ceil(MyGraphSys.DeviceX(n1)-eps);
        x2:=floor(MyGraphSys.DeviceX(n3)+eps);
        y1:=ceil(MyGraphSys.DeviceY(n2)-eps);
        y2:=floor(MyGraphSys.DeviceY(n4)+eps);
        var1.assignX(x2-x1+1);
        var2.assignX(y2-y1+1)
        (*
        if MyGraphSys is TScreenGraphSys then
          begin
            x1:=ceil((n1-left)*TScreenGraphSys(MyGraphSys).HMulti-eps);
            x2:=floor((n3-left)*TScreenGraphSys(MyGraphSys).HMulti+eps);
            y1:=ceil((top-n2)*TScreenGraphSys(MyGraphSys).VMulti-eps);
            y2:=floor((top-n4)*TScreenGraphSys(MyGraphSys).VMulti+eps);
            var1.assignX(x2-x1+1);
            var2.assignX(y2-y1+1)
          end
        else
          begin
            var1.assignX(0);
            var2.assignX(0)
          end
        *)
     end

        ;
end;

type
  TAskPixelValue=class(TaskStatus)
    exp1,exp2:TPrincipal;
    var1:TVariable;
    constructor create(prev,eld:TStatement);
    procedure exec;override;
    destructor destroy;override;
   end;

constructor TAskPixelValue.create(prev,eld:TStatement);
begin
   inherited create(prev,eld);
   check('(',IDH_PIXEL);
   exp1:=NExpression;
   check(',',IDH_PIXEL);
   exp2:=NExpression;
   check(')',IDH_PIXEL);
   var1:=NVariable;
end;

destructor TAskPixelValue.destroy;
begin
   exp1.free;
   exp2.free;
   var1.free;
   inherited destroy;
end;

procedure TAskPixelValue.exec;
begin
  StatusInit;
  WaitReady;
  var1.assignLongint(MyGraphSys.ColorIndexOf(MyGraphSys.DeviceX(exp1.evalX),
                                            MyGraphSys.DeviceY(exp2.evalX)))
end;

type
  TAskDeviceSize=class(TaskStatus)
    exp1,exp2:TVariable;
    exp3:TStrVari;
    constructor create(prev,eld:TStatement);
    procedure exec;override;
    destructor destroy;override;
   end;


constructor TAskDeviceSize.create(prev,eld:TStatement);
begin
   inherited create(prev,eld);
   exp1:=nvariable;
   check(',',IDH_GRAPHICS);
   exp2:=nvariable;
   check(',',IDH_GRAPHICS);
   exp3:=Strvari;
end;

procedure TAskDeviceSize.exec;
var
   w,h:double;
   s:string;
begin
      StatusInit;
      WaitReady;
      MyGraphSys.AskDeviceSize(w,h,s);
      exp1.assignX(w);
      exp2.assignX(h);
      exp3.substS(s) ;
end;

destructor TAskDeviceSize.destroy;
begin
    exp1.free;
    exp2.free;
    exp3.free;
    inherited destroy;
end;

type
  TAskBitmapSize=class(TaskStatus)
    exp1,exp2:TVariable;
    constructor create(prev,eld:TStatement);
    procedure exec;override;
    destructor destroy;override;
   end;


constructor TAskBitmapSize.create(prev,eld:TStatement);
begin
   inherited create(prev,eld);
   exp1:=nvariable;
   check(',',IDH_GRAPHICS);
   exp2:=nvariable;
end;

procedure TAskBitmapSize.exec;
begin
      StatusInit;
      WaitReady;
      exp1.assignX(MyGraphSys.GWidth);
      exp2.assignX(MyGraphSys.GHeight)
end;

destructor TAskBitmapSize.destroy;
begin
    exp1.free;
    exp2.free;
    inherited destroy;
end;

type
  TTAskPixelArray=class(TResetBoolean)
     x1,y1:longint;
     p:TArray;
     ptext:pansistring;
    constructor create(var s:boolean; x10,y10:longint; p0:TArray; var text0:ansistring);
    procedure ExecCore;override;
  end;

constructor TTAskPixelArray.create(var s:boolean; x10,y10:longint; p0:TArray; var text0:ansistring);
 begin
   inherited create(s);
   x1:=x10; y1:=y10;
   p:=p0;
   ptext:=@text0;
end;

procedure TTAskPixelArray.ExecCore;
var
   c:integer;
   i,j:longint;
begin
              for i:=0 to p.size[1]-1 do
                 for j:=0 to p.size[2]-1 do
                     begin
                         c:=MyGraphSys.ColorIndexOf(x1+i,y1+j);
                         with p do ItemAssignLongint(i*size[2]+j,c);
                         if c=-1 then ptext^:='PRESENT';
                     end;
end;


type
  TAskPixelArray=class(TaskStatus)
    exp1,exp2:TPrincipal;
    mat1:TMatrix;
    exp3:TStrVari;
    constructor create(prev,eld:TStatement);
    procedure exec;override;
    destructor destroy;override;
   end;

constructor TAskPixelArray.create(prev,eld:TStatement);
begin
   inherited create(prev,eld);
   check('(',IDH_PIXEL);
   exp1:=NExpression;
   check(',',IDH_PIXEL);
   exp2:=NExpression;
   check(')',IDH_PIXEL);
   mat1:=NMatrix;
   if mat1.idr.dim<>2 then seterrDimension(IDH_PIXEL);
   if test(',') then
         exp3:=StrVari;
end;

destructor TAskPixelArray.destroy;
begin
   exp1.free;
   exp2.free;
   mat1.free;
   exp3.free;
   inherited destroy;
end;

procedure TAskPixelArray.exec;
var
   x1,y1:longint;
   p:TArray;
   c:integer;
   text:ansistring;
   s:boolean;
begin
       StatusInit;
       WaitReady;
       x1:=MyGraphSys.DeviceX(exp1.evalX);
       y1:=MyGraphSys.DeviceY(exp2.evalX);
       TVar(p):=mat1.point;
       text:='ABSENT';
       if p<>nil then
          begin
             addQueue(TTAskPixelArray.create(s,x1,y1,p,text));
             while s do (TThread.CurrentThread).Yield  ;
             if exp3<>nil then
                exp3.substS(text);
          end
end;

type
  TAskTextJustify=class(TaskStatus)
    exp1,exp2:TStrVari;
    constructor create(prev,eld:TStatement);
    procedure exec;override;
    destructor destroy;override;
   end;


constructor TAskTextJustify.create(prev,eld:TStatement);
begin
   inherited create(prev,eld);
   exp1:=StrVari;
   check(',',IDH_TEXT);
   exp2:=StrVari;
end;

procedure TAskTextJustify.exec;
begin
  StatusInit;
  WaitReady;
  with MyGraphSys do
    begin
      exp1.substS(HJustification[HJustify]);
      exp2.substS(VJustification[VJustify])
    end;
end;

destructor TAskTextJustify.destroy;
begin
    exp1.free;
    exp2.free;
    inherited destroy;
end;

type
    TAskTextWidth=class(TaskStatus)
       Text:TPrincipal;
       Width:TVariable;
       constructor create(prev,eld:TStatement);
       destructor destroy;override;
       procedure exec;override;
      end;

constructor TAskTextWidth.create(prev,eld:TStatement);
begin
    inherited create(prev,eld);
    Check('(',IDH_COLOR);
    Text:=SExpression;
    check(')',IDH_COLOR);
    Width:=NVariable;
end;

destructor TAskTextWidth.destroy;
begin
    Text.free;
    Width.free;
    inherited destroy
end;

procedure TAskTextWidth.exec;           //2013.12.21
var
   s:string;
   x:double;
begin
   StatusInit;
   WaitReady;
   with MyGraphSys do
     begin
       x:=VirtualX(textwidth(Text.evalS))-VirtualX(0);
       //if TextProblemCoordinate then
         if not TextPhysicalCoordinate then                                 // ver.8.1.3
          x:=x*((VirtualY(0)-VirtualY(1))/(VirtualX(1)-VirtualX(0))) ;
     end;
   Width.assignX(x);
end;





type
    TAskColorMix=class(TaskStatus)
       ColorIndex:TPrincipal;
       Red,Green,Blue:TVariable;
       constructor create(prev,eld:TStatement);
       destructor destroy;override;
       procedure exec;override;
      end;

constructor TAskColorMix.create(prev,eld:TStatement);
begin
    inherited create(prev,eld);
    Check('(',IDH_COLOR);
    ColorIndex:=nexpression;
    check(')',IDH_COLOR);
    Red:=NVariable;
    check(',',IDH_COLOR);
    Green:=NVariable;
    check(',',IDH_COLOR);
    Blue:=NVariable;
end;

destructor TAskColorMix.destroy;
begin
    ColorIndex.free;
    Red.free;
    Green.free;
    Blue.free;
    inherited destroy
end;

procedure AskColorMix(cc:integer;var r,g,b:byte);
var
   col:TColor;
begin
   col:=MyPalette[cc];
   b:=(col and $ff0000) div $10000;
   g:=(col and $00ff00) div $100;
   r:=col and $0000ff;
end;

procedure TAskColorMix.exec;
var
   cc:longint;
   r,g,b:byte;
begin
     StatusInit;
     WaitReady;
     cc:=ColorIndex.evalLongint;
     if (cc<0) or (cc>maxcolor) and not MyPalette.paletteDisabled then
       begin
          red.assignLongInt(0);
          green.assignLongint(0);
          blue.assignLongint(0);
          if status<>nil then
             status.assignLongint(11086);
       end
     else
       begin
         askColorMix(cc,r,g,b);
         red.assignX(r/255);
         green.assignX(g/255);
         blue.assignX(b/255);
       end;
end;

type
  TAskClip=class(TaskStatus)
    exp:TStrVari;
    constructor create(prev,eld:TStatement);
    procedure exec;override;
    destructor destroy;override;
   end;


constructor TAskClip.create(prev,eld:TStatement);
begin
   inherited create(prev,eld);
   exp:=StrVari;
end;

procedure TAskClip.exec;
var
   s:string;
begin
    StatusInit;
    WaitReady;
    if MyGraphSys.clip then s:='ON' else s:='OFF';
    exp.substS(s);
end;

destructor TAskClip.destroy;
begin
    exp.free;
    inherited destroy;
end;

type
  TAskAreaStyle=class(TAskClip)
      procedure exec;override;
  end;

procedure TAskAreaStyle.exec;
var
   s:string;
begin
    StatusInit;
    WaitReady;
    case MyGraphSys.AreaStyle of
      asSolid: s:='SOLID';
      asHollow:s:='HOLLOW';
      asHATCH: s:='HATCH';
    end;
    exp.substS(s);
end;

type
  TAskColorMode=class(TAskClip)
      procedure exec;override;
  end;

procedure TAskColorMode.exec;
var
   s:string;
begin
    StatusInit;
    WaitReady;
    exp.substS(MyGraphSys.AskColorMode);
end;

type
  TAskBeamMode=class(TAskClip)
      procedure exec;override;
  end;

procedure TAskBeamMode.exec;
var
   s:string;
begin
    StatusInit;
    WaitReady;
    exp.substS(AskBeamMode);
end;

type
  TAskTextBack=class(TAskClip)
      procedure exec;override;
  end;

procedure TAskTextBack.exec;
var
   s:string;
begin
    StatusInit;
    WaitReady;
    with MyGraphSys do
    if iBKmode=TRANSPARENT  then  s:='TRANSPARENT'
    else if iBKmode=OPAQUE then s:='OPAQUE';
    exp.substS(s);
end;

type
  TAskTextFont=class(TaskStatus)
    exp1:TStrVari;
    exp2:TVariable;
    constructor create(prev,eld:TStatement);
    procedure exec;override;
    destructor destroy;override;
   end;


constructor TAskTextFont.create(prev,eld:TStatement);
begin
   inherited create(prev,eld);
   exp1:=StrVari;
   check(',',IDH_TEXT);
   exp2:=NVariable;
end;

procedure TAskTextFont.exec;
var
   name:AnsiString;
   size:integer;
begin
  StatusInit;
  WaitReady;
  MyGraphSys.AskTextFont(name,size);
  exp1.substS(name);
  exp2.assignLongint(size)
end;

destructor TAskTextFont.destroy;
begin
    exp1.free;
    exp2.free;
    inherited destroy;
end;



function  ASKst(prev,eld:TStatement):TAskStatus;
begin
    ASKst:=nil;
    if token='WINDOW' then
       begin
            gettoken;
            ASKst:=TAskWindow.create(prev,eld);
       end
    else if token='VIEWPORT' then
       begin
            gettoken;
            ASKst:=TAskViewport.create(prev,eld);
       end
    else if  (token='LINE') then
        begin
            gettoken;
            if  (token='COLOR')  then
                begin
                    gettoken;
                    ASKst:=TAsk.create(prev,eld,getlinecolor)
                end
            else if(token='STYLE') then
               begin
                    gettoken;
                    ASKst:=TAsk.create(prev,eld,getlinestyle)
               end
            else if(token='WIDTH') then
               begin
                    gettoken;
                    ASKst:=TAsk.create(prev,eld,getlinewidth)
               end
        end
    else if (token='POINT') then
        begin
           gettoken;
           if (token='COLOR')  then
                 begin
                     gettoken;
                     askst:=TAsk.create(prev,eld,getpointcolor)
                 end
          else if(token='STYLE') then
               begin
                    gettoken;
                    ASKst:=TAsk.create(prev,eld,getpointstyle)
               end
        end
    else if (token='AREA') then
        begin
           gettoken;
           if (token='COLOR')  then
               begin
                  gettoken;
                  ASKst:=TAsk.create(prev,eld,getareacolor)
               end
           else if(token='STYLE') then
               begin
                  gettoken;
                  if token='INDEX' then
                     begin
                       gettoken;
                       ASKst:=TAsk.create(prev,eld,getAreaStyleIndex);
                     end
                  else
                     ASKst:=TAskAreaStyle.create(prev,eld)
                end
        end
    else if (token='TEXT') then
        begin
           gettoken;
           if (token='COLOR')  then
                 begin
                     gettoken;
                     ASKst:=TASK.create(prev,eld,gettextcolor)
                 end
           else if (token='HEIGHT')  then
                 begin
                     gettoken;
                     ASKst:=TASKTextHeight.create(prev,eld,nil)
                 end
           else if (token='ANGLE')  then
                 begin
                     gettoken;
                     confirmedDegrees;
                     ASKst:=TASKTextAngle.create(prev,eld,nil);
                 end
           else if(token='JUSTIFY') then
               begin
                    gettoken;
                    ASKst:=TAskTextJustify.create(prev,eld)
               end
           else if(token='WIDTH') then
               begin
                    gettoken;
                    ASKst:=TAskTextWidth.create(prev,eld)
               end
            else if(token='BACKGROUND') then
               begin
                    gettoken;
                    ASKst:=TAskTextBack.create(prev,eld)
               end
           else if(token='FONT') then
               begin
                    gettoken;
                    ASKst:=TAskTextFont.create(prev,eld)
               end
       end
    else if token='MAX' then
       begin
            gettoken;
            if token='POINT' then
               begin
                   gettoken;
                   if token='STYLE' then
                     begin
                       gettoken;
                       ASKst:=TAsk.create(prev,eld,getmaxpointstyle);
                     end
                   else if token='DEVICE' then
                     begin
                       gettoken;
                       ASKst:=TAsk.create(prev,eld,getmaxpointdevice);
                     end
               end
            else if token='LINE' then
               begin
                   gettoken;
                   checktoken('STYLE',IDH_LINE);
                   ASKst:=TAsk.create(prev,eld,getmaxlinestyle);
               end
            else if token='COLOR' then
               begin
                   gettoken;
                   ASKst:=TAsk.create(prev,eld,getmaxcolor);
               end
            else if token='MULTIPOINT' then
               begin
                  gettoken;
                  CheckToken('DEVICE',IDH_LOCATE);
                  ASKst:=TAsk.create(prev,eld,getmaxMultipointdevice);
               end
            else if token='CHOICE' then
               begin
                  gettoken;
                  CheckToken('DEVICE',IDH_LOCATE);
                  ASKst:=TAsk.create(prev,eld,getmaxChoiceDevice);
               end
            else if token='VALUE' then
               begin
                  gettoken;
                  CheckToken('DEVICE',IDH_LOCATE);
                  ASKst:=TAsk.create(prev,eld,getmaxValueDevice);
               end
       end
    else if token='PIXEL' then
       begin
            gettoken;
            if token='SIZE' then
               begin
                   gettoken;
                   ASKst:=TAskPixelSize.create(prev,eld);
               end
            else if token='VALUE' then
               begin
                   gettoken;
                   ASKst:=TAskPixelValue.create(prev,eld);
               end
            else if token='ARRAY' then
               begin
                   gettoken;
                   ASKst:=TAskPixelArray.create(prev,eld);
               end;
       end
    else if token='DEVICE' then
       begin
            gettoken;
            if token='VIEWPORT' then
               begin
                   gettoken;
                   ASKst:=TAskDeviceViewport.create(prev,eld);
               end
            else if token='WINDOW' then
               begin
                   gettoken;
                   ASKst:=TAskDeviceWindow.create(prev,eld);
               end
            else if token='SIZE' then
               begin
                   gettoken;
                   ASKst:=TAskDeviceSize.create(prev,eld);
               end
       end
    else if token='CLIP' then
       begin
            gettoken;
            ASKst:=TAskClip.create(prev,eld);
       end
    else if (token='AXIS') then
        begin
           gettoken;
           if (token='COLOR')  then
                 begin
                     gettoken;
                     askst:=TAsk.create(prev,eld,getaxiscolor)
                 end
        end
    else if token='COLOR' then
       begin
            gettoken;
            if token='MIX' then
               begin
                   gettoken;
                   ASKst:=TAskColorMix.create(prev,eld);
               end
            else if token='MODE' then
               begin
                   gettoken;
                   ASKst:=TAskColorMode.create(prev,eld);
               end
       end
    else if token='PIXELS' then
       begin
            gettoken;
            ASKst:=TAskBitMapSize.create(prev,eld);
       end
    else if token='BITMAP' then
       begin
            gettoken;
            if token='SIZE' then
               begin
                   gettoken;
                   ASKst:=TAskBitMapSize.create(prev,eld);
               end
       end
    else if token='BEAM' then
       begin
            gettoken;
            if token='MODE' then
               begin
                   gettoken;
                   ASKst:=TAskBeamMode.create(prev,eld);
               end
       end
    else
       seterrIllegal(token,0);

    if token='STATUS' then
       begin
          gettoken;
          result.status:=nVariable;
       end;
end;

(*
function newpairlist(n:integer):PPointpairlist;
begin
   GetMem(pointer(result),sizeof(integer)+sizeof(pointpair)*n);
   result^.count:=n
end;


procedure disposepairlist(p:PPointpairlist);
begin
   if p<>nil then FreeMem(pointer(p),sizeof(integer)+sizeof(pointpair)*p^.count)
end;
*)

{*************}
{PLOT or GRAPH}
{*************}


constructor TPutMark0.create(a0,b0:integer);
begin
   inherited create;
   a:=a0; b:=b0;
   PointStyle:=graphic.PointStyle;
   PointColor:=graphic.PointColor;
end;

procedure TPutmark0.execute;
begin
    MyGraphSys.putMark0(a,b,pointstyle,pointcolor);
    RepaintRequest:=true;
end;

procedure putMark(x,y:double);
var
  i,j:integer;
begin
    with MyGraphSys do
    if ConvToDeviceX(x,i) and ConvToDeviceY(y,j) then    //2009.6.22
      AddQueue(TPutMark0.create(i,j));
end;

type TPlotTo0=Class(TGraphCommand)
  a,b:integer;
  constructor create(a0,b0:integer);
  procedure execute;override;
 end;

 constructor TPlotTo0.create(a0,b0:integer);
begin
   inherited create;
   a:=a0; b:=b0;
end;

procedure TPlotTo0.execute;
begin
    MyGraphSys.PlotTo0(a,b);
    RepaintRequest:=true;
end;

procedure PlotTo(x,y:double);
var
  i,j:integer;
begin
    with MyGraphSys do
    if ConvToDeviceX(x,i) and ConvToDeviceY(y,j) then
      begin
        AddQueue(TPlotTo0.create(i,j));
        graphic.beam:=true;      //MyGraphSys.beam:=true はMyGraphSys.PlotTo0で実行される。
      end;
end;



var
   x0,y0:double;

procedure ProjectivePlotTo(const x1,y1:double);
var
  a,b,s,t,u,x,y:double;
label
  Retry1,Retry2;
begin
  with CurrentTransform do
    begin
      WaitReady;
      if graphic.beam=true then
        begin
          a:=x1-x0;
          b:=y1-y0;
          s:=ox*a+oy*b;
          t:=-(ox*x0+oy*y0+oo);
          if s<>0 then
            begin
               t:=t/s;

               if (t>0 - 1e-14) and (t<=1 + 1e-14) then
                 begin

                   u:=t;
                 Retry1:
                   u:=u-0.0001;
                   if u>0 then
                     begin
                       x:=a*u+x0;
                       y:=b*u+y0;
                       if transform(x,y) then
                          graphic.PlotTo(x,y)
                       else
                          GOTO Retry1;
                     end;

                   BeamOff;

                   u:=1-t;
                 Retry2:
                   u:=u-0.0001;
                   if u>0 then
                     begin
                       x:=a*(1-u)+x0;
                       y:=b*(1-u)+y0;
                       if transform(x,y) then
                          graphic.PlotTo(x,y)
                       else
                          GOTO Retry2;
                     end;
                 end;
            end;
        end;

      x:=x1;
      y:=y1;
      if transform(x,y) then
         graphic.PlotTo(x,y);
      x0:=x1;
      y0:=y1;
      BeamOn;
    end;
end;



function NormalSegment(const x0,y0,x1,y1:double):boolean;
var
  a,b,s,t:double;
begin
  result:=true;
  if CurrentTransform=nil then exit;
  with CurrentTransform do
    begin
      a:=x1-x0;
      b:=y1-y0;
      s:=ox*a+oy*b;
      t:=-(ox*x0+oy*y0+oo);
      if s<>0 then
        begin
           t:=t/s;
           if (t>=0) and (t<=1) then
              result:=false;
        end
      else if t=0 then
        result:=false;  
    end
end;



type
  TPlotItem=class
     exp1,exp2:TPrincipal;
     next:TPlotItem;
     PLOTstm:boolean;
    constructor create(plot:boolean; prev:TPlotItem);
    procedure PutMark;
    procedure PlotTo;
    function eval(var x,y:double):boolean;
    destructor Destroy;override;
   end;

constructor TPlotItem.create(plot:boolean; prev:TPlotItem);   //2011.3.5
begin
   inherited create;
   PLOTstm:=plot;
   exp1:=NExpression;
   if (programunit.Arithmetic<>PrecisionComplex)
      or (prev=nil) and (token=',')
      or (prev<>nil) and (prev.exp2<>nil) then
      begin
        check(',',IDH_GRAPHICS);
        exp2:=NExpression;
      end;
   if (token=';') and (nextTokenSpec<>tail) and (NextToken<>'ELSE') then
   begin
      gettoken;
      next:=TPlotItem.create(PLOTstm, self);
   end;
end;



destructor TPlotItem.Destroy;
begin
   next.free;
   exp2.free;
   exp1.free;
   inherited destroy;
end;


procedure TPlotItem.PutMark;
var
  x,y:double;
begin
    if self=nil then exit;
    if eval(x,y) then
      begin
        graphic.putMark(x,y);
      end;
    next.PutMark;

end;






procedure TPlotItem.PlotTo;
var
  x,y:double;
begin
    if self=nil then exit;
    if not PLOTstm or (CurrentTransform=nil) or CurrentTransform.IsAffine then
       begin
         if eval(x,y) then
           begin
             graphic.PlotTo(x,y)
           end
       end
     else
       begin
         ProjectivePlotTo(exp1.evalX,exp2.evalX);
       end;

    next.PlotTo
end;

function TPlotItem.eval(var x,y:double):boolean;    //2011.3.5
var
   z:complex;
begin
  if exp2<>nil then
    begin
      x:=exp1.evalX;
      y:=exp2.evalX;
    end
  else
    begin
      exp1.evalC(z);
      x:=z.x;
      y:=z.y;
    end;
  result:=not PLOTstm or currenttransform.transform(x,y);
end;

type
   TPlotPoints=class(TStatement)
       Items:TPlotItem;
       GRAPHst:Boolean;
          cont:Boolean;
     constructor create(prev,eld:TStatement; plot:boolean);
     constructor createnul(prev,eld:TStatement);  //PLOT LINES文で使う
     procedure exec;override;
     destructor destroy;override;
   end;

   TPlotLines=class(TPlotPoints)
    constructor create(prev,eld:TStatement; plot:boolean);
    procedure exec;override;
  end;

constructor TPlotPoints.create(prev,eld:TStatement; plot:boolean);
begin
   inherited create(prev,eld);
   Items:=TPlotItem.create(plot, nil);
end;

constructor TPlotLines.create(prev,eld:TStatement; plot:boolean);
begin
   inherited create(prev,eld,plot);
   if not plot then GRAPHst:=true;
   if plot and (token=';') then
      begin
        cont:=true;
        gettoken;
      end;
end;

constructor TPlotPoints.createnul(prev,eld:TStatement);
begin
    inherited Create(prev,eld);
    GRAPHst:=false;
    cont:=false;
end;


destructor TPlotPoints.destroy;
begin
  Items.free;
  inherited destroy
end;

procedure TPlotPoints.exec;
begin
   if graphsys.BeamMode=bmRigorous then BeamOff;
   Items.PutMark;
   RepaintRequest:=true;
end;

procedure TPlotLines.exec;
begin
  if GRAPHst then BeamOff;
  Items.PlotTo;
  if not cont then
     BeamOff;

end;


type
   TPointArray=array[ 0..1023] of TPoint;
   PPointArray=^TPointArray;

type
   TCoordinate=Packed Record
               x,y:double;
           end;
   TCoordinateArray=Packed Array[0..1023] of TCoordinate;
   PCoordinateArray=^TCoordinateArray;

function TestNormalSegments(p:PCoordinateArray; count:integer):boolean;
var
   i:integer;
begin
   result:=true;
   for i:=0 to count-1 do
       result:=result and NormalSegment(p^[i].x, p^[i].y,
                           p^[(i+1)mod count].x, p^[(i+1)mod count].y);
end;

type
   TPlotOrg=class(TStatement)
       pointpairs:TObjectList;
       limit:TPrincipal;
       mat,mat2:TMatrix;
       GRAPHst :boolean;
     constructor create(prev,eld:TStatement; plot:boolean);
     constructor createmat(prev,eld:TStatement; plot:boolean);
     destructor destroy;override;
     function evalLimit:integer;
     function MakeList(p:PPointArray; lim:integer):integer; //結果は点の個数
     procedure MakeCoordinateList(p:PCoordinateArray; lim:integer); //変換前の座標
     function ReMakeList(p:PCoordinateArray; q:PPointArray; count:integer):integer; //結果は点の個数
     procedure PlotProjectiveLine(lim:integer);
   end;

   TMatPlotPoints=class(TPlotOrg)
     procedure exec;override;
   end;

   TMatPlotLines=class(TPlotOrg)
       // cont:boolean;
     constructor create(prev,eld:TStatement; plot:boolean);
     //constructor createnul(prev,eld:TStatement);
     procedure exec;override;
   end;

   TPlotArea=class(TPlotOrg)
     constructor create(prev,eld:TStatement; plot:boolean);
     procedure exec;override;
     procedure ProjectivePolygon(lim:integer);
   end;

   TPlotBezier=class(TStatement)
       expx: array[0..3]of TPrincipal;
       expy: array[0..3]of TPrincipal;
       GRAPHst :boolean;
     constructor create(prev,eld:TStatement; plot:boolean);
     procedure exec;override;
     destructor destroy;override;
   end;

   function PLOTst(prev,eld:TStatement):TStatement;
   var
      plot:boolean;
   begin
      PLOTst:=nil;
      GraphMode:=true;
      plot:=(prevToken='PLOT');
      //ver. 8.1.3.3
      if token='POINTS' then
           begin
               gettoken;
               checktoken(':',IDH_GRAPHICS);
               PLOTst:=TPlotPoints.create(prev,eld,plot)
           end
      else if (token='LINES') then
         begin
          gettoken;
          if ( ((tokenspec=tail) or (token='ELSE'))
              or ((token=':') and (nexttoken='') ))
              and plot then
              PLOTst:=TPlotLines.createnul(prev,eld)
          else
             begin
              checktoken(':',IDH_LINE);
              PLOTst:=TPlotLines.create(prev,eld,plot)
             end
         end
      else if token='AREA' then
         begin
             gettoken;
             checktoken(':',IDH_AREA);
             PLOTst:=TPLotArea.create(prev,eld,plot)
         end
      else if (token='TEXT') or (token='LABEL') or plot and (token='LETTERS') then
         begin
             PLOTst:=PlotTextst(prev,eld)
         end
      else if token='BEZIER' then
         begin
             gettoken;
             checktoken(':',IDH_AREA);
             PLOTst:=TPLotBezier.create(prev,eld,plot)
         end
      else if plot and not DisableAbbreviatedPLOT
           and ((tokenspec=tail) or (token='ELSE'))  then
              PLOTst:=TPlotLines.createnul(prev,eld)
      else if plot and not DisableAbbreviatedPLOT
           and (nexttoken <>':') then
          begin
            StatusMes.add(token+s_CantBelongHere);
            PLOTst:=TPlotLines.create(prev,eld,plot)
          end
      else
         seterrIllegal(token,IDH_GRAPHICS);
   end;

(*
constructor TPlotOrg.create(prev,eld:TStatement; plot:boolean);
var
   exp:TPrincipal;
Label
   L1;
begin
    inherited create(prev,eld);
    GRAPHst:=not plot;
    pointpairs:=TObjectList.create(4);
    repeat
        exp:=nexpression;
        pointpairs.add(exp);
        check(',',IDH_GRAPHICS);
        exp:=nexpression;
        pointpairs.add(exp);
        if (token=';') and (nexttokenspec<>tail) and (nexttoken<>'ELSE') then
            gettoken
        else
            goto L1;
   until false;
 L1:
end;

constructor TPlotOrg.createmat(prev,eld:TStatement; plot:boolean);
begin
    graphmode:=true;
    inherited create(prev,eld);
    GRAPHst:=not plot;
    gettoken; {POINTS, etc.}
    if test(',') and (token='LIMIT') then
       begin
          gettoken;
          limit:=NExpression;
          {if limit=nil then fail}
       end;
    checktoken(':',IDH_MAT_PLOT);
    try
       mat:=Nmatrix;      {nilでも可}
       if (mat<>nil) and (mat.idr.dim=1) then
           begin
             check(',',IDH_MAT_PLOT);
             mat2:=Nmatrix;
           end;
    except
       on ERecompile do raise;
       else;
    end;
    if (mat<>nil) and (mat.idr.dim=1) and (mat2<>nil) and (mat2.idr.dim=1)
      or (mat<>nil) and (mat.idr.dim=2) then
    else
         begin seterrdimension(IDH_MAT);{done;fail} end;
end;
*)
constructor TPlotOrg.create(prev,eld:TStatement; plot:boolean);     //2011.3.5
var
   exp:TPrincipal;
   flag:boolean;
Label
   L1;
begin
    inherited create(prev,eld);
    flag:=false;
    GRAPHst:=not plot;
    pointpairs:=TObjectList.create(4);
    repeat
        exp:=nexpression;
        pointpairs.add(exp);
        if ((programunit.Arithmetic<>PrecisionComplex) or (token=',')) and not flag then
           begin
              check(',',IDH_GRAPHICS);
              exp:=nexpression;
           end
        else
           begin
              exp:=nil;
              flag:=true;
           end;
        pointpairs.add(exp);
        if (token=';') and (nexttokenspec<>tail) and (nexttoken<>'ELSE') then
            gettoken
        else
            goto L1;
   until false;
 L1:
end;



constructor TPlotOrg.createmat(prev,eld:TStatement; plot:boolean); //2011.3.5
begin
    graphmode:=true;
    inherited create(prev,eld);
    GRAPHst:=not plot;
    gettoken; {POINTS, etc.}
    if test(',') and (token='LIMIT') then
       begin
          gettoken;
          limit:=NExpression;
          {if limit=nil then fail}
       end;
    checktoken(':',IDH_MAT_PLOT);
    try
       mat:=Nmatrix;      {nilでも可}
       if (mat<>nil) and (mat.idr.dim=1)
          and ((programunit.Arithmetic<>precisionComplex) or (token=',')) then
           begin
             check(',',IDH_MAT_PLOT);
             mat2:=Nmatrix;
           end;
    except
       on ERecompile do raise;
       else;
    end;
    if (mat<>nil) and (mat.idr.dim=1) and (mat2<>nil) and (mat2.idr.dim=1)
      or (mat<>nil) and (mat.idr.dim=1) and (programunit.Arithmetic=precisionComplex)
      or (mat<>nil) and (mat.idr.dim=2)then
    else
         begin seterrdimension(IDH_MAT);{done;fail} end;
end;



constructor TMatPlotLines.create(prev,eld:TStatement; plot:boolean);
begin
  inherited create(prev,eld,plot);
 {
  if (token=';') and plot then
      begin
         gettoken;
         cont:=true;
      end
  else
      cont:=false;
 }
end;

constructor TPlotArea.create(prev,eld:TStatement; plot:boolean);
begin
   inherited create(prev,eld,plot);
   if not (pointpairs.count>=2*3) then
        seterr('',IDH_AREA);
end;


destructor TPlotOrg.destroy;
begin
    pointpairs.free;
    limit.free;
    mat.free;
    inherited destroy
end;

function TPlotOrg.evalLimit:integer;     //2011.3.5
begin
   if pointpairs<>nil then
      result:=Pointpairs.count div 2
   else if mat<>nil then
     begin
       result:=maxint;
       if limit<>nil then
          result:=limit.evalInteger;
       result:=min(result, TArray(mat.point).Size[1]);
       if mat2=nil then
          begin
            if not( TArray(mat.point) is TCArray)
               and (TArray(mat.point).size[2]<2) then
              setexception(6401)
          end
        else
          if TArray(mat2.point).size[1]<result then
              setexception(6401);
     end;
end;


(*
function TPlotOrg.MakeList(p:PPointArray; lim:integer):integer; //結果は点の個数
var
   index:integer;
   x,y:double;
   array1,array2:TArray;
begin
   index:=0;
   if pointpairs<>nil then
      with PointPairs do
        begin
          result:=0;
          while index<lim do
             begin
                x:=TPrincipal(items[index*2  ]).evalX;
                y:=TPrincipal(items[index*2+1]).evalX;
                inc(index);
                if GRAPHst or currenttransform.transform(x,y) then
                   begin
                     p^[result].x:=restrict(MyGraphSys.deviceX(x));
                     p^[result].y:=restrict(MyGraphSys.deviceY(y));
                     inc(result);
                   end
             end
        end
   else if (mat<>nil) and (mat2=nil) then
      with TArray(mat.point) do
      begin
          result:=0;
          while index<lim do
             begin
                ItemGetX(index*size[2],  x);
                ItemGetX(Index*size[2]+1,y);
                inc(index);
                if GRAPHst or currenttransform.transform(x,y) then
                   begin
                       p^[result].x:=restrict(MyGraphSys.deviceX(x));
                       p^[result].y:=restrict(MyGraphSys.deviceY(y));
                       inc(result)
                   end
             end;
      end
   else if (mat<>nil) and (mat2<>nil) then
      begin
          array1:=TArray(mat.point);
          array2:=TArray(mat2.point);
          result:=0;
          while index<lim do
             begin
                  array1.ItemGetX(index,x);
                  array2.ItemGetX(index,y);
                  inc(index);
                  if GRAPHst or currenttransform.transform(x,y) then
                     begin
                      p^[result].x:=restrict(MyGraphSys.deviceX(x));
                      p^[result].y:=restrict(MyGraphSys.deviceY(y));
                      inc(result);
                     end
             end
      end
end;

procedure TPlotOrg.MakeCoordinateList(p:PCoordinateArray; lim:integer); //変換前の座標
var
   index:integer;
   array1,array2:TArray;
begin
   index:=0;
   if pointpairs<>nil then
      with PointPairs do
        begin
          while index<lim do
             begin
                p^[index].x:=TPrincipal(items[index*2  ]).evalX;
                p^[index].y:=TPrincipal(items[index*2+1]).evalX;
                inc(index);
             end
        end
   else if (mat<>nil) and (mat2=nil) then
      with TArray(mat.point) do
      begin
          while index<lim do
             begin
                ItemGetX(index*size[2],   p^[index].x);
                ItemGetX(Index*size[2]+1, p^[index].y);
                inc(index);
             end;
      end
   else if (mat<>nil) and (mat2<>nil) then
      begin
          array1:=TArray(mat.point);
          array2:=TArray(mat2.point);
          while index<lim do
             begin
                  array1.ItemGetX(index, p^[index].x);
                  array2.ItemGetX(index, p^[index].y);
                  inc(index);
             end
      end
end;
*)
function TPlotOrg.MakeList(p:PPointArray; lim:integer):integer; //結果は点の個数 //2011.3.5
var
   index:integer;
   x,y:double;
   array1,array2:TArray;
   i:pointer;
   z:complex;
begin
   index:=0;
   if pointpairs<>nil then
      with PointPairs do
        begin
          result:=0;
          while index<lim do
             begin
                i:=items[index*2+1];
                if i<>nil then
                  begin
                x:=TPrincipal(items[index*2  ]).evalX;
                y:=TPrincipal(i).evalX;
                  end
                else
                  begin
                    TPrincipal(items[index*2  ]).evalC(z);
                    x:=z.x;
                    y:=z.y;
                  end;
                inc(index);
                if GRAPHst or currenttransform.transform(x,y) then
                   begin
                     p^[result].x:=restrict(MyGraphSys.deviceX(x));
                     p^[result].y:=restrict(MyGraphSys.deviceY(y));
                     inc(result);
                   end
             end
        end
   else if (mat<>nil) and (mat2=nil) then
      begin
          array1:=TArray(mat.point);
          if array1.dim=1 then
            with array1 as TCArray do
              begin
                  result:=0;
                  while index<lim do
                   begin
                      ItemGetC(index,z);
                      x:=z.x;
                      y:=z.y;
                      inc(index);
                      if GRAPHst or currenttransform.transform(x,y) then
                         begin
                             p^[result].x:=restrict(MyGraphSys.deviceX(x));
                             p^[result].y:=restrict(MyGraphSys.deviceY(y));
                             inc(result)
                         end
                   end
              end
          else
            with array1 do
              begin
                  result:=0;
                  while index<lim do
                     begin
                        ItemGetF(index*size[2],  x);
                        ItemGetF(Index*size[2]+1,y);
                        inc(index);
                        if GRAPHst or currenttransform.transform(x,y) then
                           begin
                               p^[result].x:=restrict(MyGraphSys.deviceX(x));
                               p^[result].y:=restrict(MyGraphSys.deviceY(y));
                               inc(result)
                           end
                     end;
              end
      end
   else if (mat<>nil) and (mat2<>nil) then
      begin
          array1:=TArray(mat.point);
          array2:=TArray(mat2.point);
          result:=0;
          while index<lim do
             begin
                  array1.ItemGetF(index,x);
                  array2.ItemGetF(index,y);
                  inc(index);
                  if GRAPHst or currenttransform.transform(x,y) then
                     begin
                      p^[result].x:=restrict(MyGraphSys.deviceX(x));
                      p^[result].y:=restrict(MyGraphSys.deviceY(y));
                      inc(result);
                     end
             end
      end
end;



procedure TPlotOrg.MakeCoordinateList(p:PCoordinateArray; lim:integer); //変換前の座標 //2011.3.5
var
   index:integer;
   array1,array2:TArray;
   i:pointer;
   z:complex;
begin
   index:=0;
   if pointpairs<>nil then
      with PointPairs do
        begin
          while index<lim do
             begin
                i:=items[index*2+1];
                if i<>nil then
                  begin
                    p^[index].x:=TPrincipal(items[index*2  ]).evalX;
                    p^[index].y:=TPrincipal(i).evalX;
                  end
                else
                  begin
                    TPrincipal(items[index*2  ]).evalC(z);
                    p^[index].x:=z.x;
                    p^[index].y:=z.y;
                  end;
                inc(index);
             end
        end
   else if (mat<>nil) and (mat2=nil) then
      begin
          array1:=TArray(mat.point);
          if array1.dim=1 then
            with array1 as TCArray do
            while index<lim do
             begin
                ItemGetC(index,z);
                p^[index].x:=z.x;
                p^[index].y:=z.y;
                inc(index);
             end
          else
            with array1 do
            while index<lim do
             begin
                ItemGetF(index*size[2],   p^[index].x);
                ItemGetF(Index*size[2]+1, p^[index].y);
                inc(index);
             end;
      end
   else if (mat<>nil) and (mat2<>nil) then
      begin
          array1:=TArray(mat.point);
          array2:=TArray(mat2.point);
          while index<lim do
             begin
                  array1.ItemGetF(index, p^[index].x);
                  array2.ItemGetF(index, p^[index].y);
                  inc(index);
             end
      end
end;


function TPlotOrg.ReMakeList(p:PCoordinateArray; q:PPointArray; count:integer):integer; //結果は点の個数
var
  i,index:integer;
  x,y:double;
begin
  result:=0;
  for i:=0 to count-1 do
    begin
      x:=p^[i].x;
      y:=p^[i].y;
      if GRAPHst or currenttransform.transform(x,y) then
         begin
           q^[result].x:=restrict(MyGraphSys.deviceX(x));
           q^[result].y:=restrict(MyGraphSys.deviceY(y));
           inc(result)
        end
    end;
end;




procedure TMatPlotPoints.exec;
var
   p:PPointArray;
   i:integer;
   count:integer;
begin
   if BeamMode=bmRigorous then Beamoff;
   count:=evalLimit;
   GetMem(p, count*sizeof(TPoint));
   try
     for i:=0 to MakeList(p,count)-1 do
         AddQueue(TPutMark0.create(p^[i].x, p^[i].y));
   finally
      Freemem(p,count*sizeof(TPoint));
   end;

end;




 constructor TPolyLine.create(const Points0:array of TPoint);
 var i:integer;
 begin
   inherited create;
   SetLength(points,length(points0));
   for i:=0 to High(Points) do
        points[i]:=Points0[i]
 end;

procedure TPolyLine.execute;
begin
     MyGraphSys.PolyLine(Points)
end;

destructor TPolyLine.destroy;
begin
    points:=nil;
    inherited destroy;
end;

procedure TMatPlotLines.exec;
var
   p:PPointArray;
   i,index:integer;
   count:integer;
   n:integer;
begin
   BeamOff;
   count:=evalLimit;
   if GRAPHst and (count<2) then
                                 setexception(11100);
   if GRAPHst or (CurrentTransform=nil) or CurrentTransform.IsAffine then
     begin
       GetMem(p,count*sizeof(TPoint));
       try
         n:=MakeList(p,count);
         AddQueue(TPolyLine.create(slice(p^,n)));
       finally
          Freemem(p,count*sizeof(TPoint));
       end;
     end
   else
     PlotProjectiveLine(count);
   RepaintRequest:=true;
   BeamOff;
end;

procedure TPlotorg.PlotProjectiveLine(lim:integer);
var
   index:integer;
   p:PCoordinateArray;
begin
   GetMem(p, lim*SizeOf(TCoordinate));
   try
      MakeCoordinateList(p, lim);
      for index:=0 to lim-1 do
        with p^[index] do  ProjectivePlotTo(x,y);
   finally
      FreeMem(p, lim*SizeOf(TCoordinate));
   end;
end;


procedure TPolygon.execute;
begin
     MyGraphSys.Polygon(Points)
end;

procedure TPlotArea.exec;
var
   p:PPointArray;
   i:integer;
   count:integer;
begin
  //WaitReady;

   with MyGraphSys do
     if BeamMode=bmRigorous then Beamoff;
  count:=evalLimit;
  if count<3 then setexception(11100);

  if GRAPHst or (CurrentTransform=nil) or CurrentTransform.IsAffine then
    begin
      GetMem(p,count*sizeof(TPoint));
      try
          AddQueue(TPolygon.create(slice(p^,MakeList(p,count))));
      finally
          Freemem(p,count*sizeof(TPoinT));
      end
    end
   else
      ProjectivePolygon(count)
      ;
 RepaintRequest:=true;

end;


function Inner(x,y:double; p:PCoordinateArray; count:integer):boolean;
var
  i:integer;
  x0,y0,x1,y1,y2:double;
  xt:double;
begin
  if (p^[0].x = p^[count-1].x) and (p^[0].y = p^[count-1].y) then dec(count);

  result:=false;

  for i:=0 to count -1 do
    begin
       x0:=p^[i].x;
       y0:=p^[i].y;
       x1:=p^[(i+1) mod count].x;
       y1:=p^[(i+1) mod count].y;
       y2:=p^[(i+2) mod count].y;

       if (y0 - y) * (y - y1) >0 then
          begin
             xt:=(x1-x0)/(y1-y0)*(y-y0)+x0;
             if x=xt then begin result:=true; exit end
             else if x<xt then result:=not result;
          end
       else if y=y1 then
          begin
            if (y0=y1) then
               begin
                 if ((x -x0)*(x - x1)<=0) then
                    begin result:=true ; exit end ;
               end
            else if (y=y1) and ((y0 - y1)*(y1 - y2)>0) then
               begin
                 if x<x1 then result:= not result
               end
          end
    end;
end;

type TPutColor=Class(TGraphCommand)
  a,b:longint;
  c:integer;
  constructor create(a0,b0:longint; c0:integer);
  procedure execute;override;
end;

constructor TPutColor.create( a0,b0:longint; c0:integer);
begin
  inherited create;
  a:=a0; b:=b0; c:=c0
end;

procedure TPutColor.execute;
begin
  MyGraphSys.putPixel(a,b,c);
end;

procedure TPlotArea.ProjectivePolygon(lim:integer);
var
   p:PCoordinateArray;
   q:PPointArray;
   a,b:integer;
   x,y,yy:double;
begin
   GetMem(p, lim*SizeOf(TCoordinate));
   try
     MakeCoordinateList(p,lim);
     if TestNormalSegments(p,lim) then
       begin
         GetMem(q,lim*sizeof(TPoint));
         try
           AddQueue(TPolygon.create(slice(q^,ReMakeList(p,q,lim))));
         finally
           Freemem(q,lim*sizeof(TPoinT));
         end
       end
     else
       with MyGraphSys do
         for b:=ClipRect.top to Cliprect.Bottom do
           begin
             yy:=virtualY(b);
             for a:=ClipRect.Left to Cliprect.Right do
                begin
                   x:=virtualX(a);
                   y:=yy;
                   if currenttransform.invtransform(x,y) then
                       if inner(x,y,p,lim) then
                          AddQueue(TPutColor.create(a,b,areacolor));
                end;
            RepaintRequest:=true;
           end;
   finally
      FreeMem(p, lim*SizeOf(TCoordinate));
   end;

end;


constructor TPlotBezier.create(prev,eld:TStatement; plot:boolean);
var
   i:integer;
begin
    inherited create(prev,eld);
    GRAPHst:=not plot;
    for i:=0 to 3 do
    begin
       expx[i]:=NExpression;
       check(',',0);
       expy[i]:=NExpression;
       if i<3 then check(';',0);
    end;
end;

destructor TPlotBezier.destroy;
var
  i:integer;
begin
  for i:=3 downto 0 do
    begin
      expy[i].Free;
      expx[i].Free;
    end;
  inherited destroy;
end;

Type TPolyBezier=class(TPolyLine)
  procedure execute;override;
end;

procedure TPolyBezier.execute;
begin
  MyGraphSys.PolyBezier(Points);
end;

procedure TPlotBezier.exec;
var
   i:integer;
   x,y:double;
   points:Array[0..3]of TPoint;
begin
  for i:=0 to 3 do
  begin
     x:=expx[i].evalX;
     y:=expy[i].evalX;
     if GraphSt or CurrentTransform.transform(x,y) then
       begin
         points[i].X:=MyGraphSys.deviceX(x);
         points[i].Y:=MyGraphsys.deviceY(y);
       end;
  end;
  AddQueue(TPolyBezier.create(Points));
  RepaintRequest:=true;
end;




{*********}
{MAT CELLS}
{*********}
type
   TMatCells=class(TStatement)
       exp1,exp2,exp3,exp4:tPrincipal;
       mat1:TMatrix;
       GRAPHst:boolean;
     constructor create(prev,eld:TStatement);
     procedure exec;override;
     destructor destroy;override;
   end;

constructor TMatCells.create(prev,eld:TStatement);
begin
  graphmode:=true;
  inherited create(prev,eld);
  GRAPHst:=not (PrevToken='PLOT');
  gettoken;  // CELLS
  CheckToken(',',IDH_MAT_CELLS);
  CheckToken('IN',IDH_MAT_CELLS);
  exp1:=Nexpression;
  CheckToken(',',IDH_MAT_CELLS);
  exp2:=Nexpression;
  CheckToken(';',IDH_MAT_CELLS);
  exp3:=Nexpression;
  CheckToken(',',IDH_MAT_CELLS);
  exp4:=Nexpression;
  CheckToken(':',IDH_MAT_CELLS);
  mat1:=NMatrix;
  if mat1.idr.dim<>2 then seterrDimension(IDH_MAT_CELLS);
end;

destructor TMatCells.destroy;
begin
   exp1.free;
   exp2.free;
   exp3.free;
   exp4.free;
   mat1.free;
   inherited destroy;
end;

(* すべてWIN APIに依存して描く・・・遅い
procedure TMatCells.exec;
var
   a,b,i,j:integer;
   color:longint;
   x,y,x1,y1,x2,y2,w,h:double;
   xx,yy,dx,dy:double;
   p:TArray;
   colorbyte:^byte;
   svDrawMode:boolean;
   PaletteDisabled:boolean;
   red,green,blue:byte;
   Points:array[1..4]of TPoint;
   a1,b1,a2,b2,a3,b3,a4,b4:double;
begin

  x1:=exp1.evalX;
  y1:=exp2.evalX;
  x2:=exp3.evalX;
  y2:=exp4.evalX;

  p:=nil;
  TVar(p):=Mat1.point;
  if p=nil then exit;


     svDrawMode:=GraphSys.HiddenDrawMode;
     MyGraphSys.SetHiddenDrawMode(true);

     w:=(x2-x1)/p.size[1];
     h:=(y2-y1)/p.size[2];

     x:=x1;
     y:=y1;
     for i:=0 to p.size[1]-1 do
      begin
        for j:=0 to p.size[2]-1 do
         begin
           color:=p.pointij(i,j).evalInteger;
           x:=x1+w*i; xx:=x+w;
           y:=y1+h*j; yy:=y+h;
           a1:=x; b1:=y;
           a2:=xx;b2:=y;
           a3:=xx;b3:=yy;
           a4:=x; b4:=yy;
           if not GRAPHst then
            begin
              currenttransform.transform(a1,b1);
              currenttransform.transform(a2,b2);
              currenttransform.transform(a3,b3);
              currenttransform.transform(a4,b4);
            end;
           with MyGraphSys do
           begin
             Points[1].x:=DeviceX(a1);  Points[1].y:=DeviceY(b1);
             Points[2].x:=DeviceX(a2);  Points[2].y:=DeviceY(b2);
             Points[3].x:=DeviceX(a3);  Points[3].y:=DeviceY(b3);
             Points[4].x:=DeviceX(a4);  Points[4].y:=DeviceY(b4);
           end;
           ColorPolygon(MyGraphsys.Canvas1, Points, color);

         end;
       end;
     MyGraphSys.SetHiddenDrawMode(svdrawMode);
end;
*)
type TPixelData=array[0..3]of byte;
     PPixeldata=^TPixelData;

procedure MatCellsSeb(x1,x2,y1,y2:double; p:Tarray; GRAPHst:boolean; var f:boolean);
var
   a,b,i,j:integer;
   color:longint;
   x,y,w,h:double;
   xx,yy,dx,dy:double;
   RowPtr:PByte;
   PixelPtr:PPixelData;
   svDrawMode:boolean;
   PaletteDisabled:boolean;
   red,green,blue:byte;
   redix,greenix,blueix:byte;
   Points:array[1..4]of TPoint;
   a1,b1,a2,b2,a3,b3,a4,b4:double;
   RawImage: TRawImage;
   BytePerPixel: Integer;
   PixFormat:TPixelFormat;
begin
  ClearExceptions(false);
  PaletteDisabled:=MyPalette.PaletteDisabled;      //2023.09.17

  if (MyGraphSys is TScreenBMPGraphSys)
     and ((CurrentTransform=nil)
       or CurrentTransform.IsAffine and (abs(CurrentTransform.det)>1/1024)) then
     begin
         //PaletteDisabled:=MyPalette.PaletteDisabled;
         svDrawMode:=GraphSys.HiddenDrawMode;
         GraphSys.HiddenDrawMode:=True;

          x:=MyGraphSys.virtualX(0);
          y:=MyGraphSys.virtualY(0);
         dx:=MyGraphSys.virtualX(1);
         dy:=MyGraphSys.virtualY(1);
         if not GRAPHst then
            begin
              currenttransform.invtransform(x,y);
              currenttransform.invtransform(dx,dy);
            end;
         dx:=dx-x;
         dy:=y-dy;

         if (x2-x1)*dx<0 then
             dx:=-dx;
         if (y2-y1)*dy<0 then
             dy:=-dy;
         w:=p.size[1]/(x2-x1+dx);
         h:=p.size[2]/(y2-y1+dy);

         with TScreenBMPGraphSys(MyGraphSys) do
            begin
               PixFormat:=Bitmap1.PixelFormat;
               if (PixFormat=pf24bit) and (bitmap1.canvas.pen.mode=pmCopy) then
                 begin
                     Bitmap1.BeginUpdate(false);
                     RawImage := Bitmap1.RawImage;
                     BytePerPixel := RawImage.Description.BitsPerPixel div 8;
                     with RawImage.Description do
                        begin
                            redix:=redshift div 8;
                            greenix:=greenshift div 8;
                            blueix:=blueshift div 8;
                            if ByteOrder=riboMSBFirst then
                               begin
                                 RedIx:=BytePerPixel-1-RedIx;
                                 GreenIx:=BytePerPixel-1-GreenIx;
                                 BlueIx:=BytePerPixel-1-BlueIx;
                               end;
                         end;
                     RowPtr:=PByte(RawImage.Data);
                     for b:=0 to Bitmap1.Height-1 do
                       begin
                         PixelPtr:=PPixelData(RowPtr);
                         y:=virtualY(b);
                         yy:=y;
                         for a:=0 to Bitmap1.Width-1 do
                            begin
                               if (a>=ClipRect.Left) and (a<=ClipRect.Right)
                               and (b>=ClipRect.top) and (b<=ClipRect.Bottom) then
                                  begin
                                      x:=virtualX(a);
                                      y:=yy;
                                      if not GRAPHst then
                                          currenttransform.invtransform(x,y);
                                      i:=math.floor(w*(x-x1)+1e-9 {計算誤差の補償});
                                      j:=math.floor(h*(y-y1)+1e-9 {計算誤差の補償});
                                      if  (i>=0) and (i<p.size[1]) and (j>=0) and (j<p.size[2]) then
                                       begin
                                            with p do color:=ItemEvaLInteger(i*size[2]+j);
                                           if (color>=0) and ((color<=maxcolor) or PaletteDisabled) then
                                             begin
                                                if not PaletteDisabled then
                                                   color:=MyPalette[color];
                                                red:=byte(color);
                                                color:=color shr 8;
                                                green:=byte(color);
                                                color:=color shr 8;
                                                blue:=byte(color);
                                                PixelPtr^[redix]:=red;
                                                PixelPtr^[greenIx]:=green;
                                                PixelPtr^[BlueIx]:=Blue;
                                              end
                                           else
                                              f:=true;
                                       end;
                                  end;
                               inc(PByte(PixelPtr),BytePerPixel);
                            end;
                         Inc(RowPtr, RawImage.Description.BytesPerLine);
                       end;
                       Bitmap1.EndUpdate(False);
                end
             else
                 begin
                        for b:=ClipRect.top to Cliprect.Bottom do
                          begin
                            y:=virtualY(b);
                            yy:=y;
                            for a:=ClipRect.Left to Cliprect.Right do
                               begin
                                    x:=virtualX(a);
                                    y:=yy;
                                    if not GRAPHst then
                                       currenttransform.invtransform(x,y);
                                    i:=floor(w*(x-x1)+1e-9 {計算誤差の補償});
                                    j:=floor(h*(y-y1)+1e-9 {計算誤差の補償});
                                    if  (i>=0) and (i<p.size[1]) and (j>=0) and (j<p.size[2]) then
                                     begin
                                          with p do color:=ItemEvaLInteger(i*size[2]+j);
                                          if (color>=0) and ((color<=maxcolor) or PaletteDisabled) then
                                            begin
                                               if not PaletteDisabled then
                                                  color:=MyPalette[color];
                                               if MyGraphSys.testClipRect(a,b)then
                                                  Bitmap1.Canvas.pixels[a,b]:=color;
                                            end
                                          else
                                              f:=true;
                                     end;
                              end;
                          end;
                  end;
           GraphSys.HiddenDrawMode:=svDrawMode ;
        end
     end
  else  if (CurrentTransform<>nil) and (abs(CurrentTransform.det)>1/1024) and
        ((MyGraphSys is TScreenBMPGraphSys) or
                                     not   (NormalSegment(x1,y1,x1,y2)
                                        and NormalSegment(x1,y2,x2,y2)
                                        and NormalSegment(x2,y2,x2,y1)
                                        and NormalSegment(x2,y1,x1,y1))) then
     begin
       w:=(p.size[1]-0.0001)/(x2-x1);
       h:=(p.size[2]-0.0001)/(y2-y1);

       with MyGraphSys do
         for b:=ClipRect.top to Cliprect.Bottom do
           begin
             yy:=virtualY(b);
             for a:=ClipRect.Left to Cliprect.Right do
                begin
                   x:=virtualX(a);
                   y:=yy;
                   if currenttransform.invtransform(x,y) then
                     try
                       i:=floor(w*(x-x1)+1e-9 {計算誤差の補償});
                       j:=floor(h*(y-y1)+1e-9 {計算誤差の補償});
                       if  (i>=0) and (i<p.size[1]) and (j>=0) and (j<p.size[2]) then
                         begin
                           with p do color:=ItemEvaLInteger(i*size[2]+j);
                           if not ((color>=0) and (color<=maxcolor) or PaletteDisabled) then f:=true;
                           PutPixel(a,b,color);
                         end
                     except
                     end
                end;
           end;
     end
   else
     begin
       w:=(x2-x1)/p.size[1];
       h:=(y2-y1)/p.size[2];
       x:=x1;
       y:=y1;
       for i:=0 to p.size[1]-1 do
        begin
          for j:=0 to p.size[2]-1 do
           begin
             with p do color:=ItemEvalInteger(i*size[2]+j);
             if not ((color>=0) and (color<=maxcolor) or PaletteDisabled) then f:=true;
             x:=x1+w*i; xx:=x+w;
             y:=y1+h*j; yy:=y+h;
             a1:=x; b1:=y;
             a2:=xx;b2:=y;
             a3:=xx;b3:=yy;
             a4:=x; b4:=yy;
             if GRAPHst or
                currenttransform.transform(a1,b1) and
                currenttransform.transform(a2,b2) and
                currenttransform.transform(a3,b3) and
                currenttransform.transform(a4,b4) then
               begin
                 with MyGraphSys do
                 begin
                   Points[1].x:=DeviceX(a1);  Points[1].y:=DeviceY(b1);
                   Points[2].x:=DeviceX(a2);  Points[2].y:=DeviceY(b2);
                   Points[3].x:=DeviceX(a3);  Points[3].y:=DeviceY(b3);
                   Points[4].x:=DeviceX(a4);  Points[4].y:=DeviceY(b4);
                 end;
                 MyGraphsys.ColorPolygon( Points, color);
               end;
           end;
         end;
     end;

   RepaintRequest:=true;
end;

Type TMatCellsSub=Class(TReSetBoolean)
    x1,x2,y1,y2:double;
    p:Tarray;
    GRAPHst:boolean;
    pf:PBoolean;
    constructor create( var b:boolean;
          x10,x20,y10,y20:double; p0:Tarray; GRAPHst0:boolean; var f:boolean);
    procedure execcore;override;
end;

constructor TMatCellsSub.create( var b:boolean;
         x10,x20,y10,y20:double; p0:Tarray; GRAPHst0:boolean; var f:boolean);
begin
  inherited create(b);
  x1:=x10;
  x2:=x20;
  y1:=y10;
  y2:=y20;
  p:=p0;
  GRAPHst:=GRAPHst0;
  pf:=@f;
end;

procedure TMatCellsSub.execcore;
begin
   MatCellsSeb(x1,x2,y1,y2, p,GRAPHst,pf^);
end;

procedure TMatCells.exec;
var
   x1,y1,x2,y2:double;
   p:TArray;
   f:boolean;
   s:boolean;
begin

  x1:=exp1.evalX;
  y1:=exp2.evalX;
  x2:=exp3.evalX;
  y2:=exp4.evalX;

  p:=nil;
  TVar(p):=Mat1.point;
  if p=nil then exit;


  f:=false;
  //MatCellsSeb(x1,x2,y1,y2, p,GRAPHst,f);
  AddQueue(TMatCellsSub.create( s, x1,x2,y1,y2, p,GRAPHst,f));
  while s do  (TThread.CurrentThread).Yield  ;
  //if insideofwhen and f then setexception(11085)
  if f then
    ReportException(insideofwhen,11085)
end;


function MATPLOTst(prev,eld:TStatement):TStatement;
var
   plot:boolean;
begin
   plot:=(PrevToken='PLOT');
   MATPLOTst:=nil;
   if token='POINTS' then
      MATPLOTst:=TMatPlotPoints.createmat(prev,eld,plot)
   else if token='LINES' then
      MATPLOTst:=TMatPlotLines.createmat(prev,eld,plot)
   else if token='AREA' then
      MATPLOTst:=TPLOTAREA.createmat(prev,eld,plot)
   else if token='CELLS' then
      MATPLOTst:=TMatCells.create(prev,eld)
   else
      seterr('',IDH_MAT_PLOT);
end;




{*****}
{mouse}
{*****}


type
  TGetPoint=class(TStatement)
    exp1,exp2:TVariable;
    LocateSt:boolean;
    NoBeamOff:boolean;
    dev1,exp3,exp4:TPrincipal;
    constructor create(prev,eld:TStatement; get:boolean);
    procedure exec;override;
    destructor destroy;override;
   end;


function  GETst(prev,eld:TStatement):TStatement;
begin
   graphmode:=true;
   GETst:=TGETPOINT.create(prev,eld,PrevToken='GET');
end;


constructor TGetPoint.create(prev,eld:TStatement; get:boolean);
begin
   inherited create(prev,eld);
   LocateSt:=not get;
   checktoken('POINT',IDH_GET);
  if test('(') then
     begin
       dev1:=NExpression;
       check(')',IDH_LOCATE)
     end;
  if (token=',') and (nexttoken='AT') then
     begin
       gettoken;
       gettoken;
       exp3:=NExpression;
       check(',',IDH_GET);
       exp4:=NExpression;
     end;
   if (token=',') and (nexttoken='NOBEAMOFF') then
       begin
          Gettoken;
          Gettoken;
          NoBeamOff:=true;
       end;
   checktoken(':',IDH_GET);
   exp1:=nvariable;
   check(',',IDH_GET);
   exp2:=nvariable;
end;


destructor TGetPoint.destroy;
begin
    exp1.free;
    exp2.free;
    dev1.free;
    exp3.free;
    exp4.Free;
    inherited destroy;
end;

type TPointAtSub=Class(TGraphCommand)
   x,y:double;
   constructor create(x0,y0:double);
   procedure execute;override;
end;

constructor TPointAtSub.create(x0,y0:double);
begin
  inherited create;
  x:=x0; y:=y0;
end;

procedure TPointAtSub.execute;
var
   vx,vy:integer;
begin
      vx:=MyGraphSys.deviceX(x);
      vy:=MyGraphSys.deviceY(y);
      MyGraphSys.MoveMouse(vx,vy);
end;

procedure PointAt(exp3,exp4:TPrincipal);
var
  x,y:double;
begin
   x:=exp3.evalX;
   y:=exp4.evalX;
   if CurrentTransform.transform(x,y) then
     begin
      AddQueue(TPointAtSub.create(x,y));
     end;
end;

type
  TTgetPoint=class(TResetBoolean)
    pa,pb:PInteger;
    LineNumb:integer;
    NoBeamOff:boolean;
    constructor create(var s:boolean; var a,b:integer; LineNumb0:integer; n0:boolean);
    procedure execCore;override;
 end;

constructor TTGetPoint.create(var s:boolean; var a,b:integer;  LineNumb0:integer; n0:boolean);
begin
  inherited create(s);
  pa:=@a; pb:=@b;
  LineNumb:=LineNumb0;
  NoBeamoff:=n0;
end;

procedure TTGetPoint.execCore;
var
  vx,vy:integer;
begin
    SelectLine(FrameForm.Memo1,LineNumb);
    with MyGraphSys do
      beam:=beam and ((BeamMode=bmImmortal) or NoBeamOff);
    MyGraphSys.getpoint(vx,vy);
    pa^:=vx;
    pb^:=vy;
end;


procedure TGetPoint.exec;
var
   a,b:integer;
   x,y:double;
   s:boolean;
begin
   if MyGraphSys<>ScreenBMPGraphSys then
       Setexception(11140);
   if (dev1<>nil) and (dev1.evalInteger<>1) then
       setexception(11152);

    if exp3<>nil then
       PointAt(exp3,exp4);
    WaitReady;

    Graphic.beam:=Graphic.beam and ((BeamMode=bmImmortal) or NoBeamOff);  //8.0.2.4  2020.02.13

    AddQueue(TTGetPoint.create(s,a,b,LineNumb,NoBeamoff));
    while s do  (TThread.CurrentThread).Yield  ;

    x:=MyGraphSys.virtualX(a);
    y:=MyGraphSys.virtualY(b);

    if LOCATEst or currenttransform.invtransform(x,y) then
      begin
        exp1.assignX(x) ;
        exp2.assignX(y) ;
      end
    else
      setexception(-3009)
end;




{**********}
{MOUSE POLL}
{**********}

type
   TMousePoll=class(TStatement)
        exp1,exp2,exp3,exp4:TVariable;
     constructor create(prev,eld:TStatement);
     procedure exec;override;
     destructor destroy;override;
    end;


function MOUSEst(prev,eld:TStatement):Tstatement;
begin
    MOUSEst:=nil;
    checktoken('POLL',IDH_EXTENSION);
    MOUSEst:=TmousePoll.create(prev,eld);
    graphmode:=true;
end;

constructor TMOusePoll.create(prev,eld:TStatement);
begin
   inherited create(prev,eld);
   exp1:=nvariable;
   check(',',IDH_EXTENSION);
   exp2:=nvariable;
   check(',',IDH_EXTENSION);
   exp3:=nvariable;
   check(',',IDH_EXTENSION);
   exp4:=nvariable;
end;

destructor TMousePoll.destroy;
begin
   exp1.free;
   exp2.free;
   exp3.free;
   exp4.free;
   inherited destroy
end;


type
   TTMousePol=class(TresetBoolean)
     pa,pb:PInteger;
     pl,pr:Pboolean;
     constructor create(var s: boolean; var a,b:integer; var l,r:boolean);
     procedure execCore;override;
   end;
constructor TTMousePol.create(var s: boolean; var a,b:integer; var l,r:boolean);
begin
   inherited create(s);
   pa:=@a; pb:=@b;
   pl:=@l; pr:=@r;
end;
procedure TTMousePol.execCore;
var
      vx,vy:integer;
begin
   MyGraphSys.MousePol(vx,vy,pl^,pr^);
   pa^:=vx;
   pb^:=vy;
end;



procedure TMousePoll.exec;
var
   s:boolean;
   a,b:integer;
   x,y:double;
   left,right:boolean;
begin
   if MyGraphSys<>ScreenBMPGraphSys then
       Setexception(11140);

   sleep(10);   //Ver. 8.0.2.0
   AddQueue(TTMousePol.create(s,a,b,left,right));
   while s do  (TThread.CurrentThread).Yield  ;
   x:=MyGraphSys.virtualX(a);
   y:=MyGraphSys.virtualY(b);
  if currenttransform.invtransform(x,y) then
      begin
         exp1.assignX(x);
         exp2.assignX(y);
         exp3.assignLongint(byte(left));
         exp4.assignLongint(byte(right));
      end
   else
      setexception(-3009)
end;


{***************}
{CLEAR statement}
{***************}
type
   TTClear=class(TGraphCommand)
     procedure execute;override;
   end;
procedure TTClear.execute;
begin
      MyGraphSys.clear;
      RepaintRequest:=true;
end;

type
   TCLEAR=class(TSTATEMENT)
     procedure exec;override;
   end;

procedure TCLEAR.exec;
begin
    if MyGraphSys<>nil then
   begin
     AddQueue(TTClear.create)
   end;
end;

function CLEARst(prev,eld:TStatement):TStatement;
begin
    CLEARst:=TCLEAR.create(prev,eld);
end;

{********}
{GLOAD st}
{********}

type
     TGLoad=class(TStatement)
          exp1:TPrincipal;
        constructor create(prev,eld:TStatement);
        procedure exec;override;
        destructor destroy;override;
      end;

constructor TGLoad.create(prev,eld:TStatement);
begin
   inherited create(prev,eld);
   exp1 :=SExpression;
end;

destructor TGLoad.destroy;
begin
   exp1.free;
   inherited destroy
end;

type
  TTGload=class(TGraphCommand)
    s:ansistring;
    pr:PBoolean;
    constructor create(s0:ansistring; var r:boolean);
    procedure execute;override;
  end;

constructor TTGload.create(s0:ansistring; var r:boolean);
begin
  inherited create;
  s:=s0;
  pr:=@r;
end;

procedure TTGload.execute;
begin
   pr^:=MyGraphSys.OpenFile(s);
   RepaintRequest:=true;
end;

procedure TGLoad.exec;
var
   s:ansistring;
   r:boolean;
begin
   r:=false;
   if currenttransform<>nil then
            setexception(11004);     //2011.11.18追加
   s:=exp1.evalS;
   if not fileexists(s) then s:=s+'.BMP';
   if fileexists(s) then
      begin
        AddQueue(TTGLoad.create(s,r));
        WaitReady;
      end;
   if r=false then setexception(9005)

end;

function GLOADst(prev,eld:TStatement):TStatement;
begin
    graphMode:=true;
    GLOADst:=TGLoad.create(prev,eld);
end;

type
     TGSave=class(TStatement)
          exp1,exp2:TPrincipal;
        constructor create(prev,eld:TStatement);
        procedure exec;override;
        destructor destroy;override;
      end;

constructor TGSave.create(prev,eld:TStatement);
begin
   inherited create(prev,eld);
   exp1 :=SExpression;
   if token=',' then
   begin
     gettoken;
     exp2:=SExpression;
   end;
end;

destructor TGSave.destroy;
begin
   exp1.free;
   exp2.free;
   inherited destroy
end;

type
     TTGSave=Class(TTGLoad)
     procedure Execute;override;
  end;

procedure TTGsave.execute;
begin
  pr^:= MyGraphSys.SaveFile(s);
end;

procedure TGSave.exec;
var
   s1,s2:ansistring;
   ext:string;
   n:integer;
   i:integer;
   r:boolean;
begin
   r:=false;
   s2:='';
   s1:=exp1.evalS;

   if exp2<>nil then
   begin
     s2:=exp2.evalS; //to be ignored
     Lower(s2);
   end;
   AddQueue(TTGSave.create(s1,r));
   WaitReady;
   if r=false then setexception(9005)
end;

(*
procedure TGSave.exec;
var
   s1,s2:ansistring;
begin
   s2:='';
   s1:=exp1.evalS;
   if exp2<>nil then
   begin
     s2:=exp2.evalS;
     Lower(s2);
   end;
   try
     if (s2='') or (s2='32bit') then
       MyGraphSys.SaveBMPFile(s1)
     else if s2='8bit' then
       MyGraphSys.SaveFileFormat(s1,pf8bit)
     else if s2='1bit' then
       MyGraphSys.SaveFileFormat(s1,pf1bit) ;
   except
     setexception(9052)
   end;
end;
*)

function GSAVEst(prev,eld:TStatement):TStatement;
begin
    GSAVEst:=TGSave.create(prev,eld);
end;

{*********}
{Functions}
{*********}
function PixelX(x:double):double;
begin
  //  WaitReady;
  with MyGraphSys do
    result:=DeviceX(x) - DeviceX(left);
end;

function PixelY(x:double):double;
begin
  //  WaitReady;
  with MyGraphSys do
    result:=DeviceY(bottom) - DeviceY(x)
end;

function WindowX(x:double):double;
begin
  //  WaitReady;
  with MyGraphSys do
    result:=VirtualX( DeviceX(left) +
            LongIntRound(x) )
end;

function WindowY(x:double):double;
begin
  //  WaitReady;
  with MyGraphSys do
    result:=VirtualY( DeviceY(bottom) - 
      LongIntRound(x))
end;

{*********}
{Microsoft}
{*********}
type
    TMSWindow=class(TCustomSetWindow)
       constructor create(prev,eld:TStatement);
    end;

constructor TMSWindow.create(prev,eld:TStatement);
begin
    inherited create(prev,eld);
    graphmode:=true;
    check( '(',IDH_SYNTAX_MICROSOFT);
    x1:=nexpression;
    check(',',IDH_SYNTAX_MICROSOFT);
    y2:=nexpression;
    check(')',IDH_SYNTAX_MICROSOFT);
    check('-',IDH_SYNTAX_MICROSOFT);
    check('(',IDH_SYNTAX_MICROSOFT);
    x2:=nexpression;
    check(',',IDH_SYNTAX_MICROSOFT);
    y1:=nexpression;
    check(')',IDH_SYNTAX_MICROSOFT);
end;

function  WINDOWst(prev,eld:TStatement):TStatement;
begin
  if PermitMicrosoft then
    result:=TMSWINDOW.create(prev,eld)
  else
    Seterr(s_WINDOW, IDH_WINDOW)  ;
end;



type
   TPSET=class(TStatement)
       exp1,exp2,exp3:TPrincipal;
       constructor create(prev,eld:TStatement);
       destructor destroy;override;
       procedure exec;override;
      end;

constructor TPSet.create(prev,eld:TStatement);
begin
    graphmode:=true;
    inherited create(prev,eld);
    Check('(',IDH_SYNTAX_MICROSOFT);
    exp1:=nexpression;
    check(',',IDH_SYNTAX_MICROSOFT);
    exp2:=nexpression;
    check(')',IDH_SYNTAX_MICROSOFT);
    if test(',') then
         exp3:=NExpression;
end;


destructor TPSet.destroy;
begin
    exp1.free;
    exp2.free;
    exp3.free;
    inherited destroy
end;

 
type
   TTPSET0=Class(TPutmark0)
     procedure execute;override;
   end;

procedure TTPSET0.execute;
var
   c:integer;
begin
   c:=GetLineColor;
   MyGraphSys.MSmoveto(a,b);
   MyGraphSys.putPixel(a,b,c);
end;


type
   TTPSET=Class(TTPSET0)
     c:integer;
     constructor create(a0,b0:longint; c0:integer);
     procedure execute;override;
   end;

constructor TTPSET.create(a0,b0:longint; c0:integer);
begin
  inherited create(a0,b0);
  c:=c0;
end;

procedure TTPSET.execute;
begin
   MyGraphSys.MSmoveto(a,b);
   MyGraphSys.putPixel(a,b,c);
end;
{
procedure TPSet.exec;
var
  a,b,c:integer;
begin
  a:=MyGraphSys.DeviceX(exp1.evalX);
  b:=MyGraphSys.DeviceY(exp2.evalX);
  c:=GetLineColor;
  if exp3<>nil then
    c:=exp3.evalInteger;
  MyGraphSys.MSmoveto(a,b);
  MyGraphSys.putColor(a,b,c);
end;
}
procedure TPSet.exec;
var
  a,b,c:integer;
begin
  a:=MyGraphSys.DeviceX(exp1.evalX);
  b:=MyGraphSys.DeviceY(exp2.evalX);
  if exp3<>nil then
    begin
       c:=exp3.evalInteger;
       addQueue(TTPSet.create(a,b,c))
     end
  else
       addQueue(TTPSet0.create(a,b));
end;


function  PSETst(prev,eld:TStatement):TStatement;
begin
   result:=TPSET.create(prev,eld);
end;


type
   TLINE=class(TStatement)
       exp1,exp2,exp3,exp4,exp5:TPrincipal;
       BF:char;
       constructor create(prev,eld:TStatement);
       destructor destroy;override;
       procedure exec;override;
      end;

constructor TLINE.create(prev,eld:TStatement);
begin
    graphmode:=true;
    inherited create(prev,eld);
    if token<>'-' then
       begin
          Check('(',IDH_SYNTAX_MICROSOFT);
          exp1:=nexpression;
          check(',',IDH_SYNTAX_MICROSOFT);
          exp2:=nexpression;
          check(')',IDH_SYNTAX_MICROSOFT);
       end;
    check('-',IDH_SYNTAX_MICROSOFT);
    Check('(',IDH_SYNTAX_MICROSOFT);
    exp3:=nexpression;
    check(',',IDH_SYNTAX_MICROSOFT);
    exp4:=nexpression;
    check(')',IDH_SYNTAX_MICROSOFT);
    if test(',') then
       begin
         if token<>',' then
            exp5:=NExpression;
         if (token=',') and (exp1<>nil) and (exp2<>nil) then
            begin
              gettoken;
              if token='B' then
                 begin BF:='B'; gettoken end
              else if token='BF' then
                 begin BF:='F'; gettoken end;
            end;
       end;
end;


destructor TLINE.destroy;
begin
    exp1.free;
    exp2.free;
    exp3.free;
    exp4.free;
    exp5.free;
    inherited destroy
end;

type TTLINE=class(TGraphCommand)
    x1,y1,x2,y2:longint;
    c:integer;
   constructor create(x10,y10,x20,y20:longint; c0:integer);
   procedure execute;override;
  end;

type TTLINEBF=class(TTLINE)
   procedure execute;override;
  end;

type TTLINEF=class(TTLINE)
   procedure execute;override;
  end;

 constructor TTLINE.create(x10,y10,x20,y20:longint; c0:integer);
 begin
   inherited create;
   x1:=x10; y1:=y10; x2:=x20; y2:=y20;
   c:=c0;
 end;

procedure TTLINE.execute;
var
   svLineColor:integer;
begin
  svLineColor:=MyGraphSys.LineColor;
  if c<=maxcolor then setlinecolor(c);
  if (x1<>minInt) and (y1<>MinInt) then
      MyGraphSys.MSmoveto(x1,y1);
  MyGraphSys.MSlineto(x2,y2);
  setlinecolor(svLinecolor);
end;

procedure TTLINEBF.execute;
var
   svLineColor:integer;
begin
  svLineColor:=MyGraphSys.LineColor;
  if c<=maxcolor then setlinecolor(c);
  MyGraphSys.MSmoveto(x1,y1);
  MyGraphSys.MSlineto(x1,y2);
  MyGraphSys.MSlineto(x2,y2);
  MyGraphSys.MSlineto(x2,y1);
  MyGraphSys.MSlineto(x1,y1);
  setlinecolor(svLinecolor);
end;

procedure TTLINEF.execute;
var
  svareacolor:integer;
  p:PPointArray;
begin
  svAreaColor:=MyGraphSys.areacolor;
  if c<=maxcolor then
      setAreacolor(c)
  else
      setareacolor(MyGraphSys.linecolor);
  GetMem(p,4*sizeof(TPoint));
  p^[0].x:=x1;
  p^[0].y:=y1;
  p^[1].x:=x1;
  p^[1].y:=y2;
  p^[2].x:=x2;
  p^[2].y:=y2;
  p^[3].x:=x2;
  p^[3].y:=y1;
  MyGraphSys.Polygon(slice(p^,4));
  Freemem(p,4*sizeof(TPoint));
  setAreacolor(svAreaColor);
end;

procedure TLINE.exec;
var
  x1,y1,x2,y2:longint;
  c:integer;
begin
   if exp1<>nil then x1:=MyGraphSys.DeviceX(exp1.evalX) else x1:=MinInt;
   if exp2<>nil then y1:=MyGraphSys.DeviceY(exp2.evalX) else y1:=MinInt;
   x2:=MyGraphSys.DeviceX(exp3.evalX);
   y2:=MyGraphSys.DeviceY(exp4.evalX);
   if exp5<>nil then c:=exp5.evalinteger else c:=MaxInt;
   case BF of
   'B':begin
          addQueue(TTLINEBF.create(x1,y1,x2,y2,c))
       end;
   'F':begin
          addQueue(TTLINEF.create(x1,y1,x2,y2,c))
       end;
   else
     begin
        addQueue(TTLINE.create(x1,y1,x2,y2,c))
     end;
   end;
end;



function  MSLINEst(prev,eld:TStatement):TStatement;
begin
   result:=TLINE.create(prev,eld);
end;

function  COLORst(prev,eld:TStatement):TStatement;
begin
   if test(',') then
   begin
     checktoken(',',IDH_SYNTAX_MICROSOFT);
     checktoken(',',IDH_SYNTAX_MICROSOFT);
     if test(',') then
        result:=LabelStatement(prev,eld) ;
   end;
   COLORst:=TSet.createColor(prev,eld,SetLineColor);
end;

procedure MSScreen(c:integer);
begin
  MyGraphSys.MSScreen(c);
end;

function  SCREENst(prev,eld:TStatement):TStatement;
begin
    SCREENst:=TSet.createColor(prev,eld,MSScreen)
end;

procedure CLS(c:integer);
begin
  MyGraphSys.clear;
end;

function  CLSst(prev,eld:TStatement):TStatement;
begin
       CLSst:=TSet.createColor(prev,eld,CLS);
end;



type
   TPAINT=class(TStatement)
       exp1,exp2,exp3,exp4:TPrincipal;
       constructor create(prev,eld:TStatement);
       destructor destroy;override;
       procedure exec;override;
      end;


constructor TPAINT.create(prev,eld:TStatement);
begin
    graphmode:=true;
    inherited create(prev,eld);
    Check('(',IDH_SYNTAX_MICROSOFT);
    exp1:=nexpression;
    check(',',IDH_SYNTAX_MICROSOFT);
    exp2:=nexpression;
    check(')',IDH_SYNTAX_MICROSOFT);
    if test(',') then
      begin
        if token<>',' then
           exp3:=nexpression;
        if test(',') then
           exp4:=nexpression;
      end;
end;

destructor TPAINT.destroy;
begin
    exp1.free;
    exp2.free;
    exp3.free;
    exp4.free;
    inherited destroy
end;

type
   TTPAINT=Class(TPutmark0)
     ac,bc:integer;
     constructor create(a0,b0:longint; ac0,bc0:integer);
     procedure execute;override;
   end;

constructor TTPAINT.create(a0,b0:longint; ac0,bc0:integer);
begin
  inherited create(a0,b0);
  ac:=ac0;
  bc:=bc0;
end;

procedure TTPAINT.execute;
begin
   MyGraphSys.MSPaint(a,b,ac,bc);
end;

procedure TPAINT.exec;
var
  a,b:longint;
  ac,bc:integer;
begin
   a:=MyGraphSys.deviceX(exp1.evalX);
   b:=MyGraphSys.deviceY(exp2.evalX);
   ac:=getLineColor;
   if exp3<>nil then ac:=exp3.evalInteger;
   bc:=ac;
   if exp4<>nil then bc:=exp4.evalInteger;
   //MyGraphSys.MSPaint(a,b,ac,bc);
   addQueue(TTPAINT.create(a,b,ac,bc));
end;

function  PAINTst(prev,eld:TStatement):TStatement;
begin
   result:=TPaint.create(prev,eld);
end;


type
   TCircle=class(TStatement)
       exp1,exp2,exp3,exp4,exp7,exp8:TPrincipal;
       F:boolean;
       constructor create(prev,eld:TStatement);
       destructor destroy;override;
       procedure exec;override;
      end;


constructor TCircle.create(prev,eld:TStatement);
begin
    graphmode:=true;
    inherited create(prev,eld);
    Check('(',IDH_SYNTAX_MICROSOFT);
    exp1:=nexpression;
    check(',',IDH_SYNTAX_MICROSOFT);
    exp2:=nexpression;
    check(')',IDH_SYNTAX_MICROSOFT);
    check(',',IDH_SYNTAX_MICROSOFT);
    exp3:=nexpression;
    if test(',') then
       begin
          if token<>',' then
             begin
                exp4:=nexpression;
             end;
          if test(',') then
          begin
            check(',',IDH_SYNTAX_MICROSOFT);
            check(',',IDH_SYNTAX_MICROSOFT);
            if token<>',' then
                   exp7:=NExpression;
            if test(',') then
              begin
                CHECK('F',IDH_SYNTAX_MICROSOFT);
                F:=true;
                if test(',') then
                      exp8:=NExpression;
              end;
          end;
       end;
end;

destructor TCircle.destroy;
begin
    exp1.free;
    exp2.free;
    exp3.free;
    exp4.free;
    exp7.free;
    exp8.free;
    inherited destroy
end;

type
   TTMSCircle=class(TGraphCommand)
     x1,y1,x2,y2:integer;
     lc,ac:integer;
     f:boolean;
     constructor create(x10,y10,x20,y20:integer; lc0,ac0:integer; f0:boolean);
     procedure execute;override;
   end;

constructor TTMSCircle.create(x10,y10,x20,y20:integer; lc0,ac0:integer; f0:boolean);
begin
  inherited create;
  x1:=x10;  y1:=y10;  x2:=x20;  y2:=y20;
  lc:=lc0;  ac:=ac0;
  f:=f0;
end;

procedure TTMSCircle.execute;
begin
    MyGraphSys.MSCircle(x1,y1,x2,y2,lc,ac,F);
end;


procedure TCircle.exec;
var
  radius,ratio,rh,rv:double;
  x,y:double;
  x1,y1,x2,y2:integer;
  lc,ac:integer;
  t:integer;
begin
   x:=exp1.evalX;
   y:=exp2.evalX;
   radius:=exp3.evalX;
   if exp4=nil then lc:=getLineColor else lc:=exp4.evalInteger;
   if exp7=nil then ratio:=1. else ratio:=abs(exp7.evalX);
   if exp8=nil then ac:=lc else ac:=exp8.evalInteger;
   if ratio<=1 then
     begin  rh:=radius; rv:=radius*ratio  end
   else
     begin  rh:=radius/ratio; rv:=radius  end;
   x1:=MyGraphSys.deviceX(x-rh);  x2:=MyGraphSys.deviceX(x+rh);
   y1:=MyGraphSys.deviceY(y-rv);  y2:=MyGraphSys.deviceY(y+rv);
   if x1>x2 then begin t:=x1; x1:=x2; x2:=t end;
   if y1>y2 then begin t:=y1; y1:=y2; y2:=t end;
   //MyGraphSys.MSCircle(x1,y1,x2,y2,lc,ac,F);
   addQueue(TTMSCircle.create(x1,y1,x2,y2,lc,ac,F));
end;

function  CIRCLEst(prev,eld:TStatement):TStatement;
begin
   result:=TCircle.create(prev,eld);
end;


type
   TFLOOD=class(TStatement)
       exp1,exp2:TPrincipal;
       constructor create(prev,eld:TStatement);
       destructor destroy;override;
       procedure exec;override;
      end;

function  FLOODst(prev,eld:TStatement):TStatement;
   begin
      result:=TFLOOD.create(prev,eld);
   end;

constructor TFLOOD.create(prev,eld:TStatement);
begin
    graphmode:=true;
    inherited create(prev,eld);
    exp1:=nexpression;
    check(',',IDH_FLOOD);
    exp2:=nexpression;
end;

destructor TFLOOD.destroy;
begin
    exp1.free;
    exp2.free;
    inherited destroy
end;
{
procedure TFLOOD.exec;
var
  x,y:double;
  a,b:longint;
begin
   x:=exp1.evalX;
   y:=exp2.evalX;
   currenttransform.transform(x,y);
   a:=MyGraphSys.deviceX(x);
   b:=MyGraphSys.deviceY(y);
   MyGraphSys.FLOOD(a,b);
end;
}

type TTFlood=class(TPutmark0)
  procedure execute;override;
 end;

procedure TFLOOD.exec;
var
  x,y:double;
  a,b:longint;
begin
   x:=exp1.evalX;
   y:=exp2.evalX;
   currenttransform.transform(x,y);
   a:=MyGraphSys.deviceX(x);
   b:=MyGraphSys.deviceY(y);
   addQueue(TTFLOOD.create(a,b));
end;

procedure TTFLOOD.execute;
begin
   MyGraphSys.FLOOD(a,b);
end;


type
   TTFLOODFILL=class(TTFLOOD)
     procedure execute;override;
   end;

type
   TFLOODFILL=class(TFlood)
       procedure exec;override;
   end;

procedure TFLOODFILL.exec;
var
  x,y:double;
  a,b:longint;
begin
   x:=exp1.evalX;
   y:=exp2.evalX;
   currenttransform.transform(x,y);
   a:=MyGraphSys.deviceX(x);
   b:=MyGraphSys.deviceY(y);
   addQueue(TTFLOODFILL.create(a,b));
end;

procedure TTFLOODFILL.execute;
begin
      MyGraphSys.FloodFill(a,b);
end;

function  FLOODFILLst(prev,eld:TStatement):TStatement;
begin
   result:=TFLOODFILL.create(prev,eld);
end;


{*******}
{GDEVICE}
{*******}

function  GRAPHICSst(prev,eld:TStatement):TStatement;
begin
   if token='DEVICE' then
     begin
       gettoken ;
       if token='PRINTER' then
       begin
         gettoken;
         result:=TStatement.create(prev,eld);
         NextGraphMode:=PRTDirectMode;
       end
       {
       else if token='METAFILE' then
       begin
         gettoken;
         result:=TStatement.create(prev,eld);
         NextGraphMode:=PRTMetaFileMode;
       end;
       }
     end;

end;

{******}
{LOCATE}
{******}
type
  TLocate=class(TStatement)
      dev1, exp1, exp2, exp3:TPrincipal;
      nvar1:tVariable;
      sary1:TMatrix;
      NoWait:boolean;
     constructor create(prev,eld:TStatement);
     destructor destroy;override;
  end;

  TLocateChoice=class(TLocate)
     procedure exec;override;
  end;

  tLocateValue=class(TLocate)
     procedure exec;override;
  end;

constructor TLocate.create(prev,eld:TStatement);
var
  Valuest:boolean;
begin
  inherited create(prev,eld);
  Valuest:=false;
  if token='VALUE' then
    begin
     valuest:=true;
     if Nexttoken='NOWAIT' then
        begin
           NoWait:=true;
           gettoken;
        end;
    end;
  gettoken;
  if test('(') then
     begin

       if tokenspec=sidf then
          sary1:=SMatrixDim(1)
       else
          dev1:=NExpression;
       check(')',IDH_LOCATE)
     end;
  if Valuest and (token=',') and (nextToken='RANGE') then
    begin
      gettoken;
      gettoken;
      exp1:=NExpression;
      check('TO',IDH_LOCATE);
      exp2:=NExpression;
    end;
  if test(',') then
     begin
       check('AT',IDH_LOCATE);
       exp3:=NExpression;
     end;
  check(':',idh_locate);
  nvar1:=NVariable;
end;

destructor TLocate.destroy;
begin
  dev1.Free;
  sary1.Free;
  exp1.Free;
  exp2.Free;
  exp3.Free;
  nvar1.Free;
  inherited destroy;
end;

type
  TTLocateChoice=class(TResetBoolean)
    dev0,ini0:integer;
    Capts:TstringList;
    pr:PLongInt;
    constructor create(var s:boolean; dev00,ini00:integer; Capts0:TStringList; var r:longint);
    procedure ExecCore;override;
 end;

constructor TTLocateChoice.create(var s:boolean; dev00,ini00:integer; Capts0:TStringList; var r:longint);
begin
   inherited create(s);
   dev0:=dev00; ini0:=ini00;
   Capts:=Capts0;
   pr:=@r;
end;

procedure TTLocateChoice.ExecCore;
begin
    pr^:=LocateChoiceForm.Choice(dev0,ini0,Capts)
end;

procedure TLocateChoice.exec;
var
  dev0,ini0:integer;
  capts:TStringList;
  i:integer;
  s:boolean;
  r:longint;
begin
   sleep(50);        //2019/09/02 Ver 8.0.1.7
   with MyGraphsys do
      if beamMode=bmRigorous then beamOff;
   dev0:=8;
   ini0:=0;
   if dev1<>nil then
       begin
         dev0:=dev1.evalInteger;
         if dev0=1 then dev0:=8;    //first device has 8 buttons
       end;
   if exp3<>nil then
       ini0:=exp3.evalInteger;
   if (dev0>255) or (dev0<=0) then
       setexception(11140);
   capts:=TStringList.create;
   try
       if sary1=nil then
          for i:=1 to dev0 do
             Capts.Add(inttostr(i))
       else
         with TSArray(sary1.point) do
           begin
             dev0:=amount;
             for i:=0 to Dev0-1 do
                capts.add(ItemGetS(i));
           end;
       AddQueue(TTlocateChoice.create(s,dev0,ini0,Capts,r));
       while s do (TThread.CurrentThread).Yield  ;
       nvar1.assignLongint(r)
   finally
      capts.free
   end;
end;

type TTLocateValue=class(TResetBoolean)
  n:integer;
  vr,vi,nowait:boolean;
  left0,right0,ini0:double;
  Name0:Ansistring;
  pr:PDouble;
  constructor create(var s:boolean; n0:integer; vr0,vi0,nowait0:boolean;
                           left00,right00,ini00:double;Name00:Ansistring;
                           var r:double);
  procedure execCore;override;
end;

constructor TTLocateValue.create(var s:boolean; n0:integer; vr0,vi0,nowait0:boolean;
                           left00,right00,ini00:double;Name00:Ansistring;
                           var r:double);
begin
  inherited create(s);
  n:=n0; vr:=vr0; vi:=vi0; nowait:=nowait0; left0:=left00; right0:=right00; ini0:=ini00;
  Name0:=Name00; pr:=@r;
end;
procedure TTLocateValue.execCore;
begin
  pr^:=LocateForm.Value(n, vr,vi,nowait, left0,right0,ini0, Name0)
end;

procedure TlocateValue.exec;
var
   left0,right0,ini0,Val0:double;
   dev0:integer;
   Name0:String;
   s:boolean;
begin
   sleep(50);        //2019/09/02 Ver 8.0.1.7
   dev0:=1;
   if (dev1<>nil) then
       dev0:=dev1.evalInteger;
   if not dev0 in [1..MaxValueDevice]  then
       setexception(11152);

   if nvar1 is TSubstance then
      Name0:=TSubstance(nvar1).idr.name;

   if beamMode=bmRigorous then beamoff;
   if exp1<>nil then
     begin
      left0:=exp1.evalX;
      right0:=exp2.evalX;
     end;
   if exp3<>nil then
     ini0:=exp3.evalX;

   AddQueue(TTLocateValue.create(s,
                   dev0,exp1<>nil,exp3<>nil,NoWait,left0,right0,ini0,Name0,Val0));
   while s do  (TThread.CurrentThread).Yield  ;
   nvar1.assignX(val0);

end;



function  LOCATEst(prev,eld:TStatement):TStatement;
begin
 if token='POINT' then
   LOCATEst:=GETst(prev,eld)
 else if token='CHOICE' then
   LOCATEst:=TLocateChoice.create(prev,eld)
 else if token='VALUE' then
   LOCATEst:=TLocateValue.create(prev,eld)
end;


{**********}
{MAT LOCATE}
{**********}

type
   TMatLocate=class(TStatement)
      mat1,mat2:TMatrix;
      redim1,redim2:TMatRedim;
      dev1,exp3,exp4:TPrincipal;
      dim:byte;
      varilen:boolean;
      locatest:boolean;
     constructor create(prev,eld:TStatement);
     destructor destroy;override;
     procedure exec;override;
  end;

destructor TmatLocate.destroy;
begin
  mat1.Free;
  mat2.Free;
  redim1.free;
  redim2.Free;
  exp3.Free;
  exp4.Free;
  dev1.free;
  inherited destroy
end;

constructor TmatLocate.create(prev,eld:TStatement);
begin
   inherited create(prev,eld);
   graphmode:=true;
   locatest:=(PrevToken='LOCATE');
   CheckToken('POINT',IDH_GET);
   if test('(') then    //選択機構
   begin
      dev1:=NExpression;
      check(')',IDH_LOCATE)
   end;
   if test(',') then    //開始点
     begin
       check('AT',IDH_LOCATE);
       exp3:=NExpression;
       check(',',IDH_GET);
       exp4:=NExpression;
     end;

   check(':',IDH_GET);

   mat1:=NMatrix;
   //if mat1=nil then raise ESyntaxError.create('');
   dim:=Mat1.idr.dim;
   if dim>=3 then seterrdimension(Idh_GET);
   if token='(' then
      if nexttoken='?' then
         begin
           gettoken;
           gettoken;
           varilen:=true;
           if dim=2 then
                    check(',',IDH_GET);
           check(')',IDH_GET);
         end
      else
         redim1:=TMatRedim.create(mat1,false);

   if dim=1 then
     begin
        check(',',IDH_GET);
        mat2:=NMatrixDim(1);
        if varilen then
           begin
              check('(',IDH_GET);
              check('?',IDH_GET);
              check(')',IDH_GET);
           end
        else if token='(' then
           redim2:=TMatredim.create(mat2,false);
     end;

end;

//const DBL_MAX= 1.7976931348623158e+308;
procedure TmatLocate.exec;
var
   vx,vy,vx0,vy0:integer;
   maxlen:integer;
   x,y:double;
   i:integer;
   left,right:boolean;
   s:boolean;
begin
  //MyGraphsys.beam:=false;
  BeamOff;

  if exp3<>nil then
     PointAt(exp3,exp4);

  if varilen then
     begin
       vx0:=low(integer);
       vy0:=low(integer);
       case dim of
        1: maxlen:=min(TArray(mat1.point).MaxSize,TArray(mat2.point).MaxSize);
        2: begin
            maxlen:=TArray(mat1.point).MaxSize div 2;
            TArray(mat1.point).size[2]:=2;
           end;
       end;
       repeat
           sleep(10);
           //MyGraphSys.MousePol(vx,vy,left,right)
            AddQueue(TTMousePol.create(s,vx,vy,left,right));
            while s do  (TThread.CurrentThread).Yield  ;
        until left=false;
       repeat
           sleep(10);
           //MyGraphSys.MousePol(vx,vy,left,right)
            AddQueue(TTMousePol.create(s,vx,vy,left,right));
            while s do  (TThread.CurrentThread).Yield  ;
        until left=true;
       i:=0;
       while (i<maxlen) and (left=true) do
         begin
           if (vx<>vx0)or(vy<>vy0) then
             begin
               x:=MyGraphsys.virtualX(vx);
               y:=MyGraphsys.VirtualY(vy);
               if Locatest or CurrentTransform.InvTransform(x,y) then
                 case dim of
                 1:begin
                     TArray(mat1.point).ItemAssignX(i,x);
                     TArray(mat2.point).ItemAssignX(i,y);
                   end;
                 2:begin
                     with TArray(mat1.point) do ItemAssignX(i*size[2],  x);
                     with TArray(mat1.point) do ItemAssignX(i*size[2]+1,y);
                   end;
                 end
               else
                 setexception(-3009)  ;
             end;
           inc(i);
           sleep(20);
           //MyGraphSys.MousePol(vx,vy,left,right)
           AddQueue(TTMousePol.create(s,vx,vy,left,right));
           while s do  (TThread.CurrentThread).Yield  ;
         end;
       if i=maxlen then beep;
       case dim of
        1:begin
            TArray(mat1.point).size[1]:=i;
            TArray(mat2.point).size[1]:=i;
          end;
        2:begin
            TArray(mat1.point).size[1]:=i;
          end;
       end;
     end
  else
     begin  //上下限再定義
       if redim1<>nil then redim1.exec;
       if redim2<>nil then redim2.exec;
       case dim of
        1:begin
            maxlen:=TArray(mat1.point).size[1];
            if maxlen<>TArray(mat2.point).size[1] then
                setexception(6401);
          end;
        2:begin
            maxlen:=TArray(mat1.point).size[1];
            if TArray(mat1.point).size[2]<2 then
               setexception(6401);
          end;
       end;
       for i:=0 to maxlen-1 do
         begin
            //MyGraphsys.getpoint(vx,vy);
           WaitReady;
            AddQueue(TTGetPoint.create(s,vx,vy,LineNumb,true{NoBeamoff}));
            while s do  (TThread.CurrentThread).Yield  ;
            x:=MyGraphsys.virtualX(vx);
            y:=MyGraphsys.VirtualY(vy);
            if Locatest or CurrentTransform.InvTransform(x,y) then
              case dim of
               1:begin
                   TArray(mat1.point).ItemAssignX(i,x);
                   TArray(mat2.point).ItemAssignX(i,y);
                 end;
               2:begin
                   with TArray(mat1.point) do ItemAssignX(i*size[2],  x);
                   with TArray(mat1.point) do ItemAssignX(i*size[2]+1,y);
                 end;
               end
            else
               setexception(-3009) ;
         end;
     end;
end;


function MATLOCATEst(prev,eld:TStatement):TStatement;
begin
   MATLOCATEst:=TMatLocate.create(prev,eld);
end;


function SetBeamMode(s:AnsiString):boolean;
begin
   result:=true;
   s:=AnsiUpperCase(s);
   if s=s_Rigorous then
      BeamMode:=bmRigorous
   else if s=s_Immortal then
      BeamMode:=bmImmortal
   else
      result:=false;
end;

function AskBeamMode:AnsiString;
begin
   case BeamMode of
      bmRigorous: result:=s_Rigorous;
      else result:=s_Immortal;
   end;

end;


{************}
{InitGraphics}
{************}

procedure initGraphics;
begin
  case NextGraphMode of
    ScreenBitmapMode:
        MyGraphSys:=ScreenBMPGraphSys;
    PrtDirectMode:
       MyGraphSys:=PrtDirectGraphSys;
    end;
  MyGraphSys.initGraphic;
  LocateForm.InitValue;
  Graphic.beam:=true;
  Graphsys.BeamMode:=bmRigorous;
  Graphic.pointstyle:=3;
  Graphic.pointcolor:=1;
end;




{**********}
{initialize}
{**********}




function  OnlyMSst(prev,eld:TStatement):TStatement;
begin
   Seterr(PrevToken + s_MSmodeOnly, IDH_SYNTAX_MICROSOFT)  ;
end;

procedure statementTableinit;
begin
    StatementTableInitImperative('SET',SETst);
    StatementTableInitImperative('LOCATE',LOCATEst);
    StatementTableInitImperative('PLOT',PLOTst);
    StatementTableInitImperative('GRAPH',PLOTst);
    StatementTableInitImperative('CLEAR',CLEARst);
    StatementTableInitImperative('GET',GETst);
    StatementTableInitImperative('MOUSE',MOUSEst);   //動作不良
    if(NextGraphMode=ScreenBitMapMode) then
      begin
        StatementTableInitImperative('GLOAD',GLOADst);
        StatementTableInitImperative('GSAVE',GSAVEst);
        {$IFDEF Windows}
        StatementTableInitImperative('FLOOD',FLOODst);   //対応機能なし
        if permitMicrosoft  then
           StatementTableInitImperative('PAINT',PAINTst)
        else
           StatementTableInitImperative('PAINT',FLOODFILLst);
        {$ENDIF}
      end;
    if permitMicrosoft and (NextGraphMode=ScreenBitMapMode) then
      begin
          StatementTableInitImperative('COLOR',COLORst);
          StatementTableInitImperative('PSET',PSETst);
          StatementTableInitImperative('SCREEN',SCREENst);
          StatementTableInitImperative('CLS',CLSst);
          StatementTableInitImperative('CIRCLE',CIRCLEst);

      end
    else
      begin
          StatementTableInitDeclative('GRAPHICS',GRAPHICSst);
          StatementTableInitImperative('PSET',OnlyMSst);
          StatementTableInitImperative('SCREEN',OnlyMSst);
          StatementTableInitImperative('CLS',OnlyMSst);
          StatementTableInitImperative('CIRCLE',OnlyMSst);

      end ;
    StatementTableInitImperative('WINDOW',WINDOWst);

   end;



begin


    tableInitProcs.accept(statementTableinit) ;
end.
