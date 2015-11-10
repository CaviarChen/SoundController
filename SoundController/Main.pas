unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Media;

type
  TForm1 = class(TForm)
    Text1: TText;
    Button_p: TButton;
    Button_n: TButton;
    Panel1: TPanel;
    Text2: TText;
    Text3: TText;
    Button_play: TButton;
    Text4: TText;
    Text5: TText;
    Text6: TText;
    Button_back: TButton;
    procedure FormShow(Sender: TObject);
    procedure Button_pClick(Sender: TObject);
    procedure Button_nClick(Sender: TObject);
    procedure Button_playClick(Sender: TObject);
    procedure Button_backClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure setGUI();
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses IOUtils,XSuperObject;

var config:ISuperObject;
    currentid:integer;
    MediaPlayer:array[1..4] of TMediaPlayer;

function LoadJson(f:string):Isuperobject;
var
    Reader:TStreamReader;
begin
  Reader := TStreamReader.Create(f, Tencoding.Unicode);
  Result := SO(Reader.ReadToEnd);
  Reader.Close;
  Reader.Free;
end;

function LoadConfig():integer;
begin
  try
    {$IFDEF MSWINDOWS}
       TDirectory.SetCurrentDirectory(TPath.GetDirectoryName(ParamStr(0)));
    {$ELSE}
       TDirectory.SetCurrentDirectory(TPath.GetDirectoryName(ParamStr(0))+'/../../../');
    {$ENDIF}

    config := LoadJson(TPath.GetFullPath('.'+TPath.AltDirectorySeparatorChar+'config.json'));

    if config.A['Actions'].Length = 0 then Exit(-2);

    currentid := 0;
    Form1.setGUI;

  except
    Exit(-1);
  end;

  Exit(0);
end;

//--------------------------------------

procedure TForm1.setGUI();
begin
  if currentid=config.A['Actions'].Length then
    begin
      Panel1.Visible := False;
      Button_p.Enabled := False;
      Button_n.Enabled := False;
      Exit;
    end;


  Button_p.Enabled := not(currentid=0);
  Button_n.Enabled := not(currentid=config.A['Actions'].Length-1);
  Text1.Text := Format('%d out of %d',[currentid+1,config.A['Actions'].Length]);
  Text5.Text := config.A['Actions'].O[currentid].S['hit'];

  if config.A['Actions'].O[currentid].S['type']='play' then
    Text2.Text := 'Current Action: Play ' + TPath.GetFileName(config.A['Actions'].O[currentid].S['file']);

  if config.A['Actions'].O[currentid].S['type']='stop' then
    Text2.Text := 'Current Action: Stop';

  if config.A['Actions'].O[currentid].S['type']='changevolume' then
    Text2.Text := 'Current Action: Change Volume ' + FloatToStr(config.A['Actions'].O[currentid].F['volume']);

end;

procedure TForm1.Button_backClick(Sender: TObject);
begin
  currentid := currentid-1;
  setGUI;
  Panel1.Visible := True;
end;

procedure TForm1.Button_nClick(Sender: TObject);
begin
  currentid := currentid+1;
  setGUI;
end;

procedure TForm1.Button_pClick(Sender: TObject);
begin
  currentid := currentid-1;
  setGUI;
end;

procedure TForm1.Button_playClick(Sender: TObject);
var player:integer;
begin
  player := config.A['Actions'].O[currentid].I['player'];

  if config.A['Actions'].O[currentid].S['type']='stop' then
    begin
      MediaPlayer[player].Stop;
    end;

  if config.A['Actions'].O[currentid].S['type']='changevolume' then
    begin
      MediaPlayer[player].Volume := config.A['Actions'].O[currentid].F['volume'];
    end;

  if config.A['Actions'].O[currentid].S['type']='play' then
    begin
      MediaPlayer[player].Stop;
      MediaPlayer[player].FileName := config.A['Actions'].O[currentid].S['file'];
      MediaPlayer[player].Volume := config.A['Actions'].O[currentid].F['volume'];
      MediaPlayer[player].Play;
    end;

  currentid := currentid+1;
  setGUI;
end;

procedure TForm1.FormShow(Sender: TObject);
var r,i:integer;
begin
  r := LoadConfig;
  if r<>0 then
    begin
      if r=-1 then ShowMessage('Can not load configuration.');
      if r=-2 then ShowMessage('There is no action in the configuration.');
      Self.Close;
    end;

  for i := 1 to 4 do
    MediaPlayer[i] := TMediaPlayer.Create(nil);

end;

end.
