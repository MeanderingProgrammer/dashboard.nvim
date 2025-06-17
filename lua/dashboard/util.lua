---@class mp.dash.Util
local M = {}

---@param buf integer
---@return boolean
function M.empty(buf)
    if vim.api.nvim_buf_line_count(buf) > 1 then
        return false
    end
    local line = vim.api.nvim_buf_get_lines(buf, 0, -1, false)[1]
    return not line or #line == 0
end

---@param s string
---@return integer
function M.len(s)
    return vim.fn.strdisplaywidth(s)
end

---@param outer integer
---@param inner integer
---@return integer
function M.center(outer, inner)
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
function M.icon(path)
    if M.is_directory(path .. '/.git') then
        return ' '
    else
        return ' '
    end
end

return M
