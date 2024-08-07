local M = {}

local function get_document_node()
    return vim.treesitter.get_node({pos = {0, 0}}):tree():root()
end

local function get_child_nodes(node, type, named)
    if named then
        return node:field(type)
    else
        local nodes = {}
        for child, _ in node:iter_children() do
            if child:type() == type then
                table.insert(nodes, child)
            end
        end
        return nodes
    end
end

local function get_node_text(node)
    return vim.treesitter.get_node_text(node, 0)
end

local function get_child_node_text(node, type, named)
    local text = ""
    for _, child_node in ipairs(get_child_nodes(node, type, named)) do
        text = text .. get_node_text(child_node)
    end
    return vim.trim(text)
end

local function get_headers(request_node)
    local headers = {}
    for _, header_node in ipairs(get_child_nodes(request_node, "header")) do
        local name = get_child_node_text(header_node, "name", true)
        local value = get_child_node_text(header_node, "value", true)
        headers[name] = value
    end
    return headers
end

local function get_form_data(request_node)
    local form_data = {}
    for _, form_data_node in ipairs(get_child_nodes(request_node, "form_data")) do
        local name_nodes = get_child_nodes(form_data_node, "name", true)
        local value_nodes = get_child_nodes(form_data_node, "value", true)

        for i, _ in ipairs(name_nodes) do
            local name = get_node_text(name_nodes[i])
            local value = get_node_text(value_nodes[i])
            form_data[name] = value
        end
    end
    return form_data
end

M.get_request_under_cursor = function()
    local document_node = get_document_node()

    local request_nodes = get_child_nodes(document_node, "request")
    if not next(request_nodes) then
        error("Failed to find 'request' treesitter node under cursor")
    end

    local cursor_row = unpack(vim.api.nvim_win_get_cursor(0)) - 1

    local request_node = request_nodes[1]
    for _, node in ipairs(request_nodes) do
        local node_row = node:start()
        if node_row > cursor_row then
            break
        end
        request_node = node
    end

    return {
        method = get_child_node_text(request_node, "method"),
        url = get_child_node_text(request_node, "target_url"),
        headers = get_headers(request_node),
        json_body = get_child_node_text(request_node, "json_body"),
        form_data = get_form_data(request_node),
    }
end

M.get_vars = function()
    local vars = {}

    local var_nodes = get_child_nodes(get_document_node(), "variable_declaration")
    for _, var_node in pairs(var_nodes) do
        local name = get_child_node_text(var_node, "name", true)
        local value = get_child_node_text(var_node, "value", true)
        vars[name] = value
    end

    return vars
end

return M
