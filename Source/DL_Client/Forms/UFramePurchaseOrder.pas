{*******************************************************************************
  ����: fendou116688@163.com 2015/8/8
  ����: �ɹ���������
*******************************************************************************}
unit UFramePurchaseOrder;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, Menus, dxLayoutControl,
  cxTextEdit, cxMaskEdit, cxButtonEdit, ADODB, cxLabel, UBitmapPanel,
  cxSplitter, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, cxCheckBox, dxLayoutcxEditAdapters;

type
  TfFramePurchaseOrder = class(TfFrameNormal)
    EditID: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditCustomer: TcxButtonEdit;
    dxLayout1Item7: TdxLayoutItem;
    PMenu1: TPopupMenu;
    N6: TMenuItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item8: TdxLayoutItem;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    Check1: TcxCheckBox;
    EditTruck: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N7: TMenuItem;
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure cxView1DblClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure Check1Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
  private
    { Private declarations }
  protected
    FStart,FEnd: TDate;
    FTimeS,FTimeE: TDate;
    //ʱ������
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    {*��ѯSQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl,UDataModule, UFrameBase, UFormBase, USysBusiness,
  USysConst, USysDB, UFormDateFilter, UFormInputbox, ShellAPI, UFormWait;

//------------------------------------------------------------------------------
class function TfFramePurchaseOrder.FrameID: integer;
begin
  Result := cFI_FrameOrder;
end;

procedure TfFramePurchaseOrder.OnCreateFrame;
begin
  inherited;
  FTimeS := Str2DateTime(Date2Str(Now) + ' 00:00:00');
  FTimeE := Str2DateTime(Date2Str(Now) + ' 00:00:00');

  InitDateRange(Name, FStart, FEnd);
  if not gSysParam.FIsAdmin then
  begin
    N3.Enabled:=False;
    N3.Visible:=False;
  end;
end;

procedure TfFramePurchaseOrder.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

//Desc: ���ݲ�ѯSQL
function TfFramePurchaseOrder.InitFormDataSQL(const nWhere: string): string;
begin
  EditDate.Text := Format('%s �� %s', [Date2Str(FStart), Date2Str(FEnd)]);

  Result := 'Select oo.* From $OO oo ';
  //xxxxx

  if nWhere = '' then
       Result := Result + ' Where (O_Date >=''$ST'' and O_Date<''$End'') '
  else Result := Result + ' Where (' + nWhere + ')';

  if Check1.Checked then
       Result := MacroValue(Result, [MI('$OO', sTable_OrderBak)])
  else Result := MacroValue(Result, [MI('$OO', sTable_Order)]);

  Result := MacroValue(Result, [MI('$OO', sTable_Order),
            MI('$ST', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
  //xxxxx
end;

//------------------------------------------------------------------------------
//Desc: ���
procedure TfFramePurchaseOrder.BtnAddClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  nParam.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormOrder, PopedomItem, @nParam);

  if (nParam.FCommand = cCmd_ModalResult) and (nParam.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: �޸�
procedure TfFramePurchaseOrder.BtnEditClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫ�༭�ļ�¼', sHint); Exit;
  end;

  nParam.FCommand := cCmd_EditData;
  nParam.FParamA := SQLQuery.FieldByName('O_ID').AsString;
  CreateBaseFormItem(cFI_FormOrder, PopedomItem, @nParam);

  if (nParam.FCommand = cCmd_ModalResult) and (nParam.FParamA = mrOK) then
  begin
    InitFormData(FWhere);
  end;
end;

//Desc: ɾ��
procedure TfFramePurchaseOrder.BtnDelClick(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫɾ���ļ�¼', sHint); Exit;
  end;

  nStr := SQLQuery.FieldByName('O_ID').AsString;
  if not QueryDlg('ȷ��Ҫɾ�����Ϊ[ ' + nStr + ' ]�Ķ�����?', sAsk) then Exit;

  if DeleteOrder(nStr) then ShowMsg('�ѳɹ�ɾ����¼', sHint);

  InitFormData('');
end;

//Desc: �鿴����
procedure TfFramePurchaseOrder.cxView1DblClick(Sender: TObject);
begin
end;

//Desc: ����ɸѡ
procedure TfFramePurchaseOrder.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData(FWhere);
end;

//Desc: ִ�в�ѯ
procedure TfFramePurchaseOrder.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditID then
  begin
    EditID.Text := Trim(EditID.Text);
    if EditID.Text = '' then Exit;

    FWhere := 'oo.O_ID like ''%' + EditID.Text + '%''';
    InitFormData(FWhere);
  end else

  if Sender = EditTruck then
  begin
    EditTruck.Text := Trim(EditTruck.Text);
    if EditTruck.Text = '' then Exit;

    FWhere := 'oo.O_Truck like ''%' + EditTruck.Text + '%''';
    InitFormData(FWhere);
  end else

  if Sender = EditCustomer then
  begin
    EditCustomer.Text := Trim(EditCustomer.Text);
    if EditCustomer.Text = '' then Exit;

    FWhere := 'O_ProPY like ''%%%s%%'' Or O_ProName like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCustomer.Text, EditCustomer.Text]);
    InitFormData(FWhere);
  end;
end;

procedure TfFramePurchaseOrder.N1Click(Sender: TObject);
var nOrderID, nTruck: string;
begin
  inherited;
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫ�༭�ļ�¼', sHint); Exit;
  end;
  nOrderID := SQLQuery.FieldByName('O_ID').AsString;
  nTruck   := SQLQuery.FieldByName('O_Truck').AsString;

  if SetOrderCard(nOrderID, nTruck, True) then
    ShowMsg('����ſ��ɹ�', sHint);
  //����ſ�
end;

procedure TfFramePurchaseOrder.N2Click(Sender: TObject);
var nCard: string;
begin
  inherited;
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫ�༭�ļ�¼', sHint); Exit;
  end;

  nCard := SQLQuery.FieldByName('O_Card').AsString;
  if LogoutOrderCard(nCard) then
    ShowMsg('ע���ſ��ɹ�', sHint);
  //����ſ�
  InitFormData('');
end;

procedure TfFramePurchaseOrder.N3Click(Sender: TObject);
var
  nStr,nTruck,nSQL: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('O_Truck').AsString;
    nTruck := nStr;
    if not ShowInputBox('�������µĳ��ƺ���:', '�޸�', nTruck, 15) then Exit;

    if (nTruck = '') or (nStr = nTruck) then Exit;
    //��Ч��һ��

    nStr := SQLQuery.FieldByName('O_ID').AsString;
    nSQL := 'select * from %s where D_OID=''%s'' ';
    nSQL := Format(nSQL,[sTable_OrderDtl,nStr]);
    with FDM.QueryTemp(nSQL) do
    begin
      if RecordCount > 0 then
      begin
        if (FieldByName('D_Status').AsString<>sFlag_TruckNone) and
          (FieldByName('D_Status').AsString<>sFlag_TruckIn) then
        begin
          ShowMsg('�����ѳ��أ���ֹ�޸�',sHint);
          Exit;
        end;
      end;
    end;
    if ChangeOrderTruckNo(nStr, nTruck) then
    begin
      nSQL := 'update %s set D_Truck=''%s'' where D_OID=''%s'' ';
      nSQL := Format(nSQL,[sTable_OrderDtl, nTruck, nStr]);
      with FDM.SqlTemp do
      begin
        Close;
        SQL.Text:=nSQL;
        Open;
      end;
      InitFormData(FWhere);
      ShowMsg('���ƺ��޸ĳɹ�', sHint);
    end;
  end;
end;

procedure TfFramePurchaseOrder.Check1Click(Sender: TObject);
begin
  inherited;
  InitFormData('');
end;

procedure TfFramePurchaseOrder.N4Click(Sender: TObject);
var nStr,nID,nDir: string;
    nPic: TPicture;
    nystdno,nTruckno,ndate:string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫ�鿴�ļ�¼', sHint);
    Exit;
  end;
  nystdno := SQLQuery.FieldByName('O_YSTDno').AsString;
  nTruckno := SQLQuery.FieldByName('O_Truck').AsString;
  ndate := FormatDateTime('yyyymmdd',SQLQuery.FieldByName('O_date').AsDateTime);
  nDir := gSysParam.FPicPath + nystdno+'\'+ nTruckno + '\'+ ndate +'\';

  if not DirectoryExists(nDir) then
  begin
    ForceDirectories(nDir);
  end;

  nPic := nil;
  nStr := 'Select * From %s Where P_ID like ''%s%%'' and p_name=''%s''';
  nStr := Format(nStr, [sTable_Picture, nystdno, nTruckno]);
  ShowWaitForm(ParentForm, '��ȡͼƬ', True);
  try
    with FDM.QueryTemp(nStr) do
    begin
      if RecordCount < 1 then
      begin
        ShowMsg('����������ץ��', sHint);
        Exit;
      end;
      
      nPic := TPicture.Create;
      First;
      while not Eof do
      begin
        nStr := nDir + Format('%s_%s.jpg', [FieldByName('P_ID').AsString,
                FieldByName('R_ID').AsString]);
        if FileExists(nStr) then
        begin
          Next;
          Continue;
        end;
        FDM.LoadDBImage(FDM.SqlTemp, 'P_Picture', nPic);
        nPic.SaveToFile(nStr);
        Next;
      end;
    end;
    ShellExecute(GetDesktopWindow, 'open', PChar(nDir), nil, nil, SW_SHOWNORMAL);
    //open dir
  finally
    nPic.Free;
    CloseWaitForm;
    FDM.SqlTemp.Close;
  end;
end;

procedure TfFramePurchaseOrder.N7Click(Sender: TObject);
var
  nY_stockno,nStuckno,nStr:string;
  nTunnel:string;
  nY_valid:string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫ�鿴�ļ�¼', sHint);
    Exit;
  end;

  nStuckno := SQLQuery.FieldByName('O_Stockno').AsString;

  if not InputQuery('��ʾ','����������ͨ��',nTunnel) then Exit;
  if nTunnel='' then Exit;

  nStr := 'select * from %s where y_id=''%s''';
  nStr := Format(nStr,[sTable_YSLines,nTunnel]);
  with fdm.QuerySQL(nStr) do
  begin
    if recordcount=0 then
    begin
      ShowMsg('����ͨ��'+nTunnel+'������',sHint);
      Exit;
    end;

    nY_valid := FieldByName('Y_Valid').asstring;
    if nY_valid=sflag_no then
    begin
      ShowMsg('����ͨ��'+nTunnel+'�ѹر�',sHint);
      Exit;
    end;
    nY_stockno := FieldByName('Y_StockNo').asstring;
  end;

  if Pos(nStuckno,nY_stockno)=0 then
  begin
    ShowMsg('���������ͨ��',sHint);
    Exit;
  end;
  ShowMsg('���ճɹ�',sHint);
end;

initialization
  gControlManager.RegCtrl(TfFramePurchaseOrder, TfFramePurchaseOrder.FrameID);
end.
