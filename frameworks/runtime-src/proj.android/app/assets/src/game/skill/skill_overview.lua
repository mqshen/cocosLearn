module("SkillOverview", package.seeall)

require("game/skill/skill_data_model")

-- 技能列表UI
-- 类名 ：  SkillOverview
-- json名：  jinengxiangqing_1.json
-- 配置ID:	UI_SKILL_OVERVIEW

SkillOverview.VIEW_TYPE_SKILL = 1
SkillOverview.VIEW_TYPE_HERO_LERAN_SKILL = 2
local skillItemHelper = require("game/skill/skill_item_helper")

local NUM_PER_LINE = 8

local m_pMainLayer = nil
local m_backPanel = nil
local m_tUserSkillInfo = nil
local m_tUserSkillIdList = nil

local m_pUserSkillTBV = nil

local m_tSkillItemProgressBg = nil


local m_mainCardUid = nil -- 如果不为空 表明当前属于从武将卡界面跳转进来的 目前只有武将技能学习
local m_iSkillIndx = nil

local m_iTotalCellCount = nil  -- 真正创建的行数

local m_bIsLockTouch = nil

local m_iViewType = nil

local cell_size_w = nil
local cell_size_h = nil

local cur_created_skill_item_nums = nil
local cur_user_skill_num = nil
local cur_sys_skill_num = nil

local last_offset_y = 0
local is_scrolling = nil

local m_iNonForcedGuideId = nil
local function do_remove_self()
	if m_pMainLayer then 
		if m_backPanel then
			m_backPanel:remove()
			m_backPanel = nil
		end

		m_pMainLayer:removeFromParentAndCleanup(true)
        m_pMainLayer = nil
        uiManager.remove_self_panel(uiIndexDefine.UI_SKILL_OVERVIEW)


        m_tUserSkillInfo = nil
        m_tUserSkillIdList = nil
        m_pUserSkillTBV = nil
        m_iTotalCellCount = nil
        m_mainCardUid = nil
        m_iSkillIndx = nil
        m_bIsLockTouch = nil
        m_iViewType = nil
        cell_size_h = nil
        cell_size_w = nil

        -- UIUpdateManager.remove_prop_update(dbTableDesList.user_skill.name, dataChangeType.update, SkillOverview.reload_data)
        -- UIUpdateManager.remove_prop_update(dbTableDesList.user_skill.name, dataChangeType.add, SkillOverview.reload_data)
        -- UIUpdateManager.remove_prop_update(dbTableDesList.user_skill.name, dataChangeType.remove, SkillOverview.reload_data)

        UIUpdateManager.remove_prop_update(dbTableDesList.user_res.name, dataChangeType.update, SkillOverview.reload_data)
        UIUpdateManager.remove_prop_update(dbTableDesList.user_res.name, dataChangeType.add, SkillOverview.reload_data)
        UIUpdateManager.remove_prop_update(dbTableDesList.user_res.name, dataChangeType.remove, SkillOverview.reload_data)
        cur_created_skill_item_nums = nil
        cur_user_skill_num = nil
        cur_sys_skill_num = nil

        is_scrolling = nil
        last_offset_y = 0

        m_iNonForcedGuideId = nil

        --[[
        if cardOverviewManager then
            if uiManager.is_most_above_layer(uiIndexDefine.CARD_OVERVIEW_UI) then
                cardOverviewManager.update_tb_state(true)
            end
        end

        if cardPacketManager then
            if uiManager.is_most_above_layer(uiIndexDefine.CARD_PACKET_UI) then
                cardPacketManager.update_tb_state(true)
            end
        end
        --]]
        
	end
end

function activeNonForceGuide(guide_id)
    m_iNonForcedGuideId = guide_id
end

function remove_self(closeEffect)
    if m_pMainLayer then 
        if m_tSkillItemProgressBg then 
            for k,v in ipairs(m_tSkillItemProgressBg) do 
                v:removeFromParentAndCleanup(true)
            end
            m_tSkillItemProgressBg = nil
        end
    end

	if m_backPanel then
        if closeEffect then 
            do_remove_self()
        else
    	   uiManager.hideConfigEffect(uiIndexDefine.UI_SKILL_OVERVIEW, m_pMainLayer, do_remove_self, 999, {m_backPanel:getMainWidget()})
        end
    end
end


function dealwithTouchEvent(x,y)
	return false
end








local function getUserSkillNum()
    if not m_tUserSkillInfo then return 0 end
    return #m_tUserSkillInfo
end

local function numberOfCellsInTableView(table)
    return math.ceil( getUserSkillNum()/ NUM_PER_LINE )
end




local type_sort = {2,3,1,4}
type_sort[2] = 1
type_sort[3] = 2
type_sort[1] = 3
type_sort[4] = 4
--[[
技能的排序规则：类别（指挥→战法→谋略→追击）→堆叠上限（由小到大）→ID（由小到大）
]]
local function sort_ruler(skillInfoA,skillInfoB)

    local flag_isequal_type = false
    local flag_isequal_research_num = false
    local flag_isequal_id = false

    local ret_value = false


    
    -- 技能类型排序
    local skill_type_a = Tb_cfg_skill[skillInfoA.skill_id].skill_type
    local skill_type_b = Tb_cfg_skill[skillInfoB.skill_id].skill_type
    skill_type_a = type_sort[skill_type_a]
    skill_type_b = type_sort[skill_type_b]
    if skill_type_a == skill_type_b then 
        flag_isequal_type = true
    else
        ret_value = skill_type_a < skill_type_b
    end
    

    -- 技能可研究数排序
    if flag_isequal_type then 
        local research_num_a = Tb_cfg_skill_research[skillInfoA.skill_id].research_num
        local research_num_b = Tb_cfg_skill_research[skillInfoB.skill_id].research_num
        if research_num_a == research_num_b then 
            flag_isequal_research_num = true
        else
            ret_value = research_num_a > research_num_b
        end
    end


    -- 技能ID大小排序
    if flag_isequal_research_num then 
        if skillInfoA.skill_id == skillInfoB.skill_id then 
            flag_isequal_id = true
        else
            ret_value = skillInfoA.skill_id > skillInfoB.skill_id
        end
    end

    return ret_value
end


local function doClickOnSkillItem(sender, skillInfoData)
    local sid = nil
    local skill_id = nil
    if skillInfoData then 
        sid = skillInfoData.sid
        skill_id = skillInfoData.skill_id
    end
    
    
    if m_mainCardUid then 
        -- 有武将卡 那就是武将进来学习的
        -- TODOTK 提示配置
        local skillInfo = SkillDataModel.getUserSkillInfoById(skill_id)
        -- 兵种不符
        local img_illegal_soldier = uiUtil.getConvertChildByName(sender,"img_illegal_soldier")
        -- 阵营不符
        local img_illegal_country = uiUtil.getConvertChildByName(sender,"img_illegal_country")
        -- 已学习
        local img_illegal_learned = uiUtil.getConvertChildByName(sender,"img_illegal_learned")
        if img_illegal_soldier:isVisible() then 
            tipsLayer.create("兵种不符")
        elseif img_illegal_country:isVisible() then 
            tipsLayer.create("阵营不符")
        elseif img_illegal_learned:isVisible() then   
            tipsLayer.create("已学习")
        else
            if skillInfo.learn_count_retain <= 0 then 
                
                tipsLayer.create("可学习数不足")
            else
                -- 学习
                SkillDetail.create(SkillDetail.VIEW_TYPE_LEARN,nil,skill_id,false,m_mainCardUid,m_iSkillIndx,false,m_tUserSkillIdList)
            end
        end
    else
        -- 研究进度
        require("game/skill/skill_detail")
        SkillDetail.create(SkillDetail.VIEW_TYPE_STUDY,nil,skill_id,false,nil,nil,false,m_tUserSkillIdList)

        -- require("game/skill/skill_operate")
        -- SkillOperate.create(SkillOperate.OP_TYPE_SKILL_STUDY_PROGRESS)

    end
        
    
end
local function clickOnSkillItem(sender,eventType,skillInfoData)
    if eventType == TOUCH_EVENT_BEGAN then 
        is_scrolling = false
        skillItemHelper.setSelectedState(sender,true)
        return true
    elseif eventType == TOUCH_EVENT_MOVED then 
        local pt = sender:getTouchMovePos()
        tolua.cast(pt, "CCPoint") 
        if not sender:hitTest(pt) then 
            skillItemHelper.setSelectedState(sender,false)
        end
    elseif eventType == TOUCH_EVENT_ENDED then
        if is_scrolling then 
            skillItemHelper.setSelectedState(sender,false)
            return 
        end 
        is_scrolling = false
        skillItemHelper.setSelectedState(sender,false)
        doClickOnSkillItem(sender,skillInfoData)
    end


    

end


local function clearAllSkillItemsSelectedState()
    if not m_pMainLayer then return end

    local mainWidget = m_pMainLayer:getWidgetByTag(999)
    if not mainWidget then return end
    local scrollView = uiUtil.getConvertChildByName(mainWidget,"scrollView")
    local main_panel = uiUtil.getConvertChildByName(scrollView,"main_panel")
    for i = 1,cur_created_skill_item_nums do 
        skillItem = uiUtil.getConvertChildByName(main_panel,"skill_item_" .. i)
        if skillItem then 
            skillItemHelper.setSelectedState(skillItem,false)
        end
    end

end

local function reloadSkillListDetails()
    if not m_pMainLayer then return end
    local mainWidget = m_pMainLayer:getWidgetByTag(999)
    if not mainWidget then return end

    local viewType = nil
    if m_mainCardUid and m_mainCardUid ~= 0 then 
        viewType = skillItemHelper.LAYOUT_TYPE_SKILL_OVER_VIEW_CARD_LEARN
    else
        viewType = skillItemHelper.LAYOUT_TYPE_SKILL_OVER_VIEW
    end
    local scrollView = uiUtil.getConvertChildByName(mainWidget,"scrollView")
    local main_panel = uiUtil.getConvertChildByName(scrollView,"main_panel")
    local skillItem = nil
    local progressTimerBg = nil
    
    for i = 1,cur_user_skill_num + cur_sys_skill_num do 
        skillItem = uiUtil.getConvertChildByName(main_panel,"skill_item_" .. i)
        
        local skillInfoData = m_tUserSkillInfo[i]
        progressTimerBg = m_tSkillItemProgressBg[i]
        if skillItem then 
            skillItemHelper.loadSkillInfo(skillItem,progressTimerBg,skillInfoData.skill_id,viewType,nil,m_mainCardUid)
            skillItemHelper.resetProgressTimerBg(skillItem,progressTimerBg)
            skillItem:setEnabled(true)
            skillItem:setTouchEnabled(true)
            skillItemHelper.setSelectedState(skillItem,false)
            skillItem:addTouchEventListener(function(sender,eventType)
                clickOnSkillItem(sender,eventType,skillInfoData)
            end)
        end

    end
    

    -- 第一个位置 拆解战法按钮
    local item_study_new = uiUtil.getConvertChildByName(main_panel,"item_study_new")
    local label_sk_num = uiUtil.getConvertChildByName(item_study_new,"label_sk_num")
    label_sk_num:setText( (cur_user_skill_num + cur_sys_skill_num ) .. "/" .. SKILL_NUM_MAX)
    -- 第二个位置  转换战法经验值
    local item_transfer = uiUtil.getConvertChildByName(main_panel,"item_transfer")
    local label_skvalue_num = uiUtil.getConvertChildByName(item_transfer,"label_skvalue_num")
    label_skvalue_num:setText(SkillDataModel.getUserSkillValue())
   
end

local function handleJump2StudNewSkillDirectlly()
	do_remove_self()
	
	if SkillDetail then
		SkillDetail.remove_self(true)
	end
	

	if userCardViewer then
		userCardViewer.remove_self(true)
	end

	if basicCardViewer then 
		basicCardViewer.remove_self(true)
	end

	if cardOverviewManager then 
		cardOverviewManager.remove_self(true)
	end
	
	require("game/skill/skill_operate")
    SkillOperate.create(SkillOperate.OP_TYPE_STUDY_SKILL)
end

local function handleOpenStudyNewSkill()
    require("game/skill/skill_operate")
    SkillOperate.create(SkillOperate.OP_TYPE_STUDY_SKILL)
end
local function handleOpenSkillvalueTransfer()
    require("game/skill/skill_operate")
    SkillOperate.create(SkillOperate.OP_TYPE_TRANSFER)
end
local function autoLayoutView()
    if not m_pMainLayer then return end

    local mainWidget = m_pMainLayer:getWidgetByTag(999)
    if not mainWidget then return end
    local up_img = uiUtil.getConvertChildByName(mainWidget,"up_img")
    local down_img = uiUtil.getConvertChildByName(mainWidget,"down_img")
    breathAnimUtil.start_scroll_dir_anim(up_img, down_img)
    local scrollView = uiUtil.getConvertChildByName(mainWidget,"scrollView")
    local main_panel = uiUtil.getConvertChildByName(scrollView,"main_panel")
    local img_line_split = uiUtil.getConvertChildByName(main_panel,"img_line_split")
    img_line_split:setVisible(false)

    local begin_posx = 0
    local posx_offset = -20
    local posx = begin_posx 
    local posy = main_panel:getContentSize().height

    -- 第一个位置 拆解战法按钮
    local item_study_new = uiUtil.getConvertChildByName(main_panel,"item_study_new")
    local btn_study = uiUtil.getConvertChildByName(item_study_new,"btn_study")
    -- 第二个位置  转换战法经验值
    local item_transfer = uiUtil.getConvertChildByName(main_panel,"item_transfer")
    local btn_transfer = uiUtil.getConvertChildByName(item_transfer,"btn_transfer")
    if m_iViewType == SkillOverview.VIEW_TYPE_SKILL then 
        item_study_new:setEnabled(true)
        item_transfer:setEnabled(true)
        btn_study:setTouchEnabled(true)
        btn_transfer:setTouchEnabled(true)
    else
        item_study_new:setEnabled(false)
        item_transfer:setEnabled(false)
        btn_study:setTouchEnabled(false)
        btn_transfer:setTouchEnabled(false)
    end

    item_transfer:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then
            handleOpenSkillvalueTransfer()
        end
    end)
    btn_transfer:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then
            handleOpenSkillvalueTransfer()
        end
    end)

    item_study_new:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then
            handleOpenStudyNewSkill()
        end
    end)
    btn_study:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then
            handleOpenStudyNewSkill()
        end
    end)



    local cache_line_nums = 0
    if item_study_new:isEnabled() then 
        item_study_new:setPosition(cc.p(posx,posy - item_study_new:getContentSize().height))
        posx = posx + item_study_new:getContentSize().width + posx_offset
        cache_line_nums =cache_line_nums + 1
    end

    if item_transfer:isEnabled() then 
        item_transfer:setPosition(cc.p(posx,posy - item_transfer:getContentSize().height))
        posx = posx + item_transfer:getContentSize().width + posx_offset
        cache_line_nums = cache_line_nums + 1
    end

    local skillItem = nil
    local flag_next_line = true
    for i = 1,cur_user_skill_num do 
        skillItem = uiUtil.getConvertChildByName(main_panel,"skill_item_" .. i)
        if (cache_line_nums > 0) and ((cache_line_nums % NUM_PER_LINE) == 0) then 
            posx = begin_posx
            posy = posy - item_transfer:getContentSize().height
        end
        if skillItem then 
            skillItem:setPosition(cc.p(posx,posy - skillItem:getContentSize().height))
            posx = posx + skillItem:getContentSize().width + posx_offset
            cache_line_nums = cache_line_nums + 1
        end
        
    end

    if not item_transfer:isEnabled()  and not item_study_new:isEnabled() and cur_user_skill_num < 1 then 
        flag_next_line = false
    end

    posx = begin_posx 
    if flag_next_line  then 

        posy = posy - item_transfer:getContentSize().height
    end


    -- 万恶的分割线
    if cur_sys_skill_num > 0 then 
        img_line_split:setVisible(true)
        img_line_split:setPositionY(posy)
        posy = posy - img_line_split:getContentSize().height
    end



    for i = cur_user_skill_num + 1, cur_user_skill_num + cur_sys_skill_num do 
        skillItem = uiUtil.getConvertChildByName(main_panel,"skill_item_" .. i)
        if (i >= cur_user_skill_num + NUM_PER_LINE) and ((cache_line_nums % NUM_PER_LINE) == 0) then 
            posx = begin_posx
            posy = posy - skillItem:getContentSize().height
        end
        if skillItem then 
            skillItem:setPosition(cc.p(posx,posy - skillItem:getContentSize().height))
            posx = posx + skillItem:getContentSize().width + posx_offset
            cache_line_nums = cache_line_nums + 1
        end
    end


    

    if cur_sys_skill_num > 0 then 
        posy = posy - skillItem:getContentSize().height
    end
    ------ 非强制引导2030 的引导panel

    local guide_panel_2030 = uiUtil.getConvertChildByName(main_panel,"guide_panel_2030")
    if not guide_panel_2030 then 
        guide_panel_2030 = Layout:create()
        main_panel:addChild(guide_panel_2030)
        guide_panel_2030:setName("guide_panel_2030")
        guide_panel_2030:setPosition(cc.p(10,posy))
        guide_panel_2030:setContentSize(CCSizeMake(420,150))
        guide_panel_2030:setSize(CCSizeMake(520,150))
        -- guide_panel_2030:setBackGroundColorType(LAYOUT_COLOR_SOLID)
    end


    last_offset_y = 0
    is_scrolling = false
    local function ScrollViewEvent(sender, eventType) 
        
        local last_scroll_state = is_scrolling
        if math.abs(sender:getInnerContainer():getPositionY() - last_offset_y) > 5 then 
            is_scrolling = true
        end

        if is_scrolling and not last_scroll_state then 
            clearAllSkillItemsSelectedState()
        end
        last_offset_y = sender:getInnerContainer():getPositionY()
        if eventType == SCROLLVIEW_EVENT_SCROLL_TO_TOP then 
            up_img:setVisible(false)
            down_img:setVisible(true)
        elseif eventType == SCROLLVIEW_EVENT_SCROLL_TO_BOTTOM then 
            up_img:setVisible(true)
            down_img:setVisible(false)
        elseif eventType == SCROLLVIEW_EVENT_SCROLLING then
            if scrollView:getInnerContainer():getPositionY() > (-main_panel:getPositionY()) and 
                scrollView:getInnerContainer():getPositionY() < 0  then 
                down_img:setVisible(true)
                up_img:setVisible(true)
            end
        end
    end 
    scrollView:setTouchEnabled(true)
    scrollView:addEventListenerScrollView(ScrollViewEvent)


    local twidth = scrollView:getSize().width
    if  posy >= 0 then 
        scrollView:setInnerContainerSize(CCSizeMake(twidth,main_panel:getSize().height))
        main_panel:setPositionY(0)
        -- scrollView:setTouchEnabled(false)
        up_img:setVisible(false)
        down_img:setVisible(false)
    else
        scrollView:setInnerContainerSize(CCSizeMake(twidth,main_panel:getSize().height - posy))
        main_panel:setPositionY(-posy)
        -- scrollView:setTouchEnabled(true)

    end





    local btn_jump2Study = uiUtil.getConvertChildByName(mainWidget,"btn_jump2Study")
    btn_jump2Study:setVisible(false)
    btn_jump2Study:setTouchEnabled(false)

    if m_iViewType == SkillOverview.VIEW_TYPE_HERO_LERAN_SKILL then
        if (not m_tUserSkillInfo ) or (#m_tUserSkillInfo == 0) then 
            btn_jump2Study:setVisible(true)
            btn_jump2Study:setTouchEnabled(true)
            btn_jump2Study:addTouchEventListener(function(sender,eventType)
                if eventType == TOUCH_EVENT_ENDED then 
					handleJump2StudNewSkillDirectlly()
                end
            end)
        end
    end

end
function reload_data()
    if m_bIsLockTouch then return end

    if not m_pMainLayer then return end
    local mainWidget = m_pMainLayer:getWidgetByTag(999)
    if not mainWidget then return end


    local scrollView = uiUtil.getConvertChildByName(mainWidget,"scrollView")
    local main_panel = uiUtil.getConvertChildByName(scrollView,"main_panel")

    local skillItem = nil
    for i = 1,cur_created_skill_item_nums do 
        skillItem = uiUtil.getConvertChildByName(main_panel,"skill_item_" .. i)
        if skillItem then 
            skillItem:setEnabled(false)
        end
    end

    cur_user_skill_num = 0
    cur_sys_skill_num = 0

    -- 第一个位置 拆解战法按钮
    local item_study_new = uiUtil.getConvertChildByName(main_panel,"item_study_new")

    -- 第二个位置  转换战法经验值
    local item_transfer = uiUtil.getConvertChildByName(main_panel,"item_transfer")

    

    m_tUserSkillInfo = {}
    m_tUserSkillIdList = {}

    local progressTimerBg = nil

    -- 玩家自主获取的技能列表
    local sk_cur_indx = 0

    
    local tmpVolatile = nil
    tmpVolatile = SkillDataModel.getSkillListVolatile()
    table.sort(tmpVolatile, sort_ruler)

    for i = 1,#tmpVolatile do 
        -- 如果是学习界面 过滤掉未研究成功的选项
        if (m_mainCardUid and m_mainCardUid ~= 0  and tmpVolatile[i].study_progress >= 100) or (not m_mainCardUid)  then 

            sk_cur_indx = sk_cur_indx + 1
            skillItem = uiUtil.getConvertChildByName(main_panel,"skill_item_" .. sk_cur_indx)
            if not skillItem then 
                skillItem,progressTimerBg = skillItemHelper.createWidgetItem(true)
                main_panel:addChild(skillItem)
                skillItem:setName("skill_item_" .. sk_cur_indx)
                cur_created_skill_item_nums = cur_created_skill_item_nums + 1
                m_tSkillItemProgressBg[cur_created_skill_item_nums] = progressTimerBg
            end
            cur_user_skill_num = cur_user_skill_num + 1

            table.insert(m_tUserSkillInfo,tmpVolatile[i])
            table.insert(m_tUserSkillIdList,tmpVolatile[i].skill_id)
        end

    end


    -- 系统赠送的技能列表
    local tmpImmutable = nil
    tmpImmutable = SkillDataModel.getSkillListImmutable()
    table.sort(tmpImmutable, sort_ruler)
    for i = 1,#tmpImmutable do 
        -- 如果是学习界面 过滤掉未研究成功的选项
        if (m_mainCardUid and m_mainCardUid ~= 0  and tmpImmutable[i].study_progress >= 100) or (not m_mainCardUid)  then 

            sk_cur_indx = sk_cur_indx + 1
            skillItem = uiUtil.getConvertChildByName(main_panel,"skill_item_" .. sk_cur_indx)
            if not skillItem then 
                skillItem,progressTimerBg = skillItemHelper.createWidgetItem(true)
                main_panel:addChild(skillItem)
                skillItem:setName("skill_item_" .. sk_cur_indx)
                cur_created_skill_item_nums = cur_created_skill_item_nums + 1
                m_tSkillItemProgressBg[cur_created_skill_item_nums] = progressTimerBg
            end
            cur_sys_skill_num = cur_sys_skill_num + 1
            table.insert(m_tUserSkillInfo,tmpImmutable[i])
            table.insert(m_tUserSkillIdList,tmpImmutable[i].skill_id)
        end
    end

    autoLayoutView()
    
    reloadSkillListDetails()

    

end


function updateTouchEnable(isAble)
    -- 废弃
end


-- 获取第一个完成度未达到100 的技能 widget 位置
local function getFirstUnFinishedProgressFullySkillItem()
    if not m_pMainLayer then return nil end
    local mainWidget = m_pMainLayer:getWidgetByTag(999)

    if not m_tUserSkillInfo then return nil end
    local skillInfoData = nil
    for i = 1,#m_tUserSkillInfo do 
        skillInfoData = m_tUserSkillInfo[i]
        if skillInfoData.skill_type ~= 0 and skillInfoData.study_progress < 100 then 
            local scrollView = uiUtil.getConvertChildByName(mainWidget,"scrollView")
            local main_panel = uiUtil.getConvertChildByName(scrollView,"main_panel")
            return uiUtil.getConvertChildByName(main_panel,"skill_item_" .. i)
        end
    end
    return nil
end




-- 目前这个UI只有两个视图样式 
-- 带mainCardUid 时 是技能学习
-- 不带 mainCardUid时 是技能库总览
function create( mainCardUid,skillIndx )
    if m_pMainLayer then return end

    --[[
    if cardOverviewManager then
        cardOverviewManager.update_tb_state(false)
    end

    if cardPacketManager then
        cardPacketManager.update_tb_state(false)
    end
    --]]

    SkillDataModel.create()
    require("game/skill/skill_detail")

    if mainCardUid and mainCardUid ~= 0 then 
        m_iViewType = SkillOverview.VIEW_TYPE_HERO_LERAN_SKILL
    else
        m_iViewType = SkillOverview.VIEW_TYPE_SKILL
    end

    -- TODOTK 中文收集
    local titleName = ""
    if mainCardUid and mainCardUid ~= 0 then 
        titleName = "学习战法"
    else
        titleName = "战法"
    end

    m_bIsLockTouch = false

    m_mainCardUid = mainCardUid
    m_iSkillIndx = skillIndx
    local mainWidget = GUIReader:shareReader():widgetFromJsonFile("test/jinengxiangqing_1.json")
    mainWidget:setTag(999)
    mainWidget:setTouchEnabled(true)
    m_backPanel = UIBackPanel.new()
    local all_widget = m_backPanel:create(mainWidget, remove_self, titleName)
    m_pMainLayer = TouchGroup:create()
    m_pMainLayer:addWidget(all_widget)

    
    


    uiManager.add_panel_to_layer(m_pMainLayer, uiIndexDefine.UI_SKILL_OVERVIEW,999)
    uiManager.showConfigEffect(uiIndexDefine.UI_SKILL_OVERVIEW, m_pMainLayer, nil, 999, {all_widget})


    
    cur_created_skill_item_nums = 0
    m_tSkillItemProgressBg = {}
    reload_data()

    -- UIUpdateManager.add_prop_update(dbTableDesList.user_skill.name, dataChangeType.update, SkillOverview.reload_data)
    -- UIUpdateManager.add_prop_update(dbTableDesList.user_skill.name, dataChangeType.add, SkillOverview.reload_data)
    -- UIUpdateManager.add_prop_update(dbTableDesList.user_skill.name, dataChangeType.remove, SkillOverview.reload_data)

    UIUpdateManager.add_prop_update(dbTableDesList.user_res.name, dataChangeType.update, SkillOverview.reload_data)
    UIUpdateManager.add_prop_update(dbTableDesList.user_res.name, dataChangeType.add, SkillOverview.reload_data)
    UIUpdateManager.add_prop_update(dbTableDesList.user_res.name, dataChangeType.remove, SkillOverview.reload_data)


    if m_iNonForcedGuideId == com_guide_id_list.CONST_GUIDE_2025 then 
        comGuideManager.set_show_guide(com_guide_id_list.CONST_GUIDE_2025)
        if SkillOperate then 
            SkillOperate.activeNonForceGuide(com_guide_id_list.CONST_GUIDE_2026)
        end
    elseif m_iNonForcedGuideId == com_guide_id_list.CONST_GUIDE_2031 then 
        comGuideManager.set_show_guide(com_guide_id_list.CONST_GUIDE_2031)
    elseif m_iNonForcedGuideId == com_guide_id_list.CONST_GUIDE_2034 then 
        comGuideManager.set_show_guide(com_guide_id_list.CONST_GUIDE_2034)
    end

    if m_mainCardUid and m_mainCardUid ~= 0 then 
        if CCUserDefault:sharedUserDefault():getBoolForKey("skill_overview_learn_opened") == false then
            local function finally()
                if cur_sys_skill_num >0 then 
                    comGuideManager.set_show_guide(com_guide_id_list.CONST_GUIDE_2030)
                end
            end
            require("game/guide/shareGuide/picTipsManager")
            picTipsManager.create(6,finally)
            CCUserDefault:sharedUserDefault():setBoolForKey("skill_overview_learn_opened",true)
        end
    end
end


function get_com_guide_widget(temp_guide_id)
    if not m_pMainLayer then return nil end
    local mainWidget = m_pMainLayer:getWidgetByTag(999)
    if not mainWidget then return nil end
    if temp_guide_id == com_guide_id_list.CONST_GUIDE_2025 then 
        return mainWidget
    elseif temp_guide_id == com_guide_id_list.CONST_GUIDE_2031 then 
        return mainWidget
    elseif temp_guide_id == com_guide_id_list.CONST_GUIDE_2034 then 
        return getFirstUnFinishedProgressFullySkillItem()
    elseif temp_guide_id == com_guide_id_list.CONST_GUIDE_2035 then 
        return getFirstUnFinishedProgressFullySkillItem()
    elseif temp_guide_id == com_guide_id_list.CONST_GUIDE_2030 then 
        local scrollView = uiUtil.getConvertChildByName(mainWidget,"scrollView")
        local main_panel = uiUtil.getConvertChildByName(scrollView,"main_panel")
        return uiUtil.getConvertChildByName(main_panel,"guide_panel_2030")
    else
        return nil
    end
end
