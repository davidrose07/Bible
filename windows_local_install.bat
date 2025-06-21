@echo off
setlocal

REM Check for Python
where python >nul 2>nul
if errorlevel 1 (
    echo ❌ Python not found. Please install Python and try again.
    exit /b 1
)

REM Install your package with setup.py
echo 🛠️ Installing package...
python setup.py install
if errorlevel 1 (
    echo ❌ setup.py installation failed.
    exit /b 1
)

REM Check for import errors
echo 🔍 Checking for missing modules...

(
echo import sys
echo try:
echo     import curses
echo except ImportError:
echo     print("missing:curses")
) > _check_curses.py

for /f %%i in ('python _check_curses.py') do (
    if "%%i"=="missing:curses" (
        echo ⚠️ curses module not found. Attempting to install windows-curses...
        pip install windows-curses
    )
)

del _check_curses.py

REM Optionally run your app
echo ✅ Setup complete. You can now run your app using:
echo    python -m your_module_name

endlocal
