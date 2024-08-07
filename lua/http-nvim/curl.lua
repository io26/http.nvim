local fs = require("http-nvim.fs")
local M = {}

local cmd_file = fs.file_prefix .. "cmd.sh"
local headers_file = fs.file_prefix .. "headers"
local body_file = fs.file_prefix .. "body"

local file_types = {
    ["application/json"] = "json",
    ["application/xml"] = "xml",
    ["application/pdf"] = "pdf",

    ["text/html"] = "html",
    ["text/csv"] = "csv",

    ["image/jpeg"] = "jpeg",
    ["image/png"] = "png",
}

local indent = "\n    "

M.get_cmd_file = function(request)
    local cmd = "curl -s -X " .. request.method .. " '" .. request.url .. "'"

    cmd = cmd .. " \\" .. indent .. "-D " .. headers_file
    cmd = cmd .. " \\" .. indent .. "-o " .. body_file

    for name, value in pairs(request.headers) do
        cmd = cmd .. " \\" .. indent .. "-H '" .. name .. ": " .. value .. "'"
    end

    if #request.json_body > 0 then
        local body = vim.split(request.json_body, "\n")
        local json_body = table.concat(body, indent)

        cmd = cmd .. " \\" .. indent .. "--data-raw '" .. indent .. json_body .. "'"
    end

    for name, value in pairs(request.form_data) do
        cmd = cmd .. " \\" .. indent .. "-d '" .. name .. "=" .. value .. "'"
    end

    fs.write_file(cmd_file, cmd)
    return cmd_file
end

local function get_headers()
    local headers = {}
    local proto = ""
    local status = ""

    local file = fs.read_file(headers_file)
    if file == nil then
        return headers, proto, status
    end

    local lines = vim.split(file, "\n")
    for i, line in ipairs(lines) do
        if i == 1 then
            line = vim.trim(line)

            proto, status = line:match("(.+)%s(.+)")
            if not proto then
                proto = "HTTP"
                status = "?"
            end
        elseif #line > 0 then
            local name, value = line:match("(.+):%s(.+)")
            if name then
                headers[name] = vim.trim(value)
            end
        end
    end

    return headers, proto, status
end

M.exec = function(request, callback)
    local file = M.get_cmd_file(request)

    local start = vim.loop.hrtime()
    vim.system({"sh", file}, { text = true }, function(obj)
        local elapsed = vim.loop.hrtime() - start

        local response = {
            code = obj.code,
            elapsed_ms = string.format("%.2fms", elapsed / 1e6),
            cmd_file = file,
        }

        if response.code == 0 then
            response.headers_file = headers_file
            response.headers, response.proto, response.status = get_headers()

            response.body_file = body_file
            response.body_ft = file_types[response.headers["content-type"]]

            if response.body_ft then
                response.body_file = body_file .. '.' .. response.body_ft
                fs.rename(body_file, response.body_file)
            end
        end

        if callback then
            vim.schedule(function()
                callback(response)
            end)
        end
    end)
end

return M
