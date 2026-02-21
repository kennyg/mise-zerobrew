-- metadata.lua
-- Backend plugin for zerobrew - a fast Homebrew alternative
-- Documentation: https://mise.jdx.dev/backend-plugin-development.html

PLUGIN = { -- luacheck: ignore
    name = "zerobrew",
    version = "0.2.0",
    description = "Install Homebrew formulae via zerobrew (faster Homebrew alternative)",
    author = "kennyg",
    homepage = "https://github.com/kennyg/mise-zerobrew",
    license = "MIT",
    notes = {
        "Requires zerobrew (zb) to be installed: https://github.com/lucasgelfond/zerobrew",
        "Installs formulae from Homebrew's core tap",
        "Use versioned formulae for version control (e.g., python@3.11, node@20)",
    },
}
