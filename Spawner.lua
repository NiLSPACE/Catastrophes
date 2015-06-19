
-- Spawner.lua

-- Contains the functions to initialize the natural catastrophe spawner





local g_Worlds = {}





function InitializeWorlds()
	local function CanSpawnInWorld(a_WorldName)
		for Idx, WorldName in ipairs(g_Config.Worlds) do
			if (a_WorldName == WorldName) then
				return true
			end
		end
		return false
	end
	
	cRoot:Get():ForEachWorld(
		function(a_World)
			if (CanSpawnInWorld(a_World:GetName())) then
				g_Worlds[a_World:GetName()] = math.random(g_Config.MinSpawnInterval, g_Config.MaxSpawnInterval)
			end
		end
	)
end




function InitializeSpawner()
	if (#g_Config.NaturalCatastrophes == 0) then
		-- No catastrophes to spawn naturaly, so se can bail out here
		return
	end
	
	-- Initialize all the world where the admin wants catastrophes natural spawning
	InitializeWorlds()
	
	-- Register the spawner
	cPluginManager:AddHook(cPluginManager.HOOK_WORLD_TICK, CatastropheSpawner)
end





function CatastropheSpawner(a_World)
	local WorldName = a_World:GetName()
	if (not g_Worlds[WorldName]) then
		return
	end
	
	if (g_Worlds[WorldName] ~= 0) then
		g_Worlds[WorldName] = g_Worlds[WorldName] - 1
		return
	end
	
	-- Pick a random new interval
	g_Worlds[WorldName] = math.random(g_Config.MinSpawnInterval, g_Config.MaxSpawnInterval)
	
	local NumPlayers = 0
	a_World:ForEachPlayer(
		function()
			NumPlayers = NumPlayers + 1
		end
	)
	
	local PlayerChoosen = math.random(NumPlayers)
	local CurrentPlayer = 1
	a_World:ForEachPlayer(
		function(a_Player)
			if (CurrentPlayer == PlayerChoosen) then
				-- Choose a position around the player
				local PosX = a_Player:GetPosX() + math.random(-150, 150)
				local PosZ = a_Player:GetPosZ() + math.random(-150, 150)
				
				local Catastrophe = g_Config.NaturalCatastrophes[math.random(#g_Config.NaturalCatastrophes)]:new()
				Catastrophe:SetPosition(PosX, PosZ)
				Catastrophe:ImportInWorld(a_World)
				
				a_World:BroadcastChat("A " .. tostring(Catastrophe) .. " has spawned")
				return true
			end
			
			CurrentPlayer = CurrentPlayer + 1
		end
	)
end




