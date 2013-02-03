(*
  * Copyright (c) 2013 Thundax Macro Actions
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
  * modification, are permitted provided that the following conditions are
  * met:
  *
  * * Redistributions of source code must retain the above copyright
  *   notice, this list of conditions and the following disclaimer.
  *
  * * Redistributions in binary form must reproduce the above copyright
  *   notice, this list of conditions and the following disclaimer in the
  *   documentation and/or other materials provided with the distribution.
  *
  * * Neither the name of 'Thundax Macro Actions' nor the names of its contributors
  *   may be used to endorse or promote products derived from this software
  *   without specific prior written permission.
  *
  * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
  * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
  * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
  * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
  * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*)
unit thundax.lib.actions;

interface

uses
  Generics.Collections;

type
  TActionType = (tMousePos, TMouseLClick, TMouseLDClick, TMouseRClick, TMouseRDClick, TKey, TMessage);

  TActionTypeHelper = class(TObject)
    class function CastToString(action: TActionType): string;
  end;

  IAction = interface
    procedure Execute;
    function ToString(): string;
  end;

  TParameters<T> = class(TObject)
  private
    Fparam2: T;
    Fparam1: T;
    procedure Setparam1(const Value: T);
    procedure Setparam2(const Value: T);
  public
    property param1: T read Fparam1 write Setparam1;
    property param2: T read Fparam2 write Setparam2;
    function IntegerConverterP1(): Integer;
    function IntegerConverterP2(): Integer;
    function StringConverterP1(): String;
    function StringConverterP2(): String;
    constructor Create(param1: T; param2: T);
  end;

  TAction<T> = class(TInterfacedObject, IAction)
  private
    Fparam: TParameters<T>;
    Faction: TActionType;
    procedure Setaction(const Value: TActionType);
    procedure Setparam(const Value: TParameters<T>);
    function getKey(key: String): Char;
    procedure TypeMessage(Msg: string);
  public
    property action: TActionType read Faction write Setaction;
    property param: TParameters<T>read Fparam write Setparam;
    constructor Create(action: TActionType; param: TParameters<T>);
    procedure Execute();
    function ToString(): string; override;
  end;

  TActionList = class(TList<IAction>)
    procedure SaveToFile(const FileName: string);
    procedure LoadFromFile(const FileName: string);
  end;

function GenericAsInteger(const Value): Integer; inline;
function GenericAsString(const Value): string; inline;

implementation

uses
  Windows,
  TypInfo,
  Variants,
  SysUtils,
  dbxjson,
  dbxjsonreflect,
  dialogs;

{ TParameters<T> }

function GenericAsInteger(const Value): Integer;
begin
  Result := Integer(Value);
end;

function GenericAsString(const Value): string;
begin
  Result := string(Value);
end;

constructor TParameters<T>.Create(param1, param2: T);
begin
  Setparam1(param1);
  Setparam2(param2);
end;

function TParameters<T>.IntegerConverterP1: Integer;
begin
  Result := GenericAsInteger(Fparam1);
end;

function TParameters<T>.IntegerConverterP2: Integer;
begin
  Result := GenericAsInteger(Fparam2);
end;

procedure TParameters<T>.Setparam1(const Value: T);
begin
  Fparam1 := Value;
end;

procedure TParameters<T>.Setparam2(const Value: T);
begin
  Fparam2 := Value;
end;

function TParameters<T>.StringConverterP1: String;
begin
  Result := GenericAsString(Fparam1);
end;

function TParameters<T>.StringConverterP2: String;
begin
  Result := GenericAsString(Fparam2);
end;

{ TAction<T> }

constructor TAction<T>.Create(action: TActionType; param: TParameters<T>);
begin
  Setaction(action);
  Setparam(param);
end;

procedure TAction<T>.Execute;
var
  p: Integer;
begin
  case Faction of
    tMousePos:
      SetCursorPos(param.IntegerConverterP1, param.IntegerConverterP2);
    TMouseLClick:
      begin
        mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
        mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
      end;
    TMouseLDClick:
      begin
        mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
        mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
        GetDoubleClickTime;
        mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
        mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
      end;
    TMouseRClick:
      begin
        mouse_event(MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0);
        mouse_event(MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0);
      end;
    TMouseRDClick:
      begin
        mouse_event(MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0);
        mouse_event(MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0);
        GetDoubleClickTime;
        mouse_event(MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0);
        mouse_event(MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0);
      end;
    TKey:
      TypeMessage(getKey(param.StringConverterP1));
    TMessage:
      TypeMessage(param.StringConverterP1);
  end;
end;

function TAction<T>.getKey(key: String): Char;
begin
  if key = 'TAB' then
    Result := Char(VK_TAB);
  if key = 'CLEAR' then
    Result := Char(VK_CLEAR);
  if key = 'RETURN' then
    Result := Char(VK_RETURN);
  if key = 'SHIFT' then
    Result := Char(VK_SHIFT);
  if key = 'CONTROL' then
    Result := Char(VK_CONTROL);
  if key = 'ESCAPE' then
    Result := Char(VK_ESCAPE);
  if key = 'SPACE' then
    Result := Char(VK_SPACE);
  if key = 'LEFT' then
    Result := Char(VK_LEFT);
  if key = 'UP' then
    Result := Char(VK_UP);
  if key = 'RIGHT' then
    Result := Char(VK_RIGHT);
  if key = 'DOWN' then
    Result := Char(VK_DOWN);
  if key = 'INSERT' then
    Result := Char(VK_INSERT);
  if key = 'DELETE' then
    Result := Char(VK_DELETE);
  if key = 'F1' then
    Result := Char(VK_F1);
  if key = 'F2' then
    Result := Char(VK_F2);
  if key = 'F3' then
    Result := Char(VK_F3);
  if key = 'F4' then
    Result := Char(VK_F4);
  if key = 'F5' then
    Result := Char(VK_F5);
  if key = 'F6' then
    Result := Char(VK_F6);
  if key = 'F7' then
    Result := Char(VK_F7);
  if key = 'F8' then
    Result := Char(VK_F8);
  if key = 'F9' then
    Result := Char(VK_F9);
  if key = 'F10' then
    Result := Char(VK_F10);
  if key = 'F11' then
    Result := Char(VK_F11);
  if key = 'F12' then
    Result := Char(VK_F12);
end;

function TAction<T>.ToString: string;
var
  varRes: TVarType;
  description: string;
  x, y: Integer;
  p: string;
begin
  description := TActionTypeHelper.CastToString(Faction);
  Case PTypeInfo(TypeInfo(T))^.Kind of
    tkInteger:
      begin
        description := description + ' (' + IntToStr(param.IntegerConverterP1) + ', ' + IntToStr(param.IntegerConverterP2) + ')';
      end;
    tkString, tkUString, tkChar, tkWChar, tkLString, tkWString, tkUnknown, tkVariant:
      begin
        if param.StringConverterP1 <> '' then
          description := description + ' (' + param.StringConverterP1 + ')';
      end;
  End;
  Result := description;
end;

//*********************************
//This code has been extracted from:
//http://stackoverflow.com/questions/9673442/how-can-i-send-keys-to-another-application-using-delphi-7
//http://stackoverflow.com/users/1211614/dampsquid
//*********************************
procedure TAction<T>.TypeMessage(Msg: string);
var
  CapsOn: boolean;
  i: Integer;
  ch: Char;
  shift: boolean;
  key: short;
begin
  CapsOn := (GetKeyState(VK_CAPITAL) and $1) <> 0;

  for i := 1 to length(Msg) do
  begin
    ch := Msg[i];
    ch := UpCase(ch);

    if ch <> Msg[i] then
    begin
      if CapsOn then
        keybd_event(VK_SHIFT, 0, 0, 0);
      keybd_event(ord(ch), 0, 0, 0);
      keybd_event(ord(ch), 0, KEYEVENTF_KEYUP, 0);
      if CapsOn then
        keybd_event(VK_SHIFT, 0, KEYEVENTF_KEYUP, 0);
    end
    else
    begin
      key := VKKeyScan(ch);
      if ((not CapsOn) and (ch >= 'A') and (ch <= 'Z')) or ((key and $100) > 0) then
        keybd_event(VK_SHIFT, 0, 0, 0);
      keybd_event(key, 0, 0, 0);
      keybd_event(key, 0, KEYEVENTF_KEYUP, 0);
      if ((not CapsOn) and (ch >= 'A') and (ch <= 'Z')) or ((key and $100) > 0) then
        keybd_event(VK_SHIFT, 0, KEYEVENTF_KEYUP, 0);
    end;
  end;
end;

procedure TAction<T>.Setaction(const Value: TActionType);
begin
  Faction := Value;
end;

procedure TAction<T>.Setparam(const Value: TParameters<T>);
begin
  Fparam := Value;
end;

{ TActionTypeHelper }

class function TActionTypeHelper.CastToString(action: TActionType): string;
begin
  case action of
    tMousePos:
      Result := 'Mouse position';
    TMouseLClick:
      Result := 'Mouse Left Click';
    TMouseLDClick:
      Result := 'Mouse Left Double Click';
    TMouseRClick:
      Result := 'Mouse Right Click';
    TMouseRDClick:
      Result := 'Mouse Right Double Click';
    TKey:
      Result := 'Press special key';
    TMessage:
      Result := 'Type message';
  end;
end;

{ TActionList }

procedure TActionList.LoadFromFile(const FileName: string);
begin

end;

procedure TActionList.SaveToFile(const FileName: string);
// var
// jsonMarshal: TJSONMarshal;
// jsonObject: TJSONObject;
begin
  // jsonMarshal := TJSONMarshal.Create;
  // jsonObject := jsonMarshal.Marshal(Self) as TJSONObject;

end;

end.
