unit io;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}
(***************************************)
(* Copyright (C) 2006, SHIRAISHI Kazuo *)
(***************************************)

 {$X+}

interface

uses  Classes, Dialogs,SysUtils,Controls,
      base,variabl,struct,express;

function MATREADst(prev,eld:TStatement):TStatement;
function MATINPUTst(prev,eld:TStatement):TStatement;
function MATLINEINPUTst(prev,eld:TStatement):TStatement;
function IORecovery(prev:TStatement):TStatement;
procedure RecordSetterClause(var RecordSetter:tpRecordSetter);

implementation

uses
      MainFrm,listcoll,texthand,helpctex,
      mat,textfile,control,graphic,sconsts;

{**********}
{TReadInput}
{**********}
type
  InputFunction=function(ch:TTextDevice; vc:TVarList; count:integer; cont:boolean ):boolean of object;

type
  TReadInput=class(TStatement)
         input:inputfunction;           {nilのとき Varilen}
         chn:TPrincipal;
         recovery:TStatement;
         prompt:TPrincipal;
         timeout:TPrincipal;
         elapsed:TVariable;
         vars : TListCollection;      {collection of TVariable}
         option:IOoptions;
         RecordSetter:tpRecordSetter;
         OnlyStringVars:boolean;
         MSAppendQuestionMark:boolean;
       constructor create(prev,eld:TStatement; f:inputfunction; StrOnly:boolean);
       constructor createREAD(prev,eld:TStatement);
       constructor createINPUT(prev,eld:TStatement);
       constructor createLINEINPUT(prev,eld:TStatement);
       constructor createCHARACTERINPUT(prev,eld:TStatement);
       constructor createVariLen(prev,eld:TStatement);
       function item:TObject;virtual;
       function itemVarilen:TObject;virtual;abstract;
       procedure  exec;override;
       function readsub(ch:TTextDevice):boolean;virtual;
       destructor destroy;override;
     private
       defaultPrompt:string[2];
       function MsPrompt:TPrincipal;
       function ControlItem1:boolean;
       procedure ControlItem2;
       function RegularRead(ch:TTextDevice; vc:TVarList; count:integer; cont:boolean ):boolean;
       function RegularInput(ch:TTextDevice; vc:TVarList; count:integer; cont:boolean ):boolean;
       function LineInput(ch:TTextDevice; vc:TVarList; count:integer; cont:boolean ):boolean;
       function CharacterInput(ch:TTextDevice; vc:TVarList; count:integer; cont:boolean ):boolean;
       function varileninput(ch:TTextDevice; vc:TVarList; var count:integer; cont:boolean ):boolean;
       //function Inputsub(ch:TTextDevice; vc:TVarList;  varilen:boolean ):boolean;
    end;

type
     TMatRead=class(TReadInput)
         function item:TObject;override;
         function itemVarilen:TObject;override;
         function readsub(ch:tTextDevice):boolean;override;
     end;
(*
     TMatVariLenInput=class(TMatRead)
         function item:TObject;override;
         procedure readsub(ch:TTextDevice);override;
     end;
*)



{**************}
{READ statement}
{**************}

function IORecovery(prev:TStatement):TStatement;
begin
     result:=nil;
     if (token='IF') and (nexttoken='MISSING') then
        begin
           gettoken;
           gettoken;
           check('THEN',IDH_FILE);
           if tokenspec=NRep then
              begin
                result:=GOTOst(prev,nil);
                //result.eldest:=result
              end
           else
              begin
                  check('EXIT',IDH_FILE);
                  result:=EXITst(prev,nil);
                  //result.eldest:=result
             end;
       end;
end;


{*********}
{INPUT statement}
{********}


function TReadInput.MsPrompt:TPrincipal;
begin
     result:=nil  ;{default}
     if (tokenspec=SCon) and ((NextToken=';') or (NextToken=',')) then
       begin
           if permitMicrosoft then
              begin
                  if NextToken=';' then MSAppendQuestionMark:=true;
                  result:=SExpression;
                  gettoken;
              end
           else if AutoCorrect[ac_input] or
                  confirm('INPUT PROMPT '+token+': '+EOL+
                          s_IsCorectAskConvert,
                            IDH_MICROSOFT_IO ) then
             begin
               insertText(' PROMPT');
               result:=SExpression;
               replacetoken(':');
               gettoken;
             end;
       end;
end;


destructor TReadInput.destroy;
begin
    vars.free;
    prompt.free;
    recovery.free;
    chn.free;
    inherited destroy
end;


function TReadInput.ControlItem1:boolean;
var
  CharInput:InputFunction;      // input変数の値を比較するために使用する
begin
    CharInput:=Characterinput;
    result:=true;
    if (token='#')  then
       chn:=channelExpression
    else if (token='IF') and (nexttoken='MISSING') then
         recovery:=IORecovery(self)
    else if (token='PROMPT') and (nextToken<>',')  then
       begin
         gettoken;
         prompt:=SExpression
       end
    else if (token='TIMEOUT') and (nextToken<>',')  then
       begin
         gettoken;
         timeout:=NExpression
       end
    else if (token='ELAPSED') and (nextToken<>',')  then
       begin
         gettoken;
         elapsed:=NVariable
       end
    else if (token='CLEAR') and (@input=@charInput) then
       begin
         gettoken;
         Option:=option + [ioClear]
       end
    else if (token='NOWAIT') and (@input=@charInput) then
       begin
         gettoken;
         Option:=option + [ioNoWait]
       end
    else
       result:=false;
end;

procedure TReadInput.ControlItem2;
var
  CharInput:InputFunction;      // input変数の値を比較するために使用する
begin
  CharInput:=Characterinput;

    if (token='IF') and (nexttoken='MISSING') and (recovery=nil) then
       recovery:=IORecovery(self)
    else if (token='PROMPT')  and (prompt=nil) then
       begin
         gettoken;
         prompt:=SExpression
       end
    else if (token='TIMEOUT')  and (timeout=nil) then
       begin
         gettoken;
         timeout:=NExpression
       end
    else if (token='ELAPSED')  and (elapsed=nil) then
       begin
         gettoken;
         elapsed:=NVariable
       end
    else if (token='CLEAR') and (@input=@charInput) then
       begin
         gettoken;
         Option:=option + [ioClear]
       end
    else if (token='NOWAIT') and (@input=@charInput) then
       begin
         gettoken;
         Option:=option + [ioNoWait]
       end
    else
       RecordSetterClause(RecordSetter);
end;

procedure RecordSetterClause(var RecordSetter:tpRecordSetter);
begin
    if (token='BEGIN') then
       begin
         gettoken;
         RecordSetter:=rsBegin;
       end
    else if (token='END') then
       begin
         gettoken;
         RecordSetter:=rsEnd;
       end
    else if (token='NEXT') then
       begin
         gettoken;
         RecordSetter:=rsNext;
       end
    else if (token='SAME') then
       begin
         gettoken;
         RecordSetter:=rsSAME;
       end
end;

constructor TReadInput.create(prev,eld:TStatement; f:inputfunction; StrOnly:boolean);
var
   p:TObject;
begin
   inherited create(prev,eld);
   OnlyStringVars:=StrOnly;
   RecordSetter:=rsNone;
   if InsideOfWhen then option:=[ioWhenInside];
   input:=f;
   defaultprompt:='? ';
   prompt:=MsPrompt;
   if prompt=nil then
   begin
      if ControlItem1 then
         begin
            while test(',') do
               ControlItem2;
            check(':',IDH_INPUT_PROMPT);
         end;
   end;
   vars:=TListCollection.create;
   if (self is TMatRead)
        and (@input=@TReadInput.regularinput)
        and (nextnexttoken='?') then
     begin
       input:=nil;
       Vars.insert(itemVarilen);
     end
   else
     repeat
       if (prevtoken=',') and (token='SKIP') and (nexttoken='REST') then
          begin
             gettoken;
             gettoken;
             option:=option+[ioSkipRest];
             break;
          end;
       if StrOnly and (TokenSpec<>SIdf) then
                         seterrexpected(s_StringIdentifier,IDH_MAT_INPUT);
       p:=item;
       vars.insert(p);
     until test(',')=false;
   if ProgramUnit.CharacterByte then option:=option+[ioCharacterByte];
end;


function TReadInput.item;
begin
   result:=Inputvari(OnlyStringVars)
end;


constructor TReadInput.createREAD(prev,eld:TStatement);
begin
     Create(prev,eld,regularRead,false);
     option:=option+[ioReadWrite];
end;

constructor TReadInput.createINPUT(prev,eld:TStatement);
begin
     Create(prev,eld,regularInput,false);
end;

constructor TReadInput.createLINEINPUT(prev,eld:TStatement);
begin
     Create(prev,eld,LineInput,true);
end;

constructor TReadInput.createCHARACTERINPUT(prev,eld:TStatement);
begin
     Create(prev,eld,CharacterInput,true);
     defaultprompt:='';
     if chn=nil then
        useCharInput:=true;
end;

constructor TReadInput.createVariLen(prev,eld:TStatement);
begin
     Create(prev,eld,nil{VariLenInput},false);
end;

procedure  TReadInput.exec;
var
   prom:ansistring ;
   ch:TTextDevice;
   timelimit:Double;
   starttime:double;
   x:double;
begin
    if (chn=nil) and (ioReadWrite in option) then
       ch:=PUnit.DataSeq
    else
       ch:=channel(chn,Proc,Punit);
    if ch=nil then setexception(7004);
    ch.CheckForInput(option);

    if prompt<>nil then
       begin
              prom:=prompt.evalS ;
              if permitMicrosoft and MSAppendQuestionMark then
                 prom:=prom+'? ';
       end
    else
         prom:=DefaultPrompt;

    if timeout<>nil then
       begin
          x:=timeout.evalX;
          timeLimit:=now+(x/86400. );
          if x<0 then
                    setexception(8402)
       end
    else timeLimit:=MaxNumberDouble;
    starttime:=now;

    ch.initInput(LineNumb,prom,TimeLimit);

    ch.Setpointer(RecordSetter,insideofWhen);
    if ch.DataFoundForRead
         and  readsub(ch) then       //8.0.1.3
    else
      if recovery=nil then
         setexception(extype)
      else
         begin
             extype:=0;
             recovery.exec;
         end;

    if (elapsed<>nil) and (extype<>8401) then
       elapsed.assignX((now-starttime)*86400. );


end;


function TReadInput.readsub(ch:TTextDevice):boolean;
var
   i:integer;
   vc:TVarList;
begin
    vc:=TVarList.create(Vars.Count);
    try
       for i:=0 to Vars.count-1 do
                        vc.add(TInputVari(Vars.items[i]));
       result:=Input(ch,vc,vc.count,false) ;  //ver.  8.0.1.3
    finally
      vc.deleteall;
      vc.free;
    end;
end;

function TReadInput.RegularRead(ch:TTextDevice; vc:TVarList; count:integer; cont:boolean ):boolean;
begin
    result:= ch.ReadData(vc, count, cont,option) ;       //ver.  8.0.1.3
end;

function TReadInput.RegularInput(ch:TTextDevice; vc:TVarList; count:integer; cont:boolean ):boolean;
begin
   result:=ch.InputData(vc, count,cont,option)
end;

function TReadInput.LineInput(ch:TTextDevice; vc:TVarList; count:integer; cont:boolean ):boolean;
begin
   result:=true;
   ch.LineInput(vc,count,option)
end;

function TReadInput.CharacterInput(ch:TTextDevice; vc:TVarList;  count:integer; cont:boolean):boolean;
var
    index:integer;
    inputline:ansistring;
begin
    result:=true;
    index:=0;
    while index<count do
        begin
            ch.characterInput(inputline,option);
            if not(ioNoWait in option) or (inputLine<>'') then  //2011.5.27
               TVar(vc.items[index]).read(inputline);
            inc(index);
        end;
end;




function INPUTst(prev,eld:TStatement):TStatement;
begin
     TextMode:=true;
     INPUTst:=TReadInput.createINPUT(prev,eld)
end;

function READst(prev,eld:TStatement):TStatement;
begin
        READst:=TReadInput.createREAD(prev,eld)
end;

function LINEst(prev,eld:TStatement):TStatement;
begin
   if permitMicrosoft and ((token='(') or (token='-')) then
     LINEst:=MSLINEst(prev,eld)
   else
     begin
       check('INPUT',IDH_LINE_INPUT);
       LINEst:=TREADINPUT.createLINEINPUT(prev,eld)
     end;
end;

function CHARACTERst(prev,eld:TStatement):TStatement;
begin
    check('INPUT',IDH_CHARACTER_INPUT);
    CHARACTERst:=TREADINPUT.createCHARACTERINPUT(prev,eld)
end;




{*********}
{Mat Read }
{Mat Input}
{*********}
type  TRedimArray=class
           mat:TMatrix;
           redim:TMatRedim;
         constructor create(mat1:TMatrix);
         function GetPoint(var p:TArray):boolean;
         destructor destroy;override;
      end;

constructor TRedimArray.create;
begin
   inherited create;
    mat:=mat1;
    redim:=Matredim(mat,false);
end;

destructor TRedimArray.destroy;
begin
   mat.free;
   redim.free;
   inherited destroy;
end;

function TRedimArray.GetPoint(var p:TArray):boolean;
begin
   TVar(p):=mat.point;
   result:=(p<>nil) and ((redim=nil) or redim.exec)
end;

function TReadInput.varileninput(ch:TTextDevice; vc:TVarList; var count:integer; cont:boolean ):boolean;
begin
    result:=true;
    ch.inputVarilen(vc,count,option);
end;


function TMatRead.item:Tobject;
var
   mat1:TMatrix;
begin
   mat1:=Matrix;
   result:=TRedimArray.create(mat1);
end;

function TMatRead.itemVariLen:Tobject;
var
   mat1:TMatrix;
begin
    mat1:=Matrix;
    if mat1.idr.dim<>1 then
               seterrDimension(IDH_MAT_INPUT);
    check('(',IDH_MAT_INPUT);
    check('?',IDH_MAT_INPUT);
    check(')',IDH_MAT_INPUT);
    result:=TRedimArray.create(mat1);
end;

function TMatRead.readsub(ch:TTextDevice):boolean;
var
   i,j,k:integer;
   p:TArray;
   vl:TVarList;
   vc:integer;
   al:TList;
   cont:boolean;
begin
   result:=true;
   al:=TList.Create;
   vc:=0;
   cont:=true;
   try
       for i:=0 to Vars.count-1 do
           begin
              cont:=cont and TRedimArray(Vars.items[i]).GetPoint(p);
              if cont then
                begin
                  al.Add(p);
                  vc:=vc+p.amount;
                end;
           end;
       if cont then
          try
             vl:=TVarList.create(vc);
             for i:=0 to al.Count-1 do
                begin
                    p:=TArray(al.Items[i]);
                    for j:=0 to p.amount-1 do
                        vl.Add(p.ItemSubstance0(j,false));
                end;
             if @Input <> nil then
                 result:= Input(ch, vl, vc ,false)            //ver. 8.0.1.3
             else
                 result:= VarilenInput(ch, vl, p.size[1], false);   //ver. 8.0.1.3
          finally
              k:=0;
              for i:=0 to al.Count-1 do
                begin
                   p:=TArray(al.Items[i]);
                   for j:=0 to p.amount-1 do
                     begin
                         p.DisposeSubstance0(TVar(vl.Items[k]),false);
                         inc(k);
                     end;
                end;
              vl.deleteall;
              vl.Free;
          end;
   finally
      al.Free;
   end;
end;

function MATREADst(prev,eld:TStatement):TStatement;
begin
    result:=TMatRead.createREAD(prev,eld)
end;

function MATINPUTst(prev,eld:TStatement):TStatement;
begin
      result:=TMatRead.createINPUT(prev,eld)
end;

function MATLINEINPUTst(prev,eld:TStatement):TStatement;
begin
    result:=TMatRead.createLINEINPUT(prev,eld)
end;


procedure statementTableinit;
begin
   StatementTableInitImperative('INPUT',INPUTst);
   StatementTableInitImperative('LINE',LINEst);
   StatementTableInitImperative('CHARACTER',CHARACTERst);
   StatementTableInitImperative('READ',READst);
end;

procedure functiontableInit;
begin
end;


begin
   tableInitProcs.accept(statementTableinit);
   tableInitProcs.accept(FunctionTableInit);
end.

