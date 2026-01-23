unit GraphQue;
{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}
interface
uses
  Classes, SysUtils;

procedure GraphOutExec;
Type
  TGraphCommand=Class
      procedure execute ;virtual;abstract;
  end;

  TGraphCommand2=class(TGraphCommand)
     prev:TGraphCommand;
     constructor create(p:TGraphCommand);overload;
     destructor destroy;override;
  end;

type
  pBoolean=^Boolean;
  TReSetBoolean=class(TGraphCommand)
    s:pBoolean;
    constructor create(var b:boolean);
    procedure execute;override;
    procedure ExecCore;virtual;
  end;

procedure AddQueue(s:TGraphCommand);
procedure WaitReady;

implementation
uses base,affine,graphsys,compiler,MyThread;

constructor TGraphCommand2.create(p:TGraphCommand);
begin
   inherited create;
   prev:=p;
  end;

destructor TGraphCommand2.destroy;
begin
    if prev<>nil then prev.free;
    inherited destroy;
  end;

constructor TReSetBoolean.create(var b:boolean);
begin
  inherited create;
  b:=true;
  s:=@b;
end;

procedure TReSetBoolean.execute;
begin
  ExecCore;
  s^:=false
end;

procedure TReSetBoolean.ExecCore;
begin
end;

procedure WaitReady;
var
  b:boolean;
begin
    addQueue(TReSetBoolean.create(b));
    while b do (TThread.CurrentThread).Yield  ;
end;

var
queue:array[0..65535]of TGraphCommand;
point0:word=0;
point1:word=0;

procedure GraphOutExec;
var
  p0:word;
begin
   p0:=point0;
   //if point1<>p0 then
     // RepaintRequest:=true;
   while point1<>p0 do
   begin
      with queue[point1] do
         begin
            execute;
            free;
         end;
      inc(point1);
      //RepaintRequest:=true;
      //Application.ProcessMessages;
    end;

end;

var AddQueueCriticalSection: TRTLCriticalSection;
procedure AddQueue(s:TGraphCommand);
begin
  if TThread.CurrentThread is TMyThread then
    begin
      //EnterCriticalSection(AddQueueCriticalSection);
      while word(point0+1)=point1 do (TThread.CurrentThread).Yield;
      queue[point0]:=s;
      inc(point0);
      //LeaveCriticalSection(AddQueueCriticalSection);
    end
  else
    with s do begin execute; free end

end;

initialization
InitCriticalSection(AddQueueCriticalSection);


finalization
DoneCriticalSection(AddQueueCriticalSection);



end.

