unit rational;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

(***************************************)
(* Copyright (C) 2003, SHIRAISHI Kazuo *)
(***************************************)


interface
uses SysUtils,
     arithmet;

procedure InitRational;

const
  maxnumlen=maxint div 16 {in dwords};

type
  bignum = record
    len:integer;        { in dwords}
    num:array[0..maxnumlen] of Cardinal;   {the last elememt is a overflow buffer.}
  end;
  Pbignum = ^bignum;

type
   numertype=(AnInteger, AFraction);
   PNumeric = ^numeric;
   numeric = object
      function size:integer;
      function newCopy:PNumeric;
      function NewCopyOpposite:Pnumeric;
      procedure getN(Var n:number);
      procedure getF(var x:double);
      procedure getX(var x:extended);
      procedure getLongInt(var i:LongInt; var c:integer);
      function isInteger:boolean;
      function sign:shortint;
      function isZero:boolean;
     private
      sgn:shortint;
      typ:NumerType;
      filler:smallint;
      //filler:array[1..3] of byte;
      con:array[0..maxnumlen] of cardinal;
      //con1:array[0..maxnumlen] of cardinal;
      procedure resolve(var nmr,dnm:Pbignum);
      function newcopywithsign(sn:shortint):PNumeric;
    end;

procedure DisposeNumeric(var p:Pnumeric);
//function NewRational(sgn:shortint;nmr,dnm:Pbignum):PNumeric;
function newRationalLongint(a:longint):PNumeric;
function NewRationalFromNumber(const n:PNumber):PNumeric;

procedure add(a,b:PNumeric; var x:PNumeric);
procedure sbt(a,b:PNumeric; var x:PNumeric);
procedure mlt(a,b:PNumeric; var x:PNumeric);
procedure qtt(a,b:PNumeric; var x:PNumeric);
function compare(a,b:PNumeric):shortint;
procedure opposite(var r:PNumeric);
procedure oppose(var r:PNumeric);
procedure absolute(var r:PNumeric);
procedure sgn(var r:PNumeric);
procedure intpart(var r:PNumeric);
procedure fractpart(var r:PNumeric);
procedure intround(var r:PNumeric);
procedure ceil(var r:PNumeric);
procedure BasicInt(var r:PNumeric);
procedure BasicMod( a,b:PNumeric; var x:PNumeric);
procedure BasicRemainder( a,b:PNumeric; var x:PNumeric);
procedure min( a,b:PNumeric; var x:PNumeric);
procedure max( a,b:PNumeric; var x:PNumeric);
procedure IntSQR(var p:PNumeric);
procedure IntLOG2(var p:PNumeric);
procedure numer(var r:PNumeric);
procedure denom(var r:PNumeric);
procedure gcd(a,b:PNumeric; var x:PNumeric);

function strFraction(p:Pnumeric):string;

const RToNOverflow=-1012;
var
   ConstHalf,ConstOne,ConstZero,ConstTwo,ConstTen {,ConstMaxNum}:PNumeric;
var
   constPI:PNumeric;

implementation
uses
base,vstack,memman,textfrm{debug};

function strBig(x:Pbignum):string; forward;

{$ASMMODE intel}
(*
function neg(a:shortint):shortint;assembler;
asm
   mov     al,a
   neg     al
end;
*)
 function neg(a:shortint):shortint;inline;
 begin
  neg:=-a
 end;


procedure clearBuf(p:Pbignum; s:integer);
var
  i:integer;
begin
  with p^ do
     begin
       len:=s;
       if s>0 then for i:=0 to s-1 do num[i]:=0;
     end;
end;

{***********}
{ addition  }
{subtraction}
{***********}
{$IFDEF CPU32}
function CompareBigNum(a,b:PBigNum):integer;assembler;
asm
   push  edi
   push  esi

   mov   esi, eax   {a}
   mov   edi, edx   {b}
   mov   eax, [eax]
   mov   edx, [edx]
   cmp   eax, edx
   jg    @BIGGER
   jl    @SMALLER

   std
   mov   ecx, eax
   sal   eax, 2
   add   esi, eax
   add   edi, eax
   repe  cmpsd
   cld

   ja    @BIGGER
   jb    @SMALLER
   mov   eax,0
   jmp  @EXIT
 @BIGGER:
   mov  eax,  1
   jmp  @EXIT
 @SMALLER:
   mov  eax, -1

 @EXIT:
   pop  esi
   pop  edi
end;
{$ENDIF}
{$IFDEF CPU64}
function CompareBigNum(a,b:PBigNum):integer;assembler;
asm                  {rdi}{rsi}
   xchg  rdi, rsi
   xor   rax, rax
   mov   eax, [rsi]{a}
   mov   edx, [rdi]{b}
   cmp   eax, edx
   jg    @BIGGER
   jl    @SMALLER

   std
   mov   rcx, rax
   sal   rax, 2
   add   rsi, rax
   add   rdi, rax
   repe  cmpsd
   cld

   ja    @BIGGER
   jb    @SMALLER
   mov   eax,0
   jmp  @EXIT
 @BIGGER:
   mov  eax,  1
   jmp  @EXIT
 @SMALLER:
   mov  eax, -1

 @EXIT:

end;
{$ENDIF}
procedure shrink(x:PBigNum);  {  shrink length }
var i:integer;
begin
    i:=x^.len-1;
    while (i>=0) and (x^.num[i]=0) do dec(i);
    x^.len:=i+1;
end;

{$IFDEF CPU64}
procedure  AddBufsub(buf:PbigNum; a:PBigNum; dummy{1}:int64; LenA, diff:int64);assembler;
                    {rdi}       {rsi}        {rdx}          {rcx}  {r8}
asm
      //mov   rsi,a
      //mov   rdi,buf
      //mov   rdx,1
      //mov   rcx,lenA
      clc
   @L1:
      mov   eax,[rsi][rdx*4]
      adc   [rdi][rdx*4],eax
      inc   rdx
      loop  @L1

      //xor   rcx,rcx
      mov   rcx,Diff
      jrcxz  @L3
      mov   eax,0
   @L2:
      adc   [rdi][rdx*4],eax
      inc   rdx
      loop  @L2
   @L3:
end;
{$ENDIF}
procedure  AddBuf(buf:PbigNum; a:PBigNum);pascal;
           {buf:=buf+a}
           {max buffer length is assumed  maxnumlen+1.}
var
   lenA,Diff:integer;
begin
   lenA:=a^.len;
   if lenA=0 then exit;

   Diff:=Buf^.len - LenA + 1;
   if Diff<=0 then Diff:=1;

   with buf^ do
    begin
        while len < LenA do
          begin
            num[len]:=0;
            inc(len);
          end;
        num[len]:=0;
        inc(len);
    end;
 {$IFDEF CPU32}
   asm
      push  ebx
      push  edi
      push  esi

      mov   esi,a
      mov   edi,buf
      mov   edx,1
      mov   ecx,lenA
      clc
   @L1:
      mov   eax,[esi][edx*4]
      adc   [edi][edx*4],eax
      inc   edx
      loop  @L1

      mov   ecx,Diff
      jecxz  @L3
      mov   eax,0
   @L2:
      adc   [edi][edx*4],eax
      inc   edx
      loop  @L2
   @L3:
      pop   esi
      pop   edi
      pop   ebx
   end{asm};
 {$ENDIF}
 {$IFDEF CPU64}
   AddBufSub(buf,a,1,LenA,Diff);
 {$ENDIF}
   shrink(buf);
end;

{$IFDEF CPU32}
procedure  sbtBuf(buf:PBigNum; s:PBigNum);assembler;
                // buf >= s > 0 のときに用いる
asm
      push edi
      push esi
      push ebx

      mov  esi, edx     {s}
      mov  edi, eax     {buf}

      mov  ecx,[esi]    {s^.len}
      mov  ebx,[edi]    {buf^.len}
      sub  ebx, ecx     {buf^.len - s^.len}
      mov  edx, 1
      clc
    @L1:
      mov  eax, [esi][edx*4]
      sbb  [edi][edx*4],eax
      inc  edx
      loop @L1

      mov  ecx, ebx
      jecxz @L3
    @L2:
      sbb  dword ptr [edi][edx*4],0
      inc  edx
      loop @L2
    @L3:

      pop   ebx
      pop   esi
      pop   edi
end;
{$ENDIF}
{$IFDEF CPU64}
procedure  sbtBuf(buf:PBigNum; s:PBigNum);assembler;// buf >= s > 0 のときに用いる
asm              {rdi}        {rsi}
      push rbx

      xor  rcx,rcx
      mov  ecx,[rsi]    {s^.len}
      mov  ebx,[rdi]    {buf^.len}
      sub  ebx, ecx     {buf^.len - s^.len}
      mov  rdx, 1
      clc
    @L1:
      mov  eax, [rsi][rdx*4]
      sbb  [rdi][rdx*4],eax
      inc  rdx
      loop @L1

      xor  rcx, rcx
      mov  ecx, ebx
      jrcxz @L3
    @L2:
      sbb  dword ptr [rdi][rdx*4],0
      inc  rdx
      loop @L2
    @L3:

      pop   rbx
end;
{$ENDIF}


{*************}
{Multipliction}
{*************}
{$IFDEF CPU32}
procedure MultiSub(a,b:cardinal; var i:cardinal);assembler;
asm               {eax}{edx}        {ecx}
   mul edx
   add [ecx],eax
   adc [ecx + 4],edx
   jnc @L1
   adc dword ptr [ecx + 8], 0
  @L1:
end;
{$ENDIF}
{$IFDEF CPU64}
procedure MultiSub(a,b:cardinal; var i:cardinal);assembler;
asm               {edi}{esi}     {rdx}
   mov eax,edi     //eax <- a
   mov rdi,rdx     //rdi <- i
   mov edx,esi     //edx <- b
   mul edx
   add [rdi],eax
   adc [rdi + 4],edx
   jnc @L1
   adc dword ptr [rdi + 8], 0
  @L1:
end;
{$ENDIF}

procedure Multiply( x:PBigNum; a,b:PBigNUm);
var
  lenA,lenB,i,k:integer;
begin
  lenA:=a^.len;
  lenB:=b^.len;
  clearBuf(x,lenA+lenB);
  for k:=0 to LenA+LenB-2 do
   for i:=base.max(0,k-lenB+1) to base.min(lenA-1,k) do
      MultiSub( a^.num[i], b^.num[k-i], x^.num[k]);
  shrink(x);
end;


{********}
{Division}
{********}

procedure setword(p:Pbignum; n:cardinal);
begin
    if n=0 then
             p^.len:=0
    else begin
             p^.len:=1;
             p^.num[0]:=n;
         end
end;

procedure paste( a:PBignum; x:PBignum);
begin
   {x:=a} { the domain of x must be obtained previously,larger than that of a.}
   move(a^,x^,((a^.len)+1)*sizeOf(Cardinal));
end;

{$IFDEF CPU64}
procedure MulWordSub(x:PBigNum; a:PBigNum; n:Cardinal; LenA:int64);assembler;
asm                  {RDI}      {RSI}      {edx}       {rcx}
    push  rbx

    mov  r8d,edx       {n -> r8d}
    mov  r9, rdi       {x.len -> r9}
    cld
    //mov rdi,x
    //mov rsi,a
    movsd              { x^.len:=a^.len }
    xor  rbx,rbx
    //mov  rcx,lenA
 @loop1:
    lodsd
    pushfq
    mul  r8d  {n}
    popfq
    adc  eax,ebx
    stosd
    mov  ebx,edx
    loop @loop1

    mov   eax,0
    adc   eax,ebx
    stosd
    or    eax,eax
    jz    @L1
    //mov   rdi,x
    inc   dword ptr [r9]     { inc(x^.len)}

 @L1:
    pop   rbx
 end ;
{$ENDIF}

procedure  MulWord(x:PBigNum; a:PBigNum; n:cardinal );{$IFDEF CPU32}pascal;{$ENDIF}
     {x:=a*n}           { x must be sufficiently large. }
var
   LenA:integer;
begin
   lenA:=a^.len;
   if (lenA=0) or (n=0) then
       SetWord(x,0)
   else if n=1 then
        paste(a,x)
   else
     begin
       {$IFDEF CPU64}
        Mulwordsub(x,a,n,LenA);
       {$ENDIF}
       {$IFDEF CPU32}
        asm
           push ebx
           push edi
           push esi

           cld
           mov esi,a
           mov edi,x
           movsd              { x^.len:=a^.len }
           xor  ebx,ebx
           mov  ecx,lenA
        @loop1:
           lodsd
           pushfd
           mul  n
           popfd
           adc  eax,ebx
           stosd
           mov  ebx,edx
           loop @loop1

           mov   eax,0
           adc   eax,ebx
           stosd
           or    eax,eax
           jz    @L1
           mov   edi,x
           inc   dword ptr [edi]     { inc(x^.len)}

        @L1:
           pop   esi
           pop   edi
           pop   ebx
        end{asm} ;
       {$ENDIF}
       //idle;
     end;
end;

{********}
{division}
{********}
{$IFDEF CPU32}
procedure divideShort(q,r:PBignum; a:PBignum; b:cardinal);pascal;
                                      // a^.len>0 と仮定
//var
//  i:integer;
begin
  asm
     push ebx
     push edi
     push esi

     mov  edi,q
     mov  esi,a
     mov  eax,[esi]
     mov  [edi],eax           {q^.len:=a^.len}
     mov  ebx,b
     mov  ecx,[esi]           {ecx <-- a^.len}
     mov  edx,0

   @L2:
     jecxz  @L3
     mov   eax,[esi][ecx*4]
     div   ebx
     mov   [edi][ecx*4],eax
     loop  @L2
   @L3:
     mov   edi, r
     mov   dword ptr [edi],1
     add   edi,4
     mov   [edi],edx

     pop  esi
     pop  edi
     pop  ebx
  end;
  shrink(q);
  if r.num[0]=0 then r.len:=0;
  //idle;
end;
{$ENDIF}

{$IFDEF CPU64}
procedure DivideShortSub(q,a:PBignum; r:PBignum; b:cardinal);assembler;
                      {rdi}{rsi}      {rdx]     {ecx}
asm
      push rbx

      mov  r8, rdx{r}
      mov  ebx,ecx{b}
      //mov  rdi,q
      //mov  rsi,a
      mov  eax,[rsi]
      mov  [rdi],eax           {q^.len:=a^.len}
      xor  rcx,rcx
      mov  ecx,[rsi]           {ecx <-- a^.len}
      mov  edx,0

    @L2:
      jrcxz  @L3
      mov   eax,[rsi][rcx*4]
      div   ebx
      mov   [rdi][rcx*4],eax
      loop  @L2
    @L3:
      mov   rdi, r8{r}
      mov   dword ptr [rdi],1
      add   rdi,4
      mov   [rdi],edx

      pop  rbx
end;

procedure divideShort(q,r:PBignum; a:PBignum; b:cardinal);
                                      // a^.len>0 と仮定
//var
//  i:integer;
begin
  DivideShortSub(q,a,r,b);
  shrink(q);
  if r.num[0]=0 then r.len:=0;
  //idle;
end;
{$ENDIF}

{$IFDEF CPU64}
procedure CanShiftSbtSub(s,buf:PBigNum; lenBuf, lenS:int64; var ae:wordbool);assembler;
                       {rdi}{rsi}      {rdx}   {rcx}           {r8}
 asm
     std
     mov     rax,rdx{lenBuf}
     shl     rax,2
     //mov     rsi,buf
     add     rsi,rax
     mov     rax,rcx{lenS}
     shl     rax,2
     //mov     rdi,s
     add     rdi,rax
     //mov     rcx,lenS   {lenS>0}
     repe    cmpsd
     jae     @L2       {buf>=s}
     mov    word ptr [r8],0  {buf<s}
 @L2:
     cld
 end;
function Canshiftsbt(buf:PBigNum; s:PBigNum; shift:integer):boolean;
var
   lenBuf,lenS,diff:integer;   {length in words}
   ae: wordbool;
begin
   Canshiftsbt:=true;

   lenS:=s^.len;
   if lenS=0 then exit;
   lenBuf:=buf^.len;
   diff:=lenBuf-(lenS+shift);
   if diff<0 then
                    begin
                        Canshiftsbt:=false;
                        exit;
                    end;
   if diff=0 then  { lenS>0}
       begin
          ae:=true;
          CanShiftSbtSub(s,buf,lenBuf,lenS, ae);
          if ae=false then  begin
                           Canshiftsbt:=false;
                           exit
                      end;
       end{diff=0};
end;
{$ENDIF}
{$IFDEF CPU32}
function Canshiftsbt(buf:PBigNum; s:PBigNum; shift:integer):boolean;pascal;
var
   lenBuf,lenS,diff:integer;   {length in words}
   ae: boolean;
begin
   Canshiftsbt:=true;

   lenS:=s^.len;
   if lenS=0 then exit;
   lenBuf:=buf^.len;
   diff:=lenBuf-(lenS+shift);
   if diff<0 then
                    begin
                        Canshiftsbt:=false;
                        exit;
                    end;
   if diff=0 then  { lenS>0}
       begin
          ae:=true;
          asm
              push    edi
              push    esi
              std
              mov     eax,lenBuf
              shl     eax,2
              mov     esi,buf
              add     esi,eax
              mov     eax,lenS
              shl     eax,2
              mov     edi,s
              add     edi,eax
              mov     ecx,lenS   {lenS>0}
              repe    cmpsd
              jae     @L2       {buf>=s}
              mov     ae,false  {buf<s}
          @L2:
              pop     esi
              pop     edi
              cld
          end;
          if ae=false then  begin
                           Canshiftsbt:=false;
                           exit
                      end;
       end{diff=0};
end;
{$ENDIF}

{$IFDEF CPU64}
procedure ShiftSbtSub(buf:PBigNum; s:PBigNum; shift:integer);assembler;
                     {rdi}       {rsi}       {edx}
 asm
    push  rbx
    //mov  rsi, s
    //mov  rdi, buf
    //mov  rdx,shift
    xor  rbx,rbx
    xor  rcx,rcx
    mov  ecx,[rsi]      {s^.len}
    mov  ebx,[rdi]      {Buf^.len}
    sub  ebx,ecx       {Buf^.len - s^.len}
    sub  ebx,edx       {ebx <-- buf^.len-(s^.len + shift)}

    xor  rax,rax
    mov  eax,edx  {shift}
    shl  rax,2
    add  rdi,rax

    mov  rdx,1
    clc
   @L1:
    mov  eax, [rsi][rdx*4]
    sbb  [rdi][rdx*4],eax
    inc  rdx
    loop @L1

    mov  rcx, rbx
    jrcxz @L3
  @L2:
    sbb  dword ptr [rdi][rdx*4],0
    inc  rdx
    loop @L2
  @L3:

    pop  rbx
 end{asm}   ;
{$ENDIF}


procedure  shiftsbt(buf:PBigNum; s:PBigNum; shift:integer);{$IFDEF CPU32}pascal;{$ENDIF}
   {subtract s*(2^32)^shift from buf}
      {only for case of lenBuf>=lenS+shift & buf>=s*(2^32)^shift}
           {buf:=buf-a*(2^32)^shift}
begin
   if s^.len = 0 then exit;
   {$IFDEF CPU32}
   asm
      push edi
      push esi
      push ebx

      mov  esi, s
      mov  edi, buf
      mov  edx,shift
      shl  edx,2
      add  edi,edx

      mov  ecx, s
      mov  ecx,[ecx]       {s^.len}
      mov  ebx, buf
      mov  ebx,[ebx]       {Buf^.len}
      sub  ebx,ecx
      sub  ebx,shift       {ebx <-- buf^.len-(s^.len + shift)}
      mov  edx,1
      clc
    @L1:
      mov  eax, [esi][edx*4]
      sbb  [edi][edx*4],eax
      inc  edx
      loop @L1

      mov  ecx, ebx
      jecxz @L3
    @L2:
      sbb  dword ptr [edi][edx*4],0
      inc  edx
      loop @L2
    @L3:

      pop   ebx
      pop   esi
      pop   edi
   end{asm}   ;
  {$ENDIF}
  {$IFDEF CPU64}
   ShiftSbtSub(buf, s, shift);
  {$ENDIF}
end;


{$IFDEF CPU32}
procedure DivideLong(q,r:PBigNum; a,b:PBigNum );pascal;
var
   tmpq: cardinal; {temporary quotient}
   lenA,lenB,shift:integer;
   p:integer;
   head :cardinal;
   bias:integer;   { bit shift counter}
   s:PBigNum;
   MemSize:integer;
begin
    lenA:=a^.len;
    lenB:=b^.len;

    { heading of b,for security against abnormal data.}
    while b^.num[lenB-1]=0 do dec(lenB);

    shift:=lenA-LenB ;
    if shift>=0 then clearBuf(q,shift+1) else clearBuf(q,0);
    paste(a,r);
    r^.num[lenA]:=0;

    MemSize:=(lenB+2)*SizeOf(Cardinal);
    s:=GetMemory(memSize);
    case lenB of
    1: begin
            bias:=0;
            head:=b^.num[0];
       end;
    else
       begin
           {get head of divisor} {asuume lenB>=2}
            asm
               push ebx
               push edi
               push esi

               mov  edi,b
               mov  eax,lenB
               shl  eax,2
               add  edi,eax
               mov  eax,[edi]
               mov  ebx,[edi-4]
               xor  ecx,ecx
            @loop1:
               or   eax,eax
               js   @endloop1
               shl  ebx,1
               rcl  eax,1
               inc  ecx
               jmp  @loop1
            @endloop1:
               mov  head,eax
               mov  bias,ecx

               pop  esi
               pop  edi
               pop  ebx

            end{asm}{get Head of divisor};

       end;
    end;

    while (shift>=0) do
    begin
        { get head of divident}
         p:=lenB+shift;
         asm
              push  ebx
              push  edi
              push  esi

              mov   edi,r
              mov   eax,p
              shl   eax,2
              add   edi,eax
              mov   edx,[edi+4]
              mov   eax,[edi]
              mov   ebx,[edi-4]
              mov   ecx,bias
              jecxz  @endloop2
           @loop2:
              shl   ebx,1
              rcl   eax,1
              rcl   edx,1
              loop  @loop2
           @endloop2:
         { get temporary quotient}
              cmp   edx,head
              jae   @L1
              div   head
              mov   tmpq,eax
              jmp   @L2
           @L1:
              mov   tmpq,$FFFFFFFF
           @L2:

              pop  esi
              pop  edi
              pop  ebx

         end{asm};
         MulWord(s,b,tmpq);
         shrink(r);
         while not canshiftsbt(r,s,shift) do
         begin
             dec(tmpq);
             shiftsbt(s,b,0);
         end;
         shiftsbt(r,s,shift);
         q^.num[shift]:=tmpq;
         dec(shift);
    end;
    FreeMemory(memsize);
    shrink(q);
    shrink(r);
end;
{$ENDIF}

{$IFDEF CPU64}
Procedure DivideLongSub1(b:PBignum; var head:Cardinal; var bias:int64; LenB:Int64);assembler;
                        {rdi}          {rsi}               {rdx}         {rcx}
asm
    push rbx

    //mov  rdi,b
    xor  rax,rax
    mov  eax,ecx{lenB}
    shl  rax,2
    add  rdi,rax
    mov  eax,[rdi]
    mov  ebx,[rdi-4]
    xor  rcx,rcx
 @loop1:
    or   eax,eax
    js   @endloop1
    shl  ebx,1
    rcl  eax,1
    inc  rcx
    jmp  @loop1
 @endloop1:
    mov  [rsi]{head},eax
    mov  [rdx]{bias},rcx

    pop  rbx
 end{asm}{get Head of divisor};

 Procedure DivideLongSub2(r:PBigNum; var tmpq:Cardinal; p:Int64; bias:int64; head:Cardinal);assembler;
                        {rdi}           {rsi}          {rdx}     {rcx}       {r8d}
    asm
         push  rbx

         //mov   rdi,r
         //mov   rdx,p
         shl   rdx,2
         add   rdi,rdx
         mov   edx,[rdi+4]
         mov   eax,[rdi]
         mov   ebx,[rdi-4]
         //mov   rcx,bias
         jrcxz  @endloop2
      @loop2:
         shl   ebx,1
         rcl   eax,1
         rcl   edx,1
         loop  @loop2
      @endloop2:
    { get temporary quotient}
         cmp   edx,r8d{head}
         jae   @L1
         div   r8d  {head}
         mov   [rsi]{tmpq},eax
         jmp   @L2
      @L1:
         mov   dword ptr [rsi]{tmpq},$FFFFFFFF
      @L2:

         pop  rbx
     end{asm};



procedure DivideLong(q,r:PBigNum; a,b:PBigNum );
var
   tmpq: cardinal; {temporary quotient}
   lenA,lenB,shift:integer;
   head :cardinal;
   bias:int64;   { bit shift counter}
   p:int64;
   s:PBigNum;
   MemSize:integer;
begin
    lenA:=a^.len;
    lenB:=b^.len;

    { heading of b,for security against abnormal data.}
    while b^.num[lenB-1]=0 do dec(lenB);

    shift:=lenA-LenB ;
    if shift>=0 then clearBuf(q,shift+1) else clearBuf(q,0);
    paste(a,r);
    r^.num[lenA]:=0;

    MemSize:=(lenB+2)*SizeOf(Cardinal);
    s:=GetMemory(memSize);
    case lenB of
    1: begin
            bias:=0;
            head:=b^.num[0];
       end;
    else
       begin
           {get head of divisor} {asuume lenB>=2}
           DivideLongSub1(b, head, bias , LenB);
       end;
    end;

    while (shift>=0) do
    begin
        { get head of divident}
         p:=lenB+shift;
         DivideLongSub2(r, tmpq, p, bias, head);
         MulWord(s,b,tmpq);
         shrink(r);
         while not canshiftsbt(r,s,shift) do
         begin
             dec(tmpq);
             shiftsbt(s,b,0);
         end;
         shiftsbt(r,s,shift);
         q^.num[shift]:=tmpq;
         dec(shift);
    end;
    FreeMemory(memsize);
    shrink(q);
    shrink(r);

end;
{$ENDIF}


procedure Divide(q,r:PBigNum; a,b:PBigNum );
begin
  case b^.len of
    0: SetException(3001);
    1: if (b.num[0]=1) then
          begin
            paste(a,q);
            r^.len:=0;
          end
       else
         DivideShort(q,r,a,b.num[0]);
    else DivideLong(q,r,a,b);
  end;
end;

procedure abbreviate(nmr,dnm:PBignum);

var
   a,b,q,r:PBigNum;
   t:PBigNum;
   MemSize:integer;
   len0:integer;
begin
   if dnm=nil then exit;
   if nmr^.len=0 then setword(dnm,1)
   else
     begin
       len0:=base.max(nmr^.len, dnm^.len)+1;
       MemSize:=(len0 *4 +5)*sizeof(cardinal);
       a:=GetMemory(MemSize);
       b:=@a.num[len0];
       q:=@b.num[len0];
       r:=@q.num[len0];
       paste(nmr,a);
       paste(dnm,b);
       divide(q,r,a,b);
       while r^.len>0 do
          begin
              t:=r;
              r:=a;
              a:=b;
              b:=t;
              divide(q,r,a,b);
          end;
        // b<==GCD(nmr,dnm)
        divide(q,r,nmr,b); paste(q,nmr);
        divide(q,r,dnm,b); paste(q,dnm);
        FreeMemory(MemSize);
     end
end;

{****}
{ISQR}
{****}
{$IFDEF CPU32}
procedure shiftLeft(var x:bignum);assembler; //x:=x*2
asm                    {eax}
     mov edx,eax    //退避
     mov ecx,[eax]
     jecxz    @L2
     clc
   @L1:
     inc eax
     inc eax
     inc eax
     inc eax
     rcl dword ptr [eax],1
     loop  @L1
   @L2:
     jnc   @L3
     inc eax
     inc eax
     inc eax
     inc eax
     mov dword ptr [eax],1
     inc dword ptr [edx]
   @L3:
end;
{$ENDIF}
{$IFDEF CPU64}
procedure shiftLeft(var x:bignum);assembler; //x:=x*2
asm                   {rdi}
     mov rsi,rdi    //退避
     xor rcx,rcx
     mov ecx,[rdi]
     jrcxz    @L2
     clc
   @L1:
     inc rdi
     inc rdi
     inc rdi
     inc rdi
     rcl dword ptr [rdi],1
     loop  @L1
   @L2:
     jnc   @L3
     inc rdi
     inc rdi
     inc rdi
     inc rdi
     mov dword ptr [rdi],1
     inc dword ptr [rsi]
   @L3:
end;
{$ENDIF}

{$IFDEF CPU32}
procedure shiftRightsub(var x:bignum);assembler;
asm                       {eax}
     mov ecx,[eax]
     jecxz    @L2
     add eax,ecx
     add eax,ecx
     add eax,ecx
     add eax,ecx
     clc
   @L1:
     rcr dword ptr [eax],1
     dec eax
     dec eax
     dec eax
     dec eax
     loop  @L1
   @L2:
end;
{$ENDIF}
{$IFDEF CPU64}
procedure shiftRightsub(var x:bignum);assembler;
asm                   {rdi}
     xor rcx,rcx
     mov ecx,[rdi]
     jrcxz    @L2
     add rdi,rcx
     add rdi,rcx
     add rdi,rcx
     add rdi,rcx
     clc
   @L1:
     rcr dword ptr [rdi],1
     dec rdi
     dec rdi
     dec rdi
     dec rdi
     loop  @L1
   @L2:
end;
{$ENDIF}

procedure shiftRight(var x:bignum);    //x:=x/2
begin
  shiftRightSub(x);
  shrink(@x)
end;

procedure ISQR(var x:bignum);
var
   s,ss,t,r:PBigNum;
   MemSize:integer;
begin
   if x.len=0 then exit;

   MemSize:=(x.len *4 +9)*sizeOf(Cardinal);
   s:=GetMemory(MemSize);
   ss:=@s.num[x.len+1];
   t:=@ss.num[x.len+1];
   r:=@t.num[x.len+1];
   setword(s,1);
   paste (@x,t);
   while not CanShiftSbt(s,t,0) do
     begin
        shiftLeft(s^);
        shiftRight(t^);
     end;
   repeat
     paste(s,t);
     divide(ss,r,@x,s);
     AddBuf(ss,s);
     shiftright(ss^);
     paste(ss,s);
   until canShiftSbt(s,t,0);
   paste(t,@x);
   FreeMemory(MemSize);
end;

{*******************}
{Convert to extended}
{*******************}

function ConvLong(p:pointer; var e:integer):extended;assembler;
asm
     FILD dword ptr [e]
     FILD qword ptr [p]
     FSCALE
     FXCH
     FSTP st(0)
end;

function ConvShort( p:pointer; var e:integer):extended;assembler;
asm
     FILD dword ptr [e]
     FILD dword ptr [p]
     FSCALE
     FXCH
     FSTP st(0)
end;

function ExtendedV(n:PBignum):extended;
var
  e,e1:integer;
  i:integer;
  a:array[0..1] of cardinal;
  b:array[0..1] of cardinal;
begin

  i:=n^.len;
  if i=0 then
     result:=0
  else
     begin
        e:=(i-2)*32;
        a[1]:=n^.num[i-1];
        if i>=2 then
           a[0]:=n^.num[i-2]
        else
           a[0]:=0;
        b[1]:=0;
        if i>=3 then
           b[0]:=n^.num[i-3]
        else
           b[0]:=0;
        if LongInt(a[1])<0 then
           begin
               asm
                  clc
                  rcr dword ptr a+4,1
                  rcr dword ptr a,1
                  rcr dword ptr b,1
               end;
               inc(e);
           end;
        e1:=e-32;
        result:=convlong(@a,e)+convlong(@b,e1);
     end;
end;

{****************}
{ Number of bits }
{****************}
function ILOG2(n:PBigNum):longint;
var
   i,j:longint;
   x:Cardinal;
begin
 with n^ do
   begin
     i:=(len - 1) * 8 * sizeof(Cardinal);
     x:=num[len-1];
   end;
 j:=8 * sizeof(Cardinal) - 1;
 while (j>0) and (longint(x)>0) do
    begin
       x:=x shl 1;
       dec(j)
    end;
  result:=i+j;
end;



{********************}
{ numerical variables}
{********************}

function Numeric.size:integer;
begin
   if @self=nil then
     result:=0
   else if typ=AnInteger then
     result:=(con[0]+2)*sizeof(cardinal)
   else
     result:=(con[0]+con[con[0]+1] +3 )*sizeof(cardinal);
end;

procedure DisposeNumeric(var p:Pnumeric);
begin
   if p<>nil then
     begin
       MemoryFree(pointer(p),p^.size);
       p:=nil
     end
end;

function NewRationalAnInteger(sgn:shortint; nmr:Pbignum):PNumeric;
begin
  if nmr^.len=0 then
     result:=nil
  else
     begin
       MemoryGet(pointer(result),(nmr^.len + 2)*SizeOf(cardinal));
       result^.sgn:=sgn;
       result^.typ:=AnInteger;
       paste(nmr,@result^.con[0]);
     end
end;

function NewRationalDirect(sgn:shortint; nmr,dnm:Pbignum):PNumeric;
                //nmr^とdnm^は既約でなければならない。
begin
  if nmr^.len=0 then
     result:=nil
  else if (dnm=nil) or ((dnm^.len=1) and (dnm^.num[0]=1)) then
     result:=NewRationalAnInteger(sgn,nmr)
  else
      begin
       MemoryGet(pointer(result),(nmr^.len + dnm^.len + 3)*SizeOf(cardinal));
       result^.sgn:=sgn;
       result^.typ:=AFraction;
       paste(nmr,@result^.con[0]);
       paste(dnm,@result^.con[nmr^.len + 1]);
      end;
end;

function NewRational(sgn:shortint;nmr,dnm:Pbignum):PNumeric;
var
    x,y:PBigNum;
    MemSize:integer;
begin
    MemSize:=(nmr^.len + dnm^.len +2)*sizeOf(cardinal);
    x:=GetMemory(MemSize);
    y:=@x^.num[nmr^.len];
    paste(nmr,x);
    paste(dnm,y);
    abbreviate(x,y);
    newrational:=NewRationalDirect(sgn,x,y);
    FreeMemory(MemSize);
end;

type
   ShortBigNum = record
                       len:integer;
                       num:cardinal;
                 end;

function newRationalLongint(a:longint):PNumeric;
var
   x:ShortBigNum;
begin
   if a=0 then
      result:=nil
   else if a>0 then
      begin
         x.len:=1; x.num:=a;
         result:=NewRationalAnInteger(1,PBigNum(@x))
      end
   else
      begin
         x.len:=1; x.num:=-a;
         result:=NewRationalAnInteger(-1,PBigNum(@x))
      end;
end;


function Numeric.newcopywithsign(sn:shortint):PNumeric;
var
   bytes:integer;
begin
 if @self=nil then
    result:=nil
 else
   begin
    bytes:=size;
    MemoryGet(pointer(result),bytes);
    move(self,result^,bytes);
    result^.sgn:=sn ;
   end;
end;

function  Numeric.newCopy:PNumeric;
var
   bytes:integer;
begin
 if @self=nil then
    result:=nil
 else
   begin
    bytes:=size;
    MemoryGet(pointer(result),bytes);
    move(self,result^,bytes);
   end;
end;

function Numeric.NewCopyOpposite:Pnumeric;
begin
    NewCopyOpposite:=newcopywithsign(-sign)
end;

const NumberBase:ShortBigNum=(len:1; num:1000000000);
const ConstBigNum1: ShortBigNum = (len:1; num:1);

procedure BigNumToNumber(p:PBigNum; var n:number);
var
  x,q,r:PBigNum;
  i:integer;
  MemSize:integer;
begin
  if p^.len=0 then exit;

  MemSize:=(p^.len *3 +5  )*sizeof(cardinal);
  r:=GetMemory(MemSize);
  q:=@r.num[p^.len +1];
  x:=@q.num[p^.len +1];

    paste(p,x);
    repeat
      for i:=n.places downto 1  do
          n.Frac[i+1]:=n.frac[i];
      inc(n.expn);
      if n.expn>maxexpn then setexception(RtoNOverFlow);
      if n.places<HighPrecision then inc(n.places);
      divide(q,r,x,PBigNum(@NumberBase));
      if r^.len=0 then
         n.frac[1]:=0
      else
         n.frac[1]:=r^.num[0];
      paste(q,x);
    until x^.len=0;
    freememory(Memsize)
end;

procedure Numeric.resolve(var nmr,dnm:Pbignum);
          //@self<>nilを仮定する
begin
    nmr:=@con[0];
    if typ=AnInteger then
       dnm:=nil
    else
       dnm:=@con[con[0] + 1];
end;

procedure Numeric.GetN(var n:number);
var
  x,q,r:PBigNum;
  nmr,dnm:PBigNum;
  MemSize:integer;
begin

  n.initzero;
  if @self=nil then exit;

  resolve(nmr,dnm);
  if nmr^.len=0 then exit;
  if dnm=nil then
    begin
       BigNumToNumber(nmr,n);
       n.sign:=sgn;
    end
  else
    begin
      MemSize:=(dnm^.len + base.max(nmr^.len , dnm^.len +1)*2 + 6)*sizeOf(cardinal);
      x:=GetMemory(MemSize);
      r:=@x^.num[dnm^.len +1];
      q:=@r^.num[base.max(nmr^.len , dnm^.len +1) +1];
       divide(q,r,nmr,dnm);
       n.sign:=sgn;
       BigNumToNumber(q,n);

       while (r^.len>0)and (n.places<HighPrecision) and (n.expn>=MinExpn) do
       begin
          mulword(x,r,1000000000);
          divide(q,r,x,dnm);
          if q^.len=0 then
             if n.places=0 then
                dec(n.expn)
             else
               with n do
               begin
                   inc(places);
                   frac[places]:=0;
               end
          else
             with n do
             begin
                inc(places);
                frac[places]:=q^.num[0];
             end;
       end;
       FreeMemory(MemSize);
    end;
  checkRange(n);
end;


procedure Numeric.getF(var x:double);
var
  y:extended;
begin
  getX(y);
  x:=y
end;


procedure Numeric.getX(var x:extended);
var
   nmr,dnm:PBigNum;
begin
   if @self=nil then
      x:=0.
   else
      begin
        resolve(nmr,dnm);
        if dnm=nil then
           x:=extendedv(nmr)
        else
           x:=extendedv(nmr)/extendedv(dnm);
        if sgn<0 then
           x:=-x;
      end;
end;

procedure Numeric.getLongInt(var i:longint; var c:integer);
var
   r:PNumeric;
begin
  i:=0;c:=0;
  if @self=nil then exit;

  if isinteger then
       begin
         if (con[0]=1) and (LongInt(con[1])>=0) then
         begin
            i:=con[1];
            if sgn<0 then i:=-i;
         end
         else
         c:=sgn;
       end
      else
       begin
         r:=newcopy;
         intround(r);
         r^.getLongInt(i,c);
         disposeNumeric(r);
       end;
end;

function Numeric.isInteger:boolean;
begin
  if @self=nil then
    result:=true
  else
    result:=(typ=AnInteger)
end;

function Numeric.sign:shortint;
begin
   if @self=nil then
      result:=0
   else
      result:=sgn
end;

function addabs(p,q:PNumeric; sgn:shortint):PNumeric;
var
   a,b,c,d:PBigNum;
   x,y:PBigNum;
   MemSize,adbc:integer;
begin
   p^.resolve(a,b);
   q^.resolve(c,d);

   if (b=nil) and (d=nil) then
     begin
       MemSize:=(base.max(a^.len,c^.len) +2 )*sizeOf(cardinal);
       x:=GetMemory(MemSize);
       paste(a,x);
       AddBuf(x,c);
       addabs:=newrationalAnInteger(sgn,x);
       FreeMemory(MemSize);
     end
   else if b=nil then
     begin
       adbc:=base.max(a^.len+d^.len, c^.len)+1;
       MemSize:=(adbc + 2 )*sizeOf(cardinal);
       x:=GetMemory(MemSize);
       multiply(x,a,d);
       AddBuf(x,c);
       addabs:=newrationalDirect(sgn,x,d);
       FreeMemory(MemSize);
     end
   else if d=nil then
       addabs:=addabs(q,p,sgn)
   else
     begin
       adbc:=base.max(a^.len + d^.len , b^.len + c^.len) +1;
       MemSize:=(adbc + b^.len + base.max(c^.len, d^.len) +2 )*sizeOf(cardinal);
       x:=GetMemory(MemSize);
       y:=@x.num[adbc];
       multiply(x,a,d);
       multiply(y,c,b);
       AddBuf(x,y);
       multiply(y,b,d);
       abbreviate(x,y);
       addabs:=newrationalDirect(sgn,x,y);
       FreeMemory(MemSize);
     end;
end;

function sbtabs(p,q:PNumeric; sgn:shortint):PNumeric;
var
   a,b,c,d:PBigNum;
   x,y:PBigNum;
   t:PBigNum;
   MemSize,xsize:integer;
   s:integer;
begin
   p^.resolve(a,b);
   q^.resolve(c,d);

   if (b=nil) and (d=nil) then
     begin
       s:=CompareBignum(a,c);
       if s=0 then
          result:=nil
       else
          begin
            if s<0 then
                   begin  t:=a;  a:=c;  c:=t; sgn:=-sgn end;
            MemSize:=(a^.len +2 )*sizeOf(cardinal);
            x:=GetMemory(MemSize);
             paste(a,x);
             SbtBuf(x,c);
             shrink(x);
             if x^.len=0 then
                result:=nil
             else
                result:=newrationalAnInteger(sgn,x);
             FreeMemory(MemSize);
         end
     end
   else if b=nil then
     begin
       xsize:=a^.len + d^.len +1;
       MemSize:=(xsize + base.max( c^.len,  d^.len) +2 )*sizeOf(cardinal);
       x:=GetMemory(MemSize);
       y:=@x.num[xsize];
       multiply(x,a,d);
       paste(c,y);
       s:=CompareBigNum(x,y);
       if s=0 then
          result:=nil
       else
          begin
             if s<0 then
                   begin t:=x; x:=y; y:=t; sgn:=-sgn end;
             SbtBuf(x,y);
             shrink(x);
             if x^.len=0 then
                result:=nil
             else
                result:=newrationalDirect(sgn,x,d);
          end;
       FreeMemory(MemSize)
     end
   else if d=nil then
     begin
       result:=sbtabs(q,p,-sgn)
     end
   else
     begin
       xsize:=base.max(a^.len , b^.len ) + d^.len +1;
       MemSize:=(xsize +b^.len +base.max( c^.len,  d^.len) +2 )*sizeOf(cardinal);
       x:=GetMemory(MemSize);
       y:=@x.num[xsize];
       multiply(x,a,d);
       multiply(y,c,b);
       s:=CompareBigNum(x,y);
       if s=0 then
          result:=nil
       else
          begin
             if s<0 then
                   begin t:=x; x:=y; y:=t; sgn:=-sgn end;
             SbtBuf(x,y);
             shrink(x);
             multiply(y,b,d);
             abbreviate(x,y);
             if x^.len=0 then
                result:=nil
             else
                result:=newrationalDirect(sgn,x,y);
          end;
       FreeMemory(MemSize)
     end;
end;


function sbtwithSign(a,b:PNUmeric ; sgnA,sgnB:shortint):PNUmeric ;forward;

function addwithSign(a,b:PNumeric ; sgnA,sgnB:shortint):PNumeric ;
begin
   if sgnA=0 then addwithSign:=b^.newcopywithsign(sgnB)
      else if sgnB=0 then addwithSign:=a^.newcopywithsign(sgnA)
          else if sgnA = sgnB then addwithSign:=addabs(a,b,sgnA)
                  else addwithSign:=sbtwithSign(a,b,sgnA,neg(sgnB))
end;


function sbtwithSign(a,b:PNumeric ; sgnA,sgnB:shortint):PNumeric ;
begin
   if sgnA=sgnB then
                    sbtwithSign:=sbtAbs(a,b,sgnA)
                else
                    sbtwithSign:=addwithSign(a,b,sgnA,neg(sgnB));
end;

function addrational(a,b:PNumeric):Pnumeric;
begin
  addrational:=addwithSign(a,b,a^.sgn,b^.sgn);
end;

function sbtrational(a,b:PNumeric):Pnumeric;
begin
  sbtrational:=sbtwithSign(a,b,a^.sgn,b^.sgn);
end;


{************************************}
{rational multiplication and division}
{************************************}

function multiplyrational(p,q:Pnumeric):Pnumeric;
var
   a,b,c,d:PBignum;
   a1,b1,c1,d1,x,y:PBigNum;
   MemSize:integer;
begin
   p^.resolve(a,b);
   q^.resolve(c,d);

   if (b=nil) and (d=nil) then
     begin
       MemSize:=(a^.len + c^.len +2 )*sizeOf(cardinal);
       x:=GetMemory(MemSize);
       multiply(x,a,c);
       MultiplyRational:=newrationalAnInteger((p^.sgn)*(q^.sgn),x);
       FreeMemory(MemSize);
     end
   else if b=nil then
     begin
       MemSize:=(a^.len *2 + c^.len + d^.len + 4)*sizeOf(cardinal);
       a1:=getMemory(MemSize);
       d1:=@a1.num[a^.len];
       x:=@d1.num[d^.len];
       paste(a,a1);
       paste(d,d1);
       abbreviate(a1,d1);
       multiply(x,a1,c);
       multiplyrational:=newrationalDirect((p^.sgn)*(q^.sgn),x,d1);
       FreeMemory(MemSize)
     end
   else if d=nil then
       result:=MultiplyRational(q,p)
   else
     begin
       MemSize:=((a^.len + b^.len + c^.len + d^.len)*2 + 7)*sizeOf(cardinal);
       a1:=getMemory(MemSize);
       b1:=@a1.num[a^.len];
       c1:=@b1.num[b^.len];
       d1:=@c1.num[c^.len];
       x:=@d1.num[d^.len];
       y:=@x.num[a^.len+c.len];
       paste(a,a1);
       paste(b,b1);
       paste(c,c1);
       paste(d,d1);
       abbreviate(a1,d1);
       abbreviate(c1,b1);
       multiply(x,a1,c1);
       multiply(y,b1,d1);
       multiplyrational:=newrationalDirect((p^.sgn)*(q^.sgn),x,y);
       FreeMemory(MemSize)
     end;
end;

function divideRational(p,q:PNumeric):Pnumeric;
var
   a,b,c,d:PBigNum;
   x,y,z:PBigNUm;
   qinv:PNumeric;
   MemSize:integer;
begin
   p^.resolve(a,b);
   q^.resolve(c,d);
   if c^.len=0 then  SetException(3001) ;

   if (b=nil) and (d=nil) then
     begin
       MemSize:=(a^.len + c^.len +2 )*sizeOf(cardinal);
       x:=GetMemory(MemSize);
       y:=@x.num[a^.len];
       paste(a,x);
       paste(c,y);
       abbreviate(x,y);
       DivideRational:=newrationalDirect((p^.sgn)*(q^.sgn),x,y);
       FreeMemory(MemSize);
     end
   else if d=nil then
     begin
       MemSize:=(a^.len + b^.len + c^.len *2  + 4 )*sizeOf(cardinal);
       x:=GetMemory(MemSize);
       y:=@x.num[a^.len];
       z:=@y.num[c^.len];
       paste(a,x);
       paste(c,y);
       abbreviate(x,y);
       multiply(z,b,y);
       DivideRational:=newrationalDirect((p^.sgn)*(q^.sgn),x,z);
       FreeMemory(MemSize);
     end
   else
     begin
       MemSize:=(c^.len + d^.len + 3)*sizeOf(cardinal);
       qinv:=GetMemory(memSize);
       qinv^.sgn:=q^.sgn;
       x:=@qinv.con[0];
       paste(d,x);
       y:=@x.num[x^.len];
       if (c^.len=1) and (c^.num[0]=1) then
           qinv.typ:=AnInteger
       else
         begin
           qinv.typ:=AFraction;
           paste(c,y);
         end;
       result:=MultiplyRational(p,qinv);
       FreeMemory(memSize);
     end;
end;

function IntegerPartRational(p:Pnumeric):PNumeric;
var
  q,r:PBigNum;
  nmr,dnm:PBigNum;
  MemSize:integer;
begin
   if p^.isInteger then
           begin result:=p^.newCopy; exit end;

   p^.resolve(nmr,dnm);
   MemSize:=(nmr^.len *2 +3)*sizeof(cardinal);
   r:=getMemory(MemSize);
   q:=@r.num[nmr^.len +1];
   divide(q,r,nmr,dnm);
   IntegerPartRational:=newRationalAnInteger(p^.sgn,q);
   FreeMemory(memSize)
end;

function decimalpartRational(p:PNumeric):Pnumeric;
var
  q,r:PBignum;
  nmr,dnm:PBignum;
  MemSize:integer;
begin
   p^.resolve(nmr,dnm);
   if dnm=nil then
              begin result:=nil; exit end;

   MemSize:=(nmr^.len *2 +3)*sizeof(cardinal);
   r:=getMemory(MemSize);
   q:=@r.num[nmr^.len +1];
   divide(q,r,nmr,dnm);
   DecimalPartRational:=newRational(p^.sgn,r,dnm);
   FreeMemory(memSize)
end;

{Arithmetic Routines}

procedure add(a,b:PNumeric; var x:PNumeric);
                            // xは初期化済変数でなければならない(nilでもよい)
var
  p:PNumeric;
begin
  if a=nil then
         if b=nil then
            p:=nil
         else
            p:=b^.newCopy
  else
         if b=nil then
            p:=a^.newcopy
         else
            p:=addRational(a,b);

  disposeNumeric(x);
  x:=p;
end;

procedure sbt(a,b:PNumeric; var x:PNumeric);
var
  p:PNumeric;
begin
  if a=nil then
      if b=nil then
         p:=nil
      else
         p:=b^.newCopyOpposite
  else
      if b=nil then
          p:=a^.newcopy
      else
          p:=sbtRational(a,b);
  disposeNumeric(x);
  x:=p;
end;

procedure mlt(a,b:PNumeric; var x:PNumeric);
var
  p:PNumeric;
begin
  if (a=nil) or (b=nil) then
        p:=nil
  else
        p:=MultiplyRational(a,b);
  disposeNumeric(x);
  x:=p;
end;

procedure qtt(a,b:PNumeric; var x:PNumeric);
var
  p:PNumeric;
begin
  if b=nil then
       setexception(3001)
  else
     begin
       if a=nil then
           p:=nil
       else
           p:=DivideRational(a,b);
       disposeNumeric(x);
       x:=p;
     end;
end;

function CompareSub(a,b:PNumeric):shortint;
var
   a1,a2,b1,b2:PBigNum;
   MemSize,MemSize2:integer;
   x,y:PBignum;
begin
   a^.resolve(a1,a2);
   b^.resolve(b1,b2);
   if b2=nil then
     begin
       MemSize:=0;
       x:=a1
     end
   else
     begin
       MemSize:=(a1^.len + b2^.len +4)*sizeOf(Cardinal);
       x:=GetMemory(memSize);
       multiply(x,a1,b2);
     end;
   if a2=nil then
      y:=b1
   else
      begin
       memSize2:=(a2^.len + b1^.len +4)*sizeOf(Cardinal);
       y:=GetMemory(MemSize2);
       multiply(y,a2,b1);
       memSize:=memSize+Memsize2;
      end;
   result:=compareBignum(x,y);
   if a^.sgn<0 then result:=-result;
    FreeMemory(MemSize)

end;

function compare(a,b:PNumeric):shortint;
begin
  if b^.isZero then
     result:=a^.sign
  else if a^.isZero then
     result:= - b^.sign
  else if a^.sgn=b^.sgn then
     begin
       if a^.isInteger and b^.isInteger then
          begin
            result:=compareBignum(@a^.con[0], @b^.con[0]);
            if a^.sgn<0 then result:=-result
          end
       else
          result:=CompareSub(a,b)
     end
  else if a^.sgn>b^.sgn then
     result:=1
  else
     result:=-1
end;

function Numeric.isZero:boolean;
begin
   result:=(@self=nil) or (self.sgn=0) ;
end;

procedure opposite(var r:PNumeric);
begin
  oppose(r)
end;

procedure oppose(var r:PNumeric);
begin
   if r<>nil then with r^ do sgn:=-sgn
end;

procedure absolute(var r:PNumeric);
begin
   if r<>nil then with r^ do if sgn<>0 then sgn:=1;
end;

procedure sgn(var r:PNumeric);
var
  q:PNumeric;
begin
   if (r=nil) or (r^.sgn=0) then
       q:=ConstZero.newCopy
   else
       q:=NewRationalLongint(r^.sgn);
   disposeNumeric(r);
   r:=q;
end;

procedure intpart(var r:PNumeric);
var
   p:PNumeric;
begin
  if r^.isInteger then
  else
    begin
       p:=IntegerPartRational(r);
       disposeNumeric(r);
       r:=p;
    end;
end;

procedure fractpart(var r:PNumeric);
var
   p:PNumeric;
begin
   if r<>nil then
   begin
       p:=DecimalPartRational(r);
       disposeNumeric(r);
       r:=p;
   end;
end;

procedure intround(var r:PNumeric);
begin
  if r^.isInteger then
  else
    begin
      add(r,ConstHalf,r);
      BasicInt(r);
    end;
end;

procedure BasicInt(var r:PNumeric);
begin
  if r^.isInteger then
  else
     if r^.sgn>0 then
        Intpart(r)
     else
        begin
          oppose(r);
          ceil(r);
          oppose(r);
        end;
end;

procedure ceil(var r:PNumeric);
begin
  if r^.isInteger then
  else
     if r^.sgn>0 then
        begin
          Intpart(r);
          add(r,ConstOne,r)
        end
     else
        begin
          oppose(r);
          BasicInt(r);
          oppose(r);
        end;
end;


procedure BasicMod(a,b:PNumeric; var x:PNumeric);
var
   a1,a2,b1,b2:PBignum;
   MemSize,len0:integer;
   q,r:PBignum;
   t:PNumeric;
begin
  t:=nil;
  if b^.isZero then
      begin
         disposeNumeric(x);
         setexception(3006)
      end
  else if a^.isZero then
     begin
       disposeNumeric(x);
       x:=nil
     end
  else if a^.isInteger and b^.isInteger then
     begin
         a^.resolve(a1,a2);
         b^.resolve(b1,b2);
         len0:=base.max(a1^.len , b1^.len)+1;
         MemSize:=(2*len0 + 2)*SizeOf(Cardinal);
         r:=GetMemory(MemSize);
         q:=@r^.num[len0];
         divide(q,r,a1,b1);
         if r.len=0 then
             t:=nil
         else if a^.sign=b^.sign then
             t:=newrationalDirect(b^.sign, r, PBignum(@ConstBignum1))
         else
            begin
               paste(b1,q);
               shiftsbt(q,r,0);
               shrink(q);
               t:=newrationalDirect(b^.sign, q, PBignum(@ConstBignum1))
            end;
         disposeNumeric(x);
         x:=t;
         FreeMemory(MemSize);
     end
  else
     begin
        qtt(a,b,t);
        BasicInt(t);
        mlt(b,t,t);
        sbt(a,t,x);
        disposeNumeric(t);
     end;
end;


procedure BasicRemainder(a,b:PNumeric; var x:PNumeric);
var
   a1,a2,b1,b2:PBignum;
   MemSize,len0:integer;
   q,r:PBignum;
   t:PNumeric;
begin
  t:=nil;
  if b^.isZero then
      begin
         disposeNumeric(x);
         setexception(3006)
      end
  else if a^.isZero then
     begin
       disposeNumeric(x);
       x:=nil
     end
  else if a^.isInteger and b^.isInteger then
    begin
       a^.resolve(a1,a2);
       b^.resolve(b1,b2);
       len0:=base.max(a1^.len , b1^.len)+1;
       MemSize:=(2*len0 + 2)*SizeOf(Cardinal);
       r:=GetMemory(MemSize);
       q:=@r^.num[len0];
       divide(q,r,a1,b1);
       if r.len=0 then
           t:=nil
       else
           t:=newrationalDirect(a^.sign, r, PBignum(@ConstBignum1));
       disposeNumeric(x);
       x:=t;
       FreeMemory(MemSize);
     end
   else
     begin
        qtt(a,b,t);
        IntPart(t);
        mlt(b,t,t);
        sbt(a,t,x);
        disposeNumeric(t);
     end;
end;

procedure min(a,b:PNumeric; var x:PNumeric);
var
    r:PNumeric;
begin
     if compare(a,b)<=0 then r:=a^.newcopy else r:=b^.newcopy;
     disposeNumeric(x);
     x:=r;
end;

procedure max(a,b:PNumeric; var x:PNumeric);
var
    r:PNumeric;
begin
     if compare(a,b)>=0 then r:=a^.newcopy else r:=b^.newcopy;
     disposeNumeric(x);
     x:=r;
end;

procedure GCD(a,b:PNumeric; var x:PNumeric);
var
   a1,a2,b1,b2:PBignum;
   aa,bb,qq,rr,tt:PBignum;
   MemSize,len0:integer;
   a0,b0,t:PNumeric;
begin
  t:=nil;
  if b^.isZero then
     if a^.isZero then
          setexception(3006)
     else
       begin
         t:=a^.newcopywithsign(1);
         disposeNumeric(x);
         x:=t;
       end
  else if a^.isZero then
     begin
       t:=b^.newcopywithsign(1);
       disposeNumeric(x);
       x:=t;
     end
  else if a^.isInteger and b^.isInteger then
    begin
       a^.resolve(a1,a2);
       b^.resolve(b1,b2);
       len0:=base.max(a1^.len , b1^.len)+1;
       MemSize:=(len0 *4 +5)*sizeof(cardinal);
       aa:=GetMemory(MemSize);
       bb:=@aa.num[len0];
       qq:=@bb.num[len0];
       rr:=@qq.num[len0];
       paste(a1,aa);
       paste(b1,bb);
       divide(qq,rr,aa,bb);
       while rr^.len>0 do
          begin
              tt:=rr;
              rr:=aa;
              aa:=bb;
              bb:=tt;
              divide(qq,rr,aa,bb);
          end;
        // bb<==GCD(a1,b1)
       t:=newrationalDirect(1,bb,PBignum(@ConstBignum1));
       disposeNumeric(x);
       x:=t;
       FreeMemory(MemSize);
     end
   else
     begin
        a0:=a^.newcopywithsign(1);
        b0:=b^.newcopywithsign(1);
        t:=nil;
        repeat
          basicremainder(a0,b0,t);
          disposeNumeric(a0);
          a0:=b0;
          b0:=t;
          t:=nil;
        until b0^.isZero;
        disposeNumeric(x);
        x:=a0;
        disposeNumeric(b0);
     end;
end;


procedure IntSQR(var p:PNumeric);
var
   nmr,dnm:PBigNum;
   x:PBigNum;
   MemSize:integer;
   q:PNumeric;
begin
   if p=nil then exit;
   if p^.sgn<0 then setexception(3005);

   IntPart(p);
   if p^.isZero then exit;

   p^.resolve(nmr,dnm);
   MemSize:=(nmr^.len+2)*SizeOf(Cardinal);
   x:=Getmemory(memSize);
   paste(nmr,x);
   ISQR(x^);
   shrink(x);
   q:=newRationalAnInteger(p^.sgn,x);
   disposeNumeric(p);
   p:=q;
   freeMemory(memsize)
end;

procedure IntLOG2(var p:PNumeric);
var
   nmr,dnm:PBigNum;
   x:PBigNum;
   MemSize:integer;
   q:PNumeric;
begin
   IntPart(p);
   if (p=nil) or (p^.sgn<=0) then setexception(3004);

   p^.resolve(nmr,dnm);
   MemSize:=(nmr^.len+2)*SizeOf(Cardinal);
   q:=newRationalLongInt(ILOG2(nmr));
   disposeNumeric(p);
   p:=q;
end;

procedure numer(var r:PNumeric);
var
  p:PNumeric;
  nmr,dnm:PBignum;
begin
  if r=nil then exit;
  r^.resolve(nmr,dnm);
  p:=NewRationalAnInteger(1,nmr);
  disposeNumeric(r);
  r:=p;
end;

procedure denom(var r:PNumeric);
var
  p:PNumeric;
  nmr,dnm:PBignum;
begin
  if r=nil then
     p:=ConstOne^.NewCopy
  else
     begin
        r^.resolve(nmr,dnm);
        if dnm<>nil then
          p:=NewRationalAnInteger(1,dnm)
        else
          p:=ConstOne^.NewCopy;
     end;
  disposeNumeric(r);
  r:=p;
end;

{******************}
{convert to strings}
{******************}
type string9=string[9];

procedure StrDword(n:cardinal; var c:PChar);
var
  i:integer;
begin
  for i:=1 to 9 do
     begin
        dec(c);
        c^:=chr((n mod 10) + ord('0') );
        n:=n div 10;
     end;
end;


function strBig(x:Pbignum):string;
var
  a,q,r:PBigNum;
  MemSize:integer;
  c:PChar;
begin
  if x^.len=0 then begin result:='0' ; exit end;

  memSize:=(x^.len *3 +4)*sizeOf(cardinal) + x^.len *10 +4;
  q:=GetMemory(MemSize);
  a:=@q.num[x^.len];
  r:=@a.num[x^.len];
  c:=@r.num[x^.len];
  c:=c+(x^.len*10);
  c^:=chr(0);
  paste(x,a);
  result:='';
  repeat
     divideShort(q,r,a,1000000000);
     StrDword(r.num[0],c);
     paste(q,a);
  until (a^.len=0) ;
  while c^='0' do inc(c);
  result:=c;
  FreeMemory(MemSize);
end;

function strFraction(p:Pnumeric):string;
var
  nmr,dnm:PBignum;
  s:string;
begin
  if p=nil then
     result:=' 0'
  else
  begin
    p^.resolve(nmr,dnm);
    s:= strBig(nmr) ;
    if p^.sgn=-1 then s:='-' +s else s:=' ' + s;
    if dnm=nil then
       strFraction:=s
    else
       strFraction:=s + '/' + strBig(dnm);
  end
end;

function newRationalword(m,n:cardinal):PNumeric;
                        // 使用注意
begin
  if n=1 then
    begin
       MemoryGet(pointer(result),3*sizeof(Cardinal));
       result^.sgn:=1;
       result^.typ:=AnInteger;
       result^.con[0]:=1;
       result^.con[1]:=m;
    end
   else
    begin
       MemoryGet(pointer(result),5*sizeof(Cardinal));
       result^.sgn:=1;
       result^.typ:=AFraction;
       result^.con[0]:=1;
       result^.con[1]:=m;
       result^.con[2]:=1;
       result^.con[3]:=n;
    end;
end;


function NewRationalFromNumber(const n:PNumber):PNumeric;
var
    i,exp:integer;
    p,q,r:PNumeric;
    base,dev:PNumeric;
    x:cardinal;
begin
  if arithmet.isZero(n) then
    result:=nil
  else
    begin
      p:=nil;
      base:=NewRationalWord(1000000000,1);
      i:=1;
      with n^ do
         begin
           exp:=expn;
           while exp>0 do  //整数部分
             begin
               mlt(p,base,p);
               if i<=places then
                         begin x:=frac[i];inc(i)end
                         else x:=0;
               q:=newRationalWord(x,1);
               add(p,q,p);
               disposeNumeric(q);
               dec(exp);
             end;
           dev:=NewRationalWord(1,1000000000);

           while exp<0 do
             begin
                qtt(dev,base,dev);
                inc(exp);
             end;
           while i<=places do   //小数部分
             begin
                q:=NewRationalWord(frac[i],1);
                r:=nil;
                mlt(q,dev,r);
                add(p,r,p);
                disposeNumeric(q);
                disposeNumeric(r);
                qtt(dev,base,dev);
                inc(i);
             end;
           disposeNumeric(dev);
         end;
       disposeNumeric(base);
       p^.sgn:=n^.sign;
       result:=p;
    end;
end;

procedure InitRational;
begin
   ConstHalf:=newRationalWord(1,2);
   ConstOne:=newRationalLongint(1);
   ConstZero:=nil; //NewRationalWord(0,1);
   ConstTwo:=NewRationalLongint(2);
   ConstTen:=NewRationalLongint(10);
   constPi:=nil; 
end;

end.
