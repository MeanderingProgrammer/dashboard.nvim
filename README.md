# Introduction

Neovim dashboard plugin

# Features

* Provide directory paths, plugin will display them on the new dashboard and make them accessible
  with single letter hotkey.
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
            --List of directory paths
            directories = {},
            color_groups = {
                --Color group to use for icons
                icon = 'Constant',
                --Color group to use for directory paths
                directory = 'Delimiter',
                --Color group to use for hotkeys
                hotkey = 'Statement',
            },
        })
    end,
}
```

# Acknowledgements

The popular [dashboard-nvim](https://github.com/nvimdev/dashboard-nvim) plugin was used as a reference
point in the development of this plugin. These plugins do very different things other than sharing the
concept of being a dashboard. In many ways `dashboard-nvim` is better and has a lot of neat features
but I was looking for something more user defined as opposed to inferred.

# TODO

* See if there is a decent way to replace the hard coded ascii art
* Look into autogroups, figure out if there's a nice way to avoid stacking calls
* Fix center alignment when other windows are open, will require using something other than `vim.o`
* Decide on desired behavior when hotkey is pressed while multiple windows are open
