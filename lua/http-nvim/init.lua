local env = require("http-nvim.env")
local expr = require("http-nvim.expr")
local http = require("http-nvim.http")
local curl = require("http-nvim.curl")
local ui = require("http-nvim.ui")
local fmt = require("http-nvim.fmt")
local M = {}

local curl_response = {}
local selected_env_name = "dev"
local result_file = nil

local function get_request_under_cursor()
    local vars = vim.tbl_extend("force",
        env.get_vars(selected_env_name),
        http.get_vars())
    vars = expr.eval_vars(vars)

    local request = http.get_request_under_cursor()
    return expr.eval_tbl(request, vars)
end

M.run = function()
    local request = get_request_under_cursor()

    curl.exec(request, function(response)
        curl_response = response

        ui.show_status(response)

        if response.code == 0 then
            fmt.format_file(response.body_file, response.body_ft)
            result_file = ui.get_result_file(request, response)
            M.show_result()
        end
    end)
end

M.show_result = function()
    ui.show_file(result_file)
end

M.show_cmd = function()
    local request = get_request_under_cursor()
    local cmd_file = curl.get_cmd_file(request)
    ui.show_file(cmd_file)
end

M.show_body = function()
    ui.show_file(curl_response.body_file)
end

M.show_headers = function()
    ui.show_file(curl_response.headers_file)
end

M.select_env_name = function(env_name)
    if env_name then
        selected_env_name = env_name
    else
        local env_names = vim.tbl_keys(env.get_env())
        table.sort(env_names)

        ui.select(env_names, 'Select env name:', function(choice)
            selected_env_name = choice
        end)
    end
end

return M
