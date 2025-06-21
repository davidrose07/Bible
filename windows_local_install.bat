@echo off
setlocal enabledelayedexpansion

REM Check for Python
where python >nul 2>nul
if errorlevel 1 (
    echo ❌ Python not found. Please install Python and try again.
    exit /b 1
)

REM Install your package
echo 🛠️ Installing local package from setup.py...
python setup.py install
if errorlevel 1 (
    echo ❌ setup.py installation failed.
    exit /b 1
)

REM Create temp Python script to check for curses
set "TEMPFILE=%TEMP%\_check_curses.py"
echo import sys> "%TEMPFILE%"
echo try:>> "%TEMPFILE%"
echo     import curses>> "%TEMPFILE%"
echo except ImportError:>> "%TEMPFILE%"
echo     print("missing:curses")>> "%TEMPFILE%"

REM Run check
for /f %%i in ('python "%TEMPFILE%"') do (
    if "%%i"=="missing:curses" (
        echo ⚠️  curses module not found. Installing windows-curses...
        pip install windows-curses
    )
)

REM Clean up
del "%TEMPFILE%" >nul 2>&1

REM Finished
echo ✅ Setup complete. You can now run:
echo    bible

endlocal
