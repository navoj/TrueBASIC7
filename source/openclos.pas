unit openclos;

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

(***************************************)
(* Copyright (C) 2003, SHIRAISHI Kazuo *)
(***************************************)


interface

implementation

uses base,texthand,textfile,variabl,struct,express,helpctex,io,sconsts;

type
    POpen=^TOpen;
    TOpen=class(TStatement)
        chn:TPrincipal;
        fname:TPrincipal;
        amode:TPrincipal;
        rectp:TPrincipal;
        orgtp:TPrincipal;
        rsize:TPrincipal;
        length:TPrincipal;
        constructor create(prev,eld:TStatement; chn1:TPrincipal);
        destructor destroy;override;
        procedure exec;override;
     end;

    TOpenPrinter=class(TStatement)
        chn:TPrincipal;
        constructor create(prev,eld:TStatement; chn1:TPrincipal);
        destructor destroy;override;
        procedure exec;override;
     end;

function DecideAccessMode(const s:ansistring; var am:AccessMode):boolean;
begin
   result:=true;
   if s=AccessModeLiteral[amOUTIN] then
      am:=amOutin
   else if s=AccessModeLiteral[amINPUT] then
      am:=amInput
   else if s=AccessModeLiteral[amOUTPUT] then
      am:=amOUTput
   else
      result:=false
end;

function DecideRecordType(const s:ansistring; var rc:RecordType):boolean;
begin
   result:=true;
   if s=RecordTypeLiteral[rcDisplay] then
      rc:=rcDisplay
   else if s=RecordTypeLiteral[rcInternal] then
      rc:=rcInternal
   else if s=RecordTypeLiteral[rcCSV] then
      rc:=rcCSV
   else
      result:=false
end;

function DecideOrgType(const s:ansistring; var og:OrganizationType):boolean;
begin
   result:=true;
   if s=OrganizationTypeLiteral[orgSEQ] then
      og:=orgSEQ
   else if s=OrganizationTypeLiteral[orgSTREAM] then
      og:=orgSTREAM
   else
      result:=false
end;

function DecideRecSize(const s:ansistring):boolean;
begin
   result:=(s='VARIABLE')
end;

constructor TOpen.create(prev,eld:TStatement; chn1:TPrincipal);
var
  am:accessmode;
  rc:RecordType;
  og:OrganizationType;
begin
    inherited create(prev,eld);
    chn:=chn1;
    fname:=SEXpression;
    while token=',' do
       begin
            gettoken;
            if token='ACCESS' then
               begin
                  gettoken;
                  if DecideAccessMode(token,am) then
                    begin
                         amode:=TStrConstant.create(token);
                         gettoken;
                    end
                  else
                     amode:=SExpression;
               end
            else if token='RECTYPE' then
               begin
                  gettoken;
                  if DecideRecordType(token,rc) then
                       begin
                         rectp:=TStrConstant.create(token);
                         gettoken;
                       end
                  else
                     rectp:=SExpression;
               end
           else if (token='ORGANIZATION') or (token='ORG') then
               begin
                  gettoken;
                  if DecideOrgType(token,og) then
                       begin
                         orgtp:=TStrConstant.create(token);
                         gettoken;
                       end
                  else
                     orgtp:=SExpression;
               end
           else if (token='RECSIZE')  then
               begin
                  gettoken;
                  if DEcideRecSize(token) then
                     begin
                        rsize:=TStrConstant.create(token);
                        gettoken
                     end
                  else
                      rsize:=SExpression;
                  if token='LENGTH' then
                     begin
                        gettoken;
                        length:=NExpression;
                     end;
               end
        end ;
        if (og=OrgSTREAM) and (rc<>rcInternal) then seterr('',IDH_JIS_11);   //ver 7.5.1
    {if (chn=nil) or (fn=nil) or err then begin done ;fail end;}
end;

destructor TOpen.destroy;
begin
    chn.free;
    fname.free;
    amode.free;
    rectp.free;
    orgtp.free;
    rsize.free;
    inherited destroy;
end;

procedure TOpen.exec;
var
    w:longint;
    s:ansistring;
    am:AccessMode;
    rc:RecordType;
    og:OrganizationType;
    len:integer;
begin
    am:=amOUTIN;
    rc:=rcDISPLAY;
    og:=orgSEQ;
    len:=maxint;

    w:=chn.evalInteger;

       s:=fname.evalS;
       if length<>nil then len:=length.evalInteger;
       if  ((amode=nil) or  DecideAccessMode(amode.evalS,am))
       and ((rectp=nil) or  DecideRecordType(rectp.evals,rc))
       and ((orgtp=nil) or  DecideOrgType(orgtp.evalS,og))
       and ((rsize=nil) or  DecideRecSize(rsize.evalS))
       then
       if (w>0) then
           PUnit.open(w,s,am,rc,og,len)
       else if (w=0) then
           //if insideofwhen then
           //    setexception(7002)
           //else
              // exec:=true
           ReportException(InsideOfWhen,7002)
       else
           setexception(7001);

//    else setexception(7100)
;
end;

constructor TOpenPrinter.create(prev,eld:TStatement; chn1:TPrincipal);
begin
    inherited create(prev,eld);
    chn:=chn1;
end;

destructor TOpenPrinter.destroy;
begin
    chn.free;
    inherited destroy;
end;

procedure TOpenPrinter.exec;
var
    w:longint;
begin
    w:=chn.evalInteger;
    if w>0 then
      PUnit.openPrinter(w)
    else if (w=0) then
            //if insideofwhen then
            //   setexception(7002)
            //else
              // exec:=true
         setexception(7003)
    else
         setexception(7001);
end;

function OPENst(prev,eld:TStatement):TStatement;
var
  chn:TPrincipal;
begin
   if token<>'#' then begin OPENst:=nil ;seterrexpected('#',IDH_OPEN); exit end;
   chn:=ChannelExpression;
   check(':',IDH_OPEN);
   if token='PRINTER' then
     begin
       gettoken;
       OPENst:=TOpenPrinter.create(prev,eld,chn)
     end
   else
     begin
       check('NAME',IDH_OPEN);
       Openst:=TOpen.create(prev,eld,chn)
     end;
end;


type
    TClose=class(TStatement)
        chn:TPrincipal;
        constructor create(prev,eld:TStatement);
        procedure exec;override;
        destructor destroy;override;
    end;

constructor TClose.create(prev,eld:TStatement);
begin
    inherited create(prev,eld);
    chn:=channelexpression;
    if chn=nil then seterrexpected(s_ChannelExp,IDH_CLOSE)
end;

destructor TClose.destroy;
begin
   chn.free;
   inherited destroy
end;

procedure TClose.exec;
var
   w:longint;
begin
   w:=chn.evalInteger;
   if w>0 then PUnit.close(w)
   else if w<0 then setexception(7001)
      else
      //if InsideOfWhen then setexception(7002);
      ReportException(InsideOfWhen,7002)
end;

function CLOSEst(prev,eld:TStatement):TStatement;
begin
    CLOSEst:=TClose.create(prev,eld)
end;

type
     TErase=class(TClose)
        rs:tpRecordSetter;
        constructor create(prev,eld:TStatement; rs1:tpRecordSetter);
        procedure exec;override;
     end;

constructor TErase.create(prev,eld:TStatement; rs1:tpRecordSetter);
begin
    inherited create(prev,eld);
    rs:=rs1;
end;

procedure TERase.exec;
var
   ch:TTextDevice;
begin
   ch:=Channel(chn,Proc,PUnit);
   if (ch<>nil) then ch.erase(rs,InsideOfWhen)
end;

function ERASEst(prev,eld:TStatement):TStatement;
begin
    if token='REST' then
       begin
          gettoken;
          ERASEst:=TErase.create(prev,eld, rsNone)
       end
    else
       ERASEst:=TErase.create(prev,eld,rsBegin)
end;



procedure statementTableinit;
begin
   StatementTableInitImperative('OPEN',OPENst);
   StatementTableInitImperative('CLOSE',CLOSEst);
   StatementTableInitImperative('ERASE',ERASEst);
end;

begin
   tableInitProcs.accept(statementTableinit);
end.
