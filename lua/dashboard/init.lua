local state = require('dashboard.state')
local ui = require('dashboard.ui')

local M = {}

---@class mp.dashboard.UserHighlightGroups
---@field public header? string
---@field public icon? string
---@field public directory? string
---@field public hotkey? string

---@class mp.dashboard.UserConfig
---@field public header? string[]
---@field public date_format? string
---@field public directories? (string | fun(): string[])[]
---@field public footer? (string | fun(): string?)[]
---@field public on_load? fun(path: string)
---@field public highlight_groups? mp.dashboard.UserHighlightGroups

---@param opts? mp.dashboard.UserConfig
function M.setup(opts)
    ---@type mp.dashboard.Config
    local default_config = {
        header = {},
        date_format = nil,
        directories = {},
        footer = {},
        on_load = function()
            -- Do nothing
        end,
        highlight_groups = {
            header = 'Constant',
            icon = 'Type',
            directory = 'Delimiter',
            hotkey = 'Statement',
        },
    }
    state.config = vim.tbl_deep_extend('force', default_config, opts or {})
end

function M.instance()
    local bufnr = ui.create_buffer()
    ui.load(bufnr)
    vim.api.nvim_create_autocmd('VimResized', {
        buffer = bufnr,
        callback = function()
            ui.load(bufnr)
        end,
    })
end

return M
