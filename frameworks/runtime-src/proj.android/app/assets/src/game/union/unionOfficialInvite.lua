local UnionOfficialInvite = {}


local StringUtil = require("game/utils/string_util")

local uiUtil = require("game/utils/ui_util")
local union_id = nil
local mainWidget = nil
local list_data = nil
local list_tabel_view = nil
local item_height = nil
local item_width = nil

local textEditbox = nil
function UnionOfficialInvite.remove()
    if textEditbox then  
		textEditbox:removeFromParentAndCleanup(true)
		textEditbox = nil
	end
    if mainWidget then 
        mainWidget:removeFromParentAndCleanup(true)
        mainWidget = nil
    end
    union_id = nil
    list_data = nil
    list_tabel_view = nil
    item_width = nil
    item_height = nil
end

local function dealWithClickInviteDirectly(sender,eventType)
    if eventType == TOUCH_EVENT_ENDED then
        if userData.getAffilated_union_id() ~= 0 then 
            tipsLayer.create(errorTable[89])
            return
        end
		local edit_panel = uiUtil.getConvertChildByName(mainWidget,"edit_panel")
		local label_content = uiUtil.getConvertChildByName(edit_panel,"label_content")
		local str = ""
		if config.getPlatFormInfo() == kTargetWindows then
			str = textEditbox:getText()
		else
			str = label_content:getStringValue()
		end
        --TODO  是否可以输入空字符串 "   "
        if str == "" then 
            return
        end

	    UnionOfficialData.requestInviteUserByName(str)
    end
end

--0玩家id、1玩家名（势力）、2势力、3所属州、4距离、5是否邀请过或者是否被附属（-1被附属、0未邀请、1已邀请）、6邀请时间（没有则为0）
local function layoutItem(item_panel_main,indx)
    local detailInfo = list_data[indx]
    if not detailInfo then return end
    local item_panel = tolua.cast(item_panel_main:getChildByName("main_panel"),"Layout")

    local userID = detailInfo[1]
    local userName = detailInfo[2]
    local roleForcesValue = detailInfo[3]
    local distance = detailInfo[5]
    local invitedState = detailInfo[6]

    local btn_official = uiUtil.getConvertChildByName(item_panel,"btn_official")
    btn_official:setTouchEnabled(true)
    btn_official:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then
            UIRoleForcesMain.create(userID)
        end
    end)

    local label_name_official = uiUtil.getConvertChildByName(item_panel,"label_name_official")
    label_name_official:setText(userName)

    local label_roleForcesValue = uiUtil.getConvertChildByName(item_panel,"label_level")
    label_roleForcesValue:setText(roleForcesValue)

    local label_region = uiUtil.getConvertChildByName(item_panel,"label_region")
    
    local region_state = detailInfo[4]
    local region_info = Tb_cfg_region[region_state] 
    if region_state and region_info then 
        label_region:setText(region_info.name ) 
    end


    local img_flag_1 = uiUtil.getConvertChildByName(item_panel,"img_flag_1")
    img_flag_1:setVisible(false)
    local img_flag_2 = uiUtil.getConvertChildByName(item_panel,"img_flag_2")
    img_flag_2:setVisible(false)
    local img_flag_3 = uiUtil.getConvertChildByName(item_panel,"img_flag_3")
    img_flag_3:setVisible(false)

    if distance >=0 and distance <= 40 then
        img_flag_1:setVisible(true)
    elseif distance > 40 and  distance<= 80 then 
        img_flag_2:setVisible(true)
    elseif distance >80 and distance<= 150 then
        img_flag_3:setVisible(true)
    end

    local img_invited = uiUtil.getConvertChildByName(item_panel_main,"img_invited")
    img_invited:setVisible(false)

    local btn_invite = uiUtil.getConvertChildByName(item_panel,"btn_invite")
    btn_invite:setVisible(false)
    btn_invite:setTouchEnabled(false)

    local affi_ = uiUtil.getConvertChildByName(item_panel_main,"ImageView_311322")
    affi_:setVisible(false)

    if invitedState == 1 then 
        img_invited:setVisible(true)
        img_invited:loadTexture("alliance_invited.png", UI_TEX_TYPE_PLIST)
    elseif invitedState == 0 then
        btn_invite:setVisible(true)
        btn_invite:setTouchEnabled(true)
        btn_invite:addTouchEventListener(function (sender,eventType)
            if eventType == TOUCH_EVENT_ENDED then 
                if userData.getAffilated_union_id() ~= 0 then 
                    tipsLayer.create(errorTable[89])
                    return
                end
                sender:setTouchEnabled(false)
                UnionOfficialData.requestInviteUserByID(userID)
            end
        end)
    elseif invitedState == -1 then
        img_invited:setVisible(true)
        img_invited:loadTexture("new_Unable_to_invite.png", UI_TEX_TYPE_PLIST)
        affi_:setVisible(true)
        item_panel:setOpacity(255*0.5)
    else
        print("((( unknow what to do ")
    end
     
end

function UnionOfficialInvite.refreshCell(userID )
    if not list_data then return end
    local index = 0
    for i, v in ipairs(list_data) do
        if v[1] == userID then
            v[6] = 1
            index = i
            break
        end
    end

    if not list_tabel_view then return end
    if index == 0 then return end
    local cell = list_tabel_view:cellAtIndex(index-1)
    if not cell then return end
    local item_layer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
    if item_layer then
        local item_layout = tolua.cast(item_layer:getWidgetByTag(11),"Layout")
        if item_layout then
            layoutItem(item_layout,index)
        end
    end
end

function UnionOfficialInvite.create(mainPanel,pmainWidget,unionID)
    if mainWidget then return end
    list_data = {}
    union_id = unionID
    mainWidget = GUIReader:shareReader():widgetFromJsonFile("test/Alliance_invited.json")
   
    pmainWidget:addChild(mainWidget)
    
    local list_panel = uiUtil.getConvertChildByName(mainWidget,"list_panel")

    item_width = 1060
	item_height = 77

    
    



    -- local img_main_bg = uiUtil.getConvertChildByName(mainWidget,"img_main_bg")
    -- UIListViewSize.definedUIpanel(mainWidget,img_main_bg,list_panel,nil,{})


    local function cellSizeForTable()
		return item_height,item_width
	end
    
    local function numberOfCellsInTableView()
		return #list_data
	end
    
    local function tableCellAtIndex(table, idx)
    	local cell = table:dequeueCell()
    	if nil == cell then
        	cell = CCTableViewCell:new()
        	local mlayer = TouchGroup:create()
        	mlayer:setTag(1)
        	cell:addChild(mlayer)

			local _pCell = GUIReader:shareReader():widgetFromJsonFile("test/Alliance_invited_cell_1.json")
	        tolua.cast(_pCell,"Layout")
	        mlayer:addWidget(_pCell)
	        _pCell:setTag(11)
    	end


    	local item_layer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
    	if item_layer then
    		local item_layout = tolua.cast(item_layer:getWidgetByTag(11),"Layout")
			if item_layout then
				layoutItem(item_layout,idx + 1)
			end
    	end
    	return cell
	end

    local img_drag_flag_up = uiUtil.getConvertChildByName(list_panel,"img_drag_flag_up")
    local img_drag_flag_down = uiUtil.getConvertChildByName(list_panel,"img_drag_flag_down")
    img_drag_flag_up:setVisible(false)
    img_drag_flag_down:setVisible(false)

	breathAnimUtil.start_scroll_dir_anim(img_drag_flag_up, img_drag_flag_down)
    local function tableviewScroll(view)
        if not list_tabel_view then return end
        if list_tabel_view:getContentOffset().y < 0 then 
            img_drag_flag_down:setVisible(true)
        else
            img_drag_flag_down:setVisible(false)
        end

        if list_tabel_view:getContentOffset().y > -(numberOfCellsInTableView() * 77 - list_panel:getSize().height) then 
            img_drag_flag_up:setVisible(true)
            img_drag_flag_up:setPositionY(list_panel:getSize().height - 8)
        else
            img_drag_flag_up:setVisible(false)
        end
        
    end

    
    list_tabel_view = CCTableView:create(true,CCSizeMake(list_panel:getSize().width,list_panel:getSize().height))
 	list_panel:addChild(list_tabel_view)
 	list_tabel_view:setDirection(kCCScrollViewDirectionVertical)
 	list_tabel_view:setVerticalFillOrder(kCCTableViewFillTopDown)
	list_tabel_view:ignoreAnchorPointForPosition(false)
	list_tabel_view:setAnchorPoint(cc.p(0.5,0.5))
	list_tabel_view:setPosition(cc.p(list_panel:getSize().width/2,list_panel:getSize().height/2))
	-- list_tabel_view:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
    list_tabel_view:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
    list_tabel_view:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
    list_tabel_view:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
    list_tabel_view:registerScriptHandler(tableviewScroll,CCTableView.kTableViewScroll)
    list_tabel_view:reloadData()



    local edit_panel = uiUtil.getConvertChildByName(mainWidget,"edit_panel")
	local label_content = uiUtil.getConvertChildByName(edit_panel,"label_content")
	local size_width = edit_panel:getSize().width
	local size_height = edit_panel:getSize().height
	--输入正文
	local rect = CCRectMake(5,35, 70 , 38)
    local sprite = CCScale9Sprite:createWithSpriteFrameName("frame_small.png",rect)
    sprite:setOpacity(0)
    textEditbox = CCEditBox:create(CCSize(size_width*config.getgScale(),size_height*config.getgScale()),sprite )
    textEditbox:setFontName(config.getFontName())	
    textEditbox:setFontSize(22*config.getgScale())
    textEditbox:setFontColor(ccc3(130,130,130))
    -- textEditbox:setPlaceHolder(languagePack["role_forces_edit_intro"])
    textEditbox:setPlaceholderFontSize(22*config.getgScale())
    textEditbox:setPlaceholderFontColor(ccc3(255,255,255))
    textEditbox:setMaxLength(100)
    textEditbox:setScale(1/config.getgScale())
    -- textEditbox:setText(label_content:getStringValue())
    label_content:setColor(ccc3(130,130,130))
    label_content:setText(languagePack["union_invite_edit_default"])
    textEditbox:registerScriptEditBoxHandler(function (strEventName,pSender)
		if strEventName == "began" then
            if languagePack["union_invite_edit_default"] ~= label_content:getStringValue() then
                textEditbox:setText(label_content:getStringValue())
            end
			label_content:setVisible(false)
		elseif strEventName == "ended" then
			-- ignore
		elseif strEventName == "return" then
            if StringUtil.isEmptyStr(textEditbox:getText()) then 
                label_content:setText(languagePack["union_invite_edit_default"])
                label_content:setVisible(true)
            else
                label_content:setText(textEditbox:getText())
                textEditbox:setText(" ")
                label_content:setVisible(true)
			end
		elseif strEventName == "changed" then
			-- ignore
		end
	end)
    edit_panel:addChild(textEditbox)
    textEditbox:setPosition(cc.p(0, size_height))
    textEditbox:setAnchorPoint(cc.p(0,1))

    local confirm_btn = uiUtil.getConvertChildByName(mainWidget,"confirm_btn")
    confirm_btn:setTouchEnabled(true)
    confirm_btn:addTouchEventListener(dealWithClickInviteDirectly)


    UnionOfficialInvite.requestDataFromServer()
end


function UnionOfficialInvite.updateData(package)
    if not list_tabel_view then return end
    list_data = package
    list_tabel_view:reloadData()

end
function UnionOfficialInvite.requestDataFromServer()
    if not list_tabel_view then return end
    UnionOfficialData.requestNearbyUserList()
end

return UnionOfficialInvite
