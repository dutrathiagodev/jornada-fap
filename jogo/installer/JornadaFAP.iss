; Instalador do Windows (Inno Setup). Gerado pelo workflow: iscc /DAppVersion=1.0.0 installer\JornadaFAP.iss
#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif

[Setup]
AppId={{6B1F2D7A-4C3E-4F59-9E0A-5D2A7C1B8F33}
AppName=Jornada FAP
AppVersion={#AppVersion}
AppPublisher=Faculdade Adventista do Paraná
DefaultDirName={autopf}\Jornada FAP
DefaultGroupName=Jornada FAP
DisableProgramGroupPage=yes
; Instala só para o usuário atual: não pede senha de administrador.
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
OutputDir=..
OutputBaseFilename=JornadaFAP-windows-x64-setup
SetupIconFile=..\icone.ico
UninstallDisplayIcon={app}\icone.ico
Compression=lzma2
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Files]
Source: "..\build\windows\JornadaFAP.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\icone.ico"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
; atalho na área de trabalho sempre criado, mais o do Menu Iniciar
Name: "{autodesktop}\Jornada FAP"; Filename: "{app}\JornadaFAP.exe"; IconFilename: "{app}\icone.ico"
Name: "{autoprograms}\Jornada FAP"; Filename: "{app}\JornadaFAP.exe"; IconFilename: "{app}\icone.ico"

[Run]
Filename: "{app}\JornadaFAP.exe"; Description: "Abrir o Jornada FAP agora"; Flags: nowait postinstall skipifsilent
