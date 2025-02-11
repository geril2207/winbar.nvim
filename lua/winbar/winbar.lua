local M = {}

local status_web_devicons_ok, web_devicons = pcall(require, "nvim-web-devicons")
local config = require("winbar.config").Config
local f = require("winbar.utils")

local hl_winbar_path = "WinBarPath"
local hl_winbar_file = "WinBarFile"
local hl_winbar_symbols = "WinBarSymbols"
local hl_winbar_file_icon = "WinBarFileIcon"

local api = vim.api

local winbar_mode = function()
	-- if not f.isempty(value) and f.get_buf_option('mod') then
	--     local mod = '%#LineNr#' .. opts.editor_state .. '%*'
	--     if gps_added then
	--         value = value .. ' ' .. mod
	--     else
	--         value = value .. mod
	--     end
	-- end

	-- value = value .. '%{%v:lua.winbar_gps()%}'
end

local function winbar_get_file_path(file_path)
	local file_path_list = {}
	local _ = string.gsub(file_path, "[^/]+", function(w)
		table.insert(file_path_list, w)
	end)

	local value = ""

	for i = 1, #file_path_list do
		if config.folder_icon then
			value = value .. "%#NvimTreeFolderIcon# %*"
		end
		value = value .. "%#" .. hl_winbar_path .. "#" .. file_path_list[i] .. " " .. config.icons.seperator .. " %*"
	end

	return value
end

local winbar_file = function()
	local file_path = vim.fn.expand("%:~:.:h")
	local filename = vim.fn.expand("%:t")
	local file_type = vim.fn.expand("%:e")
	local value = ""
	local file_icon = ""

	file_path = file_path:gsub("^%.", "")
	file_path = file_path:gsub("^%/", "")

	if config.left_spacing then
		local left_spacing_value

		if type(config.left_spacing) == "string" then
			left_spacing_value = config.left_spacing
		elseif type(config.left_spacing) == "function" then
			left_spacing_value = config.left_spacing()
		end

		value = left_spacing_value .. value
	end

	if not f.isempty(filename) then
		local default = false

		if f.isempty(file_type) then
			file_type = ""
			default = true
		end

		if status_web_devicons_ok then
			file_icon = web_devicons.get_icon(filename, file_type, { default = default })
			hl_winbar_file_icon = "DevIcon" .. file_type
		end

		if not file_icon then
			file_icon = config.icons.file_icon_default
		end

		file_icon = "%#" .. hl_winbar_file_icon .. "#" .. file_icon .. " %*"

		if config.show_file_path then
			value = value .. winbar_get_file_path(file_path)
		end
		value = value .. file_icon
		value = value .. "%#" .. hl_winbar_file .. "#" .. filename .. "%*"
	end

	return value
end

local _, gps = pcall(require, "nvim-gps")
local winbar_gps = function()
	local status_ok, gps_location = pcall(gps.get_location, {})
	local value = ""

	if status_ok and gps.is_available() and gps_location ~= "error" and not f.isempty(gps_location) then
		value = "%#" .. hl_winbar_symbols .. "# " .. config.icons.seperator .. " %*"
		value = value .. "%#" .. hl_winbar_symbols .. "#" .. gps_location .. "%*"
	end

	return value
end

local excludes = function()
	if vim.tbl_contains(config.exclude_filetype, vim.bo.filetype) then
		vim.opt_local.winbar = nil
		return true
	end

	return false
end

M.init = function()
	if f.isempty(config.colors.path) then
		hl_winbar_path = "MsgArea"
	else
		vim.api.nvim_set_hl(0, hl_winbar_path, { fg = config.colors.path })
	end

	if f.isempty(config.colors.file_name) then
		hl_winbar_file = "String"
	else
		vim.api.nvim_set_hl(0, hl_winbar_file, { fg = config.colors.file_name })
	end

	if f.isempty(config.colors.symbols) then
		hl_winbar_symbols = "Function"
	else
		vim.api.nvim_set_hl(0, hl_winbar_symbols, { fg = config.colors.symbols })
	end
end

M.show_winbar = function()
	if excludes() then
		return
	end

	local value = winbar_file()

	if config.show_symbols then
		if not f.isempty(value) then
			local gps_value = winbar_gps()
			value = value .. gps_value
		end
	end

	local status_ok, _ = pcall(vim.api.nvim_set_option_value, "winbar", value, { scope = "local" })
	if not status_ok then
		return
	end
end

return M
