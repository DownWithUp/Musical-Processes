program MusicalProcesses;
//For entertainment purposes only :)

{$APPTYPE CONSOLE}

uses
  SysUtils, Windows, PSAPI;

function QueryFullProcessImageNameA(hProcess : THANDLE; dwFlags : DWORD; lpExeName : LPSTR;
                                 lpdwSize : PDWORD) : DWORD; stdcall; external 'kernel32.dll' name 'QueryFullProcessImageNameA';

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
value : DWORD = MAX_PATH;
szExeName: array[0..1024] of char;
cbNeeded, dwBytesRead  : DWORD;
phMods, phMod : PDWORD;
nTemp, nTemp2, i : integer;
szModName : array [0..1024] of Char;
ModInfo : MODULEINFO;
lpBuffer : array [0..1024] of Byte; //Static array, will only play first 1024 bytes in memory. A dynamic array set to "SizeOfImage" is too large.

procedure printHelp();
begin
  writeln('Usage: ' + ExtractFileName(GetCurrentDir) + '.exe [PID] [BAA] [SPEED]' );
  writeln(#9 + 'PID = Process Id (32 bit only)');
  writeln(#9 + 'NoB = Number of Bytes (to play) (MIN 2 = 2 Bytes, 4 = 4 Bytes MAX)');
  writeln(#9 + 'SPEED = The duration of each note (MIN 200, 4000 MAX)');
end;

procedure processBeeps(dwDIL, dwSpeed : DWORD);
var
i : integer;
wTemp : Word;
begin
  for i := 0 to sizeOf(lpBuffer) do begin
    case dwDIL of
    2: wTemp := lpBuffer[i];
    4: wTemp := lpBuffer[i] * $100 + lpBuffer[i+1];
    end;
    Writeln('[i] Note: 0x' + IntToHex(wTemp, 2));
    Beep(wTemp, dwSpeed);
  end;
  Writeln('[i] Thank you for listening!');
  Halt(0); //End of music, so end the process
end;

begin
  if (paramCount <> 3) then begin
    printHelp;
    Halt(0);
  end else begin //Try to extract PID
    if (isOnlyNumbers(ParamStr(1)) and isOnlyNumbers(ParamStr(2)) and isOnlyNumbers(ParamStr(2))) then begin
      nTemp := StrToInt(ParamStr(2));
      if (nTemp in [2, 4]) then begin
        nTemp := StrToInt(ParamStr(3));
        if (nTemp <= 4000) and (nTemp >= 200) then begin
          nPid := StrToInt(ParamStr(1));
          hProcess := OpenProcess(PROCESS_ALL_ACCESS, false, nPID);
          if (hProcess = 0) then begin //OpenProcess failed
            Writeln('[!] Error: OpenProcess failed!');
            Halt(0);
          end;
          QueryFullProcessImageNameA(hProcess, 0, szExeName, @value);
          writeln('[i] Targeting: ', szExeName);
          phMods := nil; //Not needed for first call to EnumProcessModules
          EnumProcessModules(hProcess, phMods, 0, cbNeeded); //See how many modules we needs
          GetMem(phMods, cbNeeded); //hMods now has enough room
          EnumProcessModules(hProcess, phMods, cbNeeded, cbNeeded);
          phMod := phMods;
          for i := 0 to (cbNeeded div sizeOf(THANDLE)) -1 do begin
            GetModuleFileNameEx(hProcess, phMod^, @szModName, sizeOf(szModName));
            //write(szModName, ' | ', IntToStr(phMod^)); //Debug only, NewLine included
            if(trim(szModName) = trim(szExeName)) then begin
              //Found the right module
              GetModuleInformation(hProcess, phMod^, @ModInfo, sizeOf(ModInfo));
              Writeln('[i] Entry Point: 0x', IntToHex(Integer(ModInfo.EntryPoint), 8));
              Writeln('[i] Estimated Size Of Image (Length of Music): 0x', IntToHex(Integer(ModInfo.SizeOfImage), 8));
              ReadProcessMemory(hProcess, ModInfo.EntryPoint, @lpBuffer, sizeOf(lpBuffer), dwBytesRead);
              Writeln('Found start of code. Press [RETURN] to play...');
              Readln;
              nTemp := StrToInt(ParamStr(2)); nTemp2 := StrToInt(ParamStr(3));
              processBeeps(nTemp, nTemp2); //Play the music
          end;
          Inc(phMod);
          Readln;
        end;
        readln;
        Halt(0);
      end else begin
        writeln('[!] Error: Invalid SPEED');
        printHelp;
        Halt(0);
      end;
    end else begin
      writeln('[!] Error: Invalid NoB');
      Halt(0);
    end;
  end else begin
    writeln('[!] Error: Invalid Parameters');
    printHelp;
    Halt(0);
  end;
  end;
  Readln;
end.
