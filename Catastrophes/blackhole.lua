




-- cBlackHole extends cCatastrophe
local cBlackHole = setmetatable({}, cCatastrophe)





-- local functions can be accesed faster
local random = math.random
local abs    = math.abs
local max    = math.max





function cBlackHole:new()
	local Obj = cCatastrophe:new()
	
	setmetatable(Obj, cBlackHole)
	self.__index = self
	
	-- A black hole doesn't move
	Obj:SetSpeed(0, 0, 0)
	
	Obj.m_ActiveTime = random(2000, 3000)
	
	Obj.m_Size = random(30, 40)
	
	-- Will be initialized on import world
	Obj.m_ActiveArea = nil
	
	return Obj
end





function cBlackHole:OnImportWorld(a_World)
	local Succes, Height = a_World:TryGetHeight(self:GetPosX(), self:GetPosZ())
	self.m_Position.y = (Height or 64) + random(5, 10)
	
	self.m_ActiveArea = cBoundingBox(
		self:GetPosX() - self.m_Size, self:GetPosX() + self.m_Size, 
		self.m_Position.y - self.m_Size, self.m_Position.y + self.m_Size, 
		self:GetPosZ() - self.m_Size, self:GetPosZ() + self.m_Size
	)
end





-- Creates falling block entities around the black hole from the terrain.
function cBlackHole:RipGround(a_World)
	local NumNewFallingBlocks = random(20, 30)
	local StartX, EndX = self:GetPosX() - self.m_Size, self:GetPosX() + self.m_Size
	local StartZ, EndZ = self:GetPosZ() - self.m_Size, self:GetPosZ() + self.m_Size
	for I = 1, NumNewFallingBlocks do
		local X = (random(StartX, EndX) + random(StartX, EndX) + random(StartX, EndX) + random(StartX, EndX)) / 4
		local Z = (random(StartZ, EndZ) + random(StartZ, EndZ) + random(StartZ, EndZ) + random(StartZ, EndZ)) / 4
		local Succes, Height = a_World:TryGetHeight(X, Z)
		if (Succes) then
			local IsValid, BlockType, BlockMeta = a_World:GetBlockTypeMeta(X, Height, Z)
			a_World:DigBlock(X, Height, Z)
			a_World:DoWithEntityByID(a_World:SpawnFallingBlock(X + 0.5, Height + 1.5, Z + 0.5, BlockType, BlockMeta),
				function(a_Entity)
					a_Entity:SetSpeedY(4)
				end
			)
		end
	end
end





function cBlackHole:Tick(a_World, a_TimeDelta)
	if (self.m_ActiveTime == 0) then
		self:Destroy()
		return
	end
	
	local IsValid, WorldHeight = a_World:TryGetHeight(self:GetPosX(), self:GetPosZ())
	if (not IsValid) then
		self:Destroy()
		return
	end
	
	-- Create particles at the blackhole
	a_World:BroadcastParticleEffect("smoke", self:GetPosX(), self.m_Position.y, self:GetPosZ(), random()*random(), random()*random(), random()*random(), 0.5, 15)
	
	-- Suck all the entities in the area towards the blackhole
	-- TODO: Currently the entities are pulled more when they are further from the black hole. They should be pulled more when close to the black hole.
	a_World:ForEachEntityInBox(self.m_ActiveArea,
		function(a_Entity)
			local Distance = (a_Entity:GetPosition() - self.m_Position):Length()
			if ((Distance < 2) and not a_Entity:IsPlayer()) then
				a_Entity:Destroy()
				return false
			end
			
			local NewSpeed = (self.m_Position - a_Entity:GetPosition()):NormalizeCopy()
			if (a_Entity:IsPlayer()) then
				NewSpeed = NewSpeed / 8
			else
				NewSpeed = NewSpeed * 1.75
			end
			a_Entity:AddSpeed(NewSpeed)
		end
	)
	
	-- Rip the ground apart around the blackhole.
	self:RipGround(a_World)
	
	-- Clear everything around the black hole
	local BA = cBlockArea()
	BA:Create(10, 10, 10)
	BA:Write(a_World, self:GetPosX() - 5, self.m_Position.y - 5, self:GetPosZ() - 5)
	
	self.m_ActiveTime = self.m_ActiveTime - 1
end





return cBlackHole
