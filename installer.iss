[Setup]
AppName=Video Downloader           
AppVersion=1.0.0                   
DefaultDirName={pf}\VideoDownloader 
DefaultGroupName=Video Downloader  
OutputDir=.\deploy\installer                 
OutputBaseFilename=VideoDownloaderInstaller 
Compression=lzma
SolidCompression=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop icon"; GroupDescription: "Additional icons"; Flags: unchecked

[Files]
; Основний виконуваний файл
Source: "deploy\client\videodownloader.exe"; DestDir: "{app}"; Flags: ignoreversion
; Додаткові утиліти
Source: "deploy\client\yt-dlp.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "deploy\client\ffmpeg.exe"; DestDir: "{app}"; Flags: ignoreversion
; Інші залежності (DLL або конфігурації)
Source: "deploy\client\*.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "deploy\client\icon.ico"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
; Ярлик на робочому столі
Name: "{commondesktop}\Video Downloader"; Filename: "{app}\videodownloader.exe"; IconFilename: "{app}\icon.ico"; Tasks: desktopicon
; Ярлик в меню Пуск
Name: "{group}\Video Downloader"; Filename: "{app}\videodownloader.exe"; IconFilename: "{app}\icon.ico"

[Run]
; Запуск програми після встановлення
Filename: "{app}\videodownloader.exe"; Description: "Launch Video Downloader"; Flags: nowait postinstall skipifsilent
