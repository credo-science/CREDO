uses ....base64, fpjson, fphttpclient, dateutils;  

procedure upload(a: string); // 'a' is file .jpg
var
  picture1: TFileStream;
  picture_read: array of byte;
  b64: TBase64EncodingStream;
  base64_picture: TStringStream;

  requests: TFPHTTPClient;
  detection, Data: TStringStream;
  grafika, response: string;
  dt: TDateTime;
  ut: int64;
  token: string;
  O: TJSONObject;
begin
  picture1 := TFileStream.Create(a, fmOpenRead or fmShareDenyNone);
  try
    SetLength(picture_read, picture1.Size);
    picture1.Read(picture_read[1], Length(picture_read));
  finally
    picture1.Free;
  end;

  base64_picture := TStringStream.Create('');
  try
    b64 := TBase64EncodingStream.Create(base64_picture);
    try
      b64.Write(picture_read[1], Length(picture_read));
      form1.Memo1.Caption := base64_picture.DataString;
      grafika := base64_picture.DataString;
    finally
      b64.Free;
    end;
  finally
    base64_picture.Free;
  end;




  requests := TFPHTTPClient.Create(nil);
  requests.AllowRedirect := True;
  dt := Now();
  ut := (DateTimeToUnix(dt) - 7201) * 1000 + 248;
  form1.Label6.Caption := datetostr(now) + '-' + IntToStr(ut);

  try
    Data := TStringStream.Create(
      '{"app_version":1,"device_model":1,"device_type":1,"system_version":1,"device_id":1,"password":"S73071YT6","email":"mpknap@wp.pl"}');

   {   O := TJSONObject.Create([
                          'app_version',1,
                          'device_model', 1,
                         'device_type',1,
                         'system_version',1,
                           'device_id',1,
                          'password', 'S73071YT6',
                          'email', 'mpknap@wp.pl'
                     ]);
      O.DumpJSON(data);   }
    try
      requests.AddHeader('User-Agent', 'YourPreferedAgent');
      requests.AddHeader('Content-type', 'application/json');

      requests.RequestBody := Data;
      response := requests.Post('https://api.credo.science/api/v2/user/login');
      form1.label4.Caption := ('Response: ' + response);
      form1.memo2.Caption := ('Code: ' + IntToStr(requests.ResponseStatusCode) +
        ', Text: ' + requests.ResponseStatusText);

      O := TJSONObject(GetJSON(response));
      try
        token := O.Get('token');
      finally
        O.Free;
      end;

      //     label3.Caption:=('Token: '+token);
    finally
      Data.Free;
    end;
  finally
    requests.Free;

    requests := TFPHTTPClient.Create(nil);
    requests.AllowRedirect := True;
    try
      detection := TStringStream.Create('{"detections": [{"frame_content": "' +
        grafika + '"' + ', "timestamp": ' + IntToStr(ut) +
        ', "latitude": "51.708491", "longitude": "19.476362", "altitude": "12", "accuracy": "1", "provider": "google map", "width": "40", "height": "40", "id": "1"}], "device_id": "raspberry", "androidVersion": "none", "device_model": "zero", "app_version": "1", "system_version": "raspbian", "device_type": "raspberry"}');
      try
        requests.AddHeader('User-Agent', 'YourPreferedAgent');
        requests.AddHeader('Content-type', 'application/json');
        requests.AddHeader('Authorization', 'Token ' + token);
        requests.RequestBody := detection;
        form1.label5.Caption :=
          ('Response: ' + requests.Post('https://api.credo.science/api/v2/detection'));
        form1.memo3.Caption := ('Code: ' + IntToStr(requests.ResponseStatusCode) +
          ', Text: ' + requests.ResponseStatusText);

      finally
        detection.Free;
      end;

    finally
      requests.Free;
    end;
  end;
end;
