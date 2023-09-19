# Introduction

Neovim dashboard plugin

# Features

* Provide your most important repo paths, plugin will add them all to dashboard and make them accessible
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
            colors = {
                --Color used to display icons
                icon = '#F6C177',
                --Color used to display directory paths
                directory = '#908CAA',
                --Color used to display hotkeys
                hotkey = '#31748F',
            },
            --List of directory paths
            directories = {},
        })
    end,
}
```

# TODO

* Look into autogroups, figure out if there's a nice way to avoid stacking calls
