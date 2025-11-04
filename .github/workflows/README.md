# GitHub Actions Workflows

This directory contains GitHub Actions workflows for building and releasing the LiveKit Client C++ SDK across multiple platforms.

## Available Workflows

### 1. Multi-Platform Build and Release (Recommended)
**File**: `multi-platform-release.yml`

Builds the SDK for all supported platforms (Windows, Linux, macOS) and creates a unified release with all artifacts.

### 2. Windows Build and Release
**File**: `windows-build-release.yml`

Builds the SDK specifically for Windows using a self-hosted runner.

### 3. Linux Build and Release
**File**: `linux-build-release.yml`

Builds the SDK for Linux (Ubuntu) using GitHub-hosted runners.

### 4. macOS Build and Release
**File**: `macos-build-release.yml`

Builds the SDK for macOS (Intel and Apple Silicon) using GitHub-hosted runners.

---

## Multi-Platform Workflow (Recommended)

### Overview

This workflow builds the LiveKit Client C++ SDK for Windows, Linux, and macOS, then creates a unified GitHub release with all platform artifacts.

### Triggers

The workflow can be triggered in two ways:

1. **Automatic**: When a version tag is pushed (e.g., `v1.0.0`, `v2.1.3`)
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. **Manual**: Via the "Actions" tab in GitHub (workflow_dispatch)
   - Go to Actions → Windows Build and Release → Run workflow
   - Options:
     - Create a release: Choose whether to create a release
     - Release tag name: Specify a custom tag (optional, defaults to timestamp)

### Build Matrix

The workflow builds the following configurations:

- **Configuration**: Debug, Release
- **Toolset**: VS2022 (v143)

This produces 2 build artifacts per run.

### Platform Support

| Platform | Runner Type | Architectures | Configurations |
|----------|-------------|---------------|----------------|
| Windows  | Self-hosted | x64           | Debug, Release |
| Linux    | GitHub-hosted | x64         | Debug, Release |
| macOS    | GitHub-hosted | x86_64, arm64 | Debug, Release |

### Triggers

Same as individual platform workflows:
- Automatic on version tags (e.g., `v1.0.0`)
- Manual via workflow_dispatch

### Build Matrix

Total artifacts produced: 8
- Windows: 2 (Debug, Release)
- Linux: 2 (Debug, Release)  
- macOS: 4 (2 configs × 2 architectures)

---

## Windows-Only Workflow

### Self-Hosted Runner Requirements

The Windows self-hosted runner must have the following installed:

#### Required Software

1. **Visual Studio 2022** with the following components:
   - Desktop development with C++
   - MSVC v143 build tools
   - Windows 10/11 SDK
   - C++ CMake tools for Windows

2. **vcpkg** Package Manager
   - Clone vcpkg to a stable location (e.g., `C:\vcpkg` or `C:\dev\vcpkg`)
   - Run `bootstrap-vcpkg.bat` to initialize
   - Set `VCPKG_ROOT` environment variable to point to the vcpkg directory

3. **CMake** (3.11 or later)
   - Add to system PATH

4. **Git**
   - For cloning repositories and submodules

5. **Ninja Build System** (recommended)
   - Add to system PATH, or use the version included with Visual Studio

#### Environment Variables

Set these environment variables on the runner:

- `VCPKG_ROOT`: Path to vcpkg installation (e.g., `C:\vcpkg`)

### Build Artifacts

Each build configuration produces a ZIP archive containing:

```
livekit-client-cpp-windows-x64-{Config}-{Toolset}/
├── lib/
│   └── livekitclient.lib          # Static library
├── include/                        # Public header files
├── generated/                      # Generated protobuf headers
├── examples/                       # Example executables
│   ├── cpp_sample.exe
│   ├── room_event.exe
│   └── publish_audio.exe
├── README.md                       # Main documentation
├── LICENSE                         # License file
├── BUILD_WIN64.md                  # Build guide
├── QUICKSTART_WIN64.md            # Quick start guide
└── VERSION.txt                     # Build metadata
```

### Artifact Retention

- **Build artifacts**: Retained for 30 days
- **Release artifacts**: Retained for 7 days (before being attached to release)

### GitHub Release

When triggered by a version tag or manual dispatch with "Create a release" enabled:

1. All build artifacts are collected
2. A GitHub release is created with:
   - Tag name from the git tag or manual input
   - Release notes describing the build
   - All ZIP archives attached as downloadable assets

### Usage Example

#### Automatic Release on Tag

```bash
# Create and push a version tag
git tag v1.0.0
git push origin v1.0.0

# The workflow will automatically:
# 1. Build Debug and Release configurations
# 2. Package the artifacts
# 3. Create a GitHub release with all artifacts
```

#### Manual Build Without Release

1. Go to Actions → Windows Build and Release
2. Click "Run workflow"
3. Set "Create a release" to "false"
4. Click "Run workflow"

The artifacts will be uploaded to the workflow run but no release will be created.

#### Manual Build With Custom Release

1. Go to Actions → Windows Build and Release
2. Click "Run workflow"
3. Set "Create a release" to "true"
4. Enter a custom tag name (e.g., "beta-1.0.0")
5. Click "Run workflow"

A release will be created with the specified tag.

### Troubleshooting

#### vcpkg not found

**Error**: `VCPKG_ROOT environment variable is not set`

**Solution**: Ensure the `VCPKG_ROOT` environment variable is set on the runner and restart the runner service.

#### Build failures

**Error**: CMake or build errors

**Solution**: 
1. Check that all prerequisites are installed on the runner
2. Verify vcpkg dependencies are accessible
3. Check the workflow logs for specific error messages
4. Ensure sufficient disk space (10+ GB free recommended)

#### Ninja not found

**Warning**: `Ninja not found, will use default generator`

**Solution**: This is a warning, not an error. The workflow will fall back to the default Visual Studio generator. To use Ninja (faster builds):
1. Download Ninja from https://github.com/ninja-build/ninja/releases
2. Add to system PATH
3. Restart the runner service

### Workflow Maintenance

#### Adding New Build Configurations

To add support for additional toolsets or configurations:

1. Edit the `strategy.matrix` section:
   ```yaml
   strategy:
     matrix:
       config: [Debug, Release]
       toolset: [v142, v143]  # Add v142 for VS2019 support
   ```

2. Ensure the self-hosted runner has the required Visual Studio version installed

#### Modifying Build Options

To change CMake build options:

1. Edit the "Configure project" step
2. Add or modify CMake arguments:
   ```yaml
   -DBUILD_EXAMPLES=OFF   # Disable examples
   -DBUILD_TEST=OFF       # Disable tests
   ```

### Security Notes

- The workflow uses `GITHUB_TOKEN` for creating releases (automatically provided by GitHub)
- No additional secrets are required
- Build artifacts are stored in GitHub's artifact storage
- Release assets are publicly accessible

### Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Self-hosted Runners Guide](https://docs.github.com/en/actions/hosting-your-own-runners)
- [LiveKit Client C++ Build Guide](../../BUILD_WIN64.md)
