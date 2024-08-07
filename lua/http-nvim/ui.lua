local fs = require("http-nvim.fs")
local M = {}

local result_file = fs.file_prefix .. "result.md"

local binary_ft = {
    "pdf",
    "jpeg",
    "png",
}

M.show_status = function(resp)
    local result = "completed"
    local log_level = vim.log.levels.INFO

    if resp.code ~= 0 then
        result = "failed with code " .. tostring(resp.code)
        log_level = vim.log.levels.ERROR
    end

    vim.notify("http-nvim: " .. result .. " in " .. resp.elapsed_ms, log_level)
end

M.show_file = function(file)
    if file then
        vim.cmd("e " .. file)
        vim.cmd("set nomodifiable")
    end
end

M.select = function(items, prompt, on_choice)
    vim.ui.select(items, { prompt = prompt }, on_choice)
end

M.get_result_file = function(req, resp)
    local result = ""

    result = result .. "[**" .. req.method .. "** " .. req.url .. "](" .. resp.cmd_file .. ") "
    result = result .. resp.elapsed_ms .. "\n\n"

    result = result .. "# [headers](" .. resp.headers_file .. ")\n"
    result = result .. "```ini\n"
    result = result .. "[" .. resp.proto .. " " .. resp.status .. "]\n"
    for name, value in pairs(resp.headers) do
        result = result .. name .. " = " .. value .. "\n"
    end
    result = result .. "```\n"

    if vim.tbl_contains(binary_ft, resp.body_ft) then
        result = result .. "# [body](" .. resp.body_file .. ")\n"
        result = result .. "\nBINARY DATA\n"
    else
        local body = fs.read_file(resp.body_file)
        if body and #body > 0 then
            result = result .. "# [body](" .. resp.body_file .. ")\n"
            result = result .. "```" .. (resp.body_ft and resp.body_ft or "") .. "\n"
            result = result .. body
            result = result .. "\n```"
        end
    end

    fs.write_file(result_file, result)
    return result_file
end

return M

