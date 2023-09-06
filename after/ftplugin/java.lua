local config = {
    cmd = {'/home/hardware/.config/jdtls/bin/jdtls'},
    root_dir = vim.fs.dirname(vim.fs.find({'gradlew', '.git', 'mvnw'}, { upward = true })[1]),
}
require('jdtls').start_or_attach(config)

vim.keymap.set('n', '<F9>', function()
  vim.cmd("split | term java %")
end, { desc = "Run Program" })
