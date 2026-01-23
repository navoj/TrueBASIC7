unit supplieds;

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

(***************************************)
(* Copyright (C) 2003, SHIRAISHI Kazuo *)
(***************************************)


interface
uses sysUtils,LCLProc, FileUtil,
     variabl;

implementation
uses  LazUTF8,
      myutils,base,texthand,struct,express,format,helpctex,supplied;



{*************}
{str$ function}
{*************}

type
   Tstr=class(TStrExpression)
             exp:TPrincipal;
             CharacterByte:boolean;
          constructor create;
          function evalS:ansistring;override;
          destructor destroy;override;
     end;

constructor Tstr.create;
begin
   inherited create;
   exp:=argumentN1;
   {if exp=nil then fail;}
   CharacterByte:=ProgramUnit.CharacterByte;
end;

function Tstr.evalS:ansistring;
begin
  result:=trim(exp.str);
end;

destructor Tstr.destroy;
begin
   exp.free;
   inherited destroy;
end;

function strfnc:TPrincipal;
begin
   strfnc:=Tstr.create;
end;

{*************}
{CHR$ function}
{*************}
type
  TCHRfnc=Class(Tstr)
       function evalS:ansistring;override;
  end;

{$IFDEF Windows}
{$ASMMODE intel}
function JisToSJis(N:WORD):WORD; register; assembler;
asm
   {$IFDEF CPU64}
    mov  ax, N
   {$ENDIF}
    add  ax,0a17eh
    shr  ah,1
    jb  @1
    cmp  al,0deh
    sbb  al,5eh
@1: xor  ah,0e0h
end;
{$ENDIF}


function IsJIS(w:word): Boolean;
begin
  result := ($21<=hi(w))and(hi(w)<=$7E) and ($21<=lo(w))and(lo(w)<=$7E)
end;



function TCHRfnc.evalS:ansistring;
var
   i:longint;
   c:integer;
begin
   result:='';
   i:=exp.evalInteger;
   if CharacterByte then
      begin
        if (i>=0) and (i<=255) then
            result:=chr(i);
      end
   else
          result:=UnicodeToUTF8(i);

   if result='' then
           setexceptionwith('CHR',4002);
end;
(*
// Shift-JIS
function TCHRfnc.evalS:ansistring;
var
   i:longint;
   c:integer;
   w:word;
begin
   result:='';
   i:=exp.evalInteger;
   if (i>=0) then
        if i<=255 then
           begin
              result:=chr(i and 255) ;
              if IsDBCSLeadByte(i and 255) and not CharacterByte then
                setexceptionwith('CHR',4002);
           end
        else if (i<$8000) and not CharacterByte then
           begin
              result:='　';    //エラーの時の値
              w:=i;
              if IsJis(w) then
                 begin
                   w:=JisToSJis(w);
                   result:=chr(hi(w)) + chr(lo(w));
                 end
              else
                 setexceptionwith('CHR',4002);
           end
        else
           setexceptionwith('CHR',4002)
      else
           setexceptionwith('CHR',4002);
end;
*)
(*
// EUC
function TCHRfnc.evalS:ansistring;
var
   i:longint;
   c:integer;
   w:word;
begin
   result:='';
   i:=exp.evalInteger;
   if CharacterByte then
      begin
        if (i>=0) and (i<=255) then
            result:=chr(i);
      end
   else if (i>=0) and (i<=127) then
             result:=chr(i)
   else if (i>$A0) and (i<=$DF) then
             result:=chr($8E)+ chr(i)
   else if (i>=$100) and (i<$8000) then
      begin
          w:=i;
          if IsJis(w) then
             begin
                w:=w or $8080;
                result:=chr(hi(w)) + chr(lo(w));
             end;
      end;
   if result='' then
           setexceptionwith('CHR',4002);
end;
*)

function CHRfnc:TPrincipal;
begin
  CHRfnc:=TCHRfnc.create
end;

{***************}
{USING$ function}
{***************}

type
   TstrfunctionSN=class(TstrExpression)
      exp1,exp2:TPrincipal;
      CharacterByte:boolean;
      constructor  create;
      destructor    destroy;override;
   end;

   TRepeat=class(TstrfunctionSN)
      function evalS:ansistring;override;
   end;

   TUsing=class(TstrfunctionSN)
      insideofwhen:boolean;
      constructor  create;
      function evalS:ansistring;override;
   end;

constructor TstrfunctionSN.create;
begin
   inherited create;
   CharacterByte:=ProgramUnit.CharacterByte;
   check('(',IDH_STRING_FUNCTIONS);
   exp1:=SExpression;
   check(',',IDH_STRING_FUNCTIONS);
   exp2:=NExpression;
   check(')',IDH_STRING_FUNCTIONS);
end;

destructor TstrfunctionSN.destroy;
begin
    exp1.free;
    exp2.free;
   inherited destroy;
end;

constructor TUsing.create;
begin
  inherited create;
  with whenStack do insideofwhen:=items[count-1]<>nil;
end;

function TUsing.evalS:ansistring;
var
   form:ansistring;
   i,c:integer;
begin
   i:=1;
   form:=exp1.evalS;
   if (form='')  then                    // 2016.6.13
      setexceptionwith('USING$',8201);
   TestFormatItem(form);
   result:=exp2.format(form,i,c);
   //if (c=0) or not insideofwhen then
   //else
   //    setexceptionwith('USING$',c)
   if c<>0 then
        ReportException(InsideOfWhen , c, exp2.str);

end  ;

function Usingfnc:TPrincipal;
begin
  Usingfnc:=TUsing.create
end;

function TRepeat.evalS:ansistring;
var
   m:longint;
   i,l,len,ov:integer;
   t:ansistring;
begin
   result:='';
   t:=exp1.evalS;
   m:=exp2.evalInteger;
   if (m>=0) then
         begin
           l:=length(t);
           asm
              mov eax, m
              mov edx, l
              imul edx
              mov len,eax
              mov ov,edx
           end;
           if (ov<>0) or (len<0) or (len=maxint) then setexception(1051);
           try
              setlength(result,len);
              if l>0 then
                for i:=0 to m-1 do move(t[1],result[1+i*l],l) ;
           except
              setexception(OutOfMemory)
           end;
         end
      else
        setexception(4010);
end;

function Repeatfnc:TPrincipal;
begin
   Repeatfnc:=TRepeat.create
end;

{***********************}
{ Left$, Right$ function}
{***********************}
type
   TLeft=class(TstrfunctionSN)
      function evalS:ansistring;override;
   end;
   TRight=class(TstrfunctionSN)
      function evalS:ansistring;override;
   end;

function TLeft.evalS:ansistring;
var
   j:longint;
   s:ansistring;
begin
   s:=exp1.evalS;
   j:=exp2.evalInteger;
   result:=substring(s,1,j,CharacterByte);
end  ;

function TRight.evalS:ansistring;
var
   j,len:longint;
   s:ansistring;
begin
   s:=exp1.evalS;
   j:=exp2.evalInteger;
   if characterbyte then
     len:=Length(s)
   else
     len:=ByteToCharLen(s,maxint);
   result:=substring(s,len-j+1,len,CharacterByte);
end  ;


function Leftfnc:TPrincipal;
begin
   Leftfnc:=TLeft.create
end;
function Rightfnc:TPrincipal;
begin
   Rightfnc:=TRight.create
end;



{**********************}
{ SUBSTR$ function,etc.}
{**********************}
type
   TstrfunctionSNN=class(TstrExpression)
      exp1,exp2,exp3:TPrincipal;
      CharacterByte:boolean;
      constructor  create;
      destructor   destroy;override;
   end;

   TSubStr=class(TstrfunctionSNN)
      function evalS:ansistring;override;
   end;

   TMid=class(TstrfunctionSNN)
      function evalS:ansistring;override;
   end;

constructor TstrfunctionSNN.create;
begin
   inherited create;
   CharacterByte:=ProgramUnit.CharacterByte;
   check('(',IDH_STRING_FUNCTIONS);
   exp1:=SExpression;
   check(',',IDH_STRING_FUNCTIONS);
   exp2:=NExpression;
   check(',',IDH_STRING_FUNCTIONS);
   exp3:=NExpression;
   check(')',IDH_STRING_FUNCTIONS);
   {if (exp1=nil) or (exp2=nil) then begin done;fail end;}
end;

destructor TstrfunctionSNN.destroy;
begin
    exp1.free;
    exp2.free;
    exp3.free;
   inherited destroy;
end;

function TSubStr.evalS:ansistring;
var
   i,j:longint;
   s:ansistring;
begin
   s:=exp1.evalS;
   GetSubStringIndex(exp2,exp3,i,j);
   result:=substring(s,i,j,CharacterByte);
end  ;

function SubStrfnc:TPrincipal;
begin
  SubStrfnc:=TSubStr.create
end;

function TMid.evalS:ansistring;
var
   i,j:longint;
   s:ansistring;
begin
   s:=exp1.evalS;
   GetSubStringIndex(exp2,exp3,i,j);
   result:=substring(s,i,i+j-1,CharacterByte);
end  ;

function Midfnc:TPrincipal;
begin
  Midfnc:=TMid.create
end;





{********************}
{ DATE,TIME functions}
{********************}

function format2(i:integer):ansistring;
var
   s:ansistring;
begin
   system.str(i:2,s);
   if s[1]=' ' then s[1]:='0';
   format2:=s
end;


type
    TDATE=class(TStrExpression)
       function evalS:ansistring;override;
    end;

function TDATE.evalS:ansistring;
var
   y,m,d,w:word;
begin
   decodedate(date,y,m,d);
   {getdate(y,m,d,w);}
   system.str(y:4,result);
   result:=result+format2(m)+format2(d);
end;

function  DATEfnc:TPrincipal;
begin
    DATEfnc:=TDATE.create
end;


type
    TTIME=class(TStrExpression)
       function evalS:ansistring;override;
    end;

function TTIME.evalS:ansistring;
var
   h,m,sec,msec:word;
begin
   DecodeTime(Time, h, m, Sec, MSec);
   {   gettime(h,m,sec,s100);}
   result:=format2(h)+':'+format2(m)+':'+format2(sec);
end;

function  TIMEfnc:TPrincipal;
begin
    TIMEfnc:=TTIME.create
end;

{**************}
{LCASE function}
{**************}

procedure MyTrimLeft(var s:string);
var
  i:integer;
begin
  i:=0;
  while (i<length(s)) and (s[i+1]=' ') do inc(i);
  delete(s,1,i);
end;

procedure MyTrimRight(var s:string);
var
  i:integer;
begin
  i:=Length(s);
  while (i>0) and (s[i]=' ') do dec(i);
  delete(s,i+1,length(s)-i);
end;


type
   StringProcedure=procedure(var s:string);

   TLCASE=class(TStrExpression)
             exp:TPrincipal;
             f:StringProcedure;
          constructor create(f1:stringprocedure);
          function evalS:ansistring;override;
          destructor destroy;override;
     end;

constructor TLCASE.create(f1:StringProcedure);
begin
    inherited create;
    check('(',IDH_STRING_FUNCTIONS);
    exp:=SExpression;
    check(')',IDH_STRING_FUNCTIONS);
    f:=f1;
end;

function TLCASE.evalS:ansistring;
begin
   result:=exp.evalS;
   f(result);
end;

destructor TLCASE.destroy;
begin
   exp.free;
   inherited destroy;
end;

function LCASEfnc:TPrincipal;
begin
   LCASEfnc:=TLCASE.create(Lower);
end;


function UCASEfnc:TPrincipal;
begin
   UCASEfnc:=TLCASE.create(Upper);
end;

function LTRIMfnc:TPrincipal;
begin
   LTRIMfnc:=TLCASE.create(MyTrimLeft);
end;

function RTRIMfnc:TPrincipal;
begin
   RTRIMfnc:=TLCASE.create(MyTrimRight);
end;



{******}
{BSTR$ }
{******}
type
   TBSTR=class(TStrExpression)
             exp:TPrincipal;
             bin:boolean;
          constructor create;
          function evalS:ansistring;override;
          destructor destroy;override;
      end;

constructor TBSTR.create;
begin
    inherited create;
    check('(',IDH_STRING_FUNCTIONS);
    exp:=NExpression;
    check(',',IDH_STRING_FUNCTIONS);
    if token='2' then
       begin gettoken; bin:=true end
    else
       checktoken1('16',IDH_STRING_FUNCTIONS);
    check(')',IDH_STRING_FUNCTIONS);
end;

destructor TBSTR.destroy;
begin
   exp.free;
   inherited destroy;
end;

function TBSTR.evalS:ansistring;
var
   x,t:extended;
   i:integer;
begin
   x:=exp.evalX;
   if (x<0.0) {or (18446744073709551616.0<=x)} then setexceptionwith('BSTR$',4203);
   t:=system.int(x);
   if x-t<0.5 then x:=t else x:=t+1;
   if x=0 then
      result:='0'
   else
      if bin then
         begin
            result:='';
            while x>0 do
               begin
                  t:=x/2;
                  x:=system.int(t);
                  if x=t then
                      result:='0' + result
                  else
                      result:='1'+result;
               end;
         end
      else
         begin
            result:='';
            while x>0 do
               begin
                  t:=x/16;
                  x:=system.int(t);
                  i:=system.round(16*(t-x));
                  if i<10 then
                     result:=chr(ord('0')+ i) + result
                  else
                     result:=chr(ord('A')-10 + i) + result

               end;
         end
end;

function BSTRfnc:TPrincipal;
begin
   BSTRfnc:=TBSTR.create;
end;

{*******}
{EXTEXT$}
{*******}
type
     TEXTEXT=class(TStr)
       function evalS:ansistring;override;
     end;

function TEXTEXT.evalS:ansistring;
var
   i:longint;
begin
     i:=exp.evalInteger;
     if (i mod 100000 >999) then
        result:='extype '+strint(i mod 100000)
     else
        result:=''   ;
end;

function EXTEXTfnc:TPrincipal;
begin
   EXTEXTfnc:=TEXTEXT.create
end;

{$IFDEF Windows}
procedure Ansi(var s:string);
begin
   s:=UTF8ToNative(s)
end;

function ANSIStringfnc:TPrincipal;
begin
   result:=TLCASE.create(Ansi);
end;

procedure ImportAnsi(var s:string);
begin
   s:=NativeToUTF8(s)
end;

function ImportANSIfnc:TPrincipal;
begin
   result:=TLCASE.create(ImportAnsi);
end;

procedure UTF16(var s:string);
var
   ss: UnicodeString;
   i:integer;
   w:word;
begin
  ss:=UTF8ToUTF16(s);
  setlength(s,2*length(ss)+1);
  for i:=1 to length(ss) do
     begin
        w:=word(ss[i]);
        s[2*i-1]:=chr(lo(w));
        s[2*i]:=chr(hi(w));
     end;
  s[length(s)]:=chr(0);
end;

function UTF16Stringfnc:TPrincipal;
begin
   result:=TLCASE.create(UTF16);
end;
(*
procedure ImportUTF16(var s:string);
var
   ss: UnicodeString;
   i:integer;
   w:wordrec;
begin
   setlength(ss,length(s) div 2);
   for i:=1 to length(ss) do
      begin
       w.lo:=byte(s[2*i-1]);
       w.hi:=byte(s[2*i]);
       word(ss[i]):=word(w); //(w.lo+w.hi*256);
      end;
   s:=UTF16ToUTF8(ss)
end;
*)

procedure ImportUTF16(var s:string);
 begin
    s:=UTF16ToUTF8(PWideChar(s))
end;

function ImportUTF16fnc:TPrincipal;
begin
   result:=TLCASE.create(ImportUTF16);
end;
{$ENDIF}

{**********}
{initialize}
{**********}
procedure FunctionTableInit;
begin
       SuppliedFunctionTableInit('STR$',STRfnc );
       SuppliedFunctionTableInit('CHR$',CHRfnc );
       SuppliedFunctionTableInit('REPEAT$',REPEATfnc );
       SuppliedFunctionTableInit('USING$',USINGfnc );
       SuppliedFunctionTableInit('LCASE$',LCASEfnc );
       SuppliedFunctionTableInit('UCASE$',UCASEfnc );
       SuppliedFunctionTableInit('LTRIM$',LTRIMfnc );
       SuppliedFunctionTableInit('RTRIM$',RTRIMfnc );
       SuppliedFunctionTableInit('BSTR$',BSTRfnc );
       ReservedWordTableInit('DATE$',DATEfnc );
       ReservedWordTableInit('TIME$',TIMEfnc );
       SuppliedFunctionTableInit('EXTEXT$',EXTEXTfnc );
       SuppliedFunctionTableInit('SUBSTR$',SubStrfnc );
       SuppliedFunctionTableInit('MID$',Midfnc );
       SuppliedFunctionTableInit('LEFT$',Leftfnc );
       SuppliedFunctionTableInit('RIGHT$',Rightfnc );
  {$IFDEF Windows}
       SuppliedFunctionTableInit('ANSI$',AnsiStringfnc );
       SuppliedFunctionTableInit('IMPORTANSI$',ImportAnsifnc );
       SuppliedFunctionTableInit('WIDE$',UTF16Stringfnc );
       SuppliedFunctionTableInit('IMPORTWIDE$',ImportUTF16fnc );
  {$ENDIF}
end;

begin
     tableInitProcs.accept(FunctionTableInit);
end.
