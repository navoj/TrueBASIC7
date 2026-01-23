unit variablr;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}
(***************************************)
(* Copyright (C) 2006, SHIRAISHI Kazuo *)
(***************************************)

interface
uses sysUtils,arithmet,variabl,rational;

type
   TRVar=class(TAutoVar)
       public
          constructor create;
          constructor createR(p:PNumeric);
          destructor destroy;override;
          procedure substN(var n:number);   //override;
          procedure substZero;override;
          procedure substOne;override;
          procedure copyfrom(p:TVar);override;
          procedure assignwithNoRound(exp:TPrincipal);override;
          procedure assignX(x:extended);override;
          procedure assignLongint(i:longint);override;
          procedure getN(var n:number);  //override;
          procedure getX(var x:extended);override;
          procedure getR(var r:PNumeric);  //override;
          function evalInteger:integer;override;
          function evalLongint:longint;override;
          procedure swap(p:TVar);override;
          procedure read(const s:ansiString);override;
          //procedure readData(const s:ansiString);override;
          function str:ansiString;override;
          function str2:ansiString;override;
          function format(const form:ansiString; var index,code:integer):ansistring;override;
          function NewElement:TVar;override;
          function newcopy:TVar;override;
          procedure add(p:TVar);override;
          procedure multiply(p:TVar);override;
          procedure subtract(p:TVar);override;
          procedure addWithNoRound(p:TVar);override;
          procedure multiplyWithNoRound(p:TVar);override;
          function compare(p:TVar):integer;override;
          function compareP(exp:TPrincipal):integer;override;
          function sign:integer;override;
          procedure Roundvari;override;
       private
          value:Pnumeric;
          procedure substR(r:PNumeric);
          procedure sbtDirect(var p:PNumeric);
          procedure divDirect(var p:PNumeric);
     end;



type
  TRVarList = class(TVarList)
    private
       function newelement:TVar;override;
       function duplicate:TVarList;override;
  end;


type
     TRArray=class(TLegacyArray)
          function NewElement:TVar;override;
          function newcopy:TVar;override;
          function determinant(var n:PNumeric):boolean;
          function inverse:TArray;override;
       protected
          function NewAry(s:integer):TVarList;override;
       private
          function MatInv(var det:PNumeric):TRArray;
          //function minor(h:submatrix; var r:PNumeric):boolean;
          //function minordet(i,j:integer; var r:PNumeric):boolean;
     end;


implementation
uses base,format;

{ Complex Arithmetic}

{ Complex Arithmetic}



{*****}
{TRVar}
{*****}


procedure TRVar.RoundVari;
begin
end;

constructor TRVar.create;
begin
     inherited create;
end;

destructor TRVar.destroy;
begin
    disposeNumeric(value);
    inherited destroy
end;



procedure TRVar.substN(var n:number);
begin
    disposeNumeric(value);
    value:=NewRationalFromNumber(@n);
end;


procedure TRVar.substZero;
begin
    disposeNumeric(value);
    value:=Rational.ConstZero^.newCopy;
end;

procedure TRVar.substOne;
begin
    disposeNumeric(value);
    value:=Rational.ConstOne^.newCopy;
end;

procedure TRVar.copyfrom(p:TVar);
begin
   disposeNumeric(value);
   value:=TRVar(p).value^.newcopy;
end;


procedure  TRVar.assignX(x:extended);
var
    n:number;
begin
    convert(x,n);
    SubstN(n);
end;

procedure TRVar.assignLongint(i:longint);
begin
    disposeNumeric(value);
    value:=NewRationalLongInt(i);
end;


procedure TRVar.getN(var n:number);
begin
     value^.getN(n)
end;


procedure TRVar.getX(var x:extended);
begin
     value^.getX(x)
end;

function TRVar.evalInteger:integer;
var
  i,c:integer;
begin
    if (value<>nil) then
       begin
         value^.getLongint(i,c);
         if c>0 then result:=maxint
         else if c<0 then result:=MinInt
         else result:=i;
       end
    else
       result:=0;
end;

function TRVar.evalLongint:longint;
var
  c:integer;
begin
  value^.getLongint(result,c);
  if c<>0 then SetException(2001);
  //if c<>0 then  raise EInvalidOp.create('')
end;

procedure TRVar.swap(p:TVar);
var
   r:PNumeric;
begin
   {ポインタの交換}
   r:=value;
    value:=TRVar(p).value;
    TRVar(p).value:=r
end;

procedure TRVar.read(const s:ansiString);
var
   i,j,k:integer;
   s1,s2:ansistring;
   sgn:integer;
   p,ten,minus1:PNumeric;
   n:number;
   q:TRVar;
   x:longint;
   tenp:longint;
begin
   if (length(s)=0) or (s[1]='+')
      or (pos('.',s)>0) or (pos('E',s)>0) or (pos('e',s)>0) then
      begin
          NVal(s,n);
          substN(n);
          if extype=1002 then extype:=1006;
          exit;
      end;

  i:=pos('/',s);
  if i=0 then
    begin
       SubstZero;
        j:=1;
       if s[j]='-' then
          begin sgn:=-1 ;inc(j) end
       else if s[j]=' ' then
          begin sgn:=1 ;inc(j) end
       else
          sgn:=1;

       while (j<=length(s)) and ('0'<=s[j]) and (s[j]<='9') do
         begin
           k:=0;
           x:=0;
           tenp:=1;
           while (k<9) and  (j<=length(s)) and ('0'<=s[j]) and (s[j]<='9') do
            begin
                  x:=x*10+ (ord(s[j])-ord('0')) ;
                  inc(k);
                  inc(j);
                  tenp:=tenp*10;
            end;
           ten:=NewRationalLongint(tenp);
           p:=NewRationalLongint(x);
           Rational.mlt(value,ten,value);
           Rational.add(value,p,value);
           DisposeNumeric(p);
           disposeNumeric(ten);
         end;
       if j<=length(s) then setexception(8101);  //2023.10.18

       if sgn=-1 then
         begin
            minus1:= NewRationalLongint(-1);
            Rational.mlt(value,minus1,value);
            DisposeNumeric(minus1);
         end;
    end
  else
    begin
        q:=TRVar.create;
        s1:=copy(s,1,i-1);
        s2:=copy(s,i+1,length(s));
        read(s1);
        q.read(s2);
        divDirect(q.value);
        q.free;
    end;
end;


function TRVar.str:ansiString;
begin
   str:=StrFraction(value)+' '
end;

function TRVar.str2:ansiString;
begin
    Str2:=str;
end;

function TRVar.format(const form:ansiString; var index,code:integer):ansistring;
var
  n:Number;
begin
   getN(n);
   result:=formatnum(componentsN(n),form,index,code);
end;


function TRVar.newcopy:TVar;
begin
  result:=TRVar.createR(value^.newcopy);
end;

function TRVar.NewElement:TVar;
begin
   result:=TRVar.create;
end;

constructor TRVar.createR(p:PNumeric);
begin
    inherited create;
    value:=p;
end;

procedure TRVar.add(p:TVar);
begin
  rational.add(value, TRVar(p).value,value);
end;

procedure TRVar.subtract(p:TVar);
begin
  rational.sbt(value, TRVar(p).value,value)
end;

procedure TRVar.multiply(p:TVar);
begin
  rational.mlt(value, TRVar(p).value,value)
end;

procedure TRVar.addWithNoRound(p:TVar);
begin
  rational.add(value, TRVar(p).value,value);
end;

procedure TRVar.multiplyWithNoRound(p:TVar);
begin
  rational.mlt(value, TRVar(p).value,value);
end;

procedure TRVar.sbtDirect(var p:PNumeric);
begin
  rational.sbt(value,p,value);
end;

procedure TRVar.divDirect(var p:PNumeric);
begin
  rational.qtt(value,p,value);
end;


function TRVar.compare(p:TVar):integer;
begin
   compare:=rational.compare(value, TRVar(p).value)
end;


function TRVar.sign:integer;
begin
  sign:=value^.sign
end;


procedure TRVar.assignwithNoRound(exp:TPrincipal);
var
   r:PNumeric;
begin
   r:=nil;
   exp.evalR(r);
   disposeNumeric(value);
   value:=r;
end;

function TRVar.compareP(exp:TPrincipal):integer;
var
   r:PNumeric;
begin
   r:=nil;
   exp.evalR(r);
   compareP:=rational.compare(value,r);
   disposeNumeric(r)
end;

procedure TRVar.getR(var r:PNumeric);
begin
   disposeNumeric(r);
   r:=value^.NewCopy
end;

procedure TRVar.substR(r:PNumeric);
begin
   disposeNumeric(value);
   value:=r^.newCopy
end;


{*******}
{VarList}
{*******}



function TRVarList.duplicate:TVarList;
begin
   duplicate:=TRVarList.createdup(self)
end;



function TRVarList.NewElement:TVar;
begin
   NewElement:=TRVar.create
end;


{*****}
{Array}
{*****}


function TRArray.NewAry(s:integer):TVarList;
begin
    NewAry:=TRVarList.createNewElement(s,0)
end;


function TRArray.newcopy:TVar;
begin
    newCopy:=TRArray.createdup(self)
end;

function TRArray.NewElement:TVar;
begin
    result:=TRArray.createFrameCopy(self)
end;




{*******}
{TRArray}
{*******}
function TRArray.MatInv(var det:PNumeric):TRarray;
var
  i,j,k:integer;
  t,u,temp:PNumeric;
  v:TRVar;
label
  EXIT;
begin
  t:=nil; u:=nil; temp:=nil;
  result:=TRArray.createMatrix(size[1],size[2]);
  if result=nil then begin disposeNumeric(det) ; goto exit end;
  result.lbound:=lbound;

  for k:=0 to size[1]-1 do
       TRVar(result.pointij(k,k) ).substOne;
  disposeNumeric(det);
  det:=Rational.ConstOne^.newCopy;

  for k:=0 to size[1]-1 do
     begin
        i:=k;
        while  (i<size[1]) and (TRVar(pointij(i,k)).sign=0) do
                                                           inc(i);
        if i=size[1] then
           begin disposeNumeric(det); goto EXIT end
        else if i<>k then
           begin
              for j:=0 to size[1]-1 do
              begin
                 TRVar(pointij(i,j)).swap(TRVar(pointij(k,j)));
                 TRVar(result.pointij(i,j)).swap(TRVar(result.pointij(k,j)));
              end;
              Rational.oppose(det);
           end;

        TRVar(pointij(k,k)).getR(t);
        rational.mlt(det,t,det);
        for i:=k+1 to size[1]-1 do
            TRVar(pointij(k,i)).divDirect(t);
        for i:=0 to size[1]-1 do
            begin
              v:=TRVar(result.pointij(k,i));
              if v.sign<>0 then
                             v.divDirect(t);
            end;
        for j:=0 to size[1]-1 do
          if j<>k then
           begin
            TRVar(pointij(j,k)).GetR(u);
            for i:=k+1 to size[1]-1 do
                 begin
                   TRVar(pointij(k,i)).GetR(temp);
                   Rational.mlt(temp,u,temp);
                   TRVar(pointij(j,i)).sbtdirect(temp);
                 end;
            for i:=0 to size[1]-1 do
               begin
                  v:=TRVar(result.pointij(k,i));
                  if v .sign<>0 then
                    begin
                      v.GetR(temp);
                      Rational.mlt(temp,u,temp);
                      TRVar(result.pointij(j,i)).sbtdirect(temp);
                    end;
               end;
           end;
        //idle;
     end;
  EXIT:
end;


function TRArray.determinant(var n:PNumeric):boolean;
var
   p,q:TRArray;
begin
  if not ((dim=2) and (size[1]=size[2])) then
     setexception(6002);

  p:=TRArray.createdup(self);
  try
    q:=p.MatInv(n);
    q.free;
  finally
    p.free;
    if extype div 10=100 then extype:=1009;
  end;
  result:=(extype=0);
end;

function TRArray.inverse:TArray;
var
  det: PNumeric;
  p:TRArray;
begin
  det:=nil;
  p:=TRArray.createdup(self);
  result:=p.MatInv(det);
  p.free;
  if det.sign=0 then
     begin
        result.free;
        result:=nil;
       setexception(3009)
     end;
end;


end.
