unit kwlist;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}
(***************************************)
(* Copyright (C) 2003, SHIRAISHI Kazuo *)
(***************************************)


interface
uses classes, Forms,SysUtils,Dialogs,SynEditHighlighter;

type
   TKeyWordList=Class(TStringList)
       constructor create(ch:char);
       procedure PulOut(t:string);
   end;






type
  StatementKind=(kdNone, kdIF, kdDEF, kdLET, kdFunctionSubPicture,
                 kdMODULE ,kDEND, kdMAT, kdDRAW, kdREM, kdDataImage,
                 kdDeclare,kdDIM, kdAny);

type
   TKeyWordList1=Class(TStringList)
     Attr:TSynHighlighterAttributes;
     constructor create(name0:string; Attr0:TSynHighlighterAttributes);
  public
     name:string;
     kind:StatementKind;
     functionAllowed:boolean;
     TogetherWith:TStringList;
   end;

   TKeyWordList2=Class(TKeyWordList1)
       constructor create(name0:string; Attr0:TSynHighlighterAttributes);
   end;

   TStatementKWList=class(TKeyWordList1)
          constructor create;
   end;
var
   KeywordList1 {statements},
   KeywordList2 {functions},
   KeywordList3 {matrix functions},
   ReservedWord                 :TKeywordList;
   DummyTBL:TKeywordList2;  //不正なコマンド
   CommentRange:TKeyWordList2;
   //BlockTbl, DeclatTbl, ImperatTbl, ImperatExTbl :TkeywordList2;
   StatementKWList:TStatementKWList;
   InsideString:boolean;

var
    StringAttri: TSynHighlighterAttributes;
    CommentAttri: TSynHighlighterAttributes;
    ParamsAttri: TSynHighlighterAttributes;
     DeclativeAttri: TSynHighlighterAttributes;
     BlockAttri: TSynHighlighterAttributes;
     ImperativeAttri: TSynHighlighterAttributes;
     BranchAttri: TSynHighlighterAttributes;


implementation
uses  Graphics,
      base;


Constructor TKeywordList.create(ch:char);
var
  F:TextFile;
  s,n:string;
begin
   inherited create;
   sorted:=true;
   n:=ChangeFileExt(Application.ExeName,'.kw')+ch;
   AssignFile(F,n);
   try
       reset(F);
       while not EOF(F) do
        begin
          readln(F,s);
          add(s);
        end;
        close(F);
   except
       showMessage(n+' Not Found');
   end;

end;

procedure TKeywordList.PulOut(t:string);
var
  i,j:integer;
begin
  if find(t,i) and not ReservedWord.find(t,j) then
     delete(i)
end;

type
   TCreatedLists=class(TStringList)
   destructor destroy;override;
 end;

destructor TCreatedLists.destroy;
var
  i:integer;
  begin
     for i:=0 to Count-1 do
        if (Objects[i]<>nil) then
                Objects[i].Free;
    inherited destroy;
  end;

Var
   CreatedLists:TCreatedLists;

Constructor TKeywordList1.create(name0:string; Attr0:TSynHighlighterAttributes);
begin
  inherited create;
  name:=name0;
  kind:=kdNone;
  if name0='IF' then
     kind:=kdIF
  else if name0='DEF' then
     kind:=kdDEF
  else if name0='LET' then
     kind:=kdLET
  else if (name0='FUNCTION') or (name0='SUB') or (name0='PICTURE') then
     kind:=kdFunctionSubPicture
  else if name0='MODULE' then
     kind:=kdModule
  else if name0='END' then
     kind:=kdEND
  else if name0='MAT' then
     kind:=kdMAT
  else if name0='DRAW' then
     kind:=kdDRAW
  else if name0='REM' then
     kind:=kdREM
  else if (name0='DATA') or (name0='IMAGE')  then
     kind:=kdDataImage
  else if (name0='DECLARE') or (name0='PUBLIC') or (name0='SHARE') then
     kind:=kdDeclare
  else if name0='DIM' then
     kind:=kdDIM
  //else if name0='*any' then
  //   kind:=kdAny
;
  //name:=name0;
  Attr:=Attr0;
  CreatedLists.AddObject('',self);
end;

Constructor TKeywordList2.create(name0:string; Attr0:TSynHighlighterAttributes);


begin
   inherited create(name0, Attr0);
   sorted:=true;
end;

Constructor TStatementKWList.create;
var
  F:TextFile;
  l,s,t,n:string;
  sl:TStringList;
  i:integer;
  ch:char;
  functionAllowed0:boolean;
  attr0:TSynHighlighterAttributes;


     procedure makeList(list0,List00:TKeywordList1);
     var
       List,List1:TKeywordList1;
       t:string;
       repeatable:boolean;
     begin
       repeatable:=false;
        while i<sl.count do
         begin
            t:=sl.Strings[i];
           // if t='NAME' then         //debug
           //    t:=t;                 //break point
            inc(i);
            if t='{' then
                begin
                   List1:=TKeywordList1.create(s,attr0);
                   List1.functionAllowed:=FunctionAllowed0;
                   with List0 do Objects[Count-1]:=List1;
                   if List00=nil then
                         makeList(list1,nil)
                   else
                         MakeList(List1,List00);
                 end
            else if t='}' then
                 begin
                   List0.sorted:=true;
                   exit;
                 end
            else if t='%' then
               List00:=List0
            else if t='@' then
               list0.TogetherWith:=keywordList2
            else if t='*any' then
               begin
                List0.kind:=kdAny;
                List0.AddObject(t,List00)
               end
            else if t='=' then
               begin
                List0.attr:=nil;
                List0.AddObject(t,List00)
               end
            else
              begin
                List0.AddObject(t,List00)
              end;
         end;
        //sorted:=true;
     end;

begin
   inherited create('', nil);
   sl:=TStringList.create;
   for ch in 'bdgix' do
     begin
         case ch of
           'b':begin attr0:=BlockAttri;       functionAllowed0:=false end;
           'd':begin attr0:= DeclativeAttri;  functionAllowed0:=false end;
           'g':begin attr0:= BranchAttri;     functionAllowed0:=false end;
           'i':begin attr0:=ImperativeAttri;  functionAllowed0:=false end;
           'x':begin attr0:=ImperativeAttri;  functionAllowed0:=true  end;
         end;
         n:=ChangeFileExt(Application.ExeName,'.kw')+ch;
         AssignFile(F,n);
         try
             reset(F);
             while not EOF(F) do
              begin
                Readln(F,l);
                if l='' then break;
                sl.CommaText:=l;
                s:=sl.Strings[0];
                t:=''; if sl.count>1 then t:=sl.Strings[1];
                if t='*comment' then
                   AddObject(s,CommentRange)
                else if t='' then
                   AddObject(s,TKeywordList2.create(s,attr0))
                else
                  begin
                     i:=0;
                     //Add(s);
                     MakeList(self,nil)
                  end;
              end;
              close(F);
         except
             showMessage(n+' Not Found');
         end;
     end;
   sorted:=true;
   sl.free;
end;





initialization
  (* Create and initialize the attributes *)

  BlockAttri := TSynHighlighterAttributes.Create('block', 'block');
  BlockAttri.Style := [fsBold];
  BlockAttri.Foreground :=clBlue {clRed} {clBlue};

  DeclativeAttri := TSynHighlighterAttributes.Create('declative', 'declative');
  DeclativeAttri.Style := [fsBold];
  DeclativeAttri.Foreground :=clGray {clDkGray} {clOlive}  {clMaroon}  ;

  ImperativeAttri := TSynHighlighterAttributes.Create('imperative', 'imperative');
  //ImperativeAttri.Style := [fsBold];
  ImperativeAttri.Foreground :={clGreen} clPurple ;

  ParamsAttri := TSynHighlighterAttributes.Create('identif', 'identif');
  ParamsAttri.Foreground :={clPurple} clGreen {clOlive} {clRed} ;

  StringAttri := TSynHighlighterAttributes.Create('string', 'string');
  StringAttri.Foreground :=clNavy {clRed} {clTeal} {clOlive};

  CommentAttri := TSynHighlighterAttributes.Create('comment', 'comment');
  CommentAttri.Style := [{fsBold} {fsItalic}];
  CommentAttri.Foreground :=clOlive {clDkGray} {clGreen} {clFuchsia} {clRed} ;

  BranchAttri := TSynHighlighterAttributes.Create('branch', 'branch');
  BranchAttri.Foreground :=clRed ;

  with TMyIniFile.create('kwlist') do
   begin
       BlockAttri.Foreground:= ReadInteger('BlockAttri',BlockAttri.Foreground);
       DeclativeAttri.Foreground:=ReadInteger('DeclativeAttri',DeclativeAttri.Foreground );
       ImperativeAttri.Foreground:=ReadInteger('ImperativeAttri', ImperativeAttri.Foreground);
       ParamsAttri.Foreground:=ReadInteger('ParamsAttri',ParamsAttri.Foreground );
       StringAttri.Foreground :=ReadInteger('StringAttri',StringAttri.Foreground);
       CommentAttri.Foreground:=ReadInteger('CommentAttri', CommentAttri.Foreground);
       BranchAttri.Foreground:=ReadInteger('BranchAttri',BranchAttri.Foreground );
       free
   end;



  keywordlist1:=TKeywordList.create('1');
  keywordList2:=TKeywordList.create('2');
  keywordList3:=TKeywordList.create('3');
  ReservedWord:=TKeywordList.create('r');

  CreatedLists:=TCreatedLists.Create;
  DummyTBL:=TKeywordList2.create('',nil);
  DummyTBL.sorted:=true;
  CommentRange:=TKeyWordList2.create('comment',CommentAttri);
  StatementKWList:=TStatementKWList.create;



finalization

//StatementKWList.free;
//CommentRange.free;
//DummyTBL.free;
with TMyIniFile.create('kwlist') do
   begin
       WriteInteger('BlockAttri',BlockAttri.Foreground );
       WriteInteger('DeclativeAttri',DeclativeAttri.Foreground );
       WriteInteger('ImperativeAttri',ImperativeAttri.Foreground );
       WriteInteger('ParamsAttri',ParamsAttri.Foreground );
       WriteInteger('StringAttri',StringAttri.Foreground );
       WriteInteger('CommentAttri',CommentAttri.Foreground );
       WriteInteger('BranchAttri',BranchAttri.Foreground );
       free
   end;

CreatedLists.free;

ReservedWord.free;
keywordlist3.free;
keywordlist2.free;
keywordlist1.free;


end.
