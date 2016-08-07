
-- Functions.lua

-- Contains all the global functions used in this plugin





-- Loads all the catastrophes into g_Catastrophes
function LoadCatastrophes()
	local CurrentPath = cPluginManager:GetCurrentPlugin():GetLocalFolder() .. "/Catastrophes"
	local Catastrophes = cFile:GetFolderContents(CurrentPath)
	
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





-- Returns true if the given table is an array, otherwise it returns false
function table.isarray(a_Table)
	local i = 0
	for _, t in pairs(a_Table) do
		i = i + 1
		if (not rawget(a_Table, i)) then
			return false
		end
	end
	
	return true
end





-- Merges all values (except arrays) from a_DstTable into a_SrcTable if the key doesn't exist in a_SrcTable
function table.merge(a_SrcTable, a_DstTable)
	for Key, Value in pairs(a_DstTable) do
		if (not a_SrcTable[Key]) then
			a_SrcTable[Key] = Value
		elseif ((type(Value) == "table") and (type(a_SrcTable[Key]) == "table")) then
			if (not table.isarray(a_SrcTable[Key])) then
				table.merge(a_SrcTable[Key], Value)
			end
		end
	end
end




