
module("comOPMenu",package.seeall)

local main_layer = nil

local uiUtil = require("game/utils/ui_util")

local op_tv = nil
function remove_self()
    if op_tv then 
        op_tv:removeFromParentAndCleanup(true)
        op_tv = nil
    end

    if main_layer then
        main_layer:removeFromParentAndCleanup(true)
        main_layer = nil
        uiManager.remove_self_panel(uiIndexDefine.COM_OP_MENU)
    end
end

function dealwithTouchEvent(x,y)
    if not main_layer then return false end

    local widget = main_layer:getWidgetByTag(999)
    if not widget then return false end
    if widget:hitTest(cc.p(x,y)) then 
        return false
    else
        remove_self()
        return true
    end
end


-- { {label = "个人",callback = ""},{label = "个人",callback = ""},{label = "个人",callback = ""}}
function create(optionList)
    if main_layer then return end
    local widget = GUIReader:shareReader():widgetFromJsonFile("test/ui_op_menu.json")
    widget:setTag(999)
    widget:setScale(config.getgScale())
    widget:ignoreAnchorPointForPosition(false)
    widget:setAnchorPoint(cc.p(0.5, 0.5))
    widget:setPosition(cc.p(config.getWinSize().width/2 , config.getWinSize().height/2))

    main_layer = TouchGroup:create()
    main_layer:addWidget(widget)
    uiManager.add_panel_to_layer(main_layer, uiIndexDefine.COM_OP_MENU)


    local close_btn = uiUtil.getConvertChildByName(widget,"close_btn")
    close_btn:setTouchEnabled(true)
    close_btn:addTouchEventListener(function (sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then
            remove_self()
        end
    end)


    local function tableCellTouched(table,cell)
        local idx = cell:getIdx() + 1
        if not optionList[idx] then return end
        local callback = optionList[idx].callback
        remove_self()
        if callback and type(callback) == "function" then 
            callback()
        end
    end

    local function cellSizeForTable(table,cell)
        return 54,248
    end


    local function tableCellAtIndex(table,idx)
        local listPanel = uiUtil.getConvertChildByName(widget,"list_panel")
        local tempItemPanel = uiUtil.getConvertChildByName(listPanel,"item_panel")
        tempItemPanel:setVisible(false)
        tempItemPanel:setTouchEnabled(false)
        


        local cell = table:dequeueCell()
        if nil == cell then
            cell = CCTableViewCell:new()
            local mlayer = TouchGroup:create()
            local widget = tempItemPanel:clone()
            widget:setVisible(true)
            widget:setTouchEnabled(true)
            widget:setPosition(cc.p(0,0))
            mlayer:addWidget(widget)
            widget:setTag(1)
            cell:addChild(mlayer)
            mlayer:setTag(123)

        end

        local layer = tolua.cast(cell:getChildByTag(123),"TouchGroup")
        if layer then
            if layer:getWidgetByTag(1) then            
                -- setCell(idx)
                local widget = tolua.cast(layer:getWidgetByTag(1),"Layout")
                local label = uiUtil.getConvertChildByName(widget,"label")
                if optionList[idx + 1] and optionList[idx+1].label then 
                    label:setText(optionList[idx+1].label)
                end
            end
        end
        return cell
    end

    local function numberOfCellsInTableView(table,cell)
        return #optionList
    end

    local listPanel = uiUtil.getConvertChildByName(widget,"list_panel")
    op_tv = CCTableView:create(CCSizeMake(listPanel:getContentSize().width,listPanel:getContentSize().height))
    listPanel:addChild(op_tv)
    op_tv:setDirection(kCCScrollViewDirectionVertical)
    op_tv:setVerticalFillOrder(kCCTableViewFillTopDown)
    op_tv:ignoreAnchorPointForPosition(false)
    op_tv:setAnchorPoint(cc.p(0.5,0.5))
    op_tv:setPosition(cc.p(listPanel:getContentSize().width/2,listPanel:getContentSize().height/2))
   
    op_tv:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
    op_tv:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
    op_tv:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
    op_tv:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
    op_tv:reloadData()

    -- if #optionList < 4 then 
    --     op_tv:setTouchEnabled(false)
    -- end
end

