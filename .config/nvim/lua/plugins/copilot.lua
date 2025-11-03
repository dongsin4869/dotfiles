return {
  "zbirenbaum/copilot.lua",
  event = "InsertEnter",
  opts = {
    suggestion = {
      enabled = true,
      auto_trigger = true,
      debounce = 75,
      keymap = {
        accept = "<leader>p",
        dismiss = "<Esc>",
      },
    },
    panel = { enabled = false },
    filetypes = {
      ["*"] = true,
    },
  },
}
