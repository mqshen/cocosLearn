local m_armature = nil

local function remove()
	if m_armature then
		-- m_armature:getAnimation():stop()
		m_armature:removeFromParentAndCleanup(true)
		m_armature = nil

		-- CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("Export/xinshou_smoke.ExportJson")
	end
end

local function create()
	if m_armature then
		return
	end
	
	-- CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/xinshou_smoke.ExportJson")

	-- m_armature = CCArmature:create("xinshou_smoke")
	-- m_armature:setPosition(cc.p(100, 50))
	-- map.getInstance():addChild(m_armature, 1)
 --    --show_armature:getAnimation():setFrameEventCallFunc(onFrameEvent)
	-- m_armature:getAnimation():play("Animation1")

	m_armature = cc.Sprite:createWithSpriteFrameName("xinshou_smoke_1.png")
	m_armature:setAnchorPoint(cc.p(0.3,0))
	-- fire:setScale(getScaleTime())
	mapData.getObject().newGuideNode:addChild(m_armature)
	m_armature:setPosition(cc.p(100, 50))
	m_armature:runAction(CCRepeatForever:create(mapController.playLandLevel5Animation(m_armature, "xinshou_smoke_", 15, 1,0.1 )))
end

guideSmokeAnim = {
					create = create,
					remove = remove
}