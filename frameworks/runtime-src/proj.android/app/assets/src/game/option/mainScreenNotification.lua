--屏幕滚动公告
module("MainScreenNotification", package.seeall)
local main_layer = nil
local arrStrAndSprite = nil

local m_dt_width = 100
local dt = 30
local delaytime = 0.2
local fontsize = 24

local scrollView1 = nil
local back_image = nil
local m_scrollViewLayer = nil

local ColorUtil = require("game/utils/color_util")
function remove(  )
	if main_layer then
		main_layer:removeFromParentAndCleanup(true)
		main_layer = nil
		arrStrAndSprite = nil
		scrollView1 = nil
		back_image = nil
		m_scrollViewLayer = nil
	end
end

local function removeLayer( )
	if back_image then
		back_image:removeFromParentAndCleanup(true)
		scrollView1 = nil
		back_image = nil
		m_scrollViewLayer = nil
	end
end

function create(text,arg )
	if not userData.isNewBieTaskFinished() then return end
	if not text then return end
	if not main_layer then return end

	if arrStrAndSprite and #arrStrAndSprite == 0 then 
		back_image = ImageView:create()
		back_image:loadTexture("zhujiemian_gundonggonggao_n.png",UI_TEX_TYPE_PLIST)
		back_image:setScale(config.getgScale())
		back_image:setAnchorPoint(cc.p(0.5,1))

		back_image:setPosition(cc.p(config.getWinSize().width/2,config.getWinSize().height - 110 * config.getgScale()))
		main_layer:addWidget(back_image)

		m_scrollViewLayer = CCLayer:create()

		local temp = CCLabelTTF:create("f",config.getFontName(), 24)
		temp:setFontSize(fontsize)

		m_scrollViewLayer:setContentSize(CCSize(back_image:getSize().width-100,temp:getContentSize().height))

		scrollView1 = CCScrollView:create()
		scrollView1:ignoreAnchorPointForPosition(false)
		scrollView1:setAnchorPoint(cc.p(0.5,0.5))
		scrollView1:setViewSize(CCSizeMake(m_scrollViewLayer:getContentSize().width,m_scrollViewLayer:getContentSize().height))
	    scrollView1:setContainer(m_scrollViewLayer)
	    scrollView1:updateInset()
	    scrollView1:setDirection(kCCScrollViewDirectionVertical)
	    scrollView1:setClippingToBounds(true)
	    scrollView1:setBounceable(false)
	    back_image:addChild(scrollView1)
	    scrollView1:setPositionY(-back_image:getSize().height/2)
	end
	

    local index = 1
    local temp
    local tempStr = string.gsub(text[1] or text, "&", function (n)
    	temp = arg[index]
    	index = index + 1
    	return temp or "&"
    end)
    local tStr = config.richText_split(tempStr)

	local pTempLabel = nil
	local width = 0
	local layer = CCLayer:create()
	for i, v in ipairs(tStr) do
		pTempLabel = Label:create()
		pTempLabel:setFontSize(fontsize)
		pTempLabel:setText(v[2])
		if v[1] == 1 then
			pTempLabel:setColor(ColorUtil.CCC_RICH_TEXT_NORMAL)
		else
			pTempLabel:setColor(ColorUtil.CCC_RICH_TEXT_KEY_WORD)
		end
		pTempLabel:setAnchorPoint(cc.p(1,0))
		width = width + pTempLabel:getSize().width
		layer:setContentSize(CCSize(width, pTempLabel:getSize().height))
		layer:addChild(pTempLabel)
		pTempLabel:setPosition(cc.p(width, 0))
	end
	m_scrollViewLayer:addChild(layer)

	table.insert(arrStrAndSprite,{text, layer})

	if #arrStrAndSprite > 1 then
		local sprite = arrStrAndSprite[#arrStrAndSprite-1][2]
		if sprite 
		and sprite:getPositionX() + sprite:getContentSize().width + m_dt_width > m_scrollViewLayer:getContentSize().width then
			layer:setPositionX(sprite:getPositionX() + sprite:getContentSize().width + m_dt_width + dt)
		else
			layer:setPositionX(m_scrollViewLayer:getContentSize().width)
		end
	else
		layer:setPositionX(m_scrollViewLayer:getContentSize().width)
	end

	local action = animation.sequence({CCMoveBy:create((layer:getPositionX()+layer:getContentSize().width)/100, ccp(-(layer:getPositionX()+layer:getContentSize().width), 0)),
		cc.DelayTime:create(delaytime),cc.CallFunc:create(function ( )
			table.remove(arrStrAndSprite,1)
			if #arrStrAndSprite == 0 then
				removeLayer()
			end
		end)})
	layer:runAction(action)

end

function init( )
	if main_layer then
		remove()
	end
	arrStrAndSprite = {}
	main_layer = TouchGroup:create()
	cc.Director:getInstance():getRunningScene():addChild(main_layer,ANNOUNCEMENT)
end


local function setEnable(flag)
	if main_layer then
        local temp = main_layer:getChildren()
        for i=0 , main_layer:getChildrenCount()-1 do
            tolua.cast(temp:objectAtIndex(i),"Widget"):setEnabled(flag)
        end
    end
end

function chageShowState(is_in_city,flag)
	if is_in_city then 
		setEnable(false)
	else
		setEnable(flag)
	end
end

