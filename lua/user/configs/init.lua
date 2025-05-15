if vim.g.vscode then
  require("user.configs.vscode")
  require("user.configs.vscode_keymaps")
else
  require("user.configs.options")
  require("user.configs.autocmds")
  require("user.configs.keymaps")
end
