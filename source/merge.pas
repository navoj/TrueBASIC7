unit merge;

interface
procedure MergeFile;
procedure RemoveMergedText;
var  MergedLineNumber:integer;

implementation
uses SysUtils,Classes,Forms,FileUtil,
     HelpCtex,SConsts,Base,TextHand,MyUtils,AFDG;

procedure MergeFile;
var
   FName:String;
begin
  gettoken;
  if pass=1 then
    if TokenSpec=SCon then
      begin
        FName:=TokenString;
        if not FileExists(Fname) then
           begin
             Fname:=ExtractFilePath(Application.ExeName)+'UserLib/'+TokenString;
             if not FileExists(Fname) then
                begin
                  Fname:=ExtractFilePath(Application.ExeName)+'Library/'+TokenString;
                  if not FileExists(Fname) then
                     seterr(tokenString + s_IsNotFound,0);
                end;
           end;
        if MergedLineNumber<0 then
           MergedLineNumber:=MemoLineCount;

        with TStringList.create do
          begin
           try
              LoadFromFile(FName);
           except
              seterr(tokenString + s_FailedOpen,0);
           end;
           if not ProgramFileCharsetUTF8  then
              text:=NativeToUTF8(text);
           Memo.lines.beginupdate;
           Memo.Lines.Text:=Memo.Lines.Text+EOL+Text;
           Memo.lines.endupdate;
           free;
          end;
      end
    else
      SetErr('',IDH_MERGE)  ;
  skip;
end;

Procedure RemoveMergedText;
var
   i:integer;
begin
  with Memo.Lines do
    begin
       beginUpdate;
       for i:=MemoLineCount-1 downto MergedLineNumber  do
          delete(i);
       endUpdate;
    end;
end;


end.
 
