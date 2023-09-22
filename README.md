# Introduction

Neovim dashboard plugin

![Preview](images/preview.png)

* Look at the [Options -> header](#header) section to get results like above

# Features

* Fully customizable header with reference for integrating with ascii art plugin
* Provide directories and this plugin will:
    * Display them on the dashboard
    * Make them accessible with single letter hotkey
* Input is ordered and hotkeys are generated sequentially, making for a consistent experience

# Install

This plugin is going through a lot of changes.

Screenshot may not correspond to configuration below or even be possible anymore.

## Lazy.nvim

```lua
return {
    'MeanderingProgrammer/dashboard.nvim',
    event = 'VimEnter',
    dependencies = {
        'nvim-tree/nvim-web-devicons',
    },
    config = function()
        require('dashboard').setup({
            --Dashboard header
            header = {},
            --Format to display date in
            date_format = '%Y-%m-%d %H:%M:%S',
            --List of directory paths
            directories = {},
            --Highlight groups to use for various components
            highlight_groups = {
                header = 'Constant',
                icon = 'Type',
                directory = 'Delimiter',
                hotkey = 'Statement',
            },
        })
    end,
}
```

# Options

## `header`

By default no header is provided by the plugin. As it is just an array of strings you can create
your own or use another plugin which provides the ascii art.

For example using [MaximilianLloyd/ascii.nvim](https://github.com/MaximilianLloyd/ascii.nvim) in
`Lazy.nvim` to achieve the look in the screenshots:

```lua
return {
    'MeanderingProgrammer/dashboard.nvim',
    event = 'VimEnter',
    dependencies = {
        'nvim-tree/nvim-web-devicons',
        { 'MaximilianLloyd/ascii.nvim', dependencies = { 'MunifTanjim/nui.nvim' } },
    },
    config = function()
        require('dashboard').setup({
            header = require('ascii').art.text.neovim.sharp,
        })
    end,
}
```

You can also use methods provided by the ascii plugin to randomize the look on every load, for example:

```lua
require('ascii').get_random_global()
```

# Acknowledgements

The popular [dashboard-nvim](https://github.com/nvimdev/dashboard-nvim) plugin was used as a reference
point in the development of this plugin. These plugins do very different things other than sharing the
concept of being a dashboard. In many ways `dashboard-nvim` is better and has a lot of neat features
but I was looking for something more user defined as opposed to inferred.

# TODO

* Look into autogroups, figure out if there's a nice way to avoid stacking calls
* Decide on desired behavior when hotkey is pressed while multiple windows are open
* Do we need `loaded_dashboard` at the top of [dashboard.lua](plugin/dashboard.lua)
