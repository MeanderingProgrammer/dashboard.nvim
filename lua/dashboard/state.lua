---@class mp.dashboard.HighlightGroups
---@field public header string
---@field public icon string
---@field public directory string
---@field public hotkey string

---@class mp.dashboard.Config
---@field public header string[]
---@field public date_format? string
---@field public directories (string | fun(): string[])[]
---@field public footer (string | fun(): string?)[]
---@field public on_load fun(dir: string)
---@field public highlight_groups mp.dashboard.HighlightGroups

---@class mp.dashboard.State
---@field config mp.dashboard.Config
local state = {}
return state
