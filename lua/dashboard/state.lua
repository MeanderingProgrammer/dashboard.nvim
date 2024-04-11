---@class HighlightGroups
---@field public header string
---@field public icon string
---@field public directory string
---@field public hotkey string

---@class Config
---@field public header string[]
---@field public date_format? string
---@field public directories (string | fun(): string[])[]
---@field public footer (string | fun(): string?)[]
---@field public on_load fun(dir: string)
---@field public highlight_groups HighlightGroups

---@class State
---@field config Config
local state = {}
return state
