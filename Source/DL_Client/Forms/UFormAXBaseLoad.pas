unit UFormAXBaseLoad;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxLayoutControl, StdCtrls, dxLayoutcxEditAdapters,
  cxContainer, cxEdit, cxCheckBox;

type
  TfFormAXBaseLoad = class(TfFormNormal)
    chkCustomer: TcxCheckBox;
    dxLayout1Item3: TdxLayoutItem;
    chkTPRESTIGEMANAGE: TcxCheckBox;
    chkTPRESTIGEMBYCONT: TcxCheckBox;
    chkProviders: TcxCheckBox;
    chkInvent: TcxCheckBox;
    chkINVENTDIM: TcxCheckBox;
    chkINVENTLOCATION: TcxCheckBox;
    chkInvCenGroup: TcxCheckBox;
    chkEmpl: TcxCheckBox;
    chkINVENTCENTER: TcxCheckBox;
    chkCement: TcxCheckBox;
    chkTruck: TcxCheckBox;
    chkSalOrder: TcxCheckBox;
    chkSalOrderLine: TcxCheckBox;
    chkContract: TcxCheckBox;
    chkContractLine: TcxCheckBox;
    chkPurOrder: TcxCheckBox;
    chkPurOrdLine: TcxCheckBox;
    chkSupAgr: TcxCheckBox;
    chkKuWei: TcxCheckBox;
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
  fFormAXBaseLoad: TfFormAXBaseLoad;

implementation

{$R *.dfm}
uses
  DB, IniFiles, ULibFun, UMgrControl, UFormBase, USysConst, USysGrid, USysDB,
  USysBusiness, UDataModule, USysPopedom, UBusinessPacker, UAdjustForm, UFormWait;

class function TfFormAXBaseLoad.FormID: integer;
begin
  Result := cFI_FormAXBaseLoad;
end;

class function TfFormAXBaseLoad.CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl;
var
  nP: PFormCommandParam;
begin
  Result:=nil;
  with TfFormAXBaseLoad.Create(Application) do
  begin
    if not gSysParam.FIsAdmin then
    begin
      chkInvent.Visible:=False;
      chkCement.Visible:=False;
      chkINVENTDIM.Visible:=False;
      chkINVENTLOCATION.Visible:=False;
      chkINVENTCENTER.Visible:=False;
      chkInvCenGroup.Visible:=False;
      chkEmpl.Visible:=False;
      chkTruck.Visible:=False;
    end;
    Caption := '��������������';
    ShowModal;
    Free;
  end;
end;

procedure TfFormAXBaseLoad.FormCreate(Sender: TObject);
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

procedure TfFormAXBaseLoad.FormClose(Sender: TObject;
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

procedure TfFormAXBaseLoad.BtnOKClick(Sender: TObject);
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
    if chkProviders.Checked then
    begin
      if SyncRemoteProviders then
        nMsg:='��Ӧ����Ϣͬ���ɹ�'
      else
        nMsg:='��Ӧ����Ϣͬ��ʧ��';
      ShowMsg(nMsg,sHint);
    end;
    if chkInvent.Checked then
    begin
      if SyncRemoteMeterails then
        nMsg:='ԭ������Ϣͬ���ɹ�'
      else
        nMsg:='ԭ������Ϣͬ��ʧ��';
      ShowMsg(nMsg,sHint);
    end;
    if chkCement.Checked then
    begin
      if SyncCement then
        nMsg:='ˮ����Ϣͬ���ɹ�'
      else
        nMsg:='ˮ����Ϣͬ��ʧ��';
      ShowMsg(nMsg,sHint);
    end;
    if chkINVENTDIM.Checked then
    begin
      if SyncINVENTDIM then
        nMsg:='ά����Ϣͬ���ɹ�'
      else
        nMsg:='ά����Ϣͬ��ʧ��';
      ShowMsg(nMsg,sHint);
    end;
    if chkINVENTLOCATION.Checked then
    begin
      if SyncINVENTLOCATION then
        nMsg:='�ֿ���Ϣͬ���ɹ�'
      else
        nMsg:='�ֿ���Ϣͬ��ʧ��';
      ShowMsg(nMsg,sHint);
    end;
    if chkINVENTCENTER.Checked then
    begin
      if SyncINVENTCENTER then
        nMsg:='��������Ϣͬ���ɹ�'
      else
        nMsg:='��������Ϣͬ��ʧ��';
      ShowMsg(nMsg,sHint);
    end;
    if chkInvCenGroup.Checked then
    begin
      if SyncInvCenGroup then
        nMsg:='��������������Ϣͬ���ɹ�'
      else
        nMsg:='��������������Ϣͬ��ʧ��';
      ShowMsg(nMsg,sHint);
    end;
    if chkEmpl.Checked then
    begin
      if SyncEmpTable then
        nMsg:='Ա����Ϣͬ���ɹ�'
      else
        nMsg:='Ա����Ϣͬ��ʧ��';
      ShowMsg(nMsg,sHint);
    end;
    if chkTruck.Checked then
    begin
      if GetAXVehicleNo then
        nMsg:='������Ϣͬ���ɹ�'
      else
        nMsg:='������Ϣͬ��ʧ��';
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
    if chkPurOrder.Checked then
    begin
      if GetAXPurOrder then
        nMsg:='�ɹ�����ͬ���ɹ�'
      else
        nMsg:='�ɹ�����ͬ��ʧ��';
      ShowMsg(nMsg,sHint);
    end;
    if chkPurOrdLine.Checked then
    begin
      if GetAXPurOrdLine then
        nMsg:='�ɹ�������ͬ���ɹ�'
      else
        nMsg:='�ɹ�������ͬ��ʧ��';
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
    if chkKuWei.Checked then
    begin
      if SyncWmsLocation then
        nMsg:='��λ��Ϣͬ���ɹ�'
      else
        nMsg:='��λ��Ϣͬ��ʧ��';
      ShowMsg(nMsg,sHint);
    end;
  finally
    CloseWaitForm;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormAXBaseLoad,TfFormAXBaseLoad.FormID);

end.
