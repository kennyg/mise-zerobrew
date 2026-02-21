-- hooks/backend_list_versions.lua
-- Lists available versions for a Homebrew formula
-- Queries Homebrew's API and finds versioned formulae (e.g., python@3.11)

function PLUGIN:BackendListVersions(ctx)
    local tool = ctx.tool

    if not tool or tool == "" then
        error("Tool name cannot be empty")
    end

    local http = require("http")
    local json = require("json")

    -- Fetch formula list from Homebrew API
    local api_url = "https://formulae.brew.sh/api/formula.json"

    local resp, err = http.get({ url = api_url })

    if err then
        error("Failed to fetch Homebrew formula list: " .. err)
    end

    if resp.status_code ~= 200 then
        error("Homebrew API returned status " .. resp.status_code)
    end

    local formulae = json.decode(resp.body)
    local versions = {}
    local has_base_formula = false

    -- Normalize tool name (strip any existing version suffix for searching)
    local base_tool = tool:match("^([^@]+)") or tool

    -- Search for versioned formulae matching the base tool name
    for _, formula in ipairs(formulae) do
        local name = formula.name

        -- Check if this is the base formula (exact match)
        if name == base_tool then
            has_base_formula = true
        end

        -- Check if this is a versioned variant (e.g., python@3.11)
        local formula_base, version = name:match("^([^@]+)@(.+)$")
        if formula_base == base_tool then
            table.insert(versions, version)
        end
    end

    -- Add "latest" pseudo-version if base formula exists
    if has_base_formula then
        table.insert(versions, "latest")
    end

    -- Sort versions semantically (3.9 < 3.10 < 3.11, not lexicographically)
    table.sort(versions, function(a, b)
        -- Keep "latest" at the end
        if a == "latest" then
            return false
        end
        if b == "latest" then
            return true
        end

        -- Split versions into numeric parts for proper comparison
        local function parse_version(v)
            local parts = {}
            for part in v:gmatch("([^%.]+)") do
                table.insert(parts, tonumber(part) or part)
            end
            return parts
        end

        local pa, pb = parse_version(a), parse_version(b)
        for i = 1, math.max(#pa, #pb) do
            local va, vb = pa[i] or 0, pb[i] or 0
            if type(va) == "number" and type(vb) == "number" then
                if va ~= vb then
                    return va < vb
                end
            else
                if tostring(va) ~= tostring(vb) then
                    return tostring(va) < tostring(vb)
                end
            end
        end
        return false
    end)

    if #versions == 0 then
        -- No versioned formulae found - check if the tool itself exists
        for _, formula in ipairs(formulae) do
            if formula.name == tool then
                -- Tool exists but has no versions, return just "latest"
                return { versions = { "latest" } }
            end
        end
        error("Formula '" .. tool .. "' not found in Homebrew")
    end

    return { versions = versions }
end
