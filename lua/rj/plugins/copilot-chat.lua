return {
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		dependencies = {
			{ "github/copilot.vim" }, -- or zbirenbaum/copilot.lua
			{ "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
		},
		build = "make tiktoken", -- Only on MacOS or Linux
		opts = {
			-- Plugin-specific options (if any)
		},
		config = function()
			-- Require and configure the plugin
			require("CopilotChat").setup({
				-- Plugin options
			})

			-- Add keymaps here
			local map = vim.api.nvim_set_keymap
			local opts = { noremap = true, silent = true }

			-- Example Keymaps
			map("n", "<leader>cc", ":CopilotChat<CR>", opts) -- Open Copilot Chat
			map("n", "<leader>cq", ":CopilotChatClose<CR>", opts) -- Close Copilot Chat
			map("n", "<leader>cr", ":CopilotChatRequest<CR>", opts) -- Send request to Copilot Chat
		end,
	},
}
