unit charinp;

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

(***************************************)
(* Copyright (C) 2003, SHIRAISHI Kazuo *)
(***************************************)


interface

uses
   SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls,
   LResources, {$IFDEF Windows} LazUTF8,{$ENDIF} fileutil,
   myutils,base;

type
  TCharInput = class(TForm)
    Label1: TLabel;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
  public
    option:IOoptions;
    c:ansistring;
    c1:ansistring;
    TimeLimit:TDateTime;
    Timeout:boolean;
    LineNumber:integer;
    procedure execute; //結果をc1にセットする
    procedure init;
  end;

var
  CharInput: TCharInput;

implementation
uses
    struct,debugdg;
{$R *.lfm}

{$IFDEF Windows}
function  isDBCSLeadByte(ch:byte):boolean;
  begin
     result:=char(ch) in LeadBytes;
  end;

procedure ReadSJIS(var i:integer; const s:AnsiString);
begin
   if isDBCSLeadByte(byte(s[i])) then
         inc(i);
end;
{$ENDIF}

procedure TCharInput.FormKeyPress(Sender: TObject; var Key: Char);
begin
   c:=c+key;
end;



procedure TCharInput.execute;
var
   svCtrlBreakHit:boolean;
   i:integer;
   s:ansistring;
begin
   timeout:=false;
   show;
   svCtrlBreakHit:=CtrlBreakHit;
   CtrlBreakHit:=false;
   Application.ProcessMessages;

   if not(ioNoWait in option) then
   Label1.visible:=true;

   if ioClear in option then
      c:='';


   While not((ioNoWait in option) or (Length(c)>0) or CtrlBreakHit or (now>=timelimit)) do
     begin
      setfocus;
      Application.processMessages;
     end;

   if Length(c)>0 then
      begin
         if ioCharacterByte in option then
           begin
              c1:=c[1];
              delete(c,1,1);
           end
         else
            {$IFDEF Windows}
             begin
               i:=1;
               ReadSJIS(i,c);           //Shift JISを読む
               if i<=Length(c) then
                 begin
                   c1:=WinCPToUTF8(copy(c,1,i));
                   delete(c,1,i);
                 end;
            end;
           {$ELSE}
            begin
              i:=1;
              ReadMBC(i,c);
              c1:=copy(c,1,i);
              delete(c,1,i);
            end;
           {$ENDIF}
      end
   else
      c1:='';
   CtrlBreakHit:=CtrlBreakHit or svCtrlbreakHit;

   //texthand.memo.sellength:=0;
   if not(ioNoWait in option) then
      begin
         hide;
         Label1.visible:=false;
      end;
   //caption:='';
   if (now>=charinput.TimeLimit) then Timeout:=true;

   Application.ProcessMessages;
   //if CtrlBreakHit then
   //     debugdg.BreakPr('inquiry');
end;


procedure TCharInput.FormCreate(Sender: TObject);
begin
   init;
   left:=0;
   top:=0;
   width:=4;
   {$IFDEF Darwin}
    height:=12;
   {$ELSE}
    height:=1;
   {$ENDIF}


end;

procedure TCharInput.Init;
begin
   c:='';
   Label1.caption:='';
end;

initialization



end.

