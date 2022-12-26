unit Unit3;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, IdHTTP, IdSSLOpenSSL, IdURI, System.JSON,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdIOHandler, REST.Authenticator.OAuth , REST.Client, REST.Types  ,
  IdIOHandlerSocket, IdIOHandlerStack, IdSSL,IdMultipartFormData, IdServerIOHandler,System.Net.HttpClient, System.Net.HttpClientComponent,
  Vcl.ComCtrls, IPPeerClient, Data.Bind.Components,
  Data.Bind.ObjectScope; //System.Net.HttpClient.Interceptors;

type
  TForm3 = class(TForm)
    Button1: TButton;
    Client: TIdHTTP;                                               //http for Access Token
    IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;    //SSL Handler for Access Token
    Button2: TButton;
    HTTP: TIdHTTP;                                                //http for Access Token
    SSL: TIdSSLIOHandlerSocketOpenSSL;                            //SSL Handler for Access Token
    HeaderControl1: THeaderControl;
    Button3: TButton;
    httpc: TIdHTTP;
    Button4: TButton;
    httpi: TIdHTTP;
    sslc: TIdSSLIOHandlerSocketOpenSSL;
    ssli: TIdSSLIOHandlerSocketOpenSSL;
    Button5: TButton;
    sslref: TIdSSLIOHandlerSocketOpenSSL;
    httpref: TIdHTTP;
    procedure Button1Click(Sender: TObject);                      //For Access Token
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);                     //TO GET COMPANY INFO
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;
  gAccessToken: string;        //Global String variable to Store Access Token Received
  gRefToken: string;

implementation

{$R *.dfm}

procedure TForm3.Button1Click(Sender: TObject);           //Button 1 Get Access Token

const
  CLIENT_ID = 'ABMQPUrdjOKdDJtOg6gYSxOrkVr8HCHXJSVXwN6uQrVvfXPPOC';
  CLIENT_SECRET = 'gFUQMQKFOt6UIL3YdSRU6omQxtfdWHNMol6IG5ZX';

  REFRESH_TOKEN = 'AB11680765272B1GbOHJKgAKaV1k4Qk7SD9CLFZvBbztZPuKQE';    //Available for 101 DAYS

//Function to extract access token from the JSON Response you get after POST Request
function ExtractAccessToken(const JSON: string): string;
var
  Token: TJSONObject;
begin
  Token := TJSONObject.ParseJSONValue(JSON) as TJSONObject;
  try
    Result := Token.Values['access_token'].Value;
  finally
    Token.Free;
  end;
end;


var
 // Client: TIdHTTP;
  Response: TStringStream;
  Params: TStringStream;
  AccessToken: string;
begin                         //Procedure to pos
  //Client := TIdHTTP.Create(nil);
 //Response := TStringStream.Create('');
 // Client.Request.BasicAuthentication := True;
 //Params := TStringStream.Create;
  try
     //POST Required PARAM and Header for access token from refresh token
     Params := TStringStream.Create('grant_type=refresh_token&refresh_token='
     + REFRESH_TOKEN + '&client_id=' + CLIENT_ID + '&client_secret=' + CLIENT_SECRET, TEncoding.UTF8);

    {Params.Add('grant_type=client_credentials'); //Tried with Client Credentials got Access Token, But not able to make API Call
    Params.Add('scope=com.intuit.quickbooks.accounting');     //added to get proper response on 21-12      using client credentials
    Params.Add('client_id=' + 'ABMQPUrdjOKdDJtOg6gYSxOrkVr8HCHXJSVXwN6uQrVvfXPPOC');
    Params.Add('client_secret=' + 'gFUQMQKFOt6UIL3YdSRU6omQxtfdWHNMol6IG5ZX');   }

    Response := TStringStream.Create('', TEncoding.UTF8);
    Client.Request.ContentType := 'application/x-www-form-urlencoded';
    Client.Post('https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer', Params, Response);
    gAccessToken := ExtractAccessToken(Response.DataString);
    ShowMessage(gAccessToken);
  finally
    Client.Free;
    Response.Free;
    Params.Free;
  end;

end;
procedure TForm3.Button2Click(Sender: TObject);
 var
  CompanyInfo: TJSONObject;
  CompanyAddress: TJSONObject;
  Street: string;
  value: TJSONValue;
  Name: string;
  LegName: string;
  Email: string;
  Phone: string;
  Address: string;
  City: string;
  State: string;
  PostalCode: string;
  Country: string;
  message: string;

  Response: string;
  begin
    //  accessToken := ACCESS_TOKEN;
      HTTP := TIdHTTP.Create(nil);
  try
    //  SSL := TIdSSLIOHandlerSocketOpenSSL.Create(HTTP);
    // HTTP.Request.CustomHeaders.AddValue('Authorization', 'Bearer ' + gAccessToken);

  //  HTTP.c
    HTTP.IOHandler := SSL;
    HTTP.Request.CustomHeaders.Values['Authorization'] := 'Bearer ' + gAccessToken;
    HTTP.Request.ContentType := 'application/json';
    HTTP.Request.Accept := 'application/json';
    Response := HTTP.Get('https://sandbox-quickbooks.api.intuit.com/v3/company/4620816365234295000/companyinfo/4620816365234295000?minorversion=65');

    // parse the response to get the company information

      CompanyInfo := TJSONObject.ParseJSONValue(Response) as TJSONObject;
      Value := CompanyInfo.GetValue('CompanyInfo');
      Name := Value.GetValue<string>('CompanyName');
      LegName := Value.GetValue<string>('LegalName');

    //JSON k Andar JSON hai bhai, Pehle CompanyInfo k Json ko k Andar Value, phir value k andar address

      CompanyAddress := Value.GetValue<TJSONObject>('CompanyAddr');
      Street := CompanyAddress.GetValue<string>('Line1');
      City := CompanyAddress.GetValue<string>('City');
      State := CompanyAddress.GetValue<string>('CountrySubDivisionCode');
      PostalCode := CompanyAddress.GetValue<string>('PostalCode');

      //Display the message
      Message := 'Company Name: ' + Name + sLineBreak + 'Legal Name: ' + LegName + sLineBreak;
      Message := Message + 'Company Address: ' + Street + ', ' + City + ', ' + State + ' ' + PostalCode;

      ShowMessage(Message);

  finally
    HTTP.Free;
  end;
end;

procedure TForm3.Button3Click(Sender: TObject);

 var
  jsonc: TJSONObject;
  valuec: TJSONValue;
  jsoncstr : string;
  custmess: string;
  idc: string;
  strstr: TStringStream;
  customerc: TJSONObject;
  cname: string;
  responsec: string;
  begin
  //  httpc := TIdHTTP.Create(nil);
  // sslc := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    try
      httpc.IOHandler := sslc;

      httpc.Request.CustomHeaders.Values['Authorization'] := 'Bearer ' + gAccessToken ;
      httpc.Request.ContentType := 'application/json';
      httpc.Request.Accept := 'application/json';

      jsonc := TJSONObject.Create;
      try
      jsonc.AddPair('DisplayName', '12Puneet1 Soni Delphi API');
      jsonc.AddPair('FamilyName', '12FNAME1');
      jsonc.AddPair('CompanyName', '12Aspirations717');

      jsoncstr := jsonc.ToJSON;
      finally
      jsonc.Free;
      end;
      strstr :=  TStringStream.Create(jsoncstr, TEncoding.UTF8);
  //    responsec := httpc.Post('https://sandbox-quickbooks.api.intuit.com/v3/company/4620816365234295000/customer', jsonc.ToString);

  //    customerc := TJSONObject.ParseJSONValue(responsec) as TJSONObject;
  //    cname :=  Customerc.GetValue<string>('DisplayName');

    //  responsec := httpc.Post('https://sandbox-quickbooks.api.intuit.com/v3/company/4620816365234295000/customer', jsonc.ToJSON);
     // customerId := customer.Values['id'].Value;

     try
     responsec := httpc.Post('https://sandbox-quickbooks.api.intuit.com/v3/company/4620816365234295000/customer', strstr);

     customerc := TJSONObject.ParseJSONValue(responsec) as TJSONObject;
     valuec := customerc.GetValue('Customer');
     cname :=  valuec.GetValue<string>('DisplayName');
  //   idc := valuec.GetValue<string>('ID');

     custmess := 'Customer has been Created with Customer Display name '+ cname;

     ShowMessage(custmess);
      finally
       strstr.Free;
      end;
    finally
    sslc.Free;
    httpc.Free;
    end;
  end;
procedure TForm3.Button4Click(Sender: TObject);

var
InvoiceJSon: string;
iDomain: string;
iLink: string;
texti: string;
InvoiceObj: TJSONObject;
valuei: TJSONValue;
begin
    httpi := TIdHTTP.Create(nil);
    try
    //  ssli := TIdSSLIOHandlerSocketOpenSSL.Create(httpi);
      httpi.IOHandler := ssli;

        httpi.Request.CustomHeaders.Values['Authorization'] := 'Bearer ' + gAccessToken;
        httpi.Request.Accept := 'application/json';
        httpi.Request.ContentType := 'application/json';

       InvoiceJSon := httpi.Get('https://sandbox-quickbooks.api.intuit.com/v3/company/4620816365234295000/invoice/13');

     InvoiceObj := TJSONObject.ParseJSONValue(InvoiceJSon) as TJSONObject;
     valuei := InvoiceObj.GetValue('Invoice');

    // iLink := valuei.GetValue<string>('InvoiceLink');
     iDomain := valuei.GetValue<string>('domain');

     texti := 'The Invoice has been found with the GIven ID' + sLineBreak + 'The Domain for the Invoice is: ' + iDomain;
      //+ sLineBreak+ 'Domain : '+ iDomain;
     ShowMessage(texti);

    finally
    httpi.Free;
    end;
end;

procedure TForm3.Button5Click(Sender: TObject);
 


  //REFRESH_TOKEN = 'AB11680765272B1GbOHJKgAKaV1k4Qk7SD9CLFZvBbztZPuKQE';    //Available for 101 DAYS

//Function to extract access token from the JSON Response you get after POST Request
function ExtractRefToken(const JSON: string): string;
var
  reToken: TJSONObject;
begin
  reToken := TJSONObject.ParseJSONValue(JSON) as TJSONObject;
  try
    Result := reToken.Values['refresh_token'].Value;
  finally
    reToken.Free;
  end;
end;

const
  refCLIENT_ID = 'ABMQPUrdjOKdDJtOg6gYSxOrkVr8HCHXJSVXwN6uQrVvfXPPOC';
  refCLIENT_SECRET = 'gFUQMQKFOt6UIL3YdSRU6omQxtfdWHNMol6IG5ZX';
var
 // Client: TIdHTTP;
  refResponse: string;
 // refParams: TStringStream;
 refJson: TJSONObject;
  RefToken: string;
  refParams: TIdMultiPartFormDataStream;

begin                         //Procedure to pos
    //httpref := TIdHTTP.Create(nil);
 //   httpref := TIdHTTP.Create(nil);
  try
   // sslref := TIdSSLIOHandlerSocketOpenSSL.Create(httpref);
    httpref.IOHandler := sslref;

    httpref.Request.ContentType := 'application/x-www-form-urlencoded';
    httpref.Request.Accept := 'application/json';
    httpref.Request.BasicAuthentication := True;
    httpref.Request.Username := 'ABMQPUrdjOKdDJtOg6gYSxOrkVr8HCHXJSVXwN6uQrVvfXPPOC';
    httpref.Request.Password := 'gFUQMQKFOt6UIL3YdSRU6omQxtfdWHNMol6IG5ZX';

    refParams := TIdMultiPartFormDataStream.Create;

    try
      refparams.AddFormField('grant_type', 'client_credentials');
      refparams.AddFormField('scope', 'com.intuit.quickbooks.accounting');
      refResponse := httpref.Post('https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer', refparams);
      finally
      refParams.Free;
      end;

   {  //POST Required PARAM and Header for access token from refresh token
     refParams := TStringStream.Create('grant_type=client_credentials&scope=com.intuit.quickbooks.accounting&client_id='
     + refCLIENT_ID + '&client_secret=' + refCLIENT_SECRET, TEncoding.UTF8);
   //  httpref.Request.ContentType := 'application/json';      }
   // refResponse := TStringStream.Create('', TEncoding.UTF8);
    //httpref.Request.ContentType := 'application/x-www-form-urlencoded';
   // httpref.Post('https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer', refParams, refResponse);
   // gRefToken := ExtractRefToken(refResponse.DataString);
    //ShowMessage(gRefToken);

     refJson := TJSONObject.ParseJSONValue(refResponse) as TJSONObject;
     try
     RefToken := refJson.GetValue('refresh_token').Value;
     finally
     refJson.Free;
     end;
     ShowMessage(RefToken);
  finally
    httpref.Free;
    //refParams.Free;
  end;

end;

end.



 {var
  refParams: TStringList;
  refResponse: TMemoryStream;
  refJSONObject: TJSONObject;
  RefToken: string;
  buffer: TBytes;
begin
  httpref := TIdHTTP.Create(nil);
  try
 //   sslref := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    httpref.IOHandler := sslref;

    refParams := TStringList.Create;
    refParams.Add('grant_type=client_credentials');
    refParams.Add('scope=com.intuit.quickbooks.accounting');
    refParams.Add('client_id=' + 'ABMQPUrdjOKdDJtOg6gYSxOrkVr8HCHXJSVXwN6uQrVvfXPPOC');
    refParams.Add('client_secret=' + 'gFUQMQKFOt6UIL3YdSRU6omQxtfdWHNMol6IG5ZX');

    refResponse := TMemoryStream.Create;
     try
      httpref.Post('https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer', refParams, refResponse);
      refResponse.Position := 0;

        SetLength(Buffer, refResponse.Size);
        refResponse.ReadBuffer(Buffer[0], refResponse.Size);
        refJSONObject := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetString(Buffer)) as TJSONObject;
      
     // refJSONObject := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetString(PByte(refResponse.Memory), refResponse.Size)) as TJSONObject;
      try
         RefToken := refJSONObject.GetValue('refresh_token').Value;

         ShowMessage(RefToken);
      finally
        refJSONObject.Free;
      end;
    finally
      refResponse.Free;
    end;
  finally
    httpref.Free;
  end;
end; }    
