unit uHttpResponse;

interface
  uses IdHTTP, System.IOUtils , System.Types, System.SysConst, System.Diagnostics,
  System.Classes;

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

  function ReturnHttpResponse(http: TIdHttp; response : string = '') : THttpResponse;

implementation

{ THttpResponse }

function ReturnHttpResponse(http: TIdHttp; response : string = '') : THttpResponse;
var
  objHttp : THttpResponse;
begin
  objHttp := THttpResponse.Create( http, response );
  Result := objHttp;
end;

constructor THttpResponse.Create(http: TIdHttp; response : string = '');
begin
  inherited Create;
  ResponseCode := http.ResponseCode;
  ResponseText := http.Response.ResponseText;
  ResponseContent := response;
end;

end.
