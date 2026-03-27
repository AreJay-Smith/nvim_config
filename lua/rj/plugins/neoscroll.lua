return {
	"karb94/neoscroll.nvim",
	config = function()
		local neoscroll = require("neoscroll")

		neoscroll.setup({
			mappings = {},
			easing = "quadratic",
		})

		local keymap = {
			["<C-u>"] = function() neoscroll.ctrl_u({ duration = 250, easing = "sine" }) end,
			["<C-d>"] = function() neoscroll.ctrl_d({ duration = 250, easing = "sine" }) end,
			["<C-b>"] = function() neoscroll.ctrl_b({ duration = 450, easing = "circular" }) end,
			["<C-f>"] = function() neoscroll.ctrl_f({ duration = 450, easing = "circular" }) end,
		}

		local modes = { "n", "v", "x" }
		for key, func in pairs(keymap) do
			vim.keymap.set(modes, key, func)
		end
	end,
}
