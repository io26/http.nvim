local fs = require("http-nvim.fs")
local M = {}

M.get_env = function()
    local env_file = fs.find_file_in_parent_dirs("http-client.env.json")
    if not env_file then
        return {}
    end

    local env = vim.fn.json_decode(vim.fn.readfile(env_file))
    if not env then
        vim.notify("http-client.env.json is not a valid json file", vim.log.levels.ERROR)
        return {}
    end
    return env
end

M.get_vars = function(env_name)
    local env = M.get_env()
    local vars = env[env_name]
    if not vars then
        vim.notify("No variables found for env: " .. env_name, vim.log.levels.WARN)
        return {}
    end
    return vars
end

return M
