--大地图元素的管理池
-- 使用池的概念把所有生成的大地图元素缓存，拖动大地图的时候并不删除sprite，
-- 只是在缓存池中取对应的元素。如果缓存不足，那么生成新的元素，再移动到对应的位置
module("MapSpriteManage", package.seeall)
local spriteTypePool = {
	[1] = {},
	[2] = {},
	[3] = {},
	[4] = {},
	[5] = {},
	[6] = {},
	[7] = {},
	[8] = {},
	[9] = {},
	[10] = {},
	[11] = {},
	[12] = {},
	[13] = {},
	[14] = {},	
	[15] = {},
	[16] = {},
	[17] = {},
}

function remove( )
	spriteTypePool = {
	[1] = {},
	[2] = {},
	[3] = {},
	[4] = {},
	[5] = {},
	[6] = {},
	[7] = {},
	[8] = {},
	[9] = {},
	[10] = {},
	[11] = {},
	[12] = {},
	[13] = {},
	[14] = {},	
	[15] = {},
	[16] = {},
	[17] = {},
}
end

--当元素不足，生成新的元素放进缓存池
function createSprite(parent, pool, key )
	local tmpSprite = nil
	if key == "nil" then
		tmpSprite = cc.Sprite:createWithTexture(mapData.getObject().resLayer:getTexture(), mapData.getEmptyRect())
	else
		tmpSprite = cc.Sprite:createWithSpriteFrameName(key)
	end
	parent:addChild(tmpSprite)
	tmpSprite:setVisible(false)
	table.insert(pool, tmpSprite)
end

--把对应的元素从缓存池中取出
function popSprite( spriteType, key, parent)
	if spriteTypePool[spriteType] then
		--对应图素对应的池
		if not spriteTypePool[spriteType][key] then
		-- if not singleSpritePool then
			spriteTypePool[spriteType][key] = {}
		end
		if #spriteTypePool[spriteType][key] == 0 then
			createSprite(parent, spriteTypePool[spriteType][key], key )
		end

		local sprite = {}
		table.insert(sprite, spriteTypePool[spriteType][key][1])
		-- return singleSpritePool[1]
		table.remove(spriteTypePool[spriteType][key], 1)
		return sprite[1]
	else
		print(">>>>>>>>>>>>>pop error , type  ="..spriteType)
	end
end

--把暂时不用的元素放到缓存池
function pushSprite(spriteType, key, target )
	if spriteTypePool[spriteType] then
		if not spriteTypePool[spriteType][key] then
			spriteTypePool[spriteType][key] = {}
		-- if not singleSpritePool then
			-- singleSpritePool = {}
		end
		target:setVisible(false)
		target:setTag(0)
		target:setZOrder(0)
		table.insert(spriteTypePool[spriteType][key], target)
	else
		print(">>>>>>>>>>>>>push error , type  ="..spriteType)
	end
end
