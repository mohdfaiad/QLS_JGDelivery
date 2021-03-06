{*******************************************************************************
  作者: dmzn@163.com 2009-07-20
  描述: 通用熟料检验录入
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
    //合同编号
    FPrefixID: string;
    //前缀编号
    FIDLength: integer;
    //前缀长度
    procedure InitFormData(const nID: string);
    //载入数据
    procedure GetData(Sender: TObject; var nData: string);
    function SetData(Sender: TObject; const nData: string): Boolean;
    //数据处理
  public
    { Public declarations }
  end;

function ShowStockRecordAddForm: Boolean;
function ShowStockRecordEditForm(const nID: string): Boolean;
procedure ShowStockRecordViewForm(const nID: string);
procedure CloseStockRecordForm;
//入口函数

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UFormCtrl, UAdjustForm, USysDB, USysConst, UDataReport;

var
  gForm: TfFormHYRecord_clinker = nil;
  //全局使用

//------------------------------------------------------------------------------
//Desc: 添加
function ShowStockRecordAddForm: Boolean;
begin
  with TfFormHYRecord_clinker.Create(Application) do
  begin
    FRecordID := '';
    Caption := '通用熟料检验记录 - 添加';

    InitFormData('');
    Result := ShowModal = mrOK;
    Free;
  end;
end;

//Desc: 修改
function ShowStockRecordEditForm(const nID: string): Boolean;
begin
  with TfFormHYRecord_clinker.Create(Application) do
  begin
    FRecordID := nID;
    Caption := '通用熟料检验记录 - 修改';

    InitFormData(nID);
    Result := ShowModal = mrOK;
    Free;
  end;
end;

//Desc: 查看
procedure ShowStockRecordViewForm(const nID: string);
begin
  if not Assigned(gForm) then
  begin
    gForm := TfFormHYRecord_clinker.Create(Application);
    gForm.Caption := '检验记录 - 查看';
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
  //重置表名称
  
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
//Parm: 记录编号
//Desc: 载入nID供应商的信息到界面
procedure TfFormHYRecord_clinker.InitFormData(const nID: string);
var nStr: string;
begin
  EditDate.Date := Now;
  EditMan.Text := gSysParam.FUserID;
  cxComboBox1.Text := '请选择';
  EditQuaStart.Text:='0';
  EditQuaEnd.Text:='0';
  if EditStock.Properties.Items.Count < 1 then
  begin
    nStr := 'P_ID=Select P_ID,P_Name From %s';
    nStr := Format(nStr, [sTable_StockParam]);

    FDM.FillStringsData(EditStock.Properties.Items, nStr, -1, '、');
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

//Desc: 设置类型
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

  {if Pos('kzf', nStr) > 0 then //矿渣粉
  begin
    Label24.Caption := '密度g/cm:';
    Label19.Caption := '流动度比:';
    Label22.Caption := '含 水 量:';
    Label21.Caption := '石膏掺量:';
    Label34.Caption := '助 磨 剂:';
    Label18.Caption := '7天活性指数:';
    Label26.Caption := '28天活性指数:';
  end else
  begin
    Label24.Caption := '氧 化 镁:';
    Label19.Caption := '碱 含 量:';
    Label22.Caption := '细    度:';
    Label21.Caption := '稠    度:';
    Label34.Caption := '游 离 钙:';
    Label18.Caption := '3天抗折强度:';
    Label26.Caption := '28天抗折强度:';
  end; }
end;

//Desc: 生成随机编号
procedure TfFormHYRecord_clinker.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  //EditID.Text := FDM.GetSerialID(FPrefixID, sTable_StockRecord, 'R_SerialNo');
end;

//Desc: 保存数据
procedure TfFormHYRecord_clinker.BtnOKClick(Sender: TObject);
var nStr,nSQL: string;
begin
  EditID.Text := Trim(EditID.Text);
  if EditID.Text = '' then
  begin
    EditID.SetFocus;
    ShowMsg('请填写有效的水泥编号', sHint); Exit;
  end;

  if EditStock.ItemIndex < 0 then
  begin
    EditStock.SetFocus;
    ShowMsg('请填写有效的品种', sHint); Exit;
  end;
  if not IsNumber(EditQuaStart.Text,False) then
  begin
    EditQuaStart.SetFocus;
    ShowMsg('请填写有效的批次量', sHint); Exit;
  end;
  if not IsNumber(EditQuaEnd.Text,False) then
  begin
    EditQuaEnd.SetFocus;
    ShowMsg('请填写有效的预警量', sHint); Exit;
  end;
  {$IFDEF CXSY}
  if cbxCenterID.ItemIndex < 0 then
  begin
    EditStock.SetFocus;
    ShowMsg('请选择生产线', sHint); Exit;
  end;
  {$ENDIF}
  
  {$IFDEF QHSN}
  if cbxCenterID.ItemIndex < 0 then
  begin
    EditStock.SetFocus;
    ShowMsg('请选择生产线', sHint); Exit;
  end;
  {$ELSE}
  cbxCenterID.ItemIndex := -1;
  {$ENDIF}

  
  if FRecordID = '' then
  begin
    nStr := 'Select Count(*) From %s Where R_SerialNo=''%s''';
    nStr := Format(nStr, [sTable_StockRecord_clinker, EditID.Text]);
    //查询编号是否存在

    with FDM.QueryTemp(nStr) do
    if Fields[0].AsInteger > 0 then
    begin
      EditID.SetFocus;
      ShowMsg('该编号的记录已经存在', sHint);
      Exit;
    end;

    nStr := 'Select Count(*) From %s Where R_SerialNo=''%s''';
    nStr := Format(nStr, [sTable_StockRecord, EditID.Text]);
    //查询编号是否存在

    with FDM.QueryTemp(nStr) do
    if Fields[0].AsInteger > 0 then
    begin
      EditID.SetFocus;
      ShowMsg('该编号的记录已经存在于水泥检验记录中', sHint);
      Exit;
    end;

    nStr := 'Select Count(*) From %s Where R_SerialNo=''%s''';
    nStr := Format(nStr, [sTable_StockRecord_Slag, EditID.Text]);
    //查询编号是否存在

    with FDM.QueryTemp(nStr) do
    if Fields[0].AsInteger > 0 then
    begin
      EditID.SetFocus;
      ShowMsg('该编号的记录已经存在于矿渣粉检验记录中', sHint);
      Exit;
    end;

    nStr := 'Select Count(*) From %s Where R_SerialNo=''%s''';
    nStr := Format(nStr, [sTable_StockRecord_Concrete, EditID.Text]);
    //查询编号是否存在

    with FDM.QueryTemp(nStr) do
    if Fields[0].AsInteger > 0 then
    begin
      EditID.SetFocus;
      ShowMsg('该编号的记录已经存在于混凝土制品检验记录中', sHint);
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
  ShowMsg('数据已保存', sHint);
end;

end.
