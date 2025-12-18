local M = {}
function M.get_char_after_cursor()
  local col = vim.fn.col('.')
  local line = vim.fn.getline('.')
  return line:sub(col, col)
end

function M.get_char_before_cursor()
  local col = vim.fn.col('.') - 1
  local line = vim.fn.getline('.')
  return line:sub(col, col)
end

return M
