{*******************************************************************************
  ����: dmzn@163.com 2012-5-3
  ����: �û�������ѯ
*******************************************************************************}
{$I Link.Inc}
unit UFormMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxContainer, cxEdit, cxLabel, ExtCtrls, CPort, StdCtrls, Buttons,Uszttce_api,
  UHotKeyManager,uReadCardThread, USysBusiness;

type
  TCardType = (ctTTCE,ctRFID);

  TfFormMain = class(TForm)
    LabelStock: TcxLabel;
    LabelQueue: TcxLabel;
    LabelHint: TcxLabel;
    ComPort1: TComPort;
    TimerReadCard: TTimer;
    Panel1: TPanel;
    LabelTruck: TcxLabel;
    LabelDec: TcxLabel;
    LabelTon: TcxLabel;
    LabelBill: TcxLabel;
    LabelOrder: TcxLabel;
    TimerInsertCard: TTimer;
    imgPrint: TImage;
    PanelBottom: TPanel;
    PanelBCenter: TPanel;
    PanelBRight: TPanel;
    PanelBLeft: TPanel;
    imgCard: TImage;
    Image3: TImage;
    imgPurchaseCard: TImage;
    LabelCus: TcxLabel;
    LabelCenterID: TcxLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ComPort1RxChar(Sender: TObject; Count: Integer);
    procedure TimerReadCardTimer(Sender: TObject);
    procedure LabelTruckDblClick(Sender: TObject);
    procedure TimerInsertCardTimer(Sender: TObject);
    procedure imgPrintClick(Sender: TObject);
    procedure imgCardClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
    FBuffer: string;
    //���ջ���
    FLastCard: string;
    FLastQuery: Int64;
    //�ϴβ�ѯ
    FTimeCounter: Integer;
    //��ʱ
    FSzttceApi:TSzttceApi;
    FDownLoadWay:Integer;
    //��������;��
    FLines: TZTLineItems;
    FTrucks: TZTTruckItems;
    //��������
    FHotKeyMgr: THotKeyManager;
    FHotKey: Cardinal;

    FHYDan,FStockName:string;
    FHyDanPrinterName,FDefaultPrinterName:string;
    FReadCardThread:TReadCardThread;
    procedure ActionComPort(const nStop: Boolean);
    //���ڴ���
    procedure DoHotKeyHotKeyPressed(HotKey: Cardinal; Index: Word);
    {*�ȼ�����*}
  public
    { Public declarations }
    FCursorShow:Boolean;
    FCardType:TCardType;
    procedure QueryCard(const nCard: string);
    //��ѯ����Ϣ
  end;

var
  fFormMain: TfFormMain;

implementation

{$R *.dfm}

uses
  IniFiles, ULibFun, CPortTypes, USysLoger, USysDB, USmallFunc, UDataModule,
  UFormConn,USysConst,UClientWorker,UMITPacker,USysModule, uNewCard,
  UDataReport,UFormInputbox, UCardTypeSelect,UFormBarcodePrint, uZXNewPurchaseCard,
  UFormBase, uNewCardQls, UFormHYPrint;

type
  TReaderType = (ptT800, pt8142);
  //��ͷ����

  TReaderItem = record
    FType: TReaderType;
    FPort: string;
    FBaud: string;
    FDataBit: Integer;
    FStopBit: Integer;
    FCheckMode: Integer;
  end;

var
  gPath: string;
  gReaderItem: TReaderItem;
  //ȫ��ʹ��

resourcestring
  sHint       = '��ʾ';
  sConfig     = 'Config.Ini';
  sForm       = 'FormInfo.Ini';
  sDB         = 'DBConn.Ini';

//------------------------------------------------------------------------------
//Desc: ��¼��־
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TfFormMain, '����������', nEvent);
end;

//Desc: ����nConnStr�Ƿ���Ч
function ConnCallBack(const nConnStr: string): Boolean;
begin
  FDM.ADOConn.Close;
  FDM.ADOConn.ConnectionString := nConnStr;
  FDM.ADOConn.Open;
  Result := FDM.ADOConn.Connected;
end;

procedure TfFormMain.FormCreate(Sender: TObject);
var
  nStr:string;
begin
  gPath := ExtractFilePath(Application.ExeName);
  InitGlobalVariant(gPath, gPath+sConfig, gPath+sForm, gPath+sDB);

  gSysLoger := TSysLoger.Create(gPath + 'Logs\');
  gSysLoger.LogSync := False;
  ShowConnectDBSetupForm(ConnCallBack);
//  ShowCursor(False);

  FDM.ADOConn.Close;
  FDM.ADOConn.ConnectionString := BuildConnectDBStr;
  //���ݿ�����

  RunSystemObject;

  if Pos('����ɽ',gSysParam.FMainTitle) > 0 then
    FDownLoadWay := 0
  else
    FDownLoadWay := 1;
  FLastQuery := 0;
  FLastCard := '';
  FTimeCounter := 0;
  try
    ActionComPort(False);
    //������ͷ
  except
  end;
  FSzttceApi := TSzttceApi.Create;
  if FSzttceApi.ErrorCode<>0 then
  begin
    nStr := '��ʼ������������ʧ�ܣ�[ErrorCode=%d,ErrorMsg=%s]';
    nStr := Format(nStr,[FSzttceApi.ErrorCode,FSzttceApi.ErrorMsg]);
    ShowMsg(nStr,sHint);
  end;
  FSzttceApi.ParentWnd := Self.Handle;
  TimerInsertcard.Enabled := True;

  FHotKeyMgr := THotKeyManager.Create(Self);
  FHotKeyMgr.OnHotKeyPressed := DoHotKeyHotKeyPressed;

  FHotKey := TextToHotKey('Ctrl + Alt + D', False);
  FHotKeyMgr.AddHotKey(FHotKey);
  FCursorShow := False;
  if not Assigned(FDR) then
  begin
    FDR := TFDR.Create(Application);
  end;
  {$IFDEF PLKP}
    imgPrint.Visible := True;
  {$ELSE}
    imgPrint.Visible := False;
  {$ENDIF}
  imgCard.Visible := gSysParam.FCanCreateCard;
  imgPurchaseCard.Visible := not gSysParam.FCanCreateCard;
end;

procedure TfFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  try
    ActionComPort(True);
  except
  end;
  FSzttceApi.Free;
  FHotKeyMgr.Free;
end;

procedure TfFormMain.LabelTruckDblClick(Sender: TObject);
var
  nStr: string;
begin
  ShowCursor(True);
  if ShowInputPWDBox('�������˳�����:', '�û�������ѯϵͳ', nStr) and (nStr = '6934') then
  begin
    Close;
  end
  else ShowCursor(False);
end;

//Desc: ���ڲ���
procedure TfFormMain.ActionComPort(const nStop: Boolean);
var nInt: Integer;
    nIni: TIniFile;
begin
  if nStop then
  begin
    ComPort1.Close;
    Exit;
  end;

  with ComPort1 do
  begin
    with Timeouts do
    begin
      ReadTotalConstant := 100;
      ReadTotalMultiplier := 10;
    end;

    nIni := TIniFile.Create(gPath + 'Reader.Ini');
    with gReaderItem do
    try
      nInt := nIni.ReadInteger('Param', 'Type', 1);
      FType := TReaderType(nInt - 1);

      FPort := nIni.ReadString('Param', 'Port', '');
      FBaud := nIni.ReadString('Param', 'Rate', '4800');
      FDataBit := nIni.ReadInteger('Param', 'DataBit', 8);
      FStopBit := nIni.ReadInteger('Param', 'StopBit', 0);
      FCheckMode := nIni.ReadInteger('Param', 'CheckMode', 0);

      Port := FPort;
      BaudRate := StrToBaudRate(FBaud);

      case FDataBit of
       5: DataBits := dbFive;
       6: DataBits := dbSix;
       7: DataBits :=  dbSeven else DataBits := dbEight;
      end;

      case FStopBit of
       2: StopBits := sbTwoStopBits;
       15: StopBits := sbOne5StopBits
       else StopBits := sbOneStopBit;
      end;
    finally
      nIni.Free;
    end;

    ComPort1.Open;
  end;
end;

procedure TfFormMain.TimerReadCardTimer(Sender: TObject);
begin
  if FTimeCounter <= 0 then
  begin
    TimerReadCard.Enabled := False;
    FHYDan := '';
    FStockName := '';
    LabelDec.Caption := '';
//    imgPrint.Visible := False;

    LabelBill.Caption := '��������:';
    LabelTruck.Caption := '���ƺ���:';
    LabelOrder.Caption := '���۶���:';
    LabelStock.Caption := 'Ʒ������:';
    LabelQueue.Caption := '��������:';
    LabelTon.Caption := '�������:';
    LabelCenterID.Caption := '�� �� ��:';
    LabelCus.Caption := '�ͻ�����:';
    LabelHint.Caption := '����ˢ��';
    if FCardType=ctttce then FSzttceApi.ResetMachine;
    TimerInsertCard.Enabled := True;
  end else
  begin
    LabelDec.Caption := IntToStr(FTimeCounter) + ' ';
  end;

  Dec(FTimeCounter);
end;

procedure TfFormMain.ComPort1RxChar(Sender: TObject; Count: Integer);
var nStr: string;
    nIdx,nLen: Integer;
begin
  ComPort1.ReadStr(nStr, Count);
  FBuffer := FBuffer + nStr;

  nLen := Length(FBuffer);
  if nLen < 7 then Exit;

  for nIdx:=1 to nLen do
  begin
    if (FBuffer[nIdx] <> #$AA) or (nLen - nIdx < 6) then Continue;
    if (FBuffer[nIdx+1] <> #$FF) or (FBuffer[nIdx+2] <> #$00) then Continue;

    nStr := Copy(FBuffer, nIdx+3, 4);
    FBuffer := '';
    WriteLog('ComPort1RxChar:'+ParseCardNO(nStr, True));
    FCardType := ctRFID;
    QueryCard(ParseCardNO(nStr, True));
    Exit;
  end;
end;

//Date: 2012-5-3
//Parm: ����
//Desc: ��ѯnCard��Ϣ
procedure TfFormMain.QueryCard(const nCard: string);
var nVal: Double;
    nStr,nStock,nBill,nVip,nLine,nPoundQueue,nTruck: string;
    nDate: TDateTime;
    nIdx, nRID:Integer;
begin
//  mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
//  mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
  //close screen saver

  if (nCard = FLastCard) and (GetTickCount - FLastQuery < 8 * 1000) then
  begin
    TimerInsertCard.Enabled := True;
    LabelDec.Caption := '�벻ҪƵ������';
    Exit;
  end;

  try
    FTimeCounter := 10;
    TimerReadCard.Enabled := True;

    nStr := 'Select * From %s Where L_Card=''%s''';
    nStr := Format(nStr, [sTable_Bill, nCard]);

    with FDM.QuerySQL(nStr) do
    begin
      if RecordCount < 1 then
      begin
        FTimeCounter := 1;
        LabelDec.Caption := '�ſ�����Ч';
        Exit;
      end;

      nVal := 0;
      First;

      while not Eof do
      begin
        if FieldByName('L_Value').AsFloat > nVal then
        begin
          nBill := FieldByName('L_ID').AsString;
          nVal := FieldByName('L_Value').AsFloat;
        end;

        Next;
      end;

      First;
      while not Eof do
      begin
        if FieldByName('L_ID').AsString = nBill then
          Break;
        Next;
      end;

      nBill  := FieldByName('L_ID').AsString;
      nVip   := FieldByName('L_IsVip').AsString;
      nTruck := FieldByName('L_Truck').AsString;
      nStock := FieldByName('L_StockNo').AsString + FieldByName('L_Type').AsString;
      FHYDan := FieldByName('L_HYDan').AsString;
      FStockName := FieldByName('L_StockName').AsString;

      LabelBill.Caption := '��������: ' + FieldByName('L_ID').AsString;
      LabelOrder.Caption := '���۶���: ' + FieldByName('L_ZhiKa').AsString;
      LabelTruck.Caption := '���ƺ���: ' + FieldByName('L_Truck').AsString;
      LabelStock.Caption := 'Ʒ������: ' + FieldByName('L_StockName').AsString;
      LabelTon.Caption := '�������: ' + FieldByName('L_Value').AsString + '��';
      LabelCus.Caption := '�ͻ�����: ' + FieldByName('L_CusName').AsString;
      LabelCenterID.Caption := '�� �� ��: ' + FieldByName('L_InvCenterId').AsString;
//      imgPrint.Visible := True;
    end;

    //--------------------------------------------------------------------------
//    nStr := 'Select Count(*) From %s ' +
//            'Where Z_StockNo=''%s'' And Z_Valid=''%s'' And Z_VipLine=''%s''';
//    nStr := Format(nStr, [sTable_ZTLines, nStock, sFlag_Yes,nVip]);
//
//    with FDM.QuerySQL(nStr) do
//    begin
//      LabelNum.Caption := '���ŵ���: ' + Fields[0].AsString + '��';
//    end;

    //--------------------------------------------------------------------------
    nStr := 'Select R_ID,T_line,T_InTime,T_Valid From %s ZT ' +
             'Where T_HKBills like ''%%%s%%'' ';
    nStr := Format(nStr, [sTable_ZTTrucks, nBill]);

    with FDM.QuerySQL(nStr) do
    begin
      if RecordCount < 1 then
      begin
        LabelHint.Caption := '���ĳ�������Ч.';
        Exit;
      end;

      if FieldByName('T_Valid').AsString <> sFlag_Yes then
      begin
        LabelHint.Caption := '���ѳ�ʱ����,�뵽������������������.';
        Exit;
      end;

      nRID := FieldByName('R_ID').AsInteger;
      //���

      nDate := FieldByName('T_InTime').AsDateTime;
      //����ʱ��

      nLine := FieldByName('T_Line').AsString;
      //ͨ����
    end;

    if nLine = '' then
    begin
      try
        if LoadTruckQueue(FLines, FTrucks, False) then
        begin
          for nIdx:=Low(FTrucks) to High(FTrucks) do
          begin
            nStr := nStr + ',' + FTrucks[nIdx].FTruck;
            if FTrucks[nIdx].FTruck = nTruck then
            begin
              nLine := FTrucks[nIdx].FLine;
              Break;
            end;
          end;
        end;
      except
      end;
    end;
    WriteLog('���г��ƺ�:'+nStr);

    if nLine <> '' then
    begin
      nStr := 'Select Z_Valid,Z_Name From %s Where Z_ID=''%s'' ';
      nStr := Format(nStr, [sTable_ZTLines, nLine]);

      with FDM.QuerySQL(nStr) do
      begin
        if FieldByName('Z_Valid').AsString = 'N' then
        begin
        LabelHint.Caption := '�����ڵ�ͨ���ѹرգ�����ϵ������Ա.';
        Exit;
        end
        else begin
          LabelQueue.Caption := '��������: '+FieldByName('Z_Name').AsString;
        end;
//        else
//        begin
//        LabelHint.Caption := 'ϵͳ�����ĳ������볧,�뵽' +  + '���.';
//        Exit;
//        end;
      end;
    end;

    nStr := 'Select D_Value From $DT Where D_Memo = ''$PQ''';
    nStr := MacroValue(nStr, [MI('$DT', sTable_SysDict),
            MI('$PQ', sFlag_PoundQueue)]);

    with FDM.QuerySQL(nStr) do
    begin
      if FieldByName('D_Value').AsString = 'Y' then
      nPoundQueue := 'Y';
    end;

    nStr := 'Select D_Value From $DT Where D_Memo = ''$DQ''';
    nStr := MacroValue(nStr, [MI('$DT', sTable_SysDict),
            MI('$DQ', sFlag_DelayQueue)]);

    with FDM.QuerySQL(nStr) do
    begin
      if  FieldByName('D_Value').AsString = 'Y' then
      begin
        if nPoundQueue <> 'Y' then
        begin
          nStr := 'Select Count(*) From $TB Where T_InQueue Is Null And ' +
                  'T_Valid=''$Yes'' And T_StockNo=''$SN'' And T_InFact<''$IT'' And T_Vip=''$VIP''';
        end else
        begin
          nStr := ' Select Count(*) From $TB left join S_PoundLog on S_PoundLog.P_Bill=S_ZTTrucks.T_Bill ' +
                  ' Where T_InQueue Is Null And ' +
                  ' T_Valid=''$Yes'' And T_StockNo=''$SN'' And P_PDate<''$IT'' And T_Vip=''$VIP''';
        end;
        nStr := MacroValue(nStr, [MI('$TB', sTable_ZTTrucks),
            MI('$Yes', sFlag_Yes), MI('$SN', nStock),
            MI('$IT', DateTime2Str(nDate)),MI('$VIP', nVip)]);
      end else
      begin
        {nStr := 'Select Count(*) From $TB Where T_InQueue Is Null And ' +
                'T_Valid=''$Yes'' And T_StockNo=''$SN'' And T_InTime<''$IT'' And T_Vip=''$VIP'''; }
                
        nStr := 'Select Count(*) From $TB Where T_InQueue Is Null And ' +
                'T_Valid=''$Yes'' And T_StockNo=''$SN'' And T_Vip=''$VIP'' And R_ID<''$IT''';

        nStr := MacroValue(nStr, [MI('$TB', sTable_ZTTrucks),
            MI('$Yes', sFlag_Yes), MI('$SN', nStock),
            MI('$VIP', nVip), MI('$IT', IntToStr(nRID))]);
      end;
    end;
    //xxxxx
    WriteLog(nStr);
    with FDM.QuerySQL(nStr) do
    begin
      if Fields[0].AsInteger < 1 then
      begin
        nStr := gSysParam.FQueuePromt;
        LabelHint.Caption := nStr;
      end else
      begin
        nStr := '��ǰ�滹�С� %d �������ȴ�����';
        LabelHint.Caption := Format(nStr, [Fields[0].AsInteger-1]);
      end;
    end;

    FLastQuery := GetTickCount;
    FLastCard := nCard;
    //�ѳɹ�����
  except
    on E: Exception do
    begin
      ShowMsg('��ѯʧ��', sHint);
      WriteLog(E.Message);
    end;
  end;

  FDM.ADOConn.Connected := False;
end;

procedure TfFormMain.TimerInsertCardTimer(Sender: TObject);
begin
  FReadCardThread := TReadCardThread.Create(True);
  FReadCardThread.FreeOnTerminate := True;
  FReadCardThread.Resume;
  WaitForSingleObject(FReadCardThread.Handle,INFINITE);
end;

procedure TfFormMain.DoHotKeyHotKeyPressed(HotKey: Cardinal; Index: Word);
begin
  if (HotKey = FHotKey) then
  begin
    ShowCursor(True);
    FCursorShow := True;
  end;
end;

procedure TfFormMain.imgPrintClick(Sender: TObject);
var
  nP: TFormCommandParam;
  nLID,nHyDan,nStockname:string;
begin
  {$IFDEF PLKP}
  CreateBaseFormItem(cFI_FormHYPrint, '', @nP);
  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    nHyDan := nP.FParamB;
    nStockname := nP.FParamC;
    nLID := nP.FParamD;
    if Length(nHyDan) <= 1 then
    begin
      ShowMsg('��ǰƷ�������ӡ���鵥��',sHint);
      Exit;
    end;

    if not Assigned(FDR) then
    begin
      FDR := TFDR.Create(Application);
    end;

    if PrintHYReport(nLID, False) then
    begin
      ShowMsg('��ӡ�ɹ��������·���ֽ��ȡ�����Ļ��鵥',sHint);
    end
    else begin
      ShowMsg('��ӡʧ�ܣ�����ϵ��ƱԱ����',sHint);
    end;
  end;
  {$ELSE}
  CreateBaseFormItem(cFI_FormBarCodePrint, '', @nP);
  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    nHyDan := nP.FParamB;
    nStockname := nP.FParamC;
    if nHyDan='' then
    begin
      ShowMsg('��ǰƷ�������ӡ���鵥��',sHint);
      Exit;
    end;

    if not Assigned(FDR) then
    begin
      FDR := TFDR.Create(Application);
    end;

    if PrintHuaYanReport(nHYDan, nStockName, False) then
    begin
      ShowMsg('��ӡ�ɹ��������·���ֽ��ȡ�����Ļ��鵥',sHint);
    end
    else begin
      ShowMsg('��ӡʧ�ܣ�����ϵ��ƱԱ����',sHint);
    end;
  end;
  {$ENDIF}
  
end;

procedure TfFormMain.imgCardClick(Sender: TObject);
begin
  if not TimerInsertCard.Enabled then
  begin
    ShowMsg('ϵͳ���ڶ��������Ժ�...',sHint);
    Exit;
  end;
  if FDownLoadWay = 0 then
  begin
    if Sender=imgCard then
    begin
      if not Assigned(fFormNewCardQls) then
      begin
        fFormNewCardQls := TfFormNewCardQls.Create(nil);
        fFormNewCardQls.SzttceApi := FSzttceApi;
        fFormNewCardQls.SetControlsClear;
      end;
      fFormNewCardQls.BringToFront;
      fFormNewCardQls.Left := self.Left;
      fFormNewCardQls.Top := self.Top;
      fFormNewCardQls.Width := self.Width;
      fFormNewCardQls.Height := self.Height;
      fFormNewCardQls.Show;
    end
    else if Sender=imgPurchaseCard then
    begin
      ShowMsg('�ɹ�ҵ����ʱ��֧�������쿨����ȥ�˹����ڰ���',sHint);
      Exit;
    end;
  end
  else
  begin
    if Sender=imgCard then
    begin
      if not Assigned(fFormNewCard) then
      begin
        fFormNewCard := TfFormNewCard.Create(nil);
        fFormNewCard.SzttceApi := FSzttceApi;
        fFormNewCard.SetControlsClear;
      end;
      fFormNewCard.BringToFront;
      fFormNewCard.Left := self.Left;
      fFormNewCard.Top := self.Top;
      fFormNewCard.Width := self.Width;
      fFormNewCard.Height := self.Height;
      fFormNewCard.Show;
    end
    else if Sender=imgPurchaseCard then
    begin
     if not Assigned(fFormNewPurchaseCard) then
      begin
        fFormNewPurchaseCard := TfFormNewPurchaseCard.Create(nil);
        fFormNewPurchaseCard.SzttceApi := FSzttceApi;
        fFormNewPurchaseCard.SetControlsClear;
      end;
      fFormNewPurchaseCard.BringToFront;
      fFormNewPurchaseCard.Left := self.Left;
      fFormNewPurchaseCard.Top := self.Top;
      fFormNewPurchaseCard.Width := self.Width;
      fFormNewPurchaseCard.Height := self.Height;
      fFormNewPurchaseCard.Show;
    end;
  end;
  TimerInsertCard.Enabled := False;
end;

procedure TfFormMain.FormResize(Sender: TObject);
var
  nIni:TIniFile;
  nFileName:string;
  nLeft,nTop,nWidth,nHeight:Integer;
  nItemHeigth:Integer;
begin
  nFileName := ExtractFilePath(ParamStr(0))+'Config.Ini';
  if not FileExists(nFileName) then
  begin
    Exit;
  end;
  nIni := TIniFile.Create(nFileName);
  try
    nLeft := nIni.ReadInteger('screen','left',0);
    nTop := nIni.ReadInteger('screen','top',0);
    nWidth := nIni.ReadInteger('screen','width',1024);
    nHeight := nIni.ReadInteger('screen','height',768);
    nItemHeigth := nHeight div 10;

    LabelTruck.Height := nItemHeigth;
    LabelDec.Height := nItemHeigth;
    LabelBill.Height := nItemHeigth;
    LabelOrder.Height := nItemHeigth;
    LabelTon.Height := nItemHeigth;
    LabelStock.Height := nItemHeigth;
    LabelQueue.Height := nItemHeigth;
    LabelCenterID.Height := nItemHeigth;
    LabelHint.Height := nItemHeigth;
    LabelCus.Height := nItemHeigth;
    imgCard.Height := nItemHeigth;
    imgPurchaseCard.Height := nItemHeigth;
    imgPrint.Height := nItemHeigth;
    imgCard.Top := LabelHint.Top;
    imgPurchaseCard.Top := LabelHint.Top;
    imgPrint.Top := LabelHint.Top;

    Self.Left := nLeft;
    self.Top := nTop;
    self.Width := nWidth;
    self.Height := nHeight;

    imgPrint.Left := self.Width-imgprint.Width;
  finally
    nIni.Free;
  end;
end;

end.
