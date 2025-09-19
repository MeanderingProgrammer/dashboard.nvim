local parser = require('dashboard.parser')
local util = require('dashboard.util')

---@class (exact) mp.dash.ui.Config
---@field bo table<string, any>
---@field wo table<string, any>
---@field on_load fun(path: string)
---@field highlight_groups mp.dash.ui.highlight.Config

---@class (exact) mp.dash.ui.highlight.Config
---@field header string
---@field icon string
---@field directory string
---@field hotkey string

---@class mp.dash.ui.row.Hl: mp.dash.ui.col.Hl
---@field row integer

---@class mp.dash.ui.col.Hl
---@field col integer
---@field len integer
---@field name string

---@class mp.dash.Ui
---@field private config mp.dash.ui.Config
local M = {}

---@private
M.ns = vim.api.nvim_create_namespace('Dashboard')

---called from init on setup
---@param config mp.dash.ui.Config
function M.setup(config)
    M.config = config
end

---@class mp.dash.Width
---@field header integer
---@field values integer

---@class mp.dash.View
---@field height integer
---@field width integer

---@class mp.dash.Dash
---@field buf integer
---@field win integer
---@field private header string[]
---@field private values mp.dash.Value[]
---@field private footer string[]
---@field private width mp.dash.Width
---@field private lines string[]
---@field private hls mp.dash.ui.row.Hl[]
---@field private view mp.dash.View
local Dash = {}
Dash.__index = Dash

---@return mp.dash.Dash
function Dash.new()
    local self = setmetatable({}, Dash)

    self.buf = vim.api.nvim_get_current_buf()
    self.win = vim.api.nvim_get_current_win()
    if not util.empty(self.buf) then
        self.buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_win_set_buf(self.win, self.buf)
    end

    for name, value in pairs(M.config.bo) do
        vim.api.nvim_set_option_value(name, value, {
            scope = 'local',
            buf = self.buf,
        })
    end
    for name, value in pairs(M.config.wo) do
        vim.api.nvim_set_option_value(name, value, {
            scope = 'local',
            win = self.win,
        })
    end

    self.header = parser.header()
    self.values = parser.values()
    self.footer = parser.footer()

    self.width = { header = 0, values = 0 }
    for _, header in ipairs(self.header) do
        local width = util.len(header)
        self.width.header = math.max(self.width.header, width)
    end
    for _, value in ipairs(self.values) do
        -- format: <icon><s><path><s><fill><s>[<key>]
        -- space : <icon><1><path><1><    ><1>1<1  >1
        --       : icon + path + 6
        local icon, path = value.icon, value.path
        local width = util.len(icon) + util.len(path) + 6
        self.width.values = math.max(self.width.values, width)
    end

    for _, value in ipairs(self.values) do
        local path = vim.fs.normalize(value.path)
        vim.keymap.set('n', value.key, function()
            vim.cmd('lcd ' .. path)
            vim.cmd('e .')
            M.config.on_load(path)
        end, { buffer = self.buf })
    end

    return self
end

function Dash:load()
    vim.bo[self.buf].modifiable = true

    self.lines = {}
    self.hls = {}
    self.view = {
        height = vim.api.nvim_win_get_height(self.win),
        width = vim.api.nvim_win_get_width(self.win),
    }
    self:populate()
    vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, self.lines)
    for _, hl in ipairs(self.hls) do
        vim.api.nvim_buf_set_extmark(self.buf, M.ns, hl.row, hl.col, {
            end_col = hl.col + hl.len,
            hl_group = hl.name,
        })
    end

    vim.bo[self.buf].modifiable = false
    vim.bo[self.buf].modified = false
end

---@private
function Dash:populate()
    local height = #self.header + (2 * #self.values) + #self.footer

    for _ = 1, util.center(self.view.height, height) do
        self.lines[#self.lines + 1] = ''
    end
    for _, header in ipairs(self.header) do
        self:line(header)
    end
    for _, value in ipairs(self.values) do
        self:value(value)
        self.lines[#self.lines + 1] = ''
    end
    for _, footer in ipairs(self.footer) do
        self:line(footer)
    end
end

---@private
---@param line string
function Dash:line(line)
    local groups = M.config.highlight_groups
    self:center(line, {
        { col = 0, len = #line, name = groups.header },
    })
end

---@private
---@param value mp.dash.Value
function Dash:value(value)
    local limit = math.min(self.view.width, self.width.header)
    local width = math.max(self.width.values, limit)

    local l = ('%s %s'):format(value.icon, value.path)
    local r = ('[%s]'):format(value.key)
    local line = ('%s %s %s'):format(
        l,
        ('.'):rep(width - util.len(l) - util.len(r) - 2),
        r
    )
    local groups = M.config.highlight_groups
    self:center(line, {
        { col = 0, len = #value.icon, name = groups.icon },
        { col = #value.icon + 1, len = #value.path, name = groups.directory },
        { col = #line - #r, len = #r, name = groups.hotkey },
    })
end

---@private
---@param line string
---@param hls mp.dash.ui.col.Hl[]
function Dash:center(line, hls)
    local padding = util.center(self.view.width, util.len(line))
    for _, hl in ipairs(hls) do
        ---@cast hl mp.dash.ui.row.Hl
        hl.row = #self.lines
        hl.col = hl.col + padding
        self.hls[#self.hls + 1] = hl
    end
    self.lines[#self.lines + 1] = (' '):rep(padding) .. line
end

M.new = Dash.new

return M
