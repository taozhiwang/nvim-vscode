vim.keymap.set({ "n" }, "u", "<cmd>call VSCodeNotify('undo')<cr>", { noremap = true, silent = true })
vim.keymap.set({ "n" }, "<C-r>", "<cmd>call VSCodeNotify('redo')<cr>", { noremap = true, silent = true })

-- vim.keymap.set({ "n", "v" }, "<S-h>", "<cmd>call VSCodeNotify('workbench.action.navigateLeft')<cr>", { noremap = true, silent = true })
-- vim.keymap.set({ "n", "v" }, "<S-j>", "<cmd>call VSCodeNotify('workbench.action.navigateDown')<cr>", { noremap = true, silent = true })
-- vim.keymap.set({ "n", "v" }, "<S-k>", "<cmd>call VSCodeNotify('workbench.action.navigateUp')<cr>", { noremap = true, silent = true })
-- vim.keymap.set({ "n", "v" }, "<S-l>", "<cmd>call VSCodeNotify('workbench.action.navigateRight')<cr>", { noremap = true, silent = true })

-- vim.keymap.set({ "n", "v" }, "<Space>", "<cmd>call VSCodeNotify('whichkey.show')<cr>", { noremap = true, silent = true })

vim.keymap.set("n", "<C-o>", "<cmd>call VSCodeNotify('workbench.action.navigateBack')<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-i>", "<cmd>call VSCodeNotify('workbench.action.navigateForward')<cr>", { noremap = true, silent = true })

