unit UFormAXBaseLoadS;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxLayoutControl, StdCtrls, dxLayoutcxEditAdapters,
  cxContainer, cxEdit, cxCheckBox;

type
  TfFormAXBaseLoadS = class(TfFormNormal)
    chkCustomer: TcxCheckBox;
    dxLayout1Item3: TdxLayoutItem;
    chkTPRESTIGEMANAGE: TcxCheckBox;
    chkTPRESTIGEMBYCONT: TcxCheckBox;
    chkSalOrder: TcxCheckBox;
    chkSalOrderLine: TcxCheckBox;
    chkContract: TcxCheckBox;
    chkContractLine: TcxCheckBox;
    chkSupAgr: TcxCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

var
  fFormAXBaseLoadS: TfFormAXBaseLoadS;

implementation

{$R *.dfm}
uses
  DB, IniFiles, ULibFun, UMgrControl, UFormBase, USysConst, USysGrid, USysDB,
  USysBusiness, UDataModule, USysPopedom, UBusinessPacker, UAdjustForm, UFormWait;

class function TfFormAXBaseLoadS.FormID: integer;
begin
  Result := cFI_FormAXBaseLoadS;
end;

class function TfFormAXBaseLoadS.CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl;
var
  nP: PFormCommandParam;
begin
  Result:=nil;
  with TfFormAXBaseLoadS.Create(Application) do
  begin
    Caption := '���ۻ�����������';
    ShowModal;
    Free;
  end;
end;

procedure TfFormAXBaseLoadS.FormCreate(Sender: TObject);
var nIni:TIniFile;
begin
  inherited;
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
  finally
    nIni.Free;
  end;
end;

procedure TfFormAXBaseLoadS.FormClose(Sender: TObject;
  var Action: TCloseAction);
var nIni:TIniFile;
begin
  inherited;
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
  finally
    nIni.Free;
  end;
end;

procedure TfFormAXBaseLoadS.BtnOKClick(Sender: TObject);
var
  nMsg:string;
begin
  ShowWaitForm(Self, '��������...', True);
  try
    if chkCustomer.Checked then
    begin
      if SyncRemoteCustomer then
        nMsg:='�ͻ���Ϣͬ���ɹ�'
      else
        nMsg:='�ͻ���Ϣͬ��ʧ��';
      ShowMsg(nMsg,sHint);
    end;
    if chkTPRESTIGEMANAGE.Checked then
    begin
      if SyncTPRESTIGEMANAGE then
        nMsg:='���ö�ȣ��ͻ���ͬ���ɹ�'
      else
        nMsg:='���ö�ȣ��ͻ���ͬ��ʧ��';
      ShowMsg(nMsg,sHint);
    end;
    if chkTPRESTIGEMBYCONT.Checked then
    begin
      if SyncTPRESTIGEMBYCONT then
        nMsg:='���ö�ȣ��ͻ�-��ͬ��ͬ���ɹ�'
      else
        nMsg:='���ö�ȣ��ͻ�-��ͬ��ͬ��ʧ��';
      ShowMsg(nMsg,sHint);
    end;
    if chkSalOrder.Checked then
    begin
      if GetAXSalesOrder then
        nMsg:='���۶���ͬ���ɹ�'
      else
        nMsg:='���۶���ͬ��ʧ��';
      ShowMsg(nMsg,sHint);
    end;
    if chkSalOrderLine.Checked then
    begin
      if GetAXSalesOrdLine then
        nMsg:='���۶�����ͬ���ɹ�'
      else
        nMsg:='���۶�����ͬ��ʧ��';
      ShowMsg(nMsg,sHint);
    end;
    if chkContract.Checked then
    begin
      if GetAXSalesContract then
        nMsg:='���ۺ�ͬͬ���ɹ�'
      else
        nMsg:='���ۺ�ͬͬ��ʧ��';
      ShowMsg(nMsg,sHint);
    end;
    if chkContractLine.Checked then
    begin
      if GetAXSalesContLine then
        nMsg:='���ۺ�ͬ��ͬ���ɹ�'
      else
        nMsg:='���ۺ�ͬ��ͬ��ʧ��';
      ShowMsg(nMsg,sHint);
    end;
    if chkSupAgr.Checked then
    begin
      if GetAXSupAgreement then
        nMsg:='����Э��ͬ���ɹ�'
      else
        nMsg:='����Э��ͬ��ʧ��';
      ShowMsg(nMsg,sHint);
    end;
  finally
    CloseWaitForm;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormAXBaseLoadS,TfFormAXBaseLoadS.FormID);

end.
