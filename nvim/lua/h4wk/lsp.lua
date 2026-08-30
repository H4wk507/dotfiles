require("mason-lspconfig").setup({
  ensure_installed = {
    "vtsls",
    "eslint",
    "tailwindcss",
    "prismals",
    "dockerls",
    "yamlls",
    "jsonls",
    "graphql",
    "cssls",
    "html",
    "ruff",
    "lua_ls",
  },
  automatic_enable = { exclude = { "stylua" } },
})

local ts_inlay_hints = {
  parameterNames = { enabled = "literals" },
  parameterTypes = { enabled = true },
  variableTypes = { enabled = false },
  propertyDeclarationTypes = { enabled = true },
  functionLikeReturnTypes = { enabled = true },
  enumMemberValues = { enabled = true },
}

vim.lsp.config("vtsls", {
  settings = {
    vtsls = {
      autoUseWorkspaceTsdk = true,
      experimental = {
        completion = { enableServerSideFuzzyMatch = true },
      },
    },
    typescript = {
      inlayHints = ts_inlay_hints,
      updateImportsOnFileMove = { enabled = "always" },
      preferences = { includePackageJsonAutoImports = "auto" },
    },
    javascript = { inlayHints = ts_inlay_hints },
  },
})

vim.lsp.config("graphql", {
  root_dir = function(bufnr, on_dir)
    local found = require("lspconfig.util").root_pattern(
      ".graphqlrc*", ".graphql.config.*", "graphql.config.*"
    )(vim.api.nvim_buf_get_name(bufnr))
    if found then
      on_dir(found)
    end
  end,
})

vim.lsp.config("jsonls", {
  settings = {
    json = {
      schemas = require("schemastore").json.schemas(),
      validate = { enable = true },
    },
  },
})

vim.lsp.config("yamlls", {
  settings = {
    yaml = {
      schemaStore = { enable = false, url = "" },
      schemas = require("schemastore").yaml.schemas(),
      validate = true,
      keyOrdering = false,
    },
  },
})

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = {
        checkThirdParty = false,
        library = vim.api.nvim_get_runtime_file("", true),
      },
      diagnostics = { globals = { "vim" } },
      telemetry = { enable = false },
    },
  },
})

local severity = vim.diagnostic.severity
local diag_icons = vim.g.have_nerd_font
    and { [severity.ERROR] = " ", [severity.WARN] = " ", [severity.INFO] = " ", [severity.HINT] = " " }
  or { [severity.ERROR] = "●", [severity.WARN] = "●", [severity.INFO] = "●", [severity.HINT] = "●" }

vim.diagnostic.config({
  virtual_text = { spacing = 2, prefix = "●" },
  signs = { text = diag_icons },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { source = "if_many" },
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("h4wk_lsp_attach", { clear = true }),
  callback = function(ev)
    local function bmap(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = "LSP: " .. desc })
    end

    bmap("gd", vim.lsp.buf.definition, "Go to definition")
    bmap("gD", vim.lsp.buf.declaration, "Go to declaration")

    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
      bmap("<leader>th", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
      end, "Toggle inlay hints")
    end
  end,
})
