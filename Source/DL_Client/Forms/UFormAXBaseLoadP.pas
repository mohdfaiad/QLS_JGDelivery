unit UFormAXBaseLoadP;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxLayoutControl, StdCtrls, dxLayoutcxEditAdapters,
  cxContainer, cxEdit, cxCheckBox;

type
  TfFormAXBaseLoadP = class(TfFormNormal)
    chkProviders: TcxCheckBox;
    chkInvent: TcxCheckBox;
    chkPurOrder: TcxCheckBox;
    chkPurOrdLine: TcxCheckBox;
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
  fFormAXBaseLoadP: TfFormAXBaseLoadP;

implementation

{$R *.dfm}
uses
  DB, IniFiles, ULibFun, UMgrControl, UFormBase, USysConst, USysGrid, USysDB,
  USysBusiness, UDataModule, USysPopedom, UBusinessPacker, UAdjustForm, UFormWait;

class function TfFormAXBaseLoadP.FormID: integer;
begin
  Result := cFI_FormAXBaseLoadP;
end;

class function TfFormAXBaseLoadP.CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl;
var
  nP: PFormCommandParam;
begin
  Result:=nil;
  with TfFormAXBaseLoadP.Create(Application) do
  begin
    Caption := '�ɹ���������������';
    ShowModal;
    Free;
  end;
end;

procedure TfFormAXBaseLoadP.FormCreate(Sender: TObject);
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

procedure TfFormAXBaseLoadP.FormClose(Sender: TObject;
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

procedure TfFormAXBaseLoadP.BtnOKClick(Sender: TObject);
var
  nMsg:string;
begin
  ShowWaitForm(Self, '��������...', True);
  try
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
  finally
    CloseWaitForm;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormAXBaseLoadP,TfFormAXBaseLoadP.FormID);

end.
