--战报解析
-- local report = nil
-- local team = {} --攻防双方的属性
-- local result = nil --结果 2 输， 1 赢

-- local round = {} --每回合的内容
local m_topDisplayInfo = {} --首先显示的信息 
local m_sumDisplayInfo_top = {} --动画战报统计的时候显示顶部信息
local m_sumDisplayInfo_res = {} --动画战报统计的时候显示资源信息
local m_sumDisplayInfo_down = {} --动画战报统计的时候显示底部信息
-- local m_recordHeroLevelIndex = {} --记录获得经验的武将的ipos
local m_arrHeroName = {}
local s_arrPosName = {"军师","大本营","中军","前军","前军","中军","大本营","军师"}
local m_bPlay = nil
-- local roundDeail = {}

--放在最前面显示的，譬如结果，是否占领之类的
local m_definedIndex = {}
for i, v in ipairs ({218,128,129,236,239,131,132,133,226}) do
	m_definedIndex[v] = 1
end
--需要陈总发的定义被替换掉的
local m_replace_index = {}
for i, v in ipairs ({138,139,140,141,209,137}) do
	m_replace_index[v] = 1
end
--根据看战报的一方定义不同的 譬如把"对方"替换成“我方”
local m_replace_attact = {}
for i, v in ipairs ({127,206,233,207,130}) do
	m_replace_attact[v] = 1
end
--防守方不要显示的
local m_unVisible_def = {}
for i, v in ipairs ({134,235}) do
	m_unVisible_def[v] = 1
end

local m_expIndex = nil

--显示的建筑类效果
local displayEffect = {}
for i, v in ipairs({295091,295092,295093,295094,295095,295106,295107,295001,295002,295003,295004,295005,295006,295007,295008,295009,295010,295011,295012,295013,295014,295015,295016,295017,295018,295019,295020,295021,295022,295023,295024,295025,295026,295027,295028,295029,295030,295031,295032,295033,295034,295035,295036,295037,295038,295039,295040,295041,295042,295043,295044,295045,295046,295047,295048,295049,295050}) do
	displayEffect[v] = 1
end

local function setHeroName(ipos, strName)
	if strName == nil or strName == " " or strName == "null" then
		strName = s_arrPosName[ipos+1]
	end
	m_arrHeroName[ipos+1] = Tb_cfg_hero[tonumber(strName)].name
end

local function getHeroName( iPos,battleId )
	local temp = m_arrHeroName[iPos+1]
	-- if not temp then temp = "" end
	local battleData = reportData.getReport(battleId)
	if not battleData then return end
	if iPos < 4 then
		--攻方 不是自己		
		if not reportData.returnAttackOrDefend( battleData) then
			if not temp then
				return "$-3$"
			else
				return "$-3$" .. "~【"..temp.."】~"
			end
		--攻方 是自己
		else
			if not temp then
				return "$-1$"
			else
				return "$-1$" .. "^【"..temp.."】^"
			end
		end
	else
		--守方 是自己
		if not reportData.returnAttackOrDefend( battleData) then 
			if not temp then
				return "$-2$"
			else
				return "$-2$" .. "^【"..temp.."】^"
			end
		else
			if not temp then
				return "$-4$"
			else 
				return "$-4$" .. "~【"..temp.."】~"
			end
		end
	end
end

local function getSkillName(iSkillId )
	if Tb_cfg_skill[iSkillId] then
		return Tb_cfg_skill[iSkillId].name
	end
	return "S"..iSkillId
end

local function getEffectName(iEffectId)
	if Tb_cfg_skill_effect[iEffectId] then
		return Tb_cfg_skill_effect[iEffectId].name
	end
	return "E"..iEffectId
end

local function replaceStr( strTemplate, arrTmp,id, iAction)
	local index = 1
	local temp = nil
	local s_iPos = nil
	local level = nil
	local _d = nil
	local battleReport = reportData.getReport(id)
	local info = string.gsub(strTemplate, "%a", function (n)
					if not arrTmp[index] then return " " end
		      		if n =="h" then
		        		local iPos = tonumber(arrTmp[index])
						index = index + 1
						-- if iPos < 4 then
						-- 	return "$-1$"--"#("..languagePack["gong"]..")#"
						-- else
						-- 	return "$-2$"--"#("..languagePack["shou"]..")#"
						-- end
						if iPos < 4 then
							--攻方 不是自己		
							if not reportData.returnAttackOrDefend( battleReport) then 
								return "$-3$"
							--攻方 是自己
							else
								return "$-1$"
							end
						else
							--守方 是自己
							if not reportData.returnAttackOrDefend( battleReport) then 
								return "$-2$"
							else
								return "$-4$"
							end
						end
		      		elseif n == "H" then
		      			s_iPos = tonumber(arrTmp[index])
		        		temp = getHeroName(tonumber(arrTmp[index]),id)
						index = index + 1
						return temp
					elseif n == "S" then
						temp = getSkillName(tonumber(arrTmp[index]))
						_d = tonumber(arrTmp[index])
						index = index + 1
						return temp
					elseif n == "E" then
						temp = getEffectName(tonumber(arrTmp[index]))
						index = index + 1
						return temp
					elseif n == "D" then
						level = arrTmp[index]
						temp = arrTmp[index]
						index = index + 1
						return temp
					elseif n == "p" or n=="t" or n== "c" then
						index = index + 1
						return " "
					else
						return n
		      		end
	    		end)

	
	if _d and math.floor(_d/1000) == 295 and not displayEffect[_d] then
		return false
	end

	if iAction == actionDefine.getExpCount then
		if reportData.returnAttackOrDefend( battleReport) then 
			if s_iPos then
				table.insert(m_topDisplayInfo, {info, iAction, s_iPos})
				table.insert(m_sumDisplayInfo_down, {info, iAction})
				m_expIndex[s_iPos] = {#m_topDisplayInfo, #m_sumDisplayInfo_down}
			end
		end
		return false
	elseif iAction == actionDefine.unionexp then
		table.insert(m_topDisplayInfo, {info, iAction})
		table.insert(m_sumDisplayInfo_down, {info, iAction})
		return false
	elseif iAction == actionDefine.levelUp then

		if reportData.returnAttackOrDefend( battleReport) then 
				for i, v in pairs(m_expIndex) do
					if i == s_iPos then
						local tempStr = string.gsub(warRoundKeyword[actionDefine.herolevel][1], "D", function (n)
											return level
										end)
						m_topDisplayInfo[v[1]][1] = m_topDisplayInfo[v[1]][1]..tempStr
						m_sumDisplayInfo_down[v[2]][1] = m_sumDisplayInfo_down[v[2]][1]..tempStr
						break
					end
				end
		end
		return false
	elseif iAction == actionDefine.armyAfter then
		table.insert(m_topDisplayInfo,{info,iAction} )
		return false
	end
	return info
end

--详细内容分割
local function parseReportAtom( strReport, attack_userid,id)
	local index = 1
	
	if string.len(strReport) <= 0 then
		return false
	end
	
	local arrTmp = stringFunc.anlayerOnespot(strReport, ",", false)
	local temp_arr = {}--stringFunc.anlayerOnespot(strReport, ",", false)
	table.insert(temp_arr,arrTmp)
	local iAction = tonumber(arrTmp[index])
	BattlaAnimationData.initBattleData(temp_arr[1])

	index = index+1
	if iAction>=500 then return false end
	local strTemplate= warRoundKeyword[iAction][1]
	local temp = nil
	local battleReport = reportData.getReport(id)
	if m_definedIndex[iAction] then
		table.insert(m_topDisplayInfo,{replaceStr( strTemplate, {arrTmp[index]},id, iAction), iAction})
		table.insert(m_sumDisplayInfo_top, {replaceStr( strTemplate, {arrTmp[index]},id, iAction), iAction})
		return false
	end

	if m_replace_index[iAction] then
		
		if not REPORT_ACT_[battleReport.result] then return false end
		local replace_str = nil
	    local temp_name = battleReport.wid_name
	    if not battleReport.wid_name or battleReport.wid_name == "" then
	        temp_name = landData.get_city_name_when_happened(battleReport.wid)
	    end
	    -- WIN_NO_RESULT = 1, SUC_OCCP = 2, UNION_OCCP = 3, FUSHU = 4, JIEJIU = 5
	    if REPORT_ACT_[battleReport.result] then
	        if iAction == 137 or iAction == 139 or iAction == 138 or iAction == 140 then
	                replace_str = temp_name.."("..math.floor(battleReport.wid/10000)..","..(battleReport.wid%10000)..")"
	        else
	            if reportData.returnAttackOrDefend(battleReport ) then
	                replace_str = battleReport.defend_name
	            else
	                replace_str = battleReport.attack_name
	            end
	        end
	    end
		local temp_str = nil
	    local _flag = true
	    local chengfang = nil
	    -- local temp_strIndex = nil
	    if iAction == 137 then
		   	local info = string.gsub(warRoundKeyword[iAction][1], "%a", function (n)
		    								if n == "D" then
		    									chengfang = arrTmp[index]
		    								end
										end)
		   	-- if REPORT_ACT_
		   	-- temp_strIndex = REPORT_ACT_[1]--warRoundKeyword[iAction][1]
	    end

	    if reportData.returnAttackOrDefend( battleReport) then 
	        if REPORT_ACT_[battleReport.result] then
	            local index_ = 1
	            local _ar = REPORT_ACT_[battleReport.result]
	            if iAction == 137 then
	            	_ar = REPORT_ACT_[1]
	            end

	            if iAction == 140 then
	            	_ar = languagePack["demolish_battle"]
	            end
	            
	            temp_str = string.gsub(_ar, "d", function (n)
	                if index_ == 1 then
	                    index_ = index_ + 1
	                    return replace_str
	                else
	                    if not chengfang then
	                        _flag = false
	                    end
	                    return chengfang
	                end
	            end)
	        end
	    else
	        if REPORT_DEF_[battleReport.result] then
	            local index_ = 1
	            local _ar = REPORT_DEF_[battleReport.result]
	            if iAction == 137 then
	            	_ar = REPORT_DEF_[1]
	            end
	            temp_str = string.gsub(_ar, "d", function (n)
	                if index_ == 1 then
	                    index_ = index_ + 1
	                    return replace_str
	                else
	                    if not chengfang then
	                        _flag = false
	                    end
	                    return chengfang
	                end
	            end)
	        end
	    end
	    if temp_str and _flag then
	        -- readReport(temp_str,0)
	        table.insert(m_topDisplayInfo,{temp_str,0})
	        table.insert(m_sumDisplayInfo_top, {temp_str,0})
	    end

		return false
	end

	-- {127,206,233,207,130}
	if m_replace_attact[iAction] then
		local _temp = warRoundKeyword[iAction][1]
		local temp_action = iAction
		if iAction == 127 and not reportData.returnAttackOrDefend( battleReport) then
			_temp = warRoundKeyword[207][1]
			temp_action = 207
		end

		if iAction == 206 and not reportData.returnAttackOrDefend( battleReport) then
			_temp = warRoundKeyword[232][1]
			temp_action = 232
		end

		if iAction == 233 and not reportData.returnAttackOrDefend( battleReport) then
			_temp = warRoundKeyword[234][1]
			temp_action = 234
		end

		if iAction == 207 and not reportData.returnAttackOrDefend( battleReport) then
			_temp = warRoundKeyword[127][1]
			temp_action = 127
		end

		--要叫策划添加一个定义
		if iAction == 130 and not reportData.returnAttackOrDefend( battleReport) then
			_temp = warRoundKeyword[240][1]
			temp_action = 240
		end

		table.insert(m_topDisplayInfo,{replaceStr( _temp, {arrTmp[index]},id, temp_action), temp_action})
	    table.insert(m_sumDisplayInfo_top, {replaceStr( _temp, {arrTmp[index]},id, temp_action), temp_action})
		return false
	end

	if m_unVisible_def[iAction] then
		if reportData.returnAttackOrDefend( battleReport) then
			table.insert(m_topDisplayInfo,{replaceStr( strTemplate, {arrTmp[index]},id, iAction), temp_action})
		    table.insert(m_sumDisplayInfo_top, {replaceStr( strTemplate, {arrTmp[index]},id, iAction), temp_action})
		end
		return false
	end

	if iAction == actionDefine.initArmy then--初始化
		for i = 2,table.getn(arrTmp),2 do
			setHeroName(tonumber(arrTmp[i]),arrTmp[i+1])
			-- return false
		end
		return false
	
	-- RES_ID_WOOD = 1;
	-- RES_ID_STONE = 2;
	-- RES_ID_IRON = 3;
	-- RES_ID_FOOD = 4;
	-- RES_ID_MONEY = 5;// 1表示木材，2石头，3铁块，4粮食，5钱
	-- RES_ID_RES_TYPE = 6;// 资源类
	-- RES_ID_EXP = 7;// 经验
	-- RES_ID_HERO = 8;// 英雄
	-- RES_ID_ITEM = 9;// 道具
	-- RES_ID_RULE_POINT = 10;// 统治点
	-- RES_ID_RENOWN = 11;// 名望
	-- RES_ID_COUPON = 12;// 礼券
	-- RES_ID_YUAN_BAO = 99;// 元宝
	elseif iAction ==actionDefine.getResources then --获取资源
		if not reportData.returnAttackOrDefend( battleReport) then 
			return false,iAction
		end
		local listRet = "#"..languagePack["huode"].."#"
		local heroList = nil
		for i = 2,table.getn(arrTmp),2 do
			local iResIdU = tonumber(arrTmp[i])
			local iResId = iResIdU%100
			local iCount = tonumber(arrTmp[i+1])
			if iResId ~= dropType.RES_ID_HERO and iResId ~= dropType.RES_ID_ITEM and iResId ~= dropType.RES_ID_CARD_EXTRACT then
				listRet = listRet.."$"..iResId.."$".."# "..clientConfigData.getDorpCount(iResIdU, iCount).."##,# "
				table.insert(m_sumDisplayInfo_res, {"$"..iResId.."$".."@ "..clientConfigData.getDorpName( iResIdU ).."@".."# "..clientConfigData.getDorpCount(iResIdU, iCount).."#", iAction})
			elseif iResId == dropType.RES_ID_HERO then
				local iHeroId = math.floor(iResIdU/100)
				if not heroList then
					heroList = "#"..languagePack["huode"].."#"
				end
				heroList = heroList.."#"..Tb_cfg_hero[iHeroId].name.." "..clientConfigData.getDorpCount(iResIdU, iCount).."##,# "
				table.insert(m_sumDisplayInfo_res, {"@ "..Tb_cfg_hero[iHeroId].name.."@ #"..clientConfigData.getDorpCount(iResIdU, iCount).."#", iAction})
			elseif iResId == dropType.RES_ID_CARD_EXTRACT then
				listRet = listRet.."#"..clientConfigData.getDorpName( iResIdU ).."@ #"..clientConfigData.getDorpCount(iResIdU, iCount).."##,# "
				table.insert(m_sumDisplayInfo_res, {"@ "..clientConfigData.getDorpName( iResIdU ).." "..clientConfigData.getDorpCount(iResIdU, iCount).."#", iAction})
			elseif iResId == dropType.RES_ID_ITEM then

			end
		end

		local info_list = string.sub(listRet,1,string.len(listRet)-4)
		table.insert(m_topDisplayInfo,{info_list,iAction})
		if heroList then
			table.insert(m_topDisplayInfo,{string.sub(heroList,1,string.len(heroList)-4),iAction})
		end
		return false,iAction
	elseif iAction == actionDefine.wounded_soldier then
		return false
	elseif iAction >= 500 then
		return false
	elseif iAction == actionDefine.parallelBegin or iAction == actionDefine.normalParallelBegin then
		m_bPlay = true
		return false
	elseif iAction == actionDefine.parallelEnd or iAction == actionDefine.normalParallelEnd then
		m_bPlay = false
		return false
	elseif iAction == actionDefine.animationBattle then
		return false
	else
		--忽略的战报
		if iAction == 2 then
			return "#\n\n#",2
		end

		if iAction == 11 then
			return "#\n\n#",11
		end
		if ignoreReport[iAction] then return false end

		if m_bPlay then
			strTemplate = "#     #"..strTemplate
		end

		--效果在技能连续播放范围内，不显示释放的技能名和施放者
		if continuousSkill[iAction] and m_bPlay and iAction ~= actionDefine.effectDisappear then
			local temp = {}
			for i, v in ipairs(continuousSkill[iAction]) do
				if i ~= 1 then
					table.insert(temp, arrTmp[v+1])
				end
			end
			return replaceStr("#     #"..continuousSkill[iAction][1],temp,id,iAction ),iAction
		end

		--物理伤害、谋略伤害、直接恢复、驱散和祝福效果消失条目在技能连续播放范围内不显示	
		--效果代号分别为301,302,401,512,513
		-- if iAction == actionDefine.effectDisappear and m_bPlay
		-- 	and (tonumber(arrTmp[5]) == 301 or tonumber(arrTmp[5]) == 302 
		-- 		or tonumber(arrTmp[5]) == 401 or tonumber(arrTmp[5]) == 512 or tonumber(arrTmp[5]) == 513) then
		-- 	return false
		-- end

		--0 立即结算
		-- if iAction == actionDefine.effectNow and tonumber(arrTmp[4]) == 0 then
		-- 	return false
		-- end

		local temp = {}
		for i, v in ipairs(arrTmp) do
			if i >= index then
				table.insert(temp, v)
			end
		end

		return replaceStr(strTemplate,temp,id,iAction ),iAction
	end
end

local function analyze(text,attack_userid, defend_userid,id )
	m_arrHeroName = {}
	m_topDisplayInfo = {}
	m_sumDisplayInfo_top = {}
	m_sumDisplayInfo_res = {}
	m_sumDisplayInfo_down = {}
	-- m_recordHeroLevelIndex = {}
	m_bPlay = false
	m_expIndex = {}
	local detailReport = {}
	local reportText = tostring(text)
	local roundDeail = {}
	BattlaAnimationData.clearBattleData()
	BattlaAnimationData.setBattleId(id)
	local eachRound = stringFunc.anlayerOnespot(reportText, "#", false)
	for i, v in ipairs(eachRound) do
		if v then
			local str,iAction = parseReportAtom(v,attack_userid,id)
			if str then
				table.insert(roundDeail,{tostring(str),iAction})
			end
		end
	end
	BattlaAnimationData.setArmyInfo()
	
	return roundDeail,m_topDisplayInfo
end

-- 获取动画战报上部显示的内容
local function getSumResultTop( )
	return m_sumDisplayInfo_top
end

-- 获取动画战报资源的内容
local function getSumResource( )
	return m_sumDisplayInfo_res
end

--获取动画战报底部显示的内容
local function getSumResultDown( )
	return m_sumDisplayInfo_down
end

local function remove( )
	m_sumDisplayInfo_res = nil
	m_arrHeroName = nil
	m_topDisplayInfo = nil
	m_sumDisplayInfo_top = nil
	m_sumDisplayInfo_down = nil
	-- m_recordHeroLevelIndex = nil
	m_bPlay = nil
	m_expIndex = nil
	-- roundDeail = nil
end

reportInfo = {
				analyze = analyze,
				remove = remove,
				getSumResultTop = getSumResultTop,
				getSumResource = getSumResource,
				getSumResultDown = getSumResultDown
			}