unit SimuleGF;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Forms, math, ExtCtrls,
  Controls, Buttons, ToolWin, ComCtrls, Menus, StdCtrls;

const
  G     = 6.67E-11;
  UA    = 149597870700;

  C_Div = 20;           // sous divisions avant animation

  // fichier pour les objets
  Type
    TObjetGRec = Record
      m,x,y,z,r,
      vx,vy,vz   : Extended;
      c          : cardinal;
      TraceSiz   : integer;
      nom,groupe : string[80];
    end;

type
  TobjetG  = class;
  TGroupeG = class;
  TF_G = class(TForm)
    Timer: TTimer;
    TB1: TToolBar;
    TBZoomIn: TToolButton;
    TBZoomOut: TToolButton;
    TBSpeedLess: TToolButton;
    TBSpeedMore: TToolButton;
    CBTraject: TCheckBox;
    ToolButton5: TToolButton;
    CBPerspective: TCheckBox;
    ToolButton6: TToolButton;
    MainMenu: TMainMenu;
    MeSysteme: TMenuItem;
    MeOrigine: TMenuItem;
    CBNoms: TCheckBox;
    MeActif: TMenuItem;
    MeDetails: TMenuItem;
    TBPause: TToolButton;
    MeZoom: TMenuItem;
    TerreLune1: TMenuItem;
    MarsSoleil1: TMenuItem;
    SystmeSolaire1: TMenuItem;
    N10SystmesSolaires1: TMenuItem;
    N100SystmesSolaires1: TMenuItem;
    MeVitesse: TMenuItem;
    N1hs1: TMenuItem;
    N6hs1: TMenuItem;
    N12hs1: TMenuItem;
    N1js1: TMenuItem;
    N2js1: TMenuItem;
    N3js1: TMenuItem;
    N7js1: TMenuItem;
    N15js1: TMenuItem;
    N1ms1: TMenuItem;
    N3ms1: TMenuItem;
    N6ms1: TMenuItem;
    N1as1: TMenuItem;
    N2as1: TMenuItem;
    N5as1: TMenuItem;
    N10as1: TMenuItem;
    N50as1: TMenuItem;
    N100as1: TMenuItem;
    Autre1: TMenuItem;
    Autre2: TMenuItem;
    StatusBar: TStatusBar;
    MeDB: TMenuItem;
    ToolButton7: TToolButton;
    TBClrTraj: TToolButton;
    CBRR: TCheckBox;
    ToolButton1: TToolButton;
    CBTurbo: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FormBlank(Sender: TObject);
    procedure ZBClick(Sender: TObject);
    procedure SBClick(Sender: TObject);
    procedure CBZoomChange(Sender: TObject);
    procedure CBSpeedChange(Sender: TObject);
    procedure TBPauseClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MeDBClick(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure TBClrTrajClick(Sender: TObject);
    procedure CBTurboClick(Sender: TObject);
  private
    ox,oy,oz : Extended;
    Forig    : TObjetG;
    Ft       : Extended;
    Fech     : Extended;
    jrs      : Extended;
    function  FindMenu(M : TMenuItem ; obj_nam : string) : TMenuItem;
    Procedure SetInfo(i : integer; txt : string);
    Procedure WriteOrig(Value : TObjetG);
    Procedure Writet(Value : Extended);
    Procedure WriteEch(Value : Extended);
    Procedure ShowEchelle;
    Procedure LoadGroup(Name: string);

  public
    Group      : string;
    LastCall   : DWord;
    Delay      : Dword;
    iterations : integer;
    U          : TGroupeG;
    ObjFile    : file of TObjetGRec;
    ObjRec     : TObjetGRec;
    redraw     : boolean;
    Property  orig : TObjetG read Forig Write WriteOrig;
    Property  t   : Extended read Ft Write Writet;
    Property  ech : Extended read Fech Write WriteEch;
    Procedure GetSystemes;
    Procedure AjouteObjetG(OG : TObjetG);
    Procedure ClearMenu(M : TmenuItem);
    procedure MeSystemeClick(Sender: TObject);
    procedure MeActifClick(Sender: TObject);
    procedure MeOrigineClick(Sender: TObject);
    procedure MeDetailsClick(Sender: TObject);
    procedure ClearDetails;
    procedure pause;
    procedure play;
  end;

  TPosition = record
    x,y,z : extended;
  end;

  TobjetG = class
  public
    nom        : string;
    parent     : TObjetG;
    couleur    : Tcolor;
    actif      : Boolean;
    x,y,z,r,
    vx,vy,vz,
    m          : Extended;
    trajet     : Array of TPosition;
    trj_siz    : integer;
    trj_cnt    : integer;
    trj_ix0    : integer;
    max_tr     : integer;
    constructor create(_nom: string; _parent: TobjetG; _CreateRec: TObjetGRec);
    procedure dessine(ox, oy, oz: extended); virtual; abstract;
    procedure ClearTrajet; virtual; abstract; // position history in 3d
    procedure influence(infl_obj : TobjetG); virtual;
    procedure bouge; virtual;
    procedure GetAbsCoor(var absx,absy,absz : Extended);
    procedure GetCentreDeMasse(var cx,cy,cz : Extended); virtual;
  end;

  TCorpsG = class(TobjetG)
  public
    lx,ly,lr  : integer;
    procedure dessine(ox, oy, oz: extended); override;
    procedure ClearTrajet; override;
  end;

  TGroupeG = class(TobjetG)
  public
    liste     : Tlist;
    constructor create(_name: string; _parent : TObjetG; _CreateRec: TObjetGRec);
    destructor destroy; override;
    procedure dessine(ox, oy, oz: extended); override;
    procedure influence(infl_obj : TobjetG); override;
    procedure bouge; override;
    procedure ClearTrajet; override;
    function  find(name : string): TobjetG;
    procedure add(OG : TobjetG);
    procedure GetCentreDeMasse(var cx,cy,cz : Extended); override;
    procedure AjusteMV0;
    function  PlusLourd : TObjetG;
    function  PlusPres2D(mx,my:integer):TObjetG;
  end;

var
  F_G  : TF_G;

implementation

uses Fdetails, FDatabase;

{$R *.DFM}
{$WARN UNSAFE_TYPE OFF}

constructor TobjetG.create(_nom: string; _parent: TobjetG; _CreateRec: TObjetGRec);
begin
  nom := _nom;
  parent := _parent;
  couleur := _CreateRec.c;
  x := _CreateRec.x;  y := _CreateRec.y;  z := _CreateRec.z;
  vx := _CreateRec.vx; vy := _CreateRec.vy; vz := _CreateRec.vz;
  m := _CreateRec.m; trj_siz := _CreateRec.TraceSiz;
  r := _CreateRec.r;
  actif := true;
  SetLength(trajet, trj_siz);
  trj_ix0 := 0; // position where to add intem in circulat buffer
  trj_cnt := 0;
end;

procedure TobjetG.influence(infl_obj : TobjetG);
var d,ax,ay,az,at : Extended;
begin
  if not actif then exit;
  ax := infl_obj.x - x;
  ay := infl_obj.y - y;
  az := infl_obj.z - z;
  d := sqrt(ax * ax + ay * ay + az * az);

  // vecteur de longueur 1
  ax := ax / d;
  ay := ay / d;
  az := az / d;

  at := ((G * infl_obj.m) / ( d * d )) * F_G.t;

  vx := vx + ax * at;
  vy := vy + ay * at;
  vz := vz + az * at;
end;

procedure TobjetG.bouge;
begin
  if not actif then exit;
  x := x + (vx * F_G.t);
  y := y + (vy * F_G.t);
  z := z + (vz * F_G.t);
end;

procedure TobjetG.GetAbsCoor(var absx,absy,absz : extended);
begin
  if parent = nil then
    begin absx := x; absy := y; absz := z; end
  else
    begin
      parent.GetAbsCoor(absx,absy,absz);
      absx := absx + x;
      absy := absy + y;
      absz := absz + z;
    end;
end;

Procedure TobjetG.GetCentreDeMasse(var cx,cy,cz : Extended);
begin
  cx := x; cy := y; cz := z;
end;

procedure TGroupeG.dessine(ox, oy, oz: extended);
var i : integer;
begin
  for i := 0 to liste.Count - 1 do
    TobjetG(liste.items[i]).dessine(ox + x, oy + y, oz + z)
end;

procedure TcorpsG.dessine(ox, oy, oz: extended);
var ex,ey,ez,
    er,d,ech   : Extended;
    ix,iy,ir   : Integer;
    i,rw,start : Integer;
    add,first  : Boolean;
    tx,ty,tz   : Extended;

  procedure DrawBoule(x,y,r : Extended; c : TColor);
  begin
    if (abs(x) > F_G.Width * 2) or (abs(y) > F_G.height * 2) then exit;
    ix := Round(x);
    iy := Round(y);
    ir := Round(r);
    F_G.canvas.pen.color   := c;
    F_G.canvas.Brush.Color := c;
    F_G.Canvas.Brush.Style := bsSolid;
    F_G.Canvas.Ellipse(ix-ir,iy-ir,ix+ir,iy+ir);
    if F_G.CBNoms.Checked then
    begin
      F_G.canvas.font.color   := c;
      F_G.canvas.brush.Style := bsClear;
      F_G.Canvas.TextOut(ix+ir,iy+ir,nom);
    end;
  end;

begin
  if not actif then exit;
  ech := F_G.ech;    // speed optimization (not using reader eaxh time)
  DrawBoule(lx,ly,lr,F_G.Color);  //efface la boule
  ox := ox + x;
  oy := oy + y;
  oz := oz + z;

  ez := round(oz * ech) * 0.4;
  ex := (F_G.width div 2) + round(ox * ech);
  if F_G.CBPerspective.checked then
      ey := (F_G.height div 2) - round(oy * ech) - ez
  else
      ey := (F_G.height div 2) - round(oz * ech);

  if F_G.CBRR.checked then
    er := r * ech
  else
    er := max(2,round(0.05*(power(m,0.06 + sqrt(ech) * 50))));

  DrawBoule(ex,ey,er,couleur);    // re-dessine la boule
  lx := ix; ly := iy; lr := ir;

  // Add new trace point if needed
  add := true;
  if trj_cnt > 0 then begin
    rw := (trj_ix0 + trj_cnt - 1) mod trj_siz;
    d := sqrt(power(trajet[rw].x - ox,2) + power(trajet[rw].y - oy,2) + power(trajet[rw].z - oz,2));
    add := d > Max(r, 10000);  // at least 10 km between points
  end;

  if add then begin
    rw := (trj_ix0 + trj_cnt) mod trj_siz;
    trajet[rw].x := ox; trajet[rw].y := oy; trajet[rw].z := oz;
    if trj_cnt = trj_siz then
      Inc(trj_ix0)  // overwrite oldest element
    else
      Inc(trj_cnt); // increase number of elements
  end;

  if (not F_G.CBTraject.Checked) or (trj_cnt < 2) then exit;

  first := true;
  F_G.canvas.pen.color := couleur;

  start := 0;
  if not F_G.redraw then start := max(0, trj_cnt - 10);

  for i:= start to trj_cnt do
  begin
    if i = trj_cnt then begin // draw line to object
      tx := ox;
      ty := oy;
      tz := oz;
    end else begin
      rw := (trj_ix0 + i) mod trj_siz;
      tx := trajet[rw].x;
      ty := trajet[rw].y;
      tz := trajet[rw].z;
    end;

    ez := round(tz * ech) * 4 div 10;
    ex := (F_G.width div 2) + round(tx * ech);

    if F_G.CBPerspective.checked then
        ey := (F_G.height div 2) - round(ty * ech) - ez
    else
        ey := (F_G.height div 2) - round(tz * ech);

    // lever le crayon si on sort de la fenetre
    if (ex > F_G.Width) or (ey > F_G.height) or (ex < 0) or (ey < 0) then
      first := true
    else begin
      if first then
        F_G.Canvas.MoveTo(Round(ex),Round(ey))
      else
        F_G.Canvas.LineTo(Round(ex),Round(ey));
      first := false;
    end; // if
  end; // for
end;

procedure TGroupeG.influence(infl_obj : TobjetG);
var i,j : integer;
begin
  for i := 0 to liste.Count - 2 do
    for j := i + 1 to liste.Count - 1 do
    if TobjetG(liste.items[i]).actif and TobjetG(liste.items[j]).actif then
    begin
      TobjetG(liste.items[i]).influence(TobjetG(liste.items[j]));
      TobjetG(liste.items[j]).influence(TobjetG(liste.items[i]));
    end;
  if infl_obj <> nil then
    inherited;
end;

procedure TGroupeG.bouge;
var i : integer;
begin
  inherited;
  for i := 0 to liste.Count - 1 do
    TobjetG(liste.items[i]).bouge;
end;

procedure TGroupeG.ClearTrajet;
var i  : integer;
begin
  for i := 0 to liste.Count - 1 do
    TobjetG(liste.items[i]).ClearTrajet;
end;

function  TGroupeG.find(name : string): TobjetG;
var i : integer;
begin
  result := nil;
  if name = nom then
    result := self
  else
    for i := 0 to liste.Count - 1 do
    begin
      if TobjetG(liste.items[i]) is TGroupeG then
        Result := TgroupeG(liste.items[i]).find(name)
      else if 0 = CompareText(TobjetG(liste.items[i]).nom, name) then
        Result := liste.items[i];
      if result <> nil then break;
    end;
end;

procedure TGroupeG.add(OG : TobjetG);
begin
  liste.Add(OG);
  m := m + OG.m;
end;

Procedure TGroupeG.GetCentreDeMasse(var cx,cy,cz : Extended);
Var Ucx,
    Ucy,
    Ucz   : Extended;
    i     : integer;
    OG    : TObjetG;
begin
  cx := 0; cy := 0; cz := 0;
  For i := 0 to Liste.count - 1 do
  begin
    OG := Liste.Items[i];
    OG.GetCentreDeMasse(Ucx,Ucy,Ucz);
    cx := cx * OG.x;
    cy := cy * OG.y;
    cz := cz * OG.z;
  End;
  cx := cx / m;
  cy := cy / m;
  cz := cz / m;
end;

procedure TGroupeG.AjusteMV0;
Var aj : TObjetG;
    i  : integer;
    mvx,mvy,mvz : Extended;
begin
  aj := PlusLourd;
  if aj = nil then exit;
  mvx := 0; mvy := 0; mvz := 0;
  for i := 0 to liste.Count - 1 do
    if liste.Items[i] <> aj then
    with TObjetG(liste.Items[i]) do
    if actif then
    begin
      begin
        mvx := mvx + m * vx;
        mvy := mvy + m * vy;
        mvz := mvz + m * vz;
      end;
    aj.vx := -mvx/aj.m;
    aj.vy := -mvy/aj.m;
    aj.vz := -mvz/aj.m;
  end;
end;

function  TGroupeG.PlusLourd : TObjetG;
var i  : integer;
begin
  if liste.Count = 0 then
    Result := nil
  else
    begin
      Result := liste.items[0];
      For i := 0 to liste.Count - 1 do
        if TObjetG(liste.items[i]).m > Result.m then
          Result := liste.items[i];
    end;
end;

function  TGroupeG.PlusPres2D(mx,my:integer):TObjetG;
var i   : integer;
    d2d,
    d   : Extended;
begin
  Result := nil;
  d2d := 1E2000;
  for i := 0 to liste.Count - 1 do
    if TObjetG(liste.Items[i]) is TCorpsG then
    with TCorpsG(liste.Items[i]) do
    begin
      d := sqrt(power(mx - lx,2) + power(my - ly,2));
      if d < d2d then
      begin
        Result := liste.Items[i];
        d2d := d;
      end;
    end;
  if d2d > 30 then result := nil;
end;

constructor TGroupeG.create(_name: string; _parent : TObjetG; _CreateRec: TObjetGRec);
begin
  inherited create(_name, _parent, _CreateRec);
  liste := Tlist.create;
end;

destructor TGroupeG.destroy;
var i : integer;
begin
  for i := 0 to liste.Count - 1 do
    TObjetG(liste.items[i]).free;
  liste.free;
end;

procedure TCorpsG.ClearTrajet;
begin
  trj_ix0 := 0;
  trj_cnt := 0;
end;

procedure TF_G.FormCreate(Sender: TObject);
begin
  AssignFile(ObjFile,'Objects.dat');
  U := Nil;
  Fech := height / UA;
  GetSystemes;
  delay := Timer.Interval + 15;
  TB1.Buttons[0].Hint :=   TB1.Buttons[0].hint + #13 + '(Roulette souris)';
  TB1.Buttons[1].Hint :=   TB1.Buttons[1].hint + #13 + '(Roulette souris)';
  TB1.Buttons[4].Hint :=   TB1.Buttons[4].hint + #13 + '(Pavé num [+])';
  TB1.Buttons[3].Hint :=   TB1.Buttons[3].hint + #13 + '(Pavé num [-])';
  TB1.Buttons[9].Hint :=   TB1.Buttons[9].hint + #13 + '(Espace)';
end;

procedure TF_G.TimerTimer(Sender: TObject);
Var GT    : Dword;
    i,r,n : Integer;
begin
  if U = nil then exit;

  if CBTurbo.Checked then n := 100 else n := 1;

  for r := 1 to n do begin

  GT := GetTickCount;
  Delay := GT - LastCall;
  LastCall := GT;

  For i := 1 to C_div do
  begin
    U.influence(nil);
    U.bouge;
  end;
  Orig.GetAbsCoor(ox,oy,oz);

  redraw := redraw or ((iterations mod 20) = 0);
  U.dessine(-ox,-oy,-oz);
  redraw := false;

  inc(iterations);
  jrs := jrs + t * C_Div / 86400;
  end;

  if ((iterations mod 5) = 0) or (n > 1) then
  begin
    if Jrs < 1 then
      SetInfo(4,'Temps écoulé: ' + Format('%f',[jrs*24]) + ' Heures')
    else if Jrs < 31 then
      SetInfo(4,'Temps écoulé: ' + Format('%f',[jrs]) + ' Jours')
    else if Jrs < 365.25 then
      SetInfo(4,'Temps écoulé: ' + Format('%f',[jrs/30.4375]) + ' Mois')
    else
      SetInfo(4,'Temps écoulé: ' + Format('%f',[jrs/365.25]) + ' Ans');
  end;
end;

procedure TF_G.FormBlank(Sender: TObject);
begin
  canvas.pen.color := color;
  canvas.brush.style := bsSolid;
  canvas.brush.color := color;
  canvas.Rectangle(0,0,width,height);
  redraw := true;
  OnPaint(sender);
  ShowEchelle;
end;

procedure TF_G.ZBClick(Sender: TObject);
var C : string;
begin
  C := Trim(Uppercase(TToolButton(Sender).caption));
  if  C ='Z+' then ech := ech * 1.25;
  if  C ='Z-' then ech := ech / 1.25;
  FormBlank(self);
end;

procedure TF_G.SBClick(Sender: TObject);
var C : string;
begin
  C := Trim(Uppercase(TToolButton(Sender).caption));
  if  C ='V+' then t := t * 1.25;
  if  C ='V-' then t := t / 1.25;
end;

procedure TF_G.CBZoomChange(Sender: TObject);
begin
  Case TMenuItem(Sender).Tag of
    0 : ech := 3.4E-8;
    1 : ech := 1.52E-9;
    2 : ech := 4E-11;
    3 : ech := 1E-12;
    4 : ech := 1E-15;
  end;
  TMenuItem(Sender).Checked := True;
  SetInfo(2, 'Zoom: ' + TMenuItem(Sender).Caption);
  FormBlanK(Sender);
end;

procedure TF_G.CBSpeedChange(Sender: TObject);
var c : string;
    i,n : integer;
begin
  c := trim(TMenuItem(Sender).Caption);
  i := 1;
  while ((i + 1)<length(c)) and (c[i+1]>='0') and (c[i+1]<='9') do inc(i);
  n := StrToIntDef(copy(c,1,i),-1);
  if n = -1 then exit;
  case pos(copy(c,i+2,1),'hjsma') of
    0,1 : t := 3600;
    2   : t := 3600 * 24;
    3   : t := 3600 * 24 * 7;
    4   : t := 3600 * 24 * 30;
    5   : t := 3600 * 24 * 365.24;
  end;
  t := t * n * (Delay) / 1000 / C_Div;
  TMenuItem(Sender).Checked := True;
  if not CBTurbo.Checked then
    SetInfo(3, 'Vitesse: ' + TMenuItem(Sender).Caption);
end;

Procedure TF_G.WriteOrig(Value : TObjetG);
begin
  FOrig := Value;
  If Value = nil then
    begin
      SetInfo(1,'Origine: - ');
      exit;
    end
  else
    SetInfo(1,'Origine: ' + Value.nom);

  Value.GetCentreDeMasse(Value.x,Value.y,Value.z);
  U.ClearTrajet;
  U.AjusteMV0;
end;

Procedure TF_G.Writet(Value : Extended);
var rd : Extended;
    us : String;
begin
  Ft := Value;

  rd := ((Ft * 1000 * C_Div) / Max(delay,1) ) / 3600;

  us := 'h';
  if rd >= 23.9 then begin
    rd := rd / 24; us := 'jrs';
    if rd >= 30.3 then begin
      rd := rd / 30.4375; us := 'mois';
      if rd >= 11.9 then begin
        rd := rd / 12; us := 'ans'; end; end; end;

  if not CBTurbo.Checked then
    SetInfo(3,'Vitesse: ' + Format('%f ',[rd]) + us + '/sec' );
    
  MeVitesse.items[MeVitesse.count - 1].Checked := True;
  FormBlank(self);
end;

Procedure TF_G.WriteEch(Value : Extended);
begin
  Fech := Value;
  FormBlank(self);
end;

Procedure TF_G.ShowEchelle;
var ev : Extended;
begin
  if Fech = 0 then Fech := 1E-500;
  ev := min(width,height)/Fech / UA;
  SetInfo(2,'Échelle: ' + Format('%3.2f ',[ev]) + 'UA' );

  if MeZoom.Count > 0 then
    MeZoom.Items[MeZoom.Count - 1].Checked := True;
end;

Procedure TF_G.GetSystemes;
Var Mi   : TMenuItem;
//    code : integer;
begin
  Reset(ObjFile);
  While not Eof(ObjFile) do
  begin
    Read(ObjFile,ObjRec);
    if ObjRec.m = 0 then
    begin
      Mi := TmenuItem.create(self);
      Mi.RadioItem := True;
      MeSysteme.Add(Mi);
      Mi.Caption := ObjRec.Nom;
      Mi.OnClick := MeSystemeClick;
    end;
  end;
  CloseFile(ObjFile);
end;

procedure TF_G.MeSystemeClick(Sender: TObject);
begin
  LoadGroup(TMenuItem(Sender).caption);
  TMenuItem(Sender).checked := True;
end;

procedure TF_G.LoadGroup(Name: String);
var grps   : string;
    GG,NOG : TObjetG;
    U_Orig : integer;
    U_t,
    U_ech  : extended;
const
    Dummy  : TObjetGRec = (
      m:0; x:0 ; y:0; z:0;
      vx:0 ; vy:0; vz:0;
    );
begin
  Timer.Enabled := False;
  U.free;
  Group := Name;

  Iterations := 0;
  jrs := 0;

  ClearMenu(MeOrigine);
  ClearMenu(MeActif);
  ClearMenu(MeDetails);
  ClearDetails;

  U := TGroupeG.create(Name,nil,Dummy);
  AjouteObjetG(U);

  // Lire les groupes en premier
  U_Orig := -1;
  U_t    := 0;
  U_ech  := 0;
  grps   := '|' + U.nom + '|';

  Reset(ObjFile);
  While not EOF(ObjFile) do
  With ObjRec do
  begin
    Read(ObjFile,ObjRec);
    if (m = 0) and (nom = U.nom) then
    begin
      if nom = U.nom then
        begin
          U_t    := (vx / 1000) * Timer.Interval / 1000/ C_Div;
          U_ech  := min(width,height) / x ;
          U_Orig := Round(y / UA);
        end
      else
        U.add(TGroupeG.create(nom, U, ObjRec));
      grps := grps + nom + '|';
    end;
  end;

  // Ajouter les corps gravitationnels aux groupes
  Reset(ObjFile);
  While not EOF(ObjFile) do
  begin
    Read(ObjFile,ObjRec);
    if  (0 <> pos(ObjRec.groupe, grps)) and (ObjRec.m <> 0)then
    With ObjRec do
    begin
      GG := U.find(groupe);
      NOG := TCorpsG.create(nom, GG, ObjRec);
      TGroupeG(GG).add(NOG);
      AjouteObjetG(NOG);
    end;
  end;
  CloseFile(ObjFile);

  if U_Orig = -1 then
    Orig := U
  else
    Orig := U.liste[U_Orig];

  t   := U_t;
  if U_ech > 0 then ech := U_ech;
  FormBlank(self);
  SetInfo(0,'Système: ' + U.nom);
  Play;
end;

Procedure TF_G.AjouteObjetG(OG : TObjetG);
Var Mi : TMenuItem;
begin
  Mi := TMenuItem.Create(self);
  Mi.Caption   := OG.nom;
  Mi.RadioItem := True;
  Mi.OnClick   := MeOrigineClick;
  MEOrigine.Add(Mi);

  Mi := TMenuItem.Create(self);
  Mi.Caption := OG.nom;
  Mi.OnClick := MeActifClick;
  Mi.Checked := True;
  MEActif.Add(Mi);

  Mi := TMenuItem.Create(self);
  Mi.Caption := OG.nom;
  Mi.OnClick := MeDetailsClick;
  MEDetails.Add(Mi);
end;

Procedure TF_G.ClearMenu(M : TmenuItem);
begin
  While M.Count > 0 do M.Delete(0);
end;

procedure TF_G.MeActifClick(Sender: TObject);
begin
  With TMenuItem(Sender) do
  begin
    Checked := Not Checked;
    TObjetG(U.find(caption)).Actif := Checked;
    Orig.GetCentreDeMasse(Orig.x,Orig.y,Orig.y);
    U.AjusteMV0;
  end;
  FormBlank(Sender);
end;

procedure TF_G.MeOrigineClick(Sender: TObject);
begin

  With TMenuItem(Sender) do
  begin;
    TMenuItem(Sender).Checked := true;
    Orig := U.find(caption);
  end;
  FormBlank(Sender);
end;

procedure TF_G.MeDetailsClick(Sender: TObject);
Var FD : TF_Details;
    i  : integer;
begin
  With TMenuItem(Sender) do
  begin
    Checked := Not Checked;
    if checked then
      begin
        FD := TF_Details.Create(Self, U.find(caption));
        FD.Show;
      end
    Else For i := 0 to Screen.FormCount - 1 do
      if Screen.Forms[i].caption = caption then
        Screen.Forms[i].release;
  end;
  FormBlank(Sender);
end;

procedure TF_G.ClearDetails;
var i : integer;
begin
  i := 0;
  While i < Screen.FormCount do
  begin
    if Screen.Forms[i] is TF_details then
      Screen.Forms[i].release;
    inc(i);
  end;
end;

procedure TF_G.TBPauseClick(Sender: TObject);
begin
  if U = nil then exit;
  if Timer.Enabled then
    pause
  else
    play;
end;

procedure TF_G.Play;
begin
  TBPause.Caption := ' || ';
  Timer.Enabled := True;
end;

procedure TF_G.Pause;
begin
  TBPause.Caption := ' > ';
  Timer.Enabled := False;
end;


procedure TF_G.FormPaint(Sender: TObject);
begin
  if U = nil then exit;
  Orig.GetAbsCoor(ox,oy,oz);
  U.dessine(-ox,-oy,-oz);
end;

procedure TF_G.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_SPACE then
  begin
    TBpause.click;
    Key := 0;
  end else if Key = VK_ADD then
    t := t * 1.25
  else if Key = VK_SUBTRACT then
    t := t / 1.25
  else if Key = VK_F5 then
    LoadGroup(Group)
  else if Key = VK_F9 then
    begin CBTurbo.Checked := not CBTurbo.Checked; CBTurboClick(nil); end
end;

function TF_G.FindMenu(M : TMenuItem ; obj_nam : string) : TMenuItem;
Var i : integer;
begin
  result := nil;
  for i := 0 to M.Count - 1 do
    if M.Items[i].caption = obj_nam then
      Result := M.Items[i];
end;

Procedure TF_G.SetInfo(i : integer ; txt : string);
begin
  With StatusBar.Panels[i] do
  begin
    text  := txt;
    width := 22 + canvas.TextWidth(txt);
  end;
end;

procedure TF_G.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
Var OG : TObjetG;
begin
  if u = nil then exit;
  OG := U.PlusPres2D(x,y);
  if OG <> nil then
  if Button = mbLeft then
    if ssCtrl in Shift then
      FindMenu(MEActif,OG.nom).click
    else
      FindMenu(MEOrigine,OG.nom).click
  else
    FindMenu(MEDetails,OG.nom).click
end;

procedure TF_G.MeDBClick(Sender: TObject);
begin
  F_Database.show;
end;

procedure TF_G.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  if WheelDelta > 0 then
    ech := ech * 1.25
  else if WheelDelta < 0 then
    ech := ech / 1.25;
end;

procedure TF_G.TBClrTrajClick(Sender: TObject);
begin
   U.ClearTrajet;
   FormBlank(self);
end;


procedure TF_G.CBTurboClick(Sender: TObject);
begin
  if CBTurbo.Checked then
    SetInfo(3, 'Vitesse: N.D.')
  else
    t := t;

end;

end.
