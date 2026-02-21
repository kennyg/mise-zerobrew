-- .luacheckrc configuration for mise backend plugins

std = "lua51"

-- Globals defined by the mise/vfox plugin system
globals = {
    "PLUGIN",
    "RUNTIME", -- Runtime information injected by mise
}

-- Read-only globals from the plugin environment
read_globals = {
    -- vfox modules available in backend plugins
    "require",
    "cmd",    -- Command execution module
    "http",   -- HTTP client module
    "json",   -- JSON parsing module
    "file",   -- File operations module

    -- Standard Lua globals
    "os",
    "io",
    "table",
    "string",
    "math",
    "error",
    "ipairs",
    "pairs",
    "print",
    "tostring",
    "tonumber",
    "type",
    "pcall",
    "getmetatable",
    "setmetatable",
}

ignore = {
    "631", -- line is too long
    "212", -- unused argument (ctx, self often unused in simple hooks)
    "211", -- unused variable (template examples may have unused vars)
    "611", -- line contains only whitespace
    "612", -- trailing whitespace in comment
    "621", -- trailing whitespace
}

-- Allow trailing whitespace (can be auto-fixed)
allow_defined_top = true

-- Don't warn about unused arguments in hook functions
-- These are part of the plugin API signature
unused_args = false