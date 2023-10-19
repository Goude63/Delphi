unit FDatabase;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, ExtCtrls, Buttons, ToolWin,
  ComCtrls, SimuleGF;

type
  TF_Database = class(TForm)
    LbLoc: TLabel;
    Label2: TLabel;
    LbX: TLabel;
    LbY: TLabel;
    Label5: TLabel;
    LbVX: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    LbColor: TLabel;
    ToolBar1: TToolBar;
    SBPrev: TSpeedButton;
    SBNext: TSpeedButton;
    SBAdd: TSpeedButton;
    SBDel: TSpeedButton;
    ENom: TEdit;
    EGroupe: TEdit;
    Ex: TEdit;
    Ey: TEdit;
    Ez: TEdit;
    Evx: TEdit;
    Evy: TEdit;
    Evz: TEdit;
    Em: TEdit;
    Ec: TEdit;
    SBSave: TSpeedButton;
    LblUnitsPos: TLabel;
    LabUnitsV: TLabel;
    LabMassUnits: TLabel;
    LabTraceCnt: TLabel;
    ETraceCnt: TEdit;
    LbScale: TLabel;
    LbOrigineIx: TLabel;
    LbFA: TLabel;
    SB_PG: TSpeedButton;
    SB_NG: TSpeedButton;
    Label3: TLabel;
    ER: TEdit;
    LbRUnits: TLabel;
    SBConvert: TSpeedButton;
    Label4: TLabel;
    Label6: TLabel;
    Label10: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure SBNextClick(Sender: TObject);
    procedure SBPrevClick(Sender: TObject);
    procedure ENomChange(Sender: TObject);
    procedure SBSaveClick(Sender: TObject);
    procedure EmChange(Sender: TObject);
    procedure SBAddClick(Sender: TObject);
    procedure SBPNGrp(Sender: TObject);
    procedure SBDelClick(Sender: TObject);
    procedure SBConvertClick(Sender: TObject);
  private
    CurrRecNo : integer;
    ObjRec  : TObjetGRec;
    ObjFile   : file of TObjetGRec;
    MemDB : Array of TObjetGRec;
    procedure ReadDb(insertIx : integer = -1);
    procedure WriteDb(deleteIx : integer = -1);
    procedure GetData;
    procedure SaveData;
    procedure SetMode(grp: boolean);
    procedure CanEdit;
  public
    { Public declarations }
  end;

var
  F_Database: TF_Database;

const NewRec : TObjetGRec = (
  m: 0; x: 0; y: 0; vx: 0; vy: 0; vz: 0; c: $808080;
  TraceSiz: 160; nom: 'Nouvel Objet'; groupe: 'Nouvel Objet' );

implementation

{$R *.DFM}
{$WARN UNSAFE_TYPE OFF}

procedure TF_Database.FormCreate(Sender: TObject);
begin
  AssignFile(ObjFile,'Objects.dat');
  GetData;
end;

procedure TF_Database.GetData;
var fs : integer;
begin
  Reset(ObjFile);
  fs := FileSize(ObjFile);
  if CurrRecNo > (fs - 1) then CurrRecNo := fs - 1;
  if CurrRecNo < 0 then CurrRecNo := 0;
  Seek(ObjFile, CurrRecNo);
  Read(ObjFile, ObjRec);
  CloseFile(ObjFile);

  LbLoc.Caption := IntToStr(CurrRecNo + 1) + '/' + IntToStr(fs);

  try
    With ObjRec do
    begin
      Enom.text    := nom;
      Egroupe.text := groupe;
      Ex.text  := Format('%g',[x / UA ]);   // using meters in the file
      Ey.text  := Format('%g',[y / UA ]);
      Ez.text  := Format('%g',[z / UA ]);
      ER.Text  := Format('%g',[r / 1000]);  // file is in m UI in km
      Evx.text := Format('%g',[vx / 1000]); // file is in m/s UI in km/s
      Evy.text := Format('%g',[vy / 1000]);
      Evz.text := Format('%g',[vz / 1000]);
      Em.text  := FloatToStr(m);
      Ec.text  := Format('%8.8x',[c]);
      ETraceCnt.Text := IntToStr(TraceSiz);
      SetMode(m = 0);
    end;
  finally
    CanEdit;
  end;
end;

procedure TF_Database.SBNextClick(Sender: TObject);
var fs : LongInt;
begin
  Reset(ObjFile);
  fs := FileSize(ObjFile);
  CloseFile(ObjFile);

  if CurrRecNo < fs - 1 then
  begin
    Inc(CurrRecNo);
    GetData;
  end;
end;

procedure TF_Database.SBPrevClick(Sender: TObject);
begin
  if CurrRecNo > 0 then
  begin
    Dec(CurrRecNo);
    GetData;
  end;
end;

procedure TF_Database.ENomChange(Sender: TObject);
begin
  SBSave.Enabled := True;
  SBPrev.Enabled := False;
  SBNext.Enabled := False;
  SBDel.Enabled := False;
  SBAdd.Enabled := False;
  SB_PG.Enabled := false;
  SB_NG.Enabled := false;
end;

procedure TF_Database.SBSaveClick(Sender: TObject);
begin
  SaveData;
  CanEdit;
end;

procedure TF_Database.CanEdit;
begin
  SBSave.Enabled := False;
  SBPrev.Enabled := True;
  SBNext.Enabled := True;
  SBDel.Enabled := True;
  SBAdd.Enabled := True;
  SB_PG.Enabled := True;
  SB_NG.Enabled := True;
end;

procedure TF_Database.SaveData;
var fs : integer;
begin
  Reset(ObjFile);
  fs := FileSize(ObjFile);
  if CurrRecNo > (fs - 1) then CurrRecNo := fs;
  if CurrRecNo < 0 then CurrRecNo := fs;

try
  With ObjRec do
  begin
    m  := StrToFloat(Em.text);
    groupe := Egroupe.text;

    if m = 0 then
      nom := groupe
    else
      nom := Enom.text;

    x := StrToFloat(Ex.text) * UA;
    y := StrToFloat(Ey.text) * UA;
    z := StrToFloat(Ez.text) * UA;
    r := StrToFloat(ER.text) * 1000;
    vx := StrToFloat(Evx.text) * 1000;
    vy := StrToFloat(Evy.text) * 1000;
    vz := StrToFloat(Evz.text) * 1000;
    c  := StrToInt('$' + Ec.text);
    TraceSiz := StrToInt(ETraceCnt.text);
  end;

  Seek(ObjFile, CurrRecNo);
  Write(ObjFile, ObjRec);
finally
  CloseFile(ObjFile);
end;
end;

// Items that are sown for group have tag = 1, for objetcts: tag = 2
procedure TF_Database.SetMode(grp: boolean);
var i : integer;
begin
  for i := 0 to self.ComponentCount - 1 do
    if (Components[i].Tag and 3) <> 0 then  // 1 or 2
    begin
      if Components[i] is TLabel then
        (Components[i] as TLabel).visible := (Components[i].tag = 2) xor grp;
      if Components[i] is TEdit then
        (Components[i] as TEdit).visible := (Components[i].tag = 2) xor grp;
    end;
end;

procedure TF_Database.EmChange(Sender: TObject);
var grp : boolean;
begin
  try
    grp := StrToFloat(Em.Text) = 0;
  Except
    grp := true;
  end;
  SetMode(grp);
  ENomChange(Sender);
end;

procedure TF_Database.SBAddClick(Sender: TObject);
begin
  ReadDb(CurrRecNo + 1);
  WriteDB;
  Inc(CurrRecNo);
  GetData;
end;

procedure TF_Database.SBDelClick(Sender: TObject);
begin
  ReadDb;
  WriteDB(CurrRecNo);
  if CurrRecNo > 0 then CurrRecNo := CurrRecNo - 1;
  GetData; 
end;


procedure TF_Database.SBPNGrp(Sender: TObject);
var fs  : LongInt;
    dir, nxt : Integer;
    done : boolean;
begin
  Reset(ObjFile);
  fs := FileSize(ObjFile);

  if (Sender as TSpeedButton).Name = 'SB_PG'
    then dir := - 1
    else dir := 1;

  done := false;
  nxt := CurrRecNo + dir;
  while (Nxt >= 0) and (Nxt < fs) and not done do
  begin
    Seek(ObjFile, nxt);
    Read(ObjFile, ObjRec);
    if ObjRec.m = 0 then
      done := true
    else
      nxt := nxt + dir;
  end;
  CloseFile(ObjFile);
  if done then begin
    CurrRecNo := nxt;
    GetData;
  end
end;

// Read db in memory, option to insert new record
procedure TF_Database.ReadDb(insertIx : integer = -1);
var fs, ms, ix : integer;
begin
  Reset(ObjFile);
  fs := FileSize(ObjFile);
  ms := fs;
  if insertIx >= 0 then Inc(ms);
  SetLength(MemDB, ms);
  for ix := 0 to ms - 1 do
  begin
    if ix <> insertIx then
      Read(ObjFile, ObjRec)
    else
      ObjRec := NewRec;
    MemDB[ix] := ObjRec;
  end;
  CloseFile(ObjFile);
end;

// Write db from memory, option to skip a record
procedure TF_Database.WriteDb(deleteIx : integer = -1);
var ix : integer;
begin;
  Erase(ObjFile);
  Rewrite(ObjFile);
  for ix := 0 to Length(MemDB) - 1 do
  begin
    if ix <> deleteIx then
      Write(ObjFile, MemDB[ix]);
  end;
  CloseFile(ObjFile);
end;


procedure TF_Database.SBConvertClick(Sender: TObject);
Type
    TNewFileRec = Record
      m,x,y,z,r,
      vx,vy,vz   : Extended;
      c          : cardinal;
      TraceSiz   : integer;
      nom,groupe : string[80];
    end;
var NewRec : TNewFileRec;
  fs : integer;
  NewFile : file of TNewFileRec;

begin
   AssignFile(NewFile,'ObjectsNew.dat');
   Rewrite(NewFile);
   Reset(ObjFile);

   While not EOF(ObjFile) do begin
     Read(ObjFile, ObjRec);
     NewRec.m  := ObjRec.m;
     NewRec.x  := ObjRec.x;
     NewRec.y  := ObjRec.y;
     NewRec.z  := ObjRec.z;
     NewRec.vx := ObjRec.vx;
     NewRec.vy := ObjRec.vy;
     NewRec.vz := ObjRec.vz;
     NewRec.c  := ObjRec.c;
     NewRec.TraceSiz  := ObjRec.TraceSiz;
     NewRec.nom       := ObjRec.nom;
     NewRec.groupe    := ObjRec.groupe;

     // New Default
     NewRec.r := 10000 ;      // 10 km

     Write(NewFile,NewRec);
   end;

   CloseFile(ObjFile); CloseFile(NewFile);
end;

end.
