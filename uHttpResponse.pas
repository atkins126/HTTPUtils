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
      constructor Create(http : TIdHttp; response : string = '');
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
var
  objHttp : THttpResponse;
begin
    objHttp := THttpResponse.Create( http, response );
    Result := objHttp;
end;

function ReturnHttpResponse(http: TIdHttp;
                            URL: string;
                            textToSend: TStringList) : THttpResponse; overload;
var
  objHttp : THttpResponse;
  response: AnsiString;
begin
  try
    response := http.Post(URL, textToSend);
    objHttp := THttpResponse.Create( http, response );
  except
    on E: Exception do;
  end;
end;

function ReturnHttpResponse(http: TIdHttp;
                            URL: string;
                            streamToSend: TStringStream) : THttpResponse; overload;
var
  response: AnsiString;
begin
  try
    response := http.Post(URL, streamToSend);
  except
    on E: EIdHTTPProtocolException do
      response := E.ErrorMessage;
  end;

  Result := THttpResponse.Create( http, response );
end;

constructor THttpResponse.Create(http: TIdHttp; response : string = '');
begin
  inherited Create;
  ResponseCode := http.ResponseCode;
  ResponseText := http.Response.ResponseText;
  ResponseContent := response;
end;

end.
