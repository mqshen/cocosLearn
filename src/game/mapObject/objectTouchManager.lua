-- objectTouchManager.lua
-- 地图上的物件的触摸事件的分发管理
module("ObjectTouchManager", package.seeall)
local object_layer = nil

function onTouch( eventType, x, y )
	local citynameData = CityName.getCityNameArr()
	local citydata = nil
	for i, v in pairs(citynameData) do
		citydata = landData.get_world_city_info(i)
		if v[1] and citydata and (citydata.city_type == cityTypeDefine.zhucheng or citydata.city_type == cityTypeDefine.fencheng
			or citydata.city_type == cityTypeDefine.yaosai or citydata.city_type == cityTypeDefine.npc_yaosai ) and citydata.state ~= cityState.building then
			if v[1]:hitTest(cc.p(x,y)) then
				CityName.touchEvent( eventType, i )
				return true
			end
		end
	end
	if eventType == "began" or eventType == "ended" and map.getInstance():getScale() - map.getNorScale() <=0.1 then
		local armyTimeshow = armyMark.getTimeShowList()
		for i, v in pairs(armyTimeshow) do
			if v.touch_circle then
				if v.touch_circle:hitTest(cc.p(x,y)) and not mainBuildScene.getThisCityid() then
					if eventType == "ended" then
						armyMark.setTouchArmy(i )
					end
					return true
				end
			end
		end
	end
	return false
end

function remove( )
	if object_layer then
		object_layer:removeFromParentAndCleanup(true)
		object_layer = nil
	end
end

function create()
	if object_layer then return end
	object_layer = CCLayer:create()
	object_layer:setTouchEnabled(true)
	object_layer:registerScriptTouchHandler(onTouch, false, layerPriorityList.map_object, true)
	
	cc.Director:getInstance():getRunningScene():addChild(object_layer,UI_SCENE)
end

