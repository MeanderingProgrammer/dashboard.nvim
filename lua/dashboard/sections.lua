local M = {}

---@return string
function M.version()
    local version = vim.version()
    local versions = { version.major, version.minor, version.patch }
    return 'neovim ' .. table.concat(versions, '.')
end

---@return string?
function M.startuptime()
    local status, lazy = pcall(require, 'lazy')
    if status then
        return 'Startup Time ' .. lazy.stats().startuptime .. ' ms'
    else
        return nil
    end
end

return M
