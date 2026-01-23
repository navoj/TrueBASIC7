unit plottext;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}
(***************************************)
(* Copyright (C) 2006, SHIRAISHI Kazuo *)
(***************************************)


interface

implementation
uses SysUtils,Classes,
     listcoll,base,texthand,variabl,struct,express,
     draw,graphic,helpctex,using,graphsys,GraphQue,MyThread;

type
     TSetTextJustify=class(TStatement)
          exp1:TPrincipal;
          exp2:TPrincipal;
        constructor create(prev,eld:TStatement);
        destructor destroy;override;
        procedure exec;override;
      end;

constructor TSetTextJustify.create(prev,eld:TStatement);
begin
   inherited create(prev,eld);
   exp1:=SExpression;
   check(',',IDH_SET_TEXT_JUSTIFY);
   exp2:=SExpression;
end;

destructor TSetTextJustify.destroy;
begin
     exp1.free;
     exp2.free;
    inherited destroy
end;


procedure TSetTextJustify.exec;
var
   s1,s2:ansistring;
   h:tjHorizontal;
   v:tjVirtical;
begin
   s1:=exp1.evalS;
   s2:=exp2.evalS;
   s1:=ansiUpperCase(s1);
   s2:=ansiUpperCase(s2);
   WaitReady;

         h:=tjLEFT;
         while (h<=tjRIGHT) and (Hjustification[h]<>s1) do inc(h);
         if ord(h)<=ord(tjRIGHT) then
            MyGraphSys.Hjustify:=h
         else
            //if insideofwhen or not JISSetWindow then
            // setexception(4102) ;
            ReportException(InsideOfWhen  , 4102);

        v:=tjTOP;
        while (v<=tjBOTTOM) and (Vjustification[v]<>s2) do inc(v);
        if ord(v)<=ord(tjBOTTOM) then
           MyGraphSys.Vjustify:=v
        else
           //if insideofwhen  or not JISSetWindow then
           //setexception(4102) ;
           ReportException(InsideOfWhen , 4102);


end;

function SetTextJustifyst(prev,eld:TStatement):TStatement;
begin
   SetTextJustifyst:=TSetTextJustify.create(prev,eld)
end;


type
   TPlotText=class(TStatement)
         exp1,exp2,exp3:TPrincipal;
         image:TPrincipal;
         items:TListCollection;
         GraphStm:boolean;
         LabelStm:boolean;
         LettersStm:boolean;
     constructor create(prev,eld:TStatement);
     destructor destroy;override;
     procedure exec;override;
    private
     function formatted:ansistring;
   end;


function PlotTextst(prev,eld:TStatement):TStatement;
begin
    PlotTextst:=TPlotText.create(prev,eld);
end;



constructor TPLotText.create(prev,eld:TStatement); //2011.3.5
begin
   inherited create(prev,eld);
   GraphStm:=(prevToken='GRAPH');
   //LabelStm:=(Token='LABEL');
   //LettersStm:=(Token='LETTERS') or TextPhysicalCoordinate and not LabelStm;
   LabelStm:=(Token='TEXT') and TextPhysicalCoordinate  or (Token='LABEL');   //ver.8.1.3  2024.12.16
   gettoken;
   check(',',IDH_TEXT);
   check('AT',IDH_TEXT);
   exp1:=NEXpression;
   if (programunit.Arithmetic=PrecisionComplex)
       and ((token=':') or (token=',') and (nexttoken='USING')
                           and not((nextnexttoken=',') or (nextnexttoken=':'))) then
      //  複素座標
   else
      begin
        check(',',IDH_TEXT);
        exp2:=NExpression;
      end;
   if test(',') then
      begin
         CheckToken('USING',IDH_TEXT);
         image:=ImageRef;
         checkToken(':',IDH_PRINT_USING);
         items:=TListCollection.create;
         repeat
             items.insert(NSExpression);
         until test(',')=false;
      end
   else
      begin
       check(':',IDH_TEXT);
       exp3:=SExpression;
      end;
end;





destructor TPLotText.destroy;
begin
     exp1.free;
     exp2.free;
     exp3.free;
   items.free;
   image.free;
    inherited destroy
end;

type TextPrc=procedure(const n,m:double; const s:ansistring) of object;
type
   TTextPrc=class(TgraphCommand)
    prc:textprc;
    n,m:double;
    s:ansistring;
    constructor create(prc0:textprc; n0,m0:double; s0:ansistring);
    procedure execute;override;
   end;

constructor TTextPrc.create(prc0:textprc; n0,m0:double; s0:ansistring);
begin
   inherited create;
   prc:=prc0;
   n:=n0; m:=m0;
   s:=s0;
end;

procedure TTextPrc.execute;
begin
   with MyGraphSys do prc(n,m,s)
end;

procedure TPlotText.exec;    //2011.3.5
var
   n,m:double;
   z:complex;
   s:ansistring;
begin
   with MyGraphSys do
      if graphsys.BeamMode=bmRigorous then graphic.beamoff;
   if exp2<>nil then
      begin
        n:=exp1.evalX;
        m:=exp2.evalX;
      end
   else
      begin
        exp1.evalC(z);
        n:=z.x;
        m:=z.y;
      end;
   if exp3<>nil then
       s:=exp3.evalS
   else
       s:=Formatted;
   if GraphStm then
      if Labelstm then
         AddQueue(TTextPrc.create(MyGraphSys.PutText,n,m,s)) //MyGraphSys.PutText(n,m,s)
      else
         AddQueue(TTextPrc.create(MyGraphSys.Graphtext,n,m,s))
   else if currentTransform.transform(n,m) then
      if LabelStm then
         AddQueue(TTextPrc.create(MyGraphSys.puttext,n,m,s))
      else if LettersStm then
         AddQueue(TTextprc.create(MyGraphSys.PlotLetters,n,m,s))
      else
         begin
           AddQueue(TTextPrc.create(MyGraphSys.Plottext,n,m,s));
         end;
   RepaintRequest:=true;
   WaitReady;      //2025.05.24  //ver.8.1.4.1

end;





function TPlotText.formatted:ansistring;
var
   form:ansistring;
   c,i,code:integer;
begin
   result:='';
   if image<>nil then
     form:=image.evalS;
   i:=1;
   result:=literals(form,i);
   c:=0;
   while (c<items.count) do
      begin
        result:=result + TPrincipal(items.items[c]).format(form,i,code);
        if code<>0 then
           ReportException(insideofWhen,code,TPrincipal(items.items[c]).str);
        inc(c);
        result:=result +literals(form,i)
      end;

end;

begin
   graphic.settextjustifyst:=settextjustifyst;
   graphic.plottextst:=plottextst;
end.
