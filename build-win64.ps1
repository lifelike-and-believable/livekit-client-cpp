# PowerShell script to build LiveKit Client C++ SDK for Windows 64-bit
# This script automates the build process described in BUILD_WIN64.md
#
# Usage:
#   .\build-win64.ps1 [-Config Release|Debug] [-Toolset v142|v143] [-SkipVcpkgCheck] [-BuildExamples] [-BuildTests]
#
# Examples:
#   .\build-win64.ps1                                    # Build Release with v143 toolset
#   .\build-win64.ps1 -Config Debug -Toolset v142        # Build Debug with VS2019 toolset
#   .\build-win64.ps1 -Config Release -BuildExamples:$false  # Build Release without examples

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Release", "Debug")]
    [string]$Config = "Release",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("v142", "v143")]
    [string]$Toolset = "v143",
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipVcpkgCheck = $false,
    
    [Parameter(Mandatory=$false)]
    [bool]$BuildExamples = $true,
    
    [Parameter(Mandatory=$false)]
    [bool]$BuildTests = $true
)

# Script settings
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Color output functions
function Write-Success {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Cyan
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Red
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Yellow
}

Write-Info "=============================================="
Write-Info "LiveKit Client C++ SDK - Windows Build Script"
Write-Info "=============================================="
Write-Info ""

# Check prerequisites
Write-Info "Checking prerequisites..."

# Check vcpkg
if (-not $SkipVcpkgCheck) {
    if (-not $env:VCPKG_ROOT) {
        Write-Error-Custom "ERROR: VCPKG_ROOT environment variable is not set."
        Write-Info "Please install vcpkg and set VCPKG_ROOT environment variable."
        Write-Info "See BUILD_WIN64.md for detailed instructions."
        exit 1
    }
    
    if (-not (Test-Path $env:VCPKG_ROOT)) {
        Write-Error-Custom "ERROR: VCPKG_ROOT points to non-existent directory: $env:VCPKG_ROOT"
        exit 1
    }
    
    $vcpkgExe = Join-Path $env:VCPKG_ROOT "vcpkg.exe"
    if (-not (Test-Path $vcpkgExe)) {
        Write-Error-Custom "ERROR: vcpkg.exe not found in VCPKG_ROOT"
        Write-Info "Please run bootstrap-vcpkg.bat in your vcpkg directory."
        exit 1
    }
    
    Write-Success "✓ vcpkg found at: $env:VCPKG_ROOT"
}

# Check CMake
try {
    $cmakeVersion = cmake --version 2>&1 | Select-Object -First 1
    Write-Success "✓ CMake found: $cmakeVersion"
} catch {
    Write-Error-Custom "ERROR: CMake not found in PATH"
    Write-Info "Please install CMake and add it to your PATH."
    exit 1
}

# Check Git
try {
    $gitVersion = git --version 2>&1
    Write-Success "✓ Git found: $gitVersion"
} catch {
    Write-Error-Custom "ERROR: Git not found in PATH"
    exit 1
}

# Check Ninja (optional)
try {
    $ninjaVersion = ninja --version 2>&1
    Write-Success "✓ Ninja found: version $ninjaVersion"
    $generator = "Ninja"
} catch {
    Write-Warning-Custom "! Ninja not found, will use default generator"
    $generator = $null
}

Write-Info ""

# Initialize submodules
Write-Info "Checking Git submodules..."
$submoduleStatus = git submodule status
if ($submoduleStatus -match "^-") {
    Write-Info "Initializing Git submodules..."
    git submodule update --init --recursive
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Custom "ERROR: Failed to initialize Git submodules"
        exit 1
    }
    Write-Success "✓ Submodules initialized"
} else {
    Write-Success "✓ Submodules already initialized"
}

Write-Info ""

# Build configuration
$buildDir = "out/build/x64-$Config"
if ($Toolset -eq "v143") {
    $buildDir = "$buildDir-v143"
}

$triplet = "x64-windows-$Toolset"

Write-Info "Build Configuration:"
Write-Info "  Configuration: $Config"
Write-Info "  Toolset: $Toolset"
Write-Info "  Triplet: $triplet"
Write-Info "  Build Directory: $buildDir"
Write-Info "  Build Examples: $BuildExamples"
Write-Info "  Build Tests: $BuildTests"
Write-Info ""

# Prepare CMake arguments
$cmakeArgs = @(
    "-B", $buildDir,
    "-DCMAKE_BUILD_TYPE=$Config",
    "-DCMAKE_TOOLCHAIN_FILE=$env:VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake",
    "-DVCPKG_OVERLAY_TRIPLETS=cmake/triplets",
    "-DVCPKG_TARGET_TRIPLET=$triplet"
)

if ($generator) {
    $cmakeArgs += @("-G", $generator)
}

if (-not $BuildExamples) {
    $cmakeArgs += "-DBUILD_EXAMPLES=OFF"
}

if (-not $BuildTests) {
    $cmakeArgs += "-DBUILD_TEST=OFF"
}

# Configure
Write-Info "Configuring project..."
Write-Info "CMake command: cmake $($cmakeArgs -join ' ')"
Write-Info ""

& cmake $cmakeArgs

if ($LASTEXITCODE -ne 0) {
    Write-Error-Custom "ERROR: CMake configuration failed"
    exit 1
}

Write-Success "✓ Configuration completed successfully"
Write-Info ""

# Build
Write-Info "Building project..."
Write-Info "This may take a while, especially on the first build..."
Write-Info ""

$buildArgs = @(
    "--build", $buildDir,
    "--config", $Config
)

& cmake $buildArgs

if ($LASTEXITCODE -ne 0) {
    Write-Error-Custom "ERROR: Build failed"
    exit 1
}

Write-Success ""
Write-Success "=============================================="
Write-Success "Build completed successfully!"
Write-Success "=============================================="
Write-Info ""
Write-Info "Output files:"
Write-Info "  Static library: $buildDir/livekitclient.lib"

if ($BuildExamples) {
    Write-Info "  Examples:"
    Write-Info "    - $buildDir/examples/cpp_sample/cpp_sample.exe"
    Write-Info "    - $buildDir/examples/room_event/room_event.exe"
    Write-Info "    - $buildDir/examples/publish_audio/publish_audio.exe"
}

if ($BuildTests) {
    Write-Info "  Tests: $buildDir/test/"
}

Write-Info ""
Write-Info "Next steps:"
Write-Info "  1. Link livekitclient.lib to your application"
Write-Info "  2. Include headers from the include/ directory"
Write-Info "  3. See examples/ for usage examples"
Write-Info ""
Write-Success "For more information, see BUILD_WIN64.md"
