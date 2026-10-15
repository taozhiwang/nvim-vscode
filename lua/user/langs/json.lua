return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- nvim-treesitter main has no separate jsonc parser; json covers it
      vim.list_extend(opts.ensure_installed, { "json", "json5" })
    end,
  },

  {
    "b0o/SchemaStore.nvim",
    lazy = true,
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        jsonls = {
          -- lazy-load schemastore when needed
          on_new_config = function(new_config)
            new_config.settings.json.schemas = vim.tbl_deep_extend(
              "force",
              new_config.settings.json.schemas or {},
              require("schemastore").json.schemas()
            )
          end,
          settings = {
            json = {
              validate = { enable = true },
            },
          },
        },
      },
    },
  },

  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        json = { "prettier" },
        jsonc = { "prettier" },
      },
    },
  },

  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "prettier" })
    end,
  },
}
