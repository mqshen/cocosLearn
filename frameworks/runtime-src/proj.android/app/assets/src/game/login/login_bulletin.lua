local loginBulletin = {}

local main_layer = nil

-- require("game/encapsulation/commonFunc")
-- local uiUtil = require("game/utils/ui_util")
local loginEnterGame = require("game/login/login_enter_game")

local richTextContent = nil

local list_tabel_view = nil

local bulletin_list = nil
local selected_bulletin_indx = nil

local scroll_panel_ori_w = nil
local scroll_panel_ori_h = nil

local m_tCacheRichTextElem = nil
local ColorUtil = require("game/utils/color_util")

local function getConvertChildByName(parent,childName)
    assert(childName, "why get a nil child")
    local child = parent:getChildByName(childName)
    if child then 
       tolua.cast(child, child:getDescription())
    else
        -- print("node named["..childName.."]not found")
        -- print(debug.traceback())
    end
    return child
end


function loginBulletin.remove()
    if richTextContent then 
        richTextContent:removeFromParentAndCleanup(true)
        richTextContent = nil
    end

    if list_tabel_view then 
        list_tabel_view:removeFromParentAndCleanup(true)
        list_tabel_view = nil
    end
	if main_layer then 
		main_layer:removeFromParentAndCleanup(true)
		main_layer = nil
	end
	loginEnterGame.changeAbleBtnEnterGame(true)
    -- local loginBulletinList = require("game/login/login_bulletin_list")
    -- loginBulletinList.create()

    bulletin_list = nil
    scroll_panel_ori_w = nil
    scroll_panel_ori_h = nil
    selected_bulletin_indx = nil
    m_tCacheRichTextElem = nil
end


local function parseConfigData(data)
    return data
    -- local subCfgContent = nil
    -- while data:match("{.-}")  do
    --     subCfgContent = data:match("{.-}") 
    --     subCfgContent = string.gsub(subCfgContent,"{","")
    --     subCfgContent = string.gsub(subCfgContent,"}","")
    --     data = string.gsub(data,"{" .. subCfgContent .. "}","#@" .. subCfgContent .. "@#")
    -- end 

    -- return "#" .. data .. "#"

    -- local listData = configBeforeLoad.split_to_table(data.content,"||")
    -- local retData = {}
    -- local itemData = nil
    -- local tempData = nil
    -- local content,cell = nil,nil
    -- for k,v in ipairs(listData) do 
    --     print(">>>>>>>>>>>>>>>>",v)
    --     tempData = loadstring("return " .. "{" ..  v .. "}")()
    --     itemData = {}
    --     itemData[1] = tempData[1]
        

    --     content,cell = configBeforeLoad.richText_split(tempData[2])
    --     itemData[2] = content
    --     table.insert(retData,itemData)
    -- end
    -- return retData
end



local function dealWithClickClose(sender,eventType)
	if eventType == TOUCH_EVENT_ENDED then 
		loginBulletin.remove()
        loginGUI.setUIVisible(true)
	end
end


local function updateDetail(indx)
    local bulletinData = bulletin_list[indx]
    if not bulletinData then return end
    local temp_widget = main_layer:getWidgetByTag(999)

    local desc_arrow_up = getConvertChildByName(temp_widget,"desc_arrow_up")
    local desc_arrow_down = getConvertChildByName(temp_widget,"desc_arrow_down")
    desc_arrow_up:setVisible(false)
    desc_arrow_down:setVisible(false)

    if not temp_widget then return end
    -- 设置公告详细信息
    local scroll_panel = getConvertChildByName(temp_widget,"scroll_panel")
    
    local main_panel = getConvertChildByName(scroll_panel,"main_panel")
    if m_tCacheRichTextElem then 
        for i,v in ipairs(m_tCacheRichTextElem) do
            richTextContent:removeElement(v)
        end
    end
    m_tCacheRichTextElem = {}

    

    local node = GUIReader:shareReader():widgetFromJsonFile("test/login_bulletin_cell.json")
    re = RichElementCustomNode:create(1, ccc3(255,255,255), 255, node)
    richTextContent:pushBackElement(re)
    table.insert(m_tCacheRichTextElem,re)
    local label_title = tolua.cast(node:getChildByName("label_title"),"Label")--uiUtil.getConvertChildByName(node,"label_title")
    label_title:setText(bulletinData.sub_title)

    re = RichElementText:create(1,ColorUtil.CCC_TEXT_MAIN_CONTENT , 255, "\n",config.getFontName(), 22)
    richTextContent:pushBackElement(re)
    table.insert(m_tCacheRichTextElem,re)

    local cfgData = parseConfigData(bulletinData.content)
    local parseData = config.richText_split(cfgData)
    for kk,vv in ipairs(parseData) do 
        content_txt = vv[2]
        if vv[1] == 1 then 
            re = RichElementText:create(1,ColorUtil.CCC_TEXT_MAIN_CONTENT , 255, content_txt,config.getFontName(), 22)
        else
            re = RichElementText:create(1,ColorUtil.CCC_TEXT_SUB_TITLE , 255, content_txt,config.getFontName(), 22)
        end 
        richTextContent:pushBackElement(re)
        table.insert(m_tCacheRichTextElem,re)
    end

    -- local re = nil
    -- local content_txt = nil
    -- for k,itemData in ipairs(cfgData) do 
        
    --     for kk,vv in ipairs(itemData[2]) do 
    --         content_txt = vv[2]
    --         if kk == 1 then 
    --             content_txt = "    " .. content_txt 
    --         end
    --         if vv[1] == 1 then 
    --             re = RichElementText:create(1, ColorUtil.CCC_TEXT_MAIN_CONTENT, 255, content_txt,configBeforeLoad.getFontName(), 22)
    --         else
    --             re = RichElementText:create(1, ColorUtil.CCC_TEXT_SUB_TITLE, 255, content_txt,configBeforeLoad.getFontName(), 22)
    --         end 
    --         richTextContent:pushBackElement(re)
    --         table.insert(m_tCacheRichTextElem,re)
    --     end
    -- end

    richTextContent:formatText()

    local ori_w = scroll_panel_ori_w  
    local ori_h = scroll_panel_ori_h 


    local realHeight = richTextContent:getRealHeight()
    if realHeight > ori_h then 
        scroll_panel:setInnerContainerSize(CCSizeMake(ori_w,realHeight))
        main_panel:setPositionY(realHeight - ori_h)
        scroll_panel:setTouchEnabled(true)
        desc_arrow_down:setVisible(true)
    else
        scroll_panel:setInnerContainerSize(CCSizeMake(ori_w,ori_h))
        main_panel:setPositionY(0)
        scroll_panel:setTouchEnabled(false)
    end
end

local function doSetSelectedBulltin(indx,isSelected)
    local cell = list_tabel_view:cellAtIndex(indx - 1)
    if not cell then return end
    local item_layer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
    if not item_layer then return end
    local item_layout = tolua.cast(item_layer:getWidgetByTag(11),"Layout")
    if not item_layout then return end
    local item = item_layout:getChildByTag(111)
    if not item then return end
    local bulletinData = bulletin_list[indx]
    if not bulletinData then return end
    local img_unread = getConvertChildByName(item,"img_unread")
    if isSelected then 
        bulletinData.isRead = true
    end
    -- img_unread:setVisible(false)
    img_unread:setVisible(not bulletinData.isRead)
    local btn_main = getConvertChildByName(item,"btn_main")
    btn_main:setBright(not isSelected)


    ----------------------------------------- 如果不是选中 不需要更新信息
    if isSelected then 
        updateDetail(indx)
    end
end

local function setSelectedBulletin(indx)
    if selected_bulletin_indx == indx then return end
    selected_bulletin_indx = indx

    for i = 1, #bulletin_list do 
        doSetSelectedBulltin(i,i == indx)
    end
end

function loginBulletin.create()
	if main_layer then return end
	
    loginGUI.setUIVisible(false)
	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/gongggao.json")
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
 	
    btn_close = getConvertChildByName(temp_widget,"btn_close")
    btn_close:setTouchEnabled(true)
    btn_close:addTouchEventListener(dealWithClickClose)


 	local panel_list = getConvertChildByName(temp_widget,"panel_list")
    local panel_item = getConvertChildByName(panel_list,"panel_item")
    panel_list:setBackGroundColorType(LAYOUT_COLOR_NONE)
    panel_item:setBackGroundColorType(LAYOUT_COLOR_NONE)
    panel_item:setVisible(false)

    local list_arrow_down = getConvertChildByName(temp_widget,"list_arrow_down")
    local list_arrow_up = getConvertChildByName(temp_widget,"list_arrow_up")
    list_arrow_up:setVisible(false)
    list_arrow_down:setVisible(false)


    bulletin_list = loginData.getBulletinList()
    for i =1 ,#bulletin_list do 
        bulletin_list[i].isRead = false
    end

    -- 滑动到顶部或底部的时候的回调
    local function scrollViewDidScroll(view)
        if view:getContentOffset().y < 0 then
            list_arrow_down:setVisible(true)
        else
            list_arrow_down:setVisible(false)
        end

        if view:getContentSize().height + view:getContentOffset().y > view:getViewSize().height then
            list_arrow_up:setVisible(true)
        else
            list_arrow_up:setVisible(false)
        end
    end

    local function cellSizeForTable()
        return panel_item:getContentSize().height,panel_item:getContentSize().width
    end

    local function numberOfCellsInTableView(table)
        return #bulletin_list
    end


    local function clonePanelItem(indx)
        local item = panel_item:clone()
        -- item:setBackGroundColorType(LAYOUT_COLOR_NONE)
        item:setVisible(true)
        return item
    end



    local function tableCellTouched(table,cell_t)
        setSelectedBulletin(cell_t:getIdx()+1)
    end


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
            local item = nil
            item = clonePanelItem(indx)
            item:setTag(111)
            layout:addChild(item)
            item:ignoreAnchorPointForPosition(false)
            item:setAnchorPoint(cc.p(0,0.5))
            item:setPosition(cc.p( (panel_list:getContentSize().width -  panel_item:getContentSize().width)/2,panel_item:getContentSize().height/2))

        end
        
        local item_layer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
        if item_layer then
            local item_layout = tolua.cast(item_layer:getWidgetByTag(11),"Layout")
            if item_layout then
                local item = item_layout:getChildByTag(111)
                local bulletinData = bulletin_list[indx]
                if bulletinData then 
                    local label_title = getConvertChildByName(item,"label_title")
                    label_title:setText("【" .. languagePack["announcement"] .. "】" .. bulletinData.title)
                    local img_unread = getConvertChildByName(item,"img_unread")
                    img_unread:setVisible(not bulletinData.isRead)
                    -- img_unread:setVisible(false)
                    local btn_main = getConvertChildByName(item,"btn_main")
                    btn_main:setBright(not (selected_bulletin_indx == indx)) 
                end
            end
        end
        return cell
    end

    list_tabel_view = CCTableView:create(CCSizeMake(panel_list:getContentSize().width,panel_list:getContentSize().height))
    panel_list:addChild(list_tabel_view)
    list_tabel_view:setDirection(kCCScrollViewDirectionVertical)
    list_tabel_view:setVerticalFillOrder(kCCTableViewFillTopDown)
    list_tabel_view:ignoreAnchorPointForPosition(false)
    list_tabel_view:setAnchorPoint(cc.p(0.5,0.5))
    list_tabel_view:setPosition(cc.p(panel_list:getContentSize().width/2,panel_list:getContentSize().height/2))
    list_tabel_view:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
    --list_tabel_view:registerScriptHandler(tableCellHightlight,CCTableView.kTableCellHighLight)
    --list_tabel_view:registerScriptHandler(tableCellUnhightlight,CCTableView.kTableCellUnhighLight)

    list_tabel_view:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)

    list_tabel_view:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
    list_tabel_view:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)

    list_tabel_view:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
    list_tabel_view:reloadData()



     


    local scroll_panel = getConvertChildByName(temp_widget,"scroll_panel")
    scroll_panel:setBackGroundColorType(LAYOUT_COLOR_NONE)
    scroll_panel_ori_w = scroll_panel:getContentSize().width
    scroll_panel_ori_h = scroll_panel:getContentSize().height

    local main_panel = getConvertChildByName(scroll_panel,"main_panel")
    main_panel:setBackGroundColorType(LAYOUT_COLOR_NONE)

    

   


    local desc_arrow_up = getConvertChildByName(temp_widget,"desc_arrow_up")
    local desc_arrow_down = getConvertChildByName(temp_widget,"desc_arrow_down")
    desc_arrow_up:setVisible(false)
    desc_arrow_down:setVisible(false)



    local function ScrollViewEvent(sender, eventType) 
        
        if eventType == SCROLLVIEW_EVENT_SCROLL_TO_TOP then 
            desc_arrow_up:setVisible(false)
            desc_arrow_down:setVisible(true)
        elseif eventType == SCROLLVIEW_EVENT_SCROLL_TO_BOTTOM then 
            desc_arrow_up:setVisible(true)
            desc_arrow_down:setVisible(false)
        elseif eventType == SCROLLVIEW_EVENT_SCROLLING then
            if scroll_panel:getInnerContainer():getPositionY() > (-scroll_panel:getPositionY()) and 
                scroll_panel:getInnerContainer():getPositionY() < 0  then 
                desc_arrow_down:setVisible(true)
                desc_arrow_up:setVisible(true)
            end
        end
    end
    scroll_panel:addEventListenerScrollView(ScrollViewEvent)
    -- 富文本
    richTextContent = RichText:create()
	richTextContent:ignoreContentAdaptWithSize(false)
    -- richTextContent:setVerticalSpace(3)
    richTextContent:setSize(CCSizeMake(main_panel:getContentSize().width, 0 ))
    richTextContent:setAnchorPoint(cc.p(0.5,1))
    main_panel:addChild(richTextContent)
    richTextContent:setPosition(cc.p(main_panel:getContentSize().width/2,main_panel:getContentSize().height))
 	
end

function loginBulletin.show(id)
	loginBulletin.create()
    
    for i=1 ,#bulletin_list do 
        if bulletin_list[i].id == id then 
            local temp_widget = main_layer:getWidgetByTag(999)
            local panel_list = getConvertChildByName(temp_widget,"panel_list")
            local panel_item = getConvertChildByName(panel_list,"panel_item")
            local offsetY = list_tabel_view:getViewSize().height - list_tabel_view:getContentSize().height
            offsetY = offsetY + (i - 1) * (panel_item:getContentSize().height)
            if #bulletin_list > 4 then 
                if offsetY > 0 then offsetY = 0 end
                list_tabel_view:setContentOffsetInDuration(cc.p(0,offsetY),0.5)
            end
            bulletin_list[i].isRead = true
            setSelectedBulletin(i)
            updateDetail(i)
            break
        end
    end
end

function loginBulletin.getInstance(  )
    return mlayer
end

return loginBulletin
