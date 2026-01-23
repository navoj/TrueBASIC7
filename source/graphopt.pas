unit graphopt;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Spin, PrintersDlgs;


type

  { TGraphOptDlg }

  TGraphOptDlg = class(TForm)
    Bevel1: TBevel;
    FontDialog1: TFontDialog;
    Label6: TLabel;
    ListBox1: TListBox;
    Okbtn: TButton;
    CancelBtn: TButton;
    HelpBtn: TButton;
    RadioGroup1: TRadioGroup;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    PrinterSetupDialog1: TPrinterSetupDialog;
    Label1: TLabel;
    TrackBar1: TTrackBar;
    Label2: TLabel;
    Label3: TLabel;
    RadioGroup2: TRadioGroup;
    Label4: TLabel;
    Label5: TLabel;
    procedure HelpBtnClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private 宣言 }
  public
    procedure execute;
  end;

var
  GraphOptDlg: TGraphOptDlg;

implementation

uses printers,
     GraphSys,Paintfrm,mainfrm,htmlhelp;
{$R *.lfm}

procedure TGraphOptDlg.execute;
begin
    RadioGroup1.ItemIndex:=byte(NextGraphMode);
    RadioGroup2.ItemIndex:=byte(alignTop);
    TrackBar1.Position:=AdditionalMargin;

    if ShowModal=mrOk then
       begin
         byte(NextGraphMode):=RadioGroup1.ItemIndex;
         byte(AlignTop):=RadioGroup2.ItemIndex;
         AdditionalMargin:=TrackBar1.Position;
         Printer.PrinterIndex:=ListBox1.ItemIndex;
       end;
end;

procedure TGraphOptDlg.HelpBtnClick(Sender: TObject);
begin
  //Application.HelpContext(HelpContext);
  OpenBrowser('html/basi68xe.htm');
  end;

procedure TGraphOptDlg.Button1Click(Sender: TObject);
begin
  inherited;
  paintform.Font1Click(Sender);
end;

procedure TGraphOptDlg.Button2Click(Sender: TObject);
begin
  inherited;
     FontDialog1.Font.Assign(printer.canvas.font);
     if FontDialog1.execute then
          printer.canvas.font.Assign(FontDialog1.Font);
end;

procedure TGraphOptDlg.Button3Click(Sender: TObject);
begin
  inherited;
  Printer.PrinterIndex:=ListBox1.ItemIndex;
  PrinterSetupDialog1.Execute;
end;



procedure TGraphOptDlg.RadioGroup1Click(Sender: TObject);
begin
  inherited;
  with RadioGroup1 do
  case itemindex of
   0:
    begin
    Button1.enabled:=true;
    Button2.enabled:=false;
    Button3.enabled:=false;
    Label1.enabled:=false;
    TrackBar1.enabled:=false;
    Label2.enabled:=false;
    Label3.enabled:=false;
    Label4.enabled:=false;
    Label5.enabled:=false;
    RadioGroup2.enabled:=false;
    ListBox1.Enabled:=false;
    end;

    1:
    begin
    Button1.enabled:=false;
    Button2.enabled:=true;
    Button3.enabled:=true;
    Label1.enabled:=true;
    TrackBar1.enabled:=true;
    Label2.enabled:=true;
    Label3.enabled:=true;
    Label4.enabled:=true;
    Label5.enabled:=true;
    RadioGroup2.enabled:=true;
    ListBox1.Enabled:=true;
    end;
  end;
end;






procedure TGraphOptDlg.FormCreate(Sender: TObject);
begin
  inherited;
  FontDialog1.Font.Assign(paintform.font);
  Button2.Visible:=true;
  Button3.Visible:=true;
     // プリンタ有無のテスト
  RadioGroup1.Enabled:=(printer.Printers.Count>0);
  ListBox1.Enabled:=false;
  ListBox1.Items:=Printer.Printers;
end;

end.

