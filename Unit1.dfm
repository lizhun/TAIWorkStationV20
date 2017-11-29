object Form1: TForm1
  Left = 438
  Top = 281
  Width = 917
  Height = 439
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object mmo1: TMemo
    Left = 136
    Top = 168
    Width = 737
    Height = 217
    Lines.Strings = (
      'mmo1')
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object btn4: TButton
    Left = 8
    Top = 24
    Width = 129
    Height = 25
    Caption = #20174#25968#25454#21457#36865'AI'#25968#25454
    TabOrder = 1
    OnClick = btn4Click
  end
  object lbledtpatid: TLabeledEdit
    Left = 168
    Top = 104
    Width = 121
    Height = 21
    EditLabel.Width = 48
    EditLabel.Height = 13
    EditLabel.Caption = 'lbledtpatid'
    TabOrder = 2
    Text = '1231'
  end
  object lbledtimageId: TLabeledEdit
    Left = 312
    Top = 104
    Width = 121
    Height = 21
    EditLabel.Width = 62
    EditLabel.Height = 13
    EditLabel.Caption = 'lbledtimageId'
    TabOrder = 3
    Text = '1'
  end
  object lbledtserver: TLabeledEdit
    Left = 152
    Top = 32
    Width = 113
    Height = 21
    EditLabel.Width = 72
    EditLabel.Height = 13
    EditLabel.Caption = #25968#25454#24211#22320#22336'    '
    TabOrder = 4
    Text = '192.168.1.25'
  end
  object lbledtimgLocalRootPath: TLabeledEdit
    Left = 456
    Top = 104
    Width = 169
    Height = 21
    EditLabel.Width = 112
    EditLabel.Height = 13
    EditLabel.Caption = 'lbledtimgLocalRootPath'
    TabOrder = 5
    Text = 'D:\'
  end
  object lbledtimgServerRootPath: TLabeledEdit
    Left = 656
    Top = 104
    Width = 145
    Height = 21
    EditLabel.Width = 117
    EditLabel.Height = 13
    EditLabel.Caption = 'lbledtimgServerRootPath'
    TabOrder = 6
  end
  object btngetAIREsult: TButton
    Left = 24
    Top = 64
    Width = 105
    Height = 25
    Caption = #33719#21462'AI'#32467#26524
    TabOrder = 7
    OnClick = btngetAIREsultClick
  end
  object lbledtusername: TLabeledEdit
    Left = 320
    Top = 32
    Width = 121
    Height = 21
    EditLabel.Width = 51
    EditLabel.Height = 13
    EditLabel.Caption = #29992#25143#21517'     '
    TabOrder = 8
    Text = 'demo'
  end
  object lbledtpassword: TLabeledEdit
    Left = 472
    Top = 32
    Width = 121
    Height = 21
    EditLabel.Width = 45
    EditLabel.Height = 13
    EditLabel.Caption = #23494#30721'       '
    TabOrder = 9
    Text = 'demo'
  end
  object lbledtdbbase: TLabeledEdit
    Left = 624
    Top = 32
    Width = 121
    Height = 21
    EditLabel.Width = 51
    EditLabel.Height = 13
    EditLabel.Caption = #25968#25454#21517'     '
    TabOrder = 10
    Text = 'test'
  end
  object idhtp1: TIdHTTP
    MaxLineAction = maException
    ReadTimeout = 0
    AllowCookies = True
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = 0
    Request.ContentRangeStart = 0
    Request.ContentType = 'text/html'
    Request.Accept = 'text/html, */*'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    HTTPOptions = [hoForceEncodeParams]
    Left = 96
    Top = 328
  end
  object idcdrm1: TIdDecoderMIME
    FillChar = '='
    Left = 32
    Top = 328
  end
  object idncdrm1: TIdEncoderMIME
    FillChar = '='
    Left = 64
    Top = 328
  end
  object con1: TADOConnection
    Provider = 'SQLNCLI11.1'
    Left = 80
    Top = 248
  end
end
