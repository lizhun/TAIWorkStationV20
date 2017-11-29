unit TencentAIHelper;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IdComponent, IdHTTP, IdCoder, IdCoderMIME, IdMultipartFormData,
  IniFiles, ADODB, xmldom, XMLDoc, msxmldom, XMLIntf;

type
  TTencentAIUploadImage = class
    imageId: string;
   // Url: string;
   // DescPosition: string;
    Content: string;
    filePath: string;
  end;

type
  TTencentAIResult = class
    Code: string;
    CodeName: string;
    Url: string;
  end;

type
  TArrayTTencentAIUploadImage = array of TTencentAIUploadImage;

type
  TArrayImageId = array of string;

type
  TencentAIFrontUrl = (UploadDataUrl, GetAIResultUrl, UploadReportUrl);

type
  TTencentAIUploadData = class
    DbType: string;                    //必填 这个是程序内部使用，如WJ CJ ZXJ XZJ
    PatId: string;      
   // StudyId: string;                 //必填 这个是唯一ID，将由前置服务器自动生成
    StudyType: string;                 //必填 报告类型   1 食管癌 2 眼底 3肠镜 4 肺结节
    StudyDate: string;                 //必填 报告日期 yyyy-mm-dd 如1988-11-11
    StudyName: string;                 //必填 检查名称
    PatientId: string;                 //必填 病人在医院对应的ID
    PatientName: string;               //必填 病人姓名
    PatientGender: string;             //必填 性别  0未知，1男，2女，3其它
    PatientBirthday: string;           //必填 生日 yyyy-mm-dd 如1988-11-11
    Images: TArrayTTencentAIUploadImage; //必填 图片信息  至少传一张
  end;

type
  TTencentAIManager = class
  private
    _OnBeforeSend: TNotifyEvent;
    function _GetWebSVRUrl(urlType: TencentAIFrontUrl): string;
    function _GetAIDataFromDb(con: TADOConnection; patId: string; imageIds: TArrayImageId): TTencentAIUploadData;
    function _GetTencentAIUploadData(con: TADOConnection; patId: string): TTencentAIUploadData;
    function _ImageToBuffer(AImgFile: string): string;
  public
    ImgLocalRootPath: string;
    ImgServerRootPath: string;
    function MSendAIDataFromDb(con: TADOConnection; patId: string; imageIds: TArrayImageId): string;
    function MSendAIData(data: TTencentAIUploadData): string;
    function MGetAIResult(con: TADOConnection; patId: string): TTencentAIResult;
    property OnBeforeSend: TNotifyEvent read _OnBeforeSend write _OnBeforeSend;
    function MakeUploadImage(imageId: string; filePath: string): TTencentAIUploadImage;
  end;

implementation

function TTencentAIManager.MSendAIDataFromDb(con: TADOConnection; patId: string; imageIds: TArrayImageId): string;
var
  data: TTencentAIUploadData;
  res: string;
begin
  data := _GetAIDataFromDb(con, patId, imageIds);
  res := MSendAIData(data);
  Result := res;
end;

function TTencentAIManager.MGetAIResult(con: TADOConnection; patId: string): TTencentAIResult;
var
  postForm: TIdMultiPartFormDataStream;
  http: TIdHTTP;
  res: string;
  data: TTencentAIUploadData;
  list: TStringList;
  resultdata: TTencentAIResult;
begin
  postForm := TIdMultiPartFormDataStream.Create;
  data := _GetTencentAIUploadData(con, patId);
  postForm.AddFormField('DbType', data.DbType);
  postForm.AddFormField('PatId', data.PatId);
  http := TIdHTTP.Create(nil);
  res := http.Post(_GetWebSVRUrl(GetAIResultUrl), postForm);
  res := UTF8Decode(res);
  list := TStringList.Create;
  ExtractStrings(['$'],[], PChar(res), list);
  resultdata := TTencentAIResult.Create;
  resultdata.Code := list[0];
  resultdata.CodeName := list[1];
  resultdata.Url := list[2];
  Result := resultdata;
end;

function TTencentAIManager.MSendAIData(data: TTencentAIUploadData): string;
var
  postForm: TIdMultiPartFormDataStream;
  http: TIdHTTP;
  i, ilen: Integer;
  res: string;
begin
  postForm := TIdMultiPartFormDataStream.Create;
  http := TIdHTTP.Create(nil);

  postForm.AddFormField('DbType', data.DbType);
  postForm.AddFormField('PatId', data.PatId);
  //postForm.AddFormField('StudyId', data.StudyId);
  postForm.AddFormField('StudyType', data.StudyType);
  postForm.AddFormField('StudyName', AnsiToUtf8(data.StudyName));
  postForm.AddFormField('PatientId', data.PatientId);
  postForm.AddFormField('PatientName', AnsiToUtf8(data.PatientName));
  postForm.AddFormField('PatientGender', data.PatientGender);
  postForm.AddFormField('PatientBirthday', AnsiToUtf8(data.PatientBirthday));
  postForm.AddFormField('StudyDate', data.StudyDate);
  ilen := Length(data.Images);
  for i := 0 to ilen - 1 do
  begin
    postForm.AddFormField('img_' + data.Images[i].imageId + '_content', _ImageToBuffer(ImgLocalRootPath + data.Images[i].filePath));
    postForm.AddFormField('img_' + data.Images[i].imageId + '_url', ImgServerRootPath + data.Images[i].filePath);
  end;
  if Assigned(OnBeforeSend) then
  begin
    OnBeforeSend(Self);
  end;
  res := http.Post(_GetWebSVRUrl(UploadDataUrl), postForm);
  FreeAndNil(http);
  FreeAndNil(postForm);
  Result := res;
end;

function TTencentAIManager._GetTencentAIUploadData(con: TADOConnection; patId: string): TTencentAIUploadData;
var
  data: TTencentAIUploadData;
  query: TADOQuery;
  i, len: Integer;
begin
  data := TTencentAIUploadData.Create;
  query := TADOQuery.Create(nil);
  query.Connection := con;
  query.SQL.Text := 'select m.DbType,m.PatId,m.StudyType, m.StudyDate,m.StudyName,m.PatientId,m.PatientName,' + 'm.PatientGender, m.PatientBirthday from V_TencentAIUpload m where m.PatId=:patid ';
  query.Parameters.ParamByName('patid').value := patId;
  query.Prepared := True;
  query.Open;
  query.First;
  data.DbType := query.FieldByName('DbType').AsString;
  data.PatId := query.FieldByName('PatId').AsString;
  data.StudyType := query.FieldByName('StudyType').AsString;
  data.StudyDate := query.FieldByName('StudyDate').AsString;
  data.StudyName := query.FieldByName('StudyName').AsString;
  data.PatientId := query.FieldByName('PatientId').AsString;
  data.PatientName := query.FieldByName('PatientName').AsString;
  data.PatientGender := query.FieldByName('PatientGender').AsString;
  data.PatientBirthday := query.FieldByName('PatientBirthday').AsString;
  query.Close;
  FreeAndNil(query);
  Result := data;
end;

function TTencentAIManager._GetAIDataFromDb(con: TADOConnection; patId: string; imageIds: TArrayImageId): TTencentAIUploadData;
var
  data: TTencentAIUploadData;
  query: TADOQuery;
  i, len: Integer;
begin
  data := TTencentAIUploadData.Create;
  query := TADOQuery.Create(nil);
  query.Connection := con;
  query.SQL.Text := 'select m.DbType,m.PatId,m.StudyType, m.StudyDate,m.StudyName,m.PatientId,m.PatientName,' + 'm.PatientGender, m.PatientBirthday,i.imageId,i.imgfile from V_TencentAIUpload m ' + 'inner join V_TencentAIUploadDetail i on m.patid=i.pid where m.patid=:patid and i.imageid in (';
  len := Length(imageIds);
  for i := 0 to len - 1 do
  begin
    if i <> (len - 1) then
    begin
      query.SQL.Text := query.SQL.Text + ':img' + imageIds[i] + ',';
    end
    else
    begin
      query.SQL.Text := query.SQL.Text + ':img' + imageIds[i];
    end;
  end;
  query.SQL.Text := query.SQL.Text + ')';
  query.Parameters.ParamByName('patid').value := patId;
  for i := 0 to len - 1 do
  begin
    query.Parameters.ParamByName('img' + imageIds[i]).value := imageIds[i];
  end;
  query.Prepared := True;
  query.Open;
  query.First;
  data.DbType := query.FieldByName('DbType').AsString;
  data.PatId := query.FieldByName('PatId').AsString;
  data.StudyType := query.FieldByName('StudyType').AsString;
  data.StudyDate := query.FieldByName('StudyDate').AsString;
  data.StudyName := query.FieldByName('StudyName').AsString;
  data.PatientId := query.FieldByName('PatientId').AsString;
  data.PatientName := query.FieldByName('PatientName').AsString;
  data.PatientGender := query.FieldByName('PatientGender').AsString;
  data.PatientBirthday := query.FieldByName('PatientBirthday').AsString;
  SetLength(data.Images, query.RecordCount);
  i := 0;
  while not query.Eof do
  begin
    data.Images[i] := MakeUploadImage(query.FieldByName('imageId').AsString, query.FieldByName('imgfile').AsString);
    i := i + 1;
    query.Next;
  end;
  query.Close;
  FreeAndNil(query);
  Result := data;
end;

function TTencentAIManager.MakeUploadImage(imageId: string; filePath: string): TTencentAIUploadImage;
var
  data: TTencentAIUploadImage;
begin
  data := TTencentAIUploadImage.Create;
  data.imageId := imageId;
  data.filePath := filePath;
  if (data.filePath <> '') then
  begin
    data.Content := _ImageToBuffer(ImgLocalRootPath + filePath);
  end;
  Result := data;
end;

function TTencentAIManager._GetWebSVRUrl(urlType: TencentAIFrontUrl): string;
var
  myinifile: TIniFile;
  gwebsvrurl: string;
begin

  if FileExists('TencentAIConfig.ini') then
  begin
    myinifile := Tinifile.create(getcurrentdir + '\TencentAIConfig.ini');
    case urlType of
      UploadDataUrl:
        begin
          gwebsvrurl := myinifile.readstring('Service', 'UploadDataUrl', '');
        end;

      GetAIResultUrl:
        begin
          gwebsvrurl := myinifile.readstring('Service', 'GetAIResultUrl', '');
        end;
      UploadReportUrl:
        begin
          gwebsvrurl := myinifile.readstring('Service', 'UploadReportUrl', '');
        end;

    end;

    FreeAndNil(myinifile);
  end
  else
  begin
    gwebsvrurl := 'http://localhost:9999/Handler1.ashx';
  end;

  Result := gwebsvrurl;
end;

function TTencentAIManager._ImageToBuffer(AImgFile: string): string;
var
  MyFileStream: TFileStream;
  EncoderMIME: TIdEncoderMIME;
begin
  result := '';
  if FileExists(AImgFile) then
  begin
    EncoderMIME := TIdEncoderMIME.Create(nil);
    try
      MyFileStream := TFileStream.Create(AImgFile, fmOpenRead);
      try
        SetLength(result, MyFileStream.Size);
        MyFileStream.Read(result[1], MyFileStream.Size);
        result := EncoderMIME.EncodeString(result);
      finally
        MyFileStream.Free;
      end;
    finally
      EncoderMIME.Free;
    end;
  end;
end;

end.

