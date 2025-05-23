return {
  -- Basic lib
  { "nvim-lua/plenary.nvim", lazy = true },
  -- Icons lib
  {
    "echasnovski/mini.icons",
    lazy = true,
    opts = {
      file = {
        [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
        ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
      },
      filetype = {
        dotenv = { glyph = "", hl = "MiniIconsYellow" },
      },
    },
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },
  -- UI lib
  { "MunifTanjim/nui.nvim", lazy = true },

  -- Save and restore session
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    keys = {
      {
        "<leader>qs",
        function()
          require("persistence").load()
        end,
        desc = "Restore Session",
      },
      {
        "<leader>ql",
        function()
          require("persistence").load({ last = true })
        end,
        desc = "Restore Last Session",
      },
      {
        "<leader>qQ",
        function()
          require("persistence").stop()
          pcall(vim.cmd.qall)
        end,
        desc = "Quit Without Saving Session",
      },
    },
    opts = {
      -- options = vim.opt.sessionoptions:get(),
    },
  },

  -- Better bd
  {
    "echasnovski/mini.bufremove",
    keys = {
      {
        "<Leader>bd",
        function()
          local bd = require("mini.bufremove").delete
          if vim.bo.modified then
            local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
            if choice == 1 then
              pcall(vim.cmd.write)
              bd(0)
            elseif choice == 2 then
              bd(0, true)
            end
          else
            bd(0)
          end
        end,
        desc = "Delete Buffer",
      },
    },
    opts = {},
  },

  -- Finds and lists all of the TODO, FIX, PERF etc comment
  -- in your project and loads them into a browsable list.
  {
    "folke/todo-comments.nvim",
    event = "User LazyFile",
    cmd = { "TodoTelescope" },
    -- stylua: ignore
    keys = {
      { "<Leader>st", "<Cmd>TodoTelescope<CR>", desc = "Todos" },
      { "<Leader>sT", "<Cmd>TodoTelescope keywords=TODO,FIX,PERF<CR>", desc = "TODO/FIX/PERF" },
    },
    opts = {},
  },
}
