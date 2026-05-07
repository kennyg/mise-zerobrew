-- hooks/backend_exec_env.lua
-- Sets up environment variables for zerobrew-installed tools

function PLUGIN:BackendExecEnv(ctx)
    local install_path = ctx.install_path

    local file = require("file")

    -- zerobrew installs directly under {install_path} (bin/, lib/, include/, ...)
    local bin_path = file.join_path(install_path, "bin")

    local env_vars = {
        { key = "PATH", value = bin_path },
    }

    local lib_path = file.join_path(install_path, "lib")

    if RUNTIME.osType == "Darwin" then
        table.insert(env_vars, { key = "DYLD_LIBRARY_PATH", value = lib_path })
    elseif RUNTIME.osType == "Linux" then
        table.insert(env_vars, { key = "LD_LIBRARY_PATH", value = lib_path })
    end

    local include_path = file.join_path(install_path, "include")
    table.insert(env_vars, { key = "C_INCLUDE_PATH", value = include_path })
    table.insert(env_vars, { key = "CPLUS_INCLUDE_PATH", value = include_path })

    local pkgconfig_path = file.join_path(install_path, "lib", "pkgconfig")
    table.insert(env_vars, { key = "PKG_CONFIG_PATH", value = pkgconfig_path })

    return {
        env_vars = env_vars,
    }
end
