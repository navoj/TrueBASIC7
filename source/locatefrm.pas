unit LocateFrm;

{$MODE Delphi}

interface

uses
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls;


type

  { TLocateForm }

  TLocateForm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Name1: TLabel;
    Name2: TLabel;
    Name3: TLabel;
    name4: TLabel;
    name5: TLabel;
    Name6: TLabel;
    Name7: TLabel;
    Name8: TLabel;
    name9: TLabel;
    name10: TLabel;
    Name11: TLabel;
    Name12: TLabel;
    Name13: TLabel;
    name14: TLabel;
    name15: TLabel;
    Name16: TLabel;
    Name17: TLabel;
    Name18: TLabel;
    name19: TLabel;
    name20: TLabel;

    TrackBar1: TTrackBar;
    TrackBar2: TTrackBar;
    TrackBar3: TTrackBar;
    TrackBar4: TTrackBar;
    TrackBar5: TTrackBar;
    TrackBar6: TTrackBar;
    TrackBar7: TTrackBar;
    TrackBar8: TTrackBar;
    TrackBar9: TTrackBar;
    TrackBar10: TTrackBar;
    TrackBar11: TTrackBar;
    TrackBar12: TTrackBar;
    TrackBar13: TTrackBar;
    TrackBar14: TTrackBar;
    TrackBar15: TTrackBar;
    TrackBar16: TTrackBar;
    TrackBar17: TTrackBar;
    TrackBar18: TTrackBar;
    TrackBar19: TTrackBar;
    TrackBar20: TTrackBar;

    OkButton: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    function Value(n:integer; vr,vi,nowait:boolean;
                              left0,right0,ini0:double;Name0:Ansistring):double;
    procedure InitValue;

    procedure TrackBar1Change(Sender: TObject);
    procedure TrackBar2Change(Sender: TObject);
    procedure TrackBar3Change(Sender: TObject);
    procedure TrackBar4Change(Sender: TObject);
    procedure TrackBar5Change(Sender: TObject);
    procedure TrackBar6Change(Sender: TObject);
    procedure TrackBar7Change(Sender: TObject);
    procedure TrackBar8Change(Sender: TObject);
    procedure TrackBar9Change(Sender: TObject);
    procedure TrackBar10Change(Sender: TObject);
    procedure TrackBar11Change(Sender: TObject);
    procedure TrackBar12Change(Sender: TObject);
    procedure TrackBar13Change(Sender: TObject);
    procedure TrackBar14Change(Sender: TObject);
    procedure TrackBar15Change(Sender: TObject);
    procedure TrackBar16Change(Sender: TObject);
    procedure TrackBar17Change(Sender: TObject);
    procedure TrackBar18Change(Sender: TObject);
    procedure TrackBar19Change(Sender: TObject);
    procedure TrackBar20Change(Sender: TObject);
  private
    valuet1,left1,right1:double;
    valuet2,left2,right2:double;
    valuet3,left3,right3:double;
    valuet4,left4,right4:double;
    valuet5,left5,right5:double;
    valuet6,left6,right6:double;
    valuet7,left7,right7:double;
    valuet8,left8,right8:double;
    valuet9,left9,right9:double;
    valuet10,left10,right10:double;
    valuet11,left11,right11:double;
    valuet12,left12,right12:double;
    valuet13,left13,right13:double;
    valuet14,left14,right14:double;
    valuet15,left15,right15:double;
    valuet16,left16,right16:double;
    valuet17,left17,right17:double;
    valuet18,left18,right18:double;
    valuet19,left19,right19:double;
    valuet20,left20,right20:double;

    function Value1(vr,vi,nowait:boolean; left0,right0,ini0:double; Name0:Ansistring):double;
    function Value2(vr,vi,nowait:boolean; left0,right0,ini0:double; Name0:Ansistring):double;
    function Value3(vr,vi,nowait:boolean; left0,right0,ini0:double; Name0:Ansistring):double;
    function Value4(vr,vi,nowait:boolean; left0,right0,ini0:double; Name0:Ansistring):double;
    function Value5(vr,vi,nowait:boolean; left0,right0,ini0:double; Name0:Ansistring):double;
    function Value6(vr,vi,nowait:boolean; left0,right0,ini0:double; Name0:Ansistring):double;
    function Value7(vr,vi,nowait:boolean; left0,right0,ini0:double; Name0:Ansistring):double;
    function Value8(vr,vi,nowait:boolean; left0,right0,ini0:double; Name0:Ansistring):double;
    function Value9(vr,vi,nowait:boolean; left0,right0,ini0:double; Name0:Ansistring):double;
    function Value10(vr,vi,nowait:boolean; left0,right0,ini0:double; Name0:Ansistring):double;
    function Value11(vr,vi,nowait:boolean; left0,right0,ini0:double; Name0:Ansistring):double;
    function Value12(vr,vi,nowait:boolean; left0,right0,ini0:double; Name0:Ansistring):double;
    function Value13(vr,vi,nowait:boolean; left0,right0,ini0:double; Name0:Ansistring):double;
    function Value14(vr,vi,nowait:boolean; left0,right0,ini0:double; Name0:Ansistring):double;
    function Value15(vr,vi,nowait:boolean; left0,right0,ini0:double; Name0:Ansistring):double;
    function Value16(vr,vi,nowait:boolean; left0,right0,ini0:double; Name0:Ansistring):double;
    function Value17(vr,vi,nowait:boolean; left0,right0,ini0:double; Name0:Ansistring):double;
    function Value18(vr,vi,nowait:boolean; left0,right0,ini0:double; Name0:Ansistring):double;
    function Value19(vr,vi,nowait:boolean; left0,right0,ini0:double; Name0:Ansistring):double;
    function Value20(vr,vi,nowait:boolean; left0,right0,ini0:double; Name0:Ansistring):double;

  end;

var
  LocateForm: TLocateForm;

implementation
uses Base,Struct,PaintFrm;
{$R *.lfm}

function TLocateForm.Value(n:integer; vr,vi,nowait:boolean;
                           left0,right0,ini0:double;Name0:Ansistring):double;
begin
 case n of
 1:  result:=value1(vr,vi,nowait,left0,right0,ini0,Name0);
 2:  result:=value2(vr,vi,nowait,left0,right0,ini0,Name0);
 3:  result:=value3(vr,vi,nowait,left0,right0,ini0,Name0);
 4:  result:=value4(vr,vi,nowait,left0,right0,ini0,Name0);
 5:  result:=value5(vr,vi,nowait,left0,right0,ini0,Name0);
 6:  result:=value6(vr,vi,nowait,left0,right0,ini0,Name0);
 7:  result:=value7(vr,vi,nowait,left0,right0,ini0,Name0);
 8:  result:=value8(vr,vi,nowait,left0,right0,ini0,Name0);
 9:  result:=value9(vr,vi,nowait,left0,right0,ini0,Name0);
 10: result:=value10(vr,vi,nowait,left0,right0,ini0,Name0);
 11: result:=value11(vr,vi,nowait,left0,right0,ini0,Name0);
 12: result:=value12(vr,vi,nowait,left0,right0,ini0,Name0);
 13: result:=value13(vr,vi,nowait,left0,right0,ini0,Name0);
 14: result:=value14(vr,vi,nowait,left0,right0,ini0,Name0);
 15: result:=value15(vr,vi,nowait,left0,right0,ini0,Name0);
 16: result:=value16(vr,vi,nowait,left0,right0,ini0,Name0);
 17: result:=value17(vr,vi,nowait,left0,right0,ini0,Name0);
 18: result:=value18(vr,vi,nowait,left0,right0,ini0,Name0);
 19: result:=value19(vr,vi,nowait,left0,right0,ini0,Name0);
 20: result:=value20(vr,vi,nowait,left0,right0,ini0,Name0);
 else
     setexception(11140);
 end;
end;

function TLocateForm.Value1(vr,vi,nowait:boolean; left0,right0,ini0:double; Name0:Ansistring):double;
begin
   name1.Caption:=name0;
   OkButton.Visible:=not nowait;
   name1.Visible:=true;

   if vr then
     begin
      left1:=left0;
      right1:=right0;
     end;

   if vi then
      valuet1:=ini0;

   if (valuet1-left1)*(valuet1-right1)>0 then
      if vi then
         setexception(11152)
      else
         valuet1:=(left0+right0)/2.0;

   with TrackBar1 do
            Position:=round(min+(valuet1-left1)/(right1-left1)*(max-min));
   TrackBar1Change(self);

   TrackBar1.Visible:=true;
   TrackBar1.Enabled:=true;
   WindowState:=wsNormal;
   if nowait then
        show
   else
     begin
       TrackBar2.Enabled:=false;
       TrackBar3.Enabled:=false;
       TrackBar4.Enabled:=false;
       TrackBar5.Enabled:=false;
       TrackBar6.Enabled:=false;
       TrackBar7.Enabled:=false;
       TrackBar8.Enabled:=false;
       TrackBar9.Enabled:=false;
       TrackBar10.Enabled:=false;
       TrackBar11.Enabled:=false;
       TrackBar12.Enabled:=false;
       TrackBar13.Enabled:=false;
       TrackBar14.Enabled:=false;
       TrackBar15.Enabled:=false;
       TrackBar16.Enabled:=false;
       TrackBar17.Enabled:=false;
       TrackBar18.Enabled:=false;
       TrackBar19.Enabled:=false;
       TrackBar20.Enabled:=false;
       ShowModal;
       if ModalResult<>mrOk then
          CtrlBreakHit:=true ;
       TrackBar1.Enabled:=false;
     end;
   Application.ProcessMessages;
   result:=valuet1;

end;

function TLocateForm.Value2(vr,vi,nowait:boolean; left0,right0,ini0:double; Name0:Ansistring):double;
begin
   name2.Caption:=name0;
   OkButton.Visible:=not nowait;
   if ClientHeight<2*50 then ClientHeight:=2*50;
   name2.Visible:=true;

   if vr then
     begin
      left2:=left0;
      right2:=right0;
     end;

   if vi then
      valuet2:=ini0;

   if (valuet2-left2)*(valuet2-right2)>0 then
      if vi then
         setexception(11152)
      else
         valuet2:=(left0+right0)/2.0;

   with TrackBar2 do
            Position:=round(min+(valuet2-left2)/(right2-left2)*(max-min));
   TrackBar2Change(self);

   TrackBar2.Visible:=true;
   TrackBar2.Enabled:=true;
   WindowState:=wsNormal;
   if nowait then
         Show
   else
     begin
       TrackBar1.Enabled:=false;
       TrackBar3.Enabled:=false;
       TrackBar4.Enabled:=false;
       TrackBar5.Enabled:=false;
       TrackBar6.Enabled:=false;
       TrackBar7.Enabled:=false;
       TrackBar8.Enabled:=false;
       TrackBar9.Enabled:=false;
       TrackBar10.Enabled:=false;
       TrackBar11.Enabled:=false;
       TrackBar12.Enabled:=false;
       TrackBar13.Enabled:=false;
       TrackBar14.Enabled:=false;
       TrackBar15.Enabled:=false;
       TrackBar16.Enabled:=false;
       TrackBar17.Enabled:=false;
       TrackBar18.Enabled:=false;
       TrackBar19.Enabled:=false;
       TrackBar20.Enabled:=false;
       ShowModal;
       if ModalResult<>mrOk then
          CtrlBreakHit:=true ;
       TrackBar2.Enabled:=false;
     end;
   Application.ProcessMessages;
   result:=valuet2 ;
end;



function TLocateForm.Value3(vr,vi,nowait:boolean; left0,right0,ini0:double; Name0:Ansistring):double;
begin
   name3.Caption:=name0;
   OkButton.Visible:=not nowait;
   if ClientHeight<3*50 then ClientHeight:=3*50;
   name3.Visible:=true;

   if vr then
     begin
      left3:=left0;
      right3:=right0;
     end;

   if vi then
      valuet3:=ini0;

   if (valuet3-left3)*(valuet3-right3)>0 then
      if vi then
        setexception(11152)
      else
         valuet3:=(left0+right0)/2.0;

   with TrackBar3 do
            Position:=round(min+(valuet3-left3)/(right3-left3)*(max-min));
   TrackBar3Change(self);

   TrackBar3.Visible:=true;
   TrackBar3.Enabled:=true;
   WindowState:=wsNormal;
   if nowait then
         Show
   else
     begin
       TrackBar1.Enabled:=false;
       TrackBar2.Enabled:=false;
       TrackBar4.Enabled:=false;
       TrackBar5.Enabled:=false;
       TrackBar6.Enabled:=false;
       TrackBar7.Enabled:=false;
       TrackBar8.Enabled:=false;
       TrackBar9.Enabled:=false;
       TrackBar10.Enabled:=false;
       TrackBar11.Enabled:=false;
       TrackBar12.Enabled:=false;
       TrackBar13.Enabled:=false;
       TrackBar14.Enabled:=false;
       TrackBar15.Enabled:=false;
       TrackBar16.Enabled:=false;
       TrackBar17.Enabled:=false;
       TrackBar18.Enabled:=false;
       TrackBar19.Enabled:=false;
       TrackBar20.Enabled:=false;
       ShowModal;
       if ModalResult<>mrOk then
          CtrlBreakHit:=true ;
       TrackBar3.Enabled:=false;
     end;
   Application.ProcessMessages;
   result:=valuet3;
end;

function TLocateForm.Value4(vr,vi,nowait:boolean; left0,right0,ini0:double; Name0:Ansistring):double;
begin
   name4.Caption:=name0;
   OkButton.Visible:=not nowait;
   if ClientHeight<4*50 then ClientHeight:=4*50;
   name4.Visible:=true;

   if vr then
     begin
      left4:=left0;
      right4:=right0;
     end;

   if vi then
      valuet4:=ini0;

   if (valuet4-left4)*(valuet4-right4)>0 then
      if vi then
        setexception(11152)
      else
         valuet4:=(left0+right0)/2.0;

   with TrackBar4 do
            Position:=round(min+(valuet4-left4)/(right4-left4)*(max-min));
   TrackBar4Change(self);

   TrackBar4.Visible:=true;
   TrackBar4.Enabled:=true;
   WindowState:=wsNormal;
   if nowait then
     Show
   else
     begin
       TrackBar1.Enabled:=false;
       TrackBar2.Enabled:=false;
       TrackBar3.Enabled:=false;
       TrackBar5.Enabled:=false;
       TrackBar6.Enabled:=false;
       TrackBar7.Enabled:=false;
       TrackBar8.Enabled:=false;
       TrackBar9.Enabled:=false;
       TrackBar10.Enabled:=false;
       TrackBar11.Enabled:=false;
       TrackBar12.Enabled:=false;
       TrackBar13.Enabled:=false;
       TrackBar14.Enabled:=false;
       TrackBar15.Enabled:=false;
       TrackBar16.Enabled:=false;
       TrackBar17.Enabled:=false;
       TrackBar18.Enabled:=false;
       TrackBar19.Enabled:=false;
       TrackBar20.Enabled:=false;
       ShowModal;
       if ModalResult<>mrOk then
          CtrlBreakHit:=true ;
       TrackBar4.Enabled:=false;
     end;
   Application.ProcessMessages;
   result:=valuet4;
end;

function TLocateForm.Value5(vr,vi,nowait:boolean; left0,right0,ini0:double; Name0:Ansistring):double;
begin
   name5.Caption:=name0;
   OkButton.Visible:=not nowait;
   if ClientHeight<5*50 then ClientHeight:=5*50;
   name5.Visible:=true;

   if vr then
     begin
      left5:=left0;
      right5:=right0;
     end;

   if vi then
      valuet5:=ini0;

   if (valuet5-left5)*(valuet5-right5)>0 then
      if vi then
        setexception(11152)
      else
         valuet5:=(left0+right0)/2.0;

   with TrackBar5 do
            Position:=round(min+(valuet5-left5)/(right5-left5)*(max-min));
   TrackBar5Change(self);

   TrackBar5.Visible:=true;
   TrackBar5.Enabled:=true;
   WindowState:=wsNormal;
   if nowait then
         Show
   else
     begin
       TrackBar1.Enabled:=false;
       TrackBar2.Enabled:=false;
       TrackBar3.Enabled:=false;
       TrackBar4.Enabled:=false;
       TrackBar6.Enabled:=false;
       TrackBar7.Enabled:=false;
       TrackBar8.Enabled:=false;
       TrackBar9.Enabled:=false;
       TrackBar10.Enabled:=false;
       TrackBar11.Enabled:=false;
       TrackBar12.Enabled:=false;
       TrackBar13.Enabled:=false;
       TrackBar14.Enabled:=false;
       TrackBar15.Enabled:=false;
       TrackBar16.Enabled:=false;
       TrackBar17.Enabled:=false;
       TrackBar18.Enabled:=false;
       TrackBar19.Enabled:=false;
       TrackBar20.Enabled:=false;
       ShowModal;
       if ModalResult<>mrOk then
          CtrlBreakHit:=true ;
       TrackBar1.Enabled:=false;
     end;
   Application.ProcessMessages;
   result:=valuet5;
end;

function TLocateForm.Value6(vr, vi, nowait: boolean; left0, right0,
  ini0: double; Name0: Ansistring): double;
begin
 name6.Caption:=name0;
 OkButton.Visible:=not nowait;
 if ClientHeight<6*50 then ClientHeight:=6*50;
 name6.Visible:=true;

 if vr then
   begin
    left6:=left0;
    right6:=right0;
   end;

 if vi then
    valuet6:=ini0;

 if (valuet6-left6)*(valuet6-right6)>0 then
    if vi then
      setexception(11152)
    else
       valuet6:=(left0+right0)/2.0;

 with TrackBar6 do
          Position:=round(min+(valuet6-left6)/(right6-left6)*(max-min));
 TrackBar6Change(self);

 TrackBar6.Visible:=true;
 TrackBar6.Enabled:=true;
 WindowState:=wsNormal;
 if nowait then
       Show
 else
   begin
     TrackBar1.Enabled:=false;
     TrackBar2.Enabled:=false;
     TrackBar3.Enabled:=false;
     TrackBar4.Enabled:=false;
     TrackBar5.Enabled:=false;
     TrackBar7.Enabled:=false;
     TrackBar8.Enabled:=false;
     TrackBar9.Enabled:=false;
     TrackBar10.Enabled:=false;
     TrackBar11.Enabled:=false;
     TrackBar12.Enabled:=false;
     TrackBar13.Enabled:=false;
     TrackBar14.Enabled:=false;
     TrackBar15.Enabled:=false;
     TrackBar16.Enabled:=false;
     TrackBar17.Enabled:=false;
     TrackBar18.Enabled:=false;
     TrackBar19.Enabled:=false;
     TrackBar20.Enabled:=false;
     ShowModal;
     if ModalResult<>mrOk then
        CtrlBreakHit:=true ;
     TrackBar1.Enabled:=false;
   end;
 Application.ProcessMessages;
 result:=valuet6;
end;

function TLocateForm.Value7(vr, vi, nowait: boolean; left0, right0,
  ini0: double; Name0: Ansistring): double;
begin
 name7.Caption:=name0;
 OkButton.Visible:=not nowait;
 if ClientHeight<7*50 then ClientHeight:=7*50;
 name7.Visible:=true;

 if vr then
   begin
    left7:=left0;
    right7:=right0;
   end;

 if vi then
    valuet7:=ini0;

 if (valuet7-left7)*(valuet7-right7)>0 then
    if vi then
      setexception(11152)
    else
       valuet7:=(left0+right0)/2.0;

 with TrackBar7 do
          Position:=round(min+(valuet7-left7)/(right7-left7)*(max-min));
 TrackBar7Change(self);

 TrackBar7.Visible:=true;
 TrackBar7.Enabled:=true;
 WindowState:=wsNormal;
 if nowait then
       Show
 else
   begin
     TrackBar1.Enabled:=false;
     TrackBar2.Enabled:=false;
     TrackBar3.Enabled:=false;
     TrackBar4.Enabled:=false;
     TrackBar5.Enabled:=false;
     TrackBar6.Enabled:=false;
     TrackBar8.Enabled:=false;
     TrackBar9.Enabled:=false;
     TrackBar10.Enabled:=false;
     TrackBar11.Enabled:=false;
     TrackBar12.Enabled:=false;
     TrackBar13.Enabled:=false;
     TrackBar14.Enabled:=false;
     TrackBar15.Enabled:=false;
     TrackBar16.Enabled:=false;
     TrackBar17.Enabled:=false;
     TrackBar18.Enabled:=false;
     TrackBar19.Enabled:=false;
     TrackBar20.Enabled:=false;
     ShowModal;
     if ModalResult<>mrOk then
        CtrlBreakHit:=true ;
     TrackBar1.Enabled:=false;
   end;
 Application.ProcessMessages;
 result:=valuet7;
end;

function TLocateForm.Value8(vr, vi, nowait: boolean; left0, right0,
  ini0: double; Name0: Ansistring): double;
begin
 name8.Caption:=name0;
 OkButton.Visible:=not nowait;
 if ClientHeight<8*50 then ClientHeight:=8*50;
 name8.Visible:=true;

 if vr then
   begin
    left8:=left0;
    right8:=right0;
   end;

 if vi then
    valuet8:=ini0;

 if (valuet8-left8)*(valuet8-right8)>0 then
    if vi then
      setexception(11152)
    else
       valuet8:=(left0+right0)/2.0;

 with TrackBar8 do
          Position:=round(min+(valuet8-left8)/(right8-left8)*(max-min));
 TrackBar8Change(self);

 TrackBar8.Visible:=true;
 TrackBar8.Enabled:=true;
 WindowState:=wsNormal;
 if nowait then
       Show
 else
   begin
     TrackBar1.Enabled:=false;
     TrackBar2.Enabled:=false;
     TrackBar3.Enabled:=false;
     TrackBar4.Enabled:=false;
     TrackBar5.Enabled:=false;
     TrackBar6.Enabled:=false;
     TrackBar7.Enabled:=false;
     TrackBar9.Enabled:=false;
     TrackBar10.Enabled:=false;
     TrackBar11.Enabled:=false;
     TrackBar12.Enabled:=false;
     TrackBar13.Enabled:=false;
     TrackBar14.Enabled:=false;
     TrackBar15.Enabled:=false;
     TrackBar16.Enabled:=false;
     TrackBar17.Enabled:=false;
     TrackBar18.Enabled:=false;
     TrackBar19.Enabled:=false;
     TrackBar20.Enabled:=false;
     ShowModal;
     if ModalResult<>mrOk then
        CtrlBreakHit:=true ;
     TrackBar1.Enabled:=false;
   end;
 Application.ProcessMessages;
 result:=valuet8;
end;

function TLocateForm.Value9(vr, vi, nowait: boolean; left0, right0,
  ini0: double; Name0: Ansistring): double;
begin
 name9.Caption:=name0;
 OkButton.Visible:=not nowait;
 if ClientHeight<9*50 then ClientHeight:=9*50;
 name9.Visible:=true;

 if vr then
   begin
    left9:=left0;
    right9:=right0;
   end;

 if vi then
    valuet9:=ini0;

 if (valuet9-left9)*(valuet9-right9)>0 then
    if vi then
      setexception(11152)
    else
       valuet9:=(left0+right0)/2.0;

 with TrackBar9 do
          Position:=round(min+(valuet9-left9)/(right9-left9)*(max-min));
 TrackBar9Change(self);

 TrackBar9.Visible:=true;
 TrackBar9.Enabled:=true;
 WindowState:=wsNormal;
 if nowait then
       Show
 else
   begin
     TrackBar1.Enabled:=false;
     TrackBar2.Enabled:=false;
     TrackBar3.Enabled:=false;
     TrackBar4.Enabled:=false;
     TrackBar5.Enabled:=false;
     TrackBar6.Enabled:=false;
     TrackBar7.Enabled:=false;
     TrackBar8.Enabled:=false;
     TrackBar10.Enabled:=false;
     TrackBar11.Enabled:=false;
     TrackBar12.Enabled:=false;
     TrackBar13.Enabled:=false;
     TrackBar14.Enabled:=false;
     TrackBar15.Enabled:=false;
     TrackBar16.Enabled:=false;
     TrackBar17.Enabled:=false;
     TrackBar18.Enabled:=false;
     TrackBar19.Enabled:=false;
     TrackBar20.Enabled:=false;
     ShowModal;
     if ModalResult<>mrOk then
        CtrlBreakHit:=true ;
     TrackBar1.Enabled:=false;
   end;
 Application.ProcessMessages;
 result:=valuet9;
end;

function TLocateForm.Value10(vr, vi, nowait: boolean; left0, right0,
  ini0: double; Name0: Ansistring): double;
begin
 name10.Caption:=name0;
 OkButton.Visible:=not nowait;
 if ClientHeight<10*50 then ClientHeight:=10*50;
 name10.Visible:=true;

 if vr then
   begin
    left10:=left0;
    right10:=right0;
   end;

 if vi then
    valuet10:=ini0;

 if (valuet10-left10)*(valuet10-right10)>0 then
    if vi then
      setexception(11152)
    else
       valuet10:=(left0+right0)/2.0;

 with TrackBar10 do
          Position:=round(min+(valuet10-left10)/(right10-left10)*(max-min));
 TrackBar10Change(self);

 TrackBar10.Visible:=true;
 TrackBar10.Enabled:=true;
 WindowState:=wsNormal;
 if nowait then
       Show
 else
   begin
     TrackBar1.Enabled:=false;
     TrackBar2.Enabled:=false;
     TrackBar3.Enabled:=false;
     TrackBar4.Enabled:=false;
     TrackBar5.Enabled:=false;
     TrackBar6.Enabled:=false;
     TrackBar7.Enabled:=false;
     TrackBar8.Enabled:=false;
     TrackBar9.Enabled:=false;
     TrackBar11.Enabled:=false;
     TrackBar12.Enabled:=false;
     TrackBar13.Enabled:=false;
     TrackBar14.Enabled:=false;
     TrackBar15.Enabled:=false;
     TrackBar16.Enabled:=false;
     TrackBar17.Enabled:=false;
     TrackBar18.Enabled:=false;
     TrackBar19.Enabled:=false;
     TrackBar20.Enabled:=false;
     ShowModal;
     if ModalResult<>mrOk then
        CtrlBreakHit:=true ;
     TrackBar1.Enabled:=false;
   end;
 Application.ProcessMessages;
 result:=valuet10;
end;

function TLocateForm.Value11(vr, vi, nowait: boolean; left0, right0,
  ini0: double; Name0: Ansistring): double;
begin
 name11.Caption:=name0;
 OkButton.Visible:=not nowait;
 if ClientHeight<11*50 then ClientHeight:=11*50;
 name11.Visible:=true;

 if vr then
   begin
    left11:=left0;
    right11:=right0;
   end;

 if vi then
    valuet11:=ini0;

 if (valuet11-left11)*(valuet11-right11)>0 then
    if vi then
      setexception(11152)
    else
       valuet11:=(left0+right0)/2.0;

 with TrackBar11 do
          Position:=round(min+(valuet11-left11)/(right11-left11)*(max-min));
 TrackBar11Change(self);

 TrackBar11.Visible:=true;
 TrackBar11.Enabled:=true;
 WindowState:=wsNormal;
 if nowait then
       Show
 else
   begin
     TrackBar1.Enabled:=false;
     TrackBar2.Enabled:=false;
     TrackBar3.Enabled:=false;
     TrackBar4.Enabled:=false;
     TrackBar5.Enabled:=false;
     TrackBar6.Enabled:=false;
     TrackBar7.Enabled:=false;
     TrackBar8.Enabled:=false;
     TrackBar9.Enabled:=false;
     TrackBar10.Enabled:=false;
     TrackBar12.Enabled:=false;
     TrackBar13.Enabled:=false;
     TrackBar14.Enabled:=false;
     TrackBar15.Enabled:=false;
     TrackBar16.Enabled:=false;
     TrackBar17.Enabled:=false;
     TrackBar18.Enabled:=false;
     TrackBar19.Enabled:=false;
     TrackBar20.Enabled:=false;
     ShowModal;
     if ModalResult<>mrOk then
        CtrlBreakHit:=true ;
     TrackBar1.Enabled:=false;
   end;
 Application.ProcessMessages;
 result:=valuet11;
end;

function TLocateForm.Value12(vr, vi, nowait: boolean; left0, right0,
  ini0: double; Name0: Ansistring): double;
begin
 name12.Caption:=name0;
 OkButton.Visible:=not nowait;
 if ClientHeight<12*50 then ClientHeight:=12*50;
 name12.Visible:=true;

 if vr then
   begin
    left12:=left0;
    right12:=right0;
   end;

 if vi then
    valuet12:=ini0;

 if (valuet12-left12)*(valuet12-right12)>0 then
    if vi then
      setexception(11152)
    else
       valuet12:=(left0+right0)/2.0;

 with TrackBar12 do
          Position:=round(min+(valuet12-left12)/(right12-left12)*(max-min));
 TrackBar12Change(self);

 TrackBar12.Visible:=true;
 TrackBar12.Enabled:=true;
 WindowState:=wsNormal;
 if nowait then
       Show
 else
   begin
     TrackBar1.Enabled:=false;
     TrackBar2.Enabled:=false;
     TrackBar3.Enabled:=false;
     TrackBar4.Enabled:=false;
     TrackBar5.Enabled:=false;
     TrackBar6.Enabled:=false;
     TrackBar7.Enabled:=false;
     TrackBar8.Enabled:=false;
     TrackBar9.Enabled:=false;
     TrackBar10.Enabled:=false;
     TrackBar11.Enabled:=false;
     TrackBar13.Enabled:=false;
     TrackBar14.Enabled:=false;
     TrackBar15.Enabled:=false;
     TrackBar16.Enabled:=false;
     TrackBar17.Enabled:=false;
     TrackBar18.Enabled:=false;
     TrackBar19.Enabled:=false;
     TrackBar20.Enabled:=false;
     ShowModal;
     if ModalResult<>mrOk then
        CtrlBreakHit:=true ;
     TrackBar1.Enabled:=false;
   end;
 Application.ProcessMessages;
 result:=valuet12;
end;

function TLocateForm.Value13(vr, vi, nowait: boolean; left0, right0,
  ini0: double; Name0: Ansistring): double;
begin
 name13.Caption:=name0;
 OkButton.Visible:=not nowait;
 if ClientHeight<13*50 then ClientHeight:=13*50;
 name13.Visible:=true;

 if vr then
   begin
    left13:=left0;
    right13:=right0;
   end;

 if vi then
    valuet13:=ini0;

 if (valuet13-left13)*(valuet13-right13)>0 then
    if vi then
      setexception(11152)
    else
       valuet13:=(left0+right0)/2.0;

 with TrackBar13 do
          Position:=round(min+(valuet13-left13)/(right13-left13)*(max-min));
 TrackBar13Change(self);

 TrackBar13.Visible:=true;
 TrackBar13.Enabled:=true;
 WindowState:=wsNormal;
 if nowait then
       Show
 else
   begin
     TrackBar1.Enabled:=false;
     TrackBar2.Enabled:=false;
     TrackBar3.Enabled:=false;
     TrackBar4.Enabled:=false;
     TrackBar5.Enabled:=false;
     TrackBar6.Enabled:=false;
     TrackBar7.Enabled:=false;
     TrackBar8.Enabled:=false;
     TrackBar9.Enabled:=false;
     TrackBar10.Enabled:=false;
     TrackBar11.Enabled:=false;
     TrackBar12.Enabled:=false;
     TrackBar14.Enabled:=false;
     TrackBar15.Enabled:=false;
     TrackBar16.Enabled:=false;
     TrackBar17.Enabled:=false;
     TrackBar18.Enabled:=false;
     TrackBar19.Enabled:=false;
     TrackBar20.Enabled:=false;
     ShowModal;
     if ModalResult<>mrOk then
        CtrlBreakHit:=true ;
     TrackBar1.Enabled:=false;
   end;
 Application.ProcessMessages;
 result:=valuet13;
end;

function TLocateForm.Value14(vr, vi, nowait: boolean; left0, right0,
  ini0: double; Name0: Ansistring): double;
begin
 name14.Caption:=name0;
 OkButton.Visible:=not nowait;
 if ClientHeight<14*50 then ClientHeight:=14*50;
 name14.Visible:=true;

 if vr then
   begin
    left14:=left0;
    right14:=right0;
   end;

 if vi then
    valuet14:=ini0;

 if (valuet14-left14)*(valuet14-right14)>0 then
    if vi then
      setexception(11152)
    else
       valuet14:=(left0+right0)/2.0;

 with TrackBar14 do
          Position:=round(min+(valuet14-left14)/(right14-left14)*(max-min));
 TrackBar14Change(self);

 TrackBar14.Visible:=true;
 TrackBar14.Enabled:=true;
 WindowState:=wsNormal;
 if nowait then
       Show
 else
   begin
     TrackBar1.Enabled:=false;
     TrackBar2.Enabled:=false;
     TrackBar3.Enabled:=false;
     TrackBar4.Enabled:=false;
     TrackBar5.Enabled:=false;
     TrackBar6.Enabled:=false;
     TrackBar7.Enabled:=false;
     TrackBar8.Enabled:=false;
     TrackBar9.Enabled:=false;
     TrackBar10.Enabled:=false;
     TrackBar11.Enabled:=false;
     TrackBar12.Enabled:=false;
     TrackBar13.Enabled:=false;
     TrackBar15.Enabled:=false;
     TrackBar16.Enabled:=false;
     TrackBar17.Enabled:=false;
     TrackBar18.Enabled:=false;
     TrackBar19.Enabled:=false;
     TrackBar20.Enabled:=false;
     ShowModal;
     if ModalResult<>mrOk then
        CtrlBreakHit:=true ;
     TrackBar1.Enabled:=false;
   end;
 Application.ProcessMessages;
 result:=valuet14;
end;

function TLocateForm.Value15(vr, vi, nowait: boolean; left0, right0,
  ini0: double; Name0: Ansistring): double;
begin
 name15.Caption:=name0;
 OkButton.Visible:=not nowait;
 if ClientHeight<15*50 then ClientHeight:=15*50;
 name15.Visible:=true;

 if vr then
   begin
    left15:=left0;
    right15:=right0;
   end;

 if vi then
    valuet15:=ini0;

 if (valuet15-left15)*(valuet15-right15)>0 then
    if vi then
      setexception(11152)
    else
       valuet15:=(left0+right0)/2.0;

 with TrackBar15 do
          Position:=round(min+(valuet15-left15)/(right15-left15)*(max-min));
 TrackBar15Change(self);

 TrackBar15.Visible:=true;
 TrackBar15.Enabled:=true;
 WindowState:=wsNormal;
 if nowait then
       Show
 else
   begin
     TrackBar1.Enabled:=false;
     TrackBar2.Enabled:=false;
     TrackBar3.Enabled:=false;
     TrackBar4.Enabled:=false;
     TrackBar5.Enabled:=false;
     TrackBar6.Enabled:=false;
     TrackBar7.Enabled:=false;
     TrackBar8.Enabled:=false;
     TrackBar9.Enabled:=false;
     TrackBar10.Enabled:=false;
     TrackBar11.Enabled:=false;
     TrackBar12.Enabled:=false;
     TrackBar13.Enabled:=false;
     TrackBar14.Enabled:=false;
     TrackBar16.Enabled:=false;
     TrackBar17.Enabled:=false;
     TrackBar18.Enabled:=false;
     TrackBar19.Enabled:=false;
     TrackBar20.Enabled:=false;
     ShowModal;
     if ModalResult<>mrOk then
        CtrlBreakHit:=true ;
     TrackBar1.Enabled:=false;
   end;
 Application.ProcessMessages;
 result:=valuet15;
end;

function TLocateForm.Value16(vr, vi, nowait: boolean; left0, right0,
  ini0: double; Name0: Ansistring): double;
begin
 name16.Caption:=name0;
 OkButton.Visible:=not nowait;
 if ClientHeight<16*50 then ClientHeight:=16*50;
 name16.Visible:=true;

 if vr then
   begin
    left16:=left0;
    right16:=right0;
   end;

 if vi then
    valuet16:=ini0;

 if (valuet16-left16)*(valuet16-right16)>0 then
    if vi then
      setexception(11152)
    else
       valuet16:=(left0+right0)/2.0;

 with TrackBar16 do
          Position:=round(min+(valuet16-left16)/(right16-left16)*(max-min));
 TrackBar16Change(self);

 TrackBar16.Visible:=true;
 TrackBar16.Enabled:=true;
 WindowState:=wsNormal;
 if nowait then
       Show
 else
   begin
     TrackBar1.Enabled:=false;
     TrackBar2.Enabled:=false;
     TrackBar3.Enabled:=false;
     TrackBar4.Enabled:=false;
     TrackBar5.Enabled:=false;
     TrackBar6.Enabled:=false;
     TrackBar7.Enabled:=false;
     TrackBar8.Enabled:=false;
     TrackBar9.Enabled:=false;
     TrackBar10.Enabled:=false;
     TrackBar11.Enabled:=false;
     TrackBar12.Enabled:=false;
     TrackBar13.Enabled:=false;
     TrackBar14.Enabled:=false;
     TrackBar15.Enabled:=false;
     TrackBar17.Enabled:=false;
     TrackBar18.Enabled:=false;
     TrackBar19.Enabled:=false;
     TrackBar20.Enabled:=false;
     ShowModal;
     if ModalResult<>mrOk then
        CtrlBreakHit:=true ;
     TrackBar1.Enabled:=false;
   end;
 Application.ProcessMessages;
 result:=valuet16;
end;

function TLocateForm.Value17(vr, vi, nowait: boolean; left0, right0,
  ini0: double; Name0: Ansistring): double;
begin
 name17.Caption:=name0;
 OkButton.Visible:=not nowait;
 if ClientHeight<17*50 then ClientHeight:=17*50;
 name17.Visible:=true;

 if vr then
   begin
    left17:=left0;
    right17:=right0;
   end;

 if vi then
    valuet17:=ini0;

 if (valuet17-left17)*(valuet17-right17)>0 then
    if vi then
      setexception(11152)
    else
       valuet17:=(left0+right0)/2.0;

 with TrackBar17 do
          Position:=round(min+(valuet17-left17)/(right17-left17)*(max-min));
 TrackBar17Change(self);

 TrackBar17.Visible:=true;
 TrackBar17.Enabled:=true;
 WindowState:=wsNormal;
 if nowait then
       Show
 else
   begin
     TrackBar1.Enabled:=false;
     TrackBar2.Enabled:=false;
     TrackBar3.Enabled:=false;
     TrackBar4.Enabled:=false;
     TrackBar5.Enabled:=false;
     TrackBar6.Enabled:=false;
     TrackBar7.Enabled:=false;
     TrackBar8.Enabled:=false;
     TrackBar9.Enabled:=false;
     TrackBar10.Enabled:=false;
     TrackBar11.Enabled:=false;
     TrackBar12.Enabled:=false;
     TrackBar13.Enabled:=false;
     TrackBar14.Enabled:=false;
     TrackBar15.Enabled:=false;
     TrackBar16.Enabled:=false;
     TrackBar18.Enabled:=false;
     TrackBar19.Enabled:=false;
     TrackBar20.Enabled:=false;
     ShowModal;
     if ModalResult<>mrOk then
        CtrlBreakHit:=true ;
     TrackBar1.Enabled:=false;
   end;
 Application.ProcessMessages;
 result:=valuet17;
end;

function TLocateForm.Value18(vr, vi, nowait: boolean; left0, right0,
  ini0: double; Name0: Ansistring): double;
begin
 name18.Caption:=name0;
 OkButton.Visible:=not nowait;
 if ClientHeight<18*50 then ClientHeight:=18*50;
 name18.Visible:=true;

 if vr then
   begin
    left18:=left0;
    right18:=right0;
   end;

 if vi then
    valuet18:=ini0;

 if (valuet18-left18)*(valuet18-right18)>0 then
    if vi then
       setexception(11152)
    else
       valuet18:=(left0+right0)/2.0;

 with TrackBar18 do
          Position:=round(min+(valuet18-left18)/(right18-left18)*(max-min));
 TrackBar18Change(self);

 TrackBar18.Visible:=true;
 TrackBar18.Enabled:=true;
 WindowState:=wsNormal;
 if nowait then
       Show
 else
   begin
     TrackBar1.Enabled:=false;
     TrackBar2.Enabled:=false;
     TrackBar3.Enabled:=false;
     TrackBar4.Enabled:=false;
     TrackBar5.Enabled:=false;
     TrackBar6.Enabled:=false;
     TrackBar7.Enabled:=false;
     TrackBar8.Enabled:=false;
     TrackBar9.Enabled:=false;
     TrackBar10.Enabled:=false;
     TrackBar11.Enabled:=false;
     TrackBar12.Enabled:=false;
     TrackBar13.Enabled:=false;
     TrackBar14.Enabled:=false;
     TrackBar15.Enabled:=false;
     TrackBar16.Enabled:=false;
     TrackBar17.Enabled:=false;
     TrackBar19.Enabled:=false;
     TrackBar20.Enabled:=false;
     ShowModal;
     if ModalResult<>mrOk then
        CtrlBreakHit:=true ;
     TrackBar1.Enabled:=false;
   end;
 Application.ProcessMessages;
 result:=valuet18;
end;

function TLocateForm.Value19(vr, vi, nowait: boolean; left0, right0,
  ini0: double; Name0: Ansistring): double;
begin
 name19.Caption:=name0;
 OkButton.Visible:=not nowait;
 if ClientHeight<19*50 then ClientHeight:=19*50;
 name19.Visible:=true;

 if vr then
   begin
    left19:=left0;
    right19:=right0;
   end;

 if vi then
    valuet19:=ini0;

 if (valuet19-left19)*(valuet19-right19)>0 then
    if vi then
       setexception(11152)
    else
       valuet19:=(left0+right0)/2.0;

 with TrackBar19 do
          Position:=round(min+(valuet19-left19)/(right19-left19)*(max-min));
 TrackBar19Change(self);

 TrackBar19.Visible:=true;
 TrackBar19.Enabled:=true;
 WindowState:=wsNormal;
 if nowait then
       Show
 else
   begin
     TrackBar1.Enabled:=false;
     TrackBar2.Enabled:=false;
     TrackBar3.Enabled:=false;
     TrackBar4.Enabled:=false;
     TrackBar5.Enabled:=false;
     TrackBar6.Enabled:=false;
     TrackBar7.Enabled:=false;
     TrackBar8.Enabled:=false;
     TrackBar9.Enabled:=false;
     TrackBar10.Enabled:=false;
     TrackBar11.Enabled:=false;
     TrackBar12.Enabled:=false;
     TrackBar13.Enabled:=false;
     TrackBar14.Enabled:=false;
     TrackBar15.Enabled:=false;
     TrackBar16.Enabled:=false;
     TrackBar17.Enabled:=false;
     TrackBar18.Enabled:=false;
     TrackBar20.Enabled:=false;
     ShowModal;
     if ModalResult<>mrOk then
        CtrlBreakHit:=true ;
     TrackBar1.Enabled:=false;
   end;
 Application.ProcessMessages;
 result:=valuet19;
end;

function TLocateForm.Value20(vr, vi, nowait: boolean; left0, right0,
  ini0: double; Name0: Ansistring): double;
begin
  name20.Caption:=name0;
 OkButton.Visible:=not nowait;
 if ClientHeight<20*50 then ClientHeight:=20*50;
 name20.Visible:=true;

 if vr then
   begin
    left20:=left0;
    right20:=right0;
   end;

 if vi then
    valuet20:=ini0;

 if (valuet20-left20)*(valuet20-right20)>0 then
    if vi then
       setexception(11152)
    else
       valuet20:=(left0+right0)/2.0;

 with TrackBar20 do
          Position:=round(min+(valuet20-left20)/(right20-left20)*(max-min));
 TrackBar20Change(self);

 TrackBar20.Visible:=true;
 TrackBar20.Enabled:=true;
 WindowState:=wsNormal;
 if nowait then
       Show
 else
   begin
     TrackBar1.Enabled:=false;
     TrackBar2.Enabled:=false;
     TrackBar3.Enabled:=false;
     TrackBar4.Enabled:=false;
     TrackBar5.Enabled:=false;
     TrackBar6.Enabled:=false;
     TrackBar7.Enabled:=false;
     TrackBar8.Enabled:=false;
     TrackBar9.Enabled:=false;
     TrackBar10.Enabled:=false;
     TrackBar11.Enabled:=false;
     TrackBar12.Enabled:=false;
     TrackBar13.Enabled:=false;
     TrackBar14.Enabled:=false;
     TrackBar15.Enabled:=false;
     TrackBar16.Enabled:=false;
     TrackBar17.Enabled:=false;
     TrackBar18.Enabled:=false;
     TrackBar19.Enabled:=false;
     ShowModal;
     if ModalResult<>mrOk then
        CtrlBreakHit:=true ;
     TrackBar1.Enabled:=false;
   end;
 Application.ProcessMessages;
 result:=valuet20;
end;


procedure TLocateForm.TrackBar1Change(Sender: TObject);
begin
 with TrackBar1 do
   begin
     valuet1:=left1 + (Position/(max-min))*(right1-left1);
     Label1.Caption:=Format('%8.8g',[valuet1]);
     Label1.Left:=Left+(Position -label1.Width) div 2;
     Label1.Visible:=true;
   end;
end;

procedure TLocateForm.TrackBar2Change(Sender: TObject);
begin
 with TrackBar2 do
   begin
     valuet2:=left2 + (Position/(max-min))*(right2-left2);
     Label2.Caption:=Format('%8.8g',[valuet2]);
     Label2.Left:=Left+(Position -label2.Width) div 2;
     Label2.Visible:=true;
   end;
end;

procedure TLocateForm.TrackBar3Change(Sender: TObject);
begin
 with TrackBar3 do
   begin
     valuet3:=left3 + (Position/(max-min))*(right3-left3);
     Label3.Caption:=Format('%8.8g',[valuet3]);
     Label3.Left:=Left+(Position -label3.Width) div 2;
     Label3.Visible:=true;
   end;
end;

procedure TLocateForm.TrackBar4Change(Sender: TObject);
begin
 with TrackBar4 do
   begin
     valuet4:=left4 + (Position/(max-min))*(right4-left4);
     Label4.Caption:=Format('%8.8g',[valuet4]);
     Label4.Left:=Left+(Position -label4.Width) div 2;
     Label4.Visible:=true;
   end;
end;

procedure TLocateForm.TrackBar5Change(Sender: TObject);
begin
 with TrackBar5 do
   begin
     valuet5:=left5 + (Position/(max-min))*(right5-left5);
     Label5.Caption:=Format('%8.8g',[valuet5]);
     Label5.Left:=Left+(Position -label5.Width) div 2;
     Label5.Visible:=true;
   end;
end;


procedure TLocateForm.TrackBar6Change(Sender: TObject);
begin
 with TrackBar6 do
   begin
     valuet6:=left6 + (Position/(max-min))*(right6-left6);
     Label6.Caption:=Format('%8.8g',[valuet6]);
     Label6.Left:=Left+(Position -label1.Width) div 2;
     Label6.Visible:=true;
   end;
end;

procedure TLocateForm.TrackBar7Change(Sender: TObject);
begin
 with TrackBar7 do
   begin
     valuet7:=left7 + (Position/(max-min))*(right7-left7);
     Label7.Caption:=Format('%8.8g',[valuet7]);
     Label7.Left:=Left+(Position -label7.Width) div 2;
     Label7.Visible:=true;
   end;
end;

procedure TLocateForm.TrackBar8Change(Sender: TObject);
begin
 with TrackBar8 do
   begin
     valuet8:=left8 + (Position/(max-min))*(right8-left8);
     Label8.Caption:=Format('%8.8g',[valuet8]);
     Label8.Left:=Left+(Position -label8.Width) div 2;
     Label8.Visible:=true;
   end;
end;

procedure TLocateForm.TrackBar9Change(Sender: TObject);
begin
 with TrackBar9 do
   begin
     valuet9:=left9 + (Position/(max-min))*(right9-left9);
     Label9.Caption:=Format('%8.8g',[valuet9]);
     Label9.Left:=Left+(Position -label9.Width) div 2;
     Label9.Visible:=true;
   end;
end;

procedure TLocateForm.TrackBar10Change(Sender: TObject);
begin
 with TrackBar10 do
   begin
     valuet10:=left10 + (Position/(max-min))*(right10-left10);
     Label10.Caption:=Format('%8.8g',[valuet10]);
     Label10.Left:=Left+(Position -label10.Width) div 2;
     Label10.Visible:=true;
   end;
end;

procedure TLocateForm.TrackBar11Change(Sender: TObject);
begin
 with TrackBar11 do
   begin
     valuet11:=left11 + (Position/(max-min))*(right11-left11);
     Label11.Caption:=Format('%8.8g',[valuet11]);
     Label11.Left:=Left+(Position -label11.Width) div 2;
     Label11.Visible:=true;
   end;
end;

procedure TLocateForm.TrackBar12Change(Sender: TObject);
begin
 with TrackBar12 do
   begin
     valuet12:=left12 + (Position/(max-min))*(right12-left12);
     Label12.Caption:=Format('%8.8g',[valuet12]);
     Label12.Left:=Left+(Position -label12.Width) div 2;
     Label12.Visible:=true;
   end;
end;

procedure TLocateForm.TrackBar13Change(Sender: TObject);
begin
 with TrackBar13 do
   begin
     valuet13:=left13 + (Position/(max-min))*(right13-left13);
     Label13.Caption:=Format('%8.8g',[valuet13]);
     Label13.Left:=Left+(Position -label13.Width) div 2;
     Label13.Visible:=true;
   end;
end;

procedure TLocateForm.TrackBar14Change(Sender: TObject);
begin
 with TrackBar14 do
   begin
     valuet14:=left14 + (Position/(max-min))*(right14-left14);
     Label14.Caption:=Format('%8.8g',[valuet14]);
     Label14.Left:=Left+(Position -label14.Width) div 2;
     Label14.Visible:=true;
   end;
end;

procedure TLocateForm.TrackBar15Change(Sender: TObject);
begin
 with TrackBar15 do
   begin
     valuet15:=left15 + (Position/(max-min))*(right15-left15);
     Label15.Caption:=Format('%8.8g',[valuet15]);
     Label15.Left:=Left+(Position -label15.Width) div 2;
     Label15.Visible:=true;
   end;
end;

procedure TLocateForm.TrackBar16Change(Sender: TObject);
begin
 with TrackBar16 do
   begin
     valuet16:=left16 + (Position/(max-min))*(right16-left16);
     Label16.Caption:=Format('%8.8g',[valuet16]);
     Label16.Left:=Left+(Position -label16.Width) div 2;
     Label16.Visible:=true;
   end;
end;

procedure TLocateForm.TrackBar17Change(Sender: TObject);
begin
 with TrackBar17 do
   begin
     valuet17:=left17 + (Position/(max-min))*(right17-left17);
     Label17.Caption:=Format('%8.8g',[valuet17]);
     Label17.Left:=Left+(Position -label17.Width) div 2;
     Label17.Visible:=true;
   end;
end;

procedure TLocateForm.TrackBar18Change(Sender: TObject);
begin
 with TrackBar18 do
   begin
     valuet18:=left18 + (Position/(max-min))*(right18-left18);
     Label18.Caption:=Format('%8.8g',[valuet18]);
     Label18.Left:=Left+(Position -label18.Width) div 2;
     Label18.Visible:=true;
   end;
end;

procedure TLocateForm.TrackBar19Change(Sender: TObject);
begin
 with TrackBar19 do
   begin
     valuet19:=left19 + (Position/(max-min))*(right19-left19);
     Label19.Caption:=Format('%8.8g',[valuet19]);
     Label19.Left:=Left+(Position -label19.Width) div 2;
     Label19.Visible:=true;
   end;
end;

procedure TLocateForm.TrackBar20Change(Sender: TObject);
begin
 with TrackBar20 do
   begin
     valuet20:=left20 + (Position/(max-min))*(right20-left20);
     Label20.Caption:=Format('%8.8g',[valuet20]);
     Label20.Left:=Left+(Position -label20.Width) div 2;
     Label20.Visible:=true;
   end;
end;

procedure TLocateForm.InitValue;
begin
  Hide;  //Visible:=false;
  Application.ProcessMessages;
  left1:=0;  right1:=1;   valuet1:=0.5;
  left2:=0;  right2:=1;   valuet2:=0.5;
  left3:=0;  right3:=1;   valuet3:=0.5;
  left4:=0;  right4:=1;   valuet4:=0.5;
  left5:=0;  right5:=1;   valuet5:=0.5;
  left6:=0;  right6:=1;   valuet6:=0.5;
  left7:=0;  right7:=1;   valuet7:=0.5;
  left8:=0;  right8:=1;   valuet8:=0.5;
  left9:=0;  right9:=1;   valuet9:=0.5;
  left10:=0; right10:=1;  valuet10:=0.5;
  left11:=0; right11:=1;  valuet11:=0.5;
  left12:=0; right12:=1;  valuet12:=0.5;
  left13:=0; right13:=1;  valuet13:=0.5;
  left14:=0; right14:=1;  valuet14:=0.5;
  left15:=0; right15:=1;  valuet15:=0.5;
  left16:=0; right16:=1;  valuet16:=0.5;
  left17:=0; right17:=1;  valuet17:=0.5;
  left18:=0; right18:=1;  valuet18:=0.5;
  left19:=0; right19:=1;  valuet19:=0.5;
  left20:=0; right20:=1;  valuet20:=0.5;
  name1.Visible:=false;  Trackbar1.Visible:=false;  Label1.Visible:=false;
  name2.Visible:=false;  Trackbar2.Visible:=false;  Label2.Visible:=false;
  name3.Visible:=false;  Trackbar3.Visible:=false;  Label3.Visible:=false;
  name4.Visible:=false;  Trackbar4.Visible:=false;  Label4.Visible:=false;
  name5.Visible:=false;  Trackbar5.Visible:=false;  Label5.Visible:=false;
  name6.Visible:=false;  Trackbar6.Visible:=false;  Label6.Visible:=false;
  name7.Visible:=false;  Trackbar7.Visible:=false;  Label7.Visible:=false;
  name8.Visible:=false;  Trackbar8.Visible:=false;  Label8.Visible:=false;
  name9.Visible:=false;  Trackbar9.Visible:=false;  Label9.Visible:=false;
  name10.Visible:=false; Trackbar10.Visible:=false; Label10.Visible:=false;
  name11.Visible:=false; Trackbar11.Visible:=false; Label11.Visible:=false;
  name12.Visible:=false; Trackbar12.Visible:=false; Label12.Visible:=false;
  name13.Visible:=false; Trackbar13.Visible:=false; Label13.Visible:=false;
  name14.Visible:=false; Trackbar14.Visible:=false; Label14.Visible:=false;
  name15.Visible:=false; Trackbar15.Visible:=false; Label15.Visible:=false;
  name16.Visible:=false; Trackbar16.Visible:=false; Label16.Visible:=false;
  name17.Visible:=false; Trackbar17.Visible:=false; Label17.Visible:=false;
  name18.Visible:=false; Trackbar18.Visible:=false; Label18.Visible:=false;
  name19.Visible:=false; Trackbar19.Visible:=false; Label19.Visible:=false;
  name20.Visible:=false; Trackbar20.Visible:=false; Label20.Visible:=false;

  ClientHeight:=50;
  OkButton.Visible:=true;


  //paintform.visible:=false;
end;

procedure TLocateForm.FormCreate(Sender: TObject);
begin
  {$IFDEF LclGtk2}
  BorderStyle:=bsSizeable;   // bug of Lazarus 1.0 Linux ?
  {$ENDIF}

  with TMyIniFile.create('locateForm') do
       begin
         Left:=ReadInteger('Left',Left);
         Top:=ReadInteger('Top',Top);
         free
       end;
end;

procedure TLocateForm.FormDestroy(Sender: TObject);
begin
  with TMyIniFile.create('LocateForm') do
     begin
        WriteInteger('Left',Left);
        WriteInteger('Top',Top);
        free
     end;
end;

end.
