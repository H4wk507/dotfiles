local function augroup(name)
  return vim.api.nvim_create_augroup("h4wk_" .. name, { clear = true })
end

-- Briefly highlight the text that was just yanked.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("yank"),
  callback = function()
    vim.hl.on_yank({ higroup = "Visual", timeout = 150 })
  end,
})

-- Two-space indent for web and markup filetypes.
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("indent"),
  pattern = {
    "javascript", "javascriptreact", "typescript", "typescriptreact",
    "json", "jsonc", "html", "css", "scss", "less", "yaml", "toml",
    "lua", "markdown", "graphql",
  },
  callback = function()
    vim.bo.tabstop = 2
    vim.bo.softtabstop = 2
    vim.bo.shiftwidth = 2
  end,
})

-- Treesitter highlighting for every filetype that has a parser installed.
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("treesitter"),
  callback = function(ev)
    if not pcall(vim.treesitter.start, ev.buf) then
      return
    end
    local ts_indent = {
      javascript = true, javascriptreact = true,
      typescript = true, typescriptreact = true,
    }
    if ts_indent[vim.bo[ev.buf].filetype] then
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

-- Reopen a file on the line it was left on.
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_position"),
  callback = function(ev)
    if vim.bo[ev.buf].filetype == "gitcommit" then
      return
    end
    local mark = vim.api.nvim_buf_get_mark(ev.buf, [["]])
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
