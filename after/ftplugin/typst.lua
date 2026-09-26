-- ┌───────────────────────┐
-- │ Typst filetype config │
-- └───────────────────────┘
--
-- This applies only to Typst ('*.typ') files. It provides buffer-local mappings
-- for 'chomosuke/typst-preview.nvim' (configured in 'plugin/40_plugins.lua').
-- The preview must be started inside a saved '.typ' buffer.

local map = function(lhs, rhs, desc)
  vim.keymap.set('n', lhs, rhs, { buffer = 0, desc = desc })
end

map('<Leader>lp', '<Cmd>TypstPreviewToggle<CR>',             'Preview toggle')
map('<Leader>lP', '<Cmd>TypstPreviewStop<CR>',               'Preview stop')
map('<Leader>lc', '<Cmd>TypstPreviewFollowCursorToggle<CR>', 'Preview follow cursor (toggle)')
map('<Leader>lC', '<Cmd>TypstPreviewSyncCursor<CR>',         'Preview sync to cursor')
