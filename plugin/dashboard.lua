vim.api.nvim_create_autocmd('UIEnter', {
    group = vim.api.nvim_create_augroup('Dashboard', { clear = true }),
    callback = function()
        if vim.fn.argc() == 0 then
            require('dashboard').instance()
        end
    end,
})
