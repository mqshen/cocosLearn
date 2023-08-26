local uiDailyDevelop = {}

local m_pMainWidget = nil

local ColorUtil = require("game/utils/color_util")

local rich_text_split_h = 5

function uiDailyDevelop.remove()
	if not m_pMainWidget then return end

	m_pMainWidget:removeFromParentAndCleanup(true)
	m_pMainWidget = nil
end


local function getRichTextItem(richText)
	local richTextContent = RichText:create()
    richTextContent:ignoreContentAdaptWithSize(false)
    richTextContent:setVerticalSpace(rich_text_split_h)
    richTextContent:setSize(CCSizeMake(508, 0 ))
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
function uiDailyDevelop.reloadData(activityInfo)
	if not m_pMainWidget then return end
	
	local scrollPanel = uiUtil.getConvertChildByName(m_pMainWidget,"scrollPanel")
	local mainPanel = uiUtil.getConvertChildByName(scrollPanel,"mainPanel")
	mainPanel:removeAllChildrenWithCleanup(true)

	
	scrollPanel:setContentSize(CCSizeMake(518,400))
	scrollPanel:setInnerContainerSize(CCSizeMake(518,400))

	local last_pos_y = mainPanel:getContentSize().height
	
	
	if DailyDataModel.getActivityTimeDesc(activityInfo) ~= "" then
		local panel_time = uiUtil.getConvertChildByName(m_pMainWidget,"panel_time")
		local panel_time_clone = panel_time:clone()
		panel_time_clone:setVisible(true)
		-- panel_time_clone:setPositionX(10)
		
		mainPanel:addChild(panel_time_clone)

		last_pos_y = last_pos_y - panel_time_clone:getContentSize().height
		panel_time_clone:setPositionY(last_pos_y)

		local richTextContent = getRichTextItem(DailyDataModel.getActivityTimeDesc(activityInfo))
		mainPanel:addChild(richTextContent)
		richTextContent:setPositionY(last_pos_y)
		richTextContent:setPositionX(10)
		richTextContent:formatText()
		last_pos_y = last_pos_y - richTextContent:getRealHeight()
	end

	
	if activityInfo.desc_content and activityInfo.desc_content ~= "" then
		local panel_content = uiUtil.getConvertChildByName(m_pMainWidget,"panel_content")
		local panel_content_clone = panel_content:clone()
		panel_content_clone:setVisible(true)
		-- panel_content_clone:setPositionX(10)
		mainPanel:addChild(panel_content_clone)

		last_pos_y = last_pos_y - panel_content_clone:getContentSize().height
		panel_content_clone:setPositionY(last_pos_y)
		
		local richTextContent = getRichTextItem(activityInfo.desc_content)
		mainPanel:addChild(richTextContent)
		richTextContent:setPositionY(last_pos_y)
		richTextContent:setPositionX(10)
		richTextContent:formatText()
		last_pos_y = last_pos_y - richTextContent:getRealHeight()

	end



	if activityInfo.desc_reward_way and activityInfo.desc_reward_way ~= "" then
		local panel_reward_receivedHow = uiUtil.getConvertChildByName(m_pMainWidget,"panel_reward_receivedHow")
		local panel_reward_receivedHow_clone = panel_reward_receivedHow:clone()
		panel_reward_receivedHow_clone:setVisible(true)
		-- panel_reward_receivedHow_clone:setPositionX(10)
		mainPanel:addChild(panel_reward_receivedHow_clone)

		last_pos_y = last_pos_y - panel_reward_receivedHow_clone:getContentSize().height
		panel_reward_receivedHow_clone:setPositionY(last_pos_y)
	
		local richTextContent = getRichTextItem(activityInfo.desc_reward_way)
		mainPanel:addChild(richTextContent)
		richTextContent:setPositionY(last_pos_y)
		richTextContent:setPositionX(10)
		richTextContent:formatText()
		last_pos_y = last_pos_y - richTextContent:getRealHeight()

	end


	

	if activityInfo.desc_reward_time and activityInfo.desc_reward_time ~= "" then
		local panel_reward_receivedWhen = uiUtil.getConvertChildByName(m_pMainWidget,"panel_reward_receivedWhen")
		local panel_reward_receivedWhen_clone = panel_reward_receivedWhen:clone()
		panel_reward_receivedWhen_clone:setVisible(true)
		-- panel_reward_receivedWhen_clone:setPositionX(10)
		mainPanel:addChild(panel_reward_receivedWhen_clone)

		last_pos_y = last_pos_y - panel_reward_receivedWhen_clone:getContentSize().height
		panel_reward_receivedWhen_clone:setPositionY(last_pos_y)
		

		local richTextContent = getRichTextItem(activityInfo.desc_reward_time)
		mainPanel:addChild(richTextContent)
		richTextContent:setPositionY(last_pos_y)
		richTextContent:setPositionX(10)
		richTextContent:formatText()
		last_pos_y = last_pos_y - richTextContent:getRealHeight()

	end
	
	local img_drag_flag_down = uiUtil.getConvertChildByName(m_pMainWidget,"img_drag_flag_down")
    local img_drag_flag_up = uiUtil.getConvertChildByName(m_pMainWidget,"img_drag_flag_up")

	local ori_w = scrollPanel:getContentSize().width
    local ori_h = scrollPanel:getContentSize().height

	local real_h = mainPanel:getContentSize().height - last_pos_y
	if real_h > ori_h then
		scrollPanel:setInnerContainerSize(CCSizeMake(ori_w,real_h))
		mainPanel:setPositionY(real_h - ori_h )
		scrollPanel:setTouchEnabled(true)
		img_drag_flag_down:setVisible(true)
		img_drag_flag_up:setVisible(false)
	else
		mainPanel:setPositionY(0)
		scrollPanel:setTouchEnabled(false)
    	img_drag_flag_up:setVisible(false)
    	img_drag_flag_down:setVisible(false)
	end
end

local function init()
	if not m_pMainWidget then return end
	
	local panel_time = uiUtil.getConvertChildByName(m_pMainWidget,"panel_time")
	panel_time:setVisible(false)
	
	local panel_content = uiUtil.getConvertChildByName(m_pMainWidget,"panel_content")
	panel_content:setVisible(false)

	local panel_reward_receivedHow = uiUtil.getConvertChildByName(m_pMainWidget,"panel_reward_receivedHow")
	panel_reward_receivedHow:setVisible(false)

	local panel_reward_receivedWhen = uiUtil.getConvertChildByName(m_pMainWidget,"panel_reward_receivedWhen")
	panel_reward_receivedWhen:setVisible(false)



	local scrollPanel = uiUtil.getConvertChildByName(m_pMainWidget,"scrollPanel")
    local mainPanel = uiUtil.getConvertChildByName(scrollPanel,"mainPanel")

    local img_drag_flag_down = uiUtil.getConvertChildByName(m_pMainWidget,"img_drag_flag_down")
    local img_drag_flag_up = uiUtil.getConvertChildByName(m_pMainWidget,"img_drag_flag_up")
    img_drag_flag_up:setVisible(false)
    img_drag_flag_down:setVisible(false)

	breathAnimUtil.start_scroll_dir_anim(img_drag_flag_up, img_drag_flag_down)

    local function ScrollViewEvent(sender, eventType) 
        if eventType == SCROLLVIEW_EVENT_SCROLL_TO_TOP then 
            img_drag_flag_up:setVisible(false)
            img_drag_flag_down:setVisible(true)
        elseif eventType == SCROLLVIEW_EVENT_SCROLL_TO_BOTTOM then 
            img_drag_flag_up:setVisible(true)
            img_drag_flag_down:setVisible(false)
        elseif eventType == SCROLLVIEW_EVENT_SCROLLING then
            if scrollPanel:getInnerContainer():getPositionY() > (-mainPanel:getPositionY()) and 
                scrollPanel:getInnerContainer():getPositionY() < 0  then 
                img_drag_flag_down:setVisible(true)
                img_drag_flag_up:setVisible(true)
            end
        end
    end 
    scrollPanel:addEventListenerScrollView(ScrollViewEvent)

end

local function create()
	if m_pMainWidget then return end

	m_pMainWidget = GUIReader:shareReader():widgetFromJsonFile("test/huodong_3.json")
	init()


	return m_pMainWidget
end


function uiDailyDevelop.getInstance()
	create()
	return m_pMainWidget
end

return uiDailyDevelop
