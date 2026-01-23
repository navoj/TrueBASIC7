unit print;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}
(***************************************)
(* Copyright (C) 2006, SHIRAISHI Kazuo *)
(***************************************)


interface
uses Dialogs,Controls,
     struct;

function MatPrintst(prev,eld:TStatement):TStatement;
function MatWritest(prev,eld:TStatement):TStatement;
function IfThereClause(prev:TStatement):TStatement;

implementation

uses
     listcoll,base,texthand,textfile,variabl,express,control,io,using,format,
     helpctex,sconsts;

type
  TAbstractPrintItem=Class(TStatement)
      function  nextitem:TAbstractPrintItem;virtual;abstract;
      procedure execute(ch:TTextDevice);virtual;abstract;
    end;

  TPrint=class(TStatement)
         chn: TPrincipal;
         item:TAbstractPrintItem;
         ifthere:TStatement;
         RecordSetter:tpRecordSetter;
         option:IOoptions;
      constructor create(prev,eld:TStatement; mat:boolean; wri:boolean);
      destructor destroy;override;
      procedure  exec;override;
   end;


function IfThereClause(prev:TStatement):TStatement;
begin
     result:=nil;
     if (token='IF') and (nexttoken='THERE') then
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
             end;
       end;
end;


type
  TPrintItem=class(TAbstractPrintItem)
        exp:TPrincipal;
        direction:shortint;   {-1:TAB, 0:no care, 1:new zone, 2:new line}
        TAB:boolean;
      constructor create1;
      function  nextitem:TAbstractPrintItem;override;
      procedure execute(ch:TTextDevice);override;
      destructor destroy;override;
   end;

type
   TPrintUsing = class(TAbstractPrintItem)
           image:TPrincipal;
           items:TListCollection;
           direction:shortint;      { 0:no care,  2:new line}
        constructor create2(image1:TPrincipal);
        function initsub(image1:TPrincipal; mat:boolean):boolean;
        procedure execute(ch:TTextDevice);override;
        destructor destroy;override;
   end;

   TMatPrintUsing=class(TPrintUsing)
        constructor create2(image1:TPrincipal);
        procedure  execute(ch:TTextDevice);override;
   end;


function separator(var fin:boolean):integer;
begin
    fin:=false;
    separator:=2;
    if token=';' then
       begin
          separator:=0;
          gettoken
       end
    else if token=',' then
       begin
           separator:=1;
           gettoken
       end
    else
       fin:=true   ;
end;


constructor TPrintItem.create1;
var
  fin:boolean;
begin
    inherited create(nil,nil);
    if (token='TAB') and (IdRecord(false)=nil)
    then
       begin
          TAB:=true;
          gettoken;
          check('(',IDH_PRINT);
          exp:=NExpression;
          check(')',IDH_PRINT)
       end
    else
       if (token=',') or (token=';') then
            exp:=nil
       else
            begin
                exp:=NSExpression;
            end;
    direction:=separator(fin);
    if (not fin) and  (tokenspec<>tail) and (token<>'ELSE') then
            next:=NextItem;
end;

function  TPrintItem.NextItem:TAbstractPrintItem;
begin
    result:=TPrintItem.create1
end;



destructor TPrintItem.destroy;
begin
    exp.free;
    inherited destroy
end;


procedure TPrintItem.execute(ch:TTextDevice);
var
   s:ansistring;
   i:longint;
begin
   if ch.rectype<>rcDisplay then setexception(7313);
   case TAB of
     false:
           if exp<>nil then
                    begin
                       s:=exp.str;
                       ch.AppendStr(s);
                    end;

     true: begin
                i:=exp.evalLongint;
                if i<=0 then
                    //if insideofwhen then
                    //   setexception(4005)
                    //else
                    begin
                       i:=1;
                       ReportException(InsideOfWhen , 4005);
                    end;
                i:=((i-1) mod ch.askmargin)+ 1;
                ch.tab(i);
           end;
   end;
   if direction=1 then
       begin
           if (exp=nil) or (not TAB and (s='') ) then
              ch.AppendStr(' ');
           ch.NewZone
       end
   else if direction=2 then
           ch.newline;
   if next<>nil then TPrintItem(next).execute(ch);
end;

constructor TPrintUsing.create2(image1:TPrincipal);
begin
    initsub(image1,false) ;

end;


function TPrintUsing.initsub(image1:TPrincipal; mat:boolean):boolean;
var
    exp:TPrincipal;
begin
    initsub:=false;
    inherited create(nil,nil);
    image:=image1;
    items:=TListCollection.create;
    repeat
        if mat then
             exp:=Matrix
        else
             exp:=NSExpression;
        if exp=nil then exit;
        items.insert(exp);
    until test(',')=false;
    if token=';' then
       begin direction:=0; gettoken end
    else
       direction:=2;
    initsub:=true;
end;

destructor TPrintUsing.destroy;
begin
   items.free;
   image.free;
   inherited destroy;
end;

procedure TPrintUsing.execute(ch:TTextDevice);
var
   form:ansistring;
   formatted:ansistring;
   c,i:integer;
   p:TVar;
   TabCount0:integer;
begin
   if ch=nil then exit;

   if image<>nil then
                     form:=image.evalS ;
   if not TestFormatString(form) then
                                     setexception(8201);

   //ch.beginUpdate;
   formatted:='';
   i:=1;
   c:=0;
   TabCount0:=ch.TabCount;
   while (c<items.count) do
      begin
        p:=TPrincipal(items.items[c]).substance0(false);
        formatsub(ch,p,formatted,form,i,insideofwhen,TabCount0);
        TPrincipal(items.items[c]).disposeSubstance0(p,false);
        inc(c)
      end;

       ch.AppendStr(formatted);
       if direction=2 then ch.newline;

  //IdleImmediately;
  ch.flush;
end;

{*********}
{MAT PRINT}
{*********}


constructor TMatPrintUsing.create2(image1:TPrincipal);
begin
    initsub(image1,true);
end;


procedure TMatPrintUsing.execute(ch:TTextDEvice);
var
   form:ansistring;
   formatted:ansistring;
   c,i,j:integer;
   a:TArray;
   p:TVar;
begin
   if ch=nil then exit;

   ch.newlineifneed;
   //ch.beginUpdate;

   form:=image.evalS;
   if not TestFormatString(form) then
                                     setexception(8201);

   c:=0;
   formatted:='';
  i:=1;
   while (c<items.count) and (extype=0) do
       begin
           TVar(a):=TMatrix(items.items[c]).point;
           j:=0;
           while (j<a.amount) do
           begin
              p:=a.ItemSubstance0(j,false);
              formatsub(ch,p,formatted,form,i,insideofwhen, 0);
              a.DisposeSubstance0(p,false);
              inc(j);
           end;
           inc(c)
      end;
  ch.AppendStr(formatted);
  if direction=2 then ch.newline;
end;


destructor  TPrint.destroy;
begin
    item.free ;
    chn.free;
    inherited destroy;
end;


procedure  TPrint.exec;
var
    ch:TTextDevice;
begin
    ch:=channel(chn,Proc,Punit);
    if ch=nil then setexception(7004);
    ch.checkForOutput(option) ;
    //IdleImmediately;

    ch.Setpointer(RecordSetter,insideofWhen);
    if not ch.DataFoundForWrite then
      begin
         if item=nil then
               ch.newline
         else
           try
             item.execute(ch);
             ch.flush
           except
             ch.WBuffClear;
             raise
           end;
      end
    else
      if IfThere<>nil then
         begin
            extype:=0;
            IfThere.exec;
         end
      else
         setexceptionwith( s_DataFoundForWrite,extype);

end;

{**********}
{ Mat Print}
{**********}

type
     TMatPrintItem=class(TAbstractPrintItem)
         mat1:TMatrix;
         direction:integer;
      constructor create1;
      function  nextitem:TAbstractPrintItem;override;
      procedure execute(ch:TTextDevice);override;
      destructor destroy;override;
     end;

constructor TMatPrintItem.create1;
begin
    inherited Create(nil,nil);
    mat1:=matrix;
    if test(';') then
           direction:=0
    else if test(',') then
           direction:=1
    else
          direction :=2;
    if (tokenspec<>tail) and (token<>'ELSE') then
        next:=NextItem;
end;

function  TMatPrintItem.NextItem:TAbstractPrintItem;
begin
    result:=TMatPrintItem.create1
end;

destructor TMATPrintItem.destroy;
begin
    mat1.free;
    inherited destroy
end;

procedure TMatPrintItem.execute(ch:TTextDevice);
var
   p:TVar;
   subsc:array4;
   newzone:boolean;

     procedure column;
      var
         i:integer;
      begin
         with TArray(p) do
                     for i:=0 to size[dim]-1 do
                         begin
                             if newzone then ch.newzone;
                             subsc[dim]:=i;
                             ch.AppendStr(ItemStr(PositionNative(subsc)));
                         end;
         ch.NewLine;
     end;

  procedure row;
      var
         j:integer;
      begin
         with TArray(p) do
             if dim>1 then
                     for j:=0 to size[dim-1]-1 do
                         begin
                             subsc[dim-1]:=j;
                             column
                         end
             else
                  column;
         ch.NewLine;
     end;

var
   j,k:integer;
begin
   ch.newlineifneed;
   clearArray4(subsc);
   p:=mat1.point;
   if direction=0 then newzone:=false else newzone:=true;
     with TArray(p) do
       if dim=4 then
          for j:=0 to size[dim-3]-1 do
            begin
               subsc[dim-3]:=j;
               for k:=0 to size[dim-2]-1 do
                   begin
                       subsc[dim-2]:=k;
                       row
                   end

            end
       else if dim=3 then
               for k:=0 to size[dim-2]-1 do
                   begin
                       subsc[dim-2]:=k;
                       row
                   end
   else
                   row;
   if next<>nil then TAbstractPrintItem(next).execute(ch);
   //IdleImmediately;
end;


{***************}
{WRITE statement}
{***************}
type
  TWriteItem=class(TPRINTItem)
      constructor create1;
      function  nextitem:TAbstractPrintItem;override;
      procedure execute(ch:TTextDevice);override;
   end;

constructor TWriteItem.create1;
begin
    inherited create1;
    if tab or (direction=0)  then seterr(WriteSyntaxErrorMes,IDH_Write)
end;

function  TWriteItem.NextItem:TAbstractPrintItem;
begin
    result:=TWriteItem.create1
end;


procedure TWriteItem.execute(ch:TTextDevice);
var
   s:ansistring;
begin

   if (ch.RecType=rcDisplay) {and JISWrite} then
         begin inherited execute(ch); exit end;

   if exp<>nil then
            begin
               s:=exp.str2;
               ch.AppendStr(s);
            end;

   if direction=1 then
           ch.WriteSeparator(false)
   else if direction=2 then
           ch.newline;
   if next<>nil then TWriteItem(next).execute(ch);
end;

type
     TMatWriteItem=class(TMatPrintItem)
      constructor create1;
      function  nextitem:TAbstractPrintItem;override;
      procedure execute(ch:TTextDevice);override;
     end;

constructor TMatWriteItem.create1;
begin
    inherited create1;
    if direction=0 then seterr(WriteSyntaxErrorMes,IDH_Write)
end;

function  TMatWriteItem.NextItem:TAbstractPrintItem;
begin
    result:=TMatWriteItem.create1
end;


procedure TMatWriteItem.execute(ch:TTextDevice);
var
   p:TArray;
   i:integer;
   asize:integer;
   asize1:integer;
   s:AnsiString;
   rtCSV:boolean;
begin
   if (ch.RecType=rcDisplay)  then
         begin inherited execute(ch); exit end;

   rtCSV:=(ch.Rectype=rcCSV);
   TVar(p):=mat1.point;
   asize:=p.amount;
   //asize1:=p.size[1];
   asize1:=p.size[p.dim];              //2025.05.29  //ver. 8.1.4.2
   for i:=0 to asize-1 do
     begin
         s:=p.ItemStr2(i);
         ch.AppendStr(s);
         if i<asize-1 then ch.WriteSeparator(rtCSV and ((i+1) mod asize1=0));  //ver 7.5.1
       end;

   if next<>nil  then
      ch.WriteSeparator(rtCSV)
   else if direction=2 then
       ch.newline;
   if next<>nil then TMatWriteItem(next).execute(ch);

end;



{**********}
{Statements}
{**********}


constructor TPrint.create(prev,eld:TStatement; mat:boolean; wri:boolean);
var
  image:TPrincipal;
begin
   inherited create(prev,eld);
   if wri then option:=[ioReadWrite];
   image:=nil;
   textMode:=true;

   if wri or (token='#') then
      begin
         chn:=ChannelExpression;
         if chn=nil then
             SetErrExpected('#',IDH_INTERNAL_FILE);
         while token=',' do
            begin
               gettoken;
               if (token='USING') and not wri then
                   begin
                      gettoken;
                      image:=imageRef
                   end
               else if token='IF' then
                  IfThere:=IfThereClause(prev)
               else
                  RecordSetterClause(RecordSetter);
            end;
         if prevtoken=',' then seterrIllegal(token,IDH_FILE_PRINT);
         if not wri and not mat and ((tokenspec=tail) or (token='ELSE')) then exit;
         if not wri and not mat and (token=':') and
                                ((Nexttokenspec=tail) or (NextToken='ELSE')) then
            begin
               ReplaceToken(' ');
               Raise ERecompile.create('') ;
            end;

         checkToken(':',IDH_FILE_PRINT);
         if wri then
            if mat then
               item:=TMatWriteItem.create1
            else
               item:=TWriteItem.create1
         else if image<>nil then
            if mat then
                  item:=TMatPrintUsing.create2(image)
            else
                  item:=TPrintUsing.create2(image)
         else
            if mat then
                  item:=TMatPrintItem.create1
            else
                  item:=TPrintItem.create1 ;

      end
   else if (token='USING')
      and ((NextTokenSpec=NREP) or (NextTokenspecWithinParenthesis in [SCon,SIdf]))
      then
      begin
         gettoken;
         image:=ImageRef;
         if not mat and ((tokenspec=tail) or (token='ELSE')) then exit;
         if (token=';') then
             if permitMicrosoft then
                gettoken
             else if (AutoCorrect[ac_using]
                            {or confirm(s_ConfirmCorrectPRINT_USING,
                                       IDH_microsoft_IO)}) then
                    begin  {MS-syntax}
                      replacetoken(':');
                      gettoken;
                    end
                  else
         else
            checkToken(':',IDH_PRINT_USING);

         if mat then
              item:=TMatPrintUsing.create2(image)
         else
              item:=TPrintUsing.create2(image);

      end
   else
      begin
        if not mat and ((tokenspec=tail) or (token='ELSE') or (token=':')) then exit;
        if mat then
              item:=TMatPrintItem.create1
        else
              item:=TPrintItem.create1;
      end;

end;

function Printst(prev,eld:tStatement):TStatement;
begin
   result:=TPrint.create(prev,eld,false,false);
end;

function MatPrintst(prev,eld:TStatement):TStatement;
begin
  result:=TPrint.create(prev,eld,true,false)
end;


function  WRITEst(prev,eld:TStatement):TStatement;
begin
  result:=TPrint.create(prev,eld,false,true)
end;

function MatWritest(prev,eld:TStatement):TStatement;
begin
  result:=TPrint.create(prev,eld,true,true)
end;

function PRINTQst(prev,eld:TStatement):TStatement;
begin
   SelectPrevToken;   {SelectLine(TextHand.memo,linenumber);}
   if AutoCorrect[ac_using] or
     ( MessageDlg(s_QuestionMark,mtConfirmation,
                               [mbYes,mbNo],IDH_MICROSOFT_IO)=mrYes) then
      begin
      replaceprevToken('PRINT ');
      PRINTQst:=PRINTst(prev,eld)
      end
   else
      seterrIllegal(prevToken,IDH_MICROSOFT_IO)   ;
  end;

{******}
{LPRINT}
{******}

type
  TLPRINT=class(TPRINT)
    procedure exec;override;
  end;

procedure  TLPrint.exec;
begin
    //IdleImmediately;

    if item=nil then
       LocalPrinter.newline
    else
      begin
       try
          item.execute(LocalPrinter);
          LocalPrinter.flush
       except
          LocalPrinter.WBuffClear;
          raise
       end;
      end

end;



function LPRINTst(prev,eld:TStatement):TStatement;
begin
   if permitMicrosoft then
        result:=TLPRINT.create(prev,eld,false,false)
   else
        seterr(s_LPRINT,IDH_MICROSOFT_IO)   ;
end;



procedure statementTableinit;
begin
       statementTableinitImperative('PRINT',PRINTst);
       statementTableinitImperative('WRITE',WRITEst);
       statementTableinitImperative('?',PRINTQst);
       statementTableinitImperative('LPRINT',LPRINTst);
end;

begin
   tableInitProcs.accept(statementTableinit);
end.

