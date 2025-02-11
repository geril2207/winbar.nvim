local M = {}

---@class WinbarConfig
---@field left_spacing nil|function|string
M.defaults = {
	enabled = false,
	change_events = { "DirChanged", "CursorMoved", "BufWinEnter", "BufFilePost", "InsertEnter", "BufWritePost" },

	show_file_path = true,
	folder_icon = true,
	left_spacing = nil,
	show_symbols = true,

	colors = {
		path = "",
		file_name = "",
		symbols = "",
	},

	icons = {
		file_icon_default = "",
		seperator = ">",
		editor_state = "●",
		lock_icon = "",
	},

	exclude_filetype = {
		"help",
		"startify",
		"dashboard",
		"packer",
		"neogitstatus",
		"NvimTree",
		"Trouble",
		"alpha",
		"lir",
		"Outline",
		"spectre_panel",
		"toggleterm",
		"qf",
	},
}

---@class WinbarConfig
M.Config = {}

function M.setup(config)
	M.Config = vim.tbl_deep_extend("force", {}, M.defaults, config or {})
end

return M
