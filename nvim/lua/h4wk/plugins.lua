local map = vim.keymap.set
local nerd = vim.g.have_nerd_font

local flavour = "macchiato"

local function gh(repo)
  return "https://github.com/" .. repo
end

vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("h4wk_pack_build", { clear = true }),
  callback = function(ev)
    local spec, kind = ev.data.spec, ev.data.kind
    if kind ~= "install" and kind ~= "update" then
      return
    end
    if spec.name == "telescope-fzf-native.nvim" then
      vim.system({ "make" }, { cwd = ev.data.path }):wait()
    end
  end,
})

vim.pack.add({
  { src = gh("catppuccin/nvim"), name = "catppuccin" },
  gh("nvim-lualine/lualine.nvim"),
  gh("lewis6991/gitsigns.nvim"),
  gh("echasnovski/mini.icons"),

  { src = gh("nvim-treesitter/nvim-treesitter"), version = "main" },
  gh("windwp/nvim-ts-autotag"),

  gh("nvim-lua/plenary.nvim"),
  gh("nvim-telescope/telescope.nvim"),
  gh("nvim-telescope/telescope-fzf-native.nvim"),

  gh("neovim/nvim-lspconfig"),
  gh("mason-org/mason.nvim"),
  gh("mason-org/mason-lspconfig.nvim"),
  gh("WhoIsSethDaniel/mason-tool-installer.nvim"),
  gh("b0o/SchemaStore.nvim"),

  { src = gh("Saghen/blink.cmp"), version = vim.version.range("^1.0.0") },

  gh("stevearc/conform.nvim"),

  gh("tpope/vim-fugitive"),
  gh("mbbill/undotree"),
  gh("lervag/vimtex"),
}, { confirm = false })

require("mason").setup({ ui = { border = "rounded" } })
require("mason-tool-installer").setup({
  ensure_installed = {
    "tree-sitter-cli",
    "stylua",
    "prettierd",
  },
  run_on_start = true,
  auto_update = false,
})

require("catppuccin").setup({
  flavour = flavour,
  transparent_background = true,
  term_colors = true,
  styles = {
    comments = { "italic" },
    keywords = { "italic" },
  },
  integrations = {
    blink_cmp = true,
    gitsigns = true,
    mason = true,
    telescope = { enabled = true },
    treesitter = true,
    native_lsp = {
      enabled = true,
      underlines = {
        errors = { "undercurl" },
        hints = { "undercurl" },
        warnings = { "undercurl" },
        information = { "undercurl" },
      },
    },
  },
})
vim.cmd.colorscheme("catppuccin")

require("mini.icons").setup({ style = nerd and "glyph" or "ascii" })
MiniIcons.mock_nvim_web_devicons()

require("lualine").setup({
  options = {
    theme = "catppuccin-" .. flavour,
    globalstatus = true,
    icons_enabled = nerd,
    component_separators = { left = "│", right = "│" },
    section_separators = nerd and { left = "", right = "" } or { left = "", right = "" },
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = {
      { "branch", icon = nerd and "" or "git:" },
      { "diff", symbols = { added = "+", modified = "~", removed = "-" } },
      { "diagnostics", symbols = { error = "E", warn = "W", info = "I", hint = "H" } },
    },
    lualine_c = { { "filename", path = 1 } },
    lualine_x = { "filetype" },
    lualine_y = { "progress" },
    lualine_z = { "location" },
  },
})

require("gitsigns").setup({
  signs = {
    add = { text = "┃" },
    change = { text = "┃" },
    delete = { text = "▁" },
    topdelete = { text = "▔" },
    changedelete = { text = "~" },
    untracked = { text = "┆" },
  },
  on_attach = function(bufnr)
    local gs = require("gitsigns")
    local function bmap(mode, lhs, rhs, desc)
      map(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end
    bmap("n", "]c", function() gs.nav_hunk("next") end, "Next hunk")
    bmap("n", "[c", function() gs.nav_hunk("prev") end, "Previous hunk")
    bmap("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
    bmap("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
    bmap("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
    bmap("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
  end,
})

require("nvim-treesitter").setup()

local parsers = {
  "bash", "c", "css", "diff", "dockerfile", "gitcommit", "go", "graphql",
  "html", "javascript", "jsdoc", "json", "lua", "luadoc", "markdown",
  "markdown_inline", "prisma", "python", "query", "regex", "scss", "toml", "tsx",
  "typescript", "vim", "vimdoc", "yaml",
}
if vim.fn.executable("tree-sitter") == 1 then
  local installed = require("nvim-treesitter.config").get_installed("parsers")
  local missing = vim.tbl_filter(function(p)
    return not vim.tbl_contains(installed, p)
  end, parsers)
  if #missing > 0 then
    require("nvim-treesitter").install(missing)
  end
end

require("nvim-ts-autotag").setup()

local telescope = require("telescope")
telescope.setup({
  defaults = {
    prompt_prefix = nerd and "   " or "> ",
    selection_caret = nerd and "  " or "> ",
    path_display = { "truncate" },
    layout_config = { horizontal = { preview_width = 0.55 } },
    file_ignore_patterns = { "^%.git/", "node_modules/" },
  },
})
pcall(telescope.load_extension, "fzf")

local pick = require("telescope.builtin")
map("n", "<C-p>", pick.git_files, { desc = "Find git files" })
map("n", "<leader>pf", pick.find_files, { desc = "Find files" })
map("n", "<leader>ps", pick.live_grep, { desc = "Grep in project" })
map("n", "<leader>pw", pick.grep_string, { desc = "Grep word under cursor" })
map("n", "<leader>pb", pick.buffers, { desc = "Find buffer" })
map("n", "<leader>ph", pick.help_tags, { desc = "Find help tag" })
map("n", "<leader>pd", pick.diagnostics, { desc = "Find diagnostic" })
map("n", "<leader>pr", pick.resume, { desc = "Resume last picker" })

require("blink.cmp").setup({
  keymap = { preset = "default" },
  appearance = { nerd_font_variant = "mono" },
  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 200 },
    menu = { draw = { treesitter = { "lsp" } } },
  },
  sources = { default = { "lsp", "path", "snippets", "buffer" } },
  signature = { enabled = true },
})

local prettier = { "prettierd", "prettier", stop_after_first = true }
require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    javascript = prettier,
    javascriptreact = prettier,
    typescript = prettier,
    typescriptreact = prettier,
    json = prettier,
    jsonc = prettier,
    css = prettier,
    scss = prettier,
    html = prettier,
    yaml = prettier,
    markdown = prettier,
    graphql = prettier,
    python = { "ruff_format" },
  },
  format_on_save = function(bufnr)
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end
    if #vim.lsp.get_clients({ bufnr = bufnr, name = "eslint" }) > 0 then
      pcall(vim.api.nvim_buf_call, bufnr, function()
        vim.cmd("LspEslintFixAll")
      end)
    end
    return { timeout_ms = 2000, lsp_format = "fallback" }
  end,
})

map({ "n", "v" }, "<leader>f", function()
  require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format buffer" })

vim.api.nvim_create_user_command("FormatToggle", function(args)
  if args.bang then
    vim.b.disable_autoformat = not vim.b.disable_autoformat
  else
    vim.g.disable_autoformat = not vim.g.disable_autoformat
  end
end, { bang = true, desc = "Toggle format-on-save (! for current buffer only)" })

vim.g.vimtex_view_method = "zathura"
vim.g.vimtex_compiler_method = "latexmk"
vim.g.vimtex_quickfix_mode = 0
