unit FInt;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids, ExtCtrls, math, ComCtrls, printers;

type
  TF_Interet = class(TForm)
    Panel1: TPanel;
    SG: TStringGrid;
    Label1: TLabel;
    EMontant: TEdit;
    Label2: TLabel;
    ETauxAnnuel: TEdit;
    Label3: TLabel;
    ENcap: TEdit;
    CBMode: TComboBox;
    ENombre: TEdit;
    Label4: TLabel;
    EVersements: TEdit;
    Panel2: TPanel;
    Label5: TLabel;
    ETotal: TEdit;
    Label6: TLabel;
    EIntTot: TEdit;
    Timer: TTimer;
    BDetails: TButton;
    Label7: TLabel;
    DTP: TDateTimePicker;
    BPrint: TButton;
    procedure FormShow(Sender: TObject);
    procedure EChange(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure EVersementsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ENombreKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BDetailsClick(Sender: TObject);
    procedure BPrintClick(Sender: TObject);
  private
    C      : Real;
    I      : Real;
    NC     : Integer;
    N      : Real;
    P      : Real;
    Calculated : Tedit;
    function  CalculRapide : boolean;
    Procedure AllWhite;
    function  StrToFloatDef(s : string; def : real): real;
    procedure bug(E : Tedit);
    procedure Details(Print : boolean = false);
  public
    { Public declarations }
  end;

var
  F_Interet: TF_Interet;

implementation

{$R *.DFM}

procedure TF_Interet.FormShow(Sender: TObject);
begin
  CBMode.ItemIndex := 1;
  SG.Cells[0,0] := '#';
  SG.Cells[1,0] := 'Date';
  SG.Cells[2,0] := 'Versement';
  SG.Cells[3,0] := 'Intérêt';
  SG.Cells[4,0] := 'Remise';
  SG.Cells[5,0] := 'Capital';
end;

procedure TF_Interet.EChange(Sender: TObject);
begin
  Timer.enabled := False;
  AllWhite;
  Timer.enabled := True;
  Application.ProcessMessages;
end;

procedure TF_Interet.AllWhite;
var i : integer;
begin
  For i := 0 To ComponentCount - 1 do
    if (Components[i] is TEdit) and not TEdit(Components[i]).ReadOnly then
      TEdit(Components[i]).color := clWhite
    else if Components[i] is TComboBox then
      TComboBox(Components[i]).color := clWhite;
end;

procedure TF_Interet.bug(E : Tedit);
begin
  E.Color := clRed;
  Sysutils.Beep;
  E.SetFocus;
  E.SelectAll;
end;

procedure TF_Interet.TimerTimer(Sender: TObject);
begin
  if assigned(Calculated) then Calculated.clear;
  BPrint.Enabled   := False;
  BDetails.Enabled := False;
  Timer.Enabled := False;
  if (Trim(Emontant.text) = '')
  or (Trim(ETauxAnnuel.text) = '')
  or (Trim(ENCap.text) = '')
  or ((Trim(ENombre.text) = '') and (Trim(EVersements.text) = '')) then
    exit;

  C := StrToFloatDef(EMontant.Text, -1);
  if C = -1 then begin bug(EMontant); exit; end;

  NC := StrToIntDef(ENcap.Text, -1);
  if N = -1 then begin bug(ENcap); exit; end;

  if trim(ENombre.text) <> '' then
    begin
      N := StrToFloatDef(ENombre.Text, -1);
      if N = 0 then exit;
      if N = -1 then begin bug(ENombre); exit; end;
      // si on entre le nombre d'années, calculer le nombre de versements annuels
      if CBMode.ItemIndex = 1 then
        N := N * NC;
    end
  else
    N := 0;

  if trim(EVersements.text) <> '' then
    begin
      P := StrToFloatDef(EVersements.Text, -1);
      if P = -1 then begin Bug(EVersements); exit; end;
      P := Round(p*100) / 100;
    end
  else
    P := 0;

  I := StrToFloatDef(ETauxAnnuel.Text, -1) / 100;
  if I = -1 then begin Bug(ETauxAnnuel); exit; end;

  BPrint.Enabled   := CalculRapide ;
  BDetails.Enabled := BPrint.Enabled;
end;

function  TF_Interet.StrToFloatDef(s : string; def : real): real;
var s2 : string;
begin
  DecimalSeparator := '.';
  s2 := s;
  if pos('.',s2) =length(s2) then s2 := s2 + '0';
  try
    Result := StrToFloat(s2);
  except
    Result := Def;
  end;
end;

function TF_Interet.CalculRapide : boolean;
var i1n : Real;
    CI  : Real;
begin
 Result := false;
 I := I / NC;
 if p = 0 then
   begin
     i1n := Power(1 + I, N);
     p := (I * C * i1n) / ( i1n -1 );
     EVersements.Text := Format('%f',[p]);
     EVersements.Color := clAqua;
     Calculated := EVersements;
     ETotal.text  := Format('%f',[N * P]);
     EIntTot.Text := Format('%f',[N * P - C]);
     P := Round(p*100) / 100;
   end
 else
   begin
     N  := 0;
     CI := C;
     While C > P do begin
       C := C + Round(100 * I * C) / 100 - P;
       IF C >= CI then Begin Bug(EVersements); exit; end;
       N := N + 1;
     end;
     ETotal.text  := Format('%f',[N * P + C + C * I]);
     EIntTot.Text := Format('%f',[N * P + C + C * I - CI]);
     Calculated   := ENombre;
     if C > 0 then N := N + 1;
     if CBMode.ItemIndex = 0 then
       // versements
       ENombre.Text := Format('%d',[N])
     else
       // nombre d'années
       ENombre.Text := Format('%f',[N / NC]);
     ENombre.Color := clAqua;
     c := ci;
   end;
  Timer.Enabled := False;
  Result := True;
end;

procedure TF_Interet.EVersementsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Enombre.Clear;
  Calculated := Nil;
end;

procedure TF_Interet.ENombreKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  EVersements.Clear;
  Calculated := Nil;
end;

procedure TF_Interet.BDetailsClick(Sender: TObject);
begin
  SG.RowCount := 2;
  if height < Panel1.Height * 3 then
    height := Panel1.Height * 3;
  Details;
end;

procedure TF_Interet.BPrintClick(Sender: TObject);
begin
  Printer.Title := 'Calcul d''amortissement';
  Printer.BeginDoc;
  Details(True);
  Printer.EndDoc;
end;

procedure TF_Interet.Details(Print : boolean = false);
var CI    : real;
    y     : integer;
    pw,ph : integer;
    D     : TDateTime;

  procedure NextDate;
  begin
     Case NC of
        1  : D := IncMonth(D,12);
        2  : D := IncMonth(D,6);
        3  : D := IncMonth(D,4);
        4  : D := IncMonth(D,3);
        6  : D := IncMonth(D,2);
       12  : D := IncMonth(D,1);
       13  : D := D + 28;
       26  : D := D + 14;
       52  : D := D + 7;
       else D := Round(D + 365.25 / NC);
     end;
  end;

  procedure addline(n:Integer;Date : Tdatetime; V,I,R,C : Real);
  var l : integer;
  begin
    if print then
      With Printer.Canvas do
      begin
        TextOut(pw *   5 div 100, y, IntToStr(n));
        TextOut(pw *  10 div 100, y, DateToStr(Date));
        TextOut(pw *  20 div 100, y, Format('%f',[V]));
        TextOut(pw *  30 div 100, y, Format('%f',[I]));
        TextOut(pw *  40 div 100, y, Format('%f',[R]));
        TextOut(pw *  50 div 100, y, Format('%f',[C]));
        y := y + ABS(font.Height) * 5 div 4;
        if y > ph * 95 div 100 then
          printer.NewPage;
      end
    else
      begin
        l := sg.RowCount - 1;
        sg.Cells[0,l] := Format(' %3d',[n]);
        sg.Cells[1,l] := ' ' + DateToStr(Date);
        sg.Cells[2,l] := Format(' %8.2f',[V]);
        sg.Cells[3,l] := Format(' %6.2f',[I]);
        sg.Cells[4,l] := Format(' %8.2f',[R]);
        sg.Cells[5,l] := Format(' %11.2f',[C]);
        sg.RowCount := l + 2;
      end;
  end;
begin
   N  := 0;
   CI := C;
   D  := DTP.Date;
   if print then
   begin
     pw := printer.PageWidth;
     ph := printer.PageHeight;
     y  := ph * 2 div 100;
   end;

   AddLine(0,D,0,0,0,C);
   While C > P do begin
     N := N + 1;
     NextDate;
     AddLine(Round(N), D, P, C * I, P - C * I, C + I * C - P);
     C := C + Round(100 * I * C) / 100 - P;
   end;
   ETotal.text  := Format('%f',[N * P + C + C * I]);
   EIntTot.Text := Format('%f',[N * P + C + C * I - CI]);
   NextDate;
   if C > 0 then
     AddLine( Round(N + 1), D, C + I * C, C * I,C , 0);
   C := CI;
   if not print then
     SG.RowCount := SG.RowCount - 1;
end;

end.
