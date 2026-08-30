local map = vim.keymap.set

map("n", "<leader>pv", vim.cmd.Ex, { desc = "Open file explorer" })

map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
map({ "n", "v" }, "<leader>p", [["+p]], { desc = "Paste from system clipboard" })
map("x", "<leader>P", [["_dP]], { desc = "Paste without clobbering register" })

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

map("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centred)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centred)" })
map("n", "n", "nzzzv", { desc = "Next match (centred)" })
map("n", "N", "Nzzzv", { desc = "Previous match (centred)" })

map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic under cursor" })
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })

map("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Toggle undotree" })
map("n", "<leader>gs", vim.cmd.Git, { desc = "Fugitive status" })

map("n", "<leader>pu", function() vim.pack.update() end, { desc = "Update plugins" })
