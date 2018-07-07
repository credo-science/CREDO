program CREDO;

  {$MODE Delphi}

uses
  core,Forms,tachartlazaruspkg, Interfaces,unit3,unit2,unit4;

 {$R *.res}

begin
  Application.Scaled:=True;
  Application.Initialize;
  Application.Title := 'Credo Detector for PC/Windows';
  Application.CreateForm(Tformularz, formularz);
  Application.CreateForm(Tform3, form3);
   Application.CreateForm(Tform4, form4);
 Application.CreateForm(Tform2, form2);
   Application.Run;
end.
