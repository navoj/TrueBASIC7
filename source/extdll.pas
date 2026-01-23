unit extdll;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}
interface
uses struct;
procedure PrepareCallback(Proc:TRoutine);

implementation
uses
    {$IFDEF UNIX}
     dl,
    {$ENDIF}
    {$IFDEF Windows}
     Windows,
    {$ENDIF}
     SysUtils, Forms,Controls,
     variabl,express,texthand,base,HelpCtex,supplied,SConsts,math2,
     MainFrm,textfrm,paintfrm,tracefrm,inputdlg,charinp,locatefrm,locatech;

const DLL_Error=-9900;
const MissingCALLBACK=-9901;



{*******}
{ŠO•”DLL}
{*******}
type
    PPointerArray=^TPointerArray;
    TPointerArray=array[0..7] of pointer;
    TLongIntFunction=function:LongInt;
    TFPUFunction=function:extended;
    TAssign=class(TStatement)
      {$IFDEF UNIX}
       Handle:Pointer;
      {$ELSE}
       Handle:THandle;
      {$ENDIF}
       ProcAddr:TLongIntFunction;
       ProcAddrX:TFPUFunction;
       NumParam:integer;
       params:PPointerArray;
       ResultType:char;
       GUI:boolean;
       CDecl:boolean;
       constructor create(prev,eld:TStatement);
     procedure exec;override;
     destructor destroy;override;
    end;

constructor TAssign.Create(prev,eld:TStatement);
var
  Routine:TRoutine;
begin
  inherited create(prev,eld);
  routine:=localroutine;
  if routine=nil then routine:=programunit;

{$IFDEF UNIX}
  Cdecl:=true;
  Handle:=dlopen (PChar(ExtractFilePath(Application.ExeName)+TokenString), RTLD_LAZY);
  if Handle=nil then
     Handle:=dlopen (PChar(TokenString), RTLD_LAZY);
  if (Handle=nil) then
     SetErr(tokenString + ' could not be loaded' ,IDH_DLL);
  if Handle<>nil then
     begin
        gettoken;
        check(',',IDH_DLL);
        Pointer(@ProcAddr):= dlsym(Handle, PChar(TokenString));
        gettoken;
     end ;
{$ELSE}
  Handle:=LoadLibrary(PChar(ExtractFilePath(Application.ExeName)+TokenString));
  if Handle=0 then
     Handle:=LoadLibrary(PChar(TokenString));
  if (Handle=0) then
     SetErr(tokenString + ' could not be loaded' ,IDH_DLL);
  if Handle<>0 then
     begin
        gettoken;
        check(',',IDH_DLL);
        @ProcAddr:=GetProcAddress(Handle,PChar(TokenString));
        gettoken;
     end ;
{$ENDIF}

  if @ProcAddr=nil then
                 SetErr(tokenString+ s_isnotfound,IDH_DLL);

  NumParam:=Routine.paramcount;
 {$IFDEF CPUAArch64}
  if NumParam>12 then seterr('Sorry, too many params',IDH_DLL);
 {$ENDIF}
  {$IFDEF CPUArm}
  if NumParam>12 then seterr('Sorry, too many params',IDH_DLL);
 {$ENDIF}

  params:=AllocMem(sizeof(pointer)*NumParam);

  (*
  if (Routine.Resultvar<>nil) and test(',') then
     begin
        CheckToken('FPU',IDH_EXTENSION_MS);
         @ProcAddrX:=@ProcAddr;
        @ProcAddr:=nil;
     end;*)

   if  token=',' then
     begin
        if (Routine.Resultvar<>nil) and(nexttoken='FPU') then
           begin
             gettoken;
             gettoken;
             @ProcAddrX:=@ProcAddr;
             @ProcAddr:=nil;
           end
        else if nexttoken='GUI' then
           begin
              gettoken;
              gettoken;
              GUI:=true;
           end
    end;
    if  test(',')
        and ((token='CDECL') {$IFDEF Windows}or (token='STDCALL'){$ENDIF} ) then
           begin
              CDECL:=(token='CDECL');
              gettoken;
           end;
end;

destructor TAssign.destroy;
begin
{$IFDEF UNIX}
  if Handle<>nil then
      dlclose(Handle);
{$ELSE}
  FreeLibrary(Handle);
{$ENDIF}
  if params<>nil then freemem(params,sizeof(pointer)*NumParam);
  inherited destroy
end;

Function GetString(p:PChar):string;
begin
  result:=p
end;

{$IF DEFined(CPU386)}
{$ASMMODE INTEL}
Function RoundToLongint(x:extended):longint;assembler;
asm
    PUSH EDX
    PUSH EAX
    FLD x
    FISTP QWORD PTR [ESP]
    WAIT
    POP EAX
    POP EDX
end;

procedure TAssign.exec;
var
   i,j:integer;
   p:pointer;
   x:double;
begin
   if GUI then sleep(50);        //2019/09/02 Ver 8.0.1.7

   i:=0;

   try
     //SetFPUMask(OriginalCW);
     while i<NumParam do
       begin
         with TIdRec(Proc.VarTable.items[i]) do
           if kindchar='s' then
              string(params^[i]):=subs.evalS
           else
              begin
                longint(params^[i]):=RoundToLongint(subs.evalX);
              end;
         inc(i);
       end;

     try
       j:=i;
       while j>0 do
         begin
           dec(j);
           p:=@params^[j];
           asm
             mov eax, p
             push dword ptr [eax]
           end;
         end;
       if Proc.resultVar<>nil then
           if @ProcAddr<>nil then
              if Proc.resultVar.kindchar='n' then
                 Proc.resultVar.subs.assignLongint(ProcAddr)
              else
                 Proc.resultVar.subs.substS(GetString(Pchar(ProcAddr)))
           else
              Proc.resultVar.subs.assignX(ProcAddrX)
       else
            ProcAddr;

    if cdecl then
      // restore stack  (assume Cdecl)
        begin
         j:=i;
         while j>0 do
           begin
             asm
               pop EAX
             end;
             dec(j);
         end;
       end;

     except
      on E:EExtype do
         raise;
      else
         SetException(DLL_Error)
     end;

   finally
     //SetFPUMask(NormalCW);
     while i>0 do
       begin
         dec(i);
         with TIdRec(Proc.VarTable.items[i]) do
           if kindchar='s' then
              string(params^[i]):=''
           else
              longint(params^[i]):=0;
       end;
   end;

end;
{$ELSEIF Defined(CPUx86_64)}
{$ASMMODE INTEL}

Function RoundToInt64(x:extended):Int64;
begin
   result:=Round(x)
end;

{$IF DEFINED(Windows)}
 procedure TAssign.exec;
var
   i,j:integer;
   p:pointer;
   x:Int64;
begin
   if GUI then sleep(50);        //2019/09/02 Ver 8.0.1.7

   i:=0;

   try
     while i<NumParam do
       begin
         with TIdRec(Proc.VarTable.items[i]) do
           if kindchar='s' then
              string(params^[i]):=subs.evalS
           else
              begin
                Int64(params^[i]):=RoundToInt64(subs.evalX);
              end;
         inc(i);
       end;

     try
      if NumParam>0 then
         begin
            x:=int64(params^[0]);
            asm
               mov  rcx,x
            end;
         end;
       if NumParam>1 then
         begin
            x:=int64(params^[1]);
            asm
               mov  rdx,x
            end;
         end;
       if NumParam>2 then
         begin
            x:=int64(params^[2]);
            asm
               mov  r8,x
            end;
         end;
       if NumParam>3 then
          begin
             x:=int64(params^[3]);
             asm
                mov  r9,x
             end;
          end;

       asm
         sub rsp, 4*sizeof(nativeInt)
       end;

      for i:=4 to NumParam-1 do
        begin
          p:=@params^[i];
          asm
            mov  rax, p
            push qword ptr [rax]
          end;
        end;



       if Proc.resultVar<>nil then
           if @ProcAddr<>nil then
              if Proc.resultVar.kindchar='n' then
                 Proc.resultVar.subs.assignLongint(ProcAddr)
              else
                 Proc.resultVar.subs.substS(GetString(Pchar(ProcAddr)))
           else
              Proc.resultVar.subs.assignX(ProcAddrX)
       else
            ProcAddr;

       // restore stack  ()
        begin
        end;

     except
      on E:EExtype do
         raise;
      else
         SetException(DLL_Error)
     end;

   finally
     while i>0 do
       begin
         dec(i);
         with TIdRec(Proc.VarTable.items[i]) do
           if kindchar='s' then
              string(params^[i]):=''
           else
              Int64(params^[i]):=0;
       end;
   end;

end;




{$ELSE}
 procedure TAssign.exec;
var
   i,j:integer;
   p:pointer;
   x:Int64;
begin
   if GUI then sleep(50);        //2019/09/02 Ver 8.0.1.7

   i:=0;

   try
     SetFPUMask(OriginalCW);
     while i<NumParam do
       begin
         with TIdRec(Proc.VarTable.items[i]) do
           if kindchar='s' then
              string(params^[i]):=subs.evalS
           else
              begin
                Int64(params^[i]):=RoundToInt64(subs.evalX);
              end;
         inc(i);
       end;

     try
        j:=NumParam;
        while j>6 do
          begin
            dec(j);
            x:=int64(params^[j]);
            asm
            push x
            end;
          end;
        if NumParam>=6 then
           begin
             x:=int64(params^[5]);
             asm
                mov  r9,x
             end;
          end;
        if NumParam>=5 then
           begin
             x:=int64(params^[4]);
             asm
                mov  r8,x
             end;
          end;
         if NumParam>=4 then
             begin
               x:=int64(params^[3]);
               asm
                  mov  rcx,x
               end;
            end;
        if NumParam>=3 then
            begin
              x:=int64(params^[2]);
              asm
                 mov  rdx,x
              end;
           end;
        if NumParam>=2 then
            begin
              x:=int64(params^[1]);
              asm
                 mov  rsi,x
              end;
           end;
        if NumParam>=1 then
            begin
              x:=int64(params^[0]);
              asm
                 mov  rdi,x
              end;
           end;


       if Proc.resultVar<>nil then
           if @ProcAddr<>nil then
              if Proc.resultVar.kindchar='n' then
                 Proc.resultVar.subs.assignLongint(ProcAddr)
              else
                 Proc.resultVar.subs.substS(GetString(Pchar(ProcAddr)))
           else
              Proc.resultVar.subs.assignX(ProcAddrX)
       else
            ProcAddr;

       // restore stack  ()
        begin
        end;

     except
      on E:EExtype do
         raise;
      else
         SetException(DLL_Error)
     end;

   finally
     //SetFPUMask(NormalCW);
     while i>0 do
       begin
         dec(i);
         with TIdRec(Proc.VarTable.items[i]) do
           if kindchar='s' then
              string(params^[i]):=''
           else
              Int64(params^[i]):=0;
       end;
   end;

end;

{$ENDIF}

{$ELSEIF DEFINED(CPUAARCH64)}

Function RoundToInt64(x:extended):Int64;
begin
   result:=Round(x)
end;

procedure TAssign.exec;
var
   i:integer;
   p:pointer;
   x:Int64;
   a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11:int64;
   function assignsub(a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11:int64; a12:pointer):int64; assembler;
   asm
      mov x0,x1
      mov x1,x2
      mov x2,x3
      mov x3,x4
      mov x4,x5
      mov x5,x6
      mov x6,x7
      ldr x7, [sp,#16]
      ldr x8, [sp,#24]
      ldr x9, [sp,#32]
      ldr x10,[sp,#40]
      ldr x11,[sp,#48]
      ldr x12,[sp,#56]
      stp x10,x11,[sp,#-16]!
      stp x8,x9,  [sp,#-16]!
      blr x12
      ldp x8,x9,  [sp],#16
      ldp x10,x11,[sp],#16
   end;

begin
   if GUI then sleep(50);        //2019/09/02 Ver 8.0.1.7
   p:=@procaddr;
   i:=0;
   try
     while i<NumParam do
       begin
         with TIdRec(Proc.VarTable.items[i]) do
           if kindchar='s' then
              string(params^[i]):=subs.evalS
           else
              begin
                Int64(params^[i]):=RoundToInt64(subs.evalX);
              end;
         inc(i);
       end;
      if NumParam>0 then   a0:=int64(params^[0])  else  a0:=0;;
      if NumParam>1 then   a1:=int64(params^[1])  else  a1:=1;;
      if NumParam>2 then   a2:=int64(params^[2])  else  a2:=2;;
      if NumParam>3 then   a3:=int64(params^[3])  else  a3:=3;;
      if NumParam>4 then   a4:=int64(params^[4])  else  a4:=4;;
      if NumParam>5 then   a5:=int64(params^[5])  else  a5:=5;;
      if NumParam>6 then   a6:=int64(params^[6])  else  a6:=6;;
      if NumParam>7 then   a7:=int64(params^[7])  else  a7:=7;;
      if NumParam>8 then   a8:=int64(params^[8])  else  a8:=8;;
      if NumParam>9 then   a9:=int64(params^[9])  else  a9:=9;;
      if NumParam>10 then a10:=int64(params^[10]) else a10:=10;;
      if NumParam>11 then a11:=int64(params^[11]) else a11:=11;;

      try
       x:= assignsub( a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,p);

       if Proc.resultVar<>nil then
           if @ProcAddr<>nil then
              if Proc.resultVar.kindchar='n' then
                 Proc.resultVar.subs.assignX( x)
              else
                 Proc.resultVar.subs.substS(GetString(Pchar(x)))
           else
              {Proc.resultVar.subs.assignX(ProcAddrX) }
       else
            {ProcAddr};

       // restore stack  ()
        begin
        end;

     except
      on E:EExtype do
         raise;
      on E:exception do
         SetExceptionWith(E.Message, DLL_Error)
     end;

   finally
     while i>0 do
       begin
         dec(i);
         with TIdRec(Proc.VarTable.items[i]) do
           if kindchar='s' then
              string(params^[i]):=''
           else
              Int64(params^[i]):=0;
       end;
   end;

end;

{$ELSEIF DEFINED(CPUArm)}

Function RoundToInt(x:extended):NativeInt;
begin
   result:=Round(x)
end;

procedure TAssign.exec;
var
   i:integer;
   p:pointer;
   x:NativeInt;
   a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11:NativeInt;
  function assignsub(a0,a1,a2,a3:NativeInt; a4:pointer):NativeInt; assembler;
   asm
      mov r0,r1
      mov r1,r2
      mov r2,r3
      ldr r3,[r11,#4]
      ldr r12,[r11,#8]
      blx r12
   end;
  function assignsub1(a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11:NativeInt; a12:pointer):NativeInt; assembler;
   asm
      mov r0,r1
      mov r1,r2
      mov r2,r3
      ldr r12,[r11,#36]  //a11
      ldr r3, [r11,#32]  //a10
      push {r3, r12}
      ldr r12,[r11,#28]  //a9
      ldr r3, [r11,#24]  //a8
      push {r3, r12}
      ldr r12,[r11,#20]  //a7
      ldr r3, [r11,#16]  //a6
      push {r3, r12}
      ldr r12,[r11,#12]  //a5
      ldr r3, [r11,#8]   //a4
      push {r3, r12}
      ldr r3,[r11,#4]    //a3
      ldr r12,[r11,#40]  //a12
      blx r12
      pop  {r3, r12}
      pop  {r3, r12}
      pop  {r3, r12}
      pop  {r3, r12}
   end;


begin
   if GUI then sleep(50);        //2019/09/02 Ver 8.0.1.7
   p:=@procaddr;
   i:=0;
   try
     while i<NumParam do
       begin
         with TIdRec(Proc.VarTable.items[i]) do
           if kindchar='s' then
              string(params^[i]):=subs.evalS
           else
              begin
                NativeInt(params^[i]):=RoundToInt(subs.evalX);
              end;
         inc(i);
       end;
      if NumParam>0 then  a0:=int64(params^[0]) else a0:=0;;
      if NumParam>1 then  a1:=int64(params^[1]) else a1:=1;;
      if NumParam>2 then  a2:=int64(params^[2]) else a2:=2;;
      if NumParam>3 then  a3:=int64(params^[3]) else a3:=3;;
      if NumParam>4 then
        begin
          if NumParam>4  then  a4:=int64(params^[4])  else  a4:=4;;
          if NumParam>5  then  a5:=int64(params^[5])  else  a5:=5;;
          if NumParam>6  then  a6:=int64(params^[6])  else  a6:=6;;
          if NumParam>7  then  a7:=int64(params^[7])  else  a7:=7;;
          if NumParam>8  then  a8:=int64(params^[8])  else  a8:=8;;
          if NumParam>9  then  a9:=int64(params^[9])  else  a9:=9;;
          if NumParam>10 then a10:=int64(params^[10]) else a10:=10;;
          if NumParam>11 then a11:=int64(params^[11]) else a11:=11;;
       end;

      try
       if Numparam<=4 then
          x:= assignsub(a0,a1,a2,a3,p)
       else
          x:= assignsub1(a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,p) ;

       if Proc.resultVar<>nil then
           if @ProcAddr<>nil then
              if Proc.resultVar.kindchar='n' then
                 Proc.resultVar.subs.assignX( x)
              else
                 Proc.resultVar.subs.substS(GetString(Pchar(x)))
           else
              {Proc.resultVar.subs.assignX(ProcAddrX) }
       else
            {ProcAddr};

       // restore stack  ()
        begin
        end;

     except
      on E:EExtype do
         raise;
      on E:exception do
         SetExceptionWith(E.Message, DLL_Error)
     end;

   finally
     while i>0 do
       begin
         dec(i);
         with TIdRec(Proc.VarTable.items[i]) do
           if kindchar='s' then
              string(params^[i]):=''
           else
              NativeInt(params^[i]):=0;
       end;
   end;

end;
{$ELSE}
procedure TAssign.exec;
begin

end;
{$ENDIF}


function  ASSIGNst(prev,eld:TStatement):TStatement;
begin
   ASSIGNst:=TAssign.create(prev,eld);
end;


{*************}
{ CallBack    }
{*************}

type
    TIntArray=array[0..8] of NativeInt;
    PIntArray=^TIntArray;

var
   ProcPtr: array[0..9]of TRoutine;
   NumParams:array[0..9]of integer;
   {$IFDEF CPU386}
   ccCdecl:array[0..9]of boolean;
   {$ENDIF}


{$IF DEFINED(cpu32)}
function ManageCallBack(n:integer; p:PIntArray):integer;
var
   i,j:integer;
   svCurrentStatement,svNextStatement:TStatement;
begin
  result:=0;

  with ProcPtr[n] do
    begin
      NumParams[n]:=Paramcount;

      VarTable.pushStack;
      for j:=0 to VarTable.count-1 do
        TIdrec(VarTable.items[j]).subs.getVar1;

      for i:=0 to ParamCount-1 do
        begin
          with TIdRec(VarTable.items[i]) do
             case kindchar of
               's':
                 subs.substS(PChar(p^[i]));
               'n':
                 subs.assignLongint(p^[i]);
             end;
        end;

      svCurrentStatement:=CurrentStatement;
      svNextStatement:=NextStatement;
      try
        try
          runBlock(block);
        except
          On E:EControlException do
           if    (kind='F') and (E is EExitFunction)
               or (kind='S') and (E is EExitSub)
               or (kind='P') and (E is EExitPicture)
           then
           else
             raise
        end;
        if resultvar<>nil then
          with ResultVar do
             case kindchar of
               's': result:=LongInt(Pchar(resultvar.subs.evalS));
               'n': result:=resultvar.subs.evalLongInt;
             end;
      finally
         CurrentStatement:=svCurrentStatement;
         NextStatement:=svNextStatement;

         for j:=VarTable.count -1 downto 0 do
            TIdrec(VarTable.items[j]).FreeVar;
         VarTable.popStack;

         propagateException;
      end;
  end;
end;

{$IF DEFINED(CPUARM)}
function CallBack0(a0,a1,a2,a3:NativeInt):NativeInt;
var
   p0:TIntArray;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  result:=ManageCallBack(0,@p0);
end;

function CallBack1(a0,a1,a2,a3:NativeInt):NativeInt;
var
   p0:TIntArray;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  result:=ManageCallBack(1,@p0);
end;

function CallBack2(a0,a1,a2,a3:NativeInt):NativeInt;
var
   p0:TIntArray;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  result:=ManageCallBack(2,@p0);
end;

function CallBack3(a0,a1,a2,a3:NativeInt):NativeInt;
var
   p0:TIntArray;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  result:=ManageCallBack(3,@p0);
end;

function CallBack4(a0,a1,a2,a3:NativeInt):NativeInt;
var
   p0:TIntArray;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  result:=ManageCallBack(4,@p0);
end;

function CallBack5(a0,a1,a2,a3,a4:NativeInt):NativeInt;
var
   p0:TIntArray;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  p0[4]:=a4;
  result:=ManageCallBack(5,@p0);
end;

function CallBack6(a0,a1,a2,a3,a4,a5:NativeInt):NativeInt;
var
   p0:TIntArray;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  p0[4]:=a4;
  p0[5]:=a5;
  result:=ManageCallBack(6,@p0);
end;

function CallBack7(a0,a1,a2,a3,a4,a5,a6:NativeInt):NativeInt;
var
   p0:TIntArray;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  p0[4]:=a4;
  p0[5]:=a5;
  p0[6]:=a6;
  result:=ManageCallBack(7,@p0);
end;

function CallBack8(a0,a1,a2,a3,a4,a5,a6,a7:NativeInt):NativeInt;
var
   p0:TIntArray;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  p0[4]:=a4;
  p0[5]:=a5;
  p0[6]:=a6;
  p0[7]:=a7;
  result:=ManageCallBack(8,@p0);
end;

function CallBack9(a0,a1,a2,a3,a4,a5,a6,a7,a8:NativeInt):NativeInt;
var
   p0:TIntArray;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  p0[4]:=a4;
  p0[5]:=a5;
  p0[6]:=a6;
  p0[7]:=a7;
  p0[8]:=a8;
  result:=ManageCallBack(9,@p0);
end;
{$ELSEIF DEFINED(CPU386) and DEFINED(windows)}
function CallBack0:longint; stdcall;
begin
  result:=ManageCallBack(0,nil);
end;

function CallBack1(p0:longint):longint; stdcall;
begin
  result:=ManageCallBack(1,@p0);
end;

function CallBack2(p0,p1:longint):longint; stdcall;
begin
  result:=ManageCallBack(2,@p0);
end;

function CallBack3(p0,p1,p2:longint):longint; stdcall;
begin
  result:=ManageCallBack(3,@p0);
end;

function CallBack4(p0,p1,p2,p3:longint):longint; stdcall;
begin
  result:=ManageCallBack(4,@p0);
end;

function CallBack5(p0,p1,p2,p3,p4:longint):longint; stdcall;
begin
  result:=ManageCallBack(5,@p0);
end;

function CallBack6(p0,p1,p2,p3,p4,p5:longint):longint; stdcall;
begin
  result:=ManageCallBack(6,@p0);
end;

function CallBack7(p0,p1,p2,p3,p4,p5,p6:longint):longint; stdcall;
begin
  result:=ManageCallBack(7,@p0);
end;

function CallBack8(p0,p1,p2,p3,p4,p5,p6,p7:longint):longint; stdcall;
begin
  result:=ManageCallBack(8,@p0);
end;

function CallBack9(p0,p1,p2,p3,p4,p5,p6,p7,p8:longint):longint; stdcall;
begin
  result:=ManageCallBack(9,@p0);
end;

function CallBack0C:longint; cdecl;
begin
  result:=ManageCallBack(0,nil);
end;

function CallBack1C(p0:longint):longint; cdecl;
begin
  result:=ManageCallBack(1,@p0);
end;

function CallBack2C(p0,p1:longint):longint; cdecl;
begin
  result:=ManageCallBack(2,@p0);
end;

function CallBack3C(p0,p1,p2:longint):longint; cdecl;
begin
  result:=ManageCallBack(3,@p0);
end;

function CallBack4C(p0,p1,p2,p3:longint):longint; cdecl;
begin
  result:=ManageCallBack(4,@p0);
end;

function CallBack5C(p0,p1,p2,p3,p4:longint):longint; cdecl;
begin
  result:=ManageCallBack(5,@p0);
end;

function CallBack6C(p0,p1,p2,p3,p4,p5:longint):longint; cdecl;
begin
  result:=ManageCallBack(6,@p0);
end;

function CallBack7C(p0,p1,p2,p3,p4,p5,p6:longint):longint; cdecl;
begin
  result:=ManageCallBack(7,@p0);
end;

function CallBack8C(p0,p1,p2,p3,p4,p5,p6,p7:longint):longint; cdecl;
begin
  result:=ManageCallBack(8,@p0);
end;

function CallBack9C(p0,p1,p2,p3,p4,p5,p6,p7,p8:longint):longint; cdecl;
begin
  result:=ManageCallBack(9,@p0);
end;
{$ELSEIF DEFINED(CPU386) and DEFINED(Linux)}
function CallBack0:longint; CDECL;
begin
  result:=ManageCallBack(0,nil);
end;

function CallBack1(p0:longint):longint; CDECL;
begin
  result:=ManageCallBack(1,@p0);
end;

function CallBack2(p0,p1:longint):longint; CDECL;
begin
  result:=ManageCallBack(2,@p0);
end;

function CallBack3(p0,p1,p2:longint):longint; CDECL;
begin
  result:=ManageCallBack(3,@p0);
end;

function CallBack4(p0,p1,p2,p3:longint):longint; CDECL;
begin
  result:=ManageCallBack(4,@p0);
end;

function CallBack5(p0,p1,p2,p3,p4:longint):longint; CDECL;
begin
  result:=ManageCallBack(5,@p0);
end;

function CallBack6(p0,p1,p2,p3,p4,p5:longint):longint; CDECL;
begin
  result:=ManageCallBack(6,@p0);
end;

function CallBack7(p0,p1,p2,p3,p4,p5,p6:longint):longint; CDECL;
begin
  result:=ManageCallBack(7,@p0);
end;

function CallBack8(p0,p1,p2,p3,p4,p5,p6,p7:longint):longint; CDECL;
begin
  result:=ManageCallBack(8,@p0);
end;

function CallBack9(p0,p1,p2,p3,p4,p5,p6,p7,p8:longint):longint; CDECL;
begin
  result:=ManageCallBack(9,@p0);
end;

{$ENDIF}

{$ELSEIF Defined(CPU64)}
type
    Int64Array=array[0..8] of Int64;
    PInt64Array=^Int64Array;


function ManageCallBack(n:integer; p:PInt64Array):int64;
var
   i,j:integer;
   svCurrentStatement,svNextStatement:TStatement;
begin
  result:=0;

  with ProcPtr[n] do
    begin
      NumParams[n]:=Paramcount;

      VarTable.pushStack;
      for j:=0 to VarTable.count-1 do
        TIdrec(VarTable.items[j]).subs.getVar1;

      for i:=0 to ParamCount-1 do
        begin
          with TIdRec(VarTable.items[i]) do
             case kindchar of
               's':
                 subs.substS(PChar(p^[i]));
               'n':
                 subs.assignX(p^[i]);
                 //subs.assignLongint(p^[i]);
             end;
        end;

      svCurrentStatement:=CurrentStatement;
      svNextStatement:=NextStatement;
      try
        try
          runBlock(block);
        except
          On E:EControlException do
           if    (kind='F') and (E is EExitFunction)
               or (kind='S') and (E is EExitSub)
               or (kind='P') and (E is EExitPicture)
           then
           else
             raise
        end;
        if resultvar<>nil then
          with ResultVar do
             case kindchar of
               's': result:=LongInt(Pchar(resultvar.subs.evalS));
               'n': result:=trunc(resultvar.subs.evalX);
             end;
      finally
         CurrentStatement:=svCurrentStatement;
         NextStatement:=svNextStatement;

         for j:=VarTable.count -1 downto 0 do
            TIdrec(VarTable.items[j]).FreeVar;
         VarTable.popStack;

         propagateException;
      end;
  end;
end;

{$IF DEFINED(CPUx64)}

{$IFDEF Windows}
function CallBack0(a0,a1,a2,a3:int64):int64;
var
   p0:Int64Array;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  result:=ManageCallBack(0,@p0);
end;

function CallBack1(a0,a1,a2,a3:int64):int64;
var
   p0:Int64Array;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  result:=ManageCallBack(1,@p0);
end;

function CallBack2(a0,a1,a2,a3:int64):int64;
var
   p0:Int64Array;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  result:=ManageCallBack(2,@p0);
end;

function CallBack3(a0,a1,a2,a3:int64):int64;
var
   p0:Int64Array;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  result:=ManageCallBack(3,@p0);
end;

function CallBack4(a0,a1,a2,a3:int64):int64;
var
   p0:Int64Array;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  result:=ManageCallBack(4,@p0);
end;

function CallBack5(a0,a1,a2,a3,a4:int64):int64;
var
   p0:Int64Array;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  p0[4]:=a4;
  result:=ManageCallBack(5,@p0);
end;

function CallBack6(a0,a1,a2,a3,a4,a5:int64):int64;
var
   p0:Int64Array;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  p0[4]:=a4;
  p0[5]:=a5;
  result:=ManageCallBack(6,@p0);
end;

function CallBack7(a0,a1,a2,a3,a4,a5,a6:int64):int64;
var
   p0:Int64Array;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  p0[4]:=a4;
  p0[5]:=a5;
  p0[6]:=a6;
  result:=ManageCallBack(7,@p0);
end;

function CallBack8(a0,a1,a2,a3,a4,a5,a6,a7:int64):int64;
var
   p0:Int64Array;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  p0[4]:=a4;
  p0[5]:=a5;
  p0[6]:=a6;
  p0[7]:=a7;
  result:=ManageCallBack(8,@p0);
end;

function CallBack9(a0,a1,a2,a3,a4,a5,a6,a7,a8:int64):int64;
var
   p0:Int64Array;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  p0[4]:=a4;
  p0[5]:=a5;
  p0[6]:=a6;
  p0[7]:=a7;
  p0[8]:=a8;
  result:=ManageCallBack(9,@p0);
end;

{$ELSE}  //Linux
function CallBack0(a0,a1,a2,a3,a4,a5:int64):int64;
var
   p0:Int64Array;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  p0[4]:=a4;
  p0[5]:=a5;
  result:=ManageCallBack(0,@p0);
end;

function CallBack1(a0,a1,a2,a3,a4,a5:int64):int64;
var
   p0:Int64Array;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  p0[4]:=a4;
  p0[5]:=a5;
  result:=ManageCallBack(1,@p0);
end;

function CallBack2(a0,a1,a2,a3,a4,a5:int64):int64;
var
   p0:Int64Array;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  p0[4]:=a4;
  p0[5]:=a5;
  result:=ManageCallBack(2,@p0);
end;

function CallBack3(a0,a1,a2,a3,a4,a5:int64):int64;
var
   p0:Int64Array;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  p0[4]:=a4;
  p0[5]:=a5;
  result:=ManageCallBack(3,@p0);
end;

function CallBack4(a0,a1,a2,a3,a4,a5:int64):int64;
var
   p0:Int64Array;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  p0[4]:=a4;
  p0[5]:=a5;
  result:=ManageCallBack(4,@p0);
end;

function CallBack5(a0,a1,a2,a3,a4,a5:int64):int64;
var
   p0:Int64Array;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  p0[4]:=a4;
  p0[5]:=a5;
  result:=ManageCallBack(5,@p0);
end;

function CallBack6(a0,a1,a2,a3,a4,a5:int64):int64;
var
   p0:Int64Array;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  p0[4]:=a4;
  p0[5]:=a5;
  result:=ManageCallBack(6,@p0);
end;

function CallBack7(a0,a1,a2,a3,a4,a5,a6:int64):int64;
var
   p0:Int64Array;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  p0[4]:=a4;
  p0[5]:=a5;
  p0[6]:=a6;
  result:=ManageCallBack(7,@p0);
end;

function CallBack8(a0,a1,a2,a3,a4,a5,a6,a7:int64):int64;
var
   p0:Int64Array;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  p0[4]:=a4;
  p0[5]:=a5;
  p0[6]:=a6;
  p0[7]:=a7;
  result:=ManageCallBack(8,@p0);
end;

function CallBack9(a0,a1,a2,a3,a4,a5,a6,a7,a8:int64):int64;
var
   p0:Int64Array;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  p0[4]:=a4;
  p0[5]:=a5;
  p0[6]:=a6;
  p0[7]:=a7;
  p0[8]:=a8;
  result:=ManageCallBack(9,@p0);
end;
{$ENDIF}

{$ELSEIF DEFINED(CPUAArch64)}

function CallBack0(a0,a1,a2,a3,a4,a5,a6,a7:int64):int64;
var
   p0:Int64Array;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  p0[4]:=a4;
  p0[5]:=a5;
  p0[6]:=a6;
  p0[7]:=a7;
  result:=ManageCallBack(0,@p0);
end;

function CallBack1(a0,a1,a2,a3,a4,a5,a6,a7:int64):int64;
var
   p0:Int64Array;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  p0[4]:=a4;
  p0[5]:=a5;
  p0[6]:=a6;
  p0[7]:=a7;
  result:=ManageCallBack(1,@p0);
end;

function CallBack2(a0,a1,a2,a3,a4,a5,a6,a7:int64):int64;
var
   p0:Int64Array;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  p0[4]:=a4;
  p0[5]:=a5;
  p0[6]:=a6;
  p0[7]:=a7;
  result:=ManageCallBack(2,@p0);
end;

function CallBack3(a0,a1,a2,a3,a4,a5,a6,a7:int64):int64;
var
   p0:Int64Array;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  p0[4]:=a4;
  p0[5]:=a5;
  p0[6]:=a6;
  p0[7]:=a7;
  result:=ManageCallBack(3,@p0);
end;

function CallBack4(a0,a1,a2,a3,a4,a5,a6,a7:int64):int64;
var
   p0:Int64Array;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  p0[4]:=a4;
  p0[5]:=a5;
  p0[6]:=a6;
  p0[7]:=a7;
  result:=ManageCallBack(4,@p0);
end;

function CallBack5(a0,a1,a2,a3,a4,a5,a6,a7:int64):int64;
var
   p0:Int64Array;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  p0[4]:=a4;
  p0[5]:=a5;
  p0[6]:=a6;
  p0[7]:=a7;
  result:=ManageCallBack(5,@p0);
end;

function CallBack6(a0,a1,a2,a3,a4,a5,a6,a7:int64):int64;
var
   p0:Int64Array;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  p0[4]:=a4;
  p0[5]:=a5;
  p0[6]:=a6;
  p0[7]:=a7;
  result:=ManageCallBack(6,@p0);
end;

function CallBack7(a0,a1,a2,a3,a4,a5,a6,a7:int64):int64;
var
   p0:Int64Array;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  p0[4]:=a4;
  p0[5]:=a5;
  p0[6]:=a6;
  p0[7]:=a7;
  result:=ManageCallBack(7,@p0);
end;

function CallBack8(a0,a1,a2,a3,a4,a5,a6,a7:int64):int64;
var
   p0:Int64Array;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  p0[4]:=a4;
  p0[5]:=a5;
  p0[6]:=a6;
  p0[7]:=a7;
  result:=ManageCallBack(8,@p0);
end;

function CallBack9(a0,a1,a2,a3,a4,a5,a6,a7,a8:int64):int64;
var
   p0:Int64Array;
begin
  p0[0]:=a0;
  p0[1]:=a1;
  p0[2]:=a2;
  p0[3]:=a3;
  p0[4]:=a4;
  p0[5]:=a5;
  p0[6]:=a6;
  p0[7]:=a7;
  p0[8]:=a8;
  result:=ManageCallBack(9,@p0);
end;
{$ENDIF}

{$ENDIF}

{$IF DEFINED(CPU386) or DEFINED(CPUarm) or DEFINED(CPUx64) or DEFINED(CPUAarch64)}
type
  TCallBackAdr=class(TMiscX)
       exp:TPrincipal;
       PUnit:TProgramUnit;
      constructor create;
      function evalX:extended;override;
      destructor destroy;override;
     private
      function getAddress(i:NativeInt):NativeInt;
    end;

function TCallBackAdr.getAddress(i:NativeInt):NativeInt;
begin
  {$IF DEFINED(CPU386) and DEFINED(windows)}
  if ccCdecl[i] then
        case i of
            0:  result:=NativeInt(@CallBack0C);
            1:  result:=NativeInt(@CallBack1C);
            2:  result:=NativeInt(@CallBack2C);
            3:  result:=NativeInt(@CallBack3C);
            4:  result:=NativeInt(@CallBack4C);
            5:  result:=NativeInt(@CallBack5C);
            6:  result:=NativeInt(@CallBack6C);
            7:  result:=NativeInt(@CallBack7C);
            8:  result:=NativeInt(@CallBack8C);
            9:  result:=NativeInt(@CallBack9C);
          else  result:=0;
        end
  else
  {$ENDIF}
        case i of
             0:  result:=NativeInt(@CallBack0);
             1:  result:=NativeInt(@CallBack1);
             2:  result:=NativeInt(@CallBack2);
             3:  result:=NativeInt(@CallBack3);
             4:  result:=NativeInt(@CallBack4);
             5:  result:=NativeInt(@CallBack5);
             6:  result:=NativeInt(@CallBack6);
             7:  result:=NativeInt(@CallBack7);
             8:  result:=NativeInt(@CallBack8);
             9:  result:=NativeInt(@CallBack9);
           else  result:=0;
         end;
end;

constructor TCallBackAdr.create;
begin
    inherited create;
    check('(',IDH_CALLBACK);
    exp:=NExpression ;
    check(')',IDH_CALLBACK);
    PUnit:=ProgramUnit;
end;

destructor TCallBackAdr.destroy;
begin
    inherited destroy;
end;

function TCallBackAdr.evalX:extended;
var
   i:integer;
begin
  i:=exp.evalLongint ;
  if (i>=0) and (i<=9)
            and (ProcPtr[i]<>nil)
            and ( not (ProcPtr[i] is TLocalProc)
                   or (TLocalProc(ProcPtr[i]).parent=Punit)) then
      result:=GetAddress(i)
  else
      setexception(MissingCallBack);

end;

function CallBackAdrfnc:TPrincipal;far;
begin
    CallBackAdrFnc:=NOperation(TCallBackAdr.create)
end;
{$ENDIF}

procedure InitCallBack;
var
  i:integer;
begin
   for i:=0 to 9 do
     ProcPtr[i]:=nil;
end;

procedure PrepareCallback(Proc:TRoutine);
var
   i:integer;
begin
  {$IF DEFINED(CPU386) or DEFINED(CPUx64) or DEFINED(CPUAarch64) or DEFINED(CPUArm)}
  //if (Proc.paramcount=0) then
  //        seterr('Unsuitable for CallBack',IDH_CALLBACK);
  if (length(token)=1) and (token[1]>='0') and (token[1]<='9') then
     begin
       i:=ord(token[1])-ord('0');
       if (Pass=1) and (ProcPtr[i]<>nil) then
          seterr('Duplicate index',IDH_CALLBACK);
       ProcPtr[i]:=proc;
       gettoken;
     end;
  if  test(',')
      and ((token='CDECL') {$IFDEF Windows}or (token='STDCALL'){$ENDIF} ) then
      begin
          {$IFDEF CPU386}ccCDECL[i]:=(token='CDECL');{$ENDIF}
          gettoken;
      end;

  {$ELSE}
   seterr('CallBack Not Available',IDH_CALLBACK);
  {$ENDIF}
end;


{**************}
{Windows Handle}
{**************}
{$IFDEF Windows}
type
    TWinHandle=class(TMiscX)
       exp:TPrincipal;
      constructor create;
      function evalX:extended;override;
      destructor destroy;override;
    end;

constructor TWinHandle.create;
begin
    inherited create;
    check('(',IDH_STRING_FUNCTIONS);
    exp:=SExpression;
    check(')',IDH_STRING_FUNCTIONS);
end;

destructor TWinHandle.destroy;
begin
    exp.free;
    inherited destroy;
end;

function TWinHandle.evalX:extended;
var
   s:string;
   w:TWinControl;
begin
   s:=uppercase(exp.evalS);
   if s='MAIN' then
      w:=FrameForm
   else if s='TEXT' then
      w:=TextForm
   else if s='GRAPHICS' then
      w:=PaintForm
   else if s='TRACE' then
      w:=TraceForm
   else if s='INPUT' then
      w:=InputDialog
   else if s='CHARACTER INPUT' then
      w:=CharInput
   else if (s='LOCATE') or (s='LOCATEVALUE') then
      w:=LocateForm
   else if s='LOCATECHOICE' then
      w:=LocateChoiceForm
   else if s='EDIT' then
      w:=TextForm.memo1
   else
      w:=nil;
   if w<>nil then
      result:=NativeInt(w.Handle)
   else
      result:=0
end;

function  WinHandlefnc:TPrincipal;
begin
    WinHandlefnc:=NOperation(TWinHandle.create)
end;
{$ENDIF}

{************}
{Registration}
{************}


procedure statementTableinit;
begin
  {$IF DEFINED(CPU386) or DEFINED(CPUx64) or DEFINED(CPUAarch64) or DEFINED(CPUArm)}
   StatementTableInitDeclative ('ASSIGN',ASSIGNst);
  {$ENDIF}
  {$IF DEFINED(CPU386) or DEFINED(CPUx64) or DEFINED(CPUAarch64)or DEFINED(CPUArm)}
   SuppliedFunctionTable.accept('CALLBACKADR',CallBackAdrfnc);
   InitCallBack;
  {$ENDIF}
  {$IFDEF Windows}
   SuppliedFunctionTable.accept('WINHANDLE',WinHandlefnc);
  {$ENDIF}
 end;


begin
   Struct.PrePareCallBack:=PrepareCallBack;
   tableInitProcs.accept(statementTableinit);
end.

