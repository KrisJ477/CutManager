@echo off
REM ---------------------------------------------------------------
REM  Deploy the Cut Guide PWA to https://github.com/KrisJ477/CutManager
REM  This folder is its own repository, deliberately separate from the
REM  parent PipeGCodeGenerator repo it happens to sit inside.
REM ---------------------------------------------------------------
setlocal enabledelayedexpansion
cd /d "%~dp0"

set "REMOTE=https://github.com/KrisJ477/CutManager.git"
set "GITNAME=Kris"
set "GITMAIL=kris@pipegcode.local"

echo.
echo === K^&J Cut Guide - deploy ===
echo Folder: %CD%
echo.

where git >nul 2>&1
if errorlevel 1 (
  echo ERROR: git is not on PATH. Install Git for Windows first.
  pause & exit /b 1
)

REM Check for .git in THIS folder only. rev-parse would walk up the tree
REM and find the parent repository instead.
if not exist ".git" (
  echo Initialising a repository in this folder...
  git init
)

REM A fresh repo inherits nothing from the parent, whose identity was set
REM locally rather than globally. Without this, commit silently fails.
git config user.email >nul 2>&1
if errorlevel 1 (
  echo Setting commit identity for this repository...
  git config user.name "%GITNAME%"
  git config user.email "%GITMAIL%"
)

REM Always work on main, whatever the default was.
git rev-parse --verify HEAD >nul 2>&1
if errorlevel 1 (
  git checkout -B main
) else (
  git branch -M main
)

REM Point origin at CutManager, correcting it if it points anywhere else.
git remote get-url origin >nul 2>&1
if errorlevel 1 (
  git remote add origin "%REMOTE%"
) else (
  for /f "delims=" %%u in ('git remote get-url origin') do set "CURRENT=%%u"
  if /i not "!CURRENT!"=="%REMOTE%" (
    echo Repointing origin from !CURRENT!
    git remote set-url origin "%REMOTE%"
  )
)

REM Bring down anything already on GitHub so the push is not rejected.
git ls-remote --exit-code --heads origin main >nul 2>&1
if not errorlevel 1 (
  echo Rebasing on origin/main...
  git pull --rebase origin main
)

echo Staging files...
git add -A

git diff --cached --quiet
if not errorlevel 1 (
  echo Nothing changed since the last deploy.
) else (
  git commit -m "Deploy %DATE% %TIME%"
  if errorlevel 1 (
    echo.
    echo COMMIT FAILED - see the message above. Nothing was pushed.
    pause & exit /b 1
  )
)

echo Pushing...
git push -u origin main
if errorlevel 1 (
  echo.
  echo PUSH FAILED. Check the message above:
  echo   - "Authentication failed"       : use a Personal Access Token, not your password
  echo   - "rejected / non-fast-forward" : run this script again to rebase
  pause & exit /b 1
)

echo.
echo Done. Live in a minute or so at:
echo   https://krisj477.github.io/CutManager/
echo.
pause
