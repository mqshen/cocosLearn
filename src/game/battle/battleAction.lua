--战报动画中用到的动作
local dt = 1
local d_prepareSkill = "02_jinengzhunbei"
local m_over = true

--是否卡牌发亮
local function isLight( index,isUp )
	--防止是军师放技能
	if BattlaAnimationUI.getLightImage(index) then
		if not isUp then
			if not BattlaAnimationUI.getHeroIsBeatback(index) then
				BattlaAnimationUI.getLightImage(index):setVisible(true)
			end
		else
			BattlaAnimationUI.getLightImage(index):setVisible(false)
		end
	end
end

--往上或者往上的动作
local function upOrDownAction(target,flag,isUp,index,number,hero)
	local function upActionCallFunc( )
		--isS 当要播放技能名字时，等待技能名字特效播放完
		if flag or hero then
			-- BattlaAnimationUI.setArrCardFlag(index, not isUp)
			BattlaAnimationUI.playAnimationByCallback(hero)
		end
	end
	if index == 1 or index == 8 then
		if not isUp then
			upActionCallFunc( )
		else
			-- target:runAction(CCFadeOut:create(0.5*dt))
		end
		return
	end

	local totalScale = BattlaAnimationUI.getNormalScale(index)
	local scale = (isUp == false and 1.1*totalScale) or totalScale
	local time = (isUp and 0.07*dt) or 0.03*dt
	local h
	if isUp then
		h = BattlaAnimationUI.getInitPos(index)
	else
		h = BattlaAnimationUI.getInitPos(index)+ number*target:getContentSize().height*0.1
	end
	local action = CCMoveTo:create(time, ccp(target:getPositionX(),h))
	local action1 = CCScaleTo:create(time, scale)
	local actionFinish = animation.spawn({action,action1})
	target:runAction(animation.sequence({actionFinish,cc.CallFunc:create(upActionCallFunc)}))
end

--target:动作的目标，flag：是否是动作的结束 index：武将在m_arrCard数据结构中的index
local function downActionOrUpAction(target,flag,index,hero )
	local isUp = BattlaAnimationUI.getArrCardFlag(index)
	if not BattlaAnimationUI.isAboveLine(index) then
		upOrDownAction(BattlaAnimationUI.getArrCard(index),flag, isUp,index,(isUp and -1) or 1,hero)
	else
		upOrDownAction(BattlaAnimationUI.getArrCard(index),flag, isUp,index,(isUp and 1) or -1,hero)
	end
	isLight( index,isUp)
end

--飘数字动作
local function displayNum( iHeroIndex,target,text,flag,hero,colorStr,iAciton )
	local str = nil
	if effectNumber[iAciton] then
		str =effectNumber[iAciton]..text
	else
		str = text
	end

	local textLayer = CCLabelTTF:create(str,config.getFontName(), 35, CCSize(600, 50), kCCTextAlignmentCenter)
	local function callback( )
		textLayer:removeFromParentAndCleanup(true)
		if flag or hero then
			BattlaAnimationUI.playAnimationByCallback(hero)
		end
	end
	textLayer:setAnchorPoint(cc.p(0.5,0.5))
	if colorStr then
		if colorStr == "!" then
			BattlaAnimationUI.setArmyCount( iHeroIndex, text, false)
		end

		if colorStr == "#" then
			BattlaAnimationUI.setArmyCount( iHeroIndex, text, true)
		end

		if colorStr == "+" or colorStr == "#" then
			textLayer:setColor(ccc3(0,255,0))
		else
			textLayer:setColor(ccc3(255,0,0))
		end
	end
	target:addChild(textLayer,3,3)
	textLayer:setPosition(cc.p(target:getContentSize().width/2,target:getContentSize().height/2))
	local action = animation.spawn({CCFadeOut:create(0.6*dt), CCMoveBy:create(0.6*dt, ccp(0,target:getContentSize().height*0.1))})
	textLayer:runAction(animation.sequence({action, cc.CallFunc:create(callback)}))
end

--播放查表的特效 target:目标 file:动画文件名字 flag:是否是结束动作, isBeforeNum:是否在动画后播数字
--num:飘的数字
-- iHeroIndex,strEffect,flag, nil,nil,nil,iAciton,hero,colorStr
local function playAnimation( iHeroIndex,file,flag, isBeforeNum, num, isflag,iAciton,hero,colorStr)
	local target = BattlaAnimationUI.getArrCard(iHeroIndex)
	-- local isUp = BattlaAnimationUI.getArrCardFlag(iHeroIndex)
	-- local m_bAbove = BattlaAnimationUI.isAboveLine(iHeroIndex)
	local function afterAnimationFun(tempFlag )
		if flag or (hero and not isBeforeNum) then
			BattlaAnimationUI.playAnimationByCallback(hero)
		end

		if isBeforeNum then
			displayNum( iHeroIndex,target,num,isflag,hero,colorStr,iAciton)
		end
	end

	local function animationCallFunc(armature, eventType, name)
		if eventType == 1 then
			if file ~= d_prepareSkill then
				armature:removeFromParentAndCleanup(true)
			end
			if BattlaAnimationUI.allHeroBecomeInit() then
				target:runAction(animation.sequence({cc.DelayTime:create(0.1*dt),cc.CallFunc:create(function ( )
					afterAnimationFun(false)
				end)}))
			else
				afterAnimationFun(true)
			end
		end
	end

	if animationToMusic[file] then
		LSound.playSound(animationToMusic[file])
	end

	if file then
		if BattlaAnimationUI.getRootWidget() then
			if file == d_prepareSkill and BattlaAnimationUI.getPrepareSkill(iHeroIndex) then
				if BattlaAnimationUI.allHeroBecomeInit() then
					target:runAction(animation.sequence({cc.DelayTime:create(0.1*dt),cc.CallFunc:create(afterAnimationFun)}))
				else
					afterAnimationFun()
				end
				return
			end
			local armature = CCArmature:create(file)

		    armature:getAnimation():playWithIndex(0)
		    armature:getAnimation():setSpeedScale(armature:getAnimation():getSpeedScale()/dt)
		    local pointWorld = target:convertToWorldSpace(cc.p(target:getContentSize().width/2,target:getContentSize().height/2))
		    local point = BattlaAnimationUI.getRootWidget():convertToNodeSpace(cc.p(pointWorld.x,pointWorld.y))
		    BattlaAnimationUI.getRootWidget():addChild(armature,2,2)
		    armature:setPosition(cc.p(point.x, point.y))
		    if file ~= d_prepareSkill then
		   		armature:getAnimation():setMovementEventCallFunc(animationCallFunc)
		   	else
		   		BattlaAnimationUI.setPrepareSkill(iHeroIndex, armature)
		   		armature:runAction(animation.sequence({cc.DelayTime:create(0.3*dt), cc.CallFunc:create(function ( )
		   			if BattlaAnimationUI.allHeroBecomeInit() then
						target:runAction(animation.sequence({cc.DelayTime:create(0.1*dt),cc.CallFunc:create(afterAnimationFun)}))
					else
						afterAnimationFun()
					end
		   		end)}))
		   	end
		end
	else
		afterAnimationFun()
	end

    if iAciton == actionDefine.normalAttack or colorStr == "!" then
    	local action = CCScaleTo:create(0.1*dt, 0.9)
   		local action1 = CCScaleTo:create(0.1*dt, 1)
    	target:runAction(animation.sequence({action,action1,}))
    end
end

local function shakeEffect( )
	local function displayLack( )
		local textLayer = CCLabelTTF:create(languagePack["julibuzu"],config.getFontName(), 40, CCSize(400, 60), kCCTextAlignmentCenter)
		textLayer:setColor(ccc3(255,0,0))
		local function callback1( )
			textLayer:removeFromParentAndCleanup(true)
		end
		textLayer:setAnchorPoint(cc.p(0.5,0.5))
		BattlaAnimationUI.getRootWidget():addChild(textLayer,3,3)
		textLayer:setPosition(cc.p(BattlaAnimationUI.getRootWidget():getContentSize().width/2,BattlaAnimationUI.getRootWidget():getContentSize().height/2))
		textLayer:runAction(animation.sequence({CCFadeOut:create(1*dt), cc.CallFunc:create(callback1)}))
	end

	local moveLeft=CCMoveBy:create(0.02*dt, ccp(-10, 0)) 
	local moveRight=CCMoveBy:create(0.02*dt, ccp(10,0)) 
	local action= animation.sequence({moveLeft,moveRight})
	return animation.spawn({cc.CallFunc:create(displayLack),CCRepeat:create(action,1)})
	-- return --CCRepeat:create(action1,1) 
end

local function shakeAction( iHeroIndex,flag,index,hero)
	local target = BattlaAnimationUI.getArrCard(iHeroIndex)
	local isUp = BattlaAnimationUI.getArrCardFlag(iHeroIndex)
	local function afterFun( )
		if flag or hero then
			isLight(iHeroIndex,true)
			m_over = true
			BattlaAnimationUI.playAnimationByCallback(hero)
		end
	end

	local function afterShakeFunc( )
		if BattlaAnimationUI.allHeroBecomeInit() then
			target:runAction(animation.sequence({cc.DelayTime:create(0.1*dt),cc.CallFunc:create(afterFun)}))
		else
			afterFun()
		end
	end

	local function cardUpFunc( )
		downActionOrUpAction(target,false,index,hero )
		BattlaAnimationUI.setArrCardFlag(index, true)
	end
	isLight(iHeroIndex,isUp)
	-- target:runAction(animation.sequence({cc.CallFunc:create(cardUpFunc),cc.DelayTime:create(0.5*dt),
		-- shakeEffect(),cc.DelayTime:create(0.5*dt),cc.CallFunc:create(afterShakeFunc)}))
	m_over = false
	target:runAction(animation.sequence({shakeEffect(),cc.DelayTime:create(0.3*dt),cc.CallFunc:create(afterFun)}))
end

local function nothingTodo(iHeroIndex,flag,index,hero )
	local target = BattlaAnimationUI.getArrCard(iHeroIndex)
	local function callbackFunc( )
		if flag or hero then
			BattlaAnimationUI.playAnimationByCallback(hero)
		end
	end
	local function nothingFunC( )
		if BattlaAnimationUI.allHeroBecomeInit() then
			target:runAction(animation.sequence({cc.DelayTime:create(0.1*dt),cc.CallFunc:create(callbackFunc)}))
		else
			callbackFunc()
		end
	end
	target:runAction(animation.sequence({shakeEffect(),cc.DelayTime:create(0.3*dt),
		cc.CallFunc:create(callbackFunc)}))
end

local function betterSkillPlay( index, flag, hero, isplayAnima, file, iAciton, colorStr, skillid)
	local model = BattlaAnimationUI.getHeroTarget(index)
	model.skillAction:setVisible(true)

	local function heroCallback( )
		local isAbove = BattlaAnimationUI.isAboveLine(index)
		local heroSprite =  cc.Sprite:create("gameResources/card/card_"..model.heroid..".png")--
		local armature = CCArmature:create("26_kapaitexie")
		armature:getAnimation():playWithIndex(0)
		armature:getAnimation():setSpeedScale(armature:getAnimation():getSpeedScale()/dt)
		armature:getAnimation():setMovementEventCallFunc(function (armatureNode, eventType, name)
			if eventType == 1 then
				armatureNode:removeFromParentAndCleanup(true)
			end
		end)
		-- 
		local point
		local num = 1
		local black_eff = cc.Sprite:createWithSpriteFrameName("effect.png")
		if isAbove then
			num = -1
			point = BattlaAnimationUI.getRootWidget():convertToNodeSpace(cc.p(0, config.getWinSize().height/2))
			heroSprite:setAnchorPoint(cc.p(1,0.5))
			black_eff:setAnchorPoint(cc.p(666/960, 327/640))
			black_eff:setPosition(cc.p(heroSprite:getContentSize().width/2, heroSprite:getContentSize().height/2))
			armature:setAnchorPoint(cc.p(0,0.5))
		else
			point = BattlaAnimationUI.getRootWidget():convertToNodeSpace(cc.p(config.getWinSize().width, config.getWinSize().height/2))
			heroSprite:setAnchorPoint(cc.p(0,0.5))
			armature:setAnchorPoint(cc.p(0,0.5))
			black_eff:setFlipX(true)
			black_eff:setPosition(cc.p(heroSprite:getContentSize().width/2+180, heroSprite:getContentSize().height/2))
		end
		heroSprite:setPosition(cc.p(point.x, point.y ))
		BattlaAnimationUI.getRootWidget():addChild(heroSprite,4,4)

		heroSprite:addChild(black_eff)
		heroSprite:addChild(armature)
		armature:setScaleY(heroSprite:getContentSize().height/armature:getContentSize().height)

		if isAbove then
			armature:setPosition(cc.p(heroSprite:getContentSize().width , heroSprite:getContentSize().height/2))
			armature:setScaleX(-config.getWinSize().width*0.9/armature:getContentSize().width)
		else
			armature:setPosition(cc.p(heroSprite:getContentSize().width , heroSprite:getContentSize().height/2))
			armature:setScaleX(config.getWinSize().width*0.9/armature:getContentSize().width)
		end
		local colorLayer = cc.LayerColor:create(cc.c4b(0,0,0,100),config.getWinSize().width, config.getWinSize().height)
		BattlaAnimationUI.getRootWidget():addChild(colorLayer,3,3)
		colorLayer:runAction(CCFadeTo:create(0.3*dt,200))

		local tempPoint1 = BattlaAnimationUI.getRootWidget():convertToNodeSpace(cc.p(0 ,0))
		local tempPoint2 = BattlaAnimationUI.getRootWidget():convertToNodeSpace(cc.p(config.getWinSize().width ,0))
		local heroAction1 = CCMoveBy:create(0.2*dt, ccp(-num*(tempPoint2.x-tempPoint1.x)*0.9,0))
		local heroAction2 = cc.DelayTime:create(0.5*dt)
		local heroAction3 = cc.CallFunc:create(function ( )
			heroSprite:removeFromParentAndCleanup(true)
			colorLayer:removeFromParentAndCleanup(true)
			--如果在技能准备，要删除准备技能的特效
			local name =BattlaAnimationUI.getIsPerpare(index)
			local object = BattlaAnimationUI.getPrepareSkill(index)
			if name and skillid and name == skillid and object 
				and iAciton ~= actionDefine.playPrepare and iAciton ~= actionDefine.playPrepareing then
				object:removeFromParentAndCleanup(true)
				BattlaAnimationUI.setIsPerpare(index, nil)
				BattlaAnimationUI.setPrepareSkill(index, nil)
			end
			if not isplayAnima then
				downActionOrUpAction(model.target,flag,index,hero)
				BattlaAnimationUI.setArrCardFlag(index, true)
			else
				playAnimation(index,file,flag, nil,nil,nil,iAciton,hero,colorStr)
			end
		end)
		heroSprite:runAction(animation.sequence({heroAction1,heroAction2, heroAction3}) )
	end
	local action1 = cc.DelayTime:create(0.1*dt)
	local action2 = cc.CallFunc:create(function ( )
		model.skillAction:setVisible(false)
		heroCallback()
	end)
	model.skillAction:runAction(animation.sequence({action1, action2--[[,action3,action4]]}))
end

	--技能名， 是否是动作结束
local function displaySkillName(isplayAnima,skillid,target,flag,iHeroIndex,hero,file,iAciton,colorStr)
	local text = Tb_cfg_skill[skillid].name
	if iAciton == actionDefine.playPrepare or iAciton == actionDefine.playPrepareing then
		text = text..languagePack["zhunbeizhong"]
		BattlaAnimationUI.setIsPerpare(iHeroIndex, skillid)
	end


	local textLayer = CCLabelTTF:create(text,config.getFontName(), 30, CCSize(200, 30), kCCTextAlignmentCenter)
	textLayer:setColor(ccc3(255,0,0))
	local function skillanimationCallFunc(armatureNode, eventType, name)
		if eventType == 1 then
			textLayer:removeFromParentAndCleanup(true)
			armatureNode:removeFromParentAndCleanup(true)
			if Tb_cfg_skill[skillid].skill_quality >=4 and iAciton ~= actionDefine.playPrepare and iAciton ~= actionDefine.playPrepareing then
				betterSkillPlay( iHeroIndex, flag, hero, isplayAnima, file, iAciton, colorStr,skillid)
			else
				--如果在技能准备，要删除准备技能的特效
				local name =BattlaAnimationUI.getIsPerpare(iHeroIndex)
				local object = BattlaAnimationUI.getPrepareSkill(iHeroIndex)
				if name and name == skillid and object 
					and iAciton ~= actionDefine.playPrepare and iAciton ~= actionDefine.playPrepareing then
					object:removeFromParentAndCleanup(true)
					BattlaAnimationUI.setIsPerpare(iHeroIndex, nil)
					BattlaAnimationUI.setPrepareSkill(iHeroIndex, nil)
				end
				if not isplayAnima then
					downActionOrUpAction(target,flag,iHeroIndex,hero)
					BattlaAnimationUI.setArrCardFlag(iHeroIndex, true)
				else
					playAnimation(iHeroIndex,file,flag, nil,nil,nil,iAciton,hero,colorStr)
				end
			end
		end
	end
	textLayer:setAnchorPoint(cc.p(0.5,0.5))

	local armature = CCArmature:create("03_jinengshiyong")
	armature:getAnimation():playWithIndex(0)
	armature:getAnimation():setSpeedScale(armature:getAnimation():getSpeedScale()/dt)
	target:addChild(armature,2,2)
	if BattlaAnimationUI.isAboveLine(iHeroIndex) then
		armature:setPosition(cc.p(target:getContentSize().width/2, -armature:getContentSize().height/2))
	else
		armature:setPosition(cc.p(target:getContentSize().width/2, target:getContentSize().height+armature:getContentSize().height/2))
	end
	armature:getAnimation():setMovementEventCallFunc(skillanimationCallFunc)
	
	armature:addChild(textLayer)
	textLayer:runAction(CCFadeOut:create(2*dt))
end

local function analyzeStr(arrNum, mod, arrTmp , flag,hero)
	local iHeroIndex = 0
	local num = 0
	local colorStr = ""
	local strSkill = nil
	local isH = false
	local isD = false
	local isS = false
	local iAciton = tonumber(arrTmp[1])

	for i,v in ipairs(arrNum) do
		local str = string.sub(v,1,1)
		if str == "H" then
			isH = true
		elseif str == "D" then
			isD = true
			num = tonumber(arrTmp[tonumber(string.sub(v,2,2))+1])
			colorStr =string.sub(v,3,3)
		elseif str == "S" then
			isS = true
		elseif str == "P" then
			strSkill = skillSelect[iAciton][tonumber(arrTmp[tonumber(string.sub(v,2,2))+1])]
		end
	end

	for i, v in ipairs(arrNum) do
		if i~=1 then
			local str = string.sub(v,1,1)
			local index = tonumber(string.sub(v,2,2))
			if str == "H" then
				iHeroIndex = tonumber(arrTmp[index+1])+1
				--标记反击
				if iAciton == actionDefine.beatBack then
					BattlaAnimationUI.setHeroIsBeatback(iHeroIndex, true)
				end

				if mod == 1 then
					if (iAciton == actionDefine.passiveSkill or iAciton ==actionDefine.playSkillBefore
					or iAciton == actionDefine.playSkillAfter or iAciton == actionDefine.playAttack
					or iAciton == actionDefine.playPrepare or iAciton == actionDefine.playPrepareing) and isS then
						local temp = tonumber(string.sub(arrNum[i+1],2,2))
						displaySkillName(false,tonumber(arrTmp[temp+1]), BattlaAnimationUI.getArrCard(iHeroIndex),flag,iHeroIndex,hero,warRoundKeyword[tonumber(arrTmp[1])][3],iAciton,colorStr)
					else
						downActionOrUpAction(BattlaAnimationUI.getArrCard(iHeroIndex),flag,iHeroIndex,hero)
						BattlaAnimationUI.setArrCardFlag(iHeroIndex, true)
					end
					break
				elseif mod == 2 then
					downActionOrUpAction(BattlaAnimationUI.getArrCard(iHeroIndex),flag,iHeroIndex,hero)
					BattlaAnimationUI.setArrCardFlag(iHeroIndex, false)
				elseif mod == 3 then
					if isD then
						playAnimation(iHeroIndex,warRoundKeyword[tonumber(arrTmp[1])][3],false,true,num,flag,iAciton,hero,colorStr)
						break
					else
						if (iAciton == actionDefine.passiveSkill or iAciton ==actionDefine.playSkillBefore
						or iAciton == actionDefine.playSkillAfter or iAciton == actionDefine.playAttack
						or iAciton == actionDefine.playPrepare or iAciton == actionDefine.playPrepareing
						or iAciton == actionDefine.playInterrupt) and isS then
							if iAciton == actionDefine.playInterrupt then
								local name =BattlaAnimationUI.getIsPerpare(iHeroIndex)
								local object = BattlaAnimationUI.getPrepareSkill(iHeroIndex)
								local temp = tonumber(string.sub(arrNum[i+1],2,2))
								if name and name == tonumber(arrTmp[temp+1]) and object then
									object:removeFromParentAndCleanup(true)
									BattlaAnimationUI.setIsPerpare(iHeroIndex, nil)
									BattlaAnimationUI.setPrepareSkill(iHeroIndex, nil)
								end
								if flag or hero then
									BattlaAnimationUI.playAnimationByCallback(hero)
								end
							else
								local temp = tonumber(string.sub(arrNum[i+1],2,2))
								displaySkillName(true,tonumber(arrTmp[temp+1]),BattlaAnimationUI.getArrCard(iHeroIndex),flag,iHeroIndex,hero,warRoundKeyword[tonumber(arrTmp[1])][3],iAciton,colorStr )
							end
						else
							playAnimation(iHeroIndex,warRoundKeyword[tonumber(arrTmp[1])][3],flag, nil,nil,nil,iAciton,hero,colorStr)
						end
						break
					end
					-- else
					-- 	-- target,file,flag, isBeforeNum, num, isflag, index
					-- 	playAnimation(iHeroIndex,warRoundKeyword[tonumber(arrTmp[1])][3],flag, nil,nil,nil,iAciton,hero,colorStr)
					-- end
				elseif mod == 4 then
					shakeAction(iHeroIndex,flag,iHeroIndex,hero)
					break
				elseif mod == 5 then
					nothingTodo(iHeroIndex,flag,iHeroIndex,hero)
					break
				elseif mod == 6 then
					displayNum(iHeroIndex,BattlaAnimationUI.getArrCard(iHeroIndex),num,flag,hero,colorStr,iAciton)
					break
				elseif mod == 7 then
					if isD then
						playAnimation(iHeroIndex,strSkill,false,true,num,flag,iAciton,hero,colorStr)
					else
						playAnimation(iHeroIndex,strSkill,flag, nil,nil,nil,iAciton,hero,colorStr)
					end
					break
				elseif mod == 9 then
					local effectid_index = nil--arrNum[3]
					local effectid = nil
					local strEffect = nil
					for i,v in pairs(arrNum) do
						if string.sub(v,1,1) == "E" then
							effectid_index = tonumber(string.sub(v,2,2))
							effectid = tonumber(arrTmp[effectid_index + 1])
							break
						end
					end
					if effectid and effectName[effectid] then 
						strEffect = effectName[effectid]
					end
					
					if strEffect then
						playAnimation(iHeroIndex,strEffect,false, nil,nil,nil,iAciton,hero,colorStr)
					else
						if flag or hero then
							BattlaAnimationUI.playAnimationByCallback(hero)
						end
					end
					break
				end
			elseif str =="S" then
				-- if iAciton == actionDefine.passiveSkill or iAciton ==actionDefine.playSkillBefore
				-- 	or iAciton == actionDefine.playSkillAfter or iAciton == actionDefine.playAttack then
				-- 	displaySkillName(Tb_cfg_skill[tonumber(arrTmp[index+1])].name)
				-- end
			elseif str =="E" then
				-- if flag then
				-- 	BattlaAnimationUI.playAnimationByCallback()
				-- end
			elseif str == "D" then
				if isH and flag then
					-- displayNum( BattlaAnimationUI.getArrCard(iHeroIndex),tonumber(arrTmp[index+1]),true )
				else
					displayNum( iHeroIndex,BattlaAnimationUI.getArrCard(iHeroIndex),num,false,hero,colorStr,iAciton )
				end
			end
		end
	end
end

local function setSpeed( )
	local times = 1/dt
	if times >=2 then
		dt = 1
	else
		dt = dt/(times+1)
	end
end

local function getSpeed( )
	return dt
end

--
local function actionBystep(strtext, arrTmp, flag, hero)
	if not strtext or string.len(strtext) <= 0 then
		if flag or hero then
			BattlaAnimationUI.playAnimationByCallback(hero)
		end
	end
	local arrNum = stringFunc.anlayerOnespot(strtext, ";", false)
	if not arrNum then
		if flag or hero then
			BattlaAnimationUI.playAnimationByCallback(hero)
		end
		return false
	end

	if not tonumber(arrNum[1]) then
	elseif tonumber(arrNum[1]) == 0 then
		-- playAnimation( BattlaAnimationUI.getRootWidget(),warRoundKeyword[tonumber(arrTmp[1])][3],true,hero)
		
		local function removeSelf(armature, eventType, name )
			if eventType == 1 then
				if warRoundKeyword[tonumber(arrTmp[1])][3] == "01_zhandoukaishi" then
					armature:removeFromParentAndCleanup(true)
				end
				BattlaAnimationUI.playAnimationByCallback()
				for i=1, 8 do
					local object = BattlaAnimationUI.getPrepareSkill(i)
					if object then
						object:removeFromParentAndCleanup(true)
					end
					BattlaAnimationUI.setPrepareSkill(i,nil)
				end
			end
		end
		if animationToMusic[warRoundKeyword[tonumber(arrTmp[1])][3]] then
			LSound.playSound(animationToMusic[warRoundKeyword[tonumber(arrTmp[1])][3]])
		end

		--在战斗开始的时候将军师隐藏
		if warRoundKeyword[tonumber(arrTmp[1])][3] == "01_zhandoukaishi" then
			for i=1, 8, 7 do
				local target = BattlaAnimationUI.getArrCard(i)
				if target then
					target:runAction(CCFadeOut:create(0.5*dt))
				end
			end
		end

		local armature = CCArmature:create(warRoundKeyword[tonumber(arrTmp[1])][3])
    	armature:getAnimation():playWithIndex(0)
    	armature:getAnimation():setSpeedScale(armature:getAnimation():getSpeedScale()/dt)
    	armature:setPosition(cc.p(BattlaAnimationUI.getRootWidget():getContentSize().width/2,BattlaAnimationUI.getRootWidget():getContentSize().height/2))
    	BattlaAnimationUI.getRootWidget():addChild(armature,2,2)
    	armature:getAnimation():setMovementEventCallFunc(removeSelf)
    elseif tonumber(arrNum[1]) == 8 then
    	if tonumber(arrTmp[1]) == actionDefine.effectExsit or tonumber(arrTmp[1]) == actionDefine.strongEffectExsit then
			local target = BattlaAnimationUI.getArrCard(tonumber(arrTmp[2])+1)
			if target then
				local sprite = cc.Sprite:createWithSpriteFrameName("20_wuliao.png")
				target:addChild(sprite)
				sprite:setPosition(cc.p(target:getContentSize().width/2, target:getContentSize().height/2))
				sprite:runAction(animation.sequence({CCFadeOut:create(1*dt), cc.CallFunc:create(function ()
					sprite:removeFromParentAndCleanup(true)
					if hero or flag then
						BattlaAnimationUI.playAnimationByCallback(hero)
					end
				end)}))
			end
		else
			BattlaAnimationUI.setDead(tonumber(arrTmp[2])+1)
			local object = BattlaAnimationUI.getPrepareSkill(tonumber(arrTmp[2])+1)
			if object then
				object:removeFromParentAndCleanup(true)
			end
			BattlaAnimationUI.setPrepareSkill(tonumber(arrTmp[2])+1,nil)
			if hero then
				BattlaAnimationUI.playAnimationByCallback(hero)
			end
		end
	elseif (tonumber(arrNum[1]) >= 1 and tonumber(arrNum[1]) <= 7) or tonumber(arrNum[1]) == 9 then
		analyzeStr(arrNum, tonumber(arrNum[1]), arrTmp, flag,hero)
	end
end

local function setOver( flag )
	m_over = flag
end

local function getOver(  )
	return m_over
end

BattleAction = {
					actionBystep = actionBystep,
					downAction = downAction,
					upAction = upAction,
					downActionOrUpAction = downActionOrUpAction,
					setSpeed = setSpeed,
					getSpeed = getSpeed,
					setOver = setOver,
					getOver = getOver
}