unit uHttpUtils;

interface
uses
  IdHTTP, System.IOUtils , System.Types, System.SysConst, System.Diagnostics,
  System.Classes, uHttpResponse, DMCem, uNetwork_Info, IdIOHandler,
  IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL, System.JSON,
  System.SysUtils, IdMultipartFormData, IdURI;

  type TTipoEnvio = (tpJson, tpUrlEncoded, tpRaw);
  type TIdHTTPAccess = class(TIdHTTP);
  type THttpOptions = class
    private
      token,
      urlResource,
      xmlJsonToSend,
      payload : AnsiString;
      gravaDadosLog,
      isListObjectJson,
      needPayload,
      encodeUrl : boolean;
      contentType : TTipoEnvio;
    public
      procedure ContentIsObjJson( enabled : Boolean = True ) ;
      procedure SetToken( security_token: AnsiString );
      procedure SetUrlResource( url: AnsiString );
      procedure SetContentToSend( contentToSend: AnsiString );
      procedure AddPayload( enabled : Boolean = True;
                            customPayload : AnsiString = 'payload=' );
      procedure SetEncodedUrl( enabled : Boolean = true );
  end;
  type THttpUtils = class
    private
      IdHTTP1 : TIdHTTP;
      IdSSLIOHandlerSocketOpenSSL1 : TIdSSLIOHandlerSocketOpenSSL;
      isListObjectJson,
      addPayload,
      gravaDadosLog,
      encodeUrl : boolean;
      token,
      payload : AnsiString;
      contentType : TTipoEnvio;

      procedure GravaLog( erro, acao, urlResource, xmlJsonText: string );
      function  PostObj( urlResource,
                         xmlJsonText : AnsiString ): THttpResponse;
      function GetObj( urlResource : AnsiString ) : THttpResponse;
      function PutObj( urlResource : string;
                       streamToSend : TStringStream ): THttpResponse;
      function DeleteObj( resource : AnsiString;
                          streamToSend : TStringStream ): THttpResponse;
      procedure SetToken;
      procedure SetContentType;
    public
      constructor Create;

  end;

  function PostHttp( options: THttpOptions ): THttpResponse;
  function GetHttpObj( options: THttpOptions ) : THttpResponse;
  function PutHttpObj( options: THttpOptions  ) : THttpResponse;
  function DeleteHttp( options: THttpOptions ) : THttpResponse;
  function FaktoryHttpOptions( tipo : TTipoEnvio ): THttpOptions;

implementation

{ THttpUtils }

function PostHttp( options: THttpOptions ): THttpResponse;
var
  httpUt : THttpUtils;
begin
  httpUt := nil;
  Result := nil;

  if not DModCem.INetAtivo or not CheckINetConnection then
    Exit;

  try
    try
      httpUt := THttpUtils.Create;
      httpUt.contentType := options.contentType;
      httpUt.token := options.token;
      httpUt.gravaDadosLog := options.gravaDadosLog;
      httpUt.isListObjectJson := options.isListObjectJson;
      httpUt.addPayload := options.needPayload;
      httpUt.payload := options.payload;

      if options.encodeUrl then begin
        options.urlResource := TIdURI.URLEncode( options.urlResource );
        httpUt.IdHTTP1.HTTPOptions := httpUt.IdHttp1.HTTPOptions + [hoForceEncodeParams];
      end;

      Result := httpUt.PostObj( options.urlResource, options.xmlJsonToSend );
    except
      on E: Exception do;
    end;
  finally
    httpUt.Free;
  end;
end;

function GetHttpObj( options: THttpOptions ) : THttpResponse;
var
  httpUt : THttpUtils;
begin
  httpUt := nil;
  Result := nil;

  if not DModCem.INetAtivo or not CheckINetConnection then
    Exit;

  try
    try
      httpUt := THttpUtils.Create;
      httpUt.contentType := options.contentType;
      httpUt.token := options.token;
      httpUt.gravaDadosLog := options.gravaDadosLog;
      httpUt.isListObjectJson := options.isListObjectJson;
      httpUt.addPayload := options.needPayload;

      Result := httpUt.GetObj( options.urlResource );
    except
      on E: Exception do;
    end;
  finally
    httpUt.Free;
  end;

end;

function PutHttpObj( options: THttpOptions  ) : THttpResponse;
var
  httpUt : THttpUtils;
begin
  httpUt := nil;
  Result := nil;

  if not DModCem.INetAtivo or not CheckINetConnection then
    Exit;

  try
    try
      httpUt := THttpUtils.Create;
      httpUt.token := options.token;
      httpUt.gravaDadosLog := options.gravaDadosLog;
      httpUt.encodeUrl := options.encodeUrl;

      if options.encodeUrl then begin
        options.urlResource := TIdURI.URLEncode( options.urlResource );
        httpUt.IdHTTP1.HTTPOptions := httpUt.IdHttp1.HTTPOptions + [hoForceEncodeParams];
      end;

      Result := httpUt.PutObj( options.urlResource,
                               TStringStream.Create( options.xmlJsonToSend,
                                                     TEncoding.UTF8 ) );
    except
      on E: Exception do;
    end;
  finally
    httpUt.Free;
  end;
end;

function DeleteHttp( options: THttpOptions ) : THttpResponse;
var
  httpUt : THttpUtils;
begin
  Result := nil;

  if not DModCem.INetAtivo or not CheckINetConnection then
    Exit;

  httpUt := THttpUtils.Create;
  try
    try
      httpUt.token := options.token;
      httpUt.gravaDadosLog := options.gravaDadosLog;
      httpUt.encodeUrl := options.encodeUrl;

      if options.encodeUrl then begin
        options.urlResource := TIdURI.URLEncode( options.urlResource );
        httpUt.IdHTTP1.HTTPOptions := httpUt.IdHttp1.HTTPOptions + [hoForceEncodeParams];
      end;

      Result := httpUt.DeleteObj( options.urlResource,
                                  TStringStream.Create( options.xmlJsonToSend,
                                                        TEncoding.UTF8 ));
    except
      on E: Exception do;
    end;
  finally
    httpUt.Free;
  end;
end;

function FaktoryHttpOptions( tipo : TTipoEnvio ): THttpOptions;
var
  httpOpt : THttpOptions;
begin
  httpOpt := THttpOptions.Create;
  httpOpt.contentType := tipo;
  httpOpt.gravaDadosLog := true;

  case tipo of
    tpUrlEncoded : begin
      httpOpt.AddPayload;
      httpOpt.SetEncodedUrl;
    end;
    tpRaw : begin
      httpOpt.AddPayload( false );
      httpOpt.SetEncodedUrl( false );
    end;
  end;

  Result := httpOpt;
end;

procedure THttpOptions.AddPayload( enabled : Boolean = True;
                                   customPayload : AnsiString = 'payload=' );
begin
  needPayload := enabled;
  payload := customPayload;
end;

procedure THttpOptions.ContentIsObjJson( enabled : Boolean = True );
begin
  isListObjectJson := enabled;
end;

procedure THttpOptions.SetContentToSend(contentToSend: AnsiString);
begin
  xmlJsonToSend := contentToSend;
end;

procedure THttpOptions.SetEncodedUrl(enabled: Boolean);
begin
  encodeUrl := enabled;
end;

procedure THttpOptions.SetToken(security_token: AnsiString);
begin
  token := security_token;
end;

procedure THttpOptions.SetUrlResource(url: AnsiString);
begin
  urlResource := url;
end;

constructor THttpUtils.Create;
begin
   IdHTTP1 := TIdHTTP.Create( nil );
   IdSSLIOHandlerSocketOpenSSL1 := TIdSSLIOHandlerSocketOpenSSL.Create( IdHTTP1 );
   IdSSLIOHandlerSocketOpenSSL1.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
   IdHTTP1.IOHandler := IdSSLIOHandlerSocketOpenSSL1;
   IdHTTP1.Request.Charset := 'utf-8';
   IdHttp1.Request.Accept := '*/*';
   IdHTTP1.Request.UserAgent := 'Mozilla/5.0 (Windows NT 10.0;Win64;x64) AppleWebKit/537.36 (KHTML,like Gecko) Chrome/58.0.3029.96 Safari/537.36';
   IdHTTP1.ReadTimeout := 9000000;
   IdHTTP1.HTTPOptions := IdHttp1.HTTPOptions - [hoForceEncodeParams];
end;

function THttpUtils.DeleteObj( resource : AnsiString;
                               streamToSend : TStringStream  ): THttpResponse;
const
  methodName = 'DeleteObj'; 
begin
  Result := nil;

  if not DModCem.INetAtivo or not CheckINetConnection then
    Exit;

  try
    try
      if ( resource <> '' ) then begin

        {TIdHTTPAccess(IdHTTP1).DoRequest( 'DELETE',
                                          resource,
                                          streamToSend,
                                          nil,
                                          [] );}
        IdHTTP1.Delete( resource, streamToSend );
        Result := ReturnHttpResponse( IdHTTP1, IdHTTP1.Response.ResponseText );
      end;
    except
      on E: EIdHTTPProtocolException do
        GravaLog( E.ErrorMessage, methodName, resource, '' );
      on E: Exception do
        GravaLog( E.Message, methodName, resource, '' );
    end;
  finally
  end;
end;

function THttpUtils.GetObj( urlResource : AnsiString ): THttpResponse;
const
  methodName = 'GetObj';
begin
  Result := nil;

  if not DModCem.INetAtivo or not CheckINetConnection then
    Exit;

  try
    try
      if ( urlResource <> '' ) then begin
        SetToken;
        SetContentType;
        Result := ReturnHttpResponse( IdHTTP1, IdHTTP1.Get( urlResource ) );
      end;
    except
      on E: Exception do
        GravaLog( E.Message, methodName, urlResource, '' );
    end;
  finally
    IdHTTP1.Free;
  end
end;

procedure THttpUtils.GravaLog( erro, acao, urlResource, xmlJsonText: string );
var
  arq: TextFile;
  msgErro : AnsiString;
begin

  if not gravaDadosLog then Exit;

  msgErro := Format( '[DataHora: %s]' + #13 +
                     'Mensagem retorno: %s' + #13 +
                     'Procedimento: %s '+ #13 +
                     'endpoint: %s' + #13 +
                     'JSON/XML: %s ' + #13 +
                     'Http Code: %d' + #13 +
                     'Http Response: %s' + #13,
                     [FormatDateTime('c', Now ), erro, acao, urlResource, xmlJsonText, IdHTTP1.ResponseCode, IdHTTP1.ResponseText] );

  try
    AssignFile( arq, 'httpUtils.txt' );

   if not( FileExists( 'httpUtils.txt' ) )then
     Rewrite( arq )
   else Append( arq );

   Writeln( arq, msgErro );
   CloseFile( arq );
  except
    on E : Exception do;
  end;

end;

function THttpUtils.PostObj( urlResource,
                             xmlJsonText : AnsiString ): THttpResponse;
const
  methodName = 'PostObj';
var
  TextToSend : TStringList;
  StreamToSend: TStringStream;
begin
  TextToSend := nil;
  StreamToSend := nil;
  Result := nil;
  try
    try
      if ( urlResource <> '' ) then begin

        SetToken;
        SetContentType;

        if ( isListObjectJson ) then begin
          Insert( '[', xmlJsonText ,0 );
          xmlJsonText := xmlJsonText + ']';
        end;

         if addPayload then
          xmlJsonText := payload + xmlJsonText;

        TextToSend := TStringList.Create;
        TextToSend.Add( xmlJsonText );

        if contentType = tpJson then begin
          StreamToSend := TStringStream.Create( xmlJsonText, TEncoding.UTF8 );
          Result := ReturnHttpResponse( IdHTTP1, urlResource, StreamToSend );
        end
        else
          Result := ReturnHttpResponse( IdHTTP1, IdHTTP1.Post( urlResource, TextToSend ) );
      end;

    except
      on E: EIdHTTPProtocolException do
        GravaLog( E.ErrorMessage, methodName, urlResource, xmlJsonText );
      on E: Exception do
        GravaLog( E.Message, methodName, urlResource, xmlJsonText );
    end;
  finally
    StreamToSend.Free;
    TextToSend.Free;
    IdHTTP1.Free;
  end;
end;

function THttpUtils.PutObj( urlResource: string;
  streamToSend: TStringStream ): THttpResponse;
const
  methodName = 'PutObj';
begin
  IdHTTP1.IOHandler := IdSSLIOHandlerSocketOpenSSL1;
  IdSSLIOHandlerSocketOpenSSL1.SSLOptions.Mode := sslmClient;
  IdSSLIOHandlerSocketOpenSSL1.SSLOptions.Method := sslvTLSv1_2;
  Result := nil;
  try
    try
      if ( urlResource <> '' ) then begin
        SetToken;
        SetContentType;
        Result := ReturnHttpResponse( IdHTTP1, IdHTTP1.Put( urlResource, streamToSend ) );
      end;
    except
      on E: EIdHTTPProtocolException do
        GravaLog( E.ErrorMessage, methodName, urlResource, '' );
      on E: Exception do
        GravaLog( E.Message, methodName, urlResource, '' );
    end;
  finally
    IdHTTP1.Free;
  end;
end;

procedure THttpUtils.SetContentType;
begin
  case contentType of
    tpJson : IdHTTP1.Request.ContentType := 'application/json';
    tpUrlEncoded : IdHTTP1.Request.ContentType := 'application/x-www-form-urlencoded';
    tpRaw : begin
      IdHTTP1.Request.ContentType := 'text/xml';
      IdHTTP1.Request.ContentEncoding := 'raw';
    end;
  end;
end;

procedure THttpUtils.SetToken;
begin
  if ( token <> '' ) then
    IdHTTP1.Request.CustomHeaders.Add( 'Authorization:Bearer ' + token );
end;

end.
