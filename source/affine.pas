unit affine;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

(***************************************)
(* Copyright (C) 2006, SHIRAISHI Kazuo *)
(***************************************)

{$T+}
interface
uses variabl,math2sub;

{$MAXFPUREGISTERS default}
(*
    class Affine means:
    x'= xx * x + xy * y + xo
    y'= yx * x + yy * y + yo
*)
type
     TAffine=class
         {$A4}
         xx, yx, zx, ox:double;
         xy, yy, zy, oy:double;
         xz, yz, zz, oz:double;
         xo, yo, zo, oo:double;
         {$A+}
         next:TAffine;
         class function NewInstance: TObject;override;
         procedure FreeInstance;override;
         constructor Create;
         procedure make(transform:TObjectList);
         procedure scale1(a:double);
         procedure scale(a,b:double);
         procedure shift(a,b:double);
         procedure rotate(t:double);
         procedure rotate2(ct,st:double);
         procedure shear(t:double);
         procedure revmlt(m:TAffine);
         procedure mlt(m:TAffine);
         procedure cmlt(const c:complex);
         function transform(var x,y:double):boolean;
         function InvTransform(var x,y:double):boolean;
         function det:double;
         function IsAffine:boolean;
         function IsSimilarPositive:boolean;

        private
     end;

implementation
uses math,draw,base,vstack;

class function TAffine.NewInstance: TObject;
begin
   result:=InitInstance(getMemory(instancesize));
end;

procedure TAffine.FreeInstance;
begin
   freeMemory(instanceSize)
end;


constructor  TAffine.create;
begin
    inherited create;
	xx := 1.0;
	yy := 1.0;
        zz := 1.0;
        oo := 1.0;
end;

procedure TAffine.make(transform:TObjectList);
var
   i:integer;
   p:TTransformTerm;
begin
  i:=0;
  while (i<transform.count)  do
    begin
        TObject(p):=transform.items[i];
        p.exec(self);
        inc(i)
    end;
end;


function TAffine.transform(var x,y:double):boolean;
var
   cx,cy, c:double;
begin
   result:=true;
   if self=nil then exit;
   try
     cx := xx * x + xy * y + xo;
     cy := yx * x + yy * y + yo;
     c  := ox * x + oy * y + oo;
      if c=0 then begin result:=false; exit end;
     x:=cx / c;
     y:=cy / c;
   except
     result:=false;
   end;
end;

function TAffine.InvTransform(var x,y:double):boolean;
var
   cx,cy,c:double;
   dx,dy,dd:double;
begin
   result:=true;
   if self=nil then exit;

   try
      dx:= oo * x - xo;
      dy:= oo * y - yo;
      dd:= x * yo - y * xo;
      cx:= yy * dx - xy * dy - oy * dd;
      cy:= xx * dy - yx * dx + ox * dd;
      c := (xx * yy - yx * xy) - ox * (x * yy - y * xy) + oy * ( x * yx - y * xx);
      if c=0 then
             begin result:=false; exit end;
      x:=cx/c;
      y:=cy/c;
   except
     result:=false;
   end;
end;

procedure TAffine.scale1(a:double);
begin
	xx:=xx*a;
	xy:=xy*a;
        xz:=xz*a;
	xo:=xo*a;

	yx:=yx*a;
	yy:=yy*a;
        yz:=yz*a;
	yo:=yo*a;

	zx:=zx*a;
	zy:=zy*a;
        zz:=zz*a;
	zo:=zo*a;

end;

procedure TAffine.scale(a,b:double) ;
begin
	xx:=xx*a;
	xy:=xy*a;
        xz:=xz*a;
	xo:=xo*a;

	yx:=yx*b;
	yy:=yy*b;
        yz:=yz*b;
	yo:=yo*b;
end;


procedure TAffine.shift(a,b:double) ;
 begin
        xx:= xx + ox * a;
        xy:= xy + oy * a;
	xz:= xz + oz * a;
        xo:= xo + oo * a;

        yx:= yx + ox * b;
        yy:= yy + oy * b;
	yz:= yz + oz * b;
        yo:= yo + oo * b;
 end;

procedure TAffine.rotate(t:double);
begin
     rotate2(cos(t),sin(t))
end;

procedure TAffine.rotate2(ct,st:double);
var
   Nxx,Nxy,Nxz,Nxo,Nyx,Nyy,Nyz,Nyo:double;
begin
   Nxx := xx * ct - yx * st;
   Nxy := xy * ct - yy * st;
   Nxz := xz * ct - yz * st;
   Nxo := xo * ct - yo * st;

   Nyx := yx * ct + xx * st;
   Nyy := yy * ct + xy * st;
   Nyz := yz * ct + xz * st;
   Nyo := yo * ct + xo * st;

	xx := Nxx;
	xy := Nxy;
        xz := Nxz;
        xo := Nxo;

	yx := Nyx;
	yy := Nyy;
        yz := Nyz;
	yo := Nyo;
end;

procedure TAffine.cmlt(const c:complex);
begin
   rotate2(c.x,c.y)
end ;

procedure TAffine.shear(t:double);
var
   tt:double;
begin
   tt:=math.tan(t);
   xx := xx + yx * tt;
   xy := xy + yy * tt;
   xz := xz + yz * tt;
   xo := xo + yo * tt;
end;

procedure TAffine.revmlt(m:TAffine);
var
   Nxx,Nxy,Nxz,Nyx,Nyy,Nyz,Nzx,Nzy,Nzz,Nxo,Nyo,Nzo,Nox,Noy,Noz,Noo: double;
begin
	Nxx := m.xx * xx + m.yx * xy + m.zx * xz + m.ox * xo;
	Nxy := m.xy * xx + m.yy * xy + m.zy * xz + m.oy * xo;
        Nxz := m.xz * xx + m.yz * xy + m.zz * xz + m.oz * xo;
	Nxo := m.xo * xx + m.yo * xy + m.zo * xz + m.oo * xo;

	Nyx := m.xx * yx + m.yx * yy + m.zx * yz + m.ox * yo;
	Nyy := m.xy * yx + m.yy * yy + m.zy * yz + m.oy * yo;
        Nyz := m.xz * yx + m.yz * yy + m.zz * yz + m.oz * yo;
	Nyo := m.xo * yx + m.yo * yy + m.zo * yz + m.oo * yo;

	Nzx := m.xx * zx + m.yx * zy + m.zx * zz + m.ox * zo;
	Nzy := m.xy * zx + m.yy * zy + m.zy * zz + m.oy * zo;
        Nzz := m.xz * zx + m.yz * zy + m.zz * zz + m.oz * zo;
	Nzo := m.xo * zx + m.yo * zy + m.zo * zz + m.oo * zo;

	Nox := m.xx * ox + m.yx * oy + m.zx * oz + m.ox * oo;
	Noy := m.xy * ox + m.yy * oy + m.zy * oz + m.oy * oo;
        Noz := m.xz * ox + m.yz * oy + m.zz * oz + m.oz * oo;
	Noo := m.xo * ox + m.yo * oy + m.zo * oz + m.oo * oo;

	xx := Nxx;
	xy := Nxy;
        xz := Nxz;
	xo := Nxo;

	yx := Nyx;
	yy := Nyy;
        yz := Nyz;
	yo := Nyo;

        zx := Nzx;
        zy := Nzy;
        zz := Nzz;
        zo := Nzo;

        ox := Nox;
        oy := Noy;
        oz := Noz;
        oo := Noo;
end ;

procedure TAffine.mlt(m:TAffine);
var
   Nxx,Nxy,Nxz,Nyx,Nyy,Nyz,Nzx,Nzy,Nzz,Nxo,Nyo,Nzo,Nox,Noy,Noz,Noo:double;
begin
	Nxx := xx * m.xx + yx * m.xy + zx * m.xz + ox * m.xo;
	Nxy := xy * m.xx + yy * m.xy + zy * m.xz + oy * m.xo;
        Nxz := xz * m.xx + yz * m.xy + zz * m.xz + oz * m.xo;
	Nxo := xo * m.xx + yo * m.xy + zo * m.xz + oo * m.xo;

	Nyx := xx * m.yx + yx * m.yy + zx * m.yz + ox * m.yo;
	Nyy := xy * m.yx + yy * m.yy + zy * m.yz + oy * m.yo;
        Nyz := xz * m.yx + yz * m.yy + zz * m.yz + oz * m.yo;
	Nyo := xo * m.yx + yo * m.yy + zo * m.yz + oo * m.yo;

	Nzx := xx * m.zx + yx * m.zy + zx * m.zz + ox * m.zo;
	Nzy := xy * m.zx + yy * m.zy + zy * m.zz + oy * m.zo;
        Nzz := xz * m.zx + yz * m.zy + zz * m.zz + oz * m.zo;
	Nzo := xo * m.zx + yo * m.zy + zo * m.zz + oo * m.zo;

	Nox := xx * m.ox + yx * m.oy + zx * m.oz + ox * m.oo;
	Noy := xy * m.ox + yy * m.oy + zy * m.oz + oy * m.oo;
        Noz := xz * m.ox + yz * m.oy + zz * m.oz + oz * m.oo;
	Noo := xo * m.ox + yo * m.oy + zo * m.oz + oo * m.oo;

	xx := Nxx;
	xy := Nxy;
        xz := Nxz;
        xo := Nxo;

	yx := Nyx;
	yy := Nyy;
        yz := Nyz;
	yo := Nyo;

        zx := Nzx;
        zy := Nzy;
        zz := Nzz;
        zo := Nzo;

        ox := Nox;
        oy := Noy;
        oz := Noz;
        oo := Noo;
end ;



function TAffine.IsAffine:boolean;
begin
  result:=(ox=0) and (oy=0) and (oz=0)
end;

function TAffine.det:double;
begin
     det:=oo*(xx*yy - xy*yx)  +ox*(xy*yo - yy*xo) + oy*(yx*xo - xx*yo) ;
end ;

function TAffine.IsSimilarPositive:boolean;
var
   s,t,u:double;
begin
   result:=true;
   if self = nil then exit;

   s:=xx*xx + yx*yx;
   t:=yy*yy + xy*xy;
   u:=xx*xy + yx*yy;
   result:=isAffine and (s=t)and (abs(u/t)<1e-2) and (det>0)

end;
{$MAXFPUREGISTERS default}
end.


