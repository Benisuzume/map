local Path = require ('map.path')
local Utils = require ('map.utils')

return function (state)
	local build = Utils.load_files (state.settings.input.build, '%.lua$')
	local settings = Utils.deep_copy (state.settings)
	state.environment.settings = Utils.read_only (settings)

	-- Run user build scripts.
	do
		local messages = {}

		for _, file in ipairs (build) do
			if Path.is_file (file) then
				local chunk, message = loadfile (file)

				if chunk then
					chunk (state.environment)
				else
					table.insert (messages, message)
				end
			end
		end

		if #messages > 0 then
			table.insert (messages, 1, 'error:')
			return nil, table.concat (messages, '\n\t')
		end
	end

	return true
end
