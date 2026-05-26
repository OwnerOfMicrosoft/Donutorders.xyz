@echo off
title DonutSMP Auto-Push
color 0A

echo =======================================
echo   DonutSMP Auto-Push is running
echo   Watching for changes to orders.json
echo   Press Ctrl+C to stop
echo =======================================
echo.

:: Source file (your mod writes here)
set SOURCE=C:\Users\Caleb\Desktop\orders.json

:: Destination in your repo
set DEST=C:\donutorders\data.json

:: Your repo folder
set REPO=C:\donutorders

:: How often to check for changes (seconds)
set INTERVAL=30

set LAST_HASH=none

:loop
  :: Check if source file exists
  if not exist "%SOURCE%" (
    echo [%time%] Waiting for %SOURCE% to appear...
    timeout /t %INTERVAL% /nobreak >nul
    goto loop
  )

  :: Get current file hash to detect changes
  for /f "skip=1 tokens=* delims=" %%A in ('certutil -hashfile "%SOURCE%" MD5 2^>nul') do (
    if not "%%A"=="CertUtil: -hashfile command completed successfully." (
      set CURRENT_HASH=%%A
      goto :check
    )
  )

  :check
  if "%CURRENT_HASH%"=="%LAST_HASH%" (
    timeout /t %INTERVAL% /nobreak >nul
    goto loop
  )

  :: File changed! Copy and push.
  echo [%time%] Change detected! Pushing to GitHub...
  set LAST_HASH=%CURRENT_HASH%

  copy /y "%SOURCE%" "%DEST%" >nul
  if errorlevel 1 (
    echo [%time%] ERROR: Could not copy file. Check paths.
    timeout /t %INTERVAL% /nobreak >nul
    goto loop
  )

  cd /d "%REPO%"
  git add data.json
  git commit -m "data: auto-update %date% %time%"
  git push

  if errorlevel 1 (
    echo [%time%] ERROR: Git push failed. Check your internet and credentials.
  ) else (
    echo [%time%] Done! Site will update in ~30 seconds.
  )

  echo.
  timeout /t %INTERVAL% /nobreak >nul
goto loop
