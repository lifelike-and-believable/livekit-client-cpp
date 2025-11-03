# Building LiveKit Client Static Libraries for Windows 64-bit

This guide provides step-by-step instructions for building the LiveKit C++ client SDK static libraries on Windows 64-bit.

> 📋 **Quick Start**: If you're already familiar with C++ development on Windows, check out [QUICKSTART_WIN64.md](./QUICKSTART_WIN64.md) for a condensed version of this guide.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installing Dependencies](#installing-dependencies)
3. [Setting Up vcpkg](#setting-up-vcpkg)
4. [Cloning the Repository](#cloning-the-repository)
5. [Building the Static Libraries](#building-the-static-libraries)
6. [Build Output](#build-output)
7. [Troubleshooting](#troubleshooting)

## Prerequisites

Before you begin, ensure you have the following installed on your Windows system:

### Required Software

1. **Visual Studio 2019 or 2022**
   - Download from: https://visualstudio.microsoft.com/downloads/
   - Required workload: "Desktop development with C++"
   - Ensure you have the following components:
     - MSVC v142 (VS 2019) or MSVC v143 (VS 2022) build tools
     - Windows 10 SDK (or later)
     - C++ CMake tools for Windows

2. **CMake 3.11 or later**
   - Download from: https://cmake.org/download/
   - Make sure to add CMake to your system PATH during installation

3. **Git**
   - Download from: https://git-scm.com/download/win
   - Required for cloning the repository and submodules

4. **Ninja Build System** (recommended)
   - Download from: https://github.com/ninja-build/ninja/releases
   - Extract `ninja.exe` to a directory in your PATH (e.g., `C:\Program Files\CMake\bin\`)
   - Alternatively, Ninja is included with Visual Studio's CMake tools

### System Requirements

- Windows 10 or later (64-bit)
- At least 8 GB RAM (16 GB recommended)
- At least 10 GB free disk space

## Installing Dependencies

This project uses **vcpkg** to manage C++ dependencies. The following dependencies will be automatically installed:

- protobuf
- libwebsockets
- openssl (version 1.1.1n)
- abseil-cpp
- libuv

## Setting Up vcpkg

### Step 1: Install vcpkg

1. Open a Command Prompt or PowerShell window

2. Clone vcpkg to a location on your system (e.g., `C:\dev\vcpkg`):
   ```cmd
   cd C:\dev
   git clone https://github.com/microsoft/vcpkg.git
   cd vcpkg
   ```

3. Run the vcpkg bootstrap script:
   ```cmd
   .\bootstrap-vcpkg.bat
   ```

4. Set the `VCPKG_ROOT` environment variable to point to your vcpkg installation:
   - Open "Edit the system environment variables" from the Start menu
   - Click "Environment Variables"
   - Under "User variables" (or "System variables"), click "New"
   - Variable name: `VCPKG_ROOT`
   - Variable value: `C:\dev\vcpkg` (or your vcpkg installation path)
   - Click OK to save

5. **Important**: Close and reopen any command prompts or terminals to pick up the new environment variable

### Step 2: Verify vcpkg Installation

```cmd
%VCPKG_ROOT%\vcpkg version
```

This should display the vcpkg version information.

## Cloning the Repository

### Step 1: Clone the Repository with Submodules

```cmd
git clone --recurse-submodules https://github.com/lifelike-and-believable/livekit-client-cpp.git
cd livekit-client-cpp
```

If you already cloned the repository without submodules, initialize them:

```cmd
git submodule update --init --recursive
```

### Step 2: Verify Submodules

Ensure all submodules are checked out:

```cmd
git submodule status
```

You should see entries for:
- `deps/dr_libs`
- `deps/nlohmann_json`
- `deps/plog`
- `protocol`

## Building the Static Libraries

You can build the project using either **Automated Scripts**, **Visual Studio**, or **Command Line**.

### Option A: Using Automated Build Scripts (Recommended)

For convenience, automated build scripts are provided:

#### PowerShell Script (Recommended)

```powershell
# Build Release with VS2022 (v143 toolset) - Default
.\build-win64.ps1

# Build Debug with VS2019 (v142 toolset)
.\build-win64.ps1 -Config Debug -Toolset v142

# Build Release without examples and tests
.\build-win64.ps1 -Config Release -BuildExamples:$false -BuildTests:$false
```

#### Batch Script

```cmd
REM Build Release with VS2022 (v143 toolset) - Default
build-win64.bat

REM Build Debug with VS2019 (v142 toolset)
build-win64.bat Debug v142

REM Build Release with VS2022 (v143 toolset)
build-win64.bat Release v143
```

These scripts will:
- Check all prerequisites
- Initialize Git submodules if needed
- Configure and build the project
- Display helpful information about build outputs

### Option B: Building with Visual Studio

If you prefer to use the Visual Studio IDE:

#### For Visual Studio 2019 (v142 toolset):

1. Open Visual Studio 2019

2. Select **File → Open → CMake** and open the `CMakeLists.txt` from the repository root

3. Visual Studio will automatically start configuring the project using the settings from `CMakeSettings.json`

4. Select the build configuration from the dropdown:
   - **x64-Debug** (for debug build with v142 toolset)
   - **x64-Release** (for release build with v142 toolset)

5. Build the project:
   - Select **Build → Build All** from the menu
   - Or press `Ctrl+Shift+B`

#### For Visual Studio 2022 (v143 toolset):

1. Open Visual Studio 2022

2. Select **File → Open → CMake** and open the `CMakeLists.txt` from the repository root

3. Select the build configuration from the dropdown:
   - **x64-Debug-v143** (for debug build with v143 toolset)
   - **x64-Release-v143** (for release build with v143 toolset)

4. Build the project:
   - Select **Build → Build All** from the menu
   - Or press `Ctrl+Shift+B`

### Option C: Building from Command Line

#### For Visual Studio 2019 (v142 toolset):

1. Open **x64 Native Tools Command Prompt for VS 2019** from the Start menu

2. Navigate to the repository directory:
   ```cmd
   cd path\to\livekit-client-cpp
   ```

3. Configure the project (Debug build):
   ```cmd
   cmake -B out/build/x64-Debug ^
         -G Ninja ^
         -DCMAKE_BUILD_TYPE=Debug ^
         -DCMAKE_TOOLCHAIN_FILE=%VCPKG_ROOT%/scripts/buildsystems/vcpkg.cmake ^
         -DVCPKG_OVERLAY_TRIPLETS=cmake/triplets ^
         -DVCPKG_TARGET_TRIPLET=x64-windows-v142
   ```

   Or configure for Release build:
   ```cmd
   cmake -B out/build/x64-Release ^
         -G Ninja ^
         -DCMAKE_BUILD_TYPE=Release ^
         -DCMAKE_TOOLCHAIN_FILE=%VCPKG_ROOT%/scripts/buildsystems/vcpkg.cmake ^
         -DVCPKG_OVERLAY_TRIPLETS=cmake/triplets ^
         -DVCPKG_TARGET_TRIPLET=x64-windows-v142
   ```

4. Build the project:
   ```cmd
   cmake --build out/build/x64-Debug
   ```
   
   Or for Release:
   ```cmd
   cmake --build out/build/x64-Release
   ```

#### For Visual Studio 2022 (v143 toolset):

1. Open **x64 Native Tools Command Prompt for VS 2022** from the Start menu

2. Navigate to the repository directory:
   ```cmd
   cd path\to\livekit-client-cpp
   ```

3. Configure the project (Debug build):
   ```cmd
   cmake -B out/build/x64-Debug-v143 ^
         -G Ninja ^
         -DCMAKE_BUILD_TYPE=Debug ^
         -DCMAKE_TOOLCHAIN_FILE=%VCPKG_ROOT%/scripts/buildsystems/vcpkg.cmake ^
         -DVCPKG_OVERLAY_TRIPLETS=cmake/triplets ^
         -DVCPKG_TARGET_TRIPLET=x64-windows-v143
   ```

   Or configure for Release build:
   ```cmd
   cmake -B out/build/x64-Release-v143 ^
         -G Ninja ^
         -DCMAKE_BUILD_TYPE=Release ^
         -DCMAKE_TOOLCHAIN_FILE=%VCPKG_ROOT%/scripts/buildsystems/vcpkg.cmake ^
         -DVCPKG_OVERLAY_TRIPLETS=cmake/triplets ^
         -DVCPKG_TARGET_TRIPLET=x64-windows-v143
   ```

4. Build the project:
   ```cmd
   cmake --build out/build/x64-Debug-v143
   ```
   
   Or for Release:
   ```cmd
   cmake --build out/build/x64-Release-v143
   ```

### Build Configuration Options

You can customize the build with the following CMake options:

- `-DUSE_SYSTEM_PROTOBUF=ON/OFF` - Use system protobuf instead of vcpkg (default: ON)
- `-DUSE_SYSTEM_JSON=ON/OFF` - Use system nlohmann/json instead of submodule (default: OFF)
- `-DUSE_SYSTEM_ABSL=ON/OFF` - Use system Abseil instead of bundled (default: OFF)
- `-DBUILD_EXAMPLES=ON/OFF` - Build example applications (default: ON)
- `-DBUILD_TEST=ON/OFF` - Build test suite (default: ON)

Example with custom options:
```cmd
cmake -B out/build/x64-Release ^
      -G Ninja ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_TOOLCHAIN_FILE=%VCPKG_ROOT%/scripts/buildsystems/vcpkg.cmake ^
      -DVCPKG_OVERLAY_TRIPLETS=cmake/triplets ^
      -DVCPKG_TARGET_TRIPLET=x64-windows-v143 ^
      -DBUILD_EXAMPLES=OFF ^
      -DBUILD_TEST=OFF
```

## Build Output

After a successful build, you will find the following:

### Static Library

- **Debug build**: `out/build/x64-Debug/livekitclient.lib` (or `x64-Debug-v143` for VS2022)
- **Release build**: `out/build/x64-Release/livekitclient.lib` (or `x64-Release-v143` for VS2022)

This is the main static library that you can link against in your applications.

### Generated Protocol Buffers

- Located in: `out/build/x64-<Config>/generated/`
- Contains compiled protobuf headers and sources for LiveKit protocol

### Example Applications (if BUILD_EXAMPLES=ON)

- `out/build/x64-<Config>/examples/cpp_sample/cpp_sample.exe`
- `out/build/x64-<Config>/examples/room_event/room_event.exe`
- `out/build/x64-<Config>/examples/publish_audio/publish_audio.exe`

### Test Applications (if BUILD_TEST=ON)

- Located in: `out/build/x64-<Config>/test/`

## Troubleshooting

### Issue: vcpkg not found or VCPKG_ROOT not set

**Solution**: Ensure the `VCPKG_ROOT` environment variable is set correctly and restart your terminal/IDE.

```cmd
echo %VCPKG_ROOT%
```

This should output the path to your vcpkg installation.

### Issue: CMake cannot find Visual Studio

**Solution**: Use the appropriate Visual Studio Developer Command Prompt instead of a regular command prompt.

### Issue: "Ninja not found" error

**Solution**: Either:
1. Install Ninja and add it to your PATH
2. Use a different generator: `-G "Visual Studio 16 2019"` (for VS2019) or `-G "Visual Studio 17 2022"` (for VS2022)
3. Use the Ninja that comes with Visual Studio by opening the "Developer Command Prompt"

### Issue: vcpkg fails to install dependencies

**Solution**:
1. Ensure you have a stable internet connection
2. Update vcpkg to the latest version:
   ```cmd
   cd %VCPKG_ROOT%
   git pull
   .\bootstrap-vcpkg.bat
   ```
3. Try cleaning the vcpkg cache:
   ```cmd
   %VCPKG_ROOT%\vcpkg remove --outdated
   ```

### Issue: Out of memory during build

**Solution**: Close other applications and try building with fewer parallel jobs:
```cmd
cmake --build out/build/x64-Release -- -j4
```

### Issue: WebRTC library download fails

**Solution**: The WebRTC library is downloaded automatically via CMake FetchContent from:
`https://github.com/zesun96/libwebrtc/releases/download/webrtc-dac8015-4/`

If the download fails:
1. Check your internet connection
2. Try downloading manually from the URL shown in the CMake output
3. Extract to: `deps/libwebrtc/win_x64_debug/` (for debug) or `deps/libwebrtc/win_x64_release/` (for release)

### Issue: Protobuf version mismatch

**Solution**: Ensure you're using the version specified in `vcpkg.json`. If issues persist, try:
```cmd
%VCPKG_ROOT%\vcpkg remove protobuf
%VCPKG_ROOT%\vcpkg install protobuf
```

### Issue: Linker errors related to runtime library mismatch

**Solution**: This project uses static runtime linkage (`/MT` for release, `/MTd` for debug). Ensure all dependencies are built with the same runtime linkage. The custom vcpkg triplets in `cmake/triplets/` are configured for this.

### Issue: Submodules are not initialized

**Solution**:
```cmd
git submodule update --init --recursive
```

## Additional Notes

- **Build time**: First build may take 30-60 minutes as vcpkg downloads and compiles dependencies
- **Disk space**: Build artifacts and dependencies may require 5-10 GB of disk space
- **Static linking**: This project builds static libraries with static runtime (`/MT`, `/MTd`) for easier distribution
- **C++ Standard**: This project requires C++20 support

## Getting Help

If you encounter issues not covered in this guide:

1. Check the main [README.md](./Readme.md) for general information
2. Review the [CMakeLists.txt](./CMakeLists.txt) for build configuration details
3. Open an issue on the GitHub repository with:
   - Your Windows version
   - Visual Studio version
   - Complete error messages
   - CMake configuration output

## Next Steps

After successfully building the static libraries:

1. Check out the [examples](./examples/) directory to see how to use the SDK
2. Link `livekitclient.lib` to your application
3. Include the necessary headers from the `include/` directory
4. Ensure you link all required dependencies in your project

---

**Note**: This guide is specific to Windows 64-bit builds. For other platforms, refer to the main README.md file.
