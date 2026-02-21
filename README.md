# mise-zerobrew

A [mise](https://mise.jdx.dev) backend plugin that installs Homebrew formulae via [zerobrew](https://github.com/lucasgelfond/zerobrew) - a 5-20x faster Homebrew alternative.

## Why?

Zerobrew provides significant speed improvements over Homebrew through:
- **Content-addressable storage** - instant reinstalls from cache
- **APFS clonefile** - zero disk overhead on macOS
- **Parallel operations** - concurrent downloads and extraction
- **HTTP caching** - aggressive CDN caching

This plugin lets you use zerobrew's speed while managing tools through mise.

## Benchmarks

Tested on macOS (CI runner):

| Package | Homebrew | Zerobrew | Speedup |
|---------|----------|----------|---------|
| **Cold install** (no cache) ||||
| jq | 5.42s | 2.17s | **2.4x** |
| tree | 4.16s | 0.70s | **5.9x** |
| **Warm install** (cached) ||||
| jq | 4.46s | 0.33s | **13.4x** |
| tree | 3.41s | 0.27s | **12.4x** |
| wget | 3.87s | 1.05s | **3.6x** |

Run benchmarks locally: `mise run benchmark`

## Prerequisites

1. Install [mise](https://mise.jdx.dev/getting-started.html)
2. Install [zerobrew](https://github.com/lucasgelfond/zerobrew):
   ```bash
   curl -fsSL https://zerobrew.rs/install | bash
   ```

## Installation

```bash
mise plugins install zerobrew https://github.com/kennyg/mise-zerobrew
```

## Usage

### Basic Usage

```bash
# Install the latest version of a formula
mise use zerobrew:jq
mise use zerobrew:ripgrep

# Install a specific versioned formula
mise use zerobrew:python@3.11
mise use zerobrew:node@20

# List available versions
mise ls-remote zerobrew:python
```

### In mise.toml

```toml
[tools]
"zerobrew:jq" = "latest"
"zerobrew:python" = "3.11"
"zerobrew:node" = "20"
```

## How It Works

### Version Discovery

The plugin queries the [Homebrew API](https://formulae.brew.sh/api/formula.json) to find:
- Versioned formulae (e.g., `python@3.11`, `node@20`, `go@1.21`)
- The base formula (exposed as version `latest`)

### Installation

Each tool+version combination gets its own isolated zerobrew installation:
```
~/.local/share/mise/installs/zerobrew-{tool}/{version}/
├── prefix/
│   ├── bin/       # Symlinks to binaries (mise uses this)
│   ├── lib/       # Libraries
│   └── Cellar/    # Actual package files
├── store/         # Content-addressable cache
└── db/            # SQLite tracking database
```

The plugin uses `zb --root <path> install <formula>` to isolate each installation.

## Limitations

- **Versioned formulae only**: Version selection relies on Homebrew's `@version` naming convention. Not all formulae have versioned variants.
- **macOS/Linux only**: Zerobrew requires APFS (macOS) or ext4/xfs (Linux) for optimal performance.
- **Homebrew core tap only**: Only formulae from the default Homebrew tap are supported.

## Development

```bash
# Clone
git clone https://github.com/kennyg/mise-zerobrew
cd mise-zerobrew

# Link for local testing
mise plugins link zerobrew .

# Test
mise ls-remote zerobrew:python
mise install zerobrew:jq@latest
```

### Running Tests

```bash
mise run test
mise run lint
mise run ci
```

## License

MIT
