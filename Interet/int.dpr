program int;

uses
  Forms,
  FInt in 'FInt.pas' {F_Interet};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TF_Interet, F_Interet);
  Application.Run;
end.
