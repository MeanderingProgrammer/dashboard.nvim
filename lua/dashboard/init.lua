local util = require('dashboard.util')

local M = {}
local context = {}

local function center(lines)
    local max_width = util.get_max_width(lines)
    local center_lines = util.get_padded_table(lines)
    local highlights = {}
    for _, line in pairs(lines) do
        if type(line) == 'string' then
            local left_padding = util.pad_left(util.len(line))
            table.insert(center_lines, left_padding .. line)
        elseif type(line) == 'table' then
            local icon = util.get_icon(line.dir)
            local content = icon .. ' ' .. line.dir
            local left_padding = util.pad_left(max_width)
            local inner_pad = max_width - util.len(content) - 2

            content = left_padding .. content .. (' '):rep(inner_pad) .. '[' .. line.key .. ']'
            table.insert(center_lines, content)

            table.insert(highlights, {
                line = #center_lines - 1,
                icon = { start = util.len(left_padding), length = 4 },
                directory = { start = util.len(left_padding) + 4, length = util.len(line.dir) + 1 },
                hotkey = { start = util.len(content) - 1, length = 4 }
            })
        else
            error('Unhandled type: ' .. type(line))
        end
    end
    return center_lines, highlights
end

local function map_key(key, dir)
    dir = vim.fs.normalize(dir)
    vim.keymap.set('n', key, function()
        vim.cmd('lcd ' .. dir)
        vim.cmd('e .')
    end, { buffer = true })
end

local function set_buffer(bufnr)
    local lines = {}

    for _, line in pairs(context.opts.header) do
        table.insert(lines, line)
    end

    if context.opts.date_format then
        table.insert(lines, os.date(context.opts.date_format))
    end

    --This breaks if there are > 26 repos
    for i, dir in pairs(context.opts.directories) do
        local key = string.char(96 + i)
        map_key(key, dir)
        table.insert(lines, { dir = dir, key = key })
        table.insert(lines, '')
    end

    local center_lines, highlights = center(lines)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, center_lines)
    local function set_highlight(name, line, highlight)
        local start = highlight.start
        vim.api.nvim_buf_add_highlight(bufnr, -1, name, line, start, start + highlight.length)
    end
    local groups = context.opts.highlight_groups
    for _, highlight in pairs(highlights) do
        set_highlight(groups.icon, highlight.line, highlight.icon)
        set_highlight(groups.directory, highlight.line, highlight.directory)
        set_highlight(groups.hotkey, highlight.line, highlight.hotkey)
    end
end

local function load(bufnr)
    vim.bo[bufnr].modifiable = true
    set_buffer(bufnr)
    vim.bo[bufnr].modifiable = false
    vim.bo[bufnr].modified = false
end

M.instance = function()
    local bufnr = vim.api.nvim_get_current_buf()
    if not util.is_empty(bufnr) then
        bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_win_set_buf(0, bufnr)
    end

    util.set_options()

    load(bufnr)
    --Reload on resize
    vim.api.nvim_create_autocmd('VimResized', {
        callback = function()
            load(bufnr)
        end,
    })
end

M.setup = function(opts)
    opts = opts or {}
    local default_opts = {
        header = {},
        date_format = nil,
        directories = {},
        highlight_groups = {
            icon = 'Constant',
            directory = 'Delimiter',
            hotkey = 'Statement',
        },
    }
    context.opts = vim.tbl_deep_extend('force', default_opts, opts)
end

return M
