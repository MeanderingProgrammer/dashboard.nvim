local M = {}

local function center(lines)
    local center_lines = {}
    for _, line in pairs(lines) do
        local extra_space = vim.o.columns - vim.api.nvim_strwidth(line)
        local left_pad = math.floor(extra_space / 2) - 6
        if left_pad > 0 then
            local center_line = (' '):rep(left_pad) .. line
            table.insert(center_lines, center_line)
        else
            table.insert(center_lines, line)
        end
    end
    return center_lines
end

local function load(bufnr)
    vim.bo[bufnr].modifiable = true

    local lines = {}
    table.insert(lines, 'test-1')
    table.insert(lines, 'test-2')
    table.insert(lines, 'test-3')

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, center(lines))

    vim.bo[bufnr].modifiable = false
    vim.bo[bufnr].modified = false
end

M.instance = function()
    local bufnr = vim.api.nvim_get_current_buf()

    --Print some metadata for now
    print('MODE', vim.api.nvim_get_mode().mode)
    print('MODIFIED', vim.bo.modified)
    print('BUF_NUMBER', bufnr)

    load(bufnr)

    --Reload on resize
    vim.api.nvim_create_autocmd('VimResized', {
        buffer = bufnr,
        group = vim.api.nvim_create_augroup('Dashboard', { clear = true }),
        callback = function()
            load(bufnr)
        end,
    })
end

M.setup = function(opts)
    -- Currently no options
end

return M
