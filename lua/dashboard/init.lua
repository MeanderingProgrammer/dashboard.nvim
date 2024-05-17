local sections = require('dashboard.sections')
local state = require('dashboard.state')
local util = require('dashboard.util')

---@param lines (string | table)[]
---@return integer
local function get_max_width(lines)
    local lengths = {}
    for _, line in ipairs(lines) do
        if type(line) == 'string' then
            table.insert(lengths, util.len(line))
        elseif type(line) == 'table' and line.dir then
            table.insert(lengths, #line.dir + 6)
        end
    end
    return vim.fn.max(lengths)
end

---@class mp.dashboard.ResolvedHighlight
---@field line integer
---@field name string
---@field start integer
---@field length integer

---@param lines (string | table)[]
---@return string[]
---@return mp.dashboard.ResolvedHighlight[]
local function center(lines)
    local max_width = get_max_width(lines)
    local center_lines = util.get_padded_table(#lines)
    local groups = state.config.highlight_groups
    local highlights = {}
    for _, line in ipairs(lines) do
        if type(line) == 'string' then
            local left_pad = util.pad_left(util.len(line))
            local content = string.format('%s%s', left_pad, line)

            table.insert(center_lines, content)

            table.insert(highlights, {
                line = #center_lines - 1,
                name = groups.header,
                start = #left_pad,
                length = #line,
            })
        elseif type(line) == 'table' then
            local left_pad = util.pad_left(max_width)

            local icon = util.get_icon(line.dir)
            local inner_content = string.format('%s %s', icon, line.dir)

            local hotkey_content = string.format('[%s]', line.key)

            local content = string.format(
                '%s%s%s%s',
                left_pad,
                inner_content,
                (' '):rep(max_width - util.len(inner_content) - #hotkey_content),
                hotkey_content
            )

            table.insert(center_lines, content)

            table.insert(highlights, {
                line = #center_lines - 1,
                name = groups.icon,
                start = #left_pad,
                length = #icon + 1,
            })
            table.insert(highlights, {
                line = #center_lines - 1,
                name = groups.directory,
                start = #left_pad + #icon + 1,
                length = #line.dir,
            })
            table.insert(highlights, {
                line = #center_lines - 1,
                name = groups.hotkey,
                start = #content - #hotkey_content,
                length = #hotkey_content,
            })
        else
            error('Unhandled type: ' .. type(line))
        end
    end
    return center_lines, highlights
end

---@param key string
---@param dir string
local function map_key(key, dir)
    dir = vim.fs.normalize(dir)
    vim.keymap.set('n', key, function()
        vim.cmd('lcd ' .. dir)
        vim.cmd('e .')
        state.config.on_load(dir)
    end, { buffer = true })
end

---@param bufnr integer
local function set_buffer(bufnr)
    local lines = {}

    for _, line in ipairs(state.config.header) do
        table.insert(lines, line)
    end

    if state.config.date_format then
        table.insert(lines, os.date(state.config.date_format))
    end

    local directory_paths = {}
    for _, dir in ipairs(state.config.directories) do
        if type(dir) == 'string' then
            table.insert(directory_paths, dir)
        elseif type(dir) == 'function' then
            for _, path in ipairs(dir()) do
                table.insert(directory_paths, path)
            end
        end
    end

    local directories = {}
    for _, dir in ipairs(directory_paths) do
        if #directories < 26 and util.is_dir(dir) then
            table.insert(directories, dir)
        end
    end

    for i, dir in ipairs(directories) do
        local key = string.char(96 + i)
        map_key(key, dir)
        table.insert(lines, { dir = dir, key = key })
        table.insert(lines, '')
    end

    for _, section in ipairs(state.config.footer) do
        if type(section) == 'string' then
            if sections[section] ~= nil then
                local line = sections[section]()
                if line ~= nil then
                    table.insert(lines, line)
                end
            else
                table.insert(lines, section)
            end
        elseif type(section) == 'function' then
            local line = section()
            if line ~= nil and type(line) == 'string' then
                table.insert(lines, line)
            end
        else
            print('Unhandled footer type: ' .. type(section))
        end
    end

    local center_lines, highlights = center(lines)

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, center_lines)

    local ns_id = vim.api.nvim_create_namespace('Dashboard')
    for _, hl in ipairs(highlights) do
        vim.api.nvim_buf_set_extmark(bufnr, ns_id, hl.line, hl.start, {
            end_col = hl.start + hl.length,
            hl_group = hl.name,
        })
    end
end

---@param bufnr integer
local function load(bufnr)
    vim.bo[bufnr].modifiable = true
    set_buffer(bufnr)
    vim.bo[bufnr].modifiable = false
    vim.bo[bufnr].modified = false
end

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
---@field public on_load? fun(dir: string)
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
    local bufnr = vim.api.nvim_get_current_buf()
    if not util.is_empty(bufnr) then
        bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_win_set_buf(0, bufnr)
    end

    local opts = {
        ['filetype'] = 'dashboard',
        ['number'] = false,
        ['relativenumber'] = false,
        ['bufhidden'] = 'wipe',
        ['buflisted'] = false,
        ['swapfile'] = false,
        ['cursorline'] = false,
        ['cursorcolumn'] = false,
    }
    for opt, val in pairs(opts) do
        vim.opt_local[opt] = val
    end

    load(bufnr)
    -- Reload on resize
    vim.api.nvim_create_autocmd('VimResized', {
        callback = function()
            load(bufnr)
        end,
    })
end

return M
