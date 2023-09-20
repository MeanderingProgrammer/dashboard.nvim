# Introduction

Neovim dashboard plugin

![Preview](images/preview.png)

# Features

* Provide directory paths, plugin will display them on the dashboard and make them accessible with
  single letter hotkey.
* Order of input is preserved and hotkeys are generated sequentially, making experience consistent.

# Install

All setup options are optional and shown with their default values, though not setting any directories
would be a strange choice.

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
            --List of directory paths
            directories = {},
            --Highlight groups to use for various components
            highlight_groups = {
                icon = 'Constant',
                directory = 'Delimiter',
                hotkey = 'Statement',
            },
        })
    end,
}
```

# Adding a Header

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
* Fix center alignment when other windows are open, will require using something other than `vim.o`
* Decide on desired behavior when hotkey is pressed while multiple windows are open
