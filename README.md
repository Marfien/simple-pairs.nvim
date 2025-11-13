# simple-pairs.nvim

A minimal, fast, and extensible Neovim plugin for automatic insertion and management of paired characters (brackets, quotes, etc.) in insert mode. Written in Lua.

## Features

- Automatically inserts closing pairs when typing opening characters.
- Skips insertion inside Treesitter nodes (by default `commend` and `string`)
- Smart handling of quotes and backticks.
- Jump over closing pairs if already present.
- Deletes both sides of an empty pair with backspace.
- Inserts new lines inside empty pairs with proper indentation.
- Easily configurable and extensible.

## Installation

Use your favorite plugin manager. Example with [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "Marfien/simple-pairs.nvim",
  event = "InsertEnter",
  config = function()
    require("simple-pairs-nvim").setup()
  end
}
```

## Configuration

You can override the default configuration in your setup:

```lua
require("simple-pairs-nvim").setup({
  ignored = {
    ts_nodes = { "string", "comment" }, -- Treesitter nodes to ignore
    filetypes = { },
  },
  pairs = {
    ["("] = ")",
    ["["] = "]",
    ["{"] = "}",
    ['"'] = '"',
    ["'"] = "'",
    ["`"] = "`",
  },
})
```

## How it works

- Uses Treesitter to avoid inserting pairs inside strings and comments.
- Handles opening and closing pairs, quotes, backspace, and enter.
- Keymaps are set in insert mode for all configured pairs.

## License

MIT
