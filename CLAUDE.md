# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

mise-zerobrew is a mise backend plugin written in Lua 5.4 that provides fast Homebrew formula installation using zerobrew as an alternative to Homebrew. It implements the vfox-compatible plugin system.

## Development Commands

All commands are run via mise:

```bash
mise run format    # Format Lua code with stylua
mise run lint      # Run all linters (luacheck, stylua check, actionlint)
mise run test      # Run structure, syntax, and integration tests
mise run ci        # Run lint + test (used in CI)
```

## Architecture

The plugin implements three hooks required by the mise backend system:

- **hooks/backend_list_versions.lua** - Queries the Homebrew API (`https://formulae.brew.sh/api/formula.json`) to list available versions. Returns versioned formulae (e.g., `python@3.11`) plus "latest" pseudo-version for base formulae.

- **hooks/backend_install.lua** - Installs packages via zerobrew (`zb --root <path> install <formula>`). Handles version-to-formula mapping and validates zerobrew availability.

- **hooks/backend_exec_env.lua** - Configures environment variables (PATH, library paths, include paths, pkg-config) for installed tools. Handles macOS (DYLD_LIBRARY_PATH) vs Linux (LD_LIBRARY_PATH) differences.

- **metadata.lua** - Plugin metadata (name, version, description).

## Lua Module Globals

The plugin uses these globals provided by the mise/vfox runtime:
- `PLUGIN` - Plugin metadata
- `RUNTIME` - Runtime info (osType, archType)
- `cmd` - Command execution
- `http` - HTTP client
- `json` - JSON parsing
- `file` - File operations

## Testing

The test script (`mise-tasks/test`) runs three test categories:
1. Structure tests - verify required files exist
2. Syntax tests - validate Lua syntax with luac
3. Integration tests - only run if zerobrew is installed; test plugin linking, version listing, installation, and execution
