object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'HttpUtils'
  ClientHeight = 326
  ClientWidth = 492
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    492
    326)
  PixelsPerInch = 96
  TextHeight = 13
  object btnGet: TButton
    Left = 160
    Top = 277
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'GET'
    TabOrder = 0
    OnClick = btnGetClick
  end
  object btnPost: TButton
    Left = 241
    Top = 277
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'POST'
    TabOrder = 1
    OnClick = btnPostClick
  end
  object btnPut: TButton
    Left = 322
    Top = 277
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'PUT'
    TabOrder = 2
    OnClick = btnPutClick
  end
  object btnDelete: TButton
    Left = 403
    Top = 277
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'DELETE'
    TabOrder = 3
    OnClick = btnDeleteClick
  end
  object Memo1: TMemo
    Left = 8
    Top = 16
    Width = 470
    Height = 241
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 4
  end
end
