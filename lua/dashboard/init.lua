local art = require('dashboard.art')

local M = {}
local context = {}

local function pad_left(line, length)
    local extra_space = vim.o.columns - length
    local left_pad = math.floor(extra_space / 2) - 2
    if left_pad > 0 then
        line = (' '):rep(left_pad) .. line
    end
    return line
end

local function get_padded_table(lines)
    local padded_table = {}
    local extra_lines = vim.o.lines - #lines
    local top_pad = math.floor(extra_lines / 2) - 2
    if top_pad > 0 then
        for _ = 1, top_pad do
            table.insert(padded_table, '')
        end
    end
    return padded_table
end

local function get_max_width(lines)
    local lengths = {}
    for _, line in pairs(lines) do
        if type(line) == 'string' then
            table.insert(lengths, vim.api.nvim_strwidth(line))
        end
    end
    return vim.fn.max(lengths)
end

local function center(lines)
    local max_width = get_max_width(lines)
    local center_lines = get_padded_table(lines)
    for _, line in pairs(lines) do
        if type(line) == 'string' then
            line = pad_left(line, vim.api.nvim_strwidth(line))
            table.insert(center_lines, line)
        elseif type(line) == 'table' then
            local content = line.icon .. ' ' .. line.dir
            local inner_pad = max_width - vim.api.nvim_strwidth(content) - 2
            content = pad_left(content, max_width)
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

local function load(bufnr)
    vim.bo[bufnr].modifiable = true

    local lines = {}
    for _, line in pairs(art.header) do
        table.insert(lines, line)
    end
    table.insert(lines, os.date('%Y-%m-%d %H:%M:%S'))
    table.insert(lines, '󰊢')
    --This breaks if there are > 26 repos
    for i, dir in pairs(context.opts.directories) do
        local key = string.char(96 + i)
        map_key(key, dir)
        table.insert(lines, { icon = '', dir = dir, key = key })
    end

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, center(lines))

    vim.bo[bufnr].modifiable = false
    vim.bo[bufnr].modified = false
end

M.instance = function()
    local opts = {
        ['filetype'] = 'dashboard',
        ['number'] = false,
        ['relativenumber'] = false,
    }
    for opt, val in pairs(opts) do
        vim.opt_local[opt] = val
    end

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
