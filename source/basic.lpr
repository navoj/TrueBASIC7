{$MINSTACKSIZE $00100000}
{$MAXSTACKSIZE $00200000}

program basic;

{$MODE Delphi}

(*************************************************************************
    Copyright 2017, SHIRAISHI Kazuo

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU General Public License for more details.
*************************************************************************)

uses
 {$ifdef unix}
  cthreads,
 {$endif}
  Interfaces, // this includes the LCL widgetset
  Forms,

  base in 'base.pas',
  MainFrm in 'MainFrm.pas' {frameform},
  textfrm in 'textfrm.pas' {textform},
  tracefrm in 'tracefrm.pas' {traceform},
  paintfrm in 'paintfrm.pas' {paintform},
  convdlg in 'convdlg.pas' {convtdlg},
  numberdg in 'numberdg.pas' {numberdlg},
  toolfrm in 'toolfrm.pas' {toolbox},
  inputdlg in 'inputdlg.pas' {inputdialog},
  sizedlg in 'sizedlg.pas' {optionsizedlg},
  colordlg in 'colordlg.pas' {colorindexdlg},
  optiondg in 'optiondg.pas' {optiondlg},
  debugdg in 'debugdg.pas' {debugdlg},
  syntaxdg in 'syntaxdg.pas' {syntaxdlg},
  optina in 'optina.pas' {optionac},
  afdg in 'afdg.pas' {autoformatdlg},
  fkeydlg in 'fkeydlg.pas' {fkeysdlg},
  moddlg in 'moddlg.pas' {moddialog},
  compadlg in 'compadlg.pas' {compatibilityDialog},
  compiler in 'compiler.pas',
  supplied in 'supplied.pas',
  suppliedc in 'suppliedc.pas',
  suppliedr in 'suppliedr.pas',
  supplieds in 'supplieds.pas',
  extensio in 'extensio.pas',
  openclos in 'openclos.pas',
  chain in 'chain.pas',
  charinp in 'charinp.pas' {CharInput},
  locatefrm in 'locatefrm.pas' {LocateForm},
  locatech in 'locatech.pas' {LocateChoice},
  printdlg in 'printdlg.pas'{PrintDlg},
  htmlhelp in 'htmlhelp.pas',
  about in 'about.pas'{AboutBox},
  mesdlg in 'mesdlg.pas',
  graphopt,
  extdll,
  hselect, kedit, printer4lazarus;

{$R basic.res}

begin
  Application.Scaled:=True;
  Application.Title:='';
  Application.Initialize;
  Application.HelpFile := '';
  Application.CreateForm(TFrameForm, FrameForm);
  Application.CreateForm(TTextForm, TextForm);
  Application.CreateForm(TTraceForm, TraceForm);
  Application.CreateForm(TOptionSizeDlg, OptionSizeDlg);
  Application.CreateForm(TPaintForm, PaintForm);
  Application.CreateForm(TColorIndexDlg, ColorIndexDlg);
  Application.CreateForm(TOptionDlg, OptionDlg);
  Application.CreateForm(TDebugDlg, DebugDlg);
  Application.CreateForm(TInputDialog, InputDialog);
  Application.CreateForm(TOptionAC, OptionAC);
  Application.CreateForm(TAutoFormatDlg, AutoFormatDlg);
  Application.CreateForm(TFkeysDlg, FkeysDlg);
  Application.CreateForm(TMODDialog, MODDialog);
  Application.CreateForm(TToolBox, ToolBox);
  Application.CreateForm(TConvtDlg, ConvtDlg);
  Application.CreateForm(TNumberDlg, NumberDlg);
  Application.CreateForm(TSyntaxDlg, SyntaxDlg);
  Application.CreateForm(TcompatibilityDialog, compatibilityDialog);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(TLocateForm, LocateForm);
  Application.CreateForm(TLocateChoiceForm, LocateChoiceForm);
  Application.CreateForm(TCharInput, CharInput);
  Application.CreateForm(TPrintDialog1, PrintDialog1);
  Application.CreateForm(THelpSelector, HelpSelector);
  Application.CreateForm(TKanjiEdit, KanjiEdit);
  Application.CreateForm(TMessageDialog, MessageDialog);
  Application.CreateForm(TGraphOptDlg, GraphOptDlg);

  if (ParamIndex<=ParamCount) then
     if NoRun then
        begin
           FrameForm.OpenTextFile(ParamStr(paramIndex));
             Application.run
        end
     else if OpenAndRun then
        begin
          NoBackUp:=true;
          FrameForm.OpenTextFile(ParamStr(paramIndex));
          RunNormal;
          Application.Run
        end
     else
        begin
          NoBackUp:=true;
          FrameForm.OpenTextFile(ParamStr(paramIndex));
          RunNormal;
          ToTerminate:=true;
          FrameForm.Visible:=false;
          Application.Run
        end
  else
     begin
       ToOpen:=true;
       Application.Run;
     end;



end.
