{*******************************************************************************
  ����: dmzn@163.com 2012-4-21
  ����: Զ�̴�ӡ�������
*******************************************************************************}
unit UFormMain;

{.$DEFINE DEBUG}
interface
{$I Link.inc}
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  IdContext, IdBaseComponent, IdComponent, IdCustomTCPServer, IdTCPServer,
  IdGlobal, UMgrRemotePrint, SyncObjs, UTrayIcon, StdCtrls, ExtCtrls,
  ComCtrls;

type
  TfFormMain = class(TForm)
    GroupBox1: TGroupBox;
    MemoLog: TMemo;
    StatusBar1: TStatusBar;
    CheckSrv: TCheckBox;
    EditPort: TLabeledEdit;
    IdTCPServer1: TIdTCPServer;
    CheckAuto: TCheckBox;
    CheckLoged: TCheckBox;
    Timer1: TTimer;
    BtnConn: TButton;
    Timer2: TTimer;
    BtnTest: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
    procedure CheckSrvClick(Sender: TObject);
    procedure CheckLogedClick(Sender: TObject);
    procedure IdTCPServer1Execute(AContext: TIdContext);
    procedure BtnConnClick(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure BtnTestClick(Sender: TObject);
  private
    { Private declarations }
    FTrayIcon: TTrayIcon;
    {*״̬��ͼ��*}
    FBillList: TStrings;
    FSyncLock: TCriticalSection;
    //ͬ����
    procedure ShowLog(const nStr: string);
    //��ʾ��־
    procedure DoExecute(const nContext: TIdContext);
    //ִ�ж���
    procedure PrintBill(var nBase: TRPDataBase;var nBuf: TIdBytes;nCtx: TIdContext);
    //��ӡ����
  public
    { Public declarations }
  end;

  function IsBrick(const nStockno:string):Boolean;
var
  fFormMain: TfFormMain;

implementation

{$R *.dfm}
uses
  IniFiles, Registry, ULibFun, UDataModule, UDataReport, USysLoger, UFormConn,
  DB, USysDB;

var
  gPath: string;               //����·��
  gIfHY: string;               //�Ƿ��ӡ���鵥
  gHYplan :string;             //���鵥��

resourcestring
  sHint               = '��ʾ';
  sConfig             = 'Config.Ini';
  sForm               = 'FormInfo.Ini';
  sDB                 = 'DBConn.Ini';
  sAutoStartKey       = 'RemotePrinter';

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TfFormMain, '��ӡ��������Ԫ', nEvent);
end;

//------------------------------------------------------------------------------
procedure TfFormMain.FormCreate(Sender: TObject);
var nIni: TIniFile;
    nReg: TRegistry;
    nTest: Boolean;
begin
  gPath := ExtractFilePath(Application.ExeName);
  InitGlobalVariant(gPath, gPath+sConfig, gPath+sForm, gPath+sDB);
  
  gSysLoger := TSysLoger.Create(gPath + 'Logs\');
  gSysLoger.LogEvent := ShowLog;

  FTrayIcon := TTrayIcon.Create(Self);
  FTrayIcon.Hint := Caption;
  FTrayIcon.Visible := True;
  
  FBillList := TStringList.Create;
  FSyncLock := TCriticalSection.Create;
  //new item

  nIni := nil;
  nReg := nil;
  try
    nIni := TIniFile.Create(gPath + 'Config.ini');
    EditPort.Text := nIni.ReadString('Config', 'Port', '8000');
    Timer1.Enabled := nIni.ReadBool('Config', 'Enabled', False);
    nTest:= nIni.ReadBool('Config', 'TestBtn', False);
    BtnTest.Enabled:=nTest;
    BtnTest.Visible:=nTest;

    nReg := TRegistry.Create;
    nReg.RootKey := HKEY_CURRENT_USER;

    nReg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', True);
    CheckAuto.Checked := nReg.ValueExists(sAutoStartKey);
  finally
    nIni.Free;
    nReg.Free;
  end;

  FDM.ADOConn.Close;
  FDM.ADOConn.ConnectionString := BuildConnectDBStr;
  //���ݿ�����
end;

procedure TfFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
var nIni: TIniFile;
    nReg: TRegistry;
begin
  nIni := nil;
  nReg := nil;
  try
    nIni := TIniFile.Create(gPath + 'Config.ini');
    //nIni.WriteString('Config', 'Port', EditPort.Text);
    nIni.WriteBool('Config', 'Enabled', CheckSrv.Enabled);

    nReg := TRegistry.Create;
    nReg.RootKey := HKEY_CURRENT_USER;

    nReg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', True);
    if CheckAuto.Checked then
      nReg.WriteString(sAutoStartKey, Application.ExeName)
    else if nReg.ValueExists(sAutoStartKey) then
      nReg.DeleteValue(sAutoStartKey);
    //xxxxx
  finally
    nIni.Free;
    nReg.Free;
  end;

  FBillList.Free;
  FSyncLock.Free;
  //lock
end;

procedure TfFormMain.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  CheckSrv.Checked := True;
end;

procedure TfFormMain.CheckSrvClick(Sender: TObject);
begin
  if not IdTCPServer1.Active then
    IdTCPServer1.DefaultPort := StrToInt(EditPort.Text);
  IdTCPServer1.Active := CheckSrv.Checked;

  BtnConn.Enabled := not CheckSrv.Checked;
  EditPort.Enabled := not CheckSrv.Checked;

  FSyncLock.Enter;
  try
    FBillList.Clear;
    Timer2.Enabled := CheckSrv.Checked;
  finally
    FSyncLock.Leave;
  end;
end;

procedure TfFormMain.CheckLogedClick(Sender: TObject);
begin
  gSysLoger.LogSync := CheckLoged.Checked;
end;

procedure TfFormMain.ShowLog(const nStr: string);
var nIdx: Integer;
begin
  MemoLog.Lines.BeginUpdate;
  try
    MemoLog.Lines.Insert(0, nStr);
    if MemoLog.Lines.Count > 100 then
     for nIdx:=MemoLog.Lines.Count - 1 downto 50 do
      MemoLog.Lines.Delete(nIdx);
  finally
    MemoLog.Lines.EndUpdate;
  end;
end;

//Desc: ����nConnStr�Ƿ���Ч
function ConnCallBack(const nConnStr: string): Boolean;
begin
  FDM.ADOConn.Close;
  FDM.ADOConn.ConnectionString := nConnStr;
  FDM.ADOConn.Open;
  Result := FDM.ADOConn.Connected;
end;

//Desc: ���ݿ�����
procedure TfFormMain.BtnConnClick(Sender: TObject);
begin
  if ShowConnectDBSetupForm(ConnCallBack) then
  begin
    FDM.ADOConn.Close;
    FDM.ADOConn.ConnectionString := BuildConnectDBStr;
    //���ݿ�����
  end;
end;

//------------------------------------------------------------------------------
procedure TfFormMain.IdTCPServer1Execute(AContext: TIdContext);
begin
  try
    DoExecute(AContext);
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
      AContext.Connection.Socket.InputBuffer.Clear;
    end;
  end;
end;

procedure TfFormMain.DoExecute(const nContext: TIdContext);
var nBuf: TIdBytes;
    nBase: TRPDataBase;
begin
  with nContext.Connection do
  begin
    Socket.ReadBytes(nBuf, cSizeRPBase, False);
    BytesToRaw(nBuf, nBase, cSizeRPBase);

    case nBase.FCommand of
     cRPCmd_PrintBill :
      begin
        PrintBill(nBase, nBuf, nContext);
        //print
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2016-10-28
//Parm: ��������;��ʾ;���ݶ���;��ӡ��
//Desc: ��ӡnBill��������
function PrintBill4(const nBill: string; var nHint: string;
 const nPrinter: string = ''): Boolean;
var nStr,nIfFenChe: string;
    nDS: TDataSet;
begin
  Result := False;
  try
    nStr := 'Select *,substring(L_ID,3,LEN(L_ID)-2) as L_CID From %s b Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, nBill]);

    nDS := FDM.SQLQuery(nStr, FDM.SQLQuery1);
    if not Assigned(nDS) then Exit;

    if nDS.RecordCount < 1 then
    begin
      nHint := '������[ %s ] ����Ч!!';
      nHint := Format(nHint, [nBill]);
      Exit;
    end;

    nStr := gPath + 'Report\LadingBill4.fr3';
    if not FDR.LoadReportFile(nStr) then
    begin
      nHint := '�޷���ȷ���ر����ļ�';
      Exit;
    end;

    if nPrinter = '' then
         FDR.Report1.PrintOptions.Printer := 'My_Default_Printer'
    else FDR.Report1.PrintOptions.Printer := nPrinter;

    FDR.Dataset1.DataSet := FDM.SQLQuery1;
    FDR.PrintReport;
    Result := FDR.PrintSuccess;
    if Result then
    begin
      nStr := 'update %s set L_BDPrint=L_BDPrint+1 Where L_ID=''%s''';
      nStr := Format(nStr, [sTable_Bill, nBill]);
      with FDM.SQLTemp do
      begin
        Close;
        SQL.Text:=nStr;
        ExecSQL;
      end;
    end;
  except
    on e:Exception do
    begin
      WriteLog('PrintBill4: '+e.Message);
    end;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2016-10-28
//Parm: ��������;��ʾ;���ݶ���;��ӡ��
//Desc: ��ӡnBill��������
function PrintBill6(const nBill: string; var nHint: string;
 const nPrinter: string = ''): Boolean;
var nStr,nIfFenChe: string;
    nDS: TDataSet;
begin
  Result := False;
  try
    nStr := 'Select *,substring(L_ID,3,LEN(L_ID)-2) as L_CID From %s b Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, nBill]);

    nDS := FDM.SQLQuery(nStr, FDM.SQLQuery1);
    if not Assigned(nDS) then Exit;

    if nDS.RecordCount < 1 then
    begin
      nHint := '������[ %s ] ����Ч!!';
      nHint := Format(nHint, [nBill]);
      Exit;
    end;

    nStr := gPath + 'Report\LadingBill6.fr3';
    if not FDR.LoadReportFile(nStr) then
    begin
      nHint := '�޷���ȷ���ر����ļ�';
      Exit;
    end;

    if nPrinter = '' then
         FDR.Report1.PrintOptions.Printer := 'My_Default_Printer'
    else FDR.Report1.PrintOptions.Printer := nPrinter;

    FDR.Dataset1.DataSet := FDM.SQLQuery1;
    FDR.PrintReport;
    Result := FDR.PrintSuccess;
    if Result then
    begin
      nStr := 'update %s set L_BDPrint=L_BDPrint+1 Where L_ID=''%s''';
      nStr := Format(nStr, [sTable_Bill, nBill]);
      with FDM.SQLTemp do
      begin
        Close;
        SQL.Text:=nStr;
        ExecSQL;
      end;
    end;
  except
    on e:Exception do
    begin
      WriteLog('PrintBill6: '+e.Message);
    end;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2012-4-1
//Parm: ��������;��ʾ;���ݶ���;��ӡ��
//Desc: ��ӡnBill��������
function PrintBillReport(const nBill: string; var nHint: string;
 const nPrinter: string = ''; const nMoney: string = '0'): Boolean;
var nStr,nIfFenChe: string;
    nDS: TDataSet;
    nP4OK,nP6OK:Boolean;
    nStockno:string;
begin
  Result := False;
  try
    nStr := 'Select *,%s As L_ValidMoney From %s b Where L_ID=''%s''';
    nStr := Format(nStr, [nMoney, sTable_Bill, nBill]);

    nDS := FDM.SQLQuery(nStr, FDM.SQLQuery1);
    if not Assigned(nDS) then Exit;

    if nDS.RecordCount < 1 then
    begin
      nHint := '������[ %s ] ����Ч!!';
      nHint := Format(nHint, [nBill]);
      Exit;
    end;
    nIfFenChe:= nDS.FieldByName('L_IfFenChe').AsString;
    nStockno := nDS.FieldByName('L_stockno').AsString;
    //gIfHY:= nDS.Fieldbyname('L_IfHYPrint').AsString;
    if nIfFenChe='Y' then
    begin
      nP4OK:=PrintBill4(nBill,nHint,nPrinter);
      Sleep(200);
      nP6OK:=PrintBill6(nBill,nHint,nPrinter);
      Result:=True;
    end else
    begin
      nStr := gPath + 'Report\LadingBill.fr3';
      if isbrick(nStockno) then
      begin
        nStr := gPath + 'Report\LadingBill_brick.fr3';
      end;
      if not FDR.LoadReportFile(nStr) then
      begin
        nHint := '�޷���ȷ���ر����ļ�';
        Exit;
      end;

      if nPrinter = '' then
           FDR.Report1.PrintOptions.Printer := 'My_Default_Printer'
      else FDR.Report1.PrintOptions.Printer := nPrinter;

      FDR.Dataset1.DataSet := FDM.SQLQuery1;
      FDR.PrintReport;
      Result := FDR.PrintSuccess;
      if Result then
      begin
        nStr := 'update %s set L_BDPrint=L_BDPrint+1 Where L_ID=''%s''';
        nStr := Format(nStr, [sTable_Bill, nBill]);
        with FDM.SQLTemp do
        begin
          Close;
          SQL.Text:=nStr;
          ExecSQL;
        end;
      end;
    end;
  except
    on e:Exception do
    begin
      WriteLog('PrintBillReport: '+e.Message);
    end;
  end;
end;

//Date: 2012-4-1
//Parm: �ɹ�����;��ʾ;���ݶ���;��ӡ��
//Desc: ��ӡnOrder�ɹ�����
function PrintOrderReport(const nOrder: string; var nHint: string;
 const nPrinter: string = ''; const nMoney: string = '0'): Boolean;
var nStr: string;
    nDS: TDataSet;
    nPath:string;
begin
  WriteLog('PrintOrderReport(nOrder='+nOrder+',nHint='+nHint+',nPrinter='+nPrinter+')');
  Result := False;
  nPath := '';
  try
    nStr := 'Select * From %s oo Inner Join %s od on oo.O_ID=od.D_OID Where D_ID=''%s''';
    nStr := Format(nStr, [sTable_Order, sTable_OrderDtl, nOrder]);

    WriteLog('sql=['+nStr+']');
    nDS := FDM.SQLQuery(nStr, FDM.SQLQuery1);
    if not Assigned(nDS) then Exit;

    if nDS.RecordCount>0 then
    begin
      nPath := gPath + 'Report\PurchaseOrder.fr3';
    end
    else begin
      nStr := 'Select * From %s oo where R_id=''%s''';
      nStr := Format(nStr, [sTable_CardOther, nOrder]);
      WriteLog('sql=['+nStr+']');
      nDS := FDM.SQLQuery(nStr, FDM.SQLQuery1);
      if not Assigned(nDS) then Exit;
      if nDS.RecordCount>0 then
      begin
        nPath := gPath + 'Report\TempOrder.fr3';
      end;    
    end;

    if nPath='' then
    begin
      nHint := '�ɹ�������ʱ��[ %s ] ����Ч!!';
      nHint := Format(nHint, [nOrder]);
      Exit;
    end;

    if not FDR.LoadReportFile(nPath) then
    begin
      nHint := '�޷���ȷ���ر����ļ�[nPath]';
      Exit;
    end;

    if nPrinter = '' then
         FDR.Report1.PrintOptions.Printer := 'My_Default_Printer'
    else FDR.Report1.PrintOptions.Printer := nPrinter;

    FDR.Dataset1.DataSet := FDM.SQLQuery1;
    WriteLog('before FDR.PrintReport');
    FDR.PrintReport;
    Result := FDR.PrintSuccess;
  except
    on e:Exception do
    begin
      WriteLog('PrintOrderReport: '+e.Message);
    end;
  end;
end;

//Date: 2012-4-1
//Parm: ��������;��ʾ;���ݶ���;��ӡ��
//Desc: ��ӡnBill��������
function PrintHYReport(const nBill: string; var nHint: string;
 const nHYPrinter: string = ''): Boolean;
var nStr: string;
    nDS: TDataSet;
    npath:string;
    nIsHongda:Boolean;
begin
  Result := False;
  nIsHongda := False;
  npath := '';
  try
    nStr := 'select a.*,b.*,c.* from %s a,%s b,%s c '+
            'where a.P_ID=b.R_PID and b.R_SerialNo=c.L_HYDan and c.L_ID= ''%s'' ';
    nStr := Format(nStr,[sTable_StockParam, sTable_StockRecord, sTable_Bill, nBill]);

    nDS := FDM.SQLQuery(nStr, FDM.SQLQuery2);
    if not Assigned(nDS) then Exit;
    if nDS.RecordCount>0 then
    begin
      {$IFDEF QHSN}
      {$IFDEF GGJC}
        nIsHongda := True;
      {$ENDIF}
      {$ENDIF}
      if nIsHongda then
      begin
        npath := gPath + 'Report\HuanYan3HeGe.fr3';
      end
      else begin
        if Pos('����',nDS.FieldByName('L_StockName').AsString)>0 then
          npath := gPath + 'Report\HuanYan3ShuLiao.fr3'
        else
          npath := gPath + 'Report\HuanYan3HeGe.fr3';
      end;
    end
    else begin
      nStr := 'select a.*,b.*,c.* from %s a,%s b,%s c '+
              'where a.P_ID=b.R_PID and b.R_SerialNo=c.L_HYDan and c.L_ID= ''%s'' ';
      nStr := Format(nStr,[sTable_StockParam, sTable_StockRecord_Slag, sTable_Bill, nBill]);
      nDS := FDM.SQLQuery(nStr, FDM.SQLQuery2);
      if not Assigned(nDS) then Exit;
      if nDS.RecordCount>0 then
      begin
        npath := gPath + 'Report\HuanYan3HeGe_slag.fr3';
      end
      else begin
        nStr := 'select a.*,b.*,c.* from %s a,%s b,%s c '+
                'where a.P_ID=b.R_PID and b.R_SerialNo=c.L_HYDan and c.L_ID= ''%s'' ';
        nStr := Format(nStr,[sTable_StockParam, sTable_StockRecord_Concrete, sTable_Bill, nBill]);
        nDS := FDM.SQLQuery(nStr, FDM.SQLQuery2);
        if not Assigned(nDS) then Exit;
        if nDS.RecordCount>0 then
        begin
          npath := gPath + 'Report\HuanYan3HeGe_Concrete.fr3';
        end
        else begin
          nStr := 'select a.*,b.*,c.* from %s a,%s b,%s c '+
                  'where a.P_ID=b.R_PID and b.R_SerialNo=c.L_HYDan and c.L_ID= ''%s'' ';
          nStr := Format(nStr,[sTable_StockParam, sTable_StockRecord_clinker, sTable_Bill, nBill]);
          nDS := FDM.SQLQuery(nStr, FDM.SQLQuery2);
          if not Assigned(nDS) then Exit;
          if nds.RecordCount>0 then
          begin
            npath := gPath + 'Report\HuanYan3ShuLiao.fr3'
          end
          else begin
            nHint := '���鵥[ %s ] ����Ч!!';
            nHint := Format(nHint, [nBill]);
            Exit;
          end;
        end;
      end;
    end;
    if nDS.Fieldbyname('L_IfHYPrint').AsString <> 'Y' then Exit;

    if (nDS.FieldByName('P_ID').AsString = '') or
      (nDS.FieldByName('P_ID').IsNull) then
    begin
      nHint := 'Ʒ��ID���󣬲��ܴ�ӡ��';
      Exit;
    end;

    if (nDS.FieldByName('L_HYDan').AsString = '') or
      (nDS.FieldByName('L_HYDan').IsNull) then
    begin
      nHint := 'ʽ�����Ϊ�գ����ܴ�ӡ��';
      Exit;
    end;

    if not FDR.LoadReportFile(npath) then
    begin
      nHint := '�޷���ȷ���ر����ļ�['+npath+']';
      Exit;
    end;

    if nHYPrinter = '' then
         FDR.Report1.PrintOptions.Printer := 'My_Default_Printer'
    else FDR.Report1.PrintOptions.Printer := nHYPrinter;

    FDR.Dataset1.DataSet := FDM.SQLQuery2;
    FDR.PrintReport;
    Result := FDR.PrintSuccess;
    if Result then
    begin
      nStr := 'update %s set L_HYPrint=L_HYPrint+1 Where L_ID=''%s''';
      nStr := Format(nStr, [sTable_Bill, nBill]);
      with FDM.SQLTemp do
      begin
        Close;
        SQL.Text:=nStr;
        ExecSQL;
      end;
    end;
  except
    on e:Exception do
    begin
      WriteLog('PrintHYReport: '+e.Message);
    end;
  end;
end;

//Desc: ��ӡ����
procedure TfFormMain.PrintBill(var nBase: TRPDataBase; var nBuf: TIdBytes;
  nCtx: TIdContext);
var nStr: WideString;
begin
  nCtx.Connection.Socket.ReadBytes(nBuf, nBase.FDataLen, False);
  nStr := Trim(BytesToString(nBuf));

  FSyncLock.Enter;
  try
    FBillList.Add(nStr);
  finally
    FSyncLock.Leave;
  end;

  WriteLog(Format('��Ӵ�ӡ������: %s', [nStr]));
  //loged
end;

procedure TfFormMain.Timer2Timer(Sender: TObject);
var nPos: Integer;
    nBill,nHint,nPrinter,nMoney, nType: string;
    nHyprinter: string;
    nPrintOK:Boolean;
begin
  Timer2.Enabled:=False;
  try
    FSyncLock.Enter;
    gIfHY:='N';
    gHYplan:='';
    try
      if FBillList.Count < 1 then Exit;
      nBill := FBillList[0];
      FBillList.Delete(0);
    finally
      FSyncLock.Leave;
    end;

    //bill #9 printer #8 money #7 CardType #11 Hyprinter
    nPos := Pos(#7, nBill);
    if nPos > 1 then
    begin
      nType := nBill;
      nBill := Copy(nBill, 1, nPos - 1);
      System.Delete(nType, 1, nPos);
    end else nType := '';

    nPos := Pos(#8, nBill);
    if nPos > 1 then
    begin
      nMoney := nBill;
      nBill := Copy(nBill, 1, nPos - 1);
      System.Delete(nMoney, 1, nPos);

      if not IsNumber(nMoney, True) then
        nMoney := '0';
      //xxxxx
    end else nMoney := '0';

    nPos := Pos(#9, nBill);
    if nPos > 1 then
    begin
      nPrinter := nBill;
      nBill := Copy(nBill, 1, nPos - 1);
      System.Delete(nPrinter, 1, nPos);
    end else nPrinter := '';

    nPos := Pos(#11, nBill);
    if nPos > 1 then
    begin
      nHyprinter := nBill;
      nBill := Copy(nBill, 1, nPos - 1);
      System.Delete(nHyprinter, 1, nPos);
    end else nHyprinter := '';

    WriteLog('��ʼ��ӡ: ' + nBill);
    if (nType = 'P') or (nType = 'O') then
      PrintOrderReport(nBill, nHint, nPrinter)
    else begin
      nPrintOK:=PrintBillReport(nBill, nHint, nPrinter, nMoney);
      if (nPrintOK=True) then PrintHYReport(nBill,nHint,nHyprinter);
    end;
    WriteLog('��ӡ����.' + nHint);
  finally
    Timer2.Enabled:=True;
  end;
end;

procedure TfFormMain.BtnTestClick(Sender: TObject);
var
  nStr:string;
  myini:TIniFile;
begin
  FSyncLock.Enter;
  myini := TIniFile.Create(gPath + 'Config.ini');
  try
    nStr:=myini.ReadString('Test','Data','');
    if nStr<>'' then
      FBillList.Add(nStr);
  finally
    myini.Free;
    FSyncLock.Leave;
  end;

  WriteLog(Format('��Ӳ��Դ�ӡ������: %s', [nStr]));
end;

function IsBrick(const nStockno: string): Boolean;
var nStr: string;
begin
  nStr := 'select * from %s where d_name=''%s'' and d_desc=''%s''';
  nStr := Format(nStr,[sTable_SysDict,sFlag_BrickItem,nStockno]);
  Result := FDM.SQLQuery(nStr,fdm.SQLTemp).RecordCount>0;
end;

end.
