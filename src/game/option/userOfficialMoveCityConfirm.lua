module("UserOfficialMoveCityConfirm", package.seeall)
-- 迁城确认界面
-- 类名 ：  UserOfficialMoveCityConfirm
-- json名：  qianchengqueren.json
-- 配置ID:	UI_USER_OFFICIAL_MOVE_CITY_CONFIRM

local StringUtil = require("game/utils/string_util")
local textEditbox = nil
local m_pMainLayer = nil
function reloadData()

end



local function do_remove_self()
	if m_pMainLayer then 

		m_pMainLayer:removeFromParentAndCleanup(true)
        m_pMainLayer = nil
        if textEditbox then  
			textEditbox:removeFromParentAndCleanup(true)
			textEditbox = nil
		end
        uiManager.remove_self_panel(uiIndexDefine.UI_USER_OFFICIAL_MOVE_CITY_CONFIRM)
	end
end


function remove_self(closeEffect)
	if closeEffect then 
		do_remove_self()
		return 
	end
	uiManager.hideConfigEffect(uiIndexDefine.UI_USER_OFFICIAL_MOVE_CITY_CONFIRM, m_pMainLayer, do_remove_self, 999)
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


local function checkBtnState()
	if not m_pMainLayer then return end

	local widget = m_pMainLayer:getWidgetByTag(999)

	local btn_confirm = uiUtil.getConvertChildByName(widget,"btn_confirm")
	local ret_str = StringUtil.DelS(textEditbox:getText())
    if ret_str == languagePack['move_city_confirm'] then
		btn_confirm:setBright(true)
	else
		btn_confirm:setBright(false)
	end
end
function create(coordinate_wid,coordinate_name)
	if m_pMainLayer then return end

	local widget = GUIReader:shareReader():widgetFromJsonFile("test/qianchengqueren.json")
    widget:setTag(999)
	widget:setScale(config.getgScale())
	widget:ignoreAnchorPointForPosition(false)
	widget:setAnchorPoint(cc.p(0.5, 0.5))
	widget:setPosition(cc.p(config.getWinSize().width/2 , config.getWinSize().height/2))

	m_pMainLayer = TouchGroup:create()
    m_pMainLayer:addWidget(widget)
    uiManager.add_panel_to_layer(m_pMainLayer, uiIndexDefine.UI_USER_OFFICIAL_MOVE_CITY_CONFIRM)
	
  
    
    local edit_panel = uiUtil.getConvertChildByName(widget,"edit_panel")
    edit_panel:setVisible(true)
    edit_panel:setBackGroundColorType(LAYOUT_COLOR_NONE)
	local size_width = edit_panel:getSize().width
	local size_height = edit_panel:getSize().height
	--输入正文
	
	local editBoxSize = CCSizeMake(edit_panel:getContentSize().width*config.getgScale(),edit_panel:getContentSize().height*config.getgScale() )
	local rect = CCRectMake(9,9,2,2)

	textEditbox = CCEditBox:create(editBoxSize, CCScale9Sprite:createWithSpriteFrameName("Enter_the_name_plate.png",rect))
	textEditbox:setAlignment(1)
	textEditbox:setFontName(config.getFontName())
	textEditbox:setFontSize(20*config.getgScale())
	textEditbox:setFontColor(ccc3(91,92,96))
	widget:addChild(textEditbox)
	textEditbox:setScale(1/config.getgScale())
	textEditbox:setPosition(cc.p(edit_panel:getPositionX(), edit_panel:getPositionY()))
	textEditbox:setAnchorPoint(cc.p(0,0))
	textEditbox:setVisible(true)
  	textEditbox:setText(languagePack['default_editor_tips'])
  	textEditbox:setZOrder(999)

  	textEditbox:registerScriptEditBoxHandler(function (strEventName,pSender)
            
        if strEventName == "began" then
            textEditbox:setText(" ")    
        elseif strEventName == "return" then
            if StringUtil.DelS(textEditbox:getText()) == '' then
                textEditbox:setText(languagePack['default_editor_tips'])
            end
            checkBtnState()
        end
    end)


  	local btn_cancel = uiUtil.getConvertChildByName(widget,"btn_cancel")
  	btn_cancel:setTouchEnabled(true)
    btn_cancel:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_BEGAN then 
        	remove_self()
        end
    end)


    local btn_confirm = uiUtil.getConvertChildByName(widget,"btn_confirm")
  	btn_confirm:setTouchEnabled(true)
    btn_confirm:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_BEGAN then 
        	local ret_str = StringUtil.DelS(textEditbox:getText())
        	if ret_str == languagePack['move_city_confirm'] then
        		-- TODOTK
        		remove_self()
                local userOfficialMoveCity = require("game/option/userOfficialMoveCity")
                userOfficialMoveCity.onSelectedTargetCityWid(coordinate_wid)
        	else
        		tipsLayer.create(errorTable[154])
        	end
        end
    end)

    checkBtnState()


    local label_city_name = uiUtil.getConvertChildByName(widget,"label_city_name")
    local label_city_coordinate = uiUtil.getConvertChildByName(widget,"label_city_coordinate")
    label_city_name:setText(coordinate_name)
    local coor_x = math.floor(coordinate_wid / 10000)
    local coor_y = coordinate_wid % 10000
    label_city_coordinate:setText("(" .. coor_x .. "," .. coor_y .. ")")
	uiManager.showConfigEffect(uiIndexDefine.UI_USER_OFFICIAL_MOVE_CITY_CONFIRM,m_pMainLayer)
end