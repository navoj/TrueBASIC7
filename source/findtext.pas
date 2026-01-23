unit findtext;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

(***************************************)
(* Copyright (C) 2003, SHIRAISHI Kazuo *)
(***************************************)


interface
uses  Classes, StdCtrls, ComCtrls, Dialogs, SynEdit,Sysutils,Forms,
      base,arithmet;

//function FindWord(memo:TMemo; const SearchStr: string; StartPos, Len: Integer; Options: TSearchTypes): Integer;
function FindWord(memo:TSynEdit; const SearchStr: string; StartPos, Len: Integer;Options: TFindOptions): Integer;
//function MultiLine(var s:string):boolean;
function MultiLine(const s:string):boolean;
function SearchText(Memo:TSynEdit; const s:string; n,searchlen:integer; Options1:TFindOptions):integer;

implementation
uses strutils,
     sconsts;

const PunctuationCharactors :set of char
             =[chr(0)..' ', '!', '#', '&'..'/', ':'..'?','\', '^'];

function token(memo:TSynEdit; var cp0,cp:integer):string;
 var
  memotextlen:integer;

  function t(p:integer):char;
  var
    s:string[1];
  begin
    result:=#0;
    if p<memotextlen then
    with memo do
    begin
      selstart:=p;
      selend:=p+1;   //sellength:=1;
      s:=seltext;
      if length(s)>0 then
         result:=s[1];
    end;
  end;

begin
  memotextlen:=length(memo.text);
     while t(cp) in [#13,#10,' '] do inc(cp);
     cp0:=cp;
     if t(cp) in ['<','=','>'] then
       begin
         inc(cp);
         if t(cp) in ['<','=','>'] then
           inc(cp)
       end
     else if t(cp)='"' then
        repeat
          repeat
            inc(cp);
          until t(cp) in [#0,#13,#10,'"'];
          if t(cp)='"' then inc(cp);
        until (t(cp)<>'"') or ((cp>=memotextlen))
     else if (cp<memotextlen) and (t(cp) in PunctuationCharactors) then
       inc(cp)
     else
       while (cp<memotextlen) and not(t(cp) in PunctuationCharactors) do
                                           inc(cp);
     with memo do
        begin
          selstart:=cp0;
          SelEnd:=cp;   //sellength:=cp-cp0;
          result:=seltext;
        end;
end;


function FindWord(memo:TSynEdit; const SearchStr: string;
                  StartPos, Len: Integer; Options:TFindOptions): Integer;
var
  cp,cp0:integer;
  s,s1:string;
begin
  result:=-1;
  s1:=SearchStr;
  if not(frMatchCase in options)  then s1:=Uppercase(s1);

  cp:=StartPos;
  memo.Lines.BeginUpdate;
  while (cp-Startpos<len) and (cp<length(memo.text)) do    //ver.8.1.5.2 //2026.11.06
   begin
     s:=token(memo,cp0,cp);
     if cp=length(memo.text)  then
              begin result:=-1;  break end;
     if not(frMatchCase in Options) then s:=UpperCase(s);
     if s=s1 then
              begin result:=cp0; break end;
   end;
   memo.lines.EndUpdate
end;

function MultiLine(const s:string):boolean;
var
  cp0,cp:integer;
begin
  cp:=1;
  result:=(pos(EOL,s)>0);
(*
  if result then
    begin
       s:=token(s,cp0,cp);
       if (length(s)=1) and (s[1] in PunctuationCharactors) then s:=''
    end
*)    
end;

function SearchText(memo:TSynEdit;const  s:string; n,SearchLen:integer; Options1:TFindOptions):integer;
var
  i:integer;
  cond:boolean;
  SearchText:ansistring;
  wholetext:ansistring;
begin
  SearchText:=s;
  WholeText:=copy(memo.Text, n,SearchLen);
  if not(frMatchCase in Options1) then
      begin
         SearchText:=UpperCase(s);
         WholeText:=UpperCase(WholeText);
      end;
  result:=Pos(SearchText,WholeText)-1;
  if result>=0 then
     result:=result+n;
  {
  with Memo do
  begin
    Lines.BeginUpdate;
    for i:=n to base.min(length(Text)-len+1,n+searchlen) do
      begin
        selstart:=i;
        selend:=i+len;  // sellength:=len;
        if frMatchCase in Options1 then
          cond:=(seltext=s)
        else
          cond:=comparetext(seltext,s)=0;
        if cond then
           begin
              result:=i;
              break;
           end;
      end;
    Lines.EndUpdate;
    end;
    }

end;


end.
