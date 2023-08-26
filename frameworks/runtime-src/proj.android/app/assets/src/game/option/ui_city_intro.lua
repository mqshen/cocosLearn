module("UICityIntro",package.seeall)
-- 城市介绍
-- 类名 UICityIntro
-- json名 wenhaoshuoming.json
-- 配置ID  UI_CITY_INTRO

local ColorUtil = require("game/utils/color_util")

local m_pMainLayer = nil

local m_iCityType = nil

-- TODOTK 中文收集
local CFG_INTRO_INFO_TITLE = {}
CFG_INTRO_INFO_TITLE[cityTypeDefine.zhucheng] = {}
CFG_INTRO_INFO_TITLE[cityTypeDefine.zhucheng][1] = "【主城简介】"
CFG_INTRO_INFO_TITLE[cityTypeDefine.zhucheng][2] = "【主城视野】"
CFG_INTRO_INFO_TITLE[cityTypeDefine.zhucheng][3] = "【主城沦陷】"

CFG_INTRO_INFO_TITLE[cityTypeDefine.fencheng] = {}
CFG_INTRO_INFO_TITLE[cityTypeDefine.fencheng][1] = "【分城简介】"
CFG_INTRO_INFO_TITLE[cityTypeDefine.fencheng][2] = "【分城视野】"
CFG_INTRO_INFO_TITLE[cityTypeDefine.fencheng][3] = "【分城拆除】"

CFG_INTRO_INFO_TITLE[cityTypeDefine.yaosai] = {}
CFG_INTRO_INFO_TITLE[cityTypeDefine.yaosai][1] = "【要塞简介】"
CFG_INTRO_INFO_TITLE[cityTypeDefine.yaosai][2] = "【要塞视野】"
CFG_INTRO_INFO_TITLE[cityTypeDefine.yaosai][3] = "【要塞拆除】"

local CFG_INTRO_INFO = {}
CFG_INTRO_INFO[cityTypeDefine.zhucheng] = {}
CFG_INTRO_INFO[cityTypeDefine.zhucheng][1] = "#是势力的根本。可在城内进行设施建造，部队配置、部队征兵、扩建操作。#"
CFG_INTRO_INFO[cityTypeDefine.zhucheng][2] = "#以主城为中心的5格土地范围内，是主城的视野范围。视野范围内可查看到其它势力的部队信息、建造中的要塞。可与同盟成员共享视野。#"
CFG_INTRO_INFO[cityTypeDefine.zhucheng][3] = "#主城耐久度被敌方同盟部队降低到0时会处于沦陷状态，并会失去一定数量的资源及领地，敌方同盟成员则可以借沦陷方领地地出征。可上缴资源给敌方同盟进行反叛，脱离沦陷。（注意：只有加入同盟后才能使敌方沦陷。）#"

CFG_INTRO_INFO[cityTypeDefine.fencheng] = {}
CFG_INTRO_INFO[cityTypeDefine.fencheng][1] = "#与主城功能类似，可在城内进行设施建造，部队配置、部队征兵、扩建操作。#"
CFG_INTRO_INFO[cityTypeDefine.fencheng][2] = "#以分城为中心的4格土地范围内，是分城的视野范围。视野范围内可查看到其它势力的部队信息。可与同盟成员共享视野。#"
CFG_INTRO_INFO[cityTypeDefine.fencheng][3] = "#可在都督府设施界面中手动拆除。或受到敌方部队攻击，耐久度降为0时被拆除。分城拆除后会变成废墟，在废墟上重建分城可保留原分城建造的设施，但设施等级会随机下降。#"

CFG_INTRO_INFO[cityTypeDefine.yaosai] = {}
CFG_INTRO_INFO[cityTypeDefine.yaosai][1] = "#可调动放置部队到要塞中，并允许1支部队在内征兵。适合前线征战的部队休整。#"
CFG_INTRO_INFO[cityTypeDefine.yaosai][2] = "#以要塞为中心的2格土地范围内，是要塞的视野范围。视野范围内可查看到其它势力的部队信息。可与同盟成员共享视野。#"
CFG_INTRO_INFO[cityTypeDefine.yaosai][3] = "#可在堡垒设施界面中手动拆除。或受到敌方部队攻击，耐久度降为0时被拆除。#"

local function do_remove_self()
	if m_pMainLayer then
		m_pMainLayer:removeFromParentAndCleanup(true)
		m_pMainLayer = nil
		
		m_iCityType = nil

		uiManager.remove_self_panel(uiIndexDefine.UI_CITY_INTRO)
	end
end

function remove_self()
	uiManager.hideConfigEffect(uiIndexDefine.UI_CITY_INTRO, m_pMainLayer, do_remove_self, 999)	
end

function dealwithTouchEvent(x,y)
	if not m_pMainLayer then return false end
	local widget = m_pMainLayer:getWidgetByTag(999)
	if not widget then return false end
	if widget:hitTest(cc.p(x,y)) then 
		return false
	else
		remove_self()
		return true
	end
end


local function getRichTextItem(richText)
	local richTextContent = RichText:create()
    richTextContent:ignoreContentAdaptWithSize(false)
    richTextContent:setVerticalSpace(2)
    richTextContent:setSize(CCSizeMake(555, 0 ))
    richTextContent:setAnchorPoint(cc.p(0,1))

	local re = nil
    local contentText = nil

    local parseData = config.richText_split(richText)
    for kk,vv in ipairs(parseData) do 
        contentText = vv[2]
        if vv[1] == 1 then 
            re = RichElementText:create(1,ColorUtil.CCC_TEXT_MAIN_CONTENT , 255, contentText,config.getFontName(), 22)
        else
            re = RichElementText:create(1,ColorUtil.CCC_TEXT_SUB_TITLE , 255, contentText,config.getFontName(), 22)
        end 
        richTextContent:pushBackElement(re)
    end

   	-- richTextContent:formatText()
	
	return richTextContent
end


local function loadIntroInfo()
	if not m_iCityType then return end
	if not CFG_INTRO_INFO_TITLE[m_iCityType] then return end

	if not m_pMainLayer then return end
	local mainWidget = m_pMainLayer:getWidgetByTag(999)
	
	local img_drag_flag_up = uiUtil.getConvertChildByName(mainWidget,"up_img")
	local img_drag_flag_down = uiUtil.getConvertChildByName(mainWidget,"down_img")
	img_drag_flag_down:setVisible(false)
	img_drag_flag_up:setVisible(false)
	
	local panel_title = uiUtil.getConvertChildByName(mainWidget,"panel_title")
	panel_title:setVisible(false)

	local panel_split = uiUtil.getConvertChildByName(mainWidget,"panel_split")
	panel_split:setVisible(false)
	
	local scrollView = uiUtil.getConvertChildByName(mainWidget,"scrollView")
	local scrollPanel = uiUtil.getConvertChildByName(scrollView,"main_panel")
	
	local last_pos_y = scrollPanel:getContentSize().height

	for i = 1,#CFG_INTRO_INFO_TITLE[m_iCityType] do 
		local panel_title_clone = panel_title:clone()
		panel_title_clone:setVisible(true)
		
		panel_title_clone:setPositionX(0)

		scrollPanel:addChild(panel_title_clone)
		last_pos_y = last_pos_y - panel_title_clone:getContentSize().height
		panel_title_clone:setPositionY(last_pos_y)
		
		local label_title = uiUtil.getConvertChildByName(panel_title_clone,"label_title")
		label_title:setText(CFG_INTRO_INFO_TITLE[m_iCityType][i])
		if CFG_INTRO_INFO[m_iCityType] and CFG_INTRO_INFO[m_iCityType][i] then
			local richTextContent = getRichTextItem(CFG_INTRO_INFO[m_iCityType][i])
			richTextContent:formatText()

			last_pos_y = last_pos_y - 5
			scrollPanel:addChild(richTextContent)
			richTextContent:setPositionY(last_pos_y)
			richTextContent:setPositionX(10)
			last_pos_y = last_pos_y - richTextContent:getRealHeight()


			if i ~= #CFG_INTRO_INFO_TITLE then
				local panel_split_clone = panel_split:clone()
				panel_split_clone:setVisible(true)
				last_pos_y = last_pos_y - panel_split_clone:getContentSize().height
				scrollPanel:addChild(panel_split_clone)
				panel_split_clone:setPositionY(last_pos_y)
				panel_split_clone:setPositionX(0)
			end
		end
	end


	local twidth = scrollView:getSize().width
    if last_pos_y >= 0 then 
        scrollView:setInnerContainerSize(CCSizeMake(twidth,scrollPanel:getSize().height))
        scrollPanel:setPositionY(0)
		scrollView:setTouchEnabled(false)
    else
    	scrollView:setInnerContainerSize(CCSizeMake(twidth,scrollPanel:getSize().height - last_pos_y))
        scrollPanel:setPositionY(-last_pos_y)
		scrollView:setTouchEnabled(true)
		img_drag_flag_down:setVisible(true)
    end

 
end
local function init()
	if not m_pMainLayer then return end

	local mainWidget = m_pMainLayer:getWidgetByTag(999)

	local scrollView = uiUtil.getConvertChildByName(mainWidget,"scrollView")
	local scrollPanel = uiUtil.getConvertChildByName(scrollView,"main_panel")

	local img_drag_flag_down = uiUtil.getConvertChildByName(mainWidget,"down_img")
	local img_drag_flag_up = uiUtil.getConvertChildByName(mainWidget,"up_img")
	img_drag_flag_down:setVisible(false)
	img_drag_flag_up:setVisible(false)
	
	local function ScrollViewEvent(sender, eventType) 
    	if eventType == SCROLLVIEW_EVENT_SCROLL_TO_TOP then 
    		img_drag_flag_up:setVisible(false)
    		img_drag_flag_down:setVisible(true)
    	elseif eventType == SCROLLVIEW_EVENT_SCROLL_TO_BOTTOM then 
    		img_drag_flag_up:setVisible(true)
    		img_drag_flag_down:setVisible(false)
    	elseif eventType == SCROLLVIEW_EVENT_SCROLLING then
    		if scrollView:getInnerContainer():getPositionY() > (-scrollPanel:getPositionY()) and 
				scrollView:getInnerContainer():getPositionY() < 0  then 
    			img_drag_flag_down:setVisible(true)
    			img_drag_flag_up:setVisible(true)
    		end
    	end
	end 

	scrollView:setTouchEnabled(true)

	scrollView:addEventListenerScrollView(ScrollViewEvent)
	

	local btn_ok = uiUtil.getConvertChildByName(mainWidget,"btn_ok")
	btn_ok:setTouchEnabled(true)
	btn_ok:addTouchEventListener(function(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then
			remove_self()
		end
	end)
	
	loadIntroInfo()
end

function create(cityType)
	if m_pMainLayer then return end
	
	m_iCityType = cityType

	local widget = GUIReader:shareReader():widgetFromJsonFile("test/wenhaoshuoming.json")
    widget:setTag(999)
	widget:setScale(config.getgScale())
	widget:ignoreAnchorPointForPosition(false)
	widget:setAnchorPoint(cc.p(0.5, 0.5))
    widget:setPosition(cc.p(config.getWinSize().width/2 , config.getWinSize().height/2))

	widget:setTouchEnabled(true)

    m_pMainLayer = TouchGroup:create()
    m_pMainLayer:addWidget(widget)
    uiManager.add_panel_to_layer(m_pMainLayer, uiIndexDefine.UI_CITY_INTRO,999)

	init()

	uiManager.showConfigEffect(uiIndexDefine.UI_CITY_INTRO,m_pMainLayer)
end
