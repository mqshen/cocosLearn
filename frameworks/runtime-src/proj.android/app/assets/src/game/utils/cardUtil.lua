local cardUtil = {}

--------- 暂时只用来播放技能操作特效
function cardUtil.playArmatureOnce(file,parent,posX,posY,needFloating)
    if not parent then return end
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/" .. file ..".ExportJson")
    local armature = CCArmature:create(file)
    
    
    armature:getAnimation():playWithIndex(0)
    parent:addChild(armature,2,2)
    if not posX or not posY then 
    	posX = parent:getContentSize().width/2
    	posY = parent:getContentSize().height/2
    end
    armature:setPosition(cc.p( posX, posY ))

    local function animationCallFunc(armatureNode, eventType, name)
        if eventType == 1 then
        	if armature then 
            	armatureNode:removeFromParentAndCleanup(true)
            	armature = nil
            end
        end
    end
    -- local function animationFrameFunc(...)
    -- 	print(">>>>>>>>>>>> animationFrameFunc")
    -- end
    -- armature:getAnimation():setFrameEventCallFunc(animationFrameFunc)
    if needFloating then 
		local action1 = cc.DelayTime:create(0.1)
		local action2 = CCMoveBy:create(1,ccp(0, 50*1*config.getgScale()))
		local action3 = cc.CallFunc:create(function ( )
		    if armature then
		        armature:removeFromParentAndCleanup(true)
		        armature = nil
		    end
		end)
		armature:runAction(animation.sequence({action1,action2, action3}))
	end
    
    armature:getAnimation():setMovementEventCallFunc(animationCallFunc)
    
end


-- 根据卡牌ID获取配置的可获得的称号ID列表
function cardUtil.getConfigTitleListByCardId(Cid)
	local ret = {}
	for k,cfgInfo in pairs(Tb_cfg_army_title) do 
		
		if cfgInfo.heroid_1 == Cid or 
			cfgInfo.heroid_2 == Cid or 
			cfgInfo.heroid_3 == Cid then
			table.insert(ret,k)
		end
	end
	return ret
end

function cardUtil.getConfiTitleHeroNames(Tid)
	if not Tb_cfg_army_title[Tid] then return "" end 
	local hero_id = 0
	local base_hero_info = nil
	local ret = ""
	for i = 1,3 do 
		hero_id = Tb_cfg_army_title[Tid]["heroid_" .. i]
		base_hero_info = Tb_cfg_hero[hero_id] 
		if base_hero_info then 
			
			if i == 1 then 
				ret = ret .. base_hero_info.name 
			else
				ret = ret .. "、" .. base_hero_info.name 
			end
		end
	end
	return ret
end


local function getHeroTitleName(hero_id)
	local basic_hero_info = Tb_cfg_hero[hero_id]
	return basic_hero_info.name .. "（" .. countryNameDefine[basic_hero_info.country] .. "）"
end

function cardUtil.getTitleInfo(cid)
	local titleList = cardUtil.getConfigTitleListByCardId(cid)
	local titleListInfo = {}
	local titleInfo = nil
	local basic_hero_info = nil
	local hero_num = 0

	for k, titleId in ipairs(titleList) do 
		titleInfo = Tb_cfg_army_title[titleId]
		titleListInfo[titleInfo.title] = {}
		hero_num = 0
		if titleInfo.heroid_1 ~= 0 then 
			hero_num = hero_num + 1
		end
		if titleInfo.heroid_2 ~= 0 then 
			hero_num = hero_num + 1
		end
		if titleInfo.heroid_3 ~= 0 then 
			hero_num = hero_num + 1
		end
		titleListInfo[titleInfo.title]["heronum"] = hero_num
		titleListInfo[titleInfo.title]["id"] = titleId
		titleListInfo[titleInfo.title]["skillId"] = titleInfo.skill_id
	end

	for titleName,titleValue in pairs( titleListInfo ) do 
		titleListInfo[titleName]["heronames"] = {}
		for k, cfgTitleInfo in pairs(Tb_cfg_army_title) do 
			if cfgTitleInfo.title == titleName then 
				if cfgTitleInfo.heroid_1 ~= 0 then 
					basic_hero_info = Tb_cfg_hero[cfgTitleInfo.heroid_1] 
					if not titleListInfo[titleName]["heronames"][basic_hero_info.name] then 
						titleListInfo[titleName]["heronames"][basic_hero_info.name] = {}
					end
					titleListInfo[titleName]["heronames"][basic_hero_info.name][basic_hero_info.country] =  countryNameDefine[basic_hero_info.country]
				end
				if cfgTitleInfo.heroid_2 ~= 0 then 
					basic_hero_info = Tb_cfg_hero[cfgTitleInfo.heroid_2] 
					if not titleListInfo[titleName]["heronames"][basic_hero_info.name] then 
						titleListInfo[titleName]["heronames"][basic_hero_info.name] = {}
					end
					titleListInfo[titleName]["heronames"][basic_hero_info.name][basic_hero_info.country] =  countryNameDefine[basic_hero_info.country]
				end
				if cfgTitleInfo.heroid_3 ~= 0 then 
					basic_hero_info = Tb_cfg_hero[cfgTitleInfo.heroid_3] 
					if not titleListInfo[titleName]["heronames"][basic_hero_info.name] then 
						titleListInfo[titleName]["heronames"][basic_hero_info.name] = {}
					end
					titleListInfo[titleName]["heronames"][basic_hero_info.name][basic_hero_info.country] =  countryNameDefine[basic_hero_info.country]
				end

			end
		end
	end
	-- for k,v in pairs(titleListInfo) do 
	-- 	print(">>>>>>>>>>>>>>>>",k,v["heronum"])
	-- 	for kk,vv in pairs(v["heronames"]) do 
	-- 		print(">>>>>>>",kk,vv)
	-- 		for kkk,vvv in pairs(vv) do 
	-- 			print(">>>",vvv)
	-- 		end
	-- 	end
	-- end
	return titleListInfo
end

return cardUtil
