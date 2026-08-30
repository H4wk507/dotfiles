local opt = vim.opt

vim.g.mapleader = ","
vim.g.maplocalleader = "\\"

vim.g.have_nerd_font = true

opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.colorcolumn = "80"
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.termguicolors = true
opt.guicursor = ""
opt.showmode = false
opt.laststatus = 3
opt.winborder = "rounded"
opt.pumheight = 12
opt.splitright = true
opt.splitbelow = true
opt.inccommand = "split"
opt.wrap = false

opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.breakindent = true

opt.incsearch = true
opt.hlsearch = false
opt.ignorecase = true
opt.smartcase = true

opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.updatetime = 250
opt.timeoutlen = 400
opt.confirm = true

opt.clipboard = "unnamedplus"

vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
