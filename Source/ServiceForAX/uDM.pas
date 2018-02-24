unit uDM;

interface

uses
  SysUtils, Classes, IniFiles, DB, ADODB, USysLoger;

type
  TDM = class(TDataModule)
    ADOCLoc: TADOConnection;
    ADOCRem: TADOConnection;
    qryLoc: TADOQuery;
    qryRem: TADOQuery;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  TLocDB= record
    DBUser:string;
    DBPwd:string;
    DBCatalog:string;
    DBSource:string;
  end;

type
  TRemDB= record
    DBUser:string;
    DBPwd:string;
    DBCatalog:string;
    DBSource:string;
  end;

var
  DM: TDM;
  LocalDBConn,RemDBConn:string;

implementation

{$R *.dfm}

procedure TDM.DataModuleCreate(Sender: TObject);
var
  myini:TIniFile;
  RemDB:TRemDB;
  LocDB:TLocDB;
begin
  myini:=TIniFile.Create('.\DBConn.Ini');
  try
    RemDB.DBUser:=myini.ReadString('Զ��','DBUser','');
    RemDB.DBPwd:=myini.ReadString('Զ��','DBPwd','');
    RemDB.DBCatalog:=myini.ReadString('Զ��','DBCatalog','');
    RemDB.DBSource:=myini.ReadString('Զ��','DBSource','');
    LocDB.DBUser:=myini.ReadString('����','DBUser','');
    LocDB.DBPwd:=myini.ReadString('����','DBPwd','');
    LocDB.DBCatalog:=myini.ReadString('����','DBCatalog','');
    LocDB.DBSource:=myini.ReadString('����','DBSource','');
  finally
    myini.Free;
  end;
  RemDBConn:='Provider=SQLOLEDB.1;'+
             'Password='+RemDB.DBPwd+';'+
             'Persist Security Info=True;'+
             'User ID='+RemDB.DBUser+';'+
             'Initial Catalog='+RemDB.DBCatalog+';'+
             'Data Source='+RemDB.DBSource;
  LocalDBConn:='Provider=SQLOLEDB.1;'+
                 'Password='+LocDB.DBPwd+';'+
                 'Persist Security Info=True;'+
                 'User ID='+LocDB.DBUser+';'+
                 'Initial Catalog='+LocDB.DBCatalog+';'+
                 'Data Source='+LocDB.DBSource;
  ADOCRem.ConnectionString:=RemDBConn;
  ADOCRem.Connected:=True;
  ADOCLoc.ConnectionString:=LocalDBConn;
  ADOCLoc.Connected:=True;
end;


end.
