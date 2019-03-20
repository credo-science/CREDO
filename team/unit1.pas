unit Unit1;

{$mode objfpc}{$H+}

interface

uses
 { Classes, SysUtils, FileUtil, TAGraph, TAIntervalSources, TASources, Forms,
  Controls, Graphics, Dialogs, StdCtrls, ComCtrls, TATools,
  dateutils, tatypes, TASeries, Types,TACustomSeries, wincrt;   }
   Classes, SysUtils, FileUtil, TAGraph, TASeries, Forms, Controls, Graphics,
  Dialogs, StdCtrls, TADrawUtils, TACustomSeries, TASources, TAMultiSeries,
  LCLIntf, ComCtrls, TATypes, TAIntervalSources, TAChartAxisUtils, TATools,
  TAChartListbox, dateutils, Types,wincrt,lconvencoding;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Chart1: TChart;
    ChartListbox1: TChartListbox;
    ChartToolset1: TChartToolset;
    ChartToolset1DataPointClickTool1: TDataPointClickTool;
    ChartToolset1PanDragTool1: TPanDragTool;
    ChartToolset1ZoomMouseWheelTool1: TZoomMouseWheelTool;
    DateTimeIntervalChartSource1: TDateTimeIntervalChartSource;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    ListChartSource1: TListChartSource;
    ListChartSource2: TListChartSource;
    StatusBar1: TStatusBar;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ChartToolset1DataPointClickTool1AfterMouseDown(ATool: TChartTool;
      APoint: TPoint);
    procedure ChartToolset1PanDragTool1AfterKeyDown(ATool: TChartTool;
      APoint: TPoint);
    procedure ChartToolset1ZoomClickTool1AfterKeyDown(ATool: TChartTool;
      APoint: TPoint);
    procedure ChartToolset1ZoomMouseWheelTool1AfterKeyDown(ATool: TChartTool;
      APoint: TPoint);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;
var
  Form1: TForm1;
  Series_ar: array[1..15000] of TLineSeries;

type   team_rec  =record
  team : string;
  n_t : {array[1..15000] of }integer;
end;
type
  hit = record
    time: int64;
    lat, long, user_n, user_name ,team,team_numer: string;
   end;


var
   Detection: array[1..15000] of hit;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
 // Detection: array[1..15000] of hit;
  f: textfile;
  i, j: integer;
  cc: int64;
  Read_Line: string;
  dt: tdatetime;
  m:double;
begin
  AssignFile(f, '12.03.2019.txt');
  reset(f);
  i := 1;
  while not EOF(f) do
  begin
    readln(f, cc);
    Detection[i].time := cc;


    readln(f, Read_Line);
    Detection[i].lat := Read_Line;

    readln(f, Read_Line);
    Detection[i].long := Read_Line;

    readln(f, Read_Line);
    Detection[i].user_n := Read_Line;


    readln(f, Read_Line);
    if Read_Line<>''   then
    Detection[i].team_numer := Read_Line;

   readln(f, Read_Line);
    Detection[i].team :=  CP1250ToUTF8(Read_Line);  //Read_Line;

    readln(f, Read_Line);
    Detection[i].user_name :=  CP1250ToUTF8(Read_Line);  //Read_Line;

    readln(f, Read_Line);
    Inc(i);
  end;
  closefile(f);

  for j := Low(Series_ar) to i{High(Series_ar)} do
  begin
   Series_ar[j] := TLineSeries.Create(Chart1);
    Series_ar[j].ShowPoints := True;

    //Chart1.LeftAxis.Marks.Source := Series_ar[j].Listsource;

    //Series_ar[j].SeriesColor:= rgb(Random(256), Random(256), Random(256));

    Series_ar[j].Pointer.Brush.Color := rgb(Random(256), Random(256), Random(256)); ;
    Series_ar[j].Pointer.Pen.Color := clBlack;
    Series_ar[j].Pointer.Style := psCircle;
   end;
  for j := 1 to  i{High(Series_ar) } do
  begin
    if Detection[j].team_numer <> '' then
    begin
      DT := unixToDateTime((Detection[j].time) div 1000);

    Series_ar[ (Detection[j].team_numer.ToInteger)]
    .AddXy((Detection[j].time),  (Detection[j].team_numer.ToInteger),'(Detection[j].time.ToString)' );
     Series_ar[StrToInt(Detection[j].team_numer)].Title :=
         (Detection[j].team) ;
     //Series_ar[StrToInt(Detection[j].team_numer)].marks.Format :=
       //  (Detection[j].user_name) ;

       Chart1.AddSeries(Series_ar[ (Detection[j].team_numer.ToInteger )]);
      end;
   end;
   Statusbar1.SimpleText :='Mouse Click : Left-Info/Right-Drag/MouseWhell-Zoom';

end;

procedure TForm1.ChartToolset1DataPointClickTool1AfterMouseDown(
  ATool: TChartTool; APoint: TPoint);
var
 z  : int64;
   x, y  :double;
  List1: TStringList;
 hour, grupa,napis : string;
 i:integer;
  at: tdatetime;
begin
   List1 := TStringList.Create;
  List1.Delimiter := '!';

 with ATool as TDatapointClickTool do
   if (Series is TLineSeries) then
     with TLineSeries(Series) do begin
         //  TLineSeries..GetYImgValue();
     // z:=  GetYImgValue(PointIndex);
       z := round(GetXValue(PointIndex));
       y :=  (GetYValue(PointIndex));
       at:=   unixToDateTime(z div 1000);
       hour:=timetostr(at) +marks.Format;
       if title= '' then title:='NoName';
       List1.DelimitedText := title;//marks.Format;
      //    DT := unixToDateTime(List1[0].ToInt64 div 1000);
          for i:=0 to list1.Count-1 do
           napis:=napis+' '+list1[i];
           //title.
      // Statusbar1.SimpleText := Format('%s: x = %f, y = %f', [timetostr(dt) +'   (' +napis+ ')', x, y]);
       //Statusbar1.SimpleText := 'Format('%s: z = %f, User nr = %f', [napis +'    '+ list1[0],y, y]) ;
       Statusbar1.SimpleText :='Mouse Click : Left-Info/Right-Drag/MouseWhell-Zoom';
        label2.caption:=inttostr(  series_ar[round(y)].Count);
       Label4.Caption:=hour;
       Label6.Caption:=napis;
      // Statusbar1.SimpleText :=  ( timetostr(dt) +'   (' +napis+ ')' +x.ToString);
     end
   else
     Statusbar1.SimpleText := '';
   List1.Free;
end;

procedure TForm1.ChartToolset1PanDragTool1AfterKeyDown(ATool: TChartTool;
  APoint: TPoint);
begin
 // apoint.
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  z: integer;
begin
   for z:=0  to   chartlistbox1.SeriesCount-1 do
      chartlistbox1.Checked[z]:=false;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  z: integer;
begin
   for z:=0  to   chartlistbox1.SeriesCount-1 do
      chartlistbox1.Checked[z]:=true;


end;

procedure TForm1.ChartToolset1ZoomClickTool1AfterKeyDown(ATool: TChartTool;
  APoint: TPoint);
begin
  // ChartToolset1ZoomClickTool1.ZoomFactor:=;
end;

procedure TForm1.ChartToolset1ZoomMouseWheelTool1AfterKeyDown(
  ATool: TChartTool; APoint: TPoint);
begin
  label2.Caption:='s';
   //chart1.
end;

end.
