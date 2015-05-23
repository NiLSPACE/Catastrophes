
-- catastrophe.lua

-- Contains the base class for a catastrophe.





-- Table containing all the active catastrophes. The catastrophe objects are the key in the table.
local g_ActiveCatastrophes = {}

-- Table containing all the possible catastrophes. The key is the name of the catastrophe, and the value is the constructor.
g_Catastrophes = {}





-- Add a table in g_ActiveCatastrophes for each world. The catastrophes are world-specific.
cRoot:Get():ForEachWorld(
	function(a_World)
		g_ActiveCatastrophes[a_World:GetName()] = {}
	end
)





cCatastrophe = {}





function cCatastrophe:new()
	local Obj = {}
	
	setmetatable(Obj, cCatastrophe)
	self.__index = self
	
	Obj.m_Position = Vector3d()
	Obj.m_Speed    = Vector3d()
	Obj.m_World    = ""
	
	return Obj
end





-- Loads the catastrophe into a world.
function cCatastrophe:ImportInWorld(a_World)
	self:OnImportWorld(a_World)
	
	-- Save the name of the world
	self.m_World = a_World:GetName()
	
	-- Save the catastrophe in the list with catastrophes. Since tables are references in Lua it will always stay up-to-date.
	g_ActiveCatastrophes[self.m_World][self] = true
	
end





-- Sets the speed of the catastrophe
function cCatastrophe:SetSpeed(a_SpeedX, a_SpeedZ)
	self.m_Speed.x = a_SpeedX
	self.m_Speed.z = a_SpeedZ
end





--- Adds speed above the current speed of the catastrophe
function cCatastrophe:AddSpeed(a_SpeedX, a_SpeedZ)
	self.m_Speed.x = self.m_Speed.x + a_SpeedX
	self.m_Speed.z = self.m_Speed.z + a_SpeedZ
end





-- Sets the current position of the catastrophe.
function cCatastrophe:SetPosition(a_PosX, a_PosZ)
	self.m_Position.x = a_PosX
	self.m_Position.z = a_PosZ
end





-- Returns the X-position of the catastrophe
function cCatastrophe:GetPosX()
	return self.m_Position.x
end





-- Returns the Z-position of the catastrophe
function cCatastrophe:GetPosZ()
	return self.m_Position.z
end





--- Makes the catastrophe move according to the speed it has.
function cCatastrophe:TickSpeed()
	self.m_Position = self.m_Position + self.m_Speed
end





-- Function that is called from ImportInWorld once the catastrophe is imported.
function cCatastrophe:OnImportWorld(a_World)
end





function cCatastrophe:Tick(a_World)
	self:TickSpeed()
end





-- Removes itself from the g_Catastrophes table.
function cCatastrophe:Destroy()
	g_ActiveCatastrophes[self.m_World][self] = nil
	collectgarbage("collect")
end





-- OnWorldTick hook that will tick all the catastrophes in the world.
function TickCatastrophes(a_World, a_TimeDelta)
	for Catastrophe in pairs(g_ActiveCatastrophes[a_World:GetName()]) do
		Catastrophe:Tick(a_World, a_TimeDelta)
	end
end




