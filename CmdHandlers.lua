
-- CmdHandler.lua

-- Contains all the command handlers





function HandleCatastropheCommand(a_Split, a_Player)
	-- /catastrophe <catastrophe>
	
	-- No name was given. Send the usage of the catastrophe plugin, and a list of available catastrophes.
	if (not a_Split[2]) then
		a_Player:SendMessage("Usage: " .. a_Split[1] .. " <catastrophe>")
		
		local msg = " Catastrophes: "
		for Catastrophe in pairs(g_Catastrophes) do
			msg = msg .. Catastrophe .. ", "
		end
		msg = msg:sub(1, -3)
		
		a_Player:SendMessage(msg)
		return true
	end
	
	local CatastropheName = table.concat(a_Split, " ", 2)
	local Catastrophe = g_Catastrophes[CatastropheName:lower()]
	
	if (not Catastrophe) then
		a_Player:SendMessage("Unknown catastrophe")
		return true
	end
	
	local CurrentPosition = a_Player:GetPosition():Floor()
	
	local CatastropheObj = Catastrophe:new()
	CatastropheObj:SetPosition(CurrentPosition.x, CurrentPosition.z)
	CatastropheObj:ImportInWorld(a_Player:GetWorld())
	
	a_Player:SendMessage("You summoned a catastrophe")
	return true
end



