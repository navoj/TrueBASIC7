unit texthand;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}
{$V-}
(***************************************)
(* Copyright (C) 2003, SHIRAISHI Kazuo *)
(***************************************)

interface

uses  SysUtils, Types, StdCtrls, ComCtrls,  SynEdit,
      Classes, Forms, Dialogs, Controls,
      base,arithmet;

const
  plainchar: set of char =['0'..'9','A'..'Z','a'..'z','.','+','-'];
  //unquotedchar: set of char =[' ','0'..'9','.','+','-','@'..chr($7E),chr($80)..chr($FF)];
  //unquotedchar: set of char =[' ','(',')','+','-'..'9','@'..chr($7E)];  //2023.10.27
  unquotedchar: set of char =[' ','(',')','+','-'..'9','@'..chr($7E),chr($80)..chr($FF)];  //2025.05.22

type
   TokenSpecification =(Nrep,Nidf,Scon,Sidf,relational,tail,another);
   SetOfTokenSpec=set of TokenSpecification;
type
   SyntaxError=class(Exception);

function getMemoLine(n:integer):ansistring;
procedure setMemoLine(n:integer; const s:ansistring);
procedure InsertMemoLine(n:integer; const s:ansistring);
procedure DeleteMemoLine(n:integer);
function MemoLineCount:integer;
procedure   initIdentifierChar;
var
   memo :TSynEdit = nil ;
   linenumber  :integer ;
var
   prevtoken: string;
   prevtokenspec:tokenspecification;
   token:     string;
   tokenstring:ansistring;
   tokenValue :number;
   tokenspec  :tokenspecification;
   NextToken:    string;
   NextTokenString:ansistring;
   NextTokenValue :number;
   labelnumber:integer;
   NextTokenSpec  :tokenspecification;

var
   trying:byte=0;
   indent:integer =-1;


function NextNextToken:string;
function modifier(const s:string):string;
function identifier(const s:string):string;


type
  tokensave = record
      svline:ansistring;
      svlnb:integer;
      svlnb0:integer;
      svlnb00:integer;
      svcp:integer;
      svcp0:integer;
      svcp00:integer;
      svprevtoken:string;
      svtoken:     string;
      svtokenstring:ansistring;
      svtokenValue :number;
      svtokenspec  :tokenspecification;
      svNextToken:    string;
      svNextTokenString:ansistring;
      svNextTokenValue :number;
      svNextTokenSpec  :tokenspecification;
      svinsertcount:integer;
  end;

procedure initline;
procedure gettoken;
procedure checkTail;
procedure NextLineGlobal;
procedure nextline;
procedure skip;
procedure SkipLogical;
function outoftext:boolean;

procedure resettoken1;

function datum:ansistring;


procedure savetoken(var svcp:tokensave);
procedure restoreToken(const svcp:tokensave);

procedure SetErrOnLine(linenumb:integer; const mes:AnsiString; hc:smallint);
procedure setErr(const mes:AnsiString; hc:smallint);
procedure setError(const s:AnsiString; hc:smallint);
procedure seterrExpected(const s:AnsiString; hc:smallint);
procedure seterrRestricted(const s:AnsiString; hc:smallint);
procedure seterrIllegal(const s:AnsiString; hc:smallint);
procedure seterrDimension( hc:smallint);
function test(c:char):boolean;
procedure check(const c:string; hc:smallint);
procedure checktoken(const c:string; hc:smallint);
procedure checktoken1(const c:string; hc:smallint);
function getidentifier:string;
procedure  NumericConstant(var n:number);
function NonNegativeIntegralNumber(var i:longint):boolean;
function strint(i:longint):string;

procedure insertkeyword(const keyword:ansistring; var svcp:tokensave);
procedure replacekeyword(const keyword:ansistring; var svcp:tokensave);
procedure inserttext(const keyword:ansistring);
procedure replacetoken(const keyword:ansistring);
procedure replacetoken2(const keyword:ansistring);
procedure replaceprevtoken(const keyword:ansistring);
function confirm(const msg:ansistring; hc:longint):boolean;
function confirmFrom(const svcp:tokensave; const msg:ansistring; hc:longint):boolean;
function confirmAtLine(linenumb:integer; const msg:ansistring; hc:longint):boolean;
procedure SelectToken;
procedure SelectPrevToken;
procedure NestedIfStatement;
var IFline:boolean=false;
var SvThenBlockPos:tokensave;

procedure insertline(index:integer; const s:ansistring);
function extract(const svcp:tokensave):ansistring;
function NoContinuation:boolean;

procedure DeleteLabelNumber(memo1:TSynEdit);
procedure AddLabelNumber(memo1:TSynEdit);
procedure CaseChange(memo1:TSynEdit);
function NextTokenBeyondParenthesis:string;
function NextTokenBeyondParenthesis2:string;
function NextTokenspecWithinParenthesis:TokenSpecification;
procedure FindCorrespondingParenthesis;
type
    EReCompile=class(Exception);

implementation
uses
     myutils, helpctex,numberdg,kwlist,convdlg,sconsts;


function getMemoLine(n:integer):ansistring;
begin
  try
   result:=Memo.Lines[n];
  except
   result:='';
  end;
end;

procedure setMemoLine(n:integer; const s:ansistring);
begin
  memo.lines.beginupdate;
  try
     Memo.lines[n]:=s;
  except
  end;
  memo.lines.EndUpdate;
end;

procedure InsertMemoLine(n:integer; const s:ansistring);
begin
   memo.lines.beginupdate;
   try
      Memo.Lines.Insert(n,s);
   except
   end;
   memo.lines.EndUpdate;
end;

function MemoLineCount:integer;
begin
   result:=Memo.lines.count
end;

procedure DeleteMemoLine(n:integer);
begin
  memo.lines.beginupdate;
  try
     memo.Lines.delete(n);
  except
  end;
  memo.lines.EndUpdate;
end;



{************************}
{ Text Handling Variables}
{************************}

var
   line        :ansistring ;
var
   insertcount:integer=0;
var
   cp    :integer;  { next charactor pointer}
   cp0   :integer;  { charactor pointer on line}
   cp00  :integer;  { previous chractor pointer}
   cp000 :integer;
   lnb   :integer;
   lnb0  :integer;
   lnb00 :integer;
   lnb000:integer;


{*************}
{text line handling}
{*************}

procedure setErrorSub(mes:ansistring; hc:smallint);
begin
   if HelpContext=0 then HelpContext:=hc;
   if mes<>'' then
      statusmes.add(mes);
   raise SyntaxError.create('')
end;

procedure SetErrOnLine(linenumb:integer; const mes:AnsiString; hc:smallint);
begin
    exline:=linenumb;
    expos:=1;
    exinsertcount:=0;
    seterrorSub(mes,hc);
end;

procedure seterrAt(pos:integer; const mes:AnsiString; hc:smallint);
begin
    exline  :=lnb00;
    expos   :=pos;
    exinsertcount:=insertcount;
    seterrorSub(mes,hc);
end;

procedure seterr(const mes:AnsiString; hc:smallint);
begin
   seterrAt(cp00,mes,hc)
end;

procedure seterror(const s:AnsiString; hc:smallint);
begin
   seterr(s+s_IncludesAnError,hc)
end;

procedure seterrExpected(const s:AnsiString; hc:smallint);
begin
   if token='' then
          seterr(s+s_IsExpected,hc)
   else
          seterr(token+s_CantBelongHere+ EOL+ s+s_IsExpected,hc)
end;

procedure seterrRestricted(const s:AnsiString; hc:smallint);
begin
   if token<>'' then seterr(s+s_Restricted,hc)
   else seterrExpected(s,hc)
end;


procedure seterrIllegal(const s:AnsiString; hc:smallint);
var
   mes:string;
begin
   mes:='';
   if s<>'' then
      begin
         mes:=s+s_CantBelongHere;
      end;
   seterr(mes,hc)
end;


procedure seterrDimension(hc:smallint);
begin
     seterr(s_DimmensionError,hc);
end;




{****************}
{string functions}
{****************}


function isDigit:boolean;
begin
  case line[cp] of
      '0'..'9': isDigit:=true ;
       else     isDigit:=false ;
  end;
end;

function isletter:boolean;
begin
       case line[cp] of
          'A'..'Z','a'..'z' :
                   isletter:=true ;
       else
                   isletter:=false;
       end
end;

function getline(i:integer):ansistring;
begin
   if (i<MemoLineCount) and (i>=0)  then
      result:=getMemoLine(i)
   else
      result:='';
   if result='' then result:=#0;
end;

procedure spacecut;
var
   cpsave:integer;
begin
   while (line[cp]=' ') do  inc(cp);

   if line[cp]='&' then
      begin
           cpsave:=cp;
           inc(cp);
           while (line[cp]=' ') do  inc(cp);
           if (line[cp]='!') or (line[cp]=chr(0)) then
              begin  //行継続
                     inc(lnb);
                     line:=getline(lnb);
                     if line[1]<>'&' then
                               SetErrOnLine(lnb,'&&' +s_IsExpected, IDH_JIS_4);
                     cp:=2;
                     spacecut;
              end
           else       //文字列連結演算子
              cp:=cpsave;
       end;
end;

type
  Ptokensave = ^tokensave;


var IdentifierLeadingCharacters: set of char ;
var IdentifierCharacters :set of char ;

procedure   initIdentifierChar;
var
   ch:char;
begin
  IdentifierLeadingCharacters:=['A'..'Z','a'..'z'];
  if GreekIdf then
    IdentifierLeadingCharacters:=IdentifierLeadingCharacters+[#$ce, #$cf];
  if KanjiIdf then
    IdentifierLeadingCharacters:=IdentifierLeadingCharacters+[#$e3..#$e9];
  IdentifierCharacters:=IdentifierLeadingCharacters + ['0'..'9','_']
end;

procedure ReplaceHT; forward;
procedure TabTest;
begin
  if (Pass=1) and  (NextToken<>'') then
    Case NextTokenSpec of
      another:
        begin
            case NextToken[1] of
             #9:
               begin
                 if (Application.MessageBox(Pchar(s_HT_MES),
                                 AppTitle,mb_YesNo)=IDYES) then
                   begin
                     ReplaceHT;
                     raise ERecompile.create('');
                   end;
               end;
             #1..#8, #$0A..#$1F,#$7F,#$80..#$FF:
                statusMes.add(s_CTRLChar1 +'chr$(' + strint(byte(NextToken[1])) +')' + s_appears);
            end;
        end;
    end;
end;

procedure  gettoken;
   function readout(ch:char):boolean;
   begin
       if (line[cp]=ch) then
           begin
               inc(cp);
               readout:=true
           end
       else
           readout:=false
   end;
var
   code  :integer;
   cp1:integer;
begin

   TabTest;

   spacecut;
   cp000:=cp00;
   lnb000:=lnb00;
   cp00:=cp0;
   lnb00:=lnb0;
   cp0 :=cp;
   lnb0:=lnb;
   prevtoken:=token;
   prevtokenspec:=tokenspec;
   token:=NextToken;
   tokenSpec:=NextTokenSpec;
   tokenValue:=NextTokenValue;
   tokenString:=NextTokenString;

   if line[cp] in IdentifierLeadingCharacters then
     begin
         while (line[cp] in IdentifierCharacters) do
            begin
              ReadMBC(cp,line);  //if IsDBCSLeadByte(byte(Line[cp])) then inc(cp);
              inc(cp);
            end;
         { 修飾識別名}
         if (line[cp]='.')
            and (line[cp+1] in IdentifierLeadingCharacters) then
               begin
                  inc(cp);
                  while (line[cp] in IdentifierCharacters) do
                    begin
                       ReadMBC(cp,line); //if IsDBCSLeadByte(byte(Line[cp])) then inc(cp);
                       inc(cp);
                    end;
               end;
         if readout('$') then
                  NextTokenSpec:=SIdf
         else if not permitMicrosoft or readout('%')
                     or readout('!') or readout('#') or true then
                  NextTokenSpec:=NIdf;
         NextToken:=copy(line,cp0,cp-cp0);
         upper(NextToken);
         {Microsoft END文の処理}
         if permitMicrosoft and (NextToken='END') and readout(#9) then
             NextToken:='END'#9;
     end
   else
   case line[cp] of
       '0'..'9','.':
             if (line[cp]<>'.') or (line[cp+1] in ['0'..'9'])  then
                begin
                  try
                     NumericRep(NextTokenValue,code,line,cp);
                  except
                     On EExtype do
                        begin
                          statusmes.Clear;
                          HelpContext:=0;
                          seterr(s_TooLargeConstant,IDH_JIS_DETAIL);
                        end
                     else
                        raise
                  end;
                  if code<>0 then
                        seterr(s_TooLargeConstant,IDH_JIS_DETAIL);
                  NextTokenSpec:=Nrep;
                  NextToken:=copy(line,cp0,cp-cp0);
                end
              else
                begin
                  NextTokenSpec:=Another;
                  NextToken:=line[cp];
                  inc(cp);
                end;
       '<'..'>':
                begin
                     inc(cp);
                     case line[cp] of
                          '<'..'>': inc(cp);
                          else  ;
                     end;
                     NextToken:=copy(line,cp0,cp-cp0);
                     NextTokenSpec:=relational;
                end;
       '"'     :
                begin
                     NextTokenString:='';
                     cp1:=cp+1;
                     repeat
                       repeat
                         inc(cp);
                       until line[cp] in [#0,#13,#10,'"'];
                       NextTokenString:=NextTokenString+copy(line,cp1,cp-cp1);
                       if line[cp]='"' then  inc(cp)
                       else  seterrAt(cp,s_QuoteIsExpected,IDH_STRING);
                       cp1:=cp;
                     until line[cp]<>'"';

                     NextTokenSpec:=SCon;
                     NextToken:=copy(line,cp0,cp-cp0);

                 end;
       '!',chr(0),chr(39){ｱﾎﾟｽﾄﾛﾌｨ}:
                 begin
                      cp:=length(line)+1;  {note. line[length(line)+1]=chr(0)}
                      NextToken:='';
                      NextTokenSpec:=tail;
                 end;
       else
                 begin
                      ReadMBC(cp,line); //if IsDBCSLeadByte(byte(Line[cp])) then inc(cp);
                      inc(cp);
                      NextToken:=copy(line,cp0,cp-cp0);
                      NextTokenSpec:=another;
                 end;
   end
end;

procedure replaceHT;
var
   i:integer;
   s:string;
begin
   s:=memo.lines.text;
   for i:=1 to length(s) do
         if s[i]=#9 then s[i]:=' ';
   with memo.lines do
    begin
       beginUpdate;
       text:=s;
       endupdate;
    end;
end;



function NextNextToken:string;
var
  svcp:TokenSave;
begin
  saveToken(svcp);
  gettoken;
  result:=nexttoken;
  restoreToken(svcp)
end;

function NextTokenBeyondParenthesis:string;
var
  svcp:TokenSave;
begin
  result:=nexttoken;

  if result='(' then
  begin
    saveToken(svcp);
    gettoken;
    FindCorrespondingParenthesis;
    result:=token;
    restoreToken(svcp)
  end
end;

function NextTokenBeyondParenthesis2:string;
var
  svcp:TokenSave;
begin
  result:=nexttoken;

  if result='(' then
  begin
    saveToken(svcp);
    gettoken;
    FindCorrespondingParenthesis;
    result:=token;
    if result='(' then
       begin
          gettoken;
          FindCorrespondingParenthesis;
          result:=token;
       end;
    restoreToken(svcp)
  end
end;


function NextTokenspecWithinParenthesis:TokenSpecification;
var
  svcp:TokenSave;
begin
  if nexttoken='(' then
  begin
    saveToken(svcp);
    gettoken;
    while nexttoken='(' do
          gettoken;
    result:=nexttokenSpec;
    restoreToken(svcp)
  end
  else
  result:=nexttokenSpec;
end;


procedure savetoken(var svcp:tokensave);
begin
    with svcp do
       begin
          svline:=line;
          svlnb:=lnb;
          svlnb0:=lnb0;
          svlnb00:=lnb00;
          svcp:=cp;
          svcp0:=cp0;
          svcp00:=cp00;
          svprevtoken:=prevtoken;
          svtoken:=token;
          svtokenstring:=tokenstring;
          svtokenValue :=tokenvalue;
          svtokenspec  :=tokenspec;
          svNextToken:=NextToken;
          svNextTokenString:=NextTokenString;
          svNextTokenValue :=NextTokenValue;
          svNextTokenSpec  :=NextTokenSpec;
          svinsertcount    :=insertcount;
       end
end;

function searchELSE:boolean;
var
  dummy:boolean;
begin
    if token ='IF' then
                   begin gettoken; dummy:=searchELSE;  end;
    result:=false;
    while tokenspec<>tail do
       begin
          gettoken;
          if token='ELSE' then
                   begin result:=true; exit end;
          if token ='IF' then
                   begin gettoken; dummy:=searchELSE;  end;
       end;
end;

procedure NestedIfStatement;
var
   ThenBlockPos:integer;
begin
   if lnb<>LineNumber then exit;
   RestoreToken(SvThenBlockPos);
   ThenBlockPos:=cp00;
   setMemoLine(lnb00,copy(line,1,ThenBlockPos-1));
   InsertMemoLine(lnb00+1,'END IF');
   if searchELSE then
      begin
          InsertMemoLine(lnb00+1,copy(line,cp0,maxint));
          InsertMemoLine(lnb00+1,'ELSE');
          InsertMemoLine(lnb00+1,copy(line,ThenBlockPos,cp00-1-ThenBlockPos));
      end
   else
      InsertMemoLine(lnb00+1,copy(line,ThenBlockPos,maxint));
  raise EReCompile.create('');
end;

procedure Multistatement;
begin
  if IFline then NestedIfStatement;
  if lnb<>LineNumber then exit;
  setMemoLine(lnb00,copy(line,1,cp00-1));
  InsertMemoLine(lnb0+1,copy(line,cp0,maxint));
  raise EReCompile.create('');
end;

procedure checktail;
begin
  if (token=':') and (nextToken<>'')
                 and ((nexttokenspec=Nidf)or (nexttokenspec=Sidf))
                 and (lnb=lineNumber) and (AutoCorrect[ac_multi] {or
                      confirm(s_MultiStatementIsNotAvailable ,
                                        IDH_MicroSoft_CONTROL)} ) then
           multistatement
  else if (token=':') and (nextToken='') and
                confirm( s_ColonIsAnExtra,IDH_LINE) then
           replaceToken('')
  else if tokenspec<>tail then
     seterrillegal(token,IDH_LINENUMBER)
  else if (line[cp00]=chr(39)) and not permitMicrosoft then
     if AutoCorrect[ac_remark] {or confirm(s_ConvertTailComment,
                                          IDH_MicroSoft_CONTROL)} then
        replacetoken('!')
     else
        seterrillegal(chr(39),IDH_MICROSOFT_CONTROL)   ;
end;

function NonNegativeIntegralNumber(var i:longint):boolean;
var c:integer;
begin
 result:=false;
 if (length(token)>0) and (token[1] in ['0'..'9']) then
   begin
     val(token,i,c);
     if c=0 then
        begin
         gettoken;
         result:=true
        end
   end;
end;

procedure initline;
var
    long:longint;
    prevlabelnumber:integer;
begin
    IFline:=false;
    lnb:=linenumber;
    line:=getline(linenumber);
    cp:=1;
    nexttoken:='';
    gettoken;
    gettoken;

    prevlabelnumber:=labelnumber;
    labelnumber:=0;

    if NonNegativeIntegralNumber(long) then
       if (long>0)  and (Line[1]<>' ') then
          labelnumber:=long
       else  if pass=2 then
           seterr(s_IllegalLineNumber,IDH_LINENUMBER);

    insertcount:=0;
end;

procedure restoreToken(const svcp:tokensave);
begin
    with svcp do
       begin
          line:=           svline;
          lnb:=     svlnb;
          lnb0:=    svlnb0;
          lnb00:=   svlnb00;
          cp:=             svcp;
          cp0:=            svcp0;
          cp00:=           svcp00;
          prevtoken:=      svprevtoken;
          token:=          svtoken;
          tokenstring:=    svtokenstring;
          tokenValue :=    svtokenvalue;
          tokenspec  :=    svtokenspec;
          NextToken:=      svNextToken;
          NextTokenString:=svNextTokenString;
          NextTokenValue :=svNextTokenValue;
          NextTokenSpec  :=svNextTokenSpec;
          insertcount:=    svinsertcount;
       end;
end;

function outoftext:boolean;
begin
   outoftext:=( lnb >= MemoLineCount )
end;


procedure resettoken1;
begin
   cp:=cp00;
   lnb:=lnb00;
   line:=getline(lnb);
end;


function datum:ansistring;
begin
     spacecut;
     if line[cp]='"' then
        begin
             gettoken;
             datum:= '"' + nexttokenstring; {目印として"を追加しておく}
        end
     else
        begin
            cp0:=cp;
            while (cp<=length(line)) and (line[cp] in unquotedchar) do inc(cp);
            while (cp>cp0) and (line[cp-1]=' ') do dec(cp);
            datum:=copy(line,cp0,cp-cp0);
            if (cp-cp0=0) then seterror('data',IDH_READ_DATA);
        end;
end;




{***********}
{indentation}
{***********}
var
   IndentTab:integer=0;

procedure DoIndent;
var
   cp1:integer;
   s:AnsiString;
begin
   if linenumber<0 then exit;
   if LineNumber=0 then IndentTab:=0;

   line:=getline(linenumber);
   cp:=1;
   while (cp<length(line)) and (line[cp]=' ') do inc(cp);
   cp1:=cp;  //最初の空白でない文字
   while isdigit do inc(cp);
   cp0:=cp;  //行番号の次の文字または空白
   while (cp<length(line)) and (line[cp]=' ') do inc(cp);
             //cpはコマンドの最初の文字

   if cp0<>cp1 then //行番号あり
      begin
        IndentTab:=cp0-cp1+1;
        if (cp>cp0) then
          begin
            if (cp-cp0-1 < indent*3) then
              begin
                s:=getMemoLine(LineNumber);
                Insert(spaces(indent*3 -cp + cp0 +1), s, cp );
                setMemoLine(LineNumber,s);
              end
            else if (cp-cp0-1 > indent*3) then
              begin
                s:=GetMemoLine(LineNumber);
                if indent>=0 then
                   delete(s, 1 + cp0 +indent*3 , cp-cp0-1 -indent*3)
                else
                   delete(s, 1 + cp0  , cp-cp0-1 );
                setMemoLine(LineNumber,s);
              end;
            if cp1>1 then //行番号の前の空白を削除
              begin
                s:=getMemoLine(LineNumber);
                delete(s, 1, cp1-1);
                setMemoLine(LineNumber,s);
              end
          end;
      end
   else      //行番号なし
      begin
          if cp-1 < IndentTab + indent*3 then
            begin
               s:=GetMemoLine(LineNumber);
               insert(spaces(IndentTab + indent*3 -cp+1), s, cp );
               setmemoLine(LineNumber,s);
            end
          else if cp-1 > IndentTab + indent*3 then
            begin
               s:=GetMemoLine(LineNumber);
               if indent>=0 then
                 delete(s, 1+ IndentTab + indent*3 , cp-1 -(IndentTab + indent*3) )
               else
                 delete(s, 1+ IndentTab  , cp-1 -IndentTab ) ;
               SetMemoLine(LineNumber,s);
            end;
      end;

end;




procedure NextLineGlobal;
begin
  trying:=0;
  repeat
    checkTail;
    if AutoIndent and (pass=1) and not permitMicrosoft then DoIndent;
    lineNumber:=lnb+1;
    initline;
  until (tokenspec<>tail) or outoftext ;
end;

procedure nextline;
begin
  trying:=0;

  if (token=':') and (nexttoken<>'') and permitMicrosoft then {multi-statement}
     begin
         gettoken;
         exit
     end;

  repeat
    checkTail;
    if AutoIndent and (pass=1) and not permitMicrosoft then DoIndent;
    lineNumber:=lnb+1;
    initline;
  until (tokenspec<>tail) or (labelNumber>0) or outoftext ;
end;


procedure skip;
begin
    cp:=length(line)+1;
    nextToken:='';
    gettoken;
    gettoken;
end;

procedure SkipLogical;
begin
    While tokenSpec<>tail do
          gettoken;
end;


{*************}
{text handling}
{*************}


procedure SelectToken;
begin
   with memo do
      begin
         (memo.owner as TForm).BringToFront;
         if token<>'' then
         begin
           SelStart:=LineIndex(memo,lnb00)+cp00-1+insertcount; //SendMessage(Handle,EM_LINEINDEX,lnb00,0)+cp00-1+insertcount;
           SelectWord;    //SelLength:=Length(token)
         end
         else
         begin
           SelStart:=LineIndex(memo,lnb00);  //SendMessage(Handle,EM_LINEINDEX,lnb00,0);
           SelectLine;   //SelLength:=Length(lines[lnb00])
         end;
         //SendMessage(Handle,EM_SCROLLCARET,0,0);
      end;
end;

procedure SelectPrevToken;
begin
   with memo do
      begin
         (memo.owner as TForm).BringToFront;
         SelStart:=LineIndex(Memo,lnb000)+cp000-1+insertcount;
         SelectWord;  //SelLength:=Length(token) ;
         //SendMessage(Handle,EM_SCROLLCARET,0,0);
      end;
end;

procedure SelectFrom(const svcp:tokensave);
//var
//   selend:integer;
begin
  with svcp do
   with memo do
      begin
         (memo.owner as TForm).BringToFront;
          SelStart:=LineIndex(memo,svlnb00)+svcp00-1+insertcount;
          Selend:=LineIndex(memo,lnb00)+cp00-1;
          //SelLength:=Selend-Selstart;
          //SendMessage(Handle,EM_SCROLLCARET,0,0);
      end;
end;

function test(c:char):boolean;
begin
       test:=true;
       if token=c then
           gettoken
       else
           test:=false
end;



procedure check(const c:string; hc:smallint);
begin
    if token=c then
        gettoken
    else
        seterrExpected(c,hc)
end;



procedure checktoken(const c:string; hc:smallint);
begin
    if token=c then
        gettoken
    else
        if (trying=0) and confirm(c + s_IsExpected + s_ConfirmInsert, hc) then
            inserttext(c)
        else
           seterrExpected(c,hc)
end;

procedure checktoken1(const c:string; hc:smallint);
begin
       if token=c then
           gettoken
       else if (token='') or (token='END') or (token='LOOP') or (token='NEXT') then
           seterrExpected(c,hc)
       else
           seterrIllegal(token,hc)
end;

function modifier(const s:string):string;
var
  i:integer;
begin
  if not (tokenspec in [Nidf,SIdf]) then
               seterrExpected(s_Identifier,IDH_IDENTIFIER);
  i:=pos('.',s);
  result:=copy(s,1,i-1);
end;

function identifier(const s:string):string;
var
  i:integer;
begin
  i:=pos('.',s);
  result:=copy(s,i+1,maxint);
end;

function getidentifier:string;
begin
    getidentifier:=token;
    if (token='NOT') or (token='ELSE') or (token='PRINT') or (token='REM') then
               seterr(token+s_IsReserved,IDH_RESERVED);
    if modifier(token)<>'' then
               seterrIllegal(modifier(token),IDH_RESERVED);
    gettoken
end;


function strint(i:longint):string;
var
   s:string;
begin
    str(i,s);
    strint:=s
end;


procedure  NumericConstant(var n:number);
begin
    if tokenspec=Nrep then
          begin
             n:=Tokenvalue ;
             gettoken
          end
    else if token='+' then
          begin
             gettoken;
             NumericConstant(n);
          end
    else if token='-' then
          begin
             gettoken;
             NumericConstant(n);
             oppose(n);
          end
    else
          seterrRestricted(s_Constant,IDH_NUMBER);
end;




procedure inserttext(const keyword:ansistring);
var
   s:ansistring;
   i,j:integer;
begin
   i:=cp00+insertcount;
   j:=lnb00;
   if j<MemoLineCount then
     begin
        s:=getmemoLine(j);
        if i>length(s) then begin s:=s+' ';inc(i) end;
        insert(keyword+' ',s,i);
        SetmemoLine(j,s);
        inc(insertcount,length(keyword)+1);
     end
   else
     begin
        InsertMemoLine(MemoLineCount,keyword);
        raise ERecompile.create('');
     end;
 end;

procedure insertkeyword(const keyword:ansistring; var svcp:tokensave);
var
   s:ansistring;
   i,j:integer;
begin
   i:=svcp.svcp00+svcp.svinsertcount;
   j:=svcp.svlnb00;
   s:=getmemoLine(j);
   //insert(keyword+' ',s,i);
   insert(keyword,s,i);      //2008.3.26
   setmemoLine(j,s);
   //inc(insertcount,length(keyword)+1);
   inc(insertcount,length(keyword));   //2008.5.27
end;

procedure replacetoken(const keyword:ansistring);
var
   s:ansistring;
   i,j:integer;
begin
   i:=cp00+insertcount;
   j:=lnb00;
   s:=getMemoLine(j);
   delete(s,i,length(token));
   insert(keyword,s,i);
   setMemoLine(j,s);
   inc(insertcount,length(keyword)-length(token));
end;


procedure replacetoken2(const keyword:ansistring);
begin
  replaceToken(keyword)
end;

procedure replaceprevtoken(const keyword:ansistring);
var
   s:ansistring;
   i,j:integer;
begin
   i:=cp000+insertcount;
   j:=lnb000;
   s:=getmemoLine(j);
   delete(s,i,length(prevtoken));
   insert(keyword,s,i);
   setmemoLine(j,s);
   inc(insertcount,length(keyword)-length(prevtoken));
end;


procedure replacekeyword(const keyword:ansistring; var svcp:tokensave);
var
   s:ansistring;
   i,j:integer;
begin
   i:=svcp.svcp00+svcp.svinsertcount;
   j:=svcp.svlnb00;
   s:=getmemoLine(j);
   delete(s,i,length(svcp.svtoken));
   insert(keyword,s,i);
   setMemoLine(j,s);
   inc(insertcount,length(keyword)-length(svcp.svtoken));
end;

procedure InsertLine(index:integer; const s:ansistring);
begin
   InsertMemoLine(index,s);
   inc(LineNumber);
   inc(lnb);
   inc(lnb0);
   inc(lnb00);
end;

function extract(const svcp:tokensave):ansistring;
begin
     extract:=copy(line,svcp.svcp00,cp00-svcp.svcp00);
end;

function confirm(const msg:ansistring; hc:longint):boolean;
begin
   //memo.lines.EndUpdate;
   SelectToken;
   //memo.lines.BeginUpdate;
   confirm:=
     ( MessageDlg(msg,mtConfirmation,[mbYes,mbNo],hc)=mrYes) ;
end;

function confirmFrom(const svcp:tokensave; const msg:ansistring; hc:longint):boolean;
begin
   //memo.lines.EndUpdate;
   SelectFrom(svcp);   
   //memo.lines.BeginUpdate;
   confirmFrom:=
     ( MessageDlg(msg,mtConfirmation,[mbYes,mbNo],hc)=mrYes) ;
end;

function confirmatLine(linenumb:integer; const msg:ansistring; hc:longint):boolean;
begin
   //memo.lines.EndUpdate;
   SelectLine(TextHand.memo,linenumb);
   //memo.lines.BeginUpdate;
   confirmAtLine:=
     ( MessageDlg(msg,mtConfirmation,[mbYes,mbNo],hc)=mrYes) ;
end;

function NoContinuation:boolean;
begin
   result:=(lnb=linenumber)
end;


procedure DeleteLabelNumber(memo1:TSynEdit);
var
   List:TStringList;
   index,i,j:integer;
   s:AnsiString;
   SvMemo:TSynEdit;
   backup:ansistring;
begin
  backup:=memo1.Lines.Text;
  SvMemo:=memo;
  memo:=memo1;
  List:=TStringList.create;
  List.sorted:=true;
  List.Duplicates:=DupIgnore;
  try
     {分岐先調べ}
     linenumber:=0;
     initline;
     repeat
        while tokenspec<>tail do
           begin
              if ((token='GOTO') or (token='GOSUB') or (token='RESTORE')
                or (token='THEN') or (token='ELSE') or (token='USING'))
                 and (nexttokenspec=NRep) then
                  List.append(nexttoken);
              if (token='GO') then
                 begin
                    gettoken;
                    if ((token='SUB') or (token='TO'))
                        and (nexttokenspec=NRep) then
                        List.append(nexttoken);
                 end;
              gettoken;
           end;
        nextline;
     until outoftext;

     {行番号削除}
     linenumber:=0;
     insertcount:=0;
     initline;
     repeat
        if (prevtokenspec=Nrep) and not List.find(prevtoken,index) then
           begin
                i:=cp000;
                j:=lnb000;
                s:=getmemoLine(j);
                delete(s,i,length(prevtoken));
                if (length(s)>0) and (s[i]=' ') then delete(s,i,1);
                setMemoLine(j,s);
           end;
        SkipLogical;
        nextline;
     until outoftext;
  except
    on E:Exception do
       begin
             ShowMessage(s_DEleteLineNumberFailed);
             memo1.Lines.text:=backup;
       end;
  end;
  List.clear;
  List.Free;
  Memo:=svMemo;
end;

procedure nextlineSimple;
begin
  trying:=0;

  if (token=':') and (nexttoken<>'') and permitMicrosoft then {multi-statement}
     begin
         gettoken;
         exit
     end;

  checkTail;
  if AutoIndent and (pass=1) and not permitMicrosoft then DoIndent;
  lineNumber:=lnb+1;
  initline;
end;


function isVain(const s:string):boolean;  //無効行のときtrue
var
   i:integer;
begin
  result:=true;
  i:=length(s);
  while result and (i>0) do
     begin
        if s[i]<>' ' then result:=false;
        dec(i);
     end;

end;

procedure AddLabelNumber(memo1:TSynEdit);
var
  backup:ansistring;
  initial,delta,current,i:integer;
  SvMemo:TSynEdit;
label
  Exit1;
begin
  backup:=memo1.Lines.Text;
  SvMemo:=memo;
  try
      memo:=memo1;

       //無効行を削除
      i:=memolinecount;
      while (i>0) do
      begin
         dec(i);
         if isVain(getMemoLine(i)) then  DeleteMemoLine(i);
      end;

      //初期値と増分を取得
      with NumberDlg do
        begin
           if MemoLineCount>90 then
             edit1.text:='1000'
           else if MemoLineCount>9 then
             edit1.text:='100'
           else
             edit1.text:='10';
           edit2.text:='10';
           repeat
             if showModal<>mrOk then goto Exit1;
             initial:=StrToIntDef(edit1.text,0);
             delta:=StrToIntDef(edit2.text,0);
           until (initial>0) and (delta>0);
        end;
      //行番号付加
      linenumber:=0;
      initline;
      current:=initial;
        repeat
          if LabelNumber=0 then
             setMemoLine(linenumber, strint(current) + ' ' + getMemoLine(linenumber))
          else if current<=labelNumber then
             current:=LabelNumber
          else
             begin
               raise Exception.create('');
               break;
             end;
          inc(current,delta);
          SkipLogical;
          nextlineSimple;
        until outoftext;
      Exit1:
  except
     on E:exception do
        begin
               ShowMessage(s_SupplementLineNumberFailed);
               memo1.Lines.text:=backup;
        end;
  end;
  Memo:=svMemo;

end;

procedure CaseChange(memo1:TSynEdit);
var
   index,i:integer;
   s:string;
   SvMemo:TSynEdit;
begin
  if convtDLG.showModal=mrOk then
   begin
     SvMemo:=memo;
     memo:=memo1;
     linenumber:=0;
     try
       initline;
       repeat
         while tokenspec<>tail do
            begin
               if tokenspec in [NIdf,SIdf] then
                  begin
                     if keyWordList1.find(token,i)
                        or ((token='ANGLE') and (PrevToken='OPTION'))
                        or ((token='SIZE') and (PrevToken='DEVICE')) then
                        index:=ConvtDLG.radioGroup1.ItemIndex
                     else if keyWordList2.find(token,i) then
                        index:=ConvtDLG.radioGroup2.ItemIndex
                     else
                        index:=ConvtDLG.radioGroup3.ItemIndex;
                     case index of
                        0: ;
                        1:ReplaceToken(token);
                        2:begin s:=token;lower(s); ReplaceToken(s) end ;
                     end;
                  end;
               if (token='DATA') or (token='IMAGE') or (token='REM') then
                   while tokenspec<>tail do gettoken
               else
                   gettoken;
            end;

         nextline;
       until outoftext;
     except
       on E:Exception do
     end;
     Memo:=svMemo;
   end;
end;

procedure FindCorrespondingParenthesis;
var
   svcp:tokensave;
begin
   savetoken(svcp);
   repeat
      gettoken;
      if token='(' then
         FindCorrespondingParenthesis;
   until (token=')') or (tokenspec=tail);
   if token=')' then
      gettoken
   else
      begin
         restoretoken(svcp);
         seterr(s_CorrespondingParenNotFound,{IDH_HELP}0);
      end;
end;


begin
   initIdentifierChar;
end.
