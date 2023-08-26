local skillUtil = {}

skillUtil.cacheDetail = {}

local strUtil = require("game/utils/string_util")
local uiUtil = require("game/utils/ui_util")
local ColorUtil = require("game/utils/color_util")

local function convertSpecificDecimalNum(val,decimalNum)
	val = tonumber(val)
	if not decimalNum then decimalNum = 1 end
	local integerTab,decimalTab = stringFunc.split_number_to_table(val)
	local ret_str = ""
	for i = 1,#integerTab do 
		ret_str = ret_str .. integerTab[i]
	end
	ret_str = ret_str .. '.'

	local tmp_decimal_num = decimalNum
	for i = 1,tmp_decimal_num do 
		if decimalTab[i] then 
			ret_str = ret_str .. decimalTab[i]
			decimalNum = decimalNum - 1
		end
	end

	for i = 1,decimalNum do 
		ret_str = ret_str .. '0'
	end

	return ret_str
end

function skillUtil.getSkillPerformRate(Sid,Slv)
	local skillInfo = Tb_cfg_skill[Sid]
	if not skillInfo then 
		return 0 
	end

	local probability_init = skillInfo.probability_init
	local probability_max = skillInfo.probability_max
	local ret = convertSpecificDecimalNum( probability_init+(probability_max-probability_init)/9*(Slv-1) )
	return ret
end

function skillUtil.getSkillDescByLv(Sid,Slv)
	if skillUtil.cacheDetail[Sid .. Slv] then return skillUtil.cacheDetail[Sid .. Slv] end

	local skillInfo = Tb_cfg_skill[Sid]
	if not skillInfo then return "unknow skill" end

	local retDesc = skillInfo.description

	-- 技能准备回合数相关
	retDesc = string.gsub(retDesc,"#prepare#","#@" .. skillInfo.prepare .. "回合" .. "@#")
    
	local skillDetailInfo = nil
	local subSid = 0
	-- 技能作用参数相关 delay_hit
	local delay_hit_value = 0
	while retDesc:match("#delay_hit_.-#")  do
		subSid = retDesc:match("#delay_hit_.-#") 
		subSid = string.gsub(subSid,"delay_hit_","")
		subSid = string.gsub(subSid,"#","")
		skillDetailInfo = Tb_cfg_skill_detail[ tonumber(Sid .. subSid)]
		if skillDetailInfo then 
			delay_hit_value = skillDetailInfo.delay_hit
		end
		retDesc = string.gsub(retDesc,"#delay_hit_" .. subSid .."#", "#@" .. delay_hit_value .. "次数" .. "@#")
	end


	local prob_param = 0
	local prob_init_param = 0
	local prob_max_param = 0
	while retDesc:match("#prob_param_.-#")  do
		subSid = retDesc:match("#prob_param_.-#") 
		subSid = string.gsub(subSid,"prob_param_","")
		subSid = string.gsub(subSid,"#","")
		skillDetailInfo = Tb_cfg_skill_detail[ tonumber(Sid .. subSid)]
		if skillDetailInfo then 
			prob_param = skillDetailInfo.prob_param
			prob_init_param = skillDetailInfo.prob_init_param
			prob_max_param = skillDetailInfo.prob_max_param
			prob_param = convertSpecificDecimalNum(prob_init_param+(prob_max_param-prob_init_param)/9*(Slv - 1)) .. "%%" 
		end
		retDesc = string.gsub(retDesc,"#prob_param_" .. subSid .. "#","#@" .. prob_param .. "@#")
	end 

	local temp_available_round = 0
	while retDesc:match("#available_round_.-#")  do
		subSid = retDesc:match("#available_round_.-#") 
		subSid = string.gsub(subSid,"available_round_","")
		subSid = string.gsub(subSid,"#","")
		skillDetailInfo = Tb_cfg_skill_detail[ tonumber(Sid .. subSid)]
		if skillDetailInfo then 
			temp_available_round = skillDetailInfo.available_round
		end
		retDesc = string.gsub(retDesc,"#available_round_" .. subSid .."#","#@" .. temp_available_round .. "回合" .. "@#")
	end
	
	local temp_available_hit = 0
	while retDesc:match("#available_hit_.-#")  do
		subSid = retDesc:match("#available_hit_.-#") 
		subSid = string.gsub(subSid,"available_hit_","")
		subSid = string.gsub(subSid,"#","")
		skillDetailInfo = Tb_cfg_skill_detail[ tonumber(Sid .. subSid)]
		if skillDetailInfo then 
			temp_available_hit = skillDetailInfo.available_hit
		end
		retDesc = string.gsub(retDesc,"#available_hit_" .. subSid .."#","#@" .. temp_available_hit .. "次" .. "@#")
	end
	

	-- 技能基础效果
	local init_effect_ratio = 10
	local constant_param = 10
	local intel_param = 10

	local effectValue = 0
	local effectID = 0

    --技能持续恢复 持续消耗效果
--     涉及：恢复、hot

    while retDesc:match("#effect_last_.-#")  do
        effectID = retDesc:match("#effect_last_.-#") 
        effectID = string.gsub(effectID,"effect_last_","")
        effectID = string.gsub(effectID,"#","")

        local effectDetailInfo = Tb_cfg_skill_detail[ tonumber(Sid .. effectID)]
        if effectDetailInfo then 
            init_effect_ratio = effectDetailInfo.init_effect_ratio
            constant_param = effectDetailInfo.constant_param
            intel_param = effectDetailInfo.intel_param
            
            
            effectValue = ( ( init_effect_ratio + (100-init_effect_ratio) /9*(Slv - 1) )/100 ) * (constant_param+intel_param/200*80) / 10
            effectValue = convertSpecificDecimalNum(effectValue * 10) / 10
            if effectValue > 500000 then 
                effectValue =  convertSpecificDecimalNum(effectValue/ 1000000)

            elseif (effectDetailInfo.effect_id >= 101 and effectDetailInfo.effect_id<=105) or
				(effectDetailInfo.effect_id >= 201 and effectDetailInfo.effect_id<=205) then
				effectValue = effectValue / 100
				effectValue = convertSpecificDecimalNum(effectValue)
			end
        end
		effectValue = convertSpecificDecimalNum(effectValue)
        retDesc = string.gsub(retDesc,"#effect_last_" .. effectID .."#","#@" .. effectValue .. "@#")
    end
    -- 基础效果
	while retDesc:match("#effect_.-#")  do
		effectID = retDesc:match("#effect_.-#") 
		effectID = string.gsub(effectID,"effect_","")
		effectID = string.gsub(effectID,"#","")

		local effectDetailInfo = Tb_cfg_skill_detail[ tonumber(Sid .. effectID)]
		if effectDetailInfo then 
			init_effect_ratio = effectDetailInfo.init_effect_ratio
			constant_param = effectDetailInfo.constant_param
			intel_param = effectDetailInfo.intel_param
			
			
		 	effectValue = ( ( init_effect_ratio + (100-init_effect_ratio) /9*(Slv - 1) )/100 ) * (constant_param+intel_param/200*80)

			if effectValue > 500000 then 
				effectValue =  convertSpecificDecimalNum(effectValue/ 1000000)
				-- effectValue = effectValue .. "%%"
			elseif (effectDetailInfo.effect_id >= 101 and effectDetailInfo.effect_id<=105) or
				(effectDetailInfo.effect_id >= 201 and effectDetailInfo.effect_id<=205) then
				effectValue = effectValue / 100
				effectValue = convertSpecificDecimalNum(effectValue)
			end
		end
		effectValue = convertSpecificDecimalNum(effectValue)
		retDesc = string.gsub(retDesc,"#effect_" .. effectID .."#","#@" .. effectValue .. "@#")
	end

	while retDesc:match("#%%#")  do
		retDesc = string.gsub(retDesc,"#%%#","#@%%@#")
	end
	return "#" .. retDesc .. "#"
end

-- 获取技能描述的富文本
function skillUtil.loadSkillDescRichText(Parent,Sid,Slv,needNextLv,fontSize)
    local richText = uiUtil.getConvertChildByName(Parent,"rich_text")
    if richText then 
        richText:removeFromParentAndCleanup(true)
        richText = nil
    end
    richText = RichText:create()
    richText:ignoreContentAdaptWithSize(false)
    richText:setSize(CCSizeMake(Parent:getContentSize().width,Parent:getContentSize().height))
    richText:setAnchorPoint(cc.p(0.5,1))
    richText:setPosition(cc.p(Parent:getSize().width/2,Parent:getSize().height))
    Parent:addChild(richText)
    richText:setName("rich_text")
  
  	--TODOTK 中文收集
    local str_title_1 = ""
    local str_des_1 = ""
    local str_title_2 = ""
    local str_des_2 = ""

    str_title_1 = "当前等级" .. "\n"
    str_des_1 = skillUtil.getSkillDescByLv(Sid,Slv) .. "#\n#"

    local title = RichElementText:create(1, ColorUtil.CCC_TEXT_MAIN_TITLE, 255,str_title_1 ,config.getFontName(), 20)
    -- local desc = RichElementText:create(1, ColorUtil.CCC_TEXT_MAIN_CONTENT, 255,str_des_1 ,config.getFontName(), fontSize or 22)
    richText:pushBackElement(title)
    -- richText:pushBackElement(desc)
    
    local tStr = config.richText_split(str_des_1)
    local re1 = nil
    for i,v in ipairs(tStr) do
        if v[1] == 1 then
            re1 = RichElementText:create(i, ColorUtil.CCC_TEXT_MAIN_CONTENT, 255, v[2],config.getFontName(), 18)
        else
            re1 = RichElementText:create(i, ColorUtil.CCC_RICH_TEXT_KEY_WORD, 255, v[2],config.getFontName(), 18)
        end
        richText:pushBackElement(re1)
    end
    

    
    local skillInfo = Tb_cfg_skill[Sid]

    if not needNextLv 
        or not Tb_cfg_skill_level[skillInfo.skill_quality*100 + Slv + 1] then 
        local total_str = str_title_1 .. str_des_1 .. str_title_2 .. str_des_2
        richText:formatText()
        
        return richText:getRealHeight(),richText
    end
    

    str_title_2 = "\n" .. "下一等级" .. "\n"
    str_des_2 = skillUtil.getSkillDescByLv(Sid,Slv + 1)

    title = RichElementText:create(1, ColorUtil.CCC_TEXT_MAIN_TITLE, 255, str_title_2 ,config.getFontName(), 20)
    -- desc = RichElementText:create(1, ColorUtil.CCC_TEXT_MAIN_CONTENT, 255, str_des_2 ,config.getFontName(), fontSize or 22)
    richText:pushBackElement(title)
    -- richText:pushBackElement(desc)
    
    local tStr = config.richText_split(str_des_2)
    local re1 = nil
    for i,v in ipairs(tStr) do
        if v[1] == 1 then
            re1 = RichElementText:create(i, ColorUtil.CCC_TEXT_MAIN_CONTENT, 255, v[2],config.getFontName(), 18)
        else
            re1 = RichElementText:create(i, ColorUtil.CCC_RICH_TEXT_KEY_WORD, 255, v[2],config.getFontName(), 18)
        end
        richText:pushBackElement(re1)
    end

     
    richText:formatText()
    return richText:getRealHeight(),richText
end





return skillUtil
