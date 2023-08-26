local m_pMainLayer = nil
local skillUtil =  require("game/utils/skillUtil")
local uiUtil = require("game/utils/ui_util")
local strUtil = require("game/utils/string_util")

local m_iHeroBid = nil
local skillDetailHelper = require("game/skill/skill_detail_helper")


local function do_remove_self()
	if m_pMainLayer then
		m_pMainLayer:removeFromParentAndCleanup(true)
		m_pMainLayer = nil
		m_iHeroBid = nil
		uiManager.remove_self_panel(uiIndexDefine.CARD_TEACH_INFO)
	end
end

local function remove_self()
	if not m_pMainLayer then return end
    uiManager.hideConfigEffect(uiIndexDefine.CARD_TEACH_INFO,m_pMainLayer,do_remove_self)
end
local function dealwithTouchEvent(x,y)
	if not m_pMainLayer then
		return false
	end

	local mainWidget = m_pMainLayer:getWidgetByTag(999)
	if mainWidget:hitTest(cc.p(x,y)) then
		return false
	else
		remove_self()
		return true
	end
end



local function setSelectedTeachSkillInfo(skillIndx,skillId)
	if not m_pMainLayer then return end
	local mainWidget = m_pMainLayer:getWidgetByTag(999)

	local basicHeroInfo = Tb_cfg_hero[m_iHeroBid]

	local cfgSkillLearnInfo = Tb_cfg_skill_learn[basicHeroInfo.skill_init]
	if not cfgSkillLearnInfo then return end

	local can_teach_nums = #cfgSkillLearnInfo.learn

	local panel_btns = uiUtil.getConvertChildByName(mainWidget,"panel_btns")
	local btn_skill = nil 

	for i = 1,can_teach_nums do 
		btn_skill = uiUtil.getConvertChildByName(panel_btns,"btn_skill_" .. i)
		if i == skillIndx then 
			btn_skill:setBright(false)
		else
			btn_skill:setBright(true)
		end
	end

	local panel_detail = uiUtil.getConvertChildByName(mainWidget,"panel_detail")
	local skillDetailWidget = skillDetailHelper.getSkillDetailWidget(panel_detail)
    skillDetailHelper.updateInfo(panel_detail,skillId,1)


    local panel_condition = uiUtil.getConvertChildByName(mainWidget,"panel_condition")
	local paramTab = SkillDataModel.getSkillResearchConditionDetailTxt(skillId)
	skillDetailHelper.loadResearchConditionRichText(panel_condition,paramTab,true,5)
end



local function initSkillBtns()
	if not m_pMainLayer then return end

	local mainWidget = m_pMainLayer:getWidgetByTag(999)
	local panel_btns = uiUtil.getConvertChildByName(mainWidget,"panel_btns")
	local basicHeroInfo = Tb_cfg_hero[m_iHeroBid]

	local cfgSkillLearnInfo = Tb_cfg_skill_learn[basicHeroInfo.skill_init]
	if not cfgSkillLearnInfo then return end

	local can_teach_nums = #cfgSkillLearnInfo.learn

	local btn_skill = nil
	local pos_x = nil
	local pos_y = nil
	local img_studied = nil

	for i = 1,4 do 
		btn_skill = uiUtil.getConvertChildByName(panel_btns,"btn_skill_" .. i)
		img_studied = uiUtil.getConvertChildByName(btn_skill,"img_studied")
		
		if i <= can_teach_nums then
			btn_skill:setTouchEnabled(true)
			btn_skill:setVisible(true)
			btn_skill:setTitleText(Tb_cfg_skill[cfgSkillLearnInfo.learn[i]].name)
			if SkillDataModel.isSkillOwned(cfgSkillLearnInfo.learn[i]) then 
				img_studied:setVisible(true)
			else
				img_studied:setVisible(false)
			end
		else
			btn_skill:setTouchEnabled(false)
			btn_skill:setVisible(false)
		end

		
		btn_skill:addTouchEventListener(function(sender,eventType)
			if eventType == TOUCH_EVENT_ENDED then 
				setSelectedTeachSkillInfo(i,cfgSkillLearnInfo.learn[i])
			end
		end)		
	end

	if can_teach_nums > 0 then 
		setSelectedTeachSkillInfo(1,cfgSkillLearnInfo.learn[1])
	end

	btn_skill:removeFromParentAndCleanup(true)



	
end

local function setShowInfo(heroBid)
	if m_pMainLayer then
		return
	end
	m_iHeroBid = heroBid

	if not m_iHeroBid then return end

	local basicHeroInfo = Tb_cfg_hero[m_iHeroBid]
	if not basicHeroInfo then return end

	if not Tb_cfg_skill[basicHeroInfo.skill_init] then return end

	require("game/skill/skill_data_model")
	SkillDataModel.create()

	local mainWidget = GUIReader:shareReader():widgetFromJsonFile("test/jinengxiangqing_7.json")
	mainWidget:setTag(999)
	mainWidget:setScale(config.getgScale())
	mainWidget:ignoreAnchorPointForPosition(false)
	mainWidget:setAnchorPoint(cc.p(0.5, 0.5))
	mainWidget:setPosition(cc.p(config.getWinSize().width/2 , config.getWinSize().height/2))
	mainWidget:setTouchEnabled(true)

	local panel_detail = uiUtil.getConvertChildByName(mainWidget,"panel_detail")
	local panel_btns = uiUtil.getConvertChildByName(mainWidget,"panel_btns")
	local panel_condition = uiUtil.getConvertChildByName(mainWidget,"panel_condition")
	panel_btns:setBackGroundColorType(LAYOUT_COLOR_NONE)
	panel_detail:setBackGroundColorType(LAYOUT_COLOR_NONE)
	panel_condition:setBackGroundColorType(LAYOUT_COLOR_NONE)

	m_pMainLayer = TouchGroup:create()
	m_pMainLayer:addWidget(mainWidget)
	uiManager.add_panel_to_layer(m_pMainLayer, uiIndexDefine.CARD_TEACH_INFO)

	initSkillBtns()
	
	

	uiManager.showConfigEffect(uiIndexDefine.CARD_TEACH_INFO,m_pMainLayer)
end

cardTeachInfo = {
					setShowInfo = setShowInfo,
					remove_self = remove_self,
					dealwithTouchEvent = dealwithTouchEvent
}
