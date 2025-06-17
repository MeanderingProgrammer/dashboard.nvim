---@meta

---@class (exact) mp.dash.UserConfig: mp.dash.parser.UserConfig, mp.dash.ui.UserConfig

---@class (exact) mp.dash.parser.UserConfig
---@field header? string[]
---@field date_format? string
---@field directories? (string | fun(): string[])[]
---@field footer? (string | fun(): string?)[]

---@class (exact) mp.dash.ui.UserConfig
---@field options? table<string, any>
---@field on_load? fun(path: string)
---@field highlight_groups? mp.dash.ui.highlight.UserConfig

---@class (exact) mp.dash.ui.highlight.UserConfig
---@field header? string
---@field icon? string
---@field directory? string
---@field hotkey? string
