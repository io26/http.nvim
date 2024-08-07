local fs = require("http-nvim.fs")
local M = {}

local formatters = {
    json = { "jq", "." },
    xml = { "xmllint", "--format", "-" },
    html = { "xmllint", "--format", "--html", "-" },
}

M.format_file = function(file, type)
    local cmd = formatters[type]
    if cmd == nil or not fs.command_exists(cmd[1]) then
        return
    end

    local contents = fs.read_file(file)
    if contents == nil then
        return
    end

    contents = vim.system(cmd, { stdin = contents, text = true }):wait().stdout

    fs.write_file(file, contents)
end

return M
