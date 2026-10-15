local vscode = require("vscode")

vim.keymap.set("n", "u", function()
  vscode.action("undo")
end, { desc = "Undo" })
vim.keymap.set("n", "<C-r>", function()
  vscode.action("redo")
end, { desc = "Redo" })

-- vim.keymap.set({ "n", "v" }, "<S-h>", "<cmd>call VSCodeNotify('workbench.action.navigateLeft')<cr>", { noremap = true, silent = true })
-- vim.keymap.set({ "n", "v" }, "<S-j>", "<cmd>call VSCodeNotify('workbench.action.navigateDown')<cr>", { noremap = true, silent = true })
-- vim.keymap.set({ "n", "v" }, "<S-k>", "<cmd>call VSCodeNotify('workbench.action.navigateUp')<cr>", { noremap = true, silent = true })
-- vim.keymap.set({ "n", "v" }, "<S-l>", "<cmd>call VSCodeNotify('workbench.action.navigateRight')<cr>", { noremap = true, silent = true })

-- vim.keymap.set({ "n", "v" }, "<Space>", "<cmd>call VSCodeNotify('whichkey.show')<cr>", { noremap = true, silent = true })

-- vim.keymap.set("n", "<C-o>", "<cmd>call VSCodeNotify('workbench.action.navigateBack')<cr>", { noremap = true, silent = true })
-- vim.keymap.set("n", "<C-i>", "<cmd>call VSCodeNotify('workbench.action.navigateForward')<cr>", { noremap = true, silent = true })

-- vim.keymap.set({ "n", "x" }, "<C-u>", function()
--     local visibleRanges = require('vscode').eval("return vscode.window.activeTextEditor.visibleRanges")
--     local height = visibleRanges[1][2].line - visibleRanges[1][1].line
--     for i = 1, height*2/3 do
--         vim.api.nvim_feedkeys("k", "n", false)
--     end
-- end)

-- vim.keymap.set({ "n", "x" }, "<C-d>", function()
--     local visibleRanges = require('vscode').eval("return vscode.window.activeTextEditor.visibleRanges")
--     local height = visibleRanges[1][2].line - visibleRanges[1][1].line
--     for i = 1, height*2/3 do
--         vim.api.nvim_feedkeys("j", "n", false)
--     end
-- end)

