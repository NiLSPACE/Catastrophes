




function Initialize(a_Plugin)
	a_Plugin:SetName(g_PluginInfo.Name)
	a_Plugin:SetVersion(g_PluginInfo.Version)
	
	cPluginManager:AddHook(cPluginManager.HOOK_WORLD_TICK, TickCatastrophes)
	
	-- Load all the known catastrophes into g_Catastrophes.
	LoadCatastrophes()
	
	-- Load the configuration
	InitializeConfiguration(a_Plugin:GetLocalFolder() .. "/config.cfg")
	
	-- Initializes the natural catastrophe spawner
	InitializeSpawner()
	
	-- Load the InfoReg library file for registering the Info.lua command table:
	dofile(cPluginManager:GetPluginsPath() .. "/InfoReg.lua")
	
	-- Register commands:
	RegisterPluginInfoCommands()
	
	LOG(g_PluginInfo.Name .. " v." .. g_PluginInfo.Version .. " has initialized")
	return true
end




