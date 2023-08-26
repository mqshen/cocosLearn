local UnionOfficialAppoint = {}

local uiUtil = require("game/utils/ui_util")
local union_id = nil

local list_data = nil
local list_tabel_view = nil
local item_height = nil
local item_width = nil
local demisingCountDownHandler = nil -- 禅让倒计时

local mainWidget = nil
function UnionOfficialAppoint.remove()
    require("game/union/unionOfficialAppointList")
    UnionOfficialAppointList.remove_self()
    if mainWidget then 
        mainWidget:removeFromParentAndCleanup(true)
        mainWidget = nil
    end
    union_id = nil
    list_data = nil
    list_tabel_view = nil
    item_width = nil
    item_height = nil

    if demisingCountDownHandler then 
        scheduler.remove(demisingCountDownHandler)
        demisingCountDownHandler = nil
    end
end

--[[
0官位id
1官位序列
2用户id（没有时为0）
3成员名（未任命时为空串、未开放时为开放等级）
4禅让所剩时间（没有时为0）
]]
local function layoutItemPanel(item_panel,data)
    if not data then return end
    local unionPositionType = data[1]
    local unionPosition = data[2]
    local userId = data[3]
    local userName = data[4]
    local demisingCountDown = data[5]

    

    -- 任命
    local btn_commission = uiUtil.getConvertChildByName(item_panel,"btn_commission")
    btn_commission:setTouchEnabled(false)
    btn_commission:setVisible(false)
    btn_commission:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            if userData.getAffilated_union_id() ~= 0 then 
                tipsLayer.create(errorTable[89])
                return
            end
            require("game/union/unionOfficialAppointList")
            UnionOfficialAppointList.create(2,unionPositionType,unionPosition)
        end
    end)

    --罢免
    local btn_dismiss = uiUtil.getConvertChildByName(item_panel,"btn_dismiss")
    btn_dismiss:setTouchEnabled(false)
    btn_dismiss:setVisible(false)
    btn_dismiss:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            if userData.getAffilated_union_id() ~= 0 then 
                tipsLayer.create(errorTable[89])
                return
            end
            local function callback()
                sender:setTouchEnabled(false)
                UnionOfficialData.requestUnionLeaderDesposetOfficial(userId)
            end
            alertLayer.create(errorTable[86],{userName,positionType[unionPositionType]},callback)
            
        end
    end)


    -- 卸任
    local btn_resign = uiUtil.getConvertChildByName(item_panel,"btn_resign")
    btn_resign:setTouchEnabled(false)
    btn_resign:setVisible(false)
    btn_resign:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            if userData.getAffilated_union_id() ~= 0 then 
                tipsLayer.create(errorTable[89])
                return
            end
            UnionOfficialData.requestUnionDeputyLeaderResign()
        end
    end)
    --禅让
    local btn_demise = uiUtil.getConvertChildByName(item_panel,"btn_demise")
    btn_demise:setTouchEnabled(false)
    btn_demise:setVisible(false)
    btn_demise:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            if userData.getAffilated_union_id() ~= 0 then 
                tipsLayer.create(errorTable[89])
                return
            end
            require("game/union/unionOfficialAppointList")
            UnionOfficialAppointList.create(1,unionPositionType,unionPosition)
        end
    end)

    --取消禅让
    local btn_cancel_demise = uiUtil.getConvertChildByName(item_panel,"btn_cancel_demise")
    btn_cancel_demise:setTouchEnabled(false)
    btn_cancel_demise:setVisible(false)
    btn_cancel_demise:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            if userData.getAffilated_union_id() ~= 0 then 
                tipsLayer.create(errorTable[89])
                return
            end
            sender:setTouchEnabled(false)
            UnionOfficialData.requestUnionLeaderCancelDemise()
        end
    end)

    
    --禅让倒计时
    local label_demise = uiUtil.getConvertChildByName(item_panel,"label_demise")
    label_demise:setVisible(false)
    local label_demise_count_down = uiUtil.getConvertChildByName(item_panel,"label_demise_count_down")
    label_demise_count_down:setVisible(false) 


    -- 官位信息
    local label_name_official = uiUtil.getConvertChildByName(item_panel,"label_name_official")
    if positionType[unionPositionType] then
        label_name_official:setText(positionType[unionPositionType])
    end
    local btn_official = uiUtil.getConvertChildByName(item_panel,"btn_official")
    btn_official:setTouchEnabled(true)
    btn_official:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then
            if officiaDescription[unionPositionType] then
                alertLayer.create(officiaDescription[unionPositionType],nil,nil)
            end
        end
    end)
    -- local btn_official_flag = uiUtil.getConvertChildByName(item_panel,"btn_official_flag")
    -- btn_official_flag:setTouchEnabled(true)
    -- btn_official_flag:addTouchEventListener(function(sender,eventType)
    --     if eventType == TOUCH_EVENT_ENDED then
    --         if officiaDescription[unionPositionType] then
    --             alertLayer.create(officiaDescription[unionPositionType],nil,nil)
    --         end
    --     end
    -- end)

    -- 官位成员
    local label_user_name = uiUtil.getConvertChildByName(item_panel,"label_user_name")
    label_user_name:setVisible(false)
    --label_user_name:setColor(ccc3(245,245,245))
    local label_user_name_null = uiUtil.getConvertChildByName(item_panel,"label_user_name_null")
    label_user_name_null:setVisible(false)
    --label_user_name_null:setColor(ccc3(171,187,203))
    if userId == 0 then
        label_user_name_null:setVisible(true)
        label_user_name_null:setText(languagePack["union_position_null"])
    else
        label_user_name:setVisible(true)
        label_user_name:setText(userName)
    end

    -- 是否是盟主
    local isLeader = (unionPositionType == 1)
    -- 是否是副盟主
    local isDeputyLeader = (unionPositionType == 2)

    local isOwn = (userData.getUserId() == userId)
    -- 是否处于禅让流程
    local isDemising = (demisingCountDown > 0)
    -- 是否已经任命
    local isCommissioned = (userId ~= 0)
    if isLeader then
        -- 盟主禅让
        if isOwn then
            if not isDemising then 
                btn_demise:setVisible(true)
                btn_demise:setTouchEnabled(true)
            else
                btn_cancel_demise:setVisible(true)
                btn_cancel_demise:setTouchEnabled(true)
                label_demise:setVisible(true)
                label_demise_count_down:setVisible(true)
                label_demise_count_down:setText(commonFunc.format_day(demisingCountDown))
                if demisingCountDownHandler then 
                    scheduler.remove(demisingCountDownHandler)
                    demisingCountDownHandler = nil
                end
                local function countDown()
                    demisingCountDown = demisingCountDown - 1
                    label_demise_count_down:setText(commonFunc.format_day(demisingCountDown))
                end
                demisingCountDownHandler = scheduler.create(countDown, 1)
            end
        end
    elseif isDeputyLeader and isOwn then 
        -- 副盟主卸任
		-- 只有副盟主才能 卸任
        if isCommissioned and isDeputyLeader then 
            btn_resign:setVisible(true)
            btn_resign:setTouchEnabled(true)
        end	
    else
        if isCommissioned then
            btn_dismiss:setVisible(true)
            btn_dismiss:setTouchEnabled(true)
        else
            btn_commission:setVisible(true)
            btn_commission:setTouchEnabled(true)
        end
    end
end
function UnionOfficialAppoint.create(mainPanel,pmainWidget,unionID)
    if mainWidget then return end
    list_data = {}
    union_id = unionID
    local widget = GUIReader:shareReader():widgetFromJsonFile("test/Appointment_of_officials.json")
    mainWidget = widget
    pmainWidget:addChild(mainWidget)
    
    local list_panel = uiUtil.getConvertChildByName(widget,"list_panel")

    
    item_width = 1060
	item_height = 77
    
   
    local btn_tips = uiUtil.getConvertChildByName(mainWidget,"btn_tips")
    btn_tips:setTouchEnabled(false)
    btn_tips:setVisible(false)
    btn_tips:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            
        end
    end)

    -- local img_main_bg = uiUtil.getConvertChildByName(widget,"img_main_bg")
    -- UIListViewSize.definedUIpanel(widget,img_main_bg,list_panel,nil,{})


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
            
            local _pCell = GUIReader:shareReader():widgetFromJsonFile("test/Appointment_of_officials_cell.json")
	        tolua.cast(_pCell,"Layout")
	        mlayer:addWidget(_pCell)
	        _pCell:setTag(11)
          
            
    	end


    	local item_layer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
    	if item_layer then
    		local item_panel = tolua.cast(item_layer:getWidgetByTag(11),"Layout")
			if item_panel then
                layoutItemPanel(item_panel,list_data[idx + 1])
			end
    	end

    	return cell
	end

    local img_drag_flag_up = uiUtil.getConvertChildByName(list_panel,"img_drag_flag_up")
    local img_drag_flag_down = uiUtil.getConvertChildByName(list_panel,"img_drag_flag_down")
    img_drag_flag_up:setVisible(false)
    img_drag_flag_down:setVisible(false)
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
 	list_panel:addChild(list_tabel_view,4,4)
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


    UnionOfficialAppoint.requestDataFromServer()
    
end

function UnionOfficialAppoint.updateData(package)
    if not list_tabel_view then return end
    list_data = package
    list_tabel_view:reloadData()
end

function UnionOfficialAppoint.requestDataFromServer()
    if not list_tabel_view then return end
    UnionOfficialData.requestUnionOfficialList()
end

return UnionOfficialAppoint
