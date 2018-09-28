unit Unit1;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls, ExtCtrls, Clipbrd, ComCtrls,
    fileutil, crt, dos;

type
  PRGB32Array = ^TRGB32Array;
  TRGB32Array = packed array[0..MaxInt div SizeOf(TRGBQuad) - 1] of TRGBQuad;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button4: TButton;
    Button5: TButton;
    CloseCredo: TButton;
    Calibration: TTimer;
    Detection: TTimer;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Panel1: TPanel;
    ProgressBar1: TProgressBar;
    pause: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure CalibrationTimer(Sender: TObject);
    procedure CloseCredoClick(Sender: TObject);
    procedure DetectionTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure pauseTimer(Sender: TObject);
  private
    idResultado: THandle;

    Counter_Calib, Step, Frame, Counter_Calibador: integer;
    Detect: boolean;

  public
    Image_Actual: tbitmap;

  end;

const
  WM_CAP_START = WM_USER;
  WM_CAP_DRIVER_CONNECT = WM_CAP_START + 10;
  WM_CAP_DRIVER_DISCONNECT = WM_CAP_START + 11;
  WM_CAP_EDIT_COPY = WM_CAP_START + 30;
  WM_CAP_SET_PREVIEW = WM_CAP_START + 50;
  WM_CAP_SET_PREVIEWRATE = WM_CAP_START + 52;
  WM_CAP_DLG_VIDEOFORMAT = WM_CAP_START + 41;
  WM_CAP_DLG_VIDEOSOURCE = WM_CAP_START + 42;
  WM_CAP_SINGLE_FRAME = WM_CAP_START + 72;


var
  Form1: TForm1;
  Max_Noise_level: integer;


implementation

{$R *.lfm}

{ TForm1 }
function capCreateCaptureWindowA(lpszWindowName: PChar; dwStyle: longint;
  x: integer; y: integer; nWidth: integer; nHeight: integer; ParentWin: HWND;
  nId: integer): HWND; stdcall external 'AVICAP32.DLL';


procedure TForm1.FormCreate(Sender: TObject);
begin
  idResultado := 0;
  Image_Actual := Tbitmap.Create;
  Detect := False;
  button2.Enabled := False;
  detection.Enabled := False;
  Calibration.Enabled := False;
  Counter_Calib := 0;
  Image1.Canvas.Brush.Color := clblack;
  Image1.Canvas.Pen.Color := clblack;
  image1.Canvas.FillRect(0, 0, image1.Width, image1.Height);
   Image_Actual.PixelFormat := pf8bit;
end;

procedure TForm1.pauseTimer(Sender: TObject);
begin

end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  idResultado := capCreateCaptureWindowA('My Own Capture Window',
    WS_CHILD or WS_VISIBLE, panel1.Left, panel1.Top, panel1.Width,
    panel1.Height, form1.Handle, 0);
  if idResultado <> 0 then
  begin
    try
      SendMessage(idResultado, WM_CAP_DRIVER_CONNECT, 0, 0);
      SendMessage(idResultado, WM_CAP_SET_PREVIEWRATE, 30, 0);
      SendMessage(idResultado, WM_CAP_SET_PREVIEW, 1, 0);

      SendMessage(idResultado, WM_CAP_dlg_videoformat, 0, 0);
      SendMessage(idResultado, WM_CAP_dlg_videosource, 0, 0);
      button2.Enabled := True;


    except
      //  Detection.Enabled := False;
      //  Shot_start.Enabled := False; //true
      raise;

    end;
  end
  else
  begin
    Detection.Enabled := False;
    MessageDlg('No connected camera.', mtError, [mbOK], 0);
    Button2.Enabled := False;
    Button1.Enabled := True;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin

  Detection.Enabled := False;
  Calibration.Enabled := True;

end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  if idResultado <> 0 then
  begin
    SendMessage(idResultado, WM_CAP_DRIVER_DISCONNECT, 0, 0);
    idResultado := 0;
     button1.Enabled := True;
  end;
  detection.Enabled := False;
  Detect := False;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  calibration.Enabled := False;
  detection.Enabled := False;
  pause.Enabled := True;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  pause.Enabled := False;
  detection.Enabled := True;
end;

procedure TForm1.CalibrationTimer(Sender: TObject);
var
  w, h, x, y: integer;
  Scan: PRGB32Array;
  grey: integer;

begin

  Max_Noise_level := 0;
  progressbar1.Visible := True;
  if Detect = True and detection.Enabled = True then
    if idResultado <> 0 then
    begin
      try
        SendMessage(idResultado, WM_CAP_EDIT_COPY, 0, 0);
        Image_Actual.LoadFromClipboardFormat(cf_BitMap);
         w := Image_Actual.Width;
        h := Image_Actual.Height;

        for y := 10 to h - 10 do
        begin
          Scan := Image_Actual.ScanLine[y];
          for x := 10 to w - 10 do
            with Scan[x] do
            begin
              grey := (rgbBlue + rgbGreen + rgbRed);// div 3;
              if grey > Max_Noise_level then
                Max_Noise_level := grey;
            end;
        end;


        Inc(Counter_Calib);

        progressbar1.Position := Counter_Calib;
        {We calibrate 200 frames}
        if Counter_Calib > 200 then
        begin
          label1.Caption := floattostr(Max_Noise_level);
          calibration.Enabled := False;
          detection.Enabled := True;
          progressbar1.Visible := False;
          Detect := True;
        end;


      except
        button3click(Self);
        raise;

      end;

    end
    else
    begin
      button3click(Self);
    end;

end;

procedure TForm1.CloseCredoClick(Sender: TObject);
begin

  if idResultado <> 0 then
  begin
    SendMessage(idResultado, WM_CAP_DRIVER_DISCONNECT, 0, 0);
    idResultado := 0;
     button1.Enabled := True;

  end;

  Detect := False;
  Image_Actual.Free;

  Close;
end;

procedure TForm1.DetectionTimer(Sender: TObject);

var

  i, xx, yy, a, clipx, clipy, w, h, x, y: integer;
  Shot: boolean;
  Scan: PRGB32Array;
  minimum,maximum: double;
  Max_Brightnes, Grey: integer;
  col: array[1..1000000] of tcolor;
  hour, minute, sek, sets, Year, Month, Day, WDay: word;

begin

  {"minimum" variable brightness of the minimum pixel for drawing a detection image. You can set from 0 to
  Max_Noise_level.}

  minimum := Max_Noise_level * 0.9;

 {Now we multiply
  Max_Noise_level by a value adapted to your camera. 1.29 for my LiveCam HD}

  Maximum := Max_Noise_level;// * 1.28 ;

  Shot := False;

  if idResultado <> 0 then
  begin
    try
      SendMessage(idResultado, WM_CAP_EDIT_COPY, 0, 0);
      Image_Actual.LoadFromClipboardFormat(cf_bitmap);
      Image_Actual.BeginUpdate(True);
      Grey := 0;
      a := 0;
      Max_Brightnes := 0;
      w := Image_Actual.Width;
      h := Image_Actual.Height;
      {Step 1. Analysis of the captured frame from the camera.
       If the pixel is lighter than Max_Noise_level, we increase "a".
       "a" is the number of pixels of probable detection}

      for y := 10 to h - 10 do
      begin
        Scan := Image_Actual.ScanLine[y];
        for x := 10 to w - 10 do
          with Scan[x] do
          begin
            Grey := (rgbBlue + rgbGreen + rgbRed);
             if Grey > Maximum   then
              Inc(a);

          end;

      end;
      Image_Actual.EndUpdate(False);
    except

      CloseCredoClick(Self);
      raise;

    end;
    {For my camera, "a" is a minimum of 4.
    You can change it anyway, but I do not recommend more than 10.
    If the condition is met, we have detection and in Step 2 we subject it to further analysis.}

    if (a > 3) then
      Shot := True;

    label2.Caption := IntToStr(Frame);
    Inc(Frame);


    {    "step" is the frame counter for periodic calibration.
     Here, the calibration takes place every 2,000 frames.}
    Inc(Step);
    if Step = 2000 then
    begin
      Step := 0;
      Counter_Calib := 0;
      Detect := False;
      detection.Enabled := False;
      calibration.Enabled := True;
    end;



    {Step 2
    If there is detection, we analyze and transform the picture}

    if (Shot and Detect) then
    begin

      image1.Canvas.Draw(0, 0, Image_Actual);
      for y := 10 to Image_Actual.Height - 10 do
      begin
        Scan := Image_Actual.ScanLine[y];
        for x := 10 to Image_Actual.Width - 10 do
          with Scan[x] do
          begin
            Grey := (rgbBlue + rgbGreen + rgbRed);

           if Grey > minimum then
            begin
              if Grey > Max_Brightnes then
              begin
                {clipx, clips are the coordinates of the brightest point.}
                clipx := x;
                clipy := y;
                Max_Brightnes := Grey;
               end;
              {Multiplied by, for example, 4 (brighten RGB)}
              rgbblue := rgbblue * 4;
              rgbgreen := rgbgreen * 4;
              rgbred := rgbred * 4;

              {We transform RGB color into Tcolor for drawing on canvas.}

              Grey := ((rgbblue shl 16) + (rgbgreen shl 8) + rgbred);

            // end;
           {Image1 is a picture of original sizes.}
            image1.Canvas.pen.Color := (Grey);
            image1.Canvas.brush.Color := (Grey);
            image1.Canvas.line(x, y, x - 1, y - 1);
          end;
      end;




        {Image3 is a cut out fragment of 40x40 from Image1}
        image3.Picture.Clear;
        image3.Canvas.CopyRect(rect(0, 0, 40, 40),
        image1.Canvas,
        Rect(clipx - 20, clipy - 20, clipx + 20, clipy + 20));


        {Image4 increases the size of the pixel to make the image more readable.
       Each pixel is changed to a 5x5 square.}
      i := 1;
      for yy := 1 to 40 do
        for xx := 1 to 40 do
        begin
          col[i] := (image3.Picture.Bitmap.Canvas.Pixels[xx, yy]);
          Inc(i);
        end;
      i := 1;
      for yy := 1 to 40 do
        for xx := 1 to 40 do
        begin
          image4.Canvas.brush.Color := (col[i]);
          image4.Canvas.MoveTo(xx * 5, yy * 5);
          image4.Canvas.fillrect(xx * 5, yy * 5, xx * 5 + 5, yy * 5 + 5);
          Inc(i);
        end;


      GetTime(hour, minute, sek, sets);
      GetDate(Year, Month, Day, WDay);
    {We save 3 files}
    {the original size of the camera frame}
      image1.Picture.Bitmap.SaveToFile('full/' + IntToStr(year) +
        '-' + IntToStr(month) + '-' + IntToStr(day) + '-' + IntToStr(hour) +
        '-' + IntToStr(minute) + '-' + IntToStr(sek) + '.bmp');


      {The 40x40 cut out fragment}
      Image3.Picture.bitmap.SaveToFile('det/' + IntToStr(year) + '-' +
        IntToStr(month) + '-' + IntToStr(day) + '-' + IntToStr(hour) +
        '-' + IntToStr(minute) + '-' + IntToStr(sek) + '.bmp');

      {"Zoom" or 1 pixel is 5x5 size}
      Image4.Picture.Bitmap.SaveToFile('zoom/' + IntToStr(year) +
        '-' + IntToStr(month) + '-' + IntToStr(day) + '-' + IntToStr(hour) +
        '-' + IntToStr(minute) + '-' + IntToStr(sek) + '.bmp');


      image1.Canvas.Brush.Color := clblack;
      image1.Canvas.Pen.Color := clblack;
      image1.Canvas.FillRect(0, 0, Image_Actual.Width, Image_Actual.Height);
      Inc(Counter_Calibador);
      Shot := False;
    end;

  end
  else
  begin
    closecredoClick(Self);
    MessageDlg('First, start the camera.', mtWarning, [mbOK], 0);
  end;

end;



procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if idResultado <> 0 then
  begin
    SendMessage(idResultado, WM_CAP_DRIVER_DISCONNECT, 0, 0);
    idResultado := 0;
     button1.Enabled := True;

  end;

  Detect := False;
  Image_Actual.Free;




end;

end.
