unit format;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

interface
uses arithmet;

type
   NumericComponents =record
           sign:char;
           exp:integer;
           digits:ansistring;
   end;


function componentsN(const n:number):NumericComponents;

function formatNum(const n:NumericComponents;
                form:ansistring; var i:integer;var code:integer):ansistring;

function formatStr(const s:AnsiString;
             const form:ansistring; var i:integer;var code:integer):ansistring;

function TestFormatString(const form:string):boolean;
procedure TestFormatItem(const form:string);

function IsLiteral(c:char):boolean;


implementation
uses
  MyUtils, base;

const
   nonliteral:set of char=['#', '$', '%', '*', '+', '-', '.' , '<' , '>' , '^'];

function IsLiteral(c:char):boolean;
begin
  result:=not (c in nonliteral)
end;

function componentsN(const n:number):NumericComponents;
begin
  with result do
     begin
       ConvertToString(n,Digits,exp);
       if sgn(@n)>=0 then
        sign:='+'
       else
        sign:='-';
     end;
end;





function formatNum(const n:NumericComponents;
              form:ansistring; var i:integer;var code:integer):ansistring;
var
   exrad:ansistring;
   intpart:ansistring;
   DecimalPointPos:integer;
   intplaces,MinIntPlaces,fractplaces:integer;
   exradplaces:integer;
   exp,p,j :integer;
   i0,LengthOfFormatItem:integer;
   FloatingCharacter1:string[1];
   FloatingCharacter2:string[1];
   DigitPlace:string[1];
   sign :string[1];
   comma:string[1];
   UseComma:Boolean;
   fformat,Eformat:boolean;
begin
   result:='';
   code:=0;

   if (form='') or (i>Length(form)) then setexception(8202);

  {evaluate the format-item}
   i0:=i;

   // 桁寄せ文字の置換
   if form[i] in ['<','>'] then
      if (length(form)>i) and (form[i+1] in ['$','+','-','#','*','%']) then
         form[i]:=form[i+1]
      else
         form[i]:='#';

   //浮動文字の取得
   FloatingCharacter1:='';
   FloatingCharacter2:='';
   if (form[i] in ['+','-','$']) then
      begin
          FloatingCharacter1:=form[i];
          inc(i);
          while form[i]=FloatingCharacter1 do inc(i);
          if (FloatingCharacter1='$') and (form[i] in ['+','-'])
                                       or (form[i]='$') then
                 begin
                    FloatingCharacter2:=form[i];
                    inc(i);
                 end;
      end;
           ;

   //整数書式項目  数字位置の取得
   intplaces:=0;
   MinIntPlaces:=0;
   UseComma:=false;
   DigitPlace:='';
   if form[i] in ['#','%','*'] then DigitPlace:=form[i];
   while form[i]=DigitPlace do
          begin
              inc(intplaces);
              if DigitPlace[1] in ['%','*'] then inc(MinIntPlaces);
              inc(i);
              if form[i]=',' then begin inc(i); UseComma:=true end; //コンマ
          end;

   // 小数部
   Fformat:=false;
   fractplaces:=0;
   DecimalPointPos:=i;
   if form[i]='.' then
      begin
          Fformat:=true;
          inc(i);
          while (i<=length(form)) and (form[i]='#') do
                 begin
                     inc(i);
                     inc(fractplaces)
                 end;
      end;

   // 指数部
   Eformat:=false;
   exradplaces:=0;
   while (form[i]='^') do
          begin
              Eformat:=true;
              inc(exradplaces);
              inc(i);
          end;
   LengthOfFormatItem:=i-i0;

   //syntax check
   {
   if (form[i] =',')
      or (Fformat and (intplaces=0) and (fractplaces=0))
      or (exradplaces in [1,2])  then
                 setexception(8201) ;
   }
   if i=i0 then
               setexception(8202) ;



 {evaluate the number}
  result:=n.digits;
  exp:=n.exp;
  sign:=n.sign;

 {generate}

  case Eformat of
   false:
      begin
        roundstring(result,exp+fractplaces,exp);
        if exp>=0 then
           begin
              intpart:=copy(result,1,exp);
              result:=copy(result,exp+1,maxint);
              while length(intpart)<exp do intpart:=intpart+'0';
           end
        else if result<>'' then
           begin
              intpart:='';
              while exp<0 do
                    begin
                         result:='0'+result;
                         inc(exp)
                    end;
           end
        else
           result:=StringOfChar('0',fractplaces) ;
      end;
   true: {E-format}
      begin
         roundstring(result,intplaces+fractplaces,exp) ;
         if length(result)>0 then
             exp:=exp-intplaces
         else
             exp:=0;
         intpart:=copy(result,1,intplaces);
         while length(intpart)<intplaces do intpart:=intpart+'0';
         result:=copy(result,intplaces+1,fractplaces);
      end;
    end;

    while length(result)<fractplaces do result:=result+'0';

    if (intplaces>0) and (length(intpart)+length(result)=0) then intpart:='0';
    if EFormat then while length(intpart)<intplaces do intpart:='0'+intpart;
    if DigitPlace='%' then
       while length(intpart)<MinIntPlaces do intpart:='0'+intpart;
    if DigitPlace='*' then
       while length(intpart)<MinIntPlaces do intpart:='*'+intpart;
    if JISFormat then
            while length(intpart)<IntPlaces do intpart:=' '+intpart;

    //コンマ挿入
    if UseComma then
       begin
         comma:=',';
         j:=DecimalPointPos-1;
         p:=length(intpart)+1;
         while i0<j do
            begin
               if form[j]=',' then
                  begin
                      if (p=0) or not (intpart[p-1] in ['0'..'9']) then
                         begin
                           if form[j-1]='#' then comma:=' ';
                           if form[j-1]='*' then comma:='*';
                         end;
                      if (comma<>' ') or JISFormat then
                         insert(comma,intpart,p);
                      dec(j)
                  end;
               dec(j);
               if p>0 then dec(p);
            end;
       end;

   {composite}
   if Fformat then
      result:=intpart+'.'+result
   else
      result:=intpart;

   {exrad}
   if Eformat then
      begin
         result:=result+'E';
         if exp>=0 then
            result:=result+'+'
         else
            begin result:=result+'-'; exp:=-exp end;
         str(exp,exrad);
         while length(exrad)<exradplaces-2 do exrad:='0'+exrad;
         result:=result+exrad;
         if length(exrad)>exradplaces-2 then code:=8204;
      end;

    {floating Character}
    if (FloatingCharacter2='$') then result:='$'+result;
    if  (sign='-') or (FloatingCharacter2='+')
                   or (FloatingCharacter1='+') then result:=sign+result;
    if (FloatingCharacter1='$') then result:='$'+result;

    {leading spaces}
    while length(result)<LengthOfFormatItem do result:=' '+result;

    if (length(result)>LengthOfFormatItem) and (code=0) then code:=8203;

    {error marks}
    if (code<>0) then
       begin
           result:='';
           while length(result)<LengthOfFormatItem do result:=result+'*';
       end;

end;



function testItem(const form:string; var i:integer):boolean;
var
  digitp:char;
  iform,fform:boolean;
begin
  result:=false;
  iform:=false;
  fform:=false;
  if form[i] in ['<','>'] then                   //桁寄せ
     begin
        inc(i);
        if (form[i] in ['<','>']) or IsLiteral(form[i]) then
           begin                                                 //桁寄せのみ
              result:=true;
              exit;
            end;
     end;
  if form[i] in ['+','-','$'] then              //浮動文字列
     begin
        digitp:=form[i];
        while form[i]=digitp do inc(i);
        if digitp='$' then
           begin if form[i] in ['+','-'] then inc(i)  end
        else
           if form[i]='$' then inc(i);
     end;
  digitp:=form[i];    // 数字位置？
  if digitp in ['*','#','%'] then               //整数書式項目
     begin
       iform:=true;
       while (form[i]=digitp) or
             (form[i]=',') and (form[i+1]=digitp)
                                               do inc(i);
     end;
  if form[i]='.' then                           //小数書式項目
     begin
       inc(i);
       if not iform and (form[i]<>'#') then exit;
       fform:=true;
       while form[i]='#' do inc(i);
     end;
  if (iform or fform) and (form[i]='^') then
     begin
        inc(i); if form[i]<>'^' then exit;
        inc(i); if form[i]<>'^' then exit;
        while form[i]='^' do inc(i);            //指数書式項目
     end;
  if form[i] in [',','^'] then exit;  //異常
  result:=iform or fform;
  end;



function formatStr(const s:AnsiString;
             const form:ansistring; var i:integer;var code:integer):ansistring;
var
  c:char;
  i0:integer;
  count:integer;
  d:integer;
begin
  result:='';
  code:=0;
  if (form='') or (i>Length(form)) then begin setexception(8202);exit end;
  c:=form[i];         // 桁寄せ文字？
  i0:=i;

  TestItem(form,i) ;

  count:=i-i0;
  if i=i0 then
                 setexception(8202) ;

  if length(s)>count then
     begin
         code:=8203;
         while count>0 do begin result:=result+'*'; dec(count) end;
     end
  else if c='<' then
     begin
         result:=s;
         while length(result)<count do result:=result+' '
     end
  else if c='>' then
     begin
         result:=s;
         while length(result)<count do result:=' '+result
     end
  else
     begin
         result:=s;
         d:=1;
         while length(result)<count do
            if d>0 then
               begin result:=result+' ' ; d:=-d end
            else
               begin result:=' '+result ; d:=-d end;
     end;
end;

function TestFormatString(const form:string):boolean;
var i,i0:integer;
begin
  result:=false;
  i:=1;
  while (i<=length(form)) and IsLiteral(form[i]) do
           begin
              //if IsDBCSLeadByte(byte(form[i])) then inc(i,2) else inc(i)
              ReadMBC(i,form);
              Inc(i);
           end;
  while i<=length(form) do
    begin
     i0:=i;
     if not TestItem(form,i) then exit;
     while (i<=length(form)) and IsLiteral(form[i]) do
           begin
              //if IsDBCSLeadByte(byte(form[i])) then inc(i,2) else inc(i)
              ReadMBC(i,form);
              Inc(i);
           end;
     if i0=i then break;
    end;
  result:=(i>length(form))
end;

procedure TestFormatItem(const form:string);
var
  i:integer;
begin
  i:=1;
  if not testItem(form, i) or (i<=length(form)) then
     setexception(8201);
end;

     
end.
