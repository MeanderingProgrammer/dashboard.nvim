local ui = require('dashboard.ui')

local M = {}

---@class (exact) mp.dash.Config: mp.dash.parser.Config, mp.dash.ui.Config

---@type mp.dash.Config
M.default = {
    header = {},
    date_format = nil,
    directories = {},
    footer = {},
    options = {
        bufhidden = 'wipe',
        buflisted = false,
        cursorcolumn = false,
        cursorline = false,
        filetype = 'dashboard',
        number = false,
        relativenumber = false,
        spell = false,
        statuscolumn = '',
        swapfile = false,
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
        header = config.header,
        date_format = config.date_format,
        directories = config.directories,
        footer = config.footer,
    })
    require('dashboard.ui').setup({
        options = config.options,
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
