
module("UIChatMain",package.seeall)

require("game/chat/ui_chat_defriend")
require("game/chat/chat_data")

local StringUtil = require("game/utils/string_util")
local uiUtil = require("game/utils/ui_util")
local timeUtil = require("game/utils/time_util")



local main_layer = nil
local selected_channel = nil
local textEditbox = nil
local list_tabel_view = nil
local list_data = nil
local cacheRichInfoList = nil
local btn_record = nil

local cell_default_width = 855
local cell_default_height = 77
local cell_default_height_world_unionBattle = 110


local cell_height_per_line = 25

local cell_content_default_width = 825
local cell_content_default_height = 30
local cell_content_default_font_size = 22

local cell_height_cache = nil


local chat_interval_handler = nil
local recordIng_handler = nil


local b_is_channel_open = nil
local i_chanel_open_renown = nil
local b_is_channel_interval_limit = nil
local i_chanel_interval_left = nil


local record_class = nil
local arr_record = nil
local playing_FileName = nil --正在播放的语音的名字

local i_lastSelectedIndx = nil

local function disposeSchedulerHandler()
    if chat_interval_handler then 
        scheduler.remove(chat_interval_handler)
        chat_interval_handler = nil
    end
end

local function updateScheduler()
    checkChatInterval()
end

local function activeSchedulerHandler()
    disposeSchedulerHandler()
    chat_interval_handler = scheduler.create(updateScheduler,1)
end


local function do_remove_self()

    if list_tabel_view then 
        list_tabel_view:removeFromParentAndCleanup(true)
        list_tabel_view = nil
    end

    if textEditbox then
        textEditbox:removeFromParentAndCleanup(true)
        textEditbox = nil
    end

    playing_FileName = nil
    comOPMenu.remove_self()
    UIChatDefriend.remove_self()
    if record_class then
       record_class:remove()
    end

    if recordIng_handler then
        scheduler.remove(recordIng_handler)
    end
    recordIng_handler = nil
    btn_record = nil
    arr_record = nil
    if main_layer then
        main_layer:removeFromParentAndCleanup(true)
        main_layer = nil
        uiManager.remove_self_panel(uiIndexDefine.UI_CHAT_MAIN)
    end
    selected_channel = nil
    list_data = nil
    cell_height_cache = nil

    b_is_channel_open = nil
    i_chanel_open_renown = nil
    b_is_channel_interval_limit = nil
    i_chanel_interval_left = nil
    
end

function remove_self()
    sdkMgr:sharedSkdMgr():setTouchCount(2)
    if list_tabel_view then 
        disposeSchedulerHandler()
        list_tabel_view:removeFromParentAndCleanup(true)
        list_tabel_view = nil
    end
    uiManager.hideConfigEffect(uiIndexDefine.UI_CHAT_MAIN,main_layer,do_remove_self)
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

local function getListData()
    return ChatData.get_channel_cache_info_list(selected_channel)
end



-- 组织聊天信息的富文本
local function orgnizeChatRichText(indx)
    local chatInfo = list_data[indx]
	


    local arg = {}
    local str = chatInfo.content

    local _richText = RichText:create()
    _richText:setVerticalSpace(1)
    _richText:setAnchorPoint(cc.p(0,1))
    _richText:ignoreContentAdaptWithSize(false)
    _richText:setSize(CCSizeMake(cell_default_width, cell_default_height))
    _richText:setPosition(cc.p(0,cell_default_height))

    local ColorUtil = require("game/utils/color_util")
    local index = 0

    local tempStr = string.gsub(str, "&", function (n)
        temp = arg[index]
        index = index + 1
        return temp or "&"
    end)

    -- local tempArg = {} 
    -- tempArg["#"] = 1
    -- tempArg["@"] = 2
    -- tempArg["^"] = 3
    -- tempArg["~"] = 4
    local tStr = config.richText_split(tempStr,{"#","@","^","~"})
    local re1 = nil

    if chatInfo.param then
        if chatInfo.param.voice_file_name then
            local node = GUIReader:shareReader():widgetFromJsonFile("test/recordItem.json")
            re1 = RichElementCustomNode:create(1, ccc3(255,255,255), 255, node)
            _richText:pushBackElement(re1)
        end
    end

    for i,v in ipairs(tStr) do
        if v[1] == 1 then
            re1 = RichElementText:create(i, ccc3(255,255,255), 255, v[2],config.getFontName(), 20)
        else
            re1 = RichElementText:create(i, ccc3(255,213,110), 255, v[2],config.getFontName(), 20)
        end
        _richText:pushBackElement(re1)
    end
    
    _richText:formatText()

    local ttf = Label:create()
    ttf:setText("x")
    ttf:setFontSize(20)
    table.insert(cacheRichInfoList, {_richText:getRealHeight(), tStr,ttf:getSize().height })

end


-- 组织系统事件的富文本
local function orgnizeSysLogRichText(indx )
    -- local sysInfo = list_data[indx]
    local temp_data = list_data[indx]
    local arg = {}
    local str = game_log_msg[temp_data.log_type]
    arg = cjson.decode(temp_data.param)

    local _richText = RichText:create()
    _richText:setVerticalSpace(1)
    _richText:setAnchorPoint(cc.p(0,1))
    _richText:ignoreContentAdaptWithSize(false)
    _richText:setSize(CCSizeMake(cell_default_width, cell_default_height))
    _richText:setPosition(cc.p(0,cell_default_height))

    local ColorUtil = require("game/utils/color_util")
    local index = 0
    local wid_data = {}
    local wid_name_data = {}
    local tempStr = string.gsub(str, "%u", function (n)
        if n == "L" then
            return n
        else
            index = index + 1
            temp = arg[index]
            -- 武将名
            if n == "H" then
                return ColorUtil.getHeroNameWrite(tonumber(temp) )
            -- 地块名
            elseif n == "N" then
                -- landData.get_city_name_when_happened( land_id)
                if temp == "" then
                    table.insert(wid_name_data, temp)
                    return n
                else
                    return temp
                end
            -- 坐标
            elseif n == "A" then
                if #wid_name_data > 0 then
                    table.insert(wid_data, tonumber(temp))
                end
                return math.floor(tonumber(temp)/10000)..","..tonumber(temp)%10000
            -- 敌方势力名
            elseif n == "E" then
                return temp
            -- 设施id
            elseif n == "B" then
                return Tb_cfg_build[tonumber(temp)].name
            -- 直接显示数字
            elseif n == "X" then
                return tonumber(temp)
            -- 资源名
            elseif n == "R" or n == "C" then
                local _Str = ""
                temp = stringFunc.anlayerMsg(temp)
                for i, v in ipairs(temp) do
                    if temp_data.log_type == 13 then
                        if i~= #temp then
                            _Str = _Str .. clientConfigData.getDorpName(v[1])..languagePack['chanliangtigao'].."@"..clientConfigData.getDorpCount(v[1], v[2]).."@，"
                        else
                            _Str = _Str .. clientConfigData.getDorpName(v[1])..languagePack['chanliangtigao'].."@"..clientConfigData.getDorpCount(v[1], v[2]).."@"
                        end
                    else
                        _Str = _Str .. clientConfigData.getDorpName(v[1]).."x"..clientConfigData.getDorpCount(v[1], v[2]).." "
                    end
                end
                return _Str
            else
                return n
            end
        end
    end)
    
    -- 当有地块名字但是服务器传过来是空字符串的时候，客户端要把地块名字填上去
    if #wid_name_data > 0 then
        local index = 0
        tempStr = string.gsub(tempStr, "%u", function (n)
                if n == "L" then
                    return n
                else
                    index = index + 1
                    temp = wid_data[index]
                    if n == "N" then
                        return landData.get_city_name_when_happened( temp)
                    else
                        return n
                    end
                end
            end)
    end

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

    local ttf = Label:create()
    ttf:setText("x")
    ttf:setFontSize(20)
    
    table.insert(cacheRichInfoList, {_richText:getRealHeight(), tStr,ttf:getSize().height })
end


local function getNpcCityLevel(landId)
   local level = ni
   local cfgCityInfo = Tb_cfg_world_city[landId]
   if cfgCityInfo then 
        level = cfgCityInfo.param % 10
   end
   if level == 0 then level = 10 end
   return level
end

-- 世界频道 同盟相关的战况信息
local function setCellWidgetUnionBattleInfo(indx,cellWidget)
	local chatInfo = list_data[indx + 1]
	


	cellWidget:setPositionY(0)

    local panel_battle_info = uiUtil.getConvertChildByName(cellWidget,"panel_battle_info")
	local label_time = uiUtil.getConvertChildByName(panel_battle_info,"label_time")
    label_time:setText(timeUtil.formatChatTime(chatInfo.timestamp,userData.getServerTime()))
    label_time:setColor(ccc3(194,245,187))


    local img_bg = uiUtil.getConvertChildByName(panel_battle_info,"img_bg")

    local panel_npccity_occupied = uiUtil.getConvertChildByName(panel_battle_info,"panel_npccity_occupied")
    local panel_union_occupied = uiUtil.getConvertChildByName(panel_battle_info,"panel_union_occupied")

    panel_npccity_occupied:setVisible(false)
    panel_union_occupied:setVisible(false)

    if chatInfo.subType == ChatData.CHAT_SUB_TYPE_UNION_OCCUPY_NPCCITY then
        if chatInfo.is_first == 1 then
            panel_npccity_occupied:setVisible(true)
            local label_kill_name = uiUtil.getConvertChildByName(panel_npccity_occupied,"label_kill_name")
            local label_duribility_name = uiUtil.getConvertChildByName(panel_npccity_occupied,"label_duribility_name")
            label_kill_name:setText(chatInfo.param.kill_max_name)
            label_duribility_name:setText(chatInfo.param.duribility_max_name)
        end
    elseif chatInfo.subType == ChatData.CHAT_SUB_TYPE_UNION_OCCUPY_UNION then
        panel_union_occupied:setVisible(false)
    end


    local panel_rich_text = uiUtil.getConvertChildByName(cellWidget,"panel_rich_text")
    panel_rich_text:setBackGroundColorType(LAYOUT_COLOR_NONE)
    panel_rich_text:setVisible(true)
    panel_rich_text:removeAllChildrenWithCleanup(true)
    panel_rich_text:ignoreAnchorPointForPosition(false)
    panel_rich_text:setAnchorPoint(cc.p(0,1))
    panel_rich_text:setPosition(cc.p(10,70))

    local space = 1
    local _richText = RichText:create()
    _richText:setVerticalSpace(space)
    _richText:setAnchorPoint(cc.p(0,1))
    _richText:ignoreContentAdaptWithSize(false)
    _richText:setSize(CCSizeMake(panel_rich_text:getSize().width, panel_rich_text:getSize().height))
    panel_rich_text:addChild(_richText)
    _richText:setPosition(cc.p(0,panel_rich_text:getSize().height))

    

    local color_content = nil
    if not chatInfo.is_self then 
        color_content = ccc3(255,255,255)
    else
        color_content = ccc3(255,243,195)
    end
    local temp_height = nil
    if chatInfo.param then
        if chatInfo.param.voice_file_name then
            local node = GUIReader:shareReader():widgetFromJsonFile("test/recordItem.json")
            re1 = RichElementCustomNode:create(1, ccc3(255,255,255), 255, node)
            _richText:pushBackElement(re1)

            initRecordImage( node, chatInfo, panel_rich_text, space )
        end
    end

    if cacheRichInfoList[indx+1] then
        for i,v in ipairs(cacheRichInfoList[indx+1][2]) do
            if v[1] == 1 then
                re1 = RichElementText:create(i, ccc3(188,216,168), 255, v[2],config.getFontName(), 20)
            elseif v[1] == 2 then
                re1 = RichElementText:create(i, ccc3(255,213,110), 255, v[2],config.getFontName(), 20)
            elseif v[1] == 3 then
                re1 = RichElementText:create(i, ccc3(222,212,171), 255, v[2],config.getFontName(), 20)
            else
                re1 = RichElementText:create(i, ccc3(154,42,61), 255, v[2],config.getFontName(), 20)
            end
            _richText:pushBackElement(re1)
        end
        temp_height = cacheRichInfoList[indx+1][1]
        _richText:setPosition(cc.p(0,panel_rich_text:getSize().height))
    end
    _richText:formatText()


    if chatInfo.subType == ChatData.CHAT_SUB_TYPE_UNION_OCCUPY_NPCCITY or 
        chatInfo.subType == ChatData.CHAT_SUB_TYPE_UNION_INFO  then
        img_bg:loadTexture(ResDefineUtil.ui_chat_battle_info_imgs[2],UI_TEX_TYPE_PLIST)
    else
        img_bg:loadTexture(ResDefineUtil.ui_chat_battle_info_imgs[1],UI_TEX_TYPE_PLIST)
    end

end

function stopRecordHandler( )
    if playing_FileName then
        if list_data and list_tabel_view then
            for i, v in pairs(list_data) do
                if v.param and v.param.voice_file_name and v.param.voice_file_name == playing_FileName then
                    local cell = list_tabel_view:cellAtIndex(i-1)
                    if cell then
                        local layer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
                        if layer then
                            local widget = layer:getWidgetByTag(10)
                            if widget then
                                local panel_rich_text = uiUtil.getConvertChildByName(widget,"panel_rich_text")
                                local item = panel_rich_text:getChildByTag(99)
                                if item then
                                    VoicePlayAnimation.remove(item, v.param.voice_file_name)
                                end
                            end
                        end
                    end
                end
            end
        end
        playing_FileName = nil
    end

    if recordIng_handler then
        scheduler.remove(recordIng_handler)
        recordIng_handler = nil
    end
end

function startRecordHandler(filename,sec )
    if recordIng_handler then
        scheduler.remove(recordIng_handler)
        recordIng_handler = nil
    end

    playing_FileName = filename--chatInfo.param.voice_file_name
    recordIng_handler = scheduler.create(function ( )
        stopRecordHandler()
    end,sec)
end

local function initRecordImage( node, chatInfo, panel_rich_text, space )
    VoiceMgr.downLoad_amr_from_server(chatInfo.param.md5_key, chatInfo.param.voice_file_name)

    local time = chatInfo.param.voice_seconds --防止0秒
    if time <= 0 then
        time = 1
    end
    local node1 = node:clone()
    node1:setTouchEnabled(true)
    node1:addTouchEventListener(function (sender ,eventType )
        if eventType == TOUCH_EVENT_ENDED then
            stopRecordHandler()
            startRecordHandler(chatInfo.param.voice_file_name,time )
            VoicePlayAnimation.create(node1, chatInfo.param.voice_file_name)
        end
    end)
    local Label_time = tolua.cast(node1:getChildByName("Label_time"),"Label")
    Label_time:setText(time..languagePack['date_sec'])
    panel_rich_text:addChild(node1,99,99)
    node1:setPosition(cc.p(0,panel_rich_text:getSize().height-node1:getSize().height-space))
    if playing_FileName and playing_FileName == chatInfo.param.voice_file_name then
        VoicePlayAnimation.create(node1, chatInfo.param.voice_file_name)
    end
end

-- 聊天信息
local function setCellWidgetChatInfo(indx,cellWidget)
    local chatInfo = list_data[indx + 1]
    local main_panel = uiUtil.getConvertChildByName(cellWidget,"main_panel")
    local bg_front = uiUtil.getConvertChildByName(main_panel,"bg_img_front")
    local bg_back = uiUtil.getConvertChildByName(main_panel,"bg_img_back")

    local offsetHeight = 0
    if cacheRichInfoList[indx+1] then
        offsetHeight = cacheRichInfoList[indx+1][1] - cacheRichInfoList[indx+1][3]
    end
    bg_front:setSize(CCSizeMake(cell_default_width,cell_default_height+offsetHeight))
    bg_back:setSize(CCSizeMake(cell_default_width,cell_default_height+offsetHeight))
    cellWidget:setPositionY(offsetHeight)


    local label_title = uiUtil.getConvertChildByName(main_panel,"label_title")
    local label_name = uiUtil.getConvertChildByName(main_panel,"label_name")
    local label_time = uiUtil.getConvertChildByName(main_panel,"label_time")
    label_title:setVisible(true)
    label_name:setVisible(true)
    
    local show_user_name = ""
    local show_title_str = ""
    if chatInfo.region_name ~= "" then 
        show_title_str = show_title_str .. "【" .. chatInfo.region_name .. "】"
    end
    if chatInfo.union_name ~= "" and selected_channel ~= ChatData.CHANNEL_INDX_UNION then 
        show_title_str = show_title_str .. "【" .. chatInfo.union_name .. "】"
    end
    if chatInfo.is_self then 
        show_user_name = languagePack["first_person_name"]
    else
        show_user_name = chatInfo.user_name
    end

    if chatInfo.is_self then 
        label_title:setVisible(false)
        label_name:setText(show_user_name)
        label_name:setPositionX(11)
    else
        label_title:setVisible(true)
        label_title:setText(show_title_str)
        label_title:setPositionX(11)
        label_name:setText(show_user_name)
        label_name:setPositionX(label_title:getPositionX() + label_title:getContentSize().width)
    end

    label_time:setText(timeUtil.formatChatTime(chatInfo.timestamp,userData.getServerTime()))

    if not chatInfo.is_self then 
        label_name:setColor(ccc3(226,184,103))
        label_time:setColor(ccc3(194,245,187))
    else
        label_name:setColor(ccc3(255,243,195))
        label_time:setColor(ccc3(255,243,195))
    end

    if chatInfo.subType == ChatData.CHAT_SUB_TYPE_SYS then
        label_title:setText(languagePack['str_system'])
        label_title:setVisible(true)
        label_name:setVisible(false)
    end
    local panel_rich_text = uiUtil.getConvertChildByName(cellWidget,"panel_rich_text")
    panel_rich_text:setBackGroundColorType(LAYOUT_COLOR_NONE)
    panel_rich_text:setVisible(true)
    panel_rich_text:removeAllChildrenWithCleanup(true)
    panel_rich_text:ignoreAnchorPointForPosition(false)
    panel_rich_text:setAnchorPoint(cc.p(0,1))
    panel_rich_text:setPosition(cc.p(10,42))

    local space = 1
    local _richText = RichText:create()
    _richText:setVerticalSpace(space)
    _richText:setAnchorPoint(cc.p(0,1))
    _richText:ignoreContentAdaptWithSize(false)
    _richText:setSize(CCSizeMake(panel_rich_text:getSize().width, panel_rich_text:getSize().height))
    panel_rich_text:addChild(_richText)
    _richText:setPosition(cc.p(0,panel_rich_text:getSize().height))

    

    local color_content = nil
    if not chatInfo.is_self then 
        color_content = ccc3(255,255,255)
    else
        color_content = ccc3(255,243,195)
    end
    local temp_height = nil
    if chatInfo.param then
        if chatInfo.param.voice_file_name then
            local node = GUIReader:shareReader():widgetFromJsonFile("test/recordItem.json")
            re1 = RichElementCustomNode:create(1, ccc3(255,255,255), 255, node)
            _richText:pushBackElement(re1)

            initRecordImage( node, chatInfo, panel_rich_text, space )
        end
    end

    if cacheRichInfoList[indx+1] then
        for i,v in ipairs(cacheRichInfoList[indx+1][2]) do
            if v[1] == 1 then
                re1 = RichElementText:create(i, color_content, 255, v[2],config.getFontName(), 20)
            else
                re1 = RichElementText:create(i, ccc3(255,213,110), 255, v[2],config.getFontName(), 20)
            end
            _richText:pushBackElement(re1)
        end
        temp_height = cacheRichInfoList[indx+1][1]
        _richText:setPosition(cc.p(0,panel_rich_text:getSize().height))
    end
    _richText:formatText()
end

-- 系统事件
local function setCellWidgetSysGrountEvent(indx,cellWidget)
    local sysInfo = list_data[indx + 1]

    local main_panel = uiUtil.getConvertChildByName(cellWidget,"main_panel")
    local bg_front = uiUtil.getConvertChildByName(main_panel,"bg_img_front")
    local bg_back = uiUtil.getConvertChildByName(main_panel,"bg_img_back")

    local offset = 0
    if cacheRichInfoList[indx+1] then
        offset = cacheRichInfoList[indx+1][1] - cacheRichInfoList[indx+1][3]
    end
    bg_front:setSize(CCSizeMake(cell_default_width,cell_default_height+offset))
    bg_back:setSize(CCSizeMake(cell_default_width,cell_default_height+offset))
    cellWidget:setPositionY(offset)

    local label_title = uiUtil.getConvertChildByName(main_panel,"label_title")
    local label_name = uiUtil.getConvertChildByName(main_panel,"label_name")
    local label_time = uiUtil.getConvertChildByName(main_panel,"label_time")

    label_title:setText(languagePack["ground_event_title_name"])
    label_time:setText(timeUtil.formatChatTime(sysInfo.log_time,userData.getServerTime()))
    label_title:setVisible(true)
    label_name:setVisible(false)
    

    label_title:setColor(ccc3(194,245,187))
    label_time:setColor(ccc3(194,245,187))

    local panel_rich_text = uiUtil.getConvertChildByName(cellWidget,"panel_rich_text")
    panel_rich_text:setBackGroundColorType(LAYOUT_COLOR_NONE)
    panel_rich_text:setVisible(true)
    panel_rich_text:removeAllChildrenWithCleanup(true)
    panel_rich_text:ignoreAnchorPointForPosition(false)
    panel_rich_text:setAnchorPoint(cc.p(0,1))
    panel_rich_text:setPosition(cc.p(10,42))

    local _richText = RichText:create()
    _richText:setVerticalSpace(1)
    _richText:setAnchorPoint(cc.p(0,1))
    _richText:ignoreContentAdaptWithSize(false)
    _richText:setSize(CCSizeMake(panel_rich_text:getSize().width, panel_rich_text:getSize().height))
    panel_rich_text:addChild(_richText)
    _richText:setPosition(cc.p(0,panel_rich_text:getSize().height))

    


    local temp_height = nil
    if cacheRichInfoList[indx+1] then
        for i,v in ipairs(cacheRichInfoList[indx+1][2]) do
            if v[1] == 1 then
                re1 = RichElementText:create(i, ccc3(255,255,255), 255, v[2],config.getFontName(), 20)
            else
                re1 = RichElementText:create(i, ccc3(255,213,110), 255, v[2],config.getFontName(), 20)
            end
            _richText:pushBackElement(re1)
        end
        temp_height = cacheRichInfoList[indx+1][1]
        _richText:setPosition(cc.p(0,panel_rich_text:getSize().height))
    end
    _richText:formatText()
end


local function setCellWidget(indx,cellWidget)
	
	local chatInfo = list_data[indx + 1]
	local main_panel = uiUtil.getConvertChildByName(cellWidget,"main_panel")
	main_panel:setVisible(false)

	local panel_rich_text = uiUtil.getConvertChildByName(cellWidget,"panel_rich_text")
	panel_rich_text:setVisible(false)

    local panel_battle_info = uiUtil.getConvertChildByName(cellWidget,"panel_battle_info")
    panel_battle_info:setVisible(false)
    panel_battle_info:setPositionY(0)

	

	
    panel_rich_text:setVisible(true)
	if selected_channel == ChatData.CHANNEL_INDX_WORLD and chatInfo and chatInfo.subType then
		if chatInfo.subType == ChatData.CHAT_SUB_TYPE_NORMAL then
			main_panel:setVisible(true)
		elseif chatInfo.subType == ChatData.CHAT_SUB_TYPE_VOICE then
            main_panel:setVisible(true)
		elseif chatInfo.subType == ChatData.CHAT_SUB_TYPE_SYS then
            main_panel:setVisible(true)
        else
			panel_battle_info:setVisible(true)
		end
	else
		main_panel:setVisible(true)
	end
	

    if selected_channel == ChatData.CHANNEL_INDX_SYS then 
        setCellWidgetSysGrountEvent(indx,cellWidget)
    else
		if selected_channel == ChatData.CHANNEL_INDX_WORLD then
			local chatInfo = list_data[indx + 1]
			if chatInfo and chatInfo.subType and 
				(chatInfo.subType == ChatData.CHAT_SUB_TYPE_NORMAL 
					or chatInfo.subType == ChatData.CHAT_SUB_TYPE_VOICE 
                    or chatInfo.subType == ChatData.CHAT_SUB_TYPE_SYS) then
				setCellWidgetChatInfo(indx,cellWidget)
			else
                setCellWidgetUnionBattleInfo(indx,cellWidget)
			end
		else
        	setCellWidgetChatInfo(indx,cellWidget)
		end
    end
end

local function setCell(indx)

    if not list_tabel_view then return end
    
    local cell = list_tabel_view:cellAtIndex(indx)
    if not cell then return end
    
    local cellWidget = nil
    local cellLayer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
    if cellLayer then
        cellWidget = tolua.cast(cellLayer:getWidgetByTag(10),"Layout")
        setCellWidget(indx,cellWidget)
    end  
end

local function refreshCell()
    if not list_data then return end
    for i = 1 ,#list_data do 
        setCell(i - 1)
    end
end






-- 检查聊天消耗
function checkChatCost()
    if not main_layer then return end
    local widget = main_layer:getWidgetByTag(999) 
    if not widget then return end

    local panel_cost = uiUtil.getConvertChildByName(widget,"panel_cost")

    if selected_channel == ChatData.CHANNEL_INDX_SYS then 
        return 
    end
    if selected_channel == ChatData.CHANNEL_INDX_UNION then 
        return 
    end

    if selected_channel == ChatData.CHANNEL_INDX_REGION then 
        return 
    end

    -- 世界聊天频道  免费次数使用完后 才需要玉符消耗
    if selected_channel == ChatData.CHANNEL_INDX_WORLD then 
        local label_free_count = uiUtil.getConvertChildByName(panel_cost,"label_free_count")
        
        local free_txt = languagePack['mianfei'] ..  "（" .. ChatData.getChatFreeCountLeft(selected_channel) .. "/" .. ChatData.CHANNEL_FREE_CHAT_COUNT_WORLD .. "）"
        label_free_count:setText(free_txt)

        local img_cost_gold = uiUtil.getConvertChildByName(panel_cost,"img_cost_gold")
        local label_cost_gold = uiUtil.getConvertChildByName(panel_cost,"label_cost_gold")

        label_free_count:setVisible(false)
        img_cost_gold:setVisible(false)
        label_cost_gold:setVisible(false)

        label_cost_gold:setText(ChatData.getChatCost(selected_channel))
        if ChatData.getChatFreeCountLeft(selected_channel) > 0 then 
            label_free_count:setVisible(true)
        else
            img_cost_gold:setVisible(true)
            label_cost_gold:setVisible(true)
            if userData.getYuanbao() >= ChatData.getChatCost(selected_channel) then 
                label_cost_gold:setColor(ccc3(234,232,156))
            else
                label_cost_gold:setColor(ccc3(207,72,75))
            end
        end
    end
end

local function checkNullTips()
    if not main_layer then return end
    local widget = main_layer:getWidgetByTag(999)
    local label_null_tips = uiUtil.getConvertChildByName(widget,"label_null_tips")
    local label_union_tips = uiUtil.getConvertChildByName(widget,"label_union_tips")

     -- 如果没有数据给出友好提示
    if #list_data > 0 then 
        label_null_tips:setVisible(false)
    else
        label_null_tips:setVisible(true)
        if selected_channel == ChatData.CHANNEL_INDX_WORLD then 
            label_null_tips:setText(languagePack["chat_null_personal"])
        elseif selected_channel == ChatData.CHANNEL_INDX_UNION then 
            label_null_tips:setText(languagePack["chat_null_union"] )
        elseif selected_channel == ChatData.CHANNEL_INDX_SYS then 
            label_null_tips:setText(languagePack["chat_null_sys"] )
        elseif selected_channel == ChatData.CHANNEL_INDX_REGION then 
            label_null_tips:setText(languagePack["chat_null_region"] )
        end

        if label_union_tips:isVisible() then 
            label_null_tips:setVisible(false)
        end
    end

end


function refreshChatInfo(indx)
    if indx ~= selected_channel then return end

    if selected_channel == ChatData.CHANNEL_INDX_UNION and 
        not (userData.getUnion_id() and userData.getUnion_id() ~= 0) then
        return 
    end
    list_data = getListData()

    cacheRichInfoList = {}
    if selected_channel == ChatData.CHANNEL_INDX_SYS then
        for i, v in ipairs(list_data) do
            orgnizeSysLogRichText(i)
        end
    else
        for i,v in ipairs(list_data) do 
            orgnizeChatRichText(i)
        end
    end

    if not list_tabel_view then return end
    list_tabel_view:reloadData()
    if #list_data > 4 then
        list_tabel_view:setContentOffset(cc.p(0,0))
    end
    --refreshCell()

    checkChatCost()
    checkNullTips()
end


function getCurSelectedIndx()
    return selected_channel
end


function refreshMsgCount(indx,count)
    if not main_layer then return end
    if indx == selected_channel then return end
    local widget = main_layer:getWidgetByTag(999)
    local temp_btn = uiUtil.getConvertChildByName(widget,"btn_" .. indx)
    local img_flag = uiUtil.getConvertChildByName(temp_btn,"img_flag")
    if count and count > 0 then 
        img_flag:setVisible(true)
    else
        img_flag:setVisible(false)
    end
end


local function resetChatDefault()
    if not main_layer then return end
    if indx == selected_channel then return end
    local widget = main_layer:getWidgetByTag(999)

    local edit_panel = uiUtil.getConvertChildByName(widget,"edit_panel")
    local content_panel = uiUtil.getConvertChildByName(edit_panel,"content_panel")
    local label_chatDefault = uiUtil.getConvertChildByName(content_panel,"label_chatDefault")

    textEditbox:setText(" ")
    label_chatDefault:setVisible(true)
    label_chatDefault:setText(languagePack["chat_default"])
    label_chatDefault:setColor(ccc3(91,92,96))
    -- changeSendBtnState(true,true)
    label_chatDefault:setPositionX(0)
    label_chatDefault:setAnchorPoint(cc.p(0,0.5))


end


function setViewByChannel(channelId)

    if selected_channel == channelId then return end

    local widget = main_layer:getWidgetByTag(999)
    if not widget then return end
    local temp_btn = nil
    local is_btn_able = true
    for i = 1,4 do
        temp_btn = uiUtil.getConvertChildByName(widget,"btn_" .. i)
        is_btn_able = false
        if i ~= channelId then is_btn_able = true end
        temp_btn:setTouchEnabled(is_btn_able)
        temp_btn:setBright(is_btn_able)
        uiUtil.setBtnLabel(temp_btn,not is_btn_able)
    end

    
    refreshMsgCount(channelId,0)

    comOPMenu.remove_self()
    UIChatDefriend.remove_self()
    
    local list_panel = uiUtil.getConvertChildByName(widget,"list_panel")
    local edit_panel = uiUtil.getConvertChildByName(widget,"edit_panel")
    local content_panel = uiUtil.getConvertChildByName(edit_panel,"content_panel")
    local label_chatDefault = uiUtil.getConvertChildByName(content_panel,"label_chatDefault")
    local btn_join_union = uiUtil.getConvertChildByName(widget,"btn_join_union")
    local btn_send = uiUtil.getConvertChildByName(widget,"btn_send")

    -- if not textEditbox:isVisible()  or StringUtil.isEmptyStr(textEditbox:getText()) or textEditbox:getText() == languagePack["chat_default"] then 
    --     label_chatDefault:setVisible(true)
    -- else
    --     label_chatDefault:setVisible(false)
    -- end
    resetChatDefault()
    
    local label_null_tips = uiUtil.getConvertChildByName(widget,"label_null_tips")
    local label_union_tips = uiUtil.getConvertChildByName(widget,"label_union_tips")

    local img_bg = uiUtil.getConvertChildByName(widget,"img_bg")
    local img_drag_flag_up = uiUtil.getConvertChildByName(widget,"img_drag_flag_up")
    local img_drag_flag_down = uiUtil.getConvertChildByName(widget,"img_drag_flag_down")
    img_drag_flag_up:setVisible(false)
    img_drag_flag_down:setVisible(false)


    local panel_cost = uiUtil.getConvertChildByName(widget,"panel_cost")
    panel_cost:setVisible(false)


    -- 切换到同盟标签时 如果没有加入同盟需要有提示
    local function showUnionLockTips(isShow)
        label_union_tips:setVisible(isShow)
        btn_join_union:setVisible(isShow)
        btn_join_union:setTouchEnabled(isShow)
        list_panel:setVisible(not isShow)
        edit_panel:setVisible(not isShow)
        textEditbox:setVisible(not isShow)
        textEditbox:setTouchEnabled(not isShow)
        btn_record:setVisible(not isShow)
        btn_record:setTouchEnabled(not isShow)
        btn_send:setVisible(not isShow)
        btn_send:setTouchEnabled(not isShow)
        list_tabel_view:setVisible(not isShow)
        list_tabel_view:setTouchEnabled(not isShow)
    end

    -- 不同的标签有不同的高度
    local function autoSizeImgBg(width,height)
        -- img_bg:setContentSize(CCSizeMake(width,height))
        img_bg:setSize(CCSizeMake(width,height))
    end

    -- 不同的标签页的 list 高度也不一样的
    local function autoSizeList(width,height,x,y)
        list_panel:setContentSize(CCSizeMake(width,height))
        list_panel:setPosition(cc.p(x,y))
        list_panel:setSize(CCSizeMake(width,height))

        list_tabel_view:setContentSize(CCSizeMake(width,height))
        list_tabel_view:setViewSize(CCSizeMake(width,height))
        list_tabel_view:setPosition(cc.p(width/2,height/2))

        img_drag_flag_up:setPositionY(list_panel:getPositionY() + height)
        img_drag_flag_down:setPositionY(list_panel:getPositionY())
    end
    if channelId == ChatData.CHANNEL_INDX_WORLD then
        -- 世界聊天频道
        showUnionLockTips(false)
        autoSizeImgBg(862,373)
        autoSizeList(862,368,30,132)
        panel_cost:setVisible(true)
    elseif channelId == ChatData.CHANNEL_INDX_UNION then
        -- 同盟聊天频道
        if userData.getUnion_id() and userData.getUnion_id() ~= 0 then
            showUnionLockTips(false)
            autoSizeImgBg(862,373)
            autoSizeList(862,368,30,132)
        else
            showUnionLockTips(true)
            autoSizeImgBg(862,475)
            autoSizeList(862,470,30,30)
        end
        panel_cost:setVisible(false)
    elseif channelId == ChatData.CHANNEL_INDX_REGION then 
        -- 州聊天频道
        showUnionLockTips(false)
        autoSizeImgBg(862,373)
        autoSizeList(862,368,30,132)
        panel_cost:setVisible(false)
    elseif channelId == ChatData.CHANNEL_INDX_SYS then 
        -- 系统事件
        
        autoSizeImgBg(862,475)
        showUnionLockTips(false)
        edit_panel:setVisible(false)
        textEditbox:setVisible(false)
        textEditbox:setTouchEnabled(false)
        btn_record:setVisible(false)
        btn_record:setTouchEnabled(false)
        btn_send:setVisible(false)
        btn_send:setTouchEnabled(false)
        autoSizeList(862,470,30,30)

        panel_cost:setVisible(false)
    end

    ChatData.clearUnReadMsg(channelId)

    selected_channel = channelId
	i_lastSelectedIndx = selected_channel 
    list_data = getListData()

    checkNullTips()

    cacheRichInfoList = {}
    if channelId == ChatData.CHANNEL_INDX_SYS then
        for i, v in ipairs(list_data) do
            orgnizeSysLogRichText(i)
        end
    else
        for i,v in ipairs(list_data) do 
            orgnizeChatRichText(i)
        end
    end

    if not list_tabel_view then return end
    list_tabel_view:reloadData()
    if #list_data > 4 then
        list_tabel_view:setContentOffset(cc.p(0,0))
    end
    --refreshCell()

    checkOpenState()
    checkChatInterval()
    
    checkChatCost()
end



local function tableCellTouched(table,cell)
    local idx = cell:getIdx()
    local chatInfo = list_data[idx + 1]
    if not chatInfo then return end
    
    if chatInfo.is_self then return end

    if chatInfo.subType ~= ChatData.CHAT_SUB_TYPE_NORMAL and 
        chatInfo.subType ~= ChatData.CHAT_SUB_TYPE_VOICE then
        return 
    end



    
    local function callback_detail()
        UIRoleForcesMain.create(chatInfo.user_id)
    end

    local function callback_sendMail()
        SendMailUI.create("","",chatInfo.user_id, chatInfo.user_name)
    end
    local function callback_defriend()

        alertLayer.create(errorTable[2018],{chatInfo.user_name},function()
            BlackNameListData.addUserByIdList({chatInfo.user_id})
        end)
    end

    if selected_channel and selected_channel ~= ChatData.CHANNEL_INDX_SYS then
        comOPMenu.create({
            {label = languagePack["gerenxinxi"],callback = callback_detail},
            {label = languagePack["fasongyoujian"],callback = callback_sendMail},
            {label = languagePack["jiaruheimingdan"] ,callback = callback_defriend},
        })
    end

end



local function cellSizeForTable(table,idx)
	
	if selected_channel == ChatData.CHANNEL_INDX_WORLD then
		-- 固定大小的
		local chatInfo = list_data[idx + 1]
		if chatInfo and chatInfo.subType and 
			 not (chatInfo.subType == ChatData.CHAT_SUB_TYPE_VOICE 
			 or chatInfo.subType == ChatData.CHAT_SUB_TYPE_NORMAL
             or chatInfo.subType == ChatData.CHAT_SUB_TYPE_SYS) then
			
    		 return cell_default_height_world_unionBattle,cell_default_width
		end
	end

    local offset = 0
    if cacheRichInfoList[idx+1] then
        offset = cacheRichInfoList[idx+1][1] - cacheRichInfoList[idx+1][3]
    end
    return cell_default_height+offset,cell_default_width

end

local function tableCellHightlight(table,cell)

    local idx = cell:getIdx()

    local cellLayer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
    local cellWidget = nil
    local btn_cell = nil
    cellWidget = tolua.cast(cellLayer:getWidgetByTag(10),"Layout")


	local chatInfo = list_data[idx + 1]
	
	if chatInfo and chatInfo.subType and
		(chatInfo.subType == ChatData.CHANNEL_WORLD_SUBTYPE_OCCUPY_UNION or 
		 chatInfo.subType == ChatData.CHANNEL_WORLD_SUBTYPE_OCCUPY_NPCCITY) then
		
		 -- TODO 选择效果
		 return
	end

    local main_panel = uiUtil.getConvertChildByName(cellWidget,"main_panel")
    local bg_front = uiUtil.getConvertChildByName(main_panel,"bg_img_front")
    local bg_back = uiUtil.getConvertChildByName(main_panel,"bg_img_back")
    bg_front:setVisible(false)
    bg_back:setVisible(true)
    
 
end

local function tableviewScroll(view)
    local widget = main_layer:getWidgetByTag(999)
    local list_panel = uiUtil.getConvertChildByName(widget,"list_panel")
    local img_drag_flag_up = uiUtil.getConvertChildByName(widget,"img_drag_flag_up")
    local img_drag_flag_down = uiUtil.getConvertChildByName(widget,"img_drag_flag_down")


    if list_tabel_view:getContentOffset().y < 0 then 
        img_drag_flag_down:setVisible(true)
    else
        img_drag_flag_down:setVisible(false)
    end

    if list_tabel_view:getContentOffset().y > -(#list_data * cell_default_height - list_panel:getSize().height) then 
        img_drag_flag_up:setVisible(true)
    else
        img_drag_flag_up:setVisible(false)
    end
end

local function tableCellUnhightlight(table,cell)
    local idx = cell:getIdx()

    local cellLayer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
    local cellWidget = nil
    local btn_cell = nil
    cellWidget = tolua.cast(cellLayer:getWidgetByTag(10),"Layout")


	local chatInfo = list_data[idx + 1]
	
	if chatInfo and chatInfo.subType and
		(chatInfo.subType == ChatData.CHANNEL_WORLD_SUBTYPE_OCCUPY_UNION or 
		 chatInfo.subType == ChatData.CHANNEL_WORLD_SUBTYPE_OCCUPY_NPCCITY) then
		
		 -- TODO 选择效果
		 return
	end
    local main_panel = uiUtil.getConvertChildByName(cellWidget,"main_panel")
    local bg_front = uiUtil.getConvertChildByName(main_panel,"bg_img_front")
    local bg_back = uiUtil.getConvertChildByName(main_panel,"bg_img_back")
    bg_front:setVisible(true)
    bg_back:setVisible(false)
end

local function numberOfCellsInTableView()
    return #list_data
end


local function tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    
    if cell == nil then
        cell = CCTableViewCell:new()
        local cellLayer = TouchGroup:create()
        cellLayer:setTag(1)
        cell:addChild(cellLayer)
		
		local cellWidget = GUIReader:shareReader():widgetFromJsonFile("test/ui_chat_cell.json")

		tolua.cast(cellWidget,"Layout")
		cellLayer:addWidget(cellWidget)
    	cellWidget:setTag(10)
    

	end
	 

    local cellWidget = nil
    local cellLayer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
	
	
	
	
    


    if cellLayer then
        cellWidget = tolua.cast(cellLayer:getWidgetByTag(10),"Layout")
        setCellWidget(idx,cellWidget)
    end
    
    return cell
end

-- 聊天列表初始化
local function initChatListView()
    local widget = main_layer:getWidgetByTag(999)

    local list_panel = uiUtil.getConvertChildByName(widget,"list_panel")
    local img_drag_flag_up = uiUtil.getConvertChildByName(widget,"img_drag_flag_up")
    local img_drag_flag_down = uiUtil.getConvertChildByName(widget,"img_drag_flag_down")
    img_drag_flag_up:setVisible(false)
    img_drag_flag_down:setVisible(false)
    breathAnimUtil.start_scroll_dir_anim(img_drag_flag_up, img_drag_flag_down)
    
    list_tabel_view = CCTableView:create(true,CCSizeMake(list_panel:getSize().width,list_panel:getSize().height))
 	list_panel:addChild(list_tabel_view)
 	list_tabel_view:setDirection(kCCScrollViewDirectionVertical)
 	list_tabel_view:setVerticalFillOrder(kCCTableViewFillTopDown)
	list_tabel_view:ignoreAnchorPointForPosition(false)
	list_tabel_view:setAnchorPoint(cc.p(0.5,0.5))
	list_tabel_view:setPosition(cc.p(list_panel:getSize().width/2,list_panel:getSize().height/2))
	list_tabel_view:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
    list_tabel_view:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
    list_tabel_view:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
    list_tabel_view:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
    list_tabel_view:registerScriptHandler(tableCellHightlight,CCTableView.kTableCellHighLight)
    list_tabel_view:registerScriptHandler(tableCellUnhightlight,CCTableView.kTableCellUnhighLight)
    list_tabel_view:registerScriptHandler(tableviewScroll,CCTableView.kTableViewScroll)
    
    -- list_tabel_view:reloadData()
end




local function changeSendBtnState(isAble,isBright)
    if not main_layer then return end
    local widget = main_layer:getWidgetByTag(999)
    if not widget then return end

    local btn_send = uiUtil.getConvertChildByName(widget,"btn_send")
    local label_send = uiUtil.getConvertChildByName(btn_send,"label_send")
    label_send:setText(languagePack['fasong'])

    if b_is_channel_open then 
        
        if b_is_channel_interval_limit then 
            if i_chanel_interval_left and i_chanel_interval_left > 0 then 
                label_send:setText(i_chanel_interval_left .. languagePack['date_sec'])
            else
                label_send:setText(languagePack['fasong'])
            end
            btn_send:setTouchEnabled(true)
            btn_send:setBright(false)

            btn_record:setTouchEnabled(true)
            btn_record:setBright(false)
        else
            btn_send:setTouchEnabled(isAble)
            btn_send:setBright(isBright)

            btn_record:setTouchEnabled(isAble)
            if not record_class:getInstance() then
                btn_record:setBright(isBright)
            end
        end
    else
        btn_send:setTouchEnabled(true)
        btn_send:setBright(false)

        btn_record:setTouchEnabled(true)
        btn_record:setBright(false)
    end
end


-- 检查频道功能是否开放

function checkOpenState()
    b_is_channel_open,i_chanel_open_renown = ChatData.getChatChannelOpenState(selected_channel)

    if b_is_channel_open then 
        changeSendBtnState(true,true)
    else
        changeSendBtnState(true,false)
    end
end
----- 检查聊天间隔限制
function checkChatInterval()
    if not main_layer then return end
    local widget = main_layer:getWidgetByTag(999) 
    if not widget then return end

    b_is_channel_interval_limit = false
    i_chanel_interval_left = 0

    local ret_can_chat = false

    local intervalSec = ChatData.getNextChatTimestamp(selected_channel) 

    if intervalSec > 0 then 
        intervalSec = intervalSec - userData.getServerTime()
    end
    
    if intervalSec <= 0 then
        changeSendBtnState(true,true)
    else
        b_is_channel_interval_limit = true
        i_chanel_interval_left = intervalSec
        changeSendBtnState(true,false)
    end


end

-- 适配下频道按钮的位置
local function offsetChannelBtnPos()

end

--  各个聊天频道的提示
local function resetChannelBtnState()
    if not main_layer then return end
    local widget = main_layer:getWidgetByTag(999)
    if not widget then return end

    local btn_indx = nil
    local img_flag = nil
    for i = 1,4 do 
        btn_indx = uiUtil.getConvertChildByName(widget,"btn_" .. i)
        btn_indx:setTouchEnabled(true)
        img_flag = uiUtil.getConvertChildByName(btn_indx,"img_flag")
        img_flag:setVisible(false)

        btn_indx:addTouchEventListener(function(sender,eventType)
            if eventType == TOUCH_EVENT_ENDED then
                setViewByChannel(i)
            end
        end)

        if ChatData.getChannelUnreadNum(i) > 0 then 
            img_flag:setVisible(true)
        end
    end

    local btn_join_union = uiUtil.getConvertChildByName(widget,"btn_join_union")
    btn_join_union:setTouchEnabled(true)
    btn_join_union:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then
            sender:setTouchEnabled(false)
            remove_self()
            UnionCreateMainUI.create()
        end
    end)
end

local function initRecord (_fileName )
    if not main_layer then return end
    if _fileName and not arr_record[_fileName] then
        arr_record[_fileName] = {length = nil, translate_str = nil, md5key= nil}
    end
end

-- 检查信息是否完整，完整就发送到服务器
-- 语音聊天{voice_file_name,md5_key,voice_seconds}
local function isMsgComplete ( _fileName )
    if not main_layer then return end
    if _fileName and arr_record[_fileName] and arr_record[_fileName].length 
    and arr_record[_fileName].translate_str and arr_record[_fileName].md5key then
        if selected_channel == ChatData.CHANNEL_INDX_WORLD then
            ChatData.requestChatWorld(arr_record[_fileName].translate_str, ChatData.CHANNEL_WORLD_SUBTYPE_VOICE, {_fileName, arr_record[_fileName].md5key, arr_record[_fileName].length})
        elseif selected_channel == ChatData.CHANNEL_INDX_UNION then
            ChatData.requestChatUnion(arr_record[_fileName].translate_str,{_fileName, arr_record[_fileName].md5key, arr_record[_fileName].length})
        elseif selected_channel == ChatData.CHANNEL_INDX_REGION then 
            ChatData.requestChatRegion(arr_record[_fileName].translate_str,{_fileName, arr_record[_fileName].md5key, arr_record[_fileName].length})
        else
            print(">>>>>>>>>>>>>> unknow what to do")
        end
        arr_record[_fileName] = nil
    end
end

function create(indx)
    if main_layer then return end
    sdkMgr:sharedSkdMgr():setTouchCount(1)

	if not indx then
		if i_lastSelectedIndx then 
			indx = i_lastSelectedIndx
		else
			indx = 1
		end
	end

	--[[
    --同盟＞世界＞本州＞系统
    if not indx then  
        if ChatData.getChannelUnreadNum(ChatData.CHANNEL_INDX_UNION) > 0 then 
            indx = ChatData.CHANNEL_INDX_UNION
        elseif ChatData.getChannelUnreadNum(ChatData.CHANNEL_INDX_WORLD) > 0 then 
            indx = ChatData.CHANNEL_INDX_WORLD
        elseif ChatData.getChannelUnreadNum(ChatData.CHANNEL_INDX_REGION) > 0 then 
            indx = ChatData.CHANNEL_INDX_REGION
        elseif ChatData.getChannelUnreadNum(ChatData.CHANNEL_INDX_SYS) > 0 then 
            indx = ChatData.CHANNEL_INDX_SYS
        else
			if i_lastSelectedIndx then 
				indx = i_lastSelectedIndx
			else
				indx = 1
			end
        end
    end  
	]]

    cacheRichInfoList = {}
    list_data = {}
    cell_height_cache = {}
    arr_record = {}
    local widget = GUIReader:shareReader():widgetFromJsonFile("test/ui_chat_main.json")
    widget:setTag(999)
	widget:setScale(config.getgScale())
	widget:ignoreAnchorPointForPosition(false)
	widget:setAnchorPoint(cc.p(0.5, 0.5))
 --    local posx,posy = 158 * config.getgScale(), config.getWinSize().height - 79 * config.getgScale()
	-- widget:setPosition(cc.p(posx , posy))

    widget:setPosition(cc.p(config.getWinSize().width/2 , config.getWinSize().height/2))

    main_layer = TouchGroup:create()
    main_layer:addWidget(widget)
    uiManager.add_panel_to_layer(main_layer, uiIndexDefine.UI_CHAT_MAIN)

    local close_btn = uiUtil.getConvertChildByName(widget,"close_btn")
    close_btn:setTouchEnabled(true)
    close_btn:addTouchEventListener(function(sender,eventType) 
        if eventType == TOUCH_EVENT_ENDED then
            remove_self()
        end
    end)

    resetChannelBtnState()

    -- 语音的按钮
    btn_record = uiUtil.getConvertChildByName(widget,"Button_record")
    local record_layer = nil
    record_class = VoiceSendUI.new()

    local finger_out_call = function ( )
        list_tabel_view:setTouchEnabled(true)
    end


    -- 上传包完后的回调，返回这个文件的md5值
    local uploadCallback = function (_fileName,md5key )
        -- print(">>>>>>>>>>>>>>>md5key="..md5key.."  filename=".._fileName)
        initRecord(_fileName)
        arr_record[_fileName].md5key = md5key
        isMsgComplete(_fileName)
    end 

    -- 返回翻译的结果
    local translateCallback = function (_fileName,translate_str )
        -- print(">>>>>>>>>>>>>>>translate_str="..translate_str.."  filename=".._fileName)
        initRecord(_fileName)
        arr_record[_fileName].translate_str = translate_str
        isMsgComplete(_fileName)
    end 

    -- 返回录音长度, -1代表这条录音不上传
    local lengthCallback = function ( _fileName,length )
        -- print(">>>>>>>>>>>>>>>length="..length.."  filename=".._fileName)
        if length == -1 then
            return
        end
        initRecord(_fileName)
        arr_record[_fileName].length = length
        isMsgComplete(_fileName)
    end

    btn_record:addTouchEventListener(function (sender,eventType  )
        if not b_is_channel_open then 
            tipsLayer.create(languagePack["chat_openstate_tips"],nil,{math.floor(i_chanel_open_renown/100)})
            return 
        end

        if b_is_channel_interval_limit then 
            tipsLayer.create(languagePack["chat_interval_limit"])
            return
        end


        if selected_channel == ChatData.CHANNEL_INDX_WORLD then 
            if ChatData.getChatFreeCountLeft(selected_channel) < 1 then 
                if userData.getYuanbao() < ChatData.getChatCost(selected_channel) then
                    alertLayer.create(errorTable[2008],nil,function()
                        PayUI.create()
                    end)
                    comAlertConfirm.setBtnTitleText("前往充值","取消")
                    return
                end
            end
        end

        stopRecordHandler()
        if eventType == TOUCH_EVENT_ENDED then
            finger_out_call()
        elseif eventType == TOUCH_EVENT_BEGAN then
            list_tabel_view:setTouchEnabled(false)
        elseif eventType == TOUCH_EVENT_CANCELED then
            finger_out_call()
        end
        record_class:when_btn_eventType(widget,btn_record,sender,eventType)
    end)
    
    record_class:init(widget,btn_record,uploadCallback, translateCallback, lengthCallback)


    -- 游戏精灵入口
    local gamespritePanel = uiUtil.getConvertChildByName(widget,"Panel_huanyihuan_0")
    gamespritePanel:addTouchEventListener(function ( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            GameSpriteMainUI.create()
        end
    end)

    local list_panel = uiUtil.getConvertChildByName(widget,"list_panel")
    list_panel:setBackGroundColorType(LAYOUT_COLOR_NONE)

    --初始化待展示的聊天列表
    local edit_panel = uiUtil.getConvertChildByName(widget,"edit_panel")
    edit_panel:setClippingEnabled(true)
    edit_panel:setBackGroundColorType(LAYOUT_COLOR_NONE)

    local content_panel = uiUtil.getConvertChildByName(edit_panel,"content_panel")
    content_panel:setClippingEnabled(true)
    content_panel:setBackGroundColorType(LAYOUT_COLOR_NONE)
    local label_chatDefault = uiUtil.getConvertChildByName(content_panel,"label_chatDefault")
    label_chatDefault:setColor(ccc3(91,92,96))

    local size_width = edit_panel:getSize().width
	local size_height = edit_panel:getSize().height
    --输入正文
	
    local editBoxSize = CCSizeMake(edit_panel:getContentSize().width*config.getgScale(),edit_panel:getContentSize().height*config.getgScale() )
    local rect = CCRectMake(9,9,2,2)
    textEditbox = CCEditBox:create(editBoxSize, CCScale9Sprite:createWithSpriteFrameName("Enter_the_name_plate.png",rect))
    -- textEditbox:setAlignment(1)
    textEditbox:setFontName(config.getFontName())
    textEditbox:setFontSize(20*config.getgScale())
    textEditbox:setFontColor(ccc3(91,92,96))
    -- textEditbox:setText(languagePack["chat_default"])
    -- textEditbox:setMaxLength(60)
    -- textEditbox:setInputMode(kEditBoxInputModeNumeric)
    widget:addChild(textEditbox)
    textEditbox:setScale(1/config.getgScale())
    textEditbox:setPosition(cc.p(edit_panel:getPositionX(), edit_panel:getPositionY()))
    textEditbox:setAnchorPoint(cc.p(0,0))
    -- textEditbox:setAlignment(2)
    label_chatDefault:setText(languagePack["chat_default"])
    label_chatDefault:setVisible(true)
    

    local function editFinished()
        if StringUtil.isEmptyStr(textEditbox:getText()) then
            resetChatDefault()
        else
            label_chatDefault:setVisible(true)
            -- changeSendBtnState(true,true)
            label_chatDefault:setText(textEditbox:getText())
            textEditbox:setText(" ")
            if (label_chatDefault:getContentSize().width) >= content_panel:getContentSize().width then 
                label_chatDefault:setPositionX(content_panel:getContentSize().width)
                label_chatDefault:setAnchorPoint(cc.p(1,0.5))
            else
                label_chatDefault:setPositionX(0)
                label_chatDefault:setAnchorPoint(cc.p(0,0.5))
            end
        end
    end

    local function checkColor()
        local str = StringUtil.DelS(textEditbox:getText())
        if not str or str ~= "" or str == languagePack["chat_default"] then
            textEditbox:setFontColor(ccc3(255,243,195))
            label_chatDefault:setColor(ccc3(255,243,195))
        else
            textEditbox:setFontColor(ccc3(91,92,96))
            label_chatDefault:setColor(ccc3(91,92,96))
        end 
    end

    textEditbox:registerScriptEditBoxHandler(function (strEventName,pSender)
            
        if strEventName == "began" then
            if StringUtil.DelS(label_chatDefault:getStringValue()) ~= languagePack["chat_default"] then
                textEditbox:setText(label_chatDefault:getStringValue())
            end
            label_chatDefault:setVisible(false)

        elseif strEventName == "ended" then
            -- editFinished()
        elseif strEventName == "return" then
            editFinished()
        elseif strEventName == "changed" then
            -- ignore
            checkColor()                
        end
    end)
    

    
    
    
    


    local btn_send = uiUtil.getConvertChildByName(widget,"btn_send")
    changeSendBtnState(true,true)

    btn_send:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            if not b_is_channel_open then 
                tipsLayer.create(languagePack["chat_openstate_tips"],nil,{math.floor(i_chanel_open_renown/100)})
                return 
            end

            if b_is_channel_interval_limit then 
                tipsLayer.create(languagePack["chat_interval_limit"])
                return
            end


            if selected_channel == ChatData.CHANNEL_INDX_WORLD then 
                if ChatData.getChatFreeCountLeft(selected_channel) < 1 then 
                    if userData.getYuanbao() < ChatData.getChatCost(selected_channel) then
                        alertLayer.create(errorTable[2008],nil,function()
                            PayUI.create()
                        end)
                        comAlertConfirm.setBtnTitleText("前往充值","取消")
                        return
                    end
                end
            end
            local str = nil
            if configBeforeLoad.getPlatFormInfo() ~= kTargetWindows then 
                str = label_chatDefault:getStringValue()
            else
                str = textEditbox:getText()
            end
            str = StringUtil.DelS(str)

            if not str  or str == "" or 
                str == languagePack["chat_default"] then 
                resetChatDefault()
                return 
            end

            if StringUtil.utfstrlen(str) > 60 then 
                tipsLayer.create(languagePack["chat_default_error"])
                return 
            end
            
            --TODO 敏感词处理
            if selected_channel == ChatData.CHANNEL_INDX_WORLD then
                ChatData.requestChatWorld(str)
            elseif selected_channel == ChatData.CHANNEL_INDX_UNION then
                ChatData.requestChatUnion(str)
            elseif selected_channel == ChatData.CHANNEL_INDX_REGION then 
                ChatData.requestChatRegion(str)
            else
                print(">>>>>>>>>>>>>> unknow what to do")
            end
            resetChatDefault()
        end

    end)

    resetChatDefault()

    initChatListView()

    setViewByChannel(indx)
    uiManager.showConfigEffect(uiIndexDefine.UI_CHAT_MAIN,main_layer)


    activeSchedulerHandler()
end

function show()
    if main_layer then return end
    ChatData.requestChatHistory()
end

function getInstance()
    return main_layer
end
