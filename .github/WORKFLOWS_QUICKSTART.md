# Workflows Quick Start Guide

## Overview

The LiveKit C++ Client SDK supports automated builds for:
- **Windows** (x64) - Self-hosted runner
- **Linux** (x64) - GitHub-hosted runner
- **macOS** (x86_64 and arm64) - GitHub-hosted runner

## Creating a Multi-Platform Release

### Option 1: Using Git Tags (Recommended)

The easiest way to create a multi-platform release is by pushing a version tag:

```bash
# Create a version tag
git tag v1.0.0

# Push the tag to trigger the workflow
git push origin v1.0.0
```

This will automatically:
1. Build Debug and Release configurations for Windows, Linux, and macOS
2. Package all artifacts (8 total: 2 Windows, 2 Linux, 4 macOS)
3. Create a GitHub release with the version tag
4. Attach all build artifacts to the release

**Note**: By default, pushing a tag triggers the **multi-platform workflow** which builds for all platforms.

### Option 2: Manual Workflow Dispatch

For testing or creating custom releases:

1. Navigate to your repository on GitHub
2. Click on the **Actions** tab
3. Select the desired workflow:
   - **Multi-Platform Build and Release** (recommended for full releases)
   - **Windows Build and Release** (Windows only)
   - **Linux Build and Release** (Linux only)
   - **macOS Build and Release** (macOS only)
4. Click **Run workflow** button
5. Configure options:
   - **Create a release**: Select "true" if you want a release, "false" for just building
   - **Release tag name**: Enter a custom tag (e.g., "beta-1.0.0") or leave empty for timestamp
6. Click **Run workflow**

## What Gets Built

### Multi-Platform Workflow

Produces 8 artifacts:

**Windows (Self-hosted runner)**
- Debug and Release with VS2022 (v143)

**Linux (GitHub-hosted: ubuntu-latest)**
- Debug and Release with GCC

**macOS (GitHub-hosted: macos-latest)**
- Debug and Release for x86_64 (Intel)
- Debug and Release for arm64 (Apple Silicon)

### Individual Platform Workflows

Each platform workflow produces 2-4 artifacts depending on the platform.

## Artifact Contents

Each artifact ZIP contains:

```
📦 livekit-client-cpp-windows-x64-{Config}-v143.zip
├── 📁 lib/
│   └── livekitclient.lib           # Static library
├── 📁 include/                      # Header files
├── 📁 generated/                    # Protobuf headers
├── 📁 examples/
│   ├── cpp_sample.exe
│   ├── room_event.exe
│   └── publish_audio.exe
├── 📄 README.md
├── 📄 LICENSE
├── 📄 BUILD_WIN64.md
├── 📄 QUICKSTART_WIN64.md
└── 📄 VERSION.txt                   # Build metadata
```

## Choosing the Right Artifact

| Platform | Architecture | Debug | Release |
|----------|--------------|-------|---------|
| Windows | x64 | `livekit-client-cpp-windows-x64-Debug.zip` | `livekit-client-cpp-windows-x64-Release.zip` |
| Linux | x64 | `livekit-client-cpp-linux-x64-Debug.tar.gz` | `livekit-client-cpp-linux-x64-Release.tar.gz` |
| macOS Intel | x86_64 | `livekit-client-cpp-macos-x86_64-Debug.tar.gz` | `livekit-client-cpp-macos-x86_64-Release.tar.gz` |
| macOS Apple Silicon | arm64 | `livekit-client-cpp-macos-arm64-Debug.tar.gz` | `livekit-client-cpp-macos-arm64-Release.tar.gz` |

## Downloading Artifacts

### From Workflow Run

1. Go to **Actions** tab
2. Click on a workflow run
3. Scroll down to **Artifacts** section
4. Download the desired platform and configuration

### From Release

1. Go to **Releases** (or **Tags** → select a tag → **Release**)
2. Download the appropriate asset for your platform from the **Assets** section

## Runner Setup (For Repository Maintainers)

### GitHub-Hosted Runners

Linux and macOS builds use GitHub-hosted runners - **no setup required!**

### Self-Hosted Windows Runner

The Windows build requires a self-hosted runner with:

### Prerequisites

1. **Visual Studio 2022** with C++ development tools
2. **vcpkg** installed with `VCPKG_ROOT` environment variable set
3. **CMake** 3.11 or later
4. **Git** for repository operations
5. **Ninja** (optional, for faster builds)

### Setting Up vcpkg

```cmd
# Clone vcpkg
cd C:\
git clone https://github.com/microsoft/vcpkg.git
cd vcpkg

# Bootstrap vcpkg
.\bootstrap-vcpkg.bat

# Set environment variable (System-wide)
setx VCPKG_ROOT "C:\vcpkg" /M
```

### Registering the Runner

1. Go to repository **Settings** → **Actions** → **Runners**
2. Click **New self-hosted runner**
3. Select **Windows** as the operating system
4. Follow the setup instructions
5. Add labels: `self-hosted`, `windows`

For detailed setup instructions, see [workflows/README.md](workflows/README.md)

## Troubleshooting

### Build Fails with "VCPKG_ROOT not set"

**Solution**: Ensure `VCPKG_ROOT` environment variable is set on the runner and restart the runner service.

```powershell
# Verify environment variable
echo $env:VCPKG_ROOT

# Should output something like: C:\vcpkg
```

### Build Takes Too Long

First build will be slow (30-60 minutes) as vcpkg downloads and builds dependencies. Subsequent builds should be much faster (5-10 minutes) as dependencies are cached.

### Workflow Not Triggering on Tags

Ensure you're pushing the tag to GitHub:

```bash
# Verify tag exists locally
git tag

# Push tag to remote
git push origin v1.0.0

# Or push all tags
git push origin --tags
```

## Examples

### Creating a Stable Release

```bash
git tag v1.0.0
git push origin v1.0.0
```

### Creating a Beta Release

```bash
git tag v1.0.0-beta.1
git push origin v1.0.0-beta.1
```

### Creating a Release Candidate

```bash
git tag v1.0.0-rc.1
git push origin v1.0.0-rc.1
```

### Testing Without Creating a Release

Use workflow_dispatch:
1. Go to Actions → Windows Build and Release → Run workflow
2. Set "Create a release" to "false"
3. Run the workflow
4. Download artifacts from the workflow run page

## Best Practices

1. **Use semantic versioning** for tags (e.g., v1.0.0, v2.1.3)
2. **Test with workflow_dispatch** before creating official releases
3. **Document breaking changes** in release notes
4. **Keep runners updated** with latest Visual Studio and vcpkg versions
5. **Monitor disk space** on runners (builds require ~10GB)

## Need Help?

- 📖 See [workflows/README.md](workflows/README.md) for detailed documentation
- 🔨 See [BUILD_WIN64.md](../BUILD_WIN64.md) for local build instructions
- 🐛 Open an issue if you encounter problems
