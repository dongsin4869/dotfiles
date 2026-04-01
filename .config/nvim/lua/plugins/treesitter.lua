-- Highlight, edit, and navigate code
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({})

      -- Install parsers
      require("nvim-treesitter").install({
        "lua",
        "python",
        "fortran",
        "c",
        "cpp",
        "javascript",
        "typescript",
        "vimdoc",
        "vim",
        "regex",
        "terraform",
        "dockerfile",
        "toml",
        "json",
        "java",
        "groovy",
        "go",
        "gitignore",
        "graphql",
        "yaml",
        "make",
        "cmake",
        "latex",
        "markdown",
        "markdown_inline",
        "bash",
        "tsx",
        "css",
        "html",
        "diff",
      })

      -- Enable treesitter highlighting and indentation for all filetypes
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })

      -- Register additional file extensions
      vim.filetype.add({ extension = { tf = "terraform" } })
      vim.filetype.add({ extension = { tfvars = "terraform" } })
      vim.filetype.add({ extension = { pipeline = "groovy" } })
      vim.filetype.add({ extension = { multibranch = "groovy" } })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = {
          lookahead = true,
        },
        move = {
          set_jumps = true,
        },
      })

      -- Select keymaps
      local select_fn = function(query)
        return function()
          require("nvim-treesitter-textobjects.select").select_textobject(query, "textobjects")
        end
      end
      vim.keymap.set({ "x", "o" }, "aa", select_fn("@parameter.outer"))
      vim.keymap.set({ "x", "o" }, "ia", select_fn("@parameter.inner"))
      vim.keymap.set({ "x", "o" }, "af", select_fn("@function.outer"))
      vim.keymap.set({ "x", "o" }, "if", select_fn("@function.inner"))
      vim.keymap.set({ "x", "o" }, "ac", select_fn("@class.outer"))
      vim.keymap.set({ "x", "o" }, "ic", select_fn("@class.inner"))

      -- Move keymaps
      local move = require("nvim-treesitter-textobjects.move")
      vim.keymap.set({ "n", "x", "o" }, "]m", function() move.goto_next_start("@function.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "]]", function() move.goto_next_start("@class.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "]M", function() move.goto_next_end("@function.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "][", function() move.goto_next_end("@class.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "[m", function() move.goto_previous_start("@function.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "[[", function() move.goto_previous_start("@class.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "[M", function() move.goto_previous_end("@function.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "[]", function() move.goto_previous_end("@class.outer", "textobjects") end)

      -- Swap keymaps
      vim.keymap.set("n", "<leader>a", function()
        require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner")
      end)
      vim.keymap.set("n", "<leader>A", function()
        require("nvim-treesitter-textobjects.swap").swap_previous("@parameter.inner")
      end)
    end,
  },
}
