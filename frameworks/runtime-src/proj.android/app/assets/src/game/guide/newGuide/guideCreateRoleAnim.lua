local m_armature = nil

local function remove()
	if m_armature then
		m_armature:getAnimation():stop()
		m_armature:removeFromParentAndCleanup(true)
		m_armature = nil

		CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("Export/xinshou/xinshou_jianlishili.ExportJson")

		newGuideInfo.enter_next_guide()
	end
end

local function create()
	if m_armature then
		return
	end
	
	CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/xinshou/xinshou_jianlishili.ExportJson")

	--[[
	local function animationEvent(armatureBack,movementType,movementID)
        if movementType == 1 then
            remove()
        end
    end
    --]]

    local function onFrameEvent( bone,evt,originFrameIndex,currentFrameIndex)
        if evt == "change_facade" then
        	mapController.setIsRefreshMainCity(true)
			mapController.setMainCityFade()
        elseif evt == "finish" then
        	remove()
        end
    end

	m_armature = CCArmature:create("xinshou_jianlishili")
	m_armature:setPosition(cc.p(100, 50))
	m_armature:setVisible(false)
	map.getInstance():addChild(m_armature, 1)
    --m_armature:getAnimation():setMovementEventCallFunc(animationEvent)
    m_armature:getAnimation():setFrameEventCallFunc(onFrameEvent)


	local main_city_id = userData.getMainPos()
	local city_x = math.floor(main_city_id/10000)
	local city_y = main_city_id%10000
	mapController.setOpenMessage(false)
	mapController.locateCoordinate(city_x, city_y,function() 
					mapController.setOpenMessage(true)
					m_armature:setVisible(true)
					m_armature:getAnimation():play("Animation1")
				end)

end

guideCreateRoleAnim = {
					create = create,
					remove = remove
}