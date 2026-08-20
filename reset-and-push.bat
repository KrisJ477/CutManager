@echo off
REM  ONE-TIME CLEANUP
REM  Throws away the tangled local git history (detached HEAD, half-finished
REM  rebase, broken remote URL) and force-pushes one clean commit.
REM  The remote currently holds an older partial upload; local files win.
REM  After this runs successfully, use deploy.bat from then on.
setlocal
cd /d "%~dp0"

echo.
echo This will delete the local git history in:
echo   %CD%
echo and overwrite https://github.com/KrisJ477/CutManager main branch.
echo Your actual files are untouched.
echo.
pause

if exist ".git" rmdir /s /q ".git"

git init
git checkout -b main
git config user.name "Kris"
git config user.email "kris@pipegcode.local"
git remote add origin https://github.com/KrisJ477/CutManager.git

git add -A
git commit -m "Cut Guide PWA - clean baseline"

git push -u origin main --force

echo.
echo Now enable Pages: Settings - Pages - branch main - folder / (root)
echo Then use deploy.bat for all future updates.
echo.
pause
