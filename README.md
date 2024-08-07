# http.nvim

Yet another [http](https://www.jetbrains.com/help/idea/exploring-http-syntax.html) curl wrapper. Why? Simplicity is the way :)

## Features

- Run http request under cursor
- Read and substitute variables
- [http-client.env.json](https://www.jetbrains.com/help/idea/exploring-http-syntax.html#http-client-env-json) support
- Formatting with `jq`, `xmllint` 
- Curl command, headers, body could be found in /tmp
- Result is shown as a markdown file

## Install

### Dependencies

- Mandatory
    - linux / wsl2
    - curl
    - [tree-sitter](https://github.com/tree-sitter/tree-sitter)
        - `:TSInstall http` ([tree-sitter-http](https://github.com/rest-nvim/tree-sitter-http))
- Optional
    - `jq`
    - `xmllint`

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "io26/http.nvim",
    config = function()
        local map = vim.keymap.set
        map("n", "<leader>rr", require("http-nvim").run)
        map("n", "<leader>re", require("http-nvim").select_env_name)
        map("n", "<leader>ro", require("http-nvim").show_result)
        map("n", "<leader>rc", require("http-nvim").show_cmd)
        map("n", "<leader>rb", require("http-nvim").show_body)
        map("n", "<leader>rh", require("http-nvim").show_headers)
    end
}
```
# Inspired by

- [rest.nvim](https://github.com/rest-nvim/rest.nvim)
- [kulala.nvim](https://github.com/mistweaverco/kulala.nvim)
