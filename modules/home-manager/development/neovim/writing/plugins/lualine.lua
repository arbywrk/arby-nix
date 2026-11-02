require("core.statusline").setup({
  components = {
    {
      function()
        local count = vim.fn.wordcount()
        return (count.visual_words or count.words) .. " words"
      end,
    },
  },
})
