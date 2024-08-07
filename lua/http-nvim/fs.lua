local M = {
    file_prefix = "/tmp/http-nvim_"
}

function M.write_file(filename, str)
    local file = io.open(filename, "w")
    if file then
        file:write(str)
        file:close()
        return true
    end
    return false
end

function M.read_file(filename)
    local f = io.open(filename, 'r')
    if f == nil then
        return nil
    end
    local content = f:read('*a')
    f:close()
    return content
end

function M.rename(from, to)
    os.rename(from, to)
end

M.command_exists = function(cmd)
    return vim.fn.executable(cmd) == 1
end

-- find nearest file in parent directories, starting from the current buffer file path
-- @param filename: string
-- @return string|nil
-- @usage local p = fs.find_file_in_parent_dirs('Makefile')
M.find_file_in_parent_dirs = function(filename)
    local dir = vim.fn.expand('%:p:h')
    -- make sure we don't go into an infinite loop
    -- if the file is in the root directory of windows or unix
    -- we should stop at the root directory
    -- for linux, the root directory is '/'
    -- for windows, the root directory is '[SOME_LETTER]:\'
    while dir ~= '/' and dir:match('[A-Z]:\\') == nil do
        local parent = dir .. '/' .. filename
        if vim.fn.filereadable(parent) == 1 then
            return parent
        end
        dir = vim.fn.fnamemodify(dir, ':h')
    end
    return nil
end

return M
