module("UIDailyBulletin",package.seeall)

-- 每日公告
local uiUtil = require("game/utils/ui_util")
local ColorUtil = require("game/utils/color_util")
local mainLayer = nil

local b_DailyFirstLogin = nil
local mf_callback = nil

local cache_bulletin_item = nil

local rich_text_split_h = 5
local function setEnable( flag )
    if mainLayer then
        local temp = mainLayer:getChildren()
        for i=0 , mainLayer:getChildrenCount()-1 do
            tolua.cast(temp:objectAtIndex(i),"Widget"):setEnabled(flag)
        end
    end
end


local function createBulletinItem(title,cfgContent)
    if not cache_bulletin_item then 
        cache_bulletin_item = {}
    end
    local panel_item = GUIReader:shareReader():widgetFromJsonFile("test/The_main_interface_of_announcement_cell.json")
    local panel_title = uiUtil.getConvertChildByName(panel_item,"panel_title")
    local panel_line = uiUtil.getConvertChildByName(panel_item,"panel_line")
    local panel_rich = uiUtil.getConvertChildByName(panel_item,"panel_rich")
    local label_title = uiUtil.getConvertChildByName(panel_title,"label_title")
    label_title:setText(title)

    panel_item:ignoreAnchorPointForPosition(false)
    panel_item:setAnchorPoint(cc.p(0,1))
    local richTextContent = RichText:create()
    richTextContent:ignoreContentAdaptWithSize(false)
    richTextContent:setVerticalSpace(rich_text_split_h)
    richTextContent:setSize(CCSizeMake(panel_rich:getContentSize().width, 0 ))
    richTextContent:setAnchorPoint(cc.p(0.5,1))
    panel_rich:addChild(richTextContent)
    richTextContent:setPosition(cc.p(panel_rich:getContentSize().width/2 ,panel_rich:getContentSize().height))

    local re = nil
    local contentText = nil
    local subCfgContent = nil
    -- while cfgContent:match("{.-}")  do
    --     subCfgContent = cfgContent:match("{.-}") 
    --     subCfgContent = string.gsub(subCfgContent,"{","")
    --     subCfgContent = string.gsub(subCfgContent,"}","")
    --     cfgContent = string.gsub(cfgContent,"{" .. subCfgContent .. "}","#@" .. subCfgContent .. "@#")
    -- end 

    -- cfgContent = "#" .. cfgContent .. "#"

    local parseData = config.richText_split(cfgContent)
    for kk,vv in ipairs(parseData) do 
        contentText = vv[2]
        if vv[1] == 1 then 
            re = RichElementText:create(1,ColorUtil.CCC_TEXT_MAIN_CONTENT , 255, contentText,config.getFontName(), 22)
        else
            re = RichElementText:create(1,ColorUtil.CCC_TEXT_SUB_TITLE , 255, contentText,config.getFontName(), 22)
        end 
        richTextContent:pushBackElement(re)
    end

    panel_line:removeFromParentAndCleanup(false)
    re = RichElementCustomNode:create(1, ccc3(255,255,255), 255, panel_line)
    richTextContent:pushBackElement(re)

    richTextContent:setName("richText")

    richTextContent:formatText()
    return panel_item,real_h
end

local function loadData(data)
    if not data then return end
    if not mainLayer then return end
    local mainWidget = mainLayer:getWidgetByTag(999)
    if not mainWidget then return end
    local labelTitle = uiUtil.getConvertChildByName(mainWidget,"labelTitle")

    local serverId = loginData.getLastCacheServerId()
    local serverInfo = loginData.getServerInfoById(serverId)
    local labelTitle = uiUtil.getConvertChildByName(mainWidget,"labelTitle")
    -- if serverId and serverInfo then 
    --     labelTitle:setText(serverId .. languagePack["server_title"] ..
    --         "  " .. serverInfo.name .. " " .. languagePack["announcement"])
    -- else
    --     labelTitle:setText(languagePack["announcement"])
    -- end
    labelTitle:setText(languagePack["announcement"])

    local scrollPanel = uiUtil.getConvertChildByName(mainWidget,"scrollPanel")
    local mainPanel = uiUtil.getConvertChildByName(scrollPanel,"mainPanel")
    

    if not cache_bulletin_item then 
        cache_bulletin_item = {}
    end

    local bulletin_item  = nil
    for k,itemData in pairs(data) do 

        bulletin_item = createBulletinItem(itemData[1],itemData[2])

        mainPanel:addChild(bulletin_item)
        
        table.insert(cache_bulletin_item,bulletin_item)
    end


    local ori_w = scrollPanel:getContentSize().width
    local ori_h = scrollPanel:getContentSize().height


    local real_h = 0
    local panel_rich = nil
    local rich_text = nil
    local ori_pos_y = nil

    local total_h = 10
    ori_pos_y = mainPanel:getContentSize().height - total_h
    
    for k,panel_item in pairs(cache_bulletin_item) do 
        panel_rich = uiUtil.getConvertChildByName(panel_item,"panel_rich")
        rich_text = uiUtil.getConvertChildByName(panel_rich,"richText")
        real_h = panel_item:getContentSize().height - panel_rich:getContentSize().height + rich_text:getRealHeight()
        panel_item:setPositionY(ori_pos_y)
        ori_pos_y = ori_pos_y - real_h - rich_text_split_h
        total_h = total_h + real_h + rich_text_split_h
    end
    total_h = total_h - rich_text_split_h
    if total_h > ori_h then 
        scrollPanel:setInnerContainerSize(CCSizeMake(ori_w,total_h))
        mainPanel:setPositionY(total_h - ori_h)
    end


    
end


local function addObserver()
    netObserver.addObserver(NOTICE_LIST, receiveDataFromServer)
end

local function removeObserver()
    netObserver.removeObserver(NOTICE_LIST)
end


-- 服务端返回数据
function receiveDataFromServer(data)

    -- 优先级由大到小排序
    local function sort_ruler(va,vb)
        if va[4] > vb[4] then 
            return true
        else
            return false 
        end
    end

    table.sort(data,sort_ruler)


    removeObserver()

    local itemCount = 0
    for k,v in pairs(data) do 
        itemCount = itemCount + 1
    end
    if itemCount == 0 then 

        if mf_callback and type(mf_callback) == "function" then 
            mf_callback()
            mf_callback = nil
        end
        
        --TODOTK 中文收集
        if not b_DailyFirstLogin then 
            tipsLayer.create(languagePack['noAnnouncement'])
        end
        return 
    end

    create(data)

end

-- 请求数据

local function requestData()
    Net.send(NOTICE_LIST, {})
end




function remove_self()
    cache_bulletin_item = nil
    if mainLayer then 
        mainLayer:removeFromParentAndCleanup(true)
        mainLayer = nil
        uiManager.remove_self_panel(uiIndexDefine.UI_DAILY_BULLETIN)
        removeObserver()

        if mf_callback and type(mf_callback) == "function" then 
            mf_callback()
            mf_callback = nil
        end

        b_DailyFirstLogin = nil
    end
end

function dealwithTouchEvent(x,y)
    if not mainLayer then return false end
    local mainWidget = mainLayer:getWidgetByTag(999)
    if not mainWidget then return false end
    if mainWidget:hitTest(cc.p(x,y)) then 
        return false 
    else
        remove_self()
        return true
    end
end




function create(dataFromServer)
    if mainLayer then return end
    local mainWidget = GUIReader:shareReader():widgetFromJsonFile("test/The_main_interface_of_announcement.json")
    mainWidget:setTag(999)
    mainWidget:setScale(config.getgScale())
    mainWidget:ignoreAnchorPointForPosition(false)
    mainWidget:setAnchorPoint(cc.p(0.5, 0.5))
    mainWidget:setPosition(cc.p(config.getWinSize().width/2 , config.getWinSize().height/2))
    mainLayer = TouchGroup:create()
    mainLayer:addWidget(mainWidget)
    uiManager.add_panel_to_layer(mainLayer, uiIndexDefine.UI_DAILY_BULLETIN)

    -- 按钮事件
    local btnClose = uiUtil.getConvertChildByName(mainWidget,"btnClose")
    btnClose:setTouchEnabled(true)
    btnClose:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then
            remove_self()
        end
    end)


    local scrollPanel = uiUtil.getConvertChildByName(mainWidget,"scrollPanel")
    local mainPanel = uiUtil.getConvertChildByName(scrollPanel,"mainPanel")

    local img_drag_flag_down = uiUtil.getConvertChildByName(mainWidget,"img_drag_flag_down")
    local img_drag_flag_up = uiUtil.getConvertChildByName(mainWidget,"img_drag_flag_up")
    img_drag_flag_up:setVisible(false)
    img_drag_flag_down:setVisible(false)
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


  

    loadData(dataFromServer)
    uiManager.showScaleEffect(mainLayer,999,nil,0.3,0.6)



   
end




function show(dailyFirstLogin,callback)
    mf_callback = callback
    addObserver()
    requestData()
    b_DailyFirstLogin = dailyFirstLogin
end