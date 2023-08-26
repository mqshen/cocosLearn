local NewbieProtectOverdue = {}
-- 新手保护期过期

local IMG_TIPS = "test/res_single/xinshou_tips_01.png"
local instance = nil

function NewbieProtectOverdue.remove()
	if not instance then return end
	
	instance:removeFromParentAndCleanup(true)
	instance = nil

	local textureCache = CCTextureCache:sharedTextureCache()
	textureCache:removeTextureForKey( IMG_TIPS )

	Net.send(USER_PROTECTED_POPUP ,{})
end


function NewbieProtectOverdue.create()
	if instance then return end
	instance = true

	local function onTouch(eventType, x, y)
		if eventType == "ended" then
			NewbieProtectOverdue.remove()
		end
		return true
	end

	local winSize = config.getWinSize()
	local layer = cc.LayerColor:create(cc.c4b(14, 17, 24, 220), winSize.width, winSize.height)
	cc.Director:getInstance():getRunningScene():addChild(layer,100)
	-- layer:setTag(19880230)
	layer:registerScriptTouchHandler(onTouch,false, -132, true)
	layer:setTouchEnabled(true)

	local tipsImage = ImageView:create()
	tipsImage:loadTexture(IMG_TIPS,UI_TEX_TYPE_LOCAL)	
	layer:addChild(tipsImage)
	tipsImage:ignoreAnchorPointForPosition(false)
	tipsImage:setAnchorPoint(cc.p(0.5,0.5))
	tipsImage:setPosition(cc.p(winSize.width/2, winSize.height/2))
	tipsImage:setScale(configBeforeLoad.getgScale())

	instance = layer
end


return NewbieProtectOverdue