unit frmMainUse;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, uHttpUtils, uHttpResponse;

type
  TForm1 = class(TForm)
    btnGet: TButton;
    btnPost: TButton;
    btnPut: TButton;
    btnDelete: TButton;
    Memo1: TMemo;
    procedure btnGetClick(Sender: TObject);
    procedure btnPostClick(Sender: TObject);
    procedure btnPutClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
  private
    httpOpt : THttpOptions;
    procedure ShowResponseInfo(response: THttpResponse);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

const
  urlBase = 'https://jsonplaceholder.typicode.com';
  urlGet = '/posts';
  urlGetId = '/posts/1';

implementation

{$R *.dfm}

procedure TForm1.btnDeleteClick(Sender: TObject);
begin
  httpOpt := FaktoryHttpOptions(TTipoEnvio.tpJson);
  httpOpt.SetUrlResource(urlBase + urlGetId);
  ShowResponseInfo(DeleteHttp(httpOpt));
end;

procedure TForm1.btnGetClick(Sender: TObject);
begin
  httpOpt := FaktoryHttpOptions(TTipoEnvio.tpUrlEncoded);
  httpOpt.SetUrlResource(urlBase + urlGet);
  ShowResponseInfo(GetHttpObj(httpOpt));
end;

procedure TForm1.btnPostClick(Sender: TObject);
var
  json: string;
begin
  json := '{"title": "foo",' +
          '"body": "bar",' +
          '"userId": 1}';

  httpOpt := FaktoryHttpOptions(TTipoEnvio.tpJson);
  httpOpt.SetUrlResource(urlBase + urlGet);
  httpOpt.SetContentToSend(json);
  ShowResponseInfo(PostHttp(httpOpt));
end;

procedure TForm1.btnPutClick(Sender: TObject);
var
  json: string;
begin
  json := '{"id":1,' +
          '"title": "foo",' +
          '"body": "bar",' +
          '"userId": 1}';

  httpOpt := FaktoryHttpOptions(TTipoEnvio.tpJson);
  httpOpt.SetUrlResource(urlBase + urlGetId);
  httpOpt.SetContentToSend(json);
  ShowResponseInfo(PutHttpObj(httpOpt));
end;

procedure TForm1.ShowResponseInfo(response: THttpResponse);
begin
  Memo1.Text := Format('Response Code: %d ' + #13 + #10 +
                       'Response Text: %s ' + #13 + #10 +
                       'Response Content: %s ' + #13 + #10,
                       [response.ResponseCode, response.ResponseText, response.ResponseContent]);
end;

end.
