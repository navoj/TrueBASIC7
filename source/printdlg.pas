unit printdlg;

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

interface

uses
   Types,Classes, SysUtils, Graphics, Controls, Forms, Dialogs,  SynEdit,
   ExtCtrls, StdCtrls, Buttons, LResources, PrintersDlgs,Printers ;

type

  { TPrintDialog1 }

  TPrintDialog1 = class(TForm)
    ListBox1: TListBox;
    OkButton: TBitBtn;
    cancelButton: TBitBtn;
    FontDialog1: TFontDialog;
    PrinterButton: TButton;
    FontButton: TButton;
    PrinterSetupDialog1: TPrinterSetupDialog;
    procedure ListBox1SelectionChange(Sender: TObject; User: boolean);
    procedure PrinterButtonClick(Sender: TObject);
    procedure FontButtonClick(Sender: TObject);
    procedure OnFormShow(Sender: TObject);
  private
    { Private 宣言 }
  public
    procedure execute(memo1:TSynEdit);  overload;
  end;

var
  PrintDialog1: TPrintDialog1;
var
  PrinterFont: TFont;

procedure PrintMemo(Lines:TStrings);

implementation
uses
     base,sconsts, myutils;
 {$R *.lfm}

procedure PrintMemo(Lines:TStrings);
var
  x,y,dy:integer;
  i: Integer;
  margin:integer;
begin
{todo 1 printer}

  with Printer do
    begin
      BeginDoc;
      Canvas.Font.Assign(PrinterFont);
      Canvas.Font.PixelsPerInch:=XDPI;
      margin:=XDPI div 2;
      with Canvas do
      begin
         //Brush.Color := clBlack;
         dy:=TextHeight(Lines.Strings[0]);
         if dy=0 then dy:=120;                   // bug on Lazarus
         x:=margin;   //左margin
         y:=margin;   //上margin
         i:=0;
         while i<Lines.Count do
           begin
             TextOut(x,y, Lines.Strings[i]);
             inc(i);
             y:=y+dy;
             if y > pageHeight - margin then
                begin
                  NewPage;
                  y:=margin;
                end;
           end;
      end;
      EndDoc;
    end;

end;


procedure TPrintDialog1.execute(memo1:TSynEdit);
begin
  if showModal=mrOk then
          PrintMemo(Memo1.lines);
end;

procedure TPrintDialog1.PrinterButtonClick(Sender: TObject);
begin
    PrinterSetupDialog1.Execute;
end;

procedure TPrintDialog1.ListBox1SelectionChange(Sender: TObject; User: boolean);
begin
  Printer.PrinterIndex:=ListBox1.ItemIndex;
end;

procedure TPrintDialog1.FontButtonClick(Sender: TObject);
begin
   //FontDialog1.Device:=fdPrinter;
   FontDialog1.Font:=PrinterFont;
   if FontDialog1.Execute then
         PrinterFont.Assign(FontDialog1.Font);

end;

procedure TPrintDialog1.OnFormShow(Sender: TObject);
begin
  ListBox1.Items:=printer.printers;
  ListBox1.ItemIndex:=Printer.PrinterIndex;
end;

initialization
   PrinterFont:=TFont.create;

  with PrinterFont do
    begin
      //CharSet:=OEM_CHARSET;
      Color := clBlack;
      Size := 11;
      Pitch := fpFixed;
    end;

   with TMyIniFile.create('PrinterFont') do
       begin
         RestoreFont(PrinterFont);
         free
       end;

finalization


   with TMyIniFile.create('PrinterFont') do
         begin
             StoreFont(PrinterFont);
             free
         end;

   PrinterFont.Free;


end.
