@echo off
setlocal
cd /d "%~dp0.."
set "VENDOR=third_party\media_kit"
if not exist "%VENDOR%" mkdir "%VENDOR%"

echo Downloading media_kit Windows native libraries with certificate check disabled...
curl.exe -k -L --retry 3 --retry-all-errors -o "%VENDOR%\mpv-dev-x86_64-20230924-git-652a1dd.7z" "https://github.com/media-kit/libmpv-win32-video-build/releases/download/2023-09-24/mpv-dev-x86_64-20230924-git-652a1dd.7z"
if errorlevel 1 exit /b 1
curl.exe -k -L --retry 3 --retry-all-errors -o "%VENDOR%\ANGLE.7z" "https://github.com/alexmercerind/flutter-windows-ANGLE-OpenGL-ES/releases/download/v1.0.1/ANGLE.7z"
if errorlevel 1 exit /b 1

echo.
echo Verifying MD5...
powershell -NoProfile -Command ^
  "$mpv = (Get-FileHash '%VENDOR%\mpv-dev-x86_64-20230924-git-652a1dd.7z' -Algorithm MD5).Hash.ToLower();" ^
  "$angle = (Get-FileHash '%VENDOR%\ANGLE.7z' -Algorithm MD5).Hash.ToLower();" ^
  "if ($mpv -ne 'a832ef24b3a6ff97cd2560b5b9d04cd8') { Write-Error ('mpv MD5 mismatch: ' + $mpv); exit 1 };" ^
  "if ($angle -ne 'e866f13e8d552348058afaafe869b1ed') { Write-Error ('ANGLE MD5 mismatch: ' + $angle); exit 1 };" ^
  "Write-Host 'MD5 OK'"
if errorlevel 1 exit /b 1
echo Done.
endlocal
