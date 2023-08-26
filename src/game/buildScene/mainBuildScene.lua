--进入主城建筑界面的底层layer
local rootLayer = nil
local wid = nil
require("game/buildScene/buildMsgManager")
require("game/buildScene/buildTreeManager")
local function onTouchBegan( x, y)
	if buildingExpandTitle.getInstance() then 
		return true
	else
		return false
	end
end

local b_isQuitNeedEffect = false

local function isQuitNeedEffect()
	return b_isQuitNeedEffect
end

local function swtichViewOutMainCity()

end



local function remove( needEffect, callback )
	b_isQuitNeedEffect = needEffect
	local function finally()
		

		require("game/buildScene/buildingExpand")
		BuildingExpand.remove()
		if mapController then
			-- mapController.removeSmoke()
			mapController.removeSmokeByTime()
		end

		if rootLayer then
			rootLayer:removeFromParentAndCleanup(true)
			rootLayer = nil
			
			buildMsgManager.remove_self()
			
			buildTreeManager.remove_self()
		end
		mainScene.setBtnsVisible(true)
		if mapData.getObject() then
			map.setAnchorPoint(0,0)
		end
		ObjectManager.setObjectLayerVisible(nil)
		armyMark.setLineVisible(true)
		UIUpdateManager.remove_prop_update(dbTableDesList.user_city.name, dataChangeType.remove, mainBuildScene.removeCity)
		SmallMiniMap.setMapVisibel(true)

		local coor_x = nil
		local coor_y = nil
		if wid then 
			coor_x = math.floor(wid/10000)
			coor_y = wid%10000
		end
		if needEffect and coor_x and coor_y then 
			-- local winSize = config.getWinSize()
			-- mapData.getObject().layer:setScale(map.getNorScale())
			-- mapData.getObject().layer:setPosition(cc.p(winSize.width/2-100, winSize.height/2-50))
			-- mapData.requestMapData(coor_x, coor_y, false)
			local m_coor_x ,m_coor_y = map.getLocation()
			if not( m_coor_x == coor_x and m_coor_y == coor_y )then
				-- mapController.jump(coor_x,coor_y)
			end
		end
		wid = nil
		

		newGuideInfo.enter_next_guide()
		armyListManager.change_show_state(true)
		if callback then
			callback()
		end
	end
	-- mainOption.changeInCityState(false)
	-- map.setMlayerScale(map.getNorScale(),finally)

	if cityMsg then 
		cityMsg.remove_self()
	end
	

	if needEffect then 
		-- mainOption.changeInCityState(false)
		-- map.setMlayerScale(map.getNorScale(),finally)
		-- mapController.simulatingScaleMove(false,math.floor(wid/10000),wid%10000,map.getNorScale()*1.5,map.getNorScale(),finally,nil,10,1)
		if mapController then
			mapController.setResVisible(true)
			mapController.setCityShadow(false)
		end
		if mapController then 
			mapController.quitCity(math.floor(wid/10000),wid%10000,finally)
		end
	else
		-- mainOption.changeInCityState(false)
		if map then
			map.setMlayerScale(map.getNorScale(),nil,0)
		end
		-- if mapController then
		-- 	mapController.setResVisible(true)
		-- end
		finally()
	end
	

end


-- 进入主城
local function create(x, y)
	require("game/buildScene/buildingExpand")
	
	local function onTouch(eventType, x1, y1 )
		if eventType == "began" then 
			
			-- if mainOption.isHitInVoidArea(x1, y1) then 
			-- 	cityMsg.create()
			-- end	
			BuildingExpand.touchBegin(x1, y1) 
        	return onTouchBegan(x1, y1)
    	elseif eventType == "ended" then
    		BuildingExpand.touchEnd(x1, y1) 
    		return true
    	elseif eventType == "moved" then
    		BuildingExpand.touchBegin(x1, y1)
    		return true
    	else
    		return true
    	end
	end
	local winSize = config.getWinSize()
	rootLayer = cc.LayerColor:create(cc.c4b(0,0,0,0),winSize.width, winSize.height)
	rootLayer:registerScriptTouchHandler(onTouch,false, layerPriorityList.map_priority, true)
	rootLayer:setTouchEnabled(true)

	cc.Director:getInstance():getRunningScene():addChild(rootLayer)
	rootLayer:ignoreAnchorPointForPosition(false)
	rootLayer:setAnchorPoint(cc.p(0.5,0.5))
	rootLayer:setPosition(cc.p(winSize.width/2, winSize.height/2))
	
	wid = x*10000+y

	-- mainOption.changeInCityState(true)
	-- ObjectManager.setObjectLayerVisible(2)
	-- armyMark.setLineVisible(false)
	-- UIUpdateManager.add_prop_update(dbTableDesList.user_city.name, dataChangeType.remove, mainBuildScene.removeCity)
	-- SmallMiniMap.setMapVisibel(false)

	
	-- mainOption.setSecondPanelVisible(false,false)
	ObjectManager.setObjectLayerVisible(2)
	armyMark.setLineVisible(false)
	UIUpdateManager.add_prop_update(dbTableDesList.user_city.name, dataChangeType.remove, mainBuildScene.removeCity)
	SmallMiniMap.setMapVisibel(false)
	-- mapController.setResVisible(false)
	-- mapController.setCityShadow(true)
	--newGuideInfo.enter_next_guide()

	-- cityMsg.create()
	
end

local function getThisCityid()
	return wid
end

local function setThisCityid(cid)
	wid = cid
end

local function getRootLayer( )
	return rootLayer
end

local function removeCity(packet )
	if packet == wid then
		remove()
	end
end


local function isInCity()
    if wid then return true end
    return false
end
mainBuildScene = {
					create = create,
					remove = remove,
					getThisCityid = getThisCityid,
					setThisCityid = setThisCityid,
					getRootLayer = getRootLayer,
					removeCity = removeCity,
                    isInCity = isInCity,
                    isQuitNeedEffect = isQuitNeedEffect,
				}
