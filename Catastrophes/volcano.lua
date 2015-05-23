




-- cVolcano extends cCatastrophe
local cVolcano = setmetatable({}, cCatastrophe)





-- All the blocks the volcano will spew out. Stone is in here allot, so the volcano is more likely to spew out stone.
local g_Blocks = 
{
	E_BLOCK_STONE, E_BLOCK_STONE, E_BLOCK_STONE, E_BLOCK_STONE, E_BLOCK_STONE,
	E_BLOCK_STONE, E_BLOCK_STONE, E_BLOCK_STONE, E_BLOCK_STONE, E_BLOCK_STONE,
	E_BLOCK_STONE, E_BLOCK_STONE, E_BLOCK_STONE, E_BLOCK_STONE, E_BLOCK_STONE,
	E_BLOCK_STONE, E_BLOCK_STONE, E_BLOCK_STONE, E_BLOCK_STONE, E_BLOCK_STONE,
	E_BLOCK_STONE, E_BLOCK_STONE, E_BLOCK_STONE, E_BLOCK_STONE, E_BLOCK_STONE,
	E_BLOCK_OBSIDIAN, E_BLOCK_OBSIDIAN, E_BLOCK_OBSIDIAN, E_BLOCK_OBSIDIAN, 
	E_BLOCK_OBSIDIAN, E_BLOCK_OBSIDIAN, E_BLOCK_OBSIDIAN, E_BLOCK_OBSIDIAN, 
	E_BLOCK_IRON_ORE, E_BLOCK_IRON_ORE, E_BLOCK_IRON_ORE,
	E_BLOCK_GOLD_ORE, E_BLOCK_GOLD_ORE,
	E_BLOCK_DIAMOND_ORE,
	E_BLOCK_FIRE,
	E_BLOCK_LAVA
}

-- Save the number of blocks. This way we don't have to count the number of blocks every time.
local g_NumBlocks = #g_Blocks





-- All the plants with the block they will be replaced with.
local g_Plants =
{
	[E_BLOCK_LEAVES]           = E_BLOCK_FIRE,
	[E_BLOCK_NEW_LEAVES]       = E_BLOCK_FIRE,
	[E_BLOCK_TALL_GRASS]       = E_BLOCK_AIR,
	[E_BLOCK_BIG_FLOWER]       = E_BLOCK_AIR,
	[E_BLOCK_GRASS]            = E_BLOCK_DIRT,
	[E_BLOCK_FARMLAND]         = E_BLOCK_DIRT,
	[E_BLOCK_LOG]              = E_BLOCK_BLOCK_OF_COAL,
	[E_BLOCK_NEW_LOG]          = E_BLOCK_BLOCK_OF_COAL,
	[E_BLOCK_PLANKS]           = E_BLOCK_FIRE,
	[E_BLOCK_WOODEN_STAIRS]    = E_BLOCK_FIRE,
	[E_BLOCK_COBBLESTONE]      = E_BLOCK_STONE,
	[E_BLOCK_FENCE]            = E_BLOCK_AIR,
	[E_BLOCK_ICE]              = E_BLOCK_WATER,
	[E_BLOCK_STATIONARY_WATER] = E_BLOCK_AIR,
	[E_BLOCK_WATER]            = E_BLOCK_AIR,
	[E_BLOCK_SNOW]             = E_BLOCK_AIR,
	[E_BLOCK_SAPLING]          = E_BLOCK_AIR,
	[E_BLOCK_CROPS]            = E_BLOCK_AIR,
}





-- Make these math functions local. When set to local you can all them faster.
local abs    = math.abs
local random = math.random
local max    = math.max
local cos    = math.cos
local sqrt   = math.sqrt
local floor  = math.floor





-- Throws an falling block in a random direction.
local function ThrowBlock(a_World, a_FallingBlockID)
	a_World:DoWithEntityByID(a_FallingBlockID,
		function(a_Entity)
			a_Entity:SetSpeed(random(-6, 6), 7 + random(15), random(-6, 6))
		end
	)
end





function cVolcano:new()
	local Obj = cCatastrophe:new()
	
	setmetatable(Obj, cVolcano)
	self.__index = self
	
	-- Volcano's don't move.
	Obj:SetSpeed(0, 0)
	
	-- It takes between 500 and 1000 ticks to build a volcano.
	Obj.m_ActiveTime = random(1000, 1500)
	
	-- We spawn an explosion at the position every X ticks. Because we set it to 0 first it will create an explosion on start.
	Obj.m_ExplosionTimer = 0
	
	-- Each X ticks a layer of plants is removed.
	Obj.m_PlantsRemoveTimer = random(30, 50)
	
	-- TODO: Timer to make sounds in for the volcano
	-- Obj.m_SoundTimer = random(1, 10)
	
	-- Time in ticks until the creation of the crater is starting.
	Obj.m_TicksUntilCrater = 400
	
	-- Time in ticks how long until the next columns of the crater are placed.
	Obj.m_ColumnsTimer = random(30, 40)
	
	-- The number of times columns will be placed for the volcano.
	Obj.m_NumColumns = random(10, 15)
	
	-- Get a random size for the volcano.
	Obj.m_Size = random(20, 30)
	
	-- The Y height where the volcano started. This is used to remove large pillars that can form
	Obj.m_StartHeight = 255
	
	return Obj
end





-- Saves the height where the volcano started.
function cVolcano:OnImportWorld(a_World)
	local Succes, Height = a_World:TryGetHeight(self:GetPosX(), self:GetPosZ())
	self.m_StartHeight = Height or 255
end





-- Removes plants from the surface.
function cVolcano:RemovePlants(a_World)
	local MinX, MinZ = self:GetPosX() - self.m_Size, self:GetPosZ() - self.m_Size
	local MaxX, MaxZ = self:GetPosX() + self.m_Size, self:GetPosZ() + self.m_Size
	
	for X = MinX, MaxX do
		for Z = MinZ, MaxZ do
			-- Don't change all plants in one go, but 20% at the time.
			if (random(5) == 1) then
				
				local Succes, Height = a_World:TryGetHeight(X, Z)
				if (Succes) then
					local BlockType = a_World:GetBlock(X, Height, Z)
					local DstBlock = g_Plants[BlockType]
					if (DstBlock) then
						a_World:QueueSetBlock(X, Height, Z, DstBlock, 0, random(0, 50))
					end
				end
			end
		end
	end
end





-- Creates the crater of the volcano by pushing columns above
function cVolcano:PushColumns(a_World)
	local MinX, MinZ = self:GetPosX() - self.m_Size, self:GetPosZ() - self.m_Size
	local MaxX, MaxZ = self:GetPosX() + self.m_Size, self:GetPosZ() + self.m_Size
	
	local SizeX = MaxX - MinX
	local SizeZ = MaxZ - MinZ
	
	local Half = Vector3d(SizeX / 2, 0, SizeZ / 2)
	local BlockPos = Vector3d(0, 0, 0)
	local Column = cBlockArea()
	
	for X = 0, SizeX do
		BlockPos.x = X
		local CompleteX = MinX + X
		
		for Z = 0, SizeZ do
			BlockPos.z = Z
			local CompleteZ = MinZ + Z
			
			local Succes, WorldHeight = a_World:TryGetHeight(CompleteX, CompleteZ)
			if (Succes and (random(3) ~= 1)) then
				local Scaled = (BlockPos - Half) / Half
				local Push = cos(sqrt(Scaled.x * Scaled.x + Scaled.z * Scaled.z) * 5) / 2
				
				-- < -0.4 gives a nice ring
				if (Push < -0.4) then
					Push = -Push
					a_World:ScheduleTask(Push * 3 + random(25),
						function()
							-- Re-read the worldheight. It could already be modified.
							local Succes, WorldHeight = a_World:TryGetHeight(CompleteX, CompleteZ)
							if (not Succes) then
								return
							end
							
							-- Read a whole column and paste it one block higher.
							Column:Read(a_World, CompleteX, CompleteX, 0, WorldHeight, CompleteZ, CompleteZ)
							
							local BlockType = g_Blocks[random(g_NumBlocks)]
							-- Make the top of the crater on of the blocks the volcano can spew out
							Column:SetRelBlockTypeMeta(0, WorldHeight,  0, BlockType, 0)
							
							-- Write the block X blocks higher then normal.
							Column:Write(a_World, CompleteX, max(2.25 * Push, 0), CompleteZ)
							
							if (BlockType == E_BLOCK_LAVA) then
								-- Update the lava to start flowing.
								a_World:WakeUpSimulators(CompleteX, WorldHeight + max(2.25 * Push, 0), CompleteZ)
							end
						end
					)
				end
			end
		end
	end
end





function cVolcano:Tick(a_World, a_TimeDelta)
	if (self.m_ActiveTime == 0) then
		self:Destroy()
		return
	end
	
	local Succes, WorldHeight = a_World:TryGetHeight(self:GetPosX(), self:GetPosZ())
	if (not Succes) then -- Succes can return 0 which is still valid if we'd use if (not Succes) then
		-- We couldn't retrieve the world height. The chunk is probably unloaded. Bail out
		self:Destroy()
		return
	end
	
	-- Every X ticks we spawn an explosion at the volcano's position. The force of the explosion is between 4 and 6.
	if (self.m_ExplosionTimer == 0) then
		local ThirdSize = self.m_Size / 3
		a_World:DoExplosionAt(random(4, 6), self:GetPosX() + random(-ThirdSize, ThirdSize), WorldHeight + 4, self:GetPosZ() + random(-ThirdSize, ThirdSize), true, esOther, a_World)
		self.m_ExplosionTimer = random(30, 60)
	end
	
	if (self.m_PlantsRemoveTimer == 0) then
		self:RemovePlants(a_World)
		self.m_PlantsRemoveTimer = random(30, 50)
	end
	
	if ((self.m_NumColumns ~= 0) and (self.m_TicksUntilCrater == 0) and (self.m_ColumnsTimer == 0)) then
		-- Don't damage the world tick too much. Only push the crater columns up when the previous tick lasted less then 50 ms
		if (a_TimeDelta <= 50) then
			self.m_NumColumns = self.m_NumColumns - 1
			self.m_ColumnsTimer = random(30, 40)
			
			-- Push the columns of the crator up
			self:PushColumns(a_World)
		else
			self.m_ColumnsTimer = self.m_ColumnsTimer + 1
		end
	end
	
	-- Create 3 falling blocks per-tick
	for I = 1, 3 do
		local FallingBlock = g_Blocks[random(g_NumBlocks)]
		ThrowBlock(a_World, a_World:SpawnFallingBlock(self:GetPosX(), WorldHeight + 1.5, self:GetPosZ(), FallingBlock, 0))
	end
	
	-- Sometimes pillars form at the position of the volcano. Because of that the volcano can look really weird. Remove it.
	local PillarRemover = cBlockArea()
	PillarRemover:Create(2, max(WorldHeight - self.m_StartHeight, 0), 2, cBlockArea.baTypes + cBlockArea.baMetas)
	PillarRemover:Write(a_World, self:GetPosX() - 1, self.m_StartHeight, self:GetPosZ() - 1, cBlockArea.baTypes + cBlockArea.baMetas)
	
	self.m_ActiveTime        = self.m_ActiveTime - 1
	self.m_ExplosionTimer    = self.m_ExplosionTimer - 1
	self.m_PlantsRemoveTimer = self.m_PlantsRemoveTimer - 1
	
	if (self.m_TicksUntilCrater ~= 0) then
		self.m_TicksUntilCrater = self.m_TicksUntilCrater - 1
	else
		self.m_ColumnsTimer      = self.m_ColumnsTimer - 1
	end
end





return cVolcano
