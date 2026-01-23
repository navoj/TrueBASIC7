unit htmlhelp;
{$MODE DELPHI}{$H+}
(***************************************)
(* Copyright (C) 2003, SHIRAISHI Kazuo *)
(***************************************)


interface

uses
  SysUtils, Types, Classes, Variants, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, ExtCtrls;

procedure OpenHelp(hcx:integer); overload;
procedure OpenHelp(key:Ansistring); overload;
procedure OpenBrowser(s:ansistring);



implementation

uses
  //HelpIntfs, ShellAPI,
  //process,
{$IFDEF Windows}
   Windows,
{$ELSE}
   unix,LCLIntf,
{$ENDIF}
  MainFrm,hselect;

var
  CurrentPos:string;
  KeyWordRec:TStringList;

function HtmName(s:string):string;
var
  p:integer;
begin
  p:=pos('#',s);
  if p=0 then p:=length(s)+1;
  result:=copy(s,1,p-1);
end;

function Anchor(s:string):string;
var
  p:integer;
begin
  p:=pos('#',s);
  if p=0 then
    result:=''
  else
    result:=copy(s,p+1,length(s)-p);
end;

function LinkSelect(const HelpString: String):string;
var
   i:integer;
   s:string;
begin
  s:=KeyWordRec.Values[HelpString];
  if (s='')then
       result:='BASICHelp.html'
  else if s[1]<>'"' then
       result:=s
  else
   begin
     with TStringList.Create do
     begin
       CommaText:=s;
       with HelpSelector do
        begin
          RadioGroup1.Caption:=HelpString;
          for i:=0 to (count-1) div 2 do
                RadioGroup1.items.add(strings[i*2]);
          RadioGroup1.ItemIndex:=0;
          //RadioGroup1.SetFocus;
          ShowModal;
          result:=Strings[RadioGroup1.ItemIndex *2 +1];
          RadioGroup1.items.Clear;
        end;
       Free;
      end;
   end;
end;

var
  HelpContexts:array [0..999] of string ;
  ALinks:TStringList;


procedure InitHelpContexts;
var
   F:text;
   n:integer;
   s:string;
   p:integer;
   c:integer;

begin
   assignFile(F,ChangeFileExt(Application.ExeName,'.hcx'));
{$I-}
   Reset(F);
   if IOResult=0 then
     begin
       while not EOF(F) do
         begin
           Readln(F,s);
           p:=pos(' ',s);
           if p>0 then
             begin
               val(copy(s,p,maxint),n, c);
               if (n>=0) and (n<=999) then HelpContexts[n]:=copy(s,1,p-1);
             end;
         end;
       Close(F);
     end;
{$I+}
end;

procedure InitALinks;
var
   s:string;
begin
  s:=ChangeFileExt(Application.ExeName,'.hlk');
  ALinks:=TStringList.create;
  try
      ALinks.LoadFromFile(s) ;
  except
      ShowMessage(s + ' not found')
  end;
end;



procedure InitKeyWordRec;
var
   F:text;
   s:string;
begin
   KeywordRec:=TStringList.create;
   KeywordRec.CaseSensitive:=false;
   AssignFile(F,ChangeFileExt(Application.ExeName,'.hkw'));
{$I-}
   Reset(F);
   if IOResult=0 then
     begin
       while not EOF(F) do
         begin
           Readln(F,s);
           KeywordRec.add(s);
         end;
       close(F);
     end;
{$I+}
end;


procedure OpenBrowser(s:ansistring);
var
   i:integer;
begin
   s:=ExtractFilePath(Application.ExeName)+ s;
{$IFDEF Windows}
   ShellExecute(FrameForm.Handle, nil, PChar(s), nil, PChar(GetCurrentDir), 0);
{$ELSE}
  {$IFDEF Darwin}
   //Shell('Open ' + s);
   openURL('file://'+s);
  {$ELSE}
  //Shell('firefox ' + s + ' &');
  openURL('file://'+s);
  {$ENDIF}
{$ENDIF}
end;


procedure OpenHelp(hcx:integer);
var
   s:ansistring;
begin
   s:=ALinks.Values[HelpContexts[hcx]];
   if s='' then
         s:='BASICHelp.html'
   else
        {$IFDEF Windows}
         s:='html\'+s;
        {$ELSE}
         s:='html/'+s;
        {$ENDIF}
   OpenBrowser(s);
end;

procedure OpenHelp(key:ansistring);
begin
  OpenBrowser(LinkSelect(key));
end;

(*

type
  TKeywordHelp = class(TInterfacedObject , ICustomHelpViewer)
  private
    FViewerID : Integer;
    FHelpManager : IHelpManager;
  public
    { ICustomHelpViewer }
    function GetViewerName: string;
    function UnderstandsKeyword(const HelpString: String): Integer;
    function GetHelpStrings(const HelpString: String): TStringList;
    function CanShowTableOfContents: Boolean;
    procedure ShowHelp(const HelpString: String);
    procedure ShowTableOfContents;
    procedure NotifyID(const ViewerID: Integer);
    procedure SoftShutDown;
    procedure ShutDown;
    property HelpManager: IHelpManager read FHelpManager write FHelpManager;
    property ViewerID: Integer read FViewerID;
  end;


function TKeywordHelp.CanShowTableOfContents: Boolean;
begin
  result:=FileExists(FHelpManager.GetHelpFile);
end;

function TKeywordHelp.GetViewerName: String;
begin
  Result := 'BASIC Help';
end;

procedure TKeywordHelp.NotifyID(const ViewerID: Integer);
begin
  FViewerID := ViewerID;
end;

function TKeywordHelp.GetHelpStrings(const HelpString: String): TStringList;
begin
  Result := TStringList.Create;
  Result.Add(HelpString);
end;

procedure TKeywordHelp.ShowHelp(const HelpString: String);
begin
   ShellExecute(FrameForm.Handle, nil, PChar(LinkSelect(HelpString)), nil, nil, 0);
  //HelpForm.SetBrowser(LinkSelect(HelpString));
end;

procedure TKeywordHelp.ShowTableOfContents;
begin
   ShowHelp('')
end;

procedure TKeywordHelp.ShutDown;
begin
end;

procedure TKeywordHelp.SoftShutDown;
begin
  //HelpForm.Close
end;

function TKeywordHelp.UnderstandsKeyword(const HelpString: String): Integer;
begin
  result:=1
end;


type TExtendedHelp=class(TkeywordHelp,IExtendedHelpViewer)
  private
  public
   function UnderstandsContext(const ContextID: Integer; const HelpFileName: String): Boolean;
   procedure DisplayHelpByContext(const ContextID: Integer; const HelpFileName: String);
   function UnderstandsTopic(const Topic: String): Boolean;
   procedure DisplayTopic(const Topic: String);
  end;

function TExtendedHelp.UnderstandsContext(const ContextID: Integer; const HelpFileName: String): Boolean;
begin
 result:=  (ContextID>=0) and (ContextID<=999) 
end;


procedure TExtendedHelp.DisplayHelpByContext(const ContextID: Integer; const HelpFileName: String);
var
  s:ansistring;
begin
   s:= 'html/'+ALinks.Values[HelpContexts[ContextId]];
   ShellExecute(FrameForm.Handle, nil, PChar(s), nil, nil, 0);

   //HelpForm.SetBrowser('html/'+ALinks.Values[HelpContexts[ContextId]]);
end;

function TExtendedHelp.UnderstandsTopic(const Topic: String): Boolean;
begin
 result:=false
end;

procedure TExtendedHelp.DisplayTopic(const Topic: String);
begin
end;


var
  HelpViewer: TExtendedHelp;
*)


initialization
   InitKeyWordRec;
   InitHelpContexts;
   InitALinks;

(*
   //Application.HelpFile:=ChangeFileExt(Application.ExeName,'.htm');
   Application.HelpType:=htContext ;
   HelpViewer := TExtendedHelp.Create;
   RegisterViewer(HelpViewer, HelpViewer.FHelpManager);
*)
finalization
   ALinks.Free;
   KeywordRec.free;
(*
   with HelpViewer do
       if Assigned(FHelpManager) then FHelpManager.Release(FViewerID);
*)
end.

