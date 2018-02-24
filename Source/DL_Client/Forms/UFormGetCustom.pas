{*******************************************************************************
  ����: dmzn@163.com 2010-3-9
  ����: ѡ��ͻ�
*******************************************************************************}
unit UFormGetCustom;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxContainer, cxEdit, cxTextEdit,
  cxMaskEdit, cxDropDownEdit, dxLayoutControl, StdCtrls, cxControls,
  ComCtrls, cxListView, cxButtonEdit, cxLabel, cxLookAndFeels,
  cxLookAndFeelPainters, dxLayoutcxEditAdapters;

type
  TfFormGetCustom = class(TfFormNormal)
    EditCustom: TcxComboBox;
    dxLayout1Item4: TdxLayoutItem;
    EditCus: TcxButtonEdit;
    dxLayout1Item5: TdxLayoutItem;
    ListCustom: TcxListView;
    dxLayout1Item6: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item7: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
    procedure ListCustomKeyPress(Sender: TObject; var Key: Char);
    procedure EditCIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditCustomPropertiesEditValueChanged(Sender: TObject);
    procedure ListCustomDblClick(Sender: TObject);
  private
    { Private declarations }
    FStatus:Boolean;
    //�ͻ���Ϣ״̬ False���� True����
    FCusID,FCusName,FSaleID,FXSQYMC: string;
    //�ͻ���Ϣ
    FDataAreaID: string;
    //����
    FContractID: string;
    //��ͬ��
    FModel:string;
    //ģʽ Y������ģʽ N������ģʽ
    procedure InitFormData(const nID: string);
    //��ʼ������
    function QueryCustom(const nType: Byte): Boolean;
    //��ѯ�ͻ�
    procedure GetResult;
    //��ȡ���
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}

uses
  IniFiles, ULibFun, UMgrControl, UAdjustForm, UFormCtrl, UFormBase, USysGrid,
  USysDB, USysConst, USysBusiness, UDataModule;

class function TfFormGetCustom.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  with TfFormGetCustom.Create(Application) do
  begin
    Caption := 'ѡ��ͻ�';
    InitFormData(nP.FParamA);

    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;

    if nP.FParamA = mrOK then
    begin
      nP.FParamB := FCusID;
      nP.FParamC := FCusName;
      nP.FParamD := FSaleID;
      nP.FParamE := FXSQYMC;
    end;
    Free;
  end;
end;

class function TfFormGetCustom.FormID: integer;
begin
  Result := cFI_FormGetCustom;
end;

procedure TfFormGetCustom.FormCreate(Sender: TObject);
var nIni,myini: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
    LoadcxListViewConfig(Name, ListCustom, nIni);
  finally
    nIni.Free;
  end;
  myini:=TIniFile.Create('.\Config.Ini');
  try
    FModel:=myini.ReadString('Model','Online','Y');
  finally
    myini.Free;
  end;
end;

procedure TfFormGetCustom.FormClose(Sender: TObject;
  var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
    SavecxListViewConfig(Name, ListCustom, nIni);
  finally
    nIni.Free;
  end;

  ReleaseCtrlData(Self);
end;

//------------------------------------------------------------------------------
//Desc: ��ʼ����������
procedure TfFormGetCustom.InitFormData(const nID: string);
var nStr: string;
begin
  if nID <> '' then
  begin
    EditCus.Text := nID;
    if QueryCustom(10) then ActiveControl := ListCustom;
  end;
end;

//Date: 2010-3-9
//Parm: ��ѯ����(10: ������;20: ����Ա)
//Desc: ��ָ�����Ͳ�ѯ��ͬ
function TfFormGetCustom.QueryCustom(const nType: Byte): Boolean;
var
  nStr,nWhere,nCompanyID,nSaleID,nXSQYMC: string;
begin
  Result := False;
  FStatus:=True;
  nWhere := '';
  ListCustom.Items.Clear;

  nWhere := '(Z_OrgAccountNum Like ''%$ID%'') or (Z_OrgAccountName Like ''%$ID%'')';
  nStr := 'Select zk.*,zdt.D_StockName,zdt.D_Type From $ZK zk,$ZDT zdt ' ;
  if nWhere <> '' then
    nStr := nStr + ' Where (' + nWhere + ')';
  nStr := nStr + ' And Z_ID=D_ZID '+
          'And ((Z_SalesStatus=''1'') or '+
          '((Z_SalesType=''0'') and '+
          '((Z_SalesStatus=''0'') or '+
          '(Z_SalesStatus=''1'')))) '+
          'And D_Blocked=''0'' '+
          'Order By Z_ID';
  nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa),MI('$ZDT', sTable_ZhiKaDtl),MI('$ID', EditCus.Text)]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    First;
    while not Eof do
    with ListCustom.Items.Add do
    begin
      Caption := FieldByName('Z_OrgAccountNum').AsString;
      SubItems.Add(FieldByName('Z_OrgAccountName').AsString);
      SubItems.Add(FieldByName('Z_ID').AsString);
      if FieldByName('Z_TriangleTrade').AsString='1' then
      begin
        nSaleID:= FieldByName('Z_IntComOriSalesId').AsString;
        nCompanyID:= FieldByName('Z_CompanyId').AsString;
        nXSQYMC:=GetCompanyArea(nSaleID,nCompanyID);
        if nXSQYMC= 'Fail' then
        begin
          ShowMsg(FieldByName('Z_OrgAccountName').AsString+#13#10+'��ȡ��������ʧ��',sHint);
          Exit;
        end else
          SubItems.Add(nXSQYMC);
      end else
        SubItems.Add('-');
      SubItems.Add(FieldByName('D_StockName').AsString);
      SubItems.Add(FieldByName('D_Type').AsString);
      ImageIndex := cItemIconIndex;
      Next;
    end;

    ListCustom.ItemIndex := 0;
    Result := True;
  end else
  begin
    ShowMsg('�޿��ö���',sHint);
    Exit;
  end;
end;

procedure TfFormGetCustom.EditCIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  EditCus.Text := Trim(EditCus.Text);
  if (EditCus.Text <> '') and QueryCustom(10) then ListCustom.SetFocus;
end;


procedure TfFormGetCustom.EditCustomPropertiesEditValueChanged(
  Sender: TObject);
begin
  if QueryCustom(20) then ListCustom.SetFocus;
end;

//Desc: ��ȡ���
procedure TfFormGetCustom.GetResult;
begin
  with ListCustom.Selected do
  begin
    FCusID := Caption;
    FCusName := SubItems[0];
    FSaleID := SubItems[1];
    FXSQYMC := SubItems[2];
    if FXSQYMC <> '' then SaveCompanyArea(FXSQYMC,FSaleID);
  end;
end;

procedure TfFormGetCustom.ListCustomKeyPress(Sender: TObject;
  var Key: Char);
var nMsg:string;
begin
  if Key = #13 then
  begin
    Key := #0;
    if ListCustom.ItemIndex > -1 then
    begin
      GetResult;
      ModalResult := mrOk;
    end;
  end;
end;

procedure TfFormGetCustom.ListCustomDblClick(Sender: TObject);
var nMsg:string;
begin
  if ListCustom.ItemIndex > -1 then
  begin
    GetResult;
    ModalResult := mrOk;
  end;
end;

procedure TfFormGetCustom.BtnOKClick(Sender: TObject);
var nMsg:string;
begin
  if ListCustom.ItemIndex > -1 then
  begin
    GetResult;
    ModalResult := mrOk;
  end else ShowMsg('���ڲ�ѯ�����ѡ��', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormGetCustom, TfFormGetCustom.FormID);
end.
