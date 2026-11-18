@echo off
setlocal
cd /d "%~dp0"
if exist ".tools\node-v24.22.3-win-x64\node.exe" set "PATH=%CD%\.tools\node-v24.22.3-win-x64;%PATH%"
where node >nul 2>&1
if errorlevel 1 (
  echo Install Node.js 24 LTS, then run this file again.
  pause
  exit /b 1
)
if not exist "node_modules\express\package.json" (
  call npm ci
  if errorlevel 1 (
    pause
    exit /b 1
  )
)
echo Open the local URL below. Leave this window open while using the website.
node --env-file-if-exists=.env server/index.js
if errorlevel 1 pause
