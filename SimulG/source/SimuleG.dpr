program SimuleG;

uses
  Forms,
  SimuleGF in 'SimuleGF.pas' {F_G},
  Fdetails in 'Fdetails.pas' {F_Details},
  FDatabase in 'FDatabase.pas' {F_Database};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TF_G, F_G);
  Application.CreateForm(TF_Database, F_Database);
  Application.Run;
end.
