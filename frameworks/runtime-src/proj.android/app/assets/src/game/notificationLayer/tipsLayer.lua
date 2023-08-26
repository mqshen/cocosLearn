--屏幕飘出来的字幕
module("tipsLayer", package.seeall)

local dt = 0.3
local m_arrDisplayLayer = nil
local m_pAlert = nil
local fadeInTime = 0.3
local stayTime = 2
local fontNormal = 22

local function removeLayer( )
	if #m_arrDisplayLayer > 0 then
		m_arrDisplayLayer[1][1]:removeFromParentAndCleanup(true)
		table.remove(m_arrDisplayLayer,1)
	end
end

local function FadeOutAction( target, target_2 )
	-- local action1 = CCMoveBy:create(dt,ccp(0, 100*1*config.getgScale()))
	local action2 = CCFadeOut:create(dt)
	-- local array = animation.spawn({action1,action2})
	local action3 = cc.CallFunc:create(function ( )
		removeLayer()
	end)
	target:runAction(animation.sequence({action2, action3}))
	target_2:runAction(CCFadeOut:create(dt))
end

function create(text, dtime, arg, fontSize )
	if not text then return end
	if not m_pAlert then
		initTipsLayer()
	end

	local back_image = ImageView:create()
	back_image:loadTexture("test/res_single/Hidden_among_the_prompt_box.png",UI_TEX_TYPE_LOCAL)
	back_image:setSize(CCSize(330,61))
	back_image:setScale9Enabled(true)
	back_image:setCapInsets(CCRect(16,16,298,29))
	back_image:setScale(config.getgScale())
	back_image:setPosition(cc.p(config.getWinSize().width/2,config.getWinSize().height/2))
	-- back_image:setOpacity(0)
	-- back_image:setVisible(false)
	m_pAlert:addWidget(back_image)

	local _richText = RichText:create()
	local point = back_image:convertToNodeSpace(cc.p(config.getWinSize().width/2,config.getWinSize().height/2))
    _richText:setSize(CCSizeMake(config.getWinSize().width, back_image:getSize().height))
    _richText:setAnchorPoint(cc.p(0.5,0.5))
    _richText:setPosition(cc.p(point.x,point.y))
    back_image:addChild(_richText)

    local index = 1
    local temp
    local tempStr = string.gsub(text[2] or text, "&", function (n)
    	temp = arg[index]
    	index = index + 1
    	return temp or "&"
    end)
    local tStr = config.richText_split(tempStr)
    local re = nil
    local strTemp = ""
    for i,v in ipairs(tStr) do
    	if v[1] == 1 then
	    	re = RichElementText:create(i, ccc3(234,232,156), 255, v[2],config.getFontName(), fontSize or fontNormal)
		else
			re = RichElementText:create(i, ccc3(125,187,139), 255, v[2],config.getFontName(), fontSize or fontNormal)
		end
		strTemp = strTemp .. v[2]
		_richText:pushBackElement(re)
	end

	local pTempLabel = Label:create()
	pTempLabel:setFontSize(fontNormal)
	pTempLabel:setText(strTemp)
	local width = pTempLabel:getContentSize().width
	if width > back_image:getSize().width - 30 then
		back_image:setSize(CCSize(width + 30, back_image:getSize().height))
	end

	local action1 = CCFadeIn:create(fadeInTime)
	local action4 = cc.CallFunc:create(function ( )
		back_image:setVisible(true)
	end)

	local action2 = cc.DelayTime:create(stayTime)
	local action3 = cc.CallFunc:create(function ( )
		FadeOutAction( back_image, _richText )
	end)

	if #m_arrDisplayLayer > 0 then
		for i, v in ipairs(m_arrDisplayLayer) do
			removeLayer()
		end

		back_image:runAction(animation.sequence({action2, action3}))
	else
		back_image:setVisible(false)
		local spawn = animation.spawn({action1, action4})
		back_image:runAction(animation.sequence({spawn, action2, action3}))
		_richText:runAction(CCFadeIn:create(fadeInTime))
	end
	table.insert(m_arrDisplayLayer, {back_image, _richText})
end

function FadeOutLayerWhenPageChange( )
	if not m_pAlert then return end
	if not m_arrDisplayLayer then return end
	if #m_arrDisplayLayer > 0 then
		for i, v in ipairs(m_arrDisplayLayer) do
			v[1]:stopAllActions()
			v[2]:stopAllActions()
			FadeOutAction( v[1], v[2] )
		end
	end
end

function remove( )
	if m_pAlert then
		m_pAlert:removeFromParentAndCleanup(true)
		m_pAlert = nil
		m_arrDisplayLayer = nil
	end
end

function initTipsLayer( )
	if m_pAlert then
		remove()
	end
	m_arrDisplayLayer = {}
	m_pAlert = TouchGroup:create()
	cc.Director:getInstance():getRunningScene():addChild(m_pAlert,TIPS_SCENE)
end
