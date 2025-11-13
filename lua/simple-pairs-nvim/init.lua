local M = {}

-- Default configuration
M.config = {
  ignored = {
    ts_nodes = {
      'string',
      'comment',
    },
    filetypes = {},
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

-- Allow user configuration
function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})
  M._setup_mappings()
end

-- Helpers
local function get_char_after_cursor()
  local col = vim.fn.col('.')
  local line = vim.fn.getline('.')
  return line:sub(col, col)
end

local function get_char_before_cursor()
  local col = vim.fn.col('.') - 1
  local line = vim.fn.getline('.')
  return line:sub(col, col)
end

local function in_ignored_node()
  local captures_at_cursor = vim.treesitter.get_captures_at_cursor()

  for _, capture in ipairs(M.config.ignored.ts_nodes) do
    if vim.list_contains(captures_at_cursor, capture) then
      return true
    end
  end

  return false
end

-- Insert or skip pairs
function M.handle_open(open)
  local close = M.config.pairs[open]
  if not close then
    return open
  end

  -- Skip inside string or if next char same as close
  if in_ignored_node() or get_char_after_cursor() == open then
    return open
  end

  return open .. close .. '<Left>'
end

function M.handle_open_close(char)
  -- Skip inside string or if next char same as close
  if in_ignored_node() then
    return char
  end

  if get_char_after_cursor() == char then
    return '<Right>'
  end

  return char .. char .. '<Left>'
end

-- When typing a closing character
function M.handle_close(close)
  local next_char = get_char_after_cursor()
  if next_char ~= close or in_ignored_node() then
    return close
  else
    -- Just jump over it instead of inserting another
    return '<Right>'
  end
end

-- Handle backspace (delete both sides if empty pair)
function M.handle_backspace()
  local before = get_char_before_cursor()
  local after = get_char_after_cursor()

  if M.config.pairs[before] == after then
    return '<Right><BS><BS>'
  end

  return '<BS>'
end

-- Handle Enter inside empty pair
function M.handle_cr()
  local before = get_char_before_cursor()
  local after = get_char_after_cursor()
  if M.config.pairs[before] == after then
    return '<CR><Esc>O'
  end
  return '<CR>'
end

local function inoremap(func, key)
  vim.keymap.set('i', key, function()
    if vim.list_contains(M.config.ignored.filetypes, vim.bo.filetype) then
      return key
    end
    return func(key)
  end, { expr = true, noremap = true })
end

-- Setup all keymaps
function M._setup_mappings()
  -- opening pairs
  for open, close in pairs(M.config.pairs) do
    if close then
      if open == close then
        inoremap(M.handle_open_close, open)
      else
        inoremap(M.handle_open, open)
        inoremap(M.handle_close, close)
      end
    end
  end

  inoremap(M.handle_backspace, '<BS>')
  inoremap(M.handle_cr, '<CR>')
end

return M
