unit debuglst;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

(***************************************)
(* Copyright (C) 2006, SHIRAISHI Kazuo *)
(***************************************)



interface
uses struct;
procedure SetDebugDlg(statement:TStatement);

implementation
uses  StdCtrls, Classes,
     listcoll,debugdg,texthand,variabl;
type
   TVarList=class(TListCollection)
       procedure murge(AList:TIdTable);
       procedure murgenull;
       procedure makeup(routine:TRoutine);
       function GetText(Item:integer):ansistring;
       procedure FreeItem(item:Pointer);override;
   end;

procedure TVarList.MurgeNull;
begin
    insert(nil)
end;

procedure TVarList.murge(AList:TIdTable);
var
   i:integer;
   idrec:TIdRec;
begin
   for i:=0 to AList.count-1 do
        begin
            idrec:=TIdRec(AList.items[i]);
            if (idrec.dim>=0) and (idrec.name<>'') and (idrec.subs<>nil) and
               (idrec.kindchar in ['n','s'])then
                insert(AList.items[i]);
        end;
end;

procedure TvarList.makeup(routine:TRoutine);
var
   module1:TModule;
begin
    if routine is TLocalProc then
       begin
          murge(routine.vartable);
          murgenull;
          makeup(TLocalProc(routine).parent)
       end
    else if routine is TModule then
       begin
          murge(TModule(routine).ShareVartable);
          murge(routine.vartable);
       end
    else if routine is TProgramUnit then
       begin
          murge(routine.vartable);
          module1:=TProgramUnit(routine).parent;
          if (module1<>nil) and (module1.ShareVarTable.count>0) then
             begin
                 murgenull;
                 murge(module1.ShareVarTable)
             end;
       end;
end;


procedure TVarList.FreeItem(Item:Pointer);
begin
   {Do Nothing...Items can not be disposed on this method}
end;


function TVarList.GetText(Item:integer):ansistring;
var
   idRec:TIdRec;
   a:TArray;
   i:integer;
   s:ansistring;
const maxlength=1024;
      HLine='--------------------------';
begin
   gettext:='';
   IdRec:=TIdRec(items[Item]);
   if IdRec=nil then
      GetText:=HLine
   else
   with IdRec do
     begin
        case Dim of
            0:if (subs<>nil) and (name<>'') then
                begin
                   s:=name+'='+subs.DEbugStr;
                end;
         1..4:if (subs<>nil) then
                begin
                   a:=TArray(subs.ptr);
                   s:=name+'(';
                   for i:= 1 to dim do
                     begin
                       if i>1 then s:=s+',';
                       s:=s+strint(a.lbound[i])
                           +' TO '
                           +strint(a.lbound[i]+a.size[i]-1);
                     end;
                   s:=s+')=';
                   s:=s+a.DebugString(MaxLength);
                end;
        end;
        GetText:=copy(s,1,maxlength);

     end;
end;


procedure makevarlist(routine:TRoutine; ValuesList:TStringList);
var
    varList:TVarList;
    i:integer;
begin
       VarList:=TVarList.create;
       VarList.makeup(routine);
       with VarList do
          for i:=0 to count-1 do
               ValuesList.add(GetText(i));
       VarList.free;
end;

procedure SetDebugDlg(statement:TStatement);
var
   list:TDebugList;
begin
  list:=TDebugList.create;
  with statement do
    begin
       with DebugDlg do
         begin
           list.linenumb:=linenumb;
           //list.statement:=TextHand.memo.lines[lineNumb];
           makevarlist(proc,list.ValuesList);
           addlist(list);
         end;
   end;      
end;


end.
