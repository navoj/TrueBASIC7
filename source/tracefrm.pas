unit tracefrm;

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

(***************************************)
(* Copyright (C) 2003, SHIRAISHI Kazuo *)
(***************************************)


interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus,  StdCtrls,  Types,  ExtCtrls, ComCtrls,
  textfrm, LResources;

type

  { TTraceForm }

  TTraceForm = class(TTextForm)
    procedure FormCreate(Sender: TObject);
  private
    { Private 宣言 }
  public
    function FileFilter:string;override;
    function FileExt:string;override;
    function IniFileSection:string;override;
  end;

var
  TraceForm: TTraceForm;

implementation
uses base;
   {$R *.lfm}

function TTraceForm.FileFilter:string;
begin
   result:='LOG file|*.log'

end;


function TTraceForm.FileExt:string;
begin
   result:='.log'
end;

function TTraceForm.IniFileSection:string;
begin
   result:='Trace'
end;


procedure TTraceForm.FormCreate(Sender: TObject);
var   ScreenClientHeight:integer;
begin
  inherited;
   ScreenClientHeight:=Screen.Height-80  {WorkAreaHeight} ;
   Top:=ScreenClientHeight-Height;
   width:=min(width,screen.width div 2 +24);
   //visible:=false;
   //WindowState:=wsMinimized;
end;

initialization



end.
