{*******************************************************************************
  ����: dmzn@163.com 2010-3-14
  ����: װ���߹���
*******************************************************************************}
unit UFormZTLine;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxDropDownEdit,
  cxLabel, cxCheckBox, cxTextEdit, dxLayoutControl, StdCtrls,
  dxLayoutcxEditAdapters;

type
  TfFormZTLine = class(TfFormNormal)
    EditName: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditID: TcxTextEdit;
    LayItem1: TdxLayoutItem;
    EditMax: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    CheckValid: TcxCheckBox;
    dxLayout1Item7: TdxLayoutItem;
    EditStockName: TcxTextEdit;
    dxLayout1Item8: TdxLayoutItem;
    dxLayout1Group2: TdxLayoutGroup;
    dxLayout1Group3: TdxLayoutGroup;
    cxLabel2: TcxLabel;
    dxLayout1Item10: TdxLayoutItem;
    dxLayout1Group4: TdxLayoutGroup;
    EditPeer: TcxTextEdit;
    dxLayout1Item19: TdxLayoutItem;
    dxLayout1Item20: TdxLayoutItem;
    cxLabel4: TcxLabel;
    dxLayout1Group9: TdxLayoutGroup;
    EditStockID: TcxComboBox;
    dxLayout1Item21: TdxLayoutItem;
    EditType: TcxComboBox;
    dxLayout1Item3: TdxLayoutItem;
    dxLayout1Item22: TdxLayoutItem;
    cxLabel5: TcxLabel;
    dxLayout1Group10: TdxLayoutGroup;
    dxLayout1Group12: TdxLayoutGroup;
    cbxCenterID: TcxComboBox;
    dxLayout1Item6: TdxLayoutItem;
    cbxLocationID: TcxComboBox;
    dxLayout1Item9: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
    procedure EditStockIDPropertiesChange(Sender: TObject);
    procedure cbxLocationIDPropertiesChange(Sender: TObject);
    procedure cbxCenterIDPropertiesChange(Sender: TObject);
  protected
    { Protected declarations }
    FID: string;
    //��ʶ
    procedure InitFormData(const nID: string);
    procedure GetData(Sender: TObject; var nData: string);
    function SetData(Sender: TObject; const nData: string): Boolean;
    //���ݴ���
  public
    { Public declarations }
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

function ShowAddZTLineForm: Boolean;
function ShowEditZTLineForm(const nID: string): Boolean;
//��ں���

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UMgrControl, UDataModule, UFormInputbox, USysGrid,
  UFormCtrl, USysDB, USysConst ,USysLoger;

type
  TLineStockItem = record
    FID   : string;
    FName : string;
    FGroup: string;
  end;
  TCenterItem = record
    FGroup: string;
    FID   : string;
    FName : string;
  end;
  TLocationItem = record
    FID   : string;
    FName : string;
  end;

var
  gStockItems: array of TLineStockItem;
  //Ʒ���б�
   gCheckValid: boolean;
  //ͨ����ѡ����
  gCenterItem: array of TCenterItem;
  //�������б�
  gLocationItem: array of TLocationItem;
  //�ֿ��б�

function ShowAddZTLineForm: Boolean;
begin
  with TfFormZTLine.Create(Application) do
  try
    FID := '';
    Caption := 'װ���� - ���';

    InitFormData('');
    Result := ShowModal = mrOk;
  finally
    Free;
  end;
end;

function ShowEditZTLineForm(const nID: string): Boolean;
begin
  with TfFormZTLine.Create(Application) do
  try
    FID := nID;
    Caption := 'װ���� - �޸�';

    InitFormData(nID);
    Result := ShowModal = mrOk;
  finally
    Free;
  end;
end;

class function TfFormZTLine.FormID: integer;
begin
  Result := cFI_FormZTLine;
end;

class function TfFormZTLine.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
begin
  Result := nil;
end;

//------------------------------------------------------------------------------
procedure TfFormZTLine.InitFormData(const nID: string);
var nStr: string;
    nIdx: Integer;
begin
  ResetHintAllForm(Self, 'T', sTable_ZTLines);
  //���ñ�����

  if nID <> '' then
  begin
    EditID.Properties.ReadOnly := True;
    nStr := 'Select * From %s Where Z_ID=''%s''';
    nStr := Format(nStr, [sTable_ZTLines, nID]);

    if FDM.QueryTemp(nStr).RecordCount > 0 then
    begin
      EditStockID.Text := FDM.SqlTemp.FieldByName('Z_StockNo').AsString;
      cbxCenterID.Text := FDM.SqlTemp.FieldByName('Z_CenterID').AsString;
      cbxLocationID.Text:= FDM.SqlTemp.FieldByName('Z_LocationID').AsString;
      LoadDataToCtrl(FDM.SqlTemp, Self, '', SetData);
    end;
  end;

  nStr := 'Select D_Value,D_ParamB+D_Memo as D_ParamB,D_Desc From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_StockItem]);

  EditStockID.Properties.Items.Clear;
  SetLength(gStockItems, 0);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then Exit;
    SetLength(gStockItems, RecordCount);

    nIdx := 0;
    First;

    while not Eof do
    begin
      with gStockItems[nIdx] do
      begin
        FID := Fields[1].AsString;
        FName := Fields[0].AsString;
        FGroup := Fields[2].AsString;
        EditStockID.Properties.Items.AddObject(FID + '.' + FName, Pointer(nIdx));
      end;

      Inc(nIdx);
      Next;
    end;
  end;

  nStr := 'select a.G_ItemGroupID,a.G_InventCenterID,b.I_Name from %s a,%s b '+  //�������б�
          'where a.G_InventCenterID=b.I_CenterID ';
  nStr := Format(nStr, [sTable_InvCenGroup,sTable_InventCenter]);
  SetLength(gCenterItem, 0);
  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then Exit;
    SetLength(gCenterItem, RecordCount);

    nIdx := 0;
    First;

    while not Eof do
    begin
      with gCenterItem[nIdx] do
      begin
        FGroup:= Fields[0].AsString;
        FID := Fields[1].AsString;
        FName := Fields[2].AsString;
      end;

      Inc(nIdx);
      Next;
    end;
  end;

  nStr := 'Select I_LocationID,I_Name From %s '; //�ֿ��б�
  nStr := Format(nStr, [sTable_InventLocation]);

  cbxLocationID.Properties.Items.Clear;
  SetLength(gLocationItem, 0);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then Exit;
    SetLength(gLocationItem, RecordCount);

    nIdx := 0;
    First;

    while not Eof do
    begin
      with gLocationItem[nIdx] do
      begin
        FID := Fields[0].AsString;
        FName := Fields[1].AsString;
        cbxLocationID.Properties.Items.AddObject(FID + '.' + FName, Pointer(nIdx));
      end;

      Inc(nIdx);
      Next;
    end;
  end;
  if nID<>'' then
  begin
    EditStockIDPropertiesChange(EditStockID);
  end;
end;

procedure TfFormZTLine.EditStockIDPropertiesChange(Sender: TObject);
var nIdx,i: Integer;
begin
//  if (not EditStockID.Focused) or (EditStockID.ItemIndex < 0) then Exit;
  if (EditStockID.ItemIndex < 0) then Exit;
  try
    nIdx := Integer(EditStockID.Properties.Items.Objects[EditStockID.ItemIndex]);
  except
  end;
  EditStockName.Text := gStockItems[nIdx].FName;
  cbxCenterID.Properties.Items.Clear;
  for i:= Low(gCenterItem) to High(gCenterItem) do
  begin
    if gStockItems[nIdx].FGroup=gCenterItem[i].FGroup then
      cbxCenterID.Properties.Items.AddObject(gCenterItem[i].FID + '.' + gCenterItem[i].FName, Pointer(nIdx));
  end;
end;

function TfFormZTLine.SetData(Sender: TObject; const nData: string): Boolean;
begin
  Result := False;

  if Sender = EditType then
  begin
    Result := True;
    if nData = sFlag_TypeVIP then
      EditType.ItemIndex := 1 else
    if nData = sFlag_TypeZT then
      EditType.ItemIndex := 2 else
    if nData = sFlag_TypeShip then
      EditType.ItemIndex := 3
    else EditType.ItemIndex := 0;
  end else
  
  if Sender = CheckValid then
  begin
    Result := True;
    CheckValid.Checked := nData <> sFlag_No;
  end;
end;

procedure TfFormZTLine.GetData(Sender: TObject; var nData: string);
begin
  if Sender = EditType then
  begin
    case EditType.ItemIndex of
     0: nData := sFlag_TypeCommon;
     1: nData := sFlag_TypeVIP;
     2: nData := sFlag_TypeZT;
     3: nData := sFlag_TypeShip else nData := sFlag_TypeCommon;
    end;
  end else

  if Sender = CheckValid then
  begin
    if CheckValid.Checked   then
    begin
      nData := sFlag_Yes;
      gCheckValid := true;
    end else
    begin
      nData := sFlag_No;
      gCheckValid := false;
    end;
  end;
end;

function TfFormZTLine.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
var nVal: Integer;
begin
  Result := True;

  if Sender = EditID then
  begin
    EditID.Text := Trim(EditID.Text);
    Result := EditID.Text <> '';
    nHint := '����д��Ч���';
  end else

  if Sender = EditName then
  begin
    EditName.Text := Trim(EditName.Text);
    Result := EditName.Text <> '';
    nHint := '����д��Ч����';
  end else

  if Sender = EditStockID then
  begin
    Result := EditStockID.ItemIndex >= 0;
    nHint := '��ѡ��Ʒ��';
  end else

  if Sender = EditMax then
  begin
    Result := IsNumber(EditMax.Text, False);
    nHint := '������Ϊ�����������';
    if not Result then Exit;

    nVal := StrToInt(EditMax.Text);
    Result := (nVal > 0) and (nVal <= 50);
    nHint := '��������1-50֮��'
  end else

  if Sender= cbxCenterID then
  begin
    cbxCenterID.Text:=Trim(cbxCenterID.Text);
    Result:=cbxCenterID.Text<>'';
    nHint:= '��ѡ��������';
  end else

  {if Sender= cbxLocationID then
  begin
    cbxLocationID.Text:=Trim(cbxLocationID.Text);
    Result:=cbxLocationID.Text<>'';
    nHint:= '��ѡ��ֿ�';
  end else}
  if Sender = EditPeer then
  begin
    Result := IsNumber(EditPeer.Text, False) and (StrToInt(EditPeer.Text) > 0);
    nHint := '����Ϊ����0������';
    if not Result then Exit;
  end;

end;

procedure TfFormZTLine.BtnOKClick(Sender: TObject);
var nIdx: Integer;
    nList: TStrings;
    nStr,nEvent: string;
begin
  if not IsDataValid then Exit;

  nList := TStringList.Create;
  try
    nIdx := Integer(EditStockID.Properties.Items.Objects[EditStockID.ItemIndex]);
    nList.Add(Format('Z_StockNo=''%s''', [gStockItems[nIdx].FID]));
    for nIdx:= Low(gCenterItem) to High(gCenterItem) do
    begin
      if gCenterItem[nIdx].FID+'.'+gCenterItem[nIdx].FName=Trim(cbxCenterID.Text) then
      begin
        nList.Add(Format('Z_CenterID=''%s''', [gCenterItem[nIdx].FID]));
        Break;
      end;
    end;
    {nIdx := Integer(cbxLocationID.Properties.Items.Objects[cbxLocationID.ItemIndex]);
    nList.Add(Format('Z_LocationID=''%s''', [gLocationItem[nIdx].FID])); }

    //ext fields

    if FID = '' then
    begin
      nStr := MakeSQLByForm(Self, sTable_ZTLines, '', True, GetData, nList);
    end else
    begin
      nStr := Format('Z_ID=''%s''', [FID]);
      nStr := MakeSQLByForm(Self, sTable_ZTLines, nStr, False, GetData, nList);
    end;
  finally
    nList.Free;
  end;

  FDM.ExecuteSQL(nStr);
  ModalResult := mrOk;

  //--------------
  if   gCheckValid = false then
  begin
       nEvent := 'ͨ�� [ %s ] �ر�';
       nEvent := Format(nEvent, [EditID.Text]);
       FDM.WriteSysLog(sFlag_TruckQueue, 'UFromZTline', nEvent);
  end;
  if   gCheckValid = true  then
  begin
       nEvent := 'ͨ�� [ %s ] ����';
       nEvent := Format(nEvent, [EditID.Text]);
       FDM.WriteSysLog(sFlag_TruckQueue, 'UFromZTline',nEvent);
  end;
  //--д�����ͨ����־
  ShowMsg('ͨ���ѱ���,��ȴ�ˢ��', sHint);
end;

procedure TfFormZTLine.cbxLocationIDPropertiesChange(Sender: TObject);
var nIdx:Integer;
begin
  inherited;
  if (not cbxLocationID.Focused) or (cbxLocationID.ItemIndex < 0) then Exit;
  nIdx := Integer(cbxLocationID.Properties.Items.Objects[cbxLocationID.ItemIndex]);
  //cbxLocationID.Text:=gLocationItem[nIdx].FID;
end;

procedure TfFormZTLine.cbxCenterIDPropertiesChange(Sender: TObject);
var nIdx:Integer;
begin
  inherited;
//  if (not cbxCenterID.Focused) or (cbxCenterID.ItemIndex < 0) then Exit;
//  nIdx := Integer(cbxCenterID.Properties.Items.Objects[cbxCenterID.ItemIndex]);
  //cbxCenterID.Text:=gCenterItem[nIdx].FID;
end;

initialization
  gControlManager.RegCtrl(TfFormZTLine, TfFormZTLine.FormID);
end.
