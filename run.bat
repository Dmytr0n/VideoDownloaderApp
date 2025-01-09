@echo off

REM Define the root directory where the script is executed
set rootDir=%cd%

REM Step 1: Check and create the deploy folder structure
echo Step 1: Setting up folder structure...
if not exist "%rootDir%\deploy" (
    mkdir "%rootDir%\deploy"
    echo Folder 'deploy' created.
) else (
    echo Folder 'deploy' already exists.
)

if not exist "%rootDir%\deploy\client" (
    mkdir "%rootDir%\deploy\client"
    echo Folder 'client' created in 'deploy'.
) else (
    echo Folder 'client' already exists in 'deploy'.
)

if not exist "%rootDir%\artefacts" (
    mkdir "%rootDir%\artefacts"
    echo Folder 'deploy' created.
) else (
    echo Folder 'deploy' already exists.
)

set clientArtifactZipPath=%~dp0\artefacts\client_build_artifacts.zip

echo Checking for existing artifacts to remove...
if exist "%clientArtifactZipPath%" (
    echo Removing existing client build artifact: %clientArtifactZipPath%
    del /f /q "%clientArtifactZipPath%"
) else (
    echo Client build artifact not found, skipping removal.
)


echo All necessary artifact checks and removals completed.

REM Initialize variables for the status table
set step1Status=NOT STARTED
set step2Status=NOT STARTED
set step3Status=NOT STARTED
set step4Status=NOT STARTED
set step5Status=NOT STARTED
set step6Status=NOT STARTED
set step7Status=NOT STARTED
set step8Status=NOT STARTED

set step1Status=PASSED
echo Step 1 completed successfully. [PASSED]

REM Define local directories and paths for client and server
set projectFolder=%cd%
set clientBuildOutput=%projectFolder%\deploy\client
set clientArtifactZipPath=%projectFolder%\artefacts\client_build_artifacts.zip

REM CLIENT SECTION
echo ---------------------------
echo CLIENT BUILD AND TEST START
echo ---------------------------

REM Step 2: Check and build the client project
echo Step 2: Checking project folder...
if not exist "%projectFolder%" (
    echo Error: Project folder not found: %projectFolder%
    set step2Status=FAILED
    goto FinalReport
) else (
    echo Project folder found: %projectFolder%.
    set step2Status=PASSED   
    echo Step 2 completed successfully. [PASSED]
)

REM Step 3: Restore NuGet packages
echo Step 3: Restoring NuGet packages...
nuget restore src\VideoDownloader\videodownloader.sln
if %errorlevel% neq 0 (
    echo Error: Failed to restore NuGet packages.
    set step3Status=FAILED
    goto FinalReport
) else (
    echo NuGet packages restored successfully.
    set step3Status=PASSED
    echo Step 3 completed successfully. [PASSED]
)

REM Step 4: Check if Visual Studio Build Tools are installed
echo Step 4: Checking for Visual Studio Build Tools...

REM Check if running in GitHub Actions
if defined GITHUB_ACTIONS (
    echo Running in GitHub Actions...
    echo Visual Studio Build Tools found.
    set step4Status=PASSED
    echo Step 4 completed successfully. [PASSED]
) else (
   echo Running locally...
   REM Check for Visual Studio Build Tools locally using absolute path
   where MSBuild.exe >nul 2>nul
if errorlevel 1 (
    echo Error: Visual Studio Build Tools not found. Please install them.
    set step4Status=FAILED
    goto FinalReport
) else (
    echo Visual Studio Build Tools found.
    set step4Status=PASSED
    echo Step 4 completed successfully. [PASSED]
)


)

REM Step 5: Build the client project
echo Step 5: Building the client project...
msbuild src\VideoDownloader\videodownloader.sln /p:Configuration=Release /p:OutputPath=%clientBuildOutput%
set sourceFile=%cd%\src\VideoDownloader\icon.ico
set destinationFile=%cd%\deploy\client\icon.ico

REM Перевірка, чи існує файл у цільовому місці
if exist "%destinationFile%" (
    echo Destination file exists. Deleting...
    del /Q "%destinationFile%"
    echo Destination file deleted.
)

REM Копіювання файлу
if exist "%sourceFile%" (
    copy "%sourceFile%" "%destinationFile%"
    echo File copied successfully!
) else (
    echo Source file not found!
)
if exist "%clientBuildOutput%\videodownloader.exe" (
    echo Client build completed successfully. Artifacts located at: %clientBuildOutput%
    set step5Status=PASSED
    echo Step 5 completed successfully. [PASSED]
) else (
    echo Error: Client build failed. Please check the error messages.
    set step5Status=FAILED
    goto FinalReport
)

REM Step 6: Install yt-dlp
echo Step 6: Installing yt-dlp...
set "YTDLP_PATH=%projectFolder%\deploy\client"

if exist "%YTDLP_PATH%\yt-dlp.exe" (
    echo [INFO] yt-dlp is already installed at %YTDLP_PATH%.
    echo [INFO] Current version:
    "%YTDLP_PATH%\yt-dlp.exe" --version
    set step6Status=PASSED
    echo Step 6 completed successfully. [PASSED]
    goto add ffmpeg
) else (
    echo [INFO] yt-dlp is not found. Proceeding with installation.
    if not exist "%YTDLP_PATH%" (
        echo [INFO] Creating directory %YTDLP_PATH%...
        mkdir "%YTDLP_PATH%"
        if %errorlevel% neq 0 (
            echo [ERROR] Failed to create directory %YTDLP_PATH%.
            set step6Status=FAILED
            goto FinalReport
        )
    )

    echo [INFO] Downloading yt-dlp.exe...
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe', '%YTDLP_PATH%\yt-dlp.exe')"
    if not exist "%YTDLP_PATH%\yt-dlp.exe" (
        echo [ERROR] Failed to download yt-dlp.exe.
        set step6Status=FAILED
        goto FinalReport
    )
    echo [INFO] yt-dlp installed successfully at %YTDLP_PATH%.
    set step6Status=PASSED
    echo Step 6 completed successfully. [PASSED]
)
: add ffmpeg
REM Step 7: Install FFmpeg
set step7Status=NOT STARTED
echo Step 7: Installing FFmpeg...
set "FFMPEG_PATH=%cd%\deploy\client\ffmpeg.exe"
set "FFmpeg_URL=https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"
set "DOWNLOAD_DIR=%cd%\deploy\client\ffmpeg_download"

if exist "%FFMPEG_PATH%" (
    echo [INFO] FFmpeg is already installed at %FFMPEG_PATH%.
    echo [INFO] Current version:
    "%FFMPEG_PATH%" -version
    set step7Status=PASSED
    echo Step 7 completed successfully. [PASSED]
    goto Artefacts
) else (
    echo [INFO] FFmpeg is not found. Proceeding with installation.
)

REM Create download directory if it doesn't exist
if not exist "%DOWNLOAD_DIR%" (
    echo [INFO] Creating download directory %DOWNLOAD_DIR%...
    mkdir "%DOWNLOAD_DIR%"
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to create download directory %DOWNLOAD_DIR%.
        set step7Status=FAILED
        goto FinalReport
    )
)

REM Download FFmpeg archive
echo [INFO] Downloading FFmpeg archive...
powershell -Command "Invoke-WebRequest -Uri '%FFmpeg_URL%' -OutFile '%DOWNLOAD_DIR%\ffmpeg-release-essentials.zip'"
if not exist "%DOWNLOAD_DIR%\ffmpeg-release-essentials.zip" (
    echo [ERROR] Failed to download FFmpeg archive. Please check your internet connection.
    set step7Status=FAILED
    goto FinalReport
)

REM Extract FFmpeg archive
echo [INFO] Extracting FFmpeg archive...
powershell -Command "Expand-Archive -Path '%DOWNLOAD_DIR%\ffmpeg-release-essentials.zip' -DestinationPath '%DOWNLOAD_DIR%' -Force"
if %errorlevel% neq 0 (
    echo [ERROR] Failed to extract FFmpeg archive.
    set step7Status=FAILED
    goto FinalReport
)

REM Find the extracted FFmpeg folder
for /d %%I in ("%DOWNLOAD_DIR%\ffmpeg-*") do set "EXTRACTED_FOLDER=%%I"

REM Check if the extracted folder was found
if not defined EXTRACTED_FOLDER (
    echo [ERROR] Extracted FFmpeg folder not found.
    set step7Status=FAILED
    goto FinalReport
)

REM Move the ffmpeg.exe to the client directory
echo [INFO] Moving ffmpeg.exe to %FFMPEG_PATH%...
move "%EXTRACTED_FOLDER%\bin\ffmpeg.exe" "%FFMPEG_PATH%"
if %errorlevel% neq 0 (
    echo [ERROR] Failed to move ffmpeg.exe.
    set step7Status=FAILED
    goto FinalReport
)

REM Clean up the extracted files and folders
echo [INFO] Cleaning up extracted files...
rmdir /S /Q "%EXTRACTED_FOLDER%" 
del "%DOWNLOAD_DIR%\ffmpeg-release-essentials.zip"
rmdir /S /Q "%DOWNLOAD_DIR%"

REM Verify FFmpeg installation
echo [INFO] Verifying FFmpeg installation...
"%FFMPEG_PATH%" -version
if %errorlevel% neq 0 (
    echo [ERROR] FFmpeg installation verification failed.
    set step7Status=FAILED
    goto FinalReport
)

echo [INFO] FFmpeg installed successfully at %FFMPEG_PATH%!
set step7Status=PASSED
echo Step 7 completed successfully. [PASSED]

: Artefacts
REM Step 8: Archive client build artifacts
echo Step 8: Creating build artifact archive...
powershell -Command "Compress-Archive -Path %clientBuildOutput% -DestinationPath %clientArtifactZipPath%"
if %errorlevel% neq 0 (
    echo Error: Failed to create build artifact archive.
    set step8Status=FAILED
    goto FinalReport
) else (
    echo Build artifacts saved at: %clientArtifactZipPath%.
    set step8Status=PASSED
    echo Step 8 completed successfully. [PASSED]
)

REM Step 9: Build Installer
set step9Status=NOT STARTED
echo Step 9: Building installer...

REM Перевірка наявності Inno Setup Compiler
where iscc >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Inno Setup Compiler not found. Please install it and add to PATH.
    set step9Status=FAILED
    goto FinalReport
) else (
    echo [INFO] Inno Setup Compiler found.
)

REM Запуск Inno Setup Compiler
set innoScriptPath=%cd%\installer.iss
set outputInstallerPath=%cd%\deploy\installer\VideoDownloaderInstaller.exe

echo [INFO] Compiling installer using script: %innoScriptPath%...
iscc "%innoScriptPath%"
if not exist "%outputInstallerPath%" (
    echo [ERROR] Failed to build installer. Please check the script and try again.
    set step9Status=FAILED
    goto FinalReport
)

echo [INFO] Installer built successfully at: %outputInstallerPath%
set step9Status=PASSED
echo Step 9 completed successfully. [PASSED]

REM Step 10: Archive installer artifacts
echo Step 10: Archiving installer artifacts...
set installerArchivePath=%rootDir%\artefacts\VideoDownloaderInstaller.zip
powershell -Command "Compress-Archive -Path %outputInstallerPath% -DestinationPath %installerArchivePath% -Force"
if %errorlevel% neq 0 (
    echo Error: Failed to archive installer.
    set step10Status=FAILED
    goto FinalReport
) else (
    echo Installer artifacts archived successfully.
    set step10Status=PASSED
    echo Step 10 completed successfully. [PASSED]
)

:FinalReport

REM FINAL REPORT
echo.
echo ===========================
echo FINAL BUILD AND DEPLOY REPORT
echo ===========================
echo CLIENT SECTION:
echo - Build Output Path: "%clientBuildOutput%"
echo - Installer Path: "%outputInstallerPath%"
echo - Archived Installer: "%installerArchivePath%"
echo ===========================
echo All tasks completed successfully on %date% at %time%
echo ===========================

REM Display the table of step statuses
echo.
echo =========================================================
echo                       STATUS TABLE
echo =========================================================
echo Step   Description                          Status
echo =========================================================
echo   1    Set up folder structure              %step1Status%
echo =========================================================
echo   2    Check project folder                 %step2Status%
echo =========================================================
echo   3    Restore NuGet packages               %step3Status%
echo =========================================================
echo   4    Check Visual Studio Build Tools      %step4Status%
echo =========================================================
echo   5    Build client project                 %step5Status%
echo =========================================================
echo   6    Install yt-dlp                       %step6Status%
echo =========================================================
echo   7    Install FFmpeg                       %step7Status%
echo =========================================================
echo   8    Archive client build artifacts       %step8Status%
echo =========================================================
echo   9    Build installer                      %step9Status%
echo =========================================================
echo  10    Archive installer artifacts          %step10Status%
echo =========================================================

REM Create an HTML report file
set indexHtmlFile=%rootDir%\artefacts\index.html

echo Creating final report table in "%indexHtmlFile%"...

(
echo ^<html^>
echo ^<head^>
echo ^<title^>Build and Test Report^</title^>
echo ^<style^>
echo     body { font-family: Arial, sans-serif; }
echo     table { width: 100%%; border-collapse: collapse; margin-top: 20px; }
echo     th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
echo     th { background-color: #f4f4f4; }
echo     .passed { background-color: #d4edda; color: #155724; }
echo     .failed { background-color: #f8d7da; color: #721c24; }
echo     h1, h2 { color: #333; }
echo ^</style^>
echo ^</head^>
echo ^<body^>
echo ^<h1^>Build and Test Report^</h1^>

REM Add a table for step-by-step report
echo ^<h2^>Step Report^</h2^>
echo ^<table^>
echo ^<tr^>^<th^>Step^</th^>^<th^>Description^</th^>^<th^>Status^</th^>^</tr^>
echo ^<tr^>^<td^>1^</td^>^<td^>Set up folder structure^</td^>^<td class="%step1Status:FAILED=failed% %step1Status:PASSED=passed%"^>%step1Status%^</td^>^</tr^>
echo ^<tr^>^<td^>2^</td^>^<td^>Check project folder^</td^>^<td class="%step2Status:FAILED=failed% %step2Status:PASSED=passed%"^>%step2Status%^</td^>^</tr^>
echo ^<tr^>^<td^>3^</td^>^<td^>Restore NuGet packages^</td^>^<td class="%step3Status:FAILED=failed% %step3Status:PASSED=passed%"^>%step3Status%^</td^>^</tr^>
echo ^<tr^>^<td^>4^</td^>^<td^>Check Visual Studio Build Tools^</td^>^<td class="%step4Status:FAILED=failed% %step4Status:PASSED=passed%"^>%step4Status%^</td^>^</tr^>
echo ^<tr^>^<td^>5^</td^>^<td^>Build client project^</td^>^<td class="%step5Status:FAILED=failed% %step5Status:PASSED=passed%"^>%step5Status%^</td^>^</tr^>
echo ^<tr^>^<td^>6^</td^>^<td^>Install yt-dlp^</td^>^<td class="%step6Status:FAILED=failed% %step6Status:PASSED=passed%"^>%step6Status%^</td^>^</tr^>
echo ^<tr^>^<td^>7^</td^>^<td^>Install FFmpeg^</td^>^<td class="%step7Status:FAILED=failed% %step7Status:PASSED=passed%"^>%step7Status%^</td^>^</tr^>
echo ^<tr^>^<td^>8^</td^>^<td^>Archive client build artifacts^</td^>^<td class="%step8Status:FAILED=failed% %step8Status:PASSED=passed%"^>%step8Status%^</td^>^</tr^>
echo ^<tr^>^<td^>9^</td^>^<td^>Build installer^</td^>^<td class="%step9Status:FAILED=failed% %step9Status:PASSED=passed%"^>%step9Status%^</td^>^</tr^>
echo ^<tr^>^<td^>10^</td^>^<td^>Archive installer artifacts^</td^>^<td class="%step10Status:FAILED=failed% %step10Status:PASSED=passed%"^>%step10Status%^</td^>^</tr^>
echo ^</table^>

REM Add summary section
echo ^<h2^>Summary^</h2^>
echo ^<table^>
echo ^<tr^>^<th^>Section^</th^>^<th^>Details^</th^>^</tr^>
echo ^<tr^>^<td^>Client Build Path^</td^>^<td^>%clientBuildOutput%^</td^>^</tr^>
echo ^<tr^>^<td^>Installer Path^</td^>^<td^>%outputInstallerPath%^</td^>^</tr^>
echo ^<tr^>^<td^>Archived Installer Path^</td^>^<td^>%installerArchivePath%^</td^>^</tr^>
echo ^</table^>

echo ^<p^>All tasks completed successfully on %date% at %time%.^</p^>
echo ^</body^>
echo ^</html^>
) > "%indexHtmlFile%"

echo HTML final report created successfully at: "%indexHtmlFile%"
pause


