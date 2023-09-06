local bundles = {
  vim.fn.glob('~/.install/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-0.49.0.jar')
}

local config = {
    cmd = {'/home/hardware/.config/jdtls/bin/jdtls'},
    root_dir = vim.fs.dirname(vim.fs.find({'gradlew', '.git', 'mvnw'}, { upward = true })[1]),
    on_attach = function(client, bufnr)
      require('jdtls').setup_dap({ hotcodereplace = 'auto' })
    end,
    init_options = {
      bundles = bundles
    },
}
require('jdtls').start_or_attach(config)

vim.keymap.set('n', '<F9>', function()
  vim.cmd("split | term java %")
end, { desc = "Run Program" })
