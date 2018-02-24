{
   by lih 2016-06-29
   ���ܣ�ͬ��AX���������ݵ�DL
}
unit USyncAXBaseInfo;

{$I Link.inc}
interface

uses
  Windows, Classes, SysUtils, DateUtils, UBusinessConst, UMgrDBConn,
  UBusinessWorker, UWaitItem, ULibFun, USysDB, UMITConst, USysLoger,
  UBusinessPacker, NativeXml, UMgrParam, UWorkerBusiness;

type
  TAXSyncer = class;
  TAXSyncThread = class(TThread)
  private
    FOwner: TAXSyncer;
    //ӵ����
    FDBConn: PDBWorker;
    //���ݶ���
    FListA,FListB,FListC: TStrings;
    //�б����
    FXMLBuilder: TNativeXml;
    //XML������
    FNumAXSync: Integer;
    //�����ͬ����ʱ����
    FNumPoundSync: Integer;
    //����ͬ����ʱ����
    //FNumAXBASESync: Integer;
    //������ͬ��������ʱ
    FWaiter: TWaitObject;
    //�ȴ�����
    FSyncLock: TCrossProcWaitObject;
    //ͬ������
  protected
    function GetOnLineModel: string;
    //��ȡ����ģʽ
    procedure DoNewAXSync;
    procedure DoNewBillSyncAX;
    procedure DoDelBillSyncAX;
    procedure DoDelEmptyBillSyncAX;
    procedure DoEmptyBillSyncAX;
    procedure DoPoundSyncAX;
    procedure DoPurSyncAX;
    procedure Execute; override;
    //ִ���߳�
  public
    constructor Create(AOwner: TAXSyncer);
    destructor Destroy; override;
    //�����ͷ�
    procedure Wakeup;
    procedure StopMe;
    //��ֹ�߳�
  end;

  TAXSyncer = class(TObject)
  private
    FThread: TAXSyncThread;
    //ɨ���߳�
  public
    SyncTime:string;
    //�趨ͬ��ʱ��
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    procedure Start;
    procedure Stop;
    //��ͣ�ϴ�
    procedure LoadConfig(const nFile:string);//���������ļ�
  end;

var
  gAXSyncer: TAXSyncer = nil;
  //ȫ��ʹ��


implementation
procedure WriteLog(const nMsg: string);
begin
  gSysLoger.AddLog(TAXSyncer, 'AX����ͬ��', nMsg);
end;

constructor TAXSyncer.Create;
begin
  FThread := nil;
end;

destructor TAXSyncer.Destroy;
begin
  Stop;
  inherited;
end;

procedure TAXSyncer.Start;
begin
  if not Assigned(FThread) then
    FThread := TAXSyncThread.Create(Self);
  FThread.Wakeup;
end;

procedure TAXSyncer.Stop;
begin
  if Assigned(FThread) then
    FThread.StopMe;
  FThread := nil;
end;

//����nFile�����ļ�
procedure TAXSyncer.LoadConfig(const nFile: string);
var nXML: TNativeXml;
    nNode, nTmp: TXmlNode;
    nTime: TDateTime;
begin
  nXML := TNativeXml.Create;
  try
    nXML.LoadFromFile(nFile);
    nNode := nXML.Root.NodeByName('Item');
    try
      SyncTime:= nNode.NodeByName('SyncTime').ValueAsString;
      nTime:= StrToTime(SyncTime);
      SyncTime:= formatdatetime('hh:mm',nTime);
    except
      SyncTime:= '00:00';
    end;
    gCompanyAct:= nNode.NodeByName('CompanyAct').ValueAsString;
    nTmp := nNode.NodeByName('URLAddr');
    if Assigned(nTmp) then
      gURLAddr := nTmp.ValueAsString
    else
      gURLAddr := '';
  finally
    nXML.Free;
  end;
end;

//------------------------------------------------------------------------------
constructor TAXSyncThread.Create(AOwner: TAXSyncer);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  FXMLBuilder :=TNativeXml.Create;

  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 60*1000;
  //1 minute

  FSyncLock := TCrossProcWaitObject.Create('BusMIT_AX_Sync');
  //process sync
end;

destructor TAXSyncThread.Destroy;
begin
  FWaiter.Free;
  FListA.Free;
  FListB.Free;
  FListC.Free;
  FXMLBuilder.Free;
  
  FSyncLock.Free;
  inherited;
end;

procedure TAXSyncThread.Wakeup;
begin
  FWaiter.Wakeup;
end;

procedure TAXSyncThread.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TAXSyncThread.Execute;
var nErr: Integer;
    nInit: Int64;
    nModel: string;
begin
  FNumAXSync    := 0;
  //init counter
  FNumPoundSync:=0;
  //FNumAXBASESync:=0;
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    Inc(FNumAXSync);
    //inc counter
    Inc(FNumPoundSync);
    //Inc(FNumAXBASESync);

    if FNumAXSync >= 3 then
      FNumAXSync := 0;
    //ͬ���������AX: 10��/Сʱ
    if FNumPoundSync>=5 then
      FNumPoundSync:=0;
    //ͬ��������AX: 6��/Сʱ
    {if FNumAXBASESync>=30 then
      FNumAXBASESync:=0; }
    //ͬ��������Ϣ
    
    if (FNumAXSync <> 0) and (FNumPoundSync<>0)  then Continue; //and (FNumAXBASESync<>0)
    //��ҵ�����

    //--------------------------------------------------------------------------
    if not FSyncLock.SyncLockEnter() then Continue;
    //������������ִ��

    FDBConn := nil;
    with gParamManager.ActiveParam^ do
    try
      FDBConn := gDBConnManager.GetConnection(gDBConnManager.DefaultConnection, nErr);
      if not Assigned(FDBConn) then Continue;

      nModel := GetOnLineModel;

      if FNumAXSync = 0 then
      begin
        if nModel = sFlag_Yes then
        begin
          WriteLog('ͬ���������AX...');
          nInit := GetTickCount;
          DoNewBillSyncAX;
          DoDelBillSyncAX;
          DoEmptyBillSyncAX;
          DoDelEmptyBillSyncAX;
          WriteLog('ͬ���������AX���,��ʱ: ' + IntToStr(GetTickCount - nInit));
        end else
        begin
          WriteLog('����ģʽ');
        end;
      end;

      if FNumPoundSync = 0 then
      begin
        if nModel = sFlag_Yes then
        begin
          WriteLog('ͬ��������AX...');
          nInit := GetTickCount;
          DoPoundSyncAX;
          DoPurSyncAX;
          //DoDuanSyncAX;
          WriteLog('ͬ��������AX���,��ʱ: ' + IntToStr(GetTickCount - nInit));
        end else
        begin
          WriteLog('����ģʽ');
        end;
      end;

      {if FNumAXBASESync=0 then
      begin
        WriteLog('ͬ��AX����������...');
        nInit := GetTickCount;
        DoNewAXSync;
        WriteLog('ͬ��AX���������,��ʱ: ' + IntToStr(GetTickCount - nInit));
      end; }
    finally
      gDBConnManager.ReleaseConnection(FDBConn);
      FSyncLock.SyncLockLeave();
      WriteLog('Release FDBConn');
    end;
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

//��ȡ����ģʽ
function TAXSyncThread.GetOnLineModel: string;
var
  nStr: string;
begin
  Result:=sFlag_Yes;
  nStr := 'select D_Value from %s where D_Name=''%s'' ';
  nStr := Format(nStr, [sTable_SysDict, sFlag_OnLineModel]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    Result:=Fields[0].AsString;
    WriteLog('OnLineModel: '+Result);
  end;
end;

//Date: 2016-07-09
//lih: ͬ���������AX
procedure TAXSyncThread.DoNewBillSyncAX;
var
  nErr: Integer;
  nSQL,nStr: string;
  nOut: TWorkerBusinessCommand;
  nIdx:Integer;
begin
  try
    FListA.Clear;
    {$IFDEF GGJC}
    nSQL := 'select L_ID From '+sTable_Bill+' where (L_EmptyOut<>''Y'') '+
            'and ((L_FYAX <> ''1'') or (L_FYAX is null)) '+
            'and ((L_PDate is not null) or (L_MDate is not null)) '+
            'and L_FYNUM<=3 ';
    {$ELSE}
    nSQL := 'select L_ID From %s where (L_EmptyOut<>''Y'') '+
            'and ((L_FYAX <> ''1'') or (L_FYAX is null)) '+
            'and ((L_PDate is not null) or (L_MDate is not null)) '+
            'and L_FYNUM<=3 ';
    nSQL := Format(nSQL,[sTable_Bill]);
    {$ENDIF}
    
    writelog('DoNewBillSyncAX.sql=['+nSQL+']');
    
    with gDBConnManager.WorkerQuery(FDBConn,nSql) do
    begin
      if RecordCount<1 then
      begin
        WriteLog('�������ͬ������');
        Exit;
      end;
      First;
      while not Eof do
      begin
        FListA.Add(FieldByName('L_ID').AsString);
        Next;
      end;
    end;
    if FListA.Count>0 then
    begin
      for nIdx:=0 to FListA.Count - 1 do
      begin
        if not TWorkerBusinessCommander.CallMe(cBC_SyncFYBillAX,FListA[nIdx],'',@nOut) then
        begin
          WriteLog(FListA[nIdx]+'�����ͬ��ʧ��');
        end; 
      end;
    end;
  except
    on e:Exception do
    begin
      WriteLog('ͬ�����������'+e.Message);
    end;
  end;
end;

//Date: 2016-07-09
//lih: ͬ����ɾ���������AX
procedure TAXSyncThread.DoDelBillSyncAX;
var
  nErr: Integer;
  nSql,nStr: string;
  nOut: TWorkerBusinessCommand;
  nIdx:Integer;
begin
  try
    FListA.Clear;
    nSQL := 'select L_ID From %s where (L_FYAX = ''1'') and (L_FYDEL = ''0'') and L_FYDELNUM<=3 ';
    nSQL := Format(nSQL,[sTable_BillBak]);
    with gDBConnManager.WorkerQuery(FDBConn,nSql) do
    begin
      if RecordCount<1 then
      begin
        WriteLog('��ɾ�������ͬ������');
        Exit;
      end;
      First;
      while not Eof do
      begin
        FListA.Add(FieldByName('L_ID').AsString);
        Next;
      end;
    end;
    if FListA.Count>0 then
    begin
      for nIdx:=0 to FListA.Count - 1 do
      begin
        if not TWorkerBusinessCommander.CallMe(cBC_SyncDelSBillAX,FListA[nIdx],'',@nOut) then
        begin
          WriteLog(FListA[nIdx]+'��ɾ�����ͬ��ʧ��');
        end;
      end;
    end;
  except
    on e:Exception do
    begin
      WriteLog('ͬ����ɾ���������'+e.Message);
    end;
  end;
end;

procedure TAXSyncThread.DoDelEmptyBillSyncAX;
var
  nErr: Integer;
  nSql,nStr: string;
  nOut: TWorkerBusinessCommand;
  nIdx:Integer;
begin
  try
    FListA.Clear;
    nSQL := 'select L_ID From %s where (L_FYAX = ''1'') and (L_FYDEL = ''0'') and L_FYDELNUM<=3 and (L_EmptyOut=''Y'')';
    nSQL := Format(nSQL,[sTable_Bill]);
    with gDBConnManager.WorkerQuery(FDBConn,nSql) do
    begin
      if RecordCount<1 then
      begin
        WriteLog('�޿ճ����������ͬ������');
        Exit;
      end;
      First;
      while not Eof do
      begin
        FListA.Add(FieldByName('L_ID').AsString);
        Next;
      end;
    end;
    if FListA.Count>0 then
    begin
      for nIdx:=0 to FListA.Count - 1 do
      begin
        if not TWorkerBusinessCommander.CallMe(cBC_SyncDelSBillAX,FListA[nIdx],'',@nOut) then
        begin
          WriteLog(FListA[nIdx]+'�ճ����������ͬ��ʧ��');
        end;
      end;
    end;
  except
    on e:Exception do
    begin
      WriteLog('ͬ���ճ��������������'+e.Message);
    end;
  end;
end;

//Date: 2016-07-09
//lih: ͬ���ճ������������AX
procedure TAXSyncThread.DoEmptyBillSyncAX;
var
  nErr: Integer;
  nSql,nStr: string;
  nOut: TWorkerBusinessCommand;
  nIdx:Integer;
begin
  try
    FListA.Clear;

    nSQL := 'select L_ID From %s where (L_EmptyOut=''Y'') and '+
            '(L_FYAX = ''1'') and '+
            '((L_EOUTAX <> ''1'') or (L_EOUTAX is null)) and '+
            'L_EOUTNUM<=3 ';
    nSQL := Format(nSQL,[sTable_Bill]);
    with gDBConnManager.WorkerQuery(FDBConn,nSql) do
    begin
      if RecordCount<1 then
      begin
        WriteLog('�޿ճ����������ͬ������');
        Exit;
      end;
      First;
      while not Eof do
      begin
        FListA.Add(FieldByName('L_ID').AsString);
        Next;
      end;
    end;
    if FListA.Count>0 then
    begin
      for nIdx:=0 to FListA.Count - 1 do
      begin
        if not TWorkerBusinessCommander.CallMe(cBC_SyncEmpOutBillAX,FListA[nIdx],'',@nOut) then
        begin
          WriteLog(FListA[nIdx]+'�ճ����������ͬ��ʧ��');
        end; 
      end;
    end;
  except
    on e:Exception do
    begin
      WriteLog('ͬ���ճ��������������'+e.Message);
    end;
  end;
end;

//Date: 2016-07-09
//lih: ͬ�����۰�����AX
procedure TAXSyncThread.DoPoundSyncAX;
var
  nErr: Integer;
  nSql,nStr: string;
  nOut: TWorkerBusinessCommand;
  nIdx:Integer;
begin
  try
    FListA.Clear;
    nSQL := 'select L_ID From %s '+
            'where (L_Status=''O'') and '+
            '(L_EmptyOut <> ''Y'') and '+
            '((L_BDAX <> ''1'') or (L_BDAX is null)) and '+
            '(L_BDAX <> ''2'') and '+
            '(L_FYAX=''1'') and L_BDNUM<=3';
    nSQL := Format(nSQL,[sTable_Bill]);
    with gDBConnManager.WorkerQuery(FDBConn,nSql) do
    begin
      if RecordCount<1 then
      begin
        WriteLog('�����۰���ͬ������');
        Exit;
      end;
      First;
      while not Eof do
      begin
        FListA.Add(FieldByName('L_ID').AsString);
        Next;
      end;
    end;
    if FListA.Count>0 then
    begin
      for nIdx:=0 to FListA.Count - 1 do
      begin
        if not TWorkerBusinessCommander.CallMe(cBC_SyncStockBill,FListA[nIdx],'',@nOut) then
        begin
          WriteLog(FListA[nIdx]+'���۰���ͬ��ʧ��');
        end;
      end;
    end;
  except
    on e:Exception do
    begin
      WriteLog('ͬ�����۰�������'+e.Message);
    end;
  end;
end;

//Date: 2016-07-09
//lih: ͬ���ɹ�������AX
procedure TAXSyncThread.DoPurSyncAX;
var
  nErr: Integer;
  nSql,nStr: string;
  nOut: TWorkerBusinessCommand;
  nIdx:Integer;
begin
  try
    FListA.Clear;
    nSQL := 'select D_ID From %s '+
            'where (D_Status=''O'') and '+
            '((D_BDAX <> ''1'') or (D_BDAX is null)) and '+
            'D_BDNUM<=3';
    nSQL := Format(nSQL,[sTable_OrderDtl]);
    with gDBConnManager.WorkerQuery(FDBConn,nSql) do
    begin
      if RecordCount<1 then
      begin
        WriteLog('�޲ɹ�����ͬ������');
        Exit;
      end;
      First;
      while not Eof do
      begin
        FListA.Add(FieldByName('D_ID').AsString);
        Next;
      end;
    end;
    if FListA.Count>0 then
    begin
      for nIdx:=0 to FListA.Count - 1 do
      begin
        if not TWorkerBusinessCommander.CallMe(cBC_SyncStockOrder,FListA[nIdx],'',@nOut) then
        begin
          WriteLog(FListA[nIdx]+'�ɹ�����ͬ��ʧ��');
        end;
      end;
    end;
  except
    on e:Exception do
    begin
      WriteLog('ͬ���ɹ���������'+e.Message);
    end;
  end;
end;

//Date: 2016-06-29
//lih: ͬ��AX��������Ϣ
procedure TAXSyncThread.DoNewAXSync;
var
  nSql,nStr: string;
  nMsg:WideString;
  nOut: TWorkerBusinessCommand;
begin
  try
    if not TWorkerBusinessCommander.CallMe(cBC_SyncCustomer,'','',@nOut) then
    begin
      WriteLog('�ͻ���Ϣͬ��ʧ��');
    end;
    if not TWorkerBusinessCommander.CallMe(cBC_SyncTprGem,'','',@nOut) then
    begin
      WriteLog('���ö�ȣ��ͻ�����Ϣͬ��ʧ��');
    end;
    if not TWorkerBusinessCommander.CallMe(cBC_SyncTprGemCont,'','',@nOut) then
    begin
      WriteLog('���ö�ȣ��ͻ�-��ͬ����Ϣͬ��ʧ��');
    end;
    if not TWorkerBusinessCommander.CallMe(cBC_GetSalesOrder,'','',@nOut) then
    begin
      WriteLog('���۶���ͬ��ʧ��');
    end;
    if not TWorkerBusinessCommander.CallMe(cBC_GetSalesOrdLine,'','',@nOut) then
    begin
      WriteLog('���۶�����ͬ��ʧ��');
    end;
    if not TWorkerBusinessCommander.CallMe(cBC_GetSupAgreement,'','',@nOut) then
    begin
      WriteLog('����Э��ͬ��ʧ��');
    end;
    if not TWorkerBusinessCommander.CallMe(cBC_GetSalesCont,'','',@nOut) then
    begin
      WriteLog('���ۺ�ͬͬ��ʧ��');
    end;
    if not TWorkerBusinessCommander.CallMe(cBC_GetSalesContLine,'','',@nOut) then
    begin
      WriteLog('���ۺ�ͬ��ͬ��ʧ��');
    end;
    if not TWorkerBusinessCommander.CallMe(cBC_GetSalesCont,'','',@nOut) then
    begin
      WriteLog('���ۺ�ͬͬ��ʧ��');
    end;
    if not TWorkerBusinessCommander.CallMe(cBC_GetSalesContLine,'','',@nOut) then
    begin
      WriteLog('���ۺ�ͬ��ͬ��ʧ��');
    end;
    if not TWorkerBusinessCommander.CallMe(cBC_GetPurOrder,'','',@nOut) then
    begin
      WriteLog('�ɹ�����ͬ��ʧ��');
    end;
    if not TWorkerBusinessCommander.CallMe(cBC_GetPurOrdLine,'','',@nOut) then
    begin
      WriteLog('�ɹ���������ͬ��ʧ��');
    end;
    {$IFDEF DEBUG}
    //WriteLog(nSql);
    {$ENDIF}
  except
    on e:Exception do
    begin
      WriteLog(e.Message);
    end;
  end;
end;

initialization
  gAXSyncer := nil;
finalization
  FreeAndNil(gAXSyncer);
end.

