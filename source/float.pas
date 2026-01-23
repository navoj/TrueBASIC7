unit float;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}
(***************************************)
(* Copyright (C) 2003, SHIRAISHI Kazuo *)
(***************************************)


interface
type
    floatFunction1=procedure (var x:double);
    floatFunction2=procedure (var x,y:double);

function abs(x:extended):extended;
function int(x:extended):extended;
function floor(x:extended):integer;
function LongIntRound(x:extended):longint; overload;
function LongIntRound(x:double  ):longint; overload;
procedure  opposite(var x:extended);
procedure  add(var x,y:extended);
procedure  sbt(var x,y:extended);
procedure  mlt(var x,y:extended);
procedure  qtt(var x,y:extended);
procedure  power(var x,y:extended);
procedure  basicmod(var x,y:double);
procedure  square(var x:double);
procedure  FMAX(var x,y:double);
procedure  FMIN(var x,y:double);

procedure  FABS  (var x:double);
procedure  FCEIL (var x:double);
procedure  FFLOOR(var x:double);
procedure  FSQRT (var x:double);
procedure  FROUND(var x:double);
procedure  FEPS  (var x:double);

procedure  FSIN  (var x:double);
procedure  FCOS  (var x:double);
procedure  FTAN  (var x:double);
procedure  FCOT  (var x:double);

function fcompare(var x,y:double):integer;
function fsign(var x:double):integer;

function NPXpower(x,y:extended):extended;
function NPXpower1plus(x,y:extended):extended;

procedure invalidoperation;assembler;

implementation
 uses base;

{$ASMMODE intel}

{$IFDEF CPU32}
function Int(x:extended):extended; assembler;
asm
    FLD x
    FLDCW RoundZero
    FRNDINT
    FLDCW ControlWord
end;

function floor(x:extended):integer;
var
   i:integer;
begin
  asm
    FLD x
    FLDCW RoundNins
    FISTP i
    FLDCW ControlWord
  end;
  result:=i;
end;

procedure  FFLOOR(var x:double);assembler;
asm
    FLDCW RoundNins
    fld qword ptr [x]
    FRNDINT
    FLDCW ControlWord
    fstp qword ptr [x]
end;

procedure  FCEIL (var x:double);assembler;
asm
    FLDCW RoundPlus
    fld qword ptr [x]
    FRNDINT
    FLDCW ControlWord
    fstp qword ptr [x]
end;

procedure  BasicMod(var x,y:double);assembler;
asm
    fld qword ptr [y]
    fld qword ptr [x]
    FLD ST(0)
    FDIV ST(0),ST(2)
    FLDCW RoundNins
    FRNDINT
    FLDCW ControlWord
    FMULP ST(2),ST(0)
    FSUB  ST(0),ST(1)
   fstp qword ptr [x]
   fstp st(0)
   wait
end;
{$ELSE}

function Int(x:extended):extended;
var
   svCW:word;
begin
asm
   FNSTCW svCW
   FLDCW [RoundZero+rip]
   fld x
   frndint
   FLDCW svCW
   fstp result
end;
end;


function floor(x:extended):integer;
var
   i:integer;
   svCW:word;
begin
  asm
    FNSTCW svCW
    FLDCW [RoundNins+rip]
    FLD x
    FISTP i
    FLDCW svCW
 end;
  result:=i;
end;

function floorsub(x:extended):extended;
var
   svCW:word;
begin
  asm
    FNSTCW svCW
    FLDCW [RoundNins+rip]
    FLD x
    frndint
    FSTP result
    FLDCW svCW
 end;
end;

procedure  FFLOOR(var x:double);
begin
  x:=floorSub(x)
end;

function Ceil(x:extended):extended;
var
   svCW:word;
begin
asm
   FNSTCW svCW
   FLDCW [RoundPlus+rip]
   fld x
   frndint
   FLDCW svCW
   fstp result
end;
end;

procedure  FCEIL (var x:double);
begin
   x:=ceil(x)
end;


function  BasicModSub(x,y:double):double;
var
   svCW:word;
begin
asm
    FNSTCW svCW
    fld y
    fld x
    FLD ST(0)
    FDIV ST(0),ST(2)
    FLDCW [RoundNins+rip]
    FRNDINT
    FLDCW svCW
    FMULP ST(2),ST(0)
    FSUB  ST(0),ST(1)
   fstp result
   fstp st(0)
   wait
end;
end;

procedure  BasicMod(var x,y:double);
begin
   x:=BasicModsub(x,y)
end;
{$ENDIF}

function abs(x:extended):extended;assembler;
asm
   fld   x
   fabs
end;

function LongIntRound(x:extended):longint;
var
   i:longint;
begin
   asm
    FLD x
    FISTP i
   end;
   result:=i
end;

function LongIntRound(x:double):LongInt;
var
  v:LongInt;
begin
asm
    FLD x
    FISTP v
end;
  result:=v
end;


procedure  opposite(var x:extended);assembler;
asm
   fld tbyte ptr [x]
   FCHS
   fstp tbyte ptr [x]
end;

procedure  add(var x,y:extended);assembler;
asm
   fld tbyte ptr [x]
   fld tbyte ptr [y]
   fadd
   fstp tbyte ptr [x]
   wait
end;

procedure  sbt(var x,y:extended);assembler;
asm
   fld tbyte ptr [x]
   fld tbyte ptr [y]
   fsub
   fstp tbyte ptr [x]
   wait
end;

procedure  mlt(var x,y:extended);assembler;
asm
   fld tbyte ptr [x]
   fld tbyte ptr [y]
   fmul
   fstp tbyte ptr [x]
   wait
end;

procedure  qtt(var x,y:extended);assembler;
asm
   fld tbyte ptr [x]
   fld tbyte ptr [y]
   fdiv
   fstp tbyte ptr [x]
   wait
end;

procedure square(var x:double);assembler;
asm
   fld qword ptr [x]
   fld st
   fmul
   fstp qword ptr [x]
   wait
end;


function fsign(var x:double):integer;assembler;
asm
   fld qword ptr [x]
   ftst
   fstsw ax
   sahf
   fstp st(0)   {FPOP}
   ja  @positive
   jb  @negative
   xor eax,eax
   jmp @exit
  @positive:
   mov eax,1
   jmp @exit
  @negative:
   mov eax,-1
  @exit:
   FCLEX
end;

function fcompare(var x,y:double):integer;assembler;
asm
   fld qword ptr [y]
   fld qword ptr [x]
   fcompp
   fstsw ax
   sahf
   ja  @positive
   jb  @negative
   xor eax,eax
   jmp @exit
  @positive:
   mov eax,1
   jmp @exit
  @negative:
   mov eax,-1
  @exit:
   FCLEX
end;

procedure  FMAX(var x,y:double);assembler;
asm
    mov ecx,eax
    fld qword ptr [x]
    fld qword ptr [y]
    FCOM ST(1)
    FSTSW AX
    SAHF
    JA @End
    FXCH
@End:
    mov eax,ecx
    fstp qword ptr [x]
    fstp st(0)
end;

procedure  FMIN(var x,y:double);assembler;
asm
    mov ecx,eax
    fld qword ptr [x]
    fld qword ptr [y]
    FCOM ST(1)
    FSTSW AX
    SAHF
    JB @End
    FXCH
@End:
    mov eax,ecx
    fstp qword ptr [x]
    fstp st(0)
end;

procedure  FABS  (var x:double);assembler;
asm
    fld qword ptr [x]
    FABS
    fstp qword ptr [x]
end;


procedure  FROUND(var x:double);assembler;
asm
    fld qword ptr [x]
    FRNDINT
    fstp qword ptr [x]
end;

var
   number2:array[0..3]of word=($ffff,$ffff,$ffff,$7fef);
var
   number0:double absolute number2;

procedure  FEPS(var x:double);
var
   e:word;
begin
    number0:=x;
    e:=(number2[3] and $7ff0) div $10;
    if e>0 then
       begin
         number2[3]:=e*$10 ;
         number2[2]:=0;
         number2[1]:=0;
         number2[0]:=0;
         x:=number0/4503599627370496.
       end
    else
       begin
         number2[3]:=0;
         number2[2]:=0;
         number2[1]:=0;
         number2[0]:=1;
         x:=number0
       end;
end;


procedure  FSQRT (var x:double);assembler;
asm
    fld qword ptr [x]
    FSQRT
    fstp qword ptr [x]
end;

procedure  FSIN(var x:double) ;assembler;
asm
    fld qword ptr [x]
    FSIN
    fstp qword ptr [x]
end;

procedure  FCOS  (var x:double);assembler;
asm
    fld qword ptr [x]
    FCOS
    fstp qword ptr [x]
end;

procedure  FTAN  (var x:double);assembler;
asm
    fld qword ptr [x]
    FPTAN
    fstp st(0)
    fstp qword ptr [x]
    wait
end;

procedure  FCOT  (var x:double);assembler;
asm
    fld qword ptr [x]
    FPTAN
    fdivr
    fstp qword ptr [x]
    wait
end;

procedure FASIN (var x:double);assembler;
asm
    fld qword ptr [x]
    FLD ST(0)
    FMUL ST(0),ST(0)
    FLD1
    FSUBRP ST(1),ST(0)
    FSQRT
    FPATAN
    fstp qword ptr [x]
end;

procedure  FACOS (var x:double);assembler;
asm
    fld qword ptr [x]
    FMUL ST(0),ST(0)
    FLD1
    FSUB ST(0),ST(1)
    FSQRT
    fld qword ptr [x]
    FPATAN
    fstp qword ptr [x]
end;


function NPXpower1plus(x,y:extended):extended;assembler;
asm
   fld   y
   fld   x
   fyl2xp1
   fld   st
   frndint
   fxch
   fsub  st,st(1)
   f2xm1
   fld1
   fadd
   fscale
   fxch
   fstp st(0)  //fucomp
end;



function NPXpower(x,y:extended):extended;assembler;
asm

   fld   y
   fld   x
   fyl2x
   fld   st
   frndint
   fxch
   fsub  st,st(1)
   f2xm1
   fld1
   fadd
   fscale
   fxch
   fstp st(0) //fucomp
end;

procedure  power(var x,y:extended);
var
   t:extended;
begin
   if x>0 then
      begin
         t:=x-1;
         if abs(t)<0.125 then
            x:=NPXpower1plus(t,y)
         else
            x:=NPXPower(x,y)
      end
   else if x=0 then
      if y>0 then
         x:=0
      else if y=0 then
         x:=1
      else
         setexception(1002)
   else
      begin
         if int(y)=y then
            begin
               x:=-x;
               power(x,y);
               t:=y/2;
               if int(t)<>t then
                   x:=-x;
            end
         else
            setexception(1002)
      end;
end;


function FStr(x:extended):ansistring;
var
     s          :string[21];
     sign,sign1 :string[1];
     exrad      :string[6];
     i,e        :integer;
const places=18;
    function pureInt(x :extended):extended;
    var
       i:extended;
    begin
       i:=int(x);
       if x>=0 then
              pureInt:=i
       else
              if i=x then
                 pureint:=i
              else
                 pureint:=i-1
    end;
begin

 if x<>0 then
   begin
    e:=LongIntRound(pureint(system.ln(abs(x)) / system.ln(10)))  ;
    if (-5<=e) and (e<places) then
        begin
            if e>=-2 then str(x:1:17,s)
                     else str(x:1:16,s);

            i:=length(s);
            while s[i]='0' do dec(i);
            if s[i]='.' then dec(i);
            s:=copy(s,1,i);

            if s[1]='-' then
                begin
                   s:=copy(s,2,19);
                   sign:='-'
                end
            else
                sign:='';

            if s[1]='0' then  s:=copy(s,2,19);
            s:=sign+s
        end
    else
        begin
           if (e>=-999) and (e<=999) then
              str(x:20,s)
           else
              str(x:19,s);
           i:=pos('E',s);
           sign1:=copy(s,i+1,1);
           exrad:=copy(s,i+2,4);
           s:=copy(s,1,i-1);

            i:=length(s);
            while s[i]='0' do dec(i);
            s:=copy(s,1,i);
            i:=1;
            while s[i]=' ' do inc(i);
            s:=copy(s,i,19);

           if sign1='+' then sign1:='';

           i:=1;
           while exrad[i]='0' do inc(i);
           exrad:=copy(exrad,i,4);

           s:=s+'E'+sign1+exrad
        end;
   end
 else if (x=0) then
        s:='0';
 if s[1]<>'-' then s:=' '+s;
   FStr:=s
end;

procedure invalidoperation;assembler;
asm
         fld1
         fchs
         fsqrt   {√-1}
         fstp st(0)
end;




initialization


end.
