unit uHttpResponse;

interface
  uses IdHTTP, System.IOUtils , System.Types, System.SysConst, System.Diagnostics,
  System.Classes, System.SysUtils;

  type THttpResponse = class
    private
      FResponseCode: integer;
      FResponseText: string;
      FResponseContent: string;

    public
      constructor Create(http : TIdHttp = nil; response : string = '');
      property ResponseCode : integer read FResponseCode write FResponseCode;
      property ResponseText : string read FResponseText write FResponseText;
      property ResponseContent : string read FResponseContent write FResponseContent;
  end;

  function ReturnHttpResponse(http: TIdHttp; response : string = '') : THttpResponse; overload;

  function ReturnHttpResponse(http: TIdHttp;
                              URL: string;
                              textToSend: TStringList) : THttpResponse; overload;

  function ReturnHttpResponse(http: TIdHttp;
                              URL: string;
                              streamToSend: TStringStream) : THttpResponse; overload;

implementation

{ THttpResponse }

function ReturnHttpResponse(http: TIdHttp; response : string = '') : THttpResponse;
begin
  Result := THttpResponse.Create( http, response );
end;

function ReturnHttpResponse(http: TIdHttp;
                            URL: string;
                            textToSend: TStringList) : THttpResponse; overload;
var
  response: string;
begin
  try
    response := http.Post(URL, textToSend);
  except
    on E: EIdHTTPProtocolException do
      response := E.ErrorMessage;
  end;

  Result := THttpResponse.Create( http, response );
end;

function ReturnHttpResponse(http: TIdHttp;
                            URL: string;
                            streamToSend: TStringStream) : THttpResponse; overload;
var
  response: string;
begin
  try
    response := http.Post(URL, streamToSend);
  except
    on E: EIdHTTPProtocolException do
      response := E.ErrorMessage;
  end;

  Result := THttpResponse.Create( http, response );
end;

constructor THttpResponse.Create(http : TIdHttp = nil; response : string = '');
begin
  inherited Create;

  if http <> nil then begin
    ResponseCode := http.ResponseCode;
    ResponseText := http.Response.ResponseText;
  end;

  ResponseContent := response;
end;

end.
