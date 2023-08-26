local loginServerList = {}

local main_layer = nil

local uiUtil = require("game/utils/ui_util")

local SERVER_NUM_PER_ROW = 2

local SERVER_STATE_IMGS = {}
SERVER_STATE_IMGS[1] = "new_server_tuijian_Icon.png"
SERVER_STATE_IMGS[2] = "new_server_weihu_Icon.png"

local list_tabel_item_width = 0
local list_tabel_item_height = 0

local selected_indx = nil
local temp_cells = nil
local is_scrolling = nil
local last_offset_y = nil
-- local function tableCellHightlight(table,cell)
-- 	local item_layer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
-- 	if item_layer then
-- 		local item_layout = tolua.cast(item_layer:getWidgetByTag(11),"Layout")
-- 		if item_layout then
--     		local item_btn = item_layout:getChildByTag(111)
--     		local img_selected = uiUtil.getConvertChildByName(item_btn,"img_selected")
--     		img_selected:setVisible(true)
--     	end
--     end
-- end

-- local function tableCellUnhightlight(table,cell)
-- 	local item_layer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
-- 	if item_layer then
-- 		local item_layout = tolua.cast(item_layer:getWidgetByTag(11),"Layout")
-- 		if item_layout then
--     		local item_btn = item_layout:getChildByTag(111)
--     		local img_selected = uiUtil.getConvertChildByName(item_btn,"img_selected")
--     		img_selected:setVisible(false)
--     	end
--     end
-- end



-- local function tableCellTouched(table,cell_t)

-- 	selected_indx = cell_t:getIdx()+1

--     for k,cell in pairs(temp_cells) do
--         local item_layer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
--     	if item_layer then
-- 	    	local item_layout = tolua.cast(item_layer:getWidgetByTag(11),"Layout")
-- 		    if item_layout then
--     		    local item_btn = item_layout:getChildByTag(111)
--     		    local img_selected = uiUtil.getConvertChildByName(item_btn,"img_selected")
--     			if cell:getIdx() + 1 == selected_indx then     
--                     img_selected:setVisible(true)
--                 else
--                     img_selected:setVisible(false)
--                 end
--     	    end
--         end
--     end

-- end

local function cellSizeForTable()
	return list_tabel_item_height,list_tabel_item_width
end

local function numberOfCellsInTableView(table)
    return math.ceil(#loginData.getServerList()/2) 
end


function loginServerList.remove()
	if main_layer then 
		main_layer:removeFromParentAndCleanup(true)
		main_layer = nil
		selected_indx = nil
        temp_cells = nil
        is_scrolling = nil
        last_offset_y = nil
	end
end

local function dealWithClickBtnClose(sender,eventType)
	if eventType == TOUCH_EVENT_ENDED then
		loginGUI.createEnterGame(nil)
		loginServerList.remove()
		loginGUI.setUIVisible(true)
	end
end

local function dealWithClickBtnOK(sender,eventType)
	if eventType == TOUCH_EVENT_ENDED then 
		if nil == selected_indx then 
		-- 	loginGUI.createEnterGame(nil)
		else
			local serverList = loginData.getServerList()
			local serverInfo = serverList[selected_indx]
			loginGUI.createEnterGame(serverInfo.server_id)
		end
		loginServerList.remove()
		loginGUI.setUIVisible(true)
	end
end

local function updateServerDesc(row,col)

	local serverList = loginData.getServerList()
 	local indx = (row - 1) * SERVER_NUM_PER_ROW + col
	local serverInfo = serverList[indx]
	if not serverInfo then return end

	if not main_layer then return end
	local temp_widget = main_layer:getWidgetByTag(999)
	if not temp_widget then return end

	

	local descScrollView = uiUtil.getConvertChildByName(temp_widget,"scrollView")
	descScrollView:setBackGroundColorType(LAYOUT_COLOR_NONE)

	local panel_desc = uiUtil.getConvertChildByName(descScrollView,"panel_desc")
	panel_desc:setBackGroundColorType(LAYOUT_COLOR_NONE)

	panel_desc:removeAllChildrenWithCleanup(true)


	local _richText = RichText:create()
    _richText:setVerticalSpace(3)
    _richText:setAnchorPoint(cc.p(0,1))
    _richText:ignoreContentAdaptWithSize(false)
    _richText:setSize(CCSizeMake(panel_desc:getContentSize().width, panel_desc:getContentSize().height))
    panel_desc:addChild(_richText)
    _richText:setPosition(cc.p(0,panel_desc:getContentSize().height))

 --    public Byte flag_hidden;

	-- public String description;

    local str = serverInfo.description
    if not str or str == "" then 
    	str = languagePack['noAnnouncement'] 
    end
    
    local index = 1
    local tempStr = string.gsub(str, "&", function (n)
        temp = arg[index]
        index = index + 1
        return temp or "&"
    end)
    local tStr = config.richText_split(tempStr)
    local re1 = nil
    for i,v in ipairs(tStr) do
        if v[1] == 1 then
            re1 = RichElementText:create(i, ccc3(255,255,255), 255, v[2],config.getFontName(), 20)
        else
            re1 = RichElementText:create(i, ccc3(255,213,110), 255, v[2],config.getFontName(), 20)
        end
        _richText:pushBackElement(re1)
    end
    
    _richText:formatText()

    local realHeight = _richText:getRealHeight()
    local twidth = descScrollView:getContentSize().width
    if  realHeight > panel_desc:getContentSize().height then 
        descScrollView:setInnerContainerSize(CCSizeMake(twidth,realHeight))
        panel_desc:setPositionY(realHeight - panel_desc:getContentSize().height)
        descScrollView:setTouchEnabled(true)
    else
    	descScrollView:setInnerContainerSize(CCSizeMake(twidth,realHeight))
    	panel_desc:setPositionY(0)
    	descScrollView:setTouchEnabled(false)
    end
    local up_img = uiUtil.getConvertChildByName(temp_widget,"img_dragFlagUp")
	local down_img = uiUtil.getConvertChildByName(temp_widget,"img_dragFlagDown")
	up_img:setVisible(false)
	down_img:setVisible(false)
end


local function setSelectedServerItem(row,col,serverItem)
	local indx = (row - 1) * SERVER_NUM_PER_ROW + col
	if selected_indx and (selected_indx == indx) then return end
	selected_indx = indx

    for k,cell in pairs(temp_cells) do
        local item_layer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
    	if item_layer then
	    	local item_layout = tolua.cast(item_layer:getWidgetByTag(11),"Layout")
		    if item_layout then
		    	local item_btn = nil
		    	local img_selected
		    	for i = 1, SERVER_NUM_PER_ROW do 
		    		item_btn = item_layout:getChildByTag(110 + i)
		    		if item_btn then 
			    		img_selected = uiUtil.getConvertChildByName(item_btn,"img_selected")
	    				img_selected:setVisible(false)
	    			end
	    		end
    	    end
        end
    end
    local img_selected = uiUtil.getConvertChildByName(serverItem,"img_selected")
    img_selected:setVisible(true)

    updateServerDesc(row,col)
end



-- 第 row 行 第 col 列的 serverItem
local function cloneServerItem(row,col)
	local temp_widget = main_layer:getWidgetByTag(999)
	local list_bg = uiUtil.getConvertChildByName(temp_widget,"list_bg")
	local list_panel = uiUtil.getConvertChildByName(list_bg,"list_panel")
 	local btn_server_item = uiUtil.getConvertChildByName(list_panel,"btn_server_item")

 	local serverList = loginData.getServerList()
 	local loginsertList = loginData.getLoginServerList()
 	local indx = (row - 1) * SERVER_NUM_PER_ROW + col
	local serverInfo = serverList[indx]

	local item_btn = btn_server_item:clone()
	item_btn:setVisible(true)
	item_btn:setTouchEnabled(true)
	item_btn:addTouchEventListener(function(sender,eventType)
		if eventType == TOUCH_EVENT_BEGAN then 
	        is_scrolling = false
	        return true
	    elseif eventType == TOUCH_EVENT_ENDED then
	        if is_scrolling then return end 
	        setSelectedServerItem(row,col,item_btn)
	        is_scrolling = false
	    end
	end)

	local label_server_num = uiUtil.getConvertChildByName(item_btn,"label_server_num")
	label_server_num:setText(serverInfo.server_id%1000 .. languageBeforeLogin["server_title"])
	local label_name = uiUtil.getConvertChildByName(item_btn,"label_name")

	label_name:setText(serverInfo.name)
	label_name:setPositionX(label_server_num:getPositionX()+label_server_num:getSize().width+10)
	local img_selected = uiUtil.getConvertChildByName(item_btn,"img_selected")

    if selected_indx and (selected_indx == indx) then 
        img_selected:setVisible(true)
        setSelectedServerItem(row,col,item_btn)
        updateServerDesc(row,col)
    else
        img_selected:setVisible(false)
    end

    local img_new = uiUtil.getConvertChildByName(item_btn,"img_new")
    local img_state = uiUtil.getConvertChildByName(item_btn,"img_state")

    --是否有账号
    local has_img_login = uiUtil.getConvertChildByName(item_btn,"img_havepeople")
    has_img_login:setVisible(false)

    if loginsertList[serverInfo.server_id] then
    	has_img_login:setVisible(true)
    end

    if serverInfo.flag_new == 1 then 
    	img_new:setVisible(true)
    else
    	img_new:setVisible(false)
    end

    -- 正常状态不显示 状态图片
    img_state:setVisible(false)

    if serverInfo.flag_recommand == 1 then 
    	-- 推荐
    	img_state:loadTexture(SERVER_STATE_IMGS[1], UI_TEX_TYPE_PLIST)
    	img_state:setVisible(true)
    else
    	if serverInfo.flag_maintain == 1 then 
    		-- 维护
    		img_state:loadTexture(SERVER_STATE_IMGS[2], UI_TEX_TYPE_PLIST)
    		img_state:setVisible(true)
    	end
    end

    if serverInfo.flag_maintain == 1 then 
    	label_name:setColor(ccc3(110,110,110))
    	label_server_num:setColor(ccc3(110,110,110))
    else
    	label_name:setColor(ccc3(233,233,233))
    	label_server_num:setColor(ccc3(233,233,233))
    end

    return item_btn
end
function loginServerList.create()
	if main_layer then return end
	local serverInfo = loginData.getLastCacheServer()
	if not serverInfo then return end
	loginGUI.setUIVisible(false)
	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/login_server_list.json")
	temp_widget:setTag(999)
	temp_widget:setScale(configBeforeLoad.getgScale())
	temp_widget:ignoreAnchorPointForPosition(false)
	temp_widget:setAnchorPoint(cc.p(0.5,0.5))
	temp_widget:setPosition(cc.p(configBeforeLoad.getWinSize().width/2, configBeforeLoad.getWinSize().height/2))
 	
 	main_layer = TouchGroup:create()
	local layout = Layout:create()
    layout:setSize(CCSize(configBeforeLoad.getWinSize().width, configBeforeLoad.getWinSize().height))
    layout:setTouchEnabled(true)
    main_layer:addWidget(layout)
	main_layer:addWidget(temp_widget)
    cc.Director:getInstance():getRunningScene():addChild(main_layer)  
 	-- loginGUI.add_login_content(main_layer)

 	local hearder_bg = uiUtil.getConvertChildByName(temp_widget,"hearder_bg")
 	local btn_close = uiUtil.getConvertChildByName(hearder_bg,"btn_close")
 	btn_close:setTouchEnabled(true)
 	btn_close:addTouchEventListener(dealWithClickBtnClose)

 	local btn_ok = uiUtil.getConvertChildByName(temp_widget,"btn_ok")
 	btn_ok:setTouchEnabled(true)
 	btn_ok:addTouchEventListener(dealWithClickBtnOK)


 	-- 上一次登录的服务器
    loginData.getLastCacheServer()
    local lasted_bg = uiUtil.getConvertChildByName(temp_widget,"lasted_bg")
    local btn_server_item_lasted = uiUtil.getConvertChildByName(lasted_bg,"btn_server_item_lasted")
    local img_new = uiUtil.getConvertChildByName(btn_server_item_lasted,"img_new")
    local img_state = uiUtil.getConvertChildByName(btn_server_item_lasted,"img_state")
    if serverInfo.flag_new == 1 then 
    	img_new:setVisible(true)
    else
    	img_new:setVisible(false)
    end

    -- 正常状态不显示 状态图片
    img_state:setVisible(false)

    if serverInfo.flag_recommand == 1 then 
    	-- 推荐
    	img_state:loadTexture(SERVER_STATE_IMGS[1], UI_TEX_TYPE_PLIST)
    	img_state:setVisible(true)
    else
    	if serverInfo.flag_maintain == 1 then 
    		-- 维护
    		img_state:loadTexture(SERVER_STATE_IMGS[2], UI_TEX_TYPE_PLIST)
    		img_state:setVisible(true)
    	end
    end
    local label_server_num = uiUtil.getConvertChildByName(btn_server_item_lasted,"label_server_num")
	label_server_num:setText(serverInfo.server_id%1000 .. languageBeforeLogin["server_title"])
	local label_name = uiUtil.getConvertChildByName(btn_server_item_lasted,"label_name")
	label_name:setText(serverInfo.name)
	label_name:setPositionX(label_server_num:getPositionX()+label_server_num:getSize().width+10)
	if serverInfo.flag_maintain == 1 then 
    	label_name:setColor(ccc3(110,110,110))
    	label_server_num:setColor(ccc3(110,110,110))
    else
    	label_name:setColor(ccc3(233,233,233))
    	label_server_num:setColor(ccc3(233,233,233))
    end


	for k,v in ipairs(loginData.getServerList()) do 
		if v.server_id == serverInfo.server_id then
			selected_indx = k 
		end
	end

 	local list_bg = uiUtil.getConvertChildByName(temp_widget,"list_bg")
 	local list_panel = uiUtil.getConvertChildByName(list_bg,"list_panel")
 	list_panel:setBackGroundColorType(LAYOUT_COLOR_NONE)
 	local btn_server_item = uiUtil.getConvertChildByName(list_panel,"btn_server_item")
 	btn_server_item:setVisible(false)
 	btn_server_item:setTouchEnabled(false)

 	local size_width  = btn_server_item:getSize().width
 	local size_height = btn_server_item:getSize().height


 	list_tabel_item_width = size_width * 2 + 10
 	list_tabel_item_height = size_height + 2

 	temp_cells = {}

 	local serverList = loginData.getServerList()

 	local function tableCellAtIndex(table, idx)
 		
	    local indx = idx + 1
	    
	    

    	local cell = table:dequeueCell()
    	if nil == cell then
        	cell = CCTableViewCell:new()
        	local mlayer = TouchGroup:create()
        	mlayer:setTag(1)
        	cell:addChild(mlayer)

        	local layout = Layout:create()
			mlayer:addWidget(layout)
			layout:ignoreAnchorPointForPosition(false)
			layout:setAnchorPoint(cc.p(0,0))
			layout:setTag(11)
			
    	end

        temp_cells[indx] = cell
        

    	local item_layer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
    	if item_layer then
    		local item_layout = tolua.cast(item_layer:getWidgetByTag(11),"Layout")
			if item_layout then
				local serverItem = nil
				for i = 1,SERVER_NUM_PER_ROW do
					serverItem = item_layout:getChildByTag(110 + i)
		    		if serverItem then serverItem:removeFromParentAndCleanup(true) end
					if idx*SERVER_NUM_PER_ROW + i <= #serverList then 
						serverItem = cloneServerItem(indx,i)
						serverItem:setTag(110 + i)
						item_layout:addChild(serverItem)
						serverItem:setPosition(cc.p( 5 + size_width/2 + (i - 1) * (10 + size_width),list_tabel_item_height/2))
					end
				end
			end
    	end
    	return cell
	end

	-- 滑动到顶部或底部的时候的回调
	local function scrollViewDidScroll(view)
	    if not last_offset_y then 
	        last_offset_y = list_panel:getContentSize().height
	        last_offset_y = last_offset_y - view:getContainer():getContentSize().height 
	    end
	    if math.abs(view:getContainer():getPositionY() - last_offset_y) > 1 then 
	        is_scrolling = true
	    end
	    
	    last_offset_y = view:getContainer():getPositionY()
	    local up_img = uiUtil.getConvertChildByName(list_bg,"img_dragFlagUp")
	    local down_img = uiUtil.getConvertChildByName(list_bg,"img_dragFlagDown")
	    if view:getContentOffset().y < 0 then
	        down_img:setVisible(true)
	    else
	        down_img:setVisible(false)
	    end

	    if view:getContentSize().height + view:getContentOffset().y > view:getViewSize().height then
	        up_img:setVisible(true)
	    else
	        up_img:setVisible(false)
	    end
	end

	local up_img_1 = uiUtil.getConvertChildByName(list_bg,"img_dragFlagUp")
	local down_img_1 = uiUtil.getConvertChildByName(list_bg,"img_dragFlagDown")
	require("game/utils/breathAnimUtil")
	breathAnimUtil.start_anim(up_img_1, true, 76, 255, 1, 0)
	breathAnimUtil.start_anim(down_img_1, true, 76, 255, 1, 0)
 	
 	local list_tabel_view = CCTableView:create(CCSizeMake(list_panel:getSize().width,list_panel:getSize().height))
 	list_panel:addChild(list_tabel_view)
 	list_tabel_view:setDirection(kCCScrollViewDirectionVertical)
 	list_tabel_view:setVerticalFillOrder(kCCTableViewFillTopDown)
	list_tabel_view:ignoreAnchorPointForPosition(false)
	list_tabel_view:setAnchorPoint(cc.p(0.5,0.5))
	list_tabel_view:setPosition(cc.p(list_panel:getSize().width/2,list_panel:getSize().height/2))
	-- list_tabel_view:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
	--list_tabel_view:registerScriptHandler(tableCellHightlight,CCTableView.kTableCellHighLight)
	--list_tabel_view:registerScriptHandler(tableCellUnhightlight,CCTableView.kTableCellUnhighLight)

	list_tabel_view:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)

    list_tabel_view:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
    list_tabel_view:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)

    list_tabel_view:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
    list_tabel_view:reloadData()

    
	list_panel:runAction(CCFadeIn:create(0.3))




	--  服务器描述信息
	local descScrollView = uiUtil.getConvertChildByName(temp_widget,"scrollView")
	descScrollView:setBackGroundColorType(LAYOUT_COLOR_NONE)

	local panel_desc = uiUtil.getConvertChildByName(descScrollView,"panel_desc")
	panel_desc:setBackGroundColorType(LAYOUT_COLOR_NONE)

	

	local up_img = uiUtil.getConvertChildByName(temp_widget,"img_dragFlagUp")
	local down_img = uiUtil.getConvertChildByName(temp_widget,"img_dragFlagDown")
	up_img:setVisible(false)
	down_img:setVisible(false)
	breathAnimUtil.start_anim(up_img, true, 76, 255, 1, 0)
	breathAnimUtil.start_anim(down_img, true, 76, 255, 1, 0)

	local function ScrollViewEvent(sender, eventType) 
		local up_img = uiUtil.getConvertChildByName(temp_widget,"img_dragFlagUp")
		local down_img = uiUtil.getConvertChildByName(temp_widget,"img_dragFlagDown")
    	if eventType == SCROLLVIEW_EVENT_SCROLL_TO_TOP then 
    		up_img:setVisible(false)
    		down_img:setVisible(true)
    	elseif eventType == SCROLLVIEW_EVENT_SCROLL_TO_BOTTOM then 
    		up_img:setVisible(true)
    		down_img:setVisible(false)
    	elseif eventType == SCROLLVIEW_EVENT_SCROLLING then
    		if descScrollView:getInnerContainer():getPositionY() > (-panel_desc:getPositionY()) and 
				descScrollView:getInnerContainer():getPositionY() < 0  then 
    			down_img:setVisible(true)
    			up_img:setVisible(true)
    		end
    	end
	end 

	descScrollView:addEventListenerScrollView(ScrollViewEvent)

end

function loginServerList.fillData()
	local temp_widget = main_layer:getWidgetByTag(999)

end

function loginServerList.show(parent)
	loginServerList.create()
	loginServerList.fillData()
end

function loginServerList.getInstance( )
	return mlayer
end

return loginServerList








--[[
233,233,233
110,110,110

]]