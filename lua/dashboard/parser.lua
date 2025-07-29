local sections = require('dashboard.sections')
local util = require('dashboard.util')

---@class (exact) mp.dash.parser.Config
---@field header string[]
---@field date_format? string
---@field directories (string | fun(): string[])[]
---@field footer (string | fun(): string?)[]

---@class mp.dash.Value
---@field path string
---@field icon string
---@field key string

---@class mp.dash.Parser
---@field private config mp.dash.parser.Config
local M = {}

---called from init on setup
---@param config mp.dash.parser.Config
function M.setup(config)
    M.config = config
end

---@return string[]
function M.header()
    local result = {} ---@type string[]
    for _, line in ipairs(M.config.header) do
        result[#result + 1] = line
    end
    if M.config.date_format then
        local date = os.date(M.config.date_format)
        if type(date) == 'string' then
            result[#result + 1] = date
        end
    end
    return result
end

---@return mp.dash.Value[]
function M.values()
    local result = {} ---@type mp.dash.Value[]
    for _, path in ipairs(M.paths()) do
        if #result < 26 and util.is_directory(path) then
            result[#result + 1] = {
                path = path,
                icon = util.icon(path),
                key = string.char(97 + #result),
            }
        end
    end
    return result
end

---@private
---@return string[]
function M.paths()
    local result = {} ---@type string[]
    for _, directory in ipairs(M.config.directories) do
        if type(directory) == 'string' then
            result[#result + 1] = directory
        elseif type(directory) == 'function' then
            for _, path in ipairs(directory()) do
                result[#result + 1] = path
            end
        end
    end
    return result
end

---@return string[]
function M.footer()
    local result = {} ---@type string[]
    for _, value in ipairs(M.config.footer) do
        if type(value) == 'string' then
            local section = sections[value] ---@type fun(): string?
            if section then
                local line = section()
                if line then
                    result[#result + 1] = line
                end
            else
                result[#result + 1] = value
            end
        elseif type(value) == 'function' then
            local line = value()
            if type(line) == 'string' then
                result[#result + 1] = line
            end
        else
            vim.print('Unhandled footer type: ' .. type(value))
        end
    end
    return result
end

return M
