local parser = require('dashboard.parser')
local state = require('dashboard.state')
local util = require('dashboard.util')

---@class mp.dashboard.Highlight
---@field name string
---@field row integer
---@field start_col integer In bytes
---@field length integer In bytes

---@class mp.dashboard.Ui
local M = {}

---@return integer
function M.create_buffer()
    local bufnr = vim.api.nvim_get_current_buf()
    if not util.is_empty(bufnr) then
        bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_win_set_buf(0, bufnr)
    end
    local local_options = {
        ['filetype'] = 'dashboard',
        ['number'] = false,
        ['relativenumber'] = false,
        ['bufhidden'] = 'wipe',
        ['buflisted'] = false,
        ['swapfile'] = false,
        ['cursorline'] = false,
        ['cursorcolumn'] = false,
    }
    for option, value in pairs(local_options) do
        vim.opt_local[option] = value
    end
    return bufnr
end

---@param bufnr integer
function M.load(bufnr)
    vim.bo[bufnr].modifiable = true
    M.set_buffer(bufnr, parser.parse())
    vim.bo[bufnr].modifiable = false
    vim.bo[bufnr].modified = false
end

---@private
M.namespace = vim.api.nvim_create_namespace('Dashboard')

---@private
---@param bufnr integer
---@param dashboard mp.dashboard.Dashboard
function M.set_buffer(bufnr, dashboard)
    for _, directory in ipairs(dashboard.directories) do
        local path = vim.fs.normalize(directory.path)
        vim.keymap.set('n', directory.key, function()
            vim.api.nvim_clear_autocmds({ group = "dashboard_open" })
            vim.cmd('lcd ' .. path)
            vim.cmd('e .')
            state.config.on_load(path)
        end, { buffer = true })
    end

    local lines, highlights = M.render_data(dashboard)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    for _, hl in ipairs(highlights) do
        vim.api.nvim_buf_set_extmark(bufnr, M.namespace, hl.row, hl.start_col, {
            end_col = hl.start_col + hl.length,
            hl_group = hl.name,
        })
    end
end

---@private
---@param dashboard mp.dashboard.Dashboard
---@return string[]
---@return mp.dashboard.Highlight[]
function M.render_data(dashboard)
    local lines = {}
    local highlights = {}
    M.add_top_padding(dashboard, lines, 2)
    for _, header in ipairs(dashboard.header) do
        M.add_header_or_footer(lines, highlights, header)
    end
    local width = M.get_width(dashboard)
    for _, directory in ipairs(dashboard.directories) do
        M.add_directory(lines, highlights, width, directory)
    end
    for _, footer in ipairs(dashboard.footer) do
        M.add_header_or_footer(lines, highlights, footer)
    end
    return lines, highlights
end

---@private
---@param dashboard mp.dashboard.Dashboard
---@param lines string[]
---@param directory_height integer
function M.add_top_padding(dashboard, lines, directory_height)
    local height = #dashboard.header
        + (directory_height * #dashboard.directories)
        + #dashboard.footer
    for _ = 1, util.padding(util.height(), height) do
        table.insert(lines, '')
    end
end

---@private
---@param lines string[]
---@param highlights mp.dashboard.Highlight[]
---@param line string
function M.add_header_or_footer(lines, highlights, line)
    local padding = util.padding(util.width(), util.len(line))
    table.insert(highlights, {
        name = state.config.highlight_groups.header,
        row = #lines,
        start_col = padding,
        length = #line,
    })
    table.insert(lines, string.rep(' ', padding) .. line)
end

---@private
---@param dashboard mp.dashboard.Dashboard
---@return integer
function M.get_width(dashboard)
    local widths = {}
    for _, header in ipairs(dashboard.header) do
        table.insert(widths, util.len(header))
    end
    for _, directory in ipairs(dashboard.directories) do
        -- Format:<icon><space><path><space><filler><space>[<key>]
        -- Space :<icon><1    ><path><1    ><      ><1    >1<1  >1 = icon + path + 6
        local icon, path = directory.icon, directory.path
        table.insert(widths, util.len(icon) + util.len(path) + 6)
    end
    for _, footer in ipairs(dashboard.footer) do
        table.insert(widths, util.len(footer))
    end
    return vim.fn.max(widths)
end

---@private
---@param lines string[]
---@param highlights mp.dashboard.Highlight[]
---@param width integer
---@param directory mp.dashboard.Directory
function M.add_directory(lines, highlights, width, directory)
    local padding = util.padding(util.width(), width)

    local line = directory.icon
    table.insert(highlights, {
        name = state.config.highlight_groups.icon,
        row = #lines,
        start_col = padding,
        length = #directory.icon,
    })

    line = string.format('%s %s', line, directory.path)
    table.insert(highlights, {
        name = state.config.highlight_groups.directory,
        row = #lines,
        start_col = padding + #directory.icon + 1,
        length = #directory.path,
    })

    line = string.format(
        '%s %s [%s]',
        line,
        string.rep('.', width - util.len(line) - 5),
        directory.key
    )
    table.insert(highlights, {
        name = state.config.highlight_groups.hotkey,
        row = #lines,
        start_col = padding + #line - 3,
        length = 3,
    })

    table.insert(lines, string.rep(' ', padding) .. line)
    table.insert(lines, '')
end

return M
