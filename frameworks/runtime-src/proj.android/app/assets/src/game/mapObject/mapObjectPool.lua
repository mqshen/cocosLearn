--大地图元素的管理池
-- 使用池的概念把所有生成的大地图元素缓存，拖动大地图的时候并不删除sprite，
-- 只是在缓存池中取对应的元素。如果缓存不足，那么生成新的元素，再移动到对应的位置
module("MapObjectPool", package.seeall)
local mapTypePool = {

}

local objectZorder = {["test/sight_view_label.json"] = ARMY_WAR_STATUS,
						["game/script_json/not_war_panel"] = VIEW_INFO,
						["game/script_json/City_NPC_name"] = CITY_NAME,
						["game/script_json/City_player_name"] = CITY_NAME,
						["game/script_json/City_player_name_other"] = CITY_NAME,
						}


function remove( )
	mapTypePool = {
}
end

--当元素不足，生成新的元素放进缓存池
function createSprite( pool, key, script )
	local tmpSprite = nil
	-- if key == "nil" then
	-- 	tmpSprite = cc.Sprite:createWithTexture(mapData.getObject().resLayer:getTexture(), mapData.getEmptyRect())
	-- else
	-- 	tmpSprite = cc.Sprite:createWithSpriteFrameName(key)
	-- end
	if ObjectManager.getInstance() then
		if script then
			tmpSprite = require(key).create()
		else
			tmpSprite = GUIReader:shareReader():widgetFromJsonFile(key)
		end
		ObjectManager.getInstance():addChild(tmpSprite, objectZorder[key] or 0)
		tmpSprite:setVisible(false)
		table.insert(pool, tmpSprite)
		return true
	end
	return false
end

--把对应的元素从缓存池中取出
function popSprite( key, script)
	-- if mapTypePool[key] then
		--对应图素对应的池
		if not mapTypePool[key] then
		-- if not singleSpritePool then
			mapTypePool[key] = {}
		end

		local flag = false
		if #mapTypePool[key] == 0 then
			flag = createSprite(mapTypePool[key], key,script )
		else
			flag = true
		end

		if flag then
			local sprite = {}
			table.insert(sprite, mapTypePool[key][1])
			-- return singleSpritePool[1]
			table.remove(mapTypePool[key], 1)
			return sprite[1]
		else
			return false
		end
	-- else
		-- print(">>>>>>>>>>>>>pop error , type  ="..spriteType)
	-- end
end

--把暂时不用的元素放到缓存池
function pushSprite(key, target )
	-- if mapTypePool[key] then
		if not mapTypePool[key] then
			mapTypePool[key] = {}
		-- if not singleSpritePool then
			-- singleSpritePool = {}
		end
		target:setVisible(false)
		target:setPosition(cc.p(config.getWinSize().width*2,  config.getWinSize().height*2))
		-- target:setTag(0)
		-- target:setZOrder(0)
		table.insert(mapTypePool[key], target)
	-- else
		-- print(">>>>>>>>>>>>>push error , type  ="..spriteType)
	-- end
end