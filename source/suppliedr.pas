unit suppliedr;

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}


(***************************************)
(* Copyright (C) 2003, SHIRAISHI Kazuo *)
(***************************************)


interface

implementation
uses base,texthand,rational,variabl,struct,express,expressr, helpctex;

function ABSfnc:TPrincipal;
begin
    result:=UnaryR(rational.absolute,1003,'ABS')
end ;

function SGNfnc:TPrincipal;
begin
    result:=UnaryR(rational.sgn,1003,'SGN')
end ;

function INTfnc:TPrincipal;
begin
    result:=UnaryR(rational.BasicInt,1003,'INT')
end ;

function CEILfnc:TPrincipal;
begin
    result:=UnaryR(rational.ceil,1003,'CEIL')
end ;

function IPfnc:TPrincipal;
begin
    result:=UnaryR(rational.Intpart,1003,'IP')
end ;

function FPfnc:TPrincipal;
begin
    result:=UnaryR(rational.fractpart,1003,'FP')
end ;

function MODfnc:TPrincipal;
begin
    result:=BinaryR(rational.BasicMod,1003,'MOD')
end ;

function Remainderfnc:TPrincipal;
begin
    result:=BinaryR(rational.BasicRemainder,1003,'REMAINDER')
end ;

function MAXfnc:TPrincipal;
begin
    result:=BinaryR(rational.max,1003,'MAX')
end ;

function MINfnc:TPrincipal;
begin
    result:=BinaryR(rational.min,1003,'MIN')
end ;

function IntSQRfnc:TPrincipal;
begin
    result:=UnaryR(rational.IntSQR,1003,'INTSQR')
end ;

function IntLOG2fnc:TPrincipal;
begin
    result:=UnaryR(rational.IntLOG2,1003,'INTLOG2')
end ;

{******}
{Round }
{******}

procedure BasicRound(a,b:PNumeric; var x:PNumeric);
var
   p,q:PNumeric;
   i:longint;
   c:integer;
begin
   p:=nil;
   q:=constOne^.newCopy;
   b^.getLongInt(i,c);
   while i>0 do
     begin
       rational.mlt(q,constTen,q);
       dec(i)
     end;
   while i<0 do
     begin
       rational.qtt(q,constTen,q);
       inc(i)
     end;
   rational.mlt(a,q,p);
   intround(p);
   rational.qtt(p,q,p);
   disposeNumeric(q);
   disposeNumeric(x);
   x:=p;
end;

procedure Truncate(a,b:PNumeric; var x:PNumeric);
var
   p,q:PNumeric;
   i:longint;
   c:integer;
begin
   p:=nil;
   q:=constOne^.newCopy;
   b^.getLongInt(i,c);
   while i>0 do
     begin
       rational.mlt(q,constTen,q);
       dec(i)
     end;
   while i<0 do
     begin
       rational.qtt(q,constTen,q);
       inc(i)
     end;
   rational.mlt(a,q,p);
   intPart(p);
   rational.qtt(p,q,p);
   disposeNumeric(q);
   disposeNumeric(x);
   x:=p;
end;


function ROUNDfnc:TPrincipal;
var
   svcp:^tokensave;
   exp:TPrincipal;
   token1:string;
begin
   new(svcp);
   savetoken(svcp^);
   check('(',IDH_FUNCTIONS);
   exp:=NExpression;
   exp.free;
   token1:=token;
   try
     restoretoken(svcp^);
     if token1=')' then
      ROUNDfnc:=UnaryR(rational.intround,1002,'ROUND')
     else
      ROUNDfnc:=BinaryR(BasicRound,1002,'ROUND');
   finally
     dispose(svcp);
   end;
end;

function TRUNCATEfnc:TPrincipal;
begin
    TRUNCATEfnc:=BinaryR(truncate,1002,'TRUNCATE')
end ;


{**************}
{Fact,Perm,Comb}
{**************}

procedure perm(n,r:PNumeric; var x:PNumeric);
var
   a,y:PNumeric;
   k,i:longint;
   c:integer;
begin
   a:=n.newCopy;
   r^.getLongInt(k,c);
   if (c=0) and r^.isinteger and (r.sign>=0) then
      begin
          y:=constOne.newcopy;
          i:=0;
          while (i<k)  do
                   begin
                     rational.mlt(y,a,y);
                     rational.sbt(a,constone,a);
                     inc(i);
                     //idle
                   end;
          disposeNumeric(x);
          x:=y;
          disposeNumeric(a);
      end
   else
      begin
        disposeNumeric(a);
        setexception(4000);
      end;
end;

procedure comb(n,r:PNumeric; var x:PNumeric);
var
   a,b,y:PNumeric;
   k,i:longint;
   c:integer;
begin
   a:=n.NewCopy;
   b:=r.NewCopy;
   y:=n.Newcopy;
   rational.qtt(y,constTwo,y);
   if n^.isInteger and (n^.sign>0) and (rational.compare(r,y)>0) then
      rational.sbt(n,r,b);


   b^.getlongint(k,c);
   if (c=0) and b^.isinteger then
      if (b^.sign>=0) then
        begin
            disposeNumeric(y);y:=ConstOne^.newCopy;
            disposeNumeric(b);b:=ConstOne^.newCopy;
            i:=0;
            while (i<k) do
                   begin
                      rational.mlt(y,a,y);
                      rational.qtt(y,b,y);
                      rational.sbt(a,constone,a);
                      rational.add(b,constone,b);
                      inc(i) ;
                      //idle
                   end;
            disposeNumeric(a);
            disposeNumeric(b);
            disposeNumeric(x);
            x:=y;
        end
      else
        begin
            disposeNumeric(a);
            disposeNumeric(b);
            disposeNumeric(y);
            disposeNumeric(x);
            x:=ConstOne.newCopy
        end
   else
        begin
            disposeNumeric(a);
            disposeNumeric(b);
            disposeNumeric(y);
            setexception(4000);
        end
end;




procedure fact(var r:PNumeric);
begin
  perm(r,r,r)
end;

function FACTfnc:TPrincipal;
begin
    FACTfnc:=UnaryR(fact,4000,'FACT')
end ;

function PERMfnc:TPrincipal;
begin
   PERMfnc:=BinaryR(perm,4000,'PERM')
end;

function COMBfnc:TPrincipal;
begin
   COMBfnc:=BinaryR(comb,4000,'COMB')
end;

function NUMERfnc:TPrincipal;
begin
    Result:=UnaryR(numer,4000,'NUMER')
end ;

function DENOMfnc:TPrincipal;
begin
    result:=UnaryR(denom,4000,'DENOM')
end ;

function GCDfnc:TPrincipal;
begin
   GCDfnc:=BinaryR(gcd,4000,'GCD')
end;


procedure  FunctionTableInit;
begin
   if PrecisionMode=PrecisionRational then
   begin
       SuppliedFunctionTableInit('ABS',ABSfnc );
       SuppliedFunctionTableInit('INT',INTfnc );
       SuppliedFunctionTableInit('CEIL',CEILfnc );
       SuppliedFunctionTableInit('IP',IPfnc );
       SuppliedFunctionTableInit('FP',FPfnc );
       SuppliedFunctionTableInit('SGN',SGNfnc );
       SuppliedFunctionTableInit('MOD',MODfnc );
       SuppliedFunctionTableInit('REMAINDER',REMAINDERfnc );
       SuppliedFunctionTableInit('MAX',MAXfnc );
       SuppliedFunctionTableInit('MIN',MINfnc );
       SuppliedFunctionTableInit('INTSQR',IntSQRfnc );
       SuppliedFunctionTableInit('FACT',FACTfnc );
       SuppliedFunctionTableInit('PERM',PERMfnc );
       SuppliedFunctionTableInit('COMB',COMBfnc );
       SuppliedFunctionTableInit('NUMER',NUMERfnc );
       SuppliedFunctionTableInit('DENOM',DENOMfnc );
       SuppliedFunctionTableInit('ROUND' ,ROUNDfnc );
       SuppliedFunctionTableInit('TRUNCATE',TRUNCATEfnc );
       SuppliedFunctionTableInit('GCD',GCDfnc );
       SuppliedFunctionTableInit('INTLOG2',IntLOG2fnc );
   end;


end;

begin
   tableInitProcs.accept(FunctionTableInit);
end.
