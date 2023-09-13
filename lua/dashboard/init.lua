local M = {}

M.instance = function()
    local bufnr = vim.api.nvim_get_current_buf()

    print('MODE', vim.api.nvim_get_mode().mode)
    print('MODIFIED', vim.bo.modified)
    print('BUF_NUMBER', bufnr)

    local fill = {}
    table.insert(fill, 'test-1')
    table.insert(fill, 'test-2')
    table.insert(fill, 'test-3')

    print('LINES', vim.api.nvim_buf_line_count(bufnr))
    print('FILL_SIZE', #fill)

    vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, fill)

    vim.bo[bufnr].modifiable = false
    vim.bo[bufnr].modified = false
end

M.setup = function(opts)
    -- Currently no options
end

return M
