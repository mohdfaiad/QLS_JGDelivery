{*******************************************************************************
  ����: dmzn@163.com 2014-09-01
  ����: �������
*******************************************************************************}
unit UFormBill_brick;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ComCtrls, cxMaskEdit,
  cxDropDownEdit, cxListView, cxTextEdit, cxMCListBox, dxLayoutControl,
  StdCtrls, cxButtonEdit, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinscxPCPainter, dxLayoutcxEditAdapters, cxCheckBox, cxLabel;

type
  TfFormBill_brick = class(TfFormNormal)
    dxGroup2: TdxLayoutGroup;
    dxLayout1Item3: TdxLayoutItem;
    ListInfo: TcxMCListBox;
    dxLayout1Item4: TdxLayoutItem;
    ListBill: TcxListView;
    EditValue: TcxTextEdit;
    dxLayout1Item8: TdxLayoutItem;
    EditTruck: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    BtnAdd: TButton;
    dxLayout1Item10: TdxLayoutItem;
    BtnDel: TButton;
    dxLayout1Item11: TdxLayoutItem;
    EditLading: TcxComboBox;
    dxLayout1Item12: TdxLayoutItem;
    dxLayout1Group5: TdxLayoutGroup;
    dxLayout1Group8: TdxLayoutGroup;
    dxLayout1Group7: TdxLayoutGroup;
    dxLayout1Group2: TdxLayoutGroup;
    chkIfHYprint: TcxCheckBox;
    dxLayout1Item13: TdxLayoutItem;
    EditStock: TcxComboBox;
    dxLayout1Item7: TdxLayoutItem;
    EditJXSTHD: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    cbxSampleID: TcxComboBox;
    dxLayout1Item5: TdxLayoutItem;
    cbxCenterID: TcxComboBox;
    dxLayout1Item14: TdxLayoutItem;
    dxLayout1Group3: TdxLayoutGroup;
    cxLabel1: TcxLabel;
    dxLayout1Item15: TdxLayoutItem;
    cbxKw: TcxComboBox;
    dxLayout1Item16: TdxLayoutItem;
    chkFenChe: TcxCheckBox;
    dxLayout1Item17: TdxLayoutItem;
    EditType: TcxComboBox;
    dxLayout1Item18: TdxLayoutItem;
    dxLayout1Group4: TdxLayoutGroup;
    EditHYCus: TComboBox;
    dxLayout1Item20: TdxLayoutItem;
    cbbColor: TcxComboBox;
    dxLayout1Item19: TdxLayoutItem;
    dxLayout1Group6: TdxLayoutGroup;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditStockPropertiesChange(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure EditLadingKeyPress(Sender: TObject; var Key: Char);
    procedure cbxSampleIDPropertiesChange(Sender: TObject);
    procedure cbxCenterIDPropertiesEditValueChanged(Sender: TObject);
  protected
    { Protected declarations }
    FBuDanFlag: string;
    //�������
    procedure LoadFormData;
    procedure LoadStockList;
    //��������
    procedure initcbbcolor;
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, DB, IniFiles, UMgrControl, UAdjustForm, UFormBase, UBusinessPacker,
  UDataModule, USysPopedom, USysBusiness, USysDB, USysGrid, USysConst;

type
  TCommonInfo = record
    FZhiKa: string;
    FCusID: string;
    FMoney: Double;
    FOnlyMoney: Boolean;
    FIDList: string;
    FShowPrice: Boolean;
    FPriceChanged: Boolean;
    FSalesType: string;  //�������ͣ�0��������־ 1���� 2Ԥ��3���۶��� 4�˻����� 5�ܶ��� 6��������
    Finventlocationid:string;//��λ����
  end;

  TStockItem = record
    FType: string;
    FStockNO: string;
    FStockName: string;
    FPrice: Double;
    FValue: Double;
    FSelecte: Boolean;
    FRecID: string;
    FSampleID: string;
    Fszbz:Boolean;
    Fcolor:string;
  end;

var
  gInfo: TCommonInfo;
  gStockList: array of TStockItem;
  gSelect:Integer;
  gStockName,gType:string;
  //ȫ��ʹ��

class function TfFormBill_brick.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nBool: Boolean;
    nP: PFormCommandParam;
begin
  Result := nil;
  if GetSysValidDate < 1 then Exit;

  if not Assigned(nParam) then
  begin
    New(nP);
    FillChar(nP^, SizeOf(TFormCommandParam), #0);
  end else nP := nParam;

  try
    CreateBaseFormItem(cFI_FormGetZhika_brick, nPopedom, nP);
    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;
    gInfo.FZhiKa := nP.FParamB;
    gInfo.Finventlocationid := 'A';
    gSelect := np.FParamD;
  finally
    if not Assigned(nParam) then Dispose(nP);
  end;

  with TfFormBill_brick.Create(Application) do
  try
    {$IFDEF YDKP}
    dxLayout1Item5.Enabled:=True;
    dxLayout1Item5.Visible:=True;
    dxLayout1Item16.Enabled:=True;
    dxLayout1Item16.Visible:=True;
    cxLabel1.Visible:=True;
    {$ELSE}
      {$IFDEF PLKP}
      dxLayout1Item5.Enabled:=True;
      dxLayout1Item5.Visible:=True;
      cxLabel1.Visible:=True;
      dxLayout1Item16.Enabled:=False;
      dxLayout1Item16.Visible:=False;
      {$ELSE}
      dxLayout1Item5.Enabled:=False;
      dxLayout1Item5.Visible:=False;
      dxLayout1Item16.Enabled:=False;
      dxLayout1Item16.Visible:=False;
      cxLabel1.Visible:=False;
      {$ENDIF}
    {$ENDIF}
    {$IFDEF QHSN}
    chkFenChe.Enabled:=True;
    chkFenChe.Visible:=True;
    {$ELSE}
    chkFenChe.Enabled:=False;
    chkFenChe.Visible:=False;
    {$ENDIF}
    {$IFDEF GGJC}
    chkFenChe.Visible := False;
    {$ENDIF}
    LoadFormData;
    //try load data

    if not BtnOK.Enabled then Exit;
    gInfo.FShowPrice := gPopedomManager.HasPopedom(nPopedom, sPopedom_ViewPrice);

    Caption := '�������';
    nBool := not gPopedomManager.HasPopedom(nPopedom, sPopedom_Edit);
    EditLading.Properties.ReadOnly := nBool;

    if nPopedom = 'MAIN_D04' then //����
         FBuDanFlag := sFlag_Yes
    else FBuDanFlag := sFlag_No;
    {$IFDEF QHSN}
    {$IFDEF GGJC}
    chkIfHYprint.Checked := True;
    {$ENDIF}
    {$ENDIF}
    if Assigned(nParam) then
    with PFormCommandParam(nParam)^ do
    begin
      FCommand := cCmd_ModalResult;
      FParamA := ShowModal;

      if FParamA = mrOK then
           FParamB := gInfo.FIDList
      else FParamB := '';
    end else ShowModal;
  finally
    Free;
  end;
end;

class function TfFormBill_brick.FormID: integer;
begin
  Result := cFI_FormBill_brick;
end;

procedure TfFormBill_brick.FormCreate(Sender: TObject);
var nStr: string;
    nIni,myini: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    {nStr := nIni.ReadString(Name, 'FQLabel', '');
    if nStr <> '' then
      dxLayout1Item5.Caption := nStr; }
    //xxxxx

    LoadMCListBoxConfig(Name, ListInfo, nIni);
    LoadcxListViewConfig(Name, ListBill, nIni);
  finally
    nIni.Free;
  end;

  AdjustCtrlData(Self);
end;

procedure TfFormBill_brick.FormClose(Sender: TObject; var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveMCListBoxConfig(Name, ListInfo, nIni);
    SavecxListViewConfig(Name, ListBill, nIni);
  finally
    nIni.Free;
  end;

  ReleaseCtrlData(Self);
end;

//Desc: �س���
procedure TfFormBill_brick.EditLadingKeyPress(Sender: TObject; var Key: Char);
var nP: TFormCommandParam;
begin
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;

    if Sender = EditStock then ActiveControl := EditValue else
    if Sender = EditValue then ActiveControl := BtnAdd else
    if Sender = EditTruck then ActiveControl := EditStock else

    if Sender = EditLading then
         ActiveControl := EditTruck
    else Perform(WM_NEXTDLGCTL, 0, 0);
  end;

  if (Sender = EditTruck) and (Key = Char(VK_SPACE)) then
  begin
    Key := #0;
    nP.FParamA := EditTruck.Text;
    CreateBaseFormItem(cFI_FormGetTruck, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and(nP.FParamA = mrOk) then
      EditTruck.Text := nP.FParamB;
    EditTruck.SelectAll;
  end;
end;

//------------------------------------------------------------------------------
//Desc: �����������
procedure TfFormBill_brick.LoadFormData;
var nStr,nTmp: string;
    nDB: TDataSet;
    i,nIdx: integer;
    nZcid: string;//��ͬ���
    nNewPrice: Double;
begin
  BtnOK.Enabled := False;
  initcbbcolor;
  nDB := LoadZhiKaInfo(gInfo.FZhiKa, ListInfo, nStr);

  if Assigned(nDB) then
  with gInfo do
  begin
    if nDB.FieldByName('Z_TriangleTrade').AsString = '1' then
    begin
      FCusID := nDB.FieldByName('Z_OrgAccountNum').AsString;
      EditHYCus.Text:= nDB.FieldByName('Z_OrgAccountName').AsString;
      FPriceChanged := nDB.FieldByName('Z_TJStatus').AsString = sFlag_TJOver;
      SetCtrlData(EditLading, nDB.FieldByName('Z_Lading').AsString);
      FSalesType:=nDB.fieldByName('Z_SalesType').AsString; //0:������־���Ͳ�У�����ö��
      if Trim(nDB.FieldByName('Z_inventlocationid').AsString)<>'' then
        Finventlocationid := nDB.FieldByName('Z_inventlocationid').AsString;
      GetCustomerExt(FCusID,EditHYCus);
    end else
    begin
      FCusID := nDB.FieldByName('Z_Customer').AsString;
      EditHYCus.Text:= nDB.FieldByName('C_Name').AsString;
      FPriceChanged := nDB.FieldByName('Z_TJStatus').AsString = sFlag_TJOver;
      SetCtrlData(EditLading, nDB.FieldByName('Z_Lading').AsString);
      FSalesType:=nDB.fieldByName('Z_SalesType').AsString; //0:������־���Ͳ�У�����ö��
      if Trim(nDB.FieldByName('Z_inventlocationid').AsString)<>'' then
        Finventlocationid := nDB.FieldByName('Z_inventlocationid').AsString;
      GetCustomerExt(FCusID,EditHYCus);
    end;
    //FMoney := GetZhikaValidMoney(gInfo.FZhiKa, gInfo.FOnlyMoney);
  end else
  begin
    ShowMsg(nStr, sHint); Exit;
  end;
  {if gInfo.FSalesType <> '0' then
    BtnOK.Enabled := IsCustomerCreditValid(gInfo.FCusID)
  else}
    BtnOK.Enabled := True;
  if not BtnOK.Enabled then Exit;
  //to verify credit

  SetLength(gStockList, 0);
  nStr := 'Select D_Type,upper(D_StockNo) as D_StockNo1,* From %s Where D_Blocked=''0'' and D_ZID=''%s''';
  nStr := Format(nStr, [sTable_ZhiKaDtl, gInfo.FZhiKa]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    nStr := '';
    nIdx := 0;
    SetLength(gStockList, RecordCount);

    First;  
    while not Eof do
    with gStockList[nIdx] do
    begin
      FType := FieldByName('D_Type').AsString;
//      if FType = '0' then FType:='S';
      FStockNO := FieldByName('D_StockNo1').AsString;
      if FType='D' then
        FStockName := FieldByName('D_StockName').AsString+'��װ'
      else if FType='S' then
        FStockName := FieldByName('D_StockName').AsString+'ɢװ'
      else
        FStockName := FieldByName('D_StockName').AsString;
      if FType = '0' then FType:='S';
      FPrice := FieldByName('D_Price').AsFloat;
        //FValue := 0;
      FValue:= FieldByName('D_Value').AsFloat;
      FSelecte := False;
      FRecID := FieldByName('D_RECID').AsString;
      {if gInfo.FPriceChanged then
      begin
        nTmp := 'Ʒ��:[ %-8s ] ԭ��:[ %.2f ] �ּ�:[ %.2f ]' + #32#32;
        nTmp := Format(nTmp, [FStockName, FieldByName('D_PPrice').AsFloat, FPrice]);
        nStr := nStr + nTmp + #13#10;
      end;}

      Inc(nIdx);
      Next;
    end;
    for i:=Low(gStockList) to High(gStockList) do
    begin
      if LoadAddTreaty(gStockList[i].FRecID,nNewPrice) then
        gStockList[i].FPrice:=nNewPrice;
      gStockList[i].FValue:=GetZhikaYL(gStockList[i].FRecID);
    end;
  end else
  begin
    nStr := Format('ֽ��[ %s ]û�п����ˮ��Ʒ��,����ֹ.', [gInfo.FZhiKa]);
    ShowDlg(nStr, sHint);
    BtnOK.Enabled := False; Exit;
  end;

  {if gInfo.FPriceChanged then
  begin
    nStr := '����Ա�ѵ���ֽ��[ %s ]�ļ۸�,��ϸ����: ' + #13#10#13#10 +
            AdjustHintToRead(nStr) + #13#10 +
            '��ѯ�ʿͻ��Ƿ�����µ���,���ܵ�"��"��ť.' ;
    nStr := Format(nStr, [gInfo.FZhiKa]);

    BtnOK.Enabled := QueryDlg(nStr, sHint);
    if not BtnOK.Enabled then Exit;

    nStr := 'Update %s Set Z_TJStatus=Null Where Z_ID=''%s''';
    nStr := Format(nStr, [sTable_ZhiKa, gInfo.FZhiKa]);
    FDM.ExecuteSQL(nStr);
  end; }

  LoadStockList;
  //load stock into window
  
  //EditType.ItemIndex := 0;
  ActiveControl := EditTruck;
end;

//Desc: ˢ��ˮ���б�����
procedure TfFormBill_brick.LoadStockList;
var nStr: string;
    i,nIdx: integer;
begin
  AdjustCXComboBoxItem(EditStock, True);
  nIdx := ListBill.ItemIndex;

  ListBill.Items.BeginUpdate;
  try
    ListBill.Clear;
    for i:=Low(gStockList) to High(gStockList) do
    if gStockList[i].FSelecte then
    begin
      with ListBill.Items.Add do
      begin
        Caption := gStockList[i].FStockName;
        SubItems.Add(EditTruck.Text);
        SubItems.Add(FloatToStr(gStockList[i].FValue));
        SubItems.Add(cbbColor.Text);
        Data := Pointer(i);
        ImageIndex := cItemIconIndex;
      end;
    end else
    begin
      nStr := Format('%d=%s', [i, gStockList[i].FStockName]);
      EditStock.Properties.Items.Add(nStr);
    end;
  finally
    ListBill.Items.EndUpdate;
    if ListBill.Items.Count > nIdx then
      ListBill.ItemIndex := nIdx;
    //xxxxx

    AdjustCXComboBoxItem(EditStock, False);
    EditStock.ItemIndex := gSelect;
    cbbColor.ItemIndex := -1;
  end;
end;

//Dessc: ѡ��Ʒ��
procedure TfFormBill_brick.EditStockPropertiesChange(Sender: TObject);
var nInt: Int64;
begin
  dxGroup2.Caption := '�ᵥ��ϸ';
  if EditStock.ItemIndex < 0 then Exit;

  with gStockList[StrToInt(GetCtrlData(EditStock))] do
  begin
    if FPrice > 0 then
    begin
      //nInt := Float2PInt(gInfo.FMoney / FPrice, cPrecision, False);
      nInt := Float2PInt(FValue, cPrecision, False);
      EditValue.Text := FloatToStr(nInt / cPrecision);

      if gInfo.FShowPrice then
        dxGroup2.Caption := Format('�ᵥ��ϸ ����:%.2fԪ/ƽ', [FPrice]);
      //xxxxx
    end;
  end;
end;

function TfFormBill_brick.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
var nVal: Double;
begin
  Result := True;

  if Sender = EditStock then
  begin
    Result := EditStock.ItemIndex > -1;
    nHint := '��ѡ��ˮ������';
  end else

  if Sender = EditTruck then
  begin
    Result := Length(EditTruck.Text) > 2;
    nHint := '���ƺų���Ӧ����2λ';
  end else

  if Sender = EditLading then
  begin
    Result := EditLading.ItemIndex > -1;
    nHint := '��ѡ����Ч�������ʽ';
  end
  else if Sender = cbbColor then
  begin
    Result := cbbColor.ItemIndex > -1;
    nHint := '��ѡ����ɫ';
  end
  else if Sender = EditValue then
  begin
    Result := IsNumber(EditValue.Text, True) and (StrToFloat(EditValue.Text)>0);
    nHint := '����д��Ч�İ�����';

    if not Result then Exit;
    if not OnVerifyCtrl(EditStock, nHint) then Exit;

    with gStockList[StrToInt(GetCtrlData(EditStock))] do
    if FPrice > 0 then
    begin
      nVal := StrToFloat(EditValue.Text);
      nVal := Float2Float(nVal, cPrecision, False);
      //Result := FloatRelation(gInfo.FMoney / FPrice, nVal, rtGE, cPrecision);
      Result := FloatRelation(FValue, nVal, rtGE, cPrecision);

      nHint := '�ѳ����ɰ�����';
      if not Result then Exit;

      //if FloatRelation(gInfo.FMoney / FPrice, nVal, rtEqual, cPrecision) then
      if FloatRelation(FValue, nVal, rtEqual, cPrecision) then
      begin
        nHint := '';
        Result := QueryDlg('ȷ��Ҫ�����������ȫ��������?', sAsk);
        if not Result then ActiveControl := EditValue;
      end;
    end else
    begin
      Result := False;
      nHint := '����[ 0 ]��Ч';
    end;
  end;
end;

//Desc: ���
procedure TfFormBill_brick.BtnAddClick(Sender: TObject);
var nIdx: Integer;
    nSampleDate: string;
    nLocationID: string;
begin
  if IsDataValid then
  begin
    nIdx := StrToInt(GetCtrlData(EditStock));
    with gStockList[nIdx] do
    begin
      if (FType = sFlag_San) and (ListBill.Items.Count > 0) then
      begin
        ShowMsg('����ש�鲻�ܻ�װ', sHint);
        ActiveControl := EditStock;
        Exit;
      end;
      FValue := StrToFloat(EditValue.Text);
      FValue := Float2Float(FValue, cPrecision, False);
      InitCenter(FStockNO,FType,cbxCenterID);
      gStockName:=FStockName;
      gType:=FType;
      Fcolor := cbbColor.Text;
      {$IFDEF YDKP}
      if pos('��',FStockName)>0 then
      begin
        InitKuWei('����',cbxKw);
      end else
      if pos('��',FStockName)>0 then
      begin
        InitKuWei('��װ',cbxKw);
      end else
      begin
        InitKuWei('ɢװ',cbxKw);
      end;
      {$ENDIF}
      FSelecte := True;

      EditTruck.Properties.ReadOnly := True;
      //gInfo.FMoney := gInfo.FMoney - FPrice * FValue;
    end;

    LoadStockList;
    ActiveControl := BtnOK;
  end;
end;

//Desc: ɾ��
procedure TfFormBill_brick.BtnDelClick(Sender: TObject);
var nIdx: integer;
begin
  if ListBill.ItemIndex > -1 then
  begin
    nIdx := Integer(ListBill.Items[ListBill.ItemIndex].Data);
    with gStockList[nIdx] do
    begin
      FSelecte := False;
      //gInfo.FMoney := gInfo.FMoney + FPrice * FValue;
    end;

    LoadStockList;
    EditTruck.Properties.ReadOnly := ListBill.Items.Count > 0;
    cbxCenterID.ItemIndex:=-1;
    cbxSampleID.ItemIndex:=-1;
  end;
end;

//Desc: ����
procedure TfFormBill_brick.BtnOKClick(Sender: TObject);
var nIdx: Integer;
    nPrint: Boolean;
    nList,nTmp,nStocks: TStrings;
    nPos: Integer;
    nPlanW,nBatQuaS,nBatQuaE:Double;
    FSumTon:Double;
    nStr,nCenterYL,nStockNo,nCenterID:string;
    nYL:Double;
begin
  FSumTon:=0.00;
  if ListBill.Items.Count < 1 then
  begin
    ShowMsg('���Ȱ��������', sHint); Exit;
  end;
  if cbxCenterID.ItemIndex=-1 then
  begin
    ShowMsg('��ѡ��������', sHint); Exit;
  end;
  nPos:=Pos('.',cbxCenterID.Text);
  if nPos>0 then
    nCenterID:=Copy(cbxCenterID.Text,1,nPos-1)
  else begin
    ShowMsg('�����߸�ʽ�Ƿ�', sHint); Exit;
  end;
  if Trim(EditJXSTHD.Text) = '' then
  begin
    ShowMsg('��¼�뾭�����������', sHint); Exit;
  end;

  nStocks := TStringList.Create;
  nList := TStringList.Create;
  nTmp := TStringList.Create;
  try
    nList.Clear;
    nPrint := False;
    LoadSysDictItem(sFlag_PrintBill, nStocks);
    //���ӡƷ��

    for nIdx:=Low(gStockList) to High(gStockList) do
    with gStockList[nIdx],nTmp do
    begin
      if not FSelecte then Continue;
      //xxxxx
      Values['szbz'] := '0';
      if Fszbz then Values['szbz'] := '1';
      Values['color'] := Fcolor;
      Values['Type'] := FType;
      Values['Type'] := FType;
      Values['StockNO'] := FStockNO;
      Values['StockName'] := FStockName;
      Values['Price'] := FloatToStr(FPrice);
      Values['Value'] := FloatToStr(FValue);
      Values['RECID'] := FRecID;
      {$IFDEF YDKP}//��Ʊ¼���������
      if cbxSampleID.Enabled=True then
      begin
        if LoadNoSampleID(FStockNO) then
        begin
          FSampleID:='';
        end else
        begin
          if cbxSampleID.ItemIndex < 0 then
          begin
            ShowMsg('��ѡ��������ţ�',sHint);
            Exit;
          end;
          FSampleID:=cbxSampleID.Text;
        end;
      end else
      begin
        FSampleID:='';
      end;
      if FSampleID <> '' then
      begin
        FSumTon:=GetSumTonnage(FSampleID);
        cxLabel1.Caption:=Floattostr(FSumTon);
        if GetSampleTonnage(FSampleID, nBatQuaS, nBatQuaE) then
        begin
          if FSumTon-nBatQuaS>0 then
          begin
            ShowMsg('�������['+FSampleID+']�ѳ���',sHint);
            if UpdateSampleValid(FSampleID) then
              InitSampleID(FStockName,FType,nCenterID,cbxSampleID);
            Exit;
          end;

          nPlanW:=FValue;
          FSumTon:=FSumTon+nPlanW;
          if nBatQuaS-FSumTon<=nBatQuaE then    //��Ԥ����
          begin
            nStr:='�������['+FSampleID+']�ѵ�Ԥ����,�Ƿ�������棿';
            if not QueryDlg(nStr, sAsk) then
            begin
              if UpdateSampleValid(FSampleID) then
              InitSampleID(FStockName,FType,nCenterID,cbxSampleID);
              Exit;
            end;
          end;
          if FSumTon-nBatQuaS>0 then
          begin
            ShowMsg('�������['+FSampleID+']�ѳ���',sHint);
            Exit;
          end;
        end else
        begin
          ShowMsg('�������['+FSampleID+']��ʧЧ',sHint);
          Exit;
        end;
      end;
      {$ENDIF}
      {$IFDEF PLKP}//��Ʊ¼���������
      if cbxSampleID.Enabled=True then
      begin
        if LoadNoSampleID(FStockNO) then
        begin
          FSampleID:='';
        end else
        begin
          if cbxSampleID.ItemIndex < 0 then
          begin
            ShowMsg('��ѡ��������ţ�',sHint);
            Exit;
          end;
          FSampleID:=cbxSampleID.Text;
        end;
      end else
      begin
        FSampleID:='';
      end;
      if FSampleID <> '' then
      begin
        FSumTon:=GetSumTonnage(FSampleID);
        cxLabel1.Caption:=Floattostr(FSumTon);
        if GetSampleTonnage(FSampleID, nBatQuaS, nBatQuaE) then
        begin
          if FSumTon-nBatQuaS>0 then
          begin
            ShowMsg('�������['+FSampleID+']�ѳ���',sHint);
            if UpdateSampleValid(FSampleID) then
              InitSampleID(FStockName,FType,nCenterID,cbxSampleID);
            Exit;
          end;

          nPlanW:=FValue;
          FSumTon:=FSumTon+nPlanW;
          if nBatQuaS-FSumTon<=nBatQuaE then    //��Ԥ����
          begin
            nStr:='�������['+FSampleID+']�ѵ�Ԥ����,�Ƿ�������棿';
            if not QueryDlg(nStr, sAsk) then
            begin
              if UpdateSampleValid(FSampleID) then
              InitSampleID(FStockName,FType,nCenterID,cbxSampleID);
              Exit;
            end;
          end;
          if FSumTon-nBatQuaS>0 then
          begin
            ShowMsg('�������['+FSampleID+']�ѳ���',sHint);
            Exit;
          end;
        end else
        begin
          ShowMsg('�������['+FSampleID+']��ʧЧ',sHint);
          Exit;
        end;
      end;
      {$ENDIF}
      {$IFDEF QHSN}//��Ʊ¼���������
      if cbxSampleID.Enabled=True then
      begin
        if LoadNoSampleID(FStockNO) then
        begin
          FSampleID:='';
        end else
        begin
          if (Pos('����',FStockName)<=0) then
          begin
            FSampleID:='';
          end else
          begin
            if cbxSampleID.ItemIndex < 0 then
            begin
              ShowMsg('��ѡ��������ţ�',sHint);
              Exit;
            end;
            FSampleID:=cbxSampleID.Text;
          end;
        end;
      end else
      begin
        FSampleID:='';
      end;
      if FSampleID <> '' then
      begin
        FSumTon:=GetSumTonnage(FSampleID);
        cxLabel1.Caption:=Floattostr(FSumTon);
        if GetSampleTonnage(FSampleID, nBatQuaS, nBatQuaE) then
        begin
          if FSumTon-nBatQuaS>0 then
          begin
            ShowMsg('�������['+FSampleID+']�ѳ���',sHint);
            if UpdateSampleValid(FSampleID) then
              InitSampleID(FStockName,FType,nCenterID,cbxSampleID);
            Exit;
          end;

          nPlanW:=FValue;
          FSumTon:=FSumTon+nPlanW;
          if nBatQuaS-FSumTon<=nBatQuaE then    //��Ԥ����
          begin
            nStr:='�������['+FSampleID+']�ѵ�Ԥ����,�Ƿ�������棿';
            if not QueryDlg(nStr, sAsk) then
            begin
              if UpdateSampleValid(FSampleID) then
              InitSampleID(FStockName,FType,nCenterID,cbxSampleID);
              Exit;
            end;
          end;
          if FSumTon-nBatQuaS>0 then
          begin
            ShowMsg('�������['+FSampleID+']�ѳ���',sHint);
            Exit;
          end;
        end else
        begin
          ShowMsg('�������['+FSampleID+']��ʧЧ',sHint);
          Exit;
        end;
      end;
      {$ENDIF}
      Values['SampleID'] := FSampleID;
      nStockNo:= Values['StockNO'];

      nList.Add(PackerEncodeStr(nTmp.Text));
      //new bill
      if (not nPrint) and (FBuDanFlag <> sFlag_Yes) then
        nPrint := nStocks.IndexOf(FStockNO) >= 0;
      //xxxxx
    end;

    with nList do
    begin
      Values['Bills'] := PackerEncodeStr(nList.Text);
      Values['LID'] := '';
      Values['ZhiKa'] := gInfo.FZhiKa;
      Values['Truck'] := EditTruck.Text;
      Values['Lading'] := GetCtrlData(EditLading);
      //Values['VPListID']:=
      Values['IsVIP'] := GetCtrlData(EditType);
      //Values['Seal'] := EditFQ.Text;
      Values['BuDan'] := FBuDanFlag;
      if chkIfHYprint.Checked then
        Values['IfHYprt'] := 'Y'
      else
        Values['IfHYprt'] := 'N';
      Values['SalesType'] := gInfo.FSalesType;
      Values['CenterID']:= nCenterID;
      Values['JXSTHD'] := Trim(EditJXSTHD.Text);
      Values['Project'] := Trim(EditHYCus.Text);
      Values['WebOrderID'] := '';
      Values['ToAddr'] := '';
      Values['IdNumber'] := '';
      {$IFDEF QHSN}
      if chkFenChe.Checked then
        Values['IfFenChe'] := 'Y'
      else
        Values['IfFenChe'] := 'N';
      {$ELSE}
      Values['IfFenChe'] := 'N';
      {$ENDIF}
      {$IFDEF YDKP}
      if cbxKw.Itemindex< 0 then
      begin
        ShowMsg('��ѡ���λ��', sHint); Exit;
      end;
      nPos:=Pos('.',cbxKw.Text);
      if (nPos>0) and (nPos<Length(cbxKw.Text)) then
      begin
        Values['KuWei']:= Copy(cbxKw.Text,1,nPos-1);
        Values['LocationID']:= Copy(cbxKw.Text,nPos+1,Length(cbxKw.Text)-nPos);
      end else
      begin
        ShowMsg('��λ��ʽ�Ƿ�', sHint); Exit;
      end;
      {$ELSE}
      Values['KuWei'] := '';
      Values['LocationID']:= gInfo.Finventlocationid;
      {$ENDIF}
      {nCenterYL:=GetCenterSUM(nStockNo,Values['CenterID']);
      if nCenterYL <> '' then
      begin
        if IsNumber(nCenterYL,True) then
        begin
          nYL:= StrToFloat(nCenterYL);
          if nYL <= 0 then
          begin
            ShowMsg('�������������㣺'+#13#10+FormatFloat('0.00',nYL),sHint);
            Exit;
          end;
        end;
      end; }
    end; 
    gInfo.FIDList := SaveBill(PackerEncodeStr(nList.Text));
    //call mit bus
    if gInfo.FIDList = '' then Exit;
  finally
    nTmp.Free;
    nList.Free;
    nStocks.Free;
  end;

  SaveCustomerExt(gInfo.FCusID,Trim(EditHYCus.Text));
  if FBuDanFlag <> sFlag_Yes then
    SetBillCard(gInfo.FIDList, EditTruck.Text, True);
  //����ſ�
  {$IFDEF PLKP}
  if nPrint then
    PrintDaiBill(gInfo.FIDList, False);
  {$ELSE}
  if PrintYesNo then
    PrintDaiBill(gInfo.FIDList, False);
  {$ENDIF}
  //print report
  
  ModalResult := mrOk;
  ShowMsg('���������ɹ�', sHint);
end;

procedure TfFormBill_brick.cbxSampleIDPropertiesChange(Sender: TObject);
begin
  {$IFDEF YDKP}
  if cbxSampleID.ItemIndex > -1 then chkIfHYprint.Checked:=True;
  {$ENDIF}
  if cxLabel1.Visible = True then
    cxLabel1.Caption:=Floattostr(GetSumTonnage(cbxSampleID.Text));
end;

procedure TfFormBill_brick.cbxCenterIDPropertiesEditValueChanged(
  Sender: TObject);
var
  nPos:Integer;
  nCenterID:string;
begin
  {$IFDEF YDKP}
  if cbxCenterID.ItemIndex>-1 then
  begin
    nPos:=Pos('.',cbxCenterID.Text);
    if nPos>0 then
      nCenterID:=Copy(cbxCenterID.Text,1,nPos-1)
    else begin
      ShowMsg('�����߸�ʽ�Ƿ�', sHint); Exit;
    end;
    InitSampleID(gStockName,gType,nCenterID,cbxSampleID);
  end;
  {$ENDIF}
  {$IFDEF PLKP}
  if cbxCenterID.ItemIndex>-1 then
  begin
    nPos:=Pos('.',cbxCenterID.Text);
    if nPos>0 then
      nCenterID:=Copy(cbxCenterID.Text,1,nPos-1)
    else begin
      ShowMsg('�����߸�ʽ�Ƿ�', sHint); Exit;
    end;
    InitSampleID(gStockName,gType,nCenterID,cbxSampleID);
  end;
  {$ENDIF}
  {$IFDEF QHSN}
  if cbxCenterID.ItemIndex>-1 then
  begin
    nPos:=Pos('.',cbxCenterID.Text);
    if nPos>0 then
      nCenterID:=Copy(cbxCenterID.Text,1,nPos-1)
    else begin
      ShowMsg('�����߸�ʽ�Ƿ�', sHint); Exit;
    end;
    InitSampleID(gStockName,gType,nCenterID,cbxSampleID);
  end;
  {$ENDIF}
end;

procedure TfFormBill_brick.initcbbcolor;
var
  nStr:string;
  nDs:TDataSet;
begin
  cbbColor.Properties.Items.Clear;
  nStr := 'select * from %s where d_name=''%s''';
  nStr := Format(nStr,[sTable_SysDict,sFlag_brickcolor]);
  nds := FDM.QueryTemp(nStr);
  while not nds.Eof do
  begin
    cbbColor.Properties.Items.Add(nds.FieldByName('d_value').asString);
    nds.Next;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormBill_brick, TfFormBill_brick.FormID);
end.
