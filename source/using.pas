unit using;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

(***************************************)
(* Copyright (C) 2003, SHIRAISHI Kazuo *)
(***************************************)


interface
uses  SysUtils, Dialogs, Controls,
      variabl,textfile,struct;
function literals(const form:ansistring; var i:integer):ansistring;
function ImageRef:TPrincipal;
procedure formatsub(ch:TTextDevice; p:TVar; var formatted:ansistring;
                     const form:ansistring;var i:integer;insideofwhen:boolean;
                     TabCount0:integer);

implementation
uses
      myutils,helpctex,base,texthand,express,
      format,sconsts ;

function ImageRef:TPrincipal;
var
    long:longint;
    index:integer;
begin
    result:=nil;
    if tokenspec=Nrep then  {行番号}
        begin
             if nonnegativeintegralnumber(long) and (long>0) then
               if pass=2 then
                  with programUnit do
                  begin
                     index:=imagelist.indexofobject(TObject(long));
                     if index>=0 then
                        imageRef:=TStrConstant.create(ImageList.strings[index])
                     else
                        seterr(SysUtils.Format(s_LineNotFound,[strint(long)]),IDH_PRINT_USING);
                  end
               else
             else
                seterrexpected(s_IllegalLineNumber,IDH_PRINT_USING);
        end
    else
        imageRef:=SExpression;
end;



function literals(const form:ansistring; var i:integer):ansistring;
var
     i0:integer;
begin
     i0:=i;
     while (i<=length(form)) and IsLiteral(form[i]) do
           begin
              //if IsDBCSLeadByte(byte(form[i])) then inc(i,2) else inc(i)
              ReadMBC(i,form);
              Inc(i);
           end;
     literals:=copy(form,i0,i-i0);

end;


procedure formatsub(ch:TTextDevice; p:TVar; var formatted:ansistring;
                     const form:ansistring;var i:integer;insideofwhen:boolean;
                     TabCount0:integer);
var
   j:integer;
   code:integer;
   exLen:integer;
begin
      if p=nil then exit;  { 1998.8.21 修正 ver3.51}

       if i>length(form) then
          begin
               ch.AppendStr(formatted);
               ch.newline;
               i:=1;
               formatted:='';
          end;

       {literals}
       formatted:=formatted +literals(form,i);

       {evaluate}

       {format an item}
        exLen:=length(formatted);
        formatted:=formatted + p.format(form,i,code);
        if ((code=8203) or (code=8204)) then
            if insideofWhen then
                extype:=code
            else
              begin
                   ReportException(InsideOfWhen,code);
                   ch.AppendStr(formatted);
                   ch.newline;
                   ch.Tab(TabCount0 + Exlen);
                   ch.AppendStr(p.str);
                   ch.newline;
                   ch.Tab(TabCount0);
                   for j:=1 to length(formatted) do formatted[j]:=' ';
              end;
     if extype=0 then
        formatted:=formatted +literals(form,i)
     else
        formatted:=''   ;
     if extype<>0 then setexception(extype);
end;

begin
end.
