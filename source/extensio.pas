unit extensio;

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

(***************************************)
(* Copyright (C) 2006, SHIRAISHI Kazuo *)
(***************************************)

interface
uses {$IFDEF Windows} windows, {$ENDIF}
    Controls, Dialogs,  Forms, SysUtils,  lclintf,  FileUtil;
var
     opendlg:TOpenDialog;
     DirName:String;

implementation
uses math,
  base,arithmet,texthand,variabl,struct,express,compiler,control, float,
  helpctex,textfrm, MainFrm,sconsts,supplied,MyThread,textfile ;

type
   TSWAP=class(TStatement)

      var1,var2:TVariable;
      constructor create(prev,eld:TStatement);
      destructor destroy;override;
      procedure exec;override;
    end;

function SWAPst(prev,eld:TStatement):TStatement;
begin
    SWAPst:=TSWAP.create(prev,eld);
end;

constructor TSWAP.create(prev,eld:TStatement);
begin
   inherited create(prev,eld);
   var1:=variable;
   check(',',IDH_EXTENSION);
   var2:=variable;
   if (var1=nil) or (var2=nil) or (var1.kind<>var2.kind) then
                          seterr('',IDH_EXTENSION);
end;

destructor TSWAP.destroy;
begin
   var1.free;
   var2.free;
   inherited destroy
end;

procedure TSWAP.exec;
var
   p1,p2:TVar;
begin
   p1:=var1.substance0(false);
   p2:=var2.substance0(false);
   if (p1<>nil) and (p2<>nil) then p1.swap(p2) ;
   var1.disposesubstance0(p1,false);
   var2.disposesubstance0(p2,false);
end;

{******}
{PAUSE }
{******}

{$IFDEF Windows}
TYPE uint=CARDINAL;
     MMRESULT = UINT;
Function timeBeginPeriod(x1: UINT): MMRESULT;stdcall; external 'winmm.dll' name 'timeBeginPeriod';
Function timeEndPeriod(x1: UINT): MMRESULT;stdcall; external 'winmm.dll' name 'timeEndPeriod';
procedure MySleep(duration:int64);
begin
   timeBeginPeriod(1);
   sleep(duration);
   timeEndPeriod(1)
end;
{$ELSE}
procedure MySleep(duration:int64);inline;
begin
  sleep(duration);
end;
{$ENDIF}

procedure wait(n:double);
var
   duration:int64;
begin
  duration:=system.round(n*1000);
  if (duration>0) and (duration<$ffffffff) then
     MySleep(duration)
  else  if duration<>0 then
    setexception(12004);
end;

type
   TPAUSE=class(TStatement)
          exp:TPrincipal;
      constructor create(prev,eld:TStatement);
      destructor destroy;override;
      procedure exec;override;
   end;

function PAUSEst(prev,eld:TStatement):TStatement;
begin
    PAUSEst:=TPause.create(prev,eld)
end;

constructor TPause.create(prev,eld:TStatement);
begin
   inherited create(prev,eld);
   if not ((tokenspec=tail) or (token='ELSE'))   then
      exp:=NSExpression;
end;

destructor TPause.destroy;
begin
   exp.free;
   inherited destroy
end;

procedure ShowMess(const s:string);
begin
   wait(0.05);        //2018/1/28 Ver 6.6.3.4
   if (ThreadMessageDlg(s + s_Pause_Mes, mtCustom, [mbOk], 800)<>mrOk)
      or (Getkeystate(27)<0) then
         CtrlBreakHit:=true;
    ClearExceptions(False);             //2014.1.20  Ver.0.6.3.6
end;

procedure TPause.exec;
var
   x:double;
begin
   if exp=nil then
      ShowMess('Pause')
   else if exp.kind='s' then
      ShowMess(exp.evalS)
   else
      begin
        x:=exp.evalX;
        wait(x)
      end;
end;

{**********}
{WAIT DELAY}
{**********}


function WAITst(prev,eld:TStatement):TStatement;
begin
    checktoken('DELAY',IDH_EXTENSION);
    WAITst:=TPause.create(prev,eld);
end;


{********}
{beep ST }
{********}
type
  TBEEP=class(TStatement)
     exp1,exp2:TPrincipal;
      constructor create(prev,eld:TStatement);
      destructor destroy;override;
      procedure exec;override;
   end;

constructor TBeep.create;
begin
  inherited create(prev,eld);
  if (tokenspec<>tail) and (token<>'ELSE') then
  begin
    exp1:=Nexpression;
    check(',',IDH_FILE_ENLARGE);
    exp2:=NExpression;
  end;
end;

destructor TBeep.destroy;
begin
   exp1.free;
   exp2.free;
   inherited destroy
end;   

procedure TBEEP.exec;
var
   freq,duration:integer;
begin
   if exp1=nil then
      SysUtils.beep
   else
      begin
         freq:=exp1.evalInteger;
         duration:=exp2.evalInteger;
         {$IFDEF Windows}
         Windows.Beep(freq,duration);
         {$ELSE}
         SysUtils.beep;
         {$ENDIF}
      end;
end;


function BEEPst(prev,eld:TStatement):TStatement;
begin
   BEEPst:=TBEEP.create(prev,eld)
end;

{**********}
{DELETEFILE}
{**********}

type
   TDELETEFILE=class(TStatement)
          exp:TPrincipal;
      constructor create(prev,eld:TStatement);
      destructor destroy;override;
      procedure exec;override;
   end;

function UNSAVEst(prev,eld:TStatement):TStatement;
begin
    result:=TDELETEFILE.create(prev,eld)
end;

constructor TDELETEFILE.create(prev,eld:TStatement);
begin
   inherited create(prev,eld);
      exp:=SExpression;
end;

destructor TDELETEFILE.destroy;
begin
   exp.free;
   inherited destroy
end;

procedure TDELETEFILE.exec;
var
   s:String;
begin
   s:=exp.evalS;
   if FileExists(s) then
     if  DeleteFile(s) then
     else
        setexception(9000)
   else
      setexception(9003)
end;

{***************}
{File Statements}
{***************}



type
   TGetCurDir=class(TStatement)
       vari:TStrVari;
      constructor create(prev,eld:TStatement);
      destructor destroy;override;
      procedure exec;override;
end;

procedure TGetCurDir.exec;
begin
    vari.substS(GetCurrentDir);
end;

type
  TMakeDir=class(TDeleteFile)
      procedure exec;override;
end;

procedure TMakeDir.exec;
begin
  if CreateDir(exp.evalS) then
  else
       setexception(9000);
end;

type
  TRemoveDir=class(TDeleteFile)
      procedure exec;override;
end;

procedure TRemoveDir.exec;
begin
  if RemoveDir(exp.evalS) then
  else
       setexception(9000);
end;


type
   TGetName=Class(TGetCurDir)
       exp:TPrincipal;
       aux:integer;
      constructor create(prev,eld:TStatement; aux0:integer);
      destructor destroy;override;
      procedure exec;override;
   end;

constructor TGetCurDir.create(prev,eld:TStatement);
begin
    inherited create(prev,eld);
    vari:=StrVari;
end;

constructor TGetName.create(prev,eld:TStatement;aux0:integer);
begin
    inherited create(prev,eld);
    aux:=aux0;
    if test(',') then
      exp:=SExpression;
end;

destructor TGetCurDir.destroy;
begin
   vari.free;
   inherited destroy
end;

destructor TGetName.destroy;
begin
   exp.free;
   inherited destroy
end;


procedure TGetName.exec;
var
  s:string;

begin
       if aux=2 then
          Opendlg:=TSaveDialog.Create(nil)
       else
          opendlg:= TOpenDialog.create(nil);
       with opendlg do
           begin
              options:=[ofHideReadOnly,ofPathMustExist,ofEnableSizing];
              if aux=1 then options:=options+[ofFileMustExist];
              if aux=2 then options:=options+[ofOverwritePrompt,ofNoReadOnlyReturn];
              if exp=nil then
              begin
               {$IFDEF Linux}
               DefaultExt:='' ;
               Filter:=s_TextFile+'|*.TXT;*.txt;*.CSV;*.csv;*.kw*;*.LOG;*.log;*.BAS;*.bas;*.LIB;*.lib|'
                      +s_ImageFile+'|*.BMP;*.bmp;*.PNG;*.png;*.JPEG;*.jpeg;*.JPG;*.jpg;*.JPE;*.jpe;*.GIF;*.gif;*.TIFF;*.tiff*.TIF;*.tif*;.XBM;*.xbm' + '|'
                      +s_AllFile +'|*.*';
               {$ELSE}
               DefaultExt:='txt' ;
               Filter:=s_TextFile+'|*.TXT;*.CSV;*.kw*;*.LOG;*'+BasExt+';*'+LibExt+'|'
                      +s_ImageFile+'|*.BMP;*.PNG;*.JPEG;*.JPG;*.JPE;*.GIF;*.TIFF;*.TIF;*.XBM' + '|'
                      +s_AllFile +'|*.*';
               {$ENDIF}
              end
              else
              begin
                s:=exp.evalS;
                if pos('|',s)=0 then
                 begin
                   DefaultExt:=s ;
                   Filter:=s + s_FILE + '|' + '*.' +s
                 end
                else
                 begin
                   Filter:=s
                 end;
              end;

              Title:=texthand.memo.lines[linenumb];
              RunThread.execOpenDlg;
              vari.substS(FileName);
              free;
           end;
end;





type
   TSplitName=Class(TStatement)
       exp:TPrincipal;
       vari1,vari2,vari3:TStrVari;
      constructor create(prev,eld:TStatement);
      destructor destroy;override;
      procedure exec;override;
   end;

constructor TSplitName.create(prev,eld:TStatement);
begin
    inherited create(prev,eld);
    check('(',IDH_FILE_ENLARGE);
    exp:=SExpression;
    check(')',IDH_FILE_ENLARGE);
    vari1:=StrVari;
    check(',',IDH_FILE_ENLARGE);
    vari2:=StrVari;
    check(',',IDH_FILE_ENLARGE);
    vari3:=StrVari;
end;


destructor TSplitName.destroy;
begin
   exp.free;
   vari1.free;
   vari2.free;
   vari3.free;
   inherited destroy
end;

procedure TSplitName.exec;
var
   s,name,ext:string;
   i:integer;
begin
   s:=exp.evalS;
   vari1.substS(ExtractFilePath(s));
   name:=ExtractFileName(s);
   i:=lastDelimiter('.',name);
   ext:=copy(name,i,maxint);
   name:=copy(name,1,i-1);
   vari2.substS(name);
   vari3.substS(ext);
end;

type
   TFileList=Class(TStatement)
       exp:TPrincipal;
       mat1:TMatrix;
      constructor create(prev,eld:TStatement);
      destructor destroy;override;
      procedure exec;override;
   end;

constructor TFileList.create(prev,eld:TStatement);
begin
    inherited create(prev,eld);
    exp:=SExpression;
    check(',',IDH_FILE_ENLARGE);
    mat1:=smatrix;
    if mat1.idr.dim<>1 then
               seterrDimension(IDH_FILE_ENLARGE);
end;


destructor TFileList.destroy;
begin
   exp.free;
   mat1.free;
   inherited destroy
end;

procedure TFileList.exec;
var
   s:string;
   Rec:TSearchRec;
   p:TSArray;
   sz:Array4;
   i:integer;
begin
   s:=exp.evalS;

   TVar(p):=mat1.point;
     if p<>nil then
       begin
          i:=0;
          try
            if FindFirst(s,0,Rec)=0 then
              begin
               if p.MaxSize<=i then SetException(5001);
               with p do ItemSubstS(i*size[2] ,Rec.Name);
               inc(i);
               while FindNext(Rec)=0 do
                 begin
                   if p.ary.count<=i then SetException(5001);
                   p.pointij(i,0).SubstS(Rec.Name);
                   inc(i);
                 end;
              end;
          finally
             FindClose(Rec);
          end;

          sz[1]:=i;
          sz[2]:=1;
          sz[3]:=1;
          sz[4]:=1;
          p.RedimNative(sz,false);
       end;
end;

type
   TFileRename=Class(TStatement)
       exp1,exp2:TPrincipal;
      constructor create(prev,eld:TStatement);
      destructor destroy;override;
      procedure exec;override;
   end;

constructor TFileRename.create(prev,eld:TStatement);
begin
    inherited create(prev,eld);
    exp1:=SExpression;
    check(',',IDH_FILE_ENLARGE);
    exp2:=SExpression;
end;

destructor TFileRename.destroy;
begin
   exp1.free;
   exp2.free;
   inherited destroy
end;

procedure TFileRename.exec;
var
  s1,s2:string;
begin
  s1:=exp1.evalS;
  s2:=exp2.evalS;
  if FileExists(s1) then
     begin
      if FileExists(s2) then
         setexception(9004)
      else if not RenameFile(s1,s2) then
         setexception(9000)
     end
  else
     setexception(9003);
end;

type
  TGetDirectoryName=class(TGetCurDir)
     procedure exec;override;
end;


procedure TGetDirectoryName.exec;
//var
//   dir:string;
begin
   //dir:=GetCurrentDir;
   //if SelectDirectory(Dir, [sdAllowCreate, sdPerformCreate, sdPrompt], 0) then
   //if SelectDirectory(s_Select_Directory, '', dir) then
   RunThread.ExecSelectDirectory;
   vari.substS(DirName);

end;



function FILEst(prev,eld:TStatement):TStatement;
begin
    if token='DELETE' then
       begin
          gettoken;
          result:=UNSAVEst(prev,eld);
       end
    else if token='GETNAME' then
       begin
          gettoken;
          result:=TGetName.create(prev,eld,0);
       end
    else if token='GETOPENNAME' then
       begin
          gettoken;
          result:=TGetName.create(prev,eld,1);
       end
    else if token='GETSAVENAME' then
       begin
          gettoken;
          result:=TGetName.create(prev,eld,2);
       end
    else if token='GETDIRECTORYNAME' then
       begin
          gettoken;
          result:=TGetDirectoryName.create(prev,eld);
       end
    else if token='SPLITNAME' then
       begin
          gettoken;
          result:=TSplitName.create(prev,eld);
       end
    else if token='RENAME' then
       begin
          gettoken;
          result:=TFileRename.create(prev,eld);
       end
    else if token='LIST' then
       begin
          gettoken;
          result:=TFileList.create(prev,eld);
       end

    else
           seterrIllegal(Token, IDH_FILE_ENLARGE)
end;

function DIRECTORYst(prev,eld:TStatement):TStatement;
begin
    if token='GETNAME' then
       begin
          gettoken;
          result:=TGetDirectoryName.create(prev,eld);
       end
    else
           seterrIllegal(Token, IDH_FILE_ENLARGE)
end;

function MAKEst(prev,eld:TStatement):TStatement;
begin
  if token='DIRECTORY' then
       begin
          gettoken;
          result:=TMakeDir.create(prev,eld);
       end
    else
           seterrIllegal(Token, IDH_FILE_ENLARGE)
end;

function REMOVEst(prev,eld:TStatement):TStatement;
begin
  if token='DIRECTORY' then
       begin
          gettoken;
          result:=TRemoveDir.create(prev,eld);
       end
    else
           seterrIllegal(Token, IDH_FILE_ENLARGE)
end;







{*******************************************}
{Number of Files that matches the expression}
{*******************************************}

type
    TNumFiles=class(TMiscInt)
       exp:TPrincipal;
      constructor create;
      function evalLongint:longint;override;
      destructor destroy;override;
    end;


constructor TNumFiles.create;
begin
     inherited create;
     checkToken('(',IDH_EXTENSION) ;
     exp:=SExpression;
     checkToken(')',IDH_EXTENSION);
end;

function TNumFiles.evalLongint:longint;
var
   s:string;
   Rec:TSearchRec;
begin
    s:=exp.evalS;
    result:=0;
    try
      if FindFirst(s,0,Rec)=0 then
        begin
          inc(result);
          while FindNext(Rec)=0 do
             inc(result);
         end;
    finally
       FindClose(Rec);
    end;
end;

destructor TNumFiles.destroy;
begin
    exp.free;
    inherited destroy
end;

function  Filesfnc:TPrincipal;
begin
      result:=NOperation(TNumFiles.create)
end;


{*************}
{Win32 API関数}
{*************}
(*
type
    TGetKeyState=class(TMiscInt)
       exp:TPrincipal;
      constructor create;
      function evalLongint:longint;override;
      destructor destroy;override;
    end;


constructor TGetKeyState.create;
begin
     inherited create;
     checkToken('(',IDH_EXTENSION) ;
     exp:=NExpression;
     checkToken(')',IDH_EXTENSION);
end;

function TGetKeyState.evalLongint:longint;
begin
   result:=GetKeyState(exp.evalinteger);
end;

destructor TGetKeyState.destroy;
begin
    exp.free;
    inherited destroy
end;

function  GetKeyStatefnc:TPrincipal;
begin
      GetKeyStatefnc:=NOperation(TGetKeyState.create)
end;
*)

{****************}
{Pack$ and Unpack}
{****************}

type
   TPack=class(TStrExpression)
             exp:TPrincipal;
          constructor create;
          function evalS:ansistring;override;
          destructor destroy;override;
     end;

constructor TPack.create;
begin
   inherited create;
   exp:=argumentN1;
end;

function TPack.evalS:ansistring;
var
   d:double;
   s:string[8];
begin
   d:=exp.evalX;
   move(d,s[1],8);
   setlength(s,8);
   result:=s;
end;

destructor TPack.destroy;
begin
   exp.free;
   inherited destroy;
end;

type
   TDWordStr=class(Tpack)
          function evalS:ansistring;override;
   end;

function TDWordStr.evalS:ansistring;
var
   d:DWord;
   s:string[4];
begin
   d:=Trunc(exp.evalX);
   move(d,s[1],4);
   setlength(s,4);
   result:=s;
end;

type
   TWordStr=class(Tpack)
          function evalS:ansistring;override;
   end;

function TWordStr.evalS:ansistring;
var
   w:word;
   s:string[2];
begin
   w:=exp.evalInteger;
   move(w,s[1],2);
   setlength(s,2);
   result:=s;
end;

type
   TByteStr=class(Tpack)
          function evalS:ansistring;override;
   end;

function TByteStr.evalS:ansistring;
var
   b:byte;
   s:string[1];
begin
   b:=exp.evalInteger;
   move(b,s[1],1);
   setlength(s,1);
   result:=s;
end;

function Packfnc:TPrincipal;
begin
   Packfnc:=TPack.create;
end;

function DWordfnc:TPrincipal;
begin
   DWordfnc:=TDWordStr.create;
end;

function Wordfnc:TPrincipal;
begin
   Wordfnc:=TWordStr.create;
end;

function Bytefnc:TPrincipal;
begin
   Bytefnc:=TByteStr.create;
end;




type
   TUnpack=Class(TMiscReal)
             exp:TPrincipal;
          constructor create;
          function evalX:extended;override;
          destructor destroy;override;
     end;

constructor TUnPack.create;
begin
    inherited create;
    check('(',0);
    exp:=SExpression;
    check(')',0);
end;

function TUnPack.evalX:extended;
var
   s:string[8];
   d:double;
begin
   s:=exp.evalS;
   move(s[1],d,8);
   result:=d;
end;

destructor TUnPack.destroy;
begin
   exp.free;
   inherited destroy;
end;

function UnPackfnc:TPrincipal;
begin
   UnPackfnc:=NOperation(TUnPack.create);
end;

{*************}
{Win32 API関数}
{*************}
type
    TGetKeyState=class(TMiscInt)
       exp:TPrincipal;
      constructor create;
      function evalLongint:longint;override;
      destructor destroy;override;
    end;


constructor TGetKeyState.create;
begin
     inherited create;
     checkToken('(',IDH_EXTENSION) ;
     exp:=NExpression;
     checkToken(')',IDH_EXTENSION);
end;

function TGetKeyState.evalLongint:longint;
begin
   result:=GetKeyState(exp.evalinteger);
end;

destructor TGetKeyState.destroy;
begin
    exp.free;
    inherited destroy
end;

function  GetKeyStatefnc:TPrincipal;
begin
      GetKeyStatefnc:=NOperation(TGetKeyState.create)
end;


{**************}
{BIT operations}
{**************}
type
  TBitNOT=class(TMiscReal)
      exp:TPrincipal;
      constructor create;
      function evalX:Extended;override;
  end;
constructor TBitNOT.create;
begin
    inherited create;
    check('(',0);
    exp:=NExpression;
    check(')',0);
end;

function TBitNOT.evalX:extended;
begin
   result:=not System.Round(exp.evalX)
end;

type
  TBitOp=class(TMiscReal)
      exp1,exp2:Tprincipal;
      constructor create;
  end;

constructor TBitOp.create;
begin
    inherited create;
    check('(',0);
    exp1:=NExpression;
    check(',',0);
    exp2:=NExpression;
    check(')',0);
end;



type
  TBitAND=class(TBitOp)
      function evalX:Extended;override;
  end;
  TBitOR=class(TBitOp)
      function evalX:Extended;override;
  end;
  TBitXOR=class(TBitOp)
      function evalX:Extended;override;
  end;
  TBitIMP=class(TBitOp)
      function evalX:Extended;override;
  end;
  TBitEQV=class(TBitOp)
      function evalX:Extended;override;
  end;

function TBitAND.evalX:extended;
begin
   result:=System.Round(exp1.evalX) and System.Round(exp2.evalX)
end;

function TBitOR.evalX:extended;
begin
   result:=System.Round(exp1.evalX) or System.Round(exp2.evalX)
end;

function TBitXOR.evalX:extended;
begin
   result:=System.Round(exp1.evalX) xor System.Round(exp2.evalX)
end;

function TBitIMP.evalX:extended;
begin
   result:=not System.Round(exp1.evalX) or System.Round(exp2.evalX)
end;

function TBitEQV.evalX:extended;
begin
   result:=not (System.Round(exp1.evalX) xor System.Round(exp2.evalX))
end;

function  BitNotfnc:TPrincipal;
begin
    Result:=NOperation(TBitNOT.create)
end;

function  BitAndfnc:TPrincipal;
begin
    Result:=NOperation(TBitAND.create)
end;

function  BitOrfnc:TPrincipal;
begin
    Result:=NOperation(TBitOR.create)
end;

function  BitXorfnc:TPrincipal;
begin
    Result:=NOperation(TBitXOR.create)
end;

function  BitIMPfnc:TPrincipal;
begin
    Result:=NOperation(TBitIMP.create)
end;

function  BitEQVfnc:TPrincipal;
begin
    Result:=NOperation(TBitEQV.create)
end;

{*******************}
{Confirmation Dialog}
{*******************}

type
   TConfirm=class(TStrExpression)
             exp:TPrincipal;
          constructor create;
          function evalS:ansistring;override;
          destructor destroy;override;
     end;

constructor TConfirm.create;
begin
   inherited create;
   exp:=SExpression;
end;


destructor TConfirm.destroy;
begin
   exp.free;
   inherited destroy;
end;



function TCONFIRM.evalS:AnsiString;
begin
  sleep(50);        //2019/09/02 Ver 8.0.1.7
  result:=YesNoLiteral[ThreadMessageDlg(exp.evalS,mtConfirmation,[mbYes,mbNo],0)=mrYes]
end;

function CONFIRMfnc:TPrincipal;
begin
    CONFIRMfnc:=TCONFIRM.create
end;




{**********}
{initialize}
{**********}

procedure statementTableinit;
begin
       StatementTableInitImperative('SWAP',SWAPst);
       StatementTableInitImperative('PAUSE',PAUSEst);
       StatementTableInitImperative('WAIT',WAITst);
       //StatementTableInitImperative('CONFIRM',CONFIRMst);
       StatementTableInitImperative('BEEP',BEEPst);
       StatementTableInitImperative('UNSAVE',UNSAVEst);
       StatementTableInitImperative('KILL',UNSAVEst);
       StatementTableInitImperative('FILE',FILEst);
       StatementTableInitImperative('DIRECTORY',DIRECTORYst);
       StatementTableInitImperative('MAKE',MAKEst);
       StatementTableInitImperative('REMOVE',REMOVEst);


end;


procedure  FunctionTableInit;
begin
    {$IFNDEF Darwin}
     SuppliedFunctionTableInit('GETKEYSTATE' , GetKeyStatefnc);
    {$ENDIF}
     SuppliedFunctionTableInit('FILES' , Filesfnc);
     SuppliedFunctionTableInit('PACKDBL$' , Packfnc);
     SuppliedFunctionTableInit('DWORD$' , DWordfnc);
     SuppliedFunctionTableInit('WORD$' , Wordfnc);
     SuppliedFunctionTableInit('BYTE$' , Bytefnc);
     SuppliedFunctionTableInit('UNPACKDBL' , UnPackfnc);
      SuppliedFunctionTableInit('BITNOT' , BitNOTfnc);
     SuppliedFunctionTableInit('BITAND' , BitANDfnc);
     SuppliedFunctionTableInit('BITOR' , BitORfnc);
     SuppliedFunctionTableInit('BITXOR' , BitXORfnc);
     SuppliedFunctionTableInit('CONFIRM$',CONFIRMfnc);

end;


begin
  tableInitProcs.accept(statementTableinit);
  tableInitProcs.accept(FunctionTableInit);
end.
