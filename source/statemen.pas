unit statemen;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}
(***************************************)
(* Copyright (C) 2006, SHIRAISHI Kazuo *)
(***************************************)


interface
uses SysUtils,  Classes;
Var
  ChainFile:string='';
var
  ChainParams:TStringList;
  
implementation
uses
      listcoll,base,variabl,struct,express,
      helpctex,arithmet,
      texthand,control,sconsts,format;



{*************}
{DIM statement}
{*************}

function NewId(const nam:AnsiString):boolean;
var
  index: integer;
begin
   if (localRoutine<>nil) and
           Localroutine.VarTable.search(nam,index)
    or (LocalRoutine=nil) and
           ( ProgramUnit.Vartable.search(nam,index)
             or ProgramUnit.ExternalVarTable.search2('',nam,index) )
    or (ProgramUnit is TModule)
            and (ProgramUnit as TModule).ShareVarTable.search(nam,index) then
         seterr(s_DuplicatedIdetifier + nam,IDH_ARRAY);
    newId:=not reservedword(nam);
end;

function NewId2(const mnam,nam:AnsiString):boolean;
var
  index: integer;
begin
  NewId2:=false;
  if mnam='' then
     NewId2:=NewId(nam)
  else if ProgramUnit.ExternalVarTable.search2(mnam,nam,index) then
             seterr(s_DuplicatedIdetifier + nam,IDH_ARRAY)
       else
             newid2:=true;
end;


procedure setSubscriptRangeErr;
begin
   seterr(s_SubscriptRange,IDH_ARRAY)
end;

type
    TDIM=class(TStatement)
          mat:TMatrix;
          lb,ub:array[1..4] of TPrincipal;
          optionbase:shortint;
          Imperative:boolean;
          another: TDIM;
        constructor create(prev,eld:TStatement);
        destructor destroy;override;
        procedure exec;override;
      end;


function DIMst(prev,eld:TStatement):TStatement;
begin
   DIMst:=TDIM.create(prev,eld)
end;

constructor TDIM.create(prev,eld:TStatement);
var
    nam:AnsiString;
    i,d:integer;
    lbound,ubound:array4;
    c:integer;
    s:boolean;
begin
    inherited  create(prev,eld);

    if (programunit.optionbase=ApNone) and (base.initialOptionbase=0) then
       begin
         insertline(LineNumber,'OPTION BASE 0');
         raise ERecompile.create('');
       end;

    optionbase:=programunit.ArrayBase;

    if pass=1 then
        nam:=getidentifier
    else
       mat:=matrix;
    check('(',IDH_ARRAY);
    d:=0;
    repeat
      inc(d);
      ub[d]:=nexpression;
      if token='TO' then
         begin
            gettoken;
            lb[d]:=ub[d];
            ub[d]:=nil;   //   2012.2.26
            ub[d]:=nexpression;
         end
      else
          ProgramUnit.DimAppeared:=true;
    until (d=4) or (test(',')=false) ;
    check(')',IDH_ARRAY);

    for i:=1 to 4 do lbound[i]:=optionbase;
    for i:=1 to 4 do ubound[i]:=lbound[i] - 1 ; //2000.2.7

    s:=true;
    for i:=1 to d do
        s:=s and ((lb[i]=nil) or lb[i].isConstant)
             and  ub[i].isConstant;

    if s then
       try
         for i:=1 to d do
             begin
                 if lb[i]<>nil then
                        lbound[i]:=lb[i].evalLongint
                 else
                        lbound[i]:=programunit.ArrayBase;
                 ubound[i]:=ub[i].evalLongint;
             end
       except
          seterr(s_SubscriptRange,IDH_JIS_7)
       end
    else if JISDim then
           seterr(s_DimParameter,COMPATIBILITY_OPTION)
         else
           Imperative:=true;

    if imperative and (LocalRoutine<>nil) then                //2008.2.11
          seterr(s_DimParameter,IDH_IMPERATIVE_DIM) ;

    if pass=1 then
       if newId(nam) then
          programUnit.Vartable.add(TIdRec.initArray(nam,d,lbound,ubound,intern,maxint)) ;

    if test(',') then
        another:=TDIM.create(self,nil);
end;

destructor TDIM.destroy;
var
   i:integer;
begin
    //mat.free;
    for i:=1 to 4 do
       begin
          lb[i].free;
          ub[i].free;
       end;
    another.free;
    inherited destroy;
end;

procedure TDIM.exec;
var
   i:integer;
   lbound,ubound,size:array4;
   s,results:boolean;
begin
  if Imperative then
    begin
       for i:=1 to mat.idr.dim do
           try
               ubound[i]:=ub[i].evalLongInt;
               if lb[i]<>nil then
                   lbound[i]:=lb[i].evalLongint
               else
                   lbound[i]:=optionbase;
           except
               on EInvalidOp do SetException(2001);
           end;
       s:=true;
       calcsize(mat.idr.dim,lbound,ubound,size);
       for i:=1 to mat.idr.dim do
           s:=s and (lbound[i]=TArray(mat.point).lbound[i])
                and (size[i]=TArray(mat.point).size[i]);
       if s then
          //results:=true
       else
          TArray(mat.point).redim0(lbound,ubound);
    end;
  if another<>nil then another.exec
end;


{**********}
{DECLARE st}
{**********}


procedure DeclareNS(VarTable:TIdTable; sp:SetOfTokenSpec; IdTag:TIdTag);
var
    nam:AnsiString;
    i,d:integer;
    lbound,ubound:Array4;
    c1,c2:integer;
    optionbase:integer;
    n:number;
    maxlen0:integer;
    maxlen:integer;
begin
  optionbase:=programunit.ArrayBase;


  maxlen0:=maxint;
  MaxLenDeclaration(sp,maxlen0);
  {
  if (sp=[SIdf]) and (token='*') then
     begin
          gettoken;
          NumericConstant(n);
          maxlen0:=LongIntVal(n,c1);
          if c1>0 then maxlen0:=maxint;
     end;
  }
  repeat
    if not (tokenspec in sp) then seterr('',IDH_DECLARE);
    nam:=getidentifier;
    d:=0;
    if token='(' then
        begin
           gettoken;
           for i:=1 to 4 do lbound[i]:=optionbase;
           for i:=1 to 4 do ubound[i]:=lbound[i];
           c1:=0;
           c2:=0;
           repeat
             NumericConstant(n);
             inc(d);
             ubound[d]:=LongintVal(n,c1);
             if token='TO' then
                begin
                   gettoken;
                   NumericConstant(n);
                   lbound[d]:=ubound[d];
                   ubound[d]:=LongintVal(n,c2);
                end
             else
                ProgramUnit.DimAppeared:=true;
             if (c1<>0) or (c2<>0) then setSubscriptRangeErr;
           until (d=4) or (test(',')=false) ;
           check(')',IDH_DECLARE);
        end;
    maxlen:=maxlen0;
    MaxLenDeclaration(sp,maxlen);

    if pass=1 then
      if newId(nam) then
         if d>0 then
            Vartable.add(TIdRec.initArray(nam,d,lbound,ubound,IdTag,maxlen))
         else
            Vartable.add(TIdRec.initSimple(nam,IdTag,maxlen));

  until test(',')=false;
end;

procedure DeclareExternalNS(VarTable:TIdTable; sp:SetOfTokenSpec);
var
    nam,mnam:AnsiString;
    d:integer;
    idr:TIdRec;
    module1:TModule;
    index1:integer;
    token1:string;
begin
  repeat

    if not (tokenspec in sp) then seterr('',IDH_MODULE);

    token1:=token;
    mnam:=modifier(token);
    if (mnam='') and (ProgramUnit.kind=#0)  then
         seterr(s_ModifiedIdentifierExpected,IDH_MODULE);
    nam:=identifier(token);
    gettoken;
    d:=0;

    if token='(' then
        begin
           gettoken;
           repeat
             inc(d);
           until (d=4) or (test(',')=false) ;
           check(')',IDH_ARRAY);

           if pass=1 then
              if newId2(mnam,nam) then
                 VarTable.add(TIdRec.initAExt(mnam,nam,d))     ;
        end
    else
        begin
            if pass=1 then
               if newID2(mnam,nam) then
                     Vartable.add(TIdRec.initSimpleExt(mnam,nam));
        end;

    if pass=2 then
      begin
        module1:=module(mnam);
        if (module1<>nil) and module1.ShareVarTable.search(nam,index1) then
           begin
              Idr:=TIdRec(module1.ShareVartable.items[index1]);
              if (idr=nil) or (idr.tag<>idPublic) then
                 seterr(SysUtils.Format(s_NotPublicDeclaredIn,[mnam,nam]),IDH_MODULE);
              if idr.dim<>d then
                 seterr(SysUtils.Format(s_ModuleDimemsion,[mnam,nam,strint(idr.dim)]),IDH_MODULE);
              if (prevtokenspec=Nidf) and (module1.arithmetic<>programunit.arithmetic) then
                 seterr(s_DisAgreeArithmetic,IDH_MODULE);
           end
        else
                 seterr(token1+s_IsNotFound,IDH_MODULE);

      end;

  until test(',')=false;
end;

procedure DeclareRoutine(VarTable:TIdTable; idtag:TIdTag; kind:char);
var
    nam,mnam:AnsiString;
    index:integer;
    idr:TIdrec;
    module1:TModule;
begin
       repeat
          mnam:=modifier(token);
          if (idtag<>extern) and (mnam<>'') then
             seterr('',IDH_MODULE);
          nam:=identifier(token);
          gettoken;

          case pass of
           1:
               if idtag=extern then
                  {if (Kind='F') or (mnam<>'')                            //2025.05.08
                    or ForceSubPictDeclare and (Kind in ['S','P']) then  //2013.12.7 }
                       if NewId2(mnam,nam) then
                          Vartable.add(TIdRec.initF(mnam,nam,extern))
                       else
                  {else}
               else {if (kind='F')                                         //2025.05.08
                     or ForceSubPictDeclare and (Kind in ['S','P'])then    //2013.12.7 }
                         if newId(nam) then
                            if idtag=intern then                        //2007.3.30
                               Vartable.add(TIdRec.initF('',nam,idtag)) //2007.3.30
                            else                                        //2007.3.30
                               Vartable.add(TIdRec.initF(Curmodule.name,nam,idtag))
                         else
                     {else}   ;

           2:
             if kind='F' then
               case IdTag of
                extern:
                  if (mnam<>'') then
                    begin
                       module1:=module(mnam);
                       if (module1<>nil) and module1.ShareVarTable.search(nam,index)         //2013.12.16
                         and (TIdRec(module1.ShareVarTable.items[index]).tag=IdPublic) then
                         else
                            seterr(mnam+'.'+nam+s_IsNotPublicDeclared,IDH_MODULE)
                    end ;
                idShare,idPublic:
                    if (prevtokenspec=NIdf) and VarTable.search(nam,index) then
                       begin
                           idr:=TIdrec(VarTable.items[index]);
                           if (getroutine(idr,'F') as TProgramUnit).arithmetic
                                  <>CurModule.Arithmetic then
                                        seterr(s_DisAgreeArithmetic,IDH_MODULE);
                       end;
               end;
          end;

       until test(',')=false;
end;

function DECLAREst(prev,eld:TStatement):TStatement;
var
   idtag:TIdTag;
begin
  DECLAREst:=LabelStatement(prev,eld);

  idtag:=intern;
  if token='EXTERNAL' then
     begin
          idtag:=extern;
          gettoken;
     end;

  if token='NUMERIC' then
     begin
         gettoken;
         if IdTag=Extern then
            DeclareExternalNS(ProgramUnit.ExternalVartable, [NIdf])
         else
            DeclareNS(ProgramUnit.Vartable, [NIdf],IdTag);
     end
  else if token='STRING' then
     begin
         gettoken;
         if IdTag=Extern then
            DeclareExternalNS(ProgramUnit.ExternalVartable, [SIdf])
         else
         DeclareNS(ProgramUnit.Vartable, [SIdf],IdTag);
     end
  else if (token='FUNCTION') or (token='DEF') then
     begin
       gettoken;
       if idtag=extern then
         DeclareRoutine(ProgramUnit.ExternalVarTable, idtag, 'F')
       else
         DeclareRoutine(ProgramUnit.VarTable, idtag, 'F');
     end
  else if (token='SUB') or (token='PICTURE') then
     begin
       gettoken;
       if idtag=extern then
          DeclareRoutine(ProgramUnit.ExternalSubTable, extern,prevtoken[1]) //2013.12.7
       else
          skipLogical   ;
     end;
end;

function SharePublic(prev,eld:TStatement;Idtag:TIdtag):TStatement;
var
   name:AnsiString;
begin
  if (programunit.kind='M') or
     ((programunit.kind=#0) and (Idtag=IdPublic)
                            and ((token='NUMERIC')or(token='STRING')))   then
  else
      seterrIllegal(prevtoken,IDH_Module);

  result:=LabelStatement(prev,eld);

  if token='NUMERIC' then
     begin
         gettoken;
         DeclareNS(CurModule.ShareVartable, [NIdf],IdTag);
         exit
     end
  else if token='STRING' then
     begin
         gettoken;
         DeclareNS(CurModule.ShareVartable, [SIdf],IdTag);
         exit
     end
  else if token='FUNCTION' then
     begin
        gettoken;
        DeclareRoutine(CurModule.ShareVartable,IdTag,'F')  ;
     end
  else if (token='SUB') or (token='PICTURE') then
     begin
          gettoken;
          DeclareRoutine(CurModule.ShareSubTable,IdTag,prevtoken[1]) //2013.12.7
     end
  else if (token='CHANNEL') and (idtag=IdShare) then
     begin
       gettoken;
       repeat
          checktoken('#',0);
          if (tokenspec=Nrep)  and  (pos ('.',token)=0) then
             begin
                   name:=prevtoken+token;
                   gettoken;
             end;
          case pass of
           1:if newId(name) then
                CurModule.ShareVartable.add(TIdRec.initCh(Curmodule.name,name,idtag));
           2:begin
             end ;
          end;
       until test(',')=false;
     end;
end;

function SHAREst(prev,eld:TStatement):TStatement;
begin
   result:=SharePublic(prev,eld,IdShare)
end;

function PUBLICst(prev,eld:TStatement):TStatement;
begin
   result:=SharePublic(prev,eld,IdPublic)
end;


function LOCALst(prev,eld:TStatement):TStatement;
var
   idtag:TIdTag;
begin
  idtag:=intern;
  LOCALst:=LabelStatement(prev,eld);
  if LocalRoutine<>nil then
     DeclareNS(LocalRoutine.Vartable, [NIdf,SIdf],IdTag)
  else
     //DeclareNS(ProgramUnit.Vartable, [NIdf,SIdf],IdTag)
end;

{**********}
{PROGRAM st}
{**********}
type
    TPROGRAM=class(TStatement)
          params:TListCollection;
        constructor create(prev,eld:TStatement);
        procedure exec;override;
        destructor destroy;override;
    end;

// 2004.1.7修正
var PROGRAMStatement:TPROGRAM;
function PROGRAMst(prev,eld:TStatement):TStatement;
begin
    PROGRAMstatement:=TPROGRAM.CREATE(prev,eld);
    PROGRAMst:=PROGRAMstatement;
end;

function FormalArray:TSubstance;
var
    nam:AnsiString;
    i,d:integer;
    lbound,ubound:Array4;
    c:integer;
    idr:TIdRec;
begin
    if pass=1 then
        nam:=getidentifier
    else
        result:=matrix;

    check('(',IDH_ARRAY);
    d:=0;
    repeat
      inc(d);
    until (d=4) or (test(',')=false) ;
    check(')',IDH_ARRAY);

    for i:=1 to 4 do lbound[i]:=1;
    for i:=1 to 4 do ubound[i]:=lbound[i] - 1;

    if pass=1 then
       if newId(nam) then
          begin
            idr:=TIdRec.initArray(nam,d,lbound,ubound,intern,maxint);
            programUnit.Vartable.add(idr) ;
            result:=idr.subs
          end
       else
    else

end;

constructor TPROGRAM.create(prev,eld:TStatement);
begin
    inherited create(prev,eld);
    params:=TListCollection.create;

    if linenumber<>0 then seterrIllegal(prevtoken,IDH_JIS_DETAIL);
    if tokenspec<>Nidf then seterrIllegal(token,IDH_JIS_DETAIL);
    mainProgram.name:=token;     //2000.3.31
    gettoken;
   if token='(' then
       begin
          gettoken;
          repeat
             if  NextToken='(' then
                params.insert(FormalArray)
             else
                params.insert(variable);
          until test(',')=false;
          check(')',IDH_CHAIN);
       end;
end;

destructor TPROGRAM.destroy;
begin
   params.free;
   inherited destroy;
end;

{
procedure TPROGRAM.exec;
var
   i:integer;
   s:AnsiString;
   p:PChar;
   q:boolean;
begin
   i:=0;
   while (i<params.count) and (ParamIndex+i<paramCount) and (extype=0)  do
      begin
         s:=paramstr(ParamIndex+i+1);
         q:=false;
         if (length(s)>0) and (s[1]='"') then
            begin
               p:=pchar(s);
               s:=AnsiExtractQuotedStr(p,'"');
               q:=true;
            end;
         TVariable(params[i]).point.readDataV2(s,q);
         if extype=8101 then extype:=4301;
         inc(i)
      end;

end;
}
procedure TPROGRAM.exec;
var
   i:integer;
   s:AnsiString;
   p:PChar;
   q:boolean;
   count:integer;
   Chainst:boolean;
begin
   Count:=ChainParams.Count;
   Chainst:=(Count>0);
   if not Chainst then
      Count:=ParamCount-ParamIndex;
   try
      for i:=0 to Count-1 do
        begin
           if Chainst then
                s:=TrimRight(ChainParams.Strings[i])
           else
                s:=paramstr(ParamIndex+i+1);
           q:=false;
           if (length(s)>0) and (s[1]='"') then
               begin
                   p:=pchar(s);
                   s:=AnsiExtractQuotedStr(p,'"');
                   q:=true;
               end;
           if i<Params.Count then
               TSubstance(params[i]).point.readDataV2(s,q,false)
           else if Chainst then
               SetException(4301);
        end;
    finally
        ChainParams.Clear;
        if (extype<>0) and (extype<>4302) then extype:=4301;
    end;
end;


{*********}
{OPTION st}
{*********}
function PreciMode(const s:string):tpPrecision;
var
   i:TpPrecision;
begin
   for i:=low(i) to high(i) do
      if s=PrecisionLiteral[i] then
         begin result:=i; exit end;
   seterrExpected('DECIMAL or NATIVE',IDH_JIS_9);
end;

procedure testValidOptionArithmetic;
var
   i,i0:integer;
   s:boolean;
begin
     s:=not (programunit is TModule) or ((programunit as TModule).shareVarTable.count=0);
     //PROGRAM文の引数を無視
     i0:=0;
     if (ProgramUnit=MainProgram) and (PROGRAMstatement<>nil) then
     i0:= PROGRAMstatement.params.count;
     with programunit.vartable do
          for i:=i0 to count-1 do
              s:=s and (TIdRec(items[i]).prm or (TIdRec(items[i]).kindchar<>'n'));
     if not s then
        seterr(s_OPTION_ARITHMETIC,IDH_OPTION_ARITHMETIC)
end;

function  OPTIONsub(prev,eld:TStatement; OptionLevel:OptionAppearance):TStatement;
var
  PrecMode:tpPrecision;
  Switch:boolean;
begin
   OPTIONsub:=LabelStatement(prev,eld);
   repeat
       if token='ANGLE' then
            begin
                if permitMicrosoft then
                         seterr(s_JISmode,COMPILE_OPTION_SYNTAX);

                gettoken;

                if (pass=1) then
                   if programunit.optionangle=apNone then
                      programunit.optionAngle:=OptionLevel
                   else
                      seterr( s_OnlyOneOPTION_ANGLE,IDH_TRIGONOMETRIC);

                if token='DEGREES' then
                   programunit.AngleDegrees:=true
                else if token='RADIANS' then
                   programunit.AngleDegrees:=false
                else
                   seterrExpected('DEGREES',IDH_TRIGONOMETRIC);
                gettoken;
            end
        else if token='ARITHMETIC' then
            begin
                if permitMicrosoft then
                         seterr(s_JISmode,COMPILE_OPTION_SYNTAX);

                gettoken;

                if (pass=1) then testValidOptionArithmetic;
                if (pass=1) then
                   if programunit.optionarithmet=ApNone then
                      programunit.optionArithmet:=OptionLevel
                   else
                      seterr(s_OnlyOneOPTION_ARITHMETIC,IDH_JIS_4);

                precMode:=PreciMode(token);
                Switch:=false;                      //2008.5.2
                if precmode in [PrecisionHigh,PrecisionRational] then
                   begin
                      switch :=(precmode = precisionmode)
                              and (not UseTranscendentalFunction);
                      UseTranscendentalFunction:=true;
                   end;
                programUnit.arithmetic:=precMode;
                setPrecisionMode(precMode,Switch);
                gettoken;
            end
       else if token='BASE' then
            begin
                 if pass=1 then
                    if programunit.DimAppeared then
                       seterr(s_OPTION_BASE,IDH_ARRAY);
                 gettoken;
                 programunit.optionbase:=OptionLevel;
                 if token='0' then
                     begin
                       programUnit.ArrayBase:=0;
                       gettoken;
                     end
                 else if token='1' then
                     begin
                       programUnit.ArrayBase:=1;
                       gettoken;
                     end
                 else
                    seterrRestricted('0 or 1',IDH_ARRAY);
            end
       else if token='COLLATE' then
            begin
                gettoken;
                programUnit.optionCollate:=OptionLevel;
                if token='STANDARD' then
                   ProgramUnit.CharacterByte:=false
                else if token='NATIVE' then
                   ProgramUnit.CharacterByte:=true
                else
                   seterr('',IDH_SUBSTRING);
                gettoken;
            end
       else if token='CHARACTER' then
            begin
                gettoken;
                programUnit.optionCollate:=OptionLevel;
                if token='BYTE' then
                   ProgramUnit.CharacterByte:=true
                else if (token='MULTIBYTE') or (token='UTF8') or (token='KANJI') then
                   ProgramUnit.CharacterByte:=false
                else
                   seterr('',IDH_SUBSTRING);
                gettoken;
            end
       else
            seterr('',IDH_SUBSTRING)  ;
   until test(',')=false
end;

function  OPTIONst(prev,eld:TStatement):TStatement;
begin
    OPTIONst:=OPTIONsub(prev,eld,ApUnit);
end;

function MODULEst(prev,eld:TStatement):TStatement;
begin
   result:=nil;
   if (ProgramUnit.kind='M') and (token='OPTION') then
       begin
          gettoken;
          MODULEst:=OPTIONsub(prev,eld,ApModule);
       end
   else
       seterrIllegal(prevtoken,IDH_STATEMENTS);
end;

{**********}
{DATA statement}
{**********}

function DATAst(prev,eld:TStatement):TStatement;
var
   cont:boolean;
   p:ansiString;
begin
   DATAst:=LabelStatement(prev,eld);
   resettoken1;
   if pass=1 then programunit.DataSeq.setlabelNumber(Labelnumber);
   cont:=true;
   while cont do
       begin
          p:=datum;
          if pass=1 then
              programunit.DataSeq.DataList.append(p);
          gettoken;
          if nexttoken=',' then
              cont:=true
          else
              cont:=false;
       end;
   gettoken;
end;



{*******}
{RESTORE}
{*******}
type
    TRestore=class(TStatement)
           LabelNumber:integer;
        constructor create(prev,eld:TStatement);
        procedure exec;override;
    end;

procedure TRestore.exec;
begin
    Punit.dataseq.restore(LabelNumber)
end;

constructor TRestore.create(prev,eld:TStatement);
var
   long:longint;
begin
    inherited create(prev,eld);
    if token<>'' then
       begin
       if nonnegativeintegralnumber(long) and (long>0) then
           Labelnumber:=long
       else
          seterrexpected(s_LineNumber,IDH_READ_DATA);
       if (pass=2) and (Punit.dataseq.labelNumbers.indexof(strint(long))<0) then
          seterr(SysUtils.Format(s_LineNotFound,[strint(long)]),IDH_READ_DATA);
       end;
end;

function  RESTOREst(prev,eld:TStatement):TStatement;
begin
    RESTOREst:=TRestore.create(prev,eld)
end;

{***************}
{IMAGE statement}
{***************}

function IMAGEst(prev,eld:TStatement):TStatement;
var
   svcp:TokenSave;
   s:ansistring;
   dummy:integer;
begin
   if labelNumber=0 then seterr(s_IMAGEstatement,IDH_PRINT_USING);
   IMAGEst:=TStatement.create(prev,eld);
   savetoken(svcp);
   check(':',IDH_PRINT_USING);
   skip;
   if pass=1 then
     begin
       s:=extract(svcp);
       delete(s,1,1);
       s:=trimright(s);
       if not TestFormatString(s) then
          seterr('Illegal format string',IDH_PRINT_USING);
       dummy:=programunit.ImageList.addObject(s,TObject(labelnumber));
     end;  
end;

{******}
{REM st}
{******}

function  REMst(prev,eld:TStatement):TStatement;
begin
   REMst:=LabelStatement(prev,eld) ;
   skip;
end;



{*************}
{registeration}
{*************}

procedure statementTableinit;
begin
   PROGRAMstatement:=nil;   //2004.1.7
   StatementTableInitDeclative ('PROGRAM',PROGRAMst);
   StatementTableInitDeclative ('REM',REMst);
   StatementTableInitDeclative ('DATA',DATAst);
   StatementTableInitImperative('RESTORE',RESTOREst);
   StatementTableInitDeclative ('IMAGE',IMAGEst);
   StatementTableInitSingular  ('DIM',DIMst);
   StatementTableInitDeclative ('DECLARE',DECLAREst);
   StatementTableInitDeclative ('SHARE',SHAREst);
   StatementTableInitDeclative ('PUBLIC',PUBLICst);
   StatementTableInitDeclative ('OPTION',OPTIONst);
   StatementTableInitDeclative ('MODULE',MODULEst);
   StatementTableInitDeclative ('LOCAL',LOCALst);
   if permitMicrosoft then
      begin
        StatementTableInitDeclative ('DEFDBL',REMst);
        StatementTableInitDeclative ('DEFINT',REMst);
        StatementTableInitDeclative ('DEFSNG',REMst);
        StatementTableInitDeclative ('CONSOLE',REMst);
      end;
end;

procedure functiontableInit;
begin
end;


initialization
   tableInitProcs.accept(statementTableinit);
   tableInitProcs.accept(FunctionTableInit);
    ChainParams:=TStringList.Create;

finalization
    ChainParams.Free;

end.


