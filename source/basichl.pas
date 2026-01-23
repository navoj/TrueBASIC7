unit basicHL;


{$mode objfpc}{$H+}

interface

uses
   Classes,SynEditHighlighter,
   kwlist;


  { TSynHLBasic }
type
       TParamsList=class;
type
  TSynHLBasic = class(TSynCustomHighlighter)
  protected
    // accesible for the other inheritances
 public
   FTokenPos, FTokenEnd: Integer;
   FLineText: String;
   CurrentTBL: TKeyWordList1;
   ParenNest:integer;
   ParamsList:TParamsList;
    procedure SetLine(const NewValue: String; LineNumber: Integer); override;
    procedure Next; override;
    function  GetEol: Boolean; override;
    procedure GetTokenEx(out TokenStart: PChar; out TokenLength: integer); override;
    function  GetTokenAttribute: TSynHighlighterAttributes; override;
    function GetToken: String; override;
    function GetTokenPos: Integer; override;
    function GetTokenKind: integer; override;
    function GetDefaultAttribute(Index: integer): TSynHighlighterAttributes; override;
    //function GetTokenAttribute: TSynHighlighterAttributes; override;
    //procedure Next; override;
    procedure SetRange(Value: Pointer); override;
    procedure ResetRange; override;
    function GetRange: Pointer; override;
    constructor Create(AOwner: TComponent); override;
    destructor  destroy; override;
  private
   IsExternalLine,IsEndLine,AfterTHEN:boolean;
   DeclLineIndex:integer;
   function NextToken:string;
   function isSimpleIFline:boolean;
  published

end;



type
   TParamsList=class(TStringList)
     constructor create(Line0:integer);
    private
      DeclLine:integer;
   end;





implementation
uses
  SysUtils, Forms, Graphics, Dialogs, SynEditTypes;

Constructor TParamsList.create(Line0:integer);
begin
   inherited create;
   DeclLine:=Line0;
   Sorted:=true;
   Duplicates:=dupIgnore;
end;




constructor TSynHLBasic.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);




  AddAttribute(StringAttri);
  AddAttribute(CommentAttri);
  AddAttribute(BlockAttri);
  AddAttribute(DeclativeAttri);
  AddAttribute(ImperativeAttri);
  AddAttribute(ParamsAttri);
// Ensure the HL reacts to changes in the attributes.
  // Do this once, if all attributes are created
  SetAttributesOnChange(@DefHighlightChange);


  DeclLineIndex:=-1;
end;
destructor TSynHLBasic.destroy;
var
  i:integer;
begin
  inherited destroy;
end;

  var
    ExLineIndex:integer=-1;

procedure TSynHLBasic.SetLine(const NewValue: String; LineNumber: Integer);
begin
  inherited;
  IsExternalLine:=false;
  InsideString:=false;
  IsEndLine:=false;
  AfterTHEN:=false;
  //If LineIndex<>ExLineIndex then
  ExLineIndex:=LineIndex;
  FLineText := NewValue;
  // Next will start at "FTokenEnd", so set this to 1
  FTokenEnd := 1;
  CurrentTBL:=nil;
  Next;
end;



procedure TSynHLBasic.Next;
var
  len: Integer;
  s: string;
begin
  // FTokenEnd should be at the start of the next Token (which is the Token we want)
  FTokenPos := FTokenEnd;
  // assume empty, will only happen for EOL
  FTokenEnd := FTokenPos;

  // Scan forward
  // FTokenEnd will be set 1 after the last char. That is:
  // - The first char of the next token
  // - or past the end of line (which allows GetEOL to work)

  len := length(FLineText);
  If FTokenPos > len then
     // At line end
    begin

       if (CurrentTBL<>nil) and (CurrentTBL.kind=kdDEF) then
                           if ParamsList<>nil then FreeAndNil(ParamsList);

       CurrentTBL:=nil;
       ParenNest:=0;
       exit
    end
  else if (CurrentTBL<>nil) and (CurrentTBL.Attr=CommentAttri) then
    begin
       while not(FLineText[FTokenEnd] in [#0, #10, #13]) do
          inc(FTokenEnd);
    end
  else if  FLineText[FTokenEnd] ='"' then     // string
    begin
       insideString:=true;//CurrentTBL:=StringRange;
       repeat
         inc(FTokenEnd);
         case FLineText[FTokenEnd] of
           #0, #10, #13: break;
         end;
       until FLineText[FTokenEnd] in [#0, '"'];
       if (FLineText[FTokenEnd]<>#0)
                                     then inc(FTokenEnd);
    end
  else if FLineText[FTokenEnd] in [#9, ' '] then
    // At Space? Find end of spaces
    while (FTokenEnd <= len) and  (FLineText[FTokenEnd] in [#0..#32]) do inc (FTokenEnd)
  else if (FLineText[FTokenEnd] in ['0'..'9','A'..'Z', 'a'..'z',#128..#255]) then
    // At Numeric or Alphabetic. Find end of token
    while (FTokenEnd <= len)
    and  (FLineText[FTokenEnd] in ['$','0'..'9','A'..'Z','_', 'a'..'z',#128..#255]) do inc (FTokenEnd)
  else
    inc (FTokenEnd)   ;

   s:= UpperCase(copy(FLineText, FTokenPos, FTokenEnd - FTokenPos));
   if (s='EXTERNAL') or (s='EXIT') then IsExternalLine:=true
   else if s='END' then IsEndLine:=true
   else if((s='FUNCTION') or (s='SUB') or (s='PICTURE')) then
       if IsEndLine then  DeclLineIndex:=-1
       else if not isExternalLine then DeclLineIndex:=LineIndex ;
end;

function TSynHLBasic.GetTokenAttribute: TSynHighlighterAttributes;
var
  s:string;
  i:integer;
begin
  Result:=nil;

  if insideString{CurrentTBL=StringRange} then
    begin
       Result := StringAttri;
       insidestring:=false;//CurrentTBL:=nil;
       exit
    end
  else if CurrentTBL=CommentRange then
      Result:=CommentAttri
  else
    begin
        s:= UpperCase(copy(FLineText, FTokenPos, FTokenEnd - FTokenPos));

        if s='' then
           begin
             CurrentTBL:=nil;
             {
             if (CurrentTBL<>nil) and (CurrentTBL.name='DEF')then
                if  ParamsList<>nil then FreeAndNil(ParamsList);
             }
           end
        else if s='!'  then
          begin
             Result:=CommentAttri;
             CurrentTBL:=CommentRange;
         end
        else if (ParenNest>0) and not isExternalLine and  (s[1] in ['A'..'Z'])  then
                begin
                    result:=ParamsAttri;
                    if ParamsList<>nil then ParamsList.add(s)
                end
       else if AfterTHEN and (s='ELSE') then
             begin
                 Result:=ImperativeAttri;
                 CurrentTBL:=nil
             end
       else if (ParamsList<>nil)
             and ((ParamsList.DeclLine=DeclLineIndex) or (ParamsList.DeclLine=LineIndex))
                and ParamsList.find(s,i) then
                result:=ParamsAttri
       else if  CurrentTBL<>nil then
             begin
               if (s<>'') {and  (s[1] in ['A'..'Z'])} and (CurrentTbl.kind=kdAny) then
                   begin
                     result:=nil;
                      CurrentTBL:=TKeyWordList1(CurrentTBL.objects[0])
                   end
               else
               if CurrentTBL.find(s,i) then
                   begin
                      //if s[1]='=' then
                      //  Result:=nil
                      //else
                        Result:=CurrentTBL.attr;
                      if (CurrentTBL.kind=kdIF) and isSimpleIFline then
                         begin
                            Result:=ImperativeAttri;
                            CurrentTBL:=nil;
                            AfterTHEN:=true;
                         end
                      else if  (CurrentTBL.kind=kdEND)
                         and ((s='FUNCTION') or (s='SUB') or (s='PICTURE')) then
                         begin if (ParamsList<>nil) then FreeAndNil(ParamsList); end
                      else
                         CurrentTBL:=TKeyWordList1(CurrentTBL.objects[i]);
                   end
                else if (s='(') then
                   begin
                      if (CurrentTBL.kind=kdDEF)
                       or (CurrentTBL.kind=kdFunctionSubPicture) then
                       inc(ParenNest)
                   end
                else if (s=')') then
                   begin
                     if (CurrentTBL.kind=kdDEF)
                      or (CurrentTBL.kind=kdFunctionSubPicture) then
                       dec(ParenNest)
                   end
                else if (s='=') then
                   begin
                     if (CurrentTBL.kind=kdDEF)  then
                       ParenNest:=-128;
                   end
                ;
             end
        else if StatementKWList.find(s,i)   then
          begin
            CurrentTBL:=TKeyWordList1(StatementKWList.objects[i]);
            if CurrentTBL<>nil then
              begin
                Result:=CurrentTBL.Attr;
                if (CurrentTBL.kind=kdFUNCTIONSUBPICTURE) and not IsExternalline
                   or (CurrentTBL.kind=kdDEF) then
                   begin
                      ParamsList:=TParamsList.create(LineIndex);
                   end
                else if (CurrentTBL.kind=kdIF) and isSimpleIFline then
                   Result := ImperativeAttri
                else if (CurrentTBL.kind=kdMODULE) and (NextToken='OPTION') then
                   begin
                       Result := DeclativeAttri;
                       CurrentTBL:=nil;
                   end
                else if CurrentTBL=CommentRange {REM} then
                   Result := DeclativeAttri
            ;
              end;
          end
        else if (s<>'') and (s[1] in ['A'..'Z']) then //不正な命令
          CurrentTBL:=DummyTBL;

   end;
end;



function TSynHLBasic.GetEol: Boolean;
begin
  Result := FTokenPos > length(FLineText);
end;

procedure TSynHLBasic.GetTokenEx(out TokenStart: PChar; out TokenLength: integer);
begin
  TokenStart := @FLineText[FTokenPos];
  TokenLength := FTokenEnd - FTokenPos;
end;

function TSynHLBasic.GetToken: String;
begin
  Result := copy(FLineText, FTokenPos, FTokenEnd - FTokenPos);
end;

function TSynHLBasic.GetTokenPos: Integer;
begin
  Result := FTokenPos - 1;
end;

function TSynHLBasic.NextToken:string;
var
  bkTokenPos,bkTokenEnd:integer;
begin
  bkTokenPos:=FTokenPos;
  bkTokenEnd:=FTokenEnd;
  Next;  Next;
  result:=GetToken;
  FTokenEnd := bkTokenEnd;
  FTokenPos := bkTokenPos;
end;

function TSynHLBasic.isSimpleIFline:boolean;
var
  i:integer;
begin
  result:=false;
  with TStringList.create do
  begin
    commatext:=FLineText;
    for i:=2 to count-2 do
       if (uppercase(strings[i])='THEN')
          and (strings[i+1][1] in ['0'..'9','A'..'Z', 'a'..'z']) then
       result:=true;
    free;
  end;
end;

function TSynHLBasic.GetDefaultAttribute(Index: integer): TSynHighlighterAttributes;
begin
  // Some default attributes
  case Index of
    SYN_ATTR_COMMENT: Result := CommentAttri;
    SYN_ATTR_IDENTIFIER: Result := ParamsAttri;
    //SYN_ATTR_WHITESPACE: Result := fDeclativeAttri;
    else Result := nil;
  end;
end;

function TSynHLBasic.GetTokenKind: integer;
var
  a: TSynHighlighterAttributes;
begin
  // Map Attribute into a unique number
  a := GetTokenAttribute;
  Result := 0;
  if a = DeclativeAttri then Result := 1;
  if a = BlockAttri then Result := 2;
  if a = ImperativeAttri then Result := 3;
  if a = ParamsAttri then Result := 4;
end;

{ Range }

procedure TSynHLBasic.ResetRange;
begin
  CurrentTBL := nil;
  ParenNest:=0;
  DeclLineIndex:=-1;
end;

procedure TSynHLBasic.SetRange(Value: Pointer);
begin
  // Set the current range (for current line)
  // The value is provided from an internal storage, where it was kept since the last scan
  // This is the and value of the previous line, which is used as start for the new line
  DeclLineIndex := PtrInt(Value);
end;

function TSynHLBasic.GetRange: Pointer;
begin
  // Get a storable copy of the cuurent (working) range
  Result := Pointer(PtrInt(DeclLineIndex));
end;

initialization



finalization


end.


