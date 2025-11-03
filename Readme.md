# livekit-client-cpp-sdk

C++ client SDK for LiveKit in C++20.

Because webrtc requires C++20.

## Support Platforms

- [x] Microsoft Windows
- [ ] GNU/Linux
- [ ] Apple macOS
- [ ] iOS
- [ ] Android

## Features

- [ ] Client Websocket Signal
- [ ] Receiving tracks
- [ ] Publishing tracks
- [ ] Data channels
- [ ] E2ee

## Dependencies

- [livekit-protocol](https://github.com/livekit/protocol)(as submodule by default)
- [plog](https://github.com/SergiusTheBest/plog) (as submodule by default)
- [libwebsockets](https://github.com/warmcat/libwebsockets)
- [libwebrtc](https://github.com/livekit/rust-sdks/releases) (cmake FetchContent by default)
- [protobuf](https://github.com/protocolbuffers/protobuf) (cmake find_package by default)
- [nlohmann_json](https://github.com/nlohmann/json) (as submodule by default)
- [dr_libs](https://github.com/mackron/dr_libs) (as submodule by default for examples)

## Building

### Windows 64-bit

For detailed step-by-step instructions on building static libraries for Windows 64-bit, see [BUILD_WIN64.md](./BUILD_WIN64.md).

Quick start:
1. Install Visual Studio 2019 or 2022 with C++ development tools
2. Install vcpkg and set `VCPKG_ROOT` environment variable
3. Clone this repository with submodules: `git clone --recurse-submodules <repo-url>`
4. Build using Visual Studio or command line (see BUILD_WIN64.md for details)

## Examples

See [examples](./examples/)

## Thanks

- [livekit](https://livekit.io/)
- [webrtc-sdk](https://github.com/webrtc-sdk)
- [protobuf](https://github.com/protocolbuffers/protobuf)
- [nlohmann_json](https://github.com/nlohmann/json)
- [plog](https://github.com/SergiusTheBest/plog)
- [libwebsockets](https://github.com/warmcat/libwebsockets)
- [vcpkg](https://github.com/livekit/protocol)
- [Azure](https://github.com/Azure)

## License

livekit-client-cpp is licensed under Apache License v2.0.
