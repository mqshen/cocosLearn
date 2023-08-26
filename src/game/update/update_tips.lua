local updateTips = {}
local m_pInstance = nil

local m_tSpShowed = nil
local m_tSpHid = nil

local m_iCurIndx = nil

local RES_ROOT = "test/res_single/"

local m_tTipPngs = {}
m_tTipPngs[1] = "updating_tips_1.png"
m_tTipPngs[2] = "updating_tips_2.png"
m_tTipPngs[3] = "updating_tips_3.png"
m_tTipPngs[4] = "updating_tips_4.png"
m_tTipPngs[5] = "updating_tips_5.png"
m_tTipPngs[6] = "updating_tips_6.png"
m_tTipPngs[7] = "updating_tips_7.png"


local schedulerHandler = nil

local function unloadRes()
	local textureCache = CCTextureCache:sharedTextureCache()
	for k,v in ipairs(m_tTipPngs) do 
		textureCache:removeTextureForKey( RES_ROOT .. v )
	end
end


local function loadRes()

end


local function disposeSchedulerHandler()
    if schedulerHandler then 
        scheduler.remove(schedulerHandler)
        schedulerHandler = nil
    end
end

function updateTips.remove()
	disposeSchedulerHandler()

	if m_pInstance then 
		m_pInstance:removeFromParentAndCleanup(true)
		m_pInstance = nil
		m_iCurIndx = nil

		m_tSpShowed = nil
		m_tSpHid = nil
		unloadRes()
	end
end


local function showNext()
	if not m_pInstance then return end
	if not m_iCurIndx then return end


	local function loadNextImg(img)
		if m_iCurIndx >= #m_tTipPngs then 
			m_iCurIndx = 1
		else
			m_iCurIndx = m_iCurIndx + 1
		end
		img:loadTexture(RES_ROOT .. m_tTipPngs[m_iCurIndx],UI_TEX_TYPE_LOCAL)	
	end
	local function show()
		local sp = table.remove(m_tSpHid,1)
		if not sp then return end
		loadNextImg(sp)
		
		sp:setVisible(true)
		local duration = 0.2
		sp:setScale(0.8 * configBeforeLoad.getgScale())
		sp:setOpacity(0)
    	local actionShow = CCFadeIn:create(duration)
        local actionScale = CCScaleTo:create(duration, 1 * configBeforeLoad.getgScale())
        local scaleAndShow = CCSpawn:createWithTwoActions(actionScale,actionShow)
        local finally = cc.CallFunc:create(function ( )			
    		sp:setVisible(true)
    		sp:setOpacity(255)
        	table.insert(m_tSpShowed,sp)
    	end)

        sp:runAction(animation.sequence({scaleAndShow,finally}))
	end
	local function hide()
		local sp = table.remove(m_tSpShowed,1)
		if not sp then return end
		sp:setVisible(true)
		local duration = 0.2
		local actionHide = CCFadeOut:create(duration)
		local actionScale = CCScaleTo:create(duration,1.05 * configBeforeLoad.getgScale())
		local scaleAndHide = CCSpawn:createWithTwoActions(actionScale,actionHide)
		
		local finally = cc.CallFunc:create(function ( )	
			table.insert(m_tSpHid,sp)
			sp:setVisible(false)
			sp:runAction(CCFadeIn:create(duration/2))
        	show()
    	end)
    	sp:runAction(animation.sequence({scaleAndHide,finally}))
	end

	hide()
end

local function onTouch(eventType, x1, y1 )
	if eventType == "began" then 
		return true
	elseif eventType == "ended" then
		showNext()
		return true
	elseif eventType == "moved" then
		return true
	else
		return true
	end
end


local function init()
	if m_pInstance then return end
	local winSize = configBeforeLoad.getWinSize()
	m_pInstance = cc.LayerColor:create(cc.c4b(0,0,0,0),winSize.width, winSize.height)
	m_pInstance:registerScriptTouchHandler(onTouch,false, -129, true)
	m_pInstance:setTouchEnabled(true)

	cc.Director:getInstance():getRunningScene():addChild(m_pInstance)
	m_pInstance:ignoreAnchorPointForPosition(false)
	m_pInstance:setAnchorPoint(cc.p(0.5,0.5))
	m_pInstance:setPosition(cc.p(winSize.width/2, winSize.height/2))

	m_iCurIndx = 1

	local m_pMainSp = ImageView:create()
	m_pMainSp:loadTexture(RES_ROOT .. m_tTipPngs[m_iCurIndx],UI_TEX_TYPE_LOCAL)	
	m_pInstance:addChild(m_pMainSp)
	m_pMainSp:ignoreAnchorPointForPosition(false)
	m_pMainSp:setAnchorPoint(cc.p(0.5,0.5))
	m_pMainSp:setPosition(cc.p(winSize.width/2, winSize.height/2 + 20 * configBeforeLoad.getgScale()))
	m_pMainSp:setScale(configBeforeLoad.getgScale())
	

	local m_pMainSpNext = ImageView:create()
	m_pMainSpNext:loadTexture(RES_ROOT .. m_tTipPngs[m_iCurIndx],UI_TEX_TYPE_LOCAL)	
	m_pInstance:addChild(m_pMainSpNext)
	m_pMainSpNext:ignoreAnchorPointForPosition(false)
	m_pMainSpNext:setAnchorPoint(cc.p(0.5,0.5))
	m_pMainSpNext:setPosition(cc.p(winSize.width/2, winSize.height/2 + 20 * configBeforeLoad.getgScale()))
	m_pMainSpNext:setScale(configBeforeLoad.getgScale())
	m_pMainSpNext:setVisible(false)
	


	m_pInstance:setTouchEnabled(false)
	m_pMainSp:setVisible(true)
	local duration = 1
	m_pMainSp:setScale(0.8 * configBeforeLoad.getgScale())
	m_pMainSp:setOpacity(0)
	local actionShow = CCFadeIn:create(duration)
    local actionScale = CCScaleTo:create(duration, 1 * configBeforeLoad.getgScale())
    local scaleAndShow = CCSpawn:createWithTwoActions(actionScale,actionShow)
    local finally = cc.CallFunc:create(function ( )			
		m_tSpShowed = {}
		m_tSpHid = {}
		m_pMainSp:setVisible(true)
    	m_pMainSp:setOpacity(255)
		table.insert(m_tSpShowed,m_pMainSp)
		table.insert(m_tSpHid,m_pMainSpNext)
		m_pInstance:setTouchEnabled(true)
	end)

    m_pMainSp:runAction(animation.sequence({scaleAndShow,finally}))


	
end




local function updateScheduler()
	
	disposeSchedulerHandler()
	init()
end

local function activeSchedulerHandler()
    disposeSchedulerHandler()
    schedulerHandler = scheduler.create(updateScheduler,1)
end


function updateTips.create()
	if m_pInstance then return end
	-- activeSchedulerHandler()
	init()
end

return updateTips