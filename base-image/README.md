# Base Image for Coding Agents

This is the shared base Docker image that contains common developer tools used across different coding agent images.

## Contents

- Node.js 25 (Bookworm)
- Git, curl, wget
- Build essentials
- Rust toolchain (rustup, cargo) installed in `/opt/rust` for shared access

## Building

Use the build script to build and push the base image:

```bash
./base-image/build.sh
```

Or build all images at once from the repository root:

```bash
./build.sh
```

## Adding More Tools

To add more common developer tools, modify `base-image/Dockerfile` and rebuild all dependent images.
