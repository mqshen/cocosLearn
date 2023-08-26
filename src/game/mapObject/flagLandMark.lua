--地图上面标记图标

module("flagLandMark", package.seeall)

local state_is_inited = nil
local tb_cache_object_data = nil

local function init()
	if state_is_inited then return end

	tb_cache_object_data = {}

	UIUpdateManager.add_prop_update(dbTableDesList.world_mark.name, dataChangeType.add, flagLandMark.dbDataChangeAdd)
	UIUpdateManager.add_prop_update(dbTableDesList.world_mark.name, dataChangeType.remove, flagLandMark.dbDataChange)
	UIUpdateManager.add_prop_update(dbTableDesList.world_mark.name, dataChangeType.update, flagLandMark.dbDataChange)


	ObjectManager.addObjectCallBack(LAND_MARK_FLAG, resetPosWhenMove, resetPosWhenJump)

	state_is_inited = true
end


local function clearFlagObjects()
	if not tb_cache_object_data then return end

	for k,v in pairs(tb_cache_object_data) do 
		v.object:removeFromParentAndCleanup(true)
	end
	tb_cache_object_data = {}
end

function remove()
	if not state_is_inited then return end


	UIUpdateManager.remove_prop_update(dbTableDesList.world_mark.name, dataChangeType.add, flagLandMark.dbDataChangeAdd)
	UIUpdateManager.remove_prop_update(dbTableDesList.world_mark.name, dataChangeType.remove, flagLandMark.dbDataChange)
	UIUpdateManager.remove_prop_update(dbTableDesList.world_mark.name, dataChangeType.update, flagLandMark.dbDataChange)

	clearFlagObjects()
	tb_cache_object_data = nil

	state_is_inited = nil
end



function resetPosWhenMove( )
	local coorX, coorY = userData.getLocation()
	local posx,posy = userData.getLocationPos()
	local label_pos_x, label_pos_y = nil, nil
	local label_start_x, label_start_y = nil, nil
	for i,v in pairs(tb_cache_object_data) do
		label_start_x = math.floor(v.data.wid/10000)
		label_start_y = v.data.wid%10000
		label_pos_x, label_pos_y = config.getMapSpritePos(posx,posy, coorX,coorY, label_start_x,label_start_y  )
		ObjectManager.setObjectPos(v.object, label_pos_x + 160, label_pos_y + 60)
	end
end

function resetPosWhenJump(coorX, coorY )
	local label_pos_x, label_pos_y = nil, nil
	local label_start_x, label_start_y = nil, nil
	local posx,posy = userData.getLocationPos()
	for i,v in pairs(tb_cache_object_data) do
		label_start_x = math.floor(v.data.wid/10000)
		label_start_y = v.data.wid%10000
		label_pos_x, label_pos_y = config.getMapSpritePos(posx,posy, coorX,coorY, label_start_x,label_start_y  )
		ObjectManager.setObjectPos(v.object, label_pos_x + 160, label_pos_y + 60)
	end
end




local function reloadData(newWidAdded)

	local markedList = userData.getUserMarkedLandList()

	clearFlagObjects()

	local locationX, locationY = userData.getLocation()
	local locationXPos, locationYPos = userData.getLocationPos()
	local end_x = nil
	local end_y = nil
	local x, y = nil

	for k,v in pairs(markedList) do 

		local end_x = math.floor(v.wid/10000)
		local end_y = v.wid%10000
		local x, y = config.getMapSpritePos(locationXPos,locationYPos, locationX,locationY, end_x,end_y  )

		local imgFlag = ImageView:create()
		imgFlag:loadTexture(ResDefineUtil.ui_land_mark_flag,UI_TEX_TYPE_PLIST)
		ObjectManager.addObject(LAND_MARK_FLAG,imgFlag, true, x+160, y+60 )

		local objectItem = {}
		objectItem.object = imgFlag
		objectItem.data = v
		table.insert(tb_cache_object_data,objectItem)
	end
end


local function showAddedEffect(wid)

	for k,v in pairs(tb_cache_object_data) do 
		if v.data.wid == wid then 
			local object = v.object
			local ori_pos_x = object:getPositionX()
			local ori_pos_y = object:getPositionY()
			object:setPosition(cc.p(ori_pos_x,ori_pos_y + 100))
			local action = animation.sequence({CCMoveTo:create(0.2,ccp(ori_pos_x,ori_pos_y))})
			object:runAction(action)


			SmallMiniMap.showTipsEffectMarkedLand()
		end
	end
end
function dbDataChangeAdd(package)
	reloadData()
	showAddedEffect(package.wid)
end

function dbDataChange()
	reloadData()
end
function create()
	init()

	reloadData()
end