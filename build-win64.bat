@echo off
REM Batch script to build LiveKit Client C++ SDK for Windows 64-bit
REM This script automates the build process described in BUILD_WIN64.md
REM
REM Usage: build-win64.bat [Release|Debug] [v142|v143]
REM
REM Examples:
REM   build-win64.bat                # Build Release with v143 toolset
REM   build-win64.bat Debug v142     # Build Debug with VS2019 toolset
REM   build-win64.bat Release v143   # Build Release with VS2022 toolset

setlocal enabledelayedexpansion

REM Parse arguments
set CONFIG=%1
set TOOLSET=%2

REM Set defaults
if "%CONFIG%"=="" set CONFIG=Release
if "%TOOLSET%"=="" set TOOLSET=v143

REM Validate config
if /i not "%CONFIG%"=="Release" if /i not "%CONFIG%"=="Debug" (
    echo ERROR: Invalid configuration "%CONFIG%". Must be Release or Debug.
    exit /b 1
)

REM Validate toolset
if /i not "%TOOLSET%"=="v142" if /i not "%TOOLSET%"=="v143" (
    echo ERROR: Invalid toolset "%TOOLSET%". Must be v142 or v143.
    exit /b 1
)

echo ==============================================
echo LiveKit Client C++ SDK - Windows Build Script
echo ==============================================
echo.

REM Check prerequisites
echo Checking prerequisites...
echo.

REM Check vcpkg
if "%VCPKG_ROOT%"=="" (
    echo ERROR: VCPKG_ROOT environment variable is not set.
    echo Please install vcpkg and set VCPKG_ROOT environment variable.
    echo See BUILD_WIN64.md for detailed instructions.
    exit /b 1
)

if not exist "%VCPKG_ROOT%" (
    echo ERROR: VCPKG_ROOT points to non-existent directory: %VCPKG_ROOT%
    exit /b 1
)

if not exist "%VCPKG_ROOT%\vcpkg.exe" (
    echo ERROR: vcpkg.exe not found in VCPKG_ROOT
    echo Please run bootstrap-vcpkg.bat in your vcpkg directory.
    exit /b 1
)

echo [OK] vcpkg found at: %VCPKG_ROOT%

REM Check CMake
cmake --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: CMake not found in PATH
    echo Please install CMake and add it to your PATH.
    exit /b 1
)
echo [OK] CMake found

REM Check Git
git --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Git not found in PATH
    exit /b 1
)
echo [OK] Git found

REM Check Ninja (optional)
ninja --version >nul 2>&1
if errorlevel 1 (
    echo [WARN] Ninja not found, will use default generator
    set GENERATOR=
) else (
    echo [OK] Ninja found
    set GENERATOR=-G Ninja
)

echo.

REM Initialize submodules
echo Checking Git submodules...
git submodule status | findstr /R "^-" >nul
if not errorlevel 1 (
    echo Initializing Git submodules...
    git submodule update --init --recursive
    if errorlevel 1 (
        echo ERROR: Failed to initialize Git submodules
        exit /b 1
    )
    echo [OK] Submodules initialized
) else (
    echo [OK] Submodules already initialized
)

echo.

REM Build configuration
set BUILD_DIR=out\build\x64-%CONFIG%
if /i "%TOOLSET%"=="v143" set BUILD_DIR=!BUILD_DIR!-v143
set TRIPLET=x64-windows-%TOOLSET%

echo Build Configuration:
echo   Configuration: %CONFIG%
echo   Toolset: %TOOLSET%
echo   Triplet: %TRIPLET%
echo   Build Directory: %BUILD_DIR%
echo.

REM Configure
echo Configuring project...
echo.

cmake -B %BUILD_DIR% ^
      %GENERATOR% ^
      -DCMAKE_BUILD_TYPE=%CONFIG% ^
      -DCMAKE_TOOLCHAIN_FILE=%VCPKG_ROOT%/scripts/buildsystems/vcpkg.cmake ^
      -DVCPKG_OVERLAY_TRIPLETS=cmake/triplets ^
      -DVCPKG_TARGET_TRIPLET=%TRIPLET%

if errorlevel 1 (
    echo ERROR: CMake configuration failed
    exit /b 1
)

echo [OK] Configuration completed successfully
echo.

REM Build
echo Building project...
echo This may take a while, especially on the first build...
echo.

cmake --build %BUILD_DIR% --config %CONFIG%

if errorlevel 1 (
    echo ERROR: Build failed
    exit /b 1
)

echo.
echo ==============================================
echo Build completed successfully!
echo ==============================================
echo.
echo Output files:
echo   Static library: %BUILD_DIR%\livekitclient.lib
echo   Examples:
echo     - %BUILD_DIR%\examples\cpp_sample\cpp_sample.exe
echo     - %BUILD_DIR%\examples\room_event\room_event.exe
echo     - %BUILD_DIR%\examples\publish_audio\publish_audio.exe
echo   Tests: %BUILD_DIR%\test\
echo.
echo Next steps:
echo   1. Link livekitclient.lib to your application
echo   2. Include headers from the include/ directory
echo   3. See examples/ for usage examples
echo.
echo For more information, see BUILD_WIN64.md
echo.

endlocal
