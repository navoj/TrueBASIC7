{$X+}
unit compiler;
{$IFDEF FPC}
  {$MODE DELPHI} {$H+}
{$ENDIF}
(***************************************)
(* Copyright (C) 2016, SHIRAISHI Kazuo *)
(***************************************)



interface
uses  SysUtils, Classes, Types, Forms, Dialogs, ComCtrls, Controls, Graphics,
     StdCtrls, FileUtil, SynEditHighlighter, math,
     struct;


procedure RunNormal;
procedure RunStep;
procedure ExecuteOnThread;

var
   changedir:procedure;
   setIndentOption:procedure;
   setOperation:procedure;
   setRunOption:procedure;
   setRunOption2:procedure;
   setDebug:procedure;
   setLineEndMarker:procedure;
   setRefferingPath:procedure;
var
   ProgramOnRunning:string='';

implementation

uses
     MainFrm,paintfrm,textfrm,tracefrm, graphopt, base,arithmet,
     myutils,rational,texthand,textfile,express,statemen,graphsys,graphic,
     debugdg,helpctex,math2sub,charinp,sconsts,vstack,memman,merge,mesdlg,
     MyThread;

type
  TBackUp=class(TThread)
       text1:ansistring;
       fName:ansistring;
    constructor create(const s,f:AnsiString);
    procedure execute;override;
  end;

constructor TBackUp.create(const s,f:AnsiString);
begin
   inherited create(false);
   text1:=s;
   FName:=f;
end;

procedure TBackUp.execute;
var
  t:Text;
begin
  assignFile(t,fname);
  try
    rewrite(t);
    write(t,text1);
    close(t)
  except
  end;
end;


var
    ReCompile:boolean=false;

function compile:boolean;
begin
 Screen.cursor:=crHourGlass;
 compile:=true;
 recompile:=false;

 try
      struct.compile;
  except
  on E:Exception do
      begin
          compile:=false;
          currentprogram.deletestatements; //2011.3.9 追加
          currentprogram.freeall;
          if E is EReCompile then
             recompile:=true
          else if not (E is SyntaxError) then
             ShowMessage(s_internalErrorCompiling+EOL+E.message +EOL+Contact);
      end;
 end;
 Screen.cursor:=crDefault;
end;

function CompilePrg:boolean;
var
   ErrorMes:string;
   svUseTranscendentalFunction:boolean;
begin
   svUseTranscendentalFunction := UseTranscendentalFunction;

   try
   FrameForm.Memo1.lines.BeginUpdate;

   extype:=0;
   InitSeed;

   GraphMode:=false;
   textMode:=false;
   UseCharInput:=false;

   ReCompile:=false;
   repeat

       SetPrecisionMode(InitialPrecisionMode,true);

       indent:=-1;
       USEnest:=0;

       DoStack:=TList.Create;
       ForStack:=TList.create;
       WhenStack:=TList.create;
       WhenStack.add(nil);
       WhenUseStack:=TList.create;
       WhenUseStack.add(nil);

       result:=false;
       pass:=1;

      try
         if compile then
            begin
               pass:=2;
               currentprogram.deletestatements;
               currentprogram.VarTablesRebuild;
               currentprogram.ShareVarTableGetVar;
               result:=compile;
            end;
       finally
         DoStack.Free;
         ForStack.free;
         WhenStack.free;
         WhenUseStack.free;
         KeyWordTablesFreeAll;
         Pass:=0;
       end;
   until recompile=false;


   finally
        FrameForm.Memo1.lines.EndUpdate;
   end;
   //  エラーを表示する
   if result=false then
       begin
         SelectLine(FrameForm.memo1,exline);
         //MyMessageDlg(statusmes.murgeWithOR, mtWarning, [mbOK,mbHelp]
         //                                  ,HelpContext,s_SyntaxError);

         ErrorMes:= s_SyntaxError+' at line ' + IntToStr(exline+1)+ EOL +
                     statusmes.murgeWithOR ;
         if HelpContext=0 then
              MessageDlg( ErrorMes, mtWarning, [mbOK],HelpContext)
         else
              //MessageDlg( ErrorMes, mtWarning, [mbOK,mbHelp],HelpContext);
              ShowMessageDialog(ErrorMes, HelpContext);
         //with FrameForm.memo1 do
           // SelStart:=SendMessage(Handle,EM_LINEINDEX,
           //                       exline,0)+expos+exinsertcount-1;
         with FrameForm do
           Memo1.SelStart:=LineIndex(FrameForm.Memo1,exline)+expos+exinsertcount-1;
         end;

   UseTranscendentalFunction := svUseTranscendentalFunction
end;


 var  mes:string;
 var  hc:integer;

 procedure ExecuteOnThread;
  begin
   hc:=0;
   try

   asm
      fclex
   end;
   controlword:= NormalCW;           //2014.1.12
   SetFPUMask(controlword);          //2014.1.9
   {$IFDEF CPU32}
   asm
      mov initialESP,esp
   end;
   {$ENDIF}
   {$IFDEF CPU64}
    asm
       mov [initialRSP+rip],rsp
    end;
   {$ENDIF}

    CurrentProgram.RunModules ;
  except
    on EExtype do
    begin
        SetErrorMes(extype, mes, hc);
    end;
    on E:EStackOverflow do ShowMessage(E.Message);
    on E:EOutOfMemory do ShowMessage(E.Message);
    on E:Exception do
           ShowMessage(s_InternalErrorRunning+EOL+E.message +EOL+Contact);

  end;
 end;



procedure RunPrg;
var
   CurDir:String;
   svSelStart:integer;
   svCapture:TControl;
begin
   extype:=0;
   CurrentOperation:=nil;
   statusmes.clear;
   DebugDlg.init;

   //svCapture:=Mouse.Capture;
   //Mouse.Capture:=FrameForm;

  //if not GraphMode  then
  //        PaintForm.Visible:=false;


  CurDir:=ExtractFilePath(FrameForm.OpenDialog1.FileName);
  if (CurDir<>'') and (Curdir<>GetCurrentDir) then
     SetCurrentDir(CurDir);

  console:=TConsole.create;
  PConsole.ttext:=console;           //2008.11.3
  LocalPrinter:=TLocalPrinter.create;
  TextForm.Caption:=ChangeFileExt(FrameForm.OpenDialog1.FileName,'.txt');

  TraceForm.Memo1.lines.text:='';
  TraceForm.Caption:=ChangeFileExt(FrameForm.OpenDialog1.FileName,'.log');
  TraceForm.setReadOnly(true);

  if BreakFlags.TraceMode then
     with TraceForm do
       begin
         show;
         WindowState:=wsNormal;
         BringToFront;
       end
  else
     TraceForm.hide;  //WindowState:=wsMinimized;


  //InitGraphics;         //2013.12.21 追加  //2020.2 ver. 2.1.0.0 削除
  HiddenDrawMode:=false;
  ScreenBMPGraphSys.setRasterMode(pmCopy);
  ScreenBMPGraphSys.TextHeightChanged:=false;
  PrtDirectGraphSys.TextHeightChanged:=false;
  PaintForm.initial;
  InitGraphics;

  if graphmode and  (nextGraphmode=ScreenBitmapMode) then
       begin
          PaintForm.Caption:=ChangeFileExt(FrameForm.OpenDialog1.FileName,'.bmp');
          {$IFDEF Windows}
          PaintForm.WindowState:=wsMaximized;  //下記対策。理由は不明。
          {$ENDIF}
          PaintForm.show;
          PaintForm.WindowState:=wsNormal;   //なぜか最小化後に実行すると最小化のまま
          PaintForm.BringToFront;
          if  textmode
            and (paintform.left<textform.left) and (paintform.top<textform.top)
            and (textform.Left+textform.Width<paintform.Left+paintform.Width)
            and (textform.Top+textform.Height<paintform.Top+paintform.Height) then
              begin
              textform.left:=base.max(0,paintform.left -80);
              textform.top:=base.max(0,paintform.top -40);
            end
       end
  else
     PaintForm.hide;

  if UseCharInput then
    begin
       charinput.init;
       CharInput.Show
    end;

   RunThread:=TMyThread.Create;
   sleep(10);
   repeat
      MainTask;
   until RunThread.Finished;
   controlword:=OriginalCW;     //2014.1.12
   SetFPUMask(OriginalCW);       //2014.1.9
   MainTask;
   MyGraphSys.Finish;
   RunThread.Free;

   currentprogram.ShareVarTableFreeVar;
   currentprogram.deletestatements;
   currentprogram.freeall;
   console.free;
   PConsole.ttext:=nil;        //2008.11.3
   LocalPrinter.free;
    //FrameForm.memo1.SelLength:=0;
   charinput.hide;


  statusmes.add(mes);
  With FrameForm.memo1 do
     begin
        //LockWindowUpdate(Handle);
        svSelStart:=selStart;
        SelectAll;
        //SelAttributes:=DefAttributes;
        SelStart:=svSelstart;
        //SelLength:=0;
        //LockWindowUpdate(0);
     end;

  //FrameForm.memo1.HideSelection:=false;
  if extype<>0 then
       begin
          SelectLine(FrameForm.memo1,exline);
          FrameForm.Show;
          FrameForm.BringToFront;
          mes:='EXTYPE '+strint(extype mod 100000) +EOL+ statusmes.murge ;
          if hc=0 then
             MessageDlg(mes, mtError, [mbOK], 0)
          else
             MessageDlg(mes, mtError, [mbOK,mbHelp], hc) ;

          if extype>0 then
            with TraceForm do
              begin
                with memo1 do
                  begin
                    beginupdate;
                    SelText:='Exception raised'+EOL+memo.Lines[exline]+EOL+ mes;
                    endupdate;
                  end;
                show;
                BringToFront;
               end;

          if extype>0 then
           with DebugDlg do
             begin
               RadioGroup1.visible:=false;
               ShowList(lists.count-1);  // ver. 8.1.1.5  2022.04.14
               Execute;
             end;


          statusmes.clear ;
       end;


  if extype=0 then
      begin
        if textmode then
          with TextForm do
             begin
               show;
               WindowState:=wsNormal;
               BringToFront;
             end;
        if graphMode and  (nextGraphmode=ScreenBitmapMode) then
          with PaintForm do
             begin
               show;
               WindowState:=wsNormal;
               BringToFront;
             end;
      end;

    //Mouse.Capture:=svCapture;
end;



function CompileAndRun:boolean; //compileが成功するとTrue;
begin
   HelpContext:=0;
   StatusMes.clear;
   FrameForm.StatusBar1.Panels[1].text:=s_OnCompiling;
   //FrameForm.StatusBar1.Panels[1].Bevel:=pbLowered;
   FrameForm.StatusBar1.update;

   InitMemory;
   MemoryManInit;
   InitRational;

  result:=false;
  if CompilePrg then
      begin
           result:=true;
            if MixedArithmetic then
                FrameForm.StatusBar1.Panels[1].text:=''
           else
                FrameForm.StatusBar1.Panels[1].text:=
                                       precisionText[MainProgram.arithmetic];
           ProgramOnRunning:= ChangeFileExt(FrameForm.OpenDialog1.FileName,'')+s_OnRuunnig;
           FrameForm.StatusBar1.Panels[3].text:=s_OnRuunnig;
           //FrameForm.Caption:=AppTitle + ;
           FrameForm.StatusBar1.update;
           FrameForm.Memo1.Modified:=false;
           //FrameForm.Timer1.Enabled:=true;

           try
              RunPrg;
           except
            on E:Exception do
               ShowMessage(E.message );
           end;
           //FrameForm.Timer1.Enabled:=false;
           PaintForm.Repaint;
           TextForm.TextOutExec;

           //FrameForm.Caption:=AppTitle;
     end;

   //FrameForm.StatusBar1.Panels[1].Bevel:=pbNone;
   FrameForm.StatusBar1.Panels[1].text:='';
   FrameForm.StatusBar1.Panels[3].text:=statusBarMems3;
end;

procedure SetExecutingNow(s:boolean);
var
   i:integer;
begin
   ExecutingNow:=s;
   with FrameForm do
      begin
        TBRun.enabled:=not s;
        TBStep.enabled:=not s;
        TBBreak.enabled:=s;
        TBCut.enabled:=not s;
        TBPaste.enabled:=not s;
        TBUndo.enabled:=not s;
        if not permitMicrosoft then
           begin
              TBDecimal.enabled:=not s;
              TBHighPrecision.enabled:=not s;
              TBBinary.enabled:=not s;
              TBComplex.enabled:=not s;
              TBRational.enabled:=not s;
              TBDeg.enabled:=not s;
           end;
        Option1.enabled:=not s;
      end;
   with FrameForm do begin
       Run2.enabled:=not s;
       Break1.enabled:=s;
       Step1.enabled:=not s;
       Exit1.enabled:=not s;
       PopUpRun1.enabled:=not s;
       PopUpBreak1.enabled:=s;
       PopUpStep1.enabled:=not s;
       //Close1.enabled:=not s;
       merge1.enabled:=not s;
       Cut1.enabled:=not s;
       Paste1.enabled:=not s;
       Delete1.enabled:=not s;
       Undo1.enabled:=not s;
       Repalce1.enabled:=not s;
       deleteLabelNumber1.enabled:=not s;
       addLabelNumber1.enabled:=not s;
       CaseChange1.enabled:=not s;
       ToolBox1.enabled:=not s;
       Memo1.ReadOnly:=s;
   end;
   with TextForm  do begin
       Break1.enabled:=s;
       File1.enabled:=not s;
       Edit1.enabled:=not s;
       option1.enabled:=not s;
       PopupMenu1.AutoPopup:=not s;  //LCLでは機能しない
       cut2.enabled:=not s;
       paste2.enabled:=not s;
       delete2.enabled:=not s;
   end;
   with TraceForm  do begin
       Break1.enabled:=s;
       File1.enabled:=not s;
       Edit1.enabled:=not s;
       option1.enabled:=not s;
       PopupMenu1.AutoPopup:=not s;  //LCLでは機能しない
       cut2.enabled:=not s;
       paste2.enabled:=not s;
       delete2.enabled:=not s;
   end;
   with PaintForm do begin
       break1.enabled:=s;
       File1.enabled:=not s;
       Edit1.enabled:=not s;
       option1.enabled:=not s;
   end;
end;

function appRun:boolean;
var
   svModified:boolean;
   BackUp1:TBackUp;
   BkFile:ansistring;
   svKeepText,svKeepGraphic:boolean;
   dummy:boolean;
   svHighLighter:TSynCustomHighlighter;
begin
   svHighLighter:=FrameForm.memo1.HighLighter;
   with FrameForm do
      memo1.HighLighter:=BreakHighlighter;
   if TextHand.memo<>nil then exit;   {再入防止}
   TextHand.memo:=FrameForm.memo1;

   ChainFile:='';


   BkFile:=changefileext(application.exename,'.BAK');
   if NoBackUp or not FrameForm.memo1.Modified then
      BackUp1:=nil
   else
      BackUp1:=TBackUp.create(FrameForm.memo1.lines.text,bkFile);

   MergedLineNumber:=-1;

   SetExecutingNow(True);
   svModified:=FrameForm.Memo1.Modified;

   if permitMicrosoft then
      InitialPrecisionMode:=PrecisionNative
   else
      InitialPrecisionMode:=InitialPrecisionMode0;
   initialCharacterByte:=initialCharacterByte0;

   byte(nextGraphMode):=GraphOptDlg.RadioGroup1.ItemIndex;

   //IdleImmediately;
   Application.ProcessMessages;
   try
       result:=CompileAndRun;
   except
       on E:Exception do
          ShowMessage(s_InternalErrorCompiling+EOL+E.message +EOL+Contact);
   end;

   BackUp1.free;
   SetExecutingNow(False);

   if MergedLineNumber>0 then RemoveMergedText;
   
   FrameForm.memo1.Modified:=svModified;
   TextHand.memo:=nil;
   with FrameForm do
      memo1.HighLighter:=svHighlighter;

   if not NoBackUp then
      SysUtils.DeleteFile(BkFile);

   if ChainFile<>'' then
      begin
        svKeepText:=KeepText;
        svkeepGraphic:=KeepGraphic;
        KeepText:=true;
        KeepGraphic:=true;
        
        if FrameForm.OpenTextFile(ChainFile)then
           dummy:=AppRun;

        KeepText:=svKeepText;
        KeepGraphic:=svKeepGraphic;
      end;


end;

procedure RunNormal;
begin
    BreakFlags.LongFlag:=false;
    bkDirective:=bkStep;
    appRun;
    ClearExceptions(False);
    SetFPUMask(OriginalCW);
end;

procedure RunStep;
begin
    BreakFlags.TraceChannelPlus1:=0;
    BreakFlags.TraceMode:=true;
    CtrlBreakHit:=true;
    bkDirective:=bkstep;
    appRun;
    ClearExceptions(False);
    SetFPUMask(OriginalCW);
end;



procedure noefect;
begin
end;

function dummy:TStatement;
begin
   dummy:=nil
end;


begin
  setIndentOption:=noefect;
   setoperation:=noefect;
   setRunOption:=noefect;
   setRunOption2:=noefect;
   setDebug:=noefect;
   changedir:=noefect;
   setLineEndMarker:=noefect;
   setRefferingPath:=noefect;

end.
