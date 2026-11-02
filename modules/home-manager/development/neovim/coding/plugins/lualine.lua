require("core.statusline").setup({
  components = {
    {
      function()
        local ok, dap = pcall(require, "dap")

        if not ok then
          return ""
        end

        local session = dap.session()

        if not session then
          return ""
        end

        if session.stopped_thread_id then
          return " Stopped"
        end

        return " Running"
      end,
    },
  },
  extensions = { "nvim-dap-ui" },
})
