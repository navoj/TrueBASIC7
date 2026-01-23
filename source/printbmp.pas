unit printbmp;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}
interface
uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Buttons, LResources, PrintersDlgs,
  Types, Printers;

type

  { TPrintBMPDialog }

  TPrintBMPDialog = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Panel1: TPanel;
    PrinterButton: TButton;
    PrinterSetupDialog1: TPrinterSetupDialog;
    RadioGroup1: TRadioGroup;
    procedure PrinterButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private 宣言 }
  public
    { Public 宣言 }
  end;

//var  PrintBMPDialog: TPrintBMPDialog;
procedure PrintBitMap(BitMap:TBitMap);

implementation
uses
     base, sconsts, myutils;
{$R *.lfm}
procedure TPrintBMPDialog.PrinterButtonClick(Sender: TObject);
begin
     PrinterSetupDialog1.Execute;
end;


procedure PrintBitMap(BitMap:TBitMap);
var
  GRect,Grect1: TRect;
  BMPRatio,PRTRatio: Single;
begin
  with TPrintBMPDialog.create(nil) do
    begin
       if showModal=mrOk then
  {todo 1 printer}

          with printer do
          begin
            if RadioGroup1.ItemIndex=0 then
              begin
                BeginDoc;
                Canvas.Draw(0,0, BitMap);
                EndDoc;
              end
            else
               begin
                with GRect do
                begin
                  left:=0;
                  right:=pagewidth ; //-2* Margins.cx;
                  top:=0;
                  bottom:=pageheight ;//-2* margins.cy;
                end;
                GRect1:=Grect;
                with GRect do
                     PRTRatio :=(Bottom-Top)/(Right-Left);
                BMPRatio := BitMap.Height / BitMap.Width;
                if PRTRatio>=BMPRatio then
                   begin
                       GRect.Bottom := GRect.Top+trunc((GRect.Right-Grect.Left) * BMPRatio);
                   end
                else
                   begin
                       GRect.Right:=GRect.Left + trunc((GRect.Bottom-GRect.Top)/BMPRatio);
                   end;

                BeginDoc;
                Canvas.StretchDraw(GRect, BitMap);
                EndDoc;
              end;
          end;

      free;
    end;
end;

procedure TPrintBMPDialog.FormCreate(Sender: TObject);
begin
    with TMyIniFile.create('PrintBMP') do
    begin
       RadioGroup1.ItemIndex:=ReadInteger('EnLarge',RadioGroup1.ItemIndex);
       free
    end   ;
end;

procedure TPrintBMPDialog.FormDestroy(Sender: TObject);
begin
    with TMyIniFile.create('PrintBMP') do
    begin
         WriteInteger('EnLarge',RadioGroup1.ItemIndex);
         free
    end ;
end;

Initialization

end.
