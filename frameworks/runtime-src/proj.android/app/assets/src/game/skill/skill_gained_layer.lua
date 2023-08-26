module("SkillGainedLayer", package.seeall)

--获得新技能UI
--类名  SkillGainedLayer  
-- json名：  jinengxiangqing_3.json
-- 配置ID:	UI_SKILL_GAINED

SkillGainedLayer.VIEW_TYPE_GAIN_SKILL = 1		--技能库获取新技能
SkillGainedLayer.VIEW_TYPE_SKILL_STUDY_SUCCEED = 2	-- 技能库技能研究度提升

local m_pMainLayer = nil
local m_pMainWidget = nil

local m_pSkillItemProgressBg = nil
local m_pBtnContinueStudy = nil
local m_iSkillId = nil

local m_iViewType = nil


local skillItemHelper = require("game/skill/skill_item_helper")

local function do_remove_self()
	if m_pMainLayer then
		m_pMainLayer:removeFromParentAndCleanup(true)
		m_pMainLayer = nil
		uiManager.remove_self_panel(uiIndexDefine.UI_SKILL_GAINED)

		m_iSkillId = nil
		m_pBtnContinueStudy = nil

		
		m_iViewType = nil

		-- CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("Export/yanjiu.ExportJson")
		-- CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("Export/shengji.ExportJson")

		if SkillOverview and SkillOverview.updateTouchEnable then 
			SkillOverview.updateTouchEnable(true)
		end
	end
end



function remove_self()
    if not m_pMainLayer then return end
    if m_pSkillItemProgressBg then 
		m_pSkillItemProgressBg:stopAllActions()
		m_pSkillItemProgressBg:removeFromParentAndCleanup(true)
		m_pSkillItemProgressBg = nil
	end
    uiManager.hideConfigEffect(uiIndexDefine.UI_SKILL_GAINED,m_pMainLayer,do_remove_self) 
end

local function dealwithContinueStudy()
	local skillId = m_iSkillId
    remove_self()
    require("game/skill/skill_operate")
    SkillOperate.create(SkillOperate.OP_TYPE_SKILL_STUDY_PROGRESS,nil,nil,skillId)
end

function dealwithTouchEvent(x,y)
	if not m_pMainLayer then return false end
	if not m_pBtnContinueStudy then return false end

	
	if m_pBtnContinueStudy:hitTest(cc.p(x,y)) then
		dealwithContinueStudy()
		return false
	else
		remove_self()
		return true
	end
end

local function playOnEnterEffect()
	if not m_pMainLayer then return end
	local mainWidget = m_pMainWidget

	local skill_item = uiUtil.getConvertChildByName(mainWidget,"skill_item")

	local skillItemWidget  = uiUtil.getConvertChildByName(skill_item,"skillItemWidget" )

	if m_iViewType == SkillGainedLayer.VIEW_TYPE_SKILL_STUDY_SUCCEED  then 
		skillItemHelper.playArmatureEffect(skillItemWidget,"yanjiu")
	elseif m_iViewType == SkillGainedLayer.VIEW_TYPE_GAIN_SKILL then 
		skillItemHelper.playArmatureEffect(skillItemWidget,"yanjiu")
	end

	
end
local function initLayout()
	if not m_pMainLayer then return end
	local mainWidget = m_pMainWidget
	m_pBtnContinueStudy = uiUtil.getConvertChildByName(mainWidget,"btn_continue_study")
	m_pBtnContinueStudy:setTouchEnabled(true)

	local skill_item = uiUtil.getConvertChildByName(mainWidget,"skill_item")
	skill_item:setBackGroundColorType(LAYOUT_COLOR_NONE)

	local skillItemWidget  = uiUtil.getConvertChildByName(skill_item,"skillItemWidget" )
	if not skillItemWidget then 
        skillItemWidget,m_pSkillItemProgressBg = skillItemHelper.createWidgetItem(true)
        skillItemWidget:setName("skillItemWidget")
        skill_item:addChild(skillItemWidget)
        skillItemWidget:ignoreAnchorPointForPosition(false)
		skillItemWidget:setAnchorPoint(cc.p(0.5,0.5))
		skillItemWidget:setPosition(cc.p(skill_item:getSize().width/2,skill_item:getSize().height/2))
    end
    skillItemWidget:setScale(1.5)
    skillItemHelper.loadSkillInfo(skillItemWidget,m_pSkillItemProgressBg, m_iSkillId,skillItemHelper.LAYOUT_TYPE_GAIN_SKILL_LAYER)
	
	

    m_pBtnContinueStudy:addTouchEventListener(function(sender,eventType)
    	if eventType == TOUCH_EVENT_ENDED then
            dealwithContinueStudy()
    	end
    end)

    local label_sk_name = uiUtil.getConvertChildByName(mainWidget,"label_sk_name")
    label_sk_name:setText(Tb_cfg_skill[m_iSkillId].name)

    local img_flag_succeed = uiUtil.getConvertChildByName(mainWidget,"img_flag_succeed")

    local panel_gain_skill = uiUtil.getConvertChildByName(mainWidget,"panel_gain_skill")
    panel_gain_skill:setVisible(false)
    if m_iViewType == SkillGainedLayer.VIEW_TYPE_SKILL_STUDY_SUCCEED  then 
    	img_flag_succeed:setVisible(true)
	    m_pBtnContinueStudy:setVisible(false)
	    m_pBtnContinueStudy:setTouchEnabled(false)
	elseif m_iViewType == SkillGainedLayer.VIEW_TYPE_GAIN_SKILL then 
		panel_gain_skill:setVisible(true)
		img_flag_succeed:setVisible(false)
	end
    
end

local function reloadData()
	if not m_pMainLayer then return end
	
end

function create(skillId, callback,viewType)
	if m_pMainLayer then return end

	-- CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/yanjiu.ExportJson")
    -- CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/shengji.ExportJson")

	m_iSkillId = skillId
	
	m_iViewType = viewType

	if SkillOverview and SkillOverview.updateTouchEnable then 
		SkillOverview.updateTouchEnable(false)
	end

	local win_size = config.getWinSize()
	local blackLayer = cc.LayerColor:create(cc.c4b(14, 17, 24, 150), win_size.width, win_size.height)

	local mainWidget = GUIReader:shareReader():widgetFromJsonFile("test/jinengxiangqing_3.json")
	mainWidget:setTouchEnabled(true)
	mainWidget:setTag(999)
	mainWidget:setScale(config.getgScale())
	mainWidget:ignoreAnchorPointForPosition(false)
	mainWidget:setAnchorPoint(cc.p(0.5, 0.5))
	mainWidget:setPosition(cc.p(config.getWinSize().width/2 , config.getWinSize().height/2))

	m_pMainWidget = mainWidget

	local main_bg = uiUtil.getConvertChildByName(mainWidget,"main_bg")
	main_bg:removeFromParentAndCleanup(false)
	main_bg:setSize(CCSize(win_size.width, win_size.height))
	main_bg:setPosition(cc.p(config.getWinSize().width/2 , config.getWinSize().height/2))
	m_pMainLayer = TouchGroup:create()
	blackLayer:addChild(mainWidget)

	m_pMainLayer:addChild(main_bg)
	m_pMainLayer:addChild(blackLayer)
	blackLayer:setTouchEnabled(false)
    -- m_pMainLayer:addWidget(mainWidget)
    
    initLayout()
    reloadData()

    uiManager.add_panel_to_layer(m_pMainLayer, uiIndexDefine.UI_SKILL_GAINED)
    uiManager.showConfigEffect(uiIndexDefine.UI_SKILL_GAINED,m_pMainLayer,function()
    	if m_iViewType == SkillGainedLayer.VIEW_TYPE_GAIN_SKILL then 
    		LSound.playSound(musicSound["skill_get"])
    	elseif m_iViewType == SkillGainedLayer.VIEW_TYPE_SKILL_STUDY_SUCCEED then
    		LSound.playSound(musicSound["skill_exp"])
    	end
    	playOnEnterEffect()
    end)


    
    
end