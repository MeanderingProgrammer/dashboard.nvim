local ui = require('dashboard.ui')

local M = {}

---@class (exact) mp.dash.Config: mp.dash.parser.Config, mp.dash.ui.Config

---@type mp.dash.Config
M.default = {
    autokeys = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890',
    header = {},
    date_format = nil,
    directories = {},
    footer = {},
    bo = {
        bufhidden = 'wipe',
        buflisted = false,
        filetype = 'dashboard',
        swapfile = false,
    },
    wo = {
        cursorcolumn = false,
        cursorline = false,
        number = false,
        relativenumber = false,
        spell = false,
        statuscolumn = '',
        wrap = false,
    },
    on_load = function()
        -- do nothing
    end,
    highlight_groups = {
        header = 'Constant',
        icon = 'Type',
        directory = 'Delimiter',
        hotkey = 'Statement',
    },
}

---@param opts? mp.dash.UserConfig
function M.setup(opts)
    local config = vim.tbl_deep_extend('force', M.default, opts or {})
    require('dashboard.parser').setup({
        autokeys = config.autokeys,
        header = config.header,
        date_format = config.date_format,
        directories = config.directories,
        footer = config.footer,
    })
    require('dashboard.ui').setup({
        bo = config.bo,
        wo = config.wo,
        on_load = config.on_load,
        highlight_groups = config.highlight_groups,
    })
end

function M.instance()
    local dash = ui.new()
    dash:load()
    vim.api.nvim_create_autocmd({ 'VimResized', 'WinResized' }, {
        buffer = dash.buf,
        callback = function()
            dash:load()
        end,
    })
end

return M
