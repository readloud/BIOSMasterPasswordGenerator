/*****************************************************************************
*                                                                            *
*                               CrystalDMI                                   *
*                    Copyright (C) 2004-2010 hiyohiyo                        *
*                                                                            *
*                                                   The modified BSD license *
*                                            mail: hiyohiyo@crystalmark.info *
*                                            web :   http://crystalmark.info *
*****************************************************************************/

------------------------------------------------------------------------------
■ はじめに
------------------------------------------------------------------------------
　CrystalDMI は DMI (Desktop Mangament Interface) 経由で BIOS/CPU/PCI/AGP 等の
詳細な情報を収集するユーティリティです。

------------------------------------------------------------------------------
■ インストール
------------------------------------------------------------------------------
・任意のディレクトリにダウンロードしたファイルを解凍してください。

------------------------------------------------------------------------------
■ アンインストール
------------------------------------------------------------------------------
・インストールしたフォルダごと削除してください。
※レジストリには一切情報を書き込んでおりません。

------------------------------------------------------------------------------
■ 動作環境
------------------------------------------------------------------------------
対応 OS ：Windows 7/2008/Vista/2003/XP/2000/NT4/Me/98 [x86]
          Windows 7/2008/Vista/2003/XP [x64]
フォント：Courier New (9pt)
必須事項：SMBIOS/DMI 2.2 以降

------------------------------------------------------------------------------
■ ライセンスについて
------------------------------------------------------------------------------
　CrystalDMI は The modified BSD license (修正版 BSD ライセンス) で公開され
ている Free Software です。The modified BSD license に従う限り、どなたでも自由
に改変・再配布等を行うことができます。
　詳細は付属のライセンス (COPYRIGHT.txt) をご覧ください。

※正式なライセンスは COPYRIGHT.txt (英語) ですが、通常は COPYRIGHT-ja.txt
  (日本語) を理解してくだされば問題ありません。

------------------------------------------------------------------------------
■ 機能
------------------------------------------------------------------------------
・DMI 経由でシステム情報を取得

------------------------------------------------------------------------------
■ リファレンス
------------------------------------------------------------------------------
- DMTF "System Management BIOS Reference Specification"
  Version 2.6 Final
  http://www.dmtf.org/standards/smbios

------------------------------------------------------------------------------
■ サポート
------------------------------------------------------------------------------
 00 BIOS Information
 01 System Information
 02 Base Board Information
 03 System Enclosure or Chassis
 04 Processor Information
 05 Memory Controller Information
 06 Memory Module Information
 07 Cache Information
 08 Port Connector Information
 09 System Slots
 11 OEM Strings
 13 BIOS Language Information
 16 Physical Memory Array
 17 Memory Device
 19 Memory Array Mapped Address
 20 Memory Device Mapped Address
 32 System Boot Information
126 Inactive
127 End-of-Table

------------------------------------------------------------------------------
■ 未サポート
------------------------------------------------------------------------------
 10 On Board Devices Information
 12 System Configuration Options
 14 Group Associations
 15 System Event Log
 18 32-bit Memory Error Information
 21 Built-in Pointing Device
 22 Portable Battery
 23 System Reset
 24 Hardware Security
 25 System Power Controls
 26 Voltage Probe
 27 Cooling Device
 28 Temperature Probe
 29 Electrical Current Probe
 30 Out-of-Band Remote Access
 31 Boot Integrity Services (BIS) Entry Point
 33 64-bit Memory Error Information
 34 Management Device
 35 Management Device Component
 36 Management Device Threshold Data
 37 Memory Channel
 38 IPMI Device Information
 39 System Power Supply

