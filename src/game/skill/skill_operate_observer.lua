-- TODOTK 记得要销毁
local instance = nil


local lastAdvancedHeroId = nil
local function checkHeroAdvaceNeedEffect(heroUid)
	if not instance then return false end
	if lastAdvancedHeroId and lastAdvancedHeroId == heroUid then 
		lastAdvancedHeroId = nil
		return true
	end
	return false
end



-- 武将卡进阶
local function requestHeroAdvance(targetHeroUid,materialHeroUid)
	lastAdvancedHeroId = targetHeroUid
	Net.send(HERO_ADVANCE,{targetHeroUid,materialHeroUid})
end

local function onRequestHeroAdvance(...)
	-- print(">>>>>>>>>>> onRequestHeroAdvance")
	-- config.dump({...})
end


local lastAwakenHeroId = nil

local function checkHeroAwakenNeedEffect(heroUid)
	if not instance then return false end
	if lastAwakenHeroId and lastAwakenHeroId == heroUid then
		lastAwakenHeroId = nil
		return true
	end

	return false
end
---- 武将卡觉醒
local function requestAwakeHero(targetHeroUid,sourceHeroUidList)
	lastAwakenHeroId = targetHeroUid
	Net.send(SKILL_AWAKE,{targetHeroUid,sourceHeroUidList})
end
local function onRequestAwakeHero(...)
	-- print("onRequestAwakeHero ...")
	-- config.dump({...})
end


local lastLearnSkillHeroId = nil
local lastLearnSkillIndx = nil

local function cheHeroLearnSkillNeedEffect(heroUid)
	if not instance then return nil end
	if lastLearnSkillHeroId and lastLearnSkillHeroId == heroUid then 
		lastLearnSkillHeroId = nil
		return lastLearnSkillIndx
	end
	return nil
end
-- 技能学习
local function requestHeroLearnSkill(mainHeroUid,skillId,skillIndx)
	lastLearnSkillHeroId = mainHeroUid 
	lastLearnSkillIndx = skillIndx
	Net.send(SKILL_LEARN,{mainHeroUid,skillId,skillIndx})
end

local function onRequestHeroLearnSkill(...)
	-- print(">>>>>>>>>>>> onRequestHeroLearnSkill ")
	--TODOTK 技能学习是否成功 播放不同的特效
	LSound.playSound(musicSound["skill_get"])
end
-- 技能强化
local function requestStrengthSkill(mainHeroUid,skillId)
	Net.send(SKILL_REINFORCE,{mainHeroUid,skillId})
end

local function onRequestStrengthSkill(...)
	-- print("onRequestAwakeHero")
	-- config.dump({...})
	if SkillDetail then 
		SkillDetail.onResponeSkillStrengthSucceed()
	end
	LSound.playSound(musicSound["skill_up"])
end

-- 研究获得新技能
local m_iLastSkill2Gain = nil


local function requestStudyNewSkill(mainHeroUid,skillId)
	m_iLastSkill2Gain = skillId
	Net.send(SKILL_RESEARCH,{mainHeroUid,skillId})
end
local function onRequestStudyNewSkill(...)
	-- print("onRequestStudyNewSkill")
	-- config.dump({...})
	--TODOTK 技能学习是否成功 播放不同的特效
	LSound.playSound(musicSound["skill_get"])
end

-- 转换技巧值
local function requestTranserlateSkillValue(heroUidList,costType)
	Net.send(SKILL_TRANSFORM,{heroUidList,costType})
end

local function onRequestTranserlateSkillValue(...)
	if SkillOperate and SkillOperate.responseRequestTransferSkillValue then 
		SkillOperate.responseRequestTransferSkillValue(true,...)
	end

	--招募界面的技巧值转化显示处理
	--if callResultManager then
		--callResultManager.change_technic_response(...)
	--end
end


-- 提升技能研究度
local m_iLastSkill2AdvanceStudyValue = nil
local function requestImproveSkillStudyValue(heroUidList,skillId)
	m_iLastSkill2AdvanceStudyValue = skillId
	Net.send(SKILL_IMPROVE,{skillId,heroUidList})
end

local function onRequestImproveSkillStudyVaule(param)
	-- print("onRequestImproveSkillStudyVaule")
	-- config.dump(param)

	if param == 100 then 
		if m_iLastSkill2AdvanceStudyValue then 
			SkillDataModel.updateData()
			require("game/skill/skill_gained_layer")
	        SkillGainedLayer.create(m_iLastSkill2AdvanceStudyValue,nil,SkillGainedLayer.VIEW_TYPE_SKILL_STUDY_SUCCEED)
	        m_iLastSkill2AdvanceStudyValue = nil
	        SkillOperate.remove_self(true)
	    end
    else
    	LSound.playSound(musicSound["skill_exp"])
		if SkillOperate then 
			SkillOperate.responeSkillImproveStudyValueSucceed()
		end
	end

	-- LSound.playSound(musicSound["skill_exp"])
	-- if SkillOperate then 
	-- 	SkillOperate.responeSkillImproveStudyValueSucceed(param == 100)
	-- end

end



-- 移除技能
local function requestDeleteSkill(skillId)
	Net.send(SKILL_REMOVE,{skillId})

end

local function onRequestDeleteSkill(...)
	-- print(">>>>>>>>>>>>>onRequestDeleteSkill")
	LSound.playSound(musicSound["skill_delete"])
end


-- 武将卡遗忘技能
local function requestHeroDeleteSkill(heroUid,skillId)
	Net.send(SKILL_FORGET,{heroUid,skillId})

end

local function onRequestHeroDeleteSkill(...)
	-- print(">>>>>>>>>onRequestHeroDeleteSkill")
	LSound.playSound(musicSound["skill_delete"])
end

--TODOTK 优化下 
local function updateData()
	if m_iLastSkill2Gain then 
		SkillDataModel.updateData()
		-- require("game/skill/skill_gained_layer")
  --       SkillGainedLayer.create(m_iLastSkill2Gain,nil,SkillGainedLayer.VIEW_TYPE_GAIN_SKILL)
  		require("game/skill/skill_operate")
        SkillOperate.create(SkillOperate.OP_TYPE_SKILL_STUDY_PROGRESS,nil,nil,m_iLastSkill2Gain,function()
        	SkillOperate.responeSkillImproveStudyValueSucceed(true)
        end)

        m_iLastSkill2Gain = nil
        return 
    end
end

local function clearOperateEffectData()
	lastAdvancedHeroId = nil
	lastAwakenHeroId = nil
	lastLearnSkillHeroId = nil
	lastLearnSkillIndx = nil
end

local function remove()
	if not instance then return end
	netObserver.removeObserver(HERO_ADVANCE)
	netObserver.removeObserver(SKILL_AWAKE)
	netObserver.removeObserver(SKILL_REINFORCE)
	netObserver.removeObserver(SKILL_RESEARCH)
	netObserver.removeObserver(SKILL_TRANSFORM)
	netObserver.removeObserver(SKILL_IMPROVE)
	netObserver.removeObserver(SKILL_REMOVE)
	netObserver.removeObserver(SKILL_FORGET)
	netObserver.removeObserver(SKILL_LEARN)

	instance = nil
	m_iLastSkill2Gain = nil

	UIUpdateManager.remove_prop_update(dbTableDesList.user_skill.name, dataChangeType.update, updateData)
	UIUpdateManager.remove_prop_update(dbTableDesList.user_skill.name, dataChangeType.add, updateData)
	UIUpdateManager.remove_prop_update(dbTableDesList.user_skill.name, dataChangeType.remove, updateData)
	
	clearOperateEffectData()
	
end




local function create()
	if instance then return end
	--武将卡进阶
	netObserver.addObserver(HERO_ADVANCE,onRequestHeroAdvance)
	---- 武将卡觉醒
	netObserver.addObserver(SKILL_AWAKE,onRequestAwakeHero)	
	---- 技能强化
	netObserver.addObserver(SKILL_REINFORCE,onRequestStrengthSkill)
	---- 研究获得新技能
	netObserver.addObserver(SKILL_RESEARCH,onRequestStudyNewSkill)
	---- 转换技巧值
	netObserver.addObserver(SKILL_TRANSFORM,onRequestTranserlateSkillValue)
	-- 提升技能研究度
	netObserver.addObserver(SKILL_IMPROVE,onRequestImproveSkillStudyVaule)
	-- 移除技能
	netObserver.addObserver(SKILL_REMOVE,onRequestDeleteSkill)
	-- 武将卡遗忘技能
	netObserver.addObserver(SKILL_FORGET,onRequestHeroDeleteSkill)
	-- 技能学习
	netObserver.addObserver(SKILL_LEARN,onRequestHeroLearnSkill)

	instance = true


	UIUpdateManager.add_prop_update(dbTableDesList.user_skill.name, dataChangeType.update, updateData)
	UIUpdateManager.add_prop_update(dbTableDesList.user_skill.name, dataChangeType.add, updateData)
	UIUpdateManager.add_prop_update(dbTableDesList.user_skill.name, dataChangeType.remove, updateData)



	m_iLastSkill2Gain = nil
end










local SkillOpreateObserver = {
	create = create,
	remove = remove,
	requestHeroAdvance = requestHeroAdvance, 
	requestAwakeHero = requestAwakeHero,
	requestStrengthSkill = requestStrengthSkill,
	requestStudyNewSkill = requestStudyNewSkill,
	requestTranserlateSkillValue = requestTranserlateSkillValue,
	requestImproveSkillStudyValue = requestImproveSkillStudyValue,
	requestDeleteSkill = requestDeleteSkill,
	requestHeroDeleteSkill = requestHeroDeleteSkill,
	requestHeroLearnSkill = requestHeroLearnSkill,


	checkHeroAdvaceNeedEffect = checkHeroAdvaceNeedEffect,
	checkHeroAwakenNeedEffect = checkHeroAwakenNeedEffect,
	cheHeroLearnSkillNeedEffect = cheHeroLearnSkillNeedEffect,

	clearOperateEffectData = clearOperateEffectData,
}


return SkillOpreateObserver