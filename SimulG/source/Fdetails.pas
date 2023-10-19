unit Fdetails;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, SimuleGF;

type
  TF_Details = class(TForm)
    Label1: TLabel;
    EX: TEdit;
    Label2: TLabel;
    EY: TEdit;
    Label3: TLabel;
    EZ: TEdit;
    Label4: TLabel;
    EVX: TEdit;
    Label5: TLabel;
    EVY: TEdit;
    Label6: TLabel;
    EVZ: TEdit;
    Timer: TTimer;
    BSave: TButton;
    Label7: TLabel;
    EM: TEdit;
    Edit1: TEdit;
    Label8: TLabel;
    Label9: TLabel;
    procedure TimerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EXChange(Sender: TObject);
    procedure BSaveClick(Sender: TObject);
  private
    ObjG        : TObjetG;
    Was_playing : Boolean;
  public
    constructor Create(AOwner: TComponent; OG : TObjetG); reintroduce;
  end;

var
  F_Details: TF_Details;

implementation

{$R *.DFM}

constructor TF_Details.Create(AOwner: TComponent; OG : TObjetG);
begin
  inherited Create(AOwner);
  ObjG := OG;
  Caption := OG.nom;
end;

procedure TF_Details.TimerTimer(Sender: TObject);
begin
  With ObjG do
  begin
    EX.Text  := Format('%.6g',[x / UA]);
    EY.Text  := Format('%.6g',[y / UA] );
    EZ.Text  := Format('%.6g',[z/ UA]);
    EVX.Text := Format('%.6g',[vx / 1000]);
    EVY.Text := Format('%.6g',[vy / 1000]);
    EVZ.Text := Format('%.6g',[vz / 1000]);
    EM.Text  := Format('%.6g',[m]);
  end;
  Timer.Interval := 500;
end;


procedure TF_Details.FormClose(Sender: TObject; var Action: TCloseAction);
var i : integer;
begin
  with F_G.MeDetails do
  for i := 0 to Count -1 do
    if items[i].caption = self.caption then
      items[i].checked := false;
end;

procedure TF_Details.EXChange(Sender: TObject);
begin
  Was_playing := F_G.Timer.Enabled;
  F_G.pause;
  Timer.Enabled := False;
  Timer.OnTimer(Timer);
  BSave.Enabled := True;
end;

// Internal values are in standard units (m, m/s)
procedure TF_Details.BSaveClick(Sender: TObject);
begin
  ObjG.x  := UA * StrToFloat(EX.text);
  ObjG.y  := UA * StrToFloat(EY.text);
  ObjG.z  := UA * StrToFloat(EZ.text);
  ObjG.vx := 1000 * StrToFloat(EVX.text);
  ObjG.vy := 1000 * StrToFloat(EVY.text);
  ObjG.vz := 1000 * StrToFloat(EVZ.text);
  ObjG.m  := StrToFloat(EM.text);
  BSave.Enabled := False;
  F_G.Orig.GetCentreDeMasse(F_G.Orig.x,F_G.Orig.y,F_G.Orig.z);
  F_G.U.AjusteMV0;
  Timer.Enabled := True;
  if Was_playing then F_G.play;
end;

end.
