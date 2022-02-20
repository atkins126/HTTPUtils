# HTTPUtils
Tool for http requests (GET, POST, PUT, DELETE) for Delphi, simplifying Indy use.

Usage: 

-In the project, add the files uHttpResponse.pas, uHttpUtils.pas; 
-In the desired unit, add the uses uHttpResponse, uHttpUtils;
-Now, create the objects:

  http : THttpOptions;
  response : THttpResponse;

Object THttpOptions:

Responsible to invoke the methods GET, POST, PUT, DELETE.

Methods:

  function PostHttp( options: THttpOptions ): THttpResponse;
  function GetHttpObj( options: THttpOptions ) : THttpResponse;
  function PutHttpObj( options: THttpOptions  ) : THttpResponse;
  function DeleteHttp( options: THttpOptions ) : THttpResponse;

  function FaktoryHttpOptions( tipo : TTipoEnvio ): THttpOptions;
  This method return a THttpOptions object, according the wanted type passed in param 'tipo'. Options avaliable:
  
  -tpUrlEncoded: brings by default the options AddPayload and encode the defined URL;
  -tpRaw : brings by default the options AddPayload and encode the defined URL to false;
  -tpJson: set off both payload and encode URL;
      

Object THttpUtils;

Object THttpResponse:

All the methods GET, POST, PUT, DELETE returns a THttpResponse object. This object have the following properties:
-ResponseCode: return the HTTP code of response (200);
-ResponseText: return the HTTP response text (EX: 200 OK);
-ResponseContent: return the content, like JSON, XML etc.

