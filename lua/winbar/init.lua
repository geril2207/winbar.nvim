local config = require("winbar.config")

local M = {}

function M.setup(opts)
	config.setup(opts)
	local winbar = require("winbar.winbar")

	winbar.init()
	if config.Config.enabled == true and config.Config.change_events then
		vim.api.nvim_create_autocmd(config.Config.change_events, {
			callback = function()
				winbar.show_winbar()
			end,
		})
	end
end

return M
