-- TODO: Add code documentation

local api = vim.api
local cmd = vim.cmd

local bufid, winid
local cmdheight = vim.o.cmdheight
local stats = api.nvim_list_uis()[1]

local config = {
	status = {
		enable = true,
		text = "Maximizer is active!",
		blend = 10,
		position = {
			top = true,
			left = false,
		},
	},
	keymap = {
		enable = true,
		modes = { "i", "n" },
		rhs = "<C-w>z",
	},
}

local get_win_dimesions = function(id)
	local width = api.nvim_win_get_width(id)
	local height = api.nvim_win_get_height(id)

	return width, height
end

local set_win_dimensions = function(id, width, height)
	api.nvim_win_set_width(id, width)
	api.nvim_win_set_height(id, height)
end

local show = function()
	local ids = api.nvim_list_wins()

	if #ids == 1 then
		return
	end

	local wins = {}

	for _, id in ipairs(ids) do
		local width, height = get_win_dimesions(id)

		table.insert(wins, {
			id = id,
			width = width,
			height = height,
		})
	end

	vim.g.maximizer = {
		active = true,
		wins = wins,
	}

	cmd("wincmd _ | wincmd |")

	if config.status.enable then
		local text = config.status.text
		local position = config.status.position

		local row = position.top and 1 or (stats.height - cmdheight - 1)
		local col = position.left and 1 or stats.width - 1

		local anchor = position.top and "N" or "S"
		anchor = ("%s%s"):format(anchor, position.left and "W" or "E")

		bufid = api.nvim_create_buf(false, true)

		winid = api.nvim_open_win(bufid, false, {
			relative = "editor",
			width = #text,
			height = 1,
			row = row,
			col = col,
			anchor = anchor,
			focusable = false,
			style = "minimal",
			zindex = nil,
			noautocmd = true,
		})

		api.nvim_win_set_option(winid, "winblend", config.status.blend)
		api.nvim_win_set_option(winid, "winhighlight", "Normal:MaximizerWin")
		api.nvim_buf_set_lines(bufid, 0, 30, false, { text })
		api.nvim_buf_add_highlight(bufid, -1, "MaximizerTitle", 0, 0, -1)
	end
end

local close = function(wins)
	local ids = api.nvim_list_wins()

	for _, win in ipairs(wins) do
		if vim.tbl_contains(ids, win.id) then
			set_win_dimensions(win.id, win.width, win.height)
		end
	end

	if #ids < #wins then
		cmd("wincmd _ | wincmd =")
	end

	vim.g.maximizer = {
		active = false,
		wins = {},
	}

	if config.status.enable then
		api.nvim_win_close(winid, { force = true })
		api.nvim_buf_delete(bufid, { force = true })

		winid = nil
		bufid = nil
	end
end

return {
	toggle = function()
		local maximizer = vim.g.maximizer

		if maximizer.active then
			close(maximizer.wins)
		else
			show()
		end
	end,
	setup = function(args)
		config = vim.tbl_deep_extend("force", config, args or {})

		if config.keymap.enable then
			for _, mode in ipairs(config.keymap.modes) do
				api.nvim_set_keymap(
					mode,
					config.keymap.rhs,
					[[<cmd>lua require("maximizer").toggle()<cr>]],
					{ silent = true }
				)
			end
		end

		cmd("highlight default link MaximizerTitle Title")
		cmd("highlight default link MaximizerWin Normal")
	end,
}
