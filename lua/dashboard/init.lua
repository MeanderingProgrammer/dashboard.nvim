local art = require('dashboard.art')
local util = require('dashboard.util')

local M = {}
local context = {}

local function center(lines)
    local max_width = util.get_max_width(lines)
    local center_lines = util.get_padded_table(lines)
    for _, line in pairs(lines) do
        if type(line) == 'string' then
            line = util.pad_left(line, vim.api.nvim_strwidth(line))
            table.insert(center_lines, line)
        elseif type(line) == 'table' then
            local icon = util.get_icon(line.dir)
            local content = icon .. ' ' .. line.dir
            local inner_pad = max_width - vim.api.nvim_strwidth(content) - 2
            content = util.pad_left(content, max_width)
            content = content .. (' '):rep(inner_pad) .. '[' .. line.key .. ']'
            table.insert(center_lines, content)
        else
            error('Unhandled type: ' .. type(line))
        end
    end
    return center_lines
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
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, center(lines))
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
