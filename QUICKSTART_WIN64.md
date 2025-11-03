# Quick Start Guide - Windows 64-bit

This is a quick reference for building LiveKit Client C++ SDK on Windows 64-bit. For detailed instructions, see [BUILD_WIN64.md](./BUILD_WIN64.md).

## Prerequisites Checklist

- [ ] Visual Studio 2019 or 2022 with "Desktop development with C++" workload
- [ ] CMake 3.11 or later (added to PATH)
- [ ] Git
- [ ] vcpkg installed and `VCPKG_ROOT` environment variable set

## Quick Build (Using Automated Script)

### PowerShell (Recommended)
```powershell
# Clone repository
git clone --recurse-submodules https://github.com/lifelike-and-believable/livekit-client-cpp.git
cd livekit-client-cpp

# Build (Release, VS2022)
.\build-win64.ps1

# Or build Debug with VS2019
.\build-win64.ps1 -Config Debug -Toolset v142
```

### Command Prompt
```cmd
REM Clone repository
git clone --recurse-submodules https://github.com/lifelike-and-believable/livekit-client-cpp.git
cd livekit-client-cpp

REM Build (Release, VS2022)
build-win64.bat

REM Or build Debug with VS2019
build-win64.bat Debug v142
```

## Quick Build (Manual)

### Using Visual Studio IDE
1. Open `CMakeLists.txt` in Visual Studio
2. Select configuration from dropdown (x64-Debug, x64-Release, etc.)
3. Press `Ctrl+Shift+B` to build

### Using Command Line
```cmd
REM Open "x64 Native Tools Command Prompt" for your Visual Studio version

REM Configure
cmake -B out/build/x64-Release ^
      -G Ninja ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_TOOLCHAIN_FILE=%VCPKG_ROOT%/scripts/buildsystems/vcpkg.cmake ^
      -DVCPKG_OVERLAY_TRIPLETS=cmake/triplets ^
      -DVCPKG_TARGET_TRIPLET=x64-windows-v143

REM Build
cmake --build out/build/x64-Release
```

## Output Location

After successful build:
- **Static Library**: `out/build/x64-Release/livekitclient.lib`
- **Examples**: `out/build/x64-Release/examples/*/`
- **Tests**: `out/build/x64-Release/test/`

## Common Options

### Build Configurations
- `Debug` - Debug build with symbols
- `Release` - Optimized release build

### Toolsets
- `v142` - Visual Studio 2019
- `v143` - Visual Studio 2022

### CMake Options
```cmd
-DBUILD_EXAMPLES=OFF    # Don't build examples
-DBUILD_TEST=OFF        # Don't build tests
```

## Quick Troubleshooting

| Issue | Solution |
|-------|----------|
| VCPKG_ROOT not set | Set environment variable to vcpkg directory |
| Ninja not found | Use VS Developer Command Prompt or install Ninja |
| Submodules missing | Run `git submodule update --init --recursive` |
| First build slow | Normal - vcpkg downloads dependencies (30-60 min) |

## Using in Your Project

1. **Link the library**:
   ```cmake
   target_link_libraries(your_app PRIVATE livekitclient)
   ```

2. **Include headers**:
   ```cpp
   #include "livekit/core/livekit_client.h"
   ```

3. **Link dependencies**: Ensure your project links all required dependencies (see CMakeLists.txt)

## Need Help?

See [BUILD_WIN64.md](./BUILD_WIN64.md) for:
- Detailed installation instructions
- Complete troubleshooting guide
- Advanced configuration options
- Platform requirements

## Next Steps

- Explore [examples](./examples/) to learn SDK usage
- Read [README.md](./Readme.md) for project overview
- Check project's issue tracker for known issues
