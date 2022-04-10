local api = vim.api

local M = {}

M.toggle = function()
	local maximizer = vim.g.maximizer
	local ids = api.nvim_list_wins()

	if maximizer.active then
		for _, win in ipairs(maximizer.wins) do
			if vim.tbl_contains(ids, win.id) then
				api.nvim_win_set_width(win.id, win.width)
				api.nvim_win_set_height(win.id, win.height)
			end
		end

		if #ids < #maximizer.wins then
			vim.cmd("wincmd _ | wincmd =")
		end

		vim.g.maximizer = {
			active = false,
			wins = {},
		}

		return
	end

	if #ids == 1 then
		return
	end

	local stats = api.nvim_list_uis()[1]
	local wins = {}

	for _, id in ipairs(ids) do
		table.insert(wins, {
			id = id,
			width = api.nvim_win_get_width(id),
			height = api.nvim_win_get_height(id),
		})
	end

	vim.g.maximizer = {
		active = true,
		wins = wins,
	}

	api.nvim_win_set_width(0, stats.width)
	api.nvim_win_set_height(0, stats.height - vim.o.cmdheight)
end

return M
