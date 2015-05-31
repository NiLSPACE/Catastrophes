




-- cBlackHole extends cCatastrophe
local cDrought = setmetatable({}, cCatastrophe)





local g_SrcBlocks =
{
	[E_BLOCK_LEAVES]         = {BlockType = E_BLOCK_AIR,            BlockMeta = 0,  SetFunc = cWorld.FastSetBlock},
	[E_BLOCK_NEW_LEAVES]     = {BlockType = E_BLOCK_AIR,            BlockMeta = 0,  SetFunc = cWorld.FastSetBlock},
	[E_BLOCK_LOG]            = {BlockType = E_BLOCK_LOG,            BlockMeta = 0,  SetFunc = function() end},
	[E_BLOCK_NEW_LOG]        = {BlockType = E_BLOCK_LOG,            BlockMeta = 0,  SetFunc = function() end},
	[E_BLOCK_CLAY]           = {BlockType = E_BLOCK_HARDENED_CLAY,  BlockMeta = 0,  SetFunc = cWorld.FastSetBlock},
	[E_BLOCK_SAND]           = {BlockType = E_BLOCK_SANDSTONE,      BlockMeta = 0,  SetFunc = cWorld.FastSetBlock},
	[E_BLOCK_WOOL]           = {BlockType = E_BLOCK_WOOL,           BlockMeta = 0,  SetFunc = cWorld.FastSetBlock}, -- Wool loses it's color when exposed to too much UV radiation.
	[E_BLOCK_DIRT]           = {BlockType = E_BLOCK_DIRT,           BlockMeta = 0,  SetFunc = cWorld.FastSetBlock}, -- In case we have podzol we have to change it to dirt.
	[E_BLOCK_FENCE]          = {BlockType = E_BLOCK_SPRUCE_FENCE,   BlockMeta = 0,  SetFunc = cWorld.FastSetBlock}, -- Make oak wood turn darker
	[E_BLOCK_PLANKS]         = {BlockType = E_BLOCK_PLANKS,         BlockMeta = 1,  SetFunc = cWorld.FastSetBlock}, -- Make oak wood turn darker
	[E_BLOCK_SNOW]           = {BlockType = E_BLOCK_AIR,            BlockMeta = 0,  SetFunc = cWorld.FastSetBlock},
	[E_BLOCK_SAPLING]        = {BlockType = E_BLOCK_AIR,            BlockMeta = 0,  SetFunc = cWorld.FastSetBlock},
	[E_BLOCK_CROPS]          = {BlockType = E_BLOCK_AIR,            BlockMeta = 0,  SetFunc = cWorld.FastSetBlock},
	[E_BLOCK_CARROTS]        = {BlockType = E_BLOCK_AIR,            BlockMeta = 0,  SetFunc = cWorld.FastSetBlock},
	[E_BLOCK_POTATOES]       = {BlockType = E_BLOCK_AIR,            BlockMeta = 0,  SetFunc = cWorld.FastSetBlock},
	[E_BLOCK_SUGARCANE]      = {BlockType = E_BLOCK_AIR,            BlockMeta = 0,  SetFunc = cWorld.FastSetBlock},
	[E_BLOCK_TALL_GRASS]     = {BlockType = E_BLOCK_AIR,            BlockMeta = 0,  SetFunc = cWorld.FastSetBlock}, -- Don't change with dead shrubs. They look terrible.
	[E_BLOCK_BIG_FLOWER]     = {BlockType = E_BLOCK_AIR,            BlockMeta = 0,  SetFunc = cWorld.FastSetBlock},
	[E_BLOCK_DANDELION]      = {BlockType = E_BLOCK_AIR,            BlockMeta = 0,  SetFunc = cWorld.FastSetBlock},
	[E_BLOCK_RED_ROSE]       = {BlockType = E_BLOCK_AIR,            BlockMeta = 0,  SetFunc = cWorld.FastSetBlock},
	[E_BLOCK_GRASS]          = {BlockType = E_BLOCK_DIRT,           BlockMeta = 0,  SetFunc = cWorld.FastSetBlock},
	[E_BLOCK_FARMLAND]       = {BlockType = E_BLOCK_DIRT,           BlockMeta = 0,  SetFunc = cWorld.FastSetBlock},
	[E_BLOCK_COBBLESTONE]    = {BlockType = E_BLOCK_STONE,          BlockMeta = 0,  SetFunc = cWorld.FastSetBlock},
	[E_BLOCK_VINES]          = {BlockType = E_BLOCK_AIR,            BlockMeta = 0,  SetFunc = cWorld.SetBlock}, -- Use cWorld:SetBlock so the vines beneath the current one will be removed. (Some vines might stay because of leave blocks not using SetBlock)
	[E_BLOCK_ICE]            = {BlockType = E_BLOCK_WATER,          BlockMeta = 0,  SetFunc = cWorld.SetBlock}, -- Use cWorld:SetBlock so the water is updated.
}





-- Make the needed math functions local, so they can be accessed faster.
local random = math.random





function cDrought:new()
	local Obj = cCatastrophe:new()
	
	setmetatable(Obj, cDrought)
	self.__index = self
	
	-- The size of the affected area around the middle
	Obj.m_Size = random(50, 70)
	
	-- Set a random speed
	Obj:SetSpeed(
		(random(-1, 1) + random(-1, 1) + random(-1, 1) + random(-1, 1)) / 16,
		(random(-1, 1) + random(-1, 1) + random(-1, 1) + random(-1, 1)) / 16
	)
	
	return Obj
end





function cDrought:ApplyDrought(a_World)
	-- Get the minimum and maximum coordinates that the drought can reach.
	local StartX, EndX = self:GetPosX() - self.m_Size, self:GetPosX() + self.m_Size
	local StartZ, EndZ = self:GetPosZ() - self.m_Size, self:GetPosZ() + self.m_Size
	
	
	for I = 1, self.m_Size do
		-- Get a random coordinate around the drought.
		local X = (random(StartX, EndX) + random(StartX, EndX) + random(StartX, EndX) + random(StartX, EndX)) / 4
		local Z = (random(StartZ, EndZ) + random(StartZ, EndZ) + random(StartZ, EndZ) + random(StartZ, EndZ)) / 4
		
		local Succes, Height = a_World:TryGetHeight(X, Z)
		if (Succes) then
			-- 10% chance that there will be particle effects
			if (random(10) == 1) then
				-- a_World:BroadcastSoundParticleEffect(2001, X, Height, Z, BlockType)
				a_World:BroadcastParticleEffect("smoke", X, Height + 0.5, Z, random(), random(), random(), 0.125, 25)
			end
			
			local BlockType = a_World:GetBlock(X, Height, Z)
			local BlockInf = g_SrcBlocks[BlockType]
			if (BlockInf) then
				-- Always change the first block
				BlockInf.SetFunc(a_World, X, Height, Z, BlockInf.BlockType, BlockInf.BlockMeta)
				
				-- For each block below check if we can change the block. If not then don't continue. 
				-- Also each time has a 50% chance to change. If the block isn't set the loop breaks as well.
				for Y = Height - 1, 0, -1 do
					local BlockType = a_World:GetBlock(X, Y, Z)
					local BlockInf = g_SrcBlocks[BlockType]
					if (not BlockInf) then
						-- The block doesn't exist in the source block table.
						break
					end
					
					-- Give each block a 50% chance to be set. If not we break the loop
					if (random(2) == 1) then
						BlockInf.SetFunc(a_World, X, Y, Z, BlockInf.BlockType, BlockInf.BlockMeta)
					else
						break
					end
				end
			end
		end
	end
end





function cDrought:Tick(a_World)
	if ((a_World:GetTimeOfDay() < 1000) or (a_World:GetTimeOfDay() > 13000) or a_World:IsWeatherWetAt(self:GetPosX(), self:GetPosZ())) then
		-- It's night time or it's raining. There is not enough radiation from the sun to continue.
		self:Destroy()
		return
	end
	
	-- Move the drought
	self:TickSpeed()
	
	-- Change the terrain around the catastrophe.
	self:ApplyDrought(a_World)
	
	-- Slightly change the speed each tick
	self:AddSpeed(
		(random(-1, 1) + random(-1, 1) + random(-1, 1) + random(-1, 1)) / 64,
		(random(-1, 1) + random(-1, 1) + random(-1, 1) + random(-1, 1)) / 64
	)
	
	-- Don't allow the drought to go faster then 0.25 blocks per tick
	self:ClampSpeed(-0.25, 0.25)
end





return cDrought