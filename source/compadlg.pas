unit compadlg;

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

(***************************************)
(* Copyright (C) 2003, SHIRAISHI Kazuo *)
(***************************************)


interface

uses  SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, ComCtrls, LResources;

type

  { TcompatibilityDialog }

  TcompatibilityDialog = class(TForm)
    CheckGroup1: TCheckGroup;
    OKBtn: TButton;
    CancelBtn: TButton;
    HelpBtn: TButton;
    PageControl1: TPageControl;
    RadioGroup12: TRadioGroup;
    RadioGroup15: TRadioGroup;
    RadioGroup3: TRadioGroup;
    RadioGroup13: TRadioGroup;
    RadioGroup14: TRadioGroup;
    RadioGroup7: TRadioGroup;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    RadioGroup1: TRadioGroup;
    RadioGroup4: TRadioGroup;
    RadioGroup5: TRadioGroup;
    RadioGroup2: TRadioGroup;
    RadioGroup6: TRadioGroup;
    RadioGroup9: TRadioGroup;
    RadioGroup11: TRadioGroup;
    procedure HelpBtnClick(Sender: TObject);
    procedure RadioGroup7Click(Sender: TObject);
  private
    { Private 宣言 }
  public
    { Public 宣言 }
  end;

var
  compatibilityDialog: TcompatibilityDialog;

procedure setCompatibility;

implementation

uses base,graphsys, express, texthand, htmlhelp,confopt;
{$R *.lfm}


procedure TcompatibilityDialog.HelpBtnClick(Sender: TObject);
begin
  OpenHelp(HelpContext);
end;

procedure TcompatibilityDialog.RadioGroup7Click(Sender: TObject);
begin

end;

procedure setCompatibility;

begin
   with compatibilityDialog do
   begin
      //RadioGroup3.Enabled:=false;            //ver.0.7.4
      //RadioGroup3.visible:=false;            //ver.0.7.4

       RadioGroup1.ItemIndex:=byte(JISFormat);
       RadioGroup2.ItemIndex:=byte(InitialCharacterByte0);
       RadioGroup3.ItemIndex:=1-byte(InitialBeamMode);            //ver.0.7.4
       RadioGroup4.ItemIndex:=byte(JISDim);
       RadioGroup5.ItemIndex:=byte(ForceFunctionDeclare);
       RadioGroup6.ItemIndex:=byte(JISDef);
       RadioGroup7.ItemIndex:=byte(DefaultOptionArith);           //ver.8.1.3.3
       RadioGroup9.ItemIndex:=byte(ForNextBroadOwn);
       //RadioGroup11.ItemIndex:=1-byte(TextPhysicalCoordinate);    //ver.8.1.3.2
       RadioGroup11.Visible:=false;         //ver.8.1.3.2
       RadioGroup12.ItemIndex:=byte(ResultVarStatic);
       RadioGroup13.ItemIndex:=byte(DisableAbbreviatedPLOT);
       RadioGroup14.ItemIndex:=byte(ForceSubPictDeclare);
       RadioGroup15.ItemIndex:=byte(NoSizeZeroArray);
       CheckGroup1.Checked[0]:=GreekIdf;
       CheckGroup1.Checked[1]:=KanjiIdf;
      if ShowModal=mrOK then
        begin
          byte(JISFormat):=RadioGroup1.ItemIndex;
          byte(InitialCharacterByte0):=RadioGroup2.ItemIndex;
          byte(InitialBeamMode):=1-RadioGroup3.ItemIndex;           //ver.0.7.4
          byte(JISDim):=RadioGroup4.ItemIndex;
          byte(ForceFunctionDeclare):=RadioGroup5.ItemIndex;
          byte(JISDef):=RadioGroup6.ItemIndex;
          byte(DefaultOptionArith):=RadioGroup7.ItemIndex;         //ver.8.1.3.3
          byte(ForNextBroadown):=RadioGroup9.ItemIndex;
          //TextPhysicalCoordinate:=RadioGroup11.ItemIndex = 0;
          //TextProblemCoordinate:=RadioGroup11.ItemIndex = 2;
          //byte(TextPhysicalCoordinate):=1-RadioGroup11.ItemIndex;   //ver.8.1.3.2
          byte(ResultVarStatic):=RadioGroup12.ItemIndex;
          byte(DisableAbbreviatedPLOT):=RadioGroup13.ItemIndex;
          byte(ForceSubPictDeclare):=RadioGroup14.ItemIndex;
          byte(NoSizeZeroArray):=RadioGroup15.ItemIndex;
          GreekIdf := CheckGroup1.Checked[0];
          KanjiIdf := CheckGroup1.Checked[1];
          initIdentifierChar;
        end;
   end;
end;

initialization

  with TMyIniFile.create('Frame') do
   begin
     JISFormat:=            ReadBool('JISFormat',JISFormat);
     InitialCharacterByte0:=ReadBool('CharacterByte', InitialCharacterByte0);
     //JISSetWindow:=         ReadBool('JISSetWindow',JISSetWindow);
     JISDim:=               ReadBool('JISDim',JISDim);
     ForceFunctionDeclare:= ReadBool('ForceFunctionDeclare',ForceFunctionDeclare);
     ForceSubPictDeclare:=  ReadBool('ForceSubPictDeclare', ForceSubPictDeclare);
     JISDef:=               ReadBool('JISDef',JISDef);
     ForNextBroadOwn:=      ReadBool('ForNextBroadOwn',ForNextBroadOwn);
     ResultVarStatic:=      ReadBool('ResultVarStatic',ResultVarStatic);
     NoSizeZeroArray:=      ReadBool('NoSizeZeroArray',NoSizeZeroArray);
     GreekIdf:=             ReadBool('GreekIdf',GreekIdf);
     KanjiIdf:=             ReadBool('KanjiIdf',GreekIdf);
     byte(DefaultOptionArith):=ReadInteger( 'DefaultOptionArith',byte(DefaultOptionArith));      // ver.8.1.3.3
     free
   end;
 with TMyIniFile.create('Graphics') do
  begin
     //GeometricPenOnly:=     ReadBool('GeometricPenOnly',GeometricPenOnly);
     //ForwardPlot:=          ReadBool('ForwardPlot',ForwardPlot);
     //TextProblemCoordinate:= ReadBool('TextProblemCoordinate',TextProblemCoordinate);
     //TextPhysicalCoordinate:=ReadBool('TextPhysicalCoordinate',TextPhysicalCoordinate);
     //TextPhysicalCoordinate:=  not ReadBool('TextProblemCoordinate',false);                      //ver.0.7.4
     DisableAbbreviatedPLOT:=  ReadBool('DisableAbbreviatedPLOT',DisableAbbreviatedPLOT);        //ver.8.1.3.2
     InitialBeamMode:=         TBeamMode(ReadBool('InitialBeamMode',boolean(InitialBeamMode)));  //ver.0.7.4
     free
  end;

finalization
  with TMyIniFile.create('Frame') do
   begin
    WriteBool('JISFormat',JISFormat);
    WriteBool('CharacterByte', InitialCharacterByte0);
    //WriteBool('JISSetWindow',JISSetWindow);
    WriteBool('JISDim',JISDim);
    WriteBool('ForceFunctionDeclare',ForceFunctionDeclare);
    WriteBool('ForceSubPictDeclare', ForceSubPictDeclare);
    WriteBool('JISDef',JISDef);
    WriteBool('ForNextBroadOwn',ForNextBroadOwn);
    WriteBool('ResultVarStatic',ResultvarStatic);
    WriteBool('NoSizeZeroArray',NoSizeZeroArray);
    WriteBool('GreekIdf',GreekIdf);
    WriteBool('KanjiIdf',KanjiIdf);
    WriteInteger('DefaultOptionArith', byte(DefaultOptionArith));      // ver.8.1.3.3

    free
   end;
 with TMyIniFile.create('Graphics') do
  begin
      //WriteBool('GeometricPenOnly',GeometricPenOnly);
      //WriteBool('ForwardPlot',ForwardPlot);
      //WriteBool('TextProblemCoordinate',TextProblemCoordinate);
      //WriteBool('TextPhysicalCoordinate', TextPhysicalCoordinate);
      //WriteBool('TextProblemCoordinate', not TextPhysicalCoordinate);                   //ver.8.1.3.2
      WriteBool('DisableAbbreviatedPLOT',DisableAbbreviatedPLOT);
      WriteBool('InitialBeamMode',boolean(InitialBeamMode));                            //ver.0.7.4
   free
  end;



end.

