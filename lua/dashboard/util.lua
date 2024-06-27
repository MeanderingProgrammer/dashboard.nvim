local M = {}

---@param bufnr integer
---@return boolean
function M.is_empty(bufnr)
    local num_lines = vim.api.nvim_buf_line_count(bufnr)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    return num_lines == 1 and lines[1] == ''
end

---@param s string
---@return integer
function M.len(s)
    return vim.fn.strdisplaywidth(s)
end

---@return integer
function M.height()
    return vim.api.nvim_win_get_height(0)
end

---@return integer
function M.width()
    return vim.api.nvim_win_get_width(0)
end

---@param outer integer
---@param inner integer
---@return integer
function M.padding(outer, inner)
    local amount = math.floor((outer - inner) / 2)
    if amount > 0 and inner > 0 then
        return amount
    else
        return 0
    end
end

---@param path string
---@return boolean
function M.is_directory(path)
    local normalized = vim.fs.normalize(path)
    return vim.fn.isdirectory(normalized) == 1
end

---@param path string
---@return string
function M.get_icon(path)
    if M.is_directory(path .. '/.git') then
        return ' '
    else
        return ' '
    end
end

return M
