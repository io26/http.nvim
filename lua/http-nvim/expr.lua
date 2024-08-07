local M = {}

local function has_var(str)
    return string.match(str, "{{(.-)}}")
end

M.eval_str = function(str, vars)
    local function eval(variable_name)
        local value = ""
        if vars[variable_name] then
            value = vars[variable_name]
        else
            value = "{{" .. variable_name .. "}}"
        end
        if type(value) == "string" then
            -- no need to keep " for strings
            value = value:gsub('"', "")
        end
        return value
    end
    local result = str:gsub("{{(.-)}}", eval)
    return result
end

M.eval_vars = function(vars)
    local simple_vars = {}
    local complex_vars = {}

    -- split into simple/complex vars
    for name, value in pairs(vars) do
        if has_var(value) then
            complex_vars[name] = value
        else
            simple_vars[name] = value
        end
    end

    -- try to eval complex into simple vars
    while true do
        local has_changes = false

        for name, value in pairs(complex_vars) do
            local new_value = M.eval_str(value, simple_vars)
            if new_value ~= value then
                has_changes = true
            end

            if has_var(new_value) then
                complex_vars[name] = new_value
            else
                simple_vars[name] = new_value
                complex_vars[name] = nil
            end
        end

        if not next(complex_vars) or not has_changes then
            break
        end
    end

    -- append unevaluated complex vars
    for name, value in pairs(complex_vars) do
        simple_vars[name] = value
    end

    return simple_vars
end

M.eval_tbl = function(tbl, vars)
    for name, value in pairs(tbl) do
        if type(value) == "table" then
            tbl[name] = M.eval_tbl(value, vars)
        elseif type(value) == "string" then
            tbl[name] = M.eval_str(value, vars)
        end
    end
    return tbl
end

return M
