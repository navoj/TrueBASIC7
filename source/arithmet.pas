unit arithmet;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

(***************************************)
(* Copyright (C) 2003, SHIRAISHI Kazuo *)
(***************************************)


{$X+}
{$T+}

interface
uses sysutils;

{***********}
{type Number}
{***********}

const
   HighPrecision=112;
   PrecisionMargin=4;
   MaxPlace = HighPrecision+PrecisionMargin;

var
   precision: LongInt =3;
   limit    : LongInt =3;
                        {limit: number of intermediate operationg digits;
                         normally precision +1 in multiple precision mode}
                        {limit must <= maxplace}
const
   MaxExpn = 16383; {549;}  {HighPrecision;}
   MinExpn = -maxExpn;
const
   MaxExpnNative=549;
var
   maxExpnDecimal:smallint =10;
   minExpnDecimal:smallint =-9;


type
   PNumber = ^Number;
   ShortNumber = object
                  places:LongInt;      {length in words} {1place=10000}
               procedure init(p:PNumber);
               procedure initzero;
               procedure initone;
               procedure TestAsigned;
             public//private
                  sign:  shortint;
                  tag :  byte;           {0 unsigned, 1 normal}
                  expn:  smallint;
                  frac:  array[1..3] of LongInt;
           end;

   LongNumber  = object(ShortNumber)
                  fracEx: array[4..HighPrecision] of LongInt;
           end;
   Number  = object(LongNumber)
                  fracEx2: array[HighPrecision+1..MaxPlace+1] of LongInt;
           end;

procedure subst(var p:PNumber; var n:number);
procedure disposenumber(var p:PNumber);

type
  unaryoperation =procedure(var x:number);
  binaryoperation = procedure (var a,b:Number; var x:Number);

var
  null:PNumber;
  zero:PNumber;
  one:PNumber;
  ten:PNumber;
  half:PNumber;
  MAXNUM:PNumber;
  decimalPI:PNumber;
  decimalHalfPI:PNumber;

const
   OptionDecimal :boolean = true   ;

procedure initinteger(var n:number; i:smallint);
procedure initlongint(var n:number; i:longint);

function LongintVal(var a:number; var c:integer):longint;
                                   {c=0:normal ; else c:sign}
function wordVal(var a:number; var c:integer):word;
                                   {c=0:normal ; else c:sign}
procedure add(var a,b:Number; var x:Number);
procedure sbt(var a,b:Number; var x:Number);
procedure mlt(var a,b:Number; var x:Number);
procedure qtt(var a,b:Number; var x:Number);
procedure Remainder(var a,b:Number; var x:number);
procedure divide(var a,b:number; var x,y:number);
procedure intpower(var a,b:number; var n:number);


procedure qtt2(var n:number);
function sgn(n:PNumber):integer;
function isZero(n:PNumber):boolean;
function isinteger(var n:number):boolean;
function compare(var a,b:number):integer;
procedure opposite(var n:Number);
procedure oppose(var n:number);
procedure absolute(var n:number);
procedure intpart(var n:number);
procedure fractpart(var n:number);
procedure intround(var n:number);
procedure ceil(var n:number);
procedure BasicInt(var n:number);
procedure EpsDecimal(var n:number);
procedure EpsNative(var n:number);
procedure BasicMod(var a,b:Number; var x:number);
procedure min(var a,b:number; var n:number);
procedure max(var a,b:number; var n:number);
procedure round(var x,n:number; var y:number);
procedure truncate(var x,n:number; var y:number);
procedure sqrlong(var a:number);
procedure square(var n:number);

procedure round9( var n:number);
procedure round15( var n:number);
type
    roundprocedure =procedure (var n:number);
var       RoundExpression:roundprocedure;
procedure roundprecision(var n:number);
procedure RoundVariable(var n:number);
procedure checkRangeDecimal(var n:number; extyp:integer);
procedure checkRange(var n:number);

procedure NumericRep(var n:number;var code:integer;var line:ansistring;var cp:integer);
procedure NVal(s:ansistring; var n:number);
function DStr(var n:Number):ansistring;
procedure ConvertToString(const n:number;var digits:ansistring;var exp:integer);
procedure roundstring(var s:ansistring; n:integer; var exp:integer);



{*******************}
{exetended functions}
{*******************}

procedure power(var a,b:Number; var x:Number);
function logN(var a:number):extended;
procedure convert(a:extended; var n:number);
function ExtendedVal(var a:Number):extended;



var
   signiwidth:smallint=10;
   //exradwidth:smallint=2;

procedure setOpModeDecimal;
procedure setOpModeHigh;
procedure setOpModeNative;
procedure setOpModeRational;

type
   MinimalNumber  = object
                  places:LongInt;      {length in words} {1place=10000}
                  sign:  shortint;
                  tag:   byte;
                  expn:  smallint;
                  frac:  array[1..1] of LongInt;
   end;

   decimalnumber  = object
                  places:LongInt;      {length in words} {1place=10000}
                  sign:  shortint;
                  tag:   byte;
                  expn:  smallint;
                  frac:  array[1..6] of LongInt;
    end;

   accuratenumber  = object
                  places:LongInt;      {length in words} {1place=10000}
                  sign:  shortint;
                  tag:   byte;
                  expn:  smallint;
                  frac:  array[1..highprecision+1] of LongInt;
    end;

const
   constnull:MinimalNumber = (places:0; sign:0; tag:0; expn:0; frac:(0));
   constzero:MinimalNumber = (places:0; sign:0; tag:1; expn:0; frac:(0));
   constone: MinimalNumber = (places:1; sign:1; tag:1; expn:1; frac:(1));
   constten: MinimalNumber = (places:1; sign:1; tag:1; expn:1; frac:(10));
   consthalf:MinimalNumber = (places:1; sign:1; tag:1; expn:0; frac:(500000000));

   constdecimalPI:accuratenumber =(places:Highprecision+1; sign:1; tag:1; expn:1 ;
           frac: (3,141592653,589793238,462643383,279502884,197169399,
                    375105820,974944592,307816406,286208998,628034825,
                    342117067,982148086,513282306,647093844,609550582,
                    231725359,408128481,117450284,102701938,521105559,
                    644622948,954930381,964428810,975665933,446128475,
                    648233786,783165271,201909145,648566923,460348610,
                    454326648,213393607,260249141,273724587,006606315,
                    588174881,520920962,829254091,715364367,892590360,
                    011330530,548820466,521384146,951941511,609433057,
                    270365759,591953092,186117381,932611793,105118548,
                    074462379,962749567,351885752,724891227,938183011,
                    949129833,673362440,656643086,021394946,395224737,
                    190702179,860943702,770539217,176293176,752384674,
                    818467669,405132000,568127145,263560827,785771342,
                    757789609,173637178,721468440,901224953,430146549,
                    585371050,792279689,258923542,019956112,129021960,
                    864034418,159813629,774771309,960518707,211349999,
                    998372978,049951059,731732816,096318595,024459455,
                    346908302,642522308,253344685,035261931,188171010,
                    003137838,752886587,533208381,420617177,669147303,
                    598253490,428755468,731159562,863882353,787593751,
                    957781857,780532171,226806613,001927876,611195909,
                    216420198,938095257 ));

   constdecimalHalfPI:decimalnumber =(places:6; sign:1; tag:1; expn:1 ;
           frac:(1,570796326,794896619,231321691,639751442,098500000) );
var
   constMAXNUM:MinimalNumber = (places:1; sign:1; tag:1; expn:10; frac:(100));



{************}
implementation
{************}
   uses math,base,sconsts,float,memman, struct;
{$ASMMODE intel}

{var
   OperationMode:word=0; }

{****************}
{utility routines}
{****************}



{$IFDEF CPU32}
function mini(a,b:longint):longint;assembler;
asm
   cmp    eax,edx
   jc     @L1
   mov    eax,edx
  @L1:
end;
{$ENDIF}
{$IFDEF CPU64}
function mini(a,b:longint):longint;assembler;
            //EDI<-a, ESI<-b
asm
   mov    eax,edi{a}
   cmp    eax,esi{b}
   jc     @L1
   mov    eax,esi{b}
  @L1:
end;
{$ENDIF}

{$IFDEF CPU32}
procedure movDWF(var src,dst; count:LongInt);assembler;  {move DWords forward}
asm         {move(a^,x^,count*4); }
    push    esi
    push    edi
    mov     esi,src
    mov     edi,dst
    {mov     ecx,count }
    rep     movsd
    pop     edi
    pop     esi
end;

procedure movDWB(var src,dst; count:LongInt);assembler; {move DWords backward}
asm         {move(a^,x^,count*4); }
    push    esi
    push    edi
    std
    mov     esi,src
    mov     edi,dst
    {mov     ecx,count}
    mov     eax,ecx
    dec     eax
    shl     eax,2
    add     esi,eax
    add     edi,eax
    rep     movsd
    cld
    pop     edi
    pop     esi
end;
{$ENDIF}
{$IFDEF CPU64}
procedure movDWF(var src,dst; count:LongInt);assembler;  {move DWords forward}
              // RDI<-src, RSI<-dst
asm         {move(a^,x^,count*4); }
    xchg     rdi,rsi
    xor     rcx,rcx           // clear rcx
    mov     ecx,count
    rep     movsd
end;

procedure movDWB(var src,dst; count:LongInt);assembler; {move DWords backward}
                     {rdi}{rsi}  {edx}
asm         {move(a^,x^,count*4); }
    xchg     rdi,rsi
    std
    xor     rax,rax
    mov     eax,count
    mov     rcx,rax
    dec     rax
    shl     rax,2
    add     rsi,rax
    add     rdi,rax
    rep     movsd
    cld
end;
{$ENDIF}



{**********}
{arithmetic}
{**********}

procedure ShortNumber.init(p:PNumber);
begin
   movDWF(p^,self,p^.places+2)
end;

procedure ShortNumber.initzero;
begin
    init(zero)
end;

procedure ShortNumber.initone;
begin
   init(one)
end;

procedure ShortNumber.TestAsigned;
begin
   if tag=0 then
         ReportException(false , 3101, s_Extype3101);
 end;

{$IFDEF CPU32}
procedure clear(var a; n:LongInt);assembler;
asm
   push   edi
   mov    edi,a
   mov    ecx,n
   xor    eax,eax
   rep    stosd
   pop    edi
end;
{$ENDIF}
{$IFDEF CPU64}
procedure clear(var a; n:LongInt);assembler;
               //rdi<-a, esi<-n
asm
   xor    rcx,rcx   //clear rcx
   mov    ecx,n
   xor    eax,eax
   rep    stosd
end;
{$ENDIF}



procedure lengthen(var n:number; k:LongInt);
begin
   with n do
   begin
      if k>limit then k:=limit;
      if k>places then
         begin
            {for i:=places+1 to k do frac[i]:=0;}
            clear(frac[1+places],k-places);
            places:=k
         end;
   end;
end;

procedure shorten(var n:number);
begin
  with n do
  begin
      while (places>0) and (frac[places]=0)  do dec(places);
      if places=0 then sign:=0;
  end;
end;

{$IFDEF CPU32}
function CompareRepeat(var a,b; n:LongInt):integer;assembler;
asm
   push   edi
   push   esi
  { mov    ecx,n  }
   mov    esi,a
   mov    edi,b
   rep    cmpsd
   je     @EQ
   jc     @LESS
   mov    eax,1
   jmp    @EXIT
  @EQ:
   mov    eax,0
   jmp    @EXIT
  @LESS:
   mov    eax,-1
  @EXIT:
   pop    esi
   pop    edi
end;
{$ENDIF}
{$IFDEF CPU64}
 function CompareRepeat(var a,b; n:LongInt):integer;assembler;
                            //rdi<-a, rsi<-b,  edx<-n
asm
   xchg    rdi,rsi
   xor    rcx,rcx
   mov    ecx,n
   rep    cmpsd
   je     @EQ
   jc     @LESS
   mov    eax,1
   jmp    @EXIT
  @EQ:
   mov    eax,0
   jmp    @EXIT
  @LESS:
   mov    eax,-1
  @EXIT:
end;
{$ENDIF}


function CompareAbs(var a,b:number):integer;
var
   s:integer;
   i:integer;
begin
   if a.sign=0 then
         if b.sign=0 then
            compareabs:=0
         else
            compareabs:=-1
   else if b.sign=0 then
        compareabs:=1
   else
      begin
          s:=a.expn-b.expn;
          if s<>0 then
             CompareAbs:=s
          else
             begin
                 s:=comparerepeat(a.frac[1],b.frac[1],mini(a.places,b.places));

                 if s<>0 then
                          compareabs:=s
                 else
                         compareabs:=a.places-b.places;
             end;
      end;
end;


function compare(var a,b:number):integer;
var
   s:integer;
begin
   s:=a.sign-b.sign;
   if s<>0 then
      compare:=s
   else
         if a.sign>0 then
            compare:=compareabs(a,b)
         else if a.sign<0 then
            compare:=compareabs(b,a)
         else
            compare:=0;
end;


procedure shiftLeft(var n:number; r:LongInt);
begin
    { for i:=1 to places-1 do frac[i]:=frac[i+1];}
   with n do
   begin
     if places>1 then movDWF(frac[2],frac[1],places-1);
     frac[places]:=r;
     dec(expn);
   end;
end;

function shiftRight(var n:number; carry:LongInt):LongInt;
var
  p:LongInt;
begin
   with n do
   begin
     p:=places;
     if p<limit then
             begin
                shiftright:=0;
                frac[p+1]:=frac[p];
                inc(places);
             end
     else
                shiftright:=frac[p];
    { for i:=p downto 2 do frac[i]:=frac[i-1];}
     if p>=2 then movDWB(frac[1],frac[2],p-1);
     frac[1]:=carry;
     inc(expn);
   end;
end;

procedure raisesmall(var n:number);
var
   i:LongInt;
begin
   with n do
   begin
      i:=places;
      inc(frac[i]);
      while frac[i]=1000000000 do
             begin
                    frac[i]:=0;
                    inc(frac[i-1]);
                    dec(i);
                    dec(places);
             end;
    end;
end;


procedure carryuptail(var n:number);
var
   i:LongInt;
begin
   with n do
   begin
        i:=places;
        while (frac[i]=1000000000) and (i>1) do
               begin
                      frac[i]:=0;
                      inc(frac[i-1]);
                      dec(places);
                      dec(i);
               end;
        if (i=1) and (frac[1]=1000000000) then
               begin
                     frac[1]:=1;
                     inc(expn);
               end;
   end;
end;

procedure RoundUp(var n:number);
begin
   with n do inc(frac[places]);
   carryuptail(n);
end;

{$IFDEF CPU32}
procedure carryupsub(var f; i:LongInt);assembler;
asm
           {mov    eax,f  }
           mov    ecx,i
           {mov    edx,ecx }
           shl    edx,2
           add    eax,edx
          @L1:
           cmp    dword ptr [eax],1000000000
           jc     @L2
           sub    dword ptr [eax],1000000000
           inc    dword ptr [eax-4]
          @L2:
           sub    eax,4
           loop   @L1
         (*
           les    di,f
           mov    cx,i
           mov    ax,cx
           shl    ax,1
           add    di,ax
          @L1:
           cmp    word ptr [es:di],10000
           jc     @L2
           sub    word ptr [es:di],10000
           inc    word ptr [es:di-2]
          @L2:
           sub    di,2
           loop   @L1
          *)
end;
{$ENDIF}
{$IFDEF CPU64}
 procedure carryupsub(var f; i:LongInt);assembler;
                     //rdi<-f, esi<-i
asm
           //mov    rdi,f
           xor    rcx,rcx
           mov    ecx,i
           mov    rax,rcx
           shl    rax,2
           add    rdi,rax
          @L1:
           cmp    dword ptr [rdi],1000000000
           jc     @L2
           sub    dword ptr [rdi],1000000000
           inc    dword ptr [rdi-4]
          @L2:
           sub    rdi,4
           loop   @L1
end;
{$ENDIF}


procedure carryup(var n:number);
var
   i:LongInt;

begin
  {
   for i:=places downto 2 do
      if (frac[i]>=10000) then
          begin
                 frac[i]:=frac[i]-10000;
                 inc(frac[i-1]);
          end;
  }
   with n do
   begin
        i:=places-1;
        if i>0 then carryupsub(frac[1],i);

        if (places>0) and (frac[1]>=1000000000) then
               begin
                     dec(frac[1],1000000000);
                     shiftRight(n,1);      {shiftrightを呼び出す}
                    { if r>=5000 then raisesmall(n); }
               end;
    end;
end;

{$IFDEF CPU32}
procedure unborrowsub(var f; i:LongInt);assembler;
asm
          { les    eax,f }
          { mov    edx,i }
          mov     ecx,edx
           shl    edx,2
           add    eax,edx
          @L1:
           cmp    dword ptr [eax],0
           jge    @L2
           add    dword ptr [eax],1000000000
           dec    dword ptr [eax-4]
          @L2:
           sub    eax,4
           loop   @L1
end;
{$ENDIF}
{$IFDEF CPU64}
 procedure unborrowsub(var f; i:LongInt);assembler;
                        {rdi} {esi}
asm
         //mov    rdi, f
           xor    rcx,rcx
           mov    ecx, i
           mov    rdx,rcx
           shl    rdx,2
           add    rdi,rdx
          @L1:
           cmp    dword ptr [rdi],0
           jge    @L2
           add    dword ptr [rdi],1000000000
           dec    dword ptr [rdi-4]
          @L2:
           sub    rdi,4
           loop   @L1
end;
{$ENDIF}

function  unborrow(var n:number):boolean;
var
   i:LongInt;
begin
   unborrow:=true;
   {
   for i:=places downto 2 do
                if frac[i]<0 then
                   begin
                      inc(frac[i],10000);
                      dec(frac[i-1]);
                   end;
    }
   with n do
   begin
      i:=places-1;
      if i>0 then unborrowsub(frac[1],i);
      if frac[1]<0 then
         unborrow:=false;
   end;
end;

procedure normalize(var n:number);
var
    count,p:LongInt;
begin
   with n do
   begin
        p:=places;
        count:=0;
        while (count<p) and (frac[count+1]=0) do
             begin
                  inc(count);
                  dec(expn);
                  dec(places);
             end;
        if (count>0) and (p>count) then
           {for i:=count+1 to p do
                        frac[i-count]:=frac[i];}
           movDWF(frac[1+count],frac[1],p-count);
        if places=0 then
                        sign:=0;
    end;
end;

procedure checkRange(var n:number);
begin
    with n do
    begin
        if sign=0 then  exit;

        normalize(n);
        shorten(n);
        if (expn<minExpn) then
              initzero;
        if (expn<=MaxExpn) or
           (expn=MaxExpn+1) and (places=1) and (frac[1]=1) then
        else
           begin
              expn:=MaxExpn+1;
              frac[1]:=1;
              places:=1;
              setexception(1002);
           end;
    end;
end;

{$IFDEF CPU32}
procedure addincrement(var a; var b; p:LongInt);assembler;
asm                              {asuume n>0}
   push    ebx
   jecxz   @L2
  @L1:
   mov     ebx,[edx]
   add     edx,4             { post-increment}
   add     [eax],ebx
   add     eax,4             { post-increment}
   loop    @L1
  @L2:
   pop     ebx
end;

procedure subincrement(var a; var b; p:LongInt);assembler;
asm                                   {asuume n>0}
   push    ebx
   jecxz   @L2
  @L1:
   mov     ebx,[edx]
   add     edx,4                  { post-increment}
   sub     [eax],ebx
   add     eax,4                  { post-increment}
   loop    @L1
  @L2:
   pop     ebx
end;
{$ENDIF}
{$IFDEF CPU64}
procedure addincrement(var a; var b; p:LongInt);assembler;
                     //rdi<-a, rsi<- b, edx<- p
asm                              {asuume n>0}
   xor     rcx,rcx
   mov     ecx,p
   jrcxz   @L2
  @L1:
   mov     eax,[rsi]
   add     rsi,4             { post-increment}
   add     [rdi],eax
   add     rdi,4             { post-increment}
   loop    @L1
  @L2:
end;

procedure subincrement(var a; var b; p:LongInt);assembler;
                     //rdi<-a, rsi<- b, edx<- p
asm                                   {asuume n>0}
     xor     rcx,rcx
     mov     ecx,p
     jrcxz   @L2
  @L1:
     mov     eax,[rsi]
     add     rsi,4                  { post-increment}
     sub     [rdi],eax
     add     rdi,4                  { post-increment}
     loop    @L1
  @L2:
end;
{$ENDIF}



function partadd(var n:number; var b:number):boolean;
var
      { i,j:integer;  }
       diff:integer;
begin
    with n do
    begin
          diff:=expn-b.expn;
          lengthen(n,diff+b.places);
        {
          i:=diff;
          j:=0;
          while (i<places) and (j<b.places) do
              begin
                  inc(i);
                  inc(j);
                  inc(frac[i],b.frac[j]);
              end;
         }
          if diff<limit then
             addincrement(frac[1+diff],b.frac[1],mini(b.places,limit-diff));
          carryup(n);
          partadd:=(frac[1]>=0);
    end;
end;

procedure  addsub(var a,b:Number; var x:Number);
                  {asuume a>0, b>0, a.expn>=b.expn}
                  {no care of signs. x.sign<- a.sign}
begin
   with x do
      begin
         init(@a);
         partadd(x,b);
      end;
end;

function partsbt(var n:number; var b:number):boolean;
var
    diff:integer;
begin
    with n do
    begin
          diff:=expn-b.expn;
          if diff<0 then begin partsbt:=false; setexception(SystemErr); exit end;
          lengthen(n,diff+b.places);
         {
          i:=diff;
          j:=0;
          while (i<places) and (j<b.places) do
              begin
                  inc(i);
                  inc(j);
                  frac[i]:=frac[i]-b.frac[j];
              end;
          }
          if diff<limit then
             subincrement(frac[1+diff],b.frac[1],mini(b.places,limit-diff));
      end;
      partsbt:=unborrow(n);
end;

function sbtsub(var a,b:number; var x:Number):boolean;
                    { assume a.expn>=b.expn}
                    { no care of signs. a.sign -> x.sign}
                    { result<0 means failure }
begin
    with x do
        begin
           init(@a);
           sbtsub:=partsbt(x,b)
        end;
end;


procedure add(var a,b:Number; var x:Number);
var
    n:number;
begin
    if ((a.sign>0) and (b.sign>0)) or ((a.sign<0) and (b.sign<0)) then
          begin
             if a.expn>=b.expn then
                 addsub(a,b,n)
             else
                 addsub(b,a,n);
             x.init(@n);
          end
    else if a.sign=0 then
       x.init(@b)
    else if b.sign=0 then
       x.init(@a)
    else
       begin
          if (a.expn>=b.expn) and sbtsub(a,b,n) then

          else
              sbtsub(b,a,n);
          x.init(@n);
       end;

   checkrange(x);
end;




procedure sbt(var a,b:Number; var x:Number);
var
    n:number;
begin
    if ((a.sign>0) and (b.sign>0)) or ((a.sign<0) and (b.sign<0)) then
       begin
          if (a.expn>=b.expn) and sbtsub(a,b,n) then
            else
             begin
                sbtsub(b,a,n);
                n.sign:=-n.sign;
             end ;
          x.init(@n);
       end
    else if a.sign=0 then
       begin
           x.init(@b);
           oppose(x)
       end
    else if b.sign=0 then
       x.init(@a)
    else
       begin
          if a.expn>=b.expn then
              addsub(a,b,n)
          else
              begin
                  addsub(b,a,n);
                  n.sign:=-n.sign;
              end;
          x.init(@n);
       end;

    checkrange(x);
end;

{***************************}
{multiplication and division}
{***************************}

const
   const1000000000 :LongInt = 1000000000;
{$IFDEF CPU32}

procedure unitmlt(a,b:LongInt; var x);assembler;
asm              {eax,edx}          {ecx}
   mul     edx
   add     [ecx],eax
   adc     [ecx+4],edx
   adc     dword ptr [ecx+8],0
end;
{$ENDIF}
{$IFDEF CPU64}
procedure unitmlt(a,b:LongInt; var x);assembler;
asm              {edi,esi}          {rdx}
   mov     rcx,rdx {x}
   mov     eax,edi {a}
   mov     edx,esi {b}
   mul     edx
   add     [rcx],eax
   adc     [rcx+4],edx
   adc     dword ptr [rcx+8],0
end;
{$ENDIF}

{$IFDEF CPU32}
procedure carryupmlt(var f);assembler;
asm
   push   ebx
   mov    ecx,eax         { eax ← f }
   mov    eax,[ecx+4]
   mov    edx,[ecx+8]
   div    const1000000000
   mov    ebx,eax
   mov    eax,[ecx]
   div    const1000000000
   mov    [ecx],edx
   add    [ecx-16],eax
   adc    [ecx-12],ebx
   adc    dword ptr [ecx-8],0
   pop    ebx
end;
{$ENDIF}
{$IFDEF CPU64}
procedure carryupmlt(var f);assembler;
                      {rdi}
 asm
   mov    eax,[rdi+4]
   mov    edx,[rdi+8]
   div    [const1000000000+rip]
   mov    ecx,eax
   mov    eax,[rdi]
   div    [const1000000000+rip]
   mov    [rdi],edx
   add    [rdi-16],eax
   adc    [rdi-12],ecx
   adc    dword ptr [rdi-8],0
end;
{$ENDIF}



procedure mlt(var a,b:number; var x:number);
var
   i,j,p:LongInt;
   f:array[1..maxplace+2]of array[0..3] of LongInt;
   sign:shortint;
begin
   if (a.sign=0) or (b.sign=0) then
      begin
         x.initzero;
         exit
      end;
   p:=mini(a.places+b.places,limit+2);
   clear(f,p*4);

   for i:=1 to a.places do
     if limit+2>i then
       for j:=1 to mini(b.places, limit+2-i) do
           unitmlt(a.frac[i],b.frac[j],f[i+j]);
   for i:=p downto 2 do
                       carryupmlt(f[i]);

   x.expn:=a.expn+b.expn;
   if f[1][0]=0 then
      begin
          dec(x.expn);
          dec(p);
          for i:=1 to p do x.frac[i]:=f[i+1][0]
      end
   else
       begin
           if p>limit then p:=limit;
           for i:=1 to p do x.frac[i]:=f[i][0];
       end;
   x.places:=p;
   sign:=1;
   if a.sign<0 then sign:=-1;
   if b.sign<0 then sign:=-sign;
   x.sign:=sign;
   checkRange(x) ;
end;


{*********}
{ division}
{*********}


{$IFDEF CPU32}
procedure partmltsub(a:LongInt; var b; var x);assembler;
asm
    push   esi
    push   edi
    push   ebx

    mov    esi,b
    mov    edi,x
    mov    ecx,[esi]   {b.places}
    mov    ebx,ecx
    inc    ebx
    shl    ebx,2
    add    esi,ebx     { ds:si -> b.frac[places]}
    add    edi,ebx     { es:di -> x.frac[places]}
    mov    ebx,eax
    jcxz   @L2
   @L1:
    mov    eax,[esi]
    mul    ebx
    div    const1000000000
    add    [edi+4],edx
    mov    [edi],eax
    sub    esi,4
    sub    edi,4
    loop   @L1
   @L2:
    pop    ebx
    pop    edi
    pop    esi
end;
{$ENDIF}
{$IFDEF CPU64}
procedure partmltsub(a:LongInt; var b; var x);assembler;
                     {edi}        {rsi}     {rdx}
asm
    push   rbx
    mov    eax,edi
    //mov    rsi,b
    mov    rdi,x
    xor    rcx,rcx     //loop命令を用いるので必須と思われる
    mov    ecx,[rsi]   {b.places}
    mov    rbx,rcx
    inc    rbx
    shl    rbx,2
    add    rsi,rbx     { ds:si -> b.frac[places]}
    add    rdi,rbx     { es:di -> x.frac[places]}
    mov    ebx,eax
    jecxz  @L2
   @L1:
    mov    eax,[rsi]
    mul    ebx
    div    [const1000000000+rip]
    add    [rdi+4],edx
    mov    [rdi],eax
    sub    rsi,4
    sub    rdi,4
    loop   @L1
   @L2:
    pop    rbx
end;
{$ENDIF}

procedure partmlt(e:smallint; a:LongInt; var b:number; var x:number);
begin
  with x do
  if (a=0) or (b.sign=0) then
      initzero
  else
  begin
     places:=b.places+1;
     sign:=1;
     expn:=b.expn+e+1;

     frac[places]:=0;
     { for i:=places downto 1 do frac[i]:=mltunit(a,b.frac[i],frac[i+1]);  }
     partmltsub(a,b,x);

     carryup(x);
     if frac[1]=0 then
                     shiftleft(x,0);
     shorten(x);
  end;
end;

procedure partmlt1(e:smallint; var b:number; var x:number);
begin
  with x do
  begin
     init(@b);
     sign:=1;
     expn:=expn+e;
  end;
end;


type
   CompRec=record
         lo:cardinal;
         hi:longint;
   end;
{$IFDEF CPU32}
function LongDiv(var a:comprec; b:LongInt):LongInt;assembler;
asm                {eax}       {edx}
   mov   ecx,edx
   mov   edx,[eax+4]
   mov   eax,[eax]
   div   ecx
end;
{$ENDIF}
{$IFDEF CPU64}
function LongDiv(var a:comprec; b:LongInt):LongInt;assembler;
asm                 {rdi}      {esi}
   mov   ecx,esi
   mov   edx,[rdi+4]
   mov   eax,[rdi]
   div   ecx
end;
{$ENDIF}


function longMul(a,b:LongInt):comprec;
begin
   int64(result):=int64(a)*int64(b);
end;

(*
function longMul(a,b:LongInt):comprec;assembler;
asm
   mul    edx
   mov    [ecx],eax
   mov    [ecx+4],edx
end;
*)
{$IFDEF CPU32}
procedure LongAdd(var a,b:comprec);assembler;  {a:=a+b}
asm                  {eax}{edx}
   mov   ecx,[eax]
   add   ecx,[edx]
   mov   [eax],ecx
   mov   ecx,[eax+4]
   adc   ecx,[edx+4]
   mov   [eax+4],ecx
end;
{$ENDIF}
{$IFDEF CPU64}
procedure LongAdd(var a,b:comprec);assembler;  {a:=a+b}
asm                 {rdi}{rsi}
   mov   ecx,[rdi]
   add   ecx,[rsi]
   mov   [rdi],ecx
   mov   ecx,[rdi+4]
   adc   ecx,[rsi+4]
   mov   [rdi+4],ecx
end;
{$ENDIF}

{const Comp1000000000:comp=1000000000;}

procedure dividesub(var a,b:Number; var q,r:number; division:boolean);
   var
      s:number;
      devident,temp:comprec;
      carry:LongInt;

      head :LongInt;
      multi:LongInt;
      divisor:LongInt;

   procedure heading(var b:number);
   begin
      with b  do
      begin
          if  frac[1]<10 then
               begin
                  multi  :=100000000;
                  divisor:=10;
               end
          else if  frac[1]<100 then
               begin
                  multi  :=10000000;
                  divisor:=100;
               end
          else if  frac[1]<1000 then
               begin
                  multi  :=1000000;
                  divisor:=1000;
               end
          else if  frac[1]<10000 then
               begin
                  multi  :=100000;
                  divisor:=10000;
               end
          else if  frac[1]<100000 then
               begin
                  multi  :=10000;
                  divisor:=100000;
               end
          else if  frac[1]<1000000 then
               begin
                  multi  :=1000;
                  divisor:=1000000;
               end
          else if  frac[1]<10000000 then
               begin
                  multi  :=100;
                  divisor:=10000000;
               end
          else if  frac[1]<100000000 then
               begin
                  multi  :=10;
                  divisor:=100000000;
               end
          else
               begin
                  multi:=1;
                  divisor:=1000000000;
               end;
          if places>1 then
             head:=frac[1]*multi+frac[2] div divisor
          else
             head:=frac[1]*multi ;
      end;
   end;


  procedure partqtt;

  begin
   with r do
     begin
       devident:=longmul(frac[1]*multi,1000000000);
       if places>=2 then
          begin
              temp:=longmul(frac[2],multi);
              longadd(devident,temp);
              if places>=3 then
                 begin
                    temp.hi:=0;
                    temp.lo:=frac[3] div divisor;
                    longadd(devident,temp);
                 end;
          end;
      end;
      {
      case places of
        1:devident:=(frac[1]*comp1000000000)*multi;
        2:devident:=(frac[1]*comp1000000000+frac[2])*multi;
        else devident:=(frac[1]*comp1000000000+frac[2])*multi+frac[3] div divisor;
      end;
      }
   with q do
   begin
      frac[places]:=LongDiv(devident,head);                      {temorary quotient}
      if frac[places]>=1000000000 then frac[places]:=999999999;
      partmlt(expn-places,frac[places],b,s);
      if (s.sign<>0) and not partsbt(r,s) then
         repeat
             dec(frac[places]);
             partmlt1(expn-places,b,s);
         until (s.sign=0) or partadd(r,s);
      shiftleft(r,carry);
      shorten(r);
    end;
  end;

begin
   q.initzero;
   r.init(@a);

   if b.sign=0 then
         setexception(3001)
   else if a.sign=0 then
      exit;

   heading(b);

   inc(limit);

   r.init(@a);
   r.sign:=1;
   carry:=shiftright(r,0);
   q.sign:=1;
   q.expn:=a.expn-b.expn+1;

   if division then
      begin
         q.places:=0;
         while (q.places<=limit) and (r.sign>0) do
             begin
                inc(q.places);
                partqtt;
                carry:=0;
             end;

      end
   else
      begin
         q.places:=0;
         while (compareabs(r,b)>=0) and (q.places<limit) do
             begin
                inc(q.places);
                partqtt;
                carry:=0;
             end;

          normalize(r);
          if a.sign<0 then oppose(r);
      end;

         carryup(q);
         if (q.places>0) and (q.frac[1]=0) then shiftleft(q,0);
         shorten(q);
         if q.places>limit then q.places:=limit;
         if a.sign<0 then oppose(q);
         if b.sign<0 then oppose(q);
   dec(limit);
end;




procedure qtt(var a,b:Number; var x:number);
var
   q,r:number;
begin
   dividesub(a,b,q,r,true);
   checkrange(q);
   x.init(@q);
end;



procedure remainder(var a,b:Number; var x:number);
var
   q,r,s:number;
begin
   dividesub(a,b,q,r,false);
   while compare(r,b)*b.sign>0 do
   begin
      s.init(@r);
      dividesub(s,b,q,r,false);
   end;
   checkrange(r);
   x.init(@r)
end;

procedure divide(var a,b:number; var x,y:number);
var
  q,r:number;
begin
    dividesub(a,b,q,r,false);
    checkrange(q);
    checkrange(r);
    x.init(@q);
    y.init(@r);
    if not isinteger(q) then setexception(SystemErr)
end;


procedure qtt2(var n:number);
var
   i:smallint;
   carry:LongInt;
begin
   carry:=0;
   with n do
      begin
         for i:=1 to places do
             begin
                if carry<>0 then inc(frac[i],1000000000);
                carry:=frac[i] and 1;
                frac[i]:=frac[i] shr 1;
             end;
         if (carry=1) and (places<limit) then
          begin
               inc(places);
               frac[places]:=500000000;
          end;
      end;
   normalize(n);
end;


{********}
{rounding}
{********}


{*************}
{round decimal}
{*************}

(*
procedure round10( var n:number);
label
   EXIT;
begin
    asm
       les  di,n

       cmp  byte ptr es:[di],3    {if n.places<3 then goto EXIT; }
       jb   EXIT

       cmp  word ptr number(es:[di]).frac , 1000
       jb   @L1                             { if (frac[1]>=1000)  then  }
       mov  byte ptr  es:[di],3                   { places:=3;  }
       mov  ax,  word ptr number(es:[di]).frac + 4
       mov  dx,0
       mov  bx,100
       div  bx                                        { r:=frac[3] mod 100;}
       sub  word ptr number(es:[di]).frac + 4 ,dx      {frac[3]:=frac[3]-r;}
       cmp  dx,50
       jb   EXIT                                      {if r>= 50 then }
       add  word ptr number(es:[di]).frac + 4 ,100     { frac[3]:=frac[3]+100; }
       jmp  @L5

     @L1:

       cmp  word ptr number(es:[di]).frac , 100
       jb   @L2                                   { if (frac[1]>=100)  then  }
       mov  byte ptr  es:[di],3                   { places:=3;  }
       mov  ax,  word ptr number(es:[di]).frac + 4
       mov  dx,0
       mov  bx,10
       div  bx                                        { r:=frac[3] mod 10;}
       sub  word ptr number(es:[di]).frac + 4 ,dx      {frac[3]:=frac[3]-r;}
       cmp  dx,5
       jb   EXIT                                      {if r>= 5 then }
       add  word ptr number(es:[di]).frac + 4 ,10   { frac[3]:=frac[3]+10; }
       jmp  @L5

     @L2:
       cmp  byte ptr es:[di],4    {if n.places<4 then exit; }
       jb   EXIT
       cmp  word ptr number(es:[di]).frac , 10
       jb   @L3                             { if (frac[1]>=100)  then  }
       mov  byte ptr  es:[di],3                   { places:=3;  }
       cmp  word ptr number(es:[di]).frac + 6,5000
       jb   EXIT                                    {if frac[4]>=5000 then }
       inc (word ptr number(es:[di]).frac + 4)      {inc(frac[3])}
       jmp  @L5                                          {else}

     @L3:
       mov  byte ptr  es:[di],4                   { places:=4;  }
       mov  ax,  word ptr number(es:[di]).frac + 6
       mov  dx,0
       mov  bx,1000
       div  bx                                        { r:=frac[4] mod 1000;}
       sub  word ptr number(es:[di]).frac + 6 ,dx      {frac[4]:=frac[4]-r;}
       cmp  dx,500
       jb   EXIT                                      {if r>= 500 then }
       add  word ptr number(es:[di]).frac + 6 ,1000   { frac[4]:=frac[4]+1000; }

      @L5:
   end;
   carryuptail(n);
 EXIT:
 shorten(n);
end;

procedure round11( var n:number);
label
   EXIT;
begin
    asm
       les  di,n

       cmp  byte ptr es:[di],3    {if n.places<3 then goto EXIT; }
       jb   EXIT

       cmp  word ptr number(es:[di]).frac , 1000
       jb   @L1                             { if (frac[1]>=1000)  then  }
       mov  byte ptr  es:[di],3                   { places:=3;  }
       mov  ax,  word ptr number(es:[di]).frac + 4
       mov  dx,0
       mov  bx,10
       div  bx                                        { r:=frac[3] mod 10;}
       sub  word ptr number(es:[di]).frac + 4 ,dx      {frac[3]:=frac[3]-r;}
       cmp  dx,5
       jb   EXIT                                      {if r>= 5 then }
       add  word ptr number(es:[di]).frac + 4 ,10     { frac[3]:=frac[3]+10; }
       jmp  @L5

     @L1:
       cmp  word ptr number(es:[di]).frac , 100
       jb   @L2                             { if (frac[1]>=100)  then  }
       mov  byte ptr  es:[di],3                   { places:=3;  }
       cmp  word ptr number(es:[di]).frac + 6,5000
       jb   EXIT                                    {if frac[4]>=5000 then }
       inc (word ptr number(es:[di]).frac + 4)      {inc(frac[3])}
       jmp  @L5                                          {else}


     @L2:
       cmp  byte ptr es:[di],4    {if n.places<4 then exit; }
       jb   EXIT
       mov  byte ptr  es:[di],4                   { places:=4;  }
       cmp  word ptr number(es:[di]).frac , 10
       jb   @L3                             { if (frac[1]>=10)  then  }
       mov  ax,  word ptr number(es:[di]).frac + 6
       mov  dx,0
       mov  bx,1000
       div  bx                                        { r:=frac[4] mod 1000;}
       sub  word ptr number(es:[di]).frac + 6 ,dx      {frac[4]:=frac[4]-r;}
       cmp  dx,500
       jb   EXIT                                      {if r>= 500 then }
       add  word ptr number(es:[di]).frac + 6 ,1000   { frac[4]:=frac[4]+1000; }
       jmp  @L5                                          {else}

     @L3:
       mov  ax,  word ptr number(es:[di]).frac + 6
       mov  dx,0
       mov  bx,100
       div  bx                                        { r:=frac[4] mod 100;}
       sub  word ptr number(es:[di]).frac + 6 ,dx      {frac[4]:=frac[4]-r;}
       cmp  dx,50
       jb   EXIT                                      {if r>= 50 then }
       add  word ptr number(es:[di]).frac + 6 ,100   { frac[4]:=frac[4]+100; }


     @L5:
   end;
   carryuptail(n);
 EXIT:
 shorten(n);
end;

procedure round15( var n:number);
label
   EXIT;
begin
    asm
       les  di,n

       cmp  byte ptr es:[di],4    {if n.places<4 then goto EXIT; }
       jb   EXIT

       cmp  word ptr number(es:[di]).frac , 1000
       jb   @L1                             { if (frac[1]>=1000)  then  }
       mov  byte ptr  es:[di],4                   { places:=4;  }
       mov  ax,  word ptr number(es:[di]).frac + 6
       mov  dx,0
       mov  bx,10
       div  bx                                        { r:=frac[4] mod 10;}
       sub  word ptr number(es:[di]).frac + 6 ,dx      {frac[4]:=frac[4]-r;}
       cmp  dx,5
       jb   EXIT                                      {if r>= 5 then }
       add  word ptr number(es:[di]).frac + 6 ,10     { frac[4]:=frac[4]+10; }
       jmp  @L5

     @L1:
       cmp  word ptr number(es:[di]).frac , 100
       jb   @L2                             { if (frac[1]>=100)  then  }
       mov  byte ptr  es:[di],4                   { places:=4;  }
       cmp  word ptr number(es:[di]).frac + 8,5000
       jb   EXIT                                    {if frac[5]>=5000 then }
       inc (word ptr number(es:[di]).frac + 6)      {inc(frac[4])}
       jmp  @L5                                          {else}


     @L2:
       cmp  byte ptr es:[di],5    {if n.places<5 then exit; }
       jb   EXIT
       mov  byte ptr  es:[di],5                   { places:=5;  }
       cmp  word ptr number(es:[di]).frac , 10
       jb   @L3                             { if (frac[1]>=10)  then  }
       mov  ax,  word ptr number(es:[di]).frac + 8
       mov  dx,0
       mov  bx,1000
       div  bx                                        { r:=frac[5] mod 1000;}
       sub  word ptr number(es:[di]).frac + 8 ,dx      {frac[5]:=frac[5]-r;}
       cmp  dx,500
       jb   EXIT                                      {if r>= 500 then }
       add  word ptr number(es:[di]).frac + 8 ,1000   { frac[5]:=frac[5]+1000; }
       jmp  @L5                                          {else}

     @L3:
       mov  ax,  word ptr number(es:[di]).frac + 8
       mov  dx,0
       mov  bx,100
       div  bx                                        { r:=frac[5] mod 100;}
       sub  word ptr number(es:[di]).frac + 8 ,dx      {frac[5]:=frac[5]-r;}
       cmp  dx,50
       jb   EXIT                                      {if r>= 50 then }
       add  word ptr number(es:[di]).frac + 8 ,100   { frac[5]:=frac[5]+100; }

     @L5:
   end;
   carryuptail(n);
 EXIT:
 shorten(n);
end;
*)

{$IFDEF CPU32}
function round16sub(var n:number):boolean;assembler;
  asm                 {eax}
       push edi
       mov  edi,n

       cmp  dword ptr [edi],1    {if n.places<=1 then goto @exit0; }
       jbe  @exit0

       cmp  dword ptr number([edi]).frac , 100000000
       jb   @L1                             { if (frac[1]>=100000000)  then  }
       mov  dword ptr  [edi],2                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+4
       mov  edx,0
       mov  ecx,100
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+4 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,50
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+4 ,100   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L1:

       cmp  dword ptr number([edi]).frac , 10000000
       jb   @L2                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],2                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+4
       mov  edx,0
       mov  ecx,10
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+4 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,5
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+4 ,10   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L2:

       cmp  dword ptr [edi],2    {if n.places<=2 then goto @exit0; }
       jbe  @exit0

       cmp  dword ptr number([edi]).frac , 1000000
       jb   @L3                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],2                   { places:=2;  }
       cmp  dword ptr number([edi]).frac+8,500000000
       jb   @exit0                                    {if frac[3]>=500000000 then }
       inc dword ptr number([edi]).frac+4           {inc(frac[2])}
       jmp  @L9

     @L3:

       cmp  dword ptr number([edi]).frac , 100000
       jb   @L4                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],3                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+8
       mov  edx,0
       mov  ecx,100000000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,50000000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+8 ,100000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L4:

       cmp  dword ptr number([edi]).frac , 10000
       jb   @L5                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],3                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+8
       mov  edx,0
       mov  ecx,10000000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,5000000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac + 8 ,10000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L5:

       cmp  dword ptr number([edi]).frac , 1000
       jb   @L6                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],3                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+8
       mov  edx,0
       mov  ecx,1000000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,500000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+8 ,1000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L6:

       cmp  dword ptr number([edi]).frac , 100
       jb   @L7                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],3                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+8
       mov  edx,0
       mov  ecx,100000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,50000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+8 ,100000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L7:
       cmp  dword ptr number([edi]).frac , 10
       jb   @L8                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],3                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+8
       mov  edx,0
       mov  ecx,10000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,5000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+8 ,10000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L8:
       mov  dword ptr  [edi],3                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+8
       mov  edx,0
       mov  ecx,1000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,500
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+8 ,1000   { frac[5]:=frac[5]+10; }
       {jmp  @L9 }                                         {else}

     @L9:
       mov  eax,1
       jmp  @exit
     @exit0:
       xor  eax,eax
     @exit:
       pop  edi
end;
{$ENDIF}
{$IFDEF CPU64}
function round16sub(var n:number):boolean;assembler;
  asm                 {rdi}

       cmp  dword ptr [rdi],1    {if n.places<=1 then goto @exit0; }
       jbe  @exit0

       cmp  dword ptr number([rdi]).frac , 100000000
       jb   @L1                             { if (frac[1]>=100000000)  then  }
       mov  dword ptr  [rdi],2                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+4
       mov  edx,0
       mov  ecx,100
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+4 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,50
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+4 ,100   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L1:

       cmp  dword ptr number([rdi]).frac , 10000000
       jb   @L2                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],2                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+4
       mov  edx,0
       mov  ecx,10
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+4 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,5
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+4 ,10   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L2:

       cmp  dword ptr [rdi],2    {if n.places<=2 then goto @exit0; }
       jbe  @exit0

       cmp  dword ptr number([rdi]).frac , 1000000
       jb   @L3                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],2                   { places:=2;  }
       cmp  dword ptr number([rdi]).frac+8,500000000
       jb   @exit0                                    {if frac[3]>=500000000 then }
       inc dword ptr number([rdi]).frac+4           {inc(frac[2])}
       jmp  @L9

     @L3:

       cmp  dword ptr number([rdi]).frac , 100000
       jb   @L4                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],3                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+8
       mov  edx,0
       mov  ecx,100000000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,50000000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+8 ,100000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L4:

       cmp  dword ptr number([rdi]).frac , 10000
       jb   @L5                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],3                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+8
       mov  edx,0
       mov  ecx,10000000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,5000000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac + 8 ,10000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L5:

       cmp  dword ptr number([rdi]).frac , 1000
       jb   @L6                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],3                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+8
       mov  edx,0
       mov  ecx,1000000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,500000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+8 ,1000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L6:

       cmp  dword ptr number([rdi]).frac , 100
       jb   @L7                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],3                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+8
       mov  edx,0
       mov  ecx,100000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,50000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+8 ,100000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L7:
       cmp  dword ptr number([rdi]).frac , 10
       jb   @L8                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],3                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+8
       mov  edx,0
       mov  ecx,10000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,5000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+8 ,10000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L8:
       mov  dword ptr  [rdi],3                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+8
       mov  edx,0
       mov  ecx,1000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,500
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+8 ,1000   { frac[5]:=frac[5]+10; }
       {jmp  @L9 }                                         {else}

     @L9:
       mov  eax,1
       jmp  @exit
     @exit0:
       xor  eax,eax
     @exit:
end;
{$ENDIF}


procedure round16( var n:number);
begin
   if round16sub(n) then
        carryuptail(n);
   shorten(n);
end;

{$IFDEF CPU32}
function round15sub(var n:number):boolean;assembler;
  asm
       push edi
       mov  edi,n

       cmp  dword ptr [edi],1    {if n.places<=1 then goto @exit0; }
       jbe  @exit0

       cmp  dword ptr number([edi]).frac , 100000000
       jb   @L1                             { if (frac[1]>=100000000)  then  }
       mov  dword ptr  [edi],2                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+4
       mov  edx,0
       mov  ecx,1000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+4 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,500
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+4 ,1000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L1:

       cmp  dword ptr number([edi]).frac , 10000000
       jb   @L2                             { if (frac[1]>=100000000)  then  }
       mov  dword ptr  [edi],2                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+4
       mov  edx,0
       mov  ecx,100
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+4 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,50
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+4 ,100   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L2:

       cmp  dword ptr number([edi]).frac , 1000000
       jb   @L3                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],2                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+4
       mov  edx,0
       mov  ecx,10
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+4 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,5
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+4 ,10   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L3:

       cmp  dword ptr [edi],2    {if n.places<=2 then goto @exit0; }
       jbe  @exit0

       cmp  dword ptr number([edi]).frac , 100000
       jb   @L4                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],2                   { places:=2;  }
       cmp  dword ptr number([edi]).frac+8,500000000
       jb   @exit0                                    {if frac[3]>=500000000 then }
       inc dword ptr number([edi]).frac+4           {inc(frac[2])}
       jmp  @L9

     @L4:

       cmp  dword ptr number([edi]).frac , 10000
       jb   @L5                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],3                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+8
       mov  edx,0
       mov  ecx,100000000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,50000000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+8 ,100000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L5:

       cmp  dword ptr number([edi]).frac , 1000
       jb   @L6                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],3                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+8
       mov  edx,0
       mov  ecx,10000000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,5000000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac + 8 ,10000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L6:

       cmp  dword ptr number([edi]).frac , 100
       jb   @L7                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],3                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+8
       mov  edx,0
       mov  ecx,1000000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,500000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+8 ,1000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L7:

       cmp  dword ptr number([edi]).frac , 10
       jb   @L8                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],3                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+8
       mov  edx,0
       mov  ecx,100000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,50000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+8 ,100000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L8:
       mov  dword ptr  [edi],3                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+8
       mov  edx,0
       mov  ecx,10000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,5000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+8 ,10000   { frac[5]:=frac[5]+10; }
       {jmp  @L9 }                                         {else}

     @L9:
       mov  eax,1
       jmp  @exit
     @exit0:
       xor  eax,eax
     @exit:
       pop  edi
end;
{$ENDIF}
{$IFDEF CPU64}
function round15sub(var n:number):boolean;assembler;
  asm                 {rdi}
       cmp  dword ptr [rdi],1    {if n.places<=1 then goto @exit0; }
       jbe  @exit0

       cmp  dword ptr number([rdi]).frac , 100000000
       jb   @L1                             { if (frac[1]>=100000000)  then  }
       mov  dword ptr  [rdi],2                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+4
       mov  edx,0
       mov  ecx,1000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+4 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,500
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+4 ,1000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L1:

       cmp  dword ptr number([rdi]).frac , 10000000
       jb   @L2                             { if (frac[1]>=100000000)  then  }
       mov  dword ptr  [rdi],2                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+4
       mov  edx,0
       mov  ecx,100
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+4 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,50
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+4 ,100   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L2:

       cmp  dword ptr number([rdi]).frac , 1000000
       jb   @L3                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],2                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+4
       mov  edx,0
       mov  ecx,10
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+4 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,5
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+4 ,10   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L3:

       cmp  dword ptr [rdi],2    {if n.places<=2 then goto @exit0; }
       jbe  @exit0

       cmp  dword ptr number([rdi]).frac , 100000
       jb   @L4                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],2                   { places:=2;  }
       cmp  dword ptr number([rdi]).frac+8,500000000
       jb   @exit0                                    {if frac[3]>=500000000 then }
       inc dword ptr number([rdi]).frac+4           {inc(frac[2])}
       jmp  @L9

     @L4:

       cmp  dword ptr number([rdi]).frac , 10000
       jb   @L5                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],3                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+8
       mov  edx,0
       mov  ecx,100000000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,50000000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+8 ,100000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L5:

       cmp  dword ptr number([rdi]).frac , 1000
       jb   @L6                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],3                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+8
       mov  edx,0
       mov  ecx,10000000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,5000000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac + 8 ,10000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L6:

       cmp  dword ptr number([rdi]).frac , 100
       jb   @L7                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],3                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+8
       mov  edx,0
       mov  ecx,1000000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,500000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+8 ,1000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L7:

       cmp  dword ptr number([rdi]).frac , 10
       jb   @L8                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],3                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+8
       mov  edx,0
       mov  ecx,100000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,50000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+8 ,100000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L8:
       mov  dword ptr  [rdi],3                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+8
       mov  edx,0
       mov  ecx,10000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,5000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+8 ,10000   { frac[5]:=frac[5]+10; }
       {jmp  @L9 }                                         {else}

     @L9:
       mov  eax,1
       jmp  @exit
     @exit0:
       xor  eax,eax
     @exit:
end;
{$ENDIF}


procedure round15( var n:number);
begin
   if round15sub(n) then
        carryuptail(n);
   shorten(n);
end;


{******}
{ROUND6}
{******}
{$IFDEF CPU32}
function round6sub(var n:number):boolean;assembler;
  asm
       push edi
       mov  edi,n

       cmp  dword ptr [edi],0    {if n.places<=1 then goto @exit0; }
       jbe  @exit0

       cmp  dword ptr number([edi]).frac , 100000000
       jb   @L1                             { if (frac[1]>=100000000)  then  }
       mov  dword ptr  [edi],1                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+0
       mov  edx,0
       mov  ecx,1000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+0 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,500
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+0 ,1000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L1:

       cmp  dword ptr number([edi]).frac , 10000000
       jb   @L2                             { if (frac[1]>=100000000)  then  }
       mov  dword ptr  [edi],1                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+0
       mov  edx,0
       mov  ecx,100
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+0 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,50
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+0 ,100   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L2:

       cmp  dword ptr number([edi]).frac , 1000000
       jb   @L3                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],1                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+0
       mov  edx,0
       mov  ecx,10
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+0 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,5
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+0 ,10   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L3:

       cmp  dword ptr [edi],1    {if n.places<=2 then goto @exit0; }
       jbe  @exit0

       cmp  dword ptr number([edi]).frac , 100000
       jb   @L4                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],1                   { places:=2;  }
       cmp  dword ptr number([edi]).frac+4,500000000
       jb   @exit0                                    {if frac[3]>=500000000 then }
       inc dword ptr number([edi]).frac+0           {inc(frac[2])}
       jmp  @L9

     @L4:

       cmp  dword ptr number([edi]).frac , 10000
       jb   @L5                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],2                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+4
       mov  edx,0
       mov  ecx,100000000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+4 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,50000000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+4 ,100000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L5:

       cmp  dword ptr number([edi]).frac , 1000
       jb   @L6                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],2                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+4
       mov  edx,0
       mov  ecx,10000000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+4 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,5000000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+4 ,10000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L6:

       cmp  dword ptr number([edi]).frac , 100
       jb   @L7                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],2                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+4
       mov  edx,0
       mov  ecx,1000000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+4 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,500000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+4 ,1000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L7:

       cmp  dword ptr number([edi]).frac , 10
       jb   @L8                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],2                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+4
       mov  edx,0
       mov  ecx,100000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+4 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,50000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+4 ,100000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L8:
       mov  dword ptr  [edi],2                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+4
       mov  edx,0
       mov  ecx,10000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+4 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,5000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+4 ,10000   { frac[5]:=frac[5]+10; }
       {jmp  @L9 }                                         {else}

     @L9:
       mov  eax,1
       jmp  @exit
     @exit0:
       xor  eax,eax
     @exit:
       pop  edi
end;
{$ENDIF}
 {$IFDEF CPU64}
function round6sub(var n:number):boolean;assembler;
asm                {rdi}
       cmp  dword ptr [rdi],0    {if n.places<=1 then goto @exit0; }
       jbe  @exit0

       cmp  dword ptr number([rdi]).frac , 100000000
       jb   @L1                             { if (frac[1]>=100000000)  then  }
       mov  dword ptr  [rdi],1                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+0
       mov  edx,0
       mov  ecx,1000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+0 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,500
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+0 ,1000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L1:

       cmp  dword ptr number([rdi]).frac , 10000000
       jb   @L2                             { if (frac[1]>=100000000)  then  }
       mov  dword ptr  [rdi],1                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+0
       mov  edx,0
       mov  ecx,100
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+0 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,50
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+0 ,100   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L2:

       cmp  dword ptr number([rdi]).frac , 1000000
       jb   @L3                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],1                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+0
       mov  edx,0
       mov  ecx,10
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+0 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,5
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+0 ,10   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L3:

       cmp  dword ptr [rdi],1    {if n.places<=2 then goto @exit0; }
       jbe  @exit0

       cmp  dword ptr number([rdi]).frac , 100000
       jb   @L4                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],1                   { places:=2;  }
       cmp  dword ptr number([rdi]).frac+4,500000000
       jb   @exit0                                    {if frac[3]>=500000000 then }
       inc dword ptr number([rdi]).frac+0           {inc(frac[2])}
       jmp  @L9

     @L4:

       cmp  dword ptr number([rdi]).frac , 10000
       jb   @L5                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],2                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+4
       mov  edx,0
       mov  ecx,100000000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+4 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,50000000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+4 ,100000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L5:

       cmp  dword ptr number([rdi]).frac , 1000
       jb   @L6                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],2                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+4
       mov  edx,0
       mov  ecx,10000000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+4 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,5000000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+4 ,10000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L6:

       cmp  dword ptr number([rdi]).frac , 100
       jb   @L7                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],2                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+4
       mov  edx,0
       mov  ecx,1000000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+4 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,500000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+4 ,1000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L7:

       cmp  dword ptr number([rdi]).frac , 10
       jb   @L8                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],2                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+4
       mov  edx,0
       mov  ecx,100000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+4 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,50000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+4 ,100000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L8:
       mov  dword ptr  [rdi],2                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+4
       mov  edx,0
       mov  ecx,10000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+4 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,5000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+4 ,10000   { frac[5]:=frac[5]+10; }
       {jmp  @L9 }                                         {else}

     @L9:
       mov  eax,1
       jmp  @exit
     @exit0:
       xor  eax,eax
     @exit:
end;
{$ENDIF}


procedure round6( var n:number);
begin
   if round6sub(n) then
        carryuptail(n);
   shorten(n);
end;

{$IFDEF CPU32}
function round9sub(var n:number):boolean;assembler;
  asm
       push edi
       mov  edi,n

       cmp  dword ptr [edi],1    {if n.places<=1 then goto @exit0; }
       jbe  @exit0

       cmp  dword ptr number([edi]).frac , 100000000
       jb   @L1                             { if (frac[1]>=100000000)  then  }
       mov  dword ptr  [edi],1                   { places:=1;  }
       cmp  dword ptr number([edi]).frac+4,500000000
       jb   @exit0                                    {if frac[2]>=500000000 then }
       inc dword ptr number([edi]).frac               {inc(frac[1])}
       jmp  @L9

     @L1:

       cmp  dword ptr number([edi]).frac , 10000000
       jb   @L2                                   { if (frac[1]>=10000000)  then  }
       mov  dword ptr  [edi],2                   { places:=2;  }
       mov  eax, dword ptr number([edi]).frac+4
       mov  edx,0
       mov  ecx,100000000
       div  ecx                                        { r:=frac[2] mod 100000000;}
       sub  dword ptr number([edi]).frac+4 ,edx      {frac[2]:=frac[2]-r;}
       cmp  edx,50000000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+4 ,100000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L2:

       cmp  dword ptr number([edi]).frac , 1000000
       jb   @L3                                   { if (frac[1]>=1000000)  then  }
       mov  dword ptr  [edi],2                   { places:=2;  }
       mov  eax, dword ptr number([edi]).frac+4
       mov  edx,0
       mov  ecx,10000000
       div  ecx                                        { r:=frac[2] mod 10000000;}
       sub  dword ptr number([edi]).frac+4 ,edx        {frac[2]:=frac[2]-r;}
       cmp  edx,5000000
       jb   @exit0                                      {if r>= 5000000 then }
       add  dword ptr number([edi]).frac + 4 ,10000000   { frac[2]:=frac[2]+10000000; }
       jmp  @L9

     @L3:

       cmp  dword ptr number([edi]).frac , 100000
       jb   @L4                                      { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],2                        { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+4
       mov  edx,0
       mov  ecx,1000000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+4 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,500000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+4 ,1000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L4:

       cmp  dword ptr number([edi]).frac , 10000
       jb   @L5                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],2                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+4
       mov  edx,0
       mov  ecx,100000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+4 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,50000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+4 ,100000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L5:

       cmp  dword ptr number([edi]).frac , 1000
       jb   @L6                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],2                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+4
       mov  edx,0
       mov  ecx,10000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+4 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,5000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+4 ,10000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L6:

       cmp  dword ptr number([edi]).frac , 100
       jb   @L7                                    { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],2                     { places:=2;  }
       mov  eax, dword ptr number([edi]).frac+4
       mov  edx,0
       mov  ecx,1000
       div  ecx                                      { r:=frac[2] mod 1000;}
       sub  dword ptr number([edi]).frac+4 ,edx      {frac[2]:=frac[2]-r;}
       cmp  edx,500
       jb   @exit0                                   {if r>= 500 then }
       add  dword ptr number([edi]).frac+4 ,1000     { frac[2]:=frac[2]+1000; }
       jmp  @L9

     @L7:
       cmp  dword ptr number([edi]).frac , 10
       jb   @L8                                     { if (frac[1]>=10)  then  }
       mov  dword ptr  [edi],2                      { places:=2;  }
       mov  eax, dword ptr number([edi]).frac+4
       mov  edx,0
       mov  ecx,100
       div  ecx                                      { r:=frac[2] mod 100;}
       sub  dword ptr number([edi]).frac+4 ,edx      {frac[2]:=frac[2]-r;}
       cmp  edx,50
       jb   @exit0                                   {if r>= 50 then }
       add  dword ptr number([edi]).frac+4 ,100        { frac[2]:=frac[2]+100; }
       jmp  @L9

     @L8:
       mov  dword ptr  [edi],2                      { places:=2;  }
       mov  eax, dword ptr number([edi]).frac+4
       mov  edx,0
       mov  ecx,10
       div  ecx                                      { r:=frac[2] mod 10;}
       sub  dword ptr number([edi]).frac+4 ,edx      {frac[2]:=frac[2]-r;}
       cmp  edx,5
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+4 ,10      { frac[2]:=frac[2]+10; }
       {jmp  @L9 }                                         {else}

     @L9:
       mov  eax,1
       jmp  @exit
     @exit0:
       xor  eax,eax
     @exit:
       pop  edi
end;
{$ENDIF}
{$IFDEF CPU64}
function round9sub(var n:number):boolean;assembler;
asm
       cmp  dword ptr [rdi],1    {if n.places<=1 then goto @exit0; }
       jbe  @exit0

       cmp  dword ptr number([rdi]).frac , 100000000
       jb   @L1                             { if (frac[1]>=100000000)  then  }
       mov  dword ptr  [rdi],1                   { places:=1;  }
       cmp  dword ptr number([rdi]).frac+4,500000000
       jb   @exit0                                    {if frac[2]>=500000000 then }
       inc dword ptr number([rdi]).frac               {inc(frac[1])}
       jmp  @L9

     @L1:

       cmp  dword ptr number([rdi]).frac , 10000000
       jb   @L2                                   { if (frac[1]>=10000000)  then  }
       mov  dword ptr  [rdi],2                   { places:=2;  }
       mov  eax, dword ptr number([rdi]).frac+4
       mov  edx,0
       mov  ecx,100000000
       div  ecx                                        { r:=frac[2] mod 100000000;}
       sub  dword ptr number([rdi]).frac+4 ,edx      {frac[2]:=frac[2]-r;}
       cmp  edx,50000000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+4 ,100000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L2:

       cmp  dword ptr number([rdi]).frac , 1000000
       jb   @L3                                   { if (frac[1]>=1000000)  then  }
       mov  dword ptr  [rdi],2                   { places:=2;  }
       mov  eax, dword ptr number([rdi]).frac+4
       mov  edx,0
       mov  ecx,10000000
       div  ecx                                        { r:=frac[2] mod 10000000;}
       sub  dword ptr number([rdi]).frac+4 ,edx        {frac[2]:=frac[2]-r;}
       cmp  edx,5000000
       jb   @exit0                                      {if r>= 5000000 then }
       add  dword ptr number([rdi]).frac + 4 ,10000000   { frac[2]:=frac[2]+10000000; }
       jmp  @L9

     @L3:

       cmp  dword ptr number([rdi]).frac , 100000
       jb   @L4                                      { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],2                        { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+4
       mov  edx,0
       mov  ecx,1000000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+4 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,500000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+4 ,1000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L4:

       cmp  dword ptr number([rdi]).frac , 10000
       jb   @L5                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],2                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+4
       mov  edx,0
       mov  ecx,100000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+4 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,50000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+4 ,100000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L5:

       cmp  dword ptr number([rdi]).frac , 1000
       jb   @L6                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],2                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+4
       mov  edx,0
       mov  ecx,10000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+4 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,5000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+4 ,10000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L6:

       cmp  dword ptr number([rdi]).frac , 100
       jb   @L7                                    { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],2                     { places:=2;  }
       mov  eax, dword ptr number([rdi]).frac+4
       mov  edx,0
       mov  ecx,1000
       div  ecx                                      { r:=frac[2] mod 1000;}
       sub  dword ptr number([rdi]).frac+4 ,edx      {frac[2]:=frac[2]-r;}
       cmp  edx,500
       jb   @exit0                                   {if r>= 500 then }
       add  dword ptr number([rdi]).frac+4 ,1000     { frac[2]:=frac[2]+1000; }
       jmp  @L9

     @L7:
       cmp  dword ptr number([rdi]).frac , 10
       jb   @L8                                     { if (frac[1]>=10)  then  }
       mov  dword ptr  [rdi],2                      { places:=2;  }
       mov  eax, dword ptr number([rdi]).frac+4
       mov  edx,0
       mov  ecx,100
       div  ecx                                      { r:=frac[2] mod 100;}
       sub  dword ptr number([rdi]).frac+4 ,edx      {frac[2]:=frac[2]-r;}
       cmp  edx,50
       jb   @exit0                                   {if r>= 50 then }
       add  dword ptr number([rdi]).frac+4 ,100        { frac[2]:=frac[2]+100; }
       jmp  @L9

     @L8:
       mov  dword ptr  [rdi],2                      { places:=2;  }
       mov  eax, dword ptr number([rdi]).frac+4
       mov  edx,0
       mov  ecx,10
       div  ecx                                      { r:=frac[2] mod 10;}
       sub  dword ptr number([rdi]).frac+4 ,edx      {frac[2]:=frac[2]-r;}
       cmp  edx,5
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+4 ,10      { frac[2]:=frac[2]+10; }
       {jmp  @L9 }                                         {else}

     @L9:
       mov  eax,1
       jmp  @exit
     @exit0:
       xor  eax,eax
     @exit:
end;
{$ENDIF}

procedure round9( var n:number);
begin
   if round9sub(n) then
        carryuptail(n);
   shorten(n);
end;


{$IFDEF CPU32}
function round18sub(var n:number):boolean;assembler;
  asm
       push edi
       mov  edi,n

       cmp  dword ptr [edi],2    {if n.places<=2 then goto @exit0; }
       jbe  @exit0

       cmp  dword ptr number([edi]).frac , 100000000
       jb   @L1                             { if (frac[1]>=100000000)  then  }
       mov  dword ptr  [edi],2                   { places:=2;  }
       cmp  dword ptr number([edi]).frac+8,500000000
       jb   @exit0                                    {if frac[3]>=500000000 then }
       inc dword ptr number([edi]).frac+4           {inc(frac[2])}
       jmp  @L9

     @L1:

       cmp  dword ptr number([edi]).frac , 10000000
       jb   @L2                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],3                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+8
       mov  edx,0
       mov  ecx,100000000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,50000000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+8 ,100000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L2:

       cmp  dword ptr number([edi]).frac , 1000000
       jb   @L3                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],3                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+8
       mov  edx,0
       mov  ecx,10000000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,5000000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac + 8 ,10000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L3:

       cmp  dword ptr number([edi]).frac , 100000
       jb   @L4                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],3                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+8
       mov  edx,0
       mov  ecx,1000000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,500000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+8 ,1000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L4:

       cmp  dword ptr number([edi]).frac , 10000
       jb   @L5                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],3                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+8
       mov  edx,0
       mov  ecx,100000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,50000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+8 ,100000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L5:

       cmp  dword ptr number([edi]).frac , 1000
       jb   @L6                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],3                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+8
       mov  edx,0
       mov  ecx,10000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,5000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+8 ,10000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L6:

       cmp  dword ptr number([edi]).frac , 100
       jb   @L7                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],3                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+8
       mov  edx,0
       mov  ecx,1000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,500
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+8 ,1000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L7:
       cmp  dword ptr number([edi]).frac , 10
       jb   @L8                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],3                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+8
       mov  edx,0
       mov  ecx,100
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,50
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+8 ,100   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L8:
       mov  dword ptr  [edi],3                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+8
       mov  edx,0
       mov  ecx,10
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,5
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+8 ,10   { frac[5]:=frac[5]+10; }
       {jmp  @L9 }                                         {else}

     @L9:
       mov  eax,1
       jmp  @exit
     @exit0:
       xor  eax,eax
     @exit:
       pop  edi
end;
{$ENDIF}
{$IFDEF CPU64}
function round18sub(var n:number):boolean;assembler;
asm
       cmp  dword ptr [rdi],2    {if n.places<=2 then goto @exit0; }
       jbe  @exit0

       cmp  dword ptr number([rdi]).frac , 100000000
       jb   @L1                             { if (frac[1]>=100000000)  then  }
       mov  dword ptr  [rdi],2                   { places:=2;  }
       cmp  dword ptr number([rdi]).frac+8,500000000
       jb   @exit0                                    {if frac[3]>=500000000 then }
       inc dword ptr number([rdi]).frac+4           {inc(frac[2])}
       jmp  @L9

     @L1:

       cmp  dword ptr number([rdi]).frac , 10000000
       jb   @L2                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],3                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+8
       mov  edx,0
       mov  ecx,100000000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,50000000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+8 ,100000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L2:

       cmp  dword ptr number([rdi]).frac , 1000000
       jb   @L3                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],3                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+8
       mov  edx,0
       mov  ecx,10000000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,5000000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac + 8 ,10000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L3:

       cmp  dword ptr number([rdi]).frac , 100000
       jb   @L4                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],3                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+8
       mov  edx,0
       mov  ecx,1000000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,500000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+8 ,1000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L4:

       cmp  dword ptr number([rdi]).frac , 10000
       jb   @L5                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],3                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+8
       mov  edx,0
       mov  ecx,100000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,50000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+8 ,100000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L5:

       cmp  dword ptr number([rdi]).frac , 1000
       jb   @L6                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],3                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+8
       mov  edx,0
       mov  ecx,10000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,5000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+8 ,10000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L6:

       cmp  dword ptr number([rdi]).frac , 100
       jb   @L7                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],3                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+8
       mov  edx,0
       mov  ecx,1000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,500
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+8 ,1000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L7:
       cmp  dword ptr number([rdi]).frac , 10
       jb   @L8                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],3                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+8
       mov  edx,0
       mov  ecx,100
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,50
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+8 ,100   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L8:
       mov  dword ptr  [rdi],3                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+8
       mov  edx,0
       mov  ecx,10
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,5
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+8 ,10   { frac[5]:=frac[5]+10; }
       {jmp  @L9 }                                         {else}

     @L9:
       mov  eax,1
       jmp  @exit
     @exit0:
       xor  eax,eax
     @exit:
end;
{$ENDIF}


procedure round18( var n:number);
begin
   if round18sub(n) then
        carryuptail(n);
   shorten(n);
end;

{$IFDEF CPU32}
function round18msub(var n:number):boolean;assembler;
  asm
       push edi
       mov  edi,n

       cmp  dword ptr [edi],1    {if n.places<=2 then goto @exit0; }
       jbe  @exit0

       cmp  dword ptr number([edi]).frac , 100000000
       jb   @L1                             { if (frac[1]>=100000000)  then  }
       mov  dword ptr  [edi],2                   { places:=2;  }
       mov  eax, dword ptr number([edi]).frac+4
       mov  edx,0
       mov  ecx,2
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+4 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,1
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+4 ,2        { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L1:

       cmp  dword ptr [edi],2    {if n.places<=2 then goto @exit0; }
       jbe  @exit0

       cmp  dword ptr number([edi]).frac , 10000000
       jb   @L2                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],3                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+8
       mov  edx,0
       mov  ecx,200000000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,100000000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+8 ,200000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L2:

       cmp  dword ptr number([edi]).frac , 1000000
       jb   @L3                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],3                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+8
       mov  edx,0
       mov  ecx,20000000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,10000000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac + 8 ,20000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L3:

       cmp  dword ptr number([edi]).frac , 100000
       jb   @L4                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],3                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+8
       mov  edx,0
       mov  ecx,2000000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,1000000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+8 ,2000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L4:

       cmp  dword ptr number([edi]).frac , 10000
       jb   @L5                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],3                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+8
       mov  edx,0
       mov  ecx,200000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,100000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+8 ,200000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L5:

       cmp  dword ptr number([edi]).frac , 1000
       jb   @L6                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],3                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+8
       mov  edx,0
       mov  ecx,20000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,10000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+8 ,20000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L6:

       cmp  dword ptr number([edi]).frac , 100
       jb   @L7                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],3                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+8
       mov  edx,0
       mov  ecx,2000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,1000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+8 ,2000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L7:
       cmp  dword ptr number([edi]).frac , 10
       jb   @L8                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],3                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+8
       mov  edx,0
       mov  ecx,200
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,100
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+8 ,200   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L8:
       mov  dword ptr  [edi],3                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+8
       mov  edx,0
       mov  ecx,20
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,10
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+8 ,20   { frac[5]:=frac[5]+10; }
       {jmp  @L9 }                                         {else}

     @L9:
       mov  eax,1
       jmp  @exit
     @exit0:
       xor  eax,eax
     @exit:
       pop  edi
end;
{$ENDIF}
{$IFDEF CPU64}
function round18msub(var n:number):boolean;assembler;
  asm
       cmp  dword ptr [rdi],1    {if n.places<=2 then goto @exit0; }
       jbe  @exit0

       cmp  dword ptr number([rdi]).frac , 100000000
       jb   @L1                             { if (frac[1]>=100000000)  then  }
       mov  dword ptr  [rdi],2                   { places:=2;  }
       mov  eax, dword ptr number([rdi]).frac+4
       mov  edx,0
       mov  ecx,2
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+4 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,1
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+4 ,2        { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L1:

       cmp  dword ptr [rdi],2    {if n.places<=2 then goto @exit0; }
       jbe  @exit0

       cmp  dword ptr number([rdi]).frac , 10000000
       jb   @L2                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],3                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+8
       mov  edx,0
       mov  ecx,200000000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,100000000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+8 ,200000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L2:

       cmp  dword ptr number([rdi]).frac , 1000000
       jb   @L3                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],3                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+8
       mov  edx,0
       mov  ecx,20000000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,10000000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac + 8 ,20000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L3:

       cmp  dword ptr number([rdi]).frac , 100000
       jb   @L4                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],3                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+8
       mov  edx,0
       mov  ecx,2000000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,1000000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+8 ,2000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L4:

       cmp  dword ptr number([rdi]).frac , 10000
       jb   @L5                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],3                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+8
       mov  edx,0
       mov  ecx,200000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,100000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+8 ,200000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L5:

       cmp  dword ptr number([rdi]).frac , 1000
       jb   @L6                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],3                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+8
       mov  edx,0
       mov  ecx,20000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,10000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+8 ,20000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L6:

       cmp  dword ptr number([rdi]).frac , 100
       jb   @L7                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],3                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+8
       mov  edx,0
       mov  ecx,2000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,1000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+8 ,2000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L7:
       cmp  dword ptr number([rdi]).frac , 10
       jb   @L8                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],3                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+8
       mov  edx,0
       mov  ecx,200
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,100
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+8 ,200   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L8:
       mov  dword ptr  [rdi],3                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+8
       mov  edx,0
       mov  ecx,20
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,10
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+8 ,20   { frac[5]:=frac[5]+10; }
       {jmp  @L9 }                                         {else}

     @L9:
       mov  eax,1
       jmp  @exit
     @exit0:
       xor  eax,eax
     @exit:
end;
{$ENDIF}

procedure round18m( var n:number);
begin
   if round18msub(n) then
        carryuptail(n);
   shorten(n);
end;

{$IFDEF CPU32}
function round17msub(var n:number):boolean;assembler;
  asm
       push edi
       mov  edi,n

       cmp  dword ptr [edi],1    {if n.places<=2 then goto @exit0; }
       jbe  @exit0

       cmp  dword ptr number([edi]).frac , 100000000
       jb   @L1                             { if (frac[1]>=100000000)  then  }
       mov  dword ptr  [edi],2                   { places:=2;  }
       mov  eax, dword ptr number([edi]).frac+4
       mov  edx,0
       mov  ecx,20
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+4 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,10
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+4 ,20        { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L1:

       cmp  dword ptr number([edi]).frac , 10000000
       jb   @L2                             { if (frac[1]>=100000000)  then  }
       mov  dword ptr  [edi],2                   { places:=2;  }
       mov  eax, dword ptr number([edi]).frac+4
       mov  edx,0
       mov  ecx,2
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+4 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,1
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+4 ,2        { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L2:
       cmp  dword ptr [edi],2    {if n.places<=2 then goto @exit0; }
       jbe  @exit0


       cmp  dword ptr number([edi]).frac , 1000000
       jb   @L3                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],3                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+8
       mov  edx,0
       mov  ecx,200000000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,100000000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac + 8 ,200000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L3:

       cmp  dword ptr number([edi]).frac , 100000
       jb   @L4                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],3                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+8
       mov  edx,0
       mov  ecx,20000000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,10000000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+8 ,20000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L4:

       cmp  dword ptr number([edi]).frac , 10000
       jb   @L5                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],3                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+8
       mov  edx,0
       mov  ecx,2000000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,1000000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+8 ,2000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L5:

       cmp  dword ptr number([edi]).frac , 1000
       jb   @L6                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],3                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+8
       mov  edx,0
       mov  ecx,200000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,100000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+8 ,200000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L6:

       cmp  dword ptr number([edi]).frac , 100
       jb   @L7                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],3                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+8
       mov  edx,0
       mov  ecx,20000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,10000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+8 ,20000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L7:
       cmp  dword ptr number([edi]).frac , 10
       jb   @L8                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [edi],3                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+8
       mov  edx,0
       mov  ecx,2000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,1000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+8 ,2000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L8:
       mov  dword ptr  [edi],3                   { places:=5;  }
       mov  eax, dword ptr number([edi]).frac+8
       mov  edx,0
       mov  ecx,200
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([edi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,100
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([edi]).frac+8 ,200   { frac[5]:=frac[5]+10; }
       {jmp  @L9 }                                         {else}

     @L9:
       mov  eax,1
       jmp  @exit
     @exit0:
       xor  eax,eax
     @exit:
       pop  edi
end;
{$ENDIF}
{$IFDEF CPU64}
function round17msub(var n:number):boolean;assembler;
asm
       cmp  dword ptr [rdi],1    {if n.places<=2 then goto @exit0; }
       jbe  @exit0

       cmp  dword ptr number([rdi]).frac , 100000000
       jb   @L1                             { if (frac[1]>=100000000)  then  }
       mov  dword ptr  [rdi],2                   { places:=2;  }
       mov  eax, dword ptr number([rdi]).frac+4
       mov  edx,0
       mov  ecx,20
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+4 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,10
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+4 ,20        { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L1:

       cmp  dword ptr number([rdi]).frac , 10000000
       jb   @L2                             { if (frac[1]>=100000000)  then  }
       mov  dword ptr  [rdi],2                   { places:=2;  }
       mov  eax, dword ptr number([rdi]).frac+4
       mov  edx,0
       mov  ecx,2
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+4 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,1
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+4 ,2        { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L2:
       cmp  dword ptr [rdi],2    {if n.places<=2 then goto @exit0; }
       jbe  @exit0


       cmp  dword ptr number([rdi]).frac , 1000000
       jb   @L3                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],3                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+8
       mov  edx,0
       mov  ecx,200000000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,100000000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac + 8 ,200000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L3:

       cmp  dword ptr number([rdi]).frac , 100000
       jb   @L4                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],3                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+8
       mov  edx,0
       mov  ecx,20000000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,10000000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+8 ,20000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L4:

       cmp  dword ptr number([rdi]).frac , 10000
       jb   @L5                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],3                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+8
       mov  edx,0
       mov  ecx,2000000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,1000000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+8 ,2000000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L5:

       cmp  dword ptr number([rdi]).frac , 1000
       jb   @L6                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],3                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+8
       mov  edx,0
       mov  ecx,200000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,100000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+8 ,200000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L6:

       cmp  dword ptr number([rdi]).frac , 100
       jb   @L7                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],3                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+8
       mov  edx,0
       mov  ecx,20000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,10000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+8 ,20000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L7:
       cmp  dword ptr number([rdi]).frac , 10
       jb   @L8                                   { if (frac[1]>=100)  then  }
       mov  dword ptr  [rdi],3                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+8
       mov  edx,0
       mov  ecx,2000
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,1000
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+8 ,2000   { frac[5]:=frac[5]+10; }
       jmp  @L9

     @L8:
       mov  dword ptr  [rdi],3                   { places:=5;  }
       mov  eax, dword ptr number([rdi]).frac+8
       mov  edx,0
       mov  ecx,200
       div  ecx                                        { r:=frac[5] mod 10;}
       sub  dword ptr number([rdi]).frac+8 ,edx      {frac[5]:=frac[5]-r;}
       cmp  edx,100
       jb   @exit0                                      {if r>= 5 then }
       add  dword ptr number([rdi]).frac+8 ,200   { frac[5]:=frac[5]+10; }
       {jmp  @L9 }                                         {else}

     @L9:
       mov  eax,1
       jmp  @exit
     @exit0:
       xor  eax,eax
     @exit:
end;
{$ENDIF}

procedure round17m( var n:number);
begin
   if round17msub(n) then
        carryuptail(n);
   shorten(n);
end;


procedure roundprecision(var n:number);
begin
  with n do
     if places<=precision then
           exit
     else
        begin
           n.places:=precision;
           if frac[precision+1]>=500000000 then
                  RoundUp(n);
        end;
end;

procedure NoRound(var n:number);
begin
end;


procedure checkRangeDecimal(var n:number; extyp:integer);
var
    sign:shortint;
begin
    sign:=n.sign;
    if sign=0 then exit;
    if (n.expn>=maxexpndecimal) and (compareabs(n,MAXNUM^)>0) then
            begin
               setexception(extyp);
               n.init(MAXNUM);
               n.sign:=sign;
            end
     else if (n.expn<minExpnDecimal) then
            n.initzero;
end;

var
    RoundConv,RoundVari:roundprocedure;

procedure RoundVariable(var n:number);
begin
    Roundvari(n);
    checkrangedecimal(n,1002);
end;

procedure RoundConvert(var n:number; extyp:integer);
begin
    Roundconv(n);
    checkrangedecimal(n,extyp);
end;

{********}
{Integers}
{********}

procedure intround(var n:number);     {round to integer}   // 2014.12.27 修正
var
   svPlaces: LongInt;
begin
   if n.sign=0 then exit;
   with n do
      begin
         if expn<0 then
            n.initzero
         else if expn=0 then
            if n.sign>0 then
              if frac[1]<500000000 then
                 n.initzero
              else
                 n.init(one)
            else
              if (frac[1]<500000000) or ((frac[1]=500000000) and (places=1))  then
                 n.initzero
              else
                 begin n.init(one);n.sign:=-1 end
         else if expn<places then
            begin
               svPlaces:=places;
               places:=expn;
               if n.sign>0 then
                  begin
                     if frac[expn+1]>=500000000 then
                                       RoundUp(n);

                  end
               else
                  begin
                     if (frac[expn+1]>500000000) or (frac[expn+1]=500000000) and (svPlaces>expn+1) then
                                       RoundUp(n);
                  end;
               shorten(n);
            end;
      end;
end;





function LongintVal(var a:number; var c:integer):longint;
var
   a1 :number;
   e  :smallint;
   x  :longint;

begin
 a1.init(@a);
 intround(a1);
 with a1 do
    begin
      c:=0;
      x:=0;
      case sign of
       0: ;
       1: for e:=1 to expn do
                begin
                    if (x>0) and (x<=2) then
                       x:=x*1000000000
                    else if x<>0 then
                       c:=sign;
                    if e<=places then
                       x:=x+frac[e];
                    if x<0 then
                        c:=sign;
                end;
       -1: for e:=1 to expn do
                begin
                    if (x<0) and (x>=-2) then
                       x:=x*1000000000
                    else if x<>0 then
                       c:=sign;
                    if e<=places then
                       x:=x-frac[e];
                    if x>=0 then
                        c:=sign;
                end;
      end;
      longintval:=x;
    end;
end;

function wordVal(var a:number; var c:integer):word;
var
   x  :longint;
begin
   x:=LongintVal(a,c);
   if x<0 then
      c:=-1
   else if x>$FFFF then
       c:=1
   else
       wordval:=x;
end;

{***********}
{type Number}
{***********}

function isZero(n:PNumber):boolean;
begin
   iszero:=(n^.sign=0)
end;

function sgn(n:Pnumber):integer;
begin
     sgn:=n^.sign
end;

procedure opposite(var n:Number);
begin
    with n do sign:=-sign;
end;

procedure oppose(var n:Number);
begin
    with n do sign:=-sign;
end;

procedure absolute(var n:number);
begin
    with n do if sign<>0 then sign:=1;
end;

procedure intpart(var n:number);
begin
  with n do
      begin
        if sign<>0 then
           if expn<=0 then
              initzero
           else if expn<places then
              places:=expn;
      end;
end;

procedure  fractpart(var n:number);
var
   m:number;
begin
   m:=n;
   intpart(m);
   sbt(n,m,n);
end;

procedure  BasicInt(var n:number);
var
    m:number;
begin
    if n.sign>=0 then
       intpart(n)
    else
       begin
            m:=n;
            intpart(m);
            if compare(m,n)=0 then
               n:=m
            else
               sbt(m,one^,n)
       end;
end;

procedure ceil(var n:number);
begin
    oppose(n);
    BasicInt(n);
    oppose(n);
end;

procedure  BasicMod(var a,b:Number; var x:Number);
begin
    remainder(a,b,x);
    if (a.sign=b.sign) or (x.sign=0) then
    else
    add(x,b,x)
end;


function isinteger(var n:number):boolean;
begin
   with n do
      if (sign=0) or (places<=expn) then
         isinteger:=true
      else
         isinteger:=false
end;


function nearly1(var n:number):boolean;
begin
 nearly1:=
       ((n.expn=1) and (n.frac[1]=1) and ((n.places=1)or(n.frac[2]<100000000))
        or (n.expn=0) and (n.frac[1]>900000000))
end;

{
function nearly1(var n:number):boolean;
begin
 nearly1:=
       ((n.expn=1) and (n.frac[1]=1) and ((n.places=1)or(n.frac[2]<=100000000))
        or (n.expn=0) and (n.frac[1]>=900000000))
end;
}
{
function nearly1(var n:number):boolean;
begin
 nearly1:=
       ((n.expn=1) and (n.frac[1]=1) and ((n.places=1)or(n.frac[2]<=292893218))
        or (n.expn=0) and (n.frac[1]>=707106782 ))
end;
}

{*****}
{power}
{*****}

procedure IncremPowerLongint(var a:Number; b:longint; var x:Number);    //2010.3.28
var
   svlimit:LongInt;
   bb:longint;
   y,xx:number;
label
   L1;
begin
    svlimit:=limit;
    limit:=mini(limit + 2 ,maxplace-1);
    try
      xx.initone;
      if b=0 then goto L1;
      y.init(@a);
      if b>0 then
         begin
            while b<>0 do
                begin
                   if b mod 2<>0 then mlt(xx,y,xx);
                   b:=b div 2;
                   if b<>0 then mlt(y,y,y);
                end;
         end
      else
        if iszero(@a) then
           setexception(3003)
        else
           try
              while b<>0 do
                  begin
                     if b mod 2<>0 then mlt(xx,y,xx);
                     b:=b div 2;
                     if b<>0 then mlt(y,y,y);
                  end;
              qtt(one^,xx,xx);     {y:=1/y}
           except
           on E:EExtype do
             if extype=1002 then
                begin
                  extype:=0;
                  xx.initzero;
                end
             else if extype=3001 then
                setexception(1002)
             else
                raise E;
           end;
    L1:
      x.init(@xx);
    finally
      limit:=svlimit;
    end;
end;



procedure IncremPowerComp(var a:Number; b:comp; var x:Number);     //2010.3.28
var
   svlimit:LongInt;
   y,xx:number;
   c:comp;
begin
    svlimit:=limit;
    limit:=mini(limit + 2 ,maxplace-1);
    try
        xx.initone;
        y.init(@a);
        if b>0 then
           begin
              while b<>0 do
                  begin
                     c:=system.int(b/2);
                     if b-2*c<>0 then mlt(xx,y,xx);
                     b:=c;
                     if b<>0 then mlt(y,y,y);
                  end;
           end
        else if b<0 then
           try
              while b<>0 do
                  begin
                     c:=system.int(b/2);
                     if b-2*c<>0 then mlt(xx,y,xx);
                     b:=c;
                     if b<>0 then mlt(y,y,y);
                  end;
               qtt(one^,xx,xx);     {y:=1/y}
           except
             on E:EExtype do
               if extype=1002 then
                  begin
                    extype:=0;
                    xx.initzero;
                  end
               else if extype=3001 then
                  setexception(1002)
               else
                  raise E;
           end;
        x.init(@xx);
    finally
        limit:=svlimit;
    end;
end;




procedure intpower(var a,b:number; var n:number);
var
   i:longint;
   c:integer;
   ii:comp;
begin


   if isinteger(b) then
      begin
        i:=LongintVal(b,c);
        if c=0 then
           begin
             IncremPowerLongint(a,i,n);
             exit
           end
        else
           begin
               c:=0;
               try
                  ii:=extendedVal(b);
               except
                  c:=1
               end;
               if c=0 then
                  begin
                    IncremPowerComp(a,ii,n);
                    exit
                  end;
           end;
      end;

   if UseTranscendentalFunction then
         power(a,b,n)
   else
         setexceptionwith(s_PowerIndex,1000);       //2010.3.28
end;

procedure incrempower(var a:Number; b:LongInt; var x:Number);
                                  {assume b>=0}
var
   n:number;
   z:number;
begin
    z.initone;
    n.init(@a);
    while b<>0 do
         begin
            if b mod 2 <>0 then mlt(z,n,z);
            b:=b div 2;
            if b<>0 then mlt(n,n,n);
         end;
   x.init(@z);
end;


{***********}
{type Number}
{***********}





{**********}
{arithmetic}
{**********}




procedure initinteger(var n:number; i:smallint);
begin
   n.initzero;
   if i=0 then exit;
   if i>0 then
      n.sign:=1
   else if i<0 then
      begin
         i:=-i;
         n.sign:=-1
      end;
   n.places:=1;
   n.expn:=1;
   n.frac[1]:=i;
end;

{$IFDEF CPU32}
procedure div1000000000(i:integer; var a,b:integer);assembler;
                   //   eax,         edx,ecx
asm
   push edx
   push ecx
   mov  edx,0
   mov  ecx,1000000000
   div  ecx
   pop  ecx
   mov  [ecx], edx
   pop  edx
   mov  [edx] ,eax
end;
{$ENDIF}
{$IFDEF CPU64}
procedure div1000000000(i:integer; var a,b:integer);assembler;
                   //  rdi,         rsi,rdx
asm
   mov  eax,edi{i}
   mov  rdi,rdx{b}
   mov  edx,0
   mov  ecx,1000000000
   div  ecx
   mov  [rdi], edx
   mov  [rsi] ,eax
end;
{$ENDIF}

procedure initlongint(var n:number; i:longint);
var
   a,b:integer;
begin
   n.initzero;
   if i=0 then exit;
   if i>0 then
      n.sign:=1
   else if i<0 then
      begin
         i:=-i;
         n.sign:=-1
      end;

   Div1000000000(i,a,b);
    // a:=i div 1000000000;
    // b:=i mod 1000000000;

  if a>0 then
      begin
          n.places:=2;
          n.expn:=2;
          n.frac[1]:=a;
          n.frac[2]:=b;
      end
  else
       begin
          n.places:=1;
          n.expn:=1;
          n.frac[1]:=b;
       end
end;

{*************}
{ EPS function}
{*************}

procedure EpsNative(var n:number);
begin
  with n do
       begin
           if iszero(@n) then
                 begin  frac[1]:=1 ; expn:=minExpnDecimal end
           else
                 begin
                    frac[1]:=1;
                    dec(expn,precision-1);
                 end;
           places:=1;
           sign:=1;
           if expn<minexpnDecimal then
                        begin
                            n.initzero;
                            EpsNative(n);
                        end;
       end;
end;

procedure EpsDecimal(var n:number);    {15digits}
begin
  with n do
       begin
           if iszero(@n) then
                 begin  frac[1]:=1 ; expn:=minExpnDecimal end
           else
                 begin
                      roundvariable(n);
                      if frac[1]>=100000000 then
                         begin
                             frac[1]:=1000;
                             dec(expn,1)
                         end
                      else if frac[1]>=10000000 then
                         begin
                             frac[1]:=100;
                             dec(expn,1)
                         end
                      else if frac[1]>=1000000 then
                         begin
                             frac[1]:=10;
                             dec(expn,1)
                         end
                      else if frac[1]>=100000 then
                         begin
                             frac[1]:=1;
                             dec(expn,1)
                         end
                      else if frac[1]>=10000 then
                         begin
                             frac[1]:=100000000;
                             dec(expn,2)
                         end
                      else if frac[1]>=1000 then
                         begin
                             frac[1]:=10000000;
                             dec(expn,2)
                         end
                      else if frac[1]>=100 then
                         begin
                             frac[1]:=1000000;
                             dec(expn,2)
                         end
                      else if frac[1]>=10 then
                         begin
                             frac[1]:=100000;
                             dec(expn,2)
                         end
                      else
                         begin
                            frac[1]:=10000;
                            dec(expn,2)
                         end;
                 end    ;
           places:=1;
           sign:=1;
           if expn<minexpnDecimal then
                        begin
                            n.initzero;
                            EpsDecimal(n);
                        end;
       end;
end;

procedure  min(var a,b:number; var n:number);
begin
     if compare(a,b)<=0 then n:=a else n:=b;
end;

procedure  max(var a,b:number; var n:number);
begin
     if compare(a,b)>=0 then n:=a else n:=b  ;
end;

procedure  tenfold(var x:number ; n:integer);
var
   i:integer;
begin
   if n>0 then
      for i:=1 to n do mlt(x,ten^,x)
   else if n<0 then
      for i:=-1 downto n do qtt(x,ten^,x)
end;



procedure  round(var x,n:number; var y:number);
var
   i:integer;
   c:integer;
   t:number;
begin
   i:=longintval(n,c);
   t.init(@x);
   tenfold(t,i);
   add(t,half^,y);
   BasicInt(y);
   tenfold(y,-i);
end;

procedure  truncate(var x,n:number; var y:number);
var
   i:integer;
   c:integer;
   t:number;
begin
   i:=longintval(n,c);
   t.init(@x);
   tenfold(t,i);
   y:=t;
   IntPart(y);
   tenfold(y,-i);
end;

{***********}
{square root}
{***********}

procedure sqrsub(var a:number);
var
   x,y,z:number;
   e:integer;
   limitsave:LongInt;
begin
  limitsave:=limit;
  convert(sqrt(extendedval(a)),y);
  limit:=4;
   repeat
      x.init(@y);
      qtt(a,x,y);
      add(y,x,y);
      qtt2(y);
      sbt(x,y,z);
      e:=y.expn-z.expn;
      limit:=mini(2*e+3,maxplace-1);
   until (z.sign=0) or (e>precision) ;
   limit:=maxplace-1;
   repeat
      x.init(@y);
      qtt(a,x,y);
      add(y,x,y);
      qtt2(y);
      sbt(x,y,z);
      e:=y.expn-z.expn;
   until (z.sign=0) or (e>precision) ;
   a.init(@y);
   limit:=limitsave;
end;

procedure sqrlong(var a:number);
var
   e:smallint;
begin
   if a.sign<0 then
        setexceptionwith(s_InvalidArgInSQR,3005)
   else if a.sign=0 then
   else
       begin
          e:=a.expn;
          a.expn:=e and 1;
          asm
             sar e,1
          end;
          sqrsub(a);
          a.expn:=a.expn+e;
       end;
end;

procedure square(var n:number);
begin
    mlt(n,n,n)
end;


{**********************}
{numeric representation}
{**********************}

{**********************}
{numeric representation}
{**********************}

procedure  NumericRep(var n:number;var code:integer;var line:ansistring;
                                                              var cp:integer);

var
      cpintpart,cpfractpart,cpexrad:integer;
      intpartlen,fractpartlen,exradlen:integer;
      scaledrep:boolean;

    procedure giveValue(var n:number; var code:integer);
    var
       intpart    :ansistring;
       fractpart  :ansistring;
       exrad      :ansistring;
        {i:smallint; }
        x:LongInt;
        m:number;
        c:integer;
    begin
          extype:=0; {this routine is used on phase 0, so extype may <>0}

          intpart  :=copy(line,cpintpart,  intpartlen);
          fractpart:=copy(line,cpfractpart,fractpartlen);
          exrad    :=copy(line,cpexrad,    exradlen);

          if (intpartlen=0) and (fractpartlen=0) then code:=8101;

          {give a value}

           {eliminate and append leading zeros}

           while (length(intpart)>0)and (intpart[1]='0')  do
                   delete(intpart,1,1){intpart:=copy(intpart,2,255)};
           if length(intpart) mod 9 <>0 then
              intpart:=copy('00000000',1,(9 - length(intpart) mod 9)) + intpart;
           if length(fractpart) mod 9 <>0 then
              fractpart:=fractpart + copy('00000000',1,(9-length(fractpart) mod 9));
           if length(intpart)>0 then
              n.expn:=length(intpart) div 9
           else
              begin
                 n.expn:=0;
                 while copy(fractpart,1,9)='000000000' do
                       begin
                            delete(fractpart,1,9){fractpart:=copy(fractpart,10,255)};
                            dec(n.expn);
                       end;
              end;

          fractpart:=intpart + fractpart;   {fractpart means efficient digits.}

          if fractpart='' then
             n.sign:=0
          else
             n.sign:=1;

          n.places:=0;
          while (fractpart<>'') and (n.places<limit)do
              begin
                 inc(n.places);
                 intpart:=copy(fractpart,1,9);  {intpart is used as temporary string.}
                 delete(fractpart,1,9){fractpart:=copy(fractpart,10,255)};
                 val(intpart,x,c);
                 if c<>0 then code:=1001;
                 n.frac[n.places]:=x
              end;

          if length(exrad)>0 then
              begin
                  val(exrad,x,c);
                  if (c<>0) or (x>maxExpn*9+1) then
                      code:=1001
                  else if (x<minExpn*9) then
                      begin
                          //code:=1501;   {下位桁あふれ}
                          n.initzero
                      end
                  else
                      if x>0 then
                            begin
                                incrempower(ten^,x,m);
                                mlt(n,m,n)
                            end
                         else
                            begin
                                incrempower(ten^,-x,m) ;
                                qtt(n,m,n)
                            end;
              end;
          n.tag:=1;                                             //ver.8.1.3.1
    end;


   function isDigit:boolean;
   begin
       case line[cp] of
           '0'..'9':
              isDigit:=true
            else
              isDigit:=false
       end
   end;

var
   numrep:ansistring{string[31]};

begin
      code:=0;

      while (cp<=length(line)) and (line[cp]=' ') do inc(cp); {spacecut}

      {intPart}
      cpintpart:=cp;
      while (cp<=length(line)) and isDigit do inc(cp);
      intpartlen:=cp-cpintpart;

      {fractpart}
      if (cp<=length(line)) and (line[cp]='.') then inc(cp);
      cpfractpart:=cp;
      while (cp<=length(line)) and isDigit do inc(cp);
      fractpartlen:=cp-cpfractpart;

      {exrad}
      if (cp+1<=length(line)) and (line[cp] in ['E','e'])
                              and (line[cp+1] in ['+','-','0'..'9']) then
         begin
            inc(cp);
            cpExrad:=cp;
            if (cp<=length(line)) and((line[cp]='+') or (line[cp]='-')) then
                                                                    inc(cp);
            while (cp<=length(line)) and isDigit do inc(cp);
            exradlen:=cp-cpexrad;
            scaledrep:=true;
          end
      else
          begin
             cpExrad:=cp;
             exradlen:=0;
             scaledrep:=false;
          end;


      numrep:=copy(line,cpintpart,cp-cpintpart);

      givevalue(n,code);
      shorten(n);
end;

procedure NVal(s:ansistring; var n:number);
var
   c,cp:integer;
   m:boolean;
begin
   cp:=1;
   while (cp<=length(s)) and (s[cp]=' ') do inc(cp);
   m:=false;
   if (cp<=length(s)) then
     begin
        if s[cp]='+' then
           inc(cp)
        else if (s[cp]='-') then
        begin
           m:=true;
           inc(cp)
        end;
     end;
   NumericRep(n,c,s,cp) ;
   if c<>0 then setexception(c);
   if m then oppose(n);
   while (cp<=length(s)) and (s[cp]=' ') do inc(cp);
   if cp<=length(s) then setexception(4001);
end;


procedure subst(var p:PNumber; var n:number);
begin
   if p=nil then
        MemoryGet(pointer(p), (n.places)*4+8)
   else if (p^.places<>n.places) then
      begin
        disposeNumber(p);
        MemoryGet(pointer(p), (n.places)*4+8);
      end;
   p^.init(@n)

end;




procedure ConvertToString(const n:number;var digits:ansistring;var exp:integer);
var
   s:string[9];
   i:integer;
begin
   digits:='';
   i:=1;
   while i<=n.places do
         begin
              str(n.frac[i],s);
              while length(s)<9 do s:='0' + s;
              digits:=digits + s;
              inc(i);
         end;

   if n.sign=0 then
       exp:=0
   else
       exp:=9*n.expn;
   i:=1;
   while (i<=length(digits)) and (digits[i]='0') do
                                            begin inc(i); dec(exp) end;
   delete(digits,1,i-1) {digits:=copy(digits,i,255)} ;
   while (length(digits)>0) and (digits[length(digits)]='0') do
                                       setlength(digits,length(digits)-1);
end;

procedure roundstring(var s:ansistring; n:integer; var exp:integer);
var
    carry:boolean;
    t:char;
begin
    if n<0 then begin s:='';  exit end;

    if length(s)>n then
       begin
           t:=s[n+1];
           setlength(s,n);
           if t>='5' then
              begin
                 carry:=true;
                 while carry and (length(s)>0) do
                 begin
                     s[length(s)]:=succ(s[length(s)]);
                     if s[length(s)]<='9' then
                        carry:=false
                     else
                        setlength(s,length(s)-1);
                 end;
                 if length(s)=0 then
                    begin
                        s:='1';
                        inc(exp)
                    end;
              end;
       end;

    while (length(s)>0) and (s[length(s)]='0') do
                                       setlength(s,length(s)-1);
end;


function DStr(var n:Number):ansistring;
var
     sign    :string[1];
     digits  :ansistring;
     exp     :integer;
     exrad   :ansistring;
     e     :integer;
begin
   {roundvariable(n);}
   if n.sign=0 then begin Dstr:=' 0' ; exit end;
   if n.sign>=0 then sign:=' ' else sign:='-';
   ConvertToString(n,digits,exp);
   roundstring(digits,signiwidth,exp);

   if (exp>0) and (exp<=signiwidth) then
      begin
         if exp>=length(digits) then        {wothout fraction part}
            begin
               while length(digits)<exp do digits:=digits + '0';
               Dstr:=sign + digits;
            end
         else
             begin
                Dstr:=sign + copy(digits,1,exp) + '.' +copy(digits,exp+1,maxint{255});
             end
      end
   else if (exp<=0) and ((length(digits)-exp<=signiwidth)) then
      begin
          e:=exp;
          while e<0 do
                    begin
                        digits:='0' + digits;
                        inc(e);
                    end;
          Dstr:=sign + '.' + digits;
      end
   else
      begin
          str(exp-1,exrad);
          if exp-1>0 then exrad:='+'+exrad;    //2021.12.30
          Dstr:=sign + copy(digits,1,1) + '.' + copy(digits,2,maxint{255})
                                        + 'E' +exrad;
      end;
end;


procedure disposenumber(var p:PNumber);
begin
    if p<>nil then MemoryFree(pointer(p),(p^.places)*4+8);
    p:=nil
end;


const ln2:extended=0.693147180559945309417;

function log1plus(x:extended):extended;assembler;
asm
   fldln2
   fld  x
   fyl2xp1
end;

function logN(var a:number):extended;
var
   x:number;
begin
  if sgn(@a)<=0 then
       begin
          setexceptionwith(s_InvalidArgInLOG,3004);
          logN:=0
       end
  else if nearly1(a) then
       begin
          sbt(a,one^,x);
          logN:=log1plus(extendedval(x))
       end
  else
           LogN:=ln(extendedval(a));
end;



procedure LongintPower(var a:Number; b:longint; var x:Number);     //2010.3.28
var
   y,xx:number;
label
   L1;
begin
    xx.initone;
    if b=0 then goto L1;
    y.init(@a);
    if b>0 then
       begin
          while b<>0 do
              begin
                 if b mod 2<>0 then mlt(xx,y,xx);
                 b:=b div 2;
                 if b<>0 then mlt(y,y,y);
              end;
       end
    else
       try
          while b<>0 do
              begin
                 if b mod 2<>0 then mlt(xx,y,xx);
                 b:=b div 2;
                 if b<>0 then mlt(y,y,y);
              end;
          qtt(one^,xx,xx);     {y:=1/y}
       except
         on E:EExtype do
           if extype=1002 then
              begin
                extype:=0;
                xx.initzero;
              end
           else if extype=3001 then
              setexception(1002)
           else
              raise E;
       end;
  L1:
    x.init(@xx);
end;


{
const
  const1024: ShortNumber = (places:1; sign:1; tag:1; expn:1; frac:(1024,0,0));
}

procedure convert1002(a:extended; var n:number);forward;

procedure RegularPower(var a,b:Number; var x:number);
var
    i:longint;
    c:integer;
    a1,m,n:number;
begin
  a1.init(@a);
  if sgn(@a)<=0 then
      begin
        setexception(3004);
        x.initzero
      end
  else if nearly1(a) then
      begin
        sbt(a,one^,a1);
        convert1002(NPXpower1plus(extendedval(a1),extendedval(b)),x)
      end
  else //if compareabs(b,PNumber(@const1024)^)<0 then
    begin
      m.init(@b);
      intpart(m);
      sbt(b,m,n);
      i:=longintval(m,c);
      if c=0 then
         begin
           LongintPower(a,i,x);
           if iszero(@n) then
             begin
               RoundConv(x);
               checkrangedecimal(x,1002)
             end
           else
             convert1002(extendedVal(x)*NPXPower(extendedval(a),extendedval(n)),x);
         end
      else
         convert1002(NPXpower(ExtendedVal(a),ExtendedVal(b)),x);
    end;
end;


procedure power(var a,b:Number; var x:number);
var
   n,y:number;
begin
   if (b.places=0) then
       x.initone
   else if a.sign>0 then
      begin
         regularPower(a,b,y);
         x.init(@y)
      end   
   else if a.sign=0 then
       begin
               if b.sign>0 then
                   x.initzero
               else if b.sign=0 then
                   x.initone
               else
                   setexception(3003)
       end
   else {if a<0 then}
       begin
            if isinteger(b) then
                begin
                      n.init(@a);
                      n.sign:=-n.sign;
                      power(n,b,y);
                      n.init(@b);
                      qtt2(n);
                      if not isinteger(n) then
                           y.sign:=-y.sign;
                      x.init(@y);
                end
            else
                      setexception(3002);
       end;
end;


const
    power1000000000array: array[0..31] of extended =
         (1,  1E9, 1E18, 1E27, 1E36, 1E45, 1E54, 1E63, 1E72, 1E81,
       1E90, 1E99,1E108,1E117,1E126,1E135,1E144,1E153,1E162,1E171,
      1E180,1E189,1E198,1E207,1E216,1E225,1E234,1E243,1E252,1E261,
      1E270,1E279);

   power1e288array: array[0..17] of extended =
         (1,  1e288,  1e576, 1e864,1e1152,1e1440,1e1728,1e2016,
       1e2304,1e2592,1e2880,1e3168,1e3456,1e3744,1e4032,1e4320,
       1e4607,1e4896);

(*
function power1000000000repeat(i:integer):extended;
var
   j,k:integer;
   x,y:extended;
begin
   j:=i mod 32;
   k:=i div 32;

    x:=1.E288;
    y:=1.;
    while k>0 do
        begin
           if k mod 2 =1 then
              y:=y*x;
           k:=k div 2;
           if k>0 then x:=x*x;
        end;
    power1000000000repeat:=y * power1000000000array[j]
end;
*)

function power1000000000(i:integer):extended;
var
   j,k:integer;
begin
   j:=i mod 32;
   k:=i div 32;
   power1000000000:=power1000000000array[j]*power1e288array[k]
end;

(*
function abnormal(var a:extended):wordbool;assembler;
asm
   fld tbyte ptr [a]
   fxam
   fstsw ax
   sahf
   jb    @L1
   xor eax,eax
 @L1:
   fstp st(0)
end;
*)

var
   convertplaces:integer=3;

procedure convertsub(a:extended; var n:number);
         {convert extended to Decimal}
var
   e,i:integer;
   q,f:extended;
begin

   //SetRoundMode(rmUP);

     with n do
     begin
        sign:=1;

        if a<1.E9 then
          begin
             e:=1;
             f:=1.;
            while  a*f<1. do
               begin
                   f:=f*1.E9;
                   e:=e-1;
               end;
            a:=a*f;
           {now 1<=a<1000000000 }
            expn:=e;
            for i:=1 to convertplaces do
                begin
                     q:=system.int(a);
                     frac[i]:=trunc(q);
                     a:=(a-q)*1.E9;
                end;
          end
        else {a>=1.E9}
          begin
            e:=2;
            f:=1.;
            while a/f>=1.E18  do
                    begin
                       f:=f*1.E9;
                       e:=e+1
                    end;
            a:=a/f;
           {now 1E9<=a<1E18 }
            expn:=e;
            for i:=1 to convertplaces do
                begin
                     q:=system.int(a/1.E9);
                     frac[i]:=trunc(q);
                     a:=(a-q*1.E9)*1.E9;
                end;
          end;

        places:=convertplaces;
     end;

   //SetRoundMode(rmNearest);

end;

procedure convert(a:extended; var n:number);
begin
  if isInfinite(a) then
            setexceptionwith('',1002)
    else if isNan(a) then
            setexceptionwith('',3001) ;
  if a=0 then
     n.initzero
  else
     begin
        if a<0 then
        begin convertsub(-a,n); oppose(n) end
        else
              convertsub(a,n);
        checkRange(n);
        RoundConvert(n,1003);
     end;
end;

procedure convert1002(a:extended; var n:number);
begin
  if a=0 then
     n.initzero
  else
     begin
        if a<0 then
        begin convertsub(-a,n); oppose(n) end
        else
              convertsub(a,n);
        checkRange(n);
        RoundConvert(n,1002);
     end;
end;

procedure initdecimal(var n:number; x:extended);
begin
    convert(x,n);
end;


function ExtendedVal(var a:Number):extended;

var
   i,k:integer;
   x  :extended;
begin
 with a do
    begin
      if sign=0 then
          ExtendedVal:=0
      else
          begin
            if expn>549 then setexception(1002);
            x:=0;
            for i:= mini(places,convertPlaces) downto 1 do
              begin
                k:=expn-i;
                if k>0 then
                   x:=x+frac[i]*power1000000000(k)
                else if k=0 then
                   x:=x+frac[i]
                else if k>=-548 then
                   x:=x+frac[i]/power1000000000(-k)
              end;
            if sign<0 then x:=-x;
            ExtendedVal:=x;

          end;

    end;
end;



procedure initconsts;
begin
   pointer(null):=@constnull;
   pointer(zero):=@constzero;
   pointer(one):=@constone;
   pointer(ten):=@constten;
   pointer(half):=@consthalf;
   pointer(MAXNUM):=@constMAXNUM;
   pointer(decimalPI):=@constdecimalPI;
   pointer(decimalHalfpi):=@constdecimalHalfPI;
end;




procedure setOpModeDecimal ; {JIS 15digits}
begin
       limit:=3;
       precision:=3;
       convertPlaces:=3;
       maxExpnDecimal:=11;
       minExpnDecimal:=-10;
       constMAXNUM.expn:=MaxExpnDecimal+1;
       constMAXNUM.frac[1]:=1;
       RoundVari:=round15;
       RoundExpression:=NoRound;
       RoundConv:=round17m;
        if signiwidthMore then
           signiwidth:=27
        else
           signiwidth:=15;

end;

procedure setOpModeHigh;
begin
        precision:=HighPrecision;
        limit:=precision+1;
        convertPlaces:=4;
        maxExpnDecimal:=precision;
        minExpnDecimal:=-maxExpnDecimal;
        constMAXNUM.expn:=MaxExpnDecimal+1;
        constMAXNUM.frac[1]:=1;
        RoundVari:=roundprecision;
        RoundExpression:=roundprecision;
        RoundConv:=Round17m;
        //signiwidth:=Precision*9;
        signiwidth:=(Precision+1)*18;
end;


procedure setOpModeNative;
begin
        precision:=3;
        limit:=3;
        convertPlaces:=3;
        maxExpnDecimal:=MaxExpnNative;
        minExpnDecimal:=-maxExpnDecimal;
        constMAXNUM.expn:=MaxExpnDecimal+1;
        constMAXNUM.frac[1]:=1;
        RoundVari:=NoRound;
        RoundExpression:=NoRound;
        RoundConv:=NoRound {Round17m} ;
        //exradwidth:=3;
        if signiwidthMore then
           signiwidth:=19
        else
           signiwidth:=15;
end;

procedure setOpModeRational;
begin
        precision:=HighPrecision;
        limit:=precision+1;
        convertPlaces:=4;
        maxExpnDecimal:=maxexpn;
        minExpnDecimal:=-maxExpnDecimal;
        constMAXNUM.expn:=MaxExpnDecimal+1;
        constMAXNUM.frac[1]:=1;
        RoundVari:=NoRound;
        RoundExpression:=NoRound;
        RoundConv:=Round17m;
        signiwidth:=Precision*9;
end;

procedure test;
var
 a,b,c:shortnumber;
begin
 a.initone;
 b.initone;
 add(PNumber(@a)^,PNumber(@b)^,PNumber(@c)^)
end;



begin
initconsts;
setopmodeDecimal;

end.
