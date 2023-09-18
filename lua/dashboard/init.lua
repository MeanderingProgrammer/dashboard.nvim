local art = require('dashboard.art')
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
    for _, line in pairs(art.header) do
        table.insert(lines, line)
    end
    table.insert(lines, os.date('%Y-%m-%d %H:%M:%S'))
    --This breaks if there are > 26 repos
    for i, dir in pairs(context.opts.directories) do
        local key = string.char(96 + i)
        map_key(key, dir)
        table.insert(lines, { dir = dir, key = key })
        table.insert(lines, '')
    end
    local center_lines, highlights = center(lines)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, center_lines)

    local namespace = vim.api.nvim_create_namespace('Dashboard')
    local function set_highlight(name, line, highlight)
        local start = highlight.start
        vim.api.nvim_buf_add_highlight(bufnr, namespace, name, line, start, start + highlight.length)
    end

    for _, highlight in pairs(highlights) do
        set_highlight('Icon', highlight.line, highlight.icon)
        set_highlight('Directory', highlight.line, highlight.directory)
        set_highlight('Hotkey', highlight.line, highlight.hotkey)
    end
    vim.api.nvim_set_hl_ns(namespace)
    vim.api.nvim_set_hl(namespace, 'Icon', { fg = '#FFCC00' })
    vim.api.nvim_set_hl(namespace, 'Directory', { fg = '#808080' })
    vim.api.nvim_set_hl(namespace, 'Hotkey', { fg = '#006400' })
end

local function load(bufnr)
    vim.bo[bufnr].modifiable = true
    set_buffer(bufnr)
    vim.bo[bufnr].modifiable = false
    vim.bo[bufnr].modified = false
end

M.instance = function()
    util.set_options()
    local bufnr = vim.api.nvim_get_current_buf()
    load(bufnr)
    --Reload on resize
    vim.api.nvim_create_autocmd('VimResized', {
        callback = function()
            load(bufnr)
        end,
    })
end

M.setup = function(opts)
    context.opts = opts
end

return M
