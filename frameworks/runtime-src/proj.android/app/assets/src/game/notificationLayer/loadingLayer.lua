--网络传输数据时的遮罩层，用于吸收用户这段时间的点击

-- local layer = nil
local m_tag = 19880228
-- local m_loadingHandler = nil
-- local m_handler = nil
local dt_state = nil
local defaultTime = 3
local function remove( )
	-- if m_handler then
	-- 	scheduler.remove(m_handler)
	-- 	m_handler = nil
	-- end

	-- if m_loadingHandler then
	-- 	scheduler.remove(m_loadingHandler)
	-- 	m_loadingHandler = nil
	-- end

	-- if layer then
	-- 	layer:removeFromParentAndCleanup(true)
	-- 	layer = nil
	-- end
	-- dt_state = nil
	cc.Director:getInstance():getRunningScene():removeChildByTag(m_tag,true)
end

--网络超时
local function netTimeOut( )
	remove()
	
end

local function create(dt,isLoading,noTips, canTouch)
	local function onTouch(eventType, x, y)
		return true
	end

	-- if not uiManager.getBasicLayer() then return end
	local scene = cc.Director:getInstance():getRunningScene()
	if not scene then return end
	if scene:getChildByTag(m_tag) then
		remove()
	end

	if scene:getChildByTag(m_tag) and ( not dt_state or (not dt) or dt_state ~= dt ) then
		dt_state =dt
		remove()
	end

	if isLoading == nil then isLoading = true end

	local winSize = configBeforeLoad.getWinSize()
	local layer = CCLayer:create()
	cc.Director:getInstance():getRunningScene():addChild(layer,100)
	layer:setTag(m_tag)

	if not canTouch then
		layer:registerScriptTouchHandler(onTouch,false, -131, true)
		layer:setTouchEnabled(true)
	end
	-- if m_loadingHandler then
	-- 	scheduler.remove(m_loadingHandler)
	-- 	m_loadingHandler = nil
	-- end

	local action = nil
	if dt then
		-- action  = animation.sequence({cc.CallFunc:create(function ( )
			if layer then
				local sprite = cc.Sprite:createWithSpriteFrameName("loading.png")
				layer:addChild(sprite)
				sprite:setPosition(cc.p(configBeforeLoad.getWinSize().width/2, configBeforeLoad.getWinSize().height/2))
				sprite:setScale(configBeforeLoad.getgScale())
				sprite:runAction( CCRepeatForever:create(animation.sequence({CCRotateBy:create(1,360)})))
				sprite:setVisible(isLoading)

				if dt >= 999 then
					dt = defaultTime
				end

				layer:runAction(animation.sequence({cc.DelayTime:create(dt), cc.CallFunc:create(function ( )
					if not noTips then
						tipsLayer.create(languageBeforeLogin[3])
					end
					cc.Director:getInstance():getRunningScene():removeChildByTag(m_tag,true)
				end)}))
				-- m_handler = scheduler.create(function ( )
				-- 		sprite:setRotation(sprite:getRotation()+30)
				-- end, 0.1)
			end
		-- end)})
	else
		action  = animation.sequence({cc.DelayTime:create(1), cc.CallFunc:create(function ( )
			if layer then
				local sprite = cc.Sprite:createWithSpriteFrameName("loading.png")
				layer:addChild(sprite)
				sprite:setPosition(cc.p(configBeforeLoad.getWinSize().width/2, configBeforeLoad.getWinSize().height/2))
				sprite:setScale(configBeforeLoad.getgScale())
				sprite:runAction( CCRepeatForever:create(animation.sequence({CCRotateBy:create(1,360)})))
				sprite:setVisible(isLoading)

				layer:runAction(animation.sequence({cc.DelayTime:create(defaultTime), cc.CallFunc:create(function ( )
					if not noTips then
						tipsLayer.create(languageBeforeLogin[3])
					end
					cc.Director:getInstance():getRunningScene():removeChildByTag(m_tag,true)
				end)}))
			end
		end)})
		layer:runAction(action)
	end
end

loadingLayer = {
					create = create,
					remove = remove,
}