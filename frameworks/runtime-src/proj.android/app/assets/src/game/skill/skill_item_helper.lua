local skillItemHelper = {}
skillItemHelper.LAYOUT_TYPE_SKILL_OVER_VIEW = 1 -- 技能总览
skillItemHelper.LAYOUT_TYPE_SKILL_OVER_VIEW_CARD_LEARN = 8 -- 技能总览 （武将卡学习技能）
skillItemHelper.LAYOUT_TYPE_SKILL_DETAIL_STUDY = 2 -- 技能详情研究
skillItemHelper.LAYOUT_TYPE_SKILL_DETAIL_LEARN = 3 -- 技能详情学习
skillItemHelper.LAYOUT_TYPE_SKILL_DETAIL_STRENGTH = 4 -- 技能详情强化
skillItemHelper.LAYOUT_TYPE_SKILL_OP_STUDY = 5 -- 技能操作研究
skillItemHelper.LAYOUT_TYPE_GAIN_SKILL_LAYER = 6 -- 获得新技能
skillItemHelper.LAYOUT_TYPE_SKILL_PROGRESS_STUDY = 7 -- 技能操作研究进度

-- 由于有小图标遮挡住了部分区域 需要对真实的比例转换成精确的显示比例
local function converViewProgressPercent(percent)
	if true then return percent end
	-- 视图的比例 2 ~ 96
	local ret_p = 0
	local view_p_begin = 2
	local view_p_end = 96
	ret_p = view_p_begin + (percent / 100) * (view_p_end - view_p_begin)
	return ret_p
end


local function progressTimerAction( progressTimer,fromPercentage,toPercentage,duration ,callback)
    if not duration then duration = 0.3 end
    local ac = CCProgressFromTo:create(duration,fromPercentage,toPercentage)
    local fc = cc.CallFunc:create(function ( )
        if callback then callback() end
    end)
    progressTimer:runAction(animation.sequence({ac,fc}))
end


local function testRun(progressTimerBg)
		
	progressTimerAction(progressTimerBg.next,converViewProgressPercent(0),converViewProgressPercent(100),2)
	
	progressTimerAction(progressTimerBg.cur,converViewProgressPercent(0),converViewProgressPercent(100),3,function()
		testRun(progressTimerBg)
	end)
end
    
-- 技能研究度  进度条 预估效果
function skillItemHelper.effectSutdyProgressCalculate(progressTimerBg,skillId,vTmp,vChange)
	if true then return end
	-- 唉 悲剧了 --TODOTK

	local flagAdding = vChange > 0

	local curProgress,maxProgress = SkillDataModel.getSkillStudyProgressInfo(skillId)
	local curProgressCalc = vTmp - vChange
	local retProgressCalc = vTmp

	local curPercent = curProgress % 100
	local curPercentCalc = curProgressCalc % 100
	local retPercentCalc = retProgressCalc % 100

	local curLv = math.floor( curProgress / 100 )
	local curLvCalc = math.floor( curProgressCalc / 100 )
	local retLvCalc = math.floor( retProgressCalc / 100 )
	-- 真实的数据
	-- local lvCur = math.floor( curProgress / 100 )
	-- local pCur = curProgress %100
	-- -- 当前的预测数据
	-- local lvCalcCur = math.floor( (vTmp - vChange) / 100 )
	-- local pCalcCur = (vTmp - vChange) % 100
	-- -- 加上 vChange 后的预测数据
	-- local lvCalcRet = math.floor( vTmp / 100 )
	-- local pCalcRet = vTmp % 100



	progressTimerBg.next:setVisible(true)
	

	

	-- if (curLvCalc > curLv) and (curPercentCalc > 0) then 
	-- 	progressTimerBg.cur:setVisible(false)
	-- else
	-- 	progressTimerBg.cur:setVisible(true)
	-- end




	local processTab = {}
	

	if vChange > 0 then
		while vChange  > 0 do
			if curPercentCalc + vChange < 100 then
				curProgressCalc = curProgressCalc + vChange
				table.insert(processTab,{
					math.floor(curProgressCalc/100), 
					curPercentCalc,
					curPercentCalc + vChange})
				curPercentCalc = curPercentCalc + vChange
				vChange = 0
			
			else
				local tmp = 100 - curPercentCalc
				table.insert(processTab,{
					math.floor(curProgressCalc/100), 
					curPercentCalc,
					100})
				vChange = vChange - tmp
				curProgressCalc = curProgressCalc + tmp

				if vChange > 0 then
					local tmp = 100 - curPercentCalc

					vChange = vChange - tmp
					curProgressCalc = curProgressCalc + tmp
					table.insert(processTab,{
						math.floor(curProgressCalc/100), 
						curPercentCalc,
						100})
					curPercentCalc = 0
				end
			end
		end
	elseif vChange < 0 then 
		while vChange < 0 do 
			if curPercentCalc + vChange > 0 then 
				curProgressCalc = curProgressCalc + vChange
				table.insert(processTab,{
					math.floor(curProgressCalc/100), 
					curPercentCalc,
					curPercentCalc + vChange})
				curPercentCalc = curPercentCalc + vChange
				vChange = 0
			else
				curProgressCalc = curProgressCalc - curPercentCalc
				vChange = vChange + curPercentCalc
				table.insert(processTab,{
					math.floor(curProgressCalc/100),
					curPercentCalc,
					0})
				curPercentCalc = 0
				
				if vChange <0 then
					curProgressCalc = curProgressCalc - curPercentCalc
					vChange = vChange + curPercentCalc
					table.insert(processTab,{
						math.floor(curProgressCalc/100),
						curPercentCalc,
						0})
					curPercentCalc = 100
				end
			end
		end
	end

	
	for k,v in ipairs(processTab) do 

	end

	local function runProcess()
		if #processTab <= 0 then return end
		local process = table.remove(processTab)
		if process[1] == curLv then 
			progressTimerBg.cur:setVisible(true)
		else
			progressTimerBg.cur:setVisible(false)
		end
		progressTimerAction( 
			progressTimerBg.next,
			converViewProgressPercent(process[2]),
			converViewProgressPercent(process[3]),
			0.2 ,
			runProcess)
	end
	runProcess()
end

-- 技能研究度 进度条 提升后效果
function skillItemHelper.effectStudyProgressResult(progressTimerBg,skillId,vTmp,vChange)
	-- TODOTK
	
end


local function fetchTimerProgressSP( radius,r,g,b,a)
	local node = CCDrawNode:create()
	node:drawDot(cc.p(radius,radius), radius, ccc4f(r,g,b,a))

	local render = CCRenderTexture:create(radius*2, radius*2,kCCTexture2DPixelFormat_RGBA8888)
	render:begin()
	node:visit()
	render:endToLua()

	return cc.Sprite:createWithTexture(render:getSprite():getTexture())
end

function skillItemHelper.expectedProgressing(widget,progressTimerBg,progressTimerBgExpecting ,progressCur,proggressChange,progressCurIndeed)
	if not widget then return end

	local total_percent =  progressCur + proggressChange
	if total_percent > 100 then total_percent = 100 end
	
	progressTimerBg:setPercentage( 100 - total_percent )

	progressTimerBgExpecting:setPercentage( (total_percent - progressCurIndeed) )

	progressTimerBgExpecting:setRotation(360 * (progressCurIndeed / 100) )
	progressTimerBgExpecting:setVisible(true)
end
-- skillItemHelper.LAYOUT_TYPE_SKILL_OVER_VIEW = 1 -- 卡牌总览
-- skillItemHelper.LAYOUT_TYPE_SKILL_OVER_VIEW_CARD_LEARN = 8 -- 卡牌总览 （武将卡学习技能）
-- skillItemHelper.LAYOUT_TYPE_SKILL_DETAIL_STUDY = 2 -- 技能详情研究
-- skillItemHelper.LAYOUT_TYPE_SKILL_DETAIL_LEARN = 3 -- 技能详情学习
-- skillItemHelper.LAYOUT_TYPE_SKILL_DETAIL_STRENGTH = 4 -- 技能详情强化
-- skillItemHelper.LAYOUT_TYPE_SKILL_OP_STUDY = 5 -- 技能操作研究
-- skillItemHelper.LAYOUT_TYPE_GAIN_SKILL_LAYER = 6 -- 获得新技能
-- skillItemHelper.LAYOUT_TYPE_SKILL_PROGRESS_STUDY = 7 -- 技能操作研究进度

function skillItemHelper.setViewLayout(layoutType)

end

function skillItemHelper.loadSkillInfoNonskill()

end

function skillItemHelper.loadSkillInfo(widget,progressTimerBg,skillId,viewType,skillLv,heroUid,lockProgressTimerBgChanged)

	if not widget then return end

	local skillInfo = SkillDataModel.getUserSkillInfoById(skillId)
	local cfgSkillInfo = Tb_cfg_skill[skillId]

	--------------- 只有技能总览界面需要这个背景
	local img_bg = uiUtil.getConvertChildByName(widget,"img_bg")	
	if viewType == skillItemHelper.LAYOUT_TYPE_SKILL_OVER_VIEW or 
		viewType == skillItemHelper.LAYOUT_TYPE_SKILL_OVER_VIEW_CARD_LEARN then
		img_bg:setVisible(true)
	else
		img_bg:setVisible(false)
	end
	
	--------------- 只有被用的场合 或 可用的场合 才使用此背景
	local img_bg_left = uiUtil.getConvertChildByName(widget,"img_bg_left")
	local img_bg_right = uiUtil.getConvertChildByName(widget,"img_bg_right")
	img_bg_left:setVisible(false)
	img_bg_right:setVisible(false)
	if viewType == skillItemHelper.LAYOUT_TYPE_SKILL_DETAIL_STRENGTH  
	   or viewType == skillItemHelper.LAYOUT_TYPE_GAIN_SKILL_LAYER 
	   or viewType == skillItemHelper.LAYOUT_TYPE_SKILL_DETAIL_LEARN then 
		img_bg_left:setVisible(true)
		img_bg_right:setVisible(true)
	elseif viewType == skillItemHelper.LAYOUT_TYPE_SKILL_OVER_VIEW
		or viewType == skillItemHelper.LAYOUT_TYPE_SKILL_OVER_VIEW_CARD_LEARN
		or viewType == skillItemHelper.LAYOUT_TYPE_SKILL_DETAIL_STUDY then
		if skillInfo and skillInfo.study_progress == 100 then 
			img_bg_left:setVisible(true)
			img_bg_right:setVisible(true)
		end
	end

	---------------  武将学习技能 技能总览   特有
	-- 兵种不符
	local img_illegal_soldier = uiUtil.getConvertChildByName(widget,"img_illegal_soldier")
	img_illegal_soldier:setVisible(false)
	-- 阵营不符
	local img_illegal_country = uiUtil.getConvertChildByName(widget,"img_illegal_country")
	img_illegal_country:setVisible(false)
	-- 已学习
	local img_illegal_learned = uiUtil.getConvertChildByName(widget,"img_illegal_learned")
	img_illegal_learned:setVisible(false)

	if viewType == skillItemHelper.LAYOUT_TYPE_SKILL_OVER_VIEW_CARD_LEARN then 
			
		local cfgSkillResearchInfo = Tb_cfg_skill_research[skillId]
		local flag_fit = true
		if cfgSkillResearchInfo then 
			----------------------- 从上到下优先级顺序 --- 三种限制 只会展示一种
			local heroInfo = heroData.getHeroInfo(heroUid)
			local cfgHeroInfo = Tb_cfg_hero[heroInfo.heroid]
			-- 是否已学习
			if SkillDataModel.isSkillLearnedByHeroId(heroUid,skillId) then 
				img_illegal_learned:setVisible(true)
				flag_fit = false
			end


			if flag_fit then 
				-- 阵营限制
				
				if cfgSkillResearchInfo.allow_country and #cfgSkillResearchInfo.allow_country >0 then 
					flag_fit = false
					for k,v in ipairs(cfgSkillResearchInfo.allow_country) do 
						if cfgHeroInfo.country == v then 
							flag_fit = true
						end
					end
				else
					flag_fit = true
				end
				if not flag_fit then 
					img_illegal_country:setVisible(true)
				end
			end
			-- 兵种限制
			if flag_fit then
				if cfgSkillResearchInfo.allow_type and #cfgSkillResearchInfo.allow_type >0 then 
					flag_fit = false
					for k,v in ipairs(cfgSkillResearchInfo.allow_type) do 
						if cfgHeroInfo.hero_type == v then 
							flag_fit = true
						end
					end
				else
					flag_fit = true
				end
				if not flag_fit then 
					img_illegal_soldier:setVisible(true)
				end
			end
			-- 品质限制  现在暂时不处理
		end
	end



	-------------------------------------------- 研究进度信息   
	local panel_progress_study = uiUtil.getConvertChildByName(widget,"panel_progress_study")
	panel_progress_study:setBackGroundColorType(LAYOUT_COLOR_NONE)
	local label_progress = uiUtil.getConvertChildByName(panel_progress_study,"label_progress")
	local img_progress = uiUtil.getConvertChildByName(panel_progress_study,"ImageView_837702")
	panel_progress_study:setVisible(true)
	--研究度达到100%后就不需要显示“100%&研究进度”；”
	if skillInfo then 
		label_progress:setText(skillInfo.study_progress .. "%")
		if skillInfo.study_progress == 100 then 
			panel_progress_study:setVisible(false)
		end
	end

	if viewType == skillItemHelper.LAYOUT_TYPE_SKILL_DETAIL_STRENGTH then 
		panel_progress_study:setVisible(false)
	end
	tolua.cast(label_progress:getVirtualRenderer(),"CCLabelTTF"):enableStroke(ccc3(0,0,0),2,true)

	if viewType == skillItemHelper.LAYOUT_TYPE_SKILL_OVER_VIEW or 
		viewType == skillItemHelper.LAYOUT_TYPE_SKILL_OVER_VIEW_CARD_LEARN then 
		img_progress:setVisible(false)
		label_progress:setVisible(true)
	else
		img_progress:setVisible(true)
		label_progress:setVisible(true)
	end

	-- local heroNameLayer = nil
	-- heroNameLayer = uiUtil.getConvertChildByName(panel_progress_study,"heroNameLayer")
	-- if not heroNameLayer then 
	-- 	heroNameLayer = CCLabelTTF:create(skillInfo.study_progress .. "%",config.getFontName(), 20, CCSize(600, 31), kCCTextAlignmentCenter)
	-- 	heroNameLayer:setPosition(cc.p(panel_progress_study:getSize().width/2,panel_progress_study:getSize().height/2))
	-- 	heroNameLayer:setAnchorPoint(cc.p(0.5,0.5))
	-- 	heroNameLayer:enableStroke(ccc3(0,0,0),2,true)
	-- 	heroNameLayer:setColor(ccc3(255,243,195))
	-- 	panel_progress_study:addChild(heroNameLayer)
	-- else
	-- 	heroNameLayer:setText(skillInfo.study_progress .. "%")
	-- 	print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>> setText")
	-- end



	local current_skill_type = cfgSkillInfo.skill_type -- 1 被动 2指挥  3战法 4追击

	---------------------------- 技能类型的背景框  
	local img_skillItemBg = uiUtil.getConvertChildByName(widget,"img_skillItemBg")
	img_skillItemBg:setVisible(true)
	img_skillItemBg:loadTexture(ResDefineUtil.ui_card_skill_typeD[current_skill_type],UI_TEX_TYPE_PLIST)



	---------- 技能类型的标示图


	local img_skill_type_a = uiUtil.getConvertChildByName(widget,"img_skill_type_a")
	img_skill_type_a:loadTexture(ResDefineUtil.ui_card_skill_typeA[current_skill_type],UI_TEX_TYPE_PLIST)
	img_skill_type_a:setVisible(true)
	img_bg_left:loadTexture(ResDefineUtil.ui_card_skill_typeC[current_skill_type],UI_TEX_TYPE_PLIST)
	img_bg_right:loadTexture(ResDefineUtil.ui_card_skill_typeC[current_skill_type],UI_TEX_TYPE_PLIST)
	img_bg_right:setFlipX(true)
	

	-- 只有强化中的才需要现实 等级tips
	local img_tips = uiUtil.getConvertChildByName(img_skill_type_a,"img_tips")
	img_tips:setVisible(false)
	local label_tips = uiUtil.getConvertChildByName(img_tips,"label_tips")
	if viewType == skillItemHelper.LAYOUT_TYPE_SKILL_DETAIL_STRENGTH then 
		img_tips:setVisible(true)
		if skillLv then 
			label_tips:setText(languagePack["lv"] .. skillLv)
		end
	end

	------  研究中的技能 需要灰化
	if viewType ~= skillItemHelper.LAYOUT_TYPE_SKILL_DETAIL_STRENGTH and skillInfo and (skillInfo.study_progress < 100)  then 
		-- 灰色状态切换 
		GraySprite.create(img_skill_type_a)
	else
		GraySprite.create(img_skill_type_a,nil,true)
	end
	GraySprite.create(img_tips,nil,true)
	GraySprite.create(label_tips,nil,true)

	-- 研究数信息  TODOTK 什么时候不显示
	local img_skill_type_b = uiUtil.getConvertChildByName(widget,"img_skill_type_b")
	local label_learn_count = uiUtil.getConvertChildByName(img_skill_type_b,"label_learn_count")
	img_skill_type_b:setVisible(true)

	if viewType == skillItemHelper.LAYOUT_TYPE_SKILL_DETAIL_STRENGTH then
		img_skill_type_b:setVisible(false)
	end
	if skillInfo then 
		
		if skillInfo.learn_count_retain < 1 and skillInfo.study_progress == 100  then 
			-- 可学习数耗尽
			-- label_learn_count:setColor(ccc3(161,161,161))
			label_learn_count:setColor(ccc3(202,75,75))
		elseif skillInfo.learn_count_retain < 1 and (skillInfo.study_progress < 100) then 
			-- 还不能学习 没研究成功
			-- label_learn_count:setColor(ccc3(202,75,75))
			label_learn_count:setColor(ccc3(161,161,161))
		else
			-- 研究成功 还有可学习数
			label_learn_count:setColor(ccc3(255,243,195))
		end

		if skillInfo.learn_count_retain <= 0 then 
			if skillInfo.study_progress < 100 then
				label_learn_count:setText("-/" .. skillInfo.study_count_max )
			else
				label_learn_count:setText(skillInfo.learn_count_retain .. "/" .. skillInfo.study_count_max )
			end	
		else
			label_learn_count:setText(skillInfo.learn_count_retain .. "/" .. skillInfo.study_count_max )
		end
	end
	


	-- 技能名字
	local label_skill_name = uiUtil.getConvertChildByName(widget,"label_skill_name")
	label_skill_name:setVisible(false)
	label_skill_name:setText(cfgSkillInfo.name)

	if viewType == skillItemHelper.LAYOUT_TYPE_SKILL_OVER_VIEW_CARD_LEARN 
		or viewType == skillItemHelper.LAYOUT_TYPE_SKILL_OVER_VIEW then 
		label_skill_name:setVisible(true)
	end


	progressTimerBg:setVisible(false)
	if skillInfo then
		progressTimerBg:setVisible(true)
		if not lockProgressTimerBgChanged then 
			progressTimerBg:setPercentage( 100 - skillInfo.study_progress)
		end
	end

	if viewType == skillItemHelper.LAYOUT_TYPE_SKILL_DETAIL_STRENGTH then 
		progressTimerBg:setVisible(false)
	end
end



local function createProgressTimer( bgBarImg,progressBarImg ,progressNextBarImg) 
    local bg = cc.Sprite:createWithSpriteFrameName(bgBarImg)
    local curSprite = cc.Sprite:createWithSpriteFrameName(progressBarImg)
    local nextSprite = cc.Sprite:createWithSpriteFrameName(progressNextBarImg)
    
   
	local progressTimerNext = CCProgressTimer:create(nextSprite)
	progressTimerNext:setType(kCCProgressTimerTypeRadial) 
    progressTimerNext:setRotation(-215)
    progressTimerNext:setPosition(cc.p(bg:getContentSize().width/2,bg:getContentSize().height/2)) 
    bg:addChild(progressTimerNext)
    bg.next = progressTimerNext

    local progressTimer = CCProgressTimer:create(curSprite)
    progressTimer:setType(kCCProgressTimerTypeRadial) 
    progressTimer:setRotation(-215)
    progressTimer:setPosition(cc.p(bg:getContentSize().width/2,bg:getContentSize().height/2)) 
    bg:addChild(progressTimer)
    bg.cur = progressTimer
    return bg
end




function skillItemHelper.setSelectedState(widget,isSelected)
	if not widget then return end
	local img_flag_selected = uiUtil.getConvertChildByName(widget,"img_flag_selected")
	if not img_flag_selected then return end
	img_flag_selected:setVisible(isSelected)
end

function skillItemHelper.resetProgressTimerBg(widget,progressTimerBg)
	if not widget then return end
	if not progressTimerBg then return end
	
	local panel_progress = uiUtil.getConvertChildByName(widget,"panel_progress")

	progressTimerBg:removeFromParentAndCleanup(false)

	panel_progress:addChild(progressTimerBg)
	progressTimerBg:ignoreAnchorPointForPosition(false)
	progressTimerBg:setAnchorPoint(cc.p(0.5,0.5))
	progressTimerBg:setPosition(cc.p(panel_progress:getSize().width/2,panel_progress:getSize().height/2))
		
end



function skillItemHelper.createWidgetItem(isSkill,needExpectingProgress)
	local widget = nil

	local progressTimerBg = nil -- 万恶的 Widget CCNode tag通道不统一啊
	local progressTimerBgExpecting = nil
	widget = GUIReader:shareReader():widgetFromJsonFile("test/jinengxiangqing_4.json")

	local panel_progress = uiUtil.getConvertChildByName(widget,"panel_progress")
	panel_progress:setBackGroundColorType(LAYOUT_COLOR_NONE)

	--TODOTK 编辑器里删除
	local img_progress_a = uiUtil.getConvertChildByName(panel_progress,"img_progress_a")
	local img_progress_b = uiUtil.getConvertChildByName(panel_progress,"img_progress_b")
	local img_progress_c = uiUtil.getConvertChildByName(panel_progress,"img_progress_c")
	img_progress_a:removeFromParentAndCleanup(true)
	img_progress_b:removeFromParentAndCleanup(true)
	img_progress_c:removeFromParentAndCleanup(true)
	

	local img_skill_type_a = uiUtil.getConvertChildByName(widget,"img_skill_type_a")
	local timerItem = nil
	timerItem= fetchTimerProgressSP( img_skill_type_a:getSize().width/2 , 0,0,0,0.64)
	timerItem:getTexture():setAntiAliasTexParameters()
	progressTimerBg = CCProgressTimer:create(timerItem)
	progressTimerBg:setReverseDirection(true)
	progressTimerBg:setType(kCCProgressTimerTypeRadial)
	progressTimerBg:setPosition(cc.p(panel_progress:getSize().width/2, panel_progress:getSize().height/2))
	panel_progress:addChild(progressTimerBg)



	
	local img_skill_type_a = uiUtil.getConvertChildByName(widget,"img_skill_type_a")
	local curSprite = cc.Sprite:createWithSpriteFrameName("jineng_jiazai_01.png")
	curSprite:setOpacity(160)
	-- timerItem= fetchTimerProgressSP( img_skill_type_a:getSize().width/2, 41,192,214,0.64)
	-- timerItem:getTexture():setAntiAliasTexParameters()
	progressTimerBgExpecting = CCProgressTimer:create(curSprite)
	progressTimerBgExpecting:setReverseDirection(false)
	progressTimerBgExpecting:setType(kCCProgressTimerTypeRadial)
	progressTimerBgExpecting:setPosition(cc.p(panel_progress:getSize().width/2 , panel_progress:getSize().height/2))
	panel_progress:addChild(progressTimerBgExpecting)


	skillItemHelper.setSelectedState(widget,false)
	
	return widget,progressTimerBg,progressTimerBgExpecting
end

local function playArmatureOnce(file,parent,posx,posy)
    if not parent then return end
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/" .. file .. ".ExportJson")
    local armature = CCArmature:create(file)
    
    armature:getAnimation():playWithIndex(0)
    parent:addChild(armature,999,999)
    armature:setPosition(cc.p(posx , posy))
    armature:setScale(0.8)
    loadingLayer.create(nil,false)
    local function animationCallFunc(armatureNode, eventType, name)
        if eventType == 1 or eventType == 2 then
            armatureNode:removeFromParentAndCleanup(true)
            armature = nil
            loadingLayer.remove()
            CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("Export/" .. file .. ".ExportJson")
        end
    end
    armature:getAnimation():setMovementEventCallFunc(animationCallFunc)
end 

function skillItemHelper.playArmatureEffect(widget,file)
	local img_bg = uiUtil.getConvertChildByName(widget,"img_bg")
	playArmatureOnce(file,widget,img_bg:getPositionX(),img_bg:getPositionY())
end


return skillItemHelper