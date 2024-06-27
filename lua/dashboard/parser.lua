local sections = require('dashboard.sections')
local state = require('dashboard.state')
local util = require('dashboard.util')

---@class mp.dashboard.Directory
---@field icon string
---@field path string
---@field key string

---@class mp.dashboard.Dashboard
---@field header string[]
---@field directories mp.dashboard.Directory[]
---@field footer string[]

---@class mp.dashboard.Parser
local M = {}

---@return mp.dashboard.Dashboard
function M.parse()
    return {
        header = M.get_header(),
        directories = M.get_directories(),
        footer = M.get_footer(),
    }
end

---@private
---@return string[]
function M.get_header()
    local result = {}
    for _, line in ipairs(state.config.header) do
        table.insert(result, line)
    end
    if state.config.date_format ~= nil then
        table.insert(result, os.date(state.config.date_format))
    end
    return result
end

---@private
---@return mp.dashboard.Directory[]
function M.get_directories()
    local result = {}
    for _, path in ipairs(M.flatten_directories()) do
        if #result < 26 and util.is_directory(path) then
            table.insert(result, {
                icon = util.get_icon(path),
                path = path,
                key = string.char(97 + #result),
            })
        end
    end
    return result
end

---@private
---@return string[]
function M.flatten_directories()
    local result = {}
    for _, path_or_function in ipairs(state.config.directories) do
        if type(path_or_function) == 'string' then
            table.insert(result, path_or_function)
        elseif type(path_or_function) == 'function' then
            for _, path in ipairs(path_or_function()) do
                table.insert(result, path)
            end
        end
    end
    return result
end

---@private
---@return string[]
function M.get_footer()
    local result = {}
    for _, section in ipairs(state.config.footer) do
        if type(section) == 'string' then
            if sections[section] ~= nil then
                local line = sections[section]()
                if line ~= nil then
                    table.insert(result, line)
                end
            else
                table.insert(result, section)
            end
        elseif type(section) == 'function' then
            local line = section()
            if line ~= nil and type(line) == 'string' then
                table.insert(result, line)
            end
        else
            vim.print('Unhandled footer type: ' .. type(section))
        end
    end
    return result
end

return M
