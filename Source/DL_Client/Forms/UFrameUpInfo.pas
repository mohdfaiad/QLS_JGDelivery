{*******************************************************************************
  ����:  lih 2016-08-22
  ����: �ϴ����ݲ�ѯ
*******************************************************************************}
unit UFrameUpInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  IniFiles, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, cxTextEdit, Menus,
  dxLayoutControl, cxMaskEdit, cxButtonEdit, ADODB, cxLabel, UBitmapPanel,
  cxSplitter, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, dxLayoutcxEditAdapters, cxCheckBox;

type
  TfFrameUpInfo = class(TfFrameNormal)
    PMenu1: TPopupMenu;
    N1: TMenuItem;
    cxView2: TcxGridDBTableView;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    EditBill: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditTruck: TcxButtonEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditCus: TcxButtonEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    CheckDelete: TcxCheckBox;
    dxLayout1Item8: TdxLayoutItem;
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditTruckPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnAddClick(Sender: TObject);
    procedure cxGrid1ActiveTabChanged(Sender: TcxCustomGrid;
      ALevel: TcxGridLevel);
    procedure BtnRefreshClick(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure N8Click(Sender: TObject);
    procedure PMenu1Popup(Sender: TObject);
    procedure N9Click(Sender: TObject);
    procedure N10Click(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure cxView2DblClick(Sender: TObject);
    procedure CheckDeleteClick(Sender: TObject);
  private
    { Private declarations }
  protected
    FWhereNo: string;
    //δ������
    FStart,FEnd: TDate;
    //ʱ������
    FQuerySales,FQueryPursh: Boolean;
    //��ѯ����
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    procedure OnInitFormData(var nDefault: Boolean; const nWhere: string = '';
     const nQuery: TADOQuery = nil); override;
    {*��ѯSQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, USysBusiness, UBusinessConst, UFormBase, USysDataDict,
  UDataModule, UFormDateFilter, UForminputbox, USysConst, USysDB, USysGrid;

//------------------------------------------------------------------------------
class function TfFrameUpInfo.FrameID: integer;
begin
  Result := cFI_FrameUpInfo;
end;

procedure TfFrameUpInfo.OnCreateFrame;
begin
  inherited;
  FWhereNo := '';
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameUpInfo.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

procedure TfFrameUpInfo.OnInitFormData(var nDefault: Boolean;
  const nWhere: string; const nQuery: TADOQuery);
var nStr: string;
begin
  nDefault := False;
  EditDate.Text := Format('%s �� %s', [Date2Str(FStart), Date2Str(FEnd)]);

  nStr := 'Select * From $Bill b ';
  //xxxxx

  if FWhere = '' then
       nStr := nStr + 'Where (L_Date>=''$S'' and L_Date<''$End'')'
  else nStr := nStr + 'Where (L_Date>=''$S'' and L_Date<''$End'') and (' + FWhere + ')';

  if CheckDelete.Checked then
    nStr := MacroValue(nStr, [MI('$Bill', sTable_BillBak),
            MI('$S', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))])
  else
    nStr := MacroValue(nStr, [MI('$Bill', sTable_Bill),
            MI('$S', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);

  FDM.QueryData(SQLQuery, nStr);

end;

//------------------------------------------------------------------------------
procedure TfFrameUpInfo.cxGrid1ActiveTabChanged(Sender: TcxCustomGrid;
  ALevel: TcxGridLevel);
begin
  
end;

//Desc: ˢ��
procedure TfFrameUpInfo.BtnRefreshClick(Sender: TObject);
begin
  FWhere := '';
  FWhereNo := '';
  InitFormData(FWhere);
end;

//Desc: ����
procedure TfFrameUpInfo.BtnAddClick(Sender: TObject);
begin
  
end;

//Desc ɾ��
procedure TfFrameUpInfo.BtnDelClick(Sender: TObject);
begin

end;

//Desc: ��ݲ˵�
procedure TfFrameUpInfo.cxView2DblClick(Sender: TObject);
begin
  
end;

//Desc: ����ɸѡ
procedure TfFrameUpInfo.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData(FWhere);
end;

//Desc: ִ�в�ѯ
procedure TfFrameUpInfo.EditTruckPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditCus then
  begin
    EditCus.Text := Trim(EditCus.Text);
    if EditCus.Text = '' then Exit;

    FWhere := 'L_CusPY like ''%%%s%%'' or L_CusName like ''%%%s%%''' ;
    FWhere := Format(FWhere, [EditCus.Text, EditCus.Text]);
    FWhereNo := FWhere;
    InitFormData(FWhere);
  end else

  if Sender = EditBill then
  begin
    EditBill.Text := Trim(EditBill.Text);
    if EditBill.Text = '' then Exit;

    FWhere := 'L_ID like ''%' + EditBill.Text + '%''';
    FWhereNo := FWhere;
    InitFormData(FWhere);
  end else
  
  if Sender = EditTruck then
  begin
    EditTruck.Text := Trim(EditTruck.Text);
    if EditTruck.Text = '' then Exit;

    FWhere := 'L_Truck like ''%' + EditTruck.Text + '%''';
    FWhereNo := FWhere;
    InitFormData(FWhere);
  end;
end;

//δ�ϴ������
procedure TfFrameUpInfo.N5Click(Sender: TObject);
begin
  FWhere := '(L_FYAX=''0'') and (L_FYNUM>=3)';
  InitFormData(FWhere);
end;

//Desc: ȫ��
procedure TfFrameUpInfo.N6Click(Sender: TObject);
begin
  FWhere := '1=1';
  InitFormData(FWhere);
end;

//δ�ϴ�����
procedure TfFrameUpInfo.N8Click(Sender: TObject);
begin
  FWhere := '(L_BDAX=''0'') and (L_BDNUM>=3)';
  InitFormData(FWhere);
end;

//------------------------------------------------------------------------------
procedure TfFrameUpInfo.PMenu1Popup(Sender: TObject);
begin

end;

//
procedure TfFrameUpInfo.N9Click(Sender: TObject);
var nStr,nSQL: string;
begin
  nSQL := 'ȷ��Ҫ�������ִ�������ϴ�������?';

  nSQL := Format(nSQL, [nStr]);
  if not QueryDlg(nSQL, sAsk) then Exit;

  nSQL := 'Update %s Set L_FYNUM=0 Where L_FYNUM>=3';
  nSQL := Format(nSQL, [sTable_Bill]);
  FDM.ExecuteSQL(nSQL);

  InitFormData(FWhere);
  ShowMsg('�����ɹ�', sHint);
end;

//lih: �����ϴ�
procedure TfFrameUpInfo.N10Click(Sender: TObject);
var nStr,nSQL: string;
begin
  nSQL := 'ȷ��Ҫ�����۰���ִ�������ϴ�������?';

  nSQL := Format(nSQL, [nStr]);
  if not QueryDlg(nSQL, sAsk) then Exit;

  nSQL := 'Update %s Set L_BDNUM=0 Where L_BDNUM>=3';
  nSQL := Format(nSQL, [sTable_Bill]);
  FDM.ExecuteSQL(nSQL);

  InitFormData(FWhere);
  ShowMsg('�����ɹ�', sHint);
end;

procedure TfFrameUpInfo.CheckDeleteClick(Sender: TObject);
begin
  InitFormData('');
end;

initialization
  gControlManager.RegCtrl(TfFrameUpInfo, TfFrameUpInfo.FrameID);
end.
