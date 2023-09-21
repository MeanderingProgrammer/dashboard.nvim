local util = require('dashboard.util')

local M = {}
local context = {}

local function get_max_width(lines)
    local lengths = {}
    for _, line in pairs(lines) do
        if type(line) == 'string' then
            table.insert(lengths, util.len(line))
        elseif type(line) == 'table' and line.dir then
            table.insert(lengths, util.len(line.dir) + 6)
        end
    end
    return vim.fn.max(lengths)
end

local function center(lines)
    local max_width = get_max_width(lines)
    local center_lines = util.get_padded_table(#lines)
    local groups = context.opts.highlight_groups
    local highlights = {}
    for _, line in pairs(lines) do
        if type(line) == 'string' then
            local left_pad = util.pad_left(util.len(line))
            table.insert(center_lines, left_pad .. line)
        elseif type(line) == 'table' then
            local left_padding = util.pad_left(max_width)

            local icon = util.get_icon(line.dir)
            local inner_content = string.format('%s %s', icon, line.dir)

            local hotkey_content = string.format('[%s]', line.key)

            local content = string.format(
                '%s%s%s%s',
                left_padding,
                inner_content,
                (' '):rep(max_width - util.len(inner_content) - #hotkey_content),
                hotkey_content
            )

            table.insert(center_lines, content)

            table.insert(highlights, {
                line = #center_lines - 1,
                name = groups.icon,
                start = #left_padding,
                length = #icon + 1,
            })
            table.insert(highlights, {
                line = #center_lines - 1,
                name = groups.directory,
                start = #left_padding + #icon + 1,
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

    for i, dir in pairs(context.opts.directories) do
        if i <= 26 then
            local key = string.char(96 + i)
            map_key(key, dir)
            table.insert(lines, { dir = dir, key = key })
            table.insert(lines, '')
        end
    end

    local center_lines, highlights = center(lines)

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, center_lines)

    local ns_id = vim.api.nvim_create_namespace('Dashboard')
    for _, highlight in pairs(highlights) do
        vim.api.nvim_buf_set_extmark(bufnr, ns_id, highlight.line, highlight.start, {
            end_col = highlight.start + highlight.length,
            hl_group = highlight.name,
        })
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
