# Introduction

Neovim dashboard plugin

# Features

* Provide your most important repo paths, plugin will add them all to dashboard and make them accessible
  with single letter hotkey.
* Order of input is preserved and hotkeys are generated sequentially, making experience consistent.

# Install

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
            repos = {
                --List of repository directory paths
            },
        })
    end,
}
```

# TODO

* Look into autogroups, figure out if there's a nice way to avoid stacking calls
