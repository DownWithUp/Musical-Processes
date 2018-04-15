program MusicalProcesses;
//For entertainment purposes only

{$APPTYPE CONSOLE}

uses
  SysUtils,Windows;


type
  THMODULE = ^HMODULE;


function QueryFullProcessImageNameA(hProcess : THANDLE; dwFlags : DWORD; lpExeName : LPSTR;
                                 lpdwSize : PDWORD) : DWORD; stdcall; external 'kernel32.dll' name 'QueryFullProcessImageNameA';

function EnumProcessModules(hProcess : THANDLE; lphModule : THMODULE; cb : DWORD;
                            lpcbNeeded : LPDWORD) : DWORD; stdcall; external 'PSAPI.dll'

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
nPID : Integer;
pImageFileName : PChar;
value : DWORD = MAX_PATH;
lpExeNames: array[0..255] of char;


begin
  if (paramCount <> 1) then begin
    writeln('Usage: ' + ExtractFileName(GetCurrentDir) + '.exe [PID]' );
    Halt(0);
  end else begin //Try to extract PID
    if (isOnlyNumbers(ParamStr(1))) then begin
      nPid := StrToInt(ParamStr(1));
      hProcess := OpenProcess(PROCESS_ALL_ACCESS, false, nPID);
      QueryFullProcessImageNameA(hProcess, 0, lpExeNames, @value);
      writeln(lpExeNames);
      EnumProcessModules(hProcess,

      readln;
      Halt(0);

    end else begin
      writeln('[!] Error: invalid PID');
      Halt(0);
    end;
  end;

  Readln;
end.
