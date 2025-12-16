
# Claude Code Sandbox

Run Claude Code in a sandbox.

Currently using Docker which provides reasonable isolation as long as there are no targeted attacks.

## Prerequisites

- Docker installed and running on your system
- Claude Code Docker image: `wb14123/claude-code:latest`

## Installation

### Option 1: Clone the Repository

```bash
git clone <repository-url>
cd claude-code-sandbox
chmod +x claude-code-wrapper
```

### Option 2: Download the Script Directly

```bash
curl -O <raw-url-to-claude-code-wrapper>
chmod +x claude-code-wrapper
```

## Usage

### Direct Execution

You can run the wrapper script directly:

```bash
./claude-code-wrapper
```

### Set Up an Alias (Recommended)

For easier access, add an alias to your shell configuration file (`~/.bashrc`, `~/.zshrc`, or similar):

```bash
alias claude='/path/to/claude-code-sandbox/claude-code-wrapper'
```

After adding the alias, reload your shell configuration:

```bash
source ~/.bashrc  # or source ~/.zshrc
```

Now you can run Claude Code from anywhere:

```bash
claude
```

## How It Works

The wrapper script runs Claude Code inside a Docker container with the following features:

- **Configuration persistence**: Mounts `~/.claude` and `~/.claude.json` to preserve your settings
- **Working directory access**: Mounts your current working directory, allowing Claude Code to access your project files
- **User permissions**: Runs as your current user to avoid permission issues with created/modified files
- **Isolation**: Provides sandboxed execution environment for enhanced security

## Notes

- The wrapper preserves your current working directory, so Claude Code can access files in the directory where you run it
- All Claude Code configuration is stored in your home directory and persists across container runs
- Files created or modified by Claude Code will have your user's ownership