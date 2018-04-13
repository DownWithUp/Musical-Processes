program MusicalProcesses;
//For entertainment purposes only

{$APPTYPE CONSOLE}

uses
  SysUtils,Windows;


function isOnlyNumbers(szInput : String) : Boolean;
var
i : integer;
begin
  result := false;
  for i := 1 to length(szInput) do begin
    if not (szInput[i] in ['0'..'9']) then begin
      result := false;
      exit;
    end else begin
      result := true;
      //No exit, because we need to verif we have all digits
    end;
  end;
end;

var
hProcess : THandle;
nPID : Cardinal;

begin
  if (paramCount <> 1) then begin
    writeln('Usage: ' + ExtractFileName(GetCurrentDir) + '.exe [PID]' );
    Halt(0);
  end else begin //Try to extract PID
    if (isOnlyNumbers(ParamStr(1))) then begin
      hProcess := OpenProcess(PROCESS_ALL_ACCESS, false, nPID);
      GetFileInformationByHandle(
    end else begin
      writeln('[!] Error: invalid PID');
      Halt(0);
    end;
  end;

  Readln;

end.
