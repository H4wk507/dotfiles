local lsp = require('lsp-zero')

lsp.preset("recommended")

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})

  local opts = {buffer = bufnr, remap = false}
  vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
end)


lsp.setup_servers({'tsserver', 'eslint'})

-- (Optional) Configure lua language server for neovim
local lspconfig = require('lspconfig');

lspconfig.lua_ls.setup(lsp.nvim_lua_ls())

lspconfig.tailwindcss.setup{}
lsp.setup()
