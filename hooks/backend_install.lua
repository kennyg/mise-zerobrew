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

    -- Check if zerobrew is installed
    local zb_check = cmd.exec("which zb 2>/dev/null || true")
    if zb_check == "" then
        error([[
zerobrew (zb) not found in PATH.

Install zerobrew first:
  curl -fsSL https://zerobrew.rs/install | bash

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

    -- Shell-quote the install path in case it contains spaces
    local quoted_path = "'" .. install_path:gsub("'", "'\\''") .. "'"

    -- zerobrew creates its own directory structure at install_path
    local result, install_err = cmd.exec("zb --root " .. quoted_path .. " install " .. formula)

    if install_err then
        error("Failed to install " .. formula .. ": " .. install_err)
    end

    return {}
end
