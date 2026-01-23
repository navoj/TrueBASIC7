unit draw;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}
(***************************************)
(* Copyright (C) 2006, SHIRAISHI Kazuo *)
(***************************************)

{$X+}

interface
uses  Types, SysUtils,Graphics,
      affine, variabl;
type
   TTransformTerm=class
       procedure exec(p:Taffine);virtual;abstract;
   end;

function transformation:TObjectList;
var
   currenttransform:TAffine=nil;
   {currenttransformInv:TAffine=nil;}

implementation

uses
      arithmet, base,float,texthand,express,
      graphic,struct,confopt,helpctex,plottext,sconsts,graphsys,GraphQue;



type
   TTransformMatrix=class(TTransformTerm)
          mat:TMatrix;
       constructor  create;
       procedure exec(p:Taffine);override;
       destructor  destroy;override;
   end;

   TTransformFunction=class(TTransformTerm)
          exp1,exp2:TPrincipal;
       destructor  destroy;override;
   end;

   TSHIFT=class(TTransformFunction)
       constructor  create;
       procedure exec(p:Taffine);override;
   end;

   TSCALE=class(TTransformFunction)
       constructor  create(e1:TPrincipal);
   end;

   TSCALE1=class(TSCALE)
       procedure exec(p:Taffine);override;
   end;

   TSCALEC=class(TSCALE)
       procedure exec(p:Taffine);override;
   end;

   TSCALE2=class(TSCALE)
       constructor create(e1:TPrincipal);
       procedure exec(p:Taffine);override;
   end;

   TROTATE=class(TTransformFunction)
        rad:double;
        cost,sint:double;
       constructor  create;
       procedure exec(p:Taffine);override;
   end;

   TSHEAR=class(TTransformFunction)
        rad:double;
       constructor  create;
       procedure exec(p:Taffine);override;
   end;


   TcurrentTransform=class(TTransformFunction)
       procedure exec(p:Taffine);override;
   end;


type
   ESyntaxError=class(Exception);

constructor TTransformMatrix.create;
begin
    inherited create;
    mat:=NMatrix;
    if mat=nil then raise ESyntaxError.create('');
    if mat.idr.dim<>2 then begin seterrdimension(IDH_PICTURE);raise ESyntaxError.create('') end
end;


constructor TSHIFT.create;
begin
    inherited create;
    gettoken;    { keyword }
    gettoken;    { '(' }
    exp1:=NExpression;
    if (ProgramUnit.arithmetic=PrecisionComplex) and (token<>',') then exit;
    check(',',IDH_PICTURE);
    exp2:=NExpression;
end;

constructor TSCALE.create(e1:TPrincipal);
begin
    inherited create;
    exp1:=e1;
end;

constructor TSCALE2.create(e1:TPrincipal);
begin
    inherited create(e1);
    gettoken;
    exp2:=NExpression;
end;


function scale:TSCALE;
var
   exp1:TPrincipal;
begin
    gettoken;    { keyword }
    gettoken;    { '(' }
    exp1:=NExpression;
    if token=',' then
       result:=TSCALE2.create(exp1)
    else if ProgramUnit.arithmetic=PrecisionComplex then
       result:=TSCALEC.create(exp1)
    else
       result:=TSCALE1.create(exp1)
end;

constructor TROTATE.create;
var
   x:double;
begin
    inherited create;
    gettoken;    { keyword }
    gettoken;    { '(' }
    exp1:=NExpression;
    if confirmedDegrees then
       rad:=pi/180
    else
       rad:=1;
    if (exp1=nil) then begin raise ESyntaxError.create('') end;
    if (exp1.isConstant) then
       begin
           x:=exp1.evalX;
           cost:=cos(x*rad);
           sint:=sin(x*rad);
           exp1.free;
           exp1:=nil;
        end;
end;

constructor TShear.create;
begin
    inherited create;
    gettoken;    { keyword }
    gettoken;    { '(' }
    exp1:=NExpression;
    if confirmedDegrees then
       rad:=pi/180
    else 
       rad:=1;
    if (exp1=nil) then
                  begin raise ESyntaxError.create('') end;
end;

destructor TTransformmatrix.destroy;
begin
    mat.free;
    inherited destroy;
end;

destructor TTransformFunction.destroy;
begin
    exp1.free;
    exp2.free;
    inherited destroy;
end;

procedure TSHIFT.exec(p:Taffine);
var
   c:complex;
begin
   if (exp2=nil) then
      begin
         exp1.evalC(c);
         p.shift(c.x, c.y)
      end
   else
      p.shift(exp1.evalX,exp2.evalX) ;
end;

procedure TSCALE1.exec(p:TAffine);
begin
   p.scale1(exp1.evalX) ;
end;

procedure TSCALE2.exec(p:TAffine);
begin
   p.scale(exp1.evalX,exp2.evalX)
end;

procedure TSCALEC.exec(p:TAffine);
var
   c:complex;
begin
  exp1.evalC(c);
  p.cmlt(c)
end;


procedure TROTATE.exec(p:TAffine);
begin
   if exp1=nil then
      p.rotate2(cost,sint)
   else
      p.rotate(exp1.evalX*rad)
end;

procedure TSHEAR.exec(p:TAffine);
begin
    p.shear(exp1.evalX * rad)
end;


procedure TTRansformMatrix.exec(p:Taffine);
var
   NArray:TArray;
   m:TAffine;
begin
   NArray:=TArray(mat.point);
   if (NArray<>nil) and (NArray.dim=2)
       and (NArray.size[1]=4) and (NArray.size[2]=4) then
       begin
          m:=TAffine.create;
          try
            with NArray do
             try
               ItemGetF(0,          m.xx);
               ItemGetF(1*size[2],  m.xy);
               ItemGetF(2*size[2],  m.xz);
               ItemGetF(3*size[2],  m.xo);
               ItemGetF(          1,m.yx);
               ItemGetF(1*size[2]+1,m.yy);
               ItemGetF(2*size[2]+1,m.yz);
               ItemGetF(3*size[2]+1,m.yo);
               ItemGetF(          2,m.zx);
               ItemGetF(1*size[2]+2,m.zy);
               ItemGetF(2*size[2]+2,m.zz);
               ItemGetF(3*size[2]+2,m.zo);
               ItemGetF(          3,m.ox);
               ItemGetF(1*size[2]+3,m.oy);
               ItemGetF(2*size[2]+3,m.oz);
               ItemGetF(3*size[2]+3,m.oo);
             except
               setexception(-3009)
             end;
            p.mlt(m);
          finally
            m.free;
          end;
      end
   else
       setexception(6201);
end;


procedure TCurrentTransform.exec(p:Taffine);
begin
  if CurrentTransform<>nil then  p.mlt(currenttransform);
end;



function drawaxes0(x,y:double):boolean;forward;
function drawgrid0(x,y:double):boolean;forward;
function drawaxes2(x,y:double):boolean;forward;
function drawgrid2(x,y:double):boolean;forward;
function drawcircle(x,y:double):boolean;forward;
function drawdisk(x,y:double):boolean;forward;


type
   TDRAW=class(TCALL)
           transform:TObjectList;   {collection of PTransformterm }
           substitution: function(x,y:double):boolean;   {AXES,GRID}
           exp1,exp2:TPrincipal;
           NoBeamOff:boolean;
       constructor create(prev,eld:TStatement);
       destructor destroy;override;
       procedure exec;override;
        function OverflowErCode:integer;override;
        function InvalidErCode:integer;override;
        function OpName:string;override;

   end;

function DRAWst(prev,eld:TStatement):TStatement;
begin
    DRAWst:=TDRAW.create(prev,eld);
    graphmode:=true;
end;

function transformation:TObjectList;
var
   p:TTransformTerm;
   s:boolean;
begin
   result:=TObjectList.create(4);
   try
           s:=true;
           repeat
              p:=nil;
              if nexttoken='(' then
                 begin
                    if token='SHIFT' then
                       p:=TSHIFT.create
                    else if token='SCALE' then
                       p:=scale
                    else if token='ROTATE' then
                       p:=TROTATE.create
                    else if token='SHEAR' then
                       p:=TSHEAR.create
                    else
                       seterrillegal(token,IDH_PICTURE);
                    check(')',IDH_PICTURE);
                 end
              else if token='TRANSFORM' then
                 begin
                    gettoken;
                    p:=TCurrentTransform.create
                 end
              else
                 p:=TTransformMatrix.create;
              if p<>nil then result.add(p);
              if token='*' then
                  gettoken
              else
                  s:=false;
           until s=false;
    except
      on syntaxError do
        begin
          result.free;
          result:=nil;
        end;
    end;
end;

constructor TDRAW.create;
var
   index0:integer;
   routine0:TRoutine;
   svcp:tokensave;
   retry:boolean;
   substitution0: function(x,y:double):boolean;
begin
    if ProgramUnit.ExternalSubTable.search(token,index0)
       or CurModule.ShareSubTable.search(token,index0)
       or CurrentProgram.inquire(token,routine0)
          and (routine0.kind='P') and not (routine0 is TProgramUnit) then
           inherited create(prev,eld,'P')
    else
       begin
          try
            savetoken(svcp);
            retry:=false;
            inherited create(prev,eld,'P');
            if ForceSubPictDeclare and (routine is TProgramUnit) then
              begin
                retry:=true;
                destroy;
              end;
          except
            On SyntaxError do retry:=true;
          end;
          if retry then
            begin
              restoretoken(svcp);
              @substitution0:=nil;
              if token='AXES0' then
                   substitution0:=drawaxes0
              else if token='GRID0' then
                   substitution0:=drawgrid0
              else if token='AXES' then
                   substitution0:=drawaxes2
              else if token='GRID' then
                   substitution0:=drawgrid2
              else if token='CIRCLE' then
                   substitution0:=drawcircle
              else if token='DISK' then
                  begin
                   substitution0:=drawdisk;
                   NoBeamOff:=true;
                  end;
              if @substitution0<>nil then
                begin
                    inherited TStatementCreate(prev,eld);
                    params:=nil;
                    substitution:=substitution0;
                    gettoken;
                    if token='(' then
                       begin
                          check('(',IDH_DRAW_axes);
                          exp1:=NExpression;
                          check(',',IDH_DRAW_axes);
                          exp2:=NExpression;
                          check(')',IDH_DRAW_axes);
                       end;
                end
             else
                seterrIllegal(token,IDH_PICTURE);


          end;
     end;


     if token='WITH' then
        begin
           gettoken;
           transform:=Transformation;
           if transform=nil then seterr('',IDH_PICTURE);
       end;
end;

destructor TDRAW.destroy;
begin
   transform.free;
   exp1.free;        //2011.3.8
   exp2.free;        //2011.3.8
   inherited destroy;
end;

procedure push(a:TAffine);
begin
   a.next:=currenttransform;
   currenttransform:=a;
end;

procedure pop;
var
   temp:TAffine;
begin
  with currenttransform do
  begin
   temp:=next ;
   free;
  end;
   currenttransform:=temp;
end;

type
   TManBeam=Class(TGraphCommand)
     c:boolean;
     constructor create(c0:boolean);
     procedure execute;override;
   end;
constructor Tmanbeam.create(c0:boolean);
begin
  inherited create;
  c:=c0;
end;
procedure TManBeam.execute;
begin
      MyGraphSys.beam:=MyGraphSys.beam
                      and ((Graphsys.BeamMode=bmImmortal)or c)
end;

procedure TDRAW.exec;
var
  a:TAffine;
begin
   //WaitReady;
   try
      if transform<>nil then
         begin
             a:=Taffine.create;
             //WaitReady;  //ver.8.0.2    2020.02.09  //ver. 8.2.0 2025.05.16
             push(a);              //  aはcurrenttransfromを指す
             currentoperation:=self;
             a.make(transform);
             if a.next<>nil then
                          a.mlt(a.next);
             currentoperation:=nil;
         end;

         if (BeamMode=bmImmortal)
            or (Routine<>nil) and Routine.NoBeamOff
            or (Routine=nil) and NobeamOff then
         else
               Beamoff;

      if @substitution=nil then
         inherited exec
       else if exp1=nil then
         substitution(1,1)
       else
         substitution(abs(exp1.evalX),abs(exp2.evalX));

      if (BeamMode=bmImmortal)
         or (Routine<>nil) and Routine.NoBeamOff
         or (Routine=nil) and NobeamOff then
      else
            Beamoff;

   finally
     //WaitReady;    //ver. 8.0.2   2020.02.09    //ver. 8.2.0 2025.05.16
     if transform<>nil then
            pop;
   end;
end;

function TDRAW.OverflowErCode:integer;
begin
  result:=-1005
end;

function TDRAW.InvalidErCode:integer;
begin
   result:=-3009
end;

function TDRAW.OpName:string;
begin
   result:=s_TDrawOpName;
end;

{**************}
{axes and grids}
{**************}

function convtodevice(x,y:double; var i,j:integer):boolean;
begin
   result:=currenttransform.transform(x,y)
       and MyGraphSys.ConvToDevicex(x,i)
       and MyGraphSys.ConvToDevicey(y,j);
end;

function convtovirtual(i,j:integer; var x,y:double):boolean;
begin
    x:=MyGraphSys.virtualx(i);
    y:=MyGraphSys.virtualy(j);
    result:=currenttransform.invtransform(x,y);
end;

function getboundary(var xmin,xmax,ymin,ymax:double):boolean;
 function imax(a,b:integer):integer;
 begin
    if a<b then imax:=b
    else imax:=a
 end;
 function max(a,b:double):double;
 begin
    if a<b then max:=b
    else max:=a
 end;
 function min(a,b:double):double;
 begin
    if a<b then min:=a
    else min:=b
 end;
var
  p:array[1..4]of array[1..2] of double;
  i:integer;
  w:word;
  cont:boolean;
begin
  cont:=true;
  with MyGraphSys.ClipRect do
    begin
    cont:=convtovirtual(left,top,p[1][1],p[1][2])
      and convtovirtual(left,bottom,p[2][1],p[2][2])
      and convtovirtual(right,top,p[3][1],p[3][2])
      and convtovirtual(right,bottom,p[4][1],p[4][2]);
    end;

  if cont then
    begin
      xmin:=p[1][1];
      for i:=2 to 4 do xmin:=min(p[i][1],xmin);
      xmax:=p[1][1];
      for i:=2 to 4 do xmax:=max(p[i][1],xmax);
      ymin:=p[1][2];
      for i:=2 to 4 do ymin:=min(p[i][2],ymin);
      ymax:=p[1][2];
      for i:=2 to 4 do ymax:=max(p[i][2],ymax);
    end;
  result:=cont;
end;


type
   TLine=class(TGraphCommand)
       a1,b1,a2,b2:integer;
       c:integer;
       ps:TPenStyle;
       w:integer;
       constructor create(a10,b10,a20,b20:integer; c0:integer; ps0:TPenStyle; w0:integer);
       procedure execute;override;
   end;

constructor TLine.create(a10,b10,a20,b20:integer; c0:integer; ps0:TPenStyle; w0:integer);
begin
  inherited create;
  a1:=a10; b1:=b10; a2:=a20; b2:=b20; c:=c0; ps:=ps0; w:=w0;
end;

procedure TLine.execute;
begin
  MyGraphSys.Line(a1,b1,a2,b2,c,ps,w)
end;


 procedure line1(a1,b1,a2,b2:integer);
 begin
   with MyGraphSys do
     AddQueue(Tline.create(a1,b1,a2,b2,axescolor,psSolid,linewidth));
 end;

 procedure line2(a1,b1,a2,b2:integer);
 begin
   with MyGraphSys do
     AddQueue(Tline.create(a1,b1,a2,b2,axescolor,psDot,1));
 end;

function axessub:boolean;
var
   xmin,xmax,ymin,ymax:double;
   i1,i2,j1,j2:integer;
begin
   axessub:=true;

   if getboundary(xmin,xmax,ymin,ymax)then
     begin
       if convtodevice(xmin,0,i1,j1) and
          convtodevice(xmax,0,i2,j2) then
          line1(i1,j1,i2,j2);

       if convtodevice(0,ymin,i1,j1) and
          convtodevice(0,ymax,i2,j2) then
          line1(i1,j1,i2,j2);
     end;
end;

function ceil(x:double):double;forward;
function floor(x:double):double;
begin
   if x>=0 then floor:=int(x)
   else       floor:=-ceil(-x)
 end;

function ceil(x:double):double;
begin
   if x>=0 then
      begin
          if int(x)=x then
              ceil:=int(x)
          else
              ceil:=int(x)+1
      end
   else ceil:=-floor(-x)
end;

function marksub(sx,sy:double):boolean;
var
   x,y:double;
   xmin,xmax,ymin,ymax:double;
   i,j:integer;
   svpointstyle:byte;
   svpointcolor:integer;
begin
   marksub:=true;
   if (sx=0) or (sy=0) then exit;

   WaitReady;
   svpointstyle:=getpointstyle;
   svpointcolor:=getpointcolor;
   setpointstyle(2);
   setpointcolor(axescolor);

   if getboundary(xmin,xmax,ymin,ymax) then
     begin
       xmin:=floor(xmin/sx)*sx;
       ymin:=floor(ymin/sy)*sy;
       xmax:=ceil(xmax/sx)*sx;
       ymax:=ceil(ymax/sy)*sy;

       x:=xmin;
       if (sx>0) and ((xmax-xmin)/sx<1024) then
       while (x<=xmax + sx/2) do
            begin
                if convtodevice(x,0,i,j) then
                   AddQueue(TPutMark0.create(i,j));
                x:=x+sx;
                //idle;
            end;

       y:=ymin;
       if (sy>0) and ((ymax-ymin)/sy<1024) then
       while (y<=ymax +sy/2) do
            begin
                if convtodevice(0,y,i,j) then
                   AddQueue(TPutMark0.create(i,j));
                y:=y+sy;
                //idle;
            end;
     end;

   setpointstyle(svpointstyle);
   setpointcolor(svpointcolor);
end;


function gridsub(sx,sy:double):boolean;
var
   x,y:double;
   xmin,xmax,ymin,ymax:double;
   i1,i2,j1,j2:integer;
begin
   gridsub:=true;
   if (sx=0) or (sy=0) then exit;

   getboundary(xmin,xmax,ymin,ymax);
   xmin:=floor(xmin/sx)*sx;
   ymin:=floor(ymin/sy)*sy;
   xmax:=ceil(xmax/sx)*sx;
   ymax:=ceil(ymax/sy)*sy;

   x:=xmin;
   if (sx>0) and ((xmax-xmin)/sx<1024) then
   while (x<=xmax +sx/2) do
        begin
            if convtodevice(x,ymin,i1,j1) and
               convtodevice(x,ymax,i2,j2) then
               line2(i1,j1,i2,j2);
            x:=x+sx;
            //idle;
        end;

   y:=ymin;
   if (sy>0) and ((ymax-ymin)/sy<1024) then
   while (y<=ymax +sy/2)  do
        begin
            if convtodevice(xmin,y,i1,j1) and
               convtodevice(xmax,y,i2,j2) then
               line2(i1,j1,i2,j2);
            y:=y+sy;
            //idle;
        end;

end;

function str3(x,sx:double):string;
  function int(sx:double):longint;
  begin
      result:=trunc(sx);
      if (sx<0) and (result<>sx) then dec(result)
  end;
var
  a,b,n:number;
  i:longint;
begin
  convert(x,a);
  i:=2-int(system.ln(sx)/system.ln(10));
  initlongint(n,i);
  arithmet.round(a,n,b);
  result:=DSTR(b);
end;

type
   TTextOut=class(TGraphCommand)
     x,y:integer;  s:ansistring; angle:integer;
     constructor create(x0,y0:integer; const s0:ansistring; angle0:integer);
     procedure execute;override;
 end;
 constructor TTextout.create(x0,y0:integer; const s0:ansistring; angle0:integer);
 begin
   inherited create;
   x:=x0; y:=y0; s:=s0; angle:=angle0
 end;
 procedure TTextOut.execute;
 begin
   MyGraphSys.TextOut(x,y,s,angle)
 end;


function CoordinateSub(sx,sy:double):boolean;
var
   x,y:double;
   xmin,xmax,ymin,ymax:double;
   i,j:integer;
   svtextcolor:integer;
   svTjH:tjHorizontal;
   svTjV:tjVirtical;
   s:string;
begin
   result:=true;
   if (sx=0) or (sy=0) then exit;

   WaitReady;
   svtextcolor:=gettextcolor;
   settextcolor(axesColor);
   svTjH:=MyGraphSys.Hjustify;
   svTjV:=MyGraphSys.Vjustify;
   MyGraphSys.Hjustify:=TjRight;
   MyGraphSys.Vjustify:=TjTop;

   if getboundary(xmin,xmax,ymin,ymax) then
     begin
       xmin:=floor(xmin/sx)*sx;
       ymin:=floor(ymin/sy)*sy;
       xmax:=ceil(xmax/sx)*sx;
       ymax:=ceil(ymax/sy)*sy;

       x:=xmin;
       if (sx<>0) and ((xmax-xmin)/sx<1024) then
       while (x<=xmax +sx/2)  do
            begin
                s:=str3(x,sx);
                if convtodevice(x,0,i,j) then
                   AddQueue(TTextout.create(i,j,s, MyGraphSys.xdirection(x,0)));
                x:=x+sx;
                //idle;
            end;

       y:=ymin;
       if (sy<>0) and ((ymax-ymin)/sy<1024) then
       while (y<=ymax +sy/2)  do
            begin
                s:=str3(y,sy);
                if convtodevice(0,y,i,j) then
                   AddQueue(TTextout.create(i,j,s, MyGraphSys.xdirection(0,y)));
                y:=y+sy;
                //idle;
            end;
     end;

   WaitReady;
   setTextColor(svTextColor);
   MyGraphSys.Hjustify:=svTjH;
   MyGraphSys.Vjustify:=svTjV;
end;


function drawaxes0(x,y:double):boolean;
begin
  WaitReady;
   drawaxes0:=axessub and marksub(x,y)
end;

function drawgrid0(x,y:double):boolean;
begin
  WaitReady;
   drawgrid0:=gridsub(x,y) and axessub
end;

function drawaxes2(x,y:double):boolean;
begin
  WaitReady;
   drawaxes2:=axessub and marksub(x,y)  and CoordinateSub(x,y)
end;

function drawgrid2(x,y:double):boolean;
begin
  WaitReady;
   drawgrid2:=gridsub(x,y) and axessub  and CoordinateSub(x,y)
end;

function drawcircle(x,y:double):boolean;
var
   points:array[0..360] of TPoint;
   i,j:integer;
   n,k:integer;
begin
   k:=0;
   for n:=0 to 360 do
   begin
     x:=cos(n/180*pi);
     y:=sin(n/180*pi);
     if convtodevice(x,y,i,j) then
        begin
         points[k].x:=restrict(i);
         points[k].y:=restrict(j);
         inc(k)
        end;
   end;
    AddQueue(TPolyLine.create(slice(Points,k)) );
   result:=true;
end;


function drawdisk(x,y:double):boolean;
var
   points:array[0..359] of TPoint;
   i,j:integer;
   n,k:integer;
begin
   k:=0;
   for n:=0 to 359 do
   begin
     x:=cos(n/180*pi);
     y:=sin(n/180*pi);
     if convtodevice(x,y,i,j) then
       begin
         points[k].x:=restrict(i);
         points[k].y:=restrict(j);
         inc(k);
       end;
   end;
    AddQueue(TPolygon.create(Slice(Points,k)));
   result:=true;
end;



{
function transformInv(var x,y:double):boolean;
begin
   result:=currenttransform.invtransform(x,y);
end;
}

procedure statementTableinit;
begin
          StatementTableInitImperative('DRAW',DRAWst);
end;

begin
    tableInitProcs.accept(statementTableinit) ;
    //graphic.transform:=transform;
    //graphic.inversetransform:=transforminv;

end.




