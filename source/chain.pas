unit chain;

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

interface

implementation
uses
      SysUtils, Forms, Process, FileUtil,  UTF8Process,
      listcoll,base,variabl,struct,express,
      helpctex,texthand,control,sconsts,statemen;


function ShellExec(s1,s2:string; opWaitFor:boolean):boolean;
var
   AProcess: TProcessUTF8;
begin
   result:=false;
   AProcess := TProcessUTF8.Create(nil);
   AProcess.CommandLine :=s1 + ' ' +s2;
   if opWaitFor then
     AProcess.Options := AProcess.Options + [poWaitOnExit];
   try
   try
      AProcess.Execute;
      result:=true;
   finally
      AProcess.Free;
   end;
   except
   end;
end;

type
  TEXECUTE=class(TStatement)
     exp1:TPrincipal;
     params:TListCollection;
     opWaitFor:boolean;
     ChainSt:boolean;
     NoQuotes:boolean;
    constructor create(prev,eld:TStatement; opWaitFor0:boolean);
    procedure exec;override;
    destructor destroy;override;
  end;


constructor TEXECUTE.create(prev,eld:TStatement; opWaitFor0:boolean);
begin
    inherited create(prev,eld);
    opWaitFor:=opWaitFor0;
    if token='NOWAIT' then
                      begin opWaitFor:=false; gettoken end;
    exp1:=SExpression;
    params:=TListCollection.create;
    if token='WITH' then
       begin
          gettoken;
          check('(',IDH_CHAIN);
          repeat
             params.insert(article);
          until test(',')=false;
          check(')',IDH_CHAIN);

          if token=',' then   //Ver 7.6.1
             begin
               GetToken;
               if token='NOQUOTES' then
                  begin
                     gettoken;
                     NoQuotes:=true;
                  end;
             end;

       end;
end;

destructor TEXECUTE.destroy;
begin
   exp1.free;
   params.free;
   inherited destroy;
end;

procedure TEXECUTE.exec;
var
   s1,s2,s:AnsiString;
   i:integer;
   ToChain:boolean;
begin
   sleep(50);        //2019/09/02 Ver 8.0.1.7

   ToChain:=Chainst;
   s1:=exp1.evalS;
   s2:='';
   if not FileExists(s1) and (ExtractFileExt(s1)='') then
                  s1:=s1 + BASExt;
   if not FileExists(s1)  then
      begin
        s:=ExtractFilePath(Application.ExeName)+s1;
        if FileExists(s) then
           s1:=s
        else
           s1:=FileSearch(s1,GetEnvironmentVariable('PATH'))
           ;
      end;
   if (s1<>'') and FileExists(s1) then
        begin
            if CompareText(ExtractFileExt(s1),BASExt)=0 then
               begin
                   s2:=s1;
                   s1:=Application.ExeName;
               end
          else
             ToChain:=false;
            i:=0;
         if ToChain then
            begin
               ChainFile:=s2;
               with params do
                 while i<count do
                   begin
                     ChainParams.Add(TPrincipal(items[i]).str);
                     inc(i)
                   end;
            end
          else
            begin
              if s2<>'' then
                 s2:=AnsiQuotedStr(s2,'"')+' ';
              with params do
                while i<count do
                  begin
                    if NoQuotes then
                        s2:=s2 + TPrincipal(items[i]).str +' '
                    else
                        s2:=s2 + TPrincipal(items[i]).str2 +' ' ;
                      inc(i)
                  end;
              s2:=TrimRight(s2);
              if ShellExec(s1,s2,opWaitFor) then
              else
                 setexception(10005);
            end;
      end
   else
      setexception(10005);


end;

function EXECUTEst(prev,eld:TStatement):TStatement;
begin
    EXECUTEst:=TEXECUTE.CREATE(prev,eld, true);
end;

type
    TCHAIN=class(TEXECUTE)
      constructor create(prev,eld:TStatement);
      procedure exec;override;
    end;

function CHAINst(prev,eld:TStatement):TStatement;
begin
    CHAINst:=TCHAIN.CREATE(prev,eld);
end;

constructor TCHAIN.create(prev,eld:TStatement);
begin
   inherited create(prev,eld,false);
   Chainst:=true;
end;

procedure TCHAIN.exec;
begin
   inherited exec ;
   raise EStop.create;
end;

{*************}
{registeration}
{*************}

procedure statementTableinit;
begin
   StatementTableInitImperative('CHAIN',CHAINst);
   StatementTableInitImperative('EXECUTE',EXECUTEst);
end;

procedure functiontableInit;
begin
end;


begin
   tableInitProcs.accept(statementTableinit);
   tableInitProcs.accept(FunctionTableInit);
end.
