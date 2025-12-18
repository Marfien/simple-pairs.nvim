local M = {}

local config = require('simple-pairs-nvim.config')
local helpers = require('simple-pairs-nvim.helpers')

-- Allow user configuration
---@param opts simple-pairs-nvim.Options
function M.setup(opts)
  config.normalize_override(opts)
  M._setup_mappings()
end

---@param ignored string[]
local function is_in_ignored_node(ignored)
  local captures_at_cursor = vim.treesitter.get_captures_at_cursor()

  for _, capture in ipairs(ignored) do
    if vim.list_contains(captures_at_cursor, capture) then
      return true
    end
  end

  return false
end

---@param ignore_opts simple-pairs-nvim.MappingIgnoreConfig
local function is_ignored_filetype(ignore_opts)
  return vim.list_contains(ignore_opts.filetypes, vim.bo.filetype)
end

---@param ignore_opts simple-pairs-nvim.MappingIgnoreConfig
local function should_ignore(ignore_opts)
  return is_in_ignored_node(ignore_opts.ts_nodes) or is_ignored_filetype(ignore_opts)
end

-- Insert or skip pairs
---@param char string open char
---@param pair_opts simple-pairs-nvim.MappingConfig
function M.handle_open(char, pair_opts)
  if should_ignore(pair_opts.ignored) or helpers.get_char_after_cursor() == char then
    return char
  end

  return char .. pair_opts.closing .. '<Left>'
end

---@param char string
---@param pair_opts simple-pairs-nvim.MappingConfig
function M.handle_open_close(char, pair_opts)
  if helpers.get_char_after_cursor() == char then
    return '<Right>'
  end

  -- Skip inside string or if next char same as close
  if should_ignore(pair_opts.ignored) or helpers.get_char_before_cursor() == char then
    return char
  end

  return char .. char .. '<Left>'
end

-- When typing a closing character
---@param char string
function M.handle_close(char)
  return helpers.get_char_after_cursor() == char and '<Right>' or char
end

-- Handle backspace (delete both sides if empty pair)
function M.handle_backspace()
  local before = helpers.get_char_before_cursor()
  local pair_opts = config.config.pairs[before]

  if not pair_opts or is_ignored_filetype(pair_opts.ignored) then
    return '<BS>'
  end

  vim.notify(pair_opts.closing)
  local after = helpers.get_char_after_cursor()
  return pair_opts.closing == after and '<Right><BS><BS>' or '<BS>'
end

-- Handle Enter inside empty pair
function M.handle_cr()
  local before = helpers.get_char_before_cursor()
  local pair_opts = config.config.pairs[before]

  if not pair_opts or is_ignored_filetype(pair_opts.ignored) then
    return '<CR>'
  end

  local after = helpers.get_char_after_cursor()
  return pair_opts.closing == after and '<CR><Esc>O' or '<CR>'
end

local function inoremap(func, key, pair_opts)
  vim.keymap.set('i', key, function()
    return func(key, pair_opts)
  end, { expr = true, noremap = true })
end

-- Setup all keymaps
function M._setup_mappings()
  -- opening pairs
  for open, pair_opts in pairs(config.config.pairs) do
    if open == pair_opts.closing then
      inoremap(M.handle_open_close, open, pair_opts)
    else
      inoremap(M.handle_open, open, pair_opts)
      inoremap(M.handle_close, pair_opts.closing, pair_opts)
    end
  end

  inoremap(M.handle_backspace, '<BS>', nil)
  inoremap(M.handle_cr, '<CR>', nil)
end

return M
