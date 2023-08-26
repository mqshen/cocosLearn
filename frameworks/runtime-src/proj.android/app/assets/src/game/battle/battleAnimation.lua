--动画战报播放
module("BattleAnimation", package.seeall)
local m_speed = 1
local sequenceTable  = {} --记录每一次解析是否完成
local m_roundIndex = 0 --每个武将的动作都是唯一的index
local m_battleAnimationName = {} --记录每次播放动画战报需要的序列帧名字
local m_battleNumberTable = {}
local m_scale = 2
-- 
local m_attackName = {
	["qibing_attack"] = 1,
	-- ["bubing_attack"] = 1,
	["gongbinggongji"] = 1
}

local m_beAttackName = {
	-- ["08_beigongbinggongji"] = 1,
}

local m_normalBuff = {
	["tongyong"] = 1,
}

local m_normalDebBuff = {
	-- "normal_buff" = 1,
}

function remove( )
	sequenceTable = {}
	m_speed = 1
	m_roundIndex = 0
	m_battleNumberTable = {}
end

function removeAnimationName( )
	m_battleAnimationName = {}
end

function getAnimationName(  )
	return m_battleAnimationName
end

function setSpeed( )
	if m_speed == 1 then
		m_speed = m_speed + 1
	else
		m_speed = 1
	end
	return m_speed
end

function initSpeed(  )
	m_speed = 1
end

local function setRoundIndex(index, step )
	if sequenceTable[index] then
		sequenceTable[index].finish = sequenceTable[index].finish + 1
		if sequenceTable[index].finish == sequenceTable[index].total then
			BattleAnalyse.playNext(step)
		end
	end
end

-- 通用的buff效果
local function setBuffAnimation(_scale,index, step, heroPos, strname )
	local leader = BattleAnimationController.getArmyLeader( heroPos )
	local soldier = nil
	-- CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/battle/"..strname..".ExportJson")
	if leader then
		local data = {}

		table.insert(data, {object = BattleAnimationController.getArmySoldiers(heroPos*100+1).object})

		for i, v in ipairs(leader.underIndex) do
			soldier = BattleAnimationController.getArmySoldiers(v)
			if not soldier.dead then
				if soldier.direction == 1 then
					table.insert(data, {object = soldier.object})
				else
					table.insert(data, {object = soldier.object})
				end
			end
		end

		local frameEvent = function ( node,indexCount )
			local temp_action_ = {}
			for i=2,10 do
				table.insert(temp_action_, cc.DelayTime:create(0.1))

				if i ~= 10 then
					table.insert(temp_action_, cc.CallFunc:create(function ( )
						node:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("tongyong_0"..i..".png"))
					end))
				else
					table.insert(temp_action_, cc.CallFunc:create(function ( )
						node:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("tongyong_"..i..".png"))
						node:removeFromParentAndCleanup(true)
						if indexCount==1 then
							setRoundIndex(index, step )
						end
					end))
				end
			end
			node:runAction(animation.sequence(temp_action_))
		end
		
		local child = nil
		for i, v in pairs(data) do
			child = cc.Sprite:createWithSpriteFrameName("tongyong_01.png")
			child:setAnchorPoint(cc.p(0.5,0.1))
			child:setScale(m_scale)
			v.object:addChild(child)
			child:setPosition(cc.p(v.object:getContentSize().width*v.object:getAnchorPoint().x, v.object:getContentSize().height*v.object:getAnchorPoint().y))
			frameEvent(child, i)
			
			if animationToMusic[strname] and i==1 then
				LSound.playSound(animationToMusic[strname])
			end
		end
	end
end

-- 设置骑兵或者弓兵攻击效果
local function setAttackAnimation(_scale,index, step, heroPos, strname )
	local leader = BattleAnimationController.getArmyLeader( heroPos )
	local soldier = nil
	CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/battle/"..strname..".ExportJson")
	if leader then
		local data = {}

		table.insert(data, {object = BattleAnimationController.getArmySoldiers(heroPos*100+1).object, isFlip = 1})
		if BattleAnimationController.getArmySoldiers(heroPos*100+1).direction == 2 then
			data[#data].isFlip = -1
		end

		for i, v in ipairs(leader.underIndex) do
			soldier = BattleAnimationController.getArmySoldiers(v)
			if not soldier.dead and soldier.action == "attack" then
				if soldier.direction == 1 then
					table.insert(data, {object = soldier.object, isFlip = 1})
				else
					table.insert(data, {object = soldier.object, isFlip = -1})
				end
			end
		end

		local heroData = BattleAnimationController.getHeroTarget( heroPos)
		local target = heroData.target
		local point = nil
		local armature = nil
		for i, v in ipairs(data) do
			point = v.object:getParent():convertToWorldSpace(cc.p(v.object:getPositionX(),v.object:getPositionY()+40))
			point = target:getParent():convertToNodeSpace(point)

			armature = CCArmature:create(strname)
			armature:getAnimation():playWithIndex(0)
			armature:getAnimation():setSpeedScale(armature:getAnimation():getSpeedScale()*m_speed)
			target:getParent():addChild(armature,2,2)
			armature:setPosition(point)
			armature:getAnimation():setMovementEventCallFunc(function (armatureNode, eventType, name )
				if eventType == 1 then
					armatureNode:removeFromParentAndCleanup(true)
					if i==1 then
						setRoundIndex(index, step )
					end
				end
			end)
			armature:setScaleX(_scale*v.isFlip)

			if strname == "qibing_attack" then 
				armature:setScaleY(_scale*v.isFlip)
			else
				armature:setScaleY(_scale)
			end

			if animationToMusic[strname] and i==1 then
				LSound.playSound(animationToMusic[strname])
			end
		end
	end
end

local function playAnimation( _scale,heroPos, index, step, strname, partent,pos,isGround )
	if m_attackName[strname] and heroPos then
		setAttackAnimation(_scale,index, step, heroPos, strname )
		return
	end
	-- if true and heroPos then
	if m_normalBuff[strname] and heroPos then
		setBuffAnimation(_scale,index, step, heroPos, strname)
		return
	end

	-- strname = "beitishen"
	-- strname = "shanghaiguibi"
	CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/battle/"..strname..".ExportJson")
	local armature = CCArmature:create(strname)
	armature:getAnimation():playWithIndex(0)
	armature:getAnimation():setSpeedScale(armature:getAnimation():getSpeedScale()*m_speed)
	if isGround then
		partent:addChild(armature,-1,-1)
	else
		partent:addChild(armature,2,2)
	end

	armature:setScale(_scale) 
	armature:setPosition(pos)

	-- 替身和伤害规避技能特殊处理
	if (strname == "beitishen" or strname == "shanghaiguibi") and heroPos then
		if BattleAnimationController.getArmySoldiers(heroPos*100+1).direction == 1 then
			armature:setPosition(cc.p(pos.x+28, pos.y+30))
		else
			armature:setPosition(cc.p(pos.x-28, pos.y-10))
		end
	end

	--受到弓兵攻击的特效
	if strname == "gongbingshouji" and heroPos then
		local leader = BattleAnimationController.getLeaderInfo( heroPos )
		if leader.isSelf then
			armature:setScaleX(-1*_scale)
		end
	end

	armature:getAnimation():setMovementEventCallFunc(function (armatureNode, eventType, name )
		if eventType == 1 then
			armature:removeFromParentAndCleanup(true)
			if strname == "kaishi" then
				BattleAnalyse.setWarFlag( )
				BattleAnimationController.beginAi()
			end
			setRoundIndex(index, step )
		end
	end)

	if animationToMusic[strname] then
		LSound.playSound(animationToMusic[strname])
	end
end

local function getRealAnimationName( effectStr)
	local arrEffectName = stringFunc.anlayerOnespot(effectStr,";",false)

	local targetToLeader = nil --效果放在武将lead身上，跟随移动
	local targetToGround = nil --效果放在地面上，不移动, 在兵的下层
	local targetToGroundUp = nil --效果放在地面上，不移动, 在兵的上层

	local len = nil
	local effectName = nil
	local str = nil
	for i, v in ipairs(arrEffectName) do
		len = string.len(v)
		effectName = string.sub(v, 1, len-2)
		str = string.sub(v, len, len)
		if str == "1" then
			targetToGroundUp = effectName
		elseif str == "2" then
			targetToLeader = effectName
		else
			-- targetToLeader = "08_beigongbinggongji"--effectName
			targetToGround = effectName
		end
	end

	return targetToLeader, targetToGround, targetToGroundUp
end

--武将挂了的效果
local function displayHeroDie(index,step, heroPos )
	local heroData = BattleAnimationController.getHeroTarget( heroPos)
	if not heroData then
		print(">>>>>>>>>displayHeroDie>>>>>>>>>>>> hero pos ="..heroPos.."  is nil")
		return false
	end

	local target = heroData.target

	target:runAction(animation.sequence({cc.DelayTime:create(0.5/m_speed), cc.CallFunc:create(function ( )
		BattleAnimationController.setHeroDie(heroPos)
		setRoundIndex(index, step )
	end)}))
end

--播放数字效果
local function displayNumEffect( index,step, heroPos, num, colorStr, str, iAciton )
	local tempNum = ""
	if str then
		local len = string.len(str)
		if string.sub( str,len,len) == "%" then
			tempNum = string.sub( str,1,len-1)..num.."%"
		else
			tempNum = str..num
		end
	else
		tempNum = num
	end

	local heroData = BattleAnimationController.getHeroTarget( heroPos)
	if not heroData then
		print(">>>>>>>>>>>>>>>>>>>>> hero pos ="..heroPos.."  is nil")
		return false
	end

	local temp_hero_name = nil
	if heroData.heroid then
		temp_hero_name = "【"..Tb_cfg_hero[heroData.heroid].name.."】"
	end

	local target = heroData.target

	-- 攻击距离改变的时候
	if iAciton == 36 then
		BattleAnimationController.skillChangeEffectCount(heroPos, tonumber(num))
	elseif iAciton == 43 then
		BattleAnimationController.skillChangeEffectCount(heroPos, -tonumber(num))
	end

	local moveDis = 40
	local layerColor = nil
	if colorStr then
		--损失兵力                     --增加兵力
		if colorStr == "!" or colorStr == "#" then
			if colorStr == "!" then
				BattleAnimationController.setArmyCount( heroPos, -tonumber(num))
			else
				BattleAnimationController.setArmyCount( heroPos, tonumber(num))
			end
		end

		-- 增益效果
		if colorStr == "+" or colorStr == "#" then
			-- textLayer:setColor(ccc3(0,255,0))
			layerColor = ccc3(0,255,0)
		-- debuff效果
		else
			moveDis = -1*moveDis
			-- textLayer:setColor(ccc3(255,0,0))
			layerColor = ccc3(255,0,0)
		end
	end

	local textLayer = nil
	local heroNameLayer = nil
	-- if heroData.heroid then
		
	-- end
	local temp = nil--
	temp = Label:create()
	temp:setFontSize(20)
	-- local temp_width_ = temp:getSize().width
	if heroData.isSelf then
		temp:setText(tempNum)
		textLayer = CCLabelTTF:create(tempNum,config.getFontName(), 20, CCSize(600, 31), kCCTextAlignmentRight)
		textLayer:setPosition(cc.p(target:getPositionX()- heroData.small_icon:getSize().width*0.5,target:getPositionY()+target:getContentSize().height))
		textLayer:setAnchorPoint(cc.p(1,0.5))

		heroNameLayer = CCLabelTTF:create(temp_hero_name,config.getFontName(), 20, CCSize(600, 31), kCCTextAlignmentRight)
		heroNameLayer:setPosition(cc.p(-temp:getSize().width,0))
		heroNameLayer:setAnchorPoint(cc.p(0,0))
	else
		temp:setText(temp_hero_name)
		textLayer = CCLabelTTF:create(tempNum,config.getFontName(), 20, CCSize(600, 31), kCCTextAlignmentLeft)
		textLayer:setPosition(cc.p(target:getPositionX()+temp:getSize().width+ heroData.small_icon:getSize().width*0.5,target:getPositionY()+target:getContentSize().height))
		textLayer:setAnchorPoint(cc.p(0,0.5))

		heroNameLayer = CCLabelTTF:create(temp_hero_name,config.getFontName(), 20, CCSize(600, 31), kCCTextAlignmentRight)
		-- heroNameLayer:setPosition(cc.p(,0))
		heroNameLayer:setAnchorPoint(cc.p(1,0))
	end
	heroNameLayer:setColor(layerColor)
	heroNameLayer:enableStroke(ccc3(0,0,0),2,true)
	textLayer:addChild(heroNameLayer)
	target:getParent():addChild(textLayer,3,3)
	textLayer:setColor(layerColor)
	textLayer:enableStroke(ccc3(0,0,0),2,true)

	-- target:getParent():addChild(heroNameLayer,3,3)
	-- heroNameLayer:setColor(layerColor)
	-- heroNameLayer:enableStroke(ccc3(0,0,0),2,true)

	--恢复兵力或者损失兵力不用等到飘完字再解析下一条，等待很短的时间就可以解析下一条
	if colorStr and (colorStr == "!" or colorStr == "#" or colorStr == "+" ) then
		local action = nil
		action = animation.spawn({CCFadeOut:create(1/m_speed), CCMoveBy:create(1/m_speed, ccp(0,moveDis))})

		textLayer:runAction(animation.sequence({cc.DelayTime:create(1/m_speed),action, cc.CallFunc:create(function ( )
			textLayer:removeFromParentAndCleanup(true)
			if m_battleNumberTable[heroPos] then
				if moveDis > 0 then
					table.remove(m_battleNumberTable[heroPos].useful, 1)
				else
					table.remove(m_battleNumberTable[heroPos].hurt, 1)
				end
			end
		end)}))

		textLayer:runAction(animation.sequence({cc.DelayTime:create(0.5/m_speed), cc.CallFunc:create(function ( )
			setRoundIndex(index, step )
		end)}))

		if not m_battleNumberTable[heroPos] then
			m_battleNumberTable[heroPos] = { hurt = {}, useful = {}}
		end

		local num =0
		local lastText = nil
		if moveDis > 0 then
			num = #m_battleNumberTable[heroPos].useful
			lastText = m_battleNumberTable[heroPos].useful
		else
			num = #m_battleNumberTable[heroPos].hurt
			lastText = m_battleNumberTable[heroPos].hurt
		end

		local dis = nil
		if #lastText > 0 then
			local k = 0
			for i=#lastText, 1,-1 do
				k = k+1
				dis = math.abs(textLayer:getPositionY()- lastText[i]:getPositionY())
				if dis < k*31 then
					if moveDis then
						lastText[i]:setPositionY(lastText[i]:getPositionY() + (k*31-dis))
					else
						lastText[i]:setPositionY(lastText[i]:getPositionY() - (k*31-dis))
					end
				end
			end
		end
		
		if moveDis > 0 then
			table.insert(m_battleNumberTable[heroPos].useful, textLayer)
		else
			table.insert(m_battleNumberTable[heroPos].hurt, textLayer)
		end
		
	else
		local action = animation.spawn({CCFadeOut:create(1/m_speed), CCMoveBy:create(1/m_speed, ccp(0,moveDis))})
		textLayer:runAction(animation.sequence({action, cc.CallFunc:create(function ( )
			textLayer:removeFromParentAndCleanup(true)
			setRoundIndex(index, step )
		end)}))

		--todo 如果是buff，那么所有小兵都要加上效果动画
	end
end

--播放效果
local function displayEffect(index,step,heroPos, effectStr)
	-- setRoundIndex(index, step )
	local heroData = BattleAnimationController.getHeroTarget( heroPos)
	if not heroData then
		print(">>>>>>>>>>>>>>>Effect>>>>>> hero pos ="..heroPos.."  is nil")
		return false
	end

	if not effectStr then 
		print(">>>>>>>>>>>>>>>Effect>>>>>is nil")
		return false 
	end

	local target = heroData.target
	local targetToLeader, targetToGround,targetToGroundUp = getRealAnimationName( effectStr)
	local heroLeader = BattleAnimationController.getLeaderInfo( heroPos )
	local point = heroLeader.object:getParent():convertToWorldSpace(cc.p(heroLeader.object:getPositionX(),heroLeader.object:getPositionY()))
	local scale = nil
	if targetToLeader then
		scale = m_scale*BattleAnimationController.getScale( )/config.getgScale()
		playAnimation( scale,heroPos,index, step, targetToLeader, heroData.node,heroData.node:convertToNodeSpace(point),false )
	end

	if targetToGroundUp then
		-- local heroLeader = BattleAnimationController.getLeaderInfo( heroPos )
		-- local point = heroLeader.object:getParent():convertToWorldSpace(cc.p(heroLeader.object:getPositionX(),heroLeader.object:getPositionY()))
		scale =m_scale*BattleAnimationController.getScale( )/config.getgScale()
		playAnimation( scale,heroPos,index, step, targetToGroundUp, target:getParent(), target:getParent():convertToNodeSpace(point), true )
	end

	if targetToGround then
		scale =m_scale
		-- local heroLeader = BattleAnimationController.getLeaderInfo( heroPos )
		-- local point = heroLeader.object:getParent():convertToWorldSpace(cc.p(heroLeader.object:getPositionX(),heroLeader.object:getPositionY()))
		playAnimation( scale,heroPos,index, step, targetToGround, BattleAnimationController.getArmyLayer(), BattleAnimationController.getArmyLayer():convertToNodeSpace(point), true )
	end
end

--播放序列帧
local function displayAnimationName(index,step,heroPos, animationName)
	local heroData = BattleAnimationController.getHeroTarget( heroPos)
	local target = nil
	local nodeSpace = nil
	--当不存在heropos的时候，认为是播放与武将无关的序列帧，譬如战斗开始，战斗结束之类
	if not heroData then
		target = BattleAnimationController.getInstance()
	else
		target = heroData.target
	end

	if not target then
		print(">>>>>>>>>>>>>>>>>target nil")
		return
	end

	local targetToLeader, targetToGround,targetToGroundUp = getRealAnimationName( animationName)
	local scale = nil
	if targetToLeader then
		local heroLeader = BattleAnimationController.getLeaderInfo( heroPos )
		scale = m_scale*BattleAnimationController.getScale( )/config.getgScale()
		local point = heroLeader.object:getParent():convertToWorldSpace(cc.p(heroLeader.object:getPositionX(),heroLeader.object:getPositionY()))
		playAnimation( scale,heroPos,index, step, targetToLeader, heroData.node,heroData.node:convertToNodeSpace(point) )
	end

	if targetToGround then
		if not heroData then
			return
		end
		scale = m_scale*BattleAnimationController.getScale( )/config.getgScale()
		local heroLeader = BattleAnimationController.getLeaderInfo( heroPos )
		local point = heroLeader.object:getParent():convertToWorldSpace(cc.p(heroLeader.object:getPositionX(),heroLeader.object:getPositionY()))
		playAnimation( scale,heroPos,index, step, targetToGround, BattleAnimationController.getArmyLayer(), BattleAnimationController.getArmyLayer():convertToNodeSpace(point), true )
	end

	if targetToGroundUp then
		-- print(">>>>>>>>>>>>>>>>targetToGround ="..targetToGround)
		if targetToGroundUp == "pingju" or targetToGroundUp == "huosheng" or targetToGroundUp == "zhanbai" then
			BattleAnimationController.setEndAnalisy(targetToGroundUp)
			setRoundIndex(index, step )
		else
			local point = nil
			if heroData then
				local heroLeader = BattleAnimationController.getLeaderInfo( heroPos )
				point = heroLeader.object:getParent():convertToWorldSpace(cc.p(heroLeader.object:getPositionX(),heroLeader.object:getPositionY()))
				point = target:getParent():convertToNodeSpace(point)
				-- armature:setPosition(target:getParent():convertToNodeSpace(point))
			else
				point = target:getParent():convertToWorldSpace(cc.p(config.getWinSize().width*0.5,config.getWinSize().height*0.5))
				-- armature:setPosition(point)
			end
			scale = m_scale*BattleAnimationController.getScale( )
			playAnimation( scale,heroPos, index, step, targetToGroundUp, target:getParent(), point )
		end
	end
end

local function betterSkillPlay(index,step,heroPos,skillId)
	local heroData = BattleAnimationController.getHeroTarget(heroPos)
	local target = heroData.target:getParent()
	local leader = BattleAnimationController.getLeaderInfo( heroPos )
	-- model.skillAction:setVisible(true)
	local text = Tb_cfg_skill[skillId].name
	local function heroCallback( )
		local heroSprite =  cc.Sprite:create("gameResources/card/card_"..leader.heroid..".png")--
		local textLayer = CCLabelTTF:create(text,config.getFontName(), 50, CCSize(600, 60), kCCTextAlignmentCenter, kCCVerticalTextAlignmentBottom)
		local colorLayer = cc.LayerColor:create(cc.c4b(0,0,0,100),config.getWinSize().width, config.getWinSize().height)

		if leader.isSelf then
			CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/battle/blue_26_kapaitexie.ExportJson")
		else
			CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/battle/26_kapaitexie.ExportJson")
		end

		local armature = nil
		local card_name = nil
		if leader.isSelf then
			-- card_name = "blue_battle_effect.png"
			armature = CCArmature:create("blue_26_kapaitexie")
		else
			-- card_name = "battle_effect.png"
			armature = CCArmature:create("26_kapaitexie")
		end
		armature:getAnimation():playWithIndex(0)
		armature:getAnimation():setSpeedScale(armature:getAnimation():getSpeedScale()*m_speed)
		armature:getAnimation():setFrameEventCallFunc(function ( bone, frameName )
			if frameName == "removeCard" then
				heroSprite:removeFromParentAndCleanup(true)
				textLayer:removeFromParentAndCleanup(true)
				armature:getAnimation():setMovementEventCallFunc(function (armatureNode, eventType, name)
					if eventType == 1 then
						armatureNode:removeFromParentAndCleanup(true)
						colorLayer:removeFromParentAndCleanup(true)
						setRoundIndex(index, step )
					end
				end)
			end
		end)

		-- armature:getAnimation():setMovementEventCallFunc(function (armatureNode, eventType, name)
		-- 	if eventType == 1 then
		-- 		armatureNode:removeFromParentAndCleanup(true)
		-- 		setRoundIndex(index, step )
		-- 	end
		-- end)

		local layerpoint = nil
		layerpoint = target:convertToNodeSpace(cc.p(config.getWinSize().width*0.5, config.getWinSize().height*0.5))
		armature:setPosition(layerpoint)
		target:addChild(armature,6,6)
		armature:setScale(m_scale*2)
		-- 
		-- local point
		local num = 1
		textLayer:setAnchorPoint(cc.p(0.5,0.5))
		if not leader.isSelf then
			num = -1
			layerpoint = target:convertToNodeSpace(cc.p(config.getWinSize().width*3/11, config.getWinSize().height*0.2))
			point = target:convertToNodeSpace(cc.p(0, config.getWinSize().height/2))
			heroSprite:setAnchorPoint(cc.p(1,0.5))
		else
			layerpoint = target:convertToNodeSpace(cc.p(config.getWinSize().width*8/11, config.getWinSize().height*0.2))
			point = target:convertToNodeSpace(cc.p(config.getWinSize().width, config.getWinSize().height/2))
			heroSprite:setAnchorPoint(cc.p(0,0.5))
		end
		heroSprite:setPosition(cc.p(point.x, point.y ))
		target:addChild(heroSprite,4,4)

		textLayer:setPosition(layerpoint)
		target:addChild(textLayer,7,7)

		-- armature:setScale(heroSprite:getContentSize().height/armature:getContentSize().height)

		colorLayer:setScale(1/config.getgScale())
		target:addChild(colorLayer,3,3)
		colorLayer:setAnchorPoint(0,0)
		colorLayer:runAction(CCFadeTo:create(0.3/m_speed,200))

		local tempPoint1 = target:convertToNodeSpace(cc.p(0 ,0))
		colorLayer:setPosition(tempPoint1)
		local tempPoint2 = target:convertToNodeSpace(cc.p(config.getWinSize().width ,0))
		local heroAction1 = CCMoveBy:create(0.1/m_speed, ccp(-num*(tempPoint2.x-tempPoint1.x)*0.822,0))
		heroSprite:runAction(heroAction1)
		LSound.playSound(animationToMusic["battle_card"])
	end
	local action1 = cc.DelayTime:create(0.1/m_speed)
	local action2 = cc.CallFunc:create(function ( )
		-- model.skillAction:setVisible(false)
		heroCallback()
	end)
	target:runAction(animation.sequence({action1, action2--[[,action3,action4]]}))
end

-- 播放技能特效
local function displaySkillName(index,step,heroPos, skillId, iAciton)
	-- setRoundIndex(index, step )
	local text = Tb_cfg_skill[skillId].name
	local heroData = BattleAnimationController.getHeroTarget( heroPos)
	if not heroData then
		print(">>>>>>>>>SkillName>>>>>>>>>>>> hero pos ="..heroPos.."  is nil")
		return false
	end

	local target = heroData.target


	local textLayer = nil
	local armature = nil
	local heroLeader = BattleAnimationController.getLeaderInfo( heroPos )
	
	local card = cardFrameInterface.create_small_card(nil,heroLeader.heroid , false)

	local position = heroPos
	local battle_id = BattlaAnimationData.getBattleId()
	local battleReport = reportData.getReport(battle_id)
	if position <= 4 then 
        if battleReport.attack_advance then
            cardFrameInterface.doSetAdvancedDetail(card, battleReport.attack_advance[position][1], Tb_cfg_hero[heroLeader.heroid].quality+1,battleReport.attack_advance[position][2] == 1)
        end
    else
        if battleReport.defend_advance then
            cardFrameInterface.doSetAdvancedDetail(card, battleReport.defend_advance[position-4][1], Tb_cfg_hero[heroLeader.heroid].quality+1,battleReport.defend_advance[position-4][2] == 1)
        end
    end

	cardFrameInterface.set_lv_images(heroData.level,card)
	card:setAnchorPoint(cc.p(0.5,0))
	target:getParent():addChild(card,3,3)
	card:setPosition(cc.p(target:getPositionX(), target:getPositionY()))
	if Tb_cfg_skill[skillId].skill_quality >=4 and iAciton ~= actionDefine.playPrepare and iAciton ~= actionDefine.playPrepareing then
		textLayer = CCLabelTTF:create("",config.getFontName(), 24, CCSize(600, 32), kCCTextAlignmentCenter, kCCVerticalTextAlignmentBottom)
		CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/battle/03_jinengshiyong.ExportJson")
		armature = CCArmature:create("03_jinengshiyong")
		textLayer:setPosition(cc.p(card:getSize().width*0.5,card:getSize().height*0.5))
	else
		textLayer = CCLabelTTF:create(text,config.getFontName(), 24, CCSize(600, 32), kCCTextAlignmentCenter, kCCVerticalTextAlignmentBottom)
		if not heroData.isSelf then
			CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/battle/jinengmingred.ExportJson")
			armature = CCArmature:create("jinengmingred")
		else
			CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/battle/jinengmingblue.ExportJson")
			armature = CCArmature:create("jinengmingblue")
		end
		textLayer:enableStroke(ccc3(0,0,0),2,true)
		textLayer:setPosition(cc.p(card:getSize().width*0.5,card:getSize().height))
	end
	textLayer:setAnchorPoint(cc.p(0.5,0))
	armature:getAnimation():playWithIndex(0)
	armature:getAnimation():setSpeedScale(armature:getAnimation():getSpeedScale()*m_speed)
	textLayer:addChild(armature,-1)
	if Tb_cfg_skill[skillId].skill_quality >=4 and iAciton ~= actionDefine.playPrepare and iAciton ~= actionDefine.playPrepareing then
		armature:setPosition(cc.p(textLayer:getContentSize().width/2,-5+textLayer:getContentSize().height/2))
	else
		armature:setPosition(cc.p(textLayer:getContentSize().width/2,textLayer:getContentSize().height/2))
	end
	armature:setScale(m_scale)
	card:addChild(textLayer)

	local action = CCFadeOut:create(0.5/m_speed)--animation.spawn({CCFadeOut:create(0.6/m_speed), CCMoveBy:create(0.6/m_speed, ccp(0,20))})
	target:setVisible(false)
	card:runAction(animation.sequence({cc.DelayTime:create(1),cc.CallFunc:create(function ( )
		-- 放大招
		if Tb_cfg_skill[skillId].skill_quality >=4 and iAciton ~= actionDefine.playPrepare and iAciton ~= actionDefine.playPrepareing then
			betterSkillPlay(index,step,heroPos,skillId)
		else
			setRoundIndex(index, step )
		end
	end),action, cc.CallFunc:create(function ( )
		card:removeFromParentAndCleanup(true)
		target:setVisible(true)
	end)}))
end

--step 是每一行解析标志，return回去作为判断是否结束
function create( arrTmp, step, isBeforePlay)
	m_roundIndex = m_roundIndex + 1
	local index = m_roundIndex
	local iHeroIndex = 0
	local num = ""--如果有数字，这个就是数字的大小
	local colorStr = "" --数字的颜色
	local strNormalAttack = nil --如果有被普攻的特效，这个字段代表特效的名字
	local heroPos = nil --英雄的位置
	local isH = false --Hero
	local isD = false --数字
	local isS = false --是否有技能名字要显示，可能要显示施放的技能名字
	local isP = false --被枪兵，骑兵，弓兵攻击播放不同的特效
	local isE = false --是否有效果
	local effectId = nil --效果id
	local effectStr = nil --效果对应的特效名
	local skillId = nil --技能id, 用于找到技能名字，然后显示

	local arrEffectName = nil
	local isDie = nil --是否武将挂了

	local addAnimationName = function (name )
		local arrName = stringFunc.anlayerOnespot(name,";",false)
		for i, v in ipairs(arrName) do
			m_battleAnimationName[string.sub(v, 1, string.len(v)-2)] = 1
		end
		return #arrName
	end

	local iAciton = tonumber(arrTmp[1])

	sequenceTable[index] = {total = 0, finish = 0}
	local animationName = warRoundKeyword[iAciton][3] --将要播放的序列帧的名字
	if animationName == "" then
		animationName = nil
	end

	if animationName then
		arrEffectName = stringFunc.anlayerOnespot(animationName,";",false)
		sequenceTable[index].total = sequenceTable[index].total + #arrEffectName
	end

	local arrNum = warRoundKeyword[iAciton][2]
	arrNum = stringFunc.anlayerOnespot(arrNum, ";", false)

	local mod = tonumber(arrNum[1]) --模式 有1,2,3,4,5等等

	local tempStr = nil
	for i,v in ipairs(arrNum) do
		local str = string.sub(v,1,1)
		if str == "H" then
			isH = true
			heroPos = tonumber(arrTmp[tonumber(string.sub(v,2,2))+1]+1)
			sequenceTable[index].total = sequenceTable[index].total + 1
		elseif str == "D" then
			isD = true
			num = tonumber(arrTmp[tonumber(string.sub(v,2,2))+1])
			if effectNumber[iAciton] then
				tempStr = effectNumber[iAciton]
			else
				tempStr = ""
				num = num
			end
			sequenceTable[index].total = sequenceTable[index].total + 1
			colorStr =string.sub(v,3,3)
		elseif str == "S" then
			isS = true
			skillId = tonumber(arrTmp[tonumber(string.sub(v,2,2))+1])
			sequenceTable[index].total = sequenceTable[index].total + 1
		elseif str == "P" then
			strNormalAttack = skillSelect[iAciton][tonumber(arrTmp[tonumber(string.sub(v,2,2))+1])]
			if strNormalAttack then
				isP = true
				arrEffectName = stringFunc.anlayerOnespot(strNormalAttack,";",false)

				sequenceTable[index].total = sequenceTable[index].total + #arrEffectName
			end
		elseif str == "E" then
			effectId = tonumber(arrTmp[tonumber(string.sub(v,2,2))+1])
			effectStr = effectName[effectId]
			if effectStr then
				isE = true
				arrEffectName = stringFunc.anlayerOnespot(effectStr,";",false)
				sequenceTable[index].total = sequenceTable[index].total + #arrEffectName
			end
		end
	end
	--只有当数字，技能，特效全部播放完成，才算一个解析的结束

	-- 
	-- local tempStr = ""
	if mod ~= "" then
		sequenceTable[index].total = sequenceTable[index].total + 1
		-- 6:直接显示预设文字和数字
		if mod == 6 and not isD then
			isD = true
			if effectNumber[iAciton] then
				tempStr = effectNumber[iAciton]
			else
				tempStr = ""
				num = num
			end
			colorStr = "+"
			sequenceTable[index].total = sequenceTable[index].total + 1
		--武将挂了
		elseif mod == 8 then
			-- displayHeroDie(index,step, heroPos )
			isDie = true
			sequenceTable[index].total = sequenceTable[index].total + 1
		end
		setRoundIndex(index, step )
	end

	if isH then
		setRoundIndex(index, step )
	end

	local count = 0
	if isP then
		if not isBeforePlay then
			displayEffect(index,step,heroPos, strNormalAttack)
		else
			-- m_battleAnimationName[strNormalAttack] = 1
			count = addAnimationName(strNormalAttack)
			for i=1, count do
				setRoundIndex(index, step )
			end
		end
	end

	--播放效果的特效
	if isE then
		if not isBeforePlay then
			displayEffect(index,step,heroPos, effectStr)
		else
			-- m_battleAnimationName[effectStr] = 1
			count = addAnimationName(effectStr)
			for i=1, count do
				setRoundIndex(index, step )
			end
		end
	end

	-- 播放序列帧
	if animationName then
		if isBeforePlay then
			-- m_battleAnimationName[animationName] = 1
			count = addAnimationName(animationName)
			for i=1, count do
				setRoundIndex(index, step )
			end
		else
			displayAnimationName(index,step,heroPos, animationName)
		end
	end

	--播放数字动作
	if isD then
		if isBeforePlay then
			setRoundIndex(index, step )
		else
			displayNumEffect( index,step,heroPos, num, colorStr, tempStr,iAciton )
		end
	end

	--播放技能名字，如果是需要读条的技能，还要加入播放特殊效果
	if isS then
		if isBeforePlay then
			setRoundIndex(index, step )
		else
			displaySkillName(index,step,heroPos, skillId, iAciton)
		end
	end

	if isDie then
		if isBeforePlay then
			setRoundIndex(index, step )
		else
			displayHeroDie(index,step,heroPos)
		end
	end
end