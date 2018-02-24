{
  ���ſ�����
}
unit UFrameSTCard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, ADODB, cxLabel,
  UBitmapPanel, cxSplitter, dxLayoutControl, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, ComCtrls, ToolWin, cxMaskEdit, cxButtonEdit,
  cxTextEdit, Menus;

type
  TfFrameSTCard = class(TfFrameNormal)
    EditDate: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    EditTruck: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditTruckPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditTruckKeyPress(Sender: TObject; var Key: Char);
    procedure BtnAddClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
  private
    { Private declarations }
    FStart,FEnd: TDate;
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    {*��ѯSQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

var
  fFrameSTCard: TfFrameSTCard;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, USysConst, USysDB, UFormBase, UDataModule,
  UFormDateFilter, UFormSTCard;

class function TfFrameSTCard.FrameID: integer;
begin
  Result := cFI_FrameSTCard;
end;

procedure TfFrameSTCard.OnCreateFrame;
begin
  inherited;
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameSTCard.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

function TfFrameSTCard.InitFormDataSQL(const nWhere: string): string;
var nStr: string;
begin
  EditDate.Text := Format('%s �� %s', [Date2Str(FStart), Date2Str(FEnd)]);

  Result := 'Select * From $InFac ';
  //�����

  if (nWhere = '') then
  begin
    Result := Result + 'Where (I_Date>=''$ST'' and I_Date <''$End'')';
    nStr := ' And ';
  end else nStr := ' Where (I_Date>=''$ST'' and I_Date <''$End'') and ';

  if nWhere <> '' then
    Result := Result + nStr + '(' + nWhere + ')';
  //xxxxx

  Result := MacroValue(Result, [
            MI('$ST', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
  //xxxxx

  Result := MacroValue(Result, [MI('$InFac', sTable_STInOutFact)]);
end;


procedure TfFrameSTCard.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData('');
end;

procedure TfFrameSTCard.EditTruckPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  EditTruck.Text := Trim(EditTruck.Text);
  if EditTruck.Text = '' then Exit;

  FWhere := Format('I_Truck like ''%%%s%%''', [EditTruck.Text]);
  InitFormData(FWhere);
end;

procedure TfFrameSTCard.EditTruckKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then
  begin
    EditTruck.Text := Trim(EditTruck.Text);
    if EditTruck.Text = '' then Exit;

    FWhere := Format('I_Truck like ''%%%s%%''', [EditTruck.Text]);
    InitFormData(FWhere);
  end;
end;

procedure TfFrameSTCard.BtnAddClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  nP.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormSTCard, '', @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

procedure TfFrameSTCard.N1Click(Sender: TObject);
var
  nID:Integer;
  nStr,nCard:string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nID := SQLQuery.FieldByName('R_ID').AsInteger;
    nCard:=SQLQuery.FieldByName('I_Card').AsString;
    nStr := 'Update %s Set I_Card=''ע''+I_Card Where I_Card=''%s'' ';
    nStr := Format(nStr, [sTable_STInOutFact, nCard]);
    FDM.ExecuteSQL(nStr);
    ShowMsg('ע�����ųɹ�', sHint);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameSTCard, TfFrameSTCard.FrameID);

end.
 