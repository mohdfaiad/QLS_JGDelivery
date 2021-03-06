{*******************************************************************************
  作者: dmzn@163.com 2014-06-10
  描述: 手动称重通道项
*******************************************************************************}
unit UFramePoundManualItem;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UMgrPoundTunnels, UBusinessConst, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, Menus, ExtCtrls, cxCheckBox,
  StdCtrls, cxButtons, cxTextEdit, cxMaskEdit, cxDropDownEdit, cxLabel,
  ULEDFont, cxRadioGroup, UFrameBase;

type
  TfFrameManualPoundItem = class(TBaseFrame)
    GroupBox1: TGroupBox;
    EditValue: TLEDFontNum;
    GroupBox3: TGroupBox;
    ImageGS: TImage;
    Label16: TLabel;
    Label17: TLabel;
    ImageBT: TImage;
    Label18: TLabel;
    ImageBQ: TImage;
    ImageOff: TImage;
    ImageOn: TImage;
    HintLabel: TcxLabel;
    EditTruck: TcxComboBox;
    EditMID: TcxComboBox;
    EditPID: TcxComboBox;
    EditMValue: TcxTextEdit;
    EditPValue: TcxTextEdit;
    EditJValue: TcxTextEdit;
    BtnReadNumber: TcxButton;
    BtnReadCard: TcxButton;
    BtnSave: TcxButton;
    BtnNext: TcxButton;
    Timer1: TTimer;
    PMenu1: TPopupMenu;
    N1: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    EditBill: TcxComboBox;
    EditZValue: TcxTextEdit;
    GroupBox2: TGroupBox;
    RadioPD: TcxRadioButton;
    RadioCC: TcxRadioButton;
    EditMemo: TcxTextEdit;
    EditWValue: TcxTextEdit;
    RadioLS: TcxRadioButton;
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
    Timer2: TTimer;
    procedure Timer1Timer(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure BtnNextClick(Sender: TObject);
    procedure EditBillKeyPress(Sender: TObject; var Key: Char);
    procedure EditBillPropertiesEditValueChanged(Sender: TObject);
    procedure BtnReadNumberClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure RadioPDClick(Sender: TObject);
    procedure EditTruckKeyPress(Sender: TObject; var Key: Char);
    procedure EditMValuePropertiesEditValueChanged(Sender: TObject);
    procedure EditMIDPropertiesChange(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure BtnReadCardClick(Sender: TObject);
  private
    { Private declarations }
    FCardUsed: string;
    //卡片类型
    FPoundTunnel: PPTTunnelItem;
    //磅站通道
    FLastGS,FLastBT,FLastBQ: Int64;
    //上次活动
    FBillItems: TLadingBillItems;
    FUIData,FInnerData: TLadingBillItem;
    //称重数据
    FCardTmp:string;
    //已获取卡号
    FListA: TStrings;
    //数据列表
    FMemPoundSanZ,FMemPoundSanZ_db,FMemPoundSanF,FMemPoundSanF_db:Double;
    FMemPoundBrickZ,FMemPoundBrickZ_db,FMemPoundBrickF,FMemPoundBrickF_db:Double;
    FPdataOriginal,FMDataOriginal:TPoundStationData;//数据库中保存的皮重、毛重
    FBrickItemList:TList;
    procedure InitUIData;
    procedure SetUIData(const nReset: Boolean; const nOnlyData: Boolean = False);
    //界面数据
    procedure SetImageStatus(const nImage: TImage; const nOff: Boolean);
    //设置状态
    procedure SetTunnel(const nTunnel: PPTTunnelItem);
    //关联通道
    procedure OnPoundData(const nValue: Double);
    //读取磅重
    procedure LoadBillItems(const nCard: string);
    //读取交货单
    procedure LoadTruckPoundItem(const nTruck: string);
    //读取车辆称重
    function SavePoundSale: Boolean;
    function SavePoundData: Boolean;
    //保存称重     
    procedure PlayVoice(const nStrtext: string);
    //播放语音
    procedure initBrickItems;
    function getBrickItem(const stockno:string):PBrickItem;
    function getPrePInfo(const nTruck:string;var nPrePValue:Double;var nPrePMan:string;var nPrePTime:TDateTime):Boolean;
  public
    { Public declarations }
    class function FrameID: integer; override;
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    //子类继承
    property PoundTunnel: PPTTunnelItem read FPoundTunnel write SetTunnel;
    //属性相关
    property Additional: TStrings read FListA write FListA;
  end;

implementation

{$R *.dfm}

uses
  ULibFun, UAdjustForm, UFormBase, {$IFDEF HR1847}UKRTruckProber,
  {$ELSE}UMgrTruckProbe,{$ENDIF} UMgrRemoteVoice, UMgrVoiceNet, UDataModule,
  UFormWait, USysBusiness, USysConst, USysDB;

const
  cFlag_ON    = 10;
  cFlag_OFF   = 20;

class function TfFrameManualPoundItem.FrameID: integer;
begin
  Result := 0;
end;

procedure TfFrameManualPoundItem.OnCreateFrame;
begin
  inherited;
  FListA := TStringList.Create;
  FBrickItemList := TList.Create;

  FPoundTunnel := nil;
  InitUIData;
  initBrickItems;
end;

procedure TfFrameManualPoundItem.OnDestroyFrame;
var
  i:integer;
  nItem:PBrickItem;
begin
  gPoundTunnelManager.ClosePort(FPoundTunnel.FID);
  //关闭表头端口

  AdjustStringsItem(EditMID.Properties.Items, True);
  AdjustStringsItem(EditPID.Properties.Items, True);

  FListA.Free;
  for i := FBrickItemList.Count-1 downto 0 do
  begin
    nItem := PBrickItem(FBrickItemList.Items[i]);
    Dispose(nItem);
  end;
  FBrickItemList.Clear;
  inherited;
end;

//Desc: 设置运行状态图标
procedure TfFrameManualPoundItem.SetImageStatus(const nImage: TImage;
  const nOff: Boolean);
begin
  if nOff then
  begin
    if nImage.Tag <> cFlag_OFF then
    begin
      nImage.Tag := cFlag_OFF;
      nImage.Picture.Bitmap := ImageOff.Picture.Bitmap;
    end;
  end else
  begin
    if nImage.Tag <> cFlag_ON then
    begin
      nImage.Tag := cFlag_ON;
      nImage.Picture.Bitmap := ImageOn.Picture.Bitmap;
    end;
  end;
end;

//------------------------------------------------------------------------------
//Desc: 初始化界面
procedure TfFrameManualPoundItem.InitUIData;
var nStr: string;
    nEx: TDynamicStrArray;
begin
  SetLength(nEx, 1);
  nStr := 'M_ID=Select M_ID,M_Name From %s Order By M_ID ASC';
  nStr := Format(nStr, [sTable_Materails]);

  nEx[0] := 'M_ID';
  FDM.FillStringsData(EditMID.Properties.Items, nStr, 0, '', nEx);
  AdjustCXComboBoxItem(EditMID, False);

  nStr := 'P_ID=Select P_ID,P_Name From %s Order By P_ID ASC';
  nStr := Format(nStr, [sTable_Provider]);
  
  nEx[0] := 'P_ID';
  FDM.FillStringsData(EditPID.Properties.Items, nStr, 0, '', nEx);
  AdjustCXComboBoxItem(EditPID, False);
end;

//Desc: 重置界面数据
procedure TfFrameManualPoundItem.SetUIData(const nReset,nOnlyData: Boolean);
var nStr: string;
    nInt: Integer;
    nVal: Double;
    nItem: TLadingBillItem;
begin
  if nReset then
  begin
    FillChar(nItem, SizeOf(nItem), #0);
    //init

    with nItem do
    begin
      FPModel := sFlag_PoundPD;
      FFactory := gSysParam.FFactNum;
    end;

    FCardUsed := '';

    FUIData := nItem;
    FInnerData := nItem;
    if nOnlyData then Exit;

    SetLength(FBillItems, 0);
    EditValue.Text := '0.00';
    EditBill.Properties.Items.Clear;

    gPoundTunnelManager.ClosePort(FPoundTunnel.FID);
    //关闭表头端口
  end;

  with FUIData do
  begin
    EditBill.Text := FID;
    EditTruck.Text := FTruck;
    EditMID.Text := FStockName;
    EditPID.Text := FCusName;

    EditMValue.Text := Format('%.2f', [FMData.FValue]);
    EditPValue.Text := Format('%.2f', [FPData.FValue]);
    EditZValue.Text := Format('%.2f', [FValue]);

    if (FValue > 0) and (FMData.FValue > 0) and (FPData.FValue > 0) then
    begin
      nVal := FMData.FValue - FPData.FValue;
      EditJValue.Text := Format('%.2f', [nVal]);
      EditWValue.Text := Format('%.2f', [FValue - nVal]);
    end else
    begin
      EditJValue.Text := '0.00';
      EditWValue.Text := '0.00';
    end;

    RadioPD.Checked := FPModel = sFlag_PoundPD;
    RadioCC.Checked := FPModel = sFlag_PoundCC;
    RadioLS.Checked := FPModel = sFlag_PoundLS;

    BtnSave.Enabled := FTruck <> '';
    BtnReadCard.Enabled := FTruck = '';
    BtnReadNumber.Enabled := FTruck <> '';

    RadioLS.Enabled := (FPoundID = '') and (FID = '');
    //已称过重量或销售,禁用临时模式
    RadioCC.Enabled := FID <> '';
    //只有销售有出厂模式

    EditBill.Properties.ReadOnly := (FID = '') and (FTruck <> '');
    EditTruck.Properties.ReadOnly := FTruck <> '';
    EditMID.Properties.ReadOnly := (FID <> '') or (FPoundID <> '');
    EditPID.Properties.ReadOnly := (FID <> '') or (FPoundID <> '');
    //可输入项调整

    EditMemo.Properties.ReadOnly := True;
    EditMValue.Properties.ReadOnly := not FPoundTunnel.FUserInput;
    EditPValue.Properties.ReadOnly := not FPoundTunnel.FUserInput;
    EditJValue.Properties.ReadOnly := True;
    EditZValue.Properties.ReadOnly := True;
    EditWValue.Properties.ReadOnly := True;
    //可输入量调整

    if FTruck = '' then
    begin
      EditMemo.Text := '';
      Exit;
    end;
  end;

  nInt := Length(FBillItems);
  if nInt > 0 then
  begin
    if nInt > 1 then
         nStr := '销售并单'
    else nStr := '销售';

    if FCardUsed=sFlag_Provide then nStr := '供应';

    if FUIData.FNextStatus = sFlag_TruckBFP then
    begin
      RadioCC.Enabled := False;
      EditMemo.Text := nStr + '称皮重';
    end else
    begin
      RadioCC.Enabled := True;
      EditMemo.Text := nStr + '称毛重';
    end;
  end else
  begin
    if RadioLS.Checked then
      EditMemo.Text := '车辆临时称重';
    //xxxxx

    if RadioPD.Checked then
      EditMemo.Text := '车辆配对称重';
    //xxxxx
  end;
end;

//Date: 2014-09-19
//Parm: 磁卡或交货单号
//Desc: 读取nCard对应的交货单
procedure TfFrameManualPoundItem.LoadBillItems(const nCard: string);
var nStr,nHint: string;
    nIdx,nInt: Integer;
    nBills: TLadingBillItems;
    nRes:Boolean;
    nBrickitem:Pbrickitem;
  nIsPreTruck:Boolean;
  nPrePValue:Double;
  nPrePMan:string;
  nPrePTime:TDateTime;    
begin
  if nCard = '' then
  begin
    EditBill.SetFocus;
    EditBill.SelectAll;
    ShowMsg('请输入磁卡号', sHint); Exit;
  end;
  FMemPoundSanZ := 0;
  FMemPoundSanZ_db := 0;
  FMemPoundSanF := 0;
  FMemPoundSanF_db := 0;

  FMemPoundbrickZ := 0;
  FMemPoundbrickZ_db := 0;
  FMemPoundbrickF := 0;
  FMemPoundbrickF_db := 0;

  FCardUsed := GetCardUsed(nCard);
  if (FCardUsed=sFlag_Provide) then
  begin
    if (not GetPurchaseOrders(nCard, sFlag_TruckBFP, nBills)) then
    begin
      SetUIData(True);
      Exit;
    end;
  end
  else if (FCardUsed = sFlag_sale) then
  begin
    if (not GetLadingBills(nCard, sFlag_TruckBFP, nBills)) then
    begin
      SetUIData(True);
      Exit;
    end;
  end
  else if (FCardUsed = sFlag_other) then
  begin
    if (not GetPurchaseOrders(nCard, sFlag_TruckBFP, nBills)) then
    begin
      SetUIData(True);
      Exit;
    end;
    for nIdx := Low(nBills) to High(nBills) do
    begin
      nIsPreTruck := getPrePInfo(nBills[nIdx].Ftruck,nPrePValue,nPrePMan,nPrePTime);
      //固定卡预置皮重，设置历史重量为0
      if nIsPreTruck and nBills[nIdx].FCardKeep and (nBills[nIdx].FStatus=sFlag_TruckIn) and (nBills[nIdx].FNextStatus=sFlag_TruckBFP) then
      begin
        nBills[nIdx].FPData.FStation := '';
        nBills[nIdx].FPData.FValue := 0;
        nBills[nIdx].FPData.FDate := Now;
        nBills[nIdx].FPData.FOperator := '';

        nBills[nIdx].FMData.FStation := '';
        nBills[nIdx].FMData.FValue := 0;
        nBills[nIdx].FMData.FDate := Now;
        nBills[nIdx].FMData.FOperator := '';
      end
      //交换皮重和毛重
      else begin
        //下一状态为毛重，皮重大于0，毛重等于0
        if (nBills[nIdx].FNextStatus=sFlag_TruckBFM) and (nBills[nIdx].FPData.FValue>0.0001) and (nBills[nIdx].FMData.FValue<0.0001) then
        begin
          nBills[nIdx].FMData.FValue := nBills[nIdx].FPData.FValue;
          nBills[nIdx].FMData.FStation := nBills[nIdx].FPData.FStation;
          nBills[nIdx].FMData.FDate := nBills[nIdx].FPData.FDate;
          nBills[nIdx].FMData.FOperator := nBills[nIdx].FPData.FOperator;

          nBills[nIdx].FPData.FStation := '';
          nBills[nIdx].FPData.FValue := 0;
          nBills[nIdx].FPData.FDate := Now;
          nBills[nIdx].FPData.FOperator := '';
        end;
      end;
    end;
  end;
//  if (FCardUsed=sFlag_Provide)
//      and (not GetPurchaseOrders(nCard, sFlag_TruckBFP, nBills)))
//    or
//    ((FCardUsed <> sFlag_Provide)
//      and (not GetLadingBills(nCard, sFlag_TruckBFP, nBills)))
//  then
//  begin
//    SetUIData(True);
//    Exit;
//  end;

  nHint := '';
  nInt := 0;

  for nIdx:=Low(nBills) to High(nBills) do
  with nBills[nIdx] do
  begin
    if (FStatus <> sFlag_TruckBFP) and (FNextStatus = sFlag_TruckZT) then
      FNextStatus := sFlag_TruckBFP;
    //状态校正

    FSelected := (FNextStatus = sFlag_TruckBFP) or
                 (FNextStatus = sFlag_TruckBFM);
    //可称重状态判定

    if FSelected then
    begin
      Inc(nInt);
      Continue;
    end;

    nStr := '※.单号:[ %s ] 状态:[ %-6s -> %-6s ]   ';
    if nIdx < High(nBills) then nStr := nStr + #13#10;

    nStr := Format(nStr, [FID,
            TruckStatusToStr(FStatus), TruckStatusToStr(FNextStatus)]);
    nHint := nHint + nStr;
  end;

  if nInt = 0 then
  begin
    nHint := '该车辆当前不能过磅,详情如下: ' + #13#10#13#10 + nHint;
    ShowDlg(nHint, sHint);
    Exit;
  end;

  EditBill.Properties.Items.Clear;
  SetLength(FBillItems, nInt);
  nInt := 0;

  for nIdx:=Low(nBills) to High(nBills) do
  with nBills[nIdx] do
  begin
    if FSelected then
    begin
      if (FCardUsed <> sFlag_other) then FPoundID := '';
      //该标记有特殊用途
      
      if nInt = 0 then
           FInnerData := nBills[nIdx]
      else FInnerData.FValue := FInnerData.FValue + FValue;
      //累计量

      EditBill.Properties.Items.Add(FID);
      FBillItems[nInt] := nBills[nIdx];
      Inc(nInt);
    end;
  end;

  FPdataOriginal := FInnerData.FPData;
  FMDataOriginal := FInnerData.FMData;
  FInnerData.FPModel := sFlag_PoundPD;
  FUIData := FInnerData;
  SetUIData(False);

  with gSysParam,nBills[0] do
  begin
    nBrickitem := getBrickItem(FStockNo);
    if Assigned(nBrickitem) then
    begin
      try
        GetPoundWc(StrToFloat(EditZValue.Text),FMemPoundbrickZ_db,FMemPoundbrickF_db,sFlag_wuchaType_Z);
      except
        on e:Exception do
        begin
          ShowMsg(e.Message,sHint);
        end;
      end;
    end
    else if (Fszbz='1') and (FType = sFlag_San) then
    begin
      try
        GetPoundWc(StrToFloat(EditZValue.Text),FMemPoundSanZ_db,FMemPoundSanF_db,sFlag_wuchaType_S);
      except
        on e:Exception do
        begin
          ShowMsg(e.Message,sHint);
        end;
      end;
    end
    else if FDaiPercent and (FType = sFlag_Dai) then
    begin
      try
        nRes:=GetPoundWc(StrToFloat(EditZValue.Text),FPoundDaiZ_1,FPoundDaiF_1);
      except
        on e:Exception do
        begin
          ShowMsg(e.Message,sHint);
        end;
      end;
    end;
  end;
  {$IFNDEF QHSN}
  nStr:=OpenDoor(nCard,'0');
  {$ENDIF}
  
  if not FPoundTunnel.FUserInput then
    gPoundTunnelManager.ActivePort(FPoundTunnel.FID, OnPoundData, True);
  //xxxxx
end;

//Date: 2014-09-25
//Parm: 车牌号
//Desc: 读取nTruck的称重信息
procedure TfFrameManualPoundItem.LoadTruckPoundItem(const nTruck: string);
var nData: TLadingBillItems;
begin
  if nTruck = '' then
  begin
    EditTruck.SetFocus;
    EditTruck.SelectAll;
    ShowMsg('请输入车牌号', sHint); Exit;
  end;

  if not GetTruckPoundItem(nTruck, nData) then
  begin
    SetUIData(True);
    Exit;
  end;

  FInnerData := nData[0];   
  FUIData := FInnerData;
  SetUIData(False);

  if not FPoundTunnel.FUserInput then
    gPoundTunnelManager.ActivePort(FPoundTunnel.FID, OnPoundData, True);
  //xxxxx
end;

//------------------------------------------------------------------------------
//Desc: 更新运行状态
procedure TfFrameManualPoundItem.Timer1Timer(Sender: TObject);
begin
  SetImageStatus(ImageGS, GetTickCount - FLastGS > 5 * 1000);
  SetImageStatus(ImageBT, GetTickCount - FLastBT > 5 * 1000);
  SetImageStatus(ImageBQ, GetTickCount - FLastBQ > 5 * 1000);
end;

//Desc: 关闭红绿灯
procedure TfFrameManualPoundItem.Timer2Timer(Sender: TObject);
var
  nStr:string;
begin
  Timer2.Tag := Timer2.Tag + 1;
  if Timer2.Tag < 10 then Exit;

  Timer2.Tag := 0;
  Timer2.Enabled := False;
  nStr:=TunnelOC(FPoundTunnel.FID,sFlag_No);
end;

//Desc: 表头数据
procedure TfFrameManualPoundItem.OnPoundData(const nValue: Double);
begin
  FLastBT := GetTickCount;
  EditValue.Text := Format('%.2f', [nValue]);
end;

//Desc: 设置通道
procedure TfFrameManualPoundItem.SetTunnel(const nTunnel: PPTTunnelItem);
begin
  FPoundTunnel := nTunnel;
  SetUIData(True);
end;

//Desc: 控制红绿灯
procedure TfFrameManualPoundItem.N1Click(Sender: TObject);
var
  nStr:string;
begin
  N1.Checked := not N1.Checked;
  //status change
  //{$IFDEF HR1847}
  //gKRMgrProber.TunnelOC(FPoundTunnel.FID, N1.Checked);
  //{$ELSE}
  //gProberManager.TunnelOC(FPoundTunnel.FID, N1.Checked);
  //{$ENDIF}
  if N1.Checked=True then
    nStr:=TunnelOC(FPoundTunnel.FID,sFlag_No)
  else
    nStr:=TunnelOC(FPoundTunnel.FID,sFlag_Yes);
end;

//Desc: 关闭称重页面
procedure TfFrameManualPoundItem.N3Click(Sender: TObject);
var nP: TWinControl;
begin
  nP := Parent;
  while Assigned(nP) do
  begin
    if (nP is TBaseFrame) and
       (TBaseFrame(nP).FrameID = cFI_FramePoundManual) then
    begin
      TBaseFrame(nP).Close();
      Exit;
    end;

    nP := nP.Parent;
  end;
end;

//Desc: 继续按钮
procedure TfFrameManualPoundItem.BtnNextClick(Sender: TObject);
begin
  SetUIData(True);
end;

procedure TfFrameManualPoundItem.EditBillKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    if EditBill.Properties.ReadOnly then Exit;

    EditBill.Text := Trim(EditBill.Text);
    LoadBillItems(EditBill.Text);
  end;
end;

procedure TfFrameManualPoundItem.EditTruckKeyPress(Sender: TObject;
  var Key: Char);
var nP: TFormCommandParam;
begin
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;
    if EditTruck.Properties.ReadOnly then Exit;

    EditTruck.Text := Trim(EditTruck.Text);
    LoadTruckPoundItem(EditTruck.Text);
  end;

  if Key = Char(VK_SPACE) then
  begin
    Key := #0;
    if EditTruck.Properties.ReadOnly then Exit;
    
    nP.FParamA := EditTruck.Text;
    CreateBaseFormItem(cFI_FormGetTruck, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and(nP.FParamA = mrOk) then
      EditTruck.Text := nP.FParamB;
    EditTruck.SelectAll;
  end;
end;

procedure TfFrameManualPoundItem.EditBillPropertiesEditValueChanged(
  Sender: TObject);
begin
  if EditBill.Properties.Items.Count > 0 then
  begin
    if EditBill.ItemIndex < 0 then
    begin
      EditBill.Text := FUIData.FID;
      Exit;
    end;

    with FBillItems[EditBill.ItemIndex] do
    begin
      if FUIData.FID = FID then Exit;
      //同单号
      
      FUIData.FID := FID;
      FUIData.FCusName := FCusName;
      FUIData.FStockName := FStockName;
    end;

    SetUIData(False);
    //ui
  end;
end;

//Desc: 读数
procedure TfFrameManualPoundItem.BtnReadNumberClick(Sender: TObject);
var nVal: Double;
begin
  if not IsNumber(EditValue.Text, True) then Exit;
  nVal := StrToFloat(EditValue.Text);
  if nVal < 0.05 then
  begin
    ShowMsg('重量异常，禁止保存。',sHint);
    Exit;
  end;

  if (Length(FBillItems) > 0) and (FCardUsed <> sFlag_Provide) then
  begin
    if FBillItems[0].FNextStatus = sFlag_TruckBFP then
         FUIData.FPData.FValue := nVal
    else FUIData.FMData.FValue := nVal;
  end else
  begin
    if FInnerData.FPData.FValue > 0 then
    begin
      if nVal <= FInnerData.FPData.FValue then
      begin
        FUIData.FPData := FInnerData.FMData;
        FUIData.FMData := FInnerData.FPData;

        FUIData.FPData.FValue := nVal;
        FUIData.FNextStatus := sFlag_TruckBFP;
        //切换为称皮重
      end else
      begin
        FUIData.FPData := FInnerData.FPData;
        FUIData.FMData := FInnerData.FMData;

        FUIData.FMData.FValue := nVal;
        FUIData.FNextStatus := sFlag_TruckBFM;
        //切换为称毛重
      end;
    end else FUIData.FPData.FValue := nVal;
  end;

  {$IFNDEF QHSN}
  if IsTunnelOK(FPoundTunnel.FID)= sFlag_No then
  begin
    ShowMsg('车辆未站稳,请稍后', sHint);
    Exit;
  end;
  {$ENDIF}
  SetUIData(False);

end;

//Desc: 由读头指定交货单
procedure TfFrameManualPoundItem.BtnReadCardClick(Sender: TObject);
var nStr: string;
    nInit: Int64;
    nChar: Char;
    nCard: string;
    nP: TFormCommandParam;
begin
  nCard := '';
  try
    BtnReadCard.Enabled := False;
    nInit := GetTickCount;

    while GetTickCount - nInit < 5 * 1000 do
    begin
      ShowWaitForm(ParentForm, '正在读卡', False);
      {$IFDEF QHSN}
      CreateBaseFormItem(cFI_FormReadCard, PopedomItem, @nP);
      if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;
      nStr := Trim(nP.FParamB);
      {$ELSE}
      nStr := ReadPoundCard(FPoundTunnel.FID);
      {$ENDIF}
      if nStr <> '' then
      begin
        nCard := nStr;
        Break;
      end else Sleep(1000);
    end;

    if nCard = '' then Exit;
    FCardTmp:= nCard;
    EditBill.Text := nCard;
    nChar := #13;
    EditBillKeyPress(nil, nChar);
    
  finally
    CloseWaitForm;
    if nCard = '' then
    begin
      BtnReadCard.Enabled := True;
      ShowMsg('没有读取成功,请重试', sHint);
    end;
  end;
end;

procedure TfFrameManualPoundItem.RadioPDClick(Sender: TObject);
begin
  if RadioPD.Checked then
    FUIData.FPModel := sFlag_PoundPD;
  if RadioCC.Checked then
    FUIData.FPModel := sFlag_PoundCC;
  if RadioLS.Checked then
    FUIData.FPModel := sFlag_PoundLS;
  //切换模式

  SetUIData(False);
end;

procedure TfFrameManualPoundItem.EditMValuePropertiesEditValueChanged(
  Sender: TObject);
var nVal: Double;
    nEdit: TcxTextEdit;
begin
  nEdit := Sender as TcxTextEdit;
  if not IsNumber(nEdit.Text, True) then Exit; 
  nVal := StrToFloat(nEdit.Text);

  if Sender = EditPValue then
  begin
//    if FUIData.FStatus=sFlag_TruckBFM then
//    begin
//      if abs(FPdataOriginal.FValue-nVal)>0.000001 then
//      begin
//        FUIData.FMData := FPdataOriginal;
//      end;
//    end;
    FUIData.FPData.FValue := nVal;
  end;
  //xxxxx

  if Sender = EditMValue then
    FUIData.FMData.FValue := nVal;
  SetUIData(False);
end;

procedure TfFrameManualPoundItem.EditMIDPropertiesChange(Sender: TObject);
begin
  if Sender = EditMID then
  begin
    if not EditMID.Focused then Exit;
    //非操作人员调整
    EditMID.Text := Trim(EditMID.Text);

    if EditMID.ItemIndex < 0 then
    begin
      FUIData.FStockNo := '';
      FUIData.FStockName := EditMID.Text;
    end else
    begin
      FUIData.FStockNo := GetCtrlData(EditMID);
      FUIData.FStockName := EditMID.Text;
    end;
  end else

  if Sender = EditPID then
  begin
    if not EditPID.Focused then Exit;
    //非操作人员调整
    EditPID.Text := Trim(EditPID.Text);

    if EditPID.ItemIndex < 0 then
    begin
      FUIData.FCusID := '';
      FUIData.FCusName := EditPID.Text;
    end else
    begin
      FUIData.FCusID := GetCtrlData(EditPID);
      FUIData.FCusName := EditPID.Text;
    end;
  end;
end;

//------------------------------------------------------------------------------
//Desc: 原材料或临时

function TfFrameManualPoundItem.SavePoundData: Boolean;
var nNextStatus: string;
begin
  Result := False;
  //init

  if (FUIData.FPData.FValue <= 0) and (FUIData.FMData.FValue <= 0) then
  begin
    ShowMsg('请先称重', sHint);
    Exit;
  end;

  if (FUIData.FPData.FValue > 0) and (FUIData.FMData.FValue > 0) then
  begin
    if FUIData.FPData.FValue > FUIData.FMData.FValue then
    begin
      ShowMsg('皮重应小于毛重', sHint);
      Exit;
    end;
  end;

  SetLength(FBillItems, 1);
  FBillItems[0] := FUIData;
  //复制用户界面数据
  
  with FBillItems[0] do
  begin
    FFactory := gSysParam.FFactNum;
    //xxxxx
    
    if FNextStatus = sFlag_TruckBFP then
         FPData.FStation := FPoundTunnel.FID
    else FMData.FStation := FPoundTunnel.FID;
  end;

  if (FCardUsed = sFlag_other) then
  begin
    if FBillItems[0].FStatus = sFlag_TruckIn then
      nNextStatus := sFlag_TruckBFP
    else nNextStatus := sFlag_TruckBFM;

    if FBillItems[0].FPData.FStation='' then FBillItems[0].FPData.FStation := FPoundTunnel.FID;
    if FBillItems[0].FMData.FStation='' then FBillItems[0].FMData.FStation := FPoundTunnel.FID;

    if FBillItems[0].FPData.FOperator='' then FBillItems[0].FPData.FOperator := gSysParam.FUserID;
    if FBillItems[0].FMData.FOperator='' then FBillItems[0].FMData.FOperator := gSysParam.FUserID;

    Result := SaveTruckPoundItem(FPoundTunnel, FBillItems);
    if Result then
    begin
      Result := SavePurchaseOrders(nNextStatus, FBillItems,FPoundTunnel);
    end;
    exit;
  end
  else if (FCardUsed = sFlag_Provide) then
  begin
    {$IFDEF GLPURCH}
    if FBillItems[0].FStatus = sFlag_TruckIn then
         nNextStatus := sFlag_TruckBFP
    else nNextStatus := sFlag_TruckBFM;
    {$ELSE}
    if (FBillItems[0].FStatus = sFlag_TruckBFP) or
      (FBillItems[0].FStatus = sFlag_TruckXH) then
         nNextStatus := sFlag_TruckBFM
    else nNextStatus := sFlag_TruckBFP;
    {$ENDIF}

    Result := SavePurchaseOrders(nNextStatus, FBillItems,FPoundTunnel);
  end else Result := SaveTruckPoundItem(FPoundTunnel, FBillItems);
  //保存称重
end;

//Desc: 保存销售
function TfFrameManualPoundItem.SavePoundSale: Boolean;
var nStr: string;
    nVal,nNet: Double;
    nFoutData: string;
    nSQL,nPrePUse: string;
    nBrickItem:PBrickItem;
begin
  Result := False;
  //init

  if FBillItems[0].FNextStatus = sFlag_TruckBFP then
  begin
    if FUIData.FPData.FValue <= 0 then
    begin
      ShowMsg('请先称量皮重', sHint);
      Exit;
    end;
    if FBillItems[0].FType = sFlag_San then
    begin
      nNet := GetTruckEmptyValue(FUIData.FTruck,nPrePUse);
      nVal := nNet * 1000 - FUIData.FPData.FValue * 1000;

      if (nNet > 0) and (Abs(nVal) > gSysParam.FPoundSanF) then
      begin
        nStr := '车辆[ %s ]实时皮重误差较大,详情如下:' + #13#10#13#10 +
                '※.实时皮重: %.2f吨' + #13#10 +
                '※.历史皮重: %.2f吨' + #13#10 +
                '※.误差量: %.2f公斤' + #13#10#13#10 +
                '是否继续保存?';
        nStr := Format(nStr, [FUIData.FTruck, FUIData.FPData.FValue,
                nNet, nVal]);
        if not QueryDlg(nStr, sAsk) then Exit;
      end;
    end;
  end else
  begin
    if FUIData.FMData.FValue <= 0 then
    begin
      ShowMsg('请先称量毛重', sHint);
      Exit;
    end;
  end;

  if (FUIData.FPData.FValue > 0) and (FUIData.FMData.FValue > 0) then
  begin
    if FBillItems[0].FYSValid <> sFlag_Yes then //判断是否空车出厂
    begin
      if FUIData.FPData.FValue > FUIData.FMData.FValue then
      begin
        ShowMsg('皮重应小于毛重', sHint);
        Exit;
      end;

      nNet := FUIData.FMData.FValue - FUIData.FPData.FValue;
      //净重
      nVal := nNet * 1000 - FInnerData.FValue * 1000;
      //与开票量误差(公斤)

      with gSysParam,FBillItems[0] do
      begin
        nBrickItem := getBrickItem(FStockNo);
        if Assigned(nBrickItem) then
        begin
          nVal := nNet * 1000 - FInnerData.FValue*nbrickitem.FTonOfPerSquare * 1000;
          if nVal>0 then
          begin
            FMemPoundBrickZ := Float2Float(FInnerData.FValue * FMemPoundBrickZ_db * 1000,
                                         cPrecision, False);
          end
          else begin
            FMemPoundBrickF := Float2Float(FInnerData.FValue * FMemPoundBrickF_db * 1000,
                                         cPrecision, False);
          end;
        end
        else if (Fszbz='1') and (FType=sFlag_San) then
        begin
          if nVal>0 then
          begin
            FMemPoundSanZ := Float2Float(FInnerData.FValue * FMemPoundSanZ_db * 1000,
                                         cPrecision, False);
          end
          else begin
            FMemPoundSanF := Float2Float(FInnerData.FValue * FMemPoundSanF_db * 1000,
                                         cPrecision, False);
          end;
        end
        else if FDaiPercent and (FType = sFlag_Dai) then
        begin
          if nVal > 0 then
               FPoundDaiZ := Float2Float(FInnerData.FValue * FPoundDaiZ_1 * 1000,
                                         cPrecision, False)
          else FPoundDaiF := Float2Float(FInnerData.FValue * FPoundDaiF_1 * 1000,
                                         cPrecision, False);
        end;

        if Assigned(nBrickItem) then
        begin
          nVal := nNet * 1000 - FInnerData.FValue * nbrickitem.FTonOfPerSquare * 1000;
          if ((nVal>0) and (FMemPoundBrickZ>0) and (nVal>FMemPoundBrickZ)) or
             ((nVal<0) and (FMemPoundBrickF>0) and (-nval>FMemPoundBrickF)) then
          begin
            nStr := '车辆[ %s ]实际装车量误差较大,详情如下:' + #13#10#13#10 +
                    '开单量: %.2f吨,' + //#13#10 +
                    '装车量: %.2f吨,';// + //#13#10 +
                    //'误差量: %.2f公斤';
            if nVal > 0 then
              nStr := nStr+'请卸%.2f公斤';
            if nVal < 0 then
              nStr := nStr+'请补%.2f公斤';
            
            try
              nSQL := 'Insert into '+sTable_PoundDevia+' (D_Bill,D_Truck,D_CusID,D_CusName,'+
                      'D_StockName,D_PlanValue,D_JValue,D_DeviaValue,D_Date) values ('''+FID+
                      ''','''+FTruck+''','''+FCusID+''','''+FCusName+''','''+FStockName+
                      ''','''+FloatToStr(FInnerData.FValue)+''','''+FormatFloat('0.00',nNet)+
                      ''','''+FormatFloat('0.00',nVal)+''','''+FormatDateTime('yyyy-mm-dd hh:mm:ss',Now)+''')';
              with FDM.SqlTemp do
              begin
                Close;
                SQL.Text:=nSQL;
                ExecSQL;
              end;
            except
              on e:Exception do
              begin
                ShowMsg('Save Devia Error: '+#10#13+e.Message,sHint);
              end;
            end;
            {$IFNDEF DEBUG}
            PlayVoice(nStr);
            {$ENDIF}
            nStr := nStr + #13#10#13#10 + '是否继续保存?';
            nStr := Format(nStr, [FTruck, FInnerData.FValue*nbrickitem.FTonOfPerSquare, nNet, Abs(nVal)]);
            if not QueryDlg(nStr, sAsk) then Exit;
          end;
        end
        else if ((FType = sFlag_Dai) and (
            ((nVal > 0) and (FPoundDaiZ > 0) and (nVal > FPoundDaiZ)) or
            ((nVal < 0) and (FPoundDaiF > 0) and (-nVal > FPoundDaiF)))) then
            {or
           ((FType = sFlag_San) and (
            (nVal < 0) and (FPoundSanF > 0) and (-nVal > FPoundSanF))) then}
        begin
          nStr := '车辆[ %s ]实际装车量误差较大,详情如下:' + #13#10#13#10 +
                  '开单量: %.2f吨,' + //#13#10 +
                  '装车量: %.2f吨,';// + //#13#10 +
                  //'误差量: %.2f公斤';
          if nVal > 0 then
            nStr := nStr+'请卸包%.2f公斤';
          if nVal < 0 then
            nStr := nStr+'请补包%.2f公斤';
            
          try
            nSQL := 'Insert into '+sTable_PoundDevia+' (D_Bill,D_Truck,D_CusID,D_CusName,'+
                    'D_StockName,D_PlanValue,D_JValue,D_DeviaValue,D_Date) values ('''+FID+
                    ''','''+FTruck+''','''+FCusID+''','''+FCusName+''','''+FStockName+
                    ''','''+FloatToStr(FInnerData.FValue)+''','''+FormatFloat('0.00',nNet)+
                    ''','''+FormatFloat('0.00',nVal)+''','''+FormatDateTime('yyyy-mm-dd hh:mm:ss',Now)+''')';
            with FDM.SqlTemp do
            begin
              Close;
              SQL.Text:=nSQL;
              ExecSQL;
            end;
          except
            on e:Exception do
            begin
              ShowMsg('Save Devia Error: '+#10#13+e.Message,sHint);
            end;
          end;
          {$IFNDEF DEBUG}
          PlayVoice(nStr);
          {$ENDIF}
          nStr := nStr + #13#10#13#10 + '是否继续保存?';
          nStr := Format(nStr, [FTruck, FInnerData.FValue, nNet, Abs(nVal)]);
          if not QueryDlg(nStr, sAsk) then Exit;
        end
	      else if ((Fszbz='1') and (FType = sFlag_San) and (
            ((nVal > 0) and (FMemPoundSanZ > 0) and (nVal > FMemPoundSanZ)) or
            ((nVal < 0) and (FMemPoundSanF > 0) and (Abs(nVal) > FMemPoundSanF)))) then
        begin
//          WriteLog('正误差值：'+floattostr(FMemPoundSanZ)+'  负误差值：'+floattostr(FMemPoundSanF));
          nStr := '车辆[%s]实际装车量误差较大，请通知司机核对';
          nStr := Format(nStr, [FTruck]);

          nStr := '车辆[ %s ]实际装车量误差较大,详情如下:' + #13#10#13#10 +
                  '开单量: %.2f吨,' +// #13#10 +
                  '装车量: %.2f吨,';// +// #13#10 +
                  //'误差量: %.2f公斤';
          if nVal > 0 then
            nStr := nStr+'请卸%.2f公斤';
          if nVal < 0 then
            nStr := nStr+'请补%.2f公斤';

          nSQL := 'Insert into '+sTable_PoundDevia+' (D_Bill,D_Truck,D_CusID,D_CusName,'+
                  'D_StockName,D_PlanValue,D_JValue,D_DeviaValue,D_Date) values ('''+FID+
                  ''','''+FTruck+''','''+FCusID+''','''+FCusName+''','''+FStockName+
                  ''','''+FloatToStr(FInnerData.FValue)+''','''+FormatFloat('0.00',nNet)+
                  ''','''+FormatFloat('0.00',nVal)+''','''+FormatDateTime('yyyy-mm-dd hh:mm:ss',Now)+''')';
          FDM.ExecuteSQL(nSQL);
          {$IFNDEF DEBUG}
          PlayVoice(nStr);
          {$ENDIF}
          nStr := nStr + #13#10#13#10 + '是否继续保存?';
          nStr := Format(nStr, [FTruck, FInnerData.FValue, nNet, Abs(nVal)]);
          if not QueryDlg(nStr, sAsk) then Exit;
        end;
      end;
    end;
  end;

  with FBillItems[0] do
  begin
    FPModel := FUIData.FPModel;
    FFactory := gSysParam.FFactNum;

    with FPData do
    begin
      FStation := FPoundTunnel.FID;
      FValue := FUIData.FPData.FValue;
      FOperator := gSysParam.FUserID;
    end;

    with FMData do
    begin
      FStation := FPoundTunnel.FID;
      FValue := FUIData.FMData.FValue;
      FOperator := gSysParam.FUserID;
    end;

    FPoundID := sFlag_Yes;
    //标记该项有称重数据
    Result := SaveLadingBills(nFoutData,FNextStatus, FBillItems, FPoundTunnel);
    //保存称重
    if Pos('余额不足',nFoutData)>0 then
    begin
      {$IFNDEF DEBUG}
      PlayVoice(nFoutData);
      {$ENDIF}
      Application.MessageBox(PChar(nFoutData),PChar('提示'),MB_OK);
      //Result:=True;
    end;
  end;
end;

//Desc: 保存称重
procedure TfFrameManualPoundItem.BtnSaveClick(Sender: TObject);
var
  nBool: Boolean;
  nStr:string;
begin
  {$IFNDEF QHSN}
  if IsTunnelOK(FPoundTunnel.FID)=sFlag_No then
  begin
    ShowMsg('车辆未站稳,请稍后', sHint);
    Exit;
  end;
  {$ENDIF}
  nBool := False;
  try
    BtnSave.Enabled := False;
    ShowWaitForm(ParentForm, '正在保存称重', True);
    
    if (Length(FBillItems) > 0) and (FCardUsed=sFlag_Sale) then
         nBool := SavePoundSale
    else nBool := SavePoundData;

    if nBool then
    begin
      {$IFNDEF DEBUG}
      PlayVoice(#9 + FUIData.FTruck);
      //播放语音
      TunnelOC(FPoundTunnel.FID,sFlag_Yes);
      //开红绿灯
      {$ENDIF}
      gPoundTunnelManager.ClosePort(FPoundTunnel.FID);
      //关闭表头
      {$IFNDEF QHSN}
      nStr:=OpenDoor(FCardTmp,'1');
      //开启出口道闸
      {$ENDIF}
      if (FUIData.FPoundID <> '') or RadioCC.Checked then
        PrintPoundReport(FUIData.FPoundID, True);
      //原料或出厂模式

      SetUIData(True);
      BroadcastFrameCommand(Self, cCmd_RefreshData);
      ShowMsg('称重保存完毕', sHint);
    end;
  finally
    BtnSave.Enabled := not nBool;
    CloseWaitForm;
  end;
end;

procedure TfFrameManualPoundItem.PlayVoice(const nStrtext: string);
begin
  if UpperCase(FPoundTunnel.FOptions.Values['Voice'])='NET' then
       gNetVoiceHelper.PlayVoice(nStrtext, FPoundTunnel.FID, 'pound')
  else gVoiceHelper.PlayVoice(nStrtext);
end;

procedure TfFrameManualPoundItem.initBrickItems;
var
  nStr:string;
  nItem : PBrickItem;
  nparam:Double;
begin
  nstr := 'select * from %s where d_name=''%s''';
  nStr := Format(nStr,[sTable_SysDict,sFlag_BrickItem]);
  with FDM.QuerySQL(nStr) do
  begin
    while not Eof do
    begin
      New(nItem);
      nItem.Fcode := FieldByName('d_desc').AsString;
      nparam := FieldByName('d_ParamA').AsFloat;
      nItem.FTonOfPerSquare := nparam;
      nItem.FSquareOfPerTon := 1 / nparam;
      FBrickItemList.Add(nItem);
      Next;
    end;
  end;
end;

function TfFrameManualPoundItem.getBrickItem(
  const stockno: string): PBrickItem;
var
  i:integer;
  nItem:PBrickItem;
begin
  Result := nil;
  for i := 0 to FBrickItemList.Count-1 do
  begin
    nItem := PBrickItem(FBrickItemList.Items[i]);
    if nitem.Fcode=stockno then
    begin
      Result := FBrickItemList.Items[i];
      Break;
    end;
  end;
end;

function TfFrameManualPoundItem.getPrePInfo(const nTruck: string;
  var nPrePValue: Double; var nPrePMan: string;
  var nPrePTime: TDateTime): Boolean;
var
  nStr:string;
begin
  Result := False;
  nPrePValue := 0;
  nPrePMan := '';
  nPrePTime := now;
  nStr := 'select T_PrePValue,T_PrePMan,T_PrePTime from %s where t_truck=''%s'' and T_PrePUse=''%s''';
  nStr := format(nStr,[sTable_Truck,nTruck,sflag_yes]);
  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount>0 then
    begin
      nPrePValue := FieldByName('T_PrePValue').asFloat;;
      nPrePMan := FieldByName('T_PrePMan').asString;
      nPrePTime := FieldByName('T_PrePTime').asDateTime;
      if nPrePValue>0.00001 then
      begin
        Result := True;
      end;
    end;
  end; 
end;

end.
