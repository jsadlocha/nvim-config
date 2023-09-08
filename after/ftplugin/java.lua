local fn = vim.fn
local api = vim.api
local keymap = vim.keymap
local lsp = vim.lsp
local diagnostic = vim.diagnostic

local bundles = {
  vim.fn.glob('~/.install/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-0.49.0.jar')
}

local config = {
    cmd = {'/home/hardware/.config/jdtls/bin/jdtls'},
    root_dir = vim.fs.dirname(vim.fs.find({'gradlew', '.git', 'mvnw'}, { upward = true })[1]),
    on_attach = function(client, bufnr)
      require('jdtls').setup_dap({ hotcodereplace = 'auto' })
      -- Mappings.
      local map = function(mode, l, r, opts)
        opts = opts or {}
        opts.silent = true
        opts.buffer = bufnr
        keymap.set(mode, l, r, opts)
      end

      map("n", "gd", vim.lsp.buf.definition, { desc = "go to definition" })
      map("n", "<C-]>", vim.lsp.buf.definition)
      map("n", "K", vim.lsp.buf.hover)
      map("n", "<C-k>", vim.lsp.buf.signature_help)
      map("n", "<space>rn", vim.lsp.buf.rename, { desc = "varialbe rename" })
      map("n", "gr", vim.lsp.buf.references, { desc = "show references" })
      map("n", "[d", diagnostic.goto_prev, { desc = "previous diagnostic" })
      map("n", "]d", diagnostic.goto_next, { desc = "next diagnostic" })
      -- this puts diagnostics from opened files to quickfix
      map("n", "<space>qw", diagnostic.setqflist, { desc = "put window diagnostics to qf" })
      -- this puts diagnostics from current buffer to quickfix
      map("n", "<space>qb", function() set_qflist(bufnr) end, { desc = "put buffer diagnostics to qf" })
      map("n", "<space>ca", vim.lsp.buf.code_action, { desc = "LSP code action" })
      map("n", "<space>wa", vim.lsp.buf.add_workspace_folder, { desc = "add workspace folder" })
      map("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, { desc = "remove workspace folder" })
      map("n", "<space>wl", function()
        inspect(vim.lsp.buf.list_workspace_folders())
      end, { desc = "list workspace folder" })

      -- Set some key bindings conditional on server capabilities
      if client.server_capabilities.documentFormattingProvider then
        map("n", "<space>f", vim.lsp.buf.format, { desc = "format code" })
      end

      api.nvim_create_autocmd("CursorHold", {
        buffer = bufnr,
        callback = function()
          local float_opts = {
            focusable = false,
            close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
            border = "rounded",
            source = "always", -- show source in diagnostic popup window
            prefix = " ",
          }

          if not vim.b.diagnostics_pos then
            vim.b.diagnostics_pos = { nil, nil }
          end

          local cursor_pos = api.nvim_win_get_cursor(0)
          if (cursor_pos[1] ~= vim.b.diagnostics_pos[1] or cursor_pos[2] ~= vim.b.diagnostics_pos[2])
              and #diagnostic.get() > 0
          then
            diagnostic.open_float(nil, float_opts)
          end

          vim.b.diagnostics_pos = cursor_pos
        end,
      })

      -- The blow command will highlight the current variable and its usages in the buffer.
      if client.server_capabilities.documentHighlightProvider then
        vim.cmd([[
          hi! link LspReferenceRead Visual
          hi! link LspReferenceText Visual
          hi! link LspReferenceWrite Visual
        ]])

        local gid = api.nvim_create_augroup("lsp_document_highlight", { clear = true })
        api.nvim_create_autocmd("CursorHold" , {
          group = gid,
          buffer = bufnr,
          callback = function ()
            lsp.buf.document_highlight()
          end
        })

        api.nvim_create_autocmd("CursorMoved" , {
          group = gid,
          buffer = bufnr,
          callback = function ()
            lsp.buf.clear_references()
          end
        })
      end

      if vim.g.logging_level == "debug" then
        local msg = string.format("Language server %s started!", client.name)
        vim.notify(msg, vim.log.levels.DEBUG, { title = "Nvim-config" })
      end
    end,
    init_options = {
      bundles = bundles
    },
}
require('jdtls').start_or_attach(config)

vim.keymap.set('n', '<F9>', function()
  vim.cmd("split | term java %")
end, { desc = "Run Program" })
