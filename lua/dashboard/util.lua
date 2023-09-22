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

M.get_padded_table = function(height)
    local padded_table = {}
    local extra_lines = vim.api.nvim_win_get_height(0) - height
    local top_pad = math.floor(extra_lines / 2) - 2
    for _ = 1, top_pad do
        table.insert(padded_table, '')
    end
    return padded_table
end

M.pad_left = function(width)
    local extra_space = vim.api.nvim_win_get_width(0) - width
    local left_pad = math.floor(extra_space / 2) - 2
    if left_pad > 0 and width > 0 then
        return (' '):rep(left_pad)
    else
        return ''
    end
end

M.is_dir = function(dir)
    local path = vim.fs.normalize(dir)
    return vim.fn.isdirectory(path) == 1
end

M.get_icon = function(dir)
    if M.is_dir(dir .. '/.git') then
        return ''
    else
        return ''
    end
end

M.is_empty = function(bufnr)
    local num_lines = vim.api.nvim_buf_line_count(bufnr)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    return num_lines == 1 and lines[1] == ''
end

return M
