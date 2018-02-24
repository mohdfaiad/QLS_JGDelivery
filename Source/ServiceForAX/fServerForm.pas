unit fServerForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls,
  uROClient, uROPoweredByRemObjectsButton, uROClientIntf, uROServer,
  uROSOAPMessage, uROIndyHTTPServer, uROIndyTCPServer, IniFiles, USysLoger,
  ExtCtrls, AppEvnts, ComObj, ShellAPI;

type
  TServerForm = class(TForm)
    ROMessage: TROSOAPMessage;
    ROServer: TROIndyHTTPServer;
    lblport: TLabel;
    mmo1: TMemo;
    chkShowLog: TCheckBox;
    ChkModel: TCheckBox;
    ApplicationEvents1: TApplicationEvents;
    BtnConn: TButton;
    tmrRestart: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ChkModelClick(Sender: TObject);
    procedure ApplicationEvents1Exception(Sender: TObject; E: Exception);
    procedure tmrRestartTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    gTime:string;
  end;

var
  ServerForm: TServerForm;

implementation
uses
  USysBusiness, uDM, UMITConst, UMgrParam, UMgrDBConn;

{$R *.dfm}
procedure WriteLog(const nEvent: string);
begin
  with ServerForm do
  begin
    if chkShowLog.Checked then
    begin
      if mmo1.Lines.Count > 50 then mmo1.Lines.Clear;
      mmo1.Lines.Add('['+FormatDateTime('yyyy-mm-dd hh:mm:ss',Now)+']'+nEvent);
    end;
  end;
  gSysLoger.AddLog(TServerForm, 'WebService', nEvent);
end;

//������ݿ����
procedure FillAllDBParam;
var nIdx: Integer;
    nList: TStrings;
begin
  nList := TStringList.Create;
  try
    gParamManager.LoadParam(nList, ptDB);
    for nIdx:=0 to nList.Count - 1 do
      gDBConnManager.AddParam(gParamManager.GetDB(nList[nIdx])^);
    //xxxxx
  finally
    nList.Free;
  end;
end;

procedure TServerForm.FormCreate(Sender: TObject);
var
  myini:TIniFile;
  nPort:Integer;
begin
  myini:=TIniFile.Create('.\SetParam.ini');
  try
    nPort:=myini.ReadInteger('Param','Port',8099);
    gTime:=myini.ReadString('Param','Time','23:59');
  finally
    myini.Free;
  end;
  ROServer.Port:= nPort;
  ROServer.Active := true;
  lblport.Caption:='���ж˿ڣ�'+inttostr(nPort);
  chkShowLog.Checked := True;
  if not Assigned(gSysLoger) then
    gSysLoger := TSysLoger.Create('.\Logs\');
  WriteLog('ϵͳ����');
  if GetOnLineModel then ChkModel.Checked:=True else ChkModel.Checked:=False;
  {tmrRestart.Interval := 60*1000;
  tmrRestart.Enabled := True;  }

  {gParamManager := TParamManager.Create(gPath + 'Parameters.xml');
  gDBConnManager := TDBConnManager.Create;
  FillAllDBParam;
  with gParamManager do
  begin
    gDBConnManager.DefaultConnection := ActiveParam.FDB.FID;
    gDBConnManager.MaxConn := ActiveParam.FDB.FNumWorker;
  end;}
end;

procedure TServerForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(gSysLoger);
end;

procedure TServerForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //gDBConnManager.Disconnection();
  Application.Terminate;
end;


procedure TServerForm.ChkModelClick(Sender: TObject);
begin
  if ChkModel.Checked then
    SetOnLineModel(True)
  else
    SetOnLineModel(False);
end;

procedure TServerForm.ApplicationEvents1Exception(Sender: TObject;
  E: Exception);
var
  I: integer;
begin
  //��ִ���������������������ǿ�Ʋ������ݿ����ӶϿ�������Դ��������쳣��
  //net stop MsSqlServer
  //net start MsSqlServer
  if (E is EOleException) and ((E as EOleException).ErrorCode= -2147467259) then
  begin
    with DM do
    begin
      ADOCRem.Connected := False;
      try
        ADOCRem.Connected := True;
      except
        On E2: Exception do
        begin
          WriteLog('����Զ�����ݿⷢ������'#13 + E2.Message);
        end;
      end;
    end;

    with DM do
    begin
      ADOCLoc.Connected := False;
      try
        ADOCLoc.Connected := True;
      except
        On E2: Exception do
        begin
          WriteLog('�����������ݿⷢ������'#13 + E2.Message);
        end;
      end;
    end;
  end;
end;

procedure TServerForm.tmrRestartTimer(Sender: TObject);
begin
  if FormatDateTime('hh:mm',Now)=gTime then
    ShellExecute(Self.Handle, 'open', PChar(Application.ExeName), nil, nil, SW_SHOWNORMAL);
end;

end.
