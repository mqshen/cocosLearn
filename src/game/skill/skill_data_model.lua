module("SkillDataModel", package.seeall)

SkillDataModel.OWN_TYPE_IMMUTABLE = 1
SkillDataModel.OWN_TYPE_VOLATILE = 2


local ColorUtil = require("game/utils/color_util")
local m_tSkillListImmutable = nil
local m_tSkillListVolatile = nil

local instance = nil


-- 系统默认配置的
function getSkillListImmutable()
	return m_tSkillListImmutable
end


-- 玩家可变动的技能列表（ 可删除的 ）
function getSkillListVolatile()
	return m_tSkillListVolatile
end

-- 玩家所有可用技能列表
function getSkillList()
	local ret = {}

	for k,v in ipairs(m_tSkillListImmutable) do 
		table.insert(ret,v)
	end



	for k,v in ipairs(m_tSkillListVolatile) do 
		table.insert(ret,v)
	end

	return ret
end



function getUserSkillInfoById(skillId)
	if not skillId then return nil end
	for k,v in ipairs(m_tSkillListVolatile) do 
		if v.skill_id == skillId then 
			return v
		end
	end

	for k,v in ipairs(m_tSkillListImmutable) do 
		if v.skill_id == skillId then 
			return v
		end
	end

	return nil
end

function getSkillStudyProgressInfo(skillId)
	local skillInfo = getUserSkillInfoById(skillId)
	if not skillInfo then return 1,1 end
	-- local curProgress = skillInfo.study_count * 100 + skillInfo.study_progress
	-- local maxProgress = skillInfo.study_count_max * 100 
	
	local maxProgress = 100
	local curProgress = skillInfo.study_progress
	return curProgress,maxProgress
end
-- 获取技能技巧值
function getUserSkillValue()
	for k,v in pairs(allTableData[dbTableDesList.user_res.name]) do
		return v.skill_value_cur
	end
end

-- 技能数量信息
function getSkillNumInfo()
	return #m_tSkillListImmutable + m_tSkillListVolatile,getSkillNumLimit()
end

function isSkillOwned(skillId)
	for k,v in ipairs(m_tSkillListVolatile) do 
		if v.skill_id == skillId then 
			return true
		end
	end

	for k,v in ipairs(m_tSkillListImmutable) do 
		if v.skill_id == skillId then 
			return true
		end
	end

	return false
end



local function cfg_data_rework(data_table, child_list)
	for k,v in pairs(data_table) do
		for kk,vv in pairs(child_list) do
			v[vv[1]] = stringFunc.anlayerOnespot(v[vv[1]], vv[2], vv[3])
		end
	end
end

function isHeroLearnedSkill(heroInfo)
	if not heroInfo then return end
	local hero_skill_list = heroData.getHeroSkillList(heroInfo.heroid_u)  or {}
	if #hero_skill_list <=1 then return false end -- 第一个技能不算 是系统默认的
	--TODOTK 武将卡技能遗忘的时候 让服务端直接删掉 不要再存0,0,0 的东西
	local skillCount = 1
	for i = 2 ,#hero_skill_list do 
		if hero_skill_list[i][1] > 0 then 
			skillCount = skillCount + 1
		end
	end
	return skillCount > 1
end
function isSkillLearnedByHeroInfo(heroInfo,skillId)
	if not skillId then return false end
	if not heroInfo then return false end
	local hero_skill_list = heroData.getHeroSkillList(heroInfo.heroid_u)  or {}
	if #hero_skill_list <=1 then return false end -- 第一个技能不算 是系统默认的
	
	for i =  2,#hero_skill_list do 
		if hero_skill_list[i][1] == skillId then 
			return true
		end
	end
	return false
end
function isSkillLearnedByHeroId(heroUid,skillId)
	if not heroUid then return false end
	if not skillId then return false end
	local heroInfo = heroData.getHeroInfo(heroUid)
	return isSkillLearnedByHeroInfo(heroInfo,skillId)
end
local function updateSkillCacheData()
	
	local skillInfoOrigin = {}
	for k,v in pairs(allTableData[dbTableDesList.user_skill.name]) do
		table.insert(skillInfoOrigin,v)
	end
	
	m_tSkillListImmutable = {}
	m_tSkillListVolatile = {}

	
	
	local cacheItem = nil

	for k,v in ipairs(skillInfoOrigin) do
		cacheItem = {}
		cacheItem.sid = cacheItem.skill_id_u

		-- 技能ID
		cacheItem.skill_id = v.skill_id
		-- 当前已学习数	
		cacheItem.learn_count = v.learned_num
		-- 当前已研究数
		cacheItem.study_count = v.researched_num
		-- 当前研究进度
		cacheItem.study_progress = v.research_progress
		-- 总共可学习数
		cacheItem.learn_count_max = cacheItem.study_count 
		
		-- 总共可研究数
		cacheItem.study_count_max = Tb_cfg_skill_research[cacheItem.skill_id].research_num

		-- 当前可学习数
		cacheItem.learn_count_retain = cacheItem.learn_count_max -  cacheItem.learn_count
		-- 当前可研究数
		-- cacheItem.study_count_retain = cacheItem.study_count_max - cacheItem.study_count
		cacheItem.study_count_retain = 1 - cacheItem.study_count
		-- 达到研究度上限
		cacheItem.is_study_max = cacheItem.study_count_retain <= 0
		-- 当前已学习此技能的武将
		cacheItem.hero_list_learned = {}

		local hero_info = nil
		for k,v in pairs(heroData.getAllHero()) do
			if isSkillLearnedByHeroId(k,cacheItem.skill_id) then 
				table.insert(cacheItem.hero_list_learned,k)
			end
		end
		
		
		-- 技能所属类型
		if v.skill_type == 0 then 
			-- 预设技能
			cacheItem.own_type = SkillDataModel.OWN_TYPE_IMMUTABLE
			table.insert(m_tSkillListImmutable,cacheItem)
		else
			cacheItem.own_type = SkillDataModel.OWN_TYPE_VOLATILE
			table.insert(m_tSkillListVolatile,cacheItem)
		end

	end

end



local function refreshUIView()
	if SkillOverview then 
		SkillOverview.reload_data()
	end
end

-- 数据变动驱动UI界面刷新
function updateData(...)

	updateSkillCacheData()
	refreshUIView()
end




function remove()
	if not instance then return end

	m_tSkillListImmutable = {}
	m_tSkillListVolatile = {}
	
	UIUpdateManager.remove_prop_update(dbTableDesList.user_skill.name, dataChangeType.update, updateData)
	UIUpdateManager.remove_prop_update(dbTableDesList.user_skill.name, dataChangeType.add, updateData)
	UIUpdateManager.remove_prop_update(dbTableDesList.user_skill.name, dataChangeType.remove, updateData)
	
	UIUpdateManager.remove_prop_update(dbTableDesList.user_res.name, dataChangeType.update, updateData)
	UIUpdateManager.remove_prop_update(dbTableDesList.user_res.name, dataChangeType.add, updateData)
	UIUpdateManager.remove_prop_update(dbTableDesList.user_res.name, dataChangeType.remove, updateData)
	
	instance = nil
end



function create()
	if instance then return end

	updateData()
	
	
	UIUpdateManager.add_prop_update(dbTableDesList.user_skill.name, dataChangeType.update, updateData)
	UIUpdateManager.add_prop_update(dbTableDesList.user_skill.name, dataChangeType.add, updateData)
	UIUpdateManager.add_prop_update(dbTableDesList.user_skill.name, dataChangeType.remove, updateData)

	UIUpdateManager.add_prop_update(dbTableDesList.user_res.name, dataChangeType.update, updateData)
	UIUpdateManager.add_prop_update(dbTableDesList.user_res.name, dataChangeType.add, updateData)
	UIUpdateManager.add_prop_update(dbTableDesList.user_res.name, dataChangeType.remove, updateData)


	instance = true
end


-------------------------------- 一些配置数据 -----------------------
-- 获取一张卡牌 提供给 一个技能的研究度加成（百分比）
-- 返回nil 要么非法 要么就是这张卡无法给这个技能加成
function getStudyProgressValueByCard(skillId,cardId,advance_count)
    if not skillId then return nil end
    if not cardId then return nil end
    local cfgSkillResearchInfo = Tb_cfg_skill_research[skillId]
    if not cfgSkillResearchInfo then return end
    local cfgHeroInfo = Tb_cfg_hero[cardId]
    if not cfgHeroInfo then return end


    if not advance_count then advance_count = 0 end
    advance_count = advance_count + 1

    local SKILL_IMPROVE_NORMAL_EXP = cfgSkillResearchInfo.normal_exp
    local ret_value = nil
    -- 第一大类
    for k,v in ipairs(cfgSkillResearchInfo.improve_heroid) do 
        if cardId== v then 
            ret_value = SKILL_IMPROVE_SPECIFIED_EXP
        end
    end
    if ret_value then return ret_value * advance_count end


    -- 第二大类 必须同时满足三个子类 
    -- TODOTK 抽象下
    local flag_sub = nil
    if #cfgSkillResearchInfo.improve_quality == 0 then 
        flag_sub = true
    else
        flag_sub = false
        for k,v in ipairs(cfgSkillResearchInfo.improve_quality) do 
            if cfgHeroInfo.quality == v then 

                flag_sub = true
            end
        end
    end
    if not flag_sub then return nil end -- 不满足子类 


    if #cfgSkillResearchInfo.improve_country == 0 then 
        flag_sub = true
    else
        flag_sub = false
        for k,v in ipairs(cfgSkillResearchInfo.improve_country) do 
            if cfgHeroInfo.country == v then 
                flag_sub = true
            end
        end
    end
    if not flag_sub then return nil end -- 不满足子类 

    if #cfgSkillResearchInfo.improve_type == 0 then 
        flag_sub = true
    else
        flag_sub = false
        for k,v in ipairs(cfgSkillResearchInfo.improve_type) do 
            if cfgHeroInfo.hero_type == v then 
                flag_sub = true
            end
        end
    end
    if not flag_sub then return nil end -- 不满足子类 
    if flag_sub then 
         return SKILL_IMPROVE_NORMAL_EXP * advance_count
    end
    
    return ret_value * advance_count
end

-- 研究新技能的消耗  根据消耗的武将卡的品质来确定
function getStudyNewSkillCost(heroUid)
	if not heroUid then return 0 end
	local heroInfo = heroData.getHeroInfo(heroUid)
	if not heroInfo then return 0 end

	local cfgHeroInfo = Tb_cfg_hero[heroInfo.heroid]
	local quality = cfgHeroInfo.quality

	return SKILL_RESEARCH_HERO_QUALITY_TO_SKILL_VALUE[quality + 1] or 0
end


-- 一张武将卡 作为素材卡 所转化的技巧值
function getSkillValueTurnedFromHeroCard(heroUid)
	if not heroUid then return 0 end
	local heroInfo = heroData.getHeroInfo(heroUid)
	if not heroInfo then return 0 end

	local cfgHeroInfo = Tb_cfg_hero[heroInfo.heroid]
	local quality = cfgHeroInfo.quality

	local quality_exp = SKILL_QUALITY_EXP[quality + 1] 

	local advance_count = heroInfo.advance_num

	
	-- 所有技能的经验
	local hero_skill_list = heroData.getHeroSkillList(heroInfo.heroid_u)  or {}
	local cfgSkillInfo = nil
	local total_exp = 0
	local indx = nil
	for k,v in ipairs(hero_skill_list) do 
		cfgSkillInfo = Tb_cfg_skill[v[1]]
		if cfgSkillInfo then 
			indx = cfgSkillInfo.skill_quality*100 + v[2]
			if Tb_cfg_skill_level[indx] then 
				total_exp = total_exp + Tb_cfg_skill_level[indx].total_exp 
			end
		end	
	end

	local ret = quality_exp * (1 + advance_count) + total_exp * SKILL_VALUE_TRANSFORM_RATIO / 100
	return math.floor(ret)
end


-- 技能研究的条件 以及详细信息
function getSkillResearchConditionDetailTxt(skillId)
	if not skillId then return nil end
	local cfgSkillResearchInfo = Tb_cfg_skill_research[skillId]
	if not cfgSkillResearchInfo then return nil end
	local SKILL_IMPROVE_NORMAL_EXP = cfgSkillResearchInfo.normal_exp
	
	local cfgHeroInfo = nil

	-- TODOTK 中文收集
	local condition_txt_1 = ""
	local add_rate_txt_1 = "+" .. SKILL_IMPROVE_SPECIFIED_EXP .. "%"
	local condition_tab_1 = {}
	-- 第一大类 特定武将
    for k,v in ipairs(cfgSkillResearchInfo.improve_heroid) do 
    	cfgHeroInfo = Tb_cfg_hero[v]
    	if cfgHeroInfo then 
        	condition_txt_1 = condition_txt_1  .. cfgHeroInfo.name 
        	condition_txt_1 = condition_txt_1 .. "（" 
        	condition_txt_1 = condition_txt_1 .. languagePack["countryName_" .. cfgHeroInfo.country]  
        	condition_txt_1 = condition_txt_1 .. "）"

        	local nameTxt = "【" .. languagePack["countryName_" .. cfgHeroInfo.country] .. "·" .. cfgHeroInfo.name .. "·" .. languagePack["heroTypeName_" .. cfgHeroInfo.hero_type]  .."】"

        	table.insert(condition_tab_1,{nameTxt,ColorUtil.getHeroColor(cfgHeroInfo.quality)})

        end

        if k ~= #cfgSkillResearchInfo.improve_heroid then 
        	condition_txt_1 = condition_txt_1 .. " "
        end
    end
    

    -- 第二大类

    local condition_txt_2 = ""
    local add_rate_txt_2 = "+" .. SKILL_IMPROVE_NORMAL_EXP .. "%"
    for k,v in ipairs(cfgSkillResearchInfo.improve_quality) do 
        condition_txt_2 = condition_txt_2  .. (v + 1) .. "星"
        if k ~= #cfgSkillResearchInfo.improve_quality then 
        	condition_txt_2 = condition_txt_2 .. "、"
        end
    end


    for k,v in ipairs(cfgSkillResearchInfo.improve_country) do 
        condition_txt_2 = condition_txt_2 .. languagePack["countryName_" .. v] 
        if k ~= #cfgSkillResearchInfo.improve_country then 
        	condition_txt_2 = condition_txt_2 .. "、"
        end
    end

    for k,v in ipairs(cfgSkillResearchInfo.improve_type) do 
        condition_txt_2 = condition_txt_2 .. languagePack["heroTypeSoldierName_" .. v]
        if k ~= #cfgSkillResearchInfo.improve_type then 
        	condition_txt_2 = condition_txt_2 .. "、"
        end
    end

    if condition_txt_2 ~= "" then 
    	condition_txt_2 = condition_txt_2 ..  "武将"  
    end

    -- 
    -- 
    local ret = {}
    local retB = {}
    if condition_txt_2 ~= "" then 
    	table.insert(ret,{condition_txt_2,ccc3(255,213,110)})
    	table.insert(ret,{add_rate_txt_2,ccc3(199,193,113)})
    end
    if condition_txt_1 ~= "" then 
    	-- table.insert(ret,{condition_txt_1,ccc3(255,213,110)})
    	-- table.insert(ret,{add_rate_txt_1,ccc3(199,193,113)})

    	for k,v in pairs(condition_tab_1) do 
    		table.insert(retB,v)
    	end
    	table.insert(retB,{add_rate_txt_1,ccc3(199,193,113)})
    end
    
    return {ret,retB}

end