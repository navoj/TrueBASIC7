unit confopt;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

(***************************************)
(* Copyright (C) 2003, SHIRAISHI Kazuo *)
(***************************************)


interface

type tpDefaultOptionArith =(MainProgramArith, ToolBarArith, ArithDecimal);
var   DefaultOptionArith : tpDefaultOptionArith = MainProgramArith;
var InsertOptionArithmetic:boolean = false;
function ConfirmedDegrees:boolean;
procedure ConfirmArithmetic;

implementation
uses SysUtils,Types, dialogs, StdCtrls, Controls,
     struct,base,texthand,helpctex,mainfrm,sconsts;

//var confirmed:boolean=false;

function RadianConfirmed:boolean;
var
  mes1:ansistring;
begin
  mes1:=Format(s_ConfirmAngle,[programunit.name]);
  result:=FrameForm.AngleConfirmed
       or (Messagedlg(mes1,mtconfirmation,[mbYes,mbNo],IDH_OPTION_ANGLE)=mrYes);
  if result then
        FrameForm.AngleConfirmed:=true
end;

function ConfirmedDegrees:boolean;
begin
   if not ProgramUnit.AngleDegrees
      and ((programunit.optionAngle=apNone)
      and (initialAngledegrees and not permitMicrosoft
           or (pass=1) and (mainprogram.AngleDegrees=true) and not RadianConfirmed)) then
           begin
             InsertLine(programunit.lineNumb+1,'OPTION ANGLE DEGREES');
             programunit.AngleDegrees:=true
           end;
  result:=ProgramUnit.angleDegrees;
end;

procedure ConfirmArithmetic;
begin
  // 主プログラムにOPTION ARITHMETIC文があるとき，それに合わせる。
   if InsertOptionArithmetic
     and (DefaultOptionArith=MainProgramArith)
     and (MainProgram.optionArithmet<>apNone)
     and (programunit.optionArithmet=apNone)
     and not permitMicrosoft
   then
     begin
          InsertLine(programunit.lineNumb+1,
               'OPTION ARITHMETIC ' + PrecisionLiteral[programunit.arithmetic]);
     end;
end;

end.

