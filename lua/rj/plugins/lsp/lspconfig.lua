return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function()
		-- import cmp-nvim-lsp plugin
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		local keymap = vim.keymap -- for conciseness

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				local function is_basedpyright(client_id)
					local client = vim.lsp.get_client_by_id(client_id)
					return client and client.name == "basedpyright"
				end

				local function apply_basedpyright_import(bufnr)
					local params = vim.lsp.util.make_range_params(0, "utf-16")
					params.context = { only = { "quickfix" }, diagnostics = vim.diagnostic.get(bufnr) }

					vim.lsp.buf_request_all(bufnr, "textDocument/codeAction", params, function(results)
						local selected
						local selected_client

						for client_id, response in pairs(results or {}) do
							if is_basedpyright(client_id) and response and response.result then
								for _, action in ipairs(response.result) do
									local title = (action.title or ""):lower()
									if title:find("import", 1, true) then
										selected = action
										selected_client = vim.lsp.get_client_by_id(client_id)
										break
									end
								end
							end
							if selected then
								break
							end
						end

						if not selected then
							vim.notify("No basedpyright import action here. Try <C-Space> and accept an auto-import completion.", vim.log.levels.INFO)
							return
						end

						if selected.edit then
							vim.lsp.util.apply_workspace_edit(selected.edit, selected_client and selected_client.offset_encoding or "utf-16")
						end

						if selected.command then
							local command = selected.command
							if type(command) == "table" then
								vim.lsp.buf.execute_command(command)
							else
								vim.lsp.buf.execute_command({ command = command, arguments = selected.arguments })
							end
						end
					end)
				end

				-- Buffer local mappings.
				-- See `:help vim.lsp.*` for documentation on any of the below functions
				local opts = { buffer = ev.buf, silent = true }

				-- set keybinds
				opts.desc = "Show LSP references"
				keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

				opts.desc = "Go to declaration"
				keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

				opts.desc = "Show LSP definitions"
				keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

				opts.desc = "Show LSP implementations"
				keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

				opts.desc = "Show LSP type definitions"
				keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

				opts.desc = "All code actions"
				keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

				opts.desc = "Basedpyright code actions"
				keymap.set({ "n", "v" }, "<leader>cp", function()
					vim.lsp.buf.code_action({
						filter = function(_, client_id)
							return is_basedpyright(client_id)
						end,
					})
				end, opts)

				opts.desc = "Add missing import"
				keymap.set("n", "<leader>ci", function()
					apply_basedpyright_import(ev.buf)
				end, opts)

				opts.desc = "Smart rename"
				keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

				opts.desc = "Show buffer diagnostics"
				keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

				opts.desc = "Show line diagnostics"
				keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

				opts.desc = "Go to previous diagnostic"
				keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

				opts.desc = "Go to next diagnostic"
				keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

				opts.desc = "Show documentation for what is under cursor"
				keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

				opts.desc = "Restart LSP"
				keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
			end,
		})

		-- used to enable autocompletion (assign to every lsp server config)
		local capabilities = cmp_nvim_lsp.default_capabilities()

		-- Change diagnostic symbols in the sign column (Neovim 0.11+ style)
		vim.diagnostic.config({
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = " ",
					[vim.diagnostic.severity.WARN] = " ",
					[vim.diagnostic.severity.HINT] = "󰠠 ",
					[vim.diagnostic.severity.INFO] = " ",
				},
			},
		})

		local servers = {
			"ts_ls",
			"html",
			"cssls",
			"tailwindcss",
			"lua_ls",
			"gopls",
			"basedpyright",
			"ruff",
		}

		for _, server in ipairs(servers) do
			vim.lsp.config(server, {
				capabilities = capabilities,
			})
		end

		-- configure lua server (with special settings)
		vim.lsp.config("lua_ls", {
			capabilities = capabilities,
			settings = {
				Lua = {
					-- make the language server recognize "vim" global
					diagnostics = {
						globals = { "vim" },
					},
					completion = {
						callSnippet = "Replace",
					},
				},
			},
		})

		-- configure gopls server
		vim.lsp.config("gopls", {
			capabilities = capabilities,
			cmd = { "gopls" },
			filetypes = { "go", "gomod", "gowork", "gotmpl" },
		})

		-- configure basedpyright server
		vim.lsp.config("basedpyright", {
			capabilities = capabilities,
			settings = {
				basedpyright = {
					analysis = {
						autoImportCompletions = true,
						autoSearchPaths = true,
						diagnosticMode = "workspace",
						reportUndefinedVariable = "error",
						useLibraryCodeForTypes = true,
					},
				},
			},
		})

		for _, server in ipairs(servers) do
			vim.lsp.enable(server)
		end
	end,
}
