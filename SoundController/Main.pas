unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls;

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
    procedure FormShow(Sender: TObject);
    procedure Button_pClick(Sender: TObject);
    procedure Button_nClick(Sender: TObject);
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
    config := LoadJson(TPath.GetFullPath('.\config.json'));

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

procedure TForm1.FormShow(Sender: TObject);
var r:integer;
begin
  r := LoadConfig;
  if r<>0 then
    begin
      if r=-1 then ShowMessage('Can not load configuration.');
      if r=-2 then ShowMessage('There is no action in the configuration.');
      Self.Close;
    end;

end;

end.
