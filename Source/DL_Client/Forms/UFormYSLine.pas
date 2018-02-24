{*******************************************************************************
  ����: lih 2017-5-3
  ����: ����ͨ������
*******************************************************************************}
unit UFormYSLine;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxDropDownEdit,
  cxLabel, cxCheckBox, cxTextEdit, dxLayoutControl, StdCtrls,
  dxLayoutcxEditAdapters, cxCheckComboBox, ExtCtrls;

type
  TfFormYSLine = class(TfFormNormal)
    EditID: TcxTextEdit;
    LayItem1: TdxLayoutItem;
    CheckValid: TcxCheckBox;
    dxLayout1Item7: TdxLayoutItem;
    EditName: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    chkcbbStockname: TcxCheckComboBox;
    dxLayout1Item4: TdxLayoutItem;
    editStockno: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    editStockname: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    Timer1: TTimer;
    checkYSValid: TcxCheckBox;
    dxLayout1Item8: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
    function getStocknos:string;
    procedure setStocknos(const nstrs:string);
    procedure chkcbbStocknamePropertiesChange(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  protected
    { Protected declarations }
    FID: string;
    //��ʶ
    FStocknoList:Tstrings;
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
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

function ShowAddYSLineForm: Boolean;
function ShowEditYSLineForm(const nID: string): Boolean;
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
  end;

var
  gStockItems: array of TLineStockItem;
  //Ʒ���б�
   gCheckValid: boolean;
  //ͨ����ѡ����

function ShowAddYSLineForm: Boolean;
begin
  with TfFormYSLine.Create(Application) do
  try
    FID := '';
    Caption := '����ͨ�� - ���';

    InitFormData('');
    Result := ShowModal = mrOk;
  finally
    Free;
  end;
end;

function ShowEditYSLineForm(const nID: string): Boolean;
begin
  with TfFormYSLine.Create(Application) do
  try
    FID := nID;
    Caption := '����ͨ�� - �޸�';

    InitFormData(nID);
    Result := ShowModal = mrOk;
  finally
    Free;
  end;
end;

class function TfFormYSLine.FormID: integer;
begin
  Result := cFI_FormYSLine;
end;

class function TfFormYSLine.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
begin
  Result := nil;
end;

//------------------------------------------------------------------------------
procedure TfFormYSLine.InitFormData(const nID: string);
var nStr: string;
    nIdx: Integer;
    nItem:TcxCheckComboBoxItem;
begin
  ResetHintAllForm(Self, 'T', sTable_YSLines);
  //���ñ�����

  if nID <> '' then
  begin
    EditID.Properties.ReadOnly := True;
    EditID.Enabled := False;
    nStr := 'Select * From %s Where R_ID=''%s''';
    nStr := Format(nStr, [sTable_YSLines, nID]);

    if FDM.QueryTemp(nStr).RecordCount > 0 then
    begin
      editStockno.Text := FDM.SqlTemp.FieldByName('Y_StockNo').AsString;
      LoadDataToCtrl(FDM.SqlTemp, Self, '', SetData);
    end;
  end;

  nStr := 'Select M_ID, M_Name From %s ';
  nStr := Format(nStr, [sTable_Materails]);

  chkcbbStockname.Properties.Items.Clear;
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
        FID := Fields[0].AsString;
        FName := Fields[1].AsString;
        nItem := chkcbbStockname.Properties.Items.Add;
        nItem.Description := FID + '.' + FName;
        nItem.ShortDescription := FName;
        FStocknoList.Add(Fid);
      end;

      Inc(nIdx);
      Next;
    end;
  end;
  setStocknos(editStockno.Text);
end;

function TfFormYSLine.SetData(Sender: TObject; const nData: string): Boolean;
begin
  Result := False;
  
  if Sender = CheckValid then
  begin
    Result := True;
    CheckValid.Checked := nData <> sFlag_No;
  end;
  
  if Sender = checkYSValid then
  begin
    Result := True;
    checkYSValid.Checked := nData <> sFlag_No;
  end;
end;

procedure TfFormYSLine.GetData(Sender: TObject; var nData: string);
begin
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

  if Sender = checkYSValid then
  begin
    if checkYSValid.Checked   then
    begin
      nData := sFlag_Yes;
    end else
    begin
      nData := sFlag_No;
    end;
  end;  
end;

function TfFormYSLine.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
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
  end;

  Result := getStocknos<>'';
  nHint := '��ѡ��Ʒ��';
end;

procedure TfFormYSLine.BtnOKClick(Sender: TObject);
var nIdx: Integer;
    nStr,nEvent: string;
begin
  if not IsDataValid then Exit;

  if FID = '' then
  begin
    nStr := MakeSQLByForm(Self, sTable_YSLines, '', True, GetData);
  end else
  begin
    nStr := Format('R_ID=''%s''', [FID]);
    nStr := MakeSQLByForm(Self, sTable_YSLines, nStr, False, GetData);
  end;

  FDM.ExecuteSQL(nStr);
  ModalResult := mrOk;

  //--------------
  if   gCheckValid = false then
  begin
       nEvent := 'ͨ�� [ %s ] �ر�';
       nEvent := Format(nEvent, [EditID.Text]);
       FDM.WriteSysLog(sFlag_TruckQueue, 'UFromYSline', nEvent);
  end;
  if   gCheckValid = true  then
  begin
       nEvent := 'ͨ�� [ %s ] ����';
       nEvent := Format(nEvent, [EditID.Text]);
       FDM.WriteSysLog(sFlag_TruckQueue, 'UFromYSline',nEvent);
  end;
  //--д�����ͨ����־
  ShowMsg('ͨ���ѱ���,��ȴ�ˢ��', sHint);
end;

destructor TfFormYSLine.Destroy;
begin
  FStocknoList.Free;
  inherited;
end;

constructor TfFormYSLine.Create(AOwner: TComponent);
begin
  inherited;
  Fstocknolist := TStringList.Create;
end;

function TfFormYSLine.getStocknos: string;
var
  i:Integer;
  nItem:TcxCheckComboBoxItem;
  nno:TStrings;
begin
  Result := '';
  nno := TStringList.Create;
  try
    for i := 0 to chkcbbStockname.Properties.Items.Count-1 do
    begin
      nItem := chkcbbStockname.Properties.Items[i];
      if chkcbbStockname.States[i]=cbsChecked then
      begin
        nno.Add(FStocknoList.Strings[i]);
      end;
    end;
    Result := nno.CommaText;
  finally
    nno.Free;
  end;
end;

procedure TfFormYSLine.chkcbbStocknamePropertiesChange(Sender: TObject);
begin
  inherited;
  editStockno.Text := getStocknos;
  editStockname.Text := chkcbbStockname.Text;
end;

procedure TfFormYSLine.setStocknos(const nstrs: string);
var
  i:Integer;
  nItem:TcxCheckComboBoxItem;
  nno:TStrings;
  nTmp,nSelNo:string;
begin
  nno := TStringList.Create;
  try
    nno.CommaText := nstrs;
    for i := 0 to chkcbbStockname.Properties.Items.Count-1 do
    begin
      nItem := chkcbbStockname.Properties.Items[i];
      nTmp := FStocknoList.Strings[i];
      if nno.IndexOf(nTmp)<>-1 then
      begin
        if Pos(nTmp,nItem.Description)>0 then
        begin
          chkcbbStockname.States[i] := cbsChecked;
        end;
      end;
    end;
  finally
    nno.Free;
  end;
end;

procedure TfFormYSLine.Timer1Timer(Sender: TObject);
begin
  timer1.Enabled := False;
  dxLayout1Item5.Visible := False;
  dxLayout1Item6.Visible := False;
end;

initialization
  gControlManager.RegCtrl(TfFormYSLine, TfFormYSLine.FormID);
end.
