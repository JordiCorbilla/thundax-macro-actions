program ThundaxMacroActions;

uses
  Forms,
  frmAction in 'frmAction.pas' {frmActions},
  thundax.lib.actions in 'thundax.lib.actions.pas',
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Carbon');
  Application.Title := 'Thundax Macro Actions';
  Application.CreateForm(TfrmActions, frmActions);
  Application.Run;
end.
