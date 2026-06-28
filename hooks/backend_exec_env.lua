-- hooks/backend_exec_env.lua
-- Sets up environment variables for zerobrew-installed tools

function PLUGIN:BackendExecEnv(ctx)
    local install_path = ctx.install_path

    local file = require("file")

    -- zerobrew's on-disk layout depends on the OS, mirroring its own
    -- `default_prefix_for_os` (zb_cli/src/utils.rs):
    --   * macOS (>= 0.1.2): prefix == root, so the tree is flat directly
    --     under {install_path} (bin/, lib/, include/, Cellar/, ...). macOS
    --     keeps prefix == root to stay within the Mach-O 13-char path limit.
    --   * Linux (all versions): prefix == {install_path}/prefix.
    -- Detect the nested layout when present and fall back to zerobrew's
    -- OS default otherwise, so both platforms (and legacy macOS 0.1.1, which
    -- also nested under prefix/) resolve correctly.
    local base_path = install_path
    local prefix_path = file.join_path(install_path, "prefix")
    if PLUGIN.dir_exists(file.join_path(prefix_path, "bin")) then
        base_path = prefix_path
    elseif not PLUGIN.dir_exists(file.join_path(install_path, "bin")) and RUNTIME.osType == "Linux" then
        -- Not yet materialized; honor zerobrew's Linux default.
        base_path = prefix_path
    end

    local bin_path = file.join_path(base_path, "bin")

    local env_vars = {
        { key = "PATH", value = bin_path },
    }

    -- Add lib paths for tools that need dynamic libraries
    local lib_path = file.join_path(base_path, "lib")

    if RUNTIME.osType == "Darwin" then
        table.insert(env_vars, { key = "DYLD_LIBRARY_PATH", value = lib_path })
    elseif RUNTIME.osType == "Linux" then
        table.insert(env_vars, { key = "LD_LIBRARY_PATH", value = lib_path })
    end

    -- Add include path for development headers
    local include_path = file.join_path(base_path, "include")
    table.insert(env_vars, { key = "C_INCLUDE_PATH", value = include_path })
    table.insert(env_vars, { key = "CPLUS_INCLUDE_PATH", value = include_path })

    -- Add pkg-config path
    local pkgconfig_path = file.join_path(base_path, "lib", "pkgconfig")
    table.insert(env_vars, { key = "PKG_CONFIG_PATH", value = pkgconfig_path })

    return {
        env_vars = env_vars,
    }
end

-- Returns true if `path` exists and is a directory.
-- Uses `test -d` so it stays portable across the mise/vfox Lua runtime,
-- which does not expose a filesystem-stat helper.
function PLUGIN.dir_exists(path)
    local cmd = require("cmd")
    local quoted = "'" .. path:gsub("'", "'\\''") .. "'"
    local out = cmd.exec("test -d " .. quoted .. " && echo yes || true")
    return out ~= nil and out:find("yes") ~= nil
end
