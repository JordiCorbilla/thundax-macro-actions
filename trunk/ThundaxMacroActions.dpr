program ThundaxMacroActions;

uses
  Forms,
  frmAction in 'frmAction.pas' {frmActions},
  thundax.lib.actions in 'thundax.lib.actions.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Thundax Macro Actions';
  Application.CreateForm(TfrmActions, frmActions);
  Application.Run;
end.
