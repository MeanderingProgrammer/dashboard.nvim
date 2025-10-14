vim.api.nvim_create_autocmd('UIEnter', {
    group = vim.api.nvim_create_augroup('Dashboard', {}),
    callback = function()
        if vim.fn.argc() == 0 and vim.api.nvim_buf_get_name(0) == '' then
            require('dashboard').instance()
        end
    end,
})

vim.api.nvim_create_user_command('Dashboard', function()
    require('dashboard').instance()
end, {})
