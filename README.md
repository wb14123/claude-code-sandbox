# Code Agent Sandbox

Run AI code agents in a Docker sandbox.

Currently supports:
- [Claude Code](https://github.com/anthropics/claude-code) - Anthropic's CLI coding agent
- [Qwen Code](https://github.com/QwenLM/qwen-code) - Qwen's terminal-first coding agent
- [OpenCode](https://github.com/anomalyco/opencode) - Terminal-first AI coding agent

Docker provides reasonable isolation as long as there are no targeted attacks.

## Prerequisites

- Docker installed and running on your system

## Available Docker Images

| Agent | Docker Image |
|-------|-------------|
| Claude Code | `wb14123/claude-code:latest` |
| Qwen Code | `wb14123/qwen-code:latest` |
| OpenCode | `wb14123/opencode:latest` |

## Installation

### Clone the Repository

```bash
git clone <repository-url>
cd claude-code-sandbox
```

## Usage

### Claude Code

Run the wrapper script directly:

```bash
./claude-code/claude-code-wrapper
```

Or set up an alias in your shell configuration (`~/.bashrc`, `~/.zshrc`, etc.):

```bash
alias claude='/path/to/claude-code-sandbox/claude-code/claude-code-wrapper'
```

### Qwen Code

Run the wrapper script directly:

```bash
./qwen-code/qwen-code-wrapper
```

Or set up an alias:

```bash
alias qwen='/path/to/claude-code-sandbox/qwen-code/qwen-code-wrapper'
```

### OpenCode

Run the wrapper script directly:

```bash
./opencode/opencode-wrapper
```

Or set up an alias:

```bash
alias opencode='/path/to/claude-code-sandbox/opencode/opencode-wrapper'
```

After adding aliases, reload your shell configuration:

```bash
source ~/.bashrc  # or source ~/.zshrc
```

## How It Works

The wrapper scripts run code agents inside Docker containers with the following features:

- **Configuration persistence**: Mounts agent config directories to preserve your settings
- **Working directory access**: Mounts your current working directory, allowing agents to access your project files
- **User permissions**: Runs as your current user to avoid permission issues with created/modified files
- **Isolation**: Provides sandboxed execution environment for enhanced security

## Building Images

To build all Docker images:

```bash
./build.sh
```

To build a specific agent's image:

```bash
./claude-code/build.sh
./qwen-code/build.sh
./opencode/build.sh
```

## Project Structure

```
.
├── build.sh                     # Build all Docker images
├── claude-code/
│   ├── Dockerfile
│   ├── build.sh
│   ├── check-dependencies.sh
│   └── claude-code-wrapper
├── qwen-code/
│   ├── Dockerfile
│   ├── build.sh
│   ├── check-dependencies.sh
│   └── qwen-code-wrapper
└── opencode/
    ├── Dockerfile
    ├── build.sh
    ├── check-dependencies.sh
    └── opencode-wrapper
```

## Notes

- The wrappers preserve your current working directory, so agents can access files in the directory where you run them
- All agent configuration is stored in your home directory and persists across container runs
- Files created or modified by agents will have your user's ownership
