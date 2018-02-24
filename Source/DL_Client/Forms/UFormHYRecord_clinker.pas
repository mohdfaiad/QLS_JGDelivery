{*******************************************************************************
  ����: dmzn@163.com 2009-07-20
  ����: ͨ�����ϼ���¼��
*******************************************************************************}
unit UFormHYRecord_clinker;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UDataModule, cxGraphics, StdCtrls, cxMaskEdit, cxDropDownEdit,
  cxMCListBox, cxMemo, dxLayoutControl, cxContainer, cxEdit, cxTextEdit,
  cxControls, cxButtonEdit, cxCalendar, ExtCtrls, cxPC, cxLookAndFeels,
  cxLookAndFeelPainters, cxLabel;

type
  TfFormHYRecord_clinker = class(TForm)
    dxLayoutControl1Group_Root: TdxLayoutGroup;
    dxLayoutControl1: TdxLayoutControl;
    dxLayoutControl1Group1: TdxLayoutGroup;
    BtnOK: TButton;
    dxLayoutControl1Item10: TdxLayoutItem;
    BtnExit: TButton;
    dxLayoutControl1Item11: TdxLayoutItem;
    dxLayoutControl1Group5: TdxLayoutGroup;
    EditID: TcxButtonEdit;
    dxLayoutControl1Item1: TdxLayoutItem;
    dxLayoutControl1Group2: TdxLayoutGroup;
    wPanel: TPanel;
    dxLayoutControl1Item4: TdxLayoutItem;
    Bevel2: TBevel;
    EditDate: TcxDateEdit;
    dxLayoutControl1Item2: TdxLayoutItem;
    EditMan: TcxTextEdit;
    dxLayoutControl1Item3: TdxLayoutItem;
    dxLayoutControl1Group3: TdxLayoutGroup;
    EditQuaStart: TcxTextEdit;
    dxLayoutControl1Item5: TdxLayoutItem;
    cxComboBox2: TcxComboBox;
    dxLayoutControl1Item6: TdxLayoutItem;
    EditStock: TcxComboBox;
    dxLayoutControl1Item7: TdxLayoutItem;
    EditQuaEnd: TcxTextEdit;
    dxLayoutControl1Item8: TdxLayoutItem;
    cbxCenterID: TcxComboBox;
    dxLayoutControl1Item9: TdxLayoutItem;
    dxLayoutControl1Group4: TdxLayoutGroup;
    cxTextEdit1: TcxTextEdit;
    dxLayoutControl1Item12: TdxLayoutItem;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    cxLabel5: TcxLabel;
    cxLabel6: TcxLabel;
    cxLabel7: TcxLabel;
    cxLabel8: TcxLabel;
    cxLabel9: TcxLabel;
    cxLabel10: TcxLabel;
    cxLabel11: TcxLabel;
    cxLabel12: TcxLabel;
    cxTextEdit2: TcxTextEdit;
    cxTextEdit3: TcxTextEdit;
    cxTextEdit4: TcxTextEdit;
    cxTextEdit5: TcxTextEdit;
    cxTextEdit6: TcxTextEdit;
    cxTextEdit7: TcxTextEdit;
    cxTextEdit8: TcxTextEdit;
    cxTextEdit9: TcxTextEdit;
    cxTextEdit10: TcxTextEdit;
    cxTextEdit11: TcxTextEdit;
    cxTextEdit12: TcxTextEdit;
    cxComboBox1: TcxComboBox;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnOKClick(Sender: TObject);
    procedure BtnExitClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditStockPropertiesEditValueChanged(Sender: TObject);
    procedure cxTextEdit17KeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    FRecordID: string;
    //��ͬ���
    FPrefixID: string;
    //ǰ׺���
    FIDLength: integer;
    //ǰ׺����
    procedure InitFormData(const nID: string);
    //��������
    procedure GetData(Sender: TObject; var nData: string);
    function SetData(Sender: TObject; const nData: string): Boolean;
    //���ݴ���
  public
    { Public declarations }
  end;

function ShowStockRecordAddForm: Boolean;
function ShowStockRecordEditForm(const nID: string): Boolean;
procedure ShowStockRecordViewForm(const nID: string);
procedure CloseStockRecordForm;
//��ں���

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UFormCtrl, UAdjustForm, USysDB, USysConst, UDataReport;

var
  gForm: TfFormHYRecord_clinker = nil;
  //ȫ��ʹ��

//------------------------------------------------------------------------------
//Desc: ���
function ShowStockRecordAddForm: Boolean;
begin
  with TfFormHYRecord_clinker.Create(Application) do
  begin
    FRecordID := '';
    Caption := 'ͨ�����ϼ����¼ - ���';

    InitFormData('');
    Result := ShowModal = mrOK;
    Free;
  end;
end;

//Desc: �޸�
function ShowStockRecordEditForm(const nID: string): Boolean;
begin
  with TfFormHYRecord_clinker.Create(Application) do
  begin
    FRecordID := nID;
    Caption := 'ͨ�����ϼ����¼ - �޸�';

    InitFormData(nID);
    Result := ShowModal = mrOK;
    Free;
  end;
end;

//Desc: �鿴
procedure ShowStockRecordViewForm(const nID: string);
begin
  if not Assigned(gForm) then
  begin
    gForm := TfFormHYRecord_clinker.Create(Application);
    gForm.Caption := '�����¼ - �鿴';
    gForm.FormStyle := fsStayOnTop;
    gForm.BtnOK.Visible := False;
  end;

  with gForm  do
  begin
    FRecordID := nID;
    InitFormData(nID);
    if not Showing then Show;
  end;
end;

procedure CloseStockRecordForm;
begin
  FreeAndNil(gForm);
end;

//------------------------------------------------------------------------------
procedure TfFormHYRecord_clinker.FormCreate(Sender: TObject);
var nIni: TIniFile;
begin
  ResetHintAllForm(Self, 'E', sTable_StockRecord_clinker);
  //���ñ�����
  
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
    FPrefixID := nIni.ReadString(Name, 'IDPrefix', 'SN');
    FIDLength := nIni.ReadInteger(Name, 'IDLength', 8);
  finally
    nIni.Free;
  end;

end;

procedure TfFormHYRecord_clinker.FormClose(Sender: TObject;
  var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
  finally
    nIni.Free;
  end;

  gForm := nil;
  Action := caFree;
  ReleaseCtrlData(Self);
end;

procedure TfFormHYRecord_clinker.BtnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfFormHYRecord_clinker.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Key := 0; Close;
  end else

  if Key = VK_DOWN then
  begin
    Key := 0;
    Perform(WM_NEXTDLGCTL, 0, 0);
  end else

  if Key = VK_UP then
  begin
    Key := 0;
    Perform(WM_NEXTDLGCTL, 1, 0);
  end;
end;

procedure TfFormHYRecord_clinker.cxTextEdit17KeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;
    Perform(WM_NEXTDLGCTL, 0, 0);
  end;
end;

//------------------------------------------------------------------------------
procedure TfFormHYRecord_clinker.GetData(Sender: TObject; var nData: string);
begin
  if Sender = EditDate then nData := DateTime2Str(EditDate.Date);
end;

function TfFormHYRecord_clinker.SetData(Sender: TObject; const nData: string): Boolean;
begin
  if Sender = EditDate then
  begin
    EditDate.Date := Str2DateTime(nData);
    Result := True;
  end else Result := False;
end;

//Date: 2009-6-2
//Parm: ��¼���
//Desc: ����nID��Ӧ�̵���Ϣ������
procedure TfFormHYRecord_clinker.InitFormData(const nID: string);
var nStr: string;
begin
  EditDate.Date := Now;
  EditMan.Text := gSysParam.FUserID;
  cxComboBox1.Text := '��ѡ��';
  EditQuaStart.Text:='0';
  EditQuaEnd.Text:='0';
  if EditStock.Properties.Items.Count < 1 then
  begin
    nStr := 'P_ID=Select P_ID,P_Name From %s';
    nStr := Format(nStr, [sTable_StockParam]);

    FDM.FillStringsData(EditStock.Properties.Items, nStr, -1, '��');
    AdjustStringsItem(EditStock.Properties.Items, False);
  end;
  
  if cbxCenterID.Properties.Items.Count < 1 then
  begin
    nStr := 'Select I_CenterID from %s ';
    nStr := Format(nStr,[sTable_InventCenter]);
    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      First;
      while not Eof do
      begin
        if Fields[0].AsString<> '' then
          cbxCenterID.Properties.Items.Add(Fields[0].AsString);
        Next;
      end;
    end;
  end;

  if nID <> '' then
  begin
    nStr := 'Select * From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_StockRecord_clinker, nID]);
    LoadDataToForm(FDM.QuerySQL(nStr), Self, '', SetData);
  end;
end;

//Desc: ��������
procedure TfFormHYRecord_clinker.EditStockPropertiesEditValueChanged(Sender: TObject);
var nStr: string;
begin
  if FRecordID = '' then
  begin
    nStr := 'Select * From %s Where R_PID=''%s''';
    nStr := Format(nStr, [sTable_StockParamExt, GetCtrlData(EditStock)]);
    LoadDataToCtrl(FDM.QueryTemp(nStr), wPanel);
  end;

  nStr := 'Select P_Stock From %s Where P_ID=''%s''';
  nStr := Format(nStr, [sTable_StockParam, GetCtrlData(EditStock)]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
       nStr := GetPinYinOfStr(Fields[0].AsString)
  else nStr := '';

  {if Pos('kzf', nStr) > 0 then //������
  begin
    Label24.Caption := '�ܶ�g/cm:';
    Label19.Caption := '�����ȱ�:';
    Label22.Caption := '�� ˮ ��:';
    Label21.Caption := 'ʯ�����:';
    Label34.Caption := '�� ĥ ��:';
    Label18.Caption := '7�����ָ��:';
    Label26.Caption := '28�����ָ��:';
  end else
  begin
    Label24.Caption := '�� �� þ:';
    Label19.Caption := '�� �� ��:';
    Label22.Caption := 'ϸ    ��:';
    Label21.Caption := '��    ��:';
    Label34.Caption := '�� �� ��:';
    Label18.Caption := '3�쿹��ǿ��:';
    Label26.Caption := '28�쿹��ǿ��:';
  end; }
end;

//Desc: ����������
procedure TfFormHYRecord_clinker.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  //EditID.Text := FDM.GetSerialID(FPrefixID, sTable_StockRecord, 'R_SerialNo');
end;

//Desc: ��������
procedure TfFormHYRecord_clinker.BtnOKClick(Sender: TObject);
var nStr,nSQL: string;
begin
  EditID.Text := Trim(EditID.Text);
  if EditID.Text = '' then
  begin
    EditID.SetFocus;
    ShowMsg('����д��Ч��ˮ����', sHint); Exit;
  end;

  if EditStock.ItemIndex < 0 then
  begin
    EditStock.SetFocus;
    ShowMsg('����д��Ч��Ʒ��', sHint); Exit;
  end;
  if not IsNumber(EditQuaStart.Text,False) then
  begin
    EditQuaStart.SetFocus;
    ShowMsg('����д��Ч��������', sHint); Exit;
  end;
  if not IsNumber(EditQuaEnd.Text,False) then
  begin
    EditQuaEnd.SetFocus;
    ShowMsg('����д��Ч��Ԥ����', sHint); Exit;
  end;
  {$IFDEF CXSY}
  if cbxCenterID.ItemIndex < 0 then
  begin
    EditStock.SetFocus;
    ShowMsg('��ѡ��������', sHint); Exit;
  end;
  {$ENDIF}
  
  {$IFDEF QHSN}
  if cbxCenterID.ItemIndex < 0 then
  begin
    EditStock.SetFocus;
    ShowMsg('��ѡ��������', sHint); Exit;
  end;
  {$ELSE}
  cbxCenterID.ItemIndex := -1;
  {$ENDIF}

  
  if FRecordID = '' then
  begin
    nStr := 'Select Count(*) From %s Where R_SerialNo=''%s''';
    nStr := Format(nStr, [sTable_StockRecord_clinker, EditID.Text]);
    //��ѯ����Ƿ����

    with FDM.QueryTemp(nStr) do
    if Fields[0].AsInteger > 0 then
    begin
      EditID.SetFocus;
      ShowMsg('�ñ�ŵļ�¼�Ѿ�����', sHint);
      Exit;
    end;

    nStr := 'Select Count(*) From %s Where R_SerialNo=''%s''';
    nStr := Format(nStr, [sTable_StockRecord, EditID.Text]);
    //��ѯ����Ƿ����

    with FDM.QueryTemp(nStr) do
    if Fields[0].AsInteger > 0 then
    begin
      EditID.SetFocus;
      ShowMsg('�ñ�ŵļ�¼�Ѿ�������ˮ������¼��', sHint);
      Exit;
    end;

    nStr := 'Select Count(*) From %s Where R_SerialNo=''%s''';
    nStr := Format(nStr, [sTable_StockRecord_Slag, EditID.Text]);
    //��ѯ����Ƿ����

    with FDM.QueryTemp(nStr) do
    if Fields[0].AsInteger > 0 then
    begin
      EditID.SetFocus;
      ShowMsg('�ñ�ŵļ�¼�Ѿ������ڿ����ۼ����¼��', sHint);
      Exit;
    end;

    nStr := 'Select Count(*) From %s Where R_SerialNo=''%s''';
    nStr := Format(nStr, [sTable_StockRecord_Concrete, EditID.Text]);
    //��ѯ����Ƿ����

    with FDM.QueryTemp(nStr) do
    if Fields[0].AsInteger > 0 then
    begin
      EditID.SetFocus;
      ShowMsg('�ñ�ŵļ�¼�Ѿ������ڻ�������Ʒ�����¼��', sHint);
      Exit;
    end;

    nSQL := MakeSQLByForm(Self, sTable_StockRecord_clinker, '', True, GetData);
  end else
  begin
    EditID.Text := FRecordID;
    nStr := 'R_ID=''' + FRecordID + '''';
    nSQL := MakeSQLByForm(Self, sTable_StockRecord_clinker, nStr, False, GetData);
  end;

  FDM.ExecuteSQL(nSQL);

  ModalResult := mrOK;
  ShowMsg('�����ѱ���', sHint);
end;

end.
