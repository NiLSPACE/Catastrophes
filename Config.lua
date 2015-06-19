
-- Config.lua

-- Contains the functions to initialize and write the configuration file.





g_Config = {}





local g_DefaultConfig =
[[
-- Leave this empty if you don't want catastrophes to spawn naturaly
NaturalCatastrophes = {blackhole, drought, volcano},
MinSpawnInterval = 10000,
MaxSpawnInterval = 20000,

Worlds =
{
	"world"
}
]]





-- Writes the default configuration to a_Path (a string)
local function WriteDefaultConfiguration(a_Path)
	LOGWARNING("Default configuration written to \"" .. a_Path .. "\"")
	local File = io.open(a_Path, "w")
	File:write(g_DefaultConfig)
	File:close()
end





-- Returns the default configuration table
local function GetDefaultConfiguration()
	-- load the default configuration
	local Loader = loadstring("return {" .. g_DefaultConfig .. "}")
	
	-- With this the loader can use the catastrophes directly
	setfenv(Loader, g_Catastrophes)
	
	return Loader()
end





-- Sets g_Config to the default configuration
local function LoadDefaultConfiguration()
	LOGWARNING("The default configuration will be used.")
	g_Config = GetDefaultConfiguration()
end





function InitializeConfiguration(a_Path)
	local ConfigContent = cFile:ReadWholeFile(a_Path)
	
	-- The configuration file doesn't exist or is empty. Write and load the default value
	if (ConfigContent == "") then
		WriteDefaultConfiguration(a_Path)
		LoadDefaultConfiguration()
		return
	end
	
	local ConfigLoader, Err = loadstring("return {" .. ConfigContent .. "}")
	if (not ConfigLoader) then
		local ErrorPos = Err:match(":(.-):") or 0
		LOGWARNING("Error in the configuration file near line " .. ErrorPos)
		LoadDefaultConfiguration()
		return
	end
	
	-- With this the loader can use the catastrophes directly
	setfenv(ConfigLoader, g_Catastrophes)
	
	local Succes, Res = pcall(ConfigLoader)
	if (not Succes) then
		local ErrPos = Res:match(":(.-):") or 0
		LOGWARNING("Error in the configuration file near line " .. ErrorPos)
		LoadDefaultConfiguration()
		return
	end
	
	local DefaultConfig = GetDefaultConfiguration()
	table.merge(Res, DefaultConfig)
	
	g_Config = Res
end




