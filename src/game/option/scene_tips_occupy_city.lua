module("SceneTipsOccupyCity",package.seeall)

--- 占领城池后的提示
--- 类名  SceneTipsOccupyCity
--- json名 gongcheng_shunli.json
--- 配置ID  UI_SCENE_TIPS_OCCUPY_CITY



local m_pMainLayer = nil
local m_tDetailInfo = nil

local function do_remove_self()
	if m_pMainLayer then
		m_pMainLayer:getParent():setOpacity(150)
		m_pMainLayer:removeFromParentAndCleanup(true)
		m_pMainLayer = nil
		m_tDetailInfo = nil
		uiManager.remove_self_panel(uiIndexDefine.UI_SCENE_TIPS_OCCUPY_CITY)
	end
end


function remove_self()
	do_remove_self()
	--uiManager.hideConfigEffect(uiIndexDefine.UI_SCENE_TIPS_OCCUPY_CITY, m_pMainLayer, do_remove_self, 999)	
end


function dealwithTouchEvent(x,y)
	if not m_pMainLayer then return false end
	local widget = m_pMainLayer:getWidgetByTag(999)
	if not widget then return false end

	local panel_effect = uiUtil.getConvertChildByName(widget,"panel_effect")
	if panel_effect:isVisible() then
		return false
	else
		if widget:hitTest(cc.p(x,y)) then
			return false
		else
			remove_self()
			return true
		end
	end
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


local function showDetail()
	if not m_pMainLayer then return end
	local widget = m_pMainLayer:getWidgetByTag(999)
	if not widget then return false end
	local img_content = uiUtil.getConvertChildByName(widget,"img_content")
	local panel_effect = uiUtil.getConvertChildByName(widget,"panel_effect")

	panel_effect:setVisible(false)

	img_content:setVisible(true)

	local space = 1
    local _richText = RichText:create()
    _richText:setVerticalSpace(space)
    _richText:setAnchorPoint(cc.p(0.5,0.5))
    _richText:ignoreContentAdaptWithSize(true)
    _richText:setSize(CCSizeMake(img_content:getSize().width, img_content:getSize().height))
    img_content:addChild(_richText)
    _richText:setPosition(cc.p(img_content:getSize().width/2,img_content:getSize().height/2))
    _richText:setZOrder(999)
    
    -- TODOTK 中文收集
    local rich_str = "#【同盟】& # @占领@ ^【&】^ ^&^ ^Lv.&^"
    local arg = {}
    table.insert(arg,userData.getUnion_name())
    if m_tDetailInfo then
	    if m_tDetailInfo[1] == 39 then
	    	table.insert(arg,languagePack["guodu"])
	    elseif m_tDetailInfo[1] == 40 then
	    	table.insert(arg,languagePack["zhoufu"])
	    elseif m_tDetailInfo[1] == 36 then
	    	table.insert(arg,languagePack["guanqia"])
	    else
	    	table.insert(arg,languagePack["chengchi"])
	    end
	else
		table.insert(arg,languagePack["chengchi"])
	end
	if m_tDetailInfo then
		local str_name,_lv = landData.get_city_name_lv_by_coordinate(m_tDetailInfo[2])
		table.insert(arg,str_name)
	else
		table.insert(arg,"test")
	end
	if m_tDetailInfo then
		table.insert(arg,getNpcCityLevel(m_tDetailInfo[2]))
	else
		table.insert(arg,1)
	end
    local index = 1
    local tempStr = string.gsub(rich_str, "&", function (n)
        local temp = arg[index]
        index = index + 1
        return temp or "&"
    end)

    local tStr = config.richText_split(tempStr,{"#","@","^","~"})
    local re1 = nil
    for i,v in ipairs(tStr) do
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
    _richText:formatText()
end

local function animationCallFunc(armatureNode, eventType, name)
	if eventType == 1 or eventType == 2 then
		armatureNode:removeFromParentAndCleanup(true)
		CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("Export/xinshou/gongcheng_texiao.ExportJson")
		m_pMainLayer:getParent():setOpacity(0)
		showDetail()
    end
end

local function showEffect()
	if not m_pMainLayer then return end
	local widget = m_pMainLayer:getWidgetByTag(999)
	if not widget then return false end
	local img_content = uiUtil.getConvertChildByName(widget,"img_content")
	local panel_effect = uiUtil.getConvertChildByName(widget,"panel_effect")

	img_content:setTouchEnabled(false)
	img_content:setVisible(false)

	panel_effect:setVisible(true)
	panel_effect:setBackGroundColorType(LAYOUT_COLOR_NONE)
	
	
	CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/gongcheng_texiao.ExportJson")
	local armature = CCArmature:create("gongcheng_texiao")
	armature:getAnimation():playWithIndex(0)
	armature:ignoreAnchorPointForPosition(false)
	armature:setAnchorPoint(cc.p(0.5,0.5))
	panel_effect:addChild(armature)

    armature:setPosition(cc.p(panel_effect:getContentSize().width/2, panel_effect:getContentSize().height/2))
    armature:getAnimation():setMovementEventCallFunc(animationCallFunc)

end

function create(detailInfo)
	if m_pMainLayer then return end
	m_tDetailInfo = detailInfo
	local widget = GUIReader:shareReader():widgetFromJsonFile("test/gongcheng_shunli.json")
    widget:setTag(999)
	widget:setScale(config.getgScale())
	widget:ignoreAnchorPointForPosition(false)
	widget:setAnchorPoint(cc.p(0.5, 0.5))
    widget:setPosition(cc.p(config.getWinSize().width/2 , config.getWinSize().height/2))

    m_pMainLayer = TouchGroup:create()
    m_pMainLayer:addWidget(widget)
    uiManager.add_panel_to_layer(m_pMainLayer, uiIndexDefine.UI_SCENE_TIPS_OCCUPY_CITY)
	

	local img_content = uiUtil.getConvertChildByName(widget,"img_content")
	local panel_effect = uiUtil.getConvertChildByName(widget,"panel_effect")
	img_content:setVisible(false)
	panel_effect:setVisible(false)
	
	
	uiManager.showConfigEffect(uiIndexDefine.UI_SCENE_TIPS_OCCUPY_CITY,m_pMainLayer,function()
		showEffect()		
	end)
end
