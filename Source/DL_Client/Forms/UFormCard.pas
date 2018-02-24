{*******************************************************************************
  ����: dmzn@163.com 2012-4-5
  ����: �����ſ�
*******************************************************************************}
unit UFormCard;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  CPort, CPortTypes, UFormNormal, UFormBase, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxLabel, cxTextEdit,
  dxLayoutControl, StdCtrls, cxGraphics, dxLayoutcxEditAdapters;

type
  TfFormCard = class(TfFormNormal)
    EditBill: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditTruck: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item5: TdxLayoutItem;
    EditCard: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    ComPort1: TComPort;
    procedure BtnOKClick(Sender: TObject);
    procedure ComPort1RxChar(Sender: TObject; Count: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditCardKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    FBuffer: string;
    //���ջ���
    FParam: PFormCommandParam;
    procedure InitFormData;
    procedure ActionComPort(const nStop: Boolean);
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UMgrControl, USysBusiness, USmallFunc, USysConst, USysDB,
  UBusinessConst;

type
  TReaderType = (ptT800, pt8142);
  //��ͷ����

  TReaderItem = record
    FType: TReaderType;
    FPort: string;
    FBaud: string;
    FDataBit: Integer;
    FStopBit: Integer;
    FCheckMode: Integer;
  end;

var
  gReaderItem: TReaderItem;
  //ȫ��ʹ��
  gBills: TLadingBillItems;
  //������б�

class function TfFormCard.FormID: integer;
begin
  Result := cFI_FormMakeCard;
end;

class function TfFormCard.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
begin
  Result := nil;
  if not Assigned(nParam) then Exit;

  with TfFormCard.Create(Application) do
  try
    FParam := nParam;

    if FParam.FParamC=sFlag_Provide then
         dxLayout1Item3.Caption := '�ɹ�����'
    else dxLayout1Item3.Caption := '��������';

    InitFormData;
    ActionComPort(False);

    FParam.FCommand := cCmd_ModalResult;
    FParam.FParamA := ShowModal;
  finally
    Free;
  end;
end;

procedure TfFormCard.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ActionComPort(True);
end;

procedure TfFormCard.InitFormData;
begin
  ActiveControl := EditCard;
  EditTruck.Text := FParam.FParamB;
  EditBill.Text := AdjustListStrFormat(FParam.FParamA, '''', False, ',', False);
end;

//Desc: ���ڲ���
procedure TfFormCard.ActionComPort(const nStop: Boolean);
var nInt: Integer;
    nIni: TIniFile;
begin
  if nStop then
  begin
    ComPort1.Close;
    Exit;
  end;

  with ComPort1 do
  begin
    with Timeouts do
    begin
      ReadTotalConstant := 100;
      ReadTotalMultiplier := 10;
    end;

    nIni := TIniFile.Create(gPath + 'Reader.Ini');
    with gReaderItem do
    try
      nInt := nIni.ReadInteger('Param', 'Type', 1);
      FType := TReaderType(nInt - 1);

      FPort := nIni.ReadString('Param', 'Port', '');
      FBaud := nIni.ReadString('Param', 'Rate', '4800');
      FDataBit := nIni.ReadInteger('Param', 'DataBit', 8);
      FStopBit := nIni.ReadInteger('Param', 'StopBit', 0);
      FCheckMode := nIni.ReadInteger('Param', 'CheckMode', 0);

      Port := FPort;
      BaudRate := StrToBaudRate(FBaud);

      case FDataBit of
       5: DataBits := dbFive;
       6: DataBits := dbSix;
       7: DataBits :=  dbSeven else DataBits := dbEight;
      end;

      case FStopBit of
       2: StopBits := sbTwoStopBits;
       15: StopBits := sbOne5StopBits
       else StopBits := sbOneStopBit;
      end;
    finally
      nIni.Free;
    end;

    if ComPort1.Port <> '' then
      ComPort1.Open;
    //xxxxx
  end;
end;

procedure TfFormCard.ComPort1RxChar(Sender: TObject; Count: Integer);
var nStr: string;
    nIdx,nLen: Integer;
begin
  ComPort1.ReadStr(nStr, Count);
  FBuffer := FBuffer + nStr;

  nLen := Length(FBuffer);
  if nLen < 7 then Exit;

  for nIdx:=1 to nLen do
  begin
    if (FBuffer[nIdx] <> #$AA) or (nLen - nIdx < 6) then Continue;
    if (FBuffer[nIdx+1] <> #$FF) or (FBuffer[nIdx+2] <> #$00) then Continue;

    nStr := Copy(FBuffer, nIdx+3, 4);
    EditCard.Text := ParseCardNO(nStr, True); 

    FBuffer := '';
    Exit;
  end;
end;

procedure TfFormCard.EditCardKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    BtnOK.Click;
  end else OnCtrlKeyPress(Sender, Key);
end;

//Desc: ����ſ�
procedure TfFormCard.BtnOKClick(Sender: TObject);
var nRet: Boolean;
    nStr, nHint: string;
    nIdx: Integer;
    nStockNo,nNeiDao:string;
begin
  EditCard.Text := Trim(EditCard.Text);
  if EditCard.Text = '' then
  begin
    ActiveControl := EditCard;
    EditCard.SelectAll;

    ShowMsg('��������Ч����', sHint);
    Exit;
  end;

  if FParam.FParamC = sFlag_Provide then
       nRet := SaveOrderCard(EditBill.Text, EditCard.Text)
  else nRet := SaveBillCard(EditBill.Text, EditCard.Text);
  if nRet then
  begin
    {$IFDEF GLPURCH}
    if FParam.FParamC = sFlag_Provide then
    begin
      if GetPurchaseOrders(EditCard.Text, sFlag_TruckIn, gBills) then
      begin
        nHint := '';
        for nIdx:=Low(gBills) to High(gBills) do
        if gBills[nIdx].FStatus <> sFlag_TruckNone then
        begin
          nStr := '��.����:[ %s ] ״̬:[ %-6s -> %-6s ]   ';
          if nIdx < High(gBills) then nStr := nStr + #13#10;

          nStr := Format(nStr, [gBills[nIdx].FID,
                  TruckStatusToStr(gBills[nIdx].FStatus),
                  TruckStatusToStr(gBills[nIdx].FNextStatus)]);
          nHint := nHint + nStr;
          if gBills[nIdx].FStatus = sFlag_TruckIn then
          begin
            ModalResult := mrOk;
            Exit;
          end;
        end;

        if nHint <> '' then
        begin
          nHint := '�ó�����ǰ���ܽ���,��������: ' + #13#10#13#10 + nHint;
          ShowDlg(nHint, sHint);
          Exit;
        end;
        if SavePurchaseOrders(sFlag_TruckIn, gBills) then
        begin
          ShowMsg('���������ɹ�', sHint);
        end else
        begin
          ShowMsg('��������ʧ��', sHint);
          Exit;
        end;
      end else
      begin
        ShowMsg('�ó������ܽ��������飺'+#13#10#13#10+'��ȡ��λ����ʧ��', sHint);
        Exit;
      end;
    end;
    {$ELSE}
    if FParam.FParamC = sFlag_Provide then
    begin
      if GetPurchaseOrders(EditCard.Text, sFlag_TruckIn, gBills) then
      begin
        nHint := '';
        for nIdx:=Low(gBills) to High(gBills) do
        begin
          if gBills[nIdx].FStatus <> sFlag_TruckNone then
          begin
            nStr := '��.����:[ %s ] ״̬:[ %-6s -> %-6s ]   ';
            if nIdx < High(gBills) then nStr := nStr + #13#10;

            nStr := Format(nStr, [gBills[nIdx].FID,
                    TruckStatusToStr(gBills[nIdx].FStatus),
                    TruckStatusToStr(gBills[nIdx].FNextStatus)]);
            nHint := nHint + nStr;
            if gBills[nIdx].FStatus = sFlag_TruckIn then
            begin
              ModalResult := mrOk;
              Exit;
            end;
          end;
          nStockNo:=gBills[nIdx].FStockNo;
        end;

        if nHint <> '' then
        begin
          nHint := '�ó�����ǰ���ܽ���,��������: ' + #13#10#13#10 + nHint;
          ShowDlg(nHint, sHint);
          Exit;
        end;
        if GetAutoInFactory(nStockNo) then
        begin
          if SavePurchaseOrders(sFlag_TruckIn, gBills) then
          begin
            ShowMsg('���������ɹ�', sHint);
          end else
          begin
            ShowMsg('��������ʧ��', sHint);
            Exit;
          end;
        end;
      end else
      begin
        ShowMsg('�ó������ܽ��������飺'+#13#10#13#10+'��ȡ��λ����ʧ��', sHint);
        Exit;
      end;
    end else
    begin
      if GetLadingBills(EditCard.Text, sFlag_TruckIn, gBills) then
      begin
        nHint := '';
        for nIdx:=Low(gBills) to High(gBills) do
        begin
          if gBills[nIdx].FStatus <> sFlag_TruckNone then
          begin
            nStr := '��.����:[ %s ] ״̬:[ %-6s -> %-6s ]   ';
            if nIdx < High(gBills) then nStr := nStr + #13#10;

            nStr := Format(nStr, [gBills[nIdx].FID,
                    TruckStatusToStr(gBills[nIdx].FStatus),
                    TruckStatusToStr(gBills[nIdx].FNextStatus)]);
            nHint := nHint + nStr;
            if gBills[nIdx].FStatus = sFlag_TruckIn then
            begin
              ModalResult := mrOk;
              Exit;
            end;
          end;
          nStockNo:=gBills[nIdx].FStockNo;
          nNeiDao:= gBills[nIdx].FNeiDao;
        end;

        if nHint <> '' then
        begin
          nHint := '�ó�����ǰ���ܽ���,��������: ' + #13#10#13#10 + nHint;
          ShowDlg(nHint, sHint);
          Exit;
        end;
        if nNeiDao='Y' then
        begin
          if SaveLadingBills(nStr,sFlag_TruckIn, gBills) then
          begin
            ShowMsg('���������ɹ�', sHint);
          end else
          begin
            ShowMsg('��������ʧ��', sHint);
            Exit;
          end;
        end;
      end else
      begin
        ShowMsg('�ó������ܽ��������飺'+#13#10#13#10+'��ȡ��λ����ʧ��', sHint);
        Exit;
      end;
    end;
    {$ENDIF}
    ModalResult := mrOk;
    //done
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormCard, TfFormCard.FormID);
end.
