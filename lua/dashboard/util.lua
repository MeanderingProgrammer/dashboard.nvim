local M = {}

M.set_options = function()
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
end

M.len = function(value)
    return vim.api.nvim_strwidth(value)
end

M.get_max_width = function(lines)
    local lengths = {}
    for _, line in pairs(lines) do
        if type(line) == 'string' then
            table.insert(lengths, M.len(line))
        elseif type(line) == 'table' and line.dir then
            table.insert(lengths, M.len(line.dir) + 6)
        end
    end
    return vim.fn.max(lengths)
end

M.get_padded_table = function(lines)
    local padded_table = {}
    local extra_lines = vim.o.lines - #lines
    local top_pad = math.floor(extra_lines / 2) - 2
    for _ = 1, top_pad do
        table.insert(padded_table, '')
    end
    return padded_table
end

M.pad_left = function(length)
    local extra_space = vim.o.columns - length
    local left_pad = math.floor(extra_space / 2) - 2
    if left_pad > 0 and length > 0 then
        return (' '):rep(left_pad)
    else
        return ''
    end
end

M.get_icon = function(dir)
    local git_path = vim.fs.normalize(dir .. '/.git')
    if vim.fn.isdirectory(git_path) == 1 then
        return ''
    else
        return '󰉋'
    end
end

M.is_empty = function(bufnr)
    local num_lines = vim.api.nvim_buf_line_count(bufnr)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    return num_lines == 1 and lines[1] == ''
end

return M
