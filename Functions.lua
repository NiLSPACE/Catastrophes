
-- Functions.lua

-- Contains all the global functions used in this plugin





-- Loads all the catastrophes into g_Catastrophes
function LoadCatastrophes()
	local CurrentPath = cPluginManager:GetCurrentPlugin():GetLocalFolder() .. "/Catastrophes"
	local Catastrophes = cFile:GetFolderContents(CurrentPath)
	
	-- First 2 values are "." and "..". We don't need that.
	table.remove(Catastrophes, 1); table.remove(Catastrophes, 1)
	
	for Idx, Catastrophe in ipairs(Catastrophes) do
		local Name = Catastrophe:sub(1, -5)
		local F, Err = loadfile(CurrentPath .. "/" .. Catastrophe)
		if (not F) then
			LOGWARNING(Err)
		else
			local Succes, Class = pcall(F)
			if (not Succes) then
				LOGWARNING("Error in " .. Name .. ": " .. Class)
			else
				g_Catastrophes[Name:lower()] = Class
			end
		end
	end
end




