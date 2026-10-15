local keymap = require("user.utils.keymap")
local utils = require("user.utils")

return {
  -- Parse code to AST, and use it to highlight, move, select, etc.
  -- nvim-treesitter `main` branch (Neovim 0.12+, needs the tree-sitter CLI). It only installs parsers;
  -- highlighting and indent are started per buffer below. Lazy-loading is not supported.
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    opts = {
      ensure_installed = {
        "c",
        "bash",
        "lua",
        "vim",
        "vimdoc",
        "query",
        -- Ensure to install all the parser above
        "regex",
        "diff",
        "git_config",
        "git_rebase",
        "gitattributes",
        "gitcommit",
        "gitignore",
      },
    },
    config = function(_, opts)
      local ts = require("nvim-treesitter")
      local installed = ts.get_installed()
      local missing = vim.tbl_filter(function(lang)
        return not vim.tbl_contains(installed, lang)
      end, utils.tbl_unique(opts.ensure_installed))
      if #missing > 0 then
        if vim.fn.executable("tree-sitter") == 1 then
          ts.install(missing)
        else
          vim.notify("tree-sitter CLI not found: `brew install tree-sitter-cli`", vim.log.levels.WARN)
        end
      end

      -- VSCode renders highlighting itself; Neovim there only needs parsers for textobjects
      vim.api.nvim_create_autocmd("FileType", {
        group = utils.augroup("TreesitterStart"),
        callback = function(ev)
          if vim.g.vscode then
            return
          end
          if pcall(vim.treesitter.start, ev.buf) then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },

  -- Jump between functions, classes and parameters
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "User LazyFile",
    opts = {
      move = { set_jumps = true },
    },
    config = function(_, opts)
      require("nvim-treesitter-textobjects").setup(opts)
      local moves = {
        goto_next_start = { ["]a"] = "@parameter.outer", ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
        goto_next_end = { ["]A"] = "@parameter.outer", ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
        goto_previous_start = { ["[a"] = "@parameter.outer", ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
        goto_previous_end = { ["[A"] = "@parameter.outer", ["[F"] = "@function.outer", ["[C"] = "@class.outer" },
      }
      for method, keymaps in pairs(moves) do
        for key, query in pairs(keymaps) do
          vim.keymap.set({ "n", "x", "o" }, key, function()
            -- In diff mode, keep the built-in ]c/[c (next/previous change)
            if vim.wo.diff and key:find("[cC]") then
              return vim.cmd("normal! " .. key)
            end
            require("nvim-treesitter-textobjects.move")[method](query, "textobjects")
          end, { desc = method:gsub("_", " ") .. " " .. query })
        end
      end
    end,
  },

  -- Show flag around target positions and choose them to jump
  {
    "folke/flash.nvim",
    event = "CmdlineEnter",
    -- stylua: ignore
    keys = {
      { "f", mode = { "n", "x" } },
      { "F", mode = { "n", "x" } },
      { "t", mode = { "n", "x" } },
      { "T", mode = { "n", "x" } },
      { "s", "<Cmd>lua require('flash').jump()<CR>", mode = { "n", "x" }, desc = "Flash Jump" },
      { "S", "<Cmd>lua require('flash').treesitter()<CR>", mode = { "n", "o", "x" }, desc = "Flash Treesitter" },
      { "r", "<Cmd>lua require('flash').remote({restore=true})<CR>", mode = "o", desc = "Flash Remote" },
      { ";", "<Cmd>lua require('flash').treesitter({jump={pos='start'}})<CR>", mode = { "n", "o", "x" }, desc = "Outter Start Of Treesitter Node" },
      { ",", "<Cmd>lua require('flash').treesitter({jump={pos='end'}})<CR>", mode = { "n", "o", "x" }, desc = "Outter Start Of Treesitter Node" },
    },
    opts = {
      labels = "asdfghjklqwertyuiopzxcvbnm1234567890",
      label = {
        after = false,
        before = true,
      },
      modes = {
        char = {
          highlight = { backdrop = false },
          -- Exclude some motion and operator
          label = { exclude = "ryipasdhjklxcvYPSDJKXCV" },
          keys = { "f", "F", "t", "T" },
          jump_labels = true,
          autohide = true,
          jump = { autojump = true },
          char_actions = function(motion)
            return {
              [";"] = "next",
              [","] = "prev",
              [motion:lower()] = "right",
              [motion:upper()] = "left",
            }
          end,
        },
        treesitter = {
          -- Extra exclude `o`
          label = { exclude = "ryiopasdhjklxcvYPSDJKXCV" },
        },
      },
    },
    config = function(plugin, opts)
      require("flash").setup(opts)
      vim.keymap.del({ "o" }, "f", {})
      vim.keymap.del({ "o" }, "F", {})
      vim.keymap.del({ "o" }, "t", {})
      vim.keymap.del({ "o" }, "T", {})
    end,
  },
  -- Flash Telescope config
  {
    "nvim-telescope/telescope.nvim",
    optional = true,
    opts = {
      defaults = {
        mappings = {
          i = {
            ["<C-S>"] = keymap.flash_telescope,
          },
        },
      },
    },
  },

  -- Better text-objects
  {
    "nvim-mini/mini.ai",
    keys = {
      { "a", mode = { "x", "o" } },
      { "i", mode = { "x", "o" } },
      { "g[", mode = { "n", "x", "o" } },
      { "g]", mode = { "n", "x", "o" } },
    },
    init = function()
      -- Register all text objects with which-key
      utils.on_load("which-key.nvim", function()
        local objects = {
          { " ", desc = "whitespace" },
          { '"', desc = '" string' },
          { "'", desc = "' string" },
          { "(", desc = "() block" },
          { ")", desc = "() block with ws" },
          { "<", desc = "<> block" },
          { ">", desc = "<> block with ws" },
          { "?", desc = "user prompt" },
          { "U", desc = "use/call without dot" },
          { "[", desc = "[] block" },
          { "]", desc = "[] block with ws" },
          { "_", desc = "underscore" },
          { "`", desc = "` string" },
          { "a", desc = "argument" },
          { "b", desc = ")]} block" },
          { "c", desc = "class" },
          { "d", desc = "digit(s)" },
          { "e", desc = "CamelCase / snake_case" },
          { "f", desc = "function" },
          { "g", desc = "entire file" },
          { "i", desc = "indent" },
          { "o", desc = "block, conditional, loop" },
          { "q", desc = "quote `\"'" },
          { "t", desc = "tag" },
          { "u", desc = "use/call" },
          { "{", desc = "{} block" },
          { "}", desc = "{} with ws" },
        }

        local ret = { mode = { "o", "x" } }
        ---@type table<string, string>
        local mappings = vim.tbl_extend("force", {}, {
          around = "a",
          inside = "i",
          around_next = "an",
          inside_next = "in",
          around_last = "aN",
          inside_last = "iN",
        }, {})
        mappings.goto_left = nil
        mappings.goto_right = nil

        for name, prefix in pairs(mappings) do
          name = name:gsub("^around_", ""):gsub("^inside_", "")
          ret[#ret + 1] = { prefix, group = name }
          for _, obj in ipairs(objects) do
            local desc = obj.desc
            if prefix:sub(1, 1) == "i" then
              desc = desc:gsub(" with ws", "")
            end
            ret[#ret + 1] = { prefix .. obj[1], desc = obj.desc }
          end
        end
        require("which-key").add(ret, { notify = false })
      end)
    end,
    opts = function()
      local ai = require("mini.ai")
      return {
        mappings = {
          around_last = "aN",
          inside_last = "iN",
        },
        n_lines = 250,
        custom_textobjects = {
          -- Line
          l = { "^()%s*().*()%s*()\n$" },
          -- Entire buffer
          e = function()
            return {
              from = { line = 1, col = 1 },
              ---@diagnostic disable-next-line
              to = { line = vim.fn.line("$"), col = math.max(vim.fn.getline("$"):len(), 1) },
            }
          end,
          -- a = ai.gen_spec.treesitter({ a = "@parameter.outer", i = "@parameter.inner" }, {}),
          F = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
          o = ai.gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }, {}),
        },
      }
    end,
  },
}
