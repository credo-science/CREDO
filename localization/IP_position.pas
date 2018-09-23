uses....httpsend,
  ftpsend, fphttpclient, fpjson, jsonparser,...

procedure TFormularz.Button1Click(Sender: TObject);

var
  Http: TFPHTTPClient;
  info, Content: string;
  Json: TJSONData;
  JsonObject: TJSONObject;
begin
  if InternetConnected = True then
  begin

    Http := TFPHTTPClient.Create(nil);
    try
      Http.IOTimeout := 1000;
      Http.AllowRedirect := True;
      Content := Http.Get('http://ip-api.com/json');
      Json := GetJSON(Content);
      try
        JsonObject := TJSONObject(Json);
        label1.Caption := JsonObject.Get('lat');
        label2.Caption := JsonObject.Get('lon');
        label3.Caption := JsonObject.Get('city');
        label4.Caption := JsonObject.Get('country');
        finally
        Json.Free;
      end;
    finally
      Http.Free;
    end;
  end
  else
    MessageDlg('No internet connection:(   ',
      mtWarning, [mbOK], 0);

end; 
