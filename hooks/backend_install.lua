-- hooks/backend_install.lua
-- Installs a Homebrew formula via zerobrew
-- Uses isolated ZEROBREW_ROOT per installation for mise compatibility

function PLUGIN:BackendInstall(ctx)
    local tool = ctx.tool
    local version = ctx.version
    local install_path = ctx.install_path

    if not tool or tool == "" then
        error("Tool name cannot be empty")
    end
    if not version or version == "" then
        error("Version cannot be empty")
    end
    if not install_path or install_path == "" then
        error("Install path cannot be empty")
    end

    local cmd = require("cmd")

    -- Resolve the zb binary. A bare `which zb` fails when zerobrew is
    -- installed *via mise itself* (e.g. `mise use -g cargo:zb_cli`), because
    -- mise's shim directory is not on the hook subprocess's PATH even though
    -- `mise which zb` resolves it. Fall back to `mise which zb` before giving
    -- up. See https://github.com/kennyg/mise-zerobrew/issues/3
    local function trim(s)
        return (s or ""):gsub("^%s+", ""):gsub("%s+$", "")
    end

    local zb_bin = trim(cmd.exec("command -v zb 2>/dev/null || true"))
    if zb_bin == "" then
        zb_bin = trim(cmd.exec("mise which zb 2>/dev/null || true"))
    end
    if zb_bin == "" then
        error([[
zerobrew (zb) not found in PATH.

Install zerobrew first:
  curl -fsSL https://zerobrew.rs/install | bash

Or install it via mise (no Homebrew required):
  mise use -g "github:lucasgelfond/zerobrew[matching=zb-,rename_exe=zb]"

For more info: https://github.com/lucasgelfond/zerobrew
]])
    end

    -- Determine the actual formula name to install
    local formula
    if version == "latest" then
        -- Install the base formula (e.g., "ruby")
        formula = tool
    else
        -- Install the versioned formula (e.g., "python@3.11")
        formula = tool .. "@" .. version
    end

    -- Validate formula contains only safe characters (alphanumeric, @, -, _, .)
    if not formula:match("^[%w@%-%._]+$") then
        error("Invalid formula name: " .. formula)
    end

    -- Shell-quote the install path and zb binary in case they contain spaces
    local quoted_path = "'" .. install_path:gsub("'", "'\\''") .. "'"
    local quoted_zb = "'" .. zb_bin:gsub("'", "'\\''") .. "'"

    -- zerobrew creates its own directory structure at install_path
    local result, install_err = cmd.exec(quoted_zb .. " --root " .. quoted_path .. " install " .. formula)

    if install_err then
        error("Failed to install " .. formula .. ": " .. install_err)
    end

    return {}
end
