--任务屏幕飘出来的字幕
module("taskTipsLayer", package.seeall)
local dt = 2
local m_arrDisplayLayer = nil
local m_pAlert = nil
local m_arrWaitStr = nil

local function displayLayerAction( text)
	if not m_pAlert then return end

	local back_image = ImageView:create()
	back_image:loadTexture("test/res_single/Hidden_among_the_prompt_box.png",UI_TEX_TYPE_LOCAL)
	back_image:setSize(CCSize(330,61))
	back_image:setScale9Enabled(true)
	back_image:setCapInsets(CCRect(16,16,298,29))
	back_image:setScale(config.getgScale())
	local point = m_pAlert:convertToNodeSpace(cc.p(config.getWinSize().width/2,config.getWinSize().height/2))
	back_image:setPosition(cc.p(point.x,point.y))
	m_pAlert:addWidget(back_image)

	local str = Label:create()
	str:setFontSize(22)
	str:setText(text)
	back_image:addChild(str)
	str:setAnchorPoint(cc.p(0.5,0.5))
	str:setColor(ccc3(234,232,156))

	local action6 = cc.DelayTime:create(0.2)
    local action1 = CCMoveBy:create(0.6,ccp(0, back_image:getContentSize().height ))
    local actionCallback = cc.CallFunc:create(function ( )
    	if m_arrWaitStr[1] then
    		table.remove(m_arrWaitStr,1)
    	end
    	
    	if m_arrWaitStr[1] then
    		displayLayerAction( m_arrWaitStr[1])
    	end
    end)
    m_pAlert:runAction(animation.sequence({action1, actionCallback}))

    local action4 = CCFadeIn:create(0.2)
    local action5 = cc.DelayTime:create(1)
    local action2 = CCFadeOut:create(0.8)
	local action3 = cc.CallFunc:create(function ( )
		if #m_arrDisplayLayer > 0 then
			m_arrDisplayLayer[1]:removeFromParentAndCleanup(true)
			table.remove(m_arrDisplayLayer,1)
		else
			if m_pAlert then
				m_pAlert:setPositionY(0)
			end
		end
	end)
	back_image:runAction(animation.sequence({action4,action5,action2, action3}))
	table.insert(m_arrDisplayLayer, back_image)
end

function create(text, dtime, arg, fontSize )
	if not text or #text == 0 then return end
	if #m_arrWaitStr == 0 then
		for i, v in ipairs(text) do
			table.insert(m_arrWaitStr, v)
		end
		displayLayerAction(m_arrWaitStr[1])
	else
		for i, v in ipairs(text) do
			table.insert(m_arrWaitStr, v)
		end
	end
end

function remove( )
	if m_pAlert then
		m_pAlert:removeFromParentAndCleanup(true)
		m_pAlert = nil
		m_arrDisplayLayer = nil
		m_arrWaitStr = nil
	end
end

function initTaskTipsLayer( )
	if m_pAlert then
		remove()
	end
	m_arrDisplayLayer = {}
	m_arrWaitStr = {}
	m_pAlert = TouchGroup:create()
	cc.Director:getInstance():getRunningScene():addChild(m_pAlert,TIPS_SCENE)
end