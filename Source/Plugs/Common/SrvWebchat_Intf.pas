unit SrvWebchat_Intf;

{----------------------------------------------------------------------------}
{ This unit was automatically generated by the RemObjects SDK after reading  }
{ the RODL file associated with this project .                               }
{                                                                            }
{ Do not modify this unit manually, or your changes will be lost when this   }
{ unit is regenerated the next time you compile the project.                 }
{----------------------------------------------------------------------------}

{$I RemObjects.inc}

interface

uses
  {vcl:} Classes, TypInfo,
  {RemObjects:} uROXMLIntf, uROClasses, uROClient, uROTypes, uROClientIntf;

const
  { Library ID }
  LibraryUID = '{8FF49365-D4C5-4301-9D3C-493784018061}';
  TargetNamespace = '';

  { Service Interface ID's }
  ISrvConnection_IID : TGUID = '{30A80C68-1812-4316-9630-F29666783010}';
  ISrvBusiness_IID : TGUID = '{D9C1921A-7420-42B7-9EC9-64D2C1AB73A5}';
  ISrvWebchat_IID : TGUID = '{66454F96-DB5F-421A-9483-B4D647D605FC}';

  { Event ID's }

type
  { Forward declarations }
  ISrvConnection = interface;
  ISrvBusiness = interface;
  ISrvWebchat = interface;


  { ISrvConnection }

  { Description:
      Service For Login Verify,SweetHeart ETC. }
  ISrvConnection = interface
    ['{30A80C68-1812-4316-9630-F29666783010}']
    function Action(const nFunName: AnsiString; var nData: AnsiString): Boolean;
  end;

  { CoSrvConnection }
  CoSrvConnection = class
    class function Create(const aMessage: IROMessage; aTransportChannel: IROTransportChannel): ISrvConnection;
  end;

  { TSrvConnection_Proxy }
  TSrvConnection_Proxy = class(TROProxy, ISrvConnection)
  protected
    function __GetInterfaceName:string; override;

    function Action(const nFunName: AnsiString; var nData: AnsiString): Boolean;
  end;

  { ISrvBusiness }

  { Description:
      Service For Business }
  ISrvBusiness = interface
    ['{D9C1921A-7420-42B7-9EC9-64D2C1AB73A5}']
    function Action(const nFunName: AnsiString; var nData: AnsiString): Boolean;
  end;

  { CoSrvBusiness }
  CoSrvBusiness = class
    class function Create(const aMessage: IROMessage; aTransportChannel: IROTransportChannel): ISrvBusiness;
  end;

  { TSrvBusiness_Proxy }
  TSrvBusiness_Proxy = class(TROProxy, ISrvBusiness)
  protected
    function __GetInterfaceName:string; override;

    function Action(const nFunName: AnsiString; var nData: AnsiString): Boolean;
  end;

  { ISrvWebchat }

  { Description:
      Service For Webchat }
  ISrvWebchat = interface
    ['{66454F96-DB5F-421A-9483-B4D647D605FC}']
    function Action(const nFunName: AnsiString; var nData: AnsiString): Boolean;
  end;

  { CoSrvWebchat }
  CoSrvWebchat = class
    class function Create(const aMessage: IROMessage; aTransportChannel: IROTransportChannel): ISrvWebchat;
  end;

  { TSrvWebchat_Proxy }
  TSrvWebchat_Proxy = class(TROProxy, ISrvWebchat)
  protected
    function __GetInterfaceName:string; override;

    function Action(const nFunName: AnsiString; var nData: AnsiString): Boolean;
  end;

implementation

uses
  {vcl:} SysUtils,
  {RemObjects:} uROEventRepository, uROSerializer, uRORes;

{ CoSrvConnection }

class function CoSrvConnection.Create(const aMessage: IROMessage; aTransportChannel: IROTransportChannel): ISrvConnection;
begin
  result := TSrvConnection_Proxy.Create(aMessage, aTransportChannel);
end;

{ TSrvConnection_Proxy }

function TSrvConnection_Proxy.__GetInterfaceName:string;
begin
  result := 'SrvConnection';
end;

function TSrvConnection_Proxy.Action(const nFunName: AnsiString; var nData: AnsiString): Boolean;
begin
  try
    __Message.InitializeRequestMessage(__TransportChannel, 'NewLibrary', __InterfaceName, 'Action');
    __Message.Write('nFunName', TypeInfo(AnsiString), nFunName, []);
    __Message.Write('nData', TypeInfo(AnsiString), nData, []);
    __Message.Finalize;

    __TransportChannel.Dispatch(__Message);

    __Message.Read('Result', TypeInfo(Boolean), result, []);
    __Message.Read('nData', TypeInfo(AnsiString), nData, []);
  finally
    __Message.UnsetAttributes(__TransportChannel);
    __Message.FreeStream;
  end
end;

{ CoSrvBusiness }

class function CoSrvBusiness.Create(const aMessage: IROMessage; aTransportChannel: IROTransportChannel): ISrvBusiness;
begin
  result := TSrvBusiness_Proxy.Create(aMessage, aTransportChannel);
end;

{ TSrvBusiness_Proxy }

function TSrvBusiness_Proxy.__GetInterfaceName:string;
begin
  result := 'SrvBusiness';
end;

function TSrvBusiness_Proxy.Action(const nFunName: AnsiString; var nData: AnsiString): Boolean;
begin
  try
    __Message.InitializeRequestMessage(__TransportChannel, 'NewLibrary', __InterfaceName, 'Action');
    __Message.Write('nFunName', TypeInfo(AnsiString), nFunName, []);
    __Message.Write('nData', TypeInfo(AnsiString), nData, []);
    __Message.Finalize;

    __TransportChannel.Dispatch(__Message);

    __Message.Read('Result', TypeInfo(Boolean), result, []);
    __Message.Read('nData', TypeInfo(AnsiString), nData, []);
  finally
    __Message.UnsetAttributes(__TransportChannel);
    __Message.FreeStream;
  end
end;

{ CoSrvWebchat }

class function CoSrvWebchat.Create(const aMessage: IROMessage; aTransportChannel: IROTransportChannel): ISrvWebchat;
begin
  result := TSrvWebchat_Proxy.Create(aMessage, aTransportChannel);
end;

{ TSrvWebchat_Proxy }

function TSrvWebchat_Proxy.__GetInterfaceName:string;
begin
  result := 'SrvWebchat';
end;

function TSrvWebchat_Proxy.Action(const nFunName: AnsiString; var nData: AnsiString): Boolean;
begin
  try
    __Message.InitializeRequestMessage(__TransportChannel, 'NewLibrary', __InterfaceName, 'Action');
    __Message.Write('nFunName', TypeInfo(AnsiString), nFunName, []);
    __Message.Write('nData', TypeInfo(AnsiString), nData, []);
    __Message.Finalize;

    __TransportChannel.Dispatch(__Message);

    __Message.Read('Result', TypeInfo(Boolean), result, []);
    __Message.Read('nData', TypeInfo(AnsiString), nData, []);
  finally
    __Message.UnsetAttributes(__TransportChannel);
    __Message.FreeStream;
  end
end;

initialization
  RegisterProxyClass(ISrvConnection_IID, TSrvConnection_Proxy);
  RegisterProxyClass(ISrvBusiness_IID, TSrvBusiness_Proxy);
  RegisterProxyClass(ISrvWebchat_IID, TSrvWebchat_Proxy);


finalization
  UnregisterProxyClass(ISrvConnection_IID);
  UnregisterProxyClass(ISrvBusiness_IID);
  UnregisterProxyClass(ISrvWebchat_IID);

end.
