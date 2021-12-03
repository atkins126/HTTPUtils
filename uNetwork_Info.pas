// **************************************
// Fonte: http://stackoverflow.com/questions/3270186/how-to-get-mac-address-in-windows7
// **************************************
unit uNetwork_Info;

interface

procedure GetHostInfo(var Address: AnsiString);
function CheckNetAdapterOn: boolean;
function CheckINetConnection(ignoreMNR: boolean = false): boolean;
function Get_MACAddressList(OnlyActive: boolean = false): AnsiString;
function Get_MACAddress(FirstActive: boolean = false): AnsiString;
function uNetwork_Info_LastError: AnsiString;
function GetIPFromHost(const hostName: string): string;
function GetMacFromHost(const AServerName : string) : string;

implementation

uses AnsiStrings, Windows, winsock, ActiveX, ComObj, Variants, SysUtils,
  Dialogs, IdTCPClient,
  StStrL,WinInet;

var
  sAllMacs: AnsiString;
  sLastError: AnsiString;

procedure GetHostInfo(var Address: AnsiString);
var
  WSAData: TWSAData;
  HostEnt: PHostEnt;
  Name: array [0 .. 255] of AnsiChar;
begin
  try
    { no error checking... }
    WSAStartup(2, WSAData);
    Gethostname(Name, SizeOf(Name));
    HostEnt := gethostbyname(Name);
    with HostEnt^ do
      Address := Format('%d.%d.%d.%d', [Byte(h_addr^[0]), Byte(h_addr^[1]),
        Byte(h_addr^[2]), Byte(h_addr^[3])]);
    WSACleanup;
  except
    on Exception do
      Address := '0.0.0.0';
  end;
end;

// Check of net adapter is on
function CheckNetAdapterOn: boolean;
var
  Address: AnsiString;
begin
  GetHostInfo(Address);
  Result := (Address <> '0.0.0.0') and (Address <> '127.0.0.1');
end;

// Check Network (Internet) Connection
function CheckINetConnection(ignoreMNR: boolean = false): boolean;
var
  IdTCPClient1: TIdTCPClient;
  s: AnsiString;
begin
  Result := false;
  s := Get_MACAddress(true);
  if (s = '') then
    exit;
  if ignoreMNR and ((s = '002564EBB889') or (s = '001C429C58D3')) then
    exit;
  IdTCPClient1 := TIdTCPClient.Create;
  try
    IdTCPClient1.ReadTimeout := 2000;
    IdTCPClient1.ConnectTimeout := 2000;
    IdTCPClient1.Port := 80;
    IdTCPClient1.Host := 'google.com';
    IdTCPClient1.Connect;
    IdTCPClient1.Disconnect;
    Result := true;
  except
    on Exception do;
  end;
  IdTCPClient1.Free;
end;

function Get_MACAddressList(OnlyActive: boolean = false): AnsiString;
var
  objWMIService: OLEVariant;
  colItems: OLEVariant;
  colItem: OLEVariant;
  oEnum: IEnumvariant;
  iValue: LongWord;
  wmiHost, root, wmiClass: AnsiString;

  function GetWMIObject(const objectName: AnsiString): IDispatch;
  var
    chEaten: Integer;
    BindCtx: IBindCtx; // for access to a bind context
    Moniker: IMoniker; // Enables you to use a moniker object
  begin
    OleCheck(CreateBindCtx(0, BindCtx));
    OleCheck(MkParseDisplayName(BindCtx, StringToOleStr(objectName), chEaten,
      Moniker));
    // Converts a string into a moniker that identifies the object named by the string
    OleCheck(Moniker.BindToObject(BindCtx, nil, IDispatch, Result));
    // Binds to the specified object
  end;

begin
  if (sAllMacs <> '') then
  begin
    Result := sAllMacs;
    exit;
  end;
  sAllMacs := '';
  try
    wmiHost := '.';
    root := 'root\CIMV2';
    wmiClass := 'Win32_NetworkAdapterConfiguration';
    objWMIService := GetWMIObject(Format('winmgmts:\\%s\%s', [wmiHost, root]));
    colItems := objWMIService.ExecQuery(Format('SELECT * FROM %s', [wmiClass]
      ), 'WQL', 0);
    oEnum := IUnknown(colItems._NewEnum) as IEnumvariant;
    while oEnum.Next(1, colItem, iValue) = 0 do
      if (VarToStr(colItem.MACAddress) <> '') then
        if (not OnlyActive) or colItem.IPEnabled then
          sAllMacs := sAllMacs + FilterL(VarToStr(colItem.MACAddress),
            ':') + ';';
  except
    on E: Exception do
    begin
      sAllMacs := '';
      sLastError := E.Message;
    end;
  end;
  if (sAllMacs <> '') then
    SetLength(sAllMacs, Length(sAllMacs) - 1);
  Result := sAllMacs;
end;

function Get_MACAddress(FirstActive: boolean = false): AnsiString;
var
  s: AnsiString;
  i: Integer;
begin
  s := Get_MACAddressList( FirstActive );
  if (s = '') then
    Result := ''
  else
  begin
    i := pos(';', s);
    if (i = 0) then
      Result := s
    else
      Result := copy(s, 1, i - 1);
  end;
end;

function uNetwork_Info_LastError: AnsiString;
begin
  Result := sLastError;
end;

function GetIPFromHost(const hostName: string): string;
type
  TaPInAddr = array [0 .. 10] of PInAddr;
  PaPInAddr = ^TaPInAddr;
var
  WSAData: TWSAData;
  phe: PHostEnt;
  pptr: PaPInAddr;
  Name: AnsiString;
  i: Integer;
begin
  try
    Name := hostName;
    WSAStartup(2, WSAData);
    try
      SetLength(Name, 255);
      Gethostname(PAnsiChar(Name), 255);
      phe := gethostbyname(PAnsiChar(Name));
      pptr := PaPInAddr(phe^.h_addr_list);
      i := 0;
      while pptr^[i] <> nil do
      begin
        Result := (AnsiStrings.StrPas(inet_ntoa(pptr^[i]^)));
        Inc(i);
      end;

      //verifica se o adaptador consegue
      //conexão com a internet
      {if (not CheckINetConnection) then
      begin
        Result := '127.0.0.1';
      end;}

    finally
      WSACleanup;
    end;
  except
    on Exception do
      Result := '';
  end;
end;

// ======================================================================
// Return the MAC address of Machine identified by AServerName
// Format of AServerName is '\\ServerName' or 'ServerName'
// If AServerName is a Null String then local machine MAC address
// is returned.
// Return string is in format 'XX-XX-XX-XX-XX-XX'
// http://delphi.cjcsoft.net/viewthread.php?tid=44262
// Google: delphi windows how to get MAC from host IP
// ======================================================================

function GetMacFromHost(const AServerName : string) : string;
type
     TNetTransportEnum = function(pszServer : PWideChar;
                                  Level : DWORD;
                                  var pbBuffer : pointer;
                                  PrefMaxLen : LongInt;
                                  var EntriesRead : DWORD;
                                  var TotalEntries : DWORD;
                                  var ResumeHandle : DWORD) : DWORD; stdcall;

     TNetApiBufferFree = function(Buffer : pointer) : DWORD; stdcall;

     PTransportInfo = ^TTransportInfo;
     TTransportInfo = record
                       quality_of_service : DWORD;
                       number_of_vcs : DWORD;
                       transport_name : PWChar;
                       transport_address : PWChar;
                       wan_ish : boolean;
                     end;

var E,ResumeHandle,
    EntriesRead,
    TotalEntries : DWORD;
    FLibHandle : THandle;
    sMachineName,
    Retvar : string;
    pBuffer : pointer;
    pInfo : PTransportInfo;
    FNetTransportEnum : TNetTransportEnum;
    FNetApiBufferFree : TNetApiBufferFree;
    pszServer : array[0..128] of WideChar;
    i : integer;
begin
  sMachineName := trim(AServerName);
  Retvar := '';

  // Add leading \\ if missing
  if (sMachineName <> '') and (length(sMachineName) > 2) then begin
    if copy(sMachineName,1,2) <> '\\' then
      sMachineName := '\\' + sMachineName
  end;

  // Setup and load from DLL
  pBuffer := nil;
  ResumeHandle := 0;
  FLibHandle := LoadLibrary('NETAPI32.DLL');

  // Execute the external function
  if FLibHandle <> 0 then begin
    @FNetTransportEnum := GetProcAddress(FLibHandle,'NetWkstaTransportEnum');
    @FNetApiBufferFree := GetProcAddress(FLibHandle,'NetApiBufferFree');
    E := FNetTransportEnum(StringToWideChar(sMachineName,pszServer,129),0,
                           pBuffer,-1,EntriesRead,TotalEntries,Resumehandle);

    if E = 0 then begin
      pInfo := pBuffer;

      // Enumerate all protocols - look for TCPIP
      for i := 1 to EntriesRead do begin
        if pos('TCPIP',UpperCase(pInfo^.transport_name)) <> 0 then begin
          Retvar := UpperCase( pInfo^.transport_address );
          break;
        end;
        inc(pInfo);
      end;
      if pBuffer <> nil then FNetApiBufferFree(pBuffer);
    end;

    try
      FreeLibrary(FLibHandle);
    except
      // Silent Error
    end;
  end;

  Result := Retvar;
end;

end.
