@echo off
setlocal

set "APP_NAME=bible"

REM Detect OS (only checks for Windows)
ver | findstr /i "Windows" >nul
if errorlevel 1 (
    echo ❌ Unsupported OS. This script only runs on Windows.
    exit /b 1
)

REM Check for Docker
where docker >nul 2>nul
if errorlevel 1 (
    echo 🐳 Docker not found. Attempting to install via winget...

    REM Ensure winget exists
    where winget >nul 2>nul
    if errorlevel 1 (
        echo ❌ winget not found. Please install Docker manually from https://www.docker.com/products/docker-desktop
        exit /b 1
    )

    winget install -e --id Docker.DockerDesktop
    if errorlevel 1 (
        echo ❌ Docker installation failed.
        exit /b 1
    )

    echo ✅ Docker installed. Please reboot your system if this is the first time installing Docker Desktop.
)

REM Wait for Docker to be running
echo Checking Docker status...
docker info >nul 2>nul
if errorlevel 1 (
    echo 🔄 Attempting to start Docker Desktop...
    start "" "Docker Desktop"
    timeout /t 10 >nul
    docker info >nul 2>nul
    if errorlevel 1 (
        echo ❌ Docker is not running. Please start Docker Desktop manually and rerun this script.
        exit /b 1
    )
)

REM Build Docker image
echo 🔧 Building Docker image: %APP_NAME%...
docker build -t %APP_NAME% .

REM Create wrapper command
echo 🔧 Creating wrapper script: bible.cmd...

set "WRAPPER=%ProgramData%\bible.cmd"
(
echo @echo off
echo docker run -it --rm %APP_NAME%
) > "%WRAPPER%"

echo ✅ You can now run your app with:
echo    %WRAPPER%

endlocal
