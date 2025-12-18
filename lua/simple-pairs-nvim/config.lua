local M = {}

---@class simple-pairs-nvim.MappingIgnoreConfig
---@field ts_nodes string[]
---@field filetypes string[]

---@class simple-pairs-nvim.MappingConfig
---@field closing string|nil
---@field ignored simple-pairs-nvim.MappingIgnoreConfig

---@class simple-pairs-nvim.Config
---@field pairs table<string, simple-pairs-nvim.MappingConfig>

---@class simple-pairs-nvim.Options
---@field default simple-pairs-nvim.MappingConfig
---@field pairs table<string, string|simple-pairs-nvim.MappingConfig|false>

-- Default configuration
---@type simple-pairs-nvim.Options
M.default_config = {
  default = {
    closing = nil,
    ignored = {
      ts_nodes = {
        'string',
        'comment',
      },
      filetypes = {},
    },
  },
  pairs = {
    ['('] = ')',
    ['['] = ']',
    ['{'] = '}',
    ['"'] = '"',
    ["'"] = "'",
    ['`'] = '`',
  },
}

-- Default configuration
---@type simple-pairs-nvim.Config
M.config = {
  pairs = {},
}

---Extends the config with normalized config
---@param opts simple-pairs-nvim.Options
function M.normalize_override(opts)
  opts = vim.tbl_deep_extend('keep', opts, M.default_config)

  for key, value in pairs(opts.pairs) do
    -- streamline config
    if type(value) == 'string' then
      local pair_opts = vim.deepcopy(opts.default, true)
      pair_opts.closing = value
      M.config.pairs[key] = pair_opts
    -- if closing is nil it should default to symetric pairs
    elseif type(value) == 'table' then
      local pair_opts = vim.tbl_deep_extend('keep', value, opts.default)
      pair_opts.closing = pair_opts.closing or key
      M.config.pairs[key] = pair_opts
    end
  end
end

return M
