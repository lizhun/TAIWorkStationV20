unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  IdHTTP, IdCoder, IdCoder3to4, IdCoderMIME, IdMultipartFormData,
  TencentAIHelper, DB, ADODB, ExtCtrls;

type
  TForm1 = class(TForm)
    idhtp1: TIdHTTP;
    idcdrm1: TIdDecoderMIME;
    mmo1: TMemo;
    idncdrm1: TIdEncoderMIME;
    con1: TADOConnection;
    btn4: TButton;
    lbledtpatid: TLabeledEdit;
    lbledtimageId: TLabeledEdit;
    lbledtserver: TLabeledEdit;
    lbledtimgLocalRootPath: TLabeledEdit;
    lbledtimgServerRootPath: TLabeledEdit;
    btngetAIREsult: TButton;
    lbledtusername: TLabeledEdit;
    lbledtpassword: TLabeledEdit;
    lbledtdbbase: TLabeledEdit;  
    procedure btn4Click(Sender: TObject);
    procedure btngetAIREsultClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.btn4Click(Sender: TObject);
var
  helper: TTencentAIManager;
  imgids: TArrayImageId;
begin
  helper := TTencentAIManager.Create;
  helper.imgLocalRootPath := lbledtimgLocalRootPath.Text;
  helper.imgServerRootPath := lbledtimgServerRootPath.Text;
  SetLength(imgids, 1);
  imgids[0] := lbledtimageId.Text;
  con1.Close;
  con1.ConnectionString := 'Provider=SQLOLEDB.1;User ID='+ lbledtusername.Text+
    ';Password='+ lbledtpassword.Text +
    ';Data Source='+ lbledtserver.Text +
    ';Initial Catalog='+ lbledtdbbase.Text;
  helper.MSendAIDataFromDb(con1, lbledtpatid.Text, imgids);
end;

procedure TForm1.btngetAIREsultClick(Sender: TObject);
var
  helper: TTencentAIManager;
  imgids: TArrayImageId;
begin
  helper := TTencentAIManager.Create;
  helper.imgLocalRootPath := lbledtimgLocalRootPath.Text;
  helper.imgServerRootPath := lbledtimgServerRootPath.Text;  
  con1.Close;
  con1.ConnectionString := 'Provider=SQLOLEDB.1;User ID='+ lbledtusername.Text+
    ';Password='+ lbledtpassword.Text +
    ';Data Source='+ lbledtserver.Text +
    ';Initial Catalog='+ lbledtdbbase.Text;
  ShowMessage(helper.MGetAIResult(con1, lbledtpatid.Text).CodeName) ;

end;

end.

