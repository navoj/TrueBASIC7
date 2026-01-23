unit control;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

(***************************************)
(* Copyright (C) 2006, SHIRAISHI Kazuo *)
(***************************************)


{********}
interface
{********}
uses Classes,SysUtils, Forms, Dialogs, Controls,
    variabl,struct,express;

type
   TForStructure=class(TStatement)
           controlVar:TSubstance;//TVariable;
           own1,own2 :TSubstance;//TVariable;
           Block     :TStatement;
           initial   :TPrincipal;
           limit     :TPrincipal;
           increment :TPrincipal;
           variable  :AnsiString;
        constructor create(prev,eld:TStatement);
        procedure CollectLabelInfo(t:TLabelNumberTable);override;
        function SetBreakPoint(i:integer; b:boolean):boolean;override;
        destructor destroy;override;
        procedure  exec;override;
        procedure  execloop;
   end;

   TDoStructure=class(TStatement)
             cond1 : TLogical;
             until1: boolean;
             Block : TStatement;
        constructor create(prev,eld:TStatement);
        procedure CollectLabelInfo(t:TLabelNumberTable);override;
        function SetBreakPoint(i:integer; b:boolean):boolean;override;
        destructor destroy;override;
        procedure  exec;override;
   end;

function GOTOst(prev,eld:TStatement):TStatement;
function EXITst(prev,eld:TStatement):TStatement;
function STOPst(prev,eld:TStatement):TStatement;

{************}
implementation
{************}
uses
    variabls,variablc,helpctex,base,texthand,math2sub,sconsts;

{*****************}
{control Structure}
{*****************}

function GOTOst(prev,eld:TStatement):TStatement;
begin
    GOTOst:=TGOTO.create(prev,eld)
end;

{********}
{GOSUB st}
{********}

type
   TGOSUB=class(TGOTO)
       procedure exec;override;
    end;

function GOSUBst(prev,eld:TStatement):TStatement;
begin
    GOSUBst:=TGOSUB.create(prev,eld)
end;

function GOst(prev,eld:TStatement):TStatement;
begin
    if token='SUB' then
       begin
          gettoken;
          GOst:=GOSUBst(prev,eld)
       end
    else
      begin
        checkToken1('TO',IDH_CONTROL);
        GOst:=GOTOst(prev,eld);
      end;
end;


{************}
{if structure}
{************}

type
   TCustomIfStatement=class(TSTatement)
          condition   :TLogical;
          thenBlock   :TStatement;
          ElseBlock   :TStatement;
      constructor create(prev,eld:TStatement; cond1:TLogical);
      destructor destroy;override;
      procedure  exec;override;
    end;

   TIfStructure=class(TCustomIfStatement)
          InitialLine:TStatement;
      constructor create(prev,eld:TStatement; cond1:TLogical; ini:TStatement);
      procedure  exec;override;
      procedure CollectLabelInfo(t:TLabelNumberTable);override;
      function SetBreakPoint(i:integer; b:boolean):boolean;override;
   end;

   TIfStatement=class(TCustomIfSTatement)
      constructor create(prev,eld:TStatement; cond1:TLogical);
      procedure  exec;override;
   end;

constructor TCustomIfStatement.create(prev,eld:TStatement; cond1:TLogical);
begin
   inherited create(prev,eld);
   condition:=cond1;
end;

destructor TCustomIfStatement.destroy;
begin
    ElseBlock.free;
    thenblock.free;
    condition.free;
    inherited destroy
end;

procedure TIfStructure.CollectLabelInfo(t:TLabelNumberTable);
begin
   t.additem(self);
   if ThenBlock<>nil then ThenBlock.CollectLabelInfo(t);
   if ElseBlock<>nil then  ElseBlock.CollectLabelInfo(t);
   if next<>nil then next.CollectLabelInfo(t);
end;

function TIfStructure.SetBreakPoint(i:integer; b:boolean):boolean;
begin
  if i=LineNumb then
     result:=changeStopKeySence(b)
  else
    result:=(ThenBlock<>nil) and ThenBlock.SetBreakPoint(i,b)
          or (ElseBlock<>nil) and ElseBlock.SetBreakPoint(i,b)
          or (next<>nil) and next.SetBreakPoint(i,b)
end;


{*******}
{compile}
{*******}

function imperativest(prev,eld:TStatement):TStatement;
var
    prc:StatementFunction;
    sp:statementspec;
    p:TStatement;
begin
    result:=nil;

    if (token='IF')  and not permitMicrosoft and (AutoCorrect[ac_multi] or
       confirm(s_IFTHENCorrectConfirm,IDH_MicroSoft_CONTROL) ) then
           NestedIfStatement;

    if (token='END') then
       if permitMicrosoft then
          begin result:=STOPst(prev,eld);gettoken;exit end
       else if (AutoCorrect[ac_end] {or
        confirm(s_ENDCorrectConfirm,IDH_MICROSOFT_CONTROL)}) then
        begin
           replaceToken('STOP');
           raise ERecompile.create('');
        end;

    if statementTable.find(token,prc,sp)
       and ((sp=imperative) or permitMicrosoft and (sp=structural) )then
       begin
          gettoken;
          result:=prc(prev,eld);
       end
    else
       result:=tryLETst(prev,eld);

    if (result<>nil) and (permitMicrosoft) and (token=':') then
          begin
             gettoken;
             result.next:=imperativest(result,eld);
          end;

end;

{************}
{IF Statement}
{************}

function IFstSub(prev,eld,ini:TStatement; elseifst:boolean):TCustomIfStatement;forward;
function IFst(prev,eld:TStatement):TStatement;
begin
   IFline:=true;
   IFst:=IFstSub(prev,eld,nil,false)
end;

function IFstSub(prev,eld,ini:TStatement; elseifst:boolean):TCustomIfStatement;
var
  condition:TLogical;
begin
  condition:=relationalExpression;
  checkToken('THEN',IDH_IF);
  SaveToken(SvThenBlockPos);
  result:=nil;
  try
    if (tokenspec<>tail)
       and not(permitMicrosoft and (token=':'))
       and not elseifst then
         result:=TIfStatement.create(prev,eld,condition)
    else
         result:=TIfStructure.create(prev,eld,condition,ini)
  except
    result.free;
    raise
  end;
end;

constructor TIfStatement.create(prev,eld:TStatement; cond1:TLogical);
begin
    inherited create(prev,eld,cond1);
    if tokenspec=NRep then
        begin
          thenBlock:=TGOTO.create(self,nil);
          //if thenBlock<>nil then thenBlock.eldest:=thenBlock;
          if (token='ELSE') and (NextTokenSpec=Nrep) then
             begin
                 gettoken;
                 ElseBlock:=TGOTO.create(self,nil);
                 //if ElseBlock<>nil then ElseBlock.Eldest:=ElseBlock;
             end;
       end
    else
       begin
          thenBlock:=imperativest(self,nil);
          //SetEldest(thenBlock);
          if token='ELSE' then
             begin
                 gettoken;
                 ElseBlock:=imperativest(self,nil);
                 //setEldest(ElseBlock);
             end;
       end;
end;

constructor TIfStructure.create(prev,eld:TStatement; cond1:TLogical; ini:TStatement);
var
  p:TStatement;
begin
  inherited create(prev,eld,cond1);
  if ini<>nil then
     InitialLine:=ini
  else
     InitialLine:=self ;
  nextline;
  thenblock:=block(self);
  p:=Last(ThenBlock);
  if p is TTerminal then
     TTerminal(p).statement:=initialLine;
  if token='ELSEIF' then
     begin
         gettoken;
         ElseBlock:=IFstSub(self,nil,initialLine,true) ;
         //if ElseBlock<>nil then setEldest(ElseBlock);
      end
  else
      begin
         if token ='ELSE' then
            begin
               gettoken;
               nextline ;
               ElseBlock:=block(self);
               p:=last(ElseBlock);
               if p is TTerminal then
               TTerminal(p).statement:=initialLine;
            end;
         checktoken1('END',IDH_IF);
         checktoken('IF',IDH_IF);
      end;
end;

function ELSEst(prev,eld:TStatement):TStatement;
begin
   result:=TTerminal.create(prev,eld)
end;

{********}
{FOR NEXT}
{********}
type
   TNEXT=class(TStatement)
        controlVar,own1,own2:TSubstance;//TVariable;   {copy pointer,参照のみ}
        procedure  exec;override;
   end;

   TFNEXT=class(TNEXT)
        procedure  exec;override;
   end;

   TFsimpleNEXT=class(TNEXT)
        procedure  exec;override;
   end;

   TCNEXT=class(TNEXT)
        procedure  exec;override;
   end;


procedure TForStructure.CollectLabelInfo(t:TLabelNumberTable);
begin
   t.additem(self);
   if Block<>nil then Block.CollectLabelInfo(t);
   if next<>nil then next.CollectLabelInfo(t);
end;

function TForStructure.SetBreakPoint(i:integer; b:boolean):boolean;
begin
  if i=LineNumb then
     result:=changeStopKeySence(b)
  else
       result:=(Block<>nil) and Block.SetBreakPoint(i,b)
             or (next<>nil) and next.SetBreakPoint(i,b)
end;


destructor TForStructure.destroy;
begin
   controlVar.free;
   initial.free;
   limit.free;
   increment.free;
   Block.free;
   //own1.free;
   //own2.free;
   inherited destroy
end;



function  FORst(prev,eld:TStatement):TStatement;
begin
   Forst:=TForStructure.create(prev,eld)
end;

procedure checkForVariable;
var
   i:integer;
begin
   with ForStack do
       for i:=0 to count-1 do
           if (TObject(items[i]) as TForStructure).variable=token then
              seterr(s_NestedSameVarFOR,IDH_FOR_NEXT);
end;

constructor TForStructure.create(prev,eld:TStatement);
var
      p:TStatement;
      idrec:TIdRec;
begin
       inherited create(prev,eld);
       {inc(ForNest);}
       if ForStack.count>0 then CheckForVariable;
       ForStack.add(self);
       {control variable}
       variable:=token;
       controlVar:=simpleVariable;
       checktoken('=',IDH_FOR_NEXT);
       initial:=NExpression;
       checktoken('TO',IDH_FOR_NEXT);
       limit:=NExpression;
       if token='STEP' then
          begin
              gettoken;
              increment:=NEXpression
          end;
       nextline;

       if pass=2 then
          begin
             idrec:=TIdRec.initSimple('',intern,maxint);
             own1:=idrec.subs;
             if ForNextBroadOwn then
                ProgramUnit.VarTable.add(idrec)
             else
                Proc.VarTable.add(idrec);        //2008.4.2
             idrec:=TIdRec.initSimple('',intern,maxint);
             own2:=idrec.subs;
             if ForNextBroadOwn then
                ProgramUnit.VarTable.add(idrec)
             else
                Proc.VarTable.add(idrec);        //2008.4.2
          end;

       Block:=struct.block(self);
       with ForStack do delete(count-1); {Dec(ForNest);}
       checktoken1('NEXT',IDH_FOR_NEXT);

      if token=variable then
          gettoken
      else
          if permitMicrosoft then
          else
           if (autocorrect[ac_next] or
              confirm(variable+s_IsExpected+s_InquireInsert,IDH_FOR_NEXT))
              and (token='') then
              inserttext(variable)
           else
             seterrExpected(variable,IDH_FOR_NEXT);
       p:=last(Block);
       if p is TNEXT then
          begin
               TNEXT(p).controlvar:=controlvar;
               TNEXT(p).own1:=own1;
               TNEXT(p).own2:=own2;
          end;
end;


function NEXTst(prev,eld:TStatement):TStatement;
begin
   if (ProgramUnit.arithmetic=PrecisionNative) then
      if (eld<>nil) and (eld.previous <> nil)
         and (eld.previous is TForStructure)              //2010.07.02
         and ((eld.previous as TForStructure).increment=nil) then
          NEXTst:=TFsimpleNEXT.create(prev,eld)
      else
          NEXTst:=TFNEXT.create(prev,eld)
   else if (ProgramUnit.arithmetic=PrecisionComplex) then
      NEXTst:=TCNEXT.create(prev,eld)
   else
      NEXTst:=TNEXT.create(prev,eld)
end;


{**********}
{ DO block }
{**********}
type
   TLOOP=class(TStatement)
          cond2:TLogical;
          while2:Boolean;
        constructor create(prev,eld:TStatement);
        destructor destroy;override;
        procedure  exec;override;
    end;

destructor TDoStructure.destroy;
begin
    cond1.free;
    Block.free;
    inherited destroy;
end;

destructor TLOOP.destroy;
begin
    cond2.free;
    inherited destroy;
end;

procedure TDoStructure.CollectLabelInfo(t:TLabelNumberTable);
begin
   t.additem(self);
   if Block<>nil then Block.CollectLabelInfo(t);
   if next<>nil then next.CollectLabelInfo(t);
end;

function TDoStructure.SetBreakPoint(i:integer; b:boolean):boolean;
begin
   if i=LineNumb then
     result:=changeStopKeySence(b)
   else
      result:=(block<>nil) and Block.SetBreakPoint(i,b)
         or (next<>nil) and Next.SetBreakPoint(i,b)
end;


function DOst(prev,eld:TStatement):TStatement;
begin
    DOst:=TDOstructure.create(prev,eld)
end;

constructor TDoStructure.create(prev,eld:TStatement);
var
   dummy:TStatement;
begin
    inherited create(prev,eld);
    DoStack.add(self);
    if token='UNTIL' then
       begin
           gettoken;
           until1:=true;
           cond1:=relationalexpression
       end
     else if token='WHILE' then
       begin
           gettoken;
           until1:=false;
           cond1:=relationalexpression
       end;

    nextline;
    Block:=struct.block(self);
    with DoStack do delete(count-1); {dec(DoNest);}
    checkToken1('LOOP',IDH_DO_LOOP);
    {skip;}
    {95.5.20}   dummy:=TLOOP.create(self,eld);
                dummy.free;
end;

function LOOPst(prev,eld:TStatement):TStatement;
begin
    LOOPst:=TLOOP.create(prev,eld)
end;


constructor TLOOP.create(prev,eld:TStatement);
begin
    inherited create(prev,eld);
    if token='UNTIL' then
       begin
           gettoken;
           while2:=false;
           cond2:=relationalexpression
       end
     else if token='WHILE' then
       begin
           gettoken;
           while2:=true;
           cond2:=relationalexpression
       end;
end;

{***************}
{EXIT statements}
{***************}

type
   TEXITHandlerU=class(TStatement)
          whenBlock0:TWhenException;
        constructor create(prev,eld:TStatement);
        procedure   exec;override;
   end;

constructor TEXITHandlerU.create(prev,eld:TStatement);
begin
  inherited create(prev,eld);
  with WhenUseStack do WhenBlock0:=items[count-1];
end;

type
   TEXITHandlerH=class(TStatement)
          handler:THandler;
        constructor create(prev,eld:TStatement);
        procedure exec;override;
   end;

constructor TEXITHandlerH.create(prev,eld:TStatement);
begin
  inherited create(prev,eld);
  handler:=LocalRoutine as THandler;
end;

type
   TEXITDO=class(TStatement)
      statement:TStatement;
     constructor create(prev,eld:TStatement);
     procedure exec;override;
   end;

   TEXITDO1=class(TStatement)   //USEブロックから抜ける場合に使う
      statement:TStatement;
     constructor create(prev,eld:TStatement);
     procedure exec;override;
   end;


constructor TEXITDO.create(prev,eld:TStatement);
var
  p:TStatement;
begin
  inherited create(prev,eld);
  p:=self;
  repeat
    if p.eldest=nil then raise Exception.create('');
    p:=p.eldest.previous
  until p is TDoStructure;
  Statement:=p
end;

constructor TEXITDO1.create(prev,eld:TStatement);
begin
  inherited create(prev,eld);
  with DoStack do Statement:=items[count-1];
end;

type
   TEXITFOR=class(TStatement)
      statement:TStatement;
     constructor create(prev,eld:TStatement);
     procedure exec;override;
   end;

   TEXITFOR1=class(TStatement)   //USEブロックから抜けるために用いる
      statement:TStatement;
     constructor create(prev,eld:TStatement);
     procedure exec;override;
   end;

constructor TEXITFOR.create(prev,eld:TStatement);
var
  p:TStatement;
begin
  inherited create(prev,eld);
  p:=self;
  repeat
    p:=p.eldest.previous
  until p is TForStructure;
  Statement:=p
end;

constructor TEXITFOR1.create(prev,eld:TStatement);
begin
  inherited create(prev,eld);
  with FORStack do Statement:=items[count-1];
end;

function  EXITst(prev,eld:TStatement):TStatement;
var
  exitkind:integer;
begin
    EXITst:=nil;
    if (token='DO') and (DoStack.count>0) then
       try
           EXITst:=TEXITDO.create(prev,eld)
       except
           EXITst:=TEXITDO1.create(prev,eld)
       end
    else if (token='FOR') and (ForStack.count>0) then
       try
           EXITst:=TEXITFOR.create(prev,eld)
       except
           EXITst:=TEXITFOR1.create(prev,eld)
       end
    else if ((token='FUNCTION') or (token='SUB')
                                or (token='PICTURE'))
         and  ((ProgramUnit.kind=token[1])
             or (LocalRoutine<>nil) and (LocalRoutine.kind=token[1])) then
                  begin
                     case token[1] of
                        'F':EXITst:=TEXIT.create(prev,eld,EExitFunction);
                        'S':EXITst:=TEXIT.create(prev,eld,EExitSub);
                        'P':EXITst:=TEXIT.create(prev,eld,EExitPicture);
                     end;
                  end
    else if token='HANDLER' then
       if (LocalRoutine<>nil) and (LocalRoutine.kind=token[1]) then {Handler区}
          EXITst:=TEXITHandlerH.create(prev,eld)
       else if usenest>0 then
          EXITst:=TEXITHandlerU.create(prev,eld)
       else
        seterrIllegal('EXIT '+token,IDH_CAUSE)
    else
        seterrIllegal('EXIT '+token,IDH_DO_LOOP);
    gettoken;
end;

{*****}
{Cause}
{*****}

type
   TCause=class(TStatement)
          typ:integer;
        constructor create(prev,eld:TStatement; t:integer);
        procedure  exec;override;
   end;

constructor TCause.create(prev,eld:TStatement; t:integer);
begin
   inherited create(prev,eld);
   typ:=t
end;


{***********}
{SELECT CASE}
{***********}


function caseitem(idrec:TIdrec):TLogical;forward;

function caselist(idrec:TIDRec):TLogical;
var
   list:TLogical;
begin
   list:=caseItem(idrec);
   while token=',' do
         begin
             gettoken;
             list:=TDisjunction.create(list,caseitem(idrec));
         end;
   caselist:=list
end;

function caseitem(idrec:TIdRec):TLogical;
var
   exp:TPrincipal;
   f:comparefunction;
   s:boolean;
begin
   caseitem:=nil;
   s:=false;
   if token='IS' then
      begin
          s:=true;
          gettoken;
          findcomparefunction(token,f);
          gettoken;
      end
   else
         f:=Equals;
   if idrec.kindchar='n' then
      exp:=NConstant
   else
      exp:=SConstant   ;
   if exp=nil then exit;
   if (token='TO') and not s then
      begin
      gettoken;
        if idrec.kindchar='n' then
           caseitem:=TConjunction.create(
                     TComparisonN.create(exp,idrec.subs,NotGreater),
                     TComparisonN.create(idrec.subs,NConstant,NotGreater))
        else
           caseitem:=TConjunction.create(
                     TComparisonS.create(exp,idrec.subs,NotGreater),
                     TComparisonS.create(idrec.subs ,SConstant,NotGreater))
      end
   else
      if idrec.kindchar='n' then
         caseitem:=TComparisonN.create(idrec.subs,exp,f)
      else
         caseitem:=TComparisonS.create(idrec.subs,exp,f)
end;

{***********}
{SELECT CASE}
{***********}


type
   TSelect=class(TStatement)
             exp:TPrincipal;
             own:TSubstance;
             caseblock:TStatement;
             OwnToFree:boolean;
        constructor create(prev,eld:TStatement);
        procedure CollectLabelInfo(t:TLabelNumberTable);override;
        function SetBreakPoint(i:integer; b:boolean):boolean;override;
        destructor destroy;override;
        procedure  exec;override;
   end;

   TCase=class(TCustomIFstatement)
        constructor create(prev,eld:TStatement;idrec:TIdRec);
   end;


function SELECTst(prev,eld:TStatement):TStatement;
begin
   checktoken('CASE',IDH_SELECT);
   SELECTst:=TSelect.create(prev,eld)
end;

constructor TSelect.create(prev,eld:TStatement);
var
   name:string[1];
   condition:TLogical;
   idr:TIdRec;
begin
    inherited create(prev,eld);
    exp:=NSExpression;
    name:='';
    if exp.kind='s' then name:='$';

    idr:=TIdRec.initSimple(name,intern,maxint);
    own:=idr.subs;
    if pass=2 then
          ProgramUnit.VarTable.add(idr)
    else
          OwnToFree:=true;

   nextline;
   checktoken1('CASE',IDH_SELECT);
   caseblock:=TCase.create(self,nil,idr);
   //SetEldest(CaseBlock);
    checktoken1('END',IDH_SELECT);
   checktoken('SELECT',IDH_SELECT);
end;


constructor TCASE.create(prev,eld:TStatement; idrec:TIdRec);
begin
   inherited create(prev,eld,caselist(idrec));
   nextline;
   thenblock:=block(self);
   if token='CASE' then
      begin
         gettoken;
         if token='ELSE' then
            begin
                gettoken;
                nextline;
                elseblock:=block(self)
            end
         else
            begin
             elseblock:=TCase.create(self,nil,idrec);
             //SetEldest(ElseBlock);
            end;
      end
   else
      begin
       elseblock:=TCause.create(self,nil,10004);  {END SELECT line}
      end;
end;

procedure TSelect.CollectLabelInfo(t:TLabelNumberTable);
begin
   t.additem(self);
   if caseBlock<>nil then CaseBlock.CollectLabelInfo(t);
   if next<>nil then next.CollectLabelInfo(t);
end;

function TSelect.SetBreakPoint(i:integer; b:boolean):boolean;
begin
    if i=LineNumb then
       result:=changeStopKeySence(b)
    else
       result:=(CaseBlock<>nil) and CaseBlock.setBreakPoint(i,b)
            or (next<>nil) and next.setBreakPoint(i,b)
end;



destructor TSelect.destroy;
begin
    exp.free;
    caseblock.free;
    //if pass=1 then
    if OwnToFree then
          own.idr.free;
    inherited destroy
end;



{********}
{STOP st}
{*******}

function  STOPst(prev,eld:TStatement):TStatement;
begin
   STOPst:=TEXIT.create(prev,eld,EStop)
end;

function  RETURNst(prev,eld:TStatement):TStatement;
begin
   RETURNst:=TEXIT.create(prev,eld,EReturn)
end;


Function RETRYst(prev,eld:TStatement):TStatement;
begin
   if usenest=0 then
      begin
          RETRYst:=nil;
          seterrillegal(prevtoken,IDH_WHEN_EXCEPTION)
      end
   else
      RETRYst:=TEXIT.create(prev,eld,ERetry)
end;

Function CONTINUEst(prev,eld:TStatement):TStatement;
begin
   if usenest=0 then
      begin
          CONTINUEst:=nil;
          seterrillegal(prevtoken,IDH_WHEN_EXCEPTION)
      end
   else
   CONTINUEst:=TEXIT.create(prev,eld,EContinue)
end;


{***************}
{CALL statement }
{***************}


function CALLst(prev,eld:TStatement):TStatement;
begin
    CALLst:=TCALL.create(prev,eld,'S');
end;

{***************}
{Cause Exception}
{***************}
type
TCauseException=class(TStatement)
   exp:TPrincipal;
   constructor create(prev,eld:TStatement);
   procedure exec;override;
   destructor destroy;override;
end;

function CauseExceptionst(prev,eld:TStatement):Tstatement;
begin
   checkToken('EXCEPTION',IDH_WHEN);
   CauseExceptionst:=TCauseException.create(prev,eld);
end;

constructor TCauseException.create(prev,eld:TStatement);
begin
    inherited create(prev,eld);
    exp:=NExpression;
end;

destructor TCauseException.destroy;
begin
    exp.free;
    inherited destroy;
end;

{************}
{On statement}
{************}

type
   TON=class(TStatement)
      exp:TPrincipal;
      list:TList;
      elsest:TStatement;
      gosub:boolean;
    constructor create(prev,eld:TStatement);
    procedure exec;    override;
    destructor destroy;override;
end;

function ONst(prev,eld:TStatement):TStatement;
begin
   ONst:=TON.create(prev,eld);
end;

constructor TON.create(prev,eld:TStatement);
var
   dummy:integer;
   p:TStatement;
begin
  inherited create(prev,eld);
  list:=TList.create;
  exp:=NExpression;
  if token='GO' then
     begin
        gettoken;
        if token='SUB' then
           begin
             gettoken;
             gosub:=true;
           end;
        checktoken1('TO',IDH_CONTROL);
     end
  else if token='GOSUB' then
     begin
        gettoken;
        gosub:=true;
     end
  else
    checkToken1('GOTO',IDH_CONTROL);

  repeat
       if gosub=false then
          p:=TGOTO.create(self,nil)
       else
          p:=TGOSUB.create(self,nil);
       //p.eldest:=p;
       dummy:=List.add(p)
  until test(',')=false;

  if token='ELSE' then
     begin
        gettoken;
        elsest:=imperativest(self,nil);
        if elsest<>nil then elsest.eldest:=elsest;
     end;
end;


destructor TON.destroy;
var
   i:integer;
begin
    exp.free;
    elsest.free;
    for i:=0 to list.count-1 do TObject(list.items[i]).free;
    list .free;
    inherited destroy;
end;

{*************}
{WHILE ...WEND}
{*************}

type
   TWHILE=class(TDoStructure)
        constructor create(prev,eld:TStatement);
  end;

function WHILEst(prev,eld:TStatement):TStatement;
begin
  if (token='1') and ((nexttoken='') or (nextToken=':')) then
     begin
        if permitMicrosoft then
           begin
              gettoken;
              whilest:=Dost(prev,eld);
           end
        else if autocorrect[ac_while] {or
        confirm(s_ConfirmWHILE1toDO,IDH_MICROSOFT_CONTROL)} then
          begin
             ReplacePrevToken('DO');
             ReplaceToken('');
             raise ERecompile.create('');
          end
        else
        seterr('',IDH_MICROSOFT_CONTROL)
     end
  else
     begin
       if permitMicrosoft then
           begin
              Whilest:=TWHILE.create(prev,eld);
           end
        else if autocorrect[ac_while] {or
        confirm(s_ConfirmWHILEtoDOWHILE,IDH_MICROSOFT_CONTROL)} then
          begin
              ReplacePrevToken('DO WHILE');
              raise ERecompile.create('');
          end
        else
          seterr('',IDH_MICROSOFT_CONTROL)
     end;

end;

function WENDst(prev,eld:TStatement):TStatement;
begin
    if permitMicrosoft then
        WENDst:=LOOPst(prev,eld)
    else if autocorrect[ac_while] {or
    confirm(s_ConfirmWENDtoLOOP,IDH_MICROSOFT_CONTROL)} then
      begin
       ReplacePrevToken('LOOP');
       raise ERecompile.create('');
      end
    else
       seterr('',IDH_MICROSOFT_CONTROL)
end;

constructor TWHILE.create(prev,eld:TStatement);
var
   dummy:TStatement;
begin
    inherited Tstatementcreate(prev,eld);
    DoStack.add(self);
    until1:=false;
    cond1:=relationalexpression;

    nextline;
    Block:=struct.block(self);
    with DoStack do delete(count-1); {dec(DoNest);}
    checkToken1('WEND',IDH_DO_LOOP);
    {skip;}
    {95.5.20}   dummy:=TLOOP.create(self,eld);
                dummy.free;
end;

{*********}
{RANDOMIZE}
{*********}

type
  TRandomize=class(TStatement)
        routine:TProgramUnit;
        exp:TPrincipal;
     constructor create(prev,eld:TStatement);
     procedure exec;override;
  end;


function RANDOMIZEst(prev,eld:TStatement):TStatement;
begin
    RANDOMIZEst:=TRandomize.create(prev,eld)
end;

constructor TRandomize.create(prev,eld:TStatement);
begin
    inherited  create(prev,eld);
    routine:=programunit;
   if (tokenspec<>tail) and (token<>'ELSE') then
      exp:=NExpression;
end;

{****************}
{Execute Routines}
{****************}
procedure TGOSUB.exec;
var
  svCurrentStatement,svNextStatement:TStatement;
begin
  if stacksize1>=StackLimit1 then
            setexception(stackoverflow);
  //idle;

  svCurrentStatement:=CurrentStatement;
  svNextStatement:=NextStatement;
  try
     RunBlock(statement)
  except
     on EExtype do
        if Extype=10002 then
           begin
              extype:=0;
              CurrentStatement:=svCurrentStatement;
              NextStatement:=svNextStatement;
           end
        else
           raise;
  end;
end;

procedure TIfStatement.exec;
begin
     if condition.evalBool then
        ThenBlock.SequentiallyExecute
     else
        ElseBlock.SequentiallyExecute;
end;

procedure TIfStructure.exec;
begin
  if condition.evalBool then
     if ThenBlock<>nil then
        NextStatement:=ThenBlock
     else
        NextStatement:=InitialLine.next   //ExecutiveNext
  else
     if ELSEBlock<>nil then
        NextStatement:=ELSEBlock
     else
        NextStatement:=InitialLine.next   //ExecutiveNext;
end;

procedure TCustomIfStatement.exec;
begin
  if condition.evalBool then
     if ThenBlock<>nil then
        NextStatement:=ThenBlock
     else
        NextStatement:=ExecutiveNext
  else
     if ELSEBlock<>nil then
        NextStatement:=ELSEBlock
     else
        NextStatement:=ExecutiveNext;
end;

procedure TForStructure.exec;
begin
    own1.assign(limit) ;
    if (increment=nil) then
      own2.substone
    else
      own2.assign(increment) ;
    ControlVar.assign(initial);
    execloop ;
end;

procedure TForStructure.execloop;
begin
   if (ControlVar.compare(own1) * Own2.sign  <= 0) then
      NextStatement:=Block;
end;


procedure TNEXT.exec;
begin
    //idle;
    ControlVar.add(Own2);
    if (ControlVar.compare(Own1) * Own2.sign <= 0) then
       NextStatement:=eldest
    else
       NextStatement:=eldest.previous.next;
end;

procedure TFNEXT.exec;
var
   p,q:PDouble;
begin
    //idle;
    p:=TbasisFVar(ControlVar.ptr).GetPValue;
    q:=@(TorthoFVar(Own2.ptr).value);
    p^:=p^+q^;
    if (p^-TorthoFVar(Own1.ptr).value) * q^ <= 0 then
       NextStatement:=eldest
    else
       NextStatement:=eldest.previous.next;
end;

procedure TFsimpleNEXT.exec;
var
   p:PDouble;
begin
    //idle;
    p:=TbasisFVar(ControlVar.ptr).GetPValue;
    p^:=p^+1;
    if (p^-TorthoFVar(Own1.ptr).value) <= 0 then
       NextStatement:=eldest
    else
       NextStatement:=eldest.previous.next;
end;

procedure TCNEXT.exec;
var
   p,q:PDouble;
begin
    //idle;
    PComplex(p):=TbasisCVar(ControlVar.ptr).GetPValue;
    q:=@(TorthoCVar(Own2.ptr).value.x);
    p^:=p^+q^;
    if (p^-TorthoCVar(Own1.ptr).value.x) * q^ <= 0 then
       NextStatement:=eldest
    else
       NextStatement:=eldest.previous.next;
end;

procedure   TDoStructure.exec;
begin
    if ((cond1=nil) or  (cond1.evalbool xor until1)) then
       nextStatement:=Block ;
end;

procedure TLOOP.exec;
var
    s:boolean;
begin
    //idle;
    if (cond2<>nil) and (cond2.evalbool xor while2)
       then NextStatement:=eldest.previous.next
    else
       NextStatement:=eldest.previous
end;

procedure TEXITHandlerU.exec;
begin
  with whenblock0 do
        extype:=svextype;
  raise EExitHandler.create(WhenBlock0);
end;

procedure TEXITHandlerH.exec;
var
    p:TWhenException;
begin
  with handler.WhenUseBlockStack do TObject(p):=items[count-1];
  with p do
        extype:=svextype;
  raise EExitHandler.create(p);
end;


procedure TEXITDO.exec;
begin
  NextStatement:=statement.next
end;

procedure TEXITDO1.exec;
begin
  raise EExitDo.create(statement.next)
end;

procedure TEXITFOR.exec;
begin
   NextStatement:=Statement.next
end;

procedure TEXITFOR1.exec;
begin
  raise EExitDo.create(statement.next)
end;

procedure TCause.exec;
begin
    setexception(typ);
end;

procedure TSelect.exec;
begin
   own.ptr.assign(exp);
   caseBlock.exec;
end;

procedure TCauseException.exec;
begin
   setexceptionwith('CAUSE EXCEPTION',exp.evalInteger);
end;


procedure TRandomize.exec;
begin
    if exp=nil then
       MyRandomize
    else
       MyRandomize2(exp.evalInteger)
end;

(*
procedure TRandomize.exec;
begin
    if exp=nil then
       System.Randomize
    else
       System.Randseed:=exp.evalInteger
end;
*)

Procedure TON.exec;
var
  i:longint;
begin
  i:=exp.evalInteger;
  if (i>0) and (i<=list.count) then
         (TObject(list.items[i-1]) as TGOTO).exec
  else if elsest<>nil then
         elsest.exec
  else
         setexception(10001)
end;





{**********}
{initialize}
{**********}
procedure statementTableinit;
begin
       statementTableinitStructural('FOR',FORst);
       statementTableinitTerminal  ('NEXT',NEXTst);
       statementTableinitStructural('DO',DOst);
       statementTableinitStructural('WHILE',WHILEst);
       statementTableinitTerminal  ('LOOP',LOOPst);
       statementTableinitTerminal  ('WEND',WENDst);
       statementTableinitStructural('IF',IFst);
       statementTableinitTerminal  ('ELSE',ELSEst);
       statementTableinitTerminal  ('ELSEIF',ELSEst);
       statementTableinitStructural('SELECT',SELECTst);
       statementTableinitTerminal  ('CASE',ELSEst);
       statementTableinitImperative('EXIT',EXITst);
       statementTableinitImperative('CALL',CALLst);
       statementTableinitImperative('STOP',STOPst);
       statementTableinitImperative('RETRY',RETRYst);
       statementTableinitImperative('CONTINUE',CONTINUEst);
       statementTableinitImperative('GOTO',GOTOst);
       statementTableinitImperative('GO',GOst);
       statementTableinitImperative('GOSUB',GOSUBst);
       statementTableinitImperative('RETURN',RETURNst);
       statementTableinitImperative('CAUSE',CauseExceptionst);
       statementTableinitImperative('ON',ONst);
       StatementTableInitImperative('RANDOMIZE',RANDOMIZEst);


end;


begin
 tableInitProcs.accept(statementTableinit);
end.
