local M = {}

function M.generate(close_floating_window)
	vim.ui.input({ prompt = "New serializer name: " }, function(serializer_name)
		if serializer_name ~= nil then
			local generate_command = { "bin/rails", "generate", "serializer", serializer_name }
			local nvim_notify_ok, nvim_notify = pcall(require, "notify")
			if nvim_notify_ok then
				nvim_notify(
					"Command: bin/rails generate serializer " .. serializer_name .. "...",
					"warn",
					{ title = "Generating serializer...", timeout = false }
				)
			else
				vim.notify("Generating serializer...")
			end

			vim.fn.jobstart(generate_command, {
				stdout_buffered = true,
				on_stdout = function(_, data)
					if not data then
						return
					end

					local parsed_data = {}
					for i, v in ipairs(data) do
						parsed_data[i] = string.gsub(v, "^%s*(.-)%s*$", "%1")
					end

					if nvim_notify_ok then
						nvim_notify.dismiss()
						nvim_notify(
							parsed_data,
							vim.log.levels.INFO,
							{ title = "Serializer generated successfully!", timeout = 5000 }
						)
					else
						vim.notify("Serializer generated successfully!")
					end
				end,
				on_stderr = function(_, error)
					if error[1] ~= "" then
						print("Error: ")
						print(vim.inspect(error))
					end
				end,
			})
			close_floating_window()
		else
			close_floating_window()
		end
	end)
end

return M
